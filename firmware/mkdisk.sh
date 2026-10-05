#!/bin/bash

# macOS: sfdisk is in brew's util-linux package ('brew list util-linux' and add to path)
# macOS: dosfstools is in brew
# macOS: mtools is in brew

IMAGE=`pwd`/hd.img

# Create empty disk image
dd if=/dev/zero of=$IMAGE bs=512 count=100000 2>/dev/null

# Format as FAT32 with NO volume label.
# For FAT32 the RootEntCnt field must stay 0; a non-zero value reserves a
# separate root-directory area that shifts the data region, which the
# firmware's data-base calculation does not account for.
mkdosfs -F 32 -n "" "$IMAGE"

# Generate test files (regenerated on every image build, so they survive a clean)
# test.txt: 15 bytes, one cluster
printf 'This is a test\n' > addons/test.txt
# bigfile.txt: 2048 lines x 64 bytes (63 content + linefeed) = 128 KB = 2 full clusters
# (SPC=128 -> 64 KB/cluster; cluster boundary falls exactly at line 1024)
python3 -c "open('addons/bigfile.txt','w').write(''.join('Line %05d: '%n + 'A'*51 + '\n' for n in range(1,2049)))"

# Write data to partition
mcopy -i $IMAGE -D o _image_/* ::/
mcopy -i $IMAGE -D o addons/* ::/
