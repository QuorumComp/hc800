#!/bin/sh
./b.sh
cd _image_
../../../hc800-emu-ml/_build/default/hc800emulator.exe -s boot.bin ../../data/font.bin
cd ..