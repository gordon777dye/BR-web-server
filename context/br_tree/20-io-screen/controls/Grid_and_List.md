---
title: Grid_and_List
file: Grid_and_List.md
category: 20-io-screen
subcategory: 20-io-screen/controls
kind: concept
related: [INPUT FIELDS, PRINT FIELDS, Two dimensional controls, Control, FKEY, 2D Controls, FILTER, VAL, STR, 4.3]
provenance: recovered-2b (redirect-collision casualty re-fetched from wiki)
---
This discussion assumes the reader has a clear understanding of `INPUT FIELDS` and `PRINT FIELDS` processing with simple fields.

**Grid** and **List** (a.k.a. **ListView**) are `Two dimensional controls`, which means that they contain rows and columns. GRIDs are normally used for data entry, while LISTs are used only for selection. In Business Rules, outputting to these controls is done with `Print Fields` and inputting from them is done with `Input Fields`. Each field specification pertains to one `Control`. However, a single FIELD specification can pertain to a parenthesized group of arrays. When using Grids and Lists, first the header must be populated, and then the data within the rows.

The `INPUT FIELDS` specification states Grid or List as the field type. The display area is specified in terms of rows and columns separated by a slash. The following parameter, instead of being leading field attributes, is a secondary keyword indicating the type (CNT/SUB/CELL/ROWCNT/ROWSUB/ROW) of output or input operation to be performed. The next parameter further qualifies the IO operation (CHG/SEL/ALL/CUR/NEXT). Normally this trailing attribute is an `FKEY` value which is shifted right one parameter in this context.

It is useful to work with `2D Controls` in terms of rows versus cells, particularly when the columns are dissimilar. A complete set of row oriented parameters are provided for that purpose. Output operations support the mass populating of 2D controls row by row. And input operations can be row oriented as well. The keywords associated with row processing are R, ROWCNT, ROWSUB, and ROW.

RINPUT does not work with 2D controls because the output statements are somewhat different from the input statements. The output consists of setting up the columns, including providing the column headings, and populating the control with data. The input consists of identifying what has changed in a manner that enables selective data retrieval and corresponding file updating.

If the user clicks on a column heading the GRID or LIST will be sorted on that column. Sorting is done in terms of rows. Such sorting of these controls has no affect on the BR program. The information returned to BR will be as though no sorting were performed. If a control's population is increased by populating with the plus (+) flag, the control will be resequenced back to its original order before the data is added. One way a program can restore the original displayed order of a GRID or LIST is to populate it incrementally (+) with no data. As of version 4.1 and higher, if a GRID input is attempted on a protected field, BR issues a Bell.

Shift+PgUp and Shift+PgDn selects within a List/Grid.

Grids and lists are compatible with the `FILTER` field, which works like a search bar.

In GRIDs and LISTs only, string arrays may be used to process numeric values. BR automatically performs `VAL` and `STR` conversions as needed. If string data is passed to a numeric field type such as N or DATE then it is automatically converted to numeric form for internal processing (4.2).

As of Business Rules! versions `4.3`+, arrays are automatically resized when receiving data from 2D INPUT operations. This also applies to grouped arrays. Automatic resizing only applies to one dimensional arrays and does not occur when INPUTing into two dimensional arrays. For example, where all arrays are one dimensional and may have the incorrect number of elements:

```
INPUT FIELDS "row,col,LIST rows/cols, ROW, ALL": ( MAT Array1$, MAT Array2$, MAT Array3, MAT Array4, MAT Array5$ )
```

#### FKey Processing

An `FKey` value can be associated with a LIST or GRID control by specifying the FKey number during either output or input operations. Once an Fkey value is specified, the control retains the setting until it is reset. An FKey value can be cleared by specifying an Fkey value of minus one (-1).

When a LIST or GRID has an FKey value set processing is dependent on whether or not the 2D control is being processed by an INPUT FIELDS statement:

- **Displayed but inactive** — Single clicking any cell produces the FKey interrupt.
- **Active (participating in Input Fields)** — Double clicking any cell produces the FKey completion.

With regard to simple field specifications in PRINT FIELDS or INPUT FIELDS statements, `CURROW` and `CURCOL` identify the character position where the cursor was when FIELDS processing is completed. However, when the most recent field processed is a `2D control` then `CURROW` and `CURCOL` results have different meanings:

When FIELDS processing ends and control is returned to the program while the 'current' control is of type LIST or GRID, CURROW and CURCOL are set to the current cell row and column within the 2D control instead of the character position relative to the window.

#### GRID CURSOR MOVEMENT

When field + or - is keyed BR always returns fkey values of 114 or 115 in both navigation and edit mode and for any type of data. (This assumes the X attribute or some other attribute returns control to the program.)

Default cursor positioning for Field +/- keys is to perform a down arrow operation, and the Enter key defaults to NONE (no movement).

In edit mode, Field +/- forces the signing of a numeric field, whether or not the field type is PIC.

In edit mode, Field +/- also right truncates any character or numeric data before exiting the field.

A Config statement can be used to override (control) grid cursor movement. When this is used, both Field +/- and Enter produce the same cursor movement:

```
GRID_CURSOR_MOVE  DOWN | RIGHT | NONE | DEFAULT
```

