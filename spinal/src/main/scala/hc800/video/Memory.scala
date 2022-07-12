package hc800.video

import hc800.Bus
import hc800.ReadOnlyBus
import hc800.Constants
import spinal.core._
import spinal.lib._


case class ScanlineMemory(busDomain: ClockDomain) extends BlackBox {
	val words = Constants.totalHiresPixels
	val width = log2Up(words)

	val io = new Bundle {
		val clka = in Bool()
		val ena = in Bool()
		val wea = in Bool()
		val addra = in UInt(width bits)
		val dina = in Bits(15 bits)

		val clkb = in Bool()
		val enb = in Bool()
		val addrb = in UInt(width bits)
		val doutb = out Bits(15 bits)
	}

	noIoPrefix()

	mapClockDomain(clock = io.clka)
	mapClockDomain(clockDomain = busDomain, clock = io.clkb)
}


class AttributeMemory extends BlackBox {
	import AttributeMemory._

	val io = new Bundle {
		val clka = in Bool()
		val ena = in Bool()
		val wea = in Bits(2 bits)
		val addra = in UInt(width bits)
		val dina = in Bits(16 bits)
		val douta = out Bits(16 bits)

		val clkb = in Bool()
		val enb = in Bool()
		val web = in Bool()
		val addrb = in UInt((width + 1) bits)
		val dinb = in Bits(8 bits)
		val doutb = out Bits(8 bits)
	}

	noIoPrefix()

	mapClockDomain(clock = io.clka)
	mapClockDomain(clock = io.clkb)
}

object AttributeMemory {
	val words = 4096
	val width = log2Up(words)
	val byteWidth = width + 1
}


class PaletteMemory extends BlackBox {
	import PaletteMemory._

	val io = new Bundle {
		val clka = in Bool()
		val ena = in Bool()
		val wea = in Bits(2 bits)
		val addra = in UInt(width bits)
		val dina = in Bits(16 bits)
		val douta = out Bits(16 bits)

		val clkb = in Bool()
		val enb = in Bool()
		val web = in Bool()
		val addrb = in UInt(byteWidth bits)
		val dinb = in Bits(8 bits)
		val doutb = out Bits(8 bits)
	}

	noIoPrefix()

	mapClockDomain(clock = io.clka)
	mapClockDomain(clock = io.clkb)
}

object PaletteMemory {
	val words = 256
	val width = log2Up(words)
	val byteWidth = width + 1
}


class SpinalAttributeMemory extends Component {
	val memory = new AttributeMemory()

	val io = new Bundle {
		val wideBus = slave(ReadOnlyBus(addressWidth = AttributeMemory.width, dataWidth = 16))
		val byteBus = slave(Bus(addressWidth = AttributeMemory.byteWidth, dataWidth = 8))
	}

	memory.io.dina := 0
	memory.io.wea := 0

	io.wideBus.dataToMaster <> memory.io.douta
	io.wideBus.address <> memory.io.addra
	io.wideBus.enable  <> memory.io.ena

	io.byteBus.dataFromMaster <> memory.io.dinb
	io.byteBus.address <> memory.io.addrb
	io.byteBus.write   <> memory.io.web
	io.byteBus.enable  <> memory.io.enb

	when (Delay(io.byteBus.enable, 1)) {
		io.byteBus.dataToMaster := memory.io.doutb
	} otherwise {
		io.byteBus.dataToMaster := 0
	}
}


class SpinalPaletteMemory extends Component {
	val memory = new PaletteMemory()

	val io = new Bundle {
		val wideBus = slave(ReadOnlyBus(addressWidth = PaletteMemory.width, dataWidth = 16))
		val byteBus = slave(Bus(addressWidth = PaletteMemory.byteWidth))
	}

	memory.io.dina := 0
	memory.io.wea := 0

	io.wideBus.dataToMaster <> memory.io.douta
	io.wideBus.address <> memory.io.addra
	io.wideBus.enable  <> memory.io.ena

	io.byteBus.dataFromMaster <> memory.io.dinb
	io.byteBus.address <> memory.io.addrb
	io.byteBus.write   <> memory.io.web
	io.byteBus.enable  <> memory.io.enb

	when (Delay(io.byteBus.enable, 1)) {
		io.byteBus.dataToMaster := memory.io.doutb
	} otherwise {
		io.byteBus.dataToMaster := 0
	}
}


