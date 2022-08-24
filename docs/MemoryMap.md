# Memory map

| Address | Size    | Bank    | Content          |
|---------|---------|---------|------------------|
| $000000 | $00800  | $00     | BIOS ROM         |
| $004000 | $04000  | $01     | Kernal RAM/ROM   |
| $020000 | $4000   | $08     | Chargen ROM      |
| $100000 | $8000   | $40-$41 | I/O space memory mapped |
| $108000 | $200    | $42     | Palette memory   |
| $10C000 | $2000   | $43     | Attribute memory |
| $200000 | $200000 | $80-$FF | RAM              |