This determines the field cursor position after keying Enter or Field +/-. Both navigation and edit mode produce the same resulting cursor position.

#### Restoring a User Sorted 2D Control

In versions 4.3 and higher the syntax for sorting a listview is:

```
PRINT FIELDS "nn,nn,GRID 10/40,SORT": { column number }
```

This has been extended to allow a numeric array instead of a scalar. If an array is given, it is assumed to be in the same format that SORT_ORDER returns. The new format is:

```
PRINT FIELDS "nn,nn,GRID 10/40,SORT": { column-number | numeric-array }
```

Where the numeric-array has one element for each column left to right. BR will resort the columns in the requested order.

The numeric array values indicating the order of column sorting to be performed do not need to exactly match the standard format. e.g Fractions are allowed, the values can fall within any range, and there does not need to be trailing zero elements for unsorted columns.

#### A multi column LISTview

```
01000 PRINT FIELDS "10,20,LIST 10/80,HEADERS,[HDRS][,fkey]": (MAT HEADINGS$,MAT WIDTHS, MAT FORMS$)
```

**Note:** Widths are expressed in character positions.

The [HDRS] notation refers to an optional CONFIG ATTRIBUTE HDRS specification for setting the appearance of the header row. In this case the brackets [] are required and the term HDRS may be any bracketed attribute name.

If a function key value (e.g. 1520) is given then when the control is not active, it may be clicked to trigger the specified interrupt similar to any other hot control. A function key interrupt is also triggered by double clicking during an Input operation.

| Parameter | Description |
|---|---|
| **MAT HEADINGS$** | Specifies the titles that will appear at the top of each column in the List or Grid. The format of this row may be specified by an optional parameter following HEADERS in the above example. |
| **MAT WIDTHS** | Specifies the number of characters in each column. For example if four columns are specified and the widths are given as 10, 15, 10 and 5, then the 2D control occupies 40 character positions (plus a little for the column separators) irrespective of the number of columns specified for the display area. If needed, scroll bars are used to display wider controls within the displayed area. |
| **MAT FORMS$** | Specifies the display characteristics of each column such as "C 12" or "PIC(z,zzz,zz#.##-)". A "P" following the display parameter will cause the field to be protected and no data entry will be allowed in GRID mode. |

The field form array elements may also include a trailing comma followed by field attributes (e.g. color) that pertain to the column.

```
PRINT FIELDS "10,20,LIST 10/80, = [,fkey]": (MAT NAME$, MAT CITY$, MAT AGE, MAT WEIGHT)
```

In this example, the fourth element of the HEADERS FIELD_FORM$ array (above) could specify rounding of WEIGHT to two decimal places. If an fkey value is specified, then double-clicking (or single clicking if S is specified) a cell will generate the specified fkey interrupt.

#### Reading a Listview or Grid

When using INPUT FIELDS to read from a 2D control, the leading attributes specification states the type of read operation and the trailing attributes specification is the type of cell or row selection to be performed. The third parameter can optionally specify NOWAIT or an FKEY value. If it is an FKEY value, it signifies that an FKEY event should be triggered when, in navigation mode, a selection is made by double clicking or pressing the Enter key.

##### Syntax

*(Diagram of the INPUT FIELDS/PRINT FIELDS 2D-control syntax layout — the image reference in the source wikitext was lost and could not be recovered; only a stray `950px` width parameter remained.)*

##### Parameters

Quotation marks must surround the specifications, and individual parts must be separated by commas.

**Row** and **Column** specify the space where the grid or list begins.

**List** or **Grid**, followed by rows and columns separated by a slash determine how big the list or grid is going to be. The main difference between a list and grid is that lists are for selection only while information can be added to grids directly.

The following **Read Types** are valid for both grids and lists:

| Read Type | Description |
|---|---|
| **RowCnt** | The number of rows specified. |
| **RowSub** | The subscripts of the specified rows. |
| **Row** | Read all cells in each specified row. |
| **Colcnt** | The number of columns established by the header arrays, e.g. `INPUT FIELDS "row,col,LIST rows/cols, COLCNT, ALL" : numeric-variable`. |
| **Sort_Order** | (4.3+) Provides a value of zero for each unsorted column and gives the ascending sequence of column sorts that have occurred. If a column has been reversed (double sorted) its value will be negative. The selection type used must be ALL. See the example below. |
| **HEADERS** | (As of 4.30) The read operation returns the original PRINT FIELDS HEADER values, e.g. `INPUT FIELDS "row,col,LIST rows/cols, HEADERS,ALL,NOWAIT" : (MAT HEADINGS$,MAT WIDTHS, MAT FORMS$)`. The selection type used must be ALL. |
| **MASK** | (As of 4.30) MASK can be used with Grids and Lists. As a read type, this reads the display mask setting, including listviews that have been displayed according to a `filter` or filterbox, e.g. `INPUT FIELDS "row,col,LIST rows/cols,MASK [,NOWAIT]" : mask_array`. The mask array affects only the user presentation and not the data. Use RANGE processing or the CHG selection type to selectively read from a 2D control. |

For example: `INPUT FIELDS "row,col,GRID rows/cols, SORT_ORDER, ALL" : MAT NumArray`, with the following history of sorting a four column GRID:

