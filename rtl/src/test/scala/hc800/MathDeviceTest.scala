package hc800

import spinal.core._
import spinal.core.sim._

/*
 * Drives the MATH coprocessor the way software does - one byte at a time through its bus - and
 * checks the whole contract of the lane map:
 *
 *   * any write to an input lane starts a run, and the results correspond to the lanes as of that
 *     write, whichever lane it was and in whatever order the bytes were written;
 *   * reads never destroy anything and never start anything, so a result can be read twice, or
 *     read out of order;
 *   * every strobe runs the multiply and both readings of the divide at once, so all five result
 *     ports and both status bytes are valid on the same cycle - signedness is which port a program
 *     reads, not something it declares;
 *   * the multiply has one product port because the low half of a product does not depend on the
 *     reading, and the divide has two pairs because the quotient and remainder do;
 *   * the two status bytes describe their own family, because `INT32_MIN / -1` is undefined read
 *     as signed and perfectly ordinary read as unsigned;
 *   * the status bits sit on the condition lanes: bit 0 readiness, bit 1 divide-by-zero, bit 3
 *     signed quotient overflow, bit 2 hardwired 0 so that "neither error flag" is one branch.
 *
 * The arithmetic is checked against a model of the contract written here, on directed vectors and
 * on a sweep biased into the top half of the range - the region where the divider used to lose a
 * bit and where the two readings of the same operands part company.
 */
class MathDeviceTest extends munit.FunSuite {

	private val compiled = SimConfig.compile(new Math())

	private val Mask32 = (BigInt(1) << 32) - 1

	private val Ready      = Math.Ready
	private val DivideZero = Math.DivideZero
	private val Overflow   = Math.Overflow

	// ---------------------------------------------------------------- the contract, in Scala
	//
	// Deliberately written the way the datasheet describes the device rather than the way the
	// hardware does it, so that the two agreeing means something.
	private class Contract(val x: BigInt, val y: BigInt) {
		private def signed32(v: BigInt) = if (v > Mask32 / 2) v - (BigInt(1) << 32) else v
		private def magnitude32(v: BigInt) = signed32(v).abs

		val dividend = y & Mask32
		val divisor  = x & Mask32

		val divideZero = divisor == 0

		// The raw reading: the bit patterns, which always fit since the dividend is 32 bits.
		private def divide(dividend: BigInt, divisor: BigInt) =
			if (divideZero) (BigInt(0), BigInt(0)) else (dividend / divisor, dividend % divisor)
		val (qRaw, rRaw) = divide(dividend, divisor)

		/*
		 * The signed reading: magnitudes, then the truncating convention - quotient negative when
		 * the signs differ, remainder following the dividend.  Exactly one case has no answer, and
		 * it is the one whose magnitude quotient is 2^31: fine as `-2^31`, and not representable as
		 * `+2^31`.  It is flagged rather than zeroed, and negating 2^31 gives 2^31 back, so the
		 * published value is the two's-complement wrap the hardware produces by doing nothing
		 * special.
		 */
		val signedOverflow = !divideZero && dividend == BigInt("80000000", 16) && divisor == Mask32
		private val (quotientMagnitude, remainderMagnitude) =
			divide(magnitude32(dividend), magnitude32(divisor))
		private val signsDiffer = (dividend > Mask32 / 2) != (divisor > Mask32 / 2)

		private val qSigned = if (signsDiffer) -quotientMagnitude else quotientMagnitude
		private val rSigned =
			if (dividend > Mask32 / 2) -remainderMagnitude else remainderMagnitude

		/** One number for both readings: the low half is the same either way. */
		val product = (x * y) & Mask32
		val productSignedReference = (signed32(x) * signed32(y)) & Mask32

		def quotient(family: Int)  = if (family == Raw) qRaw else qSigned & Mask32
		def remainder(family: Int) = if (family == Raw) rRaw else rSigned & Mask32

		/** The raw family has no overflow to report, and that is a property, not a shortcut. */
		def status(family: Int) = Ready |
			(if (divideZero) DivideZero else 0) |
			(if (family == Signed && signedOverflow) Overflow else 0)

		override def toString = s"x=0x${x.toString(16)} y=0x${y.toString(16)}"
	}

	private val Raw    = 0
	private val Signed = 1

	// ---------------------------------------------------------------------- the bus, in bytes
	//
	// Lane 0 of a value is its least significant byte, so `writeValue` walks up from the base and
	// `readValue` walks up from the base; neither has to care what order the other used.

