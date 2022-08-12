package hc800

import spinal.core._
import spinal.lib._
import spinal.core.sim._

import hc800.video._
import hc800.nexys3.Nexys3
import hc800.keyboard.Keyboard


case class CPU(memoryDomain: ClockDomain)(implicit lpmComponents: rc800.lpm.Components) extends Component {
	val io = new Bundle {
		val irq = in Bool()

		val bus = master(Bus(addressWidth = 16))

		val io     = out Bool()
		val code   = out Bool()
		val system = out Bool()
	}

	private val cpu = new rc800.RC811()

	cpu.io.irq := io.irq
	cpu.io.nmi := False
	
	io.bus.address := cpu.io.address
	io.bus.enable  := cpu.io.busEnable
	io.bus.write   := cpu.io.write
	cpu.io.dataIn := io.bus.dataToMaster
	io.bus.dataFromMaster := cpu.io.dataOut

	io.io := cpu.io.io
	io.code := cpu.io.code
	io.system := cpu.io.int
}


case class BusCPU(memoryDomain: ClockDomain)(implicit lpmComponents: rc800.lpm.Components) extends Component {
	val io = new Bundle {
		val irq = in Bool()

		val cpuBus = master(Bus(addressWidth = 16))
		val ioBus = master(Bus(addressWidth = 16))

		val code   = out Bool()
		val system = out Bool()
	}

	private val cpu = CPU(memoryDomain)

	cpu.io.irq := io.irq

	cpu.io.bus.dataToMaster :=
		cpu.io.bus.wireClient(io.cpuBus, !cpu.io.io) |
		cpu.io.bus.wireClient(io.ioBus, cpu.io.io)

	io.code := cpu.io.code
	io.system := cpu.io.system
}


class HC800(board: Int, vendor: Vendor.Value)(implicit lpmComponents: rc800.lpm.Components) extends Component {

	val boardIsZxNext = board == BoardId.Board.zxNext
	val boardIsMist = board == BoardId.Board.mist
	val boardIsMister = board == BoardId.Board.mister
	val boardIsNexys3 = board == BoardId.Board.nexys3

	val io = new Bundle {
		val btn = boardIsNexys3 generate (in Bits(5 bits))
		val seg = boardIsNexys3 generate (out Bits(8 bits))
		val an  = boardIsNexys3 generate (out Bits(4 bits))

		val red   = out UInt(5 bits)
		val green = out UInt(5 bits)
		val blue  = out UInt(5 bits)
		val hsync = out Bool()
		val vsync = out Bool()
		val blank = out Bool()

		val dblRed   = out UInt(5 bits)
		val dblGreen = out UInt(5 bits)
		val dblBlue  = out UInt(5 bits)
		val dblHSync = out Bool()
		val dblVSync = out Bool()
		val dblBlank = out Bool()
		
		val txd = out Bool()
		val rxd = in  Bool()

		val ramBus = master(Bus(addressWidth = 21))

		val sd_cs = out Bits(2 bits)
		val sd_clock = out Bool()
		val sd_di = out Bool()
		val sd_do = in Bool()

		val keyboardColumns = boardIsZxNext generate (in  Bits(7 bits))
		val keyboardRows    = boardIsZxNext generate (out Bits(8 bits))

		val ps2Code   = (boardIsMist || boardIsMister) generate (in Bits(8 bits))
		val ps2Make   = (boardIsMist || boardIsMister) generate (in Bool())
		val ps2Extend = (boardIsMist || boardIsMister) generate (in Bool())
		val ps2Strobe = (boardIsMist || boardIsMister) generate (in Bool())
	}

	val ioMap = new {
		val intCtrl  = M"000000000000----"
		val mmu      = M"000000010000----"
		val math     = M"000000100000----"
		val keyboard = M"000000110000----"
		val uart     = M"000001000000----"
		val graphics = M"00000101--------"
		val sd       = M"000001100000----"
		val id       = M"011111111111----"
		val board    = M"1---------------"
	}

