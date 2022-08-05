#!/bin/sh
motorr8r -fb -orom.bin kernel.rc8
#hexdump -v -e '/1 "is(U(0x%04_ax)) { data <= 0x"' -e '/1 "%02x }\n"' rom.bin >rom.vh
#echo "default { data <= 0x00 }\n" >>rom.vh
