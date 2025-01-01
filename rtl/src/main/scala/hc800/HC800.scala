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


class HC800(board: Int, vendor: Vendor.Value)(implicit lpmComponents: rc800.lpm.Components) extends Component {

	val boardIsZxNext = board == BoardId.Board.zxNext
	val boardIsMist   = board == BoardId.Board.mist
	val boardIsMister = board == BoardId.Board.mister
	val boardIsNexys3 = board == BoardId.Board.nexys3
	val boardIsMega65 = board == BoardId.Board.mega65

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

		val sd_cs     = out Bits(2 bits)
		val sd_detect = in Bool()
		val sd_clock  = out Bool()
		val sd_mosi   = out Bool()
		val sd_miso   = in Bool()

		// ZX Spectrum Next
		val keyboardColumns = boardIsZxNext generate (in  Bits(7 bits))
		val keyboardRows    = boardIsZxNext generate (out Bits(8 bits))

		// MEGA65
		val kio8_o  = boardIsMega65 generate (out Bool())
		val kio9_o  = boardIsMega65 generate (out Bool())
		val kio10_i = boardIsMega65 generate (in Bool())

		// MiST and MiSTer
		val ps2Code   = (boardIsMist || boardIsMister) generate (in Bits(8 bits))
		val ps2Make   = (boardIsMist || boardIsMister) generate (in Bool())
		val ps2Extend = (boardIsMist || boardIsMister) generate (in Bool())
		val ps2Strobe = (boardIsMist || boardIsMister) generate (in Bool())
	}

	val ramMap = new {
		val boot       = M"00000000--------------"
		val kernel     = M"00000001--------------"
		val chargen    = M"00001000--------------"
		val intCtrl    = M"010000000000000000----"
		val mmu        = M"010000000000010000----"
		val math       = M"010000000000100000----"
		val keyboard   = M"010000000000110000----"
		val uart       = M"010000000001000000----"
		val graphics   = M"01000000000101--------"
		val sd         = M"010000000001100000----"
		val board      = M"01000001111110000-----"
		val id         = M"010000011111111111----"
		val palette    = M"01000010--------------"
		val attributes = M"01000011--------------"
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

		private val cpu = CPU(memoryDomain)

		cpu.io.irq := irq

		val io = cpu.io.io addTag(crossClockDomain)
		val code = cpu.io.code addTag(crossClockDomain)
		val system = cpu.io.system addTag(crossClockDomain)

		val cpuBus = cpu.io.bus addTag(crossClockDomain)
	}


	// --- MEMORY/BUS ---

	val memoryArea = new ClockingArea(memoryDomain) {
		val chipSource = MMU.MapSource()
		val source = mainArea.cpuBusMaster ? MMU.MapSource.cpu | chipSource

		val chipMemBus = ReadOnlyBus(addressWidth = 16)
		val graphicsRegBus = Bus(addressWidth = 8)
		val attributeMemBus = Bus(addressWidth = hc800.video.AttributeMemory.byteWidth)
		val paletteMemBus = Bus(addressWidth = hc800.video.PaletteMemory.byteWidth)
		
		val machineBus = Bus(addressWidth = 22)
		machineBus.enable := RegNext(mainArea.cpuBusMaster ? cpuArea.cpuBus.enable | mainArea.chipsetBusMaster)
		machineBus.write := RegNext(mainArea.cpuBusMaster ? cpuArea.cpuBus.write | False)
		machineBus.dataFromMaster := RegNext(cpuArea.cpuBus.dataFromMaster)

		val mmu = new MMU()
		mmu.io.mapAddressIn := (mainArea.cpuBusMaster ? cpuArea.cpuBus.address | chipMemBus.address)
		mmu.io.mapSource := source
		mmu.io.mapIo     := cpuArea.io
		mmu.io.mapCode   := cpuArea.code
		mmu.io.mapSystem := cpuArea.system
		machineBus.address := RegNext(mmu.io.mapAddressOut)

		// Machine bus enables
		val mmuEnable        = machineBus.address === ramMap.mmu
		val boardIdEnable    = machineBus.address === ramMap.id
		val graphicsEnable   = machineBus.address === ramMap.graphics
		val keyboardEnable   = machineBus.address === ramMap.keyboard
		val boardEnable      = machineBus.address === ramMap.board
		val mathEnable       = machineBus.address === ramMap.math
		val uartEnable       = machineBus.address === ramMap.uart
		val sdEnable         = machineBus.address === ramMap.sd
		val intCtrlEnable    = machineBus.address === ramMap.intCtrl
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

		def mkMega65Keyboard(): hc800.keyboard.Mega65Keyboard = {
			val kbd = new hc800.keyboard.Mega65Keyboard()
			kbd.io.kio8_o  <> io.kio8_o
			kbd.io.kio9_o  <> io.kio9_o
			kbd.io.kio10_i <> io.kio10_i
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
			if (boardIsZxNext) 
				mkZxNextKeyboard()
			else if (boardIsMist || boardIsMister)
				mkMistKeyboard()
			else if (boardIsMega65)
				mkMega65Keyboard()
			else 
				new hc800.keyboard.NullKeyboard()

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

		sd.io.sd_cs     <> io.sd_cs
		sd.io.sd_detect <> io.sd_detect
		sd.io.sd_clock  <> io.sd_clock
		sd.io.sd_mosi   <> io.sd_mosi
		sd.io.sd_miso   <> io.sd_miso

		val nexys3IoDataIn = 
			if (boardIsNexys3) machineBus.wireClient(nexys3.io.bus, boardEnable)
			else B"00000000"

		val memDataIn =
			nexys3IoDataIn |
			machineBus.wireClient(graphicsRegBus, graphicsEnable) |
			machineBus.wireClient(mmu.io.regBus, mmuEnable) |
			machineBus.wireClient(boardId.io, boardIdEnable) |
			machineBus.wireClient(keyboard.io.bus, keyboardEnable) |
			machineBus.wireClient(math.io, mathEnable) |
			machineBus.wireClient(uart.io.bus, uartEnable) |
			machineBus.wireClient(sd.io.bus, sdEnable) |
			machineBus.wireClient(interruptController.io.regBus, intCtrlEnable) |
			machineBus.wireClient(bootROM.io, bootEnable) |
			machineBus.wireClient(kernel.io, kernelEnable) |
			machineBus.wireClient(font.io, fontEnable) |
			machineBus.wireClient(attributeMemBus, attrMemEnable) |
			machineBus.wireClient(paletteMemBus, paletteMemEnable) |
			machineBus.wireClient(io.ramBus, ramEnable)

		cpuArea.cpuBus.dataToMaster := memDataIn
		chipMemBus.dataToMaster := memDataIn
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
		generate("../boards/mega65/hc800_mega65.v", BoardId.Board.mega65, Vendor.Xilinx)(rc800.lpm.generic.Components)
		generate("../boards/specnext/hc800_zxnext.v", BoardId.Board.zxNext, Vendor.Xilinx)(rc800.lpm.generic.Components)
		generate("../boards/nexys3/hc800_nexys3.v", BoardId.Board.nexys3, Vendor.Xilinx)(rc800.lpm.generic.Components)
		//generate("../../../rtl/hc800_mist.v", BoardId.Board.mist, Vendor.Altera)(rc800.lpm.blackbox.Components)
		//generate("../../../rtl/hc800_mister.v", BoardId.Board.mister, Vendor.Altera)(rc800.lpm.blackbox.Components)
	}
}
