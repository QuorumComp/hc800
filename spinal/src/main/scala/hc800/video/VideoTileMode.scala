package hc800.video

import spinal.core._
import spinal.lib._

import hc800.Constants
import hc800.Bus
import hc800.ReadOnlyBus


object VideoTileMode {
	object Register extends SpinalEnum(defaultEncoding = binarySequential) {
		val	control,
			hPosL,
			hPosH,
			vPosL,
			vPosH,
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
			unused0F = newElement()
	}

	object Depth extends SpinalEnum(defaultEncoding = binarySequential) {
		val	colors2,
			colors4,
			colors16,
			colors256 = newElement()
	}
}


class VideoTileMode(secondPlane: Boolean, hTotal: Int) extends Component {
	import VideoTileMode._

	val io = new Bundle {
		val charGenAddress = in UInt(16 bits)

		val memBusCycle = in UInt(4 bits)

		val vSync = in Bool
		val hSync = in Bool
		val hBlank = in Bool
		val pixelEnable = in Bool

		val hPos = in UInt(11 bits)
		val vPos = in UInt(9 bits)

		val indexedColor = out UInt(8 bits)

		val attrBus = master(ReadOnlyBus(addressWidth = 12, dataWidth = 16))
		val memBus = master(ReadOnlyBus(addressWidth = 16))

		val regBus = slave(Bus(addressWidth = Register.craft().getBitsWidth))
	}

	val hires = Reg(Bool) init(False)
	val textMode = Reg(Bool) init(True)
	val depth = Reg(Depth()) init(Depth.colors2)
	val paletteHigh = Reg(Bits(2 bits))

	val hsyncEdge = io.hSync.rise(False)

	val hScrollPos = Reg(UInt(10 bits)) init(0)

	//
	// Shift and Fetch masks
	//

	def secondPlaneFetch(mask: Bits): Bits =
		if (secondPlane) mask.rotateRight(2) else mask

	val shiftMask = hires ? B"1111111111111111" | B"1010101010101010"
	val fetchMask = secondPlaneFetch((hires ## depth).mux (
		B"000" -> B"1000000000000000",
		B"001" -> B"1000000010000000",
		B"010" -> B"1000100010001000",
		B"011" -> B"1010101010101010",
		B"100" -> B"1000000010000000",
		B"101" -> B"1000100010001000",
		B"110" -> B"1010101010101010",
		B"111" -> B"0000000000000000"))

	val readyMask = fetchMask.rotateRight(2)

	val maskIndex = ~io.memBusCycle
	val dataShift = shiftMask(maskIndex)
	val dataFetch = fetchMask(maskIndex)
	val dataReady = readyMask(maskIndex)

	//
	// Attribute fetch
	//

	val attrLine = Reg(UInt(9 bits))
	when (hsyncEdge) {
		attrLine := io.vPos + 1
	}
	
	val normalizedHPos = (io.hBlank ? (io.hPos - hTotal) | io.hPos)

