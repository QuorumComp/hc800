# I/O Map

| Address | Size | Content    |
|---------|------|------------|
| $00xx   | 16   | Interrupt controller |
| $010x   | 16   | MMU        |
| $02xx   | 64   | MATH coprocessor |
| $030x   | 16   | Keyboard   |
| $040x   | 16   | UART       |
| $05xx   | 256  | Display controller |
| $060x   | 16   | SD card |
| $7Exx   | 256 | Board specific functions |
| $7FFx   | 16   | Board ID   |


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


## MATH coprocessor

A 32x32 -> 32 multiplier and two 32/32 -> 32 dividers, one per reading of the operands.
All three are iterative and take 32 cycles per run, with no data dependent early out, so
software starts a run and polls a status byte.

Operands and results live in a file of byte lanes rather than in shift registers. Lane 0 of
every value is its least significant byte, so a value is written or read one byte at a time
in either order and the addresses simply step. Reads destroy nothing, so a result may be read
twice, and read out of order.

| Address   | Access | Content                                       |
|-----------|--------|-----------------------------------------------|
| $0200     | R      | Status for the unsigned ports                 |
| $0201     | R      | Status for the signed ports, same layout      |
| $0202-$03 | R      | Spare, read 0                                 |
| $0204-$07 | RW     | X - operand 1, and the divisor                |
| $0208-$0B | RW     | Y - operand 2, and the dividend               |
| $020C-$0F | R      | Spare, read 0                                 |
| $0210-$13 | R      | X * Y                                         |
| $0214-$17 | R      | Spare, read 0                                 |
| $0218-$1B | R      | Unsigned Y / X, quotient                      |
| $021C-$1F | R      | Unsigned Y / X, remainder                     |
| $0220-$23 | R      | Signed Y / X, quotient                        |
| $0224-$27 | R      | Signed Y / X, remainder                       |
| $0228-$3F | R      | Spare, read 0                                 |

### Starting a run

There is no operation register and no trigger write: **any write to an input lane**
($0204-$020B) starts the device. It clears readiness and the error bits and restarts all
three units from the lane contents as of that write, so a write in the middle of a run is a
restart rather than a corruption. The invariant software relies on is that the results
correspond to the lanes as of the most recent write. Reading never strobes.

A 32 bit operand is four accesses, sixteen bus cycles, so polling is genuinely required; a
result is four accesses too, so one poll before the first result byte covers the whole
readback. All five result ports and both status bytes become valid on the same cycle.

### Two readings

Signedness is which result port a program reads. For the multiply that costs nothing: the
low half of a product is the same whichever way the operands are read, so one run answers
both readings and there is one product port. For the divide it costs a second divider,
because signed division negates its operands *before* the loop rather than its result
afterwards - `-2 / -1` is `2 r 0` signed and `0 r 0xFFFFFFFE` unsigned, which is a different
quotient and remainder, not a negated one. So the device runs one multiplier and two dividers
off one sequencer: the lanes as written go to the unsigned ports, their magnitudes and
corrected signs go to the signed ones.

Division takes the magnitudes and corrects the signs afterwards: the quotient is negative
when the operand signs differ and the remainder follows the dividend, which is the truncating
convention C uses.

### Status

| 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|
|reserved, read 0|||||Quotient overflow|always 0|Divide by zero|Ready|

The low nibble lands on the condition lanes a program tests after putting the byte in `F`:
bit 0 is the carry lane (the results are ready), bit 1 the zero lane (the divisor was zero),
bit 3 the overflow lane. Bit 2 - the negative lane - is wired to nothing and has to stay
that way, because "neither error flag" is a single branch (`j/gt`) only while N reads zero.

`$0200` describes the unsigned ports and `$0201` the signed ones, since the two readings
disagree about when the answer is undefined. Both have the layout above, so the poll and the
one branch error check are identical whichever direction a program is using. The error bits
describe the division every strobe runs, whether or not the reader is about to use its
results: a program reading a product ignores them.

Polling for readiness, with the error bits tested in one branch:

```
		ld	d,IO_MATH_BASE
		ld	e,IO_MATH_STATUS
.poll:	lio	t,(de)
		ld	f,t
		j/cc	.poll		; carry lane = ready
		j/le	.error		; zero or overflow set
```

Streaming a value through the lanes steps the pointer by two per cell, low byte first:

```
		ld	de,IO_MATH_BASE+IO_MATH_Y
		lio	(de+),t		; low cell
		exg	f,t
		lio	(de+),t		; high cell - this write starts the run
		exg	f,t
```

### The cases with no answer

There are exactly two, and they are decided from the operands as they are latched:

* **Divide by zero** (bit 1, both status bytes) - the divisor is zero. All five result
  ports answer zero, which is what lets the read path be wires.
* **Quotient overflow** (bit 3, signed status byte only) - `INT32_MIN / -1`, whose magnitude
  quotient is 2^31 and so fits as `-2^31` but not as `+2^31`. What the signed ports publish
  is the two's complement wrap, `0x80000000`, the answer every software divider gives; C
  leaves that quotient undefined, so the machine is free to publish a number and the status
  bit is how a program that cares finds out.

The unsigned family has no overflow at all - a 32 bit unsigned dividend always leaves a
quotient that fits - so that bit is wired to nothing, and that is a property of the width
rather than a simplification. A zero divisor does not also raise the overflow bit: each bit
means exactly one thing.

### Why this machine is 32 bits

The device used to be a 64 bit machine: a 64 bit dividend arriving in a third lane, and
64 bit products on two ports. It cost 831 LUT against 560 for this one on the board's FPGA,
and none of the extra width was reachable - the compiler replicates the dividend's sign byte
before every division, so a genuine 64/32 divide was never emitted; a truncating multiply
reads at most four bytes of the product; wider results are a software expansion over several
32 bit device multiplies. This is a deliberate loss: a true 64/32 divide and a 64 bit product
are now impossible, in hand written assembly included. What the narrowing buys beyond the
271 LUT is that the undefined cases nearly vanish, and that the models, the firmware helpers
and the compiler's divide path all get shorter.

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
| $02   | MiST |
| $03   | MiSTer |
| $FF   | HC800 Emulator   |

### Board ASCII description ($01)
This register returns an ASCII string containing a short human readable string with the board name.

The string's first byte contains a start bit and the string length. If bit seven is set, bits six though zero contain the string length (excluding this first marker byte). Reading the register again will return the next character.

To read the string reliably, the register should be read until a byte with the seventh bit set is retrieved, and then reading the number of characters indicated by bits six through zero.

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

## SD card
| Address | Content |
|---------|---------|
| 0       | Data    |
| 1       | Status  |

### Status
| Bit | Content | Function |
|-----|---------|----------|
| 0   | In active | Set to retrieve bytes. The byte will be available when 32 machine cycles have elapsed (four instructions). When data register is read and active bit is set, the next byte will be retrieved. |
| 1   | Out active (read only) | Will be set when data register is written. The byte will be transmitted in 32 machine cycles (four instructions) |
| 2   | Card select #0 | Selects card #0 |
| 3   | Card select #1 | Selects card #1 |

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
