---
title: FnSnap__FILE
file: FnSnap__FILE.md
category: 50-libraries
subcategory: 50-libraries/fnsnap
kind: function
related: [Sort facility]
---
==File Management==
===FNBLDSORT - build a sort control file and execute the sort===

**FnBldSort** creates a sort control file with FILE RECORD and MASK statements.  The sort is then executed creating the sorted file in either PD 3, BH 4 or Record out format.  The sort control file is then deleted.  The user's local TEMP directory is used for the work space but the files in and out files can be located anywhere either as relative or absolute paths.

 FNBLDSORT(File_Name_Source$,OUTNM$,ABR$,MASK$,MAT RECORD$,INDIR$,INDRV$,OUTDIR$,OUTDRV$)

====Functions used====

None

====Variables====
{|
|-valign="top"
|width="10%"|**File_Name_Source$ **||File name that is being sorted.  The file name can contain the path either relative (without a drive letter) or absolute (with a drive letter).  If no path is included FNBLDSORT will look in the current directory for the file.
|-valign="top"
|width="10%"|**OUTNM$ **||File name that is to be created by the sort routine.  The file name can include a path just as it could with the File_Name_Source$.
|-valign="top"
|width="10%"|**ABR$ **||Type of output file to be created A=Address using the PD 3 format B=Address using the BH4 formatR=Record out sort.
|-valign="top"
|width="10%"|**MASK$ **||The file mask that should be used to designate what positions and format the sort should use in creating the sort.  The mask statement should NOT include the word MASK, but the remainder of the mask should follow the parameters detailed in `Sort facility`.  These include multiple sort positions and types in the start position, field length, field format and ascending or descending as in "11,5,C,A" or "11,5,C,A,21,5,PD D".  Only one MASK statement is allowed, but the statement may include multiple parameter sets.
|-valign="top"
|}

The following elements are optional and can be omitted from the function call.

{|
|-valign="top"
|width="10%"|**MAT RECORD$ **||Multiple RECORD statements can be used and can contain a mix of INCLUDE and OMIT statements.  Each Include or Omit statement must be in a separate element of the RECORD$ array and NOT include the word RECORD. A statement may look something like the following:
|-valign="top"
|}
 01000 DIM RECORD$(0)*100
 01010 MAT RECORD$(1) !:RECORD$(1)='O,49,1,C," "," "'
 01010 MAT RECORD$(2) !:RECORD$(2)='I,23,5,C,"aaaaa","zzzzz"'
{|
|-valign="top"
|width="10%"|** **||Notice the use of single quotes and double quotes to avoid the necessity of using multiple double quote mars in order to get quotes included in the RECORD$ array elements.
|-valign="top"
|width="10%"|**INDIR$ **||This parameter is included for compatibility with the sort utility.  The parameter should be left blank (not, included in the function call).
|-valign="top"
|width="10%"|**INDRV$ **||This parameter is included for compatibility with the sort utility.  The parameter should be left blank (not, included in the function call).
|-valign="top"
|width="10%"|**OUTDIR$ **||This parameter is included for compatibility with the sort utility.  The parameter should be left blank (not, included in the function call).
|-valign="top"
|width="10%"|**OUTDRV$ **||This parameter is included for compatibility with the sort utility.  The parameter should be left blank (not, included in the function call).
|-valign="top"
|}

====Comments====

 A very useful function where sorts are used.  PArticularly helpful in eliminating the procedure files common in older program.  Using this function chain to procedure files to create and execute sorts can be included in the primary program much as FNINDEX is used.

===FNFIL - create a file number that will increment by 1 each time a batch is created===

Create a file number and batch number for a file that will increment by 1 each time a new batch is created. Used to create sequential file names such as transmittal files to banks or taxing authorities where it important to maintain a record of what has been sent and make sure that an existing transmittal file is not overwritten.

