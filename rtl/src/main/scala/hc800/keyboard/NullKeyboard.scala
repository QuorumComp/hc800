package hc800.keyboard

import spinal.core._
import spinal.lib._


class NullKeyboard extends Keyboard(new KeyboardBusIO()) {
	fifo.io.push.valid := False
	fifo.io.push.payload := 0
}