- column 1 (descending, most recent)
- column 2 (ascending, first sorted)
- column 3 (not sorted)
- column 4 (sorted ascending)

`SORT_ORDER` would return:

```
array(1) -> -1
array(2) ->  3
array(3) ->  0
array(4) ->  2
```

These Read Types are valid for Grids only:

| Read Type (Grids only) | Description |
|---|---|
| **Cnt** | Specify the number of cells specified (see selection types below). |
| **Sub** | Read the Cell Subscript Values (see example below). |
| **Cell** | Read each cell specified. |

For the "Sel-type" parameter, the following selection types are valid for both grids and lists:

| Selection Type | Description |
|---|---|
| **Sel** | Read one or more selected items. |
| **SelOne** | Select only one item. |
| **All** | Read all items in the control (except headings). |
| **Cur** | Current cell or row number. |
| **Next** (4.2+) | The cell the cursor is going to next if the user moved it using an arrow or a mouse click. |
| **Range** | Specifies which portion of a 2D control is to be input. (As of 4.3) See below. |
| **Cell_Range** | A special type of output range. (As of 4.3) See below. |

This Selection Type is valid for Grids only:

| Selection Type (Grids only) | Description |
|---|---|
| **Chg** | All items changed since the last '=' populate or the last CHG retrieval of cell/row contents. |

The **Read Qualifier** is an optional parameter to help the read. As of 4.3 it can be `DISPLAYED_ORDER`, `PIC`, or `FMT`. `PIC` and `FMT` allow numeric data from a string to be used.

`DISPLAYED_ORDER` indicates that the read operation is not to restore the data into its original order before returning the results to the program (as of version 4.30). This reads the original row subscripts for all rows — in their present order — and only works with the ALL selection type.

GRIDLINES makes LIST controls look like GRIDs with respect to the display of data (column and row separators).

```
PRINT FIELDS "10,20,LIST 10/80,GRIDLINES": 1 | 0 (on or off)
```

The leading attribute values "^select" or "^deselect" may be specified to allow the pre-selection of GRID / LIST Elements:

```
PRINT FIELDS "nn,nn,GRID 10/40,^select ATTR": (mat start, mat end, mat attr$)
```

The **Fkey** and **Nowait** parameters are optional. FKEY means that an FKEY event should be triggered when a selection is made by double clicking or pressing the Enter key, in navigation mode. Nowait simply means that it does not wait for user input.

Following the ending quotation mark, a colon precedes the name of the I/O List.

#### DISPLAYED ORDER Read Qualifier

As of 4.30, `DISPLAYED_ORDER` indicates that the read operation is to not restore the data into its original order before returning the results to the program, for example:

```
INPUT FIELDS "row,col,LIST rows/cols, ROWSUB, ALL, DISPLAYED_ORDER, NOWAIT": numeric-array
```

This reads the original row subscripts for all rows in their present order. This qualifier works only with the ALL selection type. It may be used in conjunction with other qualifiers such as FKEY.

#### Examples

##### LIST

```
00210 INPUT FIELDS "10,20,LIST 10/80,ROWCNT,SEL,FKEY": avail_rows  ! selected row cnt
00220  ! next INPUT operation does not wait for operator
00230 MAT subscr(avail_rows)          ! redimension with number of selected rows
00240 INPUT FIELDS "10,20,LIST 10/80,ROWSUB,SEL,NOWAIT": MAT subscr  ! read subscripts
```

##### Uniform GRID

Contains one data array and multiple columns

```
00210 INPUT FIELDS "10,20,GRID 10/80,CNT,CHG": cells      ! # of changed cells
00220 MAT subscr(cells)                                   ! redimension
00230 INPUT FIELDS "10,20,GRID 10/80,SUB,CHG,NOWAIT": MAT subscr  ! read subscripts
00240 MAT data$(cells)                                    ! redimension
00250 INPUT FIELDS "10,20,GRID 10/80,CELL,CHG,NOWAIT": MAT data$  ! read changes
```

##### Row Oriented GRID

```
00210 INPUT FIELDS "10,20,GRID 10/80,ROWCNT,CHG": rows  ! # of changed rows
00220 MAT subscr(rows)                                  ! redimension
00230 INPUT FIELDS "10,20,GRID 10/80,ROWSUB,CHG,NOWAIT": MAT subscr  ! read subscripts
00240 MAT NAME$(rows) : MAT CITY$(rows) : MAT AGE(rows) : MAT WEIGHT(rows)  ! redimension
00250 INPUT FIELDS "10,20,GRID 10/80,ROW,CHG,NOWAIT": (MAT NAME$, MAT CITY$,MAT AGE, MAT WEIGHT)  ! read changed rows
```

This brings us to the question of what is to be done with the information after it has been read. If it is to be stored in a file, then we should have included a hidden column with master file record numbers of the data in each row. This would support looping through the input array and rewriting the changed data.

While LIST subscripts are expressed in terms of rows, GRID subscripts may be either. In a four column five row GRID, the cell at row three column two has a subscript of ten.

#### Cell Subscript Values of a 5 x 4 GRID

```
 1   2   3   4
 5   6   7   8
 9  10  11  12
13  14  15  16
17  18  19  20
```

