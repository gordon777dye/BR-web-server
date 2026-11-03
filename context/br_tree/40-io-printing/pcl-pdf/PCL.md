---
title: PCL
file: PCL.md
category: 40-io-printing
subcategory: 40-io-printing/pcl-pdf
kind: statement
related: []
---
The following Substitute codes work in PCL. Those with a * will work only in PCL. Note that some of these are also mentioned in the "Page Setup Options" section of this chapter.

**Initial configuration**:

(The following must be done before anything is printed to the printer)

|  |  |
| --- | --- |
| **[PORTRAIT]** | Sets the printer to print portrait |
| **[LANDSCAPE]** | Sets the printer to print landscape |

**Logical Page Size**:

The next six settings change the logical page size for printing on {\ul different sized pages}:

|  |  |
| --- | --- |
| **[EXECUTIVE]** | Set the logical page for Executive size paper (7.25 x 10.5) |
| **[LETTER]** | Set the logical page for Letter size paper (8.5 x 11) |
| **[LEGAL]** | Set the logical page for Legal size paper (8.5 x 14) |
| **[LEDGER]** | Set the logical page for Ledger size paper (11 x 17) |
| **[A4PAPER]** | Set the logical page for A4 size paper (210mm x 297mm) |
| **[A7PAPER]** | Set the logical page for A7 size paper (297mm x 420mm) |

The next five settings change the logical page size for printing on {\ul envelopes}:

|  |  |
| --- | --- |
| **[MONARCH]** | (3 7/8 x 7.5) |
| **[COM-10]** | (4 1/8 x 9.5) |
| **[INTERNATIONAL DL]** | (110mm x 220mm) |
| **[INTERNATIONAL C5]** | (162mm x 229mm) |
| **[INTERNATIONAL B5]** | (176mm x 250mm) |

**Paper Source**:

The following six options set the paper source. By default it is set to Auto, and can be changed in printer preferences:
[PAPERSOURCEAUTO]|Feed from Printer Default<br>
[PAPERSOURCEMANUAL]|Feed from manual feeder<br>
[PAPERSOURCEMANUALENVELOPE]|Feed Envelope from manual feeder<br>
[PAPERSOURCETRAY2]|Feed from Lower Tray<br>
[PAPERSOURCEOPTIONAL]|Feed from Optional Input<br>
[PAPERSOURCEOPTIONALENVELOPE]|Feed from Optional Envelope Feeder                                                                       .............(Must set to Envelope size first)

**Multiple Copies**:

The following options will set the printer to print multiple copies. I have supported 1 - 10 copies. See a note at the end for more, or else do the PCL yourself. J

|  |  |
| --- | --- |
| ***[COPIES01]** | I |
| ***[COPIES02]** | wont |
| ***[COPIES03]** | patronize |
| ***[COPIES04]** | you |
| ***[COPIES05]** | to |
| ***[COPIES06]** | pretend |
| ***[COPIES07]** | you |
| ***[COPIES08]** | can't |
| ***[COPIES09]** | understand |
| ***[COPIES10]** | this |

**Duplex/NonDuplex modes**:

These three options set the printer to print in Duplex mode:

|  |  |
| --- | --- |
| ***[SIMPLEX]** | Standard one sided printing |
| ***[DUPLEX]** | Long edge binding double sided environmental printing |
| ***[DUPLEXSHORTEDGE]** | Short edge binding double sided printing |

Long edge binding is like your standard book. Short edge binding would be used for a calendar or one of those funky long picture books.<br>

**Top Margin**:

The following six options set the top margin: how many rows at the top of the logical page to reserve for blank space:

|  |  |
| --- | --- |
| ***[TOP0]** | Begin printing at the top of the logical page |
| ***[TOP1]** | Skip one line, then begin printing |
| ***[TOP2]** | Skip two lines, then begin printing |
| ***[TOP3]** | Skip three lines, then begin printing |
| ***[TOP4]** | Skip seventeen lines, then begin printing |
| ***[TOP5]** | Skip five lines, then begin printing |

### PrintDir

### New Print PREVIEW Features-

**Page movement**

|  |  |
| --- | --- |
| **<< and >>** | go 10% of the document |
| **< and >** | go a single page |

Select Printer Button - Reselects the printer for subsequent PREVIEW printing. Note- this will not alter the escape sequences embedded in the printer output.  But under NWP this should be printer generic.
