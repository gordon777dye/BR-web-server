---
title: BL
file: BL.md
category: 90-reference
subcategory: 90-reference/glossary-stubs
kind: concept
related: [and]
---
The **BL (binary low)** format specification is used for fast and efficient numeric storage. It is different from `B` and `BH` in just one way: when BL is specified, the lowest byte is stored first (BH stores the highest byte first, and B defaults to either BL or BH according to the native binary format of the hardware that Business Rules being run on).<br>

See also the `B` format specification discussion.