#### Sample Program

The following example shows use of LIST and GRID controls. There are seven parts in this program.

The first part creates a LIST with 2 columns and 3 rows. On lines 300 - 500, column headings, widths, and form specifications are assigned to the corresponding matrices. Lines 600 and 700 place data into the matrices to be printed in the LIST. The HEADERS operation on line 800 sets the column headings, widths and form specs. Line 900 populates the LIST by row, which is the default.

```
00100 dim HEADINGS$(2), WIDTHS(2), FORMS$(2), NAMES$(3)*28, CITIES$(3)*18, DATA$(1)*80, SUBSCR(1)
00200 print NEWPAGE
00300 let HEADINGS$(1)="Name": let HEADINGS$(2)="City"
00400 let WIDTHS(1)=30 : let WIDTHS(2)=20
00500 let FORMS$(1)="CC 28" : let FORMS$(2)="CC 18"
00600 let NAMES$(1)="Stalin" : let NAMES$(2)="Napoleon" : let NAMES$(3)="Roosevelt"
00700 let CITIES$(1)="Moscow" : let CITIES$(2)="Paris" : let CITIES$(3)="Washington"
00800 print fields "1,1,list 8/60,headers": (MAT HEADINGS$,MAT WIDTHS,MAT FORMS$)
00900 print fields "1,1,list 8/60,=R": (MAT NAMES$,MAT CITIES$)
01000 print fields "9,1,C 50" : "Press enter to insert at the end of list"
01100 let KSTAT$(1)
```

##### Output

*(Image `Output1.jpg` referenced in the source is not available — not recoverable.)*

The second part of the program demonstrates the use of the primary flag +, which adds to the end of any previously populated data. Line 01200 redimensions matrices NAMES$ and CITIES$ to allow room for one extra item in each of them. Line 01300 places new data into the matrices to be printed in the LIST. Line 01400 adds the new data to the LIST.

```
01200 mat NAMES$(UDIM(NAMES$)+1) : mat CITIES$(UDIM(CITIES$)+1)
01300 let NAMES$(4)="Churchill" : let CITIES$(4)="London"
01400 print fields "1,1,list 8/60,+": (MAT NAMES$(4:4),MAT CITIES$(4:4))
01500 print fields "9,1,C 50" : "Select rows to be read into a matrix"
```

##### Output

*(Image `Output2.jpg` referenced in the source is not available — not recoverable.)*

The third part of the program demonstrates use of read types ROWSUB and ROWCNT and selection type SEL. Line 1600 inputs the number of selected rows into AVAIL_ROWS. The user may select rows using the mouse or the keyboard and SHIFT and CTRL keys. Line 1700 redimensions matrix SUBSCR to the number of selected rows. Line 1800 inputs the subscripts of the selected rows into matrix SUBSCR. Line 1900 performs a HEADERS operation for a new LIST using the same matrices as were used in the previous LIST. Line 2000 populates the first row of the new LIST with the data from the first selected row from the previous LIST using the primary flag =. If user selects more than one row, then lines 2100 - 2500 add the data from the selected rows using the primary flag +.

```
01600 input fields "1,1,list 8/60,ROWCNT,SEL": AVAIL_ROWS
01700 mat SUBSCR(AVAIL_ROWS)
01800 input fields "1,1,list 8/60,rowsub,sel,nowait": MAT SUBSCR
01900 print fields "12,1,list 8/60,headers": (MAT HEADINGS$,MAT WIDTHS,MAT FORMS$)
02000 print fields "12,1,list 8/60,=": (MAT NAMES$(SUBSCR(1):SUBSCR(1)),MAT CITIES$(SUBSCR(1):SUBSCR(1)))
02100 if UDIM(SUBSCR) > 1 then
02200   for I = 2 to UDIM(SUBSCR)
02300     print fields "12,1,list 8/60,+": ( MAT NAMES$(SUBSCR(I):SUBSCR(I)),MAT CITIES$(SUBSCR(I):SUBSCR(I)))
02400   next I
02500 end if
02600 print fields "9,1,C 50" : "Press enter to insert at beginning of list"
```

##### Output

*(Image `Output3.jpg` referenced in the source is not available — not recoverable.)*

The fourth part of the program demonstrates the use of the primary flag -, which inserts in the beginning of any previously populated data. Line 2800 redimensions matrices NAMES$ and CITIES$ to allow room for one extra item in each of them. Line 2900 places new data into the matrices to be printed in the LIST. Line 3000 adds the new data to the beginning of the LIST ahead of previously populated data.

```
02700 let KSTAT$(1)
02800 mat NAMES$(UDIM(NAMES$)+1): mat CITIES$(UDIM(CITIES$)+1)
02900 let NAMES$(5)="Castro" :! let CITIES$(5)="Havana"
03000 print fields "1,1,list 8/60,-": (MAT NAMES$(5:5),MAT CITIES$(5:5))
03100 print fields "9,1,C 60" : "Press enter to populate list by column"
```

##### Output

*(Image `Output4.jpg` referenced in the source is not available — not recoverable.)*

The fifth part of the program, more specifically, Line 3300, demonstrates the use of the secondary flag C to populate the LIST by column. The primary flag = is also used in order to replace any previously populated data.

