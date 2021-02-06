package hc800

import spinal.core._
import spinal.lib._


object MMU {
	object MapSource extends SpinalEnum {
		val cpu,
			chipsetCharGen = newElement()
	}

	object UpperSizeConfig extends SpinalEnum(defaultEncoding = binarySequential) {
		val size16,
			size32,
			size48,
			size64 = newElement()

		def isAtLeast64(config: UpperSizeConfig.C): Bool = config.asBits.andR
		def isAtLeast48(config: UpperSizeConfig.C): Bool = config.asBits(1)
		def isAtLeast32(config: UpperSizeConfig.C): Bool = config.asBits.orR
		def isAtLeast16(config: UpperSizeConfig.C): Bool = True
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
		val userCode = Vec(Reg(Bits(8 bits)) init(0), 4)
		val userData = Vec(Reg(Bits(8 bits)) init(0), 4)
		val userHarvard = Reg(Bool()) init(False)
		val userCodeUpperSize = Reg(UpperSizeConfig()) init(UpperSizeConfig.size16)
		val userDataUpperSize = Reg(UpperSizeConfig()) init(UpperSizeConfig.size16)
		val systemCode = Reg(Bits(8 bits)) init(0)
		val systemData = Reg(Bits(8 bits)) init(0)
		val systemHarvard = Reg(Bool()) init(False)
	}

	val configurationStack = Reg(UInt(8 bits))

	val configurationVec = Vec(ConfigurationBundle(), 4)
	val updateIndex = Reg(UInt(2 bits)) init(0)
	val activeIndex = Reg(UInt(2 bits)) init(0)

	val chipsetCharGen = Reg(Bits(8 bits)) init(0)

	val mapArea = new Area {
		val config = configurationVec(activeIndex)

		def mapUpperSize(segment: UInt, config: UpperSizeConfig.C): UInt =
			segment.mux(
				0 -> (UpperSizeConfig.isAtLeast64(config) ? U(3) | 0),
				1 -> (UpperSizeConfig.isAtLeast48(config) ? U(3) | 1),
				2 -> (UpperSizeConfig.isAtLeast32(config) ? U(3) | 2),
				3 -> (UpperSizeConfig.isAtLeast16(config) ? U(3) | 3),
			)

		when (io.mapSource === MapSource.cpu) {
			val segment = io.mapAddressIn(15 downto 14)
			val codeSegment = mapUpperSize(segment, config.userCodeUpperSize)
			val dataSegment = mapUpperSize(segment, config.userDataUpperSize)

			val userCode = config.userCode(codeSegment)
			val userData = config.userHarvard ? config.userData(dataSegment) | userCode
			val userBank = io.mapCode ? userCode | userData

			val systemCode = config.systemCode
			val systemData = config.systemHarvard ? config.systemData | systemCode
			val systemBank = io.mapCode ? systemCode | systemData

			val bank = Mux (io.mapSystem && segment === 0, systemBank, userBank)
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
					config.userHarvard := io.regBus.dataFromMaster(0)
					config.systemHarvard := io.regBus.dataFromMaster(1)
					config.userCodeUpperSize := io.regBus.dataFromMaster(3 downto 2) as UpperSizeConfig()
					config.userDataUpperSize := io.regBus.dataFromMaster(5 downto 4) as UpperSizeConfig()
				}
				is (Register.codeBank0) { config.userCode(0) := io.regBus.dataFromMaster }
				is (Register.codeBank1) { config.userCode(1) := io.regBus.dataFromMaster }
				is (Register.codeBank2) { config.userCode(2) := io.regBus.dataFromMaster }
				is (Register.codeBank3) { config.userCode(3) := io.regBus.dataFromMaster }
				is (Register.dataBank0) { config.userData(0) := io.regBus.dataFromMaster }
				is (Register.dataBank1) { config.userData(1) := io.regBus.dataFromMaster }
				is (Register.dataBank2) { config.userData(2) := io.regBus.dataFromMaster }
				is (Register.dataBank3) { config.userData(3) := io.regBus.dataFromMaster }
				is (Register.systemCodeBank) { config.systemCode := io.regBus.dataFromMaster }
				is (Register.systemDataBank) { config.systemData := io.regBus.dataFromMaster }
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
				Register.configBits -> (config.userDataUpperSize ## config.userCodeUpperSize ## config.systemHarvard ## config.userHarvard).resize(8 bits),
				Register.codeBank0 -> config.userCode(0),
				Register.codeBank1 -> config.userCode(1),
				Register.codeBank2 -> config.userCode(2),
				Register.codeBank3 -> config.userCode(3),
				Register.dataBank0 -> config.userData(0),
				Register.dataBank1 -> config.userData(1),
				Register.dataBank2 -> config.userData(2),
				Register.dataBank3 -> config.userData(3),
				Register.systemCodeBank -> config.systemCode,
				Register.systemDataBank -> config.systemData,
				Register.activeIndex -> activeIndex.resize(8 bits).asBits,
				Register.chipsetCharGen -> chipsetCharGen
			)
		}.otherwise {
			regData := 0
		}
	}
}