	val ramMap = new {
		val boot       = M"00000000--------------"
		val kernel     = M"00000001--------------"
		val chargen    = M"00001000--------------"
		val palette    = M"00111000--------------"
		val attributes = M"00111100--------------"
		val ram        = M"1---------------------"
	}

	//  |-----|     |-----|     |-----|     |-----|       Lores pixels
	//  |-----|     |-----|-----|-----|     |-----|-----| Graphics memory access
	//                    |-----|                 |-----| CPU memory access
	//  |-----|     |-----|     |-----|     |-----|       CPU active
	//	+--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +
	//  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 
	// 	+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+
	//  13.5 MHz

	val mainDomain = ClockDomain.external(
		name = "bus",
		frequency = FixedFrequency(Constants.baseFrequency * 2),
		config = ClockDomainConfig(
			clockEdge        = RISING,
			resetKind        = ASYNC,
			resetActiveLevel = HIGH
		)
	)

	val mainArea = new ClockingArea(mainDomain) {
		val cycleCounter = Reg(UInt(4 bits)) init(0)
		cycleCounter := cycleCounter + 1

		private val lowCycleCounter = cycleCounter(1 downto 0)

		val cpuBusMaster = (lowCycleCounter === 0)
		val chipsetBusMaster = !cpuBusMaster
	}

	val graphicsDomain = mainDomain

	val cpuDomain = mainDomain.newClockDomainSlowedBy(2)

	val memoryDomain = mainDomain

	val scanDoubleDomain = ClockDomain.external(
		name = "dbl",
		frequency = FixedFrequency(Constants.baseFrequency * 4),
		config = ClockDomainConfig(
			clockEdge        = RISING,
			resetKind        = ASYNC,
			resetActiveLevel = HIGH
		)
	)

	// --- CPU ---

	val cpuArea = new ClockingArea(cpuDomain) {
		val irq = Bool() addTag(crossClockDomain)

		private val cpu = BusCPU(memoryDomain)

		cpu.io.irq := irq

		val code = cpu.io.code addTag(crossClockDomain)
		val system = cpu.io.system addTag(crossClockDomain)

		val cpuBus = cpu.io.cpuBus addTag(crossClockDomain)
		val ioBus = cpu.io.ioBus addTag(crossClockDomain)
	}


	// --- MEMORY/BUS ---