Returns an available file number to be used in creating a file and the sequence number to be used in opening the file.

 FNFIL(FILLOC$*100,FILNM$,&FILBATCH;SUFX$)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**FILLOC$ **||Location either relative of specific of the path into which the file should be placed.  The path should end with a "\\".  If one is not present one will be added to the path.
|-valign="top"
|width="10%"|**FILNM$ **||The first few letters of the file name to be used.  generally this is tow to three letters to identify the specific reason for the file
|-valign="top"
|width="10%"|**&FILBATCH **||
|-valign="top"
|width="10%"|**SUFX$ **||
|-valign="top"
|}
<br>
;Comments:<br>
An example might be
 01010 let x=fnfil("E:\\wb\\efile\\","MAW",fseq,"txt")
 01020 open #x:"name=E:\\wb\\efile\\MAW"&cnvrt$("PIC(#####)",fseq)&".txt,recl=3200,replace",display,output

===FNFILENAME$*80 - Provide a file name===

 FNFILENAME$*80(;NAME$*80)

Description|

;Functions used:<br>
FNOK<br>
FNWIN<br>
FNCLSWIN

;Variables:
{|
|-valign="top"
|width="10%"|**NAME$ **||An optional name to display for a file
|-valign="top"
|}
<br>
;Comments:<br>
An older version of FNGETFILE$ and FNPUTFILE$

===FNFILEOK - Check version number===

Checks version number and file length and returns the file version number.  FNFILEOK returns a variable indicating file status

 FNFILEOK(NUMBER,NAME$,LENGTH,FILE_VERSION;&OLD_VERSION)

Returned values for FNFILEOK
{|
|-valign="top"
|width="10%"|**1**||New file was created
|-valign="top"
|width="10%"|**2**||Record length was adjusted, but file versions match
|-valign="top"
|width="10%"|**3**||File versions do not match. The existing version is higher than FILE_VERSION
|-valign="top"
|width="10%"|**4**||File versions do not match. The existing version is lower than FILE_VERSION
|-valign="top"
|}
<br>
;Functions used:<br>
FNSIZE (part of FNSNAP.dll)

;Variables:
{|
|-valign="top"
|width="10%"|**NUMBER**||file number being processed
|-valign="top"
|width="10%"|**NAME$**||name of file being processed
|-valign="top"
|width="10%"|**LENGTH**||record length the file SHOULD be
|-valign="top"
|width="10%"|**FILE_VERSION**||current file version
|-valign="top"
|width="10%"|**OLD_VERSION**||file version of existing file
|-valign="top"
|}
<br>
;Comments:<br>
If the LENGTH is greater than the length of the old file the file will be expanded to the new file size.  If the actual file is greater than the requested length the record length will NOT be changed.

The function returns a value depending on what is found

===FNFILESIZE - count number of records in a file===

Returns the number of records in a named file - unnecessary, use LREC

 FNFILESIZE(FILENAME$*66)

Returns the number of records in a named file

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**FILENAME$**||NAme of file to be analyzed
|-valign="top"
|}
<br>
;Comments:<br>
This is an unnecessary function because BR returns an LREC for any open file which is the number of records in the file.  However, because the function works on a file that has NOT been opened you may find it helpful

===FNGETFILE$ - Return the name and path of an existing file===

Returns the path and name of a file that has been picked using FILEDIALOG.exe

[PICT(PICS\SNAP0010.ptf)]

 FNGETFILE(LOOKIN$,LOOKFOR$)

;Functions used:<br>
None

;Variables:
{|
|-valign="top"
|width="10%"|**LOOKIN$**||Name of the path for which to display the selection API dialog window.
|-valign="top"
|width="10%"|**LOOKFOR$**||The type of file to be included in the file look up.
|-valign="top"
|}
<br>
;Comments:

This is a BR access to the Windows API call for retrieving any file from the disk drive.

===FNGETFILENAME$*80 - Create a file name from a seed===

 FNGETFILENAME$*80(SEED$;D)

