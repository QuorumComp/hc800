package hc800.keyboard

import spinal.core._
import spinal.lib._

import hc800.ReadOnlyBus


class KeyboardBusIO() extends Bundle {
	val bus = slave(ReadOnlyBus(addressWidth = 1))
}

abstract class Keyboard[T <: KeyboardBusIO](ioIn: => T) extends Component {
	import Keyboard._

	val io = ioIn

	val fifo = new StreamFifo(dataType = Bits(8 bits), depth = 4)

	val busRegister = io.bus.address.as(Register())
	val readingData = io.bus.enable && (busRegister === Register.data);

	val keyCode = Reg(Bits(8 bits))
	val keyCodeReady = RegInit(False)

	when (readingData.rise) {
		keyCodeReady := False
	}

	val getNextValue = (fifo.io.pop.valid && !keyCodeReady).rise
	fifo.io.pop.ready := getNextValue
	when (getNextValue) {
		keyCode := fifo.io.pop.payload
		keyCodeReady := True
	}

	val busDataOut = Reg(Bits(8 bits))
	io.bus.dataToMaster := busDataOut

	when (io.bus.enable) {
		busDataOut := busRegister.mux (
			Register.data -> keyCode,
			Register.status -> B(keyCodeReady).resize(8 bits)
		)
	} otherwise {
		busDataOut := 0
	}

}


object Keyboard {
	object Register extends SpinalEnum(defaultEncoding = binarySequential) {
		val data, status = newElement()
	}
}