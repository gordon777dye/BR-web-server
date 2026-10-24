---
title: FnSnap__Window_Maintenance
file: FnSnap__Window_Maintenance.md
category: 50-libraries
subcategory: 50-libraries/fnsnap
kind: function
related: []
---
==List and Grid==
===FNLISTSPEC$*50 - Create a window for a list/grid box===

 FNLISTSPEC$*50(&LISTWIN,SR,SC,LROWS,LCOLS,AROWS,MAT H$,MAT W,MAT F$;HTEXT$*100,G$)

Description|<br>
Creates a window that contains either a list box or a grid

Functions used |FNWINHEAD

;Variables:
{|
|-valign="top"
|width="10%"|**LISTWIN **||
|-valign="top"
|width="10%"|**SR **||Startin row posito of the upper left corner of the grid
|-valign="top"
|width="10%"|**SC **||Starting column position of the upper left corner of the grid
|-valign="top"
|width="10%"|**LROWS **||Number of rows that should be provided for the grid
|-valign="top"
|width="10%"|**LCOLS **||Number of columns wide that shouldbe provided for the grid
|-valign="top"
|width="10%"|**AROWS **||Number of extra rows above the size of the grid to include in the window to allow for buttons or other informatin at the bottom.
|-valign="top"
|width="10%"|**MAT H$ **||Header title array information for the grid
|-valign="top"
|width="10%"|**MAT W **||Width array specificatin for the grid
|-valign="top"
|width="10%"|**MAT F$ **||Format specificatin array for the list
|-valign="top"
|width="10%"|**HTEXT$ **||Text to display in a header bar.  If text is included than the listbox/grid aill contain a blue header.  If HTEXT is blank no header will appear.
|-valign="top"
|width="10%"|**G$ **||Blank for a list box "GRID" to create a grid
|-valign="top"
|}
<br>
;Comments:

==Child windows==
===FNWINHEAD - Print the top bar to a window===

Prints a windows look alike bar at the top of a window using graphics that are stored in the ICONS directory directly below the BR root.

[PICT(PICS\SNAP0001.ptf)]

 FNWINHEAD(HWIN,HTEXT$*100,HLEN)

Description|<br>
Creates the top row of a window in windows look-a-like mode with a clickable X and a title

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|**HWIN **||Window number that the top bar is to be placed over
|-valign="top"
|width="10%"|**HTEXT$ **||Message of title that shuld appear printed in white within the top bar
|-valign="top"
|width="10%"|**HLEN **||Length of the bar, which should be the dsame as the width of the window referenced in HWIN
|-valign="top"
|}
<br>
;Comments:<br>
The bar will be another window which will be a child of the underlying parent window.  When the parent is closed the child will automatically close also.

===FNWINDEV - Query FNSNAP for last window opened===

Function transfers from FNSAP to the calling program the window number of the last window opened using FNWIN.  This practice is being replace in 4.17 becasue multiple windows can be opened an closed at will and does not require the strict opening of windows in a specific order.

 FNWINDEV

Description|<br>
Returns the value of the currently open window that has been opened by FNWIN

Functions used |

;Variables:
{|
|-valign="top"
|width="10%"|'''
|-valign="top"
|}
<br>
;Comments:
