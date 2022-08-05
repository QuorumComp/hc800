#!/bin/bash
IMAGE=`pwd`/hd.img
LABEL=HC800
MOUNTDIR=.disk_$LABEL
LOOPDEV=/dev/loop87 # an unused loop device that shouldn't already exist

# Create empty disk image
dd if=/dev/zero of=$IMAGE bs=512 count=100000

# Format as MBR with one partition
sfdisk $IMAGE <<EOF
label: dos
64, , 0x0C
write
EOF

rm -rf $MOUNTDIR
mkdir $MOUNTDIR

# Mount partition and format as FAT32
sudo losetup -P $LOOPDEV $IMAGE
sudo mkdosfs -F 32 -n $LABEL "${LOOPDEV}p1"
sudo mount "${LOOPDEV}p1" $MOUNTDIR -o umask=000

# Write data to partition
cp _image_/* $MOUNTDIR
cp addons/* $MOUNTDIR

# Unmount and clean up
sudo umount $MOUNTDIR
sudo losetup -d $LOOPDEV
rmdir $MOUNTDIR