```
03200 let KSTAT$(1)
03300 print fields "1,1,list 8/60,=C": (MAT NAMES$,MAT CITIES$)
```

##### Output

*(Image `Output5.jpg` referenced in the source is not available — not recoverable.)*

The sixth part of the program creates a GRID. The HEADERS operation on line 3600 uses the same HEADINGS$, WIDTHS, and FORMS$ as the previously constructed LISTs. Line 3700 sets CURFLD to be on the sixth cell of the GRID (this is discussed in the next section). Line 3800 populates the GRID. The user may change the contents of the cells.

```
03400 print fields "23,1,C 50" : "Press enter to continue": let KSTAT$(1)
03500 print NEWPAGE
03600 print fields "1,1,grid 8/60,headers": (MAT HEADINGS$,MAT WIDTHS,MAT FORMS$)
03700 let CURFLD (1,6)
03800 print fields "1,1,grid 8/60,=": (MAT NAMES$,MAT CITIES$)
```

##### Output

*(Image `Output6.jpg` referenced in the source is not available — not recoverable.)*

The seventh part of the program demonstrates the use of read types CNT, CELL, and SUB and selection type CHG. Line 3900 counts the number of changed cells and inputs that number into variable CELLS. Line 4000 redimensions the matrix SUBSCR to the number of changed cells. Line 4100 inputs the changed cells into SUBSCR. Line 4200 redimensions the matrix DATA$. Line 4300 inputs the subscripts of the changed cells into matrix DATA$. Line 4400 prints DATA$.

```
03900 input fields "1,1,grid 8/60,cnt,chg": CELLS
04000 mat SUBSCR(CELLS)
04100 input fields "1,1,grid 8/60,sub,chg,nowait": MAT SUBSCR
04200 mat DATA$(CELLS)
04300 input fields "1,1,grid 8/60,cell,chg,nowait": MAT DATA$
04400 print MAT DATA$
```

##### Output

*(Image `Output6b.jpg` referenced in the source is not available — not recoverable.)*

##### Output of line 04400

*(Image `Output7.jpg` referenced in the source is not available — not recoverable.)*

### Displaying a List or Grid (Output Operations)

*(Diagram of the output-operations syntax layout — the image reference in the source wikitext was lost and could not be recovered; only a stray `900px` width parameter remained.)*

To display a listview or a grid, you must set the headers first, using a special PRINT FIELDS operation.

#### HEADERS

The HEADERS operation sets the column headings and widths. The corresponding input/output list value must be a parenthesized group of three arrays, for example:

```
00250 PRINT FIELDS "10,20,LIST 10/80,HEADERS": (MAT HEADINGS$, MAT WIDTHS, MAT FIELD_FORMS$)
```
— or —
```
00250 PRINT FIELDS "10,20,GRID 10/80,HEADERS,[hdrs],1520": (MAT HEADINGS$, MAT WIDTHS,MAT FIELD_FORMS$)
```

The [hdrs] notation refers to an optional CONFIG ATTRIBUTE [HDRS] specification for setting the appearance of the header row. In this case the [] brackets are required.

If a function key value (e.g. 1520) is given then when the control is not active, it may be clicked to trigger the specified interrupt similar to any other hot control. A function key interrupt is also triggered by double clicking during an Input operation.

MAT HEADINGS$ Contains the column titles that will be displayed at the top of each column. The font, color and shading of these titles can be set through the [HDRS] or similar substitution attribute.

MAT WIDTHS specifies DISPLAYED Column Widths and is expressed as the number of character positions occupied by each column. Scrollbars are provided as needed to honor overall control size specified in the FIELDS specification.

For example, if four columns are specified and the widths are given as 10, 15, 10 and 5, then the 2D control occupies 40 character positions (plus a little for the column separators) irrespective of the number of columns specified for the display area. If needed, scroll bars are used to display wider controls within the displayed area.

Displayed widths of zero characters are allowed. This enables the use of hidden columns for storing things like record numbers and record keys.

MAT FIELD_FORMS$ provides the BR FORM for each column. e.g. C 15 stipulates a maximum field capacity of 15. The actual displayed length is a function of the grid size and the column relative width.

The field form array elements may also include a comma followed by leading field attributes (e.g. color) pertaining to the column.

The number of columns must be set with HEADERS prior to Populating a control (loading data into it).

#### MASKing

As of 4.3, LIST and GRID support the MASK operation, both in READs and Populating, as seen in this section. For example:

```
PRINT FIELDS "row,col,LIST rows/cols,MASK" :  mask_array
```

This restricts the rows (for both LIST and GRID) previously displayed to those corresponding to a "true" value in mask_array. A true value is represented in a numeric array as a value greater than zero. Negative values are not allowed in mask arrays. A string mask array may also be used with "T" and "F" values. The MASK stays in effect until 1) a new MASK is specified or 2) the contents of the control are changed with PRINT (=, +, -, see primary flags below). Also, the mask array affects only the user presentation, not the result set.

#### Populating

The populate operation loads data into the control. In the following example four columns are loaded:

