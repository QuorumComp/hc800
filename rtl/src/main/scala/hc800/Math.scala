package hc800

import spinal.core._
import spinal.lib._

/*
 * The MATH coprocessor: a 32x32 -> 32 multiplier and two 32/32 -> 32 dividers, addressed as a file
 * of byte lanes rather than as a stream of bytes pushed through shift registers.
 *
 * ------------------------------------------------------------------ map (window $0200-$023F)
 *
 *   $0200        R  status, for the unsigned/raw results
 *   $0201        R  status, for the signed results - same layout
 *   $0202,$0203  R  spare, read 0
 *   $0204-$0207 RW X  - operand 1, and the divisor
 *   $0208-$020B RW Y  - operand 2, and the dividend
 *   $020C-$020F R  spare, read 0
 *   $0210-$0213 R  X * Y                (32)
 *   $0214-$0217 R  spare, read 0
 *   $0218-$021B R  unsigned Y / X  quotient
 *   $021C-$021F R  unsigned Y / X  remainder
 *   $0220-$0223 R  signed   Y / X  quotient
 *   $0224-$0227 R  signed   Y / X  remainder
 *   $0228-$023F R  spare, read 0
 *
 * Lane 0 of every value is its least significant byte, so a value is written and read one byte at
 * a time in either order and the addresses simply step.  Reads never destroy anything, so a result
 * may be read twice, and read out of order.
 *
 * --------------------------------------------------------------------------- the strobe
 *
 * There is no operation register and no trigger write: **any write to an input lane**
 * ($0204-$020B) starts the device.  It clears READY, clears the error bits, and restarts all three
 * units from the lane contents as of that write.  A write in the middle of a run is therefore a
 * restart rather than a corruption, and the invariant software can rely on is "the results
 * correspond to the lanes as of the most recent write".  Reading never strobes.
 *
 * The strobe is registered by one cycle.  That is what lets the write which triggers it be seen by
 * *both* operands: the lanes and the strobe move on the same edge, so during the cycle the units
 * load on, everything - including the byte that was just written - is already in place.
 *
 * --------------------------------------------------------- two readings, and why only one is free
 *
 * There is no operation register, so signedness is which result port a program reads.  For the
 * multiply that costs nothing at all: the low half of a product is the same whether the operands
 * are read as signed or unsigned, so one run answers both readings and there is exactly one
 * product port.  For the divide it costs a second unit, and no post-hoc correction reaches it,
 * because signed division negates its operands *before* the loop, not its result afterwards.
 * `-2 / -1` makes it obvious: the same bit patterns divided unsigned are `0 r 0xFFFFFFFE`, while
 * the signed answer is `2 r 0` - a different quotient and remainder, not a negated one.  So the
 * device runs one multiplier and two dividers side by side off one sequencer:
 *
 *   X, Y as written    ->  the unsigned ports
 *   their magnitudes   ->  the signed ports, after sign correction
 *
 * The alternative was one divider run twice, the magnitudes after the bit patterns.  It costs the
 * extra unit nothing and doubles the latency, and it was rejected for two reasons beyond that:
 * nothing is ever half-published (all five result ports and both status bytes become valid on the
 * same cycle, which is what the poll and the three models have to agree about), and there is no
 * boundary between two phases for a sequencer to miss - the first draft's two bugs were both in
 * exactly that machinery.
 *
 * The two readings also disagree about when the answer is undefined, which is why there are two
 * status bytes: `-2^31 / -1` overflows as a signed divide and not as an unsigned one.  Each byte
 * describes its own family and both have the same layout, so the poll and the one-branch error
 * check are identical whichever direction a program is using.
 *
 * ------------------------------------------------------------------ why this machine is 32 bits
 *
 * The device used to be a 64-bit machine: a 64-bit dividend arriving in a third lane, and 64-bit
 * products on two ports.  It cost 831 LUT against 560 for this one, measured on the board's FPGA,
 * and none of it was reachable.  The compiler replicates the dividend's sign byte into the high
 * half before every division, so a genuine 64/32 divide was never emitted and `s64 / s32` is a
 * fatal error; a truncating multiply reads at most four bytes of the product, and results wider
 * than 32 bits are a software expansion over several 32-bit device multiplies, which is what the
 * emitter says in its own comment.  The firmware's helpers are all 32-bit too, and the 32/32
 * divide helper's only use for the high half was writing zeros into it.
 *
 * This is a deliberate loss and not an oversight: a true 64/32 divide and a 64-bit product are now
 * impossible, in hand-written assembly included.  What the narrowing buys beyond the 271 LUT is
 * that the undefined cases nearly vanish - with a 32-bit unsigned dividend the quotient always
 * fits, so the raw overflow bit is wired to zero and the signed one is the single case above - and
 * that the models, the firmware helpers and the compiler's divide path all get shorter, since the
 * sign-replication and four writes into a high-half lane disappear from each of them.
 *
 * ----------------------------------------------------------------------------- latency
 *
 * A run is 32 cycles for every operation and every operand, with no data-dependent early-out: the
 * poll bound is then provable, the models cannot drift on timing, and a driver may assume that a
 * result which arrives early was not a half-computed one.  A 32-bit operand handover is four
 * accesses, sixteen bus cycles, so polling is genuinely required; a 32-bit result readback is four
 * accesses, sixteen cycles, so one poll before the first result byte covers the whole readback.
 */
