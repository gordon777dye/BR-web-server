---
title: INDEX
file: INDEX.md
category: 30-io-file
subcategory: 30-io-file/keys-indexes
kind: statement
related: [command, Index Facility, index file, DUPKEYS, REORG, LISTDUPKEYS, procedure files, CLEAR, EXECUTE, BaseYear]
---
The **Index** `command` creates or recreates an index file. See the `Index Facility` for additional information. You may also find it useful to familiarize yourself with the concept of a [https://en.wikipedia.org/wiki/Index_(database) Database Index]

For a simple tutorial, see `Index_and_Sort_facilities_Tutorial|Index Tutorial`.

==Syntax==
 INDEX <data file> <`index file`> <key start position>[/...] <key length>[/...] [-<work path>] [{`DUPKEYS`|NATIVE|`REORG`|REPLACE|`LISTDUPKEYS`[>[>]<output file>]}][...] [-N] 

`Image:Index.png|1000px`

==Comments and Examples==
Index works both in `procedure files` and as a separate `:Category:Commands|command`. It performs a `CLEAR` operation, except when a program is active, and creates or recreates the index file as specified.

The following command replaces INDEX.FIL, if it already exists, with a new index file for the master file MASTER.FIL. The key is a field that starts at position 10 and consists of 5 characters:

 INDEX MASTER.FIL INDEX.FIL 10 5 REPLACE

The next command creates a new index file HIST.KEY for the master file HISTORY. The first key is a field that starts at position 1 and consists of 4 characters. The second key starts at position 10 and has 2 characters, and the third field starts at position 20 and has 2 characters:

 INDEX HISTORY HIST.KEY 1/10/20 4/2/2

In the following example, INDEX reorganizes the existing CUST.KEY index file. However, if CUST.KEY does not exist, a new index file by the same name is built. The REORG parameter greatly speeds up the INDEX command because it takes advantage of the part of the key file that is already in sorted order. The first key field starts at position 1 and consists of 6 characters. The second key field starts at position 4 and consists of 3 characters. **Note** that the key fields overlap.

 	INDEX CUSTOMER CUST.KEY 1/4 6/3 REORG

The next example builds a new index file called PAY.KEY for the PAYROLL master file. The key field starts at position 1 and consists of 6 characters. This command allows duplicate keys, and it sends a listing of duplicate keys to the file DUP. No warning error will occur if duplicate keys are encountered. **Note** that the parameters in this Index command are separated by commas rather than by spaces:

 INDEX PAYROLL,PAY.KEY,1,6,DUPKEYS,LISTDUPKEYS >DUP

Also note that the creation of indexes can be interrupted with Ctrl-A, and can then be resumed with GO.

==Defaults==
# Use space on the current default drive and directory as temporary work space.
# Display a record of duplicate keys on the screen.
# Send an error if duplicate keys are found; use the collating sequence specified in the BRConfig.sys file (or by the most recent CONFIG command); completely build (or rebuild) the specified index; send an error message and abort the index procedure if the specified index file already exists.

==Parameters==
The **data file name** parameter specifies the name of the data file for the index you wish to create.

**Index file name** specifies the name of the index file for the desired index.

**1st key start position** and **next key start position** specify the starting record positions of each key field. Up to **six** starting positions may be specified.

**1st key length** and **next key length** parameters indicate the number of characters contained in each key field. Each **key length** specification must correlate to a **key starting position** specification. The specifications match up according to ordinal position. The first key starting pos correlates to the first key length specification.

The indexing process requires availability of a temporary work space. The optional **work path** parameter specifies a location somewhere other than the default drive and directory for this work space.

If you decide to allow duplicate keys in the index, you can use **DUPKEYS** to prevent the corresponding error message 7603 from appearing on the screen.

As the index is being created, **LISTDUPKEYS** lists all duplicate keys on the screen.

**>Redirected output File** saves LISTDUPKEYS information that would normally be displayed on the screen to a text file.
**>>Redirected output File** appends LISTDUPKEYS information to an existing text file.
Programs can use input from this file to report on or delete the duplicate keys.

**NATIVE** causes the Index command to use native collating sequence. This parameter should be used when the following two conditions are true: an index is being performed on a packed decimal field, and COLLATE ALTERNATE has been specified for the rest of the program.

**REORG** can be used to reorganize index files directly, without reading the master file. This can greatly speed up the re-indexing process, especially on network systems, because the already sorted portion of the index file will not be sorted again. If the index file has already been fully sorted, BR will read only the header record and then quit the re-indexing process immediately.

It is important to note that the REORG parameter will generally not cause new records to be added to the index file. It is the responsibility of the programmer to be sure that index file's overflow area is updated with added records before REORG performs its operation. This can be done by always opening the index file when writing to the master file.

There are three cases in which INDEX with the REORG parameter will completely build an index file:
# When the index file does not exist.
# When the specified file is not an index file.
# When any of the key starting pos or key length parameters stored in the header record are different from those specified in the INDEX REORG command.

**REPLACE** specifies that the current index should replace an index of the same name if it exists on the disk. BR expects to create a new file when this parameter is not specified.

The **-N** option suppresses all information that would normally be output (except LISTDUPKEYS information).

==BADKEYS==

==Special Considerations==

The Index command may be executed in a program as part of the `EXECUTE` statement. If a program is active, this method of running the INDEX command does not CLEAR memory.

*When the starting key position and key length parameters are both specified as 0, INDEX will now use the key parameters as they exist in the key file.* The REPLACE parameter is assumed. 

The INDEX command may now include a SHR parameter. This allows another workstation to access the master file while indexing. For example:

 INDEX master.fil index.fil 1 4 REPLACE SHR

**Note** that SHR should be used only for making temporary indexes because master files normally should not be modified when rebuilding indexes. When INDEX is used with the SHR parameter, all records in the master file can be accessed by the INDEX command, even if a record is locked by another user. 

For *case insensitive key file access* place a U after the key length or key starting position parameters. This causes the program to keep that key field as uppercase. Whenever a record is written, the key field is converted to uppercase before it is written to the key file (master record is unchanged) and whenever the file is read with KEY=, the parts of the key that need to be converted to uppercase are converted before the key look up.

This is useful for looking up names, where the capitalization of the data on file and the key entered by the operator may be inconsistent. This also permits sequential processing of a keyed file in alpha order without regard to the case of the data. **Note** that even though BR stores the key as uppercase, the resulting processing occurs as if the case is ignored. In other words, 'A' and 'a' are considered equal.

The following code writes data as is to the master file, but writes all uppercase characters to the key file.

 00010 OPEN #1:"name=XXX,kfname=XXX.key,replace,recl=63,kps=1,kln=4u",INTERNAL,OUTIN,KEYED
 00020 WRITE #1,USING 30: "aaAA"
 00030 FORM C 4
 00040 READ #1,USING 30,KEY="AAaa": X$
 00050 PRINT X$

 INDEX MASTER.FIL KEY.FIL 1/3 2/2U REPLACE

If a key field is a two digit year it should be flagged as such so BR will use `BaseYear` when comparing values for sorting purposes. Place the letter Y after either the field position or its length. 

 INDEX MASTER.FIL KEY.FIL 1/3 2/2Y REPLACE

If a two digit year is stored in binary or packed decimal form, the INDEX command needs to indicate that by following the Y with either P or D as in:

 INDEX MASTER.FIL KEY.FIL 1/3 2/2YB REPLACE

The INDEX command defaults to B-tree indexing unless OPTION 5 is used in the BRConfig.sys file to set the universal default to ISAM or the ISAM parameter is used within the syntax of the INDEX command to override the B-tree default on an individual basis. If OPTION 5 is specified in BRConfig.sys, the INDEX command's BTREE parameter can be used to override the ISAM default on an individual basis.

;INDEX will completely rebuild the `B-tree` index when any of the following three conditions is true:
:1) When the REPLACE parameter is specified in the INDEX command,
:2) When INDEX REORG is specified and the key starting positions and/or lengths in the existing index file are different than those specified on the INDEX command, or
:3) When INDEX REORG is specified and the key file does not exist.

The syntax of the INDEX command allows the BTREE or ISAM parameters, as follows:

 INDEX file.dat,file.idx,1,2,REPLACE,ISAM
 INDEX file.dat,file.idx,1,2,REPLACE,BTREE
