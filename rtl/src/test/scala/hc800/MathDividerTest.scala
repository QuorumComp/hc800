package hc800

import spinal.core._
import spinal.core.sim._

/*
 * Checks the MATH coprocessor's 64/32 divider against an exact reference.
 *
 * The unit is a restoring divider: 32 iterations of "shift the [remainder : quotient] field
 * left, subtract the divisor when it fits".  The field needs one bit more than the divisor
 * while it shifts, and the loop did everything in 32 bits, which cost it in two ways.  The
 * "it fits" test was the sign bit of a wrapped 32-bit difference rather than a borrow, so it
 * lied whenever the partial remainder and the divisor differed in bit 31; and the shift kept
 * 31 bits of the remainder, dropping the carry out of the field.  Carrying one extra bit
 * fixes both at once: with the field one bit wider, the sign bit of the difference *is* the
 * borrow.
 *
 * This was reachable from plain C, and common: measured against the old unit in simulation,
 * 194 of 400 random `u32 / u32` divides came out wrong, `0xFFFFFFFF / 0xFFFFFFFF` among
 * them.  What saved the existing tests was small operands - a dividend below 65536 never
 * went wrong in 400 tries, because the remainder has to grow into bit 31 to lose anything.
 * The golden probe divides by 1, 2, 3, 7, 37, 55 and 256; the firmware mathtest divides by
 * $7654 and $87654 and prints expected values into a string for a human to compare; and the
 * emulator, cosim and ucsim models all divide exactly, so every existing test passes on the
 * emulator while the board disagrees.  This file is the device's first unit test.
 *
 * The signed path is not exempt either: it divides magnitudes, so INT32_MIN hands it a
 * 2^31-sized divisor, and a dividend with bit 31 set gives it large dividends too.
 *
 * A quotient that does not fit 32 bits (dividend high word >= divisor) and a zero divisor
 * have no defined arithmetic result.  The unit is required to return zeros for both and
 * flag them, so that the models - which cannot reproduce an undefined value faithfully -
 * stay identical to the hardware.
 */
class MathDividerTest extends munit.FunSuite {

	private val unsignedUnit = SimConfig.compile(new UnsignedDividerUnit32x32())
	private val signedUnit   = SimConfig.compile(new DividerUnit32x32())

	private val Mask32 = (BigInt(1) << 32) - 1
	private val Mask64 = (BigInt(1) << 64) - 1

	/** A run is a fixed 32 iterations; anything much past that never finishes. */
	private val LatencyBound = 60

	/** Reads a unit output as an unsigned value of the given width. */
	private def unsigned(bits: => Long, width: Int): BigInt =
		((BigInt(1) << 64) + BigInt(bits)) & ((BigInt(1) << width) - 1)

	/**
	 * Strobes a unit and waits for its result, through accessors so that both the
	 * unsigned unit and the signed wrapper can share it.
	 *
	 * The clock runs on its own thread, so a strobe aimed at one edge may be overwritten
	 * before any edge samples it: it is held for two cycles instead.  And restart is
	 * primed low for a cycle or two first, because a unit that starts on a rising edge of
	 * it cannot see a transition that began before its own state was settled - with the
	 * random register initialisation the simulator uses, that is a coin flip.
	 *
	 * The result is only accepted once ready has been seen to fall and then rise again,
	 * so a stale result cannot be mistaken for this division's.
	 */
	private def strobeAndWait(clock: ClockDomain, strobe: Boolean => Unit, ready: () => Boolean, what: String): Unit = {
		strobe(false)
		clock.waitRisingEdge()
		clock.waitRisingEdge()

		strobe(true)
		clock.waitRisingEdge()
		clock.waitRisingEdge()
		strobe(false)

		var busy = 0
		while (ready()) {
			clock.waitRisingEdge()
			busy += 1
			if (busy > 8) fail(s"the restart did not make the divider busy: $what")
		}

		var cycles = 0
		while (!ready()) {
			clock.waitRisingEdge()
			cycles += 1
			if (cycles > LatencyBound + 40) fail(s"the divider never finished: $what")
		}
		assert(cycles <= LatencyBound, s"the divider took $cycles cycles: $what")
	}

