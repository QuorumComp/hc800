package hc800

import spinal.core._
import spinal.lib._

class SD extends Component {
	import SD._

    val io = new Bundle {
		val bus = slave(Bus(addressWidth = 2))

		val sd_cs		= out Bits(2 bits)	// card select, active low
		val sd_detect	= in  Bool()		// card detect, active low
		val sd_clock	= out Bool()
		val sd_mosi		= out Bool()
		val sd_miso		= in  Bool()
    }

	// State

	val cardSelect = RegInit(B"00")
	val inDataEnabled = RegInit(False)
	val shiftActive = RegInit(False)

	// Clock generator

	val slowClock = RegInit(True)
	val fastClock = RegInit(False)
	val clockCount = RegInit(U(0, 6 bits))

	val sdClock = Bool()
	val shiftDataOut = Bool()
	val shiftDataIn = Bool()
	val bitCount = RegInit(U(0, 4 bits))

	sdClock := False
	shiftDataIn := False
	shiftDataOut := False
	clockCount := clockCount + 1;

	when (shiftActive) {
		when (slowClock) {
			sdClock := clockCount(5)
			shiftDataOut := clockCount(5 downto 0) === 15
			shiftDataIn := clockCount(5 downto 0) === 47
		} elsewhen (fastClock) {
			sdClock := clockCount(1)
			shiftDataOut := clockCount(1 downto 0) === 0
			shiftDataIn := clockCount(1 downto 0) === 2
		}

		when (sdClock.fall()) {
			when (bitCount === 7) {
				shiftActive := False
			} otherwise {
				bitCount := bitCount + 1
			}
		}
	}

	/*
	when (cardSelect === 0) {
		shiftActive := False
	}

	*/

	// External interface

	io.sd_cs := ~cardSelect
	io.sd_clock := sdClock


	// Shift data in and out

	val spiDataIn = RegInit(B(0xFF, 8 bits))
	val spiDataOut = RegInit(B(0x1FF, 9 bits))

	io.sd_mosi := spiDataOut(8)

	when (shiftDataOut) {
		spiDataOut := spiDataOut(7 downto 0) ## True;
	}

	when (shiftDataIn) {
		spiDataIn := spiDataIn(6 downto 0) ## io.sd_miso;
	}


	// Register interface

	val ioDataOut = Reg(Bits(8 bits))
	io.bus.dataToMaster := ioDataOut

	val busRegister = io.bus.address.as(Register())

	// Strobe register

	when (io.bus.enable && busRegister === Register.data && !shiftActive) {
		// Touch the data register and shifting begins
		clockCount   := 0
		bitCount     := 0
		shiftActive  := True
		spiDataOut   := B(0x1FF, 9 bits)
	}

	// Read register

	when (io.bus.enable && !io.bus.write) {
		ioDataOut := busRegister.mux (
			Register.data   -> spiDataIn,
			Register.status -> B((~io.sd_detect) ## shiftActive).resize(8 bits),
			Register.select -> (fastClock ## slowClock ## cardSelect).resize(8 bits)
		)
	} otherwise {
		ioDataOut := 0
	}

	// Write register

	when (io.bus.enable && io.bus.write) {
		switch (busRegister) {
			is (Register.data) {
				spiDataOut(7 downto 0) := io.bus.dataFromMaster
				spiDataOut(8) := io.bus.dataFromMaster(7)
			}
			is (Register.select) {
				fastClock := io.bus.dataFromMaster(3)
				slowClock := io.bus.dataFromMaster(2)
				cardSelect := io.bus.dataFromMaster(1 downto 0)
			}
		}
	}
}


object SD {
	object Register extends SpinalEnum(defaultEncoding = binarySequential) {
		val data, status, select = newElement()
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

	def writeSelect(component: SD, value: Int): Unit = {
		writeRegister(component, Register.select.position, value & 0xFF)
	}

	def writeData(component: SD, value: Int): Unit = {
		writeRegister(component, Register.data.position, value & 0xFF)
	}

	def readStatus(component: SD): Int = {
		readRegister(component, Register.status.position)
	}

	def readSelect(component: SD): Int = {
		readRegister(component, Register.select.position)
	}

	def readData(component: SD): Int = {
		readRegister(component, Register.data.position)
	}

	def cardSelect(component: SD, select: Boolean): Unit = {
		writeSelect(component, (readSelect(component) & ~0x01) | (if (select) 0x01 else 0x00))
	}

	def waitReady(component: SD): Unit = {
		while ((readStatus(component) & 0x01) != 0) {}
	}

	def dataOut(component: SD, data: Int): Unit = {
		waitReady(component)
		writeData(component, data)
		waitReady(component)

		(0 to 50).foreach(_ => {
			component.clockDomain.waitRisingEdge()
		})
	}

	def dataIn(component: SD): Int = {
		waitReady(component)
		writeData(component, 0xFF)
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

					var result = 0xA5
					while ((dut.io.sd_cs.toInt & 1) == 0) {
						dut.io.sd_miso #= ((result >>> 7) & 1) != 0
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
