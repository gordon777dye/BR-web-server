---
title: Format_Specifications
file: Format_Specifications.md
category: 20-io-screen
subcategory: 20-io-screen/fields-attributes
kind: statement
related: [File I/O, Business Rules!, string, numeric, internal, external, READ, REREAD, statements, WRITE]
---
The page presents a summary chart of format specifications. Also see the Format Specifications
category and File I/O for detailed descriptions of each format.

The following table shows where and how each of `Business Rules!` **format specifications** may be
used.

"S", "N" and "I" indicate whether the specification is a `string`, `numeric` or internal format
spec.

The next two columns show what happens when the format specification is used with `internal` or
`external` files, either for input (with the `READ`/`REREAD` `statements`) or for output (with the
`WRITE`/`REWRITE` statements).

The column labeled "Print (Output)" shows what happens when the format specification is used with
display files.

The last two columns show what happens when the format specification is used with full screen
processing, either for input (with the `INPUT FIELDS` statement) or for output (with the
`PRINT FIELDS` statement). Note that the information marked for Input Fields applies to
`RINPUT FIELDS` when RINPUT FIELDS is used for input. Likewise, the information marked for Print
Fields applies to RINPUT FIELDS when RINPUT FIELDS is used for output.

If there is an X in any of the last five columns, the format specification operates according to
its intended purpose when it is used as indicated. If there is an error code number in the column,
the format specification cannot be used with this type of file (the specified error will occur if
usage is attempted).

The phrase "Treat as ..." means that the specification is accepted when used as indicated, but
treated as if it were a different format specification.

The table groups its columns as: **Type** (Format, Description, S, N, I) · **Internal**
(Read/Reread, Write/Rewrite) · **Display** (Print) · **Full Screen** (Input Fields, Print Fields). S - string / N - numeric / I - internal storage

| Format | Description | S | N | I | Read/Reread (Input) | Write/Rewrite (Output) | Print (Output) | Input Fields (Input) | Print Fields (Output) |
|---|---|---|---|---|---|---|---|---|---|
| `B` | Binary | | | X | X | X | Error 0816 | Error 0816 | Error 0816 |
| `BL` | Binary Low | | | X | X | X | Error 0816 | Error 0816 | Error 0816 |
| `BH` | Binary High | | | X | X | X | Error 0816 | Error 0816 | Error 0816 |
| `C` | Character | X | | | X | X | X | X | X |
| `CC` | C Centered | X | | | Treat as C | X | X | Treat as C | X |
| `CR` | C Right Justified | X | | | Treat as C | X | X | Treat as C | X |
| `CL` | C Lowercase | X | | | Err 1006 | Err 1006 | Err 1006 | X | Treat as C |
| `CU` | C Uppercase | X | | | Err 1006 | Err 1006 | Err 1006 | X | Treat as C |
| `D` | Double Precision Floating Point | | | X | X | X | Err 801 | Err 0861 | Err 0861 |
| `DH` | Date Binary | | X | | X | X | | | |
| `DL` | Date Binary Low | | X | | X | X | | | |
| `DT` | Date Binary High | | X | | X | X | | | |
| `FMT` | Masked (Formatted) Input | X | X | | | | | X | X |
| `G` | Generic | X | X | | X | X | X | X | X |
| `GF` | G Floating Point | X | X | | X | X | X | | |
| `GL` | G Lowercase | X | X | | Err 1006 | Err 1006 | Err 1006 | X | Treat as G |
| `GU` | G Uppercase | X | X | | Err 1006 | Err 1006 | Err 1006 | X | Treat as G |
| `GZ` | G Zero Suppress | X | X | | Treat as G | X | X | Treat as G | X |
| `L` | Long Numeric | | | X | X | X | Err 0801 | X | X |
| `L` | Leave Decimal | | X | | Err 1006 | Err 1006 | Err 1006 | X | X |
| `N` | Numeric | | X | | X | X | X | X | X |
| `NZ` | N Display Zero | | X | | Treat as N | X | X | Treat as N | X |
| `Picture`, `P` | Picture | | | X | | | | X | X |
| `PD` | Packed Decimal | | | X | X | X | Err 0816 | Err 0816 | Err 0816 |
| `PIC` | Masked (Pic Spec) Input | X | X | | X | | X | X | X |
| `S` | Single Precision Floating Point | | | X | X | X | X | X | |
| `V` | String | X | | | X | X | X | X | X |
| `VL` | S Lowercase | X | | | Err 1006 | Err 1006 | Err 1006 | X | Treat as V |
| `VU` | S Lowercase | X | | | Err 1006 | Err 1006 | Err 1006 | X | Treat as V |
| `ZD` | Zoned Decimal | | | X | X | X | Err 0816 | Err 0861 | Err 0861 |

**Anomalies preserved verbatim from the source table** (not corrected here, per the "don't
guess" rule — flagged instead):

- Two rows share the format code `L` ("Long Numeric" and "Leave Decimal").
- `VU`'s description reads "S Lowercase" in the source, identical to `VL`'s; a description of
  "S Uppercase" may have been intended, but this is not confirmed.
- The `S` (Single Precision Floating Point) row had one fewer cell than every other row in the
  source wikitable. Which column the source omitted could not be determined, so the Print Fields
  (Output) value is left blank above rather than guessed.
- The format code for the `Picture` row was written in the source as a single cell containing
  both `Picture` and `P`, suggesting these are two names/spellings for the same specification;
  this is reproduced as two code spans above rather than interpreted further.

## See Also

- Error [`1006`](../../90-reference/error-codes/1006.md)
- Error [`0816`](../../90-reference/error-codes/0816.md)
- Error [`0862`](../../90-reference/error-codes/0862.md)
