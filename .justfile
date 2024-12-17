build:
    cd firmware && make
    cd rtl && sbt "runMain hc800.HC800TopLevel"
    