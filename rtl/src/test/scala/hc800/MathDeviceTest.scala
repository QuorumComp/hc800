package hc800

import spinal.core._
import spinal.core.sim._

/*
 * Drives the MATH coprocessor as software does - through its bus, one byte at a time -
 * and checks the status byte that a driver polls.
 *
 * The status byte is laid out on the condition lanes: bit 0 is readiness, bit 1 says the
 * divisor was zero, bit 3 says the quotient did not fit 32 bits, and bit 2 is wired to
 * nothing so that a program can test "no error" with one branch.  The two error bits also
 * have to survive the read: they describe the division whose results are in the output
 * registers, not whatever the operand registers happen to hold while they are being
 * refilled.
 *
 * The results themselves are read here too, because the interesting ones are the cases
 * with no answer: they must read back as zeros rather than as whatever the loop happened
 * to accumulate.
 */
class MathDeviceTest extends munit.FunSuite {

	private val compiled = SimConfig.compile(new Math())

	private val Status    = 0
	private val Operation = 1
	private val X         = 2
	private val Y         = 3
	private val Z         = 4

	private val UnsignedMultiply = 1
	private val UnsignedDivision = 3
	private val SignedDivision = 2

	private val Ready = 0x01
	private val DivideZero = 0x02
	private val Overflow = 0x08

	private def write(math: Math, register: Int, value: Int): Unit = {
		math.clockDomain.waitRisingEdge()
		math.io.address       #= register
		math.io.dataFromMaster #= value & 0xFF
		math.io.write         #= true
		math.io.enable        #= true
		math.clockDomain.waitRisingEdge()
		math.io.enable #= false
		math.io.write  #= false
		math.clockDomain.waitRisingEdge()   // leave the strobe line low before the next access
	}

	/** Reads a byte; the device answers one cycle after the access is sampled. */
	private def read(math: Math, register: Int): Int = {
		math.clockDomain.waitRisingEdge()
		math.io.address #= register
		math.io.write   #= false
		math.io.enable  #= true
		math.clockDomain.waitRisingEdge()
		math.io.enable  #= false
		math.clockDomain.waitRisingEdge()
		val value = math.io.dataToMaster.toInt & 0xFF
		math.clockDomain.waitRisingEdge()
		value
	}

	/** The registers shift their contents in as bytes are written, so the first byte of a
	 *  value is its most significant one. */
	private def writeValue(math: Math, register: Int, value: BigInt, bytes: Int): Unit =
		for (i <- (bytes - 1) to 0 by -1) write(math, register, ((value >> (8 * i)) & 0xFF).toInt)

	/** ...and out as they are read, so the first byte of a value is its least significant
	 *  one.  Reading a result register destroys it, which is why a driver reads once. */
	private def readValue(math: Math, register: Int, bytes: Int): BigInt = {
		var value = BigInt(0)
		for (i <- 0 until bytes) value = value | (BigInt(read(math, register)) << (8 * i))
		value
	}

	private def poll(math: Math, what: String): Int = {
		for (tries <- 0 until 200) {
			val status = read(math, Status)
			if ((status & Ready) != 0) return status
		}
		fail(s"the device never became ready: $what")
	}

	/** Runs one division and returns the status byte and both results. */
	private def operation(dividend: BigInt, divisor: BigInt, signed: Boolean): (Int, BigInt, BigInt) = {
		var status = 0
		var quotient = BigInt(0)
		var remainder = BigInt(0)

		compiled.doSim { (dut: hc800.Math) =>
			dut.clockDomain.forkStimulus(period = 10)
			dut.io.enable #= false
			dut.io.write  #= false

			writeValue(dut, Y, divisor, 4)
			writeValue(dut, Z, dividend, 8)
			write(dut, Operation, if (signed) SignedDivision else UnsignedDivision)

			status = poll(dut, s"$dividend / $divisor")
			quotient = readValue(dut, X, 4)
			remainder = readValue(dut, Y, 4)
		}

		(status, quotient, remainder)
	}

	private def divide(dividend: BigInt, divisor: BigInt): (Int, BigInt, BigInt) =
		operation(dividend, divisor, signed = false)

	private def checkStatus(status: Int, expectReady: Boolean, expectZero: Boolean, expectOverflow: Boolean, what: String): Unit = {
		assert((status & 0x04) == 0, s"status bit 2 is set ($what); it must read 0 forever: 0x${status.toHexString}")
		assert((status & 0xF0) == 0, s"the reserved status bits are set ($what): 0x${status.toHexString}")
		assert((status & Ready) != 0 == expectReady, s"ready bit wrong ($what): 0x${status.toHexString}")
		assert((status & DivideZero) != 0 == expectZero, s"divide-by-zero bit wrong ($what): 0x${status.toHexString}")
		assert((status & Overflow) != 0 == expectOverflow, s"quotient-overflow bit wrong ($what): 0x${status.toHexString}")
	}

