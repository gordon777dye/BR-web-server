---
title: LINKED
file: LINKED.md
category: 30-io-file
subcategory: 30-io-file/file-model
kind: statement
related: [Open Internal, Restore File, Read file, Write, Delete Statement, Krec, Functions, 4282, 4283, 0606]
---
Business Rules now supports LINKED files, which are Business Rules internal files that contain one or more sets of linked records. When their use is appropriate, linked files can be much faster than indexed files (probably two to three times as fast), and they require less overhead.

Program performance does not degrade when they increase in size. Also, records may be inserted at any point in a linked list.

However, two potential drawbacks are that corrupted link list files can be difficult to rebuild in the correct order. Also, there is no way to identify the order in which linked records are added to the file because of the way the system handles deleted records in linked list files.

Linked files are most useful for situations where you wish to attach a group of records to a master record, and the only way you will ever want or need to access those records is through the master record. An example usage is a customer maintenance program that allows the user to keep notes (up to 15 lines of 50 characters each) about each customer.

The following terms will be used to describe the operation and structure of linked files:

:1.) {\b Linked file} - A file that is opened LINKED, INTERNAL. This file will ultimately contain one or more linked lists.
:2.) {\b Linked list} - An entire set of linked records. A single linked file will usually contain several linked lists.
:3.) {\b Linked list record} - Any record in a linked list, regardless of its position within that list. The first eight bytes of each linked list record are reserved for two fields:
:(a) The next record pointer (positions 1-4)
:(b) The previous record pointer (positions 5-8).

These are maintained by Business Rules and must not be overwritten by the program. While they are normally ignored, the program can access them with a statement such as the following:

 00100 READ #1,USING "FORM 2*BH 4":NEXTPTR,PREVPTR

Next record pointer - Positions 1 through 4 of each linked list record, which identify the next record in the linked list. If this pointer is set to 0, the record is the last one in the linked list. This pointer position is maintained by Business Rules and must not be overwritten by the program.

Previous record pointer - Positions 5 through 8 of each linked list record, which point to the previous record in the linked list. If this pointer is set to 0, the record is the first one (the anchor record) in the linked list. This pointer position is maintained by Business Rules and must not be overwritten by the program.

;ANCHOR RECORD
The first record in a linked list, and the basis for accessing linked list data from the master record. The record number of this anchor point should always be written out to the master file after the list is updated. (If an anchor record has been processed, KREC will return the record number of the anchor record for the current linked list, even if the file pointer is positioned at another record in that list.) The previous record pointer (positions 5-8) of an anchor record will always be set to 0.

;RELATED RECORD:
The second and additional records in a linked list. The last record in a linked list will have a next record pointer of 0.

The following Business Rules instructions play important roles in the use of linked files:

;OPEN INTERNAL STATEMENT:
OPEN internal now accepts the LINKED keyword, which specifies that the file to be opened consists of linked lists.<br>
Also see `Open Internal`

;RESTORE FILE STATEMENT:
In linked files, the RESTORE file statement plays two important roles.
:1.) It can be used with the REC= parameter to reposition the file pointer to any specified record number.
:2.) The next role of RESTORE is that it can be used without parameters to create a new anchor point for a linked list that you wish to add or insert.
Also see `Restore File`

;READ FILE STATEMENT:
The READ file statement now accepts the LINK=string parameter for Verifying that linked records belong to a master. It can be used only on LINKED files that have been opened using the `KPS=` and `KLN=` parameters<br>
Also see `Read file`.

> Two corrections to the paragraph above, from BR's own source. **`LINK=` is admitted on four
> statements, not one** — READ, RESTORE, REWRITE and DELETE all carry it in their `syn.txt` trees — and
> BR groups it with the *positioning* parameters (`command5.cpp`'s `sec_kw[]`, beside
> FIRST/LAST/PRIOR/SAME) rather than with the FORM or locking clauses. On a LINKED file it is also the
> **only** key parameter accepted: `KEY=` and `SEARCH=` there answer error 0702, and the LINK= string
> must be the exact total key length or 0718. Folded with those rules into
> [statements §link](../statements/spec.md#link), the spec that owns the four statements.
> (The parameter names above read `KPSI7E4W2=` and `KLNE2E4W2=` in the source this page came from —
> corrupted wikitext for `KPS=` and `KLN=`, fixed here.)

;WRITE STATEMENT:
The WRITE statement may be used to insert a record into an existing linked list. (A linked list is not considered to be "existing" unless an anchor point has been established for it with a RESTORE statement.)<br>
Also see `Write`.

;DELETE STATEMENT:
The DELETE statement may be used to delete any anchor record or sub-record from a linked list. If REC= is not specified, the DELETE statement must be preceded by a successful READ of the record to be deleted.<br>
Also see `Delete Statement`.

;KREC(filenbr) function:
KREC will return the record number of the most recently processed (read or written) anchor record.<br>
Also see `Krec`(filenbr) in the `Functions` section.

===LINKED ERROR CODES===
The following error codes are specific to LINK. For full descriptions see each code individually.

`4282` Data does not match LINK=

`4283` Error in updating previous/next link

`0606` Invalid element in OPEN

`0702` File not opened KEYED or LINKED

`0718` Key length conflict
