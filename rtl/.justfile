build:
    cd ../firmware && make
    sbt "runMain hc800.HC800TopLevel"
    