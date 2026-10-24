---
title: FKEY
file: FKEY.md
category: 20-io-screen
subcategory: 20-io-screen/windows-cursor
kind: function
related: [FKEY (Disambiguation), internal function, CmdKey, print fields, input fields, Option, Double Click, Option (config), KSTAT$, Input Select]
provenance: recovered-2b (redirect-collision casualty re-fetched from wiki)
---
 FKEY(<value>)
See also `FKEY (Disambiguation)`

The **FKey** `internal function` is similar to `CmdKey`, but returns more information, particularly about how a field is exited. A **HotKey** is very similar to either of these, but is different in that hotkey is not a control word, statement, nor internal function.  HotKey is simply a term that refers to an assigned FKey value. Hot key (Fkey) values can be assigned via a `print fields` or `input fields` statement that makes a control clickable. Fkey values can also be assigned to entire windows to make the window trigger an interrupt when it is clicked.

Additionally, when an Input Field is assigned an Fkey value and Enter is pressed while the cursor is in that field, or the field is double clicked, then that fkey number is assigned to the internal FKEY variable and, if that value is preset to take action, then that interrupt occurs. OPTION 48 causes BR to disregard Fkey value assignments when Enter is pressed (FKEY is set to zero).

The following table shows a comparison of the values that are returned by FKey and CmdKey when a particular key is pressed to terminate field input. Fkey values above 100 do not cause INPUT FIELDS to terminate processing, but when control is returned to a program for other reasons the FKEY internal function can be used to determine what was keyed.

`Image:CMDKEY_FKEY.jpg`

FKey(X) sets the value of FKey to X. It also sets the value of CmdKey. However, if X is greater than 91 then CmdKey is set to zero. Likewise, the function CmdKey(X) sets both CmdKey and FKey to the value of X.

====Keyboard Mapping for FKeys====

