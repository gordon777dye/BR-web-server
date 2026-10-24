---
title: Picture
file: Picture.md
category: 20-io-screen
subcategory: 20-io-screen/controls
kind: statement
related: [file, GUI Console, Input Fields, RInput Fields, Print Fields, print, newpage, BRConfig.sys, ANI, JPG]
---
For information concerning the caching of images in BR see the `Picture (Config)| CONFIG PICTURE` page.

Commonly referred to as a **picture** this is a `file` that is used to display an image on the BR! `GUI Console`. Either P or PICTURE may be specified as a FIELDS field type. P and PICTURE are synonymous, picture was simply added for readability.

In Business Rules! there are a few ways to place pictures on the screen.
#By use of a `Input Fields` or `RInput Fields` statement.
#By use of a `Print Fields` statement.
#As the background image of `print` `newpage`

Examples:

Pictures can be displayed as fields in INPUT, PRINT, or RINPUT statements: (see explanation below)
 print #5,fields '1,1,PICTURE 2/4,[W]': 'dir\image.gif:isotropic'
 print #5,fields '1,1,P       2/4,[W]': 'dir\image.gif:isotropic'

Pictures can be displayed as the NEWPAGE background image in the following ways:

:1.) From `BRConfig.sys`:
 SCREEN OPENDFLT srow=3,scol=3,rows=20,cols=50,Picture=mylogo.jpg[:NORESIZE|TILE|ISOTROPIC]
:2.) From a command line or program:
 00100 OPEN #0: "srow=3,scol=3,rows=20,cols=50,Picture=mylogo.jpg[:NORESIZE|TILE|ISOTROPIC]",display,outin

*NORESIZE keeps the original size of the picture, instead of resizing it to fit the window.  
*TILE covers the window with as many copies of the image as will fit.  
*If neither NORESIZE, nor TILE is specified, then the picture is resized to fit the window.  
*ISOTROPIC retains the original aspect ratio during resizing.
*Keywords such as TILE are case insensitive.

If a control overlaps the background image, then the part of the background picture which is not overlapped is still visible.  The part of the background picture which is overlapped is positioned under the control.

 00100 OPEN #0: "Picture=logo.jpg:NORESIZE",display,outin
 00200 INPUT FIELDS "12,30,C 8": VAR$
 00300 PRINT FIELDS "13,30,C 8": VAR$

Output:
`Image:NEWC0018.jpg`

Also, pictures can be displayed in window areas by specifying them as FIELDS. The syntax for displaying PICTURES is:

 PRINT FIELDS "row,col,P rows/cols,[,FKEY]" : "myimage.jpg [:TILE|NORESIZE|ISOTROPIC]"

If an FKEY value is provided, the picture generates the specified FKEY value when mouse clicked.

The name of this example is: CHESSPRN.BR

 00100 PRINT FIELDS "1,10,P 3/7,, 20" : "chess.jpg"  ! FKEY will return 20 if the picture is clicked

Output:
`Image:NEWC0019.jpg`

The corresponding IO string variable must be of string type and contain the filename of a graphic image. A broad range of graphic image types are supported. 

When a picture is specified as an input field, all non-navigation keys are ignored.  For pictures, the BR Help user level is assumed to be zero. This enables tooltips without floating help windows irrespective of the actual help user level.

At a minimum, the following graphical image types are supported:
*`ANI`
*`JPG`
*`BMP`
*`PCX`
*`CUR`
*`PNG`
*`GIF`
*`PNM`
*`ICO`
*`TIFF`
*`IFF`
*`XPM`
*`JPEG`