	private def write(math: Math, lane: Int, value: Int): Unit = {
		math.clockDomain.waitRisingEdge()
		math.io.address        #= lane
		math.io.dataFromMaster #= value & 0xFF
		math.io.write          #= true
		math.io.enable         #= true
		math.clockDomain.waitRisingEdge()
		math.io.enable #= false
		math.io.write  #= false
		math.clockDomain.waitRisingEdge()
	}

	/** Reads a byte; the device answers one cycle after the access is sampled. */
	private def read(math: Math, lane: Int): Int = {
		math.clockDomain.waitRisingEdge()
		math.io.address #= lane
		math.io.write   #= false
		math.io.enable  #= true
		math.clockDomain.waitRisingEdge()
		math.io.enable #= false
		math.clockDomain.waitRisingEdge()
		val value = math.io.dataToMaster.toInt & 0xFF
		math.clockDomain.waitRisingEdge()
		value
	}

	private def writeValue(math: Math, base: Int, value: BigInt, bytes: Int): Unit =
		for (i <- 0 until bytes) write(math, base + i, ((value >> (8 * i)) & 0xFF).toInt)

	private def readValue(math: Math, base: Int, bytes: Int): BigInt = {
		var value = BigInt(0)
		for (i <- 0 until bytes) value = value | (BigInt(read(math, base + i)) << (8 * i))
		value
	}

	/** The canonical poll: three instructions, of which the bus sees the first and the last. */
	private def poll(math: Math, status: Int, what: String): Int = {
		for (tries <- 0 until 200) {
			val byte = read(math, status)
			if ((byte & Ready) != 0) return byte
		}
		fail(s"the device never became ready: $what")
	}

	/**
	 * One full operation: the operands as the emitter hands them over (Y first, so the divide
	 * handover stays one contiguous walk up to the strobing write), then both families polled and
	 * every result port read.
	 */
	private class Operation(operandX: BigInt, operandY: BigInt)
		extends Contract(operandX, operandY) {
		var statusRaw      = -1
		var statusSigned   = -1
		var quotientRaw, quotientSigned, remainderRaw, remainderSigned = BigInt(-1)
		var productSeen    = BigInt(-1)

		def run(): this.type = {
			compiled.doSim { (dut: hc800.Math) =>
				dut.clockDomain.forkStimulus(period = 10)
				dut.io.enable #= false
				dut.io.write  #= false

				writeValue(dut, Math.Y, y, 4)
				writeValue(dut, Math.X, x, 4)

				statusRaw    = poll(dut, Math.StatusRaw, s"$this raw")
				statusSigned = poll(dut, Math.StatusSigned, s"$this signed")

				quotientRaw     = readValue(dut, Math.QuotientRaw, 4)
				remainderRaw    = readValue(dut, Math.RemainderRaw, 4)
				quotientSigned  = readValue(dut, Math.QuotientSigned, 4)
				remainderSigned = readValue(dut, Math.RemainderSigned, 4)
				productSeen     = readValue(dut, Math.Product, 4)
			}
			this
		}

		/** Everything the contract says, in one assertion. */
		def check(): Unit = {
			checkStatusBits(statusRaw, s"$this raw")
			checkStatusBits(statusSigned, s"$this signed")
			assert(statusRaw == status(Raw), s"$this raw status -> $statusRaw, want ${status(Raw)}")
			assert(statusSigned == status(Signed),
				s"$this signed status -> $statusSigned, want ${status(Signed)}")
			assert(quotientRaw == quotient(Raw),
				s"$this raw quotient -> $quotientRaw, want ${quotient(Raw)}")
			assert(remainderRaw == remainder(Raw),
				s"$this raw remainder -> $remainderRaw, want ${remainder(Raw)}")
			assert(quotientSigned == quotient(Signed),
				s"$this signed quotient -> $quotientSigned, want ${quotient(Signed)}")
			assert(remainderSigned == remainder(Signed),
				s"$this signed remainder -> $remainderSigned, want ${remainder(Signed)}")
			assert(productSeen == product, s"$this product -> $productSeen, want $product")
			// The claim the single product port rests on, checked against signed arithmetic rather
			// than against the device's own operands.
			assert(productSeen == productSignedReference,
				s"$this product is not the low half of the signed product: $productSeen")
		}
	}

	private def operate(x: BigInt, y: BigInt): Operation = new Operation(x, y).run()

