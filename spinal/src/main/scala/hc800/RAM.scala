package hc800

import rc800.utils._

import spinal.core._
import spinal.lib._

import java.io.File
import java.io.FileInputStream


class RAM(size: Int) extends Component {
	val io = slave(Bus(addressWidth = log2Up(size)))

	private val memory = Mem(Bits(8 bits), size)
	private val dataOut = memory.readWriteSync(io.address, io.dataFromMaster, io.enable, io.write)

	when (Delay(io.enable, 1)) {
		io.dataToMaster := dataOut
	} otherwise {
		io.dataToMaster := 0
	}

	private def readFile(filename: String): Array[Byte] = {
		val file = new File(filename)
		using (new FileInputStream(file)) { fis =>
			val size = file.length()
			val content = new Array[Byte](size.asInstanceOf[Int])
			fis.read(content)
			content
		}
	}
	
	def initWith(filename: String): RAM = {
		val content = readFile(filename)
		memory.init(content.map(v => B(v.asInstanceOf[Int] & 0xFF)))
		this
	}
}

