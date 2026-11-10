package hc800

import spinal.core._
import spinal.lib._
import spinal.lib.fsm._


/*
 * An old experiment, not connected to anything: four multipliers whose products are summed.
 * It grew a counter of its own when the multiplier unit stopped carrying one, since the unit
 * is now a datapath the caller iterates rather than a machine that runs itself - and note
 * that it always ignored the unit's `ready`, so the sum was only ever correct if somebody
 * waited thirty-two cycles by hand.  `done` says when that is.
 */
class DotProduct extends Component {
	val io = new Bundle {
		val restart  = in  Bool()
		val done     = out Bool()
		val operand1 = in  (Vec(SInt(16 bits), 4))
		val operand2 = in  (Vec(SInt(16 bits), 4))
		val result   = out (SInt(32 bits))
	}

	private val counter = Reg(UInt(6 bits)) init (U(32))
	when (io.restart) { counter := 1 }.elsewhen (!counter(5)) { counter := counter + 1 }

	private val multipliers = Vector.fill(4)(new MultiplierUnit32x32())

	for (i <- 0 to 3) {
		multipliers(i).io.load     := io.restart
		multipliers(i).io.iterate  := !counter(5)
		// The unit is a 32-bit machine; the operands are widened the way they were when the
		// unit took Bits, which is zero-padded rather than sign-extended.
		multipliers(i).io.operand1 := io.operand1(i).asBits.asUInt.resized
		multipliers(i).io.operand2 := io.operand2(i).asBits.asUInt.resized
	}

	io.done   := counter(5)
	io.result := multipliers.map(v => v.io.result.asSInt).reduce((v1, v2) => v1 + v2)
}


case class Coprocessor() extends Component {
    import Coprocessor._

    val io = new Bundle {
		val busAddress = out UInt(11 bits)
		val busEnable  = out Bool()
		val busWrite   = out Bool()
		val busDataOut = out Bits(16 bits)
		val busDataIn  = out Bits(16 bits)

        val regAddress = in  UInt(Register.craft().getBitsWidth bits)
        val regWrite   = in  Bool()
        val regEnable  = in  Bool()
        val regDataIn  = in  Bits(8 bits)
        val regDataOut = out Bits(8 bits)
	}
	
	private val running = Reg(Bool) init(False)
	private val streamSource = Reg(UInt(11 bits))
	private val streamDestination = Reg(UInt(11 bits))
	private val pc = Reg(UInt(11 bits))
	private val loopCount = Reg(UInt(8 bits))

	private val operation = Reg(Bits(15 bits))

	private val fsm = new StateMachine {
		val fetchState = new State with EntryPoint {
			onEntry {
				running := False
			}
			whenIsActive {
				when (running) {
					io.busAddress := pc
					io.busEnable := True
					io.busWrite := False
					goto (decodeOpcode)
				}
			}
		}

		val decodeOpcode = new State {
			whenIsActive {
				pc := pc + 1
				operation := io.busDataIn(14 downto 0)
				when (io.busDataIn(15)) {
					goto (instructionA)
				}.otherwise {
					goto (instructionI)
				}
			}
		}

		val instructionA = new State {
			whenIsActive {
			}
		}

		val instructionI = new State {
			whenIsActive {
			}
		}
	}
	when (running) {
		val stage = Reg(UInt(2 bits))

	}

    when (io.regEnable && io.regWrite) {
        val reg = Register()
        reg.assignFromBits(io.regAddress.asBits)
        switch (reg) {
            is (Register.streamSourceLow)  { streamSource := (streamSource(10 downto 8) ## io.regDataIn).asUInt }
            is (Register.streamSourceHigh) { streamSource := (io.regDataIn ## streamSource(7 downto 0)).asUInt }
            is (Register.streamDestinationLow)  { streamDestination := (streamDestination(10 downto 8) ## io.regDataIn).asUInt }
            is (Register.streamDestinationHigh) { streamDestination := (io.regDataIn ## streamDestination(7 downto 0)).asUInt }
            is (Register.loopCount) { loopCount := io.regDataIn.asUInt }
            is (Register.programIndex) { pc := io.regDataIn.asUInt << 1; running := True }
        }
    }

    when (io.regEnable && !io.regWrite) {
        val reg = Register()
        reg.assignFromBits(io.regAddress.asBits)
        io.regDataOut := reg.mux (
            Register.status  -> B(0, 7 bits) ## running,
        )
    }.otherwise {
        io.regDataOut := 0
    }
}


object Coprocessor {
    object Register extends SpinalEnum(defaultEncoding = binarySequential) {
		val	status,
			streamSourceLow,
			streamSourceHigh,
			streamDestinationLow,
			streamDestinationHigh,
			loopCount,
			programIndex = newElement()
    }
}
