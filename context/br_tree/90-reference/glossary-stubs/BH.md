---
title: BH
file: BH.md
category: 90-reference
subcategory: 90-reference/glossary-stubs
kind: concept
related: [and]
---
The **BH (binary high) format specification** is used for fast and efficient numeric storage. It is different from `B` and `BL` in just one way: when BH is specified, the highest byte is stored first (BL stores the lowest byte first, and B defaults to either BL or BH according to the native binary format of the hardware that Business Rules is being run on).<br>
(See also the `B` format specification discussion.)
