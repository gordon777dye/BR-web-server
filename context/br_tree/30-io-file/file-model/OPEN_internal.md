---
title: OPEN_internal
file: OPEN_internal.md
category: 30-io-file
subcategory: 30-io-file/file-model
kind: statement
related: [statement, SHR, 0608, 4125, Functions, STATUS, Commands, OPTION, BRConfig.sys, 0606]
---
The **Open (OPE) Internal** `statement` activates a Business Rules! internal file for input/output.

 00150   Open #1: "Name=test.int,RecL=128,Use",internal,outin

:1.) When a file is opened for both `SHR` and INPUT, Business Rules will no longer change the time and date of the file. As a result of this change, when a file is to be opened both for OUTIN and for INPUT, the OPEN for OUTIN must be executed first. Otherwise an error `0608` will result. This will affect current programs.
:2.) The NOCLOSE parameter in any OPEN statement will leave that file open when a program ends or chains to another program. The only way this file is closed is by explicitly closing the file, CLEAR ALL, or by exiting from Business Rules!.

 00100 OPEN #1:"NAME=TEST,NOCLOSE",INTERNAL,INPUT,RELATIVE

:3.) The OPEN internal statement now allows for the VERSION= parameter. If a VERSION= number (0 to 32000) is specified and a file is being newly created, that version number will be saved in the header portion of the data file. Key files are not affected. If the file exists, the version number specified will be compared with the version number in the file and an error `4125` will result if they are not the same. The default version number is 0, which also causes no checking to be performed. If the version number of an opened file is non-zero, it can be displayed by the STATUS FILES command. For more information and examples, see "VERSION" in the `Functions` section and `STATUS` FILES in the `Commands` section.
:4.) OPEN internal now assumes a B-tree indexed file unless OPTION 5 is used in the BRConfig.sys file to set the universal default to ISAM or the ISAM parameter is used within the syntax of the OPEN statement to override the B-tree default on an individual basis. (If `OPTION` 5 is specified in `BRConfig.sys`, the OPEN statement's BTREE parameter can be used to override the ISAM default on an individual basis.) OPEN internal now allows the BTREE or ISAM parameters, as follows:

 00100 OPEN "NAME=filename,kfname=indexname,kps=...,ISAM"...
 00100 OPEN "NAME=filename,kfname=indexname,kps=...,BTREE".. .

:5.) OPEN internal now accepts the LINKED keyword, which specifies that the file to be opened is linked. OPEN internal's existing KPS= and KLN= parameters may be optionally used with LINKED files to identify a key field. This key field can then be used by the READ statement's LINK= parameter to Verify file integrity for each read. Error `0606` (Invalid element in OPEN) will result if the program attempts to use the first eight bytes of the record as the key field.

The following example creates the linked file LINKFILE, and identifies record positions 9 through 12 as the key field for verification:

 00010 OPEN#1:"NAME=LINKFILE,NEW,RECL=63,LINKED,KPS=9/23,KLN=4/6",INTERNAL,OUTIN,REL

:6.) The WAIT specification in the OPEN statement for all physical files will now also be used as the number of seconds to wait before re-attempting to open a file that another workstation has locked. Previously it affected the wait time on locked records only. Error code `4146` will be returned if the OPEN fails due to file locking.

===Temporary Indexes===
TMPIDX is a new parameter in the OPEN string. This specifies that the index should be created when the file is opened and removed when the file is closed.

===Comments and Examples===
An OPEN statement must be executed for a particular file before any I/O statement can act on that file.

This section discusses opening internal files, which are one of three major file types in Business Rules (the other two file types are display and external).

Internal files can be opened for INPUT, OUTPUT, or OUTIN; OUTIN allows both input and output at the same time. Whereas display files are restricted to sequential processing, internal files can be accessed as SEQUENTIAL (in chronological order), RELATIVE (according to record position) or KEYED (according to keyed position). Internal files can be used for sorting and indexing; display and external files cannot.

Internal files utilize six I/O statements: READ, REREAD, WRITE, and REWRITE, DELETE and RESTORE. Unlike display files, internal files support special numeric formats (such as packed decimal) and have a fixed record length. A header record, which is transparent to the user, keeps track of the record length, number of the last record used, etc.

Before reading input from an existing internal file called STATES, a program must have a statement such as the following:

 00500 OPEN #2: "name=STATES", INTERNAL, INPUT ,SEQUENTIAL

After line 500 is executed, the internal file STATES can be used for input using the file number, #2.

The following statement would create a new internal file called ZIPCODES and define a record length of 31 bytes:

 00510 OPEN #3: "NAME=zipcodes,NEW,recl=31", INTERNAL,OUTPUT, RELATIVE