	private def checkStatusBits(status: Int, what: String): Unit = {
		assert((status & 0x04) == 0, s"status bit 2 is set ($what); it must read 0 forever: 0x${status.toHexString}")
		assert((status & 0xF0) == 0, s"the reserved status bits are set ($what): 0x${status.toHexString}")
	}

	// ------------------------------------------------------------------------------ results
	test("one operation feeds every result port") {
		val vectors = Seq(
			BigInt(2)              -> BigInt(3),
			BigInt("FFFFFFFF", 16) -> BigInt("FFFFFFFF", 16),
			BigInt("80000000", 16) -> BigInt("80000000", 16),
			BigInt("7FFFFFFF", 16) -> BigInt("80000001", 16),
			BigInt("DEADBEEF", 16) -> BigInt("F0000000", 16)
		)
		vectors.foreach { case (x, y) => operate(x, y).check() }
	}

	/**
	 * The cases a driver has to get right, held here as the hardware contract rather than as
	 * whatever the firmware self-test happens to poke.  The last one is the only division in the
	 * machine with no signed answer, and it is defined when read unsigned: `0 r 0x80000000`.
	 */
	test("the directed divide cases") {
		val cases = Seq(
			// dividend, divisor, expected raw status, quotient, remainder
			(BigInt("DEADBEEF", 16), BigInt("F0000000", 16), Ready, BigInt(0), BigInt("DEADBEEF", 16)),
			(BigInt("FFFFFFFF", 16), BigInt("FFFFFFFF", 16), Ready, BigInt(1), BigInt(0)),
			(BigInt("DEADBEEF", 16), BigInt(0), Ready | DivideZero, BigInt(0), BigInt(0)),
			(BigInt("80000000", 16), BigInt("FFFFFFFF", 16), Ready, BigInt(0), BigInt("80000000", 16))
		)
		cases.foreach { case (dividend, divisor, wantStatus, wantQ, wantR) =>
			val op = operate(divisor, dividend)
			assert(op.statusRaw == wantStatus,
				s"$dividend / $divisor -> raw status ${op.statusRaw}, want $wantStatus")
			assert(op.quotientRaw == wantQ && op.remainderRaw == wantR,
				s"$dividend / $divisor -> q=${op.quotientRaw} r=${op.remainderRaw}, want q=$wantQ r=$wantR")
		}

		// -1 / INT32_MIN: no quotient, and the remainder follows the dividend.
		val signedCase = operate(BigInt("80000000", 16), Mask32)
		assert(signedCase.statusSigned == Ready,
			s"-1 / INT32_MIN -> signed status ${signedCase.statusSigned}, want $Ready")
		assert(signedCase.quotientSigned == BigInt(0) && signedCase.remainderSigned == Mask32,
			s"-1 / INT32_MIN -> q=${signedCase.quotientSigned} r=${signedCase.remainderSigned}, want q=0 r=$Mask32")
	}

	test("a zero divisor reports itself and clears both results") {
		Seq(BigInt(0), BigInt("1234", 16), Mask32, BigInt("80000000", 16)).foreach { dividend =>
			val op = operate(BigInt(0), dividend)
			assert(op.statusRaw == (Ready | DivideZero), s"zero divisor raw status -> ${op.statusRaw}")
			assert(op.statusSigned == (Ready | DivideZero),
				s"zero divisor signed status -> ${op.statusSigned}")
			assert(op.quotientRaw == 0 && op.remainderRaw == 0 &&
				op.quotientSigned == 0 && op.remainderSigned == 0, s"zero divisor left results: $op")
		}
	}

	/**
	 * The one division with no signed answer, and what the machine does about it: it says so in the
	 * signed status byte and publishes the two's-complement wrap, because that is what the divider's
	 * own magnitude and sign rule give, and it is what every software divider - this project's
	 * fallback included - lands on.  C leaves the value undefined, so the flag is the whole story
	 * and the wrap costs no hardware.  The unsigned pair is a different question and stays defined:
	 * `0 r 0x80000000`.
	 */
	test("the signed overflow reports itself and publishes the wrap") {
		val overflow = operate(Mask32, BigInt("80000000", 16))
		assert((overflow.statusSigned & Overflow) != 0,
			s"INT32_MIN / -1 did not overflow signed: ${overflow.statusSigned}")
		assert(overflow.quotientSigned == BigInt("80000000", 16) && overflow.remainderSigned == 0,
			s"INT32_MIN / -1 -> q=${overflow.quotientSigned} r=${overflow.remainderSigned}, " +
				"want q=0x80000000 r=0")
		assert((overflow.statusRaw & Overflow) == 0,
			s"the raw family reported an overflow it cannot have: ${overflow.statusRaw}")
		assert(overflow.quotientRaw == BigInt(0) && overflow.remainderRaw == BigInt("80000000", 16),
			s"the unsigned answer to INT32_MIN / -1 is not what it should be: q=${overflow.quotientRaw} r=${overflow.remainderRaw}")
	}

