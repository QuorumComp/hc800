package hc800

import spinal.core._
import spinal.lib._
import spinal.lib.fsm._

class UnsignedDividerUnit32x32 extends Component {
	val io = new Bundle {
		val restart   = in Bool()
		val dividend  = in (UInt(64 bits))
		val divisor   = in (UInt(32 bits))
		val quotient  = out (UInt(32 bits))
		val remainder = out (UInt(32 bits))
		val ready     = out Bool()
	}

	private val restartEdge = io.restart.rise

	private val counter = Reg(UInt(6 bits)) init(U(0x20))
	private val timeout = counter(5)

	when (restartEdge) {
		counter := 0
	}.elsewhen (!timeout) {
		counter := counter + 1
	}

	private val accumulator = Reg(UInt(64 bits))

	private val workAccumulator = restartEdge ? io.dividend | accumulator
	private val subtractedQuotient = workAccumulator(63 downto 32) - io.divisor
	private val couldSubtract = !subtractedQuotient.msb
	private val nextRemainder = couldSubtract ? subtractedQuotient(31 downto 0) | workAccumulator(63 downto 32)

	when (restartEdge || !timeout) {
		when (counter =/= U(31)) {
			accumulator := ((nextRemainder(30 downto 0)) ## (workAccumulator(31 downto 0)) ## couldSubtract).asUInt
		}.otherwise {
			accumulator := ((nextRemainder(31 downto 0)) ## (workAccumulator(30 downto 0)) ## couldSubtract).asUInt
		}
	}

	io.quotient  := accumulator(31 downto 0)
	io.remainder := accumulator(63 downto 32)
	io.ready     := timeout && !restartEdge
}


class DividerUnit32x32 extends Component {
	val io = new Bundle {
		val signed    = in Bool()
		val restart   = in Bool()
		val dividend  = in (Bits(64 bits))
		val divisor   = in (Bits(32 bits))
		val quotient  = out (Bits(32 bits))
		val remainder = out (Bits(32 bits))
		val ready     = out (Bool())
	}

	private def operandAsUInt(op: Bits): UInt =
		io.signed ? op.asSInt.abs | op.asUInt

	private val divider = new UnsignedDividerUnit32x32()
	divider.io.restart  := io.restart
	divider.io.dividend := operandAsUInt(io.dividend)
	divider.io.divisor  := operandAsUInt(io.divisor)

	private val negateResult = io.signed & (io.dividend.msb ^ io.divisor.msb)

	io.quotient  := (negateResult ? -divider.io.quotient.asSInt | divider.io.quotient.asSInt).asBits
	io.remainder := divider.io.remainder.asBits
	io.ready     := divider.io.ready
}


