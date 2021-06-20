import scala.sys.process._

lazy val buildMachineCode = taskKey[Unit]("Execute ASMotor")

val spinalVersion = "1.4.3"

lazy val hc800 = (project in file("."))
	.settings(
		name := "hc800",

		version := "1.0",

		scalaVersion := "2.12.11",

		libraryDependencies ++= Seq(
			"com.github.spinalhdl" % "spinalhdl-core_2.12" % spinalVersion,
			"com.github.spinalhdl" % "spinalhdl-lib_2.12" % spinalVersion,
			compilerPlugin("com.github.spinalhdl" % "spinalhdl-idsl-plugin_2.12" % spinalVersion)
		),

		libraryDependencies += "com.typesafe.play" %% "play-json" % "2.7.4",

		fork := true,

		buildMachineCode := {
			val s: TaskStreams = streams.value
			val shell: Seq[String] = if (sys.props("os.name").contains("Windows")) Seq("cmd", "/c") else Seq("bash", "-c")
			val buildr8r: Seq[String] = shell :+ "cd ../firmware/boot && make"
			s.log.info("Building machine code...")
			if ((buildr8r !) == 0) {
				s.log.success("Machine code build successful!")
			} else {
				throw new IllegalStateException("Machine code build failed!")
			}
		},

		Compile / unmanagedSourceDirectories += baseDirectory.value / "rc800",

		(run in Compile) := ((run in Compile) dependsOn buildMachineCode).evaluated,
	)