	/**
	 * The reason there are two status bytes even though only one case can ever differ: a driver
	 * must not be told its defined answer is undefined.  The converse case no longer exists - with
	 * a 32-bit dividend the unsigned quotient always fits - which is what the raw byte's wired-zero
	 * overflow bit is saying.
	 */
	test("only the signed family can call an answer undefined") {
		val signedOnly = operate(Mask32, BigInt("80000000", 16))
		assert((signedOnly.statusSigned & Overflow) != 0, s"magnitudes do not overflow: ${signedOnly.statusSigned}")
		assert((signedOnly.statusRaw & Overflow) == 0, s"bit patterns overflow: ${signedOnly.statusRaw}")
		signedOnly.check()
	}

	// ------------------------------------------------------------------------ the lane map
	test("reads are non-destructive and never start a run") {
		compiled.doSim { (dut: hc800.Math) =>
			dut.clockDomain.forkStimulus(period = 10)
			dut.io.enable #= false
			dut.io.write  #= false

			// A value with both ends set, so a lane that landed in the wrong place shows up.
			val operandX = BigInt("F00000FF", 16)
			val operandY = BigInt("DEADBEEF", 16)
			writeValue(dut, Math.X, operandX, 4)
			writeValue(dut, Math.Y, operandY, 4)

			poll(dut, Math.StatusRaw, "before reading")

			val first = readValue(dut, Math.Product, 4)
			val again = readValue(dut, Math.Product, 4)
			assert(first == again, s"a result changed between two reads: $first then $again")
			assert(first == ((operandX * operandY) & Mask32), s"unexpected product $first")

			// Reading is not a strobe: the status byte still says ready, and the lanes are still
			// what they were.
			assert((read(dut, Math.StatusRaw) & Ready) != 0, "reading the result cleared ready")
			assert(readValue(dut, Math.X, 4) == operandX, "reading a lane destroyed it")
		}
	}

	test("lanes are addressed, so bytes may be written and read in any order") {
		compiled.doSim { (dut: hc800.Math) =>
			dut.clockDomain.forkStimulus(period = 10)
			dut.io.enable #= false
			dut.io.write  #= false

			val value = BigInt("DEADBEEF", 16)
			// Scrambled on the way in, and read back from the top down.
			write(dut, Math.X + 2, ((value >> 16) & 0xFF).toInt)
			write(dut, Math.X + 0, (value & 0xFF).toInt)
			write(dut, Math.X + 3, ((value >> 24) & 0xFF).toInt)
			write(dut, Math.X + 1, ((value >> 8) & 0xFF).toInt)

			assert(readValue(dut, Math.X, 4) == value, "lane bytes landed in the wrong places")
			assert(read(dut, Math.X + 3) == ((value >> 24) & 0xFF).toInt,
				"the most significant lane is not the most significant byte")

			// The lanes feed the computation the same way however they were filled.
			writeValue(dut, Math.Y, BigInt(3), 4)
			poll(dut, Math.StatusRaw, "scrambled operands")
			assert(readValue(dut, Math.Product, 4) == ((value * 3) & Mask32),
				"scrambled writes reached the multiplier wrongly")
		}
	}

	test("every lane the map does not use reads zero, and only those") {
		/*
		 * Swept over the whole window rather than down a list of lanes someone typed, and with
		 * operands and a product whose bytes are all nonzero: an alias from a value into the
		 * spare half of its block - which the read path did for two of the five ports - cannot
		 * hide behind a zero the way the list version of this test let it.
		 */
		val operands = BigInt("01010101", 16)
		val used = (Seq(Math.StatusRaw, Math.StatusSigned) ++
			(Seq(Math.X, Math.Y, Math.Product, Math.QuotientRaw, Math.RemainderRaw,
				Math.QuotientSigned, Math.RemainderSigned).flatMap(base => Seq(base, base + 1, base + 2, base + 3)))).toSet

		compiled.doSim { (dut: hc800.Math) =>
			dut.clockDomain.forkStimulus(period = 10)
			dut.io.enable #= false
			dut.io.write  #= false

			writeValue(dut, Math.X, operands, 4)
			writeValue(dut, Math.Y, operands, 4)
			poll(dut, Math.StatusRaw, "spare lanes")

			// If these read zero the sweep below is not proving anything about aliases.
			assert(readValue(dut, Math.X, 4) == operands, "X did not read back")
			assert(readValue(dut, Math.Y, 4) == operands, "Y did not read back")
			assert(readValue(dut, Math.Product, 4) == ((operands * operands) & Mask32), "no product")
			assert(readValue(dut, Math.QuotientRaw, 4) == BigInt(1), "no quotient")

			for (lane <- 0 until 0x40 if !used.contains(lane))
				assert(read(dut, lane) == 0,
				       s"$$02${lane.toHexString} is not in the map and read nonzero")
		}
	}

