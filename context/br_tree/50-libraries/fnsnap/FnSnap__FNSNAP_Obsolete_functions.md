---
title: FnSnap__FNSNAP_Obsolete_functions
file: FnSnap__FNSNAP_Obsolete_functions.md
category: 50-libraries
subcategory: 50-libraries/fnsnap
kind: function
related: []
---
==Window and screen processing==
===FNMGCLR - clears a message form the fnpick message line===

 FNMGCLR ! Clear message and reset error processing flags

Description|<br>
Clears the message line form the old FNSNAP message line setup

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNSAVPART - legacy function to save a portion of the screen - obsolete in 4.17===

 FNSAVPART(SR$,SC1$,ER$,EC$,CLEARIT) !:

Description|<br>
Saves a portion of the screen - this is a legacy from character days

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNRELPART - legacy function to clear a portion of the screen obsolete in 4.17===

 FNRELPART(SCRREF,RESTSCR) !:

Description|

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNWIN - legacy function to open a window in numeric order===

 FNWIN(SR$,SC1$,ER$,EC$,WINTITL$*80,BORDTYP$*32,WINCOL$,WINNUM,DIMLST) !:

Description|<br>
Opens a window and assigns an incremental number to the window.

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNCLSWIN - legacy function to close a window opened by FNWIN===

 FNCLSWIN(CLRWIN) !:

Description|<br>
Closes the last window opened by FNWIN and sets the window number to zero

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNPM - legacy message box on the main window===

 FNPM(TXT$*78;CENTER) !:

Description|<br>
Prints a message on the message line and optionally center the text.

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**The message line must have been previously defined in the library.  See FNINIT
|-valign="top"
|}
<br>
;Comments:

==Point and pick==
===FNKEYSEL - direct file look up function requires a fixed position font===

[PICT(PICS\SNAP0012.ptf)]

 FNKEYSEL(SROW$,SCOL$,PP,&KEY$,FILENBR,FORM$*100,BT$*80,BTP$,MAXL,HK$*40,HLPFIL$*80,HLPELE) !:

Description|<br>
A legacy direct point and shoot listing of records in a file.  Character based and not GUI looking.

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNPICK_EX - A point and shoot legacy using a single matrix requires a fixed position font===

[PICT(PICS\SNAP0011.ptf)]

 FNPICK_EX(PICK_OPS,SROW$,SCOL$,PP,MAT L$,WINTITLE$*80,BORDTYPE$,MAXL,HK$*40,HLPFIL$*80,PTYP,HLPELE,MANY,RPTFCOL,AUTOSEL,MAT SEL_TYPES$,&MUSTRSET,SEARCHON,SSTR$*40;MAT SEL,&SCPT,&XKEY,MAT PICKWIN)

Description|

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNPICK - A point and shoot legacy using a single matrix requires a fixed position font===

 FNPICK(PICK_OPS,SROW$,SCOL$,PP,MAT L$,WINTITLE$*80,BORDTYPE$,MAXL,HK$*40,HLPFIL$*80,PTYP,HLPELE,MANY,RPTFCOL,AUTOSEL,MAT SEL_TYPES$,&MUSTRSET,SEARCHON,SSTR$*40;MAT SEL,&SCPT,&XKEY)

Description|

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNKEYSEL_EX - a legacy direct file access point and shoot requires a fixed sized font===

 FNKEYSEL_EX(SROW$,SCOL$,PER_WIN,&KEY$,FILENBR,KFORM$*100,NBRFIELDS,RETKEYFIELD,ACTKEYFIELD,CANCELKEY,WINTITLE$*80,BORDTYPE$,TOTLENGTH,HK$*40,HLPFIL$*40,HLPELE;KEY_CHECK,KEY_CHECK_FIELD$*30) !:

Description|

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNPOPUP - legacy code for a pop-up choice box===

 FNPOPUP(MAT MOPT$,MAT HOTKEY$,SROW$,SCOL$,MENUTITLE$*80,MENUBORDER$,MAT HM$,HMROW,HK$*40,HLPFIL$*60,OPLEN,POPNUM;POPRESET) !:

Description|<br>
Created a pop up list box with options.  This is an old character based function that has been converted to use the new gui.

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

==Supporting functions==
===Data transfer between program and library===
;FNPUTPICKWIN - transfers pick window number to FNSNAP form program

 FNPUTPICKWIN(MAT PPICKWIN)

Description|<br>
Transfers the PICKWIN matrix from the calling program to FNSNAP

Functions used |None

;Variables:
{|
|-valign="top"
|width="10%"|**MAT PPICKWIN matrix to transfer
|-valign="top"
|}
<br>
;Comments:

;FNGETPICKWIN - retrieve pick window matrix from FNSNAP

 FNGETPICKWIN(MAT PPICKWIN)

Description|<br>
Transfers the PICKWIN matrix from FNSNAP to the calling program

Functions used |None

;Variables:
{|
|-valign="top"
|width="10%"|**MAT PPICKWIN matrix to transfer
|-valign="top"
|}
<br>
;Comments:

;FNPICKWIN - gets the current pick window from fnsnap library

 FNPICKWIN(WIN,VALWIN) !:

Description|

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNWINDEV - returns the number of the currentlyactive FNSNAP window using the old system===

If FNWIN is being used to open windows then FNWINDEV returns the number of the most recently opened, and still open, window.  This proactive is becoming obsolete with GUI applications.

 FNWINDEV

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**None
|-valign="top"
|}
<br>
;Comments:

===FNLEADZERO$===

 FNLEADZERO$(NUMBER,LENGTH)- converts and zero fills a number

Turns a number into a zero filled string, similar to CNVRT$(PIC(#####)",number)

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNGETK$ - \fs20===

 FNGETK$(X) !:

Get X key strokes and return the uppercase unhexed value if it is a letter

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:<br>
Used by some FNSNAP functins to create seach strings

===FNSETALL - set all elements of an array===

 FNSETALL(SFLG) ! Set ALL elements of MAT SEL & MAT L$ 1/0

Description|

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNSETSEL - set all elements of an array===

 FNSETSEL(ELE,SETFLG) ! Set L$(ELE) for setflg 1-ON,0-OFF

Description|

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNPRTPICKBAR - a function to position a colored pick bar in FNPICK===

 FNPRTPICKBAR(COLOR$,PICK_ELE) ! print the fnpick light bar for COLOR$, element PICK_ELE

Description|

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNZLPAD$ - pads a number with zeros and converts to string===

 FNZLPAD$(NUMBER,LENGTH,DECIMALS)

Description|

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**
|-valign="top"
|}
<br>
;Comments:

===FNINIT - initializes the variable required by the original FNSNAP functions===

Converts

 FN()

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**FILENAME$**||
|-valign="top"
|width="10%"|**DIRNAME$**||
|-valign="top"
|}
<br>
;Comments:

===FNNOKEY - chekc to see if CMDKEY or FKEY were pressed===

Check to see if a CMDKEY or FKEY was pressed and produce an error for field C

 FNNOKEY(c)

;Functions used:

;Variables:
{|
|-valign="top"
|width="10%"|**C '''||Field number to produce an error for
|-valign="top"
|}
<br>
;Comments:<br>
Used by some older FNSNAP Utilities
