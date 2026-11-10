package hc800

import spinal.core._
import spinal.core.sim._
import java.nio.file.{Files, Path, Paths}
import java.nio.charset.StandardCharsets

/*
 * Records a differential trace of the MATH coprocessor: a deterministic stream of byte accesses,
 * driven through the hardware description, with the byte the board would answer written down next
 * to every read.
 *
 * The three software models - the emulator, the co-simulation driver, and ucsim - are independent
 * implementations of the same contract, and a model that agrees with itself is worth nothing.  So
 * the golden here is not an expectation someone typed: it is what the RTL said, and each model is
 * replayed against it (`dune runtest` in the emulator, `test/math_trace.cc` in ucsim).  A model
 * that drifts fails there rather than on a board.
 *
 * Every access is separated by more than a run's worth of cycles.  That is not the hardware's
 * constraint but the models': they compute at the strobing write and report READY immediately,
 * where the device takes 32 cycles with READY clear.  A driver polls, so the bytes a polled
 * driver can see are exactly the bytes compared here - and the busy window stays the property of
 * this repository's own tests, which do have a clock.
 */
class MathTraceTest extends munit.FunSuite {

	private val compiled = SimConfig.compile(new Math())

	private val Golden = Paths.get("golden", "math-trace.txt")

	/** One bus access: a byte write, or a read whose answer the RTL fills in. */
	private sealed trait Op { def lane: Int }
	private case class Write(lane: Int, value: Int) extends Op
	private case class Read(lane: Int) extends Op

	// --------------------------------------------------------------------- the traffic
	//
	// Directed vectors first - the cases where the two readings of one operand pair disagree,
	// the two undefined cases, the region where the divider used to lose a bit, and accesses to
	// everything that is not a result port - then a random sweep over the whole window.

	private val vectors: List[(BigInt, BigInt)] = List(
		BigInt(0) -> BigInt(0),
		BigInt(1) -> BigInt(0),
		BigInt(0) -> BigInt(1),                                      // divide by zero
		BigInt("FFFFFFFF", 16) -> BigInt("80000000", 16),            // INT32_MIN / -1
		BigInt("FFFFFFFE", 16) -> BigInt("FFFFFFFF", 16),            // -1 / -2
		BigInt("7FFFFFFF", 16) -> BigInt("80000000", 16),            // -2^31 / (2^31-1)
		BigInt("80000000", 16) -> BigInt("80000000", 16),            // -2^31 / -2^31
		BigInt("80000000", 16) -> BigInt(1),
		BigInt("10000", 16) -> BigInt("FFFFFFFF", 16),               // the lost-bit region
		BigInt("7FFFFFFF", 16) -> BigInt("FFFFFFFF", 16),
		BigInt(2) -> BigInt("80000000", 16),
		BigInt("12345678", 16) -> BigInt("9ABCDEF0", 16),            // a product worth reading
		BigInt("FFFFFFFF", 16) -> BigInt("FFFFFFFF", 16),
		BigInt("00010000", 16) -> BigInt("FFF00000", 16),
		BigInt("AAAAAAAA", 16) -> BigInt("55555556", 16),
		BigInt(3) -> BigInt("7FFFFFFF", 16)
	)

	/** Writes X and Y byte by byte, in a rotating byte order so that no model can rely on the
	 *  most significant byte arriving last. */
	private def writeOperands(x: BigInt, y: BigInt, descending: Boolean): List[Op] = {
		def lanes(base: Int, value: BigInt) =
			(0 until 4).map(i => base + (if (descending) 3 - i else i)).map { lane =>
				Write(lane, ((value >> (8 * (lane & 3))) & 0xFF).toInt)
			}.toList
		lanes(Math.X, x) ::: lanes(Math.Y, y)
	}

	private val readsOfEverything =
		(List(
			Math.StatusRaw, Math.StatusSigned, 0x02, 0x03,
			Math.X, Math.X + 1, Math.X + 2, Math.X + 3,
			Math.Y, Math.Y + 1, Math.Y + 2, Math.Y + 3,
			0x0C, 0x0F,
			Math.Product, Math.Product + 1, Math.Product + 2, Math.Product + 3,
			0x14, 0x17,
			Math.QuotientRaw, Math.QuotientRaw + 1, Math.QuotientRaw + 2, Math.QuotientRaw + 3,
			Math.RemainderRaw, Math.RemainderRaw + 3,
			Math.QuotientSigned, Math.QuotientSigned + 1, Math.QuotientSigned + 2,
			Math.QuotientSigned + 3, Math.RemainderSigned, Math.RemainderSigned + 3,
			0x28, 0x2C, 0x33, 0x3F
		) ::: List(Math.Product, Math.QuotientSigned)) // read back twice, in the middle
		.map(Read)