	// ------------------------------------------------------------------------- the strobe
	/** Writes one operand byte and returns the status byte as soon as it can be seen. */
	private def statusRightAfterAWrite(math: Math, lane: Int, value: Int): Int = {
		write(math, lane, value)
		read(math, Math.StatusRaw)
	}

	test("a write marks the results stale immediately, and a fresh one arrives 32 cycles later") {
		compiled.doSim { (dut: hc800.Math) =>
			dut.clockDomain.forkStimulus(period = 10)
			dut.io.enable #= false
			dut.io.write  #= false

			writeValue(dut, Math.X, BigInt(2), 4)
			writeValue(dut, Math.Y, BigInt(3), 4)
			poll(dut, Math.StatusRaw, "first run")
			assert(readValue(dut, Math.Product, 4) == BigInt(6), "the first run did not multiply")

			// Rewriting any lane makes the results that are sitting in the ports belong to nothing:
			// they must not be readable as though they were this write's.
			val status = statusRightAfterAWrite(dut, Math.X + 1, 0)
			assert((status & Ready) == 0, s"ready survived a write that started a run: $status")

			// ...and the new run is exactly as long as the old one.
			poll(dut, Math.StatusRaw, "second run")
			assert(readValue(dut, Math.Product, 4) == BigInt(6), "the second run did not multiply")
		}
	}

	test("a write in the middle of a run restarts it rather than corrupting it") {
		var product = BigInt(-1)
		compiled.doSim { (dut: hc800.Math) =>
			dut.clockDomain.forkStimulus(period = 10)
			dut.io.enable #= false
			dut.io.write  #= false

			writeValue(dut, Math.X, BigInt(2), 4)
			writeValue(dut, Math.Y, BigInt(3), 4)     // run for 2 * 3 has started
			for (_ <- 0 until 10) dut.clockDomain.waitRisingEdge()
			writeValue(dut, Math.X, BigInt(5), 4)     // restart with 5 * 3

			poll(dut, Math.StatusRaw, "restarted run")
			product = readValue(dut, Math.Product, 4)
		}
		assert(product == BigInt(15), s"a restarted run produced $product, want 15")
	}

	test("the last lane written is the one that starts the run, and the earlier ones count") {
		compiled.doSim { (dut: hc800.Math) =>
			dut.clockDomain.forkStimulus(period = 10)
			dut.io.enable #= false
			dut.io.write  #= false

			// The divide handover the emitter is required to make: the dividend first, then the
			// divisor, so only the divisor write can be the strobe and the dividend bytes written
			// before it have to be in the run that counts.
			writeValue(dut, Math.Y, BigInt("DEADBEEF", 16), 4)
			writeValue(dut, Math.X, BigInt("F0000000", 16), 4)

			poll(dut, Math.StatusRaw, "skewed handover")
			val quotient  = readValue(dut, Math.QuotientRaw, 4)
			val remainder = readValue(dut, Math.RemainderRaw, 4)
			val want      = BigInt("DEADBEEF", 16) / BigInt("F0000000", 16)
			val wantRem   = BigInt("DEADBEEF", 16) % BigInt("F0000000", 16)
			assert(quotient == want && remainder == wantRem,
				s"the run used the wrong operands: q=$quotient r=$remainder, want q=$want r=$wantRem")
		}
	}

