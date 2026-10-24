---
title: Index_Facility
file: Index_Facility.md
category: 30-io-file
subcategory: 30-io-file/keys-indexes
kind: statement
related: [OPEN internal, READ, RESTORE, REWRITE, WRITE, Index, KLN, KPS, KREC, BRConfig.sys]
---
Sometimes called key file processing, index file processing, or ISAM (Indexed Sequential Access Method), Business Rules! index facility is a powerful, yet easy-to-use collection of features. The major concept underlying this index facility is building a key file based on a particular field or set of fields in the master file. This key file allows you to selectively access particular records in the master file by knowing only the value of the key field -or sometimes just the first part of the key field.

This section presents an introductory overview of Business Rules index facility. For more detailed information, you should also see the `Delete Statement|DELETE`, `OPEN internal`, `READ`, `RESTORE`, `REWRITE` and `WRITE` statements; the `Index` command and the `KLN`, `KPS` and `KREC` functions.

==Why use indexing?==
Business Rules index is a powerful tool that can help you accomplish the following tasks quickly and efficiently:

:1.) On-line maintenance.
:2.) Sequential reports by key field.
:3.) On-line queries.
:4.) File organization.

==Terminology==
The following terminology is used in discussing the index facility:

===Duplicate keys===

===Index command===
The Index command is the instruction that tells Business Rules to begin the indexing process. This command is used both to create a new index file and to reorganize existing files. See `Index` for the complete description of its syntax. Business Rules will execute the Index command when it is issued in any one of three ways: from READY mode, from a procedure file, or with the EXECUTE statement.

===INDEX file===

===Key field===
A key field is the section (or sections) of the master file record that identifies that record. As an example, if you wish to access a particular record by specifying a customer name, the customer name would be the key field; it would exist both in the master file and in the index file.

Business Rules allows you to join up to six sections of a record (in a combined total of not more than 128 bytes) to form the key field. When more than one section of a record is used to form the key field, it is frequently called a split key.

===Key file===

===Master file===
The master file is the data file for which the index is created. It contains a large number of unordered records that must be accessed quickly by a program.

===Multiple Index Files===
A master file can have more than one index file, each with a different key field. Using multiple index files allows you to access the master records using different key fields at different times.

===Primary and Overflow Areas===
Business Rules always searches for a key field first in the primary area and then, if needed, in the overflow area.

===Relative Record Number===
The index file generally consists of two parts: a primary (or sorted) area and an overflow (or unsorted) area. A relative record number is the numeric position of a record in the master file. The first record in a master file has a relative record number of 1; the 20th record has a relative record number of 20. This number is stored in an index file along with the key field.

===Split Key===

===BADKEYS===

==BTree Facility==
The BTREE_VERIFY statement is now operational.  Note that the keyword previously was BTREE2VERIFY.

To activate the BTREE2 facility, specify OPTION 22 in the `BRConfig.sys` file.  For more details, see New Btree Facility under 3.90 Initial Changes below.

==Techniques for using multiple index files==
Several key files may be opened and automatically maintained with each master file. The total number of key files is limited only by the operating system limit for the total number of open files.

The use of multiple index files allows processing records in a master file by different key fields, such as customer number, last name, zip code, date, etc. If it is not possible or convenient to locate a record by one key, the same program can try to retrieve it by another key.

Each index file requires a separate OPEN statement. When two or more OPEN statements specify the same master file for KEYED access, Business Rules automatically links each index file together so that when a record is added, deleted, or changed in the master file, every file in the group of index files is updated simultaneously. If there are any other index files that are not open in programs that could change the master file, you should run INDEX on them occasionally. At a minimum, you should update all index files every time you back up the master file. You also must replace (not reorganize with REORG) all index files after you copy the master file and remove deleted records (see the `COPY` command).

To run Business Rules programs on a multi-user system, OPEN statements should include a share parameter to specify what is to occur when a program at another workstation attempts to read or write to the same file. A share parameter is required (at least for the first OPEN statement) when several key files "share" the same master file. NOSHR may be used to exclude other workstations, but still share a master file with a group of index files at the same workstation. For a complete description of the four share parameters, see `Share Specs` in the Definitions section; see also `Multi-User Programming`.

