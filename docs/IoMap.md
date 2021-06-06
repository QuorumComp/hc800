# I/O Map

| Address | Size | Content    |
|---------|------|------------|
| $00xx   | 16   | Interrupt controller |
| $010x   | 16   | MMU        |
| $020x   | 16   | Multiplier |
| $030x   | 16   | Keyboard   |
| $040x   | 16   | UART       |
| $050x   | 16   | Display controller |
| $7FFx   | 16   | Board ID   |
| $8000   | $8000 | Board specific functions |


## Interrupt controller
| Address | Content                | Function |
|---------|------------------------|---|
| $00     | Enable interrupt mask  | Which interrupt source that can request an interrupt |
| $01     | Request interrupt mask | Interrupt sources that are requesting interrupt |
| $02     | Handle interrupt mask  | Interrupt sources that should be handled, effectively AND of Enable and Request masks |

### Interrupt mask
| 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|
|Set/clear. When 1, remaining one bits will be set. When 0, remaining one bits will be cleared.||||||Horizontal blanking start|Vertical blanking start |


## MMU
The MMU directs various 16 bit memory addresses to the full 22 bits physical address. A bank is an 8 bit number that points to a 16 KiB contiguous slice in the 4 MiB physical address space.

Four configurations can be specified by first writing the two bits configuration selector to $00, and then writing to $01-$0B. The configuration that should active can be selected by writing to $0C. The value held by $0D are used for all four configurations.

The system banks are in effect when handling interrupts and the SYS instruction.


| Address | Content              |
|---------|----------------------|
| $00     | Update index         |
| $01     | Configuration        |
| $02     | CPU bank 0           |
| $03     | CPU bank 1           |
| $04     | CPU bank 2           |
| $05     | CPU bank 3           |
| $06     | Data bank 0          |
| $07     | Data bank 1          |
| $08     | Data bank 2          |
| $09     | Data bank 3          |
| $0A     | System code bank     |
| $0B     | System data bank     |
| $0C     | Active index         |
| $0D     | Chipset chargen bank |

### Configuration register ($01)
| Bits | Content |
|------|---------|
| 0    | Enable Harvard architecture for user mode. When 0, CPU data access uses CPU banks. When 1, CPU data access uses Data banks |
| 1    | Enable Harvard architecture for system mode. When 0, CPU data access uses CPU banks. When 1, CPU data access uses Data banks |
| 3:2  | User code upper size |
| 5:4  | User data upper size |

"Upper size" configuration determines the size of the upper bank. When size 16 KiB is selected, there are four independent banks, corresponding to the banks specified in the bank registers. When the size is 32 KiB, there are three addressable banks - two 16 KiB banks and one 32 KiB. The first two correspond to bank registers 0 and 1, the last bank is selected by bank register 3.

| Value | Meaning | Bank select registers |
|-------|---------|-----------------------|
| 0     | 4 x 16 KiB banks | 0, 1, 2, 3 |
| 1     | 2 x 16 KiB banks, 1 x 32 KiB  | 0, 1, 3 |
| 2     | 1 x 16 KiB bank, 1 x 48 KiB  | 0, 3 |
| 3     | 1 x 64 KiB  | 3 |


## Multiplier
| Address | Size | Content                 |
|---------|------|-------------------------|
| $00     | 1    | Operation               |
| $01     | 1    | Status                  |
| $02     | 2    | 16 bit value #1 (x)     |
| $04     | 2    | 16 bit value #2 (y)     |
| $06     | 4    | 32 bit value #1 (z)     |

### Operations
| Value | Operation |
|-------|-----------|
| 0     | Signed multiplication, z = x * y   |
| 1     | Unsigned multiplication, z = x * y |
| 2     | Signed division, x (quotient) y (remainder) = z / y |
| 3     | Unsigned division, x (quotient) y (remainder) = z / y |

## Keyboard
| Address | Content |
|---------|---------|
| $00     | Data    |
| $01     | Status  |

## Board ID
| Address | Content                 |
|---------|-------------------------|
| $00     | Board identifier        |
| $01     | Board ASCII description |

### Board identifier ($00)
| Value | Meaning          |
|-------|------------------|
| $00   | ZX Spectrum Next |
| $01   | Digilent Nexys 3 |
| $FF   | HC800 Emulator   |

### Board ASCII description ($01)
This register returns an ASCII string containing a short human readable string with the board name.

The string's first byte contains a start bit and the string length. If bit seven is set, bits six though zero contain the string length (excluding this first marker byte). Reading the register again will return the next character.

To read the string reliably, the register should be read until a byte with the seventh bit set is retrieved, and then reading the number of characters indicated by bits six though zero.

## UART
| Address | Content |
|---------|---------|
| 0       | Data    |
| 1       | Status  |

### Status
| Bit | Content |
|-----|---------|
| 0   | Byte available to read |
| 1   | Write allowed          | 

# Nexys 3 I/O
| Address | Size | Content         |
|---------|------|-----------------|
| $8000   | 2    | Hex segment     |
| $8010   | 1    | 5-way buttons   |
| $8020   | 2    | UART            |

## Hex segment
| Address | Content           |
|---------|-------------------|
| 0       | Low byte of value |
| 1       | High byte of value |
