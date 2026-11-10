package hc800

import spinal.core._
import spinal.lib._

/*
 * The MATH coprocessor's multiplier: 32 iterations of "shift the accumulator left, add the
 * multiplicand when the multiplier's next bit is set", returning the low 32 bits of the
 * product.  It is a shift-add machine rather than an array on purpose - the same reason the
 * divider is one: it fits the hardware this project runs on.
 *
 * This machine is the mirror of the one it replaces, which entered the multiplicand at the top
 * of a 64-bit accumulator and shifted right.  Both consume one operand bit per iteration and
 * neither needs a barrel shifter, but the narrow one needs no field above the result: shifting
 * left and adding at the bottom is exact modulo 2^32, so the carry out of the top is simply
 * not wanted and there is nothing to hold it.  That is the whole saving, and it is why the
 * product's high half is what the device gave up rather than the multiply itself - measured on
 * the board's FPGA, 49 LUT and 63 flip-flops against 50 and 95 for the 64-bit machine.
 *
 * The bits are therefore consumed from the top down, and the cycle the unit loads on consumes
 * the operand's most significant bit itself; `load` takes the operands and performs that first
 * iteration, `iterate` performs one more.  The unit carries no counter and no edge detector
 * because the device runs it and the two dividers off one sequencer, so the three stay the same
 * length by construction.
 *
 * One unit is enough for the whole device, which the old one was not: the low half of a product
 * does not depend on whether the operands are read as signed or unsigned, so the same run
 * answers both readings of the multiply.  Division is different - it negates its operands before
 * the loop, not its result afterwards - and so the device still runs two dividers.
 *
 * The operands are the caller's business: this is the unsigned machine, and feeding it magnitudes
 * or raw bit patterns is the device's choice.
 */
class MultiplierUnit32x32 extends Component {
	val io = new Bundle {
		val load     = in Bool()
		val iterate  = in Bool()
		val operand1 = in (UInt(32 bits))
		val operand2 = in (UInt(32 bits))
		val result   = out (UInt(32 bits))
	}

	private val accumulator = Reg(UInt(32 bits))
	// 31 bits rather than 32 because the cycle the unit loads on consumes the most significant
	// bit itself, so the register only ever has to hold what is left.
	private val multiplier = Reg(UInt(31 bits))

	private val bit  = io.load ? io.operand1.msb | multiplier.msb
	private val next = (accumulator ## False).asUInt(31 downto 0) + (bit ? io.operand2 | U(0, 32 bits))

	when (io.load || io.iterate) {
		accumulator := next
		multiplier  := io.load ? io.operand1(30 downto 0) | (multiplier ## False).asUInt(30 downto 0)
	}

	io.result := accumulator
}