A string constant, string variable, or string expression can be used for the OPEN statement clause which indicates what file is to be opened. Consider the following examples.

 01000 OPEN #1: "NAME=CUSTOMER.DAT", INTERNAL,INPUT
 01005 PRINT "Enter FILE for balances"
 01010 INPUT F$
 01015 LET F$ = "NAME=" & F$ & ".DAT"
 01020 OPEN #2: F$, INTERNAL, INPUT, SEQUENTIAL
 01030 OPEN #3: "NAME=SALES"&STR$(MONTH)&" .DAT",INTERNAL,INPUT,RELATIVE

Line 1000 shows OPEN using a string constant. Lines 1005 to 1020 show opening a file with a name constructed from a prompted keyboard entry. Line 1030 will open the file SALES10.DAT if the value of MONTH is 10.

The KPS= and KLN= parameters (denoted by the "key-spec" parameter in the diagram) can be used to create an index file at the same time that a master file is being created. The following example shows how a single key can be a combination of three sections of the record (up to six sections may be defined). KPS specifies the starting position of each key section and KLN specifies the length of each section (the first section starts in column 1 and is 4 bytes in length; the second starts in column 10 and is 2 bytes in length; the third starts in column 20 and is 2 bytes in length).

 00100 OPEN #9: "NAME=history,REPLACE,RECL=80,KFNAME=hist.key,KPS=1/10/20,KLN=4/2 /2",INTERNAL,OUTPUT,KEYED

===Syntax===
 OPEN #<`file number`> : {"NAME=<`file ref`>[, {`NEW`|`USE`|`REPLACE`}] [, `RECL`=<integer>] [, `KFNAME`=<`file ref`>] [, <`key spec`>] [, <`share spec`>] [, `RESERVE`] [, `Version|VERSION=`] [, `WAIT`=<integer>] [, `TRANSLATE`=<`file ref`>]"|<`string expression`>}, `INTERNAL`, {`Input Parameter|INPUT`|`OUTPUT`|`OUTIN`} [, {`SEQUENTIAL`|`RELATIVE`|`KEYED`}] [<`error condition`> <`line ref`>][,...]

`Image:Openinternal.png|900px`

===Defaults===
:1.) Use the existing file.
:2.) The file is not keyed.
:3.) Do not create a new-keyed file.
:4.) NOSHR.
:5.) Do not lock the file.
:6.) Wait 15 seconds.
:7.) No translation.
:8.) SEQUENTIAL.
:9.) Interrupt the program if an error occurs and ON is not active.

===Parameters===
The required "file number" parameter is a numeric expression that must equal 255 or an integer from 1 to 999, inclusive. Two special default values for "file number" are provided to facilitate I/O from the keyboard and to the printer and screen. These special defaults are: #0 (reserved to resize the main BR window), and #255 (reserved for printer, equivalent to DOS PRN:). No OPEN is necessary for these two reserved values.

From this point, there are two possible paths through the OPEN internal syntax. The top path will be described first.

"NAME=file-ref" is a required parameter which specifies the file or device to be opened. This parameter can be a string constant, string variable, or string expression. See `File Ref` for more information about its syntax. Using `Name=save` will allow the user to select a file location and name to save under. And using `Name=open` will allow the user to select a file to open from the standard Windows open file location window. 

The **NEW** parameter indicates that the file to be opened must also be newly created. Error `4150` (duplicate file name) will occur if NEW is specified and the file already exists.

The **USE** parameter indicates that an existing file by the specified name should be opened, but a file by the specified name may not exist, in which case Business Rules will create a new file for it; so the OPEN statement needs to have the specifications for creating it.

The **REPLACE** parameter indicates that any existing file under the specified name should be freed and that a new file under that same name be created. There will be no warning that the file is being replaced when this parameter is used. See the `File I/O` chapter for more information about the NEW, USE and REPLACE parameters.

"RECL = integer" is an optional parameter used to specify the record length. This parameter must be used with new files, but is never used with existing files since the system stores the record length for internal files in the header record.

The "KFNAME = file-ref" parameter specifies the name of an index file. It is required when a file is being opened for KEYED processing.

The "key-spec" parameter represents an insertable syntax that indicates the starting positions and lengths of up to six different key sections in a record. See details below. 

Three options are available for the "share spec" parameter: NOSHR, SHR and SHRI. NOSHR indicates that the current workstation is to have exclusive access to the file. No other opens are permitted to the same file until it has been closed. NOSHR is the default when a "share spec" is not specified. SHRI allows others to use the file for input only. Others may read that but not change a file opened SHRI. SHR allows others to read, write and update an open file. An individual record within this file may be locked during use when either OUTPUT or OUTIN is also specified and when the I/O statement utilizes the RESERVE parameter (RESERVE is the default, so explicit coding is not necessary).

