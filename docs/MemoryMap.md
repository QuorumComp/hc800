# Memory map

| Address | Size    | Bank    | Content          |
|---------|---------|---------|------------------|
| $000000 | $00800  | $00     | BIOS ROM         |
| $004000 | $04000  | $01     | Kernal RAM/ROM   |
| $020000 | $4000   | $08     | Chargen ROM      |
| $0E0000 | $200    | $38     | Palette memory   |
| $0F0000 | $2000   | $3C     | Attribute memory |
| $200000 | $200000 | $80-$FF | RAM              |
