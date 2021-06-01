package hc800

import spinal.core._
import spinal.lib._
import spinal.lib.com.uart._

class UART extends Component {
	import UART._

    val io = new Bundle {
		val bus = slave(Bus(addressWidth = 1))
		val uart = master(Uart())
    }

	val busRegister = io.bus.address.as(Register())

	val uartCtrl = new UartCtrl()
	uartCtrl.io.config.setClockDivider(baudrate = 57.6 kHz)
	uartCtrl.io.config.frame.dataLength := 7  //8 bits
	uartCtrl.io.config.frame.parity := UartParityType.NONE
	uartCtrl.io.config.frame.stop := UartStopType.ONE
	uartCtrl.io.uart <> io.uart
	uartCtrl.io.writeBreak := False

	val inFifo = new StreamFifo(dataType = Bits(8 bits), depth = 16)
	val outFifo = new StreamFifo(dataType = Bits(8 bits), depth = 16)

	val readingData = io.bus.enable && (!io.bus.write) && (busRegister === Register.data);

	inFifo.io.push <-< uartCtrl.io.read

	outFifo.io.push.valid := io.bus.enable.rise && io.bus.write && (busRegister === Register.data)
	outFifo.io.push.payload := io.bus.dataFromMaster

	uartCtrl.io.write <-< outFifo.io.pop

	val uartDataIn = Reg(Bits(8 bits))
	val uartDataInConsumed = RegInit(True)

	when (readingData.rise) {
		uartDataInConsumed := True
	}

	val getNextValue = (inFifo.io.pop.valid && uartDataInConsumed).rise
	inFifo.io.pop.ready := getNextValue
	when (getNextValue) {
		uartDataIn := inFifo.io.pop.payload
		uartDataInConsumed := False
	}

	val ioDataOut = Reg(Bits(8 bits))
	io.bus.dataToMaster := ioDataOut

	when (io.bus.enable) {
		ioDataOut := busRegister.mux (
			Register.data -> uartDataIn,
			Register.status -> B(outFifo.io.push.ready ## !uartDataInConsumed).resize(8 bits)
		)
	} otherwise {
		ioDataOut := 0
	}
}


object UART {
	object Register extends SpinalEnum(defaultEncoding = binarySequential) {
		val data, status = newElement()
	}
}