	test("a division with a divisor above 2^31 reports no error") {
		val (status, q, r) = divide(BigInt("FFFFFFFF", 16), BigInt("FFFFFFFF", 16))
		checkStatus(status, expectReady = true, expectZero = false, expectOverflow = false, "FFFFFFFF / FFFFFFFF")
		assert(q == BigInt(1) && r == BigInt(0), s"FFFFFFFF / FFFFFFFF -> q=$q r=$r, want q=1 r=0")
	}

	test("a zero divisor sets the divide-by-zero bit and clears both results") {
		for (dividend <- Seq(BigInt(0), BigInt("1234", 16), (BigInt(1) << 64) - 1)) {
			val (status, q, r) = divide(dividend, BigInt(0))
			checkStatus(status, expectReady = true, expectZero = true, expectOverflow = false, s"$dividend / 0")
			assert(q == BigInt(0) && r == BigInt(0), s"$dividend / 0 -> q=$q r=$r, want zeros")
		}
	}

	test("a quotient that does not fit sets the overflow bit and clears both results") {
		val vectors = Seq(
			(BigInt("100000000", 16), BigInt(1)),
			(BigInt("FFFFFFFF00000000", 16), BigInt("FFFFFFFF", 16)),
			((BigInt(1) << 64) - 1, BigInt("80000001", 16))
		)
		vectors.foreach { case (dividend, divisor) =>
			val (status, q, r) = divide(dividend, divisor)
			checkStatus(status, expectReady = true, expectZero = false, expectOverflow = true, s"$dividend / $divisor")
			assert(q == BigInt(0) && r == BigInt(0), s"$dividend / $divisor -> q=$q r=$r, want zeros")
		}
	}

	/**
	 * The vectors the firmware self-test prints, held here as well so that what a
	 * human compares on the board is checked against the hardware rather than
	 * against somebody's arithmetic.  The first is the case a 32-bit dividend
	 * cannot reach: its remainder passes through bit 31, which the loop used to
	 * drop.  The last is the largest magnitude a signed divisor has.
	 */
	test("the firmware self-test vectors") {
		val allOnes32 = (BigInt(1) << 32) - 1
		val vectors = Seq(
			(BigInt("1DEADBEEF", 16), BigInt("F0000000", 16), false,
				Ready, BigInt(1), BigInt("EEADBEEF", 16)),
			(BigInt("FFFFFFFF", 16), BigInt("FFFFFFFF", 16), false,
				Ready, BigInt(1), BigInt(0)),
			(BigInt("DEADBEEF", 16), BigInt(0), false,
				Ready | DivideZero, BigInt(0), BigInt(0)),
			(BigInt("100000001", 16), BigInt(1), false,
				Ready | Overflow, BigInt(0), BigInt(0)),
			// -1 / INT32_MIN: no quotient, and the remainder follows the dividend.
			((BigInt(1) << 64) - 1, BigInt("80000000", 16), true,
				Ready, BigInt(0), allOnes32)
		)
		vectors.foreach { case (dividend, divisor, signed, wantStatus, wantQ, wantR) =>
			val (status, q, r) = operation(dividend, divisor, signed)
			assert(status == wantStatus,
				s"$dividend / $divisor -> status 0x${status.toHexString}, want 0x${wantStatus.toHexString}")
			assert(q == wantQ && r == wantR,
				s"$dividend / $divisor -> q=$q r=$r, want q=$wantQ r=$wantR")
		}
	}

	test("a multiply leaves the divide error bits clear") {
		compiled.doSim { (dut: hc800.Math) =>
			dut.clockDomain.forkStimulus(period = 10)
			dut.io.enable #= false
			dut.io.write  #= false

			// Operands that would be a divide by zero and an overflow if the units were
			// not being read as a multiply: the restart is shared between them.
			writeValue(dut, X, BigInt(0), 4)
			writeValue(dut, Y, BigInt("FFFFFFFF", 16), 4)
			write(dut, Operation, UnsignedMultiply)

			val status = poll(dut, "0 * FFFFFFFF")
			checkStatus(status, expectReady = true, expectZero = false, expectOverflow = false, "multiply")
			assert(readValue(dut, Z, 8) == BigInt(0), "a multiply by zero should be zero")
		}
	}
}
