package hc800.video

import spinal.core._
import spinal.lib._

import hc800.Bus
import hc800.ReadOnlyBus
import hc800.MMU
import hc800.Constants


object VideoGenerator {
	object Register extends SpinalEnum(defaultEncoding = binarySequential) {
		val control,
			unused01,
			unused02,
			unused03,
			unused04,
			unused05,
			unused06,
			unused07,
			unused08,
			unused09,
			unused0A,
			unused0B,
			unused0C,
			unused0D,
			unused0E,
			debug = newElement()
	}
}


class VideoGenerator(scanDoubleDomain: ClockDomain) extends Component {
	import VideoGenerator._

	val io = new Bundle {
		val red   = out UInt(5 bits)
		val green = out UInt(5 bits)
		val blue  = out UInt(5 bits)
		val hSync = out Bool()
		val vSync = out Bool()
		val hBlanking = out Bool()
		val vBlanking = out Bool()

		val dblRed   = out UInt(5 bits)
		val dblGreen = out UInt(5 bits)
		val dblBlue  = out UInt(5 bits)
		val dblHSync = out Bool()
		val dblVSync = out Bool()
		val dblBlank = out Bool()

		val attrBus = master(ReadOnlyBus(addressWidth = 12, dataWidth = 16))
        val paletteBus = master(ReadOnlyBus(addressWidth = 8, dataWidth = 16))
		val memBus = master(ReadOnlyBus(addressWidth = 16))

		val memBusSource   = out (MMU.MapSource())
		val memBusCycle    = in  UInt(4 bits)

		val regBus = slave(Bus(addressWidth = 8))
	}

	private val hDisp      = Constants.totalHiresPixels
	private val hSyncStart = 48+hDisp
	private val hSyncEnd   = 32+hSyncStart
	private val hTotal     = 80+hSyncEnd

	private val native = new Area {
		private val vDisp      = Constants.totalVideolines
		private val vSyncStart = 3+vDisp
		private val vSyncEnd   = 7+vSyncStart
		private val vTotal     = 6+vSyncEnd

		private val sync = new VideoSync(initialHPos = 0, initialVPos = 0)
		sync.io.hDisp      := hDisp
		sync.io.hSyncStart := hSyncStart
		sync.io.hSyncEnd   := hSyncEnd
		sync.io.hEnd       := hTotal-1

		sync.io.vDisp      := vDisp
		sync.io.vSyncStart := vSyncStart
		sync.io.vSyncEnd   := vSyncEnd
		sync.io.vEnd       := vTotal-1

		val hSync = sync.io.hSync
		val hBlanking = sync.io.hBlanking
		val vSync = sync.io.vSync
		val pixelEnable = sync.io.pixelEnable
		val hPos = sync.io.hPos
		val vPos = sync.io.vPos

		val hSyncOut = Delay(hSync, 2)
		val vSyncOut = Delay(vSync, 2)
		val hBlankingOut = Delay(sync.io.hBlanking, 1)
		val vBlankingOut = Delay(sync.io.vBlanking, 1)
		val hPosOut = Delay(sync.io.hPos, 1)
		val vPosOut = Delay(sync.io.vPos, 1)
		val pixelEnableOut = !(hBlankingOut || vBlankingOut)

		io.hSync := hSyncOut
		io.vSync := vSyncOut
		io.hBlanking := hBlankingOut
		io.vBlanking := vBlankingOut
	}

	private val double = new ClockingArea(scanDoubleDomain) {
		private val vDisp      = 480
		private val vSyncStart = 9+vDisp
		private val vSyncEnd   = 6+vSyncStart
		private val vTotal     = 17+vSyncEnd

		private val sync = new VideoSync(initialHPos = hTotal - 2, initialVPos = vTotal - 3)
		sync.io.hDisp      := hDisp
		sync.io.hSyncStart := hSyncStart
		sync.io.hSyncEnd   := hSyncEnd
		sync.io.hEnd       := hTotal-1

		sync.io.vDisp      := vDisp
		sync.io.vSyncStart := vSyncStart
		sync.io.vSyncEnd   := vSyncEnd
		sync.io.vEnd       := vTotal-1

		io.dblHSync := Delay(sync.io.hSync, 1)
		io.dblVSync := Delay(sync.io.vSync, 1)
		io.dblBlank := Delay(!sync.io.pixelEnable, 2)

		val hPos = sync.io.hPos
		val vPos = sync.io.vPos
	}

