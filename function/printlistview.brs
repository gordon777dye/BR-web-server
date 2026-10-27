00010  ! function\printlistview.brs
00020  ! Created on 07/03/2014
00030  !
00040  ! fnPrintListview - This function prints a listview using Georges functions
00050  !  To use it, select this function for your Print Button, and set the
00060  !  print buttons "UserData" field to match the Control Name for the listview
00070  !  that you wish to print.
00080  !
00090  ! You also may select a title, by specifying it in UserData in the format:
00100  !  TargetListview|Title
00110  !
00120  ! You also may specify column suppression info in the following format:
00130  !  TargetListview|Title|00000XXX
00140  !
00150  !  0 is total
00160  !  1 is no total
00170  !  2 is show field even when grouped by it
00180  !  X is suppress column
00190  !
00200  ! If no title is specified, then the Screen Name is used to get the title.
00210  ! If no column suppression info is specified, then no columns are suppressed
00220  !
00230  dim Title$*255
00240  dim TargetField$*255
00250  dim TotalSupp$*255
00260  dim S(1)
00270  !
00280  def fnPrintListview
00290     mat S(0)
00300     if ~exists(env$("pd")&"temp") then execute "mkdir "&env$("pd")&"temp"
00310     library env$("pd")&"vol002\RTFLIB.DLL" : fnListPrint
00320  !
00330     let TotalSupp$=Title$=TargetField$=""
00340     if pos(UserData$(ControlIndex),"|") then
00350        let Title$=UserData$(ControlIndex)(pos(UserData$(ControlIndex),"|")+1:999)
00360        let TargetField$=UserData$(ControlIndex)(1:pos(UserData$(ControlIndex),"|")-1)
00370        if pos(Title$,"|") then
00380           let TotalSupp$=Title$(pos(Title$,"|")+1:999)
00390           let Title$=Title$(1:pos(Title$,"|")-1)
00400        end if
00410     else
00420        let Title$=uprc$(ScreenIO$(si_ScreenCode)(1:1))&lwrc$(ScreenIO$(si_ScreenCode)(2:999))&" List Print"
00430        let TargetField$=UserData$(ControlIndex)
00440     end if
00450  !
00460     let ListviewSubscript=fnFindSubscript(mat Subscripts$,"ctl_",TargetField$)
00470     if ListviewSubscript then
00480        let fnListPrint(Window,fnListSpec$(ControlSpec$(ListviewSubscript)),"","","",mat S,1,0,totalsupp$)
00490     else
00500        let msgbox("Couldn't find the target listview. Please ensure a valid listview is selected for the Print button, or contact the programmer who worked on your system to fix this error.")
00510     end if
00520  fnend
