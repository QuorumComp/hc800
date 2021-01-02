package hc800.nexys3

import spinal.core._
import spinal.lib._
import spinal.lib.com.uart._

import hc800.Bus


class Nexys3 extends Component {
	val io = new Bundle {
		val bus = slave(Bus(addressWidth = 15))

		val segments = out Bits(8 bits)
		val anode    = out Bits(4 bits)

		val buttons  = in  Bits(5 bits)
	}

	val ioMap = new {
		val hexSegments = M"00000000000----"
		val buttons     = M"00000000001----"
	}

	val hexEnable = (io.bus.address === ioMap.hexSegments)
	val buttonsEnable = (io.bus.address === ioMap.buttons)

	private val hexSegments = new HexSegmentsDevice()
	io.bus.wireClient(hexSegments.io.bus, hexEnable)
	hexSegments.io.segments <> io.segments
	hexSegments.io.anode    <> io.anode

	private val buttons = new Buttons(5)
	buttons.io.buttons <> io.buttons

	io.bus.dataToMaster := 
		io.bus.wireClient(buttons.io.bus, buttonsEnable)
}