	val memoryArea = new ClockingArea(memoryDomain) {
		// I/O bus enables
		val mmuEnable      = (mainArea.cpuBusMaster && (cpuArea.ioBus.address === ioMap.mmu))
		val boardIdEnable  = (mainArea.cpuBusMaster && (cpuArea.ioBus.address === ioMap.id))
		val graphicsEnable = (mainArea.cpuBusMaster && (cpuArea.ioBus.address === ioMap.graphics))
		val keyboardEnable = (mainArea.cpuBusMaster && (cpuArea.ioBus.address === ioMap.keyboard))
		val boardEnable    = (mainArea.cpuBusMaster && (cpuArea.ioBus.address === ioMap.board))
		val mathEnable     = (mainArea.cpuBusMaster && (cpuArea.ioBus.address === ioMap.math))
		val uartEnable     = (mainArea.cpuBusMaster && (cpuArea.ioBus.address === ioMap.uart))
		val sdEnable       = (mainArea.cpuBusMaster && (cpuArea.ioBus.address === ioMap.sd))
		val intCtrlEnable  = (mainArea.cpuBusMaster && (cpuArea.ioBus.address === ioMap.intCtrl))

		val chipSource = MMU.MapSource()
		val source = mainArea.cpuBusMaster ? MMU.MapSource.cpu | chipSource

		val chipMemBus = ReadOnlyBus(addressWidth = 16)
		val graphicsRegBus = Bus(addressWidth = 8)
		val attributeMemBus = Bus(addressWidth = hc800.video.AttributeMemory.byteWidth)
		val paletteMemBus = Bus(addressWidth = hc800.video.PaletteMemory.byteWidth)
		
		val machineBus = Bus(addressWidth = 22)
		machineBus.enable := (mainArea.cpuBusMaster ? cpuArea.cpuBus.enable | mainArea.chipsetBusMaster)
		machineBus.write := (mainArea.cpuBusMaster ? cpuArea.cpuBus.write | False)
		machineBus.dataFromMaster := cpuArea.cpuBus.dataFromMaster

		val mmu = new MMU()
		mmu.io.mapAddressIn := (mainArea.cpuBusMaster ? cpuArea.cpuBus.address | chipMemBus.address)
		mmu.io.mapAddressOut <> machineBus.address
		mmu.io.mapSource := source
		mmu.io.mapCode   := cpuArea.code
		mmu.io.mapSystem := cpuArea.system

		// Machine bus enables
		val bootEnable       = machineBus.address === ramMap.boot
		val kernelEnable     = machineBus.address === ramMap.kernel
		val fontEnable       = machineBus.address === ramMap.chargen
		val attrMemEnable    = machineBus.address === ramMap.attributes
		val paletteMemEnable = machineBus.address === ramMap.palette
		val ramEnable        = machineBus.address === ramMap.ram

		val boardId = new BoardId(board)

		def mkZxNextKeyboard(): hc800.keyboard.ZxNextMembrane = {
			val kbd = new hc800.keyboard.ZxNextMembrane()
			kbd.io.columns <> io.keyboardColumns
			kbd.io.rows <> io.keyboardRows
			kbd
		} 

		def mkMistKeyboard(): hc800.keyboard.MistKeyboard = {
			val kbd = new hc800.keyboard.MistKeyboard()
			kbd.io.keyCode <> io.ps2Code
			kbd.io.keyMake <> io.ps2Make
			kbd.io.keyExtend <> io.ps2Extend
			kbd.io.keyStrobe <> io.ps2Strobe
			kbd
		} 

		val keyboard =
			if (boardIsZxNext) mkZxNextKeyboard()
			else if (boardIsMist || boardIsMister) mkMistKeyboard()
			else new hc800.keyboard.NullKeyboard()

		val interruptController = new InterruptController()
		val math = new Math()
		val bootROM = new BootROM()
		val kernel = new RAM(size = 16384) initWith("../firmware/kernel/kernel.bin")
		val font = new Font()
		val uart = new UART()
		val sd = new SD()

		val nexys3 = boardIsNexys3 generate {
			val nexys3 = new Nexys3()
			nexys3.io.segments <> io.seg
			nexys3.io.anode    <> io.an
			nexys3.io.buttons  <> io.btn
			nexys3
		}

		val hBlanking = Bool()
		val vBlanking = Bool()

		interruptController.io.inRequest := B(7 bits,
			0 -> vBlanking,
			1 -> hBlanking,
			default -> False)

		interruptController.io.outRequest <> cpuArea.irq

		uart.io.uart.txd <> io.txd
		uart.io.uart.rxd <> io.rxd

		sd.io.sd_cs <> io.sd_cs
		sd.io.sd_clock <> io.sd_clock
		sd.io.sd_di <> io.sd_di
		sd.io.sd_do <> io.sd_do

		val memDataIn =
			machineBus.wireClient(bootROM.io, bootEnable) |
			machineBus.wireClient(kernel.io, kernelEnable) |
			machineBus.wireClient(font.io, fontEnable) |
			machineBus.wireClient(attributeMemBus, attrMemEnable) |
			machineBus.wireClient(paletteMemBus, paletteMemEnable) |
			machineBus.wireClient(io.ramBus, ramEnable)

		val delayMemDataIn = Delay(memDataIn, 1)
		cpuArea.cpuBus.dataToMaster := delayMemDataIn
		chipMemBus.dataToMaster := delayMemDataIn

		val nexys3IoDataIn = 
			if (boardIsNexys3) cpuArea.ioBus.wireClient(nexys3.io.bus, boardEnable)
			else B"00000000"

		val ioDataIn =
			nexys3IoDataIn |
			cpuArea.ioBus.wireClient(graphicsRegBus, graphicsEnable) |
			cpuArea.ioBus.wireClient(mmu.io.regBus, mmuEnable) |
			cpuArea.ioBus.wireClient(boardId.io, boardIdEnable) |
			cpuArea.ioBus.wireClient(keyboard.io.bus, keyboardEnable) |
			cpuArea.ioBus.wireClient(math.io, mathEnable) |
			cpuArea.ioBus.wireClient(uart.io.bus, uartEnable) |
			cpuArea.ioBus.wireClient(sd.io.bus, sdEnable) |
			cpuArea.ioBus.wireClient(interruptController.io.regBus, intCtrlEnable)

		val delayIoDataIn = Delay(ioDataIn, 1)
		cpuArea.ioBus.dataToMaster := delayIoDataIn
	}


