package hc800.keyboard

import spinal.core._
import spinal.lib._


case class mega65kbd_to_matrix() extends BlackBox {
	val io = new Bundle {
		val ioclock_i        = in Bool()

		val flopmotor_i      = in Bool()
		val flopled_i        = in Bool()
		val powerled_i       = in Bool()

		val kio8_o           = out Bool()   // clock to keyboard
		val kio9_o           = out Bool()   // data output to keyboard
		val kio10_i          = in Bool()    // data input from keyboard

		val matrix_col_o     = out Bits(8 bits)
		val matrix_col_idx_i = in UInt(4 bits)  // 0 to 9

		val delete_out_o     = out Bool()
		val return_out_o     = out Bool()
		val fastkey_out_o    = out Bool()

		// RESTORE and capslock are active low
		val restore_o        = out Bool()
		val capslock_out_o   = out Bool()

		// LEFT and UP cursor keys are active HIGH
		val leftkey_o        = out Bool()
		val upkey_o          = out Bool()
	}

	noIoPrefix()

	mapClockDomain(clock = io.ioclock_i)
}



case class Mega65KeyboardBusIO() extends KeyboardBusIO {
	val kio8_o  = out Bool()   // clock to keyboard
	val kio9_o  = out Bool()   // data output to keyboard
	val kio10_i = in Bool()    // data input from keyboard
}

case class Mega65Keyboard() extends Keyboard(Mega65KeyboardBusIO()) {
	private val matrix = mega65kbd_to_matrix()

	io.kio8_o  <> matrix.io.kio8_o
	io.kio9_o  <> matrix.io.kio9_o
	io.kio10_i <> matrix.io.kio10_i

	matrix.io.flopmotor_i := False
	matrix.io.flopled_i   := False
	matrix.io.powerled_i  := True
	
	matrix.io.matrix_col_idx_i := 0

	fifo.io.push.valid   := False
	fifo.io.push.payload := 0
}
