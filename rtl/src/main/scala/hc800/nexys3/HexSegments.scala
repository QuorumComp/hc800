package hc800.nexys3

import spinal.core._
import spinal.lib._

import hc800.WriteOnlyBus


case class SegmentIo() extends Bundle {
    val enable = Bool ()
    val data = UInt(4 bits)
}


case class HexToSegment() extends Component {
    val io = new Bundle {
        val dataIn  = in  UInt(4 bits)
        val dataOut = out Bits(8 bits)
    }

    io.dataOut := io.dataIn.mux(
        U( 0) -> ~B("00111111"),
		U( 1) -> ~B("00000110"),
		U( 2) -> ~B("01011011"),
		U( 3) -> ~B("01001111"),
		U( 4) -> ~B("01100110"),
		U( 5) -> ~B("01101101"),
		U( 6) -> ~B("01111101"),
		U( 7) -> ~B("00000111"),
		U( 8) -> ~B("01111111"),
		U( 9) -> ~B("01100111"),
		U(10) -> ~B("01110111"),
		U(11) -> ~B("01111100"),
		U(12) -> ~B("00111001"),
		U(13) -> ~B("01011110"),
		U(14) -> ~B("01111001"),
		U(15) -> ~B("01110001")
    )
}


class HexSegmentArray() extends Component {
    val io = new Bundle {
        val segment3 = in (SegmentIo())
        val segment2 = in (SegmentIo())
        val segment1 = in (SegmentIo())
        val segment0 = in (SegmentIo())

        val segments = out Bits(8 bits)
        val anode    = out Bits(4 bits)
    }

    val currentEnable = Bool()
    val currentMask = Bits(8 bits)

    val anodeMask = RegInit(B"1110")
    anodeMask := anodeMask.rotateLeft(1)

    val segment3 = HexToSegment()
    segment3.io.dataIn := io.segment3.data

    val segment2 = HexToSegment()
    segment2.io.dataIn := io.segment2.data

    val segment1 = HexToSegment()
    segment1.io.dataIn := io.segment1.data

    val segment0 = HexToSegment()
    segment0.io.dataIn := io.segment0.data

    when (anodeMask(3) === False) {
        currentEnable := io.segment3.enable
        currentMask := segment3.io.dataOut
    }.elsewhen (anodeMask(2) === False) {
        currentEnable := io.segment2.enable
        currentMask := segment2.io.dataOut
    }.elsewhen (anodeMask(1) === False) {
        currentEnable := io.segment1.enable
        currentMask := segment1.io.dataOut
    }.elsewhen (anodeMask(0) === False) {
        currentEnable := io.segment0.enable
        currentMask := segment0.io.dataOut
    }.otherwise {
        currentEnable := False
        currentMask := B(0)
    }

    io.segments := currentEnable ? currentMask | B(0xFF)
    io.anode    := anodeMask
}

class HexSegments extends Component {
    val io = new Bundle {
        val dataIn   = in  UInt(16 bits)

        val segments = out Bits(8 bits)
        val anode    = out Bits(4 bits)
    }

    val driver = new HexSegmentArray()

    driver.io.segment3.data   := io.dataIn(15 downto 12)
    driver.io.segment3.enable := True
    driver.io.segment2.data   := io.dataIn(11 downto 8)
    driver.io.segment2.enable := True
    driver.io.segment1.data   := io.dataIn(7 downto 4)
    driver.io.segment1.enable := True
    driver.io.segment0.data   := io.dataIn(3 downto 0)
    driver.io.segment0.enable := True

    io.segments := driver.io.segments
    io.anode    := driver.io.anode
}

class HexSegmentsDevice extends Component {
    val io = new Bundle {
        val bus = slave(WriteOnlyBus(addressWidth = 1))

        val segments = out Bits(8 bits)
        val anode    = out Bits(4 bits)
    }

    val hexSegments = Reg(UInt(16 bits)) init(0x0000)

    when (io.bus.enable) {
        when (io.bus.address === U(1)) {
            hexSegments(15 downto 8) := io.bus.dataFromMaster.asUInt
        }.otherwise {
            hexSegments(7 downto 0) := io.bus.dataFromMaster.asUInt
        }
    }

    val kHzArea = new SlowArea(1 kHz) {
        val segmentDriver = new HexSegments()

        segmentDriver.io.dataIn := hexSegments

        io.segments := segmentDriver.io.segments
        io.anode    := segmentDriver.io.anode
    }
}
