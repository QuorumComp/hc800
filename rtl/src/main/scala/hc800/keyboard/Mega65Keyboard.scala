package hc800.keyboard

import spinal.core._
import spinal.lib._


case class mega65kbd_to_matrix() extends BlackBox {
	val io = new Bundle {
		val cpuclock         = in Bool()

		val flopmotor        = in Bool()
		val flopled0         = in Bool()
		val flopled2         = in Bool()
		val flopledsd        = in Bool()
		val powerled         = in Bool()

		val eth_load_enable  = in Bool()

 		val kio8             = out Bool()   // clock to keyboard
		val kio9             = out Bool()   // data output to keyboard
		val kio10            = in  Bool()    // data input from keyboard

		val matrix_col       = out Bits(8 bits)
		val matrix_col_idx   = in  UInt(4 bits)  // 0 to 9

		val delete_out       = out Bool()
		val return_out       = out Bool()
		val fastkey_out      = out Bool()

		// RESTORE and capslock are active low
		val restore          = out Bool()
		val capslock_out     = out Bool()

		// LEFT and UP cursor keys are active HIGH
		val leftkey          = out Bool()
		val upkey            = out Bool()
	}

	noIoPrefix()

	mapClockDomain(clock = io.cpuclock)
}


case class Mega65MatrixToScanCode() extends Component {
	val io = new Bundle {
		val row     = in Bits(3 bits)
		val column  = in Bits(4 bits)

		val scanCode = out Bits(7 bits)
	}

	private val codes = io.column.mux (
		0 -> Vec(U"x7F", U"x10", U"x02", U"x7F", U"x08", U"x0A", U"x61", U"x7F" ),		// ?, UP, LEFT, RESTORE, INST_DEL_1, RETURN_1, CAPS_LOCK, ?
		1 -> Vec(U"x7F", U"x7F", U"x06", U"x18", U"x12", U"x14", U"x16", U"x0E" ),		// INST_DEL_2, RETURN_2, RIGHT, F7, F1, F3, F5, DOWN
		2 -> Vec(U"x33", U"x57", U"x41", U"x34", U"x5A", U"x53", U"x45", U"x62" ),		// 3, W, A, 4, Z, S, E, LEFT_SHIFT
		3 -> Vec(U"x35", U"x52", U"x44", U"x36", U"x43", U"x46", U"x54", U"x58" ),		// 5, R, D, 6, C, F, T, X
		4 -> Vec(U"x37", U"x59", U"x47", U"x38", U"x42", U"x48", U"x55", U"x56" ),		// 7, Y, G, 8, B, H, U, V
		5 -> Vec(U"x39", U"x49", U"x4A", U"x30", U"x4D", U"x4B", U"x4F", U"x4E" ),		// 9, I, J, 0, M, K, O, N
		6 -> Vec(U"x7F", U"x50", U"x4C", U"x2D", U"x2E", U"x3A", U"x40", U"x2C" ),		// + P L - . : @ ,
		7 -> Vec(U"x6E", U"x2A", U"x3B", U"x01", U"x63", U"x3D", U"x0D", U"x2F" ),		// £, *, ;, CLR_HOME, RIGHT_SHIFT, =, ARROW_UP, /
		8 -> Vec(U"x31", U"x0C", U"x65", U"x32", U"x20", U"x70", U"x51", U"x73" ),		// 1, ARROW_LEFT, CTRL, 2, SPACE, MEGA65, Q, RUN_STOP
		9 -> Vec(U"x74", U"x09", U"x66", U"x75", U"x1A", U"x1D", U"x1F", U"x1B" ),		// NO_SCROLL, TAB, ALT, HELP, F9, F11, F13, ESC
		default -> Vec(U"x7F", U"x7F", U"x7F", U"x7F", U"x7F", U"x7F", U"x7F", U"x7F")
	)

	io.scanCode := codes(io.row.asUInt).asBits.resize(7)
	//io.scanCode := io.column ## io.row
}


case class Mega65KeyboardBusIO() extends KeyboardBusIO {
	val kio8_o  = out Bool()   // clock to keyboard
	val kio9_o  = out Bool()   // data output to keyboard
	val kio10_i = in Bool()    // data input from keyboard
}


case class Mega65Keyboard() extends Keyboard(Mega65KeyboardBusIO()) {
	// MEGA65 keyboard matrix
	private val decoder = mega65kbd_to_matrix()

	io.kio8_o  <> decoder.io.kio8
	io.kio9_o  <> decoder.io.kio9
	io.kio10_i <> decoder.io.kio10

	decoder.io.flopmotor := False
	decoder.io.flopled0  := False
	decoder.io.flopled2  := False
	decoder.io.flopledsd := False
	decoder.io.powerled  := True

	decoder.io.eth_load_enable := False


	private val slowArea = new SlowArea(64) {
		val column_index = Reg(UInt(4 bits)) init(0)
		column_index := column_index.mux(
			U(9)    -> U(0),
			default -> (column_index + 1)
		)

		decoder.io.matrix_col_idx <> column_index

		private val rowsIn = RegNext(~decoder.io.matrix_col)
		private val matrix = Vec(Reg(Bits(8 bits)) init(0), 10)
		private val debouncedRows = matrix(column_index) & rowsIn
		matrix(column_index) := rowsIn

		private val debouncedMatrix = Vec(Reg(Bits(8 bits)) init(0), 10)
		private val rowsChanged = debouncedRows ^ debouncedMatrix(column_index)
		private val rowsPressed = debouncedRows & rowsChanged
		debouncedMatrix(column_index) := debouncedRows

		private val scanCode = Mega65MatrixToScanCode()
		scanCode.io.row    := 0
		scanCode.io.column := column_index.asBits

		private val keycode       = Bits(8 bits)
		private val keycode_valid = Bool
		
		keycode       := 0
		keycode_valid := False

		private def keyStateChanged(row: Int): Unit = {
			scanCode.io.row := row
			keycode_valid   := True
			keycode         := rowsPressed(row) ## scanCode.io.scanCode
		}

		switch (rowsChanged) {
			is(M"-------1") { keyStateChanged(0) }
			is(M"------1-") { keyStateChanged(1) }
			is(M"-----1--") { keyStateChanged(2) }
			is(M"----1---") { keyStateChanged(3) }
			is(M"---1----") { keyStateChanged(4) }
			is(M"--1-----") { keyStateChanged(5) }
			is(M"-1------") { keyStateChanged(6) }
			is(M"1-------") { keyStateChanged(7) }
		}

		val fifoPayload = Bits(8 bits)
		val fifoPush    = Bool()

		fifoPayload := keycode
		fifoPush    := keycode_valid

		when (keycode_valid && keycode(6 downto 0) === B(0x7F, 7 bits)) {
			fifoPush := False
		} 

		private val capslock_edges = decoder.io.capslock_out.edges()

		when (capslock_edges.rise) {
			fifoPayload := B(0x61, 8 bits)
			fifoPush    := True
		} elsewhen (capslock_edges.fall) {
			fifoPayload := B(0x61 | 0x80, 8 bits)
			fifoPush    := True
		}
	}

	fifo.io.push.valid := slowArea.fifoPush.rise
	fifo.io.push.payload := slowArea.fifoPayload
}
