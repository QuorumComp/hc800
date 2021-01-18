package hc800

import rc800.Utils._

import spinal.core._
import spinal.lib._

import java.io.File
import java.io.FileInputStream

import play.api.libs.json.Json
import play.api.libs.json.JsValue

class Font extends Component {
	val io = slave(ReadOnlyBus(addressWidth = 14))

	def readFont(): Array[Byte] =
		List("font", "box")
			.map(v => java.nio.file.Paths.get(s"../data/$v.bin"))
			.map(java.nio.file.Files.readAllBytes)
			.flatten
			.toArray

	val data = Reg(Bits(8 bits))
	io.dataToMaster := data

	val content = readFont()
	val memory = Mem(Bits(8 bits), content.map(v => B(v.asInstanceOf[Int] & 0xFF)))
	
	when (io.enable) {
		data := memory.readAsync(io.address.resized)
	} otherwise {
		data := 0
	}
}
