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

	val shiftMask = hires ? B"1111111111111111" | B"0101010101010101"
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

	val attrXAddress = (hires ? normalizedHPos(9 downto 3) | normalizedHPos(9 downto 4).resize(7 bits)) + 2
	io.attrBus.address := (attrLine(7 downto 3) ## attrXAddress).resize(12 bits).asUInt
	io.attrBus.enable := True

	//
	// Character data
	//

	val hiresLastCharPixel = normalizedHPos(2 downto 0) === (~hScrollPos(2 downto 0))
	val loresLastCharPixel = normalizedHPos(3 downto 0) === (~hScrollPos(3 downto 0))
	val lastCharPixel = hires ? hiresLastCharPixel | loresLastCharPixel

	val fetchedAttributes = io.attrBus.dataToMaster
	val attributes = Reg(Bits(8 bits)) init(0)
	val nextAttributes = Reg(Bits(8 bits)) init(0)

	val charData = Reg(Bits(8 bits)) init(0)
	val nextCharData = Reg(Bits(8 bits)) init(0)

	//
	// Attribute extraction
	//

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
	// Pixel data out
	//

	val currentCharData = charData

	when (lastCharPixel) {
		charData := nextCharData
		attributes := nextAttributes
	} elsewhen (dataShift) {
		charData := charData |<< 1
	}

	val pixel = currentCharData(7)
	val pixelData2Color = (paletteHigh ## palette ## ((U(0, 3 bits) ## pixel ^ colorXor)))

	io.indexedColor := io.pixelEnable.mux (
		False -> B(0),
		True ->  pixelData2Color
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

	when (dataFetch) {
		val tile = textMode ?
			fetchedAttributes(8 downto 0).resize(11 bits) |
			fetchedAttributes(10 downto 0)

		val charAddress = io.charGenAddress + (tile ## attrLine(2 downto 0)).asUInt
		io.memBus.enable  := True
		io.memBus.address := charAddress

		nextAttributes := fetchedAttributes(15 downto 8)
	}
	
	when (dataReady) {
		nextCharData := incomingCharData
		charDataSpillReg := charDataSpill
		io.memBus.enable  := False
		io.memBus.address := U(0)
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

	when (io.regBus.enable && !io.regBus.write) {
		val reg = Register()
		reg.assignFromBits(io.regBus.address.asBits)
		io.regBus.dataToMaster := reg.mux (
			Register.control -> B(depth ## paletteHigh ## False ## textMode ## hires ## True).resize(8 bits),
			Register.hPosL   -> hScrollPos(7 downto 0).asBits,
			Register.hPosH   -> hScrollPos(9 downto 8).asBits.resized,
			default          -> B(0)
		)
	} otherwise {
		io.regBus.dataToMaster := 0
	}
}
