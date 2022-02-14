#!/bin/sh
./b.sh
cd _image_
../../../hc800-emu-ml/_build/default/hc800emulator.exe boot.bin ../../data/font.bin -s 2
cd ..
