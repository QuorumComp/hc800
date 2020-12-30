package hc800

import spinal.core._
import spinal.lib._
import spinal.lib.fsm._

class UnsignedDividerUnit16x16 extends Component {
	val io = new Bundle {
		val restart   = in Bool()
		val dividend  = in (UInt(32 bits))
		val divisor   = in (UInt(16 bits))
		val quotient  = out (UInt(16 bits))
		val remainder = out (UInt(16 bits))
		val ready     = out Bool()
	}

	private val restartEdge = io.restart.rise

	private val counter = Reg(UInt(5 bits)) init(U(0x10))
	private val timeout = counter(4)

	when (restartEdge) {
		counter := 0
	}.elsewhen (!counter(4)) {
		counter := counter + 1
	}

	private val accumulator = Reg(UInt(32 bits))

	private val workAccumulator = restartEdge ? io.dividend | accumulator
	private val subtractedQuotient = workAccumulator(31 downto 16) - io.divisor
	private val couldSubtract = !subtractedQuotient.msb
	private val nextRemainder = couldSubtract ? subtractedQuotient(15 downto 0) | workAccumulator(31 downto 16)

	when (restartEdge || !timeout) {
		when (counter =/= U(15)) {
			accumulator := ((nextRemainder(14 downto 0)) ## (workAccumulator(15 downto 0)) ## couldSubtract).asUInt
		}.otherwise {
			accumulator := ((nextRemainder(15 downto 0)) ## (workAccumulator(14 downto 0)) ## couldSubtract).asUInt
		}
	}

	io.quotient  := accumulator(15 downto 0)
	io.remainder := accumulator(31 downto 16)
	io.ready     := timeout && !restartEdge
}


class DividerUnit16x16 extends Component {
	val io = new Bundle {
		val signed    = in Bool()
		val restart   = in Bool()
		val dividend  = in (Bits(32 bits))
		val divisor   = in (Bits(16 bits))
		val quotient  = out (Bits(16 bits))
		val remainder = out (Bits(16 bits))
		val ready     = out (Bool())
	}

	private def operandAsUInt(op: Bits): UInt =
		io.signed ? op.asSInt.abs | op.asUInt

	private val divider = new UnsignedDividerUnit16x16()
	divider.io.restart  := io.restart
	divider.io.dividend := operandAsUInt(io.dividend)
	divider.io.divisor  := operandAsUInt(io.divisor)

	private val negateResult = io.signed & (io.dividend.msb ^ io.divisor.msb)

	io.quotient  := (negateResult ? -divider.io.quotient.asSInt | divider.io.quotient.asSInt).asBits
	io.remainder := divider.io.remainder.asBits
	io.ready     := divider.io.ready
}


