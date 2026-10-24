---
title: PCL
file: PCL.md
category: 40-io-printing
subcategory: 40-io-printing/pcl-pdf
kind: statement
related: []
---
The following Substitute codes work in PCL. Those with a * will work only in PCL. Note that some of these are also mentioned in the "Page Setup Options" section of this chapter.

;Initial configuration:
(The following must be done before anything is printed to the printer)
{|
|-valign="top"
|width="10%"|**[PORTRAIT]**||Sets the printer to print portrait
|-valign="top"
|width="10%"|**[LANDSCAPE]**||Sets the printer to print landscape
|-valign="top"
|}
<br>
;Logical Page Size:
The next six settings change the logical page size for printing on {\ul different sized pages}:
{|
|-valign="top"
|width="10%"|**[EXECUTIVE]**||Set the logical page for Executive size paper (7.25 x 10.5)
|-valign="top"
|width="10%"|**[LETTER]**||Set the logical page for Letter size paper (8.5 x 11)
|-valign="top"
|width="10%"|**[LEGAL]**||Set the logical page for Legal size paper (8.5 x 14)
|-valign="top"
|width="10%"|**[LEDGER]**||Set the logical page for Ledger size paper (11 x 17)
|-valign="top"
|width="10%"|**[A4PAPER]**||Set the logical page for A4 size paper (210mm x 297mm)
|-valign="top"
|width="10%"|**[A7PAPER]**||Set the logical page for A7 size paper (297mm x 420mm)
|-valign="top"
|}
<br>
The next five settings change the logical page size for printing on {\ul envelopes}:
{|
|-valign="top"
|width="10%"|**[MONARCH]**||(3 7/8 x 7.5)
|-valign="top"
|width="10%"|**[COM-10]**||(4 1/8 x 9.5)
|-valign="top"
|width="10%"|**[INTERNATIONAL DL]**||(110mm x 220mm)
|-valign="top"
|width="10%"|**[INTERNATIONAL C5]**||(162mm x 229mm)
|-valign="top"
|width="10%"|**[INTERNATIONAL B5]**||(176mm x 250mm)
|-valign="top"
|}
<br>
;Paper Source:
The following six options set the paper source. By default it is set to Auto, and can be changed in printer preferences:
[PAPERSOURCEAUTO]|Feed from Printer Default<br>
[PAPERSOURCEMANUAL]|Feed from manual feeder<br>
[PAPERSOURCEMANUALENVELOPE]|Feed Envelope from manual feeder<br>
[PAPERSOURCETRAY2]|Feed from Lower Tray<br>
[PAPERSOURCEOPTIONAL]|Feed from Optional Input<br>
[PAPERSOURCEOPTIONALENVELOPE]|Feed from Optional Envelope Feeder                                                                       .............(Must set to Envelope size first)

;Multiple Copies:
The following options will set the printer to print multiple copies. I have supported 1 - 10 copies. See a note at the end for more, or else do the PCL yourself. J
{|
|-valign="top"
|width="10%"|***[COPIES01]**||I
|-valign="top"
|width="10%"|***[COPIES02]**||wont
|-valign="top"
|width="10%"|***[COPIES03]**||patronize
|-valign="top"
|width="10%"|***[COPIES04]**||you
|-valign="top"
|width="10%"|***[COPIES05]**||to
|-valign="top"
|width="10%"|***[COPIES06]**||pretend
|-valign="top"
|width="10%"|***[COPIES07]**||you
|-valign="top"
|width="10%"|***[COPIES08]**||can't
|-valign="top"
|width="10%"|***[COPIES09]**||understand
|-valign="top"
|width="10%"|***[COPIES10]**||this
|-valign="top"
|}
<br>
;Duplex/NonDuplex modes:
These three options set the printer to print in Duplex mode:
{|
|-valign="top"
|width="10%"|***[SIMPLEX]**||Standard one sided printing
|-valign="top"
|width="10%"|***[DUPLEX]**||Long edge binding double sided environmental printing
|-valign="top"
|width="10%"|***[DUPLEXSHORTEDGE]**||Short edge binding double sided printing
|-valign="top"
|}
<br>
Long edge binding is like your standard book. Short edge binding would be used for a calendar or one of those funky long picture books.<br>
;Top Margin:
The following six options set the top margin: how many rows at the top of the logical page to reserve for blank space:
{|
|-valign="top"
|width="10%"|***[TOP0]**||Begin printing at the top of the logical page
|-valign="top"
|width="10%"|***[TOP1]**||Skip one line, then begin printing
|-valign="top"
|width="10%"|***[TOP2]**||Skip two lines, then begin printing
|-valign="top"
|width="10%"|***[TOP3]**||Skip three lines, then begin printing
|-valign="top"
|width="10%"|***[TOP4]**||Skip seventeen lines, then begin printing
|-valign="top"
|width="10%"|***[TOP5]**||Skip five lines, then begin printing
|-valign="top"
|}

===PrintDir===

===New Print PREVIEW Features-===
;Page movement

{|
|-valign="top"
|width="10%"|**<< and >>**||go 10% of the document
|-valign="top"
|width="10%"|**< and >**||go a single page
|-valign="top"
|}
<br>
Select Printer Button - Reselects the printer for subsequent PREVIEW printing. Note- this will not alter the escape sequences embedded in the printer output.  But under NWP this should be printer generic.
