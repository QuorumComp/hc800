package hc800.chipset

import spinal.core._
import spinal.lib._

import hc800.Constants


class VideoFrame extends Component {
	val io = new Bundle {
		val pixelEnable = in Bool

		val hPos = in UInt(11 bits)
		val vPos = in UInt(9 bits)

		val indexedColor = out UInt(8 bits)
	}

	io.indexedColor := (io.pixelEnable && ((io.hPos === 0) || (io.hPos === 847) || (io.vPos === 0) || (io.vPos === 239))) ? U(1, 8 bits) | U(0, 8 bits)
}

