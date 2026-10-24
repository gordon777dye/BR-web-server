---
title: FileIO_Library
file: FileIO_Library.md
category: 50-libraries
subcategory: 50-libraries/fileio
kind: concept
related: []
provenance: recovered-2b (redirect-collision casualty re-fetched from wiki)
corrections:
  - "2026-09-30: The Disk Date Format paragraph did not say what Julian means. Added that it is a BR day number (a DAYS() value), that DATE(days) is equivalent with this kit's FileIO, and a link to spec.md#disk-date-formats."
  - "2026-10-14 §fnCSVExport: checked against this kit's dev/tools/fileio.brs (def library
    fnCsvExport, line 1753; fnExportToCSV; fnCSVExportDlg) and corrected. The 2nd parameter was
    called SuppressDialog, taking 0 or 1. The source calls it DialogType and acts on four values:
    1 and 3 skip the dialog (1755), 2 pre-ticks Select Columns (2015), 2 and 3 show the column
    picker (1865), and every value but 1 and 3 shows a closing MsgBox (1949). The trailing Launch
    parameter (1772) was missing. Added: a blank Filename$ is replaced by a generated name (1760),
    which the by-value parameter never returns; the function never assigns a return value; the
    CSV is opened with REPLACE; a failed open shows a MsgBox whatever DialogType is (1951);
    dates follow DateFormatExport$ (line 64)."
---
> **See also the source-derived [FileIO_Function_Reference.md](FileIO_Function_Reference.md)** — the
> authoritative list of all **80 `DEF LIBRARY` exports** taken from `fileio.brs`. This online-doc manual
> covers 79 of them in prose; **1** (`FnReadLayoutExtension$`) is source-only and documented there.

The **FileIO** Library began as a project to find a way to reduce the effort associated with making changes to data file layouts. Thanks to the Fileio library, when I have to make a change to a data file layout for my customers today, I can complete the task in under 1 minute, and not a single program needs to be changed in order to continue working with the new file layout. In fact, I don’t even have to update my customer’s data files, as the FileIO library takes care of this for me as well.

The trick is to define each of your file layouts in an ASCII text file layout file that is described below. The FileIO Library will parse through your file layouts, and it will instruct your programs how to access the file data after it has been read. It will also automatically detect when you make changes to the file layout, and it will update your customer’s data files on the fly to make sure they have the latest version. Finally, it contains a DataCrawler that you can use to examine the contents of any of your BR data files in a raw format.