	// --- CHIPSET ---

	val graphicsArea = new ClockingArea(graphicsDomain) {
		val videoGenerator = new VideoGenerator(scanDoubleDomain)

		io.red   <> videoGenerator.io.red
		io.green <> videoGenerator.io.green
		io.blue  <> videoGenerator.io.blue
		io.hsync <> videoGenerator.io.hSync
		io.vsync <> videoGenerator.io.vSync
		io.blank := videoGenerator.io.hBlanking || videoGenerator.io.vBlanking

		io.dblRed   <> videoGenerator.io.dblRed
		io.dblGreen <> videoGenerator.io.dblGreen
		io.dblBlue  <> videoGenerator.io.dblBlue
		io.dblHSync <> videoGenerator.io.dblHSync
		io.dblVSync <> videoGenerator.io.dblVSync
		io.dblBlank <> videoGenerator.io.dblBlank
		
		videoGenerator.io.memBus <> memoryArea.chipMemBus

		videoGenerator.io.memBusCycle <> mainArea.cycleCounter
		memoryArea.chipSource := videoGenerator.io.memBusSource

		videoGenerator.io.vBlanking <> memoryArea.vBlanking
		videoGenerator.io.hBlanking <> memoryArea.hBlanking

		val graphicsMemoryArea = new ClockingArea(memoryDomain) {
			videoGenerator.io.regBus <> memoryArea.graphicsRegBus

			val attrMemory = new SpinalAttributeMemory()
			attrMemory.io.byteBus <> memoryArea.attributeMemBus
			attrMemory.io.wideBus <> videoGenerator.io.attrBus

			val paletteMemory = new SpinalPaletteMemory() //256
			paletteMemory.io.byteBus <> memoryArea.paletteMemBus
			paletteMemory.io.wideBus <> videoGenerator.io.paletteBus
		}
	}
}


object Vendor extends Enumeration {
	val Xilinx, Altera = Value
}

//Generate the MyTopLevel's Verilog
object HC800TopLevel {
	def generate(name: String, board: Int, vendor: Vendor.Value)(implicit lpmComponents: rc800.lpm.Components): Unit = {
		new SpinalConfig(
			defaultClockDomainFrequency = FixedFrequency(Constants.baseFrequency * 2),
			netlistFileName = name
		).generateVerilog(new HC800(board, vendor)).printPruned()
	}

	def main(args: Array[String]): Unit = {
		//generate("../../../rtl/hc800_zxnext.v", BoardId.Board.zxNext, Vendor.Xilinx)(rc800.lpm.generic.Components)
		//generate("../../../rtl/hc800_mist.v", BoardId.Board.mist, Vendor.Altera)(rc800.lpm.blackbox.Components)
		//generate("hc800_nexys3.v", BoardId.Board.nexys3.position, Vendor.Xilinx)
		//generate("../../../rtl/hc800_mister.v", BoardId.Board.mister, Vendor.Altera)(rc800.lpm.blackbox.Components)
	}
}