case class Math() extends Component {
	import Math._

	val io = slave(Bus(addressWidth = LaneWidth))

	// ------------------------------------------------------------------ input lanes
	private val xLane = Reg(Bits(32 bits)) init (0)
	private val yLane = Reg(Bits(32 bits)) init (0)

	private val writePulse  = io.enable.rise && io.write
	private val strobeWrite = writePulse && (io.address >= X) && (io.address <= (Y + 3))

	private def laneWrite(base: Int, lane: Bits, bytes: Int): Unit =
		for (i <- 0 until bytes) {
			when(strobeWrite && (io.address === (base + i))) {
				lane(8 * i + 7 downto 8 * i) := io.dataFromMaster
			}
		}

	laneWrite(X, xLane, 4)
	laneWrite(Y, yLane, 4)

	private val strobe = Reg(Bool()) init (False)
	strobe := False
	when (strobeWrite) { strobe := True }

	private val xOperand = xLane.asUInt
	private val yOperand = yLane.asUInt

	/**
	 * The magnitude of a bit pattern read as two's complement, in the same number of bits:
	 * `INT32_MIN` becomes 2^31, which is exactly why the magnitude has to be taken while there is
	 * room for it - and why it is the magnitude units that are given it, rather than the raw ones
	 * being asked to be careful.
	 */
	private def magnitude(value: UInt): UInt = value.asSInt.abs.resize(value.getWidth bits)

	// ----------------------------------------------------------------------- sequencer
	//
	// Counts 1..32 and stops; bit 5 is therefore "the run is over", and the counter starts there so
	// that a power-up reads READY with meaningless results, as before.  The cycle a run loads on is
	// already its first iteration, so 31 counted cycles plus that one make 32.
	private val counter = Reg(UInt(6 bits)) init (U(Iterations))
	private val done    = counter(5)

	when (strobe) { counter := 1 }.elsewhen (!done) { counter := counter + 1 }

	private val load    = strobe
	private val iterate = !done

	// ------------------------------------------------------------------- the three units
	//
	// One multiplier, because both of its readings are the same number, and a pair of dividers,
	// because only one of theirs is.  Each unit is a datapath with no counter of its own, so the
	// three stay the same length by construction.
	private val multiplier = new MultiplierUnit32x32()
	multiplier.io.load     := load
	multiplier.io.iterate  := iterate
	multiplier.io.operand1 := xOperand
	multiplier.io.operand2 := yOperand

	private val rawDivider = new DividerUnit32x32()
	rawDivider.io.load     := load
	rawDivider.io.iterate  := iterate
	rawDivider.io.dividend := yOperand
	rawDivider.io.divisor  := xOperand

	private val magnitudeDivider = new DividerUnit32x32()
	magnitudeDivider.io.load     := load
	magnitudeDivider.io.iterate  := iterate
	magnitudeDivider.io.dividend := magnitude(yOperand)
	magnitudeDivider.io.divisor  := magnitude(xOperand)

	/*
	 * The signs the run was loaded with, kept for the signed ports.  Reading them from the lanes
	 * instead would make a result depend on operand bytes that a program is free to reload as soon
	 * as the run is over - and only the signs are needed, so only the signs are kept.  Y is both
	 * operand 2 and the dividend now, so one register serves both.
	 */
	private val signX = Reg(Bool()) init (False)
	private val signY = Reg(Bool()) init (False)
	when (strobe) {
		signX := xOperand.msb
		signY := yOperand.msb
	}

	/*
	 * The cases with no arithmetic answer, decided from the operands as they are latched, once per
	 * run - and decided before the results are captured, because that is where they are used.
	 *
	 * A zero divisor is the same question whichever reading of the operands is asked.  Beyond it
	 * there is exactly one undefined division left, and it belongs to the signed reading:
	 * `INT32_MIN / -1`, whose magnitude quotient is 2^31 and fits as `-2^31` but not as `+2^31`.
	 * There is no raw overflow to test, since a 32-bit unsigned dividend always leaves a quotient
	 * that fits, and no post-loop test either - with a 32-bit dividend that one case is the only
	 * way a magnitude quotient can exceed the signed range.
	 */
	private val divisorIsZero = xOperand === U(0, 32 bits)
	private val divideZeroReg     = Reg(Bool()) init (False)
	private val overflowSignedReg = Reg(Bool()) init (False)
	when (strobe) {
		divideZeroReg := divisorIsZero
		overflowSignedReg := (!divisorIsZero) && yOperand.msb && (!yOperand(30 downto 0).orR) &&
			xOperand.andR
	}

	private val divideZero     = divideZeroReg
	private val overflowSigned = overflowSignedReg
	private val invalidSigned  = divideZero || overflowSigned

	// ---------------------------------------------------------------------- results
	//
	// Captured together, one cycle after the last iteration, and held until the next run replaces
	// them.  The undefined cases are forced to zero here rather than at the read ports, which is
	// what lets the read path be wires: the capture does it with the registers' own enables.
	private val product            = Reg(Bits(32 bits)) init (0)
	private val quotientRaw        = Reg(Bits(32 bits)) init (0)
	private val remainderRaw       = Reg(Bits(32 bits)) init (0)
	private val quotientMagnitude  = Reg(Bits(32 bits)) init (0)
	private val remainderMagnitude = Reg(Bits(32 bits)) init (0)

	when (done && (!strobe)) {
		product            := multiplier.io.result.asBits
		quotientRaw        := divideZero ? B(0, 32 bits) | rawDivider.io.quotient.asBits
		remainderRaw       := divideZero ? B(0, 32 bits) | rawDivider.io.remainder.asBits
		quotientMagnitude  := invalidSigned ? B(0, 32 bits) | magnitudeDivider.io.quotient.asBits
		remainderMagnitude := invalidSigned ? B(0, 32 bits) | magnitudeDivider.io.remainder.asBits
	}

	/*
	 * Sign correction on the signed ports, the truncating convention C uses: the quotient is
	 * negative when the operand signs differ, and the remainder follows the dividend.  Zero
	 * negates to zero, so the undefined cases - forced to zero as they are captured - survive this
	 * stage untouched.
	 */
	private val negateQuotient  = signY ^ signX
	private val negateRemainder = signY

	private val quotientSignedValue =
		(negateQuotient ? (-quotientMagnitude.asSInt) | quotientMagnitude.asSInt).asBits
	private val remainderSignedValue =
		(negateRemainder ? (-remainderMagnitude.asSInt) | remainderMagnitude.asSInt).asBits

	// ------------------------------------------------------------------- status bytes
	/*
	 * Laid out so that the low nibble lands on the condition lanes a program tests after putting
	 * the byte in F: bit 0 is the carry lane (the results are ready), bit 1 the zero lane (the
	 * divisor was zero), bit 3 the overflow lane (the quotient did not fit the signed range, so
	 * neither signed result is defined).  Bit 2 - the negative lane - is wired to nothing, and has
	 * to stay that way: "neither error flag" is a single branch (`j/gt`) only while N reads zero.
	 * `$0200` describes the unsigned ports, `$0201` the signed ones.
	 *
	 * The overflow bit of the raw family is wired to nothing too, and that is a property rather
	 * than a simplification: it is the narrowing that made the raw quotient always fit.  The error
	 * bits describe the division every strobe runs, whether or not the program reading the status
	 * byte is about to use its results: a program reading a product ignores them.
	 */
	private val statusRaw = (B"0000" ## False.asBits ## False.asBits ##
		divideZero.asBits ## done.asBits).asBits
	private val statusSigned = (B"0000" ## overflowSigned.asBits ## False.asBits ##
		divideZero.asBits ## done.asBits).asBits

	assert(!statusRaw(2), "the status byte's negative lane must read 0")
	assert(!statusSigned(2), "the signed status byte's negative lane must read 0")
	assert(statusRaw(7 downto 4) === B"0000", "the status byte's reserved bits must read 0")
	assert(statusSigned(7 downto 4) === B"0000", "the signed status byte's reserved bits must read 0")

	// ------------------------------------------------------------------- read paths
	//
	// The window is read as eight-byte blocks, which is what the map is built out of: every 32-bit
	// lane or port is a half-block.  The byte index therefore comes from the low three address
	// bits, and a half-block picks with bit 2 - mixing that bit into both the block and the byte
	// index is how the first version of this read path lost X and Z, which sat in the upper halves
	// of their blocks.
	private val byteLane = io.address(2 downto 0)
	private val block    = io.address(5 downto 3)

	/** The byte of `value` the access selects; `count` is the value's size in bytes, and lanes
	 *  above it read 0. */
	private def byteOf(value: Bits, count: Int, index: UInt): Bits = {
		val selected = Bits(8 bits)
		selected := B(0, 8 bits)
		for (i <- 0 until count) {
			when(index === i) {
				selected := value(8 * i + 7 downto 8 * i)
			}
		}
		selected
	}

	private def byteOfHalf(value: Bits): Bits = byteOf(value, 4, byteLane(1 downto 0))

	private val statusByte = (byteLane === 0) ? statusRaw |
		((byteLane === 1) ? statusSigned | B(0, 8 bits))

	private val readByte = Bits(8 bits)
	readByte := B(0, 8 bits)
	when(block === 0) {
		// The two status bytes and the spares below X, which shares the block with them.
		readByte := byteLane(2) ? byteOfHalf(xLane) | statusByte
	}.elsewhen(block === 1) {
		readByte := byteLane(2) ? B(0, 8 bits) | byteOfHalf(yLane)
	}.elsewhen(block === 2) {
		readByte := byteLane(2) ? B(0, 8 bits) | byteOfHalf(product)
	}.elsewhen(block === 3) {
		readByte := byteLane(2) ? byteOfHalf(remainderRaw.asBits) | byteOfHalf(quotientRaw.asBits)
	}.elsewhen(block === 4) {
		readByte := byteLane(2) ? byteOfHalf(remainderSignedValue) |
			byteOfHalf(quotientSignedValue)
	}

	private val dataOut = Reg(Bits(8 bits)) init (0)
	io.dataToMaster := dataOut
	when (io.enable) { dataOut := readByte }.otherwise { dataOut := B(0, 8 bits) }
}


object Math {
	/** The window is 64 bytes, of which the map above uses $0200-$0227. */
	val LaneWidth = 6

	/** Offsets within the window.  Lane 0 of a value is its least significant byte. */
	val StatusRaw       = 0x00
	val StatusSigned    = 0x01
	val X               = 0x04
	val Y               = 0x08
	val Product         = 0x10
	val QuotientRaw     = 0x18
	val RemainderRaw    = 0x1C
	val QuotientSigned  = 0x20
	val RemainderSigned = 0x24

	/** Iterations in a run, and cycles: the load cycle is the first of them. */
	val Iterations = 32

	/** Status bits, as laid out on the condition lanes. */
	val Ready      = 0x01
	val DivideZero = 0x02
	val Overflow   = 0x08
}