	private val scanDoubler = new ScanDoubler(scanDoubleDomain)
	scanDoubler.io.pixelEnableIn := native.pixelEnableOut
	scanDoubler.io.hPosIn   := native.hPosOut
	scanDoubler.io.vPosIn   := native.vPosOut(7 downto 0)
	scanDoubler.io.redIn    := io.red
	scanDoubler.io.greenIn  := io.green
	scanDoubler.io.blueIn   := io.blue
	scanDoubler.io.hPosOut  := double.hPos
	scanDoubler.io.vPosOut  := double.vPos

	when (io.dblBlank) {
		io.dblRed   := 0
		io.dblGreen := 0
		io.dblBlue  := 0
	} otherwise {
		io.dblRed   := scanDoubler.io.redOut
		io.dblGreen := scanDoubler.io.greenOut
		io.dblBlue  := scanDoubler.io.blueOut
	}

	val plane0Enable = Reg(Bool()) init(True)
	val plane1Enable = Reg(Bool()) init(False)
	val frameEnable  = Reg(Bool()) init(False)

	val plane0 = new VideoTileMode(secondPlane = false, hTotal = hTotal)
	plane0.io.charGenAddress <> U(0)
	plane0.io.vSync <> native.vSync
	plane0.io.hSync <> native.hSync
	plane0.io.hBlank <> native.hBlanking
	plane0.io.pixelEnable <> native.pixelEnable
	plane0.io.hPos <> native.hPos
	plane0.io.vPos <> native.vPos
	plane0.io.attrBus <> io.attrBus
	plane0.io.memBus <> io.memBus
	plane0.io.memBusCycle <> io.memBusCycle
	io.memBusSource := MMU.MapSource.chipsetCharGen

	val frameMode = new VideoFrame()
	frameMode.io.pixelEnable <> native.pixelEnable
	frameMode.io.hPos <> native.hPos
	frameMode.io.vPos <> native.vPos

	io.paletteBus.enable := True
	io.paletteBus.address :=
		(frameEnable && (frameMode.io.indexedColor =/= U(0))) ? frameMode.io.indexedColor |
		plane0.io.indexedColor

	when (native.pixelEnableOut) {
		io.red   := io.paletteBus.dataToMaster(14 downto 10).asUInt
		io.green := io.paletteBus.dataToMaster(9 downto 5).asUInt
		io.blue  := io.paletteBus.dataToMaster(4 downto 0).asUInt
	}.otherwise {
		io.red   := 0
		io.green := 0
		io.blue  := 0
	}


	// --- Register interface ---

	val controlBusEnable = io.regBus.enable && (io.regBus.address === M"0000----")
	val plane0BusEnable  = io.regBus.enable && (io.regBus.address === M"0001----")
	val plane1BusEnable  = io.regBus.enable && (io.regBus.address === M"0010----")

	val controlBus = Bus(addressWidth = Register.craft().getBitsWidth)

	when (controlBus.enable && controlBus.write) {
		val reg = Register()
		reg.assignFromBits(io.regBus.address.resize(controlBus.addressWidth).asBits)
		switch (reg) {
			is (Register.control) {
				plane1Enable := io.regBus.dataFromMaster(1)
				plane0Enable := io.regBus.dataFromMaster(0)
			}
			is (Register.debug) {
				frameEnable := io.regBus.dataFromMaster(0)
			}
		}
	}

	when (controlBus.enable && !controlBus.write) {
		val reg = Register()
		reg.assignFromBits(controlBus.address.asBits)
		controlBus.dataToMaster := reg.mux (
			Register.control -> B(plane1Enable ## plane0Enable).resize(8 bits),
			Register.debug   -> B(frameEnable).resize(8 bits),
			default          -> B(0)
		)
	} otherwise {
		controlBus.dataToMaster := 0
	}

	io.regBus.dataToMaster := 
		io.regBus.wireClient(controlBus, controlBusEnable) |
		io.regBus.wireClient(plane0.io.regBus, plane0BusEnable)

}