	/**
	 * The architectural answer: a division has a result only when the divisor is nonzero
	 * and the quotient fits 32 bits, which for a magnitude division means the dividend's
	 * high word is below the divisor.  Everything else is undefined, and the unit returns
	 * zeros for it.
	 */
	private def magnitudeAnswer(dividend: BigInt, divisor: BigInt): Option[(BigInt, BigInt)] =
		if (divisor == 0 || (dividend >> 32) >= divisor) None
		else Some((dividend / divisor, dividend % divisor))

	/**
	 * One unsigned division, checked.  `defined = false` asks for the two cases with no
	 * arithmetic answer - a zero divisor, and a quotient that does not fit 32 bits - where
	 * the unit must return zeros rather than an accident of the loop.
	 */
	private def divideUnsigned(dividend: BigInt, divisor: BigInt, defined: Boolean = true): Unit = {
		val (wantQuotient, wantRemainder) =
			if (defined) magnitudeAnswer(dividend, divisor).get
			else (BigInt(0), BigInt(0))
		assert(magnitudeAnswer(dividend, divisor).isEmpty == !defined,
			s"test bug: $dividend / $divisor was expected to be ${if (defined) "defined" else "undefined"}")

		unsignedUnit.doSim { dut =>
			dut.clockDomain.forkStimulus(period = 10)
			dut.io.dividend #= dividend
			dut.io.divisor  #= divisor
			dut.clockDomain.waitRisingEdge()      // let the operands land before strobing

			strobeAndWait(dut.clockDomain, (on: Boolean) => dut.io.restart #= on,
				() => dut.io.ready.toBoolean, s"$dividend / $divisor")

			val q = unsigned(dut.io.quotient.toLong, 32)
			val r = unsigned(dut.io.remainder.toLong, 32)
			assert(q == wantQuotient && r == wantRemainder,
				s"$dividend / $divisor -> q=$q r=$r, want q=$wantQuotient r=$wantRemainder")
		}
	}

	/**
	 * One signed division, checked.  The operand patterns are the operands: the dividend
	 * is a signed 64-bit value and the divisor a signed 32-bit one, so a divisor pattern of
	 * $80000000 is INT32_MIN, not 2^31.  The wrapper takes magnitudes, divides, and
	 * corrects the signs: the quotient is negative when the operand signs differ and the
	 * remainder keeps the dividend's sign - the truncating convention C and the firmware
	 * drivers both require.
	 */
	private def divideSigned(dividend: BigInt, divisor: BigInt, defined: Boolean = true): Unit = {
		// The vectors are written as the C values they stand for; the unit sees bit
		// patterns, so the reference sign-extends those patterns rather than trusting
		// the sign of a Scala number.
		val signExtend = (pattern: BigInt, width: Int) =>
			if ((pattern & (BigInt(1) << (width - 1))) != 0) pattern - (BigInt(1) << width) else pattern
		val dividendPattern = dividend & Mask64
		val divisorPattern  = divisor  & Mask32
		val magnitude        = signExtend(dividendPattern, 64).abs
		val divisorMagnitude = signExtend(divisorPattern, 32).abs
		val (wantQuotient, wantRemainder) = magnitudeAnswer(magnitude, divisorMagnitude) match {
			case Some((q, r)) =>
				val negative = signExtend(dividendPattern, 64).signum != signExtend(divisorPattern, 32).signum
				((if (negative) -q else q) & Mask32, (if (signExtend(dividendPattern, 64) < 0) -r else r) & Mask32)
			case None => (BigInt(0), BigInt(0))
		}
		assert(magnitudeAnswer(magnitude, divisorMagnitude).isEmpty == !defined,
			s"test bug: $dividend / $divisor was expected to be ${if (defined) "defined" else "undefined"}")

		signedUnit.doSim { dut =>
			dut.clockDomain.forkStimulus(period = 10)
			dut.io.signed   #= true
			dut.io.dividend #= (dividend & Mask64)
			dut.io.divisor  #= (divisor & Mask32)
			dut.clockDomain.waitRisingEdge()

			strobeAndWait(dut.clockDomain, (on: Boolean) => dut.io.restart #= on,
				() => dut.io.ready.toBoolean, s"$dividend / $divisor")

			val q = unsigned(dut.io.quotient.toLong, 32)
			val r = unsigned(dut.io.remainder.toLong, 32)
			assert(q == wantQuotient && r == wantRemainder,
				s"$dividend / $divisor -> q=$q r=$r, want q=$wantQuotient r=$wantRemainder")
		}
	}