	/**
	 * A run is 32 cycles for every operand, with no data-dependent early-out: that is what makes
	 * the poll bound provable, what makes the two readings of the operands arrive on the same
	 * cycle, and what keeps the models from drifting on timing.  Measured here by holding the bus
	 * on the status byte and counting the cycles until ready returns.
	 */
	test("every run is exactly as long, whatever the operands are") {
		def cyclesUntilReady(x: BigInt, y: BigInt): Int = {
			var cycles = -1
			compiled.doSim { (dut: hc800.Math) =>
				dut.clockDomain.forkStimulus(period = 10)
				dut.io.enable #= false
				dut.io.write  #= false

				writeValue(dut, Math.X, x, 4)
				writeValue(dut, Math.Y, y, 4)
				poll(dut, Math.StatusRaw, s"$x,$y warm-up")

				// The strobe is the last lane write; count from the cycle after it.  The bus must
				// be re-aimed at the status byte and one edge allowed to pass before the first
				// sample, because the answer comes back a cycle after the access - sampling
				// earlier reads whatever the write access itself put on the bus, which is the
				// operand byte, and its low bit is not the ready flag.
				write(dut, Math.X + 3, ((x >> 24) & 0xFF).toInt)
				dut.io.address #= Math.StatusRaw
				dut.io.write   #= false
				dut.io.enable  #= true
				cycles = 0
				var ready = false
				while (!ready && cycles < 200) {
					dut.clockDomain.waitRisingEdge()
					cycles += 1
					ready = (dut.io.dataToMaster.toInt & Ready) != 0
				}
				dut.io.enable #= false
			}
			cycles
		}

		val lengths = Seq(
			BigInt(1)              -> BigInt(1),
			BigInt("FFFFFFFF", 16) -> BigInt("FFFFFFFF", 16),
			BigInt("80000001", 16) -> BigInt("80000000", 16)
		).map { case (x, y) => cyclesUntilReady(x, y) }

		assert(lengths.distinct.size == 1, s"runs took different numbers of cycles: $lengths")
		// The exact number depends on where the harness's counting starts relative to the strobe;
		// that it is the same for every operand is the point, and that it is about 32 is what the
		// documentation promises.
		assert(lengths.head > Math.Iterations - 8 && lengths.head < Math.Iterations + 8,
			s"a run took ${lengths.head} cycles, expected about ${Math.Iterations}")
	}

	/**
	 * The reason there are two dividers rather than one run twice: readiness must never describe one
	 * family and not the other, because a driver that polls `$0200` and then reads a signed port is
	 * entitled to the same answer as one that polls `$0201`.  Sampled across a whole run rather than
	 * asserted structurally, so a design that published one reading a few cycles early would be
	 * caught rather than excused.
	 */
	test("the two status bytes become ready on the same cycle") {
		compiled.doSim { (dut: hc800.Math) =>
			dut.clockDomain.forkStimulus(period = 10)
			dut.io.enable #= false
			dut.io.write  #= false

			writeValue(dut, Math.X, BigInt("80000001", 16), 4)
			writeValue(dut, Math.Y, BigInt("80000000", 16), 4)
			poll(dut, Math.StatusRaw, "before the sampled run")

			// Restart, then sample both bytes all the way through the run.
			write(dut, Math.X + 3, 0x80)
			val samples = (0 until 40).map { _ =>
				val raw    = read(dut, Math.StatusRaw)
				val signed = read(dut, Math.StatusSigned)
				((raw & Ready) != 0, (signed & Ready) != 0)
			}
			assert(samples.forall { case (raw, signed) => raw == signed },
				s"the families were ready at different times: $samples")
			assert(samples.exists(_._1), "neither family ever became ready")
		}
	}

	// --------------------------------------------------------------------------------- sweep
	/** Directed cases first, then a sweep biased where the two readings of the operands part
	 *  company and where the divider used to lose its bit. */
	test("a sweep of the whole map agrees with the contract") {
		val random = new scala.util.Random(0xD1C1ABE)
		def biased32: BigInt =
			if (random.nextInt(2) == 0) BigInt(32, random)
			else (BigInt(31, random) | (BigInt(1) << 31)) & Mask32

		val directed = Seq(
			(BigInt("80000000", 16), BigInt("80000000", 16)),
			(BigInt("80000001", 16), BigInt("80000000", 16)),
			(Mask32, BigInt("80000000", 16)),
			(BigInt("80000000", 16), Mask32),
			(BigInt(1), BigInt("7FFFFFFF", 16)),
			(BigInt("FFFFFFFE", 16), BigInt(2)),
			(BigInt(0), BigInt(1)),
			(BigInt(1), BigInt(0))
		)
		directed.foreach { case (x, y) => operate(x, y).check() }

		for (_ <- 1 to 150) {
			val x = biased32 | BigInt(1)
			val y = if (random.nextInt(4) == 0) BigInt(0) else biased32
			operate(x, y).check()
		}
	}
}
