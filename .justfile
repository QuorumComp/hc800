@build:
    cd firmware && make --no-print-directory -s
    cd rtl && sbt "runMain hc800.HC800TopLevel"
    