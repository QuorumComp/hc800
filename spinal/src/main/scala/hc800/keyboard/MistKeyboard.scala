package hc800.keyboard

import spinal.core._
import spinal.lib._


case class Ps2ToScanCode() extends Component {
	val io = new Bundle {
		val ps2Code = in Bits(8 bits)
		val scanCode = out Bits(7 bits)
	}

	private val codes = Mem(UInt(7 bits), Array(
		U"x00", U"x1C", U"x00", U"x16", U"x13", U"x12", U"x13", U"x00",	// 00-07
		U"x00", U"x1D", U"x19", U"x00", U"x15", U"x09", U"x60", U"x00",	// 08-0F
		U"x00", U"x64", U"x62", U"x00", U"x65", U"x51", U"x31", U"x00",	// 10-17
		U"x00", U"x00", U"x5A", U"x53", U"x41", U"x57", U"x32", U"x00",	// 18-1F
		U"x00", U"x43", U"x58", U"x44", U"x45", U"x34", U"x33", U"x00",	// 20-27
		U"x00", U"x20", U"x56", U"x46", U"x54", U"x52", U"x35", U"x00",	// 28-2F
		U"x00", U"x4E", U"x42", U"x48", U"x47", U"x59", U"x36", U"x00",	// 30-37
		U"x00", U"x00", U"x4D", U"x4A", U"x55", U"x37", U"x38", U"x00", // 38-3F
		U"x00", U"x2C", U"x4B", U"x49", U"x4F", U"x30", U"x39", U"x00", // 40-47
		U"x00", U"x2E", U"x2F", U"x4C", U"x3B", U"x50", U"x2D", U"x00", // 48-4F
		U"x00", U"x00", U"x27", U"x00", U"x5B", U"x3D", U"x00", U"x00", // 50-57
		U"x61", U"x63", U"x0A", U"x5D", U"x00", U"x5C", U"x00", U"x00", // 58-5F
		U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", U"x08", U"x00", // 60-67
		U"x00", U"x31", U"x00", U"x34", U"x37", U"x00", U"x00", U"x00", // 68-6F
		U"x30", U"x2E", U"x32", U"x35", U"x36", U"x38", U"x1B", U"x00", // 70-77
		U"x00", U"x2B", U"x33", U"x2D", U"x2A", U"x39", U"x00", U"x00", // 78-7F

		// Extended codes
		U"x00", U"x00", U"x00", U"x18", U"x00", U"x00", U"x00", U"x00", // 00-07
		U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", // 08-0F
		U"x00", U"x66", U"x00", U"x00", U"x67", U"x00", U"x00", U"x00", // 10-17
		U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", U"x68",	// 18-1F
		U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", U"x69",	// 20-27
		U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", // 28-2F
		U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", U"x00",	// 30-37
		U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", // 38-3F
		U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", U"x00",	// 40-47
		U"x00", U"x00", U"x2F", U"x00", U"x00", U"x00", U"x00", U"x00", // 48-4F
		U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", U"x00",	// 50-57
		U"x00", U"x00", U"x0A", U"x00", U"x00", U"x00", U"x00", U"x00", // 58-5F
		U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", U"x00", U"x00",	// 60-67
		U"x00", U"x05", U"x00", U"x02", U"x01", U"x00", U"x00", U"x00", // 68-6F
		U"x03", U"x04", U"x0E", U"x00", U"x06", U"x10", U"x00", U"x00", // 70-78
		U"x00", U"x00", U"x0B", U"x00", U"x00", U"x0F", U"x00", U"x00", // 79-7F
	))

	io.scanCode := codes.readSync(io.ps2Code.asUInt.resized).asBits
}


case class MistKeyboardBusIO() extends KeyboardBusIO {
	val keyCode   = in Bits(8 bits)
	val keyMake   = in Bool()
	val keyExtend = in Bool()
	val keyStrobe = in Bool()
}

case class MistKeyboard() extends Keyboard(MistKeyboardBusIO()) {
	private val scanCodeConverter = new Ps2ToScanCode()
	scanCodeConverter.io.ps2Code := ((io.keyExtend | io.keyCode(7)) ## io.keyCode.resize(7))

	val capsLockState = Reg(Bool) init(False)
	val fifoPush = Bool
	val fifoPayload = Bits(8 bits)

	fifoPush := False
	fifoPayload := 0

	when (scanCodeConverter.io.scanCode === B(0x61, 7 bits)) {
		// Handle caps lock case
		when (io.keyStrobe && io.keyMake) {
			fifoPush := True
			fifoPayload := (!capsLockState) ## scanCodeConverter.io.scanCode
			capsLockState := !capsLockState
		}
	}.otherwise {
		fifoPush := Delay(io.keyStrobe,1) && (scanCodeConverter.io.scanCode =/= 0)
		fifoPayload := io.keyMake ## scanCodeConverter.io.scanCode
	}

	fifo.io.push.valid := fifoPush.rise
	fifo.io.push.payload := fifoPayload

}
