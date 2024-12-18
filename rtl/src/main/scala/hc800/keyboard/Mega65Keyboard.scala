package hc800.keyboard

import spinal.core._
import spinal.lib._


case class mega65kbd_to_matrix() extends BlackBox {
	val io = new Bundle {
		val ioclock_i        = in Bool()

		val flopmotor_i      = in Bool()
		val flopled_i        = in Bool()
		val powerled_i       = in Bool()

		val kio8_o           = out Bool()   // clock to keyboard
		val kio9_o           = out Bool()   // data output to keyboard
		val kio10_i          = in  Bool()    // data input from keyboard

		val matrix_col_o     = out Bits(8 bits)
		val matrix_col_idx_i = in  UInt(4 bits)  // 0 to 9

		val delete_out_o     = out Bool()
		val return_out_o     = out Bool()
		val fastkey_out_o    = out Bool()

		// RESTORE and capslock are active low
		val restore_o        = out Bool()
		val capslock_out_o   = out Bool()

		// LEFT and UP cursor keys are active HIGH
		val leftkey_o        = out Bool()
		val upkey_o          = out Bool()
	}

	noIoPrefix()

	mapClockDomain(clock = io.ioclock_i)
}


case class Mega65MatrixToScanCode() extends Component {
	val io = new Bundle {
		val row     = in Bits(3 bits)
		val column  = in Bits(4 bits)

		val scanCode = out Bits(7 bits)
	}

	private val codes = io.column.mux (
		0 -> Vec(U"xFF", U"x10", U"x02", U"xFF", U"xFF", U"xFF", U"xFF", U"xFF" ),		// ?, UP, LEFT, RESTORE, RIGHT_SHIFT, RETURN?, CAPS_LOCK, ?
		1 -> Vec(U"x08", U"xFF", U"x06", U"x18", U"x12", U"x14", U"x16", U"x0E" ),		// INST/DEL?, RETURN?, RIGHT, F7, F1, F3, F5, DOWN
		2 -> Vec(U"x33", U"x57", U"x41", U"x34", U"x5A", U"x53", U"x45", U"x62" ),		// 3, W, A, 4, Z, S, E, LEFT_SHIFT
		3 -> Vec(U"x35", U"x52", U"x44", U"x36", U"x43", U"x46", U"x54", U"x58" ),		// 5, R, D, 6, C, F, T, X
		4 -> Vec(U"x37", U"x59", U"x47", U"x38", U"x42", U"x48", U"x55", U"x56" ),		// 7, Y, G, 8, B, H, U, V
		5 -> Vec(U"x39", U"x49", U"x4A", U"x30", U"x4D", U"x4B", U"x4F", U"x4E" ),		// 9, I, J, 0, M, K, O, N
		6 -> Vec(U"xFF", U"x50", U"x3B", U"x2D", U"x2E", U"xFF", U"xFF", U"x2C" ),		// +, P, L, -, ., ;, @, ,
		7 -> Vec(U"xFF", U"xFF", U"x4C", U"x01", U"x63", U"x3D", U"xFF", U"x2F" ),		// £, *, ;, CLR_HOME, RIGHT_SHIFT, =, ARROW_UP, /
		8 -> Vec(U"x31", U"xFF", U"x65", U"x32", U"x20", U"xFF", U"x51", U"xFF" ),		// 1, ARROW_LEFT, CTRL, 2, SPACE, C=, Q, ?
		9 -> Vec(U"xFF", U"x09", U"x64", U"xFF", U"x1C", U"xFF", U"xFF", U"x1B" ),		// NO_SCROLL, TAB, ALT, HELP, F9, F11, F13, ESC
		default -> Vec(U"xFF", U"xFF", U"xFF", U"xFF", U"xFF", U"xFF", U"xFF", U"xFF")
	)

	io.scanCode := codes(io.row.asUInt).asBits.resize(7)
}


case class Mega65KeyboardBusIO() extends KeyboardBusIO {
	val kio8_o  = out Bool()   // clock to keyboard
	val kio9_o  = out Bool()   // data output to keyboard
	val kio10_i = in Bool()    // data input from keyboard
}


case class Mega65Keyboard() extends Keyboard(Mega65KeyboardBusIO()) {
	// MEGA65 keyboard matrix
	private val decoder = mega65kbd_to_matrix()

	io.kio8_o  <> decoder.io.kio8_o
	io.kio9_o  <> decoder.io.kio9_o
	io.kio10_i <> decoder.io.kio10_i

	decoder.io.flopmotor_i := False
	decoder.io.flopled_i   := False
	decoder.io.powerled_i  := True


	private val slowArea = new SlowArea(64) {
		val column_index = Reg(UInt(4 bits)) init(0)
		column_index := column_index.mux(
			U(9)    -> U(0),
			default -> (column_index + 1)
		)

		decoder.io.matrix_col_idx_i <> column_index

		private val rowsIn = RegNext(~decoder.io.matrix_col_o)
		private val matrix = Vec(Reg(Bits(8 bits)) init(0), 10)
		private val debouncedRows = matrix(column_index) & rowsIn
		matrix(column_index) := rowsIn

		private val debouncedMatrix = Vec(Reg(Bits(8 bits)) init(0), 10)
		private val rowsChanged = debouncedRows ^ debouncedMatrix(column_index)
		private val rowsPressed = debouncedRows & rowsChanged
		debouncedMatrix(column_index) := debouncedRows

		private val scanCode = Mega65MatrixToScanCode()
		scanCode.io.row    := 0
		scanCode.io.column := column_index.asBits

		private val capsLockState = Reg(Bool) init(False)

		val fifoPayload = Bits(8 bits)
		val fifoPush = Bool
		
		fifoPayload := 0
		fifoPush    := False

		private def keyStateChanged(row: Int): Unit = {
			scanCode.io.row := row
			when (scanCode.io.scanCode === B(0x61, 7 bits)) {
				// Handle caps lock case
				when (rowsPressed(row)) {
					fifoPush      := True
					fifoPayload   := (!capsLockState) ## scanCode.io.scanCode
					capsLockState := !capsLockState
				}
			}.otherwise {
				fifoPush := True
				fifoPayload := rowsPressed(row) ## scanCode.io.scanCode
			}
		}

		switch (rowsChanged) {
			is(M"-------1") { keyStateChanged(0) }
			is(M"------1-") { keyStateChanged(1) }
			is(M"-----1--") { keyStateChanged(2) }
			is(M"----1---") { keyStateChanged(3) }
			is(M"---1----") { keyStateChanged(4) }
			is(M"--1-----") { keyStateChanged(5) }
			is(M"-1------") { keyStateChanged(6) }
			is(M"1-------") { keyStateChanged(7) }
		}
	}


	fifo.io.push.valid := slowArea.fifoPush.rise
	fifo.io.push.payload := slowArea.fifoPayload
}
