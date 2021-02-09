package hc800

import spinal.core._
import spinal.lib._

class SD extends Component {
	import SD._

    val io = new Bundle {
		val bus = slave(Bus(addressWidth = 1))

		val sd_cs = out Bool
		val sd_clock = out Bool
		val sd_di = in Bool
		val sd_do = out Bool
    }

	// State

	val cardSelect = RegInit(False)
	val inDataProcess = RegInit(False)
	val outDataProcess = RegInit(False)
	val spiDataIn = RegInit(B(0, 8 bits))
	val spiDataOut = RegInit(B(0, 8 bits))
	val count = Reg(U(0, 3 bits))

	// External interface

	io.sd_cs := cardSelect
	io.sd_clock := (inDataProcess || outDataProcess) && ClockDomain.current.readClockWire

	when (io.sd_clock) {
		when (count === 7) {
			count := 0
			inDataProcess := False
			outDataProcess := False
		} otherwise {
			count := count + 1
		}
	}

	when (inDataProcess) {
		spiDataIn := spiDataIn(6 downto 0) ## io.sd_di;
	}

	when (outDataProcess) {
		io.sd_do := spiDataOut(7)
		spiDataOut := spiDataOut(6 downto 0) ## False;
	} otherwise {
		io.sd_do := False
	}

	// Register interface

	val ioDataOut = Reg(Bits(8 bits))
	io.bus.dataToMaster := ioDataOut

	val busRegister = io.bus.address.as(Register())

	when (io.bus.enable && !io.bus.write) {
		ioDataOut := busRegister.mux (
			Register.data -> spiDataIn,
			Register.status -> B(cardSelect ## outDataProcess ## inDataProcess).resize(8 bits)
		)
	} otherwise {
		ioDataOut := 0
	}

	when (io.bus.enable && io.bus.write) {
		switch (busRegister) {
			is (Register.data) {
				spiDataOut := io.bus.dataFromMaster
				outDataProcess := True
			}
			is (Register.status) {
				cardSelect := io.bus.dataFromMaster(2)
				inDataProcess := io.bus.dataFromMaster(0)
			}
		}
		busRegister.mux (
			Register.data -> spiDataIn,
			Register.status -> B(cardSelect ## outDataProcess ## inDataProcess).resize(8 bits)
		)
	} otherwise {
		ioDataOut := 0
	}
}


object SD {
	object Register extends SpinalEnum {
		val data, status = newElement()
	}
}