Lines 2100 to 2400 will open four key files for a file named FILE:

 02100 OPEN #1: "name=FILE,kfname=KEY1,shr", INTERNAL,OUTIN,KEYED
 02200 OPEN #2: "name=FILE,kfname=KEY2", INTERNAL,OUTIN,KEYED
 02300 OPEN #3: "name=FILE,kfname=KEY3", INTERNAL,OUTIN,KEYED
 02400 OPEN #4: "name=FILE,kfname=KEY4", INTERNAL,OUTIN,KEYED

In the group of related OPEN statements in lines 2100 to 2400, adding a record to the master file with a WRITE #1 statement adds a record not only to KEY1, but also adds a record to KEY2, KEY3 and KEY4 because these four key files are linked and because output is enabled by specifying OUTIN for all four. Similarly, rewriting a record with a REWRITE #3 statement updates records in KEY1, KEY2, KEY3 and KEY4 if the value in the key fields is changed.

===Open Statements===
For each index file, there must be a separate `OPEN` statement.

;The rules for setting up multiple index files are:
:1.) The master file name (specified after NAME=) must be the same for all OPEN statements.
:2.) All files must have different file numbers (selecting consecutive numbers is recommended, but not required).
:3.) All share parameters must be consistent with the share parameter from the first OPEN statement encountered.

The best and easiest way to achieve this is to omit share parameters after the first OPEN statement; in this case, Business Rules uses the share parameter from the first keyed OPEN statement for all subsequent keyed OPEN statements using the same master file. Share parameters may be coded explicitly after the first OPEN statement, but some combinations of share parameters across OPEN statements may cause error code `4148` at execution time (see the table of OPEN file restrictions in `Multi-User Programming` for more information). For example, line 290 will generate error code 4148 because the SHRI parameter in line 280 conflicts with the SHR parameter in line 290.

 00280 OPEN #1: "name=FILE,kfname=KEY1,shri", INTERNAL,OUTIN,KEYED
 00290 OPEN #2: "name=FILE,kfname=KEY2,shr", INTERNAL,OUTIN,KEYED

:4.) The entire group of files may be opened NOSHR. This means no other workstation can access the master file or key files, but the master file is shared among the key files at this workstation. If NOSHR is desired for the group of files, you must code NOSHR on the first OPEN statement, then you must omit the share parameter for subsequent OPEN statements. For example,

 00040 OPEN #1:"name=FILE,kfname=KEY1,NOSHR", INTERNAL,OUTIN,KEYED
 00050 OPEN #2:"name=FILE,kfname=KEY2", INTERNAL,OUTIN,KEYED

:5.) The group of OPEN statements for keyed processing with a single master file can mix INPUT, OUTIN or OUTPUT processing with one exception. The first OPEN must be OUTPUT or OUTIN if subsequent OPEN statements use OUTPUT or OUTIN. Error code `0608` occurs when a conflicting secondary OPEN statement is executed. Keys are only updated for files opened OUTPUT or OUTIN. This feature can save system overhead on files opened with INPUT, but should be used with caution because this method can lead to index files that do not match the recently changed master file. If you use this method, index files that are not updated should be replaced (not used with REORG) as soon as possible.

In the example in lines 1100 to 1400, KEY1 and KEY2 will be automatically updated because they are opened OUTIN, but KEY3 and KEY4 will not be changed in this program.

 01100 OPEN #1: "name=FILE,kfname=KEY1,shr", INTERNAL,OUTIN,KEYED
 01200 OPEN #2: "name=FILE,kfname=KEY2", INTERNAL,OUTIN,KEYED
 01300 OPEN #3: "name=FILE,kfname=KEY3", INTERNAL,INPUT,KEYED
 01400 OPEN #4: "name=FILE,kfname=KEY4", INTERNAL,INPUT,KEYED

REWRITE #1 could change all four key fields in the master file, but KEY3 and KEY4 will not be updated because they are only opened for input.

:6.) New index files can be created at any time with the Index command. New index files can also be created with the OPEN statement, but only when creating a new (and empty) master file. To create a new master file and multiple new key files, you must code these four parameters: NEW (or USE or REPLACE), RECL=, KPS= and KLN= on all OPEN statements. For example:

 05100 OPEN #1:"name=MASTER,new,recl=31,kfname=KEY1,KPS=1,KLN=4,shr",INTERNAL,OUTIN,KEYED
 00520 OPEN #2: "name=MASTER,new,recl=31,kfname=KEY2,KPS=9,KLN=5,shr",INTERNAL,OUTIN,KEYED

