---
title: ON_ATTN
file: ON_ATTN.md
category: 90-reference
subcategory: 90-reference/error-codes
kind: error-code
related: []
---
ON ATTN now means "ON Ctrl-A" and `OPTION (Config)|OPTION` 65 is provided to ignore ON ATTN altogether: 

The IBM System/23 treated F10 as the attention key. BR changed that to Ctrl-C which was then reassigned to Ctrl-A. At some point years ago the ON ATTN trap in BR stopped working, so programs that had ON ATTN IGNORE in them were still interruptible. In 4.3 we corrected the failure which unintentionally made many legacy programs uninterruptable. So OPTION 65 was provided to ignore such statements altogether.
