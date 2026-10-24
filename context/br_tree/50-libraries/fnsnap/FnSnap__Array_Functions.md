---
title: FnSnap__Array_Functions
file: FnSnap__Array_Functions.md
category: 50-libraries
subcategory: 50-libraries/fnsnap
kind: function
related: []
---
==Sorting arrays==
===FNSORTARRAY - sort an array with header and footer===
Sorts an array either ascending or descending and optionally excludes elements at the top and bottom to allow headers and footers to remain in place - sort is based on positions within the array, not the start of the string

 FNSORTARRAY(MAT L$,START,LENGTH;DESENDING,HEADER,FOOTER)!:

Functions used |None

;Variables:
{|
|-valign="top"
|width="10%"|**Mat L$**||matrix to be sorted
|-valign="top"
|width="10%"|**START**||Starting position for the character string on which to sort
|-valign="top"
|width="10%"|**LENGTH**||length of the character sub string on which to sort
|-valign="top"
|width="10%"|**DESCENDING**|| if true sorts descending order else sorts ascending
|-valign="top"
|width="10%"|**HEADER**|| number of rows at the top of the matrix to omit from the sort
|-valign="top"
|width="10%"|**FOOTER**|| number of rows at the bottom of the matrix to omit from the sort
|-valign="top"
|}
<br>
;Comments:

Sort an array on any character sub-set allowing for header rows at the top and footer/total rows at the bottom.

===FNSRTARY - sort an array with header and footer based on itself===

Similar to FNSORTARRAY but uses the entire string to sort rather than a sub string

 FNSRTARY(MAT L$;MAT M$,DESENDING,HEADER,FOOTER)

Functions used |None

;Variables:
{|
|-valign="top"
|width="10%"|**Mat L$**||matrix to be sorted
|-valign="top"
|width="10%"|**DESCENDING**|| if true sorts descending order else sorts ascending
|-valign="top"
|width="10%"|**HEADER**|| number of rows at the top of the matrix to omit from the sort
|-valign="top"
|width="10%"|**FOOTER**|| number of rows at the bottom of the matrix to omit from the sort
|-valign="top"
|}
<br>
;Comments:

===FNSRTNARY -Sort a numeric array based on another array===

Similar to FNSRTARY but for a numeric matrix

 FNSRTNARY(MAT L;MAT M$,DESENDING,HEADER,FOOTER) !:

Functions used |None

;Variables:
{|
|-valign="top"
|width="10%"|**Mat L$**||matrix to be sorted
|-valign="top"
|width="10%"|**DESCENDING**||if true sorts descending order else sorts ascending
|-valign="top"
|width="10%"|**HEADER**||number of rows at the top of the matrix to omit from the sort
|-valign="top"
|width="10%"|**FOOTER**|| number of rows at the bottom of the matrix to omit from the sort
|-valign="top"
|}
<br>
;Comments:

==Array arithmetic==
===FNCOLSUM - sums the elements of an array for a specified column===

Provides the sum of a single column of a multi column array.

 FNCOLSUM(MAT L,C)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**MAT L **||Matrix containing multiple columns
|-valign="top"
|width="10%"|**C **||Column number to be summed
|-valign="top"
|}
;Comments:

===FNROWSUM - sums the elements of an array for a specified row===

Returns the sum of a row of a multi row and multi column array

 FNROWSUM(MAT L,R)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**Mat L **||Numeric array containing the row to be totaled
|-valign="top"
|width="10%"|**R **||Row number to be totaled
|-valign="top"
|}
<br>
;Comments:

==Searching arrays==
===FNCHRMAT$ - convert a numeric array to character===

Convert a numeric matrix into a formatted character matrix

 FNCHRMAT$(CHRMAT$,NUMMAT,FORMAT$;BLANKS)

Functions used |None

;Variables:
{|
|-valign="top"
|width="10%"|**Mat CHRMAT$**||matrix that will be output
|-valign="top"
|width="10%"|**Mat NUMMAT**||numeric matrix being converted
|-valign="top"
|width="10%"|**FORMAT$**||format used to convert each line to a string
|-valign="top"
|width="10%"|**BLANKS**||if true replaces a zero value with blanks
|-valign="top"
|}
<br>
;Comments:

