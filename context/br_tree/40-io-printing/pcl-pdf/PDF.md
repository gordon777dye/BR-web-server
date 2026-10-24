---
title: PDF
file: PDF.md
category: 40-io-printing
subcategory: 40-io-printing/pcl-pdf
kind: statement
related: [32 bit, 4.2, OPEN, NWP, NORESIZE, PDFLIB.DLL, CONFIG, statement, OPTION]
---
A **PDF** or **Portable Document Format** document (`wikipedia:Portable Document Format`) can be created with `32 bit` versions of Business Rules! `4.2` and higher.

To create a PDF file specify in the print file `OPEN` statement: Name= PDF:/ [,PrintFile= ...] If printfile is not specified, BR creates a PDF file in the spool directory.

To create a PDF file and send it to the user’s Windows program associated with PDF files (such as Adobe Acrobat): Name= PDF:/READER [,PrintFile= ...] This is the same as creating a PDF file and then double clicking it.

To create a PDF file and send it to a specified program or batch file: Name= PDF:/program-name [,PrintFile= ...]

This is not the same facility as `NWP`. However it supports all of the NWP syntax with the following exceptions:

*Tiling and cross hatching are not supported, but colors and shading do work.
*`NORESIZE` is ignored. 
*We are restricted to true type fonts only.

PDF printing provides relatively compact output file sizes and the ability to overprint PDF forms.

This feature requires the `PDFLIB.DLL` to be present in the BR directory.

To create a PDF file specify in the print file `OPEN` statement:
 Name= PDF:/ [,PrintFile= ...]

Printfile can be used to name your PDF. 

If printfile is not specified, BR creates a PDF file in the spool directory.

To create a PDF file and send it to the user’s Windows program associated with PDF files (such as Adobe Acrobat):
 Name= PDF:/READER [,PrintFile= ...]
This is the same as creating a PDF file and then double clicking it.

To create a PDF file and send it to a specified program or batch file:
 Name= PDF:/program-name [,PrintFile= ...]

A background PDF file may be specified **in the printed output** as 
 \Epdf='page_number,pdf-filename'.
As with similar NWP escape sequences, \Epdf= is case sensitive, but the pdf-filename is not.

A `CONFIG` `statement` may override the default Windows PDF reader (typically Adobe Acrobat):
 PDF_READER adobe-reader-alternate
This CONFIG statement causes BR to translate “Name= PDF:/READER” to 
“Name=PDF:/adobe-reader-alternate”.

PDF support was added to the MAC version in 4.2.

===Print Font Stretching===

When the PDF printing facility was developed, there was a problem getting PDF to print exactly like NWP and PCL when fixed width fonts were used. This was partly because early in NWP development, the fixed width fonts were stretched vertically for maximum legibility. However, in version 4.2 a default font more like PCL was used to  print in both NWP and PDF.

However, the older stretched fonts were favored again because of their superior legibility. This stretching of fixed width fonts can be disabled with `OPTION` 68. 

As of 4.3, Courier New is the default font. pdflib4-Win32.dll adds support for this stretching to PDF capabilities.

The Relative Font Heights (height to width ratios) are as follows:
{|
|-valign="top"
|-
|width="30%"|**Native Courier New  1.6 **||-Available in PCL
|-
|-valign="top"
|width="30%"|**Native Letter Gothic  2.0**||-Available in PCL
|-
|-valign="top"
|width="30%"|**Stretched Fonts 2.6**||-NWP and PDF only
|-
|-valign="top"
|}   

The 1.6, 2.0, 2.6 are ratios. For Courier New the 1.6 means that the font is 1.6 times as high as it is wide. PCL measures all fixed width fonts in width and calculates the height based on these ratios.  So for Courier New a 10 CPI font would be 1.6 * (1 / 10)(CPI) * 72 (points per inch) = 11.52 points.  Actually the ratio for Courier New appears to be 1.66666666.  This would mean that 1.66666666 * (1/10) * 72 = 12 points.
