package hc800

import spinal.core._
import spinal.lib._


object MMU {
	object MapSource extends SpinalEnum {
		val cpu,
			chipsetCharGen = newElement()
	}

	object Register extends SpinalEnum(defaultEncoding = binarySequential) {
		val updateIndex,
			configBits,
			codeBank0,
			codeBank1,
			codeBank2,
			codeBank3,
			dataBank0,
			dataBank1,
			dataBank2,
			dataBank3,
			systemCodeBank,
			systemDataBank,
			activeIndex,
			chipsetCharGen = newElement()
	}
}


class MMU extends Component {
	import MMU._

	val io = new Bundle {
		val regBus = slave(Bus(addressWidth = 4))

		val mapSource     = in  (MapSource())
		val mapCode       = in  Bool()
		val mapSystem     = in  Bool()
		val mapAddressIn  = in  UInt(16 bits)
		val mapAddressOut = out UInt(22 bits)
	}

	case class ConfigurationBundle() extends Bundle {
		val bank0 = Reg(Bits(8 bits)) init(0)
		val bank1 = Reg(Bits(8 bits)) init(1)
		val bank2 = Reg(Bits(8 bits)) init(2)
		val bank3 = Reg(Bits(8 bits)) init(3)
		val harvard = Reg(Bool()) init(False)
		val dataBank0 = Reg(Bits(8 bits)) init(0)
		val dataBank1 = Reg(Bits(8 bits)) init(1) 
		val dataBank2 = Reg(Bits(8 bits)) init(2)
		val dataBank3 = Reg(Bits(8 bits)) init(3)
		val systemCodeBank = Reg(Bits(8 bits)) init(0)
		val systemDataBank = Reg(Bits(8 bits)) init(0)
	}

	val configurationStack = Reg(UInt(8 bits))

	val configurationVec = Vec(ConfigurationBundle(), 4)
	val updateIndex = Reg(UInt(2 bits)) init(3)
	val activeIndex = Reg(UInt(2 bits)) init(3)

	val chipsetCharGen = Reg(Bits(8 bits)) init(0)

	val mapArea = new Area {
		val config = configurationVec(activeIndex)

		when (io.mapSource === MapSource.cpu) {
			val codeBank = (io.mapAddressIn(15 downto 14)).mux (
				default -> (io.mapSystem ? config.systemCodeBank | config.bank0),
				1 -> config.bank1,
				2 -> config.bank2,
				3 -> config.bank3
			)
			val dataBank = (io.mapAddressIn(15 downto 14)).mux (
				default -> (io.mapSystem ? config.systemDataBank | config.dataBank0),
				1 -> config.dataBank1,
				2 -> config.dataBank2,
				3 -> config.dataBank3
			)
			val bank = (config.harvard && !io.mapCode) ? dataBank | codeBank
			io.mapAddressOut := (bank ## io.mapAddressIn.resize(14 bits)).asUInt
		}.elsewhen (io.mapSource === MapSource.chipsetCharGen) {
			io.mapAddressOut := ((chipsetCharGen ## B(0, 14 bits)).asUInt + io.mapAddressIn.resize(22 bits))
		}.otherwise {
			io.mapAddressOut := 0
		}
	}

	val ioArea = new Area {
		val config = configurationVec(updateIndex)
		val reg = Register()
		reg.assignFromBits(io.regBus.address.asBits)

		when (io.regBus.enable && io.regBus.write) {
			switch (reg) {
				is (Register.updateIndex) { updateIndex := io.regBus.dataFromMaster(1 downto 0).asUInt }
				is (Register.configBits) {
					config.harvard := io.regBus.dataFromMaster(0)
				}
				is (Register.codeBank0) { config.bank0 := io.regBus.dataFromMaster }
				is (Register.codeBank1) { config.bank1 := io.regBus.dataFromMaster }
				is (Register.codeBank2) { config.bank2 := io.regBus.dataFromMaster }
				is (Register.codeBank3) { config.bank3 := io.regBus.dataFromMaster }
				is (Register.dataBank0) { config.dataBank0 := io.regBus.dataFromMaster }
				is (Register.dataBank1) { config.dataBank1 := io.regBus.dataFromMaster }
				is (Register.dataBank2) { config.dataBank2 := io.regBus.dataFromMaster }
				is (Register.dataBank3) { config.dataBank3 := io.regBus.dataFromMaster }
				is (Register.systemCodeBank) { config.systemCodeBank := io.regBus.dataFromMaster }
				is (Register.systemDataBank) { config.systemDataBank := io.regBus.dataFromMaster }
				is (Register.activeIndex) { 
					when (io.regBus.dataFromMaster(7)) {
						// push
						activeIndex := io.regBus.dataFromMaster(1 downto 0).asUInt
						configurationStack(5 downto 0) := configurationStack(7 downto 2)
						configurationStack(7 downto 6) := activeIndex
					}.elsewhen (io.regBus.dataFromMaster(6)) {
						// pop
						activeIndex := configurationStack(7 downto 6)
						configurationStack(7 downto 2) := configurationStack(5 downto 0)
					}.otherwise {
						activeIndex := io.regBus.dataFromMaster(1 downto 0).asUInt
					}
				}
				is (Register.chipsetCharGen) { chipsetCharGen := io.regBus.dataFromMaster }
			}
		}

		val regData = Reg(Bits(8 bits))
		io.regBus.dataToMaster := regData

		when (io.regBus.enable && !io.regBus.write) {
			regData := reg.mux (
				Register.updateIndex -> updateIndex.resize(8 bits).asBits,
				Register.configBits -> (config.harvard.asBits).resize(8 bits),
				Register.codeBank0 -> config.bank0,
				Register.codeBank1 -> config.bank1,
				Register.codeBank2 -> config.bank2,
				Register.codeBank3 -> config.bank3,
				Register.dataBank0 -> config.dataBank0,
				Register.dataBank1 -> config.dataBank1,
				Register.dataBank2 -> config.dataBank2,
				Register.dataBank3 -> config.dataBank3,
				Register.systemCodeBank -> config.systemCodeBank,
				Register.systemDataBank -> config.systemDataBank,
				Register.activeIndex -> activeIndex.resize(8 bits).asBits,
				Register.chipsetCharGen -> chipsetCharGen
			)
		}.otherwise {
			regData := 0
		}
	}
}