Description|<br>
Displays a window and request a file name. Optionally a suggested name can be displayed.

;Functions used:<br>
None

;Variables:
{|
|-valign="top"
|width="10%"|**SEED$**||Portion of a file name.  The suggested returned file name such as AP
|-valign="top"
|width="10%"|**D**||Flag to indicate that the seed name should be suffixed by the current date in MMDD format
|-valign="top"
|}
<br>
;Comments:

Useful in creating export files or other temporary files.

===FNINDEX - Build an Index file and check for duplicates===

Builds an index file for the specified file.If Duplicate keys are not allowed displays a message box allowing deletion of duplicates or ignoring the error

 FNINDEX(FLNR,FLNM$*40,KFNM$*40,KS$,KL$,DUPS,KFMSG$*200)

;Functions used:<br>
FNPRINT_FILE<br>
FNDIALOG

;Variables:
{|
|-valign="top"
|width="10%"|**FLNR**||Number assigned to file when and if it is opened by FNINDEX
|-valign="top"
|width="10%"|**FLNM$**||File name including path if necessary
|-valign="top"
|width="10%"|**KFNM$**||Key file name including path if necessary
|-valign="top"
|width="10%"|**KS$**||Key starting position(s)
|-valign="top"
|width="10%"|**KL$**||Key length(s)
|-valign="top"
|width="10%"|**DUPS**||If true (non-zero) then duplicate records are allowed, if false (zero) then duplicate keys cause a trapped error that allows display and printing of the duplicates.  The condition can also be ignored with a Continue or the duplicate keys can be deleted.
|-valign="top"
|width="10%"|**KFMSG$**||Message to display on the command console while index is being built
|-valign="top"
|}
<br>
;Comments:

===FNNEXTFIL$ - returns the file name of the next sequential file in a given location===

Similar purpose to FNFIL above, but this returns the name of the file to be used.

 FNNEXTFIL$*100(NFIL$,NPATH$*100)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**NFIL$ **||The first few characters of the file name to be created
|-valign="top"
|width="10%"|**NAPTH$ **||The path where the file is to be created.  If NPATH$ does not end with a "\\" one will be added.
|-valign="top"
|}
<br>
;Comments:<br>
Used by FNOPEN in the reprint series of functions (See printing).

===FNPUTFILE$ - Return the name and path of an file to be created, replaced or appended===

Returns the path and name of a file that has been picked using FILEDIALOG.exe

 FNPUTFILE(LOOKIN$,LOOKFOR$)

;Functions used:<br>
None

;Variables:
{|
|-valign="top"
|width="10%"|**LOOKIN$**||Name of the path for which to display the selection API dialog window.
|-valign="top"
|width="10%"|**LOOKFOR$**||The type of file to be included in the file look up.
|-valign="top"
|}
<br>
;Comments:

This is a BR access to the Windows API call for returning the name of any file from the disk drive which we want to modify in some way.

===FNSIZE - Set or correct a file size===

Changes file size of referenced file.  Will only increase file size, will not shrink file.

 FNSIZE(FLNM$,FLLEN) ! Function to change file size

;Functions used:<br>
None

;Variables:
{|
|-valign="top"
|width="10%"|**FLNM$ **||name of file being processed
|-valign="top"
|width="10%"|**FLLEN **||length of new file
|-valign="top"
|}
<br>
;Comments:

Useful in conjunction with a routine to check file versions.  The function will check the names file and if its length is less than the number passed the file will be copied to a new file with the -D and -S parameters which remove deleted records and increase the record length of each record to the -S length.

===FNUPDATE_VERSION - Change a file version and reconfigure layout===

Converts a file from one version to another based on passed FORM statements

 FNUPDATE_VERSION(FILENAME$,DIRNAME$,MAT VERSIONS,DIR COPY$,OLDFORM$*500,NEWFORM$*500;LASTREC,DELETE_LASTREC)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**FILENAME$**||File name of file to be converted without any path name
