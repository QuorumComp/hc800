package hc800

import spinal.core._
import spinal.lib._
import spinal.lib.fsm._


class UnsignedMultiplierUnit32x32 extends Component {
	val io = new Bundle {
		val restart  = in Bool()
		val operand1 = in (UInt(32 bits))
		val operand2 = in (UInt(32 bits))
		val result   = out (UInt(64 bits))
		val ready    = out Bool()
	}

	private val restartEdge = io.restart.rise

	private val counter = Reg(UInt(6 bits)) init(U(0x20))
	private val timeout = counter(5)

	when (restartEdge) {
		counter := 1
	}.elsewhen (!timeout) {
		counter := counter + 1
	}

	private val accumulator = Reg(UInt(64 bits))
	private val multiplier  = Reg(UInt(31 bits))

	private val newAccumulator = restartEdge ? U(0) | (accumulator |>> 1)
	private val newMultiplier  = restartEdge ? io.operand1 | (multiplier.resize(32))

	private val partialProduct  = newMultiplier(0) ? io.operand2 | 0

	when (restartEdge || !timeout) {
		accumulator := newAccumulator + (partialProduct << 31)
		multiplier  := newMultiplier >> 1
	}

	io.result := accumulator
	io.ready  := timeout && !restartEdge
}


class MultiplierUnit32x32 extends Component {
	val io = new Bundle {
		val signed   = in Bool()
		val restart  = in Bool()
		val operand1 = in (Bits(32 bits))
		val operand2 = in (Bits(32 bits))
		val result   = out (Bits(64 bits))
		val ready    = out (Bool())
	}

	private def operandAsUInt(op: Bits): UInt =
		io.signed ? op.asSInt.abs | op.asUInt

	private val multiplier = new UnsignedMultiplierUnit32x32()
	multiplier.io.restart  := io.restart
	multiplier.io.operand1 := operandAsUInt(io.operand1)
	multiplier.io.operand2 := operandAsUInt(io.operand2)

	private val negateResult = io.signed & (io.operand1.msb ^ io.operand2.msb)

	io.result := (negateResult ? -multiplier.io.result.asSInt | multiplier.io.result.asSInt).asBits
	io.ready  := multiplier.io.ready
}


