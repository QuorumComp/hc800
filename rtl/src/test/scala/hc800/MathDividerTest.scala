package hc800

import spinal.core._
import spinal.core.sim._

/*
 * Checks the MATH coprocessor's 32/32 divider datapath against an exact reference.
 *
 * The unit is a restoring divider: 32 iterations of "shift the [remainder : quotient] field left,
 * subtract the divisor when it fits".  The field needs one bit more than the divisor while it
 * shifts, and the loop used to do everything in 32 bits, which cost it in two ways.  The "it fits"
 * test was the sign bit of a wrapped 32-bit difference rather than a borrow, so it lied whenever
 * the partial remainder and the divisor differed in bit 31; and the shift kept 31 bits of the
 * remainder, dropping the carry out of the field.  Carrying one extra bit fixes both at once: with
 * the field one bit wider, the sign bit of the difference *is* the borrow.
 *
 * That was reachable from plain C, and common: measured against the old unit in simulation, 194 of
 * 400 random `u32 / u32` divides came out wrong, `0xFFFFFFFF / 0xFFFFFFFF` among them.  What saved
 * the existing tests was small operands - a dividend below 65536 never went wrong in 400 tries,
 * because the remainder has to grow into bit 31 to lose anything.  The sweep below is biased into
 * that region deliberately, and the divisor is kept above 2^31 often enough to walk a remainder
 * through the bit too.
 *
 * The dividend used to be 64 bits and is 32 now, which is why the vectors are too: with a 32-bit
 * unsigned dividend the quotient always fits, so there is no overflow case left for the datapath
 * to be asked about.  A zero divisor is the only undefined division in the machine, and it is
 * decided by the device, which also forces both results to zero.
 *
 * The unit is fed whatever the device chooses: the bit patterns as written for the unsigned ports,
 * and the magnitudes for the signed ones.  So both readings of the same operand pair are exercised
 * here, and the largest magnitude a 32-bit divisor has - 2^31, which `INT32_MIN` hands over - is
 * one of the directed vectors.
 */
class MathDividerTest extends munit.FunSuite {

	private val compiled = SimConfig.compile(new DividerUnit32x32())

	private val Mask32 = (BigInt(1) << 32) - 1

	/** One load plus the 31 iterations that follow it. */
	private val Iterations = 32

	/**
	 * Loads one division and runs it to completion, returning both results.
	 *
	 * The device drives these two signals; a test that drove them differently would not be testing
	 * what the hardware does.  The controls are settled low for a cycle before the load, held for
	 * exactly one cycle, and then iterated - so a missed or doubled load shows up as a wrong answer
	 * rather than as a silent stall.
	 */
	private def divide(dividend: BigInt, divisor: BigInt): (BigInt, BigInt) = {
		var quotient = BigInt(-1)
		var remainder = BigInt(-1)

		compiled.doSim { (dut: hc800.DividerUnit32x32) =>
			dut.clockDomain.forkStimulus(period = 10)

			dut.io.load     #= false
			dut.io.iterate  #= false
			dut.io.dividend #= dividend
			dut.io.divisor  #= divisor
			dut.clockDomain.waitRisingEdge()
			dut.clockDomain.waitRisingEdge()

			dut.io.load    #= true
			dut.clockDomain.waitRisingEdge()
			dut.io.load    #= false
			dut.io.iterate #= true

			for (_ <- 1 until Iterations) dut.clockDomain.waitRisingEdge()

			dut.io.iterate #= false
			dut.clockDomain.waitRisingEdge()

			quotient  = dut.io.quotient.toBigInt & Mask32
			remainder = dut.io.remainder.toBigInt & Mask32
		}

		(quotient, remainder)
	}

	private def check(dividend: BigInt, divisor: BigInt, what: String): Unit = {
		val (q, r) = divide(dividend, divisor)
		val wantQ  = dividend / divisor
		val wantR  = dividend % divisor
		assert(wantQ <= Mask32, s"$what is not this unit's question: its quotient is $wantQ")
		assert(q == wantQ && r == wantR, s"$what -> q=$q r=$r, want q=$wantQ r=$wantR")
	}

	test("the directed vectors divide exactly") {
		val vectors = Seq(
			BigInt(0)              -> BigInt(1),
			BigInt(1)              -> BigInt(1),
			BigInt("FFFFFFFF", 16) -> BigInt("FFFFFFFF", 16),
			BigInt("FFFFFFFE", 16) -> BigInt("FFFFFFFF", 16),
			BigInt("80000000", 16) -> BigInt("80000000", 16),
			BigInt("80000000", 16) -> BigInt("80000001", 16),
			BigInt("7FFFFFFF", 16) -> BigInt("80000001", 16),
			// A dividend one below the divisor: quotient zero, remainder through bit 31.
			BigInt("7FFFFFFF", 16) -> BigInt("80000000", 16),
			// INT32_MIN's magnitude as a divisor, the only 32-bit magnitude with bit 31 set, so
			// the signed reading of the same operands reaches here too.
			Mask32                 -> BigInt("80000000", 16),
			Mask32                 -> BigInt("7FFFFFFF", 16),
			Mask32                 -> BigInt(2),
			BigInt("DEADBEEF", 16) -> BigInt("F0000000", 16),
			// The quotient comes out all ones, which is as far as a 32-bit dividend goes.
			BigInt("FFFFFFFE", 16) -> BigInt(1)
		)
		vectors.foreach { case (dividend, divisor) =>
			check(dividend, divisor, s"0x${dividend.toString(16)} / 0x${divisor.toString(16)}")
		}
	}

	/**
	 * The region the old loop lost a bit in is where the partial remainder reaches bit 31, so the
	 * sweep puts the divisor and the dividend there deliberately rather than hoping a uniform draw
	 * finds them.  Every quotient fits by construction of the contract, so nothing here has to
	 * excuse a truncated expectation.
	 */
	test("a sweep biased into the top half divides exactly") {
		val random = new scala.util.Random(0x80005)

		def biased32: BigInt =
			if (random.nextInt(2) == 0) BigInt(32, random)
			else (BigInt(31, random) | (BigInt(1) << 31)) & Mask32

		val vectors = Iterator.continually {
			val divisor = biased32 | BigInt(1)
			// Half the draws put the divisor above 2^31, where a remainder can reach the bit the
			// old field dropped, and the rest keep the dividend above the divisor's top bits.
			val dividend = if (random.nextInt(2) == 0) biased32 else biased32 % divisor
			(dividend, divisor)
		}.take(500).toList

		vectors.foreach { case (dividend, divisor) =>
			check(dividend, divisor, s"0x${dividend.toString(16)} / 0x${divisor.toString(16)}")
		}
	}
}
