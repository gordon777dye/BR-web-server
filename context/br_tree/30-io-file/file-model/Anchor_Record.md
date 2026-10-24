---
title: Anchor_Record
file: Anchor_Record.md
category: 30-io-file
subcategory: 30-io-file/file-model
kind: statement
related: [Internal Files]
---
In `Internal Files`, the **Anchor Record** is the first record in a linked list, and the basis for accessing linked list data from the master record. The record number of this anchor point should always be written out to the master file after the list is updated. (If an anchor record has been processed, KREC will return the record number of the anchor record for the current linked list, even if the file pointer is positioned at another record in that list.) The previous record pointer (positions 5-8) of an anchor record will always be set to 0.