```
03010 PRINT FIELDS "10,20,LIST 10/80, =": (MAT NAME$, MAT CITY$,MAT AGE, MAT WEIGHT)
```
— or —
```
03020 PRINT FIELDS "10,20,GRID 10/80, =": (MAT NAME$, MAT CITY$, MAT AGE, MAT WEIGHT)
```

In this example, the fourth element of the HEADERS FIELD_FORM$ array (above) could specify rounding of WEIGHT to two decimal places. If an fkey value is specified, then double-clicking (or single clicking if S is specified) a cell will generate the specified fkey interrupt.

Permissible leading attribute values are:

##### Primary Flags

| Primary Flag | Description |
|---|---|
| **=** | Replace any previous data |
| **+** | Add to any previously populated data (this allows loading in chunks) |
| **-** | Insert data ahead of previously populated data (4.16+) |

#### Secondary Flags

| Secondary Flag | Description |
|---|---|
| **R** | Load one row at a time (the default - use grouped IO parens) |
| **C** | Load one column at a time - this is for loading multiple columns of the same data type |
| **L** | Provide the FKEY (see INPUT below) or Enter interrupt if the user presses up arrow or page up in the first field, or down arrow or page down in the last field. Note that this is not specified in the individual field leading attributes. |
| **S** | Single click to activate an Enter or FKEY event (otherwise a double click is required) (4.17+) |

**Note:** the following example will NOT work:

```
00100 PRINT FIELDS "10,20,LIST 10/80,=C": MAT NAME$,MAT CITY$,MAT AGE,MAT WEIGHT
```

The reason is that only MAT NAME$ will reach the list. MAT CITY$, MAT AGE and MAT WEIGHT will be associated with subsequent fields. Multiple arrays provided to a single control must be grouped with parentheses.

Populating a two-dimensional object by row with grouped IO means NAME$(1) will go into (1,1), AGE(1) will go into (1,2) and WGT(1) will go into (1,3) and so on. If a single array (MAT DATA$) is specified instead of a group, MAT DATA$ is applied horizontally instead of vertically. So DATA$(1) - DATA$(3) will be the first row and DATA$(4) - DATA$(6) will be the next row and so on.

Populating a two dimensional grid by column with an array named DATA$ means that DATA$(1) goes in (1,1) and DATA$(2) goes in (2,1) and DATA$(3) goes in (3,1). Therefore the first however many values of DATA refer to the first column and the second however many values of DATA refer to the second column. So if there are 3 columns and UDIM(DATA$) = 90 then DATA$(1)-DATA$(30) is the first column, and DATA$(31) - DATA$(60) is the second column and DATA$(61) - DATA$(90) is the last column.

For example, using the following information, each example demonstrates how the grid will be filled:

- `MAT NAME$` = George, Peter, Tom
- `MAT CITY$` = Dallas, Detroit, Denver
- `MAT AGE$` = 42, 23, 35
- `MAT WEIGHT$` = 180, 212, 193

```
00200 PRINT FIELDS "10,20,GRID 10/80, =": (MAT NAME$, MAT CITY$,MAT AGE$, MAT WEIGHT$)
```

```
Peter, Detroit, 23, 212
Tom, Denver, 35, 193
```

```
00200 PRINT FIELDS "10,20,GRID 10/80, =C": (MAT NAME$, MAT CITY$,MAT AGE$, MAT WEIGHT$)
```

```
Dallas, Detroit, Denver
42, 23, 35
180, 212, 193
```

**Note on the two result blocks above:** both are reproduced exactly as they appear in the source. Each is missing what would be its first line (a "George, Dallas, 42, 180" row for the first block, and a "George, Peter, Tom" row for the second) given the stated example data — most likely lost in the same source recovery that affected this page (see `provenance` in the frontmatter), rather than an intentional omission. Not reconstructed here per the "don't guess" rule.

As you can see using C with grouped arrays is counter-intuitive and doesn't fit well. C is most useful with a single array that should be loaded vertically down several columns.

##### Grid Validation

GRIDs are now validated as each cell is exited instead of when control is passed to the BR program after all data is entered.

##### Color and Font changes in Cells

The attributes that determine font, color and style in each cell can be set for an entire column by including these parameters in the heading FORM array. Individual cells can then be changed using a PRINT statement.

The format of the print statement is

```
00100 PRINT #WINNO, fields "2,2,LIST 10/60,ATTR":(mat start, mat end, mat attribute$)
```

With the following parameter descriptions:

| Parameter | Description |
|---|---|
| **mat start** | contains the cell number(s) where the attribute chain begins |
| **mat end** | contains the last cell number where the attribute applies |
| **mat attribute$** | contains the attribute specification that should be applied to the cell range(s) specified |

If the 2d control is a GRID, then mat Start and mat End refer to starting and ending Cell Numbers. If the 2d control is a listview, then mat Start and mat End refer to starting and ending Row Numbers.

The attributes specified for any COLUMN can be overridden on a cell basis by specifying the starting cell number, ending cell number, and the overriding attributes in three arrays that are printed to the grid window with the same grid specificatoins and the key word "ATTR".

```
02420 PRINT #BLISTWIN,FIELDS BLISTSPEC$&",ATTR": (MAT BROWS,MAT BROWE,MAT BATT$)
```

