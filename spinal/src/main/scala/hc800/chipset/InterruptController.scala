package hc800.chipset

import spinal.core._
import spinal.lib._

import hc800.Bus

case class InterruptController() extends Component {
	import InterruptController._

	val io = new Bundle {
		val inRequest  = in  Bits(7 bits)
		val outRequest = out Bool()

		val regBus = slave(Bus(addressWidth = Register.craft().getBitsWidth))
	}

	private def riseAll(in: Bits): Bits = {
		B(in.range.map(i => in(i).rise(False)))
	}

	private val enable  = Reg(Bits(7 bits)) init(0)
	private val request = Reg(Bits(7 bits)) init(0)
	private val handle  = enable & request

	request := request | riseAll(io.inRequest)

	io.outRequest := handle.orR

	private def setClear(oldValue: Bits, newBits: Bits, set: Bool): Bits = {
		set ? (oldValue | newBits) | (oldValue & ~newBits)
	}

	when (io.regBus.enable && io.regBus.write) {
		val reg = Register()
		reg.assignFromBits(io.regBus.address.asBits)
		switch (reg) {
			is (Register.enable)  { enable  := setClear(enable,  io.regBus.dataFromMaster(6 downto 0), io.regBus.dataFromMaster(7)) }
			is (Register.request) { request := setClear(request, io.regBus.dataFromMaster(6 downto 0), io.regBus.dataFromMaster(7)) }
		}
	}

	val regDataOut = Reg(Bits(8 bits))
	io.regBus.dataToMaster := regDataOut

	when (io.regBus.enable && !io.regBus.write) {
		val reg = Register()
		reg.assignFromBits(io.regBus.address.asBits)
		regDataOut := reg.mux (
			Register.enable  -> enable.resize(8 bits),
			Register.request -> request.resize(8 bits),
			Register.handle  -> handle.resize(8 bits)
		)
	}.otherwise {
		regDataOut := 0
	}
}


object InterruptController {
	object Register extends SpinalEnum(defaultEncoding = binarySequential) {
		val enable, request, handle = newElement()
	}
}