For more information about the FileIO Library visit the [Sage AX Website](http://www.sageax.com/products/fileio-library/)

To download the latest copy of FileIO, click [here.](http://www.sageax.com/downloads/FileIO.zip)

## Method of Operation

The file IO library parses a formatted text file layout and uses this information to structure the opening and the reading of a file “object”. The word object here is used to refer to all the data in a given record layout in one of your files. This library is easy to use, and provided you follow some simple standards, it will simplify your life immensely.

Your programs will need to define one array for all BR data file form statements and add a snippet of code (given below) to the program for interfacing with with the library. For each file you will need to define a couple of arrays and use the library to open them. From that point on access to data is simple and direct.

### File Object Arrays

First, in your program you must create two arrays to store the file information. If we are dealing with the Color File these would be MAT COLOR$ and MAT COLOR. One will store all the string information about a color, and the other will store the related numeric data. Our working example will involve two files: a Color File and a Color Category File. You should dimension these as follows:

```
 01030    DIM color$(1)*1000,color(1)
 01040    DIM colorcat$(1)*1000,colorcat(1)
```

We're dimensioning the string array elements to 1000 bytes each. This is the length of one field in the color file. The array element length needs to be at least as big as the largest string field in the data file.

However, it is recommended to make sure the length is long enough to handle any field you might eventually add to the file at any point in the future. BR supports multi-line textboxes, so I sometimes add long memo fields to my data files that might be 400 or 800 or even 1000 characters long, therefore 1000 is the length I use now in all my new development.

But anything will work as long as its long enough to handle the largest data field in your file.

### Forms Array

Your programs will need a string variable array to store the form statements associated with reading files. This form statements array will be dynamically generated or expanded whenever the a file is opened. It will say:

```
 01020    DIM form$(1)*255
```

This form statement will be compiled by the FileIO open statement. BR limits all compiloed form statements to 255 bytes, so 255 is sufficient to hold the compiled Forms$ statements.

### Library Linkage

You will also need the library statement:

```
 02020 library "fileio.br": fnopenfile, fnreaddescription$
```

<a id="fnopen-function"></a>
### fnOpen Function

Now, add the following snippet of code to interface with the library. Note that this snippet can be copied in exactly as provided and no customization of it is needed.

Because BR libraries do not share global variables with the programs they are called from, we will need to execute a procedure file whenever we open a file - to set the names of all of our variables. Add the following snippet of code into your program. It will create an FnOpen function that calls the library and runs the proc file. The $$$ at the end of the procfile name tells the procfile to self-destruct after execution. Since this procfile is used simply to return variable information back from the library to the main program, we don’t need it sitting around collecting dust.

```
 99010 OPEN: ! ***** Function To Call Library Openfile And Proc Subs
 99020    def Fnopen(Filename$*255, Mat F$, Mat F, Mat Form$; Inputonly, Keynum, Dont_Sort_Subs, Path$*255, Mat Descr$, Mat Field_Widths,Supress_Prompt,Ignore_Errors,Suppress_Log,___,Index)
 99030       dim _FileIOSubs$(1)*800, _Loadedsubs$(1)*80
 99040       let Fnopen=Fnopenfile(Filename$, Mat F$, Mat F, Mat Form$, Inputonly, Keynum, Dont_Sort_Subs, Path$, Mat Descr$, Mat Field_Widths, Mat _FileIOSubs$, Supress_Prompt,Ignore_Errors,Program$,Suppress_Log)
 99050       if Srch(_Loadedsubs$,Uprc$(Filename$))<=0 then : mat _Loadedsubs$(Udim(_Loadedsubs$)+1) : let _Loadedsubs$(Udim(_Loadedsubs$))=Uprc$(Filename$) : for Index=1 to Udim(Mat _Fileiosubs$) : execute (_Fileiosubs$(Index)) : next Index
 99060    fnend
```

Or, for those with Lexi:  (same but without line numbers)

```
 OPEN: ! ***** Function To Call Library Openfile And Proc Subs
    def Fnopen(Filename$*255, Mat F$, Mat F, Mat Form$; Inputonly, Keynum, Dont_Sort_Subs, Path$*255, Mat Descr$, Mat Field_Widths,Supress_Prompt,Ignore_Errors,Suppress_Log,___,Index)
       dim _FileIOSubs$(1)*800, _Loadedsubs$(1)*80
       let Fnopen=Fnopenfile(Filename$, Mat F$, Mat F, Mat Form$, Inputonly, Keynum, Dont_Sort_Subs, Path$, Mat Descr$, Mat Field_Widths, Mat _FileIOSubs$, Supress_Prompt,Ignore_Errors,Program$,Suppress_Log)
       if Srch(_Loadedsubs$,Uprc$(Filename$))<=0 then : mat _Loadedsubs$(Udim(_Loadedsubs$)+1) : let _Loadedsubs$(Udim(_Loadedsubs$))=Uprc$(Filename$) : for Index=1 to Udim(Mat _Fileiosubs$) : execute (_Fileiosubs$(Index)) : next Index
    fnend
```

### Using FileIO in Your Programs

Now you are ready to process files.   

***You simply open the files by saying:***

```
 04020    let colorfile=fnopen("color",mat color$,mat color,mat form$)
 04030    let colorcatfile=fnopen("colorcat",mat colorcat$,mat colorcat,mat form$,1)
```

***read each file as follows:***

```
 30120    read #colorfile, using form$(colorfile) : mat color$, mat color eof Ignore  
```

***and access the data:***

```
 30180    LET ColorCode$=color$(co_Code) !:
          LET ColorName$=color$(co_Name)
```

### How it Works

The above statements tell the File Library to look in the filelay folder to find the file layout for the Color File, and read it to find out what the Color File looks like. Then it OPENs the Color File, and sets MAT COLOR$ and MAT COLOR to the correct number of elements to hold an entire color record. Finally, it will define several variables that we can use as pointers (subscripts) into these arrays to access the data read into the 2 arrays, and it will assign the file handle to a variable called "colorfile".

The second open statement above will do the same thing to the color category file, except the parameter value "1" tells the function to open readonly. The array subscripts assignment procedure file (passed back from Fileio) will be executed, thereby assigning values to the subscript names in the calling program. So, if I had a file layout such as the following:

```
 color.dat, CO_, 1
 color.key, CODE
 recl=127
 ===================================================
 CODE$,          Color Code,                  C    6
 NAME$,          English Name for Color,      V   30
 CATEGORY$,      General Category of Color,   C    6
 HTML$,          HTML Code for the Color,     C    6
```

Then the functions would do the same thing as the following individual lines of code (assuming the next available file handle was 5):

```
 DIM FORM$(5)*255
 DIM COLOR$(9)*1023, COLOR(1)
 OPEN #5: “Name=color.dat, kfname=color.key”,internal,outin,keyed
 LET FORM$(5)=”form C 6,V 30,V 6,C 6”
 LET FORM$(5)=CFORM$(FORM$(5))
 LET COLORFILE=5
 CO_CODE=1
 CO_NAME=2
 CO_CATEGORY=3
 CO_HTML=4
```

The data is used by referencing the file array, with the subscript name, so the color’s description becomes color$(co_Name).

In the old days, if we wanted to change the file layout of our file, all of the programs that used that file would have to be changed one at a time to use the new file layout. Also, if the order of the fields changed, then all the programs would have to also be changed to use the new fields.

But now, using this function, we can change the file layout all we want. If we later want to insert a field into the file layout before color name, I won’t have to look at this program again; this program will just work fine, because the library maps the subscripts to the actual fields.

Also, the code is easier to read and maintain.

### Example

The whole thing looks like this:

```
 01025    ! Dimension the Arrays
 01030    DIM color$(1)*1023,color(1)
 01040    DIM colorcat$(1)*1023,colorcat(1)
 01050    DIM form$(1)*255
 02000 !
 02020 library "fileio.br": fnopenfile, fnreaddescription$
 04020    let colorfile=fnopen("color",mat color$,mat color,mat form$) ! Open the file
 05000 ! 
 30120    read #colorfile, using form$(colorfile) : mat color$, mat color eof Ignore ! Read the file
 30180    LET ColorCode$=color$(co_Code) !:
          LET ColorName$=color$(co_Name) ! Use the data by referincing it in the file arrays
 80000 !
 90000 ! Every program using fileio needs the following code
 99010  OPEN: ! ***** Function To Call Library Openfile And Generate Subs
 99020     def Fnopen(Filename$*255, Mat F$, Mat F, Mat Form$; Inputonly, Keynum, Dont_Sort_Subs, Path$*255, Mat Descr$, Mat Field_Widths)
 99030        dim _FileIOSubs$(1)*800
 99040        let Fnopen=Fnopenfile(Filename$, Mat F$, Mat F, Mat Form$, Inputonly, Keynum, Dont_Sort_Subs, Path$, Mat Descr$, Mat Field_Widths, Mat _FileIOSubs$)
 99050        for Index=1 to udim(mat _FileIOSubs$) : execute (_FileIOSubs$(Index)) : next Index
 99060     fnend
```

### File Layouts

Now lets inspect the anatomy of a properly formatted file layout. These should be placed in a subdirectory called filelay.
In this example, a farm management system uses a price file to manage seasonal prices:

```
 price.dat, PR_, 1
 price.key, FARM
 price.ky2, ITEM
 price.ky3, FARM/ITEM/GRADE
 price.ky4, DESCRIPTION-U/COST
 recl=127
 ===================================================
 FARM$,          Farm Code (or blank),        C    4
 ITEM$,          Item Code,                   C    4
 GRADE$,         Quality,                     C    4
 X,              Empty,                       X   37
 PRICE,          Default Price,               BH 3.2
 ! default cost is normally zero
 COST,           Default Cost,                BH 3.2
 XOPRICE,        Default Christmas Price,     BH 3.2
 XOCOST,         Default Christmas Cost,      BH 3.2
 MOPRICE,        Default Mothers D Price,     BH 3.2
 MOCOST,         Default Mothers D Cost,      BH 3.2
 VOPRICE,        Default Valentine Price,     BH 3.2
 VOCOST,         Default Valentine Cost,      BH 3.2
 DESCRIPTION$,   Description of Price Rule,   C   30
 #eof#
 additional comments...
```

---

```
 price.dat, PR_, 1
```

The first line contains the name of the Farm Record, a unique string to prefix all of your subscript pointers, and the file version number. The subscript prefix is to ensure that the program knows the difference between the Farm File’s Farm Code, and the Route File’s Route Code. (One will be RT_CODE and the other is FM_CODE).  These are separated by a comma. Spacing does not matter, so adjust your spacing so that it looks nice.

The Version number is used to determine when the data has changed, and an update needs to be made to your data file. Your file layouts should all start at version 0, and each time you want to make a change, you may increment this value by 1.

Each time you open a file with the FILEIO library, it reads the file version number of the file on disk (using the BR version() function), and then it compares it to the version number in your file layout. If your file layout has a higher version number then your existing data file, then the library opens the backup of the file layout for the version of the data file that exists on disk. It makes a backup copy of the existing data file, and creates a new file with the proper version number. Then it reads your records one at a time, and copies all the data from the old file into the new file one field at a time. If a field is dropped from the file layout, that data gets lost. If fields are rearranged, the data is copied and saved in the new file in the new positions. If a new field is added, it starts out blank (or 0).

If you look in the filelay folder, you will notice a version folder. This contains several files ending with a number. For example you may see a color.0, and a color.1 file.

If you run the fnopen function and it can not find your data file (usually because this is a new file and it hasn’t been created yet), *the library will automatically create your file,* based on the information you give in the first part of the file layout.

Also, whenever you make changes to your file layout, the function library will automatically update the data files on disk for you. It does this by renaming the old file, creating a new one with the new version number, and then copying the data from the old one to the new one a record at a time.

Any time it creates a file, or updates the file on disk, it creates a backup of the file *layout*. The first time you run a program that tries to read your new data file, it will create the data file for you and make a backup of the layout, and if the number in your file layout is 0, then it will create, for example, a filelay\version\price.0 file, a backup of your file layout that the library uses to figure out what has changed the next time you try to update the file.

If you wish to make any changes to this data file, first you increment the version number, (in this case make the 0 into a 1). Then change the file layout all you want. You may rearrange fields, add new fields, add or remove keys, or change the record length.

The only step necessary for having your data files updated is to increment the version number every time you make a change to the file layout.

You may make any changes you like to the file layouts, but do not change the names of your existing subscripts. If you change the subscript name, not only will all the programs that reference that subscript be broken, but additionally, the routine will not understand that you are changing the name. It will think you are dropping the old field and adding a new field and any data stored in this location will be lost when the file is updated.

```
 price.key, FARM
```

The second line contains the name of the first key, and a definition telling what the key is based on. These are separated by a comma. The key definition is made up of each of the subscript names in this file that form the keyfields for the file. When the library is called to open a file, if the file does not exist, or if it needs to be updated, a new one will be created. The function will read these subscript names that form your key definitions, and it will calculate the proper key position (KPS=) and length (KLN=) values. Then the create routine will use this information with the Index command to create the new key files.

```
 price.key, FARM
 price.ky2, ITEM
 price.ky3, FARM/ITEM/GRADE
 price.ky4, DESCRIPTION-U/COST
 recl=127
```

Notice that the third key is based on three different fields. These are separated by a “/”. It is important that you use a “/” to separate your keys when you are building a key out of more then one field, because the function uses this “/” to help it make the proper BR syntax for defining complex key fields.

Also, note the "-U" at the end of the fieldname in the 4th key. This indicates that the "Description" part of that key is case insensitive. This translates to using the "U" on part of your key spec in Business Rules.

The file can have as many keys as you want. The function will keep parsing key file names until it reaches the next part of the layout. It opens any OutIn files with all keys so that any changes you may make to the data stored on disk will be properly reflected in all the key files.

The optional RECL= Parameter is read and used whenever a new file is created or an old one is updated. If it is not specified, the record length is calculated from the fields in the layout.

```
 ===================================================
```

The next line in the file is skipped by the parsing routine, and its purpose is to make the file layouts more readable to a programmer.

```
 FARM$,          Farm Code (or blank),        C    4
```

Following the file and key structure, the fields are defined. There are three parameters on each field definition line, and you make one line for each field in your file layout. The first parameter is the subscript name that you will use in your program to refer to this data element. Place a $ at the end of the subscript name for all string elements. Don’t place anything at the end of the subscript name for numeric elements. Note that each of these names will be prefixed by the second parameter of the very first line of this layout.

The second parameter is the description. This description is for the benefit of the programmer, so when the programmer is reading the file layouts, (s)he can tell which field does what. The spaces are ignored, so you may include as many spaces as you wish to make the layout look good. It does seem like good general guidelines would be to limit your layout lines to 255 characters and your descriptions to 80.

The description is also used by the built in DataCrawler, a program that reads any of your data files and displays the entire contents in raw form in a listview. The Descriptions become the headings for each column in the listview.

Those descriptions are also used for the default captions for your fields if you use ScreenIO, a library for building GUI programs that itself builds off of fileio.

The third parameter is the form statement, which is pretty straightforward. Any items with a form statement of type “X” will be ignored, except that the length will still be used to calculate the position on disk of all remaining fields in the record. The library will take X fields into consideration when building the form statement, but not at any other time.

The fourth parameter is optionally a Disk Date Format. You can specify DATE(Julian) if you're storing your dates as BR day numbers (the value `DAYS()` returns; not an astronomical Julian day and not YYDDD) on disk. With the FileIO in this kit, DATE(days) means the same thing. Or you can specify DATE(cymd) or DATE(ymd) or DATE(mdy) or any other valid date spec here, and FileIO will treat this field like a date. See [Disk date formats](spec.md#disk-date-formats).

Your programs will still have to unpack it for you, fileio can't do that because fileio doesn't read the file for you.

However, the data crawler, the automatic updates, and screenIO, are all compatible with these dates specified in your file layout.

If the fourth parameter is anything other then DATE(format), then its treated as a comment and ignored.

The fifth and all later columns, if any, are treated as comments and ignored.

```
 ! default cost is normally zero
```

Comment line text must begin with an exclamation point, but it may be indented. Comment lines may appear anywhere (vertically) and are ignored.   

Blank lines are ignored as well.

```
 #eof#
 additional comments...
```

After the last field definition, an *optional* #eof# line may be specified, in which case any lines after that will be ignored.

```
 FARM$,          Farm Code (or blank),        C    4
 ITEM$,          Item Code,                   C    4
 GRADE$,         Quality,                     C    4
 DUMMY,          Empty,                       X   37
 PRICE,          Default Price,               BH 3.2
 ! default cost is normally zero
 COST,           Default Cost,                BH 3.2
 XOPRICE,        Default Christmas Price,     BH 3.2
 XOCOST,         Default Christmas Cost,      BH 3.2
 MOPRICE,        Default Mothers D Price,     BH 3.2
 MOCOST,         Default Mothers D Cost,      BH 3.2
 VOPRICE,        Default Valentine Price,     BH 3.2
 VOCOST,         Default Valentine Cost,      BH 3.2
 DESCRIPTION$,   Description of Price Rule,   C   30
 #eof#
 additional comments...
```

And that’s all there is to it.

### Support for Dates

As of V2.48, file layouts support dates in any storage formats on disk. Whether you store your dates in Julian or in YMD or MDY or any other format, specify so in the 4th column of your file layouts, using the FileIO Date Keyword. ex: DATE(Julian) or DATE(YMD) or any other valid BR Date Format.

![

When this is specified, it enables the FileIO data exploration tool (Data Crawler) to display the dates in human readable format. This works for both Viewing, and for Editing.

The new Date functionality also supports the File Layout Upgrade facility, allowing you to change the format of your dates on disk and FileIO will handle it automatically, upgrading the field to use the new date format for you.

It works also for Exporting your data files to CSV, and is supported automatically in the FileIO functions that do those exports. It converts the dates on export to a standard format (Default: m/d/cy) that you can specify in your FileIO.Ini File.

And it extends ScreenIO's date features to all date fields, no matter what format they're stored in. (Previously, ScreenIO's advanced date features only worked for dates stored in Julian on disk.)

This update adds two new ini file options:

```
CODE: SELECT ALL
DateFormatExport$='m/d/cy'  ! Format of Dates when Exporting to CSV
DateFormatDisplay$='m/d/cy' ! Format of Dates when displaying in Data Crawler
```

You can use these to specify your preferred Date format for Viewing/Editing, and your preferred Date format for Exporting.

Remember, you can see the full list of FileIO ini file options, by looking in the source code at the top of FileIO.

There is a new optional parameter for all layout reading functions, mat NDateSpec$ and mat SDateSpec$ which correspond with the other arrays, to let you know which fields are date fields, so that you can develop routines in your programs to automatically pack and unpack the dates.

Important Note: Using FileIO, the reading of the data file is still done directly in your programs. So this does not change how your existing programs work. It does not unpack the dates for you in your programs. You still have to do all that.

For this reason, upgrading to the new Date processing will not break any of your current code.

### Debugging Tips

When you're making new layouts, a missing comma can cause FileIO to parse the layout wrong and give you errors. Here are a couple tips to help ensure your layouts are error free before using them in your programs.

- Use the Data Crawler to test your layout. The data crawler is the simplest way to test your new layout without writing any code. It opens it and accesses the file in a very simple and straight forward manor to help identify any errors in the layout that you might have.

- If you have trouble with the form statement, you can't see whats in it because FileIO uses CForm$ to compile your form statement to make your programs run faster. But here's a way to tell what the original form statement was that FileIO generated when it put the strings first and numbers last in your program: Open the file in the Data Crawler. When you get an error, type "Print FormStatement$" to see the original form statement.

This works even if your file is working fine. Any time the file is opened with the data crawler, you can press CTRL-A and then type PRINT FormStatement$ and it will print out the uncompiled form statement for the file.

## Utilities

Now that you have your file layouts defined, you have access to several powerful utilities right out of the box using Fileio. Additionally, several more utilities are available as Add-Ons, including our most popular development tool ScreenIO. You can read more about them in their section below.

But for now, lets take a look at some of the wonderful free utilities that come built into Fileio.

Some of these utilities are accessible from your code via library functions, but the primary way you access any of them is by simply loading the FileIO Library and running it directly.

### DataCrawler

The data crawler is the original utility of FileIO. This utility shows you first a list of all data files allowing you to select one.

Select a data file and press enter, and FileIO will then display a listview containing all the data in the data file. This list is sized based on the size of your main BR window (window 0) automatically to take up the full size available to it, so if you want to see more, try opening window 0 larger before running FileIO.

At the top of the window is a filter box, and you can type anything you want in there and click "Refresh" and it will reread the data file, shortening the list to show only those records that match (case insensitive) what you have typed.

If you have ScreenIO installed, then FileIO's data crawler will take advantage of the included Animation Engine in ScreenIO to animate a loading window while the listview is displaying. If you don't have ScreenIO then FileIO will simply load the listview.

If you don't want to wait for the entire file to load, press ESC to stop the load process.

If the file is empty, FileIO will display a message box letting you know.

This tool is very useful for sorting out data errors. It will allow you to look inside any data file you have a layout for and directly view the data there.

At the bottom of the Data Crawler are several buttons. There's a Jump button that repositions the file by a key you specify and then loads the list with the data from that key on down to the end of the file.

There is a "Columns" button which you can use to decide which columns should show up on the listview. Fewer columns means faster loading so sometimes for large files I press ESC immediately when the file first starts loading to cancel the load. Then I click "Columns" and check only the columns I want to see. Finally I press the "Refresh" button to trigger it to read the file again and this time it loads much faster then before.

Next you'll find an Export button which starts the process for exporting a file to CSV. You can read more on that in the next section. And next to that is a Quit button.

In this example, we loaded the file "Read Only" so it put everything in a listview. But there are times when its useful to fix data errors this way too, especially during development. So if you want to directly edit your data file, on the first page select the file you want to edit and instead of pressing "Enter" or clicking "View", this time press "F5". F5 is the secret Edit button that loads a data file into a grid instead.

You can use the grid to change records, delete them or add them, and in addition to the buttons listed above, it also has an "Import" button for importing a CSV file into this data file.

Any changes you make to the data file are not saved until you click the "Save" button (which also only appears when you're in Edit mode).

In the 01/2015 release of FileIO, each records rec # is displayed in the listview, to aid in debugging bad data problems.

#### Debugging Tip

Any time you're viewing a file layout in the Data Crawler, you can see the Uncompiled Form Statement by pressing CTRL-A to get to an ATTN prompt, and then entering the command:

```
 print FormStatement$
```

and it will print out the original form statement.

#### Another Debugging Tip

The FileIO Datacrawler ignores records that it cannot read. This is to allow for data files that have multiple record layouts in one data file. You make a custom layout for each record type and the data crawler shows just the records that match that type in the file.

However that becomes a problem when you're making a layout to work with an existing data file. Error 726 indicates that something minor in the file layout doesn't match the data on the disk, but these errors are ignored so you might see either an empty data file, or a data file with some records missing. If that happens, you need to see the missing records in order to figure out what is wrong with your layout. ***It's very important that you don't try to use a file layout that isn't quite working right. Make sure your layout works and can read every record of a file that it should read before using it.***

To see the records that could not be read in a file, run the data crawler on the layout, then press CTRL-A to get an ATTN prompt. From there, enter the command

```
 print mat BadRead$
```

and it will print all the records that were ignored because the file layout didn't match them. It prints out the raw data from the file.

#### Function Access to use Data Crawler in your programs

You can use the data crawler in your own programs by using one of the following functions:

- fnDataCrawler - Open a Listview showing the data file
- fnDataEdit - Display the data in an editable grid
- fnShowData - This function does the same thing as the above two, but with many many more options allowing you to customize exactly what appears and exactly what they're allowed to change.

Note: its not recommended to allow your customers to use the data crawler to access your data files directly. There's no way to specify validations or do anything complicated, so unless you're careful, there are lots of ways your customers could use this tool to do damage to your data files. It is a programmer tool only.

If you do decide to use it for your end users, be careful how you implement it.

### Import/Export to CSV

You can use FileIO to export your data files to CSV or import from CSV into your data file. To do this, you want to run the data crawler and select the file layout you're looking for. Then, view it (or press F5 to edit if you want to import something). Click on the Export button and it will ask you to select a file. Once that is selected it will ask a couple other simple questions, and when you've specified the options to your satisfaction, click the Export! button. A new CSV file will be created.

Import is even more simple. To import, you must be in Edit mode (press F5 to select the file instead of the enter key) and then simply select the Import button. It will ask you again to choose the file, and then it will ask you if it should update all files by Record Number (if record number is recorded in the CSV file) or by Key (if the file has keys) or to just Add all information to the file. Select what you want and press Import and the CSV file is added to the BR data file.

#### Function Access to Import/Export from your programs

You can use the following functions to call the Import and Export functionality from your code.

- fnCSVImport
- fnCSVExport

These functions are intended to give you the ability to use our functionality to write your own import and export routines for your customers, because its not a good idea to let your customers run the Data Crawler.

### Generate Layout Wizard

There is also a Generate Layout Wizard utility in FileIO. This utility is there to help you build your file layouts. It is designed to work with a certain style of BR programming that was common in the 80s and 90s. So if your software is written in a style that opens the file directly, and reads/writes the data to a long series of individual variables, the Generate Layout Wizard is for you.

To use it, start by running FileIO. Then, don't select a layout - instead, click on the "Generate Layout" button.

You'll see a screen with a bunch of large text boxes, a small grid, and some buttons.

The first thing you want to do is select the "Browse" button and then select a .wb or .br file that contains a program that reads or writes Most of the File.

When you select one, press the Scan All button and it fileio will search the whole program looking first for all the open strings. It will take the file that is opened the most times and then search for all read statements to that file. It will look for the longest read statement and then find the Form statement associated with that Read statement, and any DIM statements for any variables used.

If you don't like the file its chosen, click the "Open Scratch Pad" button to open the temp work file it uses into the program of your choice (I use myEdit for BRS files). Simply select all the open statements for the file you DO want to build off of, then click the Paste button to paste those open statements into the "Open String" list. After that click "Clear All" to erase what it did on the first search and then click "Scan All" again to rescan the program using this new data file.

You may have to help it a bit, but once it has a proper matching open statement, read statement, form statement and dim statements for any arrays used, press the "Generate Layout" button and it will build a layout for that file.

Finally, load the layout it built and clean up anything if you want, and consider adding better descriptions for each of the fields that you know (as it will use the variable names for both the subscripts AND descriptions in the layout).

When you're all done, click "Done".

#### Functions to Generate Layouts from your code

- fnGenerateLayout
- fnWriteLayout

### Code Templates

One more tool FileIO has to help is the ability to generate code based on your file layouts.

Run FileIO and this time select a file layout and press "Generate Code". A window will pop up listing all the "Code Templates" that are available. Select one (and then select a key if it asks you - some templates require extra info). It looks like nothing happened, but the code you generated is now in your clip board. Paste it somewhere and take a look at it!

Code Templates help us to standardize our ways of doing things, which eventually leads to more and more powerful tools we can use. Code Templates also help ensure we use cleaner code by doing some of the busy-work of writing clean code for us.

#### Writing Code Templates

FileIO ships with several basic code templates. If you want to add your own, take a look in the filelay\templates folder (configurable in fileio.ini) and look at basic.brs. Copy it to your own program and then modify it to have your own code templates in it. Write me at gabriel.bakker@gmail.com with any questions. I want to help.

And if you write good code templates, its easy to share them with the BR community. Anyone can download your templates and place them in this folder and they'll instantly be available for use.

## FileIO Function Reference

*The FileIO Library contains a number of other useful functions.* The following functions are available and you are welcome to use them:

### Primary Functions

#### fnOpen

fnOpen is the primary function that opens a file, and it’s used like so:

*def Fnopen(Filename$*255, Mat F$, Mat F, Mat Form$; Inputonly, Keynum, DontSortSubs, Path$*255, Mat Descr$, Mat FieldWidths, SupressPrompt, IgnoreErrors, SuppressLog)*

Note that all of the parameters after MAT Form$ are optional. If you need to specify a parameter in the middle of the optional parameter group, just list zeroes and empty strings for the intervening unused parameters.

- FileName$ - The filename of the file layout for the file you’re reading.
- MAT F$ - The array that will be used to hold the string data for the file.
- MAT F – The array that will hold the numeric data for the file.
- MAT Form$ - An array of form statements.
- InputOnly – 1 means open for input only. 0 means open for OutIn and open every key file associated with the given data file (this is because all key files need to be open for the keys to be updated on an output) (defaults to 0). Files opened for input process considerably faster than files opened for output. Furthermore when files are opened for input only, alternate key files are *not* opened.
- KeyNum – This tells the function of which key to return the file handle (defaults to 1). Specify -1 to force the file to open Relative, without using its keys. If a file has no keys, it will always be opened Relative.
- DontSortSubs – The function by default, when compiling the Form statement, will sort the string and numeric subs in order to allow for reading the data into an array, and this parameter would turn this functionality off. However, if you are trying to read your data without reading it into an array, you are missing out on some serious efficiencies. You should normally leave this option turned off (0). This is a totally unsupported feature, and should always be set to 0, if it is specified at all.
- Path$ - The path to your data files. This optional parameter can be passed in by the calling function. It is prefixed to the beginning of the paths given in the file layout files. It is useful when your data files can be in different locations depending on the state of your program.
- mat Description$ - This optional parameter provides a way to read the description for each field from the original file layout. If the parameter is not provided, no description data will be returned.
- mat Fieldwidths – This optional parameter will return an array of the calculated display field widths. This number will always be at least large enough to contain the data for this field.
- SuppressPrompt - This optional parameter can be used to suppress the prompt normally given when fileIO creates a file. It can have three values. A value of 0, the default, uses the setting stored in your FileIO fnSettings routine to determine weather or not to prompt on Creation of a new file. A nonzero value always suppresses the prompt. A value of 1 indicates never to create a file if the file doesn't exist. A value of 2 automatically creates the file if the file doesn't exist.
- IgnoreErrors - Normally when fileio opens a data file, if there are errors trying to open the file, it prints them out to the debug console and pauses so that you can try to find out whats going wrong. If you specify 1 for "IgnoreErrors" it will cause Fileio to log those errors instead, and continue loading your program. This will result in the fnOpen file function returning Zero instead of the opened file number, so if you use IgnoreErrors, you need to test to make sure that fnOpen returned a file number before you try to access the file.
- SuppressLog - this optional parameter can be used to suppress writing to the log file for this one specific open statement. I use it for files that will be opened all the time, for example, the menu data file on one of my customers systems. Without this boolean parameter, his log file is quickly filled up with useless information any time his employees look at his menu. I specify this optional parameter to suppress logging anything about the menu file so that I can more easily find the actual programs they've used when looking in the logfile.

***Note: When using fnOpenFile, you really want to call your local function fnOpen, which in turn calls fnOpenFile for you.***  FnOpenFile is for internal use only.

Example:

```
 Let FFILE=FNOPEN(“FARM”,MAT FARM$,MAT FARM,MAT FORM$,0,2)
 Let RFILE=FNOPEN(“ROUTE”,MAT ROUTE$,MAT ROUTE,MAT FORM$,1,3)
 Let CFILE=FNOPEN(“CUSTOMER”,MAT CUSTOMER$,MAT CUSTOMER,MAT FORM$)
```

assuming:

```
 farm.dat has 3 keys: farm.ky1, farm.ky2, farm.ky3
 route.dat has 4 keys: route.ky1 … route.ky4
 customer.dat has 2 keys: customer.ky1, customer.ky2
```

This will perform the following opens and set the following variables:

```
 OPEN #1: “Name=Farm.Dat, kfname=farm.ky2”,internal,outin,keyed
 OPEN #2: “Name=Farm.Dat, kfname=farm.ky1”,internal,outin,keyed
 OPEN #3: “Name=Farm.Dat, kfname=farm.ky3”,internal,outin,keyed
 OPEN #4: “Name=Route.Dat, kfname=route.ky3”,internal,input,keyed
 OPEN #5: “Name=Customer.Dat,kfname=customer.ky1”,internal,outin,keyed
 OPEN #6: “Name=Customer.Dat,kfname=customer.ky2”,internal,outin,keyed
 LET FFILE=1
 LET RFILE=4
 LET CFILE=5
```

This will also resize the arrays, set the form statement, and create all the subscripts to make accessing the data clear and simple, as in the above example. The KEYNUM parameter is where you list the key file you would like to use for reading and writing. The extra keys are opened to ensure that all keys get updated properly when the file is changed.

Example:

```
 DIM FORM$(1),PRICE$(1)*255,PRICE(1),
 DIM DESCRIPTION$(1)*80,FIELDWIDTHS(1)
```

```
 Let PRICEFILE=FNOPEN(“PRICE”,MAT PRICE$,MAT PRICE,MAT FORM$,0,2,0,"",MAT DESCRIPTION$)
```

Assuming the Price File layout (filelay\price) contains:

```
 price.dat, PR_, 1
 price.key, FARM
 price.ky2, ITEM
 price.ky3, FARM/ITEM/GRADE
 recl=127
 ===================================================
 FARM$,          Farm Code (or blank),        C    4
 ITEM$,          Item Code,                   C    4
 GRADE$,         Quality,                     C    4
 DUMMY,          Empty,                       X   37
 PRICE,          Default Price,               BH 3.2
 COST,           Default Cost,                BH 3.2
 XOPRICE,        Default Christmas Price,     BH 3.2
 XOCOST,         Default Christmas Cost,      BH 3.2
 MOPRICE,        Default Mothers D Price,     BH 3.2
 MOCOST,         Default Mothers D Cost,      BH 3.2
 VOPRICE,        Default Valentine Price,     BH 3.2
 VOCOST,         Default Valentine Cost,      BH 3.2
 DESCRIPTION$,   Description of Price Rule,   C   30
```

This will perform the following opens and set the following variables:

```
 OPEN #1: “Name=Price.Dat, kfname=Price.ky2”,internal,outin,keyed
 OPEN #2: “Name=Price.Dat, kfname=Price.ky1”,internal,outin,keyed
 OPEN #3: “Name=Price.Dat, kfname=Price.ky3”,internal,outin,keyed
 let PRICEFILE=1
 let PR_FARM=1
 let PR_ITEM=2
 let PR_GRADE=3
 let PR_DESCR=4
 let PR_PRICE=1
 let PR_COST=2
 let PR_XOPRICE=3
 let PR_XOCOST=4
 let PR_MOPRICE=5
 let PR_MOCOST=6
 let PR_VOPRICE=7
 let PR_VOCOST=8
 MAT FORM$(1)
 MAT PRICE$(4)
 MAT PRICE(8)
 MAT DESCRIPTION$(12)
 MAT FIELDWIDTHS(12)
 let FORM$(1)=CFORM$(”form C 4,C 4,C 4,POS 74,C 30,POS 50,BH 3.2,BH 3.2,BH 3.2,BH 3.2,BH 3.2,BH 3.2,BH 3.2,BH 3.2”)
 let Description$(1)= “Farm Code (or blank)”
 let Description$(2) = “Item Code”
 let Description$(3) = “Quality”
 let Description$(4) = “Description of Price Rule”
 let Description$(5) = “Default Price”
 let Description$(6) = “Default Cost”
 let Description$(7) = “Default Christmas Price”
 let Description$(8) = “Default Christmas Cost”
 let Description$(9) = “Default Mothers D Price”
 let Description$(10) = “Default Mothers D Cost”
 let Description$(11) = “Default Valentine Price”
 let Description$(12) = “Default Valentine Cost”
 let FieldWidths(1) = 4
 let FieldWidths(2) = 4
 let FieldWidths(3) = 4
 let FieldWidths(4) = 30
 let FieldWidths(5) = 8
 let FieldWidths(6) = 8
 let FieldWidths(7) = 8
 let FieldWidths(8) = 8
 let FieldWidths(9) = 8
 let FieldWidths(10) = 8
 let FieldWidths(11) = 8
 let FieldWidths(12) = 8
 
```

There are a few things I’d like to point out about the example above. First, you will notice that the form statement jumps around to put all the strings first, and then the numbers last. This is why it has a “POS 74, C 30,POS 50”. Then notice that the subscripts for the string variables are 1 .. 4, and the subscripts for the numbers are 1 .. 8. Finally, the order of the Description and FieldWidth fields also match the sorted positioning of the Form Statement.

The reason that we sort our form statements is so that BR will allow us to read the file into arrays by saying:

```
 Read #pricefile, using form$(pricefile) : mat price$, mat price
```

Without resorting, the above statement would give a conversion error as BR attempted to put the PR_PRICE field inside mat price$(4). However, because we have reordered the form statement, we are able to read them safely into two arrays, and then we will be able to use the values without caring what position they are in the file, by simply saying PRICE$(PR_DESCRIPTION) when we want the description, and PRICE(PR_PRICE) when we want the pr_Price field.

Another thing you may notice about the above example is that it gives the calculated display length for the numeric fields as 8, when on the disk (and in the file layout) they are listed as BH 3.2. The reason for this is the program looks at the BH 3, and figures that a number that takes up 3 bytes on disk has a potential maximum size of 256**3 or 16,777,216, and therefore will need up to 8 characters of screen display space to view.

Finally, note that any field with a form statement of X is ignored by the library, except that the blank space is used when building the FORM statement.

#### fnCloseFile

This function will close the specified file number and all keys that were opened with the file.  The purpose of this function is to facilitate the closing of the extra keys that are opened when you open a file for OutIn with the library. There is no need to use this for files opened for input because it is easier to just close the file directly. Secondary keys are not opened by FileIO for files opened for input only.

You must give the function the name of the file layout. It uses this information to determine how many keys were opened, and how many it must therefore close.

Then it basically starts at the file number you gave it, and closes the next X files that were opened with the same file name as this, where X is the number of keys associated with this file.

The syntax is:

*fnCloseFile(filenumber,filelay$;path$)*

- FileNumber – The filenumber of the file you are trying to close.
- FileLay$ - The name of the file layout for this file. This is used to determine how many keys the file would have been opened with and therefore how many we now need to close.
- Path$ - Optional Alternate Path. Use to close files that were opened using the open file's optional alternate path parameter.

#### fnGetFileNumber

FnGetFileNumber is a simple function to find a valid unused file handle. If you use this function in all of your programs, they will become much more portable, as you will never have to worry about your file handles fighting with each other. The function will return 0 if no free file number was found (but with 999 of them available now, I have never seen it happen).

*fnGetFileNumber(;X,Count)*

- X – This optional parameter will specify where to start looking.
- Count - This optional parameter will specify how many file numbers to find in a row. If count is 3, then fnGetFileNumber will return the first filenumber in the first gap of three unused file numbers that it finds.

### File Reading Helper Functions

These functions perform various useful calculations to aid in interacting with data files when you're using fileio.

#### fnBuildKey$

This function will return the key for a given record in a data file. It actually reads the file layout and builds the key to match the layout.

*FnBuildKey$(Layout$, Mat F$, Mat F; Keynum)*

- Layout$ - the name of the data file to build the key for.
- Mat F$ - the string array of the file object
- Mat F - the numeric array of the file object
- KeyNum - This optional parameter specifies which of the key files in the given layout the key should be built for.

To use this, you want some code like in the following example:

```
 mat customer$=("") : mat Customer=(0)
 let customer$(cu_name)=CustName$
 let customer$(cu_phone)=CustPhone$
 read #customer, using form$(Customer), key=fnBuildKey$("customer",mat Customer$,mat Customer,2) : mat Customer$, mat Customer nokey KeyNotFound
 ! The above code assumes that the second key of the Customer file is based on the Name and Phone fields.
```

By using this logic you are able to avoid directly specifying the key in your code - which means that even if the key changes in the future, as long as your code specifies enough information, it will still find the correct key. In our example, even if we dropped the phone number from the key in the future, or even if we expand the length of the Customer Name field, our code would still work and fnBuildKey$ would still build the correct key without us having to look at or change our code again.

This kind of reasoning is central to the fileio system, which, when implemented properly, ensures that you can change your data files in any way you need to in the future, without breaking your existing programs.

#### fnUniqueKey

This function tests to see if a given key is unique to the specified file. This function is very useful for situations where you need to ensure that the user-entered key is unique.

*fnUniqueKey(Fl,key$*255)*

- FL – The file number of the opened file.
- Key$ - This is the key to test. If this key is the key for a preexisting record in the file, the function will return false. If this key can not be found in the file, the function will return true.

#### fnMakeUniqueKey$

This function generates a unique key for a given file. This is useful if you do not care what the key is, but it needs to be unique. I use this function in situations where the user never needs to know what the given key is.

This function reads the key length for the given file. Then it returns a string that is the right length, which is generated by counting in binary until a key is found that does not appear in the file. The first key found for a 4 byte key field would be chr$(0)&chr$(0)&chr$(0)&chr$(0). If that key was already in use in the file, the function would return chr$(0)&chr$(0)&chr$(0)&chr$(1). If that one was also in use, it would then try chr$(0)&chr$(0)&chr$(0)&chr$(2), and so on until it found one that wasn’t in use.

*FnMakeUniqueKey$(fl)*

- FL – This is the file number of the opened file for the desired key.

#### fnKey$

This function formats the key for the given file number. All it does is ensure the key is the correct length. You should use fnBuildKey$ instead to properly build the correct key for the record you want to read.

*FnKey$(FileNumber, Key$)*

- FileNumber - the file number we are formatting the key for
- Key$ - the key we are trying to format.

#### fnNotInFile

This function will determine if a non-key element in a line is unique. It works almost exactly like fnUniqueKey specified above, except that it allows you to enter the subscript value of the element you are checking for uniqueness. You can use this to look for uniqueness in any field, not just in the key field. Additionally, the search engine used by this function looks for a partial match, and will only return true if the given string is not found anywhere in the specified element for the given file.

*fnNotInFile(string$*100,filename$,sub)*

- String$ - Value to check for uniqueness in this file.
- Filename$ - This is the name of the file layout of the file you want to check. This file does not have to be open in order for you to search it, because the function will open it for you.
- Sub – This is the subscript value of the element you are checking.

#### fnSortKeys

This function takes an array of Primary Keys indicating records in the data file, and resorts it into the order you would have expected using one of the other keys for your data file.

For example: Lets say you had a customer file, and the first key was Customer Code and the second key was Customer Last Name. This function would take an array of Customer Codes and sort it into Last Name order.

This function requires the file to already be opened (which is usually the case when you have an array of keys from that file).

*fnSortKeys(mat Keys$,Layout$,DataFile,mat F$,mat F,mat Form$;KeyNum)*

- mat Keys$ - the array of keys. These keys are based on whatever key the file was opened with in DataFile.
- Layout$ - the file layout for the file.
- DataFile - the open file number matching the key file that matches mat Keys$.
- mat F$ - array sized to hold the strings from the data file. This is the array you get back from fnOpen.
- mat F - array sized to hold the numerics from the data file. This is the array you get back from fnOpen.
- mat Form$ - array of form statements, that you get back from fnOpen.
- KeyNum - This is the key that we'll sort based on. If not given, the first key listed in the layout is assumed.

### File Reading Functions

These functions actually read information from your data file and return it. These functions can be used to simplify the logic in your programs for many common tasks.

#### fnReadAllKeys

This function will read through a file, returning the specified element(s) from each record into (a) dynamically dimensioned array(s). For example, I could tell it to give me the Inventory Code for every inventory item in my database in one array, while placing the Inventory Description (name) for each item into the corresponding position in another array.

*fnReadAllKeys(Fl,mat f$,mat f,mat fm$,sub1,mat out1$;sub2,mat out2$)*

- Fl – The file handle for the already opened file in question.
- mat F$ - Work array with a size that corresponds to the number of string elements in the record (this is calculated automatically in the Open statement, if you used this library to open the file).
- mat F – Work array with a size that corresponds to the number of numeric elements in the record (this is calculated automatically in the Open statement, if you used this library to open the file).
- mat fm$ - Array of Forms statement. FM$(FL) must be the form statement for this file (this is calculated automatically in the Open statement, if you used this library to open the file).
- Sub1 – Subscript of the element to return in the first array
- mat out1$ - Array in which to return the data. This array will be resized to match the number of records in the file.
- Sub2 – Subscript of the element to return in the second array. This is optional. If it is specified, you must give MAT out2$, or BR will return an error.
- mat out2$ - Array in which to return the second (optional) parameter. This array will be resized to match the number of records in the file. This parameter MUST be provided when Sub2 is given (non-zero). This parameter will not be used if Sub2 is not given or is given as 0.

For example:

```
 FnReadAllKeys(InventFile,mat Invent$,mat Invent,mat Form$,IN_Code,mat InvtList$,IN_Name,mat InvtNames$)
```

#### fnReadMatchingKeys

This function will read through a file, returning the specified element(s) from each record where the key matches the specified key into (a) dynamically dimensioned array(s). This function is the same as the above function except this one will filter the results, returning only those records where the key matches the specified key.

*fnReadMatchingKeys(Fl,mat f$,mat f,mat fm$,key$,keysub,sub1,mat out1$;sub2,mat out2$)*

- FL – The file handle for the already opened file in question.
- mat F$ - Work array with a size that corresponds to the number of string elements in the record (this is calculated automatically in the Open statement, if you used this library to open the file).
- mat F – Work array with a size that corresponds to the number of numeric elements in the record (this is calculated automatically in the Open statement, if you used this library to open the file).
- mat fm$ - Array of Forms statement. FM$(FL) must be the form statement for this file (this is calculated automatically in the Open statement, if you used this library to open the file).
- Key$ - Only records where the key field matches key$ will be returned.
- Keysub – This tells the function which element is the key element for this particular file number.
- Sub1 – Subscript of the element to return in the first array.
- MAT out1$ - Array in which to return the data. This array will be resized to match the number of records in the file.
- Sub2 – Subscript of the element to return in the second array. This is optional. If it is specified, you must give MAT out2$, or BR will return an error.
- mat out2$ - Array in which to return the second (optional) parameter. This array will be resized to match the number of records in the file. This parameter MUST be provided when Sub2 is given (non-zero). This parameter will not be used if Sub2 is not given or is given as 0.

#### fnReadAllNewKeys

This function will read through a file, returning the specified element(s) from each record that isn’t already there into (a) dynamically dimensioned array(s). This function is the same as the above function, except this one will filter the results returning only those records that don’t already exist in the array (eliminating duplicates).

*FnReadAllNewKeys(Fl,mat f$,mat f,mat fm$,sub1,mat out1$; dont_reset,sub2,mat out2$)*

- FL – The file handle for the already opened file in question.
- MAT F$ - Work array with a size that corresponds to the number of string elements in the record (this is calculated automatically in the Open statement, if you used this library to open the file).
- MAT F – Work array with a size that corresponds to the number of numeric elements in the record (this is calculated automatically in the Open statement, if you used this library to open the file).
- MAT fm$ - Array of Forms statement. FM$(FL) must be the form statement for this file (this is calculated automatically in the Open statement, if you used this library to open the file).
- Sub1 – Subscript of the element to return in the first array.
- MAT out1$ - Array in which to return the data. This array will be resized to match the number of records in the file.
- Dont_reset – By default the array will clear the contents of the arrays that are passed in. This Boolean flag will instruct the function to not empty the passed in arrays.
- Sub2 – Subscript of the element to return in the second array. This is optional. If it is specified, you must give MAT out2$, or BR will return an error.
- MAT out2$ - Array in which to return the second (optional) parameter. This array will be resized to match the number of records in the file. This parameter MUST be provided when Sub2 is given (non-zero). This parameter will not be used if Sub2 is not given or is given as 0.

#### fnReadFilterKeys

This function by Mikhail Zheleznov is a modification of the above functions. Like its predecessors, it reads an entire file, populating the specified arrays with data from all or some of the records in the file. The given subscripts specify which fields to return from each record. The key given specifies search criteria for the records. The filter specifies filtering criteria that can be preformed on the data before it is returned.

*FnReadFilterKeys(Fl,Mat F$,Mat F,Mat Fm$,Key$,Keyfld,Sub1,Mat Out1$;Filter$,Filter_Sub,Readlarger,Sub2,Mat Out2$, Sub3, Mat Out3$, Sub4,Mat Out4$)*

- FL – The file handle for the already opened file in question.
- MAT F$ - Work array with a size that corresponds to the number of string elements in the record (this is calculated automatically in the Open statement, if you used this library to open the file).
- MAT F – Work array with a size that corresponds to the number of numeric elements in the record (this is calculated automatically in the Open statement, if you used this library to open the file).
- MAT fm$ - Array of Forms statement. FM$(FL) must be the form statement for this file (this is calculated automatically in the Open statement, if you used this library to open the file).
- Key$ - The key to search for in the read statements
- Keyfld – the subscript of the key field in the data file. This must match the key field specified in the data file otherwise the function won’t work.
- Sub1 – Subscript of the element to return in the first array.
- MAT out1$ - Array in which to return the data. This array will be resized to match the number of records in the file.
- Filter$ – This optional parameter identifies matches to search for in the records. It works in conjunction with Filter_Sub
- Filter_Sub – This parameter specifies which field to look for in the records for matches to Filter$. Only records which have Filter$ in the specified field will be returned.
- Sub2 – Subscript of the element to return in the second array. This is optional. If it is specified, you must give MAT out2$, or BR will return an error.
- MAT out2$ - Array in which to return the second (optional) field. This array will be resized to match the number of records in the file. This parameter MUST be provided when Sub2 is given (non-zero). This parameter will not be used if Sub2 is not given or is given as 0.
- Sub3 – Subscript of the element to return in the third array. This is optional. If it is specified, you must give MAT out3$, or BR will return an error.
- MAT out3$ - Array in which to return the third (optional) field. This array will be resized to match the number of records in the file. This parameter MUST be provided when Sub3 is given (non-zero). This parameter will not be used if Sub3 is not given or is given as 0.
- Sub4 – Subscript of the element to return in the fourth array. This is optional. If it is specified, you must give MAT out4$, or BR will return an error.
- mat out4$ - Array in which to return the fourth (optional) field. This array will be resized to match the number of records in the file. This parameter MUST be provided when Sub4 is given (non-zero). This parameter will not be used if Sub4 is not given or is given as 0.

This function was written by Mikhail Zheleznov for the fileIO library.

#### fnReadDescription$

*fnReadDescription$(Fl,Subscript,key$,mat F$,mat F,mat Form$)*

- Fl – File Handle for file to use (Route File).
- Subscript – Index of field in record to use (should be taken from file layout) (RT_NAME, which should equal 2 after opening routefile (unless we change the file layout later)).
- key$ - Item that should match a key in this file somewhere (in this case it is the route code from the farm record).
- mat F$ & mat F - Work Variables to hold a file record from the file we are reading they have to be dimensioned properly, which is why we use our colorcat$ and our colorcat for these parameters.
- mat Form$ - This will need to be our array of form statements, so the function can read the file properly.

Lets take a look at how this function works:

In the example program I used above, I am reading the Color File to get details about each color. The color file contains a colorcat code field, but I want to display the colorcat description. The colorcat file contains a few details about a color category, and it is indexed based on colorcat code:

```
 route.dat, RT_
 route.key, CODE
 recl=512
 ===================================================
 CODE,           Routing Code,                C    6
 NAME,           Routing Name Description,    C   30
 MOFT,           T/A/C (truck/air/courier),   C    1
 SHIPPINGDAY,    Day of Week for Shipping,    C    7
```

Now, as you know, in the above example, we have already opened the ColorCat File, and we have opened and read a Color record.

```
 04020    let colorfile=fnopen("color",mat color$,mat color,mat form$)
 04030    let colorcatfile=fnopen("colorcat",mat colorcat$,mat colorcat,mat form$,1)
```

```
 30120       read #colorfile, using form$(colorfile) : mat color$, mat color eof Ignore
 30180       LET ccode$=color$(CO_CODE) !:
             LET Name$=color$(CO_NAME)
```

Now all that’s left to do is to take the Color File’s ColorCat code and use it to look up the ColorCat File’s description.

```
 30190 LET ColorCat$ = fnReadDescription$(ColorCatFile, CC_NAME, Color$(CO_CATEGORY),
   mat ColorCat$, mat ColorCat, mat form$)
```

#### fnReadUnopenedDescription$

This function accomplishes the same thing as fnReadDescription except that it opens the data file for you. It is slower then FnReadDescription$, but it is easier to use.

*FnReadUnopenedDescription$(Layout$,key$*255;Field)*

- Layout$ - the layout of the file we are reading
- key$ - the value of the key field in the record to be read
- Field - the element of the data file to return. If not given, this defaults to 2, so sometimes it is a good idea to design your data files so that string field number two is a descriptive field, like Name or Description.

This function only works on the first key file for each data file. This function is a convenience function but it is slow because it opens the file and closes it for each call. Opening a file is one of the most time consuming program operations.

#### fnReadNumber

fnReadNumber does the same thing that ReadDescription does except it reads a numeric field instead of a description.

Lets take a look at how this function works:

*fnReadNumber(Fl,subscript,key$,mat F$,mat F,mat fm$)*

- Fl – File Handle for file to use (Route File).
- Subscript – Index of field in record to use (should be taken from file layout).
- Key$ - Item that should match a key in this file somewhere.
- mat F$ & mat F - Work Variables to hold a file record from the file we are reading. They have to be dimensioned properly by fnOpen.
- mat Fm$ - This will need to be our array of form statements, so the function can read the file properly.

#### fnReadUnopenedNumber

This function accomplishes the same thing as fnReadNumber except that it opens the data file for you. It is slower then FnReadNumber, but it is easier to use.

*fnReadUnopenedNumber(Layout$,key$*255;Field)*

- Layout$ - the layout of the file we are reading
- key$ - the key of the record to be read
- Field - the element of the data file to return. If not given, this defaults to 2.

#### fnReadRelativeDescription$

This function is the same as fnReadDescription$ but for Relative Files.

*fnReadRelativeDescription$(FileNumber,SubscriptToRead,RecordNumber,mat F$,mat F,mat form$)*

- Filenumber - The file number of the open data file
- SubscriptToRead - The subscript to read
- RecordNumber - the Record number to read
- mat F$ and mat F - the arrays to hold the data. They must match the dimensions and should be set with fnOpen.
- mat form$ - the forms array is also set by fnOpen.

#### fnReadRelUnopenedDescription$

This is the same as ReadUnopenedDescription$ but for Relative Files.

*fnReadRelUnopenedDescription(Layout$,RecordNumber;Field)*

- Layout$ - The file layout
- RecordNumber - the record to read
- Field - the field subscript to read

#### fnReadRelativeNumber

This is the same as fnReadNumber but for Relative Files.

*fnReadRelativeNumber(FileNumber,SubscriptToRead,RecordNumber,mat F$,mat f,mat Form$)*

- Filenumber - The file number of the open data file
- SubscriptToRead - The subscript to read
- RecordNumber - the Record number to read
- mat F$ and mat F - the arrays to hold the data. They must match the dimensions and should be set with fnOpen.
- mat form$ - the forms array is also set by fnOpen.

#### fnReadRelUnopenedNumber

This is the same as fnReadUnopenedNumber but for Relative Files.

*fnReadRelUnopenedNumber(LayoutName$,RecordNumber;Field)*

- Layout$ - The file layout
- RecordNumber - the record to read
- Field - the field subscript to read

#### fnReadRecordWhere$

This function returns the record where the given element matches the given value. It does not depend on any key files, and it can be used to locate a record based on any element. However, it loops through the entire data file to do this and it could be a bit slow for large data files. This function opens the file for you, so the file does not have to be already opened.

*FnReadRecordWhere$(Layout$,SearchSub,SearchKey$*255,ReturnSub)*

- Layout$ - the layout of the file we are searching
- SearchSub - Subscript of the element to look in
- SearchKey$ - The value we are looking for
- ReturnSub - Subscript of the element to return

### FileIO Utility Functions

#### fnDataCrawler

This function launches the Data Crawler as a function, so you can make your own programs link to it. Special thanks to Mikhail Zheleznov for turning the DataCrawler into a library function.

*fnDataCrawler(Layout$;SRow$,SCol$,Rows$,Cols$)*

#### fnDataEdit

This function is the same as fnDataCrawler only it opens a Grid for editing.

*fnDataCrawler(Layout$;SRow$,SCol$,Rows$,Cols$)*

#### fnShowData

This function builds a list or a grid in a floating window that is tied to a data file. It uses the same function that the datacrawler uses, but its much more customizable. All other datacrawler functions are just wrappers for this one.

The first parameter is the only required parameter.

*def library fnShowData(FileLay$;Edit,sRow,sCol,Rows,Cols,KeyNumber,Caption$*127,Path$*255,KeyMatch$*255,SearchMatch$*255,CallingProgram$*255,mat Records,mat IncludeCols$,mat IncludeUI$,mat ColumnDescription$,mat ColumnWidths,mat ColumnForms$,DisplayField$*80,mat FilterFields$,mat FilterForm$,mat FilterCompare$,mat FilterCaption$,mat FilterDefaults$,mat FilterKey)*

- FileLay$ - the file layout you want to display
- Edit - 1 for Edit (Grid) and 0 for View (Listview)
- sRow, sCol - the start position. if not given, its centered. If given but out of bounds, they'll be automatically adjusted to fit the grid on the screen.
- Rows, Cols - the size. If not given, defaults to fullscreen. If given but not big enough to fit the UI elements you request, they're automatically adjusted to fit everthing.
- KeyNumber - the Key to use when reading the data, used with other parameters. If not given, the file is read Relative for faster performance. Required if KeyMatch$ is given.
- Caption$ - the Caption to display, defaults to FileIO's Datacrawler
- Path$ - Alternate path to use for data files (Prepended to the name found in the layout)
- KeyMatch$ - Show only records that match this key. You can use Partial Keys. If this parameter is given, you must also give KeyNumber (above).
- SearchMatch$ - Show only records that contain this substring in them anywhere
- CallingProgram$ - used for logging purposes, pass in the system function Program$
- mat Records - Show only these records in the Grid. Use it to control exactly what the user sees.
- mat IncludeCols$ - Show only these columns. These column names must match the subscript names from the file layout.
- mat IncludeUI$ - Which UI Options to show. Build this array with one element for each optional UI element to include. Explanations of UI elements follow:
  - "ColumnsButton" - adds a Select Columns button that the user can use to modify which columns appear on the list.
  - "ExportButton" - adds an Export to CSV button that exports the data to a CSV file.
  - "ImportButton" - adds an Import from CSV button that imports from the CSV file.
  - "AddButton" - adds a button that can be used to add records to the data file.
  - "SaveButton" - adds a button allowing the user to save changes
  - "DeleteButton" - adds a button allowing the user to delete a row
  - "KeyButton" - adds a button allowing the user to jump to a specified position by key or by record number (depending on if the file is opened keyed or not)
  - "QuitButton" - adds a Quit button to the screen (the Esc key also quits)
  - "Search" - adds a case insensitive search box to the screen.
  - "Border" - adds a border around the screen
  - "Caption" - adds a caption. (If you specify a caption, this is automatically turned on. If you don't specify a caption but turn on caption here, then FileIO uses the default FileIO data crawler caption.
  - "Recl" - adds the Recl to the caption
  - "Position" - adds the positions to the field descriptions in the column headings.
- mat ColumnDescription$ - Show these captions. If blank, use the descriptions from the layout
- mat ColumnWidths - Use these widths for the data, if not given, calculate from the file layout
- mat ColumnForms$ - Display Format for the data, including DATE and FMT and PIC
- mat DisplayField$ - Counter Field to display on the Loading Window. If its a field with an associated DATE ColumnForms$ value, that column form will be used when displaying the Counter Field. It can be any of the following:
  - REC - this will display the current "REC/LREC" data in the loading window.
  - READCOUNT - this will display the "Record Count / LREC" in the loading window.
  - FINDCOUNT - this will display the number of records that match the current search criteria by itself in the loading window.
  - A Field Name - one of your field names will display that field value in the loading window
  - A string literal - anything else will display as a string in the loading window, so you could put something like "Loading, please wait" here and it will display.
- mat FilterFields$ - Contains the subscript of the field to compare to
- mat FilterForm$ - Contains the format of the field to compare to
- mat FilterCompare$ - Contains the comparison type ("<>" or ">" or "=" or ">=" or "*") (* means do a substring search)
- mat FilterCaption$ - The caption for the filter box
- mat FilterDefaults$ - The default value for the filter information
- mat FilterKey - The action to use when filtering the data this way (0 means simple exclude, 1 means start here, -1 means stop here)
  - The final five arrays can be used to add user filter boxes to the data grid. You need one element in each array for every custom user filter box on the screen.

#### fnBeginAudit

The FileIO Compare routine is available and can be called from within your programs. To do so, call fnBeginAudit to mark the Start of the compare, then do whatever you need, then run fnCompare to compare everything that has changed between when you ran fnBeginAudit and when you ran fnCompare.

See the documentation for more details.

#### fnCompare

See the documentation for more details.

#### fnCSVImport

This function calls the FileIO Import routine, the same one that you get from the Datacrawlers Import Button.

*fnCsvImport(Layout$*64;SuppressDialog,FileName$*300,ImportModeKey)*

- Layout$ - The file layout to import into
- SupressDialog - 1 to Supress the Import Dialog
- FileName$ - the name of the CSV file (Required if Dialog is Suppressed)
- ImportModeKey - the Import Mode Key (Required if Dialog is Suppressed)
  - -1 - Add all records to the file
  - 0 - Update by Record Number (The file must contain a RecNum column and it must be first)
  - 1+ - Any positive number means Update by that Key (as listed in the layout).

<a id="fncsvexport"></a>
#### fnCSVExport

This function exports a data file to a CSV file.

*fnCsvExport(Layout$*64;DialogType,Filename$*300,IncludeRecNums,KeyNumber,StartKey$,KeyMatch$,Startrec,mat Records,SearchMatch$,Launch)*

- Layout$ - The File Layout to Export
- DialogType - which screens the export shows:
  - 0 - the Export to CSV dialog (file name, Include Record Numbers, Select Columns), then an
    "Export complete!" message box. The user can tick Select Columns, which then brings up the
    column picker.
  - 1 - no screens at all. This is the only value that runs unattended.
  - 2 - as 0, with Select Columns already ticked.
  - 3 - no dialog, but the column picker.
- Filename$ - the output file name. With DialogType 1 or 3, a blank name is replaced by a
  generated one (`@:csvexpt…csv`). Filename$ is passed by value, so the caller is not told the
  generated name: pass a name when you need to find the file afterwards. With DialogType 0 or 2,
  a blank name makes the dialog open a Save As file browser first.
- IncludeRecNums - Include a column with the Record Numbers in it. With DialogType 0 or 2, the
  dialog's Include Record Numbers box sets this.
- KeyNumber - Use this key when reading the data for export
- StartKey$ - Start with the record that matches StartKey$
- KeyMatch$ - Export only the record(s) that match KeyMatch$
- StartRec - Start with this Record Number
- mat Records - Export only these records
- SearchMatch$ - Export only records containing this search string anywhere in them
- Launch - 1 to open the finished CSV in the operating system's default program
  (`sy -C -M start`). Leave it 0 in unattended runs.

Behaviour worth knowing:

- **The return value is always 0.** The function never assigns one, so it cannot be used to test
  whether the export worked. Check for the output file instead.
- **An existing file of that name is overwritten.** The CSV is opened with `REPLACE`
  (`recl=32000`).
- **If the file cannot be opened**, a "could not open output file" message box appears, with any
  DialogType, 1 included.
- **Dates are written in the `DateFormatExport$` setting's format** (default `m/d/cy`; see the
  date settings above).

#### fnExportListViewCsv

Exports the contents of the specified Listview in CSV format.

*fnExportListViewCsv(Window,Spec$;GenFileName,Delim$,FileName$*255)*

- Window - The Window containing the listview.
- Spec$ - The Spec identifying the listview.
- GenFileName - Flag telling weather or not to generate the file name.
- Delim$ - Delimiter to use. Comma is default.
- Filename$ - Filename to use

#### fnGenerateLayout & fnWriteLayout

This function calls on the Generate File Layout Wizard to generate and save the layout indicated by the parameters you give it. You must give it the same valid parameters that you would have come up with if you worked through the layout wizard the normal way, by running FileIO directly and choosing "Generate Layout".

You can also bypass the automatic parsing and generate a layout by specifying all the data directly and using fnWriteLayout.

*fnGenerateLayout(mat OpenStrings$, ReadString$*999, FormString$*20000, DimString$*999; DisplayFile)*

- mat OpenString$ - array of all the open strings for the given file from one of your old programs.
- mat ReadString$ - solid read statement from one of your old programs reading the entire record, (or at least everything you want in the layout).
- mat FormString$ - the form statement that goes with the ReadString$ (practice using the Generate Layout Wizard the normal way for details)
- mat DimString$ - the string containing Dim statements for each array mentioned in ReadString$. We need this to know how big the arrays are.
- DisplayFile - if True (1), it will Display the new layout in notepad when its done creating it. If false (0), it will simply create the file.

fnGenerateLayout takes all the above information and parses it into a layout, then calls fnWriteLayout to actually write the layout.

If you already know the information you want to put in the layout, its more direct to call fnWriteLayout below.

*fnWriteLayout(Name$,FileName$*127,VER,PRE$,MAT KFNAME$,MAT KDESCRIPTION$,MAT SUBS$,MAT DESCR$,MAT FORM$;RECL,MAT EXTRA$,DISPLAYFILE)*

- Name$ - the name of the new layout
- FileName$*127 - the name of the data file
- Ver - the version of the data file
- Pre$ - the prefix to use for the data file
- mat KfName$ - array of all the keys for the file
- mat Kdescription$ - array of the subscripts that each key is based on
- mat Subs$ - the subscript for each field in the file
- mat Descr$ - the descriptions for each field in the file
- mat Form$ - the form specs for each field in the file
- Recl - (optional) the record length of the file
- mat Extra$ - (optional) Additonal Information for each field in the file, placed in the Comments column of the new layout. This column is ignored by standard fileio processing.

DisplayFile - if True, open the file in Notepad after it has been created.

#### fnSubstituteStringCode

A Large Text Field that is searched. Code is run and any resulting variables are set, if they exist inside String enclosed between Substitute Chars (default []), then they will be replaced with the values derived by the code.

*fnSubstituteStringCode(&String$,Code$*2048;SubstituteChar$)*

- String$ - the string to be searched
- Code$ - code to be run. The resulting variables can be substituted into String
- SubstituteChar$ - Defaults to [] but here you can override the Substitute Character to be used.

#### fnSubstituteString

A Large Text Field that is searched. Any matching fields in the passed in record will be substituted into their places. For example, if the string contained [cu_name] and you ran substitutions on the Customer file, then [cu_name] would be replaced by the name in the actual Customer record.

*fnSubstituteString(&String$,Filelayout$,mat F$,mat F;SubstituteChar$)*

- String$ - the string to be searched
- FileLayout$ - the layout to be searched
- mat F$ - the record to be used for substitution
- mat F - the record to be used for substitution
- SubstituteChar$ - Defaults to [] but here you can override the Substitute Character to be used.

#### fnShowMessage

Displays a message to the user, in a child window. Returns the child window number, so that you can close it when you're done with the message.

*WindowNumber=fnShowMessage(Message$*54)*

- Message - the Message to display to the user

### File System Utility Functions

These functions perform other tasks that aid with interacting with the file system.

#### fnGetFileDateTime$

This does a directory listing to determine the Last Modified Date and Time of the given file. You pass it a file name, not a file layout, and it can be used on any file. Its not limited to BR internal files.

The syntax is:

*let FileDate$=fnGetFileDateTime$(Filename$*255)*

#### fnProgressBar

There's a Progress Bar that FileIO uses when copying or updating data files. You can use it in your own functions by calling fnProgressBar inside the main loop of the process that you want to display the progress bar over, and by calling fnCloseBar when you're done.

*fnProgressBar(Percent;Color$,ProgressAfter,ProgressThreshhold,UpdateThreshhold,Caption$*255,MessageRow$*255)*

- Percent - Percentage Complete expressed as a float between 0 and 1
- Color$ - HTML Color Code of BR Color Attribute to color the Progress Bar. Defaults to Green.
- ProgressAfter - This value can be used to prevent the progress bar from loading when the job takes only a short time.
- ProgressThreshhold - This value can be used to prevent the progress bar from loading when the job takes only a short time.
- UpdateThreshhold - This value can be used to prevent the progress bar from loading when the job takes only a short time.
- Caption$ - Optional message to display above the progress bar.
- MessageRow$ - Optional message to display on the progress bar.

#### fnCloseBar

*fnCloseBar*

Call this function to close the progress bar window when your task is done running.

#### fnCopyFile

*fnCopyFile(FromFile$*255,ToFile$*255)*

- FromFile$ - The file to copy.
- ToFile$ - The destination file name including path.

This function copies any file, by opening it as an external file and reading and writing the data to the destination file. The advantage of this technique, over using the BR copy command, is this routine is more reliable when run on client server where you may be transferring large files from one side to the other over the internet.

This fnCopyFile also has a progress bar that displays as the file is transferred, so the user knows your software is busy.

This function works over Client Server. Under Client Server, specify @: at the beginning of your filename, to specify that the file is on the client. If the file is on the server, simply leave the @: off. See the chapter on using BR's copy command under Client Server for more details on the "@:".

This function's parameters and syntax are modeled off of the built in BR copy command, and like that one, this should work for local transfers, LAN transfers, or even internet transfers. This function will work better for internet transfers then the built in BR Copy Command, however.

#### fnCopyDataFiles

*fnCopyDataFiles(DestinationFolder$*255)*

- DestinationFolder$ - the folder to copy your data files to.

This function reads your file layouts and makes a copy of every data file (and key file) in your system to the destination folder, utilizing fnCopyFile above, for better performance and reliability when running over the internet, as well as a progress bar for each individual file.

It also displays a listview while its copying so you can watch the progress while its transferring your data files.

This can be used for making backups of your BR data, or for transferring the latest data onto a laptop for access to it while you're on the road away from the internet.

#### fnReIndex

This function reindexes a single data file

*fnReIndex(DataFile$*255;CallingProgram$*255,IndexNum,Path$*25)*

- Datafile$ - the file layout of the file to index
- CallingProgram$ - used for logging, pass Program$ in here
- IndexNum - The index to rebuild - if not given, rebuilds all indexes
- Path$ - the optional alternate path to use for rebuilding the data file.

#### fnReIndexAllFiles

This function reindexes all your data files. It doesn't require any parameters.

*fnReIndexAllFiles*

#### fnUpdateFile

This function checks and Updates a data file if it needs to be updated, by opening and then closing the data file.

*fnUpdateFile(FileLayout$)*

- FileLayout$ - The name of the file to update

#### fnRemoveDeletes

This function, written by Susan Smith, removes deleted records by copying the file with the -D option.

*fnRemoveDeletes(LayoutName$*255;Path$*255,CallingProgram$*255)*

- LayoutName$ - the file layout
- Path$ - Optional Alternate Path
- CallingPRogram$ - used for logging, pass Program$ in here

### Layout Interrogation

Layout interrogation functions are provided for convenience and to enable future dictionary changes without disrupting any programs that interrogate it.

#### fnMakeSubProc

This function obtains the subscript assignments that were assigned by fnOpen according to the file layout. The fnMakeSubProc$ routine obtains the subscript assignments without actually opening the file. This is useful when a file record is passed as arrays into a library function in another program, or when you chained to another program and you need to know how to reach the data in the arrays without actually reopening the file.

*fnMakeSubProc(filelay$;mat Subscripts$)*

- FileLay$ - The name of the file layout from which to read the subscripts.
- mat Subscripts$ - If you give this optional array, fnMakeSubProc passes the subscripts back in this array rather then in the subs.$$$ file. This is much faster and helps avoid sharing conflicts.

When this routine returns, you can set the subscripts in your program by executing every element of the Subscripts$ array in a for/next loop.

If you did not pass in a subscripts array, then the a procedure file named subs.$$$ is created. If you proc that file, the proper subscripts will be set.

#### fnReadLayoutArrays

This function reads the fields in a file layout into arrays. You call it like the following

*fnReadLayoutArrays(filelay$,&prefix$;mat SSubs$, mat NSubs$, mat SSpec$, mat NSpec$,mat SDescription$, mat NDescription$,Mat Spos,Mat Npos)*

- filelay$ - the name of the layout to read
- prefix$ - the return value for the prefix for the file
- mat SSubs$ - the return value for all the string subscripts in the layout
- mat NSubs$ - the return value for the numeric subscripts in the layout
- mat SSpec$ - the return value for the string fields specs
- mat NSpec$ - the return value for the numeric fields specs
- mat SDescription$ - the return value for the Descriptions of the String Specs
- mat NDescription$ - the return value for the Descriptions of the Numeric Specs
- mat SPos - the return value for the starting positions of the String Specs
- mat NPos - the return value for the starting positions of the Numeric Specs

This function call would read the fields from the layout in filelay$, and it would return the prefix to prefix$. The Subs would be returned in mat SSubs$ and mat NSubs$.

The Spec statements are returned in mat SSpec$ and mat NSpec$ and the Descriptions are returned in mat SDescription$ and mat NDescription$. The start positions on disk of each element are returned in mat SPos and mat NPos.

All the arrays are optional. If you don’t pass them the information they are supposed to record is simply not returned.

#### fnReadLayoutHeader

This function reads the header for a given file layout.

*fnReadLayoutHeader(Layoutname$*255;&Filename$,Mat Keys$,Mat KeyDescription$)*

- LayoutName$ - Name of the layout to read
- Filename$ - The file name read from the layout
- Mat Keys$ - Array to be populated with the list of keys for the file
- Mat KeyDescription$ - Key Description String returned from the file

#### fnReadEntireLayout

This function reads the entire layout by calling fnReadLayoutHeader and fnReadLayoutArrays.

*fnReadEntireLayout(Layoutname$*255;&Filename$,&Prefix$,Mat Keys$,Mat KeyDescription$,Mat Ssubs$,Mat Nsubs$,Mat Sspec$,Mat Nspec$,Mat Sdescription$,Mat Ndescription$,Mat Spos,Mat Npos)*

- LayoutName$ - Name of the layout to read
- Filename$ - The file name read from the layout
- prefix$ - the return value for the prefix for the file
- Mat Keys$ - Array to be populated with the list of keys for the file
- Mat KeyDescription$ - Key Description String returned from the file
- mat SSubs$ - the return value for all the string subscripts in the layout
- mat NSubs$ - the return value for the numeric subscripts in the layout
- mat SSpec$ - the return value for the string fields specs
- mat NSpec$ - the return value for the numeric fields specs
- mat SDescription$ - the return value for the Descriptions of the String Specs
- mat NDescription$ - the return value for the Descriptions of the Numeric Specs
- mat SPos - the return value for the starting positions of the String Specs
- mat NPos - the return value for the starting positions of the Numeric Specs

#### fnReadSubs

This function reads the subscripts from a layout into Subs arrays.

*fnReadSubs(Layout$,mat SSubs$,mat NSubs$,&Prefix$)*

- Layout$ - the file layout name
- mat SSubs$ - the String Subscript Names
- mat NSubs$ - the Number Subscript Names
- Prefix$ - the files Prefix

#### fnReadKeyFiles

This function reads the list of key files from the layout.

*fnReadKeyFiles(Layout$,mat Keys$)*

- Layout$ - The file layout
- mat Keys$ - output array, the keys are returned here.

#### fnLayoutExtension$

This function returns the layout extension being used.

#### fnReadLayouts

This function reads the file layout folder and returns all the applicable layouts in the passed in array.

*FnReadLayouts(mat Dirlist$)*

- Mat Dirlist$ - After running the function, mat Dirlist$ will contain a list of all the file layouts that FileIO can find.

#### fnDirVersionHistoryFiles

This function reads the file layout folder and returns all the applicable layouts in the passed in array.

*fnDirVersionHistoryFiles(Layout$,mat DirList$;BypassExtension$)*

- Layout$ - Which layout to look up version history of
- Mat Dirlist$ - After running the function, mat Dirlist$ will contain a list of all previous versions from history of the requested layout.

#### fnReadLayoutPath$

This function doesn't actually interrogate your layouts. Instead, it interrogates your settings and returns the path specified for your layout files. This would usually be "filelay\" but you can change it in fileio.ini.

It has no parameters.

*let Path$=fnReadLayoutPath$*

#### fnDoesLayoutExist

This function returns true if the given file layout exists. It returns false if the layout does not exist.

*FnDoesLayoutExist(layout$)*

- Layout$ - Layout to test for

#### fnReadForm$ (uncompiled)

Sometimes you need to know the original form statement that fileio is using to read your data file, most often when you're debugging your file layout, and you're getting some problem when reading the file. The form statement that fileio normally returns is compiled using CFORM$ to save space in the array, and to make the execution of your read statements faster. You can use this function to return the original form statement for the file.

The syntax is:

*let FormStatement$=fnReadForm$*10000(FileLayout$)*

Remember to dimension FormStatement to something huge! fnReadForm$ can return up to 10,000 characters.

#### fnReadFormAndSubs

This function does the same as above but it also reads the subscripts from the file into an array.

*let fnReadFormAndSubs(Layout$,mat Subs$,&ReadForm$,&StringSize,&NumberSize)*

Note that unlike most of our functions, all the above parameters are required.

The layout is the layout you're interrogating. The Array will be populated with the subscripts after the function. The ReadForm$ variable will be filled with the form statement for the file. Remember to dimension it large enough. StringSize and NumberSize will contain the number of string fields and numeric fields in the file.

Mat Subs$ will be returned, strings first, numbers last, matching the form statement that is returned. So Subs$(1) is the first string subscript and Subs$(StringSize+1) is the first Numeric subscript.

#### fnClearLayoutCache

fnClearLayoutCash (v2.3+) clears out the cache of layout name and data to get realtime Updates to File Layouts.

### Other Useful Functions (non-layout related)

#### fnAskCombo

Opens a window with a combo box and returns the users selection.

*fnAskCombo$*255(mat Description$;Caption$*60,Default$*255)*

- mat Description$ - contains the combo box choices
- Caption$ - contains the optional caption for the window
- Default$ - the text of the item in mat Description$ that you want to be selected by default

#### fnSendEmail

This function sends an email and an optional attachment to the email address specified.

*fnSendEmail(Emailaddress$*255,Message$*10000;Subject$*255,Invoicefile$*255)*

- EmailAddress$ - the Destination Email Address
- Message$ - the Message$ to send
- Subject$ - the subject
- InvoiceFile$ - the filename of a file to attach. This is the BR filename (the function automatically converts it to an OS Filename.)

The function returns 1 when the email was sent successfully, or 0 if it wasn't sent successfully.

In order to use this function, you must have the emailcfg file layout in your layouts folder and you must have a copy of SendEmail.exe which is free and can be downloaded from the internet. Both of these files are included with the latest update of fileio.

You also have to configure fileio with the authentication information for your email server.

To configure your email server, simply run FileIO to get the data crawler, then select the emailcfg file layout and press F5 to edit it. Add a row if the file is empty.

Simply fill in the information the file is asking for in the appropriate fields and save the data, and then test sending an email to make sure it worked.

More information about sendEmail.exe is available from the author's product site here: #### fnClientEnv$

This function returns the value of a Windows Environment Variable on the client under Client Server.

*fnClientEnv$*255(EnvKey$)*

- EnvKey$ is the name of the Windows Environment Variable to check on the client.

The function returns the value of the entered environment variable.

#### fnClientServer

This function returns true if you're currently running in Client Server mode, and false if you're running in the old "native" mode.

#### fnEmpty & fnEmptyS

These functions test if the passed in array is empty or not..

The syntax is:

*fnEmpty(mat Numeric)*

or

*fnEmptyS(mat String$)*

Example:

```
 def fnSomeFunction(String$,mat Array$; mat OtherArray)
    if fnEmpty(mat OtherArray) then
       ! Arrays were empty.
    end if
 fnend
```

#### fnReadScreenSize

This function reads the screen size of the given window (or window 0 if a window wasn't passed.) This is useful for centering a window on the screen, or for making sure window 0 is big enough for the child window you're trying to create.

The syntax is:

*fnReadScreenSize(&Rows,&Cols;Window)*

- Rows & Cols - returns the screen size in rows and columns.
- Window - the window to interrogate. If not given, assumes Window 0.

#### fnBuildProcFile

This function builds a proc file to be executed later. This function and the next simplify the process of executing code in a proc file. It can even be used to spawn a new session of BR.

To use it, call fnBuildProcFile one or more times and specify some lines of code to execute.

*fnBuildProcFile(Command$*255)*

```
 let fnBuildProcFile("load "&Program2$)
 let fnBuildProcFile("run")
 let fnBuildProcFile("system")
 
 let fnRunProcFile(1)
```

#### fnRunProcFile

This function spawns a new copy of BR and in it, runs the proc file that you've previously built using fnBuildProcFile (above).

*fnRunProcFile(;NoWait)*

The optional parameter "NoWait" causes the other session to spawn and run in a new thread. If you don't specify NoWait, the current session pauses and waits for the other session to close before proceeding.

```
 let fnBuildProcFile("load "&Program2$)
 let fnBuildProcFile("run")
 let fnBuildProcFile("system")
 
 let fnRunProcFile(1)
```

#### fnLog & fnErrLog

These next two functions are functions to aid in logging. When you call either of these two functions, you give them a string that you wish to log. They will open the FileIO Log File and add a record to the end of it containing some user information such as login_name and session$, and the string that you specified. FnErrLog does the same thing as fnLog except it also logs the Error Number and the Line.

The syntax is:

*FnLog(string$)*

- String$ - the Log Message

*FnErrLog(String$)*

- String$ - the Log Message

#### fnLogArray

This function logs the given arrays to the log file, logging each field in the arrays. Its useful for recording, for example, an entire data record that is about to be written to a data file.

The syntax is:
*fnLogarray(mat F$,mat f;Message$*512,CallingProgram$*255)*
The first two parameters, of course, are the array to log. The third parameter is an optional message to be recorded along with the array, and the fourth optional parameter is the CallingProgram$ to save in the log along with the message. (The CallingProgram$ parameter can usually be passed as the system function Program$)

#### fnSetLogChanges

This function works in conjunction with the next function, and they're for recording just what changed in a data file. When the file is read, you call fnSetLogChanges and record the "before" picture of the file record.

After changes have been made and saved back to disk, you can call fnLogChanges below to record the actual changes.

The syntax is:
*fnSetLogChanges(mat F$,mat F)*

#### fnLogChanges

This function is the other half of the function above. It compares the given arrays with the ones set previously in the above function and checks for changes. Then it generates a log message recording information about just the items that changed.

The syntax is:
*fnLogChanges(mat F$,mat F;Message$*1024,CallingProgram$*255,Layout$)*

You need to pass in the same two arrays as before, but this time the modified versions of them.

You can also optionally pass a 1024 byte log message to record with the log entry.

CallingProgram$ again should be passed as the system internal function Program$.

The final parameter allows the passing of a Layout$. If you pass a Layout$, that layout is read and the subscripts are used when making the log message of changes, so that its easier to read. If you pass a layout, it will identify the changed fields by name. If you don't it will identify those fields by relative position number.

#### fnViewLogFile

All of the above functions store the information by default into a BR internal file defined in the filelay\logfile layout.

The fnViewLog function uses fnShowData to call the Data Crawler to display the FileIO Log File in a searchable listview.

*fnViewLogFile(;ShowQuit,ShowColumns,ShowExport)*

- ShowQuit - Show a quit button on the UI (if off, ESC will quit).
- ShowColumns - Include a button to allow the user to select which columns to view.
- ShowExport - Include a button to export the log file to CSV.

#### fnReadLockedUsers

This function returns a list of all users using the locked data file.

*fnReadLockedUsers(mat Users$)*

- mat Users$ - the list of users is returned here

#### fnDisplayLength

This function calculates the display length of a field based on its form spec.

*fnDisplayLength(Spec$)*

- Spec - the Form Spec to return the display length of.

#### fnLength

This function calculates the length on disk of a field based on its form spec.

*fnLength(Spec$)*

- Spec$ - the Form Spec to return the length of.

#### fnStandardTime$

Converts Military Time to Standard Time. Returns Standard Time$

*fnStandardTime$(MilitaryTime$;Seconds)*

- MilitaryTime$ - Time in 24 hr format.

#### fnMilitaryTime$

*fnMilitaryTime$(StandardTime$;Seconds)*

- StandardTime$ - Time in AM/PM Format

#### fnCalculateHours

Calculates the difference between 2 specified times.

*fnCalculateHours(TimeIn$,TOut$,DaysIN,DaysOut)*

- TimeIn$ - From Time
- TimeOut$ - To Time
- DaysIn - Days Start
- DaysOut - Days End

#### fnBuildTime$

Builds a time in the format used by the above functions.

*fnBuildTime$(H,M,S,P;Military,Seconds)*

- H - Hours
- M - Minutes
- S - Seconds
- P - Boolean indicating AM/PM - 0 is AM, 1 is PM
- Military - Flag indicating weather desired result is in Military Time or not
- Seconds - Flag indicating weather to count seconds or ignore them. (1 means count seconds)

#### fnParseTime

Takes a time and pulls out the values

*fnParseTime(T$,&H,&M,&S,&P)*

- T$ - the time to parse
- H - Return value for Hours
- M - Return value for Minutes
- S - Return value for Seconds
- P - Return Value for AM/PM

## FileIO fnSettings (Global Settings Code)

The FileIO library can be made to implement certain policies across the board.  These are established by creating a file called fileio.ini and typing statements like the following into it. This file is "PROCed", so you don't want to put line numbers in it.

Anything you don't specify in fileio.ini will take its default value, shown below. So you only need to specify the items that you want to be different.

Note, for the boolean settings below, 1 denotes TRUE and 0 denotes FALSE.

```
 let EnforceDupkeys=1                   ! Enforce that key number 1 is unique key
 let Defaultfilelayoutpath$="filelay\"  ! Path To Your File Layouts
 let Promptonfilecreate=1               ! Ask User Before Creating New Files
 let Createlogfile=0                    ! Use Logging
 let StartFileNumber=1                  ! Set above 300 to avoid conflicts with legacy programs.
 let CheckIndex=0                       ! Automatically Verify Indexes (slow)
 let CompressColumns=0                  ! Shrink or Expand Columns in Data Crawler by Default
 let MaxColWidth=20                     ! Max Default Column Width in Data Crawler
 let LogLibrary$=""                     ! Defaut Log Library, defaults to None
 let LogLayout$=""                      ! Log file layout, defaults to Internal File
 let AnimateDatacrawler=1               ! Use ScreenIO Animation for Datacrawler
 let TemplatePath$="filelay\template\"  ! Default Template Path
 let IgnoreLayouts$=""                  ! List any Ignore Layouts here.
 let CloseFileSimple=0                  ! Use simple comparison for fnCloseFile
```

#### EnforceDupkeys

Turn on the EnforceDupkeys option to force that the first key listed in your file layouts is a unique key. FileIO will generate the standard BR error for Dupkeys when attempting to create indexes if it is not unique.

#### DefaultFileLayoutPath$

Use the DefaultFileLayoutPath option to specify the path from your programs to your file layout folder. The default is "filelay\". Use this setting if you want to place your file layouts in another folder from the default.

#### PromptOnFileCreate

Use the PromptOnFileCreate setting to cause FileIO to display a message box whenever it is attempting to create a new file. This happens during the automatic update procedure, as well as during any attempt to access a file that does not exist. This setting should be turned off in your live system, and only turned on for development purposes. If you use the message box to cancel creating of the new file, then the file is not created, and fileIO or your application will most likely give an error when you attempt to actually access the new file.

It can be useful during development to make sure that you don't accidentally create the wrong files, due to an incorrectly specified path or a typeo in the filename in the layout file. However, in a live system, these things have already been tested, and you generally want the default behavior, because you don't want your users to have the ability to cancel the normal operation of FileIO.

#### CreateLogFile

Use this option to specify weather or not to use the FileIO log file. If it is turned on, a log file called FileIO.log in the current directory is created with entries listing all attempts to open a file, automatically update one, or automatically update your indexes.

#### StartFileNumber

Use this option to set the starting file number that the fnGetFileNumber and the fnOpen functions use to search for available file numbers. This is so that if you have certian reserved file numbers in your code, you can make sure that FileIO will not use those reserved file numbers, causing a conflict with your already existing programs. The default is 1, which is fine if your software does not have any reserved file numbers.

The allowable BR file numbers are 1-200 and 300-999.

#### CheckIndex

This function is used for Partial FileIO Implementations. If all of your software uses FileIO then all of your indexes are kept automatically up to date by the FileIO library and BR's internal file processing systems. However, if some of your programs do not use FileIO, and you use the FileIO library to add a new index file that those other programs do not know about, then its possible for the additional index file to become out of date when the master file is updated by your other programs.

Use this setting to cause FileIO to check the DateTime stamp on all your index files when opening a new file, and automatically update any indexes that may have potentially gotten out of date from other programs.

This option slows down the processing of the fnOpen function, particularly when running under client server over the internet. If you know that every program in your application suite uses FileIO, and that any programs that do not use FileIO still properly update all the indexes that your data file uses, then you can safely leave this setting turned off, and optimize your performance when opening several files using the fileIO system.

#### CompressColumns

This instructs the datacrawler to use smaller widths for small columns. If CompressColumns is false, the data crawler will make the column the width of the field or the width of the caption, whichever is wider. If CompressColumns is true, it will use the width of the field, not the caption.

#### MaxColWidth

This limits the column width to a set amount. This is applied after CompressColumns above.

#### LogLibrary$

If a library is specified here, then fileio looks for a BR library with the specified name, and attempts to call a library function in it called fnFileIOLog that. This function should expect six parameters, which are Logstring$, Login_Name$, Session$, Days of Date$, Time$, and CallingProgram$, if LogLayout is also nonblank.

If you specify a LogLibrary and LogLayout is blank, then it calls your function giving it only 1 parameter.

It will call your function ***instead of*** the normal log file. Use this to implement your own logging functions however you want.

#### LogLayout$

Use this setting to specify an alternate file layout for an alternate file to do the logging in. Base the file layout for this file on the logfile we supply for you in the filelay folder. It should have at least those fields, which our log routine will automatically populate, but you can add other fields if you want (though you will need to manage them yourself).

If you don't specify LogLayout, the default filelay\logfile will be used. This will allow you to also use the fnViewLogFile function to access it.

#### AnimateDataCrawler

The sister library [ScreenIO has a feature that allows you to use an animation of a clock in your loading screens in your own programs. If you have ScreenIO then FileIO will automatically detect it and use it to display a loading animation while the data in the data crawler loads.

Set AnimateDataCrawler to false (0) in your fileio.ini file to bypass the animations if you do have screenio but don't want to see the animations anyway.

#### TemplatePath$

This setting points to the folder that contains the code templates used by the Generate Code button on the main page of the Data Crawler.

#### IgnoreLayouts$

This is a comma delimited list of all layouts that you wish to suppress from appearing on the main page of the data crawler. You can still access these layouts with your code, but they won't be listed in the data crawler for you to access.

Whatever you're using for a log layout, is automatically added to this list.

#### CloseFileSimple

The fnCloseFile function closes all the individual handles to a data file that was opened for output using multiple keys.

For BR 4.18 and higher, we support a better algorithm for detecting which files are matches for a given opened file number.

Set CloseFileSimple to true (1) to force it to check the old way.

## FileIO Add-on Packages

Many FileIO Add-on packages are currently in the works.

### ScreenIO Library

The ScreenIO Library is a sister library to the FileIO library. The ScreenIO library requires the FileIO library in order to run.

The ScreenIO library is a complete Rapid Application Design tool that enables you to implement custom screen functions anywhere in your exiting programs.

If you call the ScreenIO Library as a function library, you call a function called fnFM and tell it which screen you wish to use. The ScreenIO library loads your user interface, loads your data files, and preforms all the file maintenance operations you have designed into your screens.

You can find out the latest information about the ScreenIO library in the ScreenIO page.

### Audit BR

The Audit BR developer tool makes a backup copy of your file layouts. Then you run some code you're trying to test, and finally, run Audit BR again, to get a report showing all the changes to any of your data files automatically.

AuditBR is now included directly in FileIO. To use it, select the layout from the list of layouts in the Datacrawler and press the "Compare" button.

## What’s New (also described above)

### 2018

- Support for dates in any storage formats on disk (v2.48)

### 2015

- Added Rec to display for fnShowData
- Added FormStatement$ for debugging of form statements inside fileio
- Added mat BadRead$ for debugging of 726 errors when making new layouts
- Fixed a bug causing crash when logging things from long program folders
- fnClientEnv$ - reads a Windows Environment variable on the client using the command shell
- fnAskCombo$ - added an optional parameter to set default selection.

### 2010 - 2014

- FileIO now caches your file layouts in memory to make it much faster then before when opening the same data file in multiple programs.
- Generate Layout Wizard
- fnShowData
- Improved Logging
- fnViewLogFile
- Import/Export
- Import/Export by Function
- Many other speed increases
- if ScreenIO is present, Datacrawler uses the animation routines
- fnBuildProcFile & fnRunProcFile
- fnGenerateLayout & fnWriteLayout
- fnReadForm$
- fnReadFormAndSubs
- fnGetFileDateTime$
- fnReadLayoutPath$
- fnSortKeys
- fnSetLogChanges
- fnLogChanges
- fnLogArray
- fnReadScreenSize
- fnEmpty
- fnEmptyS
- Many other useful functions that were added to the documentation at earlier dates.

### Spring 2009

***New Functions:***

The FileIO Library has been updated in Spring 2009 to provide several new functions:

- fnReadRecordWhere
- fnKey$
- fnBuildKey$
- fnReadUnopenedDescription$
- fnUpdateFile
- fnDisplayLength
- fnLength
- fnReadLayoutHeader
- fnReadEntireLayout

***Speed Increases:***

Thanks to the BR Profiler, we have increased the speed of FileIO fnOpen function by ten times when running over a LAN and by 100 times when running over the internet using Client Server.

In order to get the new Speed Upgrades, you will need to make sure that you use the latest copy of the fnOpen function in each one of your programs that use FileIO.

***Network FileIO:***
This version of FileIO has been optimized to work better in network situations.

***FnSettings:***
There are more configuration options in the fnSettings routine.

***Automatic Update Speed Fix:***
The automatic update proceedure has been made to run more then 100 times faster then before according to our benchmarking tests.

### Fall 2008

***DataCrawler Grid:***

By popular request we added a read/write version to the data crawler. This version works exactly the same as the datacrawler did before but it displays all the contents of your data files in a grid instead of a listview.

When you run the fileIO library as a program, it launches a tool known as the DataCrawler. The DataCrawler shows a listview displaying all your layout files in it. If you select one, it builds another listview with all the data in your selected data file.

If you are looking at the first list of all your file layouts, and you press F5, a grid will be build displaying all the data in your data files. You can change any of the records you like, and when you're done, your changes will be saved to the data file. Additionally, you can Add or Delete records using the buttons at the bottom. Any changes you make are not written to the disk until you click the "Save" button. If you press ESC (Cancel) the grid is closed and all changes you made sinse the last save are lost.

This tool is for programmers only. Do not give your end users access to the DataCrawler.

Use the DataCrawler at your own risk. Gabriel Bakker and Sage AX are not responsible for any harm that comes to your data files through the use of this or any other tools we offer.

The DataCrawler is not designed to be used to maintain your data files. It can be used carefully to correct small things in your data files.

***Support for Nonstandard Paths:***

Many BR Vendors keep different versions of the same data files in different locations. For example, sometimes a BR vendor will use a different Data folder to represent data for different Warehouses, or Customers. In cases like this it is necessary for your programs to specify the path to your data files. They may do so by specifying the optional "PATH" parameter to your data files. See the section #fnOpenFile for more information.

***Support for Nonstandard Layout Files Path:***

Old versions of the fileIO library required you to place all your file layouts in a subfolder of your program directory called "filelay". We have now changed the Fileio library to allow you to place your file layouts any place you want. The only requirement is that they are all together in one folder by themselves.

If you use a nonstandard path in the fileIO library, it is necessary to make a change to the fnSettings code in your copy of fileio.br.

***Prompt on Create:***

The FileIO library automatically creates any data files that it can't find. This was done to make it easier to deploy your finished programs - if you had any empty data files you could omit them from the packages and they would be created when they were needed, on the fly.

The current version of the FileIO library contains the same ability. However, it prompts you before creating any data files. This helps to avoid bugs that happen from incorrectly specifying the path to your data files.

However, if you do intend for your data files to be autocreated, then you probably don't want your end users to modify them. Therefore, you can use the PromptOnCreate setting in the fnSettings code to specify. If this value is set to true, then the fileIO library will prompt you whenever it attempts to Autocreate a data file. If it is set to false, then the fileIO library will create the data files without prompting you, like it always did before.

***fnSettings:***

The newest version of the FileIO library supports some features that require you to specify Global Settings values. These are done by modifying the contents of the fnSettings routine at the beginning of the fileIO library.

### Fall 2006

Many improvements have been made in the FileIO library over the summer. This section is intended to acquaint you with the highlights of those changes. Most of these improvements were built from ideas generated during the discussion at the April conference.

***Intermixed String and Numeric Specs:***
The File Library has been expanded to allow the reading of data files that contain mixed string and numeric specs. This is to aid those of you who are planning on implementing the FileIO Library on existing data files which may not be organized with strings first and numbers second.

The central idea of the FileIO Library is based upon the reading of your data files into a String and Numeric array. This will enable you to refer to the fields in your file by using a named subscript, saying F$(FM_NAME) to refer, for example, to the farm file’s name field. The advantage to this is that when you change the file layout, all your existing programs will not have to be modified, because they will only be looking at F$(FM_NAME). If the name field changes from the third string field to the fourth, the value of FM_NAME will also change, and you won’t have to worry about updating your data files.

However, in order to support the reading of a data file with intermixed string and numeric specs, the generated form statement will actually calculate the position of any fields that are not in order, so that the file read statement will still return all string fields first (into your string array) and the numeric fields second (into your numeric array). You do not need to worry about this; the library does it for you. All you have to do is read your file and use the data values.

The only thing that is required is making sure that all your string subscript names end with a “$”. This will tell the library that they are strings. Thank you, George, for this suggestion.

***Versioning / Automatic Updates:***
The file layouts have been expanded to contain a version number. This version number will be used to determine when a file needs to be updated. The version number is the third parameter in the file layout.

Any time you wish to change your file layouts, simply increment this version number. Each time the library attempts to open a data file, the file’s version is checked and compared with the version in the file layout. If the file layout has been changed (if the version in the file layout is greater then the version in the file) then the file will be updated to the latest version. Depending on the file size this may take a couple of moments. A simple progress bar will be displayed on screen while this is happening. The progress bar will be displayed in its own window, so it should not affect anything your programs may have had on screen.

The library uses the following procedure for updating a file. First, the file is copied to a backup file (prefixed by the letter ‘o’ for old). So color.dat would become ocolor.dat, and color.key would become ocolor.key. Then the new file is created and marked with the proper version number. (color.dat, color.key). The old file is opened in read-only mode, and the new file is opened for OutIn. The update routine actually reads through the old file layout, and one record at a time creates a new record, using the new file layout, with the same data, saving it to the new data file.

When it is done upgrading, the progress bar window is closed, and the file is reopened in the fashion you described in your call to fnOpen, and flow returns to your program as though nothing unusual has happened.

If an error occurs during processing, the routine will do what it can to roll your data files back to the previous version, but please make frequent backups of your data files anyway, just to be safe.

***Error Checking – If there is a mistake in the file layout:***
The routine attempts to discover the cause of the error in the case that one is encountered due to a missing file, a file sharing violation, or an invalid or corrupt file layout. If this should happen, the program is paused, and a text message is printed out explaining the most likely source for the error, including what part of the file layout, if any, may have caused the error.

You may then examine the printed text, and the contents of the BR system variables ERR and LINE to determine the problem. If you type “GO”, the next line will be execute “system”, ending your program.

If the file was in the middle of an upgrade when the error happened, it will be automatically rolled back to the previous version, so that when you fix the problem and try to run your program again, the file will again attempt to update from the beginning, and you won’t have to worry about corrupted data.

However, please backup your data before upgrading your data files anyway, just to be safe.

***Implementation of Keys / Creation of New Data Files:***
The library has been expanded to automatically create all new data files, and to automatically update any existing files. This means that in the file layout header, two new fields that were previously ignored are no longer ignored. The RECL value that you specify in your file layout will be used, along with the description/definition of your keys file. When you open a new file (or update an existing one), the library will calculate the proper kps and kln by evaluating the key description. This key description must match up with subscript values from the data elements in your file, and more then one may be specified, but they must be separated with slashes (/). If I wanted my Farm File to be keyed based on CODE and NAME, the proper key description would be:

```
 farm.key, CODE/NAME
```

The library will then look up the position and length on disk of the CODE and NAME fields and put them together to create the proper keys during an update or creation of a new file.

***DataCrawler:***
Perhaps the most exciting new addition to the library is the addition of a programming tool I like to call a DataCrawler. If you run the FileIO Library directly as a program, instead of using it as a library, it will function as a DataCrawler. The DataCrawler requires a New Gui version of BR, as it requires a ListView to be able to properly and easily display the data in your files.

If you run it in an older version of BR you will get a message, telling you to run it in a newer copy. If you run it in a New Gui version of BR with CONFIG GUI OFF, then GUI will be turned temporarily on for the use of the DataCrawler and then turned off again when you are finished. If you run it in a New Gui version of BR with GUI ON, it will just run normally.

When you run the DataCrawler, first you will see a ListView displaying every file layout it can find in the filelay folder. If you select a file, the DataCrawler will open a large ListView with as many columns as there are fields in the file. The Column Headings will come from the element descriptions in your data files, and the column widths will come from the displayed width of the fields. There will be a row for every record in your data file, and you can resize the column widths, and scroll around the data file to view the raw data of your BR data files on disk.

If you are dealing with a particularly enormous data file (50,000+ records) it can take a moment to populate the ListView with the data in your data file. You may hit ESC to stop loading if you like, and view only the already loaded records.

If you would like to look up a particular record (based only upon the primary key for the data file), you may press F4. This will give you a window which asks you to input the key or partial key. When you press enter, the file will be reloaded, starting at the key you specified and continuing on to the end of the file, or until you press ESC. The records you are looking for should appear at the top of the ListView.

To reset the ListView and look at the contents of the entire file again, simply press F4, and enter a blank (“”) key.

Finally, as with any ListView, you may resort your data by clicking on any of the column headings. Then you can use the slider bar at the right to scroll down to the record you desire.

This is a programming tool and is not designed to be used by an end user. This tool will open your file in read-only mode. It will not allow you to modify the data; I leave that as an exercise for the reader. However, it will update any datafiles you view to the latest version (if they need to be updated) when it opens them, just as any other program that uses the library will do.

## Appendix (Examples)

### Example.br

```
 00010    ! example.br - This program is an example of for the data reading simplification
 00020    ! Copyright April 2006 by Gabriel Bakker
 00030    ! Distributed open source as a Christmas gift to brag members
 00040    !
 00100    execute "config gui off"
 01020    DIM form$(1)*255
 01030    DIM color$(1)*255,color(1)
 01040    DIM colorcat$(1)*255,colorcat(1)
 02020    library "fileio": fnopenfile, fnreaddescription$
 04000 !
 04010 Openfiles: ! Open your files here
 04020    let colorfile=fnopen("color",mat color$,mat color,mat form$)
 04030    let colorcatfile=fnopen("colorcat",mat colorcat$,mat colorcat,mat form$,1)
 06000    ! gosub WriteFiles ! If you want to test this line, make sure to drop flag from 4030
 07000 !
 07010 MainBit: ! This'un here's tha Main Bit
 07030    RESTORE #ColorFile:
 07100    ReadNextcolor: ! Read next record
 07120       read #ColorFile, using form$(ColorFile) : mat Color$, mat Color eof EndReadColor
 07180       PRINT Color$(co_name)&" ("&Color$(co_html)&") is a member of the '";
 07190       PRINT trim$(fnReadDescription$(ColorcatFile,cc_Name,Color$(co_category),mat Colorcat$,mat Colorcat,mat form$))&"' category."
 07290       goto ReadNextColor
 07300    EndReadcolor: ! Finished with Color File
 08000    STOP
 25000 !
 25010 WriteFiles: ! Uncalled routine to demonstrate writing files
 25105       let color$(co_code)="GD" !:
             let color$(co_Name)="Gold" !:
             let color$(co_Category)="YL" !:
             let color$(co_html)="FFD700"
 25110       write #colorfile, using form$(colorfile): mat color$, mat color
 25115       let color$(co_code)="LV" !:
             let color$(co_Name)="Lavender" !:
             let color$(co_Category)="BL" !:
             let color$(co_html)="E6E6FA"
 25120       write #colorfile, using form$(colorfile): mat color$, mat color
 25125       let color$(co_Code)="OR" !:
             let color$(co_Name)="Orange" !:
             let color$(co_Category)="YL" !:
             let color$(co_html)="FFA500"
 25130       write #colorfile, using form$(colorfile): mat color$, mat color
 25205       let colorcat$(cc_Code)="YL" !:
             let colorcat$(cc_Name)="Yellows" !:
             let colorcat$(cc_html)="FFFF00"
 25210       write #colorcatfile, using form$(colorcatfile): mat colorcat$,mat colorcat
 25215       let colorcat$(cc_Code)="BL" !:
             let colorcat$(cc_Name)="Blues" !:
             let colorcat$(cc_html)="0000FF"
 25220       write #colorcatfile, using form$(colorcatfile): mat colorcat$,mat colorcat
 25300    return
 40000 !
 40010 Open: ! ***** Function to call library openfile and proc subs
 40020    def fnOpen(FILENAME$, MAT F$, MAT F, MAT FORM$;INPUTONLY,KEYNUM,___,INDEX)
 40025       dim _FileIOSubs$(1)*50
 40030       let fnopen=fnopenfile(FILENAME$, MAT F$, MAT F, MAT FORM$,INPUTONLY,KEYNUM,MAT _FileIOSubs$)
 40040       for Index=1 to udim(mat _FileIOSubs$) : execute (_FileIOSubs$(Index)) : next Index
 40090    fnend
 50000 !
 60000 Ignore: Continue
 
 Color File Layout
 color.dat, CO_, 1
 color.key, CODE
 recl=127
 ===================================================
 CODE$,          Color Code,                  C    6
 NAME$,          English Name for Color,      V   30
 CATEGORY$,      General Category of Color,   C    6
 HTML$,          HTML Code for the Color,     C    6
```

```
 ColorCat File Layout
 colorcat.dat, CC_, 0
 colorcat.key, CODE
 recl=127
 ===================================================
 CODE$,          Category Code,               C    6
 NAME$,          English Name for Color,      V   30
 HTML$,          HTML Code for the Color,     C    6
 
```

Example Layout showing multiple keys (price)

```
 price.dat, PR_, 0
 price.key, FARM
 price.ky2, ITEM
 price.ky3, FARM/ITEM/GRADE
 recl=127
 ===================================================
 FARM$,          Farm Code (or blank),        C    4
 ITEM$,          Item Code,                   C    4
 GRADE$,         Quality,                     C    4
 X,              Empty,                       X   37
 PRICE,          Default Price,               BH 3.2
 COST,           Default Cost,                BH 3.2
 XOPRICE,        Default Christmas Price,     BH 3.2
 XOCOST,         Default Christmas Cost,      BH 3.2
 MOPRICE,        Default Mothers D Price,     BH 3.2
 MOCOST,         Default Mothers D Cost,      BH 3.2
 VOPRICE,        Default Valentine Price,     BH 3.2
 VOCOST,         Default Valentine Cost,      BH 3.2
```