	val attrXAddressHires = normalizedHPos(9 downto 3) + 4 + (hScrollPos(9 downto 4) << 1)
	val attrXAddressLores = normalizedHPos(9 downto 4) + 3 + (hScrollPos(9 downto 4))
	val attrXAddress = hires ? attrXAddressHires | attrXAddressLores
	io.attrBus.address := (attrLine(7 downto 3) ## attrXAddress).resize(12 bits).asUInt
	io.attrBus.enable := True

	//
	// Attribute extraction
	//

	val fetchedAttributes = io.attrBus.dataToMaster
	val attributes = Reg(Bits(8 bits)) init(0)
	val nextAttributes = Reg(Bits(8 bits)) init(0)

	val flipx = Bool()
	val flipy = Bool()
	val priorityInvert = Bool()
	val colorXor = Bits(4 bits)
	val palette = UInt(2 bits)

	when (textMode) {
		colorXor := attributes(7 downto 4)
		palette := 0

		flipx := False
		flipy := False
		priorityInvert := False
	}.otherwise {
		palette := attributes(7 downto 6).asUInt
		flipy := attributes(5)
		flipx := attributes(4)
		priorityInvert := attributes(3)
		colorXor := 0
	}

	//
	// Character data
	//

	val hiresLastCharPixel = normalizedHPos(2 downto 0) === 7
	val loresLastCharPixel = normalizedHPos(3 downto 0) === 15
	val lastCharPixel = hires ? hiresLastCharPixel | loresLastCharPixel

	val charData = Reg(Bits(8 bits)) init(0)
	val nextCharData = Reg(Bits(8 bits)) init(0)

	when (lastCharPixel) {
		charData := nextCharData
		attributes := nextAttributes
	} elsewhen (dataShift) {
		charData := charData |<< 1
	}

	//
	// Pixel out
	//

	val pixelData2Color = (paletteHigh ## palette ## ((U(0, 3 bits) ## charData(7) ^ colorXor)))

	val pixelBuffer = Vec(Reg(Bits(8 bits)), 16)
	for (i <- 0 to 14)
		pixelBuffer(i) := pixelBuffer(i + 1)
	pixelBuffer(15) := pixelData2Color

	io.indexedColor := io.pixelEnable.mux (
		False -> B(0),
		True ->  pixelBuffer(hScrollPos(3 downto 0))
	).asUInt

	//
	// Pixel data fetch
	//

	val incomingCharData = Bits(8 bits)
	val charDataSpill = Bits(3 bits)
	val charDataSpillReg = Reg(Bits(3 bits))

	val italic = nextAttributes(3)
	val bold = nextAttributes(2)
	val underline = nextAttributes(1)

	val underlineCharData = Bits(8 bits)
	underlineCharData := (underline && attrLine(2 downto 0) === 7) ? B"11111111" | io.memBus.dataToMaster
	val boldCharData = Bits(9 bits)
	boldCharData := (underlineCharData ## B"0") | (bold ? (B"0" ## underlineCharData) | 0)
	val italicCharData = Bits(11 bits)
	when (italic && (attrLine(2 downto 0) <= 2)) {
		italicCharData := B"00" ## boldCharData
	}.elsewhen (italic && (attrLine(2 downto 0) <= 4)) {
		italicCharData := B"0" ## boldCharData ## B"0"
	}.otherwise {
		italicCharData := boldCharData ## B"00"
	}
	val finalCharData = (charDataSpillReg | italicCharData(10 downto 8)) ## italicCharData(7 downto 0)

	when (textMode && depth === Depth.colors2) {
		charDataSpill := finalCharData(2 downto 0).asBits
		incomingCharData := finalCharData(10 downto 3)
	}.otherwise {
		charDataSpill := 0
		incomingCharData := io.memBus.dataToMaster
	}

	io.memBus.enable  := False
	io.memBus.address := U(0)

	when (dataReady) {
		nextCharData := incomingCharData
		charDataSpillReg := charDataSpill
	}
 
	when (dataFetch) {
		val tile = textMode ?
			fetchedAttributes(8 downto 0).resize(11 bits) |
			fetchedAttributes(10 downto 0)

		val charAddress = io.charGenAddress + (tile ## attrLine(2 downto 0)).asUInt
		io.memBus.enable  := True
		io.memBus.address := charAddress

		nextAttributes := fetchedAttributes(15 downto 8)
	}
	
	//
	// Register interface
	//

	when (io.regBus.enable && io.regBus.write) {
		val reg = Register()
		reg.assignFromBits(io.regBus.address.asBits)
		switch (reg) {
			is (Register.control) {
				depth       := io.regBus.dataFromMaster(7 downto 6) as Depth()
				paletteHigh := io.regBus.dataFromMaster(5 downto 4)
				textMode    := io.regBus.dataFromMaster(2)
				hires       := io.regBus.dataFromMaster(1)
			}
			is (Register.hPosL) {
				hScrollPos(7 downto 0) := io.regBus.dataFromMaster.asUInt
			}
			is (Register.hPosH) {
				hScrollPos(9 downto 8) := io.regBus.dataFromMaster(1 downto 0).asUInt
			}
		}
	}

	val regData = Reg(Bits(8 bits))
	io.regBus.dataToMaster := regData

	when (io.regBus.enable && !io.regBus.write) {
		val reg = Register()
		reg.assignFromBits(io.regBus.address.asBits)
		regData := reg.mux (
			Register.control -> depth.asBits ## paletteHigh ## False ## textMode ## hires ## False,
			Register.hPosL   -> hScrollPos(7 downto 0).asBits,
			Register.hPosH   -> hScrollPos(9 downto 8).asBits.resized,
			default          -> B(0)
		)
	} otherwise {
		regData := 0
	}
}
