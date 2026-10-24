---
title: MSG
file: MSG.md
category: 70-commands
subcategory: 70-commands/information
kind: command
related: [string, internal function, Msg$, 0412, 0414, 0415, 0416, 0417, 0418, 0440]
corrections:
  - "The page documented ONE action, \"KB\", and BR has twenty-five. MSG(\"kb\") was removed from BR
    entirely on 2026-10-12 and now raises 0412; it had been nothing but a second name for
    MSG(\"send\") since 2026-09-30, when the foreground-window check that was its only difference
    became meaningless. Rewritten around send, with the full action list taken from brmsg.cpp's
    brmCommand[] table and the restricted-session permit list from numfunct.cpp
    restrictedMsgCheck(). BR 5.0."
  - "Error 0413 Window Not On Top removed: nothing raises it. It was kb's refusal when BR was not
    the foreground window, and it went with kb. The number stays reserved - BR 5.0 wberrdefs.h
    carries it as BR_DEPRECATED_ERR - so it is listed below as retired rather than deleted
    silently. Error 0440 added, which the page never had."
  - "\"This facility operates through the operating system, so it does not utilize BR scancodes\"
    was true and is not. Since 2026-09-30 send puts its keys into BR's OWN key buffer through
    putKeyVal, the same ring a key pressed in BR's window lands in, and named keys are translated
    to BR's own key values. It reaches this session and nothing else, whatever window has the
    focus, and it needs no focus at all. BR 5.0 brmsg.cpp, the comment above sendKeyFor()."
  - "Keys that mean nothing inside BR - Alt, the Windows and Apps keys, PrintScreen - are now
    DROPPED rather than sent, so the ALT+/ALT- advice at the foot of the page no longer describes
    anything that happens, and LWIN, RWIN, APPS and SNAP in the table below are accepted and
    discarded. The pipe syntax itself is unchanged, and |CTRL+| and |SHIFT+| still work as they
    did. BR 5.0 brmsg.cpp sendKeyFor()."
  - "MSG returns BEFORE its keys arrive. They are queued and fed to BR one at a time, sleeptime
    apart, while the program runs (harnessQueueProgramKey, harness.cpp), so a program must not
    expect them to be there when the call returns - and a string is no longer limited by the size
    of BR's key buffer. BR 5.0."
  - "MSG(\"sleeptime\",n) takes milliseconds, not centiseconds (line 14) or seconds (the closing paragraph); the two statements also contradicted each other. BR 5.0 brmsg.cpp BrMsg_SleeptimeObjCmd stores `sleeptime = (*num) * 1000` and hands it to wb_sleepex, which sleeps in microseconds (common.cpp); the default is `static DWORD sleeptime = 200000` µs = 0.2 s, i.e. 200. Confirmed empirically: a pacing test written to the documented 100 = 1 second ran ten times fast. Reported in context/ERRORS.md 2026-09-28."
  - "Special-character table listed F14 between F9 and F11; the key table in brmsg.cpp defines |F1| through |F12| only, so the row is F10 (there is no F13 or F14)."
  - "Special-character table completed from brmsg.cpp's SpecialChar[] table, which has 20 names the page omitted: CLR, SPACE, SEL, PRINT, EXEC, SNAP, LWIN, RWIN, APPS, NUM#, and the ALTL/ALTR, CTRLL/CTRLR and SHIFTL/SHIFTR press/release pairs. Each description is the entry's Windows VK_ code. The L variants are byte-for-byte the same event as the plain modifier; the R variants add KEYEVENTF_EXTENDEDKEY. NUM, was described as the key pad comma; it sends VK_SEPARATOR."
---
MSG("send",<`string`>) ! type a string into this session

The **MSG** `internal function` (without the dollar sign) is only available for Windows & CS
versions. This should not be confused with `Msg$`. The first parameter is the **action**, and it is
case insensitive. MSG has no effect on Unix or Linux **terminal** sessions, but works under
Client / Server with Unix the same as WINDOWS.

> **`MSG("kb")` was removed in BR 5.0 and now raises `0412`. Use `MSG("send")`,** which takes the
> same arguments and behaves the same way. `kb` was only ever `send` behind a check that BR's
> window was in front; once `send` stopped being able to leave BR there was nothing for that check
> to do.

## The actions

| Action | What it does |
|---|---|
| `send` | type a string into this session — the rest of this page |
| `sleeptime` | milliseconds between the keys `send` types; default 200 |
| `state` | the session's state |
| `getpos` `getwpos` `getcpos` | read the pointer, window and caret positions |
| `setpos` `setwpos` `setcpos` | move them — **refused in a restricted session, 4154** |
| `lclick` `mclick` `rclick` | click — **refused in a restricted session, 4154** |
| `getcb` `putcb` | read and write the clipboard |
| `dump` | write the screen to a file |
| `shot` | write a PNG of the screen to a file |
| `restore` | restore the screen |
| `loop` | the loop check |
| `menu` | redisplay the menu |
| `harness` | open or close this session's assistant channel |
| `grant` | lend the keyboard to an assistant, or take it back |
| `notify` | post a message an assistant can read |
| `agentask` `agenttext` `agentline` | open a question for an assistant, and read what it delivered |

A **restricted session** permits eighteen of these: `state`, `getpos`, `getwpos`, `getcpos`,
`getcb`, `putcb`, `loop`, `sleeptime`, `harness`, `grant`, `dump`, `shot`, `send`, `restore`,
`notify`, `agentask`, `agenttext`, `agentline`. The pointer actions and anything not in the table
are refused with **4154**, and each refusal is logged as a security event naming the action.

## Where the keys go

**`send` types into BR's own key buffer, and nowhere else.** The keys go into the same ring a key
pressed in BR's window lands in, so they reach **this session only**, whatever window has the
focus, and no focus is needed at all.

This changed in BR 5.0. `send` used to emit operating-system keyboard input, which went to whichever
window had the focus — so a program could type into another application, a command prompt, or
another BR session. That is also why error `0413` existed, and why it is now retired.

**MSG returns before the keys arrive.** They are queued and fed to BR one at a time, `sleeptime`
apart, while the program runs and reads them. So `sleeptime` paces what a person sees being typed,
a string is no longer limited by the size of BR's key buffer, and **a program must not expect every
key to be there when the call returns.**

## Error codes

*`0412` Invalid Action Code — the first parameter is not an action. **`MSG("kb")` raises this.**
*`0414` Wrong number of arguments passed
*`0415` Some error that has err message
*`0416` Not enough elements in dimensioned array
*`0417` Dimensioned string length is not big enough
*`0418` Unknown
*`0419` Error in special char spec
*`0440` MSG answer is not a number and the result variable is numeric
*`4154` restricted session: this operation is not permitted

*`0413` Window Not On Top is **retired**. It was `kb`'s refusal when BR was not the foreground
window; nothing raises it now. The number stays reserved and is never reused.

====Special Keystroke Values====

Special characters are enclosed in pipes **|**, and are translated to BR's own key values the way
`key_scan.cpp` translates a physical key. `|CTRL+|` and `|SHIFT+|` are tracked across the keys that
follow them: `|CTRL+|` with a letter gives that control character, `|SHIFT+|` with a character gives
its shifted form on the current keyboard layout (`a` to `A`, `1` to `!`), and either with a
function, arrow or editing key gives that key's control or shifted variant.

**A key that means nothing inside BR is dropped** rather than sent anywhere: Alt, the Windows and
Apps keys, and PrintScreen. They are accepted in the string and discarded, so `LWIN`, `RWIN`,
`APPS` and `SNAP` in the table below do nothing on BR 5.0.

=====Examples=====

If you want to send ctrl+c, you must send the following string:

 00010 MSG("send","|CTRL+|c|CTRL-|")

This says that you want depress the "CTRL" key, type "c", and then release "CTRL".

Example:

 MSG("send","|CTRL+|p|CTRL-|")

Will input the CTRL-P character, which causes BR to perform a printscreen operation.

=====Special Character List=====

**Each char must be enclosed in pipes**

{|
|-valign="top"
|**ALT+ ||width="75%"| press ALT - see note below
|-valign="top"
|**ALT- || release ALT
|-valign="top"|**
|-valign="top"
|**CTRL+ || press CTRL
|-valign="top"
|**CTRL- || release CTRL
|-valign="top"
|**
|-valign="top"
|**SHIFT+ || press SHIFT
|-valign="top"
|**SHIFT- || release SHIFT
|-valign="top"
|**
|-valign="top"
|**ALTL+ ALTL- || press / release ALT — the same key event as ALT+ / ALT-
|-valign="top"
|**ALTR+ ALTR- || press / release ALT with the Windows extended-key flag set
|-valign="top"
|**CTRLL+ CTRLL- || press / release CTRL — the same key event as CTRL+ / CTRL-
|-valign="top"
|**CTRLR+ CTRLR- || press / release CTRL with the Windows extended-key flag set
|-valign="top"
|**SHIFTL+ SHIFTL- || press / release SHIFT — the same key event as SHIFT+ / SHIFT-
|-valign="top"
|**SHIFTR+ SHIFTR- || press / release SHIFT with the Windows extended-key flag set
|-valign="top"
|**
|-valign="top"
|**TAB || press the tabulation key
|-valign="top"
|**RET || press the return key
|-valign="top"
|**ESC || press the escape key
|-valign="top"
|**SPACE || press the space bar
|-valign="top"
|**CLR || press the Clear key (VK_CLEAR)
|-valign="top"
|**
|-valign="top"
|**BACK || press the backward key
|-valign="top"
|**DEL || press the delete key
|-valign="top"
|**INS || press the insert key
|-valign="top"
|**HELP || press the help key
|-valign="top"
|**
|-valign="top"
|**LEFT || send the cursor to the left (left arrow)
|-valign="top"
|**RIGHT || send the cursor to the right (right arrow)
|-valign="top"
|**UP || send the cursor up (up arrow)
|-valign="top"
|**DOWN || send the cursor down (down arrow)
|-valign="top"
|**
|-valign="top"
|**PGUP || press the page up key
|-valign="top"
|**PGDN || press the page down key
|-valign="top"
|**HOME || press the home key
|-valign="top"
|**END || press the end key
|-valign="top"
|**
|-valign="top"
|**SNAP || press the Print Screen key (VK_SNAPSHOT)
|-valign="top"
|**PRINT || press the Print key (VK_PRINT — not Print Screen)
|-valign="top"
|**SEL || press the Select key (VK_SELECT)
|-valign="top"
|**EXEC || press the Execute key (VK_EXECUTE)
|-valign="top"
|**LWIN || press the left Windows key
|-valign="top"
|**RWIN || press the right Windows key
|-valign="top"
|**APPS || press the Applications (context menu) key
|-valign="top"
|**
|-valign="top"
|**F1 || press the function key F1
|-valign="top"
|**F2 || press the function key F2
|-valign="top"
|**F3 || press the function key F3
|-valign="top"
|**F4 || press the function key F4
|-valign="top"
|**F5 || press the function key F5
|-valign="top"
|**F6 || press the function key F6
|-valign="top"
|**F7 || press the function key F7
|-valign="top"
|**F8 || press the function key F8
|-valign="top"
|**F9 || press the function key F9
|-valign="top"
|**F10 || press the function key F10
|-valign="top"
|**F11 || press the function key F11
|-valign="top"
|**F12 || press the function key F12
|-valign="top"
|**
|-valign="top"
|**NUM0 || press the 0 on the key pad
|-valign="top"
|**NUM1 || press the 1 on the key pad
|-valign="top"
|**NUM2 || press the 2 on the key pad
|-valign="top"
|**NUM3 || press the 3 on the key pad
|-valign="top"
|**NUM4 || press the 4 on the key pad
|-valign="top"
|**NUM5 || press the 5 on the key pad
|-valign="top"
|**NUM6 || press the 6 on the key pad
|-valign="top"
|**NUM7 || press the 7 on the key pad
|-valign="top"
|**NUM8 || press the 8 on the key pad
|-valign="top"
|**NUM9 || press the 9 on the key pad
|-valign="top"
|**
|-valign="top"
|**NUM* || press the * on the key pad
|-valign="top"
|**NUM+ || press the + on the key pad
|-valign="top"
|**NUM- || press the - on the key pad
|-valign="top"
|**NUM, || press the key pad separator key (VK_SEPARATOR)
|-valign="top"
|**NUM# || press the key pad decimal point (VK_DECIMAL)
|-valign="top"
|**NUM/ || press the / on the key pad
|-valign="top"
|**
|-valign="top"
|}
To send the pipe character specify <nowiki>|||</nowiki>.

MSG("sleeptime",milliseconds) specifies the number of milliseconds to wait before issuing each string and each control character (`1000` = one second). The default is 200 (0.2 seconds).

**The Alt advice that used to close this page no longer applies.** It described how Windows
interpreted Alt combinations when `send` went through the operating system, and read:

> the ALT key needs to be depressed and released (ALT+ and ALT-) for every Alt-character
> specified - `|alt+|m|alt-||alt+|b|alt-|` works, `|alt+|mb|alt-|` fails.

BR 5.0 drops Alt rather than sending it, so neither form does anything now. Nothing replaces it:
there is no Alt combination to send, because there is no longer an operating system in the path to
interpret one.
