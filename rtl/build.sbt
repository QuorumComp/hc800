import scala.sys.process._

lazy val buildMachineCode = taskKey[Unit]("Execute ASMotor")

val spinalVersion = "1.15.0"

lazy val hc800 = (project in file("."))
	.settings(
		name := "hc800",

		version := "1.0",

		scalaVersion := "2.12.20",

		libraryDependencies ++= Seq(
			"com.github.spinalhdl" % "spinalhdl-core_2.12" % spinalVersion,
			"com.github.spinalhdl" % "spinalhdl-lib_2.12" % spinalVersion,
			compilerPlugin("com.github.spinalhdl" % "spinalhdl-idsl-plugin_2.12" % spinalVersion)
		),

		libraryDependencies += "com.typesafe.play" %% "play-json" % "2.7.4",

		libraryDependencies += "org.scalameta" %% "munit" % "1.1.1" % Test,

		fork := true,

		buildMachineCode := {
			val s: TaskStreams = streams.value
			val shell: Seq[String] = if (sys.props("os.name").contains("Windows")) Seq("cmd", "/c") else Seq("bash", "-c")
			val buildr8r: Seq[String] = shell :+ "cd ../firmware && make"
			s.log.info("Building machine code...")
			if ((buildr8r !) == 0) {
				s.log.success("Machine code build successful!")
			} else {
				throw new IllegalStateException("Machine code build failed!")
			}
		},

		// Only the core sources; the submodule's own build also runs its tests.
		Compile / unmanagedSourceDirectories +=
			baseDirectory.value / "rc800" / "spinal" / "src" / "main" / "scala",

		// The submodule owns the tests, but Metals imports this build, so give
		// them a Test classpath (and let `sbt test` here run them too).
		Test / unmanagedSourceDirectories +=
			baseDirectory.value / "rc800" / "spinal" / "src" / "test" / "scala",

		Compile / run := ((Compile / run) dependsOn buildMachineCode)
	)