===FNLISTSRCH - searches a character array based on a search string===

 FNLISTSRCH(MAT L$,SRCHSTR$,MAT SELECT;STRT)

Description|<br>
Performs a search on a matrix and modifies the matrix select with elements in the searched matrix that match SRCHSTR$

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**Mat L$ **||The array to be searched.  The search is case insensitive and will match any matching combination regardless of position within each element.
|-valign="top"
|width="10%"|**SRCHSTR$ **||The string that is being matched to each element, case insensitive
|-valign="top"
|width="10%"|**MAT SELECT **||A numeric array that holds the row numbers of matching elements.  Any newly found elements are added to the array.
|-valign="top"
|width="10%"|**STRT **||Optional positioning number. matches will only occur if the match is AFTER this position in the row string
|-valign="top"
|}
<br>
;Comments:<br>
Used in lists and grids following FNLISTSPEC to allow for a search of the arrays used in a list or grid and a positioning of the cursor on elements matching the criteria

===FNLISTSRCHN - searches a numeric array based on a search string===

 FNLISTSRCHN(MAT L,SRCHSTR$,MAT SELECT;STRT,SMASK$)

Description|<br>
Same as FNLISTSRCH except for a numeric matrix

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**Mat L **||The array to be searched.  Each element is turned into a string before being searched. The search is case insensitive and will match any matching combination regardless of position within each element.
|-valign="top"
|width="10%"|**SRCHSTR$ **||The string that is being matched to each element, case insensitive
|-valign="top"
|width="10%"|**MAT SELECT **||A numeric array that holds the row numbers of matching elements.  Any newly found elements are added to the array.
|-valign="top"
|width="10%"|**STRT **||Optional positioning number. matches will only occur if the match is AFTER this position in the row string
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:<br>
Used in lists and grids following FNLISTSPEC to allow for a search of the arrays used in a list or grid and a positioning of the cursor on elements matching the criteria

===FNSELECTION - selection process using two arrays===

 FNSELECTION(SELECTION,MAT SEL$,MAT SEL;MANY)

Description|<br>
Maintains two matrices, one SEL is true if an item is selected.  The other SEL$ contains the selection sequence number if MANY is greater than one or the word SELECTED if MANY equals one.  If many=0 only one item is allowed as a selection.

Functions used |None

;Variables:
{|
|-valign="top"
|width="10%"|**SELECTION the element number selected or deselected  MAT SEL$ selection number or word MAT SEL true if element is selected  MANY 0 for a single selection 1 for any or all and a number for a limited number of elements
|-valign="top"
|}
<br>
;Comments:

===FNSRCHCRIT$*50 - search criteria for a list box===

 FNSRCHCRIT$*50(SR$,SC$,LROWS,LCOLS,PARENT;MESSAGE$)

Description|<br>
Opens a window within a listbox window and asks for a search string

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

==Other==
===FNDELROW - removes a row from an array and redimensions the array===

Removes a row form an array and redimensions the array to be one row shorter

 FNDELROW$(MAT DEL,DELROW)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**MAT DEL **||The numeric array that needs to be updated
|-valign="top"
|width="10%"|**DELROW **||The row number to delete
|-valign="top"
|}
<br>
;Comments:

===FNDELROW$ - removes a row from an array and redimensions the array===

Removes a row form an array and redimensions the array to be one row shorter

 FNDELROW$(MAT DEL$,DELROW)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**MAT DEL$ **||The character array that needs to be updated
|-valign="top"
|width="10%"|**DELROW **||The row number to delete
|-valign="top"
|}
<br>
;Comments:

===FNPARMAT - split an array into sub-arrays===

Parses an array into a multi-dimensional array based on splitting at a predefined character

 FNPARMAT(MAT M$,SUB$;NOREF)

Functions used |None

;Variables:

{|
|-valign="top"
|width="10%"|**MAT M$**||matrix to be parsed
|-valign="top"
|width="10%"|**SUB$'''||character that will be treated as a boundary or field separator   NOREF if true prevents a single line matrix from being reformatted to a one dimensional matrix
|-valign="top"
|}
<br>
;Comments:
