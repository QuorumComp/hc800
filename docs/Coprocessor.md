# Stream coprocessor
2048 16 bit words

## I/O Registers

| Location | Contents                           |
|----------|------------------------------------|
| $00      | Status                             |
| $01      | Stream source                      |
| $03      | Stream destination                 |
| $05      | Loop count - 1                     |
| $06      | Program index / start program      |

### Stream source ($00)
| 15:11         | 10:0                   |
|---------------|------------------------|
| Reserved      | Word address of stream |

### Stream destination ($02)

| 15:11         | 10:0                   |
|---------------|------------------------|
| Reserved      | Word address of stream |

### Program index / start program ($04)
Starts running the program at index * 2

| 7:0           |
|---------------|
| Program index |

## Instruction format

### I format
| 15 | 14:11   | 10:0    |
|----|---------|---------|
| 0  | P field | A field |

#### Load matrix 1
| P   | A       |
|-----|---------|
| $0  | Address |

#### Load matrix 2
| P   | A       |
|-----|---------|
| $1  | Address |

#### Load vector 1
| P   | A       |
|-----|---------|
| $2  | Address |

#### Load vector 2
| P   | A       |
|-----|---------|
| $3  | Address |

#### Load scalar 1
| P   | A       |
|-----|---------|
| $4  | Address |

#### Load scalar 2
| P   | A       |
|-----|---------|
| $5  | Address |

#### Loop
| P   | A           |   |
|-----|-------------|---|
| $6  | Offset | Decrement loop count, add offset to pc if not 0 |

#### Jump
| P   | A       |
|-----|---------|
| $7  | Address |

#### Set precision
| P   | A    |
|-----|------|
| $E  | Precision, the number of fractional bits |

#### End program
| P   | A    |
|-----|------|
| $F  | $000 |


### A format
| 15 | 14:10 |  9:5 |  4:0 |
|----|-------|------|------|
| 1  | Op 2  | Op 1 | Op 0 |

### A opcodes

| Opcode | Instruction   |
|--------|---------------|
| $0     | NOP |
| $2     | Load matrix 1 (m1) |
| $3     | Load matrix 2 (m2) |
| $4     | Load vector 1 (v1) |
| $5     | Load vector 2 (v2) |
| $6     | Load scalar 1 (s1) |
| $7     | Load scalar 2 (s2) |
| $8     | Store m1 * m2 |
| $9     | Store m2 * m1 |
| $A     | Store s1 / s2 |
| $B     | Store s2 / s1 |
| $C     | Store m1 * v1 |
| $D     | Store m2 * v1 |
| $E     | Store m1 * v2 |
| $F     | Store m2 * v2 |
| $10    | Store v1 * v2 |
| $11    | Store v1 * v1 |
| $12    | Store v2 * v2 |
| $14    | Store s1 * s1 |
| $15    | Store s1 * s2 |
| $16    | Store s2 * s2 |
| $18    | Store v1 * s1 |
| $19    | Store v2 * s1 |
| $1A    | Store v1 * s2 |
| $1B    | Store v2 * s2 |
| $1C    | Store v1 / s1 |
| $1D    | Store v2 / s1 |
| $1E    | Store v1 / s2 |
| $1F    | Store v2 / s2 |