In the above example, BLISTWIN is the window number, BLISTSPEC$ is the grid specification ("GRID 10/40" for example), BROWS is an array holding the starting cell number, BROWE is an array holding the ending cell number, and BATT$ is an array holding the overriding attributes. In a list the attributes of the first cell in the row controls the appearance of the entire row.

```
01500 PRINT FIELDS "nn,nn,GRID 10/40,ATTR": (mat start, mat end, mat attr$)
```

The above example overrides the attributes of a range of cells/rows for a GRID/LIST display. This allows you to shade or otherwise alter the display of a range of cells / rows in a 2D control.

#### Aggregate Sorting

BR supports aggregated sorting for LISTs and GRIDs. This means when clicking on various column headings or programmatically sorting columns, fields of equal values retain their previous order within their new groupings (4.2).

#### Numeric Column Sorting

2D controls now facilitate numeric column sorting. This works well in conjunction with the new `DATE` field format (see release notes `4.16`) where the data is stored as day of century, but is displayed as a formatted date. It also works with all numeric columns.

If a listview columns form spec if given as DATE(mm/dd/ccyy), for example, then any time that column is sorted, either as a result of the user clicking on the column heading, or the program giving the sort command (shown below), the dates are properly sorted even though they're displayed as mm/dd/ccyy. For this to work, the data has to be given in the julian days format, see the `DAYS` function for more information.

In versions 4.2 and higher the syntax for sorting a listview is:

```
PRINT FIELDS "nn,nn,GRID 10/40,SORT": { column number }
```

To sort in reverse order, sort the column twice:

```
PRINT FIELDS "nn,nn,GRID 10/40,SORT": { column number }
PRINT FIELDS "nn,nn,GRID 10/40,SORT": { same column number }
```

This has been extended in version 4.3 to allow a numeric array instead of a scalar. If an array is given, it is assumed to be in the same format that SORT_ORDER returns. The new format is:

```
PRINT FIELDS "nn,nn,GRID 10/40,SORT": { column-number | numeric-array }
```

Where the numeric-array has one element for each column left to right. BR will resort the columns in the requested order.

The numeric array values indicating the order of column sorting to be performed do not need to exactly match the standard format. e.g Fractions are allowed, the values can fall within any range, and there does not need to be trailing zero elements for unsorted columns.

#### NOSORT for Columns

As of 4.2, the **NoSort** parameter is used to prevent users from sorting columns of a Grid or List.

For the statement:

```
PRINT FIELDS "10,20,GRID 10/80,HEADERS,[hdrs],1520": (MAT HEADINGS$, MAT WIDTHS, MAT FIELD_FORMS$)
```

The field attribute "^nosort" appearing in the MAT FIELD_FORM$ prevents the sorting of a grid or listview in response to the user clicking on the corresponding column header. This does not prevent programs from sorting on those columns.

#### Range Input

The following examples are used in versions 4.3 and higher. In these examples BR will redimension the receiving arrays as needed:

```
INPUT FIELDS "row,col,LIST rows/cols, CELL, RANGE" :
            start, end, MAT Data$
```

This reads the specified range of cells. BR redimensions MAT Data$ as needed. Note that CELL may now be used with LIST. Previously, LISTs were only addressable by row.

```
INPUT FIELDS "row,col,LIST rows/cols, ROW, RANGE" :
            (start:=7), (end:=11), ( MAT Array1$, MAT Array2, MAT Array3$ )
```

This reads the cells in rows 7 through 11. The receiving arrays are re-dimensioned as appropriate.

```
INPUT FIELDS "row,col,GRID rows/cols, ROW, RANGE":
            MAT start, MAT end, ( MAT Data1$, MAT Data2$, MAT Data3 )
```

This reads one or more ranges of rows.

A more detailed example of this is:

```
100 ! create and populate a LIST control
200 MAT START(3) : MAT END(3)
210 READ MAT START, MAT END
220 DATA 7,21,33
230 DATA 11,21,38
240 INPUT FIELDS "row,col,LIST rows/cols, ROW, RANGE": MAT START,
           MAT END, ( MAT Array1$, MAT Array2, MAT Array3$ )
```

This reads 12 rows of data ( row 7-11, row 21 and rows 33-38 ).

#### Range Output

The following examples are valid for versions `4.3` and higher. By default, RANGE output refers to rows. The special keyword CELL_RANGE is used to denote the specification of cell ranges. Additionally, the use of scalars versus arrays for start and end values determines important characteristics of the output process.

**Using Scalars For Range Specification**

```
PRINT FIELDS "7,8,GRID 10/75, RANGE": start, end, MAT Data$
```

This replaces the values in rows numbered 'start' through 'end' with the data in MAT Data$. The size of MAT Data$ must be a multiple of the number of columns in the GRID or an error is generated.

```
PRINT FIELDS "7,8,LIST 10/75, RANGE": start, end, (MAT NAME$, MAT CITY$, MAT AGE, MAT WEIGHT)
```

This replaces the values in ROWs numbered 'start' through 'end' with the data from MATs NAME$, CITY$, AGE and WEIGHT. The data arrays must all be dimensioned the same.

#### Insertion and Deletion with RANGE