|-valign="top"
|width="10%"|**DIRNAME$**||Directory where FILENAME$ exists
|-valign="top"
|width="10%"|**MAT VERSIONS**|| a 2 by 3 matrix old file information is on line 1 new file information is on line 2. Columns for each are column 1 version number. Column 2 size of the string matrix needed (Mat A$) Column 3 size of the numeric matrix needed (Mat A)
|-valign="top"
|width="10%"|**DIRCOPY$**||Work directory for update process.  If directory does not exist it will be created.
|-valign="top"
|width="10%"|**OLDFORM$**||Compiled FORM statement for the old version of the file
|-valign="top"
|width="10%"|**NEWFORM$**||Compiled FORM statement for the new version of the file
|-valign="top"
|width="10%"|**LASTREC**||If TRUE and DELETE_LASTREC is FALSE then a record 1 in the format L9 is created with the number of records in the file
|-valign="top"
|width="10%"|**DELETE_LASTREC**||If TRUE then no record 1 with number of records in the file is created in the new version file
|-valign="top"
|}
<br>
;Comments:<br>
This routine is quite old and does not allow the rearranging of fields that is possible using the newer techniques developed by Gabriel Bakker.

==Data management==
===FNSEQ - Return the next sequence for a key field===

Returns a number that is the next sequence number for a keyed file key that uses a number following the primary key to keep the records unique.

 FNSEQ(FILNR,FILKEY$,FILFRM$)

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**FILNR**||Number of already open internal, keyed file
|-valign="top"
|width="10%"|**FILKEY$**||The key that will be sequenced
|-valign="top"
|width="10%"|**FILFRM$**||Form statement for reading the key and suffix ex. "FORM pos 7,c 10,n 3"
|-valign="top"
|}
<br>
;Comments:

Useful in adding a sequence number in a keyed file so that duplicate keys are not created.

===FNTYPE - Move the contents of one text file into another open file===

Moves the contents of a named file into an existing open display file.

 FNTYPE(INFILE$*100,OUTFILE)

;Functions used:<br>
FNPROGRESS (This progress bar can be disabled in the function without damage to the function)

;Variables:
{|
|-valign="top"
|width="10%"|**INFILE$**||File name including path of any display file, the contents of which are to be moved to an open print file.
|-valign="top"
|width="10%"|**OUTFILE**||File number of an open print file.  The print file should have been opened using EOL=NONE to avoid CR and LF being inserted where they are not wanted.
|-valign="top"
|}
<br>
;Comments:<br>
Excellent for moving a graphic into a print file where the graphic or other image is greater than 32,000 characters long.  Can also be used to merge a PCL macro or form with a printed page.

==Form statements==

===FNCFORM$ - Create a Condensed Compiled Form Statement===

Takes a string of field specifications and creates a compiled FORM variable combing repetitive specifications into a bracketed multiple specification n order to fit the statement within the size limitation for a compiled form statement.

 FNCFORM$*2000(ACF$*2000)

ACF$ is a string of field specifications separated by commas.  Both are dimensioned to more than are allowable.

;Functions used:

FNCF$(ACF$)

;Comments:<br>
A string of "C 5,C 5,C 5,C 5" will be returned by FNCF$ as "4*C 5" The function FNCFORM$ takes this revised specification, adds a "FORM " to the front and compiles it into a compiled format variable.

===FNCF$ - Process a field specification string for use in FNCFORM$===

Takes a string of field specifications and creates condensed specifications string by combing repetitive specifications into a bracketed multiple specification.

 FNCF$*2000(ACF$*2000)

ACF$ is a string of field specifications separated by commas.  Both are dimensioned to more than are allowable.

;Functions used:

None

;Comments:<br>
A string of "C 5,C 5,C 5,C 5" will be returned by FNCF$ as "4*C 5"