	private def randomOps(seed: Int, count: Int): List[Op] = {
		val state = scala.collection.mutable.ListBuffer.empty[Op]
		var s = seed.toLong
		def next(): Int = {
			s = (s * 6364136223846793005L + 1442695040888963407L) & ((1L << 62) - 1)
			((s >> 17) & 0x7FFFFFFF).toInt
		}
		for (_ <- 0 until count) {
			val lane = next() & 0x3F
			// A write to anything but an input lane must do nothing at all, and reads of the
			// result ports are what a driver does; both are in proportion below.
			if ((next() & 3) == 0 && lane >= Math.X && lane <= Math.Y + 3) state += Write(lane, next() & 0xFF)
			else if ((next() & 7) == 0 && (lane < Math.X || lane > Math.Y + 3)) state += Write(lane, next() & 0xFF)
			else state += Read(lane)
		}
		state.toList
	}

	private val traffic: List[Op] =
		vectors.zipWithIndex.flatMap { case ((x, y), index) =>
			writeOperands(x, y, descending = index % 2 == 1) ::: readsOfEverything :::
				List(Write(Math.StatusRaw, 0xA5), Read(Math.Product), Read(Math.StatusRaw))
		} ::: randomOps(seed = 0x5EEDC0DE, count = 600)

	// ------------------------------------------------------------------- the bus, in bytes

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

	/** More than a run's worth of cycles with the bus idle, so the next access sees a finished
	 *  one.  The models do not need the spacing; the hardware needs it to be there. */
	private def settle(math: Math): Unit =
		for (_ <- 0 until (Math.Iterations + 4)) math.clockDomain.waitRisingEdge()

	test("the recorded trace matches the checked-in golden") {
		val answers = scala.collection.mutable.ListBuffer.empty[(Int, Int)]
		var notReady = 0

		compiled.doSim { (dut: Math) =>
			dut.clockDomain.forkStimulus(period = 10)
			dut.io.enable #= false
			dut.io.write  #= false
			dut.clockDomain.waitRisingEdge()
			traffic.foreach {
				case Write(lane, value) =>
					settle(dut)
					// The spacing is only honest if a run really has finished by now, which is
					// what this checks - and it is the same test the models' replay relies on.
					if ((read(dut, Math.StatusRaw) & Math.Ready) == 0) notReady += 1
					write(dut, lane, value)
				case Read(lane) =>
					settle(dut)
					if ((read(dut, Math.StatusRaw) & Math.Ready) == 0) notReady += 1
					answers += (lane -> read(dut, lane))
			}
		}

		assert(notReady == 0, s"$notReady accesses landed in the middle of a run")

		val header =
			"""# MATH coprocessor differential trace - generated, do not edit.
			    |# Regenerate with: sbt "testOnly hc800.MathTraceTest" (run from hc800/rtl).
			    |#
			    |# One access per line: `W <offset> <byte>` writes, `R <offset> <byte>` reads and
			    |# asserts the byte the hardware answered.  Offsets are within the device window
			    |# ($0200 + offset).  Accesses are spaced further apart than a run (32 cycles) because
			    |# the software models are instantaneous where the device is not; see MathTraceTest.
			    |""".stripMargin

		val body = new StringBuilder
		var seen = answers.iterator
		traffic.foreach {
			case Write(lane, value) => body ++= f"W $lane%02X $value%02X\n"
			case Read(_) =>
				val (lane, value) = seen.next()
				body ++= f"R $lane%02X $value%02X\n"
		}
		val trace = header + body.toString

		val fresh = answers.length
		assert(fresh > 300, s"the traffic is too small to prove anything: $fresh reads")

		val previous = if (Files.exists(Golden)) Some(Files.readAllBytes(Golden)) else None
		Files.createDirectories(Golden.getParent)
		Files.write(Golden, trace.getBytes(StandardCharsets.UTF_8))

		previous match {
			case None =>
				fail(s"no golden yet: $Golden was just written - replay it against the models and commit it")
			case Some(bytes) if new String(bytes, StandardCharsets.UTF_8) == trace => ()
			case Some(_) =>
				fail(s"$Golden no longer matches the hardware; it has been rewritten, so replay it " +
				      "against the three models and commit the new one with whatever they needed")
		}
	}
}
