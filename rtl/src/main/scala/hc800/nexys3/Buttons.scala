package hc800.nexys3

import spinal.core._
import spinal.lib._

import hc800.ReadOnlyBus

class Buttons(count: Int) extends Component {
	val io = new Bundle {
		val bus = slave(ReadOnlyBus(addressWidth = 0))
		val buttons = in Bits(count bits)
	}

	val buttonsBuf1 = RegNext(io.buttons) init(0)
	val buttonsBuf2 = RegNext(buttonsBuf1) init(0)

	val dataToMaster = Reg(Bits(8 bits))
	io.bus.dataToMaster := dataToMaster

	when (io.bus.enable) {
		dataToMaster := (buttonsBuf1 & buttonsBuf2).resize(8 bits)
	}.otherwise {
		dataToMaster := 0
	}
}