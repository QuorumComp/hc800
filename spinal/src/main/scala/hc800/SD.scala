package hc800

import spinal.core._
import spinal.lib._

class SD extends Component {
	import SD._

    val io = new Bundle {
		val bus = slave(Bus(addressWidth = 1))

		val sd_cs = out Bits(2 bits)
		val sd_clock = out Bool()
		val sd_di = out Bool()
		val sd_do = in Bool()
    }

	// State

	val cardSelect = RegInit(B"00")
	val inDataEnabled = RegInit(False)
	val inDataProcessing = RegInit(False)
	val outDataProcessing = RegInit(False)
	val spiDataIn = RegInit(B(0, 8 bits))
	val spiDataOut = RegInit(B(0, 9 bits))
	val count = RegInit(U(0, 4 bits))
	val processing = inDataProcessing || outDataProcessing
	val fastClock = RegInit(True)

	// External interface

	val clockCount = RegInit(U(0, 5 bits))
	clockCount := clockCount + 1;

	val sdClock = RegInit(False)
	val shiftDataOut = RegInit(False)
	val shiftDataIn = RegInit(False)
	when (processing) {
		when (fastClock) {
			sdClock := clockCount(1)
			shiftDataOut := clockCount(1 downto 0) === 0
			shiftDataIn := clockCount(1 downto 0) === 2
		} otherwise {
			sdClock := clockCount(4)
			shiftDataOut := clockCount === 7
			shiftDataIn := clockCount === 23
		}
	} otherwise {
		sdClock := False
	}

	io.sd_cs := ~cardSelect
	io.sd_clock := sdClock

	when (processing && shiftDataOut) {
		when (count === 8) {
			count := 0
			inDataProcessing := False
			outDataProcessing := False
		} otherwise {
			count := count + 1
		}
	}

	when (inDataProcessing && shiftDataIn) {
		spiDataIn := spiDataIn(6 downto 0) ## io.sd_do;
	}

	when (outDataProcessing) {
		io.sd_di := spiDataOut(8)
		when (shiftDataOut) {
			spiDataOut := spiDataOut(7 downto 0) ## False;
		}
	} otherwise {
		io.sd_di := False
	}

	// Register interface

	val ioDataOut = Reg(Bits(8 bits))
	io.bus.dataToMaster := ioDataOut

	val busRegister = io.bus.address.as(Register())

	when (io.bus.enable && !io.bus.write) {
		ioDataOut := busRegister.mux (
			Register.data -> spiDataIn,
			Register.status -> B(fastClock ## cardSelect ## outDataProcessing ## inDataEnabled).resize(8 bits)
		)

		when (busRegister === Register.data) {
			inDataProcessing := inDataEnabled
		}
	} otherwise {
		ioDataOut := 0
	}

	when (io.bus.enable && io.bus.write) {
		switch (busRegister) {
			is (Register.data) {
				spiDataOut(7 downto 0) := io.bus.dataFromMaster
				spiDataOut(8) := io.bus.dataFromMaster(7)
				outDataProcessing := True
				clockCount := 0
			}
			is (Register.status) {
				fastClock := io.bus.dataFromMaster(4)
				cardSelect := io.bus.dataFromMaster(3 downto 2)

				val newInEnabled = io.bus.dataFromMaster(0)
				when (newInEnabled && !inDataEnabled) {
					inDataProcessing := True
				}
				inDataEnabled := newInEnabled
			}
		}
	}
}


object SD {
	object Register extends SpinalEnum(defaultEncoding = binarySequential) {
		val data, status = newElement()
	}

	import spinal.sim._
	import spinal.core.sim._

	def writeRegister(component: SD, reg: Int, value: Int): Unit = {
		component.clockDomain.waitRisingEdge()
		component.io.bus.address #= reg
		component.io.bus.dataFromMaster #= value & 0xFF
		component.io.bus.write #= true
		component.io.bus.enable #= true

		component.clockDomain.waitRisingEdge()
		component.io.bus.enable #= false
	}

	def readRegister(component: SD, reg: Int): Int = {
		component.clockDomain.waitRisingEdge()
		component.io.bus.address #= reg
		component.io.bus.write #= false
		component.io.bus.enable #= true

		component.clockDomain.waitRisingEdge()
		component.io.bus.enable #= false

		component.clockDomain.waitRisingEdge()
		val value = component.io.bus.dataToMaster.toInt

		//System.out.println(f"R$reg -> 0x$value%02X")
		value
	}

	def writeStatus(component: SD, value: Int): Unit = {
		writeRegister(component, Register.status.position, value & 0xFF)
	}

	def writeData(component: SD, value: Int): Unit = {
		writeRegister(component, Register.data.position, value & 0xFF)
	}

	def readStatus(component: SD): Int = {
		readRegister(component, Register.status.position)
	}

	def readData(component: SD): Int = {
		readRegister(component, Register.data.position)
	}

	def cardSelect(component: SD, select: Boolean): Unit = {
		writeStatus(component, (readStatus(component) & ~0x04) | (if (select) 0x04 else 0x00))
	}

	def waitReady(component: SD): Unit = {
		while ((readStatus(component) & 0x03) != 0) {}
	}

	def dataOut(component: SD, data: Int): Unit = {
		waitReady(component)
		writeData(component, data)
		waitReady(component)
	}

	def dataIn(component: SD): Int = {
		waitReady(component)
		writeStatus(component, readStatus(component) | 0x01)
		waitReady(component)
		readData(component)
	}

	def testCmd00(component: SD): Int = {
		cardSelect(component, true)

		dataOut(component, 0x40)
		dataOut(component, 0x0)
		dataOut(component, 0x0)
		dataOut(component, 0x0)
		dataOut(component, 0x0)
		dataOut(component, 0x95)

		val result = dataIn(component)

		cardSelect(component, false)

		result
	}

	def main(args: Array[String]) {
		import spinal.sim._
		import spinal.core.sim._
		SimConfig.withWave.compile(new SD).doSim { dut =>
			dut.io.bus.enable #= false
			dut.io.bus.write #= false
			dut.io.bus.address #= 0
			dut.io.bus.dataFromMaster #= 0

			// Fork a process to generate the reset and the clock on the dut
			dut.clockDomain.forkStimulus(period = 10)

			fork {
				while (true) {
					waitUntil((dut.io.sd_cs.toInt & 1) == 0)

					var count = 0
					var result = 0xA5
					while ((dut.io.sd_cs.toInt & 1) == 0) {
						dut.io.sd_do #= ((result >>> 7) & 1) != 0
						waitUntil(dut.io.sd_clock.toBoolean)
						result = ((result >> 7) & 1) | ((result & 0x7F) << 1)
						waitUntil(!dut.io.sd_clock.toBoolean)
					}
					sleep(1)
				}

			}

			for (t <- 0 to 20) {
				dut.clockDomain.waitRisingEdge()
			}

			testCmd00(dut)
		}
	}
}