	/** Small operands: the region every existing vector in the tree lives in, and the one
	 *  the old loop got right - the remainder never grows into the bit it was dropping. */
	test("unsigned divide, small operands") {
		val vectors = Seq(
			BigInt(5)          -> BigInt(3),
			BigInt(0x1234567890L) -> BigInt(0x1000),
			(BigInt(1) << 32)  -> BigInt(2),
			BigInt("7654", 16)          -> BigInt("87654", 16),
			BigInt("7FFFFFFF", 16)      -> BigInt("80000000", 16),
			BigInt("12345678", 16)      -> BigInt("80000000", 16),
			BigInt("7FFFFFFE7FFFFFFF", 16) -> BigInt("7FFFFFFF", 16),
			BigInt("7FFFFFFF00000001", 16) -> BigInt("80000000", 16),
			BigInt("0000000100000000", 16) -> BigInt("7FFFFFFF", 16),
			BigInt("1FFFFFFFF", 16)     -> BigInt("80000001", 16),
			BigInt("DEADBEEFCAFE", 16)     -> BigInt("10000000", 16)
		)
		vectors.foreach { case (n, d) => divideUnsigned(n, d) }
	}

	/** The bug.  These are the vectors the old unit got wrong in simulation - see the file
	 *  header - all of them reachable from a plain C `u32 / u32` except the last two, which
	 *  need a dividend above 32 bits and so need a program writing the dividend register
	 *  by hand. */
	test("unsigned divide, operands in the top half of the range") {
		val vectors = Seq(
			BigInt("FFFFFFFF", 16)      -> BigInt("FFFFFFFF", 16),
			BigInt("FFFFFFFE", 16)      -> BigInt("80000001", 16),
			BigInt("87654321", 16)      -> BigInt("87654321", 16),
			BigInt("12345678", 16)      -> BigInt("F0000000", 16),
			BigInt("FFFFFFFF", 16)      -> BigInt("80000000", 16),
			BigInt("100000001", 16)     -> BigInt("B2D05E00", 16),   // / 3_000_000_000
			BigInt("1DEADBEEF", 16)     -> BigInt("F0000000", 16),
			BigInt("DEADBEEFCAFE", 16)  -> BigInt("F0000000", 16)
		)
		vectors.foreach { case (n, d) => divideUnsigned(n, d) }
	}

	/** A zero divisor has no result: zeros, flagged, rather than today's all-ones
	 *  quotient, which the models do not produce either. */
	test("divide by zero returns zeros") {
		Seq(BigInt(0), BigInt(0x1234), Mask64).foreach { n => divideUnsigned(n, BigInt(0), defined = false) }
	}

	/** A quotient that does not fit has no result either, for the same reason. */
	test("quotient overflow returns zeros") {
		val vectors = Seq(
			(BigInt(1) << 32)  -> BigInt(1),
			Mask64             -> BigInt(1),
			Mask64             -> BigInt(2),
			BigInt("8000000000000000", 16) -> BigInt("80000000", 16),
			BigInt("FFFFFFFF00000000", 16) -> BigInt("FFFFFFFF", 16)
		)
		vectors.foreach { case (n, d) => divideUnsigned(n, d, defined = false) }
	}

