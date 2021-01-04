# Building

A Windows 10 installation is recommended. It has been verified that all parts of the project, except the bitstreams, build on Linux (including WSL) and macOS. It may be possible to build the bitstreams on Linux using Linux versions of the vendor specific toolchains, but this has not been attempted.

## Windows

### Prerequisites
It is easiest and quickest to use [Chocolatey](https://chocolatey.org/) to install the prerequisites.

Install [ASMotor](https://github.com/asmotor/asmotor)

GNU Make
```
choco install make
```

Install a version of the Java JDK, for instance
```
choco install zulu11
```

Install SBT
```
choco install sbt
```

Quartus II 13.1 for MiST

Xilinx ISE 14.7 for ZX Spectrum Next

### Build
```
cd firmware && make && cd ..
cd spinal && sbt "runMain hc800.HC800TopLevel" && cd ..
```

