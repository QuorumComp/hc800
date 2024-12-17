package hc800

import spinal.core._
import spinal.lib._
import spinal.core.sim._

case class Bus(addressWidth: Int, dataWidth: Int = 8) extends Bundle with IMasterSlave {
	val enable = Bool()
	val write = Bool()
	val dataFromMaster = Bits(dataWidth bits)
	val dataToMaster = Bits(dataWidth bits)
	val address = UInt(addressWidth bits)

	override def asMaster(): Unit = {
		out(enable, write, dataFromMaster, address)
		in(dataToMaster)
	}

	def wireClient(client: Bus, gate: Bool): Bits = {
		client.enable := enable && gate
		client.write := write
		client.dataFromMaster := dataFromMaster
		client.address := address.resized

		client.dataToMaster
	}

	def wireClient(client: ReadOnlyBus, gate: Bool): Bits = {
		client.enable := enable && gate
		client.address := address.resized

		client.dataToMaster
	}

	def wireClient(client: WriteOnlyBus, gate: Bool): Unit = {
		client.enable := enable && write && gate
		client.address := address.resized
		client.dataFromMaster := dataFromMaster
	}
}


case class ReadOnlyBus(addressWidth: Int, dataWidth: Int = 8) extends Bundle with IMasterSlave {
	val enable = Bool()
	val dataToMaster = Bits(dataWidth bits)
	val address = UInt(addressWidth bits)

	override def asMaster(): Unit = {
		out(enable, address)
		in(dataToMaster)
	}

	def wireClient(client: ReadOnlyBus, gate: Bool): Bits = {
		client.enable := enable && gate
		client.address := address.resized

		client.dataToMaster
	}
}


case class WriteOnlyBus(addressWidth: Int, dataWidth: Int = 8) extends Bundle with IMasterSlave {
	val enable = Bool()
	val dataFromMaster = Bits(dataWidth bits)
	val address = UInt(addressWidth bits)

	override def asMaster(): Unit = {
		out(enable, address, dataFromMaster)
	}
}
