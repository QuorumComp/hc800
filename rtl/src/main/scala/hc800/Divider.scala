package hc800

import spinal.core._
import spinal.lib._

/*
 * The MATH coprocessor's divider: 32 iterations of "shift the [remainder : quotient] field left,
 * subtract the divisor when it fits" over a 32-bit dividend and a 32-bit divisor.
 *
 * The field needs one bit more than the divisor while it is being shifted, and the version before
 * that one did the whole loop in 32 bits.  That cost it twice over.  "It fits" was tested as the
 * sign bit of a wrapped 32-bit difference, which is a borrow only when the two operands agree in
 * bit 31 - so the subtraction was made or skipped at the wrong moment whenever they differed,
 * which is most of the time for operands in the top half of the range.  And the shift kept 31
 * bits of the remainder, dropping the carry out of the field; a restoring divider keeps its
 * remainder below the divisor, so with a divisor above 2^31 a remainder can reach that bit.  Both
 * defects are the same missing bit: with the field one bit wider, the sign bit of the difference
 * is the borrow, and nothing is thrown away.  The extra bit only ever exists inside one iteration
 * - a remainder that survives a subtraction is below the divisor again - so the register stays 32
 * bits and the bit lives in the path.
 *
 * The dividend used to be 64 bits, with the high half arriving in its own lane.  It is 32 now,
 * which removes that lane from the device, the 64-bit magnitude negate in front of this unit's
 * second instance, and - the part that is not about area - the case where the quotient does not
 * fit.  A 32-bit unsigned dividend divided by a 32-bit divisor always fits, so the only undefined
 * division left in the machine is a zero divisor, decided by the device.  The alternative
 * arithmetic was priced rather than assumed: a non-restoring loop needs no "does it fit" compare
 * and no select between two candidate remainders, but it does need an adder that inverts its
 * operand by sign every cycle, and that came out 38 LUT *dearer* per instance on the board's FPGA
 * than the loop above, which computes its difference unconditionally anyway and merely selects.
 *
 * Like the multiplier, the unit carries no counter and no restart-edge detector: the device loads
 * it and iterates it from one sequencer, and the load cycle is already the first iteration because
 * the dividend comes straight from the inputs.  `load` reloads and performs it; `iterate` performs
 * one more.  The remainder starts at zero and the first iteration consumes the dividend's most
 * significant bit, so 31 counted cycles plus the load make 32 and no cycle is spent on an
 * initialisation the loop would do again.
 *
 * This is the unsigned machine.  Signed division needs its operands negated before the loop, not
 * its result after it, so the device runs the unit a second time on magnitudes rather than asking
 * this unit about signs: `-2 / -1` is `0 r 0xFFFFFFFE` read as bit patterns and `2 r 0` read as
 * signed, a different quotient and remainder rather than a negated one.  A zero divisor, and the
 * one signed quotient that does not fit the signed range, are decided and forced to zero by the
 * device for the same reason - they belong to whichever run is being looked at.
 */
class DividerUnit32x32 extends Component {
	val io = new Bundle {
		val load      = in Bool()
		val iterate   = in Bool()
		val dividend  = in (UInt(32 bits))
		val divisor   = in (UInt(32 bits))
		val quotient  = out (UInt(32 bits))
		val remainder = out (UInt(32 bits))
	}

	private val remainder = Reg(UInt(32 bits))
	private val quotient  = Reg(UInt(32 bits))

	private val workRemainder = io.load ? U(0, 32 bits) | remainder
	private val workQuotient  = io.load ? io.dividend | quotient

	private val shiftedRemainder = (workRemainder ## workQuotient.msb).asUInt
	private val shiftedQuotient  = (workQuotient(30 downto 0) ## False).asUInt
	private val subtracted       = shiftedRemainder - io.divisor.resize(33 bits)
	private val fits             = !subtracted.msb

	when (io.load || io.iterate) {
		// Truncating the 33rd bit is only visible when the answer is undefined anyway: a defined
		// division keeps its remainder below the divisor, hence in 32 bits.
		remainder := (fits ? subtracted | shiftedRemainder).resized
		quotient  := shiftedQuotient | (fits ? U(1, 32 bits) | U(0, 32 bits))
	}

	io.quotient  := quotient
	io.remainder := remainder
}
