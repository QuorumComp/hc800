package hc800

import rc800.Utils._

import spinal.core._
import spinal.lib._

import java.io.File
import java.io.FileInputStream

class BootROM extends Component {
    val io = new Bundle {
        val bus = slave(ReadOnlyBus(addressWidth = 11))
    }

    def readBootROM(): Array[Byte] = {
        val file = new File("../firmware/boot/boot.bin")
        using (new FileInputStream(file)) { fis =>
            val size = file.length()
            val content = new Array[Byte](size.asInstanceOf[Int])
            fis.read(content)
            content
        }
    }
    
    val data = Reg(Bits(8 bits))
    io.bus.dataToMaster := data

    val content = readBootROM()
    val memory = Mem(Bits(8 bits), content.map(v => B(v.asInstanceOf[Int] & 0xFF))) 

    when (io.bus.enable) {
        data := memory.readAsync(io.bus.address)
    } otherwise {
        data := 0
    }
}
