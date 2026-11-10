package hc800

import spinal.core._
import spinal.lib._
import spinal.lib.fsm._

/*
 * A restoring divider over a 64-bit dividend and a 32-bit divisor: 32 iterations of
 * "shift the [remainder : quotient] field left, subtract the divisor when it fits".
 *
 * The field needs one bit more than the divisor while it is being shifted, and the previous
 * version did the whole loop in 32 bits.  That cost it twice over.  "It fits" was tested as
 * the sign bit of a wrapped 32-bit difference, which is a borrow only when the two operands
 * agree in bit 31 - so the subtraction was made or skipped at random whenever they
 * differed, which is most of the time for operands in the top half of the range.  And the
 * shift kept 31 bits of the remainder, dropping the carry out of the field; a restoring
 * divider keeps its remainder below the divisor, so with a divisor above 2^31 a remainder
 * can reach that bit.  Both defects are the same missing bit: with the field one bit wider,
 * the sign bit of the difference is the borrow, and nothing is thrown away.  The extra bit
 * only ever exists inside one iteration - a remainder that survives a subtraction is below
 * the divisor again - so the register stays 32 bits and the bit lives in the path.
 *
 * `restart` is a level, not an edge: while it is held the unit reloads and reports itself
 * busy, so a strobe that arrives early, late, or held for several cycles cannot leave a
 * stale result marked as fresh.  The load cycle doubles as the first of the 32 iterations
 * by taking the dividend straight from the inputs, which makes a run exactly as long as
 * the multiplier's and lets the two units share a sequencer.
 *
 * Two cases have no arithmetic answer: a zero divisor, and a quotient that does not fit 32
 * bits (dividend high word >= divisor).  Both are decided from the operands as they are
 * latched, are reported on outputs of their own, and force both results to zero - an
 * undefined value that the software models could not reproduce any other way.
 */
class UnsignedDividerUnit32x32 extends Component {
	val io = new Bundle {
		val restart    = in Bool()
		val dividend   = in (UInt(64 bits))
		val divisor    = in (UInt(32 bits))
		val quotient   = out (UInt(32 bits))
		val remainder  = out (UInt(32 bits))
		val ready      = out Bool()
		val overflow   = out Bool()
		val divideZero = out Bool()
	}

	private val counter = Reg(UInt(6 bits)) init(U(0x20))
	private val timeout = counter(5)

	// Starts at 1 rather than 0 because the cycle the unit loads on is already the first
	// iteration; the 31 that follow bring the total to 32, and bit 5 marks the end.
	when (io.restart) {
		counter := 1
	}.elsewhen (!timeout) {
		counter := counter + 1
	}

	private val remainder = Reg(UInt(32 bits))
	private val quotient  = Reg(UInt(32 bits))

	private val workRemainder = io.restart ? io.dividend(63 downto 32) | remainder
	private val workQuotient  = io.restart ? io.dividend(31 downto 0)  | quotient

	private val shiftedRemainder = (workRemainder ## workQuotient.msb).asUInt
	private val shiftedQuotient  = (workQuotient(30 downto 0) ## False).asUInt
	private val subtracted       = shiftedRemainder - io.divisor.resize(33 bits)
	private val fits             = !subtracted.msb

	when (io.restart || !timeout) {
		// Truncating the 33rd bit is only visible when the answer is undefined anyway:
		// a defined division keeps its remainder below the divisor, hence in 32 bits.
		remainder := (fits ? subtracted | shiftedRemainder).resized
		quotient  := shiftedQuotient | (fits ? U(1, 32 bits) | U(0, 32 bits))
	}

	private val overflowReg   = Reg(Bool()) init(False)
	private val divideZeroReg = Reg(Bool()) init(False)

	private val divisorIsZero = io.divisor === 0

	when (io.restart) {
		// A zero divisor has no quotient at all, so it is reported as the zero case only:
		// `hi >= 0` is trivially true and would otherwise raise an overflow nobody asked
		// for.  Each flag means exactly one thing.
		overflowReg   := (!divisorIsZero) && (io.dividend(63 downto 32) >= io.divisor)
		divideZeroReg := divisorIsZero
	}

	private val flagged = overflowReg || divideZeroReg

	io.quotient   := flagged ? U(0, 32 bits) | quotient
	io.remainder  := flagged ? U(0, 32 bits) | remainder
	io.ready      := timeout && !io.restart
	io.overflow   := overflowReg
	io.divideZero := divideZeroReg
}


/*
 * The signed view of the same unit: divide the magnitudes and correct the signs, with the
 * remainder following the dividend - the truncating convention C and the firmware drivers
 * both require.  This path was not exposed to the old loop's two defects: magnitudes stop at
 * 2^31 (INT32_MIN's), the only one of them with bit 31 set, so the operands' bit 31 stayed
 * in step and the remainder stayed below it.
 */
class DividerUnit32x32 extends Component {
	val io = new Bundle {
		val signed    = in Bool()
		val restart   = in Bool()
		val dividend  = in (Bits(64 bits))
		val divisor   = in (Bits(32 bits))
		val quotient  = out (Bits(32 bits))
		val remainder = out (Bits(32 bits))
		val ready     = out Bool()
		val overflow   = out Bool()
		val divideZero = out Bool()
	}

	private def operandAsUInt(op: Bits): UInt =
		io.signed ? op.asSInt.abs | op.asUInt

	private val divider = new UnsignedDividerUnit32x32()
	divider.io.restart    := io.restart
	divider.io.dividend   := operandAsUInt(io.dividend)
	divider.io.divisor    := operandAsUInt(io.divisor)

	private val negateResult    = io.signed & (io.dividend.msb ^ io.divisor.msb)
	private val negateRemainder = io.signed & io.dividend.msb

	// Zero negates to zero, so the undefined cases survive this stage untouched.
	io.quotient   := (negateResult ? -divider.io.quotient.asSInt | divider.io.quotient.asSInt).asBits
	io.remainder  := (negateRemainder ? -divider.io.remainder.asSInt | divider.io.remainder.asSInt).asBits
	io.ready      := divider.io.ready
	io.overflow   := divider.io.overflow
	io.divideZero := divider.io.divideZero
}
