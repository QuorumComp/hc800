package hc800

import spinal.core._
import spinal.lib._


class BoardId(board: Int) extends Component {
	import BoardId._

	val identifier =
		board match {
			case Board.zxNext => "ZX Spectrum Next"
			case Board.nexys3 => "Digilent Nexys 3"
			case Board.mist => "MiST"
			case Board.mister => "MiSTer"
			case _ => "Unknown"
		}

	val bytes = ((identifier.length | 0x80).toByte :: identifier.map((ch : Char) => ch.toByte).toList).toArray

    val io = slave(ReadOnlyBus(addressWidth = 1))

	val counter = Reg(UInt(log2Up(bytes.length) bits))
	val dataOutR = Reg(Bits(8 bits))
	io.dataToMaster := dataOutR

	when (io.enable) {
		switch (io.address) {
			is (U(0)) {
				dataOutR := board
			}
			is (U(1)) {
				switch (counter) {
					for (i <- 0 until bytes.length) {
						is (U(i)) {
							dataOutR := B(bytes(i).toInt & 0xFF)
						}
					}
				}
				counter := counter + 1
			}
		}
	} otherwise {
		dataOutR := 0
	}

    noIoPrefix()
}


object BoardId {
	object Board {
		val zxNext = 0
		val nexys3 = 1
		val mist = 2
		val mister = 3
	}
}
