package hc800.keyboard

import spinal.core._
import spinal.lib._


case class MembraneMatrixToScanCode() extends Component {
	val io = new Bundle {
		val row     = in Bits(3 bits)
		val column  = in Bits(3 bits)

		val scanCode = out Bits(7 bits)
	}

	private val codes = io.row.mux (
		0 -> Vec(U"x62", U"x5A", U"x58", U"x43", U"x56", U"x65", U"x10" ),		// <SHIFT> (-> LSHIFT), Z, X, C, V, <EXTEND>, UP
		1 -> Vec(U"x41", U"x53", U"x44", U"x46", U"x47", U"x61", U"x66" ),		// A, S, D, F, G, CAPS LOCK, GRAPH
		2 -> Vec(U"x51", U"x57", U"x45", U"x52", U"x54", U"x71", U"x72" ),		// Q, W, E, R, T, TRUE VIDEO, INV VIDEO
		3 -> Vec(U"x31", U"x32", U"x33", U"x34", U"x35", U"x1B", U"x70" ),		// 1, 2, 3, 4, 5, BREAK, EDIT
		4 -> Vec(U"x30", U"x39", U"x38", U"x37", U"x36", U"x3B", U"x22" ),		// 0, 9, 8, 7, 6, ;, "
		5 -> Vec(U"x50", U"x4F", U"x49", U"x55", U"x59", U"x2C", U"x2E" ),		// P, O, I, U, Y, , .
		6 -> Vec(U"x0A", U"x4C", U"x4B", U"x4A", U"x48", U"x08", U"x06" ),		// ENTER, L, K, J, H, DELETE, RIGHT
		7 -> Vec(U"x20", U"x64", U"x4D", U"x4E", U"x42", U"x02", U"x0E" ),		// SPACE, SYMBOL SHIFT, M, N, B, LEFT, DOWN
	)

	io.scanCode := codes(io.column.asUInt).asBits.resize(7)
}


case class ZxNextKeyboardBusIO() extends KeyboardBusIO {
	val rows    = out Bits(8 bits)
	val columns = in  Bits(7 bits)
}

case class ZxNextMembrane() extends Keyboard(ZxNextKeyboardBusIO()) {
	import ZxNextMembrane._

	private val slowArea = new SlowArea(64) {
		private val rowOut = Reg(Bits(8 bits)) init(B"11111110")
		rowOut := rowOut.rotateLeft(1)

		io.rows := rowOut

		private val decodedRow = UInt(3 bits)
		val row = RegNext(decodedRow)
		switch (rowOut) {
			is(M"-------0") { decodedRow := 0 }
			is(M"------0-") { decodedRow := 1 }
			is(M"-----0--") { decodedRow := 2 }
			is(M"----0---") { decodedRow := 3 }
			is(M"---0----") { decodedRow := 4 }
			is(M"--0-----") { decodedRow := 5 }
			is(M"-0------") { decodedRow := 6 }
			is(M"0-------") { decodedRow := 7 }
			default { decodedRow := 0 }
		}

		private val columnsIn = RegNext(~io.columns)
		private val matrix = Vec(Reg(Bits(7 bits)) init(0), 8)
		private val debouncedColumns = matrix(row) & columnsIn
		matrix(row) := columnsIn

		private val debouncedMatrix = Vec(Reg(Bits(7 bits)) init(0), 8)
		private val columnsChanged = debouncedColumns ^ debouncedMatrix(row)
		private val columnsPressed = debouncedColumns & columnsChanged
		debouncedMatrix(row) := debouncedColumns

		private val scanCode = MembraneMatrixToScanCode()
		scanCode.io.column := 0
		scanCode.io.row    := row.asBits

		private val capsLockState = Reg(Bool) init(False)

		val fifoPayload = Bits(8 bits)
		val fifoPush = Bool
		
		fifoPayload := 0
		fifoPush := False

		private def keyStateChanged(column: Int): Unit = {
			scanCode.io.column := column
			when (scanCode.io.scanCode === B(0x61, 7 bits)) {
				// Handle caps lock case
				when (columnsPressed(column)) {
					fifoPush := True
					fifoPayload := (!capsLockState) ## scanCode.io.scanCode
					capsLockState := !capsLockState
				}
			}.otherwise {
				fifoPush := True
				fifoPayload := columnsPressed(column) ## scanCode.io.scanCode
			}
		}

		switch (columnsChanged) {
			is(M"------1") { keyStateChanged(0) }
			is(M"-----1-") { keyStateChanged(1) }
			is(M"----1--") { keyStateChanged(2) }
			is(M"---1---") { keyStateChanged(3) }
			is(M"--1----") { keyStateChanged(4) }
			is(M"-1-----") { keyStateChanged(5) }
			is(M"1------") { keyStateChanged(6) }
		}
	}

	fifo.io.push.valid := slowArea.fifoPush.rise
	fifo.io.push.payload := slowArea.fifoPayload

}


object ZxNextMembrane {
	import spinal.sim._
	import spinal.core.sim._

	def readRegister(membrane: ZxNextMembrane, reg: Int): Int = {
		membrane.clockDomain.waitRisingEdge()
		membrane.io.bus.address #= reg
		membrane.io.bus.enable #= true

		membrane.clockDomain.waitRisingEdge()
		membrane.io.bus.enable #= false

		membrane.clockDomain.waitRisingEdge()
		val value = membrane.io.bus.dataToMaster.toInt

		System.out.println(f"R$reg -> 0x$value%02X")
		value
	}

	def readStatus(membrane: ZxNextMembrane) =
		readRegister(membrane, Keyboard.Register.status.position)

	def readData(membrane: ZxNextMembrane) =
		readRegister(membrane, Keyboard.Register.data.position)

	def main(args: Array[String]) {
		import spinal.sim._
		import spinal.core.sim._
		SimConfig.withWave.doSim(new ZxNextMembrane) { dut =>
			fork {
				while (true) {
					if ((dut.io.rows.toInt & 0x10) == 0) {
						dut.io.columns #= 0x7E
					} else {
						dut.io.columns #= 0x7F
					}
					sleep(1)
				}
			}

			dut.clockDomain.forkStimulus(period = 10)

			dut.io.bus.enable #= false

			for (t <- 0 to 20) {
				dut.clockDomain.waitRisingEdge()
			}

			for (t <- 0 to 400) {
				if (readStatus(dut) != 0) {
					val data = readData(dut)
					System.out.println(f"Keycode 0x$data%02X")
				}

			}
		}
	}
}
