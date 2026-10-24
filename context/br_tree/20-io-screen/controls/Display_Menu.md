---
title: Display_Menu
file: Display_Menu.md
category: 20-io-screen
subcategory: 20-io-screen/controls
kind: statement
related: [Windows, Parent=NONE, FKEY, CHAIN, END, STOP, kstat$, input fields, 6200, 3.92I]
---
MENU SUPPORT   (only for the `Windows` version)

When a user defined Windows menu is displayed, the Preferences menu is suppressed. When the user defined menu is cleared, Preferences is restored.

;Summary of menu syntax supported:

*ON FKEY 98 GOTO<
*INPUT MENU
*INPUT MENU TEXT
*INPUT MENU DATA
*INPUT MENU STATUS
*DISPLAY MENU
*DISPLAY MENU TEXT        Used to update a menu.
*DISPLAY MENU DATA        ...
*DISPLAY MENU STATUS
*MENU$
*MENU

This statement is ignored by during execution.

===DISPLAY Menu Enhanced to support a "Window Handle"===
 (??? Which Release ???) - This was added as part of `Parent=NONE`.

 DISPLAY #window,MENU

* Note: Window may be any "window handle", the program will automatically find the "appropriate Top Window".  This means that it's always safe to use your "Current "Child" Window" without having to worry about Parent=NONE status.

* As of 4.20jg, Display #window,Menu does work, but in order for the menu to function properly, you must also display the menu on the "Console" using Display Menu without the #window.

===Sample menu definition statements===

 00100    dim M$(20), PGM$(20), STATUS$(20)
 00110    data "&FILE","","R"
 00120    data "  &New","NEW","ER"
 00130    data "  &Save","SAVE","ER"
 00140    data "  &Quit","QUIT","ER"
 00150    data "&EDIT","","R"
 00160    data "  &Copy","COPY","ER"
 00170    data "  &Cut","CUT","ER"
 00171    data "  -","","R"
 00180    data "  &Paste","PASTE","ER"
 --- additional indentations imply additional menu levels --
 00190    data "  &OPTIONS","",""
 00200    data "    &Verify","","CX"
 00210    data "    &Display Name","","C"
 00220    data "&HELP","","R"
 00225    data "  &HELP","HELP","ER"
 00230 ! 
 00240    let I+=1
 00250    read M$(I),PGM$(I),STATUS$(I) eof 260 : goto 240
 
MAT M$ contains text to display. Each space indent identifies a pulldown menu of the item above.

If the text is "-", a line separator will be displayed.

MAT PGM$ is the data associated with the menu option MAT STATUS$

E = Sends `FKEY` 98 event if selected and no submenus are defined (activate ON FKEY 98 in program)

*P = Protect (disable/grey out/inactive) menu item
*C = Make item a checkable item, selecting item displays a check mark before it.
*X = Used with C, item is checked.
*R = Retain menu option even after the program ends, or chains to another program.

*ECX will return and FKey of 98, is checkable and is checked.
*EC will return an FKey of 98, is checkable and is not checked.

 00260    display MENU: MAT M$, MAT PGM$, MAT STATUS$  !Displays menu
 00270    on fkey 98 goto 400                !
 00275    let KSTAT$(1) ! Wait for a keystroke
 00280    INPUT MENU: MAT M$,MAT PGM$,MAT STATUS$ ! gets current menu settings
 00290    INPUT MENU TEXT: MAT M$ ! Rereads text only
 00300    INPUT MENU DATA: MAT PGM$
 00310    INPUT MENU STATUS: MAT STATUS$
 00400    X$=MENU$ ! returns data ("PGM$") from the last menu option selected
 00410    X=MENU ! returns the subscript of the last menu option selected
 00420    print X,X$

Selections without an "R" status do not stay active across program chains.

===Removing a menu===
The following events will remove a dropdown menu.

*`Clear#Parameters|CLEAR ALL`
*DISPLAY MENU   (with empty variables)
*`CHAIN`
*`END`
*`STOP` (and no item has a R status)

Since INPUT MENU doesn't wait for keyboard or mouse input, it is necessary to use some other means for waiting (`kstat$` or `input fields`). A menu click produces a kstat$ value of `6200` and, beginning with release `3.92I`, an FKEY value of 98.

===Example===

 02100   dim m_a$(1)*256,m_b$(1)*256,m_c$(1)*256
 02200   mat m_a$(0) : mat m_b$(0) : mat m_c$(0)
 02300   let x=5000
 02400   let fn_a('top',str$(x+=1),'E')
 02500   let fn_a(' choice 1',str$(x+=1),'E')
 02600   let fn_a(' choice 2',str$(x+=1),'E')
 02700   let fn_a(' check 1 (C)',str$(x+=1),'C')
 02800   let fn_a(' check 2 (CX)',str$(x+=1),'CX')
 02820   let fn_a(' check 3 (EC)',str$(x+=1),'EC')
 02840   let fn_a(' check 4 (ECX)',str$(x+=1),'ECX')
 02860   pr newpage
 02880   pr f '5,5,Cc 70,,B99':'[Esc] End'
 02882     display menu: mat m_a$,mat m_b$,mat m_c$
 02890   do
 03000     input fields '10,10,C 15,[D]S': pause$
 03100     print f '12,10,C 40,[W]':'menu='&str$(menu)
 03200     print f '13,10,C40 ,[W]':'menu$='&menu$
 03300     print f '14,10,C4 0,[W]':'fkey='&str$(fkey)
 03320     pr 'control returned to the calling program'
 03340     pause
 03400   loop until fkey=99
 03500   end 
 03600   def fn_a(a$*256,b$*256,c$*256)
 03700     mat m_a$(udim(mat m_a$)+1) : m_a$(udim(mat m_a$))=a$
 03720     mat m_b$(udim(mat m_b$)+1) : m_b$(udim(mat m_b$))=b$
 03740     mat m_c$(udim(mat m_c$)+1) : m_c$(udim(mat m_c$))=c$
 04000   fnend  ! fn_a
