package hc800

import rc800.Utils._

import spinal.core._
import spinal.lib._

import java.io.File
import java.io.FileInputStream

class BootROM extends Component {
	val io = slave(ReadOnlyBus(addressWidth = 11))

	private def readBootROM(): Array[Byte] = {
		val file = new File("../firmware/boot/boot.bin")
		using (new FileInputStream(file)) { fis =>
			val size = file.length()
			val content = new Array[Byte](size.asInstanceOf[Int])
			fis.read(content)
			content
		}
	}
	
	private val content = readBootROM()
	private val memory = Mem(Bits(8 bits), content.map(v => B(v.asInstanceOf[Int] & 0xFF))) 

	private val dataOut = memory.readSync(io.address, io.enable)

	when (Delay(io.enable, 1)) {
		io.dataToMaster := dataOut
	} otherwise {
		io.dataToMaster := 0
	}
}
