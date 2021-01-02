package hc800.video

import spinal.core._
import spinal.lib._

import hc800.Constants
import hc800.ReadOnlyBus


class VideoTileMode extends Component {
	val io = new Bundle {
		val charGenAddress = in UInt(16 bits)

		val memBusCycle = in UInt(4 bits)

		val vSync = in Bool
		val hSync = in Bool
		val pixelEnable = in Bool

		val hPos = in UInt(11 bits)
		val vPos = in UInt(9 bits)

		val hires = in Bool
		val textModeEnable = in Bool
		val paletteHigh = in Bits(2 bits)

		val indexedColor = out UInt(8 bits)

		val attrBus = master(ReadOnlyBus(addressWidth = 12, dataWidth = 16))
		val memBus = master(ReadOnlyBus(addressWidth = 16))
	}

	val hsyncEdge = io.hSync.rise(False)

	// Attribute address
	val attrLine = Reg(UInt(9 bits))
	when (hsyncEdge) {
		attrLine := io.vPos + 1
	}
	val nextAttrChar = (io.hires ? io.hPos(9 downto 3) | io.hPos(9 downto 4).resize(7 bits)) + 1
	val horizontalOffScreen : Bool = io.hPos > Constants.totalHiresPixels;
	val attrChar = horizontalOffScreen ? U(0) | nextAttrChar

	io.attrBus.address := (attrLine(7 downto 3) ## attrChar).resize(12 bits).asUInt
	io.attrBus.enable := True

	// Character data
	val charData = Reg(Bits(8 bits)) init(0)
	val nextCharData = Reg(Bits(8 bits)) init(0)
	val nextAttributes = Reg(Bits(8 bits)) init(0)
	val attributes = Reg(Bits(8 bits)) init(0)

	val flipx = Bool()
	val flipy = Bool()
	val priorityInvert = Bool()
	val colorXor = Bits(4 bits)
	val palette = UInt(2 bits)

	when (io.textModeEnable) {
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


	val newCharDataReady = io.hires ? io.hPos(2 downto 0).andR | io.hPos(3 downto 0).andR
	val shiftCharData = io.hires ? True | io.hPos(0)
	var charDataSpill = Reg(Bits(3 bits)) init(0)

	when (newCharDataReady) {
		when (io.textModeEnable) {
			val italic = nextAttributes(3)
			val bold = nextAttributes(2)
			val underline = nextAttributes(1)

			val underlineCharData = Bits(8 bits)
			underlineCharData := (underline && attrLine(2 downto 0) === 7) ? B"11111111" | nextCharData.asBits
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
			val spill = horizontalOffScreen ? B(0, 3 bits) | charDataSpill;
			val finalCharData = (spill | italicCharData(10 downto 8)) ## italicCharData(7 downto 0)
			charDataSpill := finalCharData(2 downto 0).asBits
			charData := finalCharData(10 downto 3)
		}.otherwise {
			charData := nextCharData
		}

		attributes := nextAttributes
	}.elsewhen (shiftCharData) {
		charData := charData |<< 1
	}

	val pixelData = charData(7)

	io.indexedColor := io.pixelEnable.mux (
		False -> (io.paletteHigh ## palette ## U(0, 4 bits)),
		True -> (io.paletteHigh ## palette ## ((U(0, 3 bits) ## pixelData) ^ colorXor))
	).asUInt

	io.memBus.enable  := False
	io.memBus.address := U(0)

	val setupMainBus = io.hires ? (io.memBusCycle(2 downto 0) === 2) | (io.memBusCycle === 2)
	val fetchMainBus = io.hires ? (io.memBusCycle(2 downto 0) === 4) | (io.memBusCycle === 4)

	when (setupMainBus) {
		val attributes = io.attrBus.dataToMaster
		nextAttributes := attributes(15 downto 8)

		val tile = Bits(11 bits)

		when (io.textModeEnable) {
			tile := attributes(8 downto 0).resize(11 bits)
		}.otherwise {
			tile := attributes(10 downto 0)
		}
		val charAddress = io.charGenAddress + (tile ## attrLine(2 downto 0)).asUInt
		io.memBus.enable  := True
		io.memBus.address := charAddress
	}
	
	when (fetchMainBus) {
		nextCharData := io.memBus.dataToMaster
		io.memBus.enable  := False
		io.memBus.address := U(0)
	}
 
}

