---
title: Positional_Parameters
file: Positional_Parameters.md
category: 30-io-file
subcategory: 30-io-file/statements
kind: statement
related: [System/36, RESTORE, DELETE, REWRITE, 0715, Pos Parameter]
---
These positional parameters can be used with the READ statement:
*FIRST
*LAST 
*PRIOR
*NEXT
*SAME 
Additionally the following are available  for `System/36` compatibility:
*`RESTORE`
*`DELETE`
*`REWRITE`

The parameters may be used with Business Rules! internal files which have been opened for either RELATIVE or KEYED access, and with external files. The files must be opened for either INPUT or OUTIN.

If positional parameters are used, DELETE and REWRITE do not need to follow a READ.

In the following sample syntax sentences, "pos-parm" represents the FIRST, LAST, PRIOR, NEXT or SAME keyword:

:READ #file-num,USING line-ref,pos-parm: var-name error-cond line-ref
:REWRITE #file-num,USING line-ref,pos-parm: var-name error-cond line-ref
:DELETE #file-num,pos-parm: error-cond line-ref
:RESTORE #file-num,pos-parm: error-cond line-ref

The FIRST keyword resets the file pointer to the first record in the file before execution of the I/O operation. If the file is empty, an EOF error is generated. The LAST keyword positions the file pointer to the last record in the file before execution of the I/O operation. If the file is empty, an EOF error is generated.

The PRIOR, NEXT and SAME positional parameters operate according to the last record referenced in the file. The last referenced record is the one that has most recently been processed by a RESTORE with a parameter (positional, REC= or KEY=), a WRITE to a relative file, a READ, a REREAD, a REWRITE, or a DELETE.

If PRIOR, NEXT or SAME positioning is attempted when no records have been referenced or after a RESTORE with no parameters has been issued, Business Rules will respond as stated below. This status can be tested with the REC function, which will return a zero for the current record when no records have been referenced. The PRIOR keyword positions the file pointer to the record previous to the last referenced record in the file. However, in a situation where a READ PRIOR, DELETE PRIOR or REWRITE PRIOR follows a RESTORE with a parameter, the file pointer is positioned to the same record that is referenced by the RESTORE.

The only exception to this is when S/36-MODE is ON, in the above situation the file pointer will then position to the previous record if one exists or else it will generate an EOF error. If PRIOR is used when no records have been referenced, an EOF error is also generated.

The NEXT keyword positions the file pointer to the record following the last referenced record in the file. If no record has been referenced, the first record in the file is accessed. If the file is empty or the file pointer was already at the last record, an EOF error is generated. If a READ NEXT, DELETE NEXT, or REWRITE NEXT follows a RESTORE with a parameter, the same record is processed.

The SAME keyword positions the file pointer to the last referenced record in the file. If no records have been referenced, error `0715` (Illegal sequence) is generated. Note that the difference between READ SAME and REREAD is that READ SAME actually reads the file again, while REREAD only unpacks the data from the buffer.

The following sample code and output shows an example of positional parameters in use:

 0130 OPEN #1: 'name=test.dat,recl=15,replace,kfname=test.key,kps=1,kln=3',INTERNAL,OUTIN,KEYED
 00140 FORM C 3,N 3
 00150 ! write 7 records with letters A through G as keys
 00160 FOR I = 1 TO 7 : WRITE #1,USING 140: CHR$(64+I),I : NEXT I
 00170 !
 00180 PRINT "KEYED:" : GOSUB TESTREAD ! read keyed
 00190 CLOSE #1:
 00200 OPEN #1: 'name=test.dat',INTERNAL,INPUT,RELATIVE
 00210 PRINT : PRINT "RELATIVELY:" : GOSUB TESTREAD ! read relative using same logic
 00220 END
 00230 TESTREAD: !
 00240 READ #1,USING 140,FIRST: A$ : PRINT "FIRST ";A$
 00250 READ #1,USING 140,SAME: A$ : PRINT "SAME ";A$
 00260 READ #1,USING 140,LAST: A$ : PRINT "LAST ";A$
 00270 READ #1,USING 140,PRIOR: A$ : PRINT "PRIOR ";A$
 00280 READ #1,USING 140,NEXT: A$ : PRINT "NEXT ";A$
 00290 PRINT "DESCENDING KEY: "; ! read whole file by descending key
 00300 RESTORE #1,LAST: : FOR I=1 TO 7 : READ #1,USING 140,PRIOR:A$ : PRINT A$; : NEXT I : PRINT
 00310 RETURN

Output:

;KEYED:
 FIRST       A
 SAME        A
 LAST        G
 PRIOR       F
 NEXT        G
DESCENDING KEY: G F E D C B A<br>
;RELATIVELY:
 FIRST       A
 SAME        A
 LAST        G
 PRIOR       F
 NEXT        G
DESCENDING KEY: G F E D C B A

For disambiguation, see `Pos Parameter`
