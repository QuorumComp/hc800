#!/bin/bash

# macOS: sfdisk is in brew's util-linux package ('brew list util-linux' and add to path)
# macOS: dosfstools is in brew
# macOS: mtools is in brew

IMAGE=`pwd`/hd.img
LABEL=HC800

# Create empty disk image
dd if=/dev/zero of=$IMAGE bs=512 count=100000

# Format as MBR with one partition
sfdisk $IMAGE <<EOF
label: dos
64, , 0x0C
write
EOF

mkdosfs -F 32 -n $LABEL "$IMAGE"

# Write data to partition
mcopy -i $IMAGE -D o _image_/* ::/
mcopy -i $IMAGE -D o addons/* ::/

