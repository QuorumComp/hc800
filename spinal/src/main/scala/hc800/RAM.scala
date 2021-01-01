package hc800

import spinal.core._
import spinal.lib._


class RAM(size: Int) extends Component {
	val io = slave(Bus(addressWidth = log2Up(size)))

	private val memory = Mem(Bits(8 bits), size)
	private val dataOut = memory.readWriteSync(io.address, io.dataFromMaster, io.enable, io.write)

	when (Delay(io.enable, 1)) {
		io.dataToMaster := dataOut
	} otherwise {
		io.dataToMaster := 0
	}
}

