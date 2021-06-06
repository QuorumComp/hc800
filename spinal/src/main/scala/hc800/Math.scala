package hc800

import spinal.core._
import spinal.lib._
import spinal.lib.fsm._

case class Math() extends Component {
    import Math._

    val io = slave(Bus(addressWidth = Register.craft().getBitsWidth))

	private val registerX = Reg(Bits(16 bits))
	private val registerY = Reg(Bits(16 bits))
	private val registerZ = Reg(Bits(32 bits))

	private val ready     = Reg(Bool())
	private val restart   = Reg(Bool())
	private val operation = Reg(Operation())

	private val multiplier = new MultiplierUnit16x16()
	multiplier.io.restart  <> restart
	multiplier.io.signed   <> (operation === Operation.signedMultiply)
	multiplier.io.operand1 <> registerX
	multiplier.io.operand2 <> registerY

	private val divider = new DividerUnit16x16()
	divider.io.restart  <> restart
	divider.io.signed   <> (operation === Operation.signedDivision)
	divider.io.dividend <> registerZ
	divider.io.divisor  <> registerY

	restart := False
	def startOperation(): Unit = {
		ready := False
		restart := True
		operation := io.dataFromMaster(1 downto 0).as(Operation())
	}

	when ((operation === Operation.signedMultiply) | (operation === Operation.unsignedMultiply)) {
		when (multiplier.io.ready.rise) {
			ready := True
			registerZ  := multiplier.io.result
		}
	}

	when ((operation === Operation.signedDivision) | (operation === Operation.unsignedDivision)) {
		when (divider.io.ready.rise) {
			ready := True
			registerX := divider.io.quotient
			registerY := divider.io.remainder
		}
	}

	private val address = io.address.as(Register())

	private val dataOut = Reg(Bits(8 bits))
	io.dataToMaster := dataOut

	when (io.enable) {
		dataOut := address.mux (
			(Register.operation -> operation.asBits.resize(8 bits)),
			(Register.status    -> ready.asBits.resize(8 bits)),
			(Register.x         -> registerX(7 downto 0)),
			(Register.y         -> registerY(7 downto 0)),
			(Register.z         -> registerZ(7 downto 0))
		)
	} otherwise {
		dataOut := 0
	}


	when (io.enable.rise && io.write) {
		switch (address) {
			is (Register.operation) { startOperation() }
			is (Register.x)         { registerX := (registerX(7 downto 0) ## io.dataFromMaster) }
			is (Register.y)         { registerY := (registerY(7 downto 0) ## io.dataFromMaster) }
			is (Register.z)         { registerZ := (registerZ(23 downto 0) ## io.dataFromMaster) }
		}
	}


	when (io.enable.rise && !io.write) {
		switch (address) {
			is (Register.x) { registerX := U(0, 8 bits) ## registerX(15 downto 8) }
			is (Register.y) { registerY := U(0, 8 bits) ## registerY(15 downto 8) }
			is (Register.z) { registerZ := U(0, 8 bits) ## registerZ(31 downto 8) }
		}
	}

}


object Math {
	object Register extends SpinalEnum(defaultEncoding = binarySequential) {
		val	status,
			operation,
			x,
			y,
			z = newElement()
	}

	object Operation extends SpinalEnum(defaultEncoding = binarySequential) {
		val signedMultiply,
			unsignedMultiply,
			signedDivision,
			unsignedDivision = newElement()
	}

	import spinal.sim._
	import spinal.core.sim._

	def writeRegister(math: Math, reg: Int, value: Int): Unit = {
		math.clockDomain.waitRisingEdge()
		math.io.address #= reg
		math.io.dataFromMaster #= value & 0xFF
		math.io.write #= true
		math.io.enable #= true

		math.clockDomain.waitRisingEdge()
		math.io.enable #= false
	}

	def readRegister(math: Math, reg: Int): Int = {
		math.clockDomain.waitRisingEdge()
		math.io.address #= reg
		math.io.write #= false
		math.io.enable #= true

		math.clockDomain.waitRisingEdge()
		math.io.enable #= false

		math.clockDomain.waitRisingEdge()
		val value = math.io.dataToMaster.toInt

		System.out.println(f"R$reg -> 0x$value%02X")
		value
	}

	def writeX(math: Math, value: Short): Unit = {
		writeRegister(math, Register.x.position, value >>> 8)
		writeRegister(math, Register.x.position, value)
	}

	def writeY(math: Math, value: Short): Unit = {
		writeRegister(math, Register.y.position, value >>> 8)
		writeRegister(math, Register.y.position, value)
	}

	def writeZ(math: Math, value: Int): Unit = {
		writeRegister(math, Register.z.position, value >>> 24)
		writeRegister(math, Register.z.position, value >>> 16)
		writeRegister(math, Register.z.position, value >>> 8)
		writeRegister(math, Register.z.position, value)
	}

	def writeOperation(math: Math, operation: Int) =
		writeRegister(math, Register.operation.position, operation)

	def readStatus(math: Math) =
		readRegister(math, Register.status.position)

	def readX(math: Math): Short = {
		val v0 = readRegister(math, Register.x.position)
		val v1 = readRegister(math, Register.x.position)

		((v1 << 8) | v0).toShort
	}

	def readY(math: Math): Short = {
		val v0 = readRegister(math, Register.y.position)
		val v1 = readRegister(math, Register.y.position)

		((v1 << 8) | v0).toShort
	}

	def readZ(math: Math): Int = {
		val v0 = readRegister(math, Register.z.position)
		val v1 = readRegister(math, Register.z.position)
		val v2 = readRegister(math, Register.z.position)
		val v3 = readRegister(math, Register.z.position)

		(v3 << 24) | (v2 << 16) | (v1 << 8) | v0
	}

	def testMul(math: Math, x: Short, y: Short): Unit = {
		writeX(math, x)
		writeY(math, y)
		writeOperation(math, Operation.signedMultiply.position)
		
		while (readStatus(math) == 0) {
			math.clockDomain.waitRisingEdge()
		}

		val z = readZ(math)
		System.out.println(f"0x$x%04X * 0x$y%04X = 0x$z%08X")
	}

	def testMul(math: Math): Unit = {
		testMul(math, 0x1234, 0x5678)
	}

	def testDiv(math: Math, z: Int, y: Int): Unit = {
		writeZ(math, z)
		writeY(math, y.toShort)
		writeOperation(math, Operation.signedDivision.position)
		
		while (readStatus(math) == 0) {
			math.clockDomain.waitRisingEdge()
		}

		val quotient = readX(math)
		val remainder = readY(math)
		System.out.println(f"0x$z%08X / 0x$y%04X = 0x$quotient%04X, rem = 0x$remainder%04X")
	}

	def testDiv(math: Math): Unit = {
		testDiv(math, 0x12345678, 0x7890)
	}

	def main(args: Array[String]) {
		import spinal.sim._
		import spinal.core.sim._
		SimConfig.withWave.doSim(new Math) { dut =>
			// Fork a process to generate the reset and the clock on the dut
			dut.clockDomain.forkStimulus(period = 10)

			dut.io.enable #= false
			dut.io.write #= false

			for (t <- 0 to 20) {
				dut.clockDomain.waitRisingEdge()
			}

			//testMul(dut)
			testDiv(dut)
		}
	}
}
