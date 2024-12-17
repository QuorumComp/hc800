package hc800.video

import spinal.core._
import spinal.lib._
import hc800.Constants

case class ScanDoubler(doubleDomain: ClockDomain) extends Component {
	val io = new Bundle {
		val pixelEnableIn = in Bool()
		val hPosIn  = in UInt(11 bits)
		val vPosIn  = in UInt(8 bits)
		val redIn   = in UInt(5 bits)
		val greenIn = in UInt(5 bits)
		val blueIn  = in UInt(5 bits)

		val hPosOut  = in UInt(11 bits)
		val vPosOut  = in UInt(9 bits)
		val redOut   = out UInt(5 bits)
		val greenOut = out UInt(5 bits)
		val blueOut  = out UInt(5 bits)
	}
	
	private val scanlineBuffer0, scanlineBuffer1 = ScanlineMemory(doubleDomain)

	private val writeBuffer = io.vPosIn(0)
	private val readBuffer = io.vPosOut(1)

	private def wireMemoryIn(memory: ScanlineMemory, enable: Bool): Unit = {
		memory.io.ena <> (writeBuffer === enable)
		memory.io.wea <> io.pixelEnableIn
		memory.io.addra <> io.hPosIn(9 downto 0)
		memory.io.dina <> io.redIn ## io.greenIn ## io.blueIn
	}

	wireMemoryIn(scanlineBuffer0, True)
	wireMemoryIn(scanlineBuffer1, False)

	private val doubleArea = new ClockingArea(doubleDomain) {
		def wireMemoryOut(memory: ScanlineMemory, enable: Bool): Unit = {
			memory.io.enb <> (readBuffer === enable)
			memory.io.addrb <> io.hPosOut(9 downto 0)
		}

		wireMemoryOut(scanlineBuffer0, True)
		wireMemoryOut(scanlineBuffer1, False)

		val rgbOut = readBuffer ? scanlineBuffer0.io.doutb | scanlineBuffer1.io.doutb

		io.redOut   := rgbOut(14 downto 10).asUInt
		io.greenOut := rgbOut(9 downto 5).asUInt
		io.blueOut  := rgbOut(4 downto 0).asUInt
	}
}