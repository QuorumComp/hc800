package hc800

import spinal.core._
import spinal.lib._
import spinal.core.sim._

import chipset.Chipset
import chipset.SpinalAttributeMemory
import chipset.SpinalPaletteMemory
import nexys3.Nexys3
import java.awt.image.Kernel
import hc800.keyboard.Keyboard


case class CPU(memoryDomain: ClockDomain) extends Component {
	val io = new Bundle {
		val irq = in Bool

		val bus = master(Bus(addressWidth = 16))

		val io     = out Bool
		val code   = out Bool
		val system = out Bool
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
	io.system := cpu.io.intActive
}


case class BusCPU(memoryDomain: ClockDomain) extends Component {
	val io = new Bundle {
		val irq = in Bool

		val cpuBus = master(Bus(addressWidth = 16))
		val ioBus = master(Bus(addressWidth = 16))

		val code   = out Bool
		val system = out Bool
	}

	private val cpu = CPU(memoryDomain)

	cpu.io.irq := io.irq

	cpu.io.bus.dataToMaster :=
		cpu.io.bus.wireClient(io.cpuBus, !cpu.io.io) |
		cpu.io.bus.wireClient(io.ioBus, cpu.io.io)

	io.code := cpu.io.code
	io.system := cpu.io.system
}


class HC800(boardIndex: Int, vendor: Vendor.Value) extends Component {

	val board = BoardId.Board.elements(boardIndex)
	val boardIsZxNext = board == BoardId.Board.zxNext
	val boardIsMist = board == BoardId.Board.mist

	val io = new Bundle {
		val btn = in Bits(5 bits)

		val seg = out Bits(8 bits)
		val an  = out Bits(4 bits)

		val red   = out UInt(5 bits)
		val green = out UInt(5 bits)
		val blue  = out UInt(5 bits)
		val hsync = out Bool()
		val vsync = out Bool()

		val dblRed   = out UInt(5 bits)
		val dblGreen = out UInt(5 bits)
		val dblBlue  = out UInt(5 bits)
		val dblHSync = out Bool()
		val dblVSync = out Bool()
		val dblBlank = out Bool()

		val txd = out Bool()
		val rxd = in  Bool()

		val ramBus = master(Bus(addressWidth = 21))

		val keyboardColumns = boardIsZxNext generate (in  Bits(7 bits))
		val keyboardRows    = boardIsZxNext generate (out Bits(8 bits))

		val ps2Code   = boardIsMist generate (in Bits(8 bits))
		val ps2Make   = boardIsMist generate (in Bool())
		val ps2Extend = boardIsMist generate (in Bool())
		val ps2Strobe = boardIsMist generate (in Bool())
	}

	val ioMap = new {
		val chipset  = M"00000000--------"
		val mmu      = M"000000010000----"
		val math     = M"000000100000----"
		val keyboard = M"000000110000----"
		val uart     = M"000001000000----"
		val id       = M"011111111111----"
		val board    = M"1---------------"
	}

	val ramMap = new {
		val boot       = M"00000000--------------"
		val kernal     = M"00000001--------------"
		val chargen    = M"00001000--------------"
		val palette    = M"00111000--------------"
		val attributes = M"00111100--------------"
		val ram        = M"1---------------------"
	}

	//  |-----|     |-----|     |-----|     |-----|       Lores pixels
	//  |-----|     |-----|-----|-----|     |-----|-----| Chipset memory access
	//        |-----|                 |-----|             CPU memory access
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
		val cycleCounter = Reg(UInt(4 bits)) init(Constants.firstCycle)
		cycleCounter := cycleCounter + 1

		private val lowCycleCounter = cycleCounter(2 downto 0)

		val cpuClockEnable = cycleCounter(0)
		val cpuBusMaster = (lowCycleCounter === 1) || (lowCycleCounter === 5)
		val chipsetBusMaster = !cpuBusMaster
	}

	val chipsetDomain = mainDomain

	val cpuDomain = ClockDomain.external(
		name = "cpu",
		frequency = FixedFrequency(Constants.baseFrequency),
		config = ClockDomainConfig(
			clockEdge        = RISING,
			resetKind        = ASYNC,
			resetActiveLevel = HIGH
		)
	)

	val memoryDomain = mainDomain


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
		val chipsetEnable  = (mainArea.cpuBusMaster && (cpuArea.ioBus.address === ioMap.chipset))
		val keyboardEnable = (mainArea.cpuBusMaster && (cpuArea.ioBus.address === ioMap.keyboard))
		val boardEnable    = (mainArea.cpuBusMaster && (cpuArea.ioBus.address === ioMap.board))
		val mathEnable     = (mainArea.cpuBusMaster && (cpuArea.ioBus.address === ioMap.math))
		val uartEnable     = (mainArea.cpuBusMaster && (cpuArea.ioBus.address === ioMap.uart))

		val dataFromMaster = (cpuArea.cpuBus.dataFromMaster | cpuArea.ioBus.dataFromMaster)

		val chipSource  = MMU.MapSource()
		val source = mainArea.cpuBusMaster ? MMU.MapSource.cpu | chipSource

		val chipMemBus = ReadOnlyBus(addressWidth = 16)
		val chipRegBus = Bus(addressWidth = 8)
		val attributeMemBus = Bus(addressWidth = hc800.chipset.AttributeMemory.byteWidth)
		val paletteMemBus = Bus(addressWidth = hc800.chipset.PaletteMemory.byteWidth)
		
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
		val kernalEnable     = machineBus.address === ramMap.kernal
		val fontEnable       = machineBus.address === ramMap.chargen
		val attrMemEnable    = machineBus.address === ramMap.attributes
		val paletteMemEnable = machineBus.address === ramMap.palette
		val ramEnable        = machineBus.address === ramMap.ram

		val boardId = new BoardId(boardIndex)

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
			else if (boardIsMist) mkMistKeyboard()
			else new hc800.keyboard.NullKeyboard()

		val math = new Math()
		val bootROM = new BootROM()
		val kernal = new RAM(size = 16384)
		val font = new Font()
		val uart = new UART()
		val nexys3 = new Nexys3()

		nexys3.io.segments <> io.seg
		nexys3.io.anode    <> io.an
		nexys3.io.buttons  <> io.btn

		uart.io.uart.txd <> io.txd
		uart.io.uart.rxd <> io.rxd

		val memDataIn =
			machineBus.wireClient(bootROM.io.bus, bootEnable) |
			machineBus.wireClient(kernal.io, kernalEnable) |
			machineBus.wireClient(font.io, fontEnable) |
			machineBus.wireClient(attributeMemBus, attrMemEnable) |
			machineBus.wireClient(paletteMemBus, paletteMemEnable) |
			machineBus.wireClient(io.ramBus, ramEnable)

		val delayMemDataIn = Delay(memDataIn, 1)
		cpuArea.cpuBus.dataToMaster := delayMemDataIn
		chipMemBus.dataToMaster := delayMemDataIn

		val ioDataIn =
			cpuArea.ioBus.wireClient(nexys3.io.bus, boardEnable) |
			cpuArea.ioBus.wireClient(chipRegBus, chipsetEnable) |
			cpuArea.ioBus.wireClient(mmu.io.regBus, mmuEnable) |
			cpuArea.ioBus.wireClient(boardId.io, boardIdEnable) |
			cpuArea.ioBus.wireClient(keyboard.io.bus, keyboardEnable) |
			cpuArea.ioBus.wireClient(math.io, mathEnable) |
			cpuArea.ioBus.wireClient(uart.io.bus, uartEnable)

		val delayIoDataIn = Delay(ioDataIn, 1)
		cpuArea.ioBus.dataToMaster := delayIoDataIn
	}


	// --- CHIPSET ---

	val scanDoubleDomain = ClockDomain.external(
		name = "dbl",
		frequency = FixedFrequency(Constants.baseFrequency * 4),
		config = ClockDomainConfig(
			clockEdge        = RISING,
			resetKind        = ASYNC,
			resetActiveLevel = HIGH
		)
	)

	val chipsetArea = new ClockingArea(chipsetDomain) {
		val chipset = new Chipset(scanDoubleDomain)

		io.red   <> chipset.io.red
		io.green <> chipset.io.green
		io.blue  <> chipset.io.blue
		io.hsync <> chipset.io.hSync
		io.vsync <> chipset.io.vSync

		io.dblRed   <> chipset.io.dblRed
		io.dblGreen <> chipset.io.dblGreen
		io.dblBlue  <> chipset.io.dblBlue
		io.dblHSync <> chipset.io.dblHSync
		io.dblVSync <> chipset.io.dblVSync
		io.dblBlank <> chipset.io.dblBlank

		cpuArea.irq <> chipset.io.interruptRequest

		chipset.io.memBus <> memoryArea.chipMemBus

		chipset.io.memBusCycle <> mainArea.cycleCounter
		memoryArea.chipSource := chipset.io.memBusSource

		val chipsetMemoryArea = new ClockingArea(memoryDomain) {
			chipset.io.regBus <> memoryArea.chipRegBus

			val attrMemory = new SpinalAttributeMemory()
			attrMemory.io.byteBus <> memoryArea.attributeMemBus
			attrMemory.io.wideBus <> chipset.io.attrBus

			val paletteMemory = new SpinalPaletteMemory() //256
			paletteMemory.io.byteBus <> memoryArea.paletteMemBus
			paletteMemory.io.wideBus <> chipset.io.paletteBus
		}
	}
}


object Vendor extends Enumeration {
	val Xilinx, Altera = Value
}

//Generate the MyTopLevel's Verilog
object HC800TopLevel {
	def generate(name: String, board: Int, vendor: Vendor.Value): Unit = {
		new SpinalConfig(
			defaultClockDomainFrequency = FixedFrequency(Constants.baseFrequency * 2),
			netlistFileName = name
		).generateVerilog(new HC800(board, vendor)).printPruned()
	}

	def main(args: Array[String]) {
		generate("../specnext/hc800_zxnext.v", BoardId.Board.zxNext.position, Vendor.Xilinx)
		generate("../mist/hc800_mist.v", BoardId.Board.mist.position, Vendor.Altera)
		generate("hc800_nexys3.v", BoardId.Board.nexys3.position, Vendor.Xilinx)
	}
}
