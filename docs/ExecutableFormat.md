# Header

| Offset | Contents |
|--------|----------|
| 0      | 'U'      |
| 1      | 'C'      |
| 2-     | Hunks    |

# Hunk

| Offset | Contents |
|--------|----------|
| 0      | Type     |
| 1-2    | Number of bytes to follow, little endian |
| 3-     | Content  |

# Hunk type 0 (End)

Stop loading executable. Must be present. No content.

# Hunk type 1 (MMU Config)

MMU configuration for user code. Must be present.

| Offset | Contents |
|--------|----------|
| 0      | MMU flags |
| 1-4    | MMU code banks |
| 5-8    | MMU data banks |

# Hunk type 2 (Data)

| Offset | Contents |
|--------|----------|
| 0      | Bank number |
| 1-     | A number of bytes |