"RESERVE" locks the file until otherwise specified; other users are denied access even when the file is not open. A reserved file is not released until a CLOSE statement with the RELEASE parameter has been specified or until a PROTECT file-ref, RELEASE command has been issued (this last command is ignored by the IBM PC-NetWork operating system). Exiting Business Rules also releases all files locked by that workstation.

The "WAIT= int" parameter specifies the number of seconds that Business Rules should wait for a locked record before generating error code `0061`. 

The "TRANSLATE=file-ref" parameter indicates that character translation is required for all input or output of C, V, G, N, ZD or PIC strings. The file-ref must identify either a 256- or 512-byte file. The first 256 bytes are used as an input translation table. See `Translate` for more information.

The above parameters (excluding the #filenum parameter) make up the file identification string. They must all be enclosed within a single set of quotation marks. If you wish to define this information elsewhere in the program, Business Rules will accept the "string- expr" (See the bottom path of the syntax diagram) parameter in their place. The following parameter descriptions apply to all forms of the OPEN display statement, no matter which syntax path is selected.

The "INTERNAL" keyword is required; it identifies the file as an internal file.

"INPUT" indicates that information in the file will be input into the program. "OUTPUT" indicates that information from the program will be output to the file. OUTIN indicates that information will be both input into the program and output to the file. One of these three keywords is required.

The keywords "SEQUENTIAL", "RELATIVE", and "KEYED" are optional parameters that specify the method of access. The default is SEQUENTIAL access.

The OPEN internal statement provides for error processing with the optional "error-cond line-ref" parameter. See `Error Conditions` for more information.

===Technical Considerations===
:1.) Relevant error conditions are: `ERROR`, `EXIT`, `IOERR` and `LOCKED`.
:2.) Blanks are not allowed before the equal sign in any of the OPEN parameters.
:3.) Although most Business Rules statements are syntactically checked as they are entered, syntax checking is delayed until execution time on some parts of the OPEN statement (parts where quoted strings or string variables can be used). Also, the distinction between uppercase and lowercase is ignored in OPEN statements; the "NAME=file-ref" parameter is no exception.
:4.) When an internal file is opened for INPUT or OUTIN the sequential pointer is positioned at the beginning of the file.
:5.) When an internal file is opened for OUTPUT, the sequential file pointer is positioned at the end of the file, so that new records will be added at the end of existing records. The REPLACE parameter can be used to override this. All existing records in the file are dropped when REPLACE is used.
:6.) Business Rules utilizes the operating system's ability to automatically allocate more space to a file (until the disk is full) when more space is needed.
:7.) Variables can be used for "file number" and "file-ref".
:8.) The system always adds 1 byte (for deleted records) to the record length that you specify. As the hardware often reads in blocks of 512 bytes, efficient or "nice" values of RECL are based on being evenly divisible into 512. Good choices for RECL are of the form 2**N-1, e.g., 7, 15, 31, 63, 127, 255, 511, 1023.
:9.) See `Functions` for more information about the FILENUM and FILE$ functions. These functions should be especially useful for displaying messages after an OPEN error due to file-sharing conflicts with another workstation. See also the `STATUS` FILES command, which displays information about file opens and file reservations.
:10.) The number of open files allowed by the operating system dictates the number of OPEN statements allowed in a Business Rules program.
:11.) When opening files for input BR will now open them read only.  THIS ALLOWS FILES WITH READ ONLY PERMISSIONS TO BE OPENED.
:12.) Version 3.9 will support long filenames with a variety of alternatives with respect to case sensitivity.   Unix defaults to case sensitive, and DOS/Windows defaults to case insensitive.   Business Rules! defaults to lower case on all platforms, unless overridden by a FILENAMES configuration statement.
:13.) Opening files for INPUT will now open them read only.  THIS ALLOWS FILES WITH READ ONLY PERMISSIONS TO BE OPENED. A consequence of this is the undetectability of multiple opens input NOSHR.  However, this poses no jeopardy to data.  Any open requesting write permissions will not be allowed while the file is opened input NOSHR, and no input NOSHR will be allowed while the file is opened for writing, but two opens input NOSHR may be allowed on the same file at the same time. Under some circumstances, two attempts to open a file input NOSHR will fail and sometimes they won't.  This is dependent on the operating system and what files are already opened.  But, while restrictions have been loosened, they require no changes to your applications to assure data integrity.

===Supplemental Syntax ("key-spec" parameter)===

===Supplemental "File Ref" Parameter===

===Supplemental Syntax ("Share-spec" Parameter)===
