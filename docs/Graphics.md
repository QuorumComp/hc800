# Graphics
* Pixel clock: 13.5 MHz
* Scanlines visible: 240
* Scanlines total: 256
* Pixel cycles per line: 880
* Visible pixels: 720 (hires)

## Visible Timing

|                              | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 |
|------------------------------|---|---|---|---|---|---|---|---|---|---|----|----|----|----|----|----|
| Hires pixel                  | x | x | x | x | x | x | x | x | x | x |  x |  x |  x |  x |  x |  x |
| Lores pixel                  | x |   | x |   | x |   | x |   | x |   |  x |    |  x |    |  x |    |
| CPU mem                      |   | x |   |   |   | x |   |   |   | x |    |    |    |  x |    |    |
| Lores P0 mem, 2 color        | x |   |   |   |   |   |   |   |   |   |    |    |    |    |    |    |
| Lores P1 mem, 2 color        |   |   |   |   |   |   |   |   | x |   |    |    |    |    |    |    |
| Lores P0 mem, 4 color        | x |   |   |   |   |   |   |   | x |   |    |    |    |    |    |    |
| Lores P1 mem, 4 color        |   |   |   |   | x |   |   |   |   |   |    |    |  x |    |    |    |
| Lores P0 mem, 16 color       | x |   |   |   | x |   |   |   | x |   |    |    |  x |    |    |    |
| Lores P1 mem, 16 color       |   |   | x |   |   |   | x |   |   |   | x  |    |    |    | x  |    |
| Lores mem, 256 color         | x |   | x |   | x |   | x |   | x |   | x  |    |  x |    | x  |    |
| Hires mem, 2 color           | x |   |   |   |   |   |   |   | x |   |    |    |    |    |    |    |
| Hires mem, 4 color           | x |   |   |   | x |   |   |   | x |   |    |    |  x |    |    |    |
| Hires mem, 16 color          | x |   | x |   | x |   | x |   | x |   | x  |    |  x |    | x  |    |


| Lores Sprite mem, 2 color    |   |   |   | x |   |   |   |   |   |   |    |    |    |    |    |    |
| Lores Sprite mem, 4 color    |   |   |   | x |   |   |   |   |   |   |    | x  |    |    |    |    |
| Lores Sprite mem, 16 color   |   |   |   | x |   |   |   | x |   |   |    | x  |    |    |    | x  |
| Hires Sprite mem, 2 color    |   |   |   | x |   |   |   |   |   |   |    | x  |    |    |    |    |
| Hires Sprite mem, 4 color    |   |   |   | x |   |   |   | x |   |   |    | x  |    |    |    | x  |

## Off screen Timing

160 hires pixels off screen. Last 32 uses visible timing to prepare for scrolling.



|                              | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 |
|------------------------------|---|---|---|---|---|---|---|---|---|---|----|----|----|----|----|----|
| Hires pixel                  | x | x | x | x | x | x | x | x | x | x |  x |  x |  x |  x |  x |  x |
| Lores pixel                  | x |   | x |   | x |   | x |   | x |   |  x |    |  x |    |  x |    |
| CPU mem                      |   | x |   |   |   | x |   |   |   | x |    |    |    |  x |    |    |
| Lores Sprite mem, 2 color    | x |   | x | x | x |   | x | x | x |   |  x |  x |  x |    |  x |  x |
| Lores Sprite mem, 4 color    | x |   | x | x | x |   | x | x | x |   |  x |  x |  x |    |  x |  x |
| Lores Sprite mem, 16 color   | x |   | x | x | x |   | x | x | x |   |  x |  x |  x |    |  x |  x |
| Hires Sprite mem, 2 color    | x |   | x | x | x |   | x | x | x |   |  x |  x |  x |    |  x |  x |
| Hires Sprite mem, 4 color    | x |   | x | x | x |   | x | x | x |   |  x |  x |  x |    |  x |  x |

## Attributes

| 15            | 14     | 13     | 12:11   | 10:0       |
|---------------|--------|--------|---------|------------|
| Flip priority | Flip Y | Flip X | Palette | Tile index |