{| border="1" style="border-collapse:collapse;"
! style="background:#a5c7ff;" colspan="1" rowspan="2"|Key
! style="background:#a5c7ff;" colspan="1" rowspan="2"|Shifted
! style="background:#a5c7ff;" colspan="2" rowspan="1" | FKey Interrupt
! style="background:#a5c7ff;" | (qwerty)
! style="background:#a5c7ff;" colspan="1" rowspan="2" | Control
! style="background:#a5c7ff;" colspan="1" rowspan="2" | Details
|-style="background:#a5c7ff;"
! style="background:#a5c7ff;" |Plain
! style="background:#a5c7ff;" |Shifted
! style="background:#a5c7ff;" |Alt
|- style="background:#ddeaff;"
|a || A ||  ||  || 30 || 0||
|-
|b || B ||  ||  || 48 || 90 ||
|- style="background:#ddeaff;"
|c || C ||  ||  || 46 || ||
|-
|d || D ||  ||  || 32 || ||
|-style="background:#ddeaff;"
|e || E ||  ||  || 18 || 113 ||
|-
|f || F ||  ||  || 33 || 91 ||
|-style="background:#ddeaff;"
|g || G ||  ||  || 34 || 111 ||
|-
|h || H ||  ||  || 35 ||
|-style="background:#ddeaff;"
|i || I ||  ||  || 23 || 110 ||
|-
|j || J ||  ||  || 36 || 104 ||
|-style="background:#ddeaff;"
|k || K ||  ||  || 37 || 102 ||
|-
|l || L ||  ||  || 38 || 116 ||
|-style="background:#ddeaff;"
|m || M ||  ||  || 50 || 0 ||
|-
|n || N ||  ||  || 49 || 103 ||
|-style="background:#ddeaff;"
|o || O ||  ||  || 24 || 115 ||
|-
|p || P ||  ||  || 25 || ||
|-style="background:#ddeaff;"
|q || Q ||  ||  || 16 || ||
|-
|r || R ||  ||  || 19 || 105 ||
|-style="background:#ddeaff;"
|s || S ||  ||  || 31 || ||
|-
|t || T ||  ||  || 20 || 106 ||
|-style="background:#ddeaff;"
|u || U ||  ||  || 22 || 114 ||
|-
|v || V ||  ||  || 47 || ||
|-style="background:#ddeaff;"
|w || W ||  ||  || 17 || 112 ||
|-
|x || X ||  ||  || 45 || ||
|-style="background:#ddeaff;"
|y || Y ||  ||  || 21 || 100 ||
|-
|z || Z ||  ||  || 44 || ||
|-style="background:#ddeaff;"
|1 || ! || || || || ||
|-
|2 || @ ||  ||  || 121 || ||
|-style="background:#ddeaff;"
|3 || # ||  ||  || 122 || ||
|-
|4 || $ ||  ||  || 123 || ||
|-style="background:#ddeaff;"
|5 || % ||  ||  || 124 || ||
|-
|6 || ^ ||  ||  || 125 || ||
|-style="background:#ddeaff;"
|7 || & ||  ||  || 126 || ||
|-
|8 || * ||  ||  || 127 || ||
|-style="background:#ddeaff;"
|9 || ( ||  ||  || 128 || ||
|-
|0 || ) ||  ||  || 129 || ||
|-style="background:#ddeaff;"
|` || ~ || || || || ||
|-
| - || _ ||  ||  || 130 || ||
|-style="background:#ddeaff;"
|= || + || || || || ||
|-
|[ || { ||  ||  ||  || 99 ||
|-style="background:#ddeaff;"
|] || } || || || || ||
|-
|\ || | || || || || ||
|-style="background:#ddeaff;"
|; || : || || || || ||
|-
|' || " || || || || ||
|-style="background:#ddeaff;"
|, || < || || || || ||
|-
|. || > || || || || ||
|-style="background:#ddeaff;"
|/ || ? || || || || ||
|-
|tab ||  || 110 || 111
|-style="background:#ddeaff;"
|field+ ||  || 114 ||
|-
|field- ||  || 115 ||
|}

Note that BR retains select (hilite) status while shift or control remain depressed after a program receives control in navigation mode. When in edit mode, the control key temporarily switches to navigation mode.

<nowiki>*</nowiki>In the following chart, the asterisks denotes a change that occurred with version 4.3. Most of the keys in prior versions were unassigned, but a few were assigned differently.

{| border="1" style="border-collapse:collapse;"
! style="background:#a5c7ff;" colspan="1" rowspan="2"|Key
! style="background:#a5c7ff;" colspan="1" rowspan="2"|Shifted
! style="background:#a5c7ff;" colspan="2" rowspan="1" | FKey Interrupt
! style="background:#a5c7ff;" | (qwerty)
! style="background:#a5c7ff;" colspan="1" rowspan="2" | Control
! style="background:#a5c7ff;" colspan="1" rowspan="2" | Details
|-style="background:#a5c7ff;"
! style="background:#a5c7ff;" |Plain
! style="background:#a5c7ff;" |Shifted
! style="background:#a5c7ff;" |Alt
|-
|enter ||  || 0 || 0 || 0 || 0 ||
|-style="background:#ddeaff;"
|home ||  || 112 || 112* || 112 || 112 ||
|-
|end ||  || 113 || 113* || 113 || 113 ||
|-style="background:#ddeaff;"
|pageUp ||  || 90 || 90 || 90 || 90 ||
|-
|pageDn ||  || 91 || 91 || 91 || 91 ||
|-style="background:#ddeaff;"
| || || || || ||
|-
|up-arrow || || 102 || 102* || 102 || 102* || FIELDS
|-style="background:#ddeaff;"
|down-arrow || || 104 || 104* || 104 || 104* ||FIELDS
|-
|left arrow ||   || 103 || 103* || 103 || 103* || FIELDS
|-style="background:#ddeaff;"
|right arrow || || 116 || 116* || 116 || 116*   || FIELDS
|-
|up-arrow || || 105 || 105 || 105* || 105* ||SELECT
|-style="background:#ddeaff;"
|down-arrow  || || 106 || 106 || 106* || 106* || SELECT
|-
|left arrow  || || 108 || 108 || 108* || 108* || SELECT
|-style="background:#ddeaff;"
|right arrow  || || 109 || 109 || 109* || 109* || SELECT
|-
|
|-style="background:#ddeaff;"
|left click ||  || 200 ||
|-
|second left ||  || 201 ||
|-style="background:#ddeaff;"
|right click ||  || 100 ||
|-
|second right ||  || 101 ||
|-style="background:#ddeaff;"
|wheel up ||  || 124 ||
|-
|wheel down ||  || 125 ||
|-style="background:#ddeaff;"
|
|-
|F1 ||  || 1 || 11 || 1 || 21 ||
|-style="background:#ddeaff;"
|F2 ||  || 2 || 12 || 2 || 22 ||
|-
|F3 ||  || 3 || 13 || 3 || 23 ||
|-style="background:#ddeaff;"
|F4 ||  || 4 || 14 || 93 || 24 ||
|-
|F5 ||  || 5 || 15 || 5 || 25 ||
|-style="background:#ddeaff;"
|F6 ||  || 6 || 16 || 6 || 26 ||
|-
|F7 ||  || 7 || 17 || 7 || 27 ||
|-style="background:#ddeaff;"
|F8 ||  || 8 || 18 || 8 || 28 ||
|-
|F9 ||  || 9 || 19 || 9 || 29 ||
|-style="background:#ddeaff;"
|F10 ||  || 10 || 20 || 10 || 30 ||
|-
|F11 ||  || 11 || 21 || 11 || 31 ||
|-style="background:#ddeaff;"
|F12 ||  || 12 || 22 || 12 || 32 ||
|}

====Standard FKeys====

{| border="1"
!FKey value
!Cause
!Additional
|-
|1
|F1
|-
|2
|F2
|-
|3
|F3
|-
|4
|F4
|-
|5
|F5
|-
|6
|F6
|-
|7
|F7
|-
|8
|F8
|-
|9
|F9
|-
|10
|F10
|-
|11
|F11 or Shift+F1
|-
|12
|F12 or Shift+F2
|-
|13
|Shift+F3
|-
|14
|Shift+F4
|-
|15
|Shift+F5
|-
|16
|Shift+F6 or Alt+Q
|-
|17
|Shift+F7 or Alt+W
|-
|18
|Shift+F8 or Alt+E
|-
|19
|Shift+F9 or Alt+R
|-
|20
|Shift+F10 or Alt+T
|-
|21
|Ctrl+F1 or Alt+Y
|-
|22
|Ctrl+F2 or Alt+U
|-
|23
|Ctrl+F3 or Alt+I
|-
|24
|Ctrl+F4 or Alt+O
|-
|25
|Ctrl+F5 or Alt+P
|-
|26
|Ctrl+F6
|-
|27
|Ctrl+F7
|-
|28
|Ctrl+F8
|-
|29
|Ctrl+F9
|-
|30
|Ctrl+F10 or Alt+A
|*
|-
|31
|Ctrl+F11 or Alt+S
|*
|-
|32
|Ctrl+F12 or Alt+D
|*
|-
|33
|Alt+F
|*
|-
|34
|Alt+G
|*
|-
|35
|Alt+H
|*
|-
|36
|-
|37
|Alt+K
|*
|-
|38
|Alt+L
|*
|-
|39
|-
|40
|-
|41
|-
|44
|Alt+Z
|*
|-
|45
|Alt+X
|*
|-
|46
|Alt+C
|*
|-
|47
|Alt+V
|*
|-
|48
|Alt+B
|*
|-
|49
|Alt+N
|*
|-
|50
|Alt+M
|*
|-
|90
|page up
|-
|91
|page down
|-
|92
|tab change
|-
|93
|Application Exit, Alt+F4 or Big X
|An `Option` exist to reassign this to a different value
|-
|98
|Drop Down Menu
|align="right"|??
|-
|99
|Escape or Alt+J
|*
|-
|100
|Ctrl+Y
|-
|104
|AE field exit
|-
|105
|AE field exit
|-
|106
|AE field exit
|-
|107
|AE field exit
|-
|110
|AE field exit (Tab)
|-
|200
|click
|-
|201
|`Double Click`
|(Requires `Option (config)` 52)
|}
;  * Alt+Key combinations will not work if a drop down menu co-exists with that letter specified as hot (with a &) at any level of the menu.


FKey 200 and FKey 206 are similar.  On windows machines with single click enabled a 200 will be returned instead of a 206.

====From a GRID with AEX attributes====

These have been tested and should probably be added to the the chart above.

{| border="1"
!FKey value
!Cause
!Additional
|-
|91
|Ctrl+Left
|-
|110
|Tab
|-
|111
|Shift+Tab
|-
|112

|Home
|-
|113
|End
|-
|114
|Field Plus (+) (the Plus key on the number pad)
|-
|116
|Right
|-
|120
|Ctrl+End or Shift+End
|-

|126
|Ctrl+Up
|-
|127
|Ctrl+Down
|-
|133
|Shift+Left
|-
|134
|Shift+Right
|-
|135
|Shift+Up
|-
|136
|Shift+Down
|-
|200
|`Double Click` (sometimes - also 201)  Also Click on windows machines with the single click preference enabled.
|-
|201
|Double Click (sometimes - also 200)
|(Requires `Option (config)` 52)
|-
|206
|Click
|}

====From a GRID with LX attributes====

{| border="1"
!FKey value
!Cause
!Additional
|-
|124
|Mouse Wheel scroll up
|-
|125
|Mouse Wheel scroll down
|}

====From a TextBox with AEX attributes====

These have been tested and should probably be added the the chart above.  FKey values listed in the GRID with AEX section above are not duplicated here.
{| border="1"
!FKey value
!Cause
!Additional
|-
|102
|Up
|-
|103
|Left (from leftmost position)
|-
|104
|Down

|}

====From a GRID with L attributes====

{| border="1"
!FKey value
!Cause
!Additional
|-
|105
|Attempt to Scroll past top
|-
|106
|Attempt to Scroll past bottom
|}

====KStat Only====

The `KSTAT$` `internal function` will return a few additional FKey values which `Input Fields` and `Input Select` will not.  These FKeys are as follows:

{| border=1
!FKey
!Description
|-
|176
|Click
|-
| 177
|Second Click in Double Click
|-
|180
|Right Click
|-
|181
|Second Click in Double Right Click
|}

====Combobox Only====

`Combo Boxes` that contain the x `attribute` often return FKey **209** in such cases use `curfld`(curfld,fkey) to avoid blinking.

  00010 do
  00020    rinput #win,fields mat io$,attr '[A]': mat setting$,choice_policy$,choice_desc$
  00030    if fkey=209 then let curfld(curfld,fkey)
  00040 loop until fkey<>209

==Hot Windows==

For versions 4.2 and higher `FKEY=` may now be specified in an `Open Window` `statement`. This makes the window `hot`, so a user can click anywhere in the window to tell the program that they want to switch focus.  The FKEY value is then inheritable, but not to independent windows. In other words, assigning an FKEY value to a window automatically assigns the same FKEY value to it's child windows, unless another FKEY ( or -1 ) is assigned to a child.

<noinclude>
</noinclude>
