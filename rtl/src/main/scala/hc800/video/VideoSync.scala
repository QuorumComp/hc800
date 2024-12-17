package hc800.video

import spinal.core._
import spinal.lib._

//
// VGA signal generator
//
// |disp                              |front|sync |back |
// |----------------------------------+-----+-----+-----|
//                                    |     |     |     |
//                                    |     |     |     +- end (total - 1)
//                                    |     |     +------- sync end
//                                    |     +------------- sync start
//                                    +------------------- disp
//

class VideoSync(initialHPos: Int, initialVPos: Int) extends Component {
	val horizontalBits = 11 bits
	val verticalBits = 9 bits

    val io = new Bundle {
        // VGA configuration
        val hDisp      = in UInt(horizontalBits)
        val hSyncStart = in UInt(horizontalBits)
		val hSyncEnd   = in UInt(horizontalBits)
		val hEnd       = in UInt(horizontalBits)

        val vDisp      = in UInt(verticalBits)
        val vSyncStart = in UInt(verticalBits)
		val vSyncEnd   = in UInt(verticalBits)
		val vEnd       = in UInt(verticalBits)

		// Output
		val hSync = out Bool()
		val vSync = out Bool()

		val hBlanking = out Bool()
		val vBlanking = out Bool()

		// Beam/pixel positions
		val hPos        = out UInt(horizontalBits)
		val vPos        = out UInt(verticalBits)
		val pixelEnable = out Bool()
    }

	val hPosReg = Reg(UInt(horizontalBits)) init(initialHPos)
	val vPosReg = Reg(UInt(verticalBits)) init(initialVPos)

	when (hPosReg === io.hEnd) {
		hPosReg := 0
		when (vPosReg === io.vEnd) {
			vPosReg := 0
		}.otherwise {
			vPosReg := vPosReg + 1
		}
	}.otherwise {
		hPosReg := hPosReg + 1
	}

	io.hSync := (hPosReg >= io.hSyncStart) && (hPosReg < io.hSyncEnd)
	io.vSync := (vPosReg >= io.vSyncStart) && (vPosReg < io.vSyncEnd)
	io.hPos  := hPosReg
	io.vPos  := vPosReg
	io.hBlanking := hPosReg >= io.hDisp
	io.vBlanking := vPosReg >= io.vDisp
	io.pixelEnable := !(io.hBlanking || io.vBlanking)
}