The number of rows being output do not need to match the number of rows being replaced. To delete a range of rows, output one or more grouped arrays with zero elements.

The following examples are valid for versions 4.3 and higher. Using the following statement, various scenarios are described.

```
PRINT FIELDS "7,8,LIST 10/75, RANGE": start, end, (MAT NAME$, MAT CITY$, MAT AGE, MAT WEIGHT)
```

| Scenario | Result |
|---|---|
| `start=7, end=11`, and the arrays have been DIMed to nine elements | Nine rows replace five, and the total content of the control is expanded by 4 rows. |
| `start=7, end=11`, and the arrays are DIMed to zero elements | Five rows are deleted, and the total size of the control is reduced by 5 rows. |
| `start=7, end=0` (anything less than 7), and the arrays are DIMed to support three rows | Three rows are inserted ahead of row seven and the total content of the control is expanded by three rows. |
| `start=5000, end={any value}`, the control only has 482 rows, and the source arrays are DIMed to support eleven rows | Eleven rows are appended to the end of the control and become rows 483 through 493. |

#### Outputting Ranges of Cells

The following examples are valid for versions 4.3 and higher.

Ranges of cells may be output in conjunction with the CELL_RANGE keyword.

```
PRINT FIELDS "7,8,LIST 10/75, CELL_RANGE": start, end, (MAT NAME$, MAT CITY$, MAT AGE, MAT WEIGHT)
```
— or —
```
PRINT FIELDS "7,8,GRID 10/75, CELL_RANGE": start, end, MAT Data$
```

In this case, start and end specify cells instead of rows. If insertion or deletion is indicated by dimensioning the data arrays to greater or fewer elements than are being replaced, then the data must be a multiple of the number of columns. Insertion and deletion is only valid in terms of rows, even when cell subscripts are used to specify ranges. In such cases, if the cell subscripts are not on row boundaries, an error is generated.

```
PRINT FIELDS "7,8,GRID 10/75, CELL_RANGE": start, start, Data$
```

In this example, the value in one cell is replaced with the content of a scalar.

#### Using Arrays For Range Specification

If the start and end specifications are array denoting multiple ranges, there must be a one to one correspondence between the number of rows specified and those in the data. This method implies replacement only and insertion or deletion is not allowed.

The data flow that this feature was designed to support is one where the user is presented with a LIST or GRID where multiple rows have been either selected or changed before returning control to the program and the program is responding by updating something on those rows.

The program begins by presenting a 2D control to the user and reading the the control with type ROWSUB or SUB. Type SUB only works for GRIDs where all colmns have the same data type. Of course the subscripts are read into a numeric array which BR redimensions as appropriate. Then the program reads the changed or selected data with NOWAIT. (This resets the CHG flags in the control.) The program then changes either row (ROWSUB) or cell (SUB) data and outputs the results using the subscript array as both the start and end specification. Other scenarios are possible but this is the primary intended use.

The following examples are valid for versions 4.3 and higher:

```
100 ! create and populate a GRID --
200 INPUT FIELDS "row,col,GRID rows/cols,ROWSUB,CHG": MAT Rowsubs
       (Reading subscripts does not reset the CHG flags in the control.)
210 INPUT FIELDS "row,col,GRID rows/cols,ROW,CHG,NOWAIT": ( MAT Data1$,
      MAT Data2, MAT Data3$ )
        BR redimensions the receiving arrays as needed.
       (Reading the data also resets the CHG flags in the control.)

220 ! process the changed rows now present in the data arrays --
300 PRINT FIELDS "row,col,GRID rows/cols,RANGE": MAT Rowsubs,
                 MAT Rowsubs, ( MAT Data1$, MAT Data2, MAT Data3$ )
```

This outputs the updated rows.

#### Grid and List BR_VB Similarities

Before introducing grids and lists in BR, similar effects could be achieved using BR_VB to work with Visual Basic. If you were familiar with BR_VB, the following notes may be of interest:

Grid and list controls work like the BR_VB interface except headers now specify the form of each column and a new input type has been added:

**A multi column LISTview:**

```
00100 PRINT FIELDS "10,20,LIST 10/80,HEADERS[,hdrs][,fkey]": (MAT HEADINGS$, MAT WIDTHS, MAT FORMS$)
```

**Note:** Widths are expressed in character positions, not percentages like they are in BR_VB.

**The populate operation:**

```
00200 PRINT FIELDS "10,20,LIST 10/80,=": (MAT NAME$, MAT CITY$, MAT AGE, MAT WEIGHT)
```

Read-Ctl type: CNT (in place of CELLROWSUB) returns a single numeric value which is the number of subscripts available to read. In the case of grids, this is the number of cells. In the case of LISTs, this is the number of rows.

```
00110 INPUT FIELDS "10,20,LIST 10/80,ROWCNT,SEL": avail_rows  ! # of selected rows
00120 MAT DATA$(3 * avail_rows)          ! redimension.. 3 cols x selected rows
00130 INPUT FIELDS "10,20,LIST 10/80,ROW,SEL,NOWAIT": MAT DATA$  ! read rows
```

## See Also

- Grids Tutorial *(no corresponding page was found in this tree — link not reconstructed)*
- Error [`0886`](../../90-reference/error-codes/0886.md)