Business Rules will remember when line 5200 is executed that the file was just created. It will create the new index file, and it will link file numbers 1 and 2 for multiple key processing.

====Limit on Number of Open Files====
The number of key files that can be opened in Business Rules is restricted by the operating system maximum of open files for any single program.

Each unique master file, index file or procedure file counts as one file against this open file limit. However, opening the same file under two or more different file numbers counts only once. Also, opened window files do not count against the operating system limit on open files.

====File Processing====
Rules for file processing with multiple key files are the same as rules for file processing with only one key file. Also, all aspects of file sharing, record locking and file name locking apply unchanged to multiple key files. The major addition is the use of different file numbers to provide access by different key fields.

READ, WRITE, REWRITE, RESTORE and DELETE statements for a given file number use the key file specified in the OPEN statement for that file. When WRITE or DELETE statements make changes to any one of the group of key fields, corresponding changes are also made in all key files if they are opened OUTIN or OUTPUT. To improve performance speed, before updating any index files, REWRITE statements first compare the changed record to a memory-resident copy of the original record so that no index file changes are made when no key fields are rewritten.

If a program opened four different key files under four different file numbers, then KEY=, KEY>=, SEARCH= and SEARCH>= could be used with any of the file numbers by following the same rules used with only one key file.

There is a file pointer to keep track of the position in each index file; thus, reading sequentially by key is simply a matter of opening the file for keyed access, then using READ statements without any KEY or SEARCH parameter. By switching between READ statements with different the file numbers, a program could read sequentially by one key, then sequentially by a second key from a second key file, then come back to the first key file and pick up where the pointer was before the switch.

The `KPS`(n) and `KLN`(n) functions return key starting position and key length for the key file given in the OPEN statement for file n.

====Technique for Using Split Key Fields====

It is not necessary for all characters in a key field to be next to each other (sometimes called adjacent or contiguous). A key field may be split into as many as six fields with a maximum combined length of 128 bytes. When split keys with up to six sections are combined with multiple index files for a single master file, the indexing capabilities are quite powerful and flexible.

For details of how to create an index file with split keys see the `Index` command or see the `OPEN internal` statement.

Also, to retrieve information about the individual sections of a key field, see the `KPS` and `KLN` functions.

To improve execution speed on sorted reports, some programmers have chosen to add another index file with a split key. For example, if a report is supposed to be sorted on three fields, you could maintain an index file with a split key consisting of those three fields in the desired order. When a report needs to be quickly generated on demand, a program can generate it immediately by reading sequentially by key using this existing index file. A general rule is that when you are frequently generating reports on small sections of the file, use indexing. When you are generating infrequent reports on major portions of files, sorting is more efficient.

==Baseyear dependent indexes==

INDEX key position or key length values may now specify a trailing "Y" character to indicate that the first two digits of the field are BASEYEAR dependent. For example:

 INDEX masterfile   keyfile   10/23Y/55   8/6/30   REPLACE   DUPKEYS

Indicates that a date field begins in position 23 with A TWO DIGIT YEAR that is BASEYEAR dependent.

If the position or length of a numerical (BH or PD) field is followed by Y, then it should also specify a B or P to indicate the storage format.  In this case it will be processed as a number with baseyear applied in accordance with the length as follows:

{| border="1" cellpadding="2"
|FIELD TYPE & LENGTH**||ASSUMED DATA FORMAT**
|-
|PD 1||Not Significant
|-
|PD 2 or BH 1||YY
|-
|PD 3 or BH 2||YYMM
|-
|PD 4, BH 3, BH 4, DT 3,||
|-
|DT 4, DL 4 or DH 4||YYMMDD
|}

Note that the specification for PD is P and the specification for BH is B in the INDEX statement, for example:

 INDEX masterfile keyfile 10/31  2BY/10 REPLACE

This creates 'keyfile' applying BASEYEAR to the first two digits of each key.  In this example, the first part of the key is assumed to be binary in YYMM format.
