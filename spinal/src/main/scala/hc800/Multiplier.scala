package hc800

import spinal.core._
import spinal.lib._
import spinal.lib.fsm._


class UnsignedMultiplierUnit16x16 extends Component {
	val io = new Bundle {
		val restart  = in Bool()
		val operand1 = in (UInt(16 bits))
		val operand2 = in (UInt(16 bits))
		val result   = out (UInt(32 bits))
		val ready    = out Bool()
	}

	private val restartEdge = io.restart.rise

	private val counter = Reg(UInt(5 bits)) init(U(0x10))
	private val timeout = counter(4)

	when (restartEdge) {
		counter := 1
	}.elsewhen (!counter(4)) {
		counter := counter + 1
	}

	private val accumulator = Reg(UInt(32 bits))
	private val multiplier  = Reg(UInt(15 bits))

	private val newAccumulator = restartEdge ? U(0) | (accumulator |>> 1)
	private val newMultiplier  = restartEdge ? io.operand1 | (multiplier.resize(16))

	private val partialProduct  = newMultiplier(0) ? io.operand2 | 0

	when (restartEdge || !timeout) {
		accumulator := newAccumulator + (partialProduct << 15)
		multiplier  := newMultiplier >> 1
	}

	io.result := accumulator
	io.ready  := timeout && !restartEdge
}


class MultiplierUnit16x16 extends Component {
	val io = new Bundle {
		val signed   = in Bool()
		val restart  = in Bool()
		val operand1 = in (Bits(16 bits))
		val operand2 = in (Bits(16 bits))
		val result   = out (Bits(32 bits))
		val ready    = out (Bool())
	}

	private def operandAsUInt(op: Bits): UInt =
		io.signed ? op.asSInt.abs | op.asUInt

	private val multiplier = new UnsignedMultiplierUnit16x16()
	multiplier.io.restart  := io.restart
	multiplier.io.operand1 := operandAsUInt(io.operand1)
	multiplier.io.operand2 := operandAsUInt(io.operand2)

	private val negateResult = io.signed & (io.operand1.msb ^ io.operand2.msb)

	io.result := (negateResult ? -multiplier.io.result.asSInt | multiplier.io.result.asSInt).asBits
	io.ready  := multiplier.io.ready
}


