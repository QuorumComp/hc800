# Disk image recipes for the HC800 firmware.
#
#   just disk         hd.img         FAT32 over the whole card
#   just disk-part    hd-part.img    one FAT32 primary partition
#   just disk-2part   hd-2part.img   Linux swap + FAT32 primary partitions
#   just disk-large   hd-large.img   >2 GiB card: swap + high-offset FAT32
#
# Images are built from _image_ (build the firmware first). Each FAT32
# filesystem is built at exactly its partition's size and then placed at the
# partition offset; partition geometry lives in the variables below.
#
# macOS prerequisites (brew): util-linux (sfdisk), dosfstools, mtools.

set fallback
set shell := ["bash", "-uc"]

sector_size   := "512"
total_sectors := "100000"

disk_image     := "hd.img"
part_image     := "hd-part.img"
two_part_image := "hd-2part.img"
large_image    := "hd-large.img"

part_start   := "2048"
part_sectors := "97952"

swap_start     := "2048"
swap_sectors   := "2048"
fat_start      := "4096"
fat_sectors    := "95904"
swap_sig_offset := "4086"

# Large-card test image (5 GiB): a large swap partition followed by a
# small FAT32 partition that starts above the 32-bit byte-address limit.
large_sectors      := "10485760"
large_swap_start   := "2048"
large_swap_sectors := "8390656"
large_fat_start    := "8392704"
large_fat_sectors  := "2093056"

tmp     := env("TMPDIR", "/tmp")
part_fs := tmp / "hc800-part-fs.img"
two_fs  := tmp / "hc800-2part-fs.img"
large_fs := tmp / "hc800-large-fs.img"

default:
    @just --list

# Generate the test files copied into the images
addons:
    #!/usr/bin/env bash
    set -euo pipefail
    printf 'This is a test\n' > addons/test.txt
    python3 -c "open('addons/bigfile.txt','w').write(''.join('Line %05d: '%n + 'A'*51 + '\n' for n in range(1,2049)))"

# Build and populate a FAT32 filesystem image of a given size in sectors
[private]
_fatfs sectors image: addons
    #!/usr/bin/env bash
    set -euo pipefail
    rm -f "{{image}}"
    dd if=/dev/zero of="{{image}}" bs=1 count=0 seek=$(({{sectors}} * {{sector_size}})) 2>/dev/null
    mkdosfs -F 32 -n "" "{{image}}"
    mcopy -i "{{image}}" -D o _image_/* ::/
    mcopy -i "{{image}}" -D o addons/* ::/

# FAT32 over the whole card
disk: (_fatfs total_sectors disk_image)
    @echo "Created {{disk_image}}"

# One FAT32 primary partition
disk-part: (_fatfs part_sectors part_fs)
    #!/usr/bin/env bash
    set -euo pipefail
    trap 'rm -f "{{part_fs}}"' EXIT
    rm -f "{{part_image}}"
    dd if=/dev/zero of="{{part_image}}" bs={{sector_size}} count={{total_sectors}} 2>/dev/null
    printf 'label: dos\nstart=%s, size=%s, type=0c\n' "{{part_start}}" "{{part_sectors}}" | sfdisk "{{part_image}}"
    dd if="{{part_fs}}" of="{{part_image}}" bs={{sector_size}} seek={{part_start}} conv=notrunc,sparse 2>/dev/null
    echo "Created {{part_image}}"

# Linux swap followed by FAT32, both primary
disk-2part: (_fatfs fat_sectors two_fs)
    #!/usr/bin/env bash
    set -euo pipefail
    trap 'rm -f "{{two_fs}}"' EXIT
    rm -f "{{two_part_image}}"
    dd if=/dev/zero of="{{two_part_image}}" bs={{sector_size}} count={{total_sectors}} 2>/dev/null
    printf 'label: dos\nstart=%s, size=%s, type=82\nstart=%s, size=%s, type=0c\n' \
        "{{swap_start}}" "{{swap_sectors}}" "{{fat_start}}" "{{fat_sectors}}" | sfdisk "{{two_part_image}}"
    printf 'SWAPSPACE2' | dd of="{{two_part_image}}" bs=1 seek=$(({{swap_start}} * {{sector_size}} + {{swap_sig_offset}})) conv=notrunc 2>/dev/null
    dd if="{{two_fs}}" of="{{two_part_image}}" bs={{sector_size}} seek={{fat_start}} conv=notrunc,sparse 2>/dev/null
    echo "Created {{two_part_image}}"

# Large (>2 GiB) card: swap first, FAT32 at a high offset at the end
disk-large: (_fatfs large_fat_sectors large_fs)
    #!/usr/bin/env bash
    set -euo pipefail
    trap 'rm -f "{{large_fs}}"' EXIT
    rm -f "{{large_image}}"
    dd if=/dev/zero of="{{large_image}}" bs=1 count=0 seek=$(({{large_sectors}} * {{sector_size}})) 2>/dev/null
    printf 'label: dos\nstart=%s, size=%s, type=82\nstart=%s, size=%s, type=0c\n' \
        "{{large_swap_start}}" "{{large_swap_sectors}}" "{{large_fat_start}}" "{{large_fat_sectors}}" | sfdisk "{{large_image}}"
    printf 'SWAPSPACE2' | dd of="{{large_image}}" bs=1 seek=$(({{large_swap_start}} * {{sector_size}} + {{swap_sig_offset}})) conv=notrunc 2>/dev/null
    dd if="{{large_fs}}" of="{{large_image}}" bs={{sector_size}} seek={{large_fat_start}} conv=notrunc,sparse 2>/dev/null
    echo "Created {{large_image}}"