	/**
	 * C's truncating division: the remainder follows the dividend.  The signed path divides
	 * magnitudes, and the only magnitude at or below 2^31 with bit 31 set is 2^31 itself
	 * (INT32_MIN's), which keeps the operands' bit 31 in step - so of the two ways the old
	 * loop lost a bit, this path met neither.  The vectors are here because the sign
	 * convention is its own source of bugs, and because that claim is cheap to keep true.
	 */
	test("signed divide follows the C convention") {
		val vectors = Seq(
			BigInt(-7)  -> BigInt(2),
			BigInt(7)   -> BigInt(-2),
			BigInt(-7)  -> BigInt(-2),
			BigInt(-100) -> BigInt(7),
			BigInt("100000000", 16) -> BigInt("80000000", 16),   // INT32_MIN as divisor
			BigInt("-100000000", 16) -> BigInt("80000000", 16),
			BigInt("7FFFFFFF", 16)   -> BigInt("80000000", 16),
			// The magnitude quotient fits 32 bits but the signed one does not; the
			// negate wraps, and so do the models, which truncate the same way.
			BigInt("-7FFFFFFF00000000", 16) -> BigInt("80000000", 16)
		)
		vectors.foreach { case (n, d) => divideSigned(n, d) }
	}

	/** The two undefined cases through the signed wrapper: zeros, as for unsigned. */
	test("signed divide with a zero divisor or an overflowing quotient returns zeros") {
		divideSigned(BigInt("7FFFFFFF", 16), BigInt(0), defined = false)
		divideSigned(BigInt("100000000", 16), BigInt(1), defined = false)
		divideSigned(BigInt("-1", 16), BigInt(0), defined = false)
	}

	/**
	 * While a restart is in progress the previous result must not be reported ready, or
	 * software could read a value that does not correspond to the operands it wrote.  The
	 * strobe is held for many cycles on purpose: the claim is then independent of which
	 * cycle the simulator's clock thread happens to sample it on, because the test waits
	 * for the unit to go busy and afterwards checks that it stays busy.  A run takes 32
	 * cycles, so a unit that reloads while the strobe is held cannot finish inside the
	 * window.
	 */
	test("a restart in progress invalidates the previous result") {
		unsignedUnit.doSim { dut =>
			dut.clockDomain.forkStimulus(period = 10)
			dut.io.dividend #= BigInt(0x555555)
			dut.io.divisor  #= BigInt(0x1234)
			dut.io.restart #= false
			dut.clockDomain.waitRisingEdge()
			dut.clockDomain.waitRisingEdge()      // prime the restart line low

			dut.io.restart #= true
			var waited = 0
			while (dut.io.ready.toBoolean) {
				dut.clockDomain.waitRisingEdge()
				waited += 1
				if (waited > 8) fail("the restart did not make the divider busy")
			}

			for (_ <- 0 until 2 * LatencyBound) {
				dut.clockDomain.waitRisingEdge()
				assert(!dut.io.ready.toBoolean, "ready came back high while the restart was held")
			}

			dut.io.restart #= false
			var cycles = 0
			while (!dut.io.ready.toBoolean) {
				dut.clockDomain.waitRisingEdge()
				cycles += 1
				if (cycles > LatencyBound + 40) fail("the divider never finished after the strobe was released")
			}
			val q = unsigned(dut.io.quotient.toLong, 32)
			val r = unsigned(dut.io.remainder.toLong, 32)
			assert(q == BigInt(0x555555) / BigInt(0x1234) && r == BigInt(0x555555) % BigInt(0x1234),
				s"restarting part way through corrupted the answer: q=$q r=$r")
		}
	}

	/**
	 * Sweeps, because the failure is data dependent: it needs a partial remainder and a
	 * divisor that differ in bit 31, which is a matter of luck once the operands are large.
	 * The second half is deliberately biased into that region - divisors above 2^31, and
	 * dividends whose high word is the largest the definition allows.
	 */
	test("unsigned divide, randomised sweep") {
		val random = new scala.util.Random(0x80005)
		val wideDivisor = () => (BigInt(31, random) | (BigInt(1) << 31)) + 1 + BigInt(30, random) % 1024
		for (round <- 0 until 400) {
			val divisor = if (round % 2 == 0) BigInt(32, random).max(BigInt(1)) else wideDivisor().min(Mask32)
			var dividend = (BigInt(32, random) << 32) | BigInt(32, random)
			if ((dividend >> 32) >= divisor) {
				val high = if (round % 4 == 0) divisor - 1 else BigInt(32, random) % divisor
				dividend = (high << 32) | BigInt(32, random)
			}
			divideUnsigned(dividend, divisor)
		}
	}
}
