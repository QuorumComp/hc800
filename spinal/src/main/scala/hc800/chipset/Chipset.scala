package hc800.chipset

import spinal.core._
import spinal.lib._

import hc800.Bus
import hc800.ReadOnlyBus
import hc800.MMU


case class Chipset(scanDoubleDomain: ClockDomain) extends Component {
	private val ioMap = new {
		val interruptController = M"000000--"
		val videoGenerator      = M"0001----"
	}

    val io = new Bundle {
		val red   = out UInt(5 bits)
		val green = out UInt(5 bits)
		val blue  = out UInt(5 bits)
		val hSync = out Bool()
		val vSync = out Bool()

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

		val interruptRequest = out Bool()
    }

	private val doubleSync = false

	private val interruptControllerEnable = (io.regBus.address === ioMap.interruptController)
	private val videoGeneratorEnable = (io.regBus.address === ioMap.videoGenerator)

	private val video = new VideoGenerator(scanDoubleDomain)

	video.io.dblRed   <> io.dblRed
	video.io.dblGreen <> io.dblGreen
	video.io.dblBlue  <> io.dblBlue
	video.io.dblHSync <> io.dblHSync
	video.io.dblVSync <> io.dblVSync
	video.io.dblBlank <> io.dblBlank

	video.io.red   <> io.red
	video.io.green <> io.green
	video.io.blue  <> io.blue
	video.io.hSync <> io.hSync
	video.io.vSync <> io.vSync

	video.io.attrBus <> io.attrBus
	video.io.paletteBus <> io.paletteBus
	video.io.memBus <> io.memBus

	video.io.memBusSource <> io.memBusSource
	video.io.memBusCycle  <> io.memBusCycle

	private val interruptController = new InterruptController()

    interruptController.io.inRequest := B(7 bits,
		0 -> video.io.vBlanking,
		1 -> video.io.hBlanking,
		default -> False)

    interruptController.io.outRequest <> io.interruptRequest

	io.regBus.dataToMaster := 
		io.regBus.wireClient(interruptController.io.regBus, interruptControllerEnable) |
		io.regBus.wireClient(video.io.regBus, videoGeneratorEnable)
}
