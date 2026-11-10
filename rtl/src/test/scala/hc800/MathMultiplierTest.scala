package hc800

import spinal.core._
import spinal.core.sim._

/*
 * Checks the MATH coprocessor's 32x32 -> 32 multiplier datapath against an exact reference.
 *
 * The unit is a shift-add machine: 32 iterations of "shift the accumulator left, add the
 * multiplicand when the multiplier's next bit is set", which is exact modulo 2^32 and returns the
 * low half of the product.  It replaced a machine that entered the multiplicand at the top of a
 * 64-bit accumulator; the low half came out of both the same way, and this file is what makes
 * that claim rather than leaving it to the argument.  The bits are consumed from the top down, so
 * the cycle the unit loads on consumes the operand's most significant bit itself, and the sweep
 * puts weight on operands with that bit set.
 *
 * The reference is a plain unsigned multiply of the bits given.  That is not a shortcut: the low
 * half of a product does not depend on whether the operands are read as signed or unsigned, which
 * is why the device has one multiplier and one product port where it used to have two of each.
 */
class MathMultiplierTest extends munit.FunSuite {

	private val compiled = SimConfig.compile(new MultiplierUnit32x32())

	private val Mask32 = (BigInt(1) << 32) - 1

	/** One load plus the 31 iterations that follow it. */
	private val Iterations = 32

	/** Loads one multiplication and runs it to completion, the way the device does. */
	private def multiply(operand1: BigInt, operand2: BigInt): BigInt = {
		var product = BigInt(-1)

		compiled.doSim { (dut: hc800.MultiplierUnit32x32) =>
			dut.clockDomain.forkStimulus(period = 10)

			dut.io.load     #= false
			dut.io.iterate  #= false
			dut.io.operand1 #= operand1
			dut.io.operand2 #= operand2
			dut.clockDomain.waitRisingEdge()
			dut.clockDomain.waitRisingEdge()

			dut.io.load    #= true
			dut.clockDomain.waitRisingEdge()
			dut.io.load    #= false
			dut.io.iterate #= true

			for (_ <- 1 until Iterations) dut.clockDomain.waitRisingEdge()

			dut.io.iterate #= false
			dut.clockDomain.waitRisingEdge()

			product = dut.io.result.toBigInt & Mask32
		}

		product
	}

	private def check(operand1: BigInt, operand2: BigInt): Unit = {
		val want = (operand1 * operand2) & Mask32
		val got  = multiply(operand1, operand2)
		assert(got == want, s"0x${operand1.toString(16)} * 0x${operand2.toString(16)} -> " +
			s"0x${got.toString(16)}, want 0x${want.toString(16)}")
	}

	test("the directed vectors multiply exactly") {
		val vectors = Seq(
			BigInt(0)              -> BigInt(0),
			BigInt(0)              -> Mask32,
			BigInt(1)              -> Mask32,
			BigInt(2)              -> BigInt("80000000", 16),
			BigInt("7FFFFFFF", 16) -> BigInt("7FFFFFFF", 16),
			BigInt("80000000", 16) -> BigInt("80000000", 16),   // 2^31 squared, which is zero here
			BigInt("FFFFFFFF", 16) -> BigInt("FFFFFFFF", 16),   // -1 * -1, i.e. 2^32 - 1
			BigInt("DEADBEEF", 16) -> BigInt("FEEDFACE", 16),
			Mask32                 -> Mask32,
			BigInt("100000000", 16) -> BigInt(1)                // lanes are 32 bits; this is 0
		).map { case (a, b) => (a & Mask32) -> (b & Mask32) }
		vectors.foreach { case (a, b) => check(a, b) }
	}

	test("a sweep of operand pairs multiplies exactly") {
		val random = new scala.util.Random(0x5EEDBEEF)
		def biased32: BigInt =
			if (random.nextInt(2) == 0) BigInt(32, random)
			else (BigInt(31, random) | (BigInt(1) << 31)) & Mask32

		for (_ <- 1 to 400) check(biased32, biased32)
	}

	/**
	 * The identity the single product port rests on: reading the same bit patterns as signed or as
	 * unsigned changes the product by multiples of 2^32 (each operand's sign correction is its
	 * value times 2^32), so the two products agree below bit 32 and one run answers both readings.
	 * Note this is *not* true of the operands' magnitudes - `-1 * 1` is `0xFFFFFFFF` unsigned and
	 * `1` as magnitudes - which is why the device feeds this unit the lanes as written and has no
	 * sign correction on the multiply at all.
	 */
	test("the low half answers the signed reading too") {
		val random = new scala.util.Random(0x51C0BA)
		def biased32: BigInt =
			if (random.nextInt(2) == 0) BigInt(32, random)
			else (BigInt(31, random) | (BigInt(1) << 31)) & Mask32
		def signed32(v: BigInt) = if (v > Mask32 / 2) v - (BigInt(1) << 32) else v

		for (_ <- 1 to 150) {
			val a = biased32
			val b = biased32
			val want = (signed32(a) * signed32(b)) & Mask32
			assert(multiply(a, b) == want,
				s"0x${a.toString(16)} * 0x${b.toString(16)} -> 0x${multiply(a, b).toString(16)}, " +
					s"signed reference 0x${want.toString(16)}")
		}
	}
}
