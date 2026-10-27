!  #Autonumber# 10,10
!  Screenio - Copyright June 2008 By Gabriel Bakker - All Rights Reserved
!  This Library Is A Combination Screen Generator / All Purpose Fm
!  Screenio Builds Upon Fileio And Is Dependent Upon Fileio
!
!  If You Run This Library As A Program, It Will Function As A Screen
!  Generator That Generates And Maintains The Sceen Data Used To Design
!  And Store Your Custom File Maintenance Routines.
!
!  If You Link To This Library And Call It As A Function Library,
!  Calling Function Fnfm("scrnname") (or fnfm$) Will Run The File
!  Maintenance Routine Titled Scrnname And Modify The Datafile That
!  Routine Is Designed To Modify.
!
!  Special Thanks to all our Supporters
!
   def fnVersion=2.95
!
!  #Autonumber# 2100,10
   library : fnDesignScreen
   let Fndesignscreen
   execute "system"

   print "This is the screenio runtime library and designer. It is used" !:
   print "creating and running ScreenIO programs." !:
   print !:
   print "If you want to know more information about ScreenIO: Business" !:
   print "Rules Rapid Development Technologies, contact Gabriel Bakker" !:
   print "of Sage AX, at gabriel.bakker@gmail.com."
   end
!
!  #Autonumber# 3000,10
!  ***************************************************************
!  *                       Default Settings                      *
!  ***************************************************************
!  To modify these settings, make your own ScreenIO.ini file
!  and place it in the root folder, or the screenio folder.
!  copy and past the following default settings into it and
!  modify them as necessary.
!
!  You want only the actual settings, not the function definition.
!
   def fnDefaultSettings
      let setting_FileIOPath$="fileio" !:
      let setting_ScreenIOPath$="screenio" !:
      let setting_LexiPath$="lexi" !:
      let setting_ClockPath$="clocks\clock" !:
      let setting_ImagePath$="images" !:
      let setting_BRExecutable$="auto" !:
      let setting_BatchFileCommand$="none" !:
      let setting_ScreenFolder$="screenio" !:
      let setting_FunctionFolder$="function\" !:
      let setting_DateFormatDisplay$="m/d/cy"
      let Setting_EnableLogging=0 !:
      let setting_ClickToMove=1 !:
      let setting_PreviewListviews=1 !:
      let setting_RealtimeFilters=0 !:
      let setting_DetailedComments=1 !:
      let setting_Load_Filter=0 !:
      let setting_FunctionSel_Filter=1 !:
      let setting_Pad_Functions=0 !:
      let setting_debug_locked_msg=0
   fnend

   def fnParseSettings
      if Setting_FunctionFolder$(len(Setting_FunctionFolder$):len(Setting_FunctionFolder$))><"\" then let Setting_FunctionFolder$=Setting_FunctionFolder$&"\"
      if Setting_ScreenFolder$(len(Setting_ScreenFolder$):len(Setting_ScreenFolder$))="\" then let Setting_ScreenFolder$=Setting_ScreenFolder$(1:len(Setting_ScreenFolder$)-1)
      if Setting_ImagePath$(len(Setting_ImagePath$):len(Setting_ImagePath$))="\" then let Setting_ImagePath$=Setting_ImagePath$(1:len(Setting_ImagePath$)-1)
      if setting_ClockPath$(len(setting_ClockPath$):len(setting_ClockPath$))="\" then let setting_ClockPath$=setting_ClockPath$(1:len(setting_ClockPath$)-1)
   fnend

!  #Autonumber# 4000,10
!  ***************************************************************
!  *                       Screen Designer                       *
!  ***************************************************************
SCREENDESIGNERDIMS: ! Dimension Variables

   dim setting_EnableLogging, setting_PreviewListviews, setting_RealtimeFilters, setting_DetailedComments, setting_debug_locked_msg, setting_Pad_Functions, setting_FunctionSel_Filter, setting_FileIOPath$*255, setting_LexiPath$*255, setting_ScreenIOPath$*255, setting_ClockPath$*255, setting_BatchFileCommand$*1024, setting_BRExecutable$*255, setting_ImagePath$*255, setting_ScreenFolder$*255, setting_FunctionFolder$*255, setting_DateFormatDisplay$*64, setting_ClickToMove
!
!  File Arrays
   dim Screenio$(1)*255, Screenio(1)
!
!  Screen Control Arrays
   dim Controlname$(1)*50, Fieldname$(1)*50, Description$(1)*255, Vposition(1), Hposition(1),Fieldtype$(1)*8, Specwidth(1), Width(1), Height(1), Truevalue$(1)*60, Falsevalue$(1)*60, Function$(1)*255, Picture$(1)*255, Parent$(1)*20, Fgcolor$(1)*6, Bgcolor$(1)*6, Justify$(1)*1, Attr$(1)*128, Multiselect(1), GridLines(1), Protected(1), Invisible(1), Tooltip$(1)*1000, Cnvrtin$(1)*255, Cnvrtout$(1)*255, Userdata$(1)*255
   dim Form$(1)*2000, Fieldsssubs$(1)*50, Fieldsnsubs$(1)*50, FrameWindows(1), FrameKeys$(1), FrameSpecControl$(1)*255
   dim Fieldssspec$(1)*30, Fieldsnspec$(1)*30, Fieldssdescription$(1)*255, Fieldsndescription$(1)*255, FieldsSPos(1),FieldsNPos(1), FieldsSDateFormat$(1)*64, FieldsNDateFormat$(1)*64
   dim Selectedcontrols(1)

EndScreenDesignerDims: !
!
!  #Autonumber# 11800,10
CONSTANTS: ! Define Preprocessed Constants
!   .   #Define#  [[Screencontrols]]   = "mat ControlName$,mat FieldName$,mat Description$,mat VPosition,mat HPosition,mat FieldType$,mat SpecWidth,mat Width,mat Height,mat TrueValue$,mat FalseValue$,mat Function$,mat Picture$,mat Parent$,mat FGColor$,mat BGColor$,mat Justify$, mat Attr$, mat Protected, mat Invisible, mat Tooltip$, mat CnvrtIn$, mat CnvrtOut$, mat Multiselect, mat UserData$, mat GridLines"
!   .   #Define#  [[Screencontrols1]]  = "mat ControlName$,mat FieldName$,mat Description$,mat VPosition,mat HPosition,mat FieldType$,mat SpecWidth,mat Width,mat Height,mat TrueValue$,mat FalseValue$,mat Function$,mat Picture$,mat Parent$,mat FGColor$,mat BGColor$,mat Justify$, mat Attr$,"
!   .   #Define#  [[Screencontrols2]]  = " mat Protected, mat Invisible, mat Tooltip$, mat CnvrtIn$, mat CnvrtOut$, mat MultiSelect,mat UserData$,mat GridLines"
!
!  #Autonumber# 12000,10
DESIGNSCREEN: !  Preforms Environment Testing And Launches The Screen Designer
   def library Fndesignscreen(;Screenname$)
      if Trim$(Env$("guimode"))="" then
         print "Please use a New GUI version of BR to design your screens."
      else
         let Fnloadandeditscreen(Screenname$)
      end if
   fnend

   def fnAutoCallScreen(;Screenname$) ! Helper function for self-calling screens.
      library : fnDesignScreen
      let fnDesignScreen(ScreenName$)
   fnend

!  #Autonumber# 13000,10
LOADANDEDITSCREEN: !  Load Files And Launch Main Screen Designer
   def Fnloadandeditscreen(;Screenname$,___,Window,Turnguibackoff, Fscreenio,Fscreenfld,Saveonexit,Oldrows,Oldcols,ForceVisibility)
!
      if fnWarnMessage then execute "system" ! #Autonumber# 13040,10
      let fnSettings ! Also includes library linkage to FileIO
!
      let Fnopenscreenfiles(Mat Screenio$,Mat Screenio)
!
      if Fnreadscreen(Screenname$, Mat Screenio$, Mat Screenio, [[Screencontrols]]) then !  Successful Read
         let Turnguibackoff=(Env$("guimode")=="OFF")
         if Turnguibackoff then execute "config gui on"
!
         let fnSetForceVisibility(0)
         let Fnreadscreensize(Oldrows,Oldcols)
!
         let Fneditscreen(Mat Screenio$, Mat Screenio, [[Screencontrols]])
!
         open #0: "rows="&Str$(Oldrows)&",cols="&Str$(Oldcols),display,outin
         if Turnguibackoff then execute "config gui off"
         let fnResetForceVisibility
      end if
   fnend
!
!  #Autonumber# 14000,10
EDITSCREEN: ! Main Screen Designer
   def Fneditscreen(Mat Screenio$, Mat Screenio, [[Screencontrols]];___,Wdebug,Weditor,Wtoolbar,Debugsize,Wactivewindow,Mode,Control,Function)
      dim Displayref_Screenio$(1)*255
      dim Displayref_Screenio(1)
!
      mat Displayref_Screenio$(Udim(Mat Screenio$))
      mat Displayref_Screenio(Udim(Mat Screenio))
!
      let Fndefineinputmodes
      do
!
! .   !  Update Screen If Anything Changes
         if ~(Fnsameas(Mat Displayref_Screenio$,Mat Screenio$) And Fnsamea(Mat Displayref_Screenio,Mat Screenio)) then
            let Fnredrawentirescreen(Wtoolbar,Wdebug,Weditor,Mat Screenio$, Mat Screenio, [[Screencontrols]])
!
            mat Displayref_Screenio$=Screenio$
            mat Displayref_Screenio=Screenio
!
            let Fnrepopulatefieldslistview(Screenio$(Si_Filelay))
            let Displayref_Screenio$(Si_Filelay)=Screenio$(Si_Filelay)
         else
! .      !  Update Field List Dropdown If It Changes
            if Displayref_Screenio$(Si_Filelay)<>Screenio$(Si_Filelay) then
               let Fnrepopulatefieldslistview(Screenio$(Si_Filelay))
               let Displayref_Screenio$(Si_Filelay)=Screenio$(Si_Filelay)
            end if
         end if
         let Fncolordebugactive((Mode==Inputdebugmode))
         let Fncolorfieldsactive((Mode==Inputfieldlistmode))
         let Fncolorattributeactive((Mode==Inputattributesmode),Mat Screenio$,Mat Screenio)

         if Fnvalidatefields(Mat Screenio$, Mat Screenio, [[Screencontrols]]) then !  Update Validate Drop Down
            ! if we're in Movement mode or fields list mode, dont erase dots
            if (Mode=InputEditorMoveMode or Mode=InputEditorMode or Mode=InputListviewMode) and (LastMode=InputEditorMoveMode or LastMode=InputEditorMode or LastMode=InputListviewMode) then
               let Fnrenderscreen(Mat Screenio$, Mat Screenio, [[Screencontrols]],1)
            else
               let Fnrenderscreen(Mat Screenio$, Mat Screenio, [[Screencontrols]])
            end if
         end if
!
         let LastMode=Mode
         let Fncheckpoint(Mat Screenio$,Mat Screenio,[[Screencontrols]]) ! Save Undo Information
!
         let Function=Fnpreforminput(Mode,Control,Mat Screenio$,Mat Screenio,[[Screencontrols]])
         let Fnprocesscommand(Function, Curfld, Mode,Control,Mat Screenio$,Mat Screenio, [[Screencontrols]])
!
      loop Until Mode=Quitmode
!
      let Fntrytoclose(Weditor)
      let Fnclosedebugwindow
      let Fnclosetoolbarwindow
      let Fncloseeditorwindow
!
      let Fnclearwindowsmenu
      let Fnclosescreenfiles
!
      close #0:
!
   fnend
!
!  #Autonumber# 16000,5
! *****************************************************************
! ************************ Main Input Loop ************************
! *****************************************************************
DEFINEMODES: !  Define The Input Spec Modes
   def Fndefineinputmodes
      dim Inputattributesmode, Inputfieldlistmode, Inputeditormode, Inputeditormovemode, Inputdebugmode, Quitmode, Selectcolormode, Selectfilelaymode, Inputlistviewmode, Selecteventsmode, Settabordermode, Configuredebugmode, ConfigureProtectedMode
!
      let Inputattributesmode=1 !:
      let Inputfieldlistmode=2 !:
      let Inputeditormode=3 !:
      let Inputeditormovemode=4 !:
      let Inputdebugmode=5 !:
      let Quitmode=6 !:
      let Selectcolormode=7 !:
      let Selectfilelaymode=8 !:
      let Inputlistviewmode=9 !:
      let Selecteventsmode=10 !:
      let Settabordermode=11 !:
      let Configuredebugmode=12 !:
      let ConfigureProtectedMode=13
   fnend
!


PREFORMINPUT: !  Preform Main Input Operation
   def Fnpreforminput(&Mode,&Control,Mat Screenio$,Mat Screenio,[[Screencontrols]];___,Window,Function,Tempcolor$,Index)
      dim Inputtooltips$(1)*255, Inputspec$(1)*60, Inputdata$(1)*255, InputTTip$(1)*255, Inputsubs(1), Inputspec$*40, Inputdata, Inputonlyspec$(1)*60, Inputonlydata$(1)*255, InputOnlyTTip$(1)*255
!
      ! Ensure that Mode is Valid
      if Mode<1 Or Mode>13 then let Mode=Inputfieldlistmode
      if Mode=Inputfieldlistmode And Fngetfieldscount=0 then let Mode=Inputattributesmode
      if (Mode=Inputlistviewmode Or Mode=Inputeditormode Or Mode=Inputeditormovemode Or Mode=Settabordermode) And (Udim(Fieldtype$)=0) then let Mode=Inputattributesmode
      if Mode=InputEditorMode and udim(mat FieldType$)>=Control and lwrc$(FieldType$(Control))="listchld" then
         let Mode=InputListviewMode
         for Index=1 to udim(mat Parent$)
            if lwrc$(trim$(Parent$(Index)))=lwrc$(trim$(Parent$(Control))) and lwrc$(FieldType$(Index))="listview" then
               let Control=Index
            end if
         next Index
      end if
!
      #Select# Mode #Case# Inputattributesmode
         let Window=Fngetattributeswindow
         let Fngetattributespec(Mat Inputspec$,Mat Inputdata$,mat InputTTip$,Mat Inputsubs)
!
         if Control<>0 And Srch(Mat Inputsubs,Control)>0 then
            let Curfld(Srch(Mat Inputsubs,Control))
         end if
!
         let Fnfiletoscreen(Mat Screenio$,Mat Screenio, Mat Inputdata$,Mat Inputsubs)

         let Fnadjustcolorbuttons(Mat Inputspec$,Mat Inputdata$,Mat Inputsubs)
!
         let Fncopyattrinputspec(Mat Inputonlyspec$,Mat Inputonlydata$,mat InputOnlyTTip$,Mat Inputspec$,Mat Inputdata$,mat InputTtip$,Mat Inputsubs)
         print #Window, fields Mat Inputspec$, help mat InputTTip$ : Mat Inputdata$
!
         execute "config keyboard 16 2200" ! Ctrl-V To Ctrl-F8 (Fkey 34)
         execute "config keyboard 0B00 0A0A0A636F6E206B657920636C6561720D" ! Shift F1 Key To "con key clear<CR>"
         do
            rinput #Window, fields Mat Inputonlyspec$, help Mat InputOnlyTTip$ : Mat Inputonlydata$
            let Io_ScreenCodeSubs=srch(mat InputSubs,si_ScreenCode)
            let InputOnlyData$(IO_ScreenCodeSubs)=fnCleanScreenCode$(InputOnlyData$(IO_ScreenCodeSubs)) ! This keeps things from screwing up for leading spaces

            if Fkey=34 then
               let Clipboard$=Env$("clipboard")(1:999999)
               if Pos(Clipboard$,"#!!") And Pos(Clipboard$,"_#_") then
                  if Fnaddcontrolsfromclipboard(Clipboard$,[[Screencontrols]]) then
! .                  ! Select new controls
                     let Oldsize=Udim(Mat Selectedcontrols)
                     mat Selectedcontrols(Udim(Mat Controlname$))=(0)
                     mat Selectedcontrols(Oldsize+1:Udim(Mat Selectedcontrols))=(1)
!
                     let Control=Oldsize+1
                     let Mode=Inputeditormovemode
                  end if
               else
                  print #Window, fields Inputonlyspec$(Curfld) : Clipboard$(1:255) soflow IGNORECLIPBOARD
                  let Inputonlydata$(Curfld)=Clipboard$(1:255)
IGNORECLIPBOARD: ! Continue
                  let Curfld(Curfld,Fkey)
               end if
            end if
         loop While Fkey=34 And Mode<>Inputeditormovemode
         execute "config keyboard clear"
!
         let Fncopybackattrinputspec(Mat Inputonlyspec$,Mat Inputonlydata$,Mat Inputspec$,Mat Inputdata$,Mat Inputsubs)
         let Fnscreentofile(Mat Screenio$, Mat Screenio, Mat Inputdata$, Mat Inputsubs)
!
         if Screenio(Si_Vsize)<1 then let Screenio(Si_Vsize)=1
         if Screenio(Si_Hsize)<1 then let Screenio(Si_Hsize)=1
         if Screenio(Si_Vsize)>120 then let Screenio(Si_Vsize)=120
         if Screenio(Si_Hsize)>220 then let Screenio(Si_Hsize)=220
!
         let Control=Inputsubs(Curfld)
         let Function=Fkey
!
      #Case#  Inputfieldlistmode
         let Window=Fngetfieldswindow
         let Fngetfieldsspec(Inputspec$)
         rinput #Window, fields Inputspec$ : Inputdata
         let Function=Fkey
!
      #Case# Inputeditormode
         let Function=Fnpreformeditorinput(Mode,Control,Mat Screenio$,Mat Screenio,[[Screencontrols]])
!
      #Case# Inputeditormovemode
         let Function=Fnpreformobjectmovement(Mode,Control,Mat Screenio$,Mat Screenio, [[Screencontrols]])
!
      #Case# Inputlistviewmode
         let Function=Fninputlistviewfields(Mode,Control,Mat Screenio$,Mat Screenio, [[Screencontrols]])
!
      #Case# Inputdebugmode
         let Window=Fngetdebugwindow
         let Fngetdebugspec(Inputspec$)
         rinput #Window, fields Inputspec$ : Inputdata
         let Function=Fkey
!
      #Case# Selectcolormode
         let Tempcolor$=Fncolorpicker$(Screenio$(Control),0,0,"Select Color",Function)
         if Fnvalidhexcolor(Tempcolor$) Or Tempcolor$="" then
            let Screenio$(Control)=Tempcolor$
         end if
         let Mode=Inputattributesmode
!
      #Case# Selectfilelaymode
         let Screenio$(Control)=Fnselectlayout$(Screenio$(Control),Function)
         ! let Displayref_Screenio$(Si_Filelay)="" ! Trigger redraw no matter what
         let Mode=Inputattributesmode
!
      #Case# Selecteventsmode
         let Fnselectevents(Mat Screenio$,Mat Screenio,Function)
         let Mode=Inputattributesmode
!
      #Case# Settabordermode
         let Fnsettaborder(Mat Screenio$,Mat Screenio,[[Screencontrols]],Function)
         let Mode=Inputattributesmode
!
      #Case# Configuredebugmode
         let Fnconfiguredebug(Mat Screenio$,Mat Screenio,Function)
         let Mode=Inputattributesmode

      #Case# ConfigureProtectedMode
         let fnConfigureProtected(Mat ScreenIO$,Mat ScreenIO,Function)
         let Mode=InputAttributesMode
!
      #End Select#
      let Fnpreforminput=Function
!
   fnend

   def fnCleanScreenCode$(Text$;___,Z,GoodLetters$,OutText$)
      let Text$=trim$(uprc$(Text$))
      for Z=1 to len(Text$)
         if Pos("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.",Text$(Z:Z)) then
            let OutText$=OutText$&Text$(Z:Z)
         end if
      next Z
      let fnCleanScreenCode$=OutText$
   fnend
!
ADJUSTCOLORBUTTONS: ! Adjust The Colors Of The Buttons For The Attributes Window
   def Fnadjustcolorbuttons(Mat Spec$,Mat Data$,Mat Subs;___,Index)
      for Index=1 to Udim(Mat Subs)
         #Select# Subs(Index) #Case# Si_Fgcolor # Si_Bgcolor
            let Fnadjustspeccolor(Spec$(Index),Data$(Index))
         #End Select#
      next Index
   fnend
!
COPYATTRINPUTSPEC: ! Copy The Attr Input Specs To The Input Spec Arrays
   def Fncopyattrinputspec(Mat Inspec$,Mat Indata$, mat InTTip$, Mat Allspec$, Mat Alldata$, mat AllTTip$, Mat Allsubs;___,Index,Count)
      mat Inspec$(0) : mat Indata$(0)
      for Index=1 to Udim(Mat Allsubs)
         #Select# Allsubs(Index) #Case# Si_Fgcolor # Si_Bgcolor # Si_Filelay # 0
         #Case Else#
            let Count=Udim(Mat Inspec$)+1
            mat Inspec$(Count) : mat Indata$(Count) : mat InTtip$(Count)
            let Inspec$(Count)=Allspec$(Index)
            let Indata$(Count)=Alldata$(Index)
            let InTTip$(Count)=AllTTip$(Index)
         #End Select#
      next Index
   fnend
!
COPYBACKATTRINPUTSPEC: ! Copy The Attr Input Specs Back To The All Spec Arrays
   def Fncopybackattrinputspec(Mat Inspec$,Mat Indata$, Mat Allspec$, Mat Alldata$, Mat Allsubs;___,Index,Count)
      let Count=0
      for Index=1 to Udim(Mat Allsubs)
         #Select# Allsubs(Index) #Case# Si_Fgcolor # Si_Bgcolor # Si_Filelay # 0
         #Case Else#
            let Count+=1
            let Allspec$(Index)=Inspec$(Count)
            let Alldata$(Index)=Indata$(Count)
         #End Select#
      next Index
   fnend
!
PROCESSCOMMAND: !  Process The User Command Here
   def Fnprocesscommand(Function,Field,&Mode,&Control,Mat Screenio$,Mat Screenio,[[Screencontrols]];___,Button$,Menucomplete,Newcontrol,Relatedcontrol)
!
      if Function=98 then
         let Menucomplete = Fnprocesswindowsmenu(Mat Screenio$,Mat Screenio,[[Screencontrols]])
         #Select# Menucomplete #Case# Menuquit
            let Mode=Quitmode
         #Case# Menuload # MenuNew
            let fnCloseFrameWindows
            mat Gaps=(0)
            let Mode=Inputattributesmode
            let Control=1
         #Case# Menuevents
            let Mode=Selecteventsmode
         #Case# Menudebug
            let Mode=Configuredebugmode
         #Case# MenuProtected
            let Mode=ConfigureProtectedMode
         #Case# Menutaborder
            let Mode=Settabordermode
         #Case# Menufgcolor
            let Mode=Selectcolormode
            let Control=Si_Fgcolor
         #Case# Menubgcolor
            let Mode=Selectcolormode
            let Control=Si_Bgcolor
         #Case# Menuselectlayout
            let Mode=Selectfilelaymode
            let Control=Si_Filelay
         #Case# Menumovement
            let Mode=Inputeditormovemode
         #Case# Menudebuglist
            let Mode=Inputdebugmode
         #Case# Menufieldslist
            let Mode=Inputfieldslistmode
         #Case# Menuaddcontrol
            let Button$=Menu$
         #End Select#
      end if

      if Function=93 or fkey=93 then
         if Fnoktoproceed(Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
            let Mode=Quitmode
         end if
      end if
!
      if Function=99 then
         mat Selectedcontrols=(0)
         let Mode=Inputattributesmode
         let Control=1
      end if
!
      if Function>=1100 And Function<1200 then !  Process Attributes Click
         let Control = FnSetInputAttributesControl(Function)
         #Select# Control #Case# Si_Fgcolor # Si_Bgcolor
            let Mode=Selectcolormode
         #Case# Si_Filelay
            let Mode=Selectfilelaymode
         #Case# 0
            if Function-1100=20 then
               let Mode=Selecteventsmode
            else if Function-1100=21 then
               let Mode=Settabordermode
            end if
         #Case Else#
            let Mode=Inputattributesmode
         #End Select#
      end if
!
      if Function=1200 Or (Function=201 And Mode=Inputdebugmode) then !  Process Debug Click/Enter
         if Mode=Inputdebugmode then
            let Fnreaddebug(Mode,Control)
         else
            let Mode=Inputdebugmode
            let Control=0
         end if
      end if
!
      if Function=44 then ! Alt-Z Is Undo
         let Fnundo(Mat Screenio$,Mat Screenio,[[Screencontrols]])
         mat SelectedControls=(0)
      end if
      if Function=19 then ! Alt-R Is Redo
         let Fnredo(Mat Screenio$,Mat Screenio,[[Screencontrols]])
      end if
!
      if Function=1300 Or (Function=201 And Mode=Inputfieldlistmode) then !  Process Fieldslist Click/Enter
         if Mode=Inputfieldlistmode then
            let Newcontrol = FnaddAndColorcurrentfield([[Screencontrols]],mat ScreeniO$,mat Screenio)
         else
            let Mode=Inputfieldlistmode
            let Control=0
         end if
      end if
!
      if Function>=1400 And Function<1500 then !  Process Button
         let Button$ = Lwrc$(Fnreadbutton$(Function))
      end if
!
      if Len(Button$) then
         let Fnprocessbutton(Button$,Mode,Control,Mat Screenio$,Mat Screenio,[[Screencontrols]])
      end if
!
      if Function>=1500 And Function<=1500+Udim(Mat Controlname$) then
         if (Control=Function-1500) then
            if (Mode=Inputeditormovemode) then
               let Mode=Inputeditormode
            else if Mode=Inputeditormode And Lwrc$(Trim$(Fieldtype$(Control)))="listview" then
               let Mode=Inputlistviewmode
            else
               let Mode=Inputeditormovemode
            end if
         else
            let Mode=Inputeditormovemode
         end if
         let Control=Function-1500
      end if
   fnend
!
!  #Autonumber# 18000,2
! *****************************************************************
! ************************ Set Tab Order **************************
! *****************************************************************
SETTABORDER: ! Opens A Child Window To Select Event Handler Functions
   def Fnsettaborder(Mat Screenio$,Mat Screenio,[[Screencontrols]];&Function,___,Index,Window)
      dim Newtaborder(1)
      dim Oldtabindex(1)
      dim Newtaborderspec$(1)*255

      let Window=Fngeteditorwindow
!
      if Window then
         mat Newtaborder(0)
         mat Oldtabindex(0)
         mat Newtaborderspec$(0)
         for Index=1 to Udim(Mat Fieldtype$)
            if fnIsInput(FieldType$(Index)) then
               mat Newtaborder(Udim(Mat Newtaborder)+1)
               let Newtaborder(Udim(Mat Newtaborder))=Udim(Mat Newtaborder)
               mat Newtaborderspec$(Udim(Mat Newtaborder))
               let Newtaborderspec$(Udim(Mat Newtaborder))=Str$(Vposition(Index))&","&Str$(Hposition(Index))&","&Str$(Width(Index))&"/NZ 3,S/#000000:#99CCFF,"&Str$(1500+Udim(Mat Newtaborder))
               mat Oldtabindex(Udim(Mat Newtaborder))
               let Oldtabindex(Udim(Mat Newtaborder))=Index
            End If
         next Index
!
         if Udim(Mat Newtaborder) then
            let Index=0
!
            let fnChangeForceVisibility(1)
            do
               print #Window, fields Mat Newtaborderspec$ : Mat Newtaborder
               input #0, fields "1,2,C 1,AEX" : Key$
               let Function=Fkey
!
               if Function>1500 And Function<=1500+Udim(Mat Newtaborder) then
                  let Index+=1
                  let Newtaborder(Function-1500)=Index
                  let Newtaborderspec$(Function-1500)=Newtaborderspec$(Function-1500)(1:Pos(Newtaborderspec$(Function-1500),",",-1)-1)&",-1"
                  let Newtaborderspec$(Function-1500)=Srep$(Newtaborderspec$(Function-1500),"#99CCFF","#00FF00")
               end if
            loop Until Index=Udim(Mat Newtaborder) Or Function=99 Or Function=98 Or Function=93 Or Function=44 Or Function=19 Or ((Function>1100) And (Function<1500))
            let fnChangeForceVisibility(0)
!
            if Index=Udim(Mat Newtaborder) then
               let Fnsetsortarrays([[Screencontrols]])
               for Index=1 to Udim(Mat Newtaborder)
                  let Fngetsortarray(Oldtabindex(Index),Oldtabindex(Newtaborder(Index)),[[Screencontrols]])
               next Index
            end if
         end if
      end if
   fnend
!
   dim Srt_Controlname$(1)*50, Srt_Fieldname$(1)*50, Srt_Description$(1)*255
   dim Srt_Vposition(1), Srt_Hposition(1), Srt_Fieldtype$(1)*8, Srt_Specwidth(1), Srt_Width(1), Srt_Height(1)
   dim Srt_Truevalue$(1)*60, Srt_Falsevalue$(1)*60
   dim Srt_Function$(1)*255, Srt_Picture$(1)*255, Srt_Parent$(1)*20
   dim Srt_Fgcolor$(1)*6, Srt_Bgcolor$(1)*6, Srt_Justify$(1)*1, Srt_Arrt$(1)*128, Srt_Multiselect(1), Srt_GridLines(1)
   dim Srt_Protected(1), Srt_Invisible(1), Srt_Tooltip$(1)*1000, Srt_Cnvrtin$(1)*255, Srt_Cnvrtout$(1)*255, Srt_Userdata$(1)*255
!
SETSORTARRAYS: !  Store The Controls In The Sort Arrays
   def Fnsetsortarrays([[Screencontrols]])
      mat Srt_Controlname$(Udim(Mat Controlname$)) = Controlname$ !:
      mat Srt_Fieldname$(Udim(Mat Fieldname$)) = Fieldname$ !:
      mat Srt_Description$(Udim(Mat Description$)) = Description$ !:
      mat Srt_Vposition(Udim(Mat Vposition)) = Vposition !:
      mat Srt_Hposition(Udim(Mat Hposition)) = Hposition !:
      mat Srt_Fieldtype$(Udim(Mat Fieldtype$)) = Fieldtype$ !:
      mat Srt_Specwidth(Udim(Mat Specwidth)) = Specwidth !:
      mat Srt_Width(Udim(Mat Width)) = Width !:
      mat Srt_Height(Udim(Mat Height)) = Height !:
      mat Srt_Truevalue$(Udim(Mat Truevalue$)) = Truevalue$ !:
      mat Srt_Falsevalue$(Udim(Mat Falsevalue$)) = Falsevalue$ !:
      mat Srt_Function$(Udim(Mat Function$)) = Function$
      mat Srt_Picture$(Udim(Mat Picture$)) = Picture$ !:
      mat Srt_Parent$(Udim(Mat Parent$)) = Parent$ !:
      mat Srt_Fgcolor$(Udim(Mat Fgcolor$)) = Fgcolor$ !:
      mat Srt_Bgcolor$(Udim(Mat Bgcolor$)) = Bgcolor$ !:
      mat Srt_Justify$(Udim(Mat Justify$)) = Justify$ !:
      mat Srt_Attr$(Udim(Mat Attr$)) = Attr$ !:
      mat Srt_Protected(Udim(Mat Protected)) = Protected !:
      mat Srt_Invisible(Udim(Mat Invisible)) = Invisible !:
      mat Srt_Tooltip$(Udim(Mat Tooltip$)) = Tooltip$ !:
      mat Srt_Cnvrtin$(Udim(Mat Cnvrtin$)) = Cnvrtin$ !:
      mat Srt_Cnvrtout$(Udim(Mat Cnvrtout$)) = Cnvrtout$ !:
      mat Srt_Multiselect(Udim(Mat Multiselect)) = Multiselect !:
      mat Srt_GridLines(Udim(Mat GridLines)) = GridLines !:
      mat Srt_Userdata$(Udim(Mat Userdata$))=Userdata$
   fnend
!
GETSORTARRAY: ! Sort The Selected Control Out Of The Sort Arrays
   def Fngetsortarray(From,To,[[Screencontrols]])
      let Controlname$(To) = Srt_Controlname$(From) !:
      let Fieldname$(To) = Srt_Fieldname$(From) !:
      let Description$(To) = Srt_Description$(From) !:
      let Vposition(To) = Srt_Vposition(From) !:
      let Hposition(To) = Srt_Hposition(From) !:
      let Fieldtype$(To) = Srt_Fieldtype$(From) !:
      let Specwidth(To) = Srt_Specwidth(From) !:
      let Width(To) = Srt_Width(From) !:
      let Height(To) = Srt_Height(From) !:
      let Truevalue$(To) = Srt_Truevalue$(From) !:
      let Falsevalue$(To) = Srt_Falsevalue$(From) !:
      let Function$(To) = Srt_Function$(From) !:
      let Picture$(To) = Srt_Picture$(From) !:
      let Parent$(To) = Srt_Parent$(From)
      let Fgcolor$(To) = Srt_Fgcolor$(From) !:
      let Bgcolor$(To) = Srt_Bgcolor$(From) !:
      let Justify$(To) = Srt_Justify$(From) !:
      let Attr$(To) = Srt_Attr$(From) !:
      let Protected(To) = Srt_Protected(From) !:
      let Invisible(To) = Srt_Invisible(From) !:
      let Tooltip$(To) = Srt_Tooltip$(From) !:
      let Cnvrtin$(To) = Srt_Cnvrtin$(From) !:
      let Cnvrtout$(To) = Srt_Cnvrtout$(From) !:
      let Multiselect(To) = Srt_Multiselect(From) !:
      let GridLines(To) = Srt_GridLines(From) !:
      let Userdata$(To) = Srt_Userdata$(From)
   fnend
!
! *****************************************************************
! ************************* Move Control **************************
! *****************************************************************
   dim Dotsprinted, SettingTempDots
   dim Clipboard$*999999
PREFORMOBJECTMOVEMENT: ! Highlight An Object And Allow Them To Move It Around.
   def Fnpreformobjectmovement(&Mode, &Control, Mat Screenio$,Mat Screenio,[[Screencontrols]];___,Newv,Newh,Neww,Newhth,Key$,Function,Th,Tv,Exitmovement,Wwindow,Relatedcontrol,Index,Oldsize,OldSetting,Success)
      if Control<1 then let Control=1
      if Control>Udim(Mat Fieldtype$) then let Control=Udim(Mat Fieldtype$)
      if Control>0 then
         let Wwindow=Fngeteditorwindow
!
         if Wwindow then
            let Newv=Vposition(Control) : let Newh=Hposition(Control)
            let Neww=Width(Control) : let Newhth=Height(Control)
!
            execute "config keyboard 0B 0F00" ! Up To Shift F5  (Fkey 15)
            execute "config keyboard 0A 1000" ! Dn To Shift F6  (Fkey 16)
            execute "config keyboard 0E 1100" ! Lf To Shift F7  (Fkey 17)
            execute "config keyboard 0C 1200" ! Rt To Shift F8  (Fkey 18)
            execute "config keyboard 08 2000" ! <- To (Fkey 32) - 19 Is Taken
            execute "config keyboard 20 1400" ! Sp To Shift F10 (Fkey 20)
            execute "config keyboard 04 1500" ! Del To Shift F11 (Fkey 21)
!
            execute "config keyboard 05 1600" ! Ctrl-E To Shift-F12 (Fkey 22)
            execute "config keyboard 12 1700" ! Ctrl-R To Ctrl-F3 (Fkey 23)
            execute "config keyboard 17 1800" ! Ctrl-W To Ctrl-F4 (Fkey 24)
            execute "config keyboard 13 1900" ! Ctrl-S To Ctrl-F5 (Fkey 25)
            execute "config keyboard 03 2100" ! Ctrl-C To (Fkey 33)
            execute "config keyboard 16 2200" ! Ctrl-V To (Fkey 34)
            execute "config keyboard 18 2300" ! Ctrl-X To (Fkey 35)
            execute "config keyboard 14 2400" ! Ctrl-T To (Fkey 36)
            execute "config keyboard 09 2500" ! Ctrl-I To (Fkey 37)
!
            execute "config keyboard 0B00 0A0A0A636F6E206B657920636C6561720D" ! Shift F1 Key To "con key clear<CR>"
            execute "config keyboard 0C00 676F20737465700D" ! Shift F2 Key To "go step<CR>"
            execute "config keyboard 0D00 20" ! Shift F3 -> Space
!
            mat Selectedcontrols(Udim(Mat Fieldtype$))
!
            let fnSelectFrameControls(Control,[[ScreenControls]])
            do
               mat Alreadymoved(Udim(Mat Selectedcontrols))=(0)
               let Fnmovecontrol(Control,Newv,Newh,Neww,Newhth,Mat Screenio$,Mat Screenio,[[Screencontrols]],0,0,Mat Selectedcontrols)
!
               if ~Dotsprinted then
                  let Scr_Freeze
                  let fnChangeForceVisibility(1)
                  let Fnprintdots(Mat Screenio$,Mat Screenio,[[Screencontrols]])
                  let Dotsprinted=1
               end if

               let fnChangeForceVisibility(0)

               input #0, fields "1,2,C 1,AEX" : Key$
!
               let Function=Fkey
!
               #Select# Function #Case# 99
                  if Sum(Mat Selectedcontrols) then
                     mat Selectedcontrols=(0)
                     let Fnrenderscreen(Mat Screenio$,Mat Screenio,[[Screencontrols]],1)
                     let Function=1000 ! Do Nothing, Stay Here.
                  end if
!
               #Case# 5
                  ! F5 - Refresh
                  let fnRenderScreen(mat ScreenIO$,mat ScreenIO,[[ScreenControls]],1)
                  let fnChangeForceVisibility(1)
                  let fnPrintDots(mat ScreenIO$,mat ScreenIO,[[ScreenControls]])
                  let Dotsprinted=1
                  let fnChangeForceVisibility(0)

               #Case# 6
                  ! F6 - RedrawDots
                  let SettingTempDots=1
                  let fnRenderScreen(mat ScreenIO$,mat ScreenIO,[[ScreenControls]],1)
                  let fnChangeForceVisibility(1)
                  let fnPrintDots(mat ScreenIO$,mat ScreenIO,[[ScreenControls]])
                  let Dotsprinted=1
                  let fnChangeForceVisibility(0)

               #Case# 33
! .               ! Copy
                  let Clipboard$=""
                  if Udim(Mat Selectedcontrols)>=Control And Selectedcontrols(Control) then
                     for Relatedcontrol=1 to Udim(Mat Selectedcontrols)
                        if Selectedcontrols(Relatedcontrol) then
                           let Fnaddtoclipboard(Clipboard$,Relatedcontrol,[[Screencontrols]]) ! Ctrl-C
                        end if
                     next Relatedcontrol
                  else
                     let Fnaddtoclipboard(Clipboard$,Control,[[Screencontrols]])
                  end if
                  let Setenv("clipboard",Clipboard$)
!
               #Case# 34
! .               ! Paste
                  let Clipboard$=Env$("clipboard")(1:999999)
                  if Fnaddcontrolsfromclipboard(Clipboard$,[[Screencontrols]]) then
! .                  ! Select new controls
                     let Oldsize=Udim(Mat Selectedcontrols)
                     mat Selectedcontrols(Udim(Mat Controlname$))=(0)
                     mat Selectedcontrols(Oldsize+1:Udim(Mat Selectedcontrols))=(1)
!
                     let Control=Oldsize+1
                     let Function=1001 ! Exit To Mainloop But Come Back In
                  end if
!
               #Case# 35
! .               ! Cut: Copy and Delete
                  let Clipboard$=""
                  if Udim(Mat Selectedcontrols)>=Control And Selectedcontrols(Control) then
                     let Success=1
                     for Relatedcontrol=1 to Udim(Mat Selectedcontrols)
                        if Selectedcontrols(Relatedcontrol) then
                           let Success=(Success and Fnaddtoclipboard(Clipboard$,Relatedcontrol,[[Screencontrols]])) ! Ctrl-C
                        end if
                     next Relatedcontrol
                  else
                     let Success=Fnaddtoclipboard(Clipboard$,Control,[[Screencontrols]])
                  end if
                  let Setenv("clipboard",Clipboard$)
!
                  if Success then
   ! .               ! Delete
                     let Fncheckpoint(Mat Screenio$,Mat Screenio,[[Screencontrols]])
                     let Control=Fndeletecontrol(Control,Mat Screenio$,Mat Screenio,[[Screencontrols]],Mat Selectedcontrols) ! Delete Control And Assign New Contrl
                     if Control then
                        let Newv=Vposition(Control)
                        let Newh=Hposition(Control)
                        let Neww=Width(Control)
                        let Newhth=Height(Control)
                        let Fncheckpoint(Mat Screenio$,Mat Screenio,[[Screencontrols]])
                     else
                        let Function=99 ! Escape Out Of Movement Mode
                     end if
                  end if
               #Case# 15
                  let Newv=Vposition(Control)-1 !  Up
               #Case# 16
                  let Newv=Vposition(Control)+1 !  Down
               #Case# 17
                  let Newh=Hposition(Control)-1 ! Left
               #Case# 18
                  let Newh=Hposition(Control)+1 !  Right
               #Case# 32
                  let Neww=Width(Control)-1     !  <- Is Shorter
                  if Justify$(Control)="R" then ! Shrink from the left
                     let Newh=Hposition(Control)+1 ! so move it right
                  end if
               #Case# 20
                  let Neww=Width(Control)+1 !  Space Is Wider
                  if Justify$(Control)="R" then ! Grow on the left
                     let Newh=Hposition(Control)-1 ! so move it left
                  end if
               #Case# 90
                  let Newhth=Height(Control)-1 ! Pgup Is Shorter
               #Case# 91
                  let Newhth=Height(Control)+1 ! Pgdn Is Taller
               #Case# 21
! .               ! Delete
                  let Fncheckpoint(Mat Screenio$,Mat Screenio,[[Screencontrols]])
                  let Control=Fndeletecontrol(Control,Mat Screenio$,Mat Screenio,[[Screencontrols]],Mat Selectedcontrols) ! Delete Control And Assign New Contrl
                  if Control then
                     let Newv=Vposition(Control)
                     let Newh=Hposition(Control)
                     let Neww=Width(Control)
                     let Newhth=Height(Control)
                     let Fncheckpoint(Mat Screenio$,Mat Screenio,[[Screencontrols]])
                  else
                     let Function=99 ! Escape Out Of Movement Mode
                  end if
!
               #Case# 0
                  let Function=1500+Control ! Enter Is Same As Click
!
               #Case# 22
! .               ! Ctrl-E: Make all Left Edges of selected controls match Yellow Control
                  mat Alreadymoved(Udim(Mat Selectedcontrols))=(0)
                  for Relatedcontrol=1 to Udim(Mat Selectedcontrols)
                     if Selectedcontrols(Relatedcontrol) And Relatedcontrol<>Control then
                        let Fnmovecontrol(Relatedcontrol,Vposition(Relatedcontrol),Hposition(Control),Width(Relatedcontrol),Height(Relatedcontrol),Mat Screenio$,Mat Screenio,[[Screencontrols]],1)
                     end if
                  next Relatedcontrol
                  let Fnrenderscreen(Mat Screenio$,Mat Screenio,[[Screencontrols]],1)
!
               #Case# 23
! .               ! Ctrl-R: Make all Right Edges of Selected Controls match Yellow Control
                  mat Alreadymoved(Udim(Mat Selectedcontrols))=(0)
                  for Relatedcontrol=1 to Udim(Mat Selectedcontrols)
                     if Selectedcontrols(Relatedcontrol) And Relatedcontrol<>Control then
                        let Fnmovecontrol(Relatedcontrol,Vposition(Relatedcontrol),Max(1,Hposition(Control)+Width(Control)-Width(Relatedcontrol)),Width(Relatedcontrol),Height(Relatedcontrol),Mat Screenio$,Mat Screenio,[[Screencontrols]],1)
                     end if
                  next Relatedcontrol
                  let Fnrenderscreen(Mat Screenio$,Mat Screenio,[[Screencontrols]],1)
!
               #Case# 24
! .               ! Ctrl-W: Make all widths of selected controls match yellow control
                  mat Alreadymoved(Udim(Mat Selectedcontrols))=(0)
                  for Relatedcontrol=1 to Udim(Mat Selectedcontrols)
                     if Selectedcontrols(Relatedcontrol) And Relatedcontrol<>Control then
                        let Fnmovecontrol(Relatedcontrol,Vposition(Relatedcontrol),Hposition(Relatedcontrol),Width(Control),Height(Relatedcontrol),Mat Screenio$,Mat Screenio,[[Screencontrols]],1)
                     end if
                  next Relatedcontrol
                  let Fnrenderscreen(Mat Screenio$,Mat Screenio,[[Screencontrols]],1)
!
               #Case# 25
! .               ! Ctrl-S: Toggle Selection
                  mat Selectedcontrols(Udim(Mat Controlname$))
                  let Selectedcontrols(Control)=~Selectedcontrols(Control)
!
               #Case# 36
! .               ! Ctrl-T: Select All Textboxes
                  mat SelectedControls(Udim(Mat Controlname$))=(0)
                  for RelatedControl=1 to Udim(Mat Fieldtype$)
                     if Lwrc$(Trim$(Fieldtype$(Relatedcontrol)))="c" then
                        let SelectedControls(Relatedcontrol)=1
                     end if
                  next RelatedControl
                  let fnRenderScreen(Mat Screenio$,Mat Screenio,[[Screencontrols]],1)
!
               #Case# 37
                  ! Ctrl-I: Inverse Selection
                  mat Selectedcontrols(Udim(Mat Controlname$))
                  for RelatedControl=1 to udim(mat SelectedControls)
                     let Selectedcontrols(RelatedControl)=~Selectedcontrols(RelatedControl)
                  next Relatedcontrol
                  let fnRenderScreen(Mat Screenio$,Mat Screenio,[[Screencontrols]],1)

               #Case# 7
                  ! F7: Select Everything
                  mat Selectedcontrols(Udim(Mat Controlname$))=(1)
                  let fnRenderScreen(Mat Screenio$,Mat Screenio,[[Screencontrols]],1)

               #End Select#
!
               if Function>2000 then
                  let Fngetclickposition(Function,Tv, Th)
                  if ((Tv>0) And (Th>0)) then
                     let Newv=Tv
                     let Newh=Th
                  end if
               end if
!
               if (Function>1100 And Function<1500) Or Function=1001 Or Function=98 Or Function=99 Or Function=93 Or Function=44 Or Function=19 Or Function=1500+Control then
                  let Exitmovement=1
               end if
!
               if Function=110 Or Function=111 Or (Function>1500 And Function<=1500+Udim(Mat Controlname$) And Function<>1500+Control) then

                  let fnChangeForceVisibility(1)
                  let Fndrawcontrol(Wwindow,Control,Mat Screenio$,Mat Screenio,[[Screencontrols]],0) ! Inactivate Old Control
!
                  if (Relatedcontrol:=Fnfindrelatedcontrol(Control,[[Screencontrols]])) then
                     let Fndrawcontrol(Wwindow,Relatedcontrol,Mat Screenio$,Mat Screenio,[[Screencontrols]],0) ! Inactivate Old Caption
                  end if

                  if lwrc$(trim$(fieldtype$(Control)))="frame" then
                     let fnPrintDots(mat ScreenIO$,mat ScreenIO,[[ScreenControls]],Vposition(Control),HPosition(Control),Width(Control)+(2*(lwrc$(trim$(Fieldtype$(Control)))=="combo")),Height(Control))
                     let fnRedrawScreenPart(Wwindow,mat ScreenIO$,mat ScreenIO,[[ScreenControls]],Vposition(Control),HPosition(Control),Width(Control)+(2*(lwrc$(trim$(Fieldtype$(Control)))=="combo")),Height(Control))
                  end if

                  let fnChangeForceVisibility(0)
!
                  if Function=110 then
                     let Control+=1
                     if Control>Udim(Mat Controlname$) then let Control=1
                  else if Function=111 then
                     let Control-=1
                     if ~Control then let Control=Udim(Mat Controlname$)
                  else
                     let Control=Function-1500
                  end if
                  let Newv=Vposition(Control)
                  let Newh=Hposition(Control)
                  let Neww=Width(Control)
                  let Newhth=Height(Control)

                  let fnSelectFrameControls(Control,[[ScreenControls]])
!
                  let Fncheckpoint(Mat Screenio$,Mat Screenio,[[Screencontrols]])
               end if
!
! .             ! Standardize Heights
            loop Until Exitmovement
            let Scr_Freeze
            execute "config keyboard clear" !  Clear Keyboard Remapping
            let Fnpreformobjectmovement=Function
         end if
      else
         let Mode=Inputattributesmode
      end if
   fnend
!
   dim Alreadymoved(1)
   dim Zero(1)
MOVECONTROL: ! Move A Control And Output  The Specs To Move It
   def Fnmovecontrol(Index,Newv,Newh,Neww,Newhth,Mat Screenio$,Mat Screenio,[[Screencontrols]];Dontactive,Donteraseyet,Mat Selcont,___,Weditor,Relatedindex,Eraserow,Erasecol,Erasewidth,Eraseheight,Dotsize,Oldv,Oldh,Oldwth,Oldhth,Olderaserow,Olderasecol,LeftDistance,RightDistance,Topdistance,BottomDistance,SelIndex,BorderSize)
      let Weditor=Fngeteditorwindow
!
!      Let Msgbox("Move Control "&Str$(Index)&":"&Str$(Vposition(Index))&","&Str$(Newv)&":"&Str$(Hposition(Index))&","&Str$(Newh))
      if ~Alreadymoved(Index) then

!         ! If things are selected and we're moving the selection then
!         !  we need to make sure that the distance from here to the bottommost control is also
!         !  considered.
!
!         ! This code is designed to ensure that controls dont bunch up
!         ! when moving groups of them near the edge with the mouse
!         !  but alas.. it didn't work so its commented out now.
!
!         let TopDistance=0 : let BottomDistance=0
!         let LeftDistance=0 : let RightDistance=0
!         if Udim(Mat Selcont)>=Index And selcont(Index) then
!            for selIndex=1 to udim(mat selcont)
!               if selcont(selIndex) then
!                  let topdistance=max(topdistance,VPosition(Index)-Vposition(selIndex))
!                  let bottomdistance=max(bottomdistance,(VPosition(selIndex)+Height(selIndex)-1)-(VPosition(Index)+Height(Index)-1))
!                  let leftdistance=max(leftdistance,HPosition(Index)-HPosition(selIndex))
!                  let rightDistance=max(Rightdistance,(HPosition(selIndex)+Width(selIndex)-1)-(HPosition(Index)+Width(Index)-1))
!               end if
!            next selIndex
!         end if

!         let Newv=Max(Min(Newv,1+Screenio(Si_Vsize)-Max(Newhth,1)+BottomDistance),1+TopDistance)
!         let Newh=Max(Min(Newh,1+Screenio(Si_Hsize)-Neww+RightDistance),1+LeftDistance)

         if (lwrc$(trim$(fieldtype$(Index)))="frame" or lwrc$(trim$(fieldtype$(Index)))="screen") and gridlines(Index) then let BorderSize=1

         if lwrc$(trim$(fieldtype$(Index)))<>"screen" then
            let Neww=Max(NewW,1)
            let NewW=min(ScreenIO(si_hsize)-2*bordersize,NewW)
            let Newhth=Max(NewHth,1)
            let newHth=min(ScreenIO(si_vsize)-2*bordersize,NewHth)
         end if

         let Newv=Max(Min(Newv,1+Screenio(Si_Vsize)-Max(Newhth,1)-BorderSize),1+BorderSize)
         let Newh=Max(Min(Newh,1+Screenio(Si_Hsize)-Max(Neww,1)-BorderSize),1+BorderSize)
!
         #Select# Lwrc$(Trim$(Fieldtype$(Index))) #Case# "listview"#"p"#"frame"#"caption"#"c"#"button"
            let Newhth=Max(1,Newhth)
         #Case# "screen"
            ! Child Screen Controls can't change size.
            let Newhth=height(Index)
            let NewW=width(Index)
         #Case Else#
            let Newhth=1
         #End Select#

         if Newv<>Vposition(Index) Or Newh<>Hposition(Index) Or Neww<>Width(Index) Or Newhth<>Height(Index) then
            let Eraserow=Vposition(Index)
            let Erasecol=Hposition(Index)
            let Erasewidth=Width(Index)+(2*(lwrc$(trim$(Fieldtype$(Index)))=="combo"))
            let Eraseheight=Max(Height(Index),1)
!
            if (Relatedindex:=Fnfindrelatedcontrol(Index,[[Screencontrols]])) then
               let Fnmovecontrol(Relatedindex,Vposition(Relatedindex)+Newv-Vposition(Index),Hposition(Relatedindex)+Newh-Hposition(Index),Width(Relatedindex),Height(Relatedindex),Mat Screenio$,Mat Screenio,[[Screencontrols]],1)
            end if
            ! Move controls inside frame if frame moves.
            if lwrc$(trim$(fieldtype$(Index)))="frame" then
               if (Newv<>Vposition(Index) Or Newh<>Hposition(Index)) then
                  for RelatedIndex=1 to udim(mat FrameMovement)
                     if FrameMovement(RelatedIndex) then
                        let Fnmovecontrol(Relatedindex,Vposition(Relatedindex)+Newv-VPosition(Index),Hposition(Relatedindex)+Newh-HPosition(Index),Width(Relatedindex)+Neww-Width(Index),Height(Relatedindex)+Newhth-Height(Index),Mat Screenio$,Mat Screenio,[[Screencontrols]],1,1)
                     end if
                  next RelatedIndex
               end if
            end if
            if Udim(Mat Selcont)>=Index And Selcont(Index) then
               let Oldv=Vposition(Index)
               let Oldh=Hposition(Index)
               let Oldwth=Width(Index)
               let Oldhth=Height(Index)
               for Relatedindex=1 to Udim(Mat Selcont)
                  if Selcont(Relatedindex) then
! .                  ! Expand EraseRow and EraseCol to include new control...
                     let Olderaserow=Eraserow
                     let Olderasecol=Erasecol
                     let Eraserow=Min(Eraserow,Vposition(Relatedindex))
                     let Erasecol =Min(Erasecol,Hposition(Relatedindex))
                     let Erasewidth=Max(Olderasecol+Erasewidth,Hposition(Relatedindex)+Width(Relatedindex)+(2*(lwrc$(trim$(Fieldtype$(RelatedIndex)))=="combo")))-Erasecol
                     let Eraseheight=Max(Olderaserow+Eraseheight,Vposition(Relatedindex)+Max(1,Height(Relatedindex)))-Eraserow
!
                     let Fnmovecontrol(Relatedindex,Vposition(Relatedindex)+Newv-Oldv,Hposition(Relatedindex)+Newh-Oldh,Width(Relatedindex)+Neww-Oldwth,Height(Relatedindex)+Newhth-Oldhth,Mat Screenio$,Mat Screenio,[[Screencontrols]],1,1)
                  end if
               next Relatedindex
            end if
         end if
!
         let Vposition(Index)=Newv
         let Hposition(Index)=Newh
         let Width(Index)=Neww
         let Height(Index)=Newhth
!
         #Select# lwrc$(trim$(fieldType$(index))) #case# "frame"
         #Case# "c" # "button" # "textbox" # "caption"
            if height(Index)<=1 then
               let fnChangeForceVisibility(1)
            end if
         #Case Else#
            let fnChangeForceVisibility(1)
         #End Select#

         if Eraserow And Erasecol And Erasewidth And Eraseheight And ~Donteraseyet then
            let Dotsize=Fncalculatedotsize(Screenio(Si_Vsize),Screenio(Si_Hsize))
            let Fnprintdots(Mat Screenio$,Mat Screenio,[[Screencontrols]],Eraserow,Erasecol,Erasewidth,Eraseheight) ! Erase Old Control
            if Dotsize>1 then
               let Fnprintdots(Mat Screenio$,Mat Screenio,[[Screencontrols]],Vposition(Index),Hposition(Index),Width(Index)+(2*(lwrc$(trim$(Fieldtype$(Index)))=="combo")),Max(Height(Index),1))
            end if
            let fnRedrawScreenPart(WEditor,mat ScreenIO$,mat ScreenIO,[[ScreenControls]],EraseRow,EraseCol,EraseWidth,EraseHeight)
         end if
!
         let Fndrawcontrol(Weditor,Index,Mat Screenio$,Mat Screenio,[[Screencontrols]],~Dontactive)

         if lwrc$(trim$(fieldtype$(Index)))="frame" then
            let fnChangeForceVisibility(1)
            let fnRedrawScreenPart(Wwindow,mat ScreenIO$,mat ScreenIO,[[ScreenControls]],Vposition(Control),HPosition(Control),Width(Control)+(2*(lwrc$(trim$(Fieldtype$(Control)))=="combo")),Height(Control))
         end if

         let fnChangeForceVisibility(0)
         let Alreadymoved(Index)=1
      end if
   fnend

   def fnRedrawScreenPart(WEditor,mat ScreenIO$,mat ScreenIO,[[ScreenControls]],EraseRow,EraseCol,EraseWidth,EraseHeight;___,CheckControl)
      for Checkcontrol=1 to Udim(Mat Controlname$)
         if lwrc$(trim$(fieldtype$(checkcontrol)))<>"frame" and lwrc$(trim$(fieldtype$(checkcontrol)))<>"listchld" then
            if ((Vposition(Checkcontrol)+Max(Height(Checkcontrol),1)-1 >= Eraserow) And (Vposition(Checkcontrol)<=Eraserow+Eraseheight-1)) then
               if ((Hposition(Checkcontrol)+Width(Checkcontrol)+(2*(lwrc$(trim$(Fieldtype$(CheckControl)))=="combo"))-1 >= Erasecol) And (Hposition(Checkcontrol)<=Erasecol+Erasewidth-1)) then
                  let Fndrawcontrol(Weditor,Checkcontrol,Mat Screenio$,Mat Screenio,[[Screencontrols]])
               end if
            end if
         end if
      next Checkcontrol
   fnend

   dim FrameMovement(1)
   def fnSelectFrameControls(Frame,[[ScreenControls]])
      mat FrameMovement(udim(mat FieldType$))
      if lwrc$(trim$(fieldType$(Frame)))="frame" then
         for Index=1 to udim(mat FieldType$)
            if Index<>Frame then
               if ((VPosition(Index)>=VPosition(Frame)) and (VPosition(Index)+Max(Height(Index),1)<=VPosition(Frame)+Height(Frame))) then
                  if ((HPosition(Index)>=HPosition(Frame)) and (HPosition(Index)+Width(Index)<=HPosition(Frame)+Width(Frame))) then
                     let FrameMovement(Index)=1
                  end if
               end if
            end if
         next Index
      else
         mat FrameMovement=(0)
      end if
   fnend
!
DELETECONTROL: ! Delete The Given Control And Return A New Control
   def Fndeletecontrol(Control,Mat Screenio$,Mat Screenio,[[Screencontrols]];Mat Selcont,___,Index)
      if Udim(Mat Selcont)>=Control And Selcont(Control) then
         let Index=0
         do While Index<Udim(Mat Selcont)
            let Index+=1
            if Selcont(Index) then
               let Fndelete(Index,Mat Screenio$,Mat Screenio,[[Screencontrols]])
               if Index<Udim(Mat Selcont) then
                  mat Selcont(Index:Udim(Mat Selcont)-1)=Selcont(Index+1:Udim(Mat Selcont))
               end if
               mat Selcont(Udim(Mat Selcont)-1)
               let Index-=1
            end if
         loop While Udim(Mat Selcont)
      else
         let Fndelete(Control,Mat Screenio$,Mat Screenio,[[Screencontrols]])
      end if
      let Fnrenderscreen(Mat Screenio$,Mat Screenio,[[Screencontrols]],1)
!
      if Control>Udim(Mat Controlname$) then let Control=Udim(Mat Controlname$)
      let Fndeletecontrol=Control
   fnend
!
   def Fndelete(Control,Mat Screenio$,Mat Screenio,[[Screencontrols]];___,Index,Row,Col,Width,Height,Childsearch)
      let Row=Vposition(Control)
      let Col=Hposition(Control)
      let Width=Width(Control)+(2*(lwrc$(trim$(Fieldtype$(Control)))=="combo"))
      let Height=Height(Control)
!
      #Select# Lwrc$(Trim$(Fieldtype$(Control))) #Case# "listview"
! .       ! If its a listview, then we need to delete all its children too.
         for Childsearch=1 to Udim(Mat Fieldtype$)
            if Childsearch<=Udim(Mat Fieldtype$) then
               if Lwrc$(Trim$(Fieldtype$(Childsearch)))="listchld" And Parent$(Childsearch)=Parent$(Control) then
                  for Index=Childsearch to Udim(Mat Controlname$)-1
                     let Fncopycontrolarrays(Index,Index+1,[[Screencontrols]])
                  next Index
                  let Fnresizecontrolarrays(Udim(Mat Controlname$)-1,[[Screencontrols]])
               end if
            end if
         next Childsearch
      #Case# "frame" # "c" # "button" # "caption"
         ! if it has a frame, we need to close the window
         let fnCloseFrameWindow(Parent$(Control))
      #Case# "screen"
         ! if its a screen, we need to close it
         let ChildSearch=srch(mat ScreenKeys$,Parent$(Control))
         if ChildSearch>0 then
            if ScreenWindows(ChildSearch) and file(ChildSearch)<>-1 then close #ScreenWindows(ChildSearch):
            for Index=ChildSearch to udim(mat ScreenKeys$)-1
               let ScreenKeys$(Index)=ScreenKeys$(Index+1)
               let ScreenWindows(Index)=ScreenWindows(Index+1)
            next Index
            mat ScreenKeys$(udim(mat ScreenKeys$)-1)
            mat ScreenWindows(udim(mat ScreenWindows)-1)
         end if

      #End Select#
!
      for Index=Control to Udim(Mat Controlname$)-1
         let Fncopycontrolarrays(Index,Index+1,[[Screencontrols]])
      next Index
      let Fnresizecontrolarrays(Udim(Mat Controlname$)-1,[[Screencontrols]])
!
      let fnChangeForceVisibility(1)
      let Fnprintdots(Mat Screenio$,Mat Screenio,[[Screencontrols]],Row,Col,Width,Height)
      let fnChangeForceVisibility(0)
   fnend
!
!
FINDRELATEDCONTROL: ! Finds The Related Control If Any
   def Fnfindrelatedcontrol(Control,[[Screencontrols]];___,Relatedindex)
      #Select# Trim$(Lwrc$(Fieldtype$(Control))) #Case# "c" # "search" # "filter" # "combo"
         if Trim$(Description$(Control))<>"" then
            if (Relatedindex:=Srch(Mat Controlname$,Description$(Control))) > 0 then
               let Fnfindrelatedcontrol=Relatedindex
            end if
         end if
      #End Select#
   fnend
!
!
!  #Autonumber# 20000,5
! *****************************************************************
! ****************************** Dots *****************************
! *****************************************************************
ADDDOT: ! Adds A Dot To The Dots Arrays
   def Fnadddot(Row,Col,Size,Mat Dotrow,Mat Dotcol,Mat Dotsize,Mat Dotexist;___,Index)
      let Index=Srch(Mat Dotexist,0)
      if Index<1 then
         let Index=Udim(Mat Dotrow) + 1
         mat Dotrow(Index)
         mat Dotcol(Index)
         mat Dotsize(Index)
         mat Dotexist(Index)
      end if
      let Dotrow(Index)=Row
      let Dotcol(Index)=Col
      let Dotsize(Index)=Size
      let Dotexist(Index)=1
!
      let Fnadddot=Index
   fnend
!
MASKDOT: ! Masks Out A Dot From The Dots Arrays
   def Fnmaskdot(Row,Col,Mat Dotrow,Mat Dotcol,Mat Dotsize,Mat Dotexist;___,Dot,Index,Jndex)
      let Dot=Fnfinddot(Row,Col,Mat Dotrow,Mat Dotcol,Mat Dotsize,Mat Dotexist)
      if Dot then
         for Index=Dotrow(Dot) to Dotrow(Dot)+Dotsize(Dot)-1
            for Jndex=Dotcol(Dot) to Dotcol(Dot)+Dotsize(Dot)-1
               if Index<>Row Or Jndex<>Col then
                  let Fnadddot(Index,Jndex,1,Mat Dotrow,Mat Dotcol,Mat Dotsize,Mat Dotexist) ! Add Smaller Dots In The Old Positions
               end if
            next Jndex
         next Index
!
         let Dotrow(Dot)=0 ! Delete Dot
         let Dotcol(Dot)=0
         let Dotsize(Dot)=0
         let Dotexist(Dot)=0
      end if
   fnend
!
FINDDOT: ! Find Which Dot Exists On A Given Row
   def Fnfinddot(Row,Col,Mat Dotrow,Mat Dotcol,Mat Dotsize,Mat Dotexist;___,Index,Dotfound)
      do While (Index:=Srch(Mat Dotexist,1,Index+1))>0
         if Index>0 then
            if (Row>=Dotrow(Index)) And (Row<=Dotrow(Index)+Dotsize(Index)-1) then
               if (Col>=Dotcol(Index)) And (Col<=Dotcol(Index)+Dotsize(Index)-1) then
                  let Dotfound=1 ! Found
                  exit do
               end if
            end if
         end if
      loop
!
      if Dotfound then
         let Fnfinddot=Index
      end if
   fnend
!
PRINTDOTS: ! Print The Clickable Dots For Click-To-Move Functionality
   def Fnprintdots(Mat Screenio$,Mat Screenio,[[Screencontrols]];Maskrow,Maskcol,Maskwidth,Maskheight,___,Index,Row,Col,Dotsize,Tr,Tc,Printfullscreen,Window)
      dim Dotrow(1), Dotcol(1), Dotsize(1),Dotexist(1)
!
      let Window=Fngeteditorwindow
!
      if Window>0 then
         mat Dotrow(0) : mat Dotcol(0) : mat Dotsize(0) : mat Dotexist(0)
!
         let Dotsize=Fncalculatedotsize(Screenio(Si_Vsize),Screenio(Si_Hsize))
!
         if ~(Maskrow Or Maskcol Or Maskwidth Or Maskheight) then
            let Printfullscreen=1
         end if
!
         if Maskrow And Maskcol And Maskwidth And ~Maskheight then
            let Maskheight=1
         end if
!
         if SettingTempDots or Pos(Uprc$(Env$("clickmove")),"Y") then
!    .      Assign Default Mask Area
            if ~Maskrow then let Maskrow=1
            if ~Maskcol then let Maskcol=1
            if ~Maskwidth then let Maskwidth=Screenio(Si_Hsize)-Maskcol+1
            if ~Maskheight then let Maskheight=Screenio(Si_Vsize)-Maskrow+1
!
!    .      Grow Mask Area Slightly To Include Only Whole Dots
            let Maskheight+=(Maskrow-((Int((Maskrow-1)/Dotsize)*Dotsize)+1))
            let Maskwidth+=(Maskcol-((Int((Maskcol-1)/Dotsize)*Dotsize)+1))
            let Maskrow=(Int((Maskrow-1)/Dotsize)*Dotsize)+1
            let Maskcol=(Int((Maskcol-1)/Dotsize)*Dotsize)+1
            let Maskheight=Int(((Maskheight-1)/Dotsize)+1)*Dotsize
            let Maskwidth=Int(((Maskwidth-1)/Dotsize)+1)*Dotsize
!
!    .      Build Dots Only For Mask Area
            for Row=Maskrow to Maskrow+Maskheight-1 step Dotsize
               for Col=Maskcol to Maskcol+Maskwidth-1 step Dotsize
                  let Fnadddot(Row,Col,Dotsize,Mat Dotrow,Mat Dotcol,Mat Dotsize,Mat Dotexist)
               next Col
            next Row
!
!    .      Finally, Mask Off Any Dots That May Be Outside The Screen.
            for Col=Screenio(Si_Hsize)+1 to Maskcol+Maskwidth
               for Row=Maskrow to Maskrow+Maskheight
                  let Fnmaskdot(Row,Col,Mat Dotrow,Mat Dotcol,Mat Dotsize,Mat Dotexist)
               next Row
            next Col
            for Row=Screenio(Si_Vsize)+1 to Maskrow+Maskheight
               for Col=Maskcol to Maskcol+Maskwidth
                  let Fnmaskdot(Row,Col,Mat Dotrow,Mat Dotcol,Mat Dotsize,Mat Dotexist)
               next Col
            next Row
!
!    .      Mask Controls Only If They Fall Inside The Already Defined Mask Area.
            for Index=1 to Udim(Controlname$)
               if Lwrc$(Trim$(Fieldtype$(Index)))<>"listchld" and Lwrc$(Trim$(Fieldtype$(Index)))<>"frame" then
                  for Row=Vposition(Index) to (Vposition(Index)+Max(1,Height(Index))-1)
                     for Col=Hposition(Index) to (Hposition(Index)+Width(Index)-1)+(2*(lwrc$(trim$(Fieldtype$(Index)))=="combo"))
                        if Col<=Maskcol+Maskwidth And Col>=Maskcol And Row<=Maskrow+Maskheight And Row>=Maskrow then
                           let Fnmaskdot(Row,Col,Mat Dotrow,Mat Dotcol,Mat Dotsize,Mat Dotexist)
                        end if
                     next Col
                  next Row
               end if
            next Index
!
            let Fnrenderdots(Window,Dotsize,Mat Dotrow,Mat Dotcol,Mat Dotsize,Mat Dotexist,Printfullscreen)
         else
            if ~Printfullscreen then
               for Index=Maskrow to Maskrow+Max(Maskheight,1)-1
                  print #Window, fields Str$(Index)&","&Str$(Maskcol)&",C "&Str$(Maskwidth) : ""
               next Index
            end if
         end if
      end if
   fnend
!
   dim Permdotrow(1), Permdotcol(1), Permdotsize(1), Permdotexist(1)
RENDERDOTS: ! Move The Dots To The Permenant Dot Arrays And Print Them
   def Fnrenderdots(Window,Dotsize,Mat Dotrow,Mat Dotcol,Mat Dotsize,Mat Dotexist;Clearpermanent,___,Index,Dot,Row,Col,Fkeyvalue)
      dim Dotspec$(1)*40, Dotdata$(1)*60
      mat Dotspec$(0) : mat Dotdata$(0)
!
      if Clearpermanent then
         mat Permdotrow(0) : mat Permdotcol(0) : mat Permdotsize(0) : mat Permdotexist(0)
      end if
!
      mat Dotspec$(Sum(Mat Dotexist))
      mat Dotdata$(Sum(Mat Dotexist))
!
      let Index=0
      do While (Index:=Srch(Mat Dotexist,1,Index+1))>0
         if ~Clearpermanent then
            for Row=Dotrow(Index) to Dotrow(Index)+Dotsize(Index)-1
               for Col=Dotcol(Index) to Dotcol(Index)+Dotsize(Index)-1
                  let Fnmaskdot(Row,Col,Mat Permdotrow,Mat Permdotcol,Mat Permdotsize,Mat Permdotexist)
               next Col
            next Row
         end if
         let Fkeyvalue=Fnadddot(Dotrow(Index),Dotcol(Index),Dotsize(Index),Mat Permdotrow,Mat Permdotcol,Mat Permdotsize,Mat Permdotexist)
!
         let Dot+=1
         let Dotspec$(Dot)=Str$(Dotrow(Index))&","&Str$(Dotcol(Index))&",P "&Str$(Dotsize(Index))&"/"&Str$(Dotsize(Index))&",,"&Str$(2000+Fkeyvalue)
         if Dotsize(Index)<Dotsize then
            let Dotdata$(Dot)=setting_ImagePath$&"\black.bmp"
         else
            if Dotsize=1 then
               let Dotdata$(Dot)=setting_ImagePath$&"\dot.bmp"
            else
               let Dotdata$(Dot)=setting_ImagePath$&"\bigdot.bmp"
            end if
         end if
      loop
!
      print #Window, fields Mat Dotspec$ : Mat Dotdata$
   fnend
!
CALCULATEDOTSIZE: ! Calculate The Step Size Based On The Screen Size
   def Fncalculatedotsize(Vsize,Hsize;___,Buttonsize,Maxnumberofbuttons)
      let Maxnumberofbuttons = 3000
!
      let Buttonsize=Int((((Vsize*Hsize)-1)/Maxnumberofbuttons))+1
      let Buttonsize=Int(Sqr(Buttonsize-1))+1
!
      let Fncalculatedotsize = Buttonsize
   fnend
!
GETCLICKPOSITION: ! Returns The Click Position
   def Fngetclickposition(Function,&Row,&Col;___,Index)
      if Function>2000 then
         let Row=Permdotrow(Function-2000)
         let Col=Permdotcol(Function-2000)
      end if
   fnend
!
!  #Autonumber# 21000,2
! *****************************************************************
! ************************ Render Controls ************************
! *****************************************************************
   dim Draw_Lv_Caption$(1)*255,Draw_Lv_Width(1),Draw_Lv_Spec$(1)*40,Draw_Lv_Data$(1)*255
DRAWCONTROL: ! Draw The Given Control
   def Fndrawcontrol(Window,Control,Mat Screenio$,Mat Screenio,[[Screencontrols]];Active,Fgcolor$,Bgcolor$,Dontpopulate,Forceindex,Runtime,___,Data$*255,Spec$*255,Index)
      if Width(Control)<=ScreenIO(si_HSize) and Height(Control)<=ScreenIO(si_VSize) then
         #Select# Lwrc$(Trim$(Fieldtype$(Control)))   #Case# "listview"
! .          ! Draw Listview Header
            let Spec$=Fncalculatelistviewheaders$(Mat Draw_Lv_Caption$, Mat Draw_Lv_Width, Mat Draw_Lv_Spec$,Control,[[Screencontrols]],Active)
            if Len(Trim$(Fgcolor$)) And Len(Trim$(Bgcolor$)) then
               let Spec$=Srep$(Spec$,Fncolor$(0,Fieldtype$(Control),Fgcolor$(Control),Bgcolor$(Control),0,Invisible(Control)),Fncolor$(0,Fieldtype$(Control),Fgcolor$,Bgcolor$))
            end if

            ! This next part fixes it so that if you have a Read event for your listview, the other stuff all updates correctly.
            !  In order for ScreenIO to do its magic, there has to be an "X" attribute for the listview and for all other input
            !  text controls on the screen, so that it can get control and make sure things are updated properly and the Read Event runs.
            if Len(Trim$(Screenio$(Si_Readfn))) then
               for Index=1 to Udim(Mat Draw_Lv_Spec$)
                  if pos(draw_lv_spec$(index),",") and Pos(Draw_Lv_Spec$(Index),"/",pos(draw_lv_spec$(index),",",-1)) then
                     let Draw_Lv_Spec$(Index)=Draw_Lv_Spec$(Index)(1:Pos(Draw_Lv_Spec$(Index),"/",-1)-1)&"X"&Draw_Lv_Spec$(Index)(Pos(Draw_Lv_Spec$(Index),"/",-1):Len(Draw_Lv_Spec$(Index)))
                  else
                     let Draw_Lv_Spec$(Index)=Draw_Lv_Spec$(Index)&"X"
                  end if
               next Index
               for Index=1 to udim(mat FieldType$)
                  if fnIsInput(FieldType$(Index)) then
                     if Pos(Attr$(Index),"/") then
                        if Attr$(Index)(pos(Attr$(Index),"/")-1:pos(Attr$(Index),"/")-1)><"X" then
                           let Attr$(Index)=Attr$(Index)(1:Pos(Attr$(Index),"/")-1)&"X"&Attr$(Index)(Pos(Attr$(Index),"/"):len(attr$(Index)))
                        end if
                     else
                        if Attr$(Index)(len(Attr$(Index)):len(Attr$(Index)))><"X" then
                           let Attr$(Index)=Attr$(Index)&"X"
                        end if
                     end if
                  end if
               next Index
            end if
!
            if Forceindex then
               let Spec$=Spec$(1:Pos(Spec$,",",-1)-1)&","&Str$(Forceindex)
            end if
!
! .         ! Add Hidden Column for Record Number
            mat Draw_Lv_Caption$(Udim(Mat Draw_Lv_Caption$)+1)
            mat Draw_Lv_Width(Udim(Mat Draw_Lv_Width)+1)
            mat Draw_Lv_Spec$(Udim(Mat Draw_Lv_Spec$)+1)
!
            let Draw_Lv_Width(Udim(Mat Draw_Lv_Width))=0
            let Draw_Lv_Spec$(Udim(Mat Draw_Lv_Spec$))="C 12"

            ! Add Hidden Column for Search
!            mat Draw_Lv_Caption$(Udim(Mat Draw_Lv_Caption$)+1)
!            mat Draw_Lv_Width(Udim(Mat Draw_Lv_Width)+1)
!            mat Draw_Lv_Spec$(Udim(Mat Draw_Lv_Spec$)+1)
!
!            let Draw_Lv_Width(Udim(Mat Draw_Lv_Width))=0
!            let Draw_Lv_Spec$(Udim(Mat Draw_Lv_Spec$))="C 1000"
!
            print #Window, fields Spec$ : (Mat Draw_Lv_Caption$, Mat Draw_Lv_Width, Mat Draw_Lv_Spec$)
!
! .         ! Populate Listview with Empty Data
            mat Draw_Lv_Data$((Height(Control)-1)*Udim(Draw_Lv_Width))=("")
            let Spec$=Fncalculatelistviewspec$(Control,[[Screencontrols]])
            print #Window, fields Spec$&",=" : (Mat Draw_Lv_Data$)
            if ~Dontpopulate then
               let Fntrytopopulatelistviews(Window,Mat Screenio$,Mat Screenio, [[Screencontrols]],Control)
            end if
         #Case# "listchld"
! .         ! Listview Children get drawn by the Draw Listview Code Above
         #Case# "frame"
            let Spec$=fnCalculateFrameSpec$(Control,[[ScreenControls]],Active,Runtime)
            if Len(Trim$(Fgcolor$)) And Len(Trim$(Bgcolor$)) then
               let Spec$=Srep$(Spec$,Fncolor$(0,Fieldtype$(Control),Fgcolor$(Control),Bgcolor$(Control),0,Invisible(Control)),Fncolor$(0,Fieldtype$(Control),Fgcolor$,Bgcolor$))
            end if
            let fnOpenFrameWindow(Window,Spec$,Control,[[ScreenControls]],Runtime,Forceindex)

         #Case# "screen"
            let fnOpenScreen(Window,Spec$,Control,[[ScreenControls]],Runtime,ForceIndex,Active)

         #Case Else#
            let Data$=Fncalculatedata$(Control,[[Screencontrols]],Active)
            let Spec$=Fncalculatespec$(Window,Control,[[Screencontrols]],Active,1)

            if Len(Trim$(Fgcolor$)) And Len(Trim$(Bgcolor$)) then
               let Spec$=Srep$(Spec$,Fncolor$(0,Fieldtype$(Control),Fgcolor$(Control),Bgcolor$(Control),0,Invisible(Control)),Fncolor$(0,Fieldtype$(Control),Fgcolor$,Bgcolor$))
            end if
            print #Window, fields Spec$ : Data$ ! Inactivate Old Control
         #End Select#
      end if
   fnend

   def fnCloseFrameWindows(;___,Index)
      let fnChangeForceVisibility(0)
      for Index=1 to udim(mat FrameWindows)
         if FrameWindows(Index) and file(FrameWindows(Index))<>-1 then
            close #FrameWindows(Index):
         end if
      next Index
      mat FrameWindows(0)
      mat FrameKeys$(0)
      mat FrameSpecControl$(0)
      for Index=1 to udim(mat ScreenWindows)
         if ScreenWindows(Index) and file(ScreenWindows(Index))<>-1 then
            close #ScreenWindows(Index):
         end if
      next Index
      mat ScreenWindows(0)
      mat ScreenKeys$(0)
   fnend

   ! if framespec is given, don't close that one.
   def fnCloseFrameWindow(FrameKey$;&FrameSpec$,___,FrameKey)
      ! check to see if window is already open
      let FrameKey=srch(mat FrameKeys$,FrameKey$)
      if FrameKey>0 then
         if ~len(FrameSpec$) or FrameSpecControl$(FrameKey)><FrameSpec$ then
            if FrameWindows(FrameKey) and file(FrameWindows(FrameKey))<>-1 then
               ! print "Close "&FrameKey$ : pause
               close #FrameWindows(FrameKey):
               let FrameWindows(FrameKey)=0
               let FrameSpecControl$(FrameKey)=""
            end if
         end if
      end if
   fnend

   def fnReadSizeFromSpec(&Rows,&Cols,Spec$*255;___,SR,SC,ER,EC)
      let Rows=fnGetSpec("rows=",Spec$)
      let Cols=fnGetSpec("cols=",Spec$)
      if ~Rows then
         let SR=fnGetSpec("srow=",Spec$)
         let ER=fnGetSpec("erow=",Spec$)
         let Rows=(ER-SR)+1
      end if
      if ~Cols then
         let SC=fnGetSpec("scol=",Spec$)
         let EC=fnGetSpec("ecol=",Spec$)
         let Cols=(EC-SC)+1
      end if
   fnend
   def fnGetSpec(Key$*128,Spec$*255;EndChar$,___,Number,Number$)
      let Number$=fnGetSpec$(Key$,Spec$,EndChar$)
      let Number=val(Number$) conv Ignore
      let fnGetSpec=Number
   fnend

   def fnGetSpec$(Key$*128,Spec$*255;EndChar$,___,PosStart)
      if EndChar$="" then let EndChar$=","
      let PosStart=pos(lwrc$(Spec$),lwrc$(Key$))
      if PosStart then
         let PosStart+=len(Key$)
         let PosEnd=pos(lwrc$(Spec$),lwrc$(EndChar$),PosStart)
         if ~PosEnd then let PosEnd=len(Spec$) else let PosEnd-=1
         let fnGetSpec$=Spec$(PosStart:PosEnd)
      end if
   fnend

   def fnSameSize(Spec$*255,Window;___,Rows,Cols,TestRows,TestCols)
      if trim$(uprc$(file$(Window)))=":CON:" then
         let fnReadScreenSize(Rows,Cols,Window)
         if fnReadSizeFromSpec(TestRows,TestCols,Spec$) then
            if Rows=TestRows and Cols=TestCols then
               let fnSameSize=1
            end if
         end if
      end if
   fnend

   def fnOpenFrameWindow(Window,Spec$*255,Control,[[ScreenControls]];Runtime,Forceindex,___,FrameKey,AlreadyOpen)
      if trim$(Parent$(Control))="" then let Parent$(Control)=Fngenerateuniquelvname$(mat Parent$,FieldType$(Control))

      ! check to see if window is already open
      let FrameKey=srch(mat FrameKeys$,Parent$(Control))
      if FrameKey>0 then
         if FrameWindows(FrameKey) and file(FrameWindows(FrameKey))<>-1 then
            if Spec$><FrameSpecControl$(FrameKey) or (Editing and ~fnSameSize(Spec$,FrameWindows(FrameKey))) then
               close #FrameWindows(FrameKey):
               let FrameWindows(FrameKey)=0
            else
               let AlreadyOpen=1
            end if
         end if
      else
         let FrameKey=udim(mat FrameWindows)
         if ~FrameKey or FrameWindows(FrameKey) then
            let FrameKey+=1
            mat FrameWindows(FrameKey)
            mat FrameKeys$(FrameKey)
            mat FrameSpecControl$(FrameKey)
         end if
         let FrameKeys$(FrameKey)=Parent$(Control)
         let FrameSpecControl$(FrameKey)=Spec$
      end if
      if (~AlreadyOpen) and (~Runtime Or ~Invisible(Control)) then
         let FrameWindows(FrameKey)=fnGetFileNumber(-1)
         open #FrameWindows(FrameKey): Spec$&",parent="&str$(window),display,outin
         ! print "Open "&Parent$(Control) : pause
         if Forceindex then
            print #FrameWindows(FrameKey), fields "1,1,C "&str$(width(control)*height(control))&",/W:T,"&Str$(Forceindex) : "" ! Make it hot
         else if ~Runtime then
            print #FrameWindows(FrameKey), fields "1,1,C "&str$(width(control)*height(control))&",/W:T,"&Fnmakeindex$(Fieldtype$(Control),Control) : "" ! Make it hot
         end if
      end if
   fnend

   dim ScreenWindows(1)
   dim ScreenKeys$(1)

   dim PData$(1)*255

   def fnOpenScreen(Window,Spec$*255,Control,[[ScreenControls]];Runtime,Forceindex,Active,_Path$*255,___,ScreenKey,KeyVal$*255,Pth$*255,Parent_Key$*255,RecordVal,Dummy$*255,Dummy,WindowNumber,Record)
      ! check to see if window is already open
      let ScreenKey=srch(mat ScreenKeys$,Parent$(Control))
      if ScreenKey>0 then
         if ScreenWindows(ScreenKey) and file(ScreenWindows(ScreenKey))<>-1 then
            close #ScreenWindows(ScreenKey):
            let ScreenWindows(ScreenKey)=0
         end if
      else
         let ScreenKey=udim(mat ScreenWindows)
         if ~ScreenKey or ScreenWindows(ScreenKey) then
            let ScreenKey+=1
            mat ScreenWindows(ScreenKey)
            mat ScreenKeys$(ScreenKey)
         end if
          let ScreenKeys$(ScreenKey)=Parent$(Control)
      end if
      if ~Runtime Or ~Invisible(Control) then
         if ~ForceIndex then let ForceIndex=Control+fnKeyBase
         if len(trim$(_path$)) then let pth$=_path$ else let pth$=path$
         if ~Runtime then
            let fnPushScreen(mat ScreenIO$,mat ScreenIO,[[ScreenControls]])
            let ParentKey$=screenio$(si_Debugparentkey)
            let CurrentKey$=screenIO$(si_DebugKey)
            let CurrentRec=screenio(si_DebugRecord)
            let Pth$=ScreenIO$(si_DebugPath)
            let fnUnpackPData$(mat PData$,ScreenIO$(si_DebugPassed))
         end if
         let Dummy$="["&FieldName$(Control)&"]"&function$(Control)
         if Runtime then let Fnparsescreeninfo(Dummy$,Keyval$,Parent_Key$,Dummy,Dummy,Dummy,Dummy,Dummy,Recordval,ParentKey$)
         let WindowNumber=val(fnMaster$(fieldname$(Control),Keyval$,VPosition(Control),HPosition(Control),Parent_Key$,Window,1,1,RecordVal,Pth$,0,Active,ForceIndex,~Runtime,mat PData$))
         if ~Runtime then
            let fnPopScreen(mat ScreenIO$,mat ScreenIO,[[ScreenControls]])
         end if
         let ScreenWindows(ScreenKey)=WindowNumber
      end if
   fnend

   def fnUnpackPData$(mat X$,Y$*255;___,Index)
      if fn42 then
         let str2mat(y$,mat X$,",")
      else
         mat x$(0)
         do while pos(y$,",")
            let Index=udim(mat x$)+1
            mat x$(Index)
            let x$(Index)=y$(1:pos(y$,",")-1)
            let y$(1:pos(y$,","))=""
         loop
         if len(trim$(y$)) then
            let Index=udim(mat x$)+1
            mat x$(Index)
            let x$(Index)=y$
         end if
      end if
   fnend

DrawScreens: ! Predraw all the screens on the screen
   def fnDrawScreens(Window,Mat ScreenIO$,mat ScreenIO,[[ScreenControls]];Runtime,ForceIndex,WhichOne,___,Index)
      for Index=1 to Udim(Mat Fieldtype$) ! Look at all controls
         if WhichOne>=0 or WhichOne*-1=Index then ! Draw just the ones we want
            #Select# Lwrc$(Trim$(Fieldtype$(Index))) #Case# "screen"
               if Fnvalidspec(Index,Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
                  let Fndrawcontrol(Window,Index,Mat Screenio$,Mat Screenio,[[Screencontrols]],0,"","",0,ForceIndex,Runtime)
               end if
            #End Select#
         end if
      next Index
   fnend

DrawFrames: ! Predraw all the frames on the screen
   def fnDrawFrames(Window,Mat ScreenIO$,mat ScreenIO,[[ScreenControls]];Runtime,ForceIndex,WhichOne,___,Index)
      for Index=1 to Udim(Mat Fieldtype$) ! Look at all controls
         if WhichOne>=0 or WhichOne*-1=Index then ! Draw just the ones we want
            #Select# Lwrc$(Trim$(Fieldtype$(Index))) #Case# "frame"
               if Fnvalidspec(Index,Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
                  let Fndrawcontrol(Window,Index,Mat Screenio$,Mat Screenio,[[Screencontrols]],0,"","",0,ForceIndex,Runtime)
               end if
            #End Select#
         end if
      next Index
   fnend
!
DRAWALLLISTVIEWS: ! Redraw All The Listviews On The Screen
   def Fndrawalllistviews(Window,Mat Screenio$,Mat Screenio,[[Screencontrols]];Runtime,Forceindex,___,Index)
      for Index=1 to Udim(Mat Fieldtype$) ! Draw All Listview Controls (there's only ever one)
         if ~Runtime Or ~Invisible(Index) then
            #Select# Lwrc$(Trim$(Fieldtype$(Index))) #Case# "listview"
               if Fnvalidspec(Index,Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
                  let Fndrawcontrol(Window,Index,Mat Screenio$,Mat Screenio,[[Screencontrols]],0,"","",1,Forceindex)
               end if
            #End Select#
         end if
      next Index
   fnend
!
TRYTOPOPULATELISTVIEWS: ! Populates The Listview With Sample Data If Possible
   def Fntrytopopulatelistviews(Window,Mat Screenio$,Mat Screenio,[[Screencontrols]];Justthisone,___,Index,Prefix$,Filenumber,Theresalistview)
      dim Trypopulate$(1)*1000, Trypopulate(1)
      for Index=1 to Udim(Mat Fieldtype$)
         if Lwrc$(Fieldtype$(Index))="listview" then
            let Theresalistview=1
         end if
      next Index
!
      if Theresalistview And Pos(Uprc$(Env$("poplist")),"Y") And Trim$(Screenio$(Si_Filelay))<>"" And Fndoeslayoutexist(Trim$(Screenio$(Si_Filelay))) then
         let Filenumber=Fnopen(Trim$(Screenio$(Si_Filelay)),Mat Trypopulate$,Mat Trypopulate,Mat Form$)
!
         let Fnreadlayoutarrays(Trim$(Screenio$(Si_Filelay)),Prefix$,Mat Fieldsssubs$,Mat Fieldsnsubs$)
         for Index=1 to Udim(Mat Fieldsssubs$)
            let Fieldsssubs$(Index)=Lwrc$(Trim$(Fieldsssubs$(Index)))
         next Index
         for Index=1 to Udim(Mat Fieldsnsubs$)
            let Fieldsnsubs$(Index)=Lwrc$(Trim$(Fieldsnsubs$(Index)))
         next Index
!
         if Pos(Uprc$(Env$("filter")),"Y") And (~Librarylinkage Or Routinename$<>Screenio$(Si_Screencode)) then
            let Routinename$=Screenio$(Si_Screencode)
            let Fnestablishlibrarylinkage
            let Fnreadlayoutarrays("screenio",Screenioprefix$,Mat Screeniossubs$,Mat Screenionsubs$)
            let fnExecuteSetSubscripts(Mat ControlName$,"ctl_")
            let fnExecuteUniqueSubscripts(Mat ControlName$,"ctl_")
         end if
!
         let Fninitializemats(Mat S$,Mat Screensubs$,[[Screencontrols]])
         let Fnexecutesetsubscripts(Mat Screensubs$,"sio_")
!
         let Fnpopulatealllistviews(Window,Filenumber,Mat Fieldsssubs$,Mat Fieldsnsubs$,Mat S$,Mat Screensubs$,Mat Form$,mat ListviewRecords,[[Screencontrols]],Justthisone,(~(Librarylinkage And Pos(Uprc$(Env$("filter")),"Y"))),1)
         let Fnclosefile(Filenumber,Trim$(Screenio$(Si_Filelay)),"",1)
      end if
   fnend
!

! #Autonumber# 25000, 5
POPULATEALLLISTVIEWS: ! This Function Populates All The Listviews On The Screen
   def Fnpopulatealllistviews(Window,Fdatafile,Mat Fieldsssubs$,Mat Fieldsnsubs$,Mat S$,Mat Screensubs$,Mat Form$,mat Records,[[Screencontrols]];Justthisone,Ignorefilters,Editing,&FirstRow,DisplayOnly,___,Attribute$*128,Index,Spec$*60,Columns,Col,Populaterow,Colindex,Position,Color$*40,Screensubindex,Clearflag$,Populatedataudim,Populatecolorudim,Populatesize,Savefdatafile,Fileform,Rowcount,Every10,HasFilterFunction)
!
      dim Populatedata$(1000)*1000, Populatecolor$(9999)*40, Populateread$(1)*1000, Populateread(1), Listviewchildindex(1), PopulateSortedSubs, InitFunction$*255,FinalFunction$*255

      let InitFunction$=FinalFunction$=""
!      dim SearchColumn$*1000
!
      if Fdatafile And File(Fdatafile)>-1 then ! If File Is Open
!
         let Populatesize=9999
! .!
         mat Populateread$(Udim(Mat Fieldsssubs$))
         mat Populateread(Udim(Mat Fieldsnsubs$))

         restore #Fdatafile:

         if ~Ignorefilters then
            if exists(setting_FunctionFolder$&"defaults\") then
               if exists(setting_FunctionFolder$&"defaults\prelist.brs") then
                  let fnExecute(fnFunctionString$(setting_FunctionFolder$&"defaults\prelist.brs"))
               end if
            end if

            if len(trim$(ScreenIO$(si_PreListviewFn))) then
               let fnExecute(trim$(ScreenIO$(si_PreListviewFn)))
            end if

            for Index=1 to Udim(Mat Fieldtype$)
               if len(trim$(Function$(Index))) and Lwrc$(Trim$(Fieldtype$(Index)))="listview" then
                  let HasFilterFunction=1
                  let InitFunction$=fnGetSpecialFunctionHandle$(trim$(Function$(Index)),"Init_")
                  let FinalFunction$=fnGetSpecialFunctionHandle$(trim$(Function$(Index)),"Final_")
               end if
            next Index

            if HasFilterFunction then
               let fnExecute(InitFunction$)
            end if
         end if
! .!
         for Index=1 to Udim(Mat Fieldtype$)
            if (Index=Justthisone) Or (Not Justthisone) then
               if Editing Or ~Invisible(Index) then
                  #Select# Lwrc$(Trim$(Fieldtype$(Index))) #Case# "listview"
                     if Fnvalidspec(Index,Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
!
                        let Fileform=Fdatafile
!
                        if ~Screenio(Si_Readindex) then
! .                        ! Open file relative for faster reading
                           let Savefdatafile=Fdatafile
                           open #(Fdatafile:=Fngetfilenumber(400)): "name="&File$(Savefdatafile)&",shr",internal,input,relative
                           restore #Fdatafile:
                        end if
!
                        let fnPrepareAnim

                        let Populatedataudim=0
                        let Populatecolorudim=0
                        let Fnclearcolorarrays
!
                        let Clearflag$=",="
                        let Columns=Fncountcolumns(Parent$(Index),[[Screencontrols]])
                        mat Listviewchildindex(Columns)
                        for Col=1 to Columns
                           let Listviewchildindex(Col)=Fnfindlistviewchild(Col,Index,[[Screencontrols]])
                        next Col

                        let Spec$=Fncalculatelistviewspec$(Index,[[Screencontrols]])
!
                        if Fnvalidattribute(Attr$(Index),FieldType$(Index)) then
                           let Attribute$=Attr$(Index)
                        end if
! .   !
                        let Rowcount=0

                        if ~IgnoreFilters and len(trim$(function$(Index))) then
                           let fnExecute("{{SetData}}")
                        end if

                        dim PopulateIncrement,PopulateRecKeySize
                        let PopulateIncrement=1000 : let PopulateRecKeySize=0
                        mat Records(0)

                        do
                           read #Fdatafile, using Form$(Fileform), release: Mat Populateread$, Mat Populateread error IGNORE
                           if File(Fdatafile)=0 then ! If No Read Problems
                              if ~Ignorefilters then
                                 let Color$:=Fnpassfilter$(Mat Populateread$,Mat Populateread,Function$(Index),Index)
                              end if
                              if Ignorefilters Or (Len(Trim$(Color$)) And Trim$(Color$)<>"0" And Uprc$(Trim$(Color$))<>"STOP") then
                                 if mod(Every10:=Every10+1,7)=0 then let fnCheckSerialSlowdown ! #Autonumber# 25500,5
                                 let Rowcount+=1
                                 let Populatecolorudim+=1
                                 if Populatecolorudim>25000 then
                                    let Fnsetcolors(Mat Populatecolor$,mat Lvac_Start,mat Lvac_End,mat Lvac_Color$)
                                    mat Populatecolor$=("")
                                    let Populatecolorudim=1
                                 end if
                                 if Populatesize<Populatecolorudim then
                                    mat Populatecolor$(25000)
                                    let Populatesize=25000
                                 end if
                                 let Populatecolor$(Populatecolorudim)=Color$
                                 let Populaterow=Populatedataudim
                                 let Populatedataudim+=(Columns+1) ! Extra Columns To Store Record Number

                                 if RowCount>PopulateRecKeySize then ! Ensure its big enough
                                    let PopulateRecKeySize+=PopulateIncrement
                                    mat Records(PopulateRecKeySize)
                                 end if
! .   !
                                 let Records(RowCount)=rec(DataFile)

!                                 let SearchColumn$=""
                                 for Col=1 to Columns
                                    let Columnindex=Listviewchildindex(Col)
                                    if Trim$(Fieldname$(Columnindex))="" And Trim$(Controlname$(Columnindex))<>"" And (Screensubindex:=Srch(Mat Screensubs$,Lwrc$(Trim$(Controlname$(Columnindex)))))>0 then
                                       let Populatedata$(Populaterow+Col)=S$(Screensubindex)
                                    else
                                       if Fnisnumber(Mat Fieldsssubs$,Mat Fieldsnsubs$,Fieldname$(Columnindex)) then
                                          let Position=Srch(Mat Fieldsnsubs$,Lwrc$(Trim$(Fieldname$(Columnindex))))
                                          if Position>0 then
                                             let Populatedata$(Populaterow+Col)=Str$(Populateread(Position))
                                          end if
                                       else
                                          let Position=Srch(Mat Fieldsssubs$,Lwrc$(Trim$(Fieldname$(Columnindex))))
                                          if Position>0 then
                                             let Populatedata$(Populaterow+Col)=Populateread$(Position)
                                             let fnTrimToCRLF(Populatedata$(Populaterow+Col))
                                          end if
                                       end if
                                    end if

                                    ! Apply Conversion From Disk
                                    ! Only implemented for Dates in C fields and Listview Children
                                    if Lwrc$(CnvrtOut$(Columnindex))(1:5)="date(" then
                                       if fnIsDigit(PopulateData$(PopulateRow+Col)) then
                                          let Populatedata$(Populaterow+Col)=str$(days(val(Populatedata$(Populaterow+Col)),fnDateMask$(CnvrtOut$(Columnindex)))) error IGNORE
                                       else
                                          let Populatedata$(Populaterow+Col)=str$(days(Populatedata$(Populaterow+Col),fnDateMask$(CnvrtOut$(Columnindex)))) error IGNORE
                                       end if
                                    end if

                                    if Fnapplyconversion(Cnvrtin$(Columnindex)) then
                                       let Populatedata$(Populaterow+Col)=trim$(Cnvrt$(fnUnpackConvertSpec$(Columnindex,[[ScreenControls]]),Val(Populatedata$(Populaterow+Col)))) error IGNORE
                                    end if  ! Attempt To Apply Conversion Manually If Fnapplyconversion Thinks We Should
                                    ! let SearchColumn$=SearchColumn$&"|"&PopulateData$(PopulateRow+Col)
                                    let Populatedata$(Populaterow+Col)=Populatedata$(Populaterow+Col)(1:Specwidth(Columnindex))
                                 next Col
                                 let Populatedata$(Populaterow+Columns+1)=Str$(Rec(Fdatafile))
                                 ! let Populatedata$(Populaterow+Columns+2)=SearchColumn$
                                 if (Populatedataudim+Columns+2)>1000 then
                                    mat Populatedata$(Populatedataudim)
                                    print #Window, fields Spec$&Clearflag$&Attribute$ : (Mat Populatedata$)
                                    mat Populatedata$(1000)
                                    let Populatedataudim=0
                                    let Clearflag$=",+"
                                 end if
                              end if
                              let fnRunAnim
                           end if
                        loop Until (File(Fdatafile)=10) Or (Uprc$(Trim$(Color$))="STOP") Or (Editing And (Populatedataudim>((Height(Index)+5)*(Columns+1))))

                        if ~IgnoreFilters and len(trim$(function$(Index))) then
                           let fnExecute("{{GetData}}")
                        end if

                        if ~Populatecolorudim then
                           let Populatedataudim=Columns+1
                           mat Populatedata$(1:Populatedataudim)=("")
                        end if

                        let fnCloseAnim ! close animation window if its there.

                        mat Populatedata$(Populatedataudim)
                        print #Window, fields Spec$&Clearflag$&Attribute$ : (Mat Populatedata$)
                        mat Populatedata$(1000)
                        if Populatecolorudim then
                           mat Populatecolor$(Populatecolorudim)
                           let Fnsetcolors(Mat Populatecolor$,mat Lvac_Start,mat Lvac_End,mat Lvac_Color$)
                           mat Populatecolor$(25000)
                           let Populatecolorudim=0
!
                           let Fnapplycolor(Window,Spec$)
                           if SpecWidth(Index)<>0 then
                              if Specwidth(Index)>0 then
                                 print #Window, fields Spec$&",SORT" : Specwidth(Index)
                              else if Specwidth(Index)<0 then
                                 print #Window, fields Spec$&",SORT" : Abs(Specwidth(Index))
                                 print #Window, fields Spec$&",SORT" : Abs(Specwidth(Index))
                              end if
                              if ~Editing and ~DisplayOnly and fn43 then
                                 mat PopulateSortedSubs(RowCount)
                                 input #Window, fields Spec$&",ROWSUB,ALL,DISPLAYED_ORDER,NOWAIT" : mat PopulateSortedSubs
                                 let FirstRow=PopulateSortedSubs(1)
                              end if
                           end if
!
                           if fn42 and GridLines(Index) then
                              print #Window, fields Spec$&",GRIDLINES" : 1
                           end if
                        end if
                        mat Records(RowCount)
                        if Savefdatafile then close #Fdatafile: : let Fdatafile=Savefdatafile
                        let Fnpopulatealllistviews=Rowcount
                     end if
                  #Case Else#
! .   ! .            ! Ignore Non-Listview Controls
                  #End Select#
               end if
            end if
         next Index

         if ~Ignorefilters then

            if exists(setting_FunctionFolder$&"defaults\") then
               if exists(setting_FunctionFolder$&"defaults\postlist.brs") then
                  let fnExecute(fnFunctionString$(setting_FunctionFolder$&"defaults\postlist.brs"))
               end if
            end if

            if len(trim$(ScreenIO$(si_PostListviewFn))) then
               let fnExecute(trim$(ScreenIO$(si_PostListviewFn)))
            end if

            if HasFilterFunction then
               let fnExecute(FinalFunction$)
            end if
         end if

      end if
   fnend

!  #Autonumber# 26500,2
   def fnTrimToCRLF(&String$;___,Pos0D,Pos0A,PosCRLF)
      let Pos0D=pos(String$,hex$("0D"))
      let Pos0A=Pos(String$,hex$("0A"))
      if Pos0D and Pos0A then
         let PosCRLF=min(Pos0d,Pos0A)
      else if Pos0D then
         let PosCRLF=Pos0D
      else if Pos0A then
         let PosCRLF=Pos0A
      else
         let PosCRLF=0
      end if
      if PosCRLF then let String$=String$(1:PosCRLF-1)
   fnend

   def Fnisnumeric(&String$;___,Dummy)
      let Dummy=Val(String$) conv NOTNUMERIC
      let Fnisnumeric=1
NOTNUMERIC: ! Do Nothing
   fnend
!
   ! Strip up to third comma, for Listview Spec (Row,Col,LIST Rows/Cols,)
   def library fnListSpec$*255(SpecIn$*255)=SpecIn$(1:pos(SpecIn$,",",pos(SpecIn$,",",pos(SpecIn$,",")+1)+1)-1)

   ! Animation Functionality
   def library fnPrepareAnimation=fnPrepareAnim
   def library fnAnimate(;Text$*60)=fnRunAnim(Text$)
   def library fnCloseAnimation=fnCloseAnim

   def fnPrepareAnim ! set defaults
      dim Animtiming,Animation,Animwindow,Cspeed,Animframe,Animv,Animh,Arw,Acl,Cbd$*40,Ccl$*40,aRows,aText
      let AnimTiming=Animation=AnimWindow=CSpeed=AnimFrame=Animv=AnimH=Arw=Acl=0
      let Cbd$=Ccl$=""
      let CSpeed=.5

      let fnSettings
   fnend

   dim AnimSpec$(1)

   def fnRunAnim(;&Text$)
      ! Note: if text is given for any animation call,
      !  it must be given for the first one.
      if Animation<>-1 then
         if Timer-Animtiming>Cspeed then
            let Animtiming=Timer
!
            if Animation Or (Animation:=Fnreadclockfolder(setting_ClockPath$,Mat Animation$,Cspeed,Animv,Animh,Ccl$,Cbd$))>0 then
! .            ! Open Animation Window if its not open
               if ~Animwindow then
                  dim Clockattr$*128
                  let Clockattr$=""
!
                  let Fnreadscreensize(Screenv,Screenh)
                  if Len(Trim$(Ccl$)) then let Clockattr$=Clockattr$&",N="&Ccl$
                  if Len(Trim$(Cbd$)) then let Clockattr$=Clockattr$&",Border="&Cbd$
                  let aRows=Animv
                  if len(Text$) then
                     let aRows+=1
                     let aText=1
                     let animH=max(len(Text$),animH)
                     mat AnimSpec$(2)
                     let AnimSpec$(2)=str$(aRows)&",1,"&str$(animH)&"/CC 60"
                  else
                     mat AnimSpec$(1)
                     let aText=0
                  end if
                  let AnimSpec$(1)="1,1,P "&Str$(Animv)&"/"&Str$(Animh)
                  let Arw=Int((Screenv-Animv)/2)+1
                  let Acl=Int((Screenh-Animh)/2)+1
                  open #(Animwindow:=Fngetfilenumber(-1)): "srow="&Str$(Arw)&",scol="&Str$(Acl)&",rows="&Str$(aRows)&",cols="&Str$(Animh)&Clockattr$,display,outin
               end if

               let Animframe+=1
               if Animframe>Udim(Mat Animation$) then let Animframe=1
               if aText then
                  let AnimSpec$(2)=AnimSpec$(2)(1:pos(AnimSpec$(2)," ",-1))&str$(len(trim$(text$)))
                  print #Animwindow, fields mat AnimSpec$ : Animation$(Animframe), trim$(Text$)
               else
                  print #Animwindow, fields mat AnimSpec$ : Animation$(Animframe)
               end if
               scr_thaw
            end if
         end if
      end if
   fnend

   def fnCloseAnim
      if Animwindow then
         close #Animwindow:
         let Animwindow=0
      end if
   fnend

   dim Animation$(1)*255
   def Fnreadclockfolder(Folder$*255,Mat Animation$,&Animspeed,&Vsize,&Hsize,&Clockcolor$,&Clockborder$;___,Index,Settings)
      if Exists(Folder$) then
         if Udim(Mat Animation$)=1 And Animation$(1)="" then
            let Fnreadfiles(Mat Animation$,Folder$,"gif",1,0,1)
            let Fnreadfiles(Mat Animation$,Folder$,"jpg",0,0,1)
!
            for Index=1 to Udim(Mat Animation$)
               let Animation$(Index)=Folder$&"\"&Animation$(Index)&":NORESIZE"
            next Index
!
            let Fnsortanimations(Mat Animation$)
         end if
         if ~Vsize Or ~Hsize then
! .         ! Read Clock File
            if Exists(Folder$&"\clock.ini") then
               open #(Settings:=Fngetfilenumber): "name="&Folder$&"\clock.ini",display,input
               input #Settings: Animspeed,Vsize,Hsize,Clockcolor$,Clockborder$ error IGNORE
               close #Settings:
            end if
!
            if ~Vsize then let Vsize=5 ! Default Size
            if ~Hsize then let Hsize=10 ! Default Size
         end if
         if Udim(Mat Animation$) then
            let Fnreadclockfolder=1
         else
            let Fnreadclockfolder=-1
         end if
      else
         let Fnreadclockfolder=-1
      end if
   fnend
!
   dim Srt_Animation$(1)*255
   dim Sort(1)
   def Fnsortanimations(Mat Animation$;___,Index)
      mat Srt_Animation$(Udim(Animation$))=Animation$
      mat Sort(Udim(Animation$))=Aidx(Animation$)
!
      for Index=1 to Udim(Mat Sort)
         let Animation$(Index)=Srt_Animation$(Sort(Index))
      next Index
   fnend
!
   dim Lastindex
   dim Lvac_Start(1)
   dim Lvac_End(1)
   dim Lvac_Color$(1)*40
!
APPLYCOLOR: ! Function To Apply A Color Array To A Listview
   def Fnsetcolors(Mat Color$,mat Lvac_Start,mat Lvac_End,mat Lvac_Color$;___,Index,Color$*40,Start)
      for Index=1 to Udim(Mat Color$)
         if Color$<>Color$(Index) then
            let Color$=Color$(Index)
            if Udim(Mat Lvac_End) And ~Lvac_End(Udim(Mat Lvac_End)) then
               let Lvac_End(Udim(Mat Lvac_End))=Index+Lastindex-1
            end if
            if Color$(1:1)="/" Or Color$(1:1)="[" then
               mat Lvac_End(Udim(Mat Lvac_End)+1)
               mat Lvac_Start(Udim(Mat Lvac_End))
               mat Lvac_Color$(Udim(Mat Lvac_End))
!
               let Lvac_Start(Udim(Mat Lvac_Start))=Index+Lastindex
               let Lvac_Color$(Udim(Mat Lvac_Color$))=Color$
            end if
         end if
      next Index
      let Lastindex+=Udim(Mat Color$)
      if Udim(Mat Lvac_End) And ~Lvac_End(Udim(Mat Lvac_End)) then
         let Lvac_End(Udim(Lvac_End))=Udim(Mat Color$)
      end if
   fnend
!
   def Fnapplycolor(Window,Spec$)
      if Udim(Mat Lvac_End)>0 then
         print #Window, fields Spec$&",ATTR" : (Mat Lvac_Start, Mat Lvac_End, Mat Lvac_Color$)
      end if
   fnend
!
   def Fnclearcolorarrays
      mat Lvac_End(0)
      mat Lvac_Start(0)
      mat Lvac_Color$(0)
      let Lastindex=0
      mat Color$(0)
   fnend
!
CALCULATELISTVIEWHEADERS: ! Calculate The Columns And Spec For A Listview
   def Fncalculatelistviewheaders$*255(Mat Caption$, Mat Wid, Mat Spec$,Control,[[Screencontrols]];Active,&Count,___,Index,Attributes$*255)
      let Count=0
      mat Caption$(Count) : mat Wid(Count) : mat Spec$(Count)
      for Index=1 to Udim(Mat Fieldtype$)
         if Lwrc$(Trim$(Fieldtype$(Index)))="listchld" And Uprc$(Trim$(Parent$(Index)))=Uprc$(Trim$(Parent$(Control))) then
            let Count+=1
            mat Caption$(Count) : mat Wid(Count) : mat Spec$(Count)
            let Caption$(Count)=Trim$(Description$(Index))
            let Wid(Count)=Width(Index)
            let Attributes$=Attr$(Index)
            if Fnvalidhexcolor(Fgcolor$(Index)) Or Fnvalidhexcolor(Bgcolor$(Index)) then
               let Attributes$=Attributes$&Fncolor$(0,Fieldtype$(Index),Fgcolor$(Index),Bgcolor$(Index))
            ! else if Fnvalidhexcolor(Fgcolor$(Index)) then
            !    let Attributes$=Attributes$&Fncolor$(0,Fieldtype$(Index),Fgcolor$(Index),"N")
            ! else if Fnvalidhexcolor(Bgcolor$(Index)) then
            !    let Attributes$=Attributes$&Fncolor$(0,Fieldtype$(Index),"N",Bgcolor$(Index))    $$$$$
            end if
            if ~Fnvalidattribute(Attributes$,FieldType$(Index)) then
               let Attributes$=""
            end if
            let Spec$(Count)="C"&Trim$(Justify$(Index))&" "&Str$(Specwidth(Index))&","&Attributes$
! .         ! Apply conversion in Header if we should
            if Fnapplyconversion(Cnvrtin$(Index),1) then let Spec$(Count)=fnUnpackConvertSpec$(Index,[[ScreenControls]])&","&Attributes$
         end if
      next Index
      let Fncalculatelistviewheaders$=Fncalculatelistviewspec$(Control,[[Screencontrols]],Active,1)
   fnend

   def fnUnpackConvertSpec$*255(Control,[[ScreenControls]];___,Spec$*255)
      let Spec$=trim$(CnvrtIn$(Control))
      if Spec$="N" then let Spec$="N "&str$(SpecWidth(Control))
      let fnUnpackConvertSpec$=Spec$
   fnend
!
   def Fnapplyconversion(&Convert$;Header)
      if Len(Trim$(Convert$)) then
         if Fn42 And Trim$(Lwrc$(Convert$))(1:3)<>"pic" And Trim$(Lwrc$(Convert$))(1:3)<>"fmt" then
! .         ! Apply at Header
            let Fnapplyconversion=Header
         else
! .         ! Apply Manually
            let Fnapplyconversion=~Header
         end if
      end if
   fnend
!
   dim Combo$(1)*255 !
POPULATECOMBO: ! This Function Populates All The Combo Boxes On The Screen
   def Fnpopulatecombo(Window,Fdatafile,Mat Fieldsssubs$,Mat Fieldsnsubs$,Mat S$,Mat Screensubs$,Mat Form$,[[Screencontrols]];Justthisone,Ignorefilters,Editing,WhichOne,___,Attribute$*128,Index,Spec$*60,Position,Select$)
      for Index=1 to Udim(Mat Fieldtype$)
         if WhichOne>=0 or WhichOne*-1=Index then
            if (Index=Justthisone) Or (Not Justthisone) then
               if Editing Or ~Invisible(Index) then
                  #Select# Lwrc$(Trim$(Fieldtype$(Index))) #Case# "combo"
                     mat Combo$(0)
                     if ~IgnoreFilters and len(trim$(function$(Index))) then
                        ! run your populate function, pass it mat combo$
                        let fnExecuteGetData(function$(Index),mat Combo$,Index)
                     end if
                     let Attribute$="="
                     let Select$=""
                     if gridlines(index) then let Select$=",SELECT"
                     let spec$=fnCalculateSpec$(Window,Index,[[ScreenControls]])

                     let Position=pos(Spec$,",",-1)
                     let Spec$(Position:Position-1)=Select$ ! insert select attribute

                     let Position=pos(Spec$,",",pos(Spec$,",",pos(Spec$,",")+1)+1)
                     let Spec$(Position+1:Position)=Attribute$ ! insert populate attribute
                     scr_freeze
                     print #Window, fields spec$ : mat Combo$
                  #Case Else#
! .                  ! Ignore Non-Combo Controls
                  #End Select#
               end if
            end if
         end if
      next Index
   fnend

CALCULATELISTVIEWSPEC: ! Calculate The Listview Spec Here
   def Fncalculatelistviewspec$*255(Control,[[Screencontrols]];Active,Headers,___,Attributes$*128,Selected)
      if Headers then
         let Attributes$=Attr$(Control)
         let Attributes$=Fnremoveprotectedattribute$(Attributes$)
         if ~Fnvalidattribute(Attributes$,FieldType$(Control)) then
            let Attributes$=""
         end if
         if Sum(Selectedcontrols) then
            mat Selectedcontrols(Udim(Mat Controlname$))
            let Selected=Selectedcontrols(Control)
         end if
         let Fncalculatelistviewspec$=Str$(Vposition(Control))&","&Str$(Hposition(Control))&",LIST "&Str$(Height(Control))&"/"&Str$(Width(Control))&",HEADERS"&","&Attributes$&Fncolor$(Active,Fieldtype$(Control),Fgcolor$(Control),Bgcolor$(Control),Selected,Invisible(Control))&","&Fnmakeindex$(Fieldtype$(Control),Control)
      else
         let Fncalculatelistviewspec$=Str$(Vposition(Control))&","&Str$(Hposition(Control))&",LIST "&Str$(Height(Control))&"/"&Str$(Width(Control))
      end if
   fnend

   def fnControlDescription$*255(Control,[[ScreenControls]];FavorControlName)
      if FavorControlName then
         if Len(Trim$(Controlname$(Control))) then
            let fnControlDescription$=Controlname$(Control)
         else if Len(Trim$(Description$(Control))) then
            let fnControlDescription$=Description$(Control)
         else
            let fnControlDescription$=Str$(Vposition(Control))&","&Str$(Hposition(Control))&","&Fncalculatefieldtype$(Fieldtype$(Control),Justify$(Control),Width(Control),Specwidth(Control),Height(Control))
         end if
      else
         if Len(Trim$(Description$(Control))) then
            let fnControlDescription$=Description$(Control)
         else if Len(Trim$(Controlname$(Control))) then
            let fnControlDescription$=Controlname$(Control)
         else
            let fnControlDescription$=Str$(Vposition(Control))&","&Str$(Hposition(Control))&","&Fncalculatefieldtype$(Fieldtype$(Control),Justify$(Control),Width(Control),Specwidth(Control),Height(Control))
         end if
      end if
   fnend

CalculateFrameSpec: ! Calculate Frame Spec here
   def fnCalculateFrameSpec$*255(Control,[[ScreenControls]];Active,Runtime,___,Attributes$*128,Selected,Text$*255,Dummy$*255,Color$*255)
      if Runtime then
         let Text$=Description$(Control)
      else if ~Active And Len(Trim$(Description$(Control))) then
         let Text$=Description$(Control)
      else if ~Active And Len(Trim$(Controlname$(Control))) then
         let Text$=Controlname$(Control)
      else
         let Text$=str$(Vposition(Control))&"."&Str$(Hposition(Control))&"."&Str$(Width(Control))&"/"&Str$(Height(Control))
      end if
      let Attributes$=",N="&Attr$(Control)
      if ~fnValidFrame(Attributes$) then let Attributes$=""
      let Color$=Fncolor$(Active,Fieldtype$(Control),Fgcolor$(Control),Bgcolor$(Control),Selected,Invisible(Control))
      if ~len(trim$(color$)) then let Color$=""
      let Attributes$=",N="&Color$
      if GridLines(Control) then
         let Attributes$=",border=S"&Color$&Attributes$
         if len(trim$(Text$)) then
            let Attributes$=Attributes$&",caption="&trim$(Text$)
         end if
      end if
      if len(trim$(picture$(Control))) then
         let Dummy$=Picture$(Control)
         if Pos(Dummy$,":",-1)>4 then let Dummy$=Dummy$(1:Pos(Dummy$,":")-1)
         if exists(Dummy$) then
            let Attributes$=Attributes$&",picture="&Picture$(Control)
         end if
      end if

      let fnCalculateFrameSpec$="srow="&str$(Vposition(Control))&",scol="&str$(Hposition(control))&",rows="&str$(height(control))&",cols="&str$(width(Control))&Attributes$
   fnend
!
CALCULATESPEC: !  Calculate Spec For Editor Control
   def Fncalculatespec$*255(Window,Index,[[Screencontrols]];Active,Editing,OtherChanged,___,Target$*32,Target,Attributes$*383,Alternatespec$*255,FinalAttr$*383,Protect,FrameSpec$*255,PosOfComma)
      if Lwrc$(Trim$(Fieldtype$(Index)))="search" or Lwrc$(Trim$(Fieldtype$(Index)))="filter" then
         let Target=Fnfindtarget(Parent$(Index),[[Screencontrols]])
         if Target>0 then
            let Target$=","&Str$(Vposition(Target))&","&Str$(Hposition(Target))
         else
            let Target$=",1,1" ! Just Has To Be Something Valid
         end if
         if Lwrc$(Trim$(Fieldtype$(Index)))="filter" then
            let fnCleanFilter(Picture$(Index))

            let Target$=Target$&","&trim$(Picture$(Index),",")
         end if
      end if
      let Attributes$=Attr$(Index)
      if Protected(Index) then
         #Select# lwrc$(trim$(FieldType$(Index))) #Case# "c"
            if len(trim$(ScreenIO$(si_ProtectedText))) then
               let Attributes$=trim$(Attributes$)&trim$(ScreenIO$(si_ProtectedText))
               let Protect=1
            end if
         #Case# "button"
            if len(trim$(ScreenIO$(si_ProtectedButton))) then
               let Attributes$=trim$(Attributes$)&trim$(ScreenIO$(si_ProtectedButton))
               let Protect=1
            end if
         #Case# "check"
            if len(trim$(ScreenIO$(si_ProtectedCheck))) then
               let Attributes$=trim$(Attributes$)&trim$(ScreenIO$(si_ProtectedCheck))
               let Protect=1
            end if
         #Case# "search" # "filter"
            if len(trim$(ScreenIO$(si_ProtectedText))) then
               let Attributes$=trim$(Attributes$)&trim$(ScreenIO$(si_ProtectedText))
               let Protect=1
            end if
         #End Select#
      end if
      if Editing then
         let Attributes$=Fnremoveprotectedattribute$(Attributes$)
         if ~Fnvalidattribute(Attributes$,FieldType$(Index)) then
            let Attributes$=""
         end if
         mat Selectedcontrols(Udim(Mat Fieldtype$))
      else
         if Uprc$(Cnvrtin$(Index))(1:4)="FMT(" then let Alternatespec$=Cnvrtin$(Index)
      end if
      if fn42ia and fnMultilineTextbox(Index,[[ScreenControls]]) then
         if fn42jd then
            let Attributes$=Attributes$&"^ENTER_CRLF"
         else
            let Attributes$=Attributes$&"^ENTER-CRLF"
         end if
      end if
      let FinalAttr$=Attributes$&Fncolor$(Active,Fieldtype$(Index),Fgcolor$(Index),Bgcolor$(Index),(Editing And Selectedcontrols(Index)),(Editing And Invisible(Index)),Protect,OtherChanged)&Target$
      let Fncalculatespec$=Str$(Vposition(Index))&","&Str$(Hposition(Index))&","&Fncalculatefieldtype$(Fieldtype$(Index),Justify$(Index),Width(Index),Specwidth(Index),Height(Index),Attr$(Index),Alternatespec$)&","&FinalAttr$&","&Fnmakeindex$(Fieldtype$(Index),Index)

      if Window then
         ! if its a multiline textbox, button, or caption then
         ! open a frame tied to the thing by unique Parent$ value
         #Select# lwrc$(trim$(fieldtype$(Index))) #Case# "c" # "button" # "caption"
            ! We need to test if frame is broken first before reprinting it. We only need to reprint if it moves or changes
            let FrameSpec$=fnCalculateFrameSpec$(Index,[[ScreenControls]])
            let fnCloseFrameWindow(parent$(Index),FrameSpec$)
            if Height(Index)>1 then
               let fnChangeForceVisibility(0)
               let fnOpenFrameWindow(Window,FrameSpec$,Index,[[ScreenControls]],1)
               let fnChangeForceVisibility(1)
            end if
         #End Select#
      end if
   fnend
!
CALCULATEDATA: !  Calculate Data For Editor Control
   def Fncalculatedata$*255(Index,[[Screencontrols]];Active,Runtime,___,Data$*255,Target,Target$,Dummy$*255)
      #Select# Lwrc$(Trim$(Fieldtype$(Index)))   #Case# "caption"
         if Runtime Or (~Active And Len(Trim$(Description$(Index)))) then
            let Data$=Description$(Index)
!            If Data$="" Then Let Data$=" "
         else if ~Active And Len(Trim$(Controlname$(Index))) then
            let Data$=Controlname$(Index)
         else
            let Data$=Str$(Vposition(Index))&","&Str$(Hposition(Index))&","&Fncalculatefieldtype$(Fieldtype$(Index),Justify$(Index),Width(Index),Specwidth(Index),Height(Index))
         end if
         let Fnchangespecwidth(Index,Len(Data$))
      #Case# "check"
         if Runtime Or (~Active And Len(Trim$(Description$(Index)))) then
            let Data$=Description$(Index)
            if Data$="" then let Data$=" "
         else if ~Active And Len(Trim$(Controlname$(Index))) then
            let Data$=Controlname$(Index)
         else if Active then
            let Data$=Str$(Vposition(Index))&","&Str$(Hposition(Index))&","&Fncalculatefieldtype$(Fieldtype$(Index),Justify$(Index),Width(Index),Specwidth(Index),Height(Index),Attr$(Index))
         else
            let Data$=""
         end if
!
         if Active then let Data$="^"&Data$
         let Fnchangespecwidth(Index,Len(Data$)+1)
      #Case# "button"
         if Runtime Or (~Active And Len(Trim$(Description$(Index)))) then
            let Data$=Description$(Index)
            if Data$="" then let Data$=" "
         else if ~Active And Len(Trim$(Function$(Index))) then
            let Data$=Function$(Index)
         else if ~Active And Len(Trim$(Controlname$(Index))) then
            let Data$=Controlname$(Index)
         else
            let Data$=Str$(Vposition(Index))&","&Str$(Hposition(Index))&","&Fncalculatefieldtype$(Fieldtype$(Index),Justify$(Index),Width(Index),Specwidth(Index),Height(Index),"",Altspec$)
         end if
         let Fnchangespecwidth(Index,Len(Data$))
      #Case# "p"
         if Runtime Or Len(Trim$(Picture$(Index))) then
            let Data$=Picture$(Index)
            if Data$="" then let Data$=setting_ImagePath$&"\nothing.gif"
            if Fn42 then
               let Dummy$=Picture$(Index)
               if Pos(Picture$(Index),":",-1)>4 then let Dummy$=Dummy$(1:Pos(Dummy$,":")-1)
               if ~Exists(Dummy$) then let Data$=setting_ImagePath$&"\nothing.gif"
            end if
         else
            if Fn42 then
               let Data$=setting_ImagePath$&"\yellow.gif"
            else
               let Data$="nothing.bmp" ! It Doesn't have to exist in 4.1
            end if
         end if
      #Case# "c"
         if Runtime then
            let Data$=Description$(Index)
            if Data$="" then let Data$=" "
         else if ~Active And Len(Trim$(Fieldname$(Index))) then
            let Data$=Fieldname$(Index)
         else if ~Active And Len(Trim$(Controlname$(Index))) then
            let Data$=Controlname$(Index)
         else
            if Uprc$(Cnvrtin$(Index))(1:4)="FMT(" then let Dummy$=Cnvrtin$(Index) else let Dummy$=""
            let Data$=Str$(Vposition(Index))&","&Str$(Hposition(Index))&","&Fncalculatefieldtype$(Fieldtype$(Index),Justify$(Index),Width(Index),Specwidth(Index),Height(Index),"",Dummy$)
         end if
!
         let Data$=Data$(1:Specwidth(Index))
!
      #Case# "search"
         let Target=Fnfindtarget(Parent$(Index),[[Screencontrols]])
         if Target>0 then
            let Target$=",,"&Str$(Vposition(Target))&","&Str$(Hposition(Target))
         end if
!
         if Runtime then
            let Data$=Description$(Index)
            if Data$="" then let Data$=" "
         else if ~Active And Len(Trim$(Controlname$(Index))) then
            let Data$=Controlname$(Index)
         else
            let Data$=Str$(Vposition(Index))&","&Str$(Hposition(Index))&","&Fncalculatefieldtype$(Fieldtype$(Index),Justify$(Index),Width(Index),Specwidth(Index),Height(Index))&Target$
         end if
!
         let Data$=Data$(1:Specwidth(Index))

      #Case# "filter"
         let Target=Fnfindtarget(Parent$(Index),[[Screencontrols]])
         if Target>0 then
            let Target$=",,"&Str$(Vposition(Target))&","&Str$(Hposition(Target))
         end if
!
         if Runtime then
            let Data$=Description$(Index)
            if Data$="" then let Data$=" "
         else if ~Active And Len(Trim$(Controlname$(Index))) then
            let Data$=Controlname$(Index)
         else
            let Data$=Str$(Vposition(Index))&","&Str$(Hposition(Index))&","&Fncalculatefieldtype$(Fieldtype$(Index),Justify$(Index),Width(Index),Specwidth(Index),Height(Index))&Target$&","&Picture$(Index)
         end if
!
         let Data$=Data$(1:Specwidth(Index))
!
      #Case# "listchld"
      #Case# "listview"
      #Case# "screen"
      #Case# "frame"
      #Case Else#
         if Runtime then
            let Data$=Description$(Index)
            if Data$="" then let Data$=" "
         else if ~Active And Len(Trim$(Fieldname$(Index))) then
            let Data$=Fieldname$(Index)
         else if ~Active And Len(Trim$(Controlname$(Index))) then
            let Data$=Controlname$(Index)
         else
            let Data$=Str$(Vposition(Index))&","&Str$(Hposition(Index))&","&Fncalculatefieldtype$(Fieldtype$(Index),Justify$(Index),Width(Index),Specwidth(Index),Height(Index))
         end if
!
         if Specwidth(Index)>0 then
            let Data$=Data$(1:Specwidth(Index))
         else
            let Data$=Data$(1:Width(Index))
         end if
      #End Select#
      let Fncalculatedata$=Data$
   fnend
!
CALCULATEHELP: ! Calculate The Helptext By Adding The "3;" To The Beginning If Necessary.
   def Fncalculatehelp$*1017(Helptext$*1050;___,X,Helplevel$)
      let fnFixTooltips(HelpText$)
      let fnCalculateHelp$=HelpText$(1:1017)
   fnend
!
   def library fnBR42=fn42
   def library fnBR43=fn43
   def fn42=(Val(Wbversion$(1:3))>=4.2)
   def fn43=(Val(Wbversion$(1:3))>=4.3)
   def fn44=(Val(Wbversion$(1:3))>=4.4)
   def fn42ia=((Wbversion$=="4.20ia") or (fn42 and (Wbversion$(5:5)>"i"))) or Fn43
   def fn42jd=(Wbversion$>="4.20jd") or fn43
   def fn42e=(wbversion$>="4.20e") or fn43
   def fn432=(wbversion$(1:4)>="4.32") or fn44
   def fn432c=((wbversion$(1:4)=="4.32") and (lwrc$(wbversion$(5:5))>="c")) or fn433
   def fn433=(wbversion$(1:4)>="4.33") or fn44

!
CALCULATEFIELDTYPE: ! Caluclate Display Spec Based On Field Type
   def Fncalculatefieldtype$*255(Type$,Justify$,Width,Specwidth,Height;Attr$*128,Altspec$*255)
      #Select# Lwrc$(Trim$(Type$)) #Case# "c"
!         if Height>1 then let Width=Width+((Height-1)*Screenio(Si_Hsize))
         let Width=Width*max(Height,1)
         if Altspec$="" then
            let Fncalculatefieldtype$=Str$(Width)&"/"&Fndisplayfieldtype$(Type$)&Trim$(Justify$)&" "&Str$(Specwidth)
         else
            let Fncalculatefieldtype$=Str$(Width)&"/"&Altspec$
         end if
      #Case# "combo"
         let Width=Width*max(Height,1)
         if Altspec$="" then
            let Fncalculatefieldtype$=Str$(Width)&"/"&Fndisplayfieldtype$(Type$)&" "&Str$(Specwidth)
         else
            let Fncalculatefieldtype$=Str$(Width)&"/"&Altspec$
         end if
      #Case# "p"
         let Fncalculatefieldtype$=Fndisplayfieldtype$(Type$)&" "&Str$(Height)&"/"&Str$(Width)
      #Case# "button"
         let Width=Width*max(Height,1)
         let Fncalculatefieldtype$=Str$(Width)&"/"&Fndisplayfieldtype$(Type$)&" "&Str$(Max(Specwidth,1))
      #Case# "caption"
!         if Height>1 then let Width=Width+((Height-1)*Screenio(Si_Hsize))
         let Width=Width*max(Height,1)
         let Fncalculatefieldtype$=Str$(Width)&"/"&Fndisplayfieldtype$(Type$)&Trim$(Justify$)&" "&Str$(Specwidth)
      #Case# "listchld"
      #Case# "listview"
      #Case# "frame"
      #Case# "check"
         if Pos("0123456789",Attr$(1:1)) then let Type$="radio"
         let Fncalculatefieldtype$=Str$(Width)&"/"&Fndisplayfieldtype$(Type$)&" "&Str$(Max(Specwidth,1))
      #Case# "search" # "filter"
         let Fncalculatefieldtype$=Str$(Width)&"/"&Fndisplayfieldtype$(Type$)&" "&Str$(Specwidth)
      #Case Else#
         let Fncalculatefieldtype$=Fndisplayfieldtype$(Type$)&" "&Str$(Width)
      #End Select#
   fnend
!
DISPLAYFIELDTYPE: !  Calculate Display Field Type
   def Fndisplayfieldtype$(Type$)
      #Select# Lwrc$(Trim$(Type$)) #Case# "caption"
         let Fndisplayfieldtype$="C"
      #Case# "button"
         let Fndisplayfieldtype$="CC"
      #Case# "listview"
      #Case# "listchld"
      #Case Else#
         let Fndisplayfieldtype$=Type$
      #End Select#
   fnend
COLOR: ! Determine Color Spec Based On Type
   def Fncolor$*255(Active,Type$,Fgcolor$,Bgcolor$;Selected,Invisible,Protected,OtherChanged,___,Sunken$,Color$*255)
      if OtherChanged then
         if len(trim$(screenIO$(si_OtherChanges))) then
            let Color$=trim$(screenIO$(si_OtherChanges))
         else
            let Color$="/#000000:#FF99FF" ! Pink
         end if
      else
         if Active then
            if Selected then
               let Bgcolor$="A0FF00" ! Yellow Green
            else
               if Invisible then
                  let Bgcolor$="FF9933" ! Orange (Yellow Pink)
               else
                  let Bgcolor$="FFFF00" ! Yellow
               end if
            end if
         else
            if Selected then
               let Bgcolor$="00FF00" ! Green
            else if Invisible then
               let BgColor$="FF99FF" ! Pink
            end if
         end if
         if ~Protected and (Len(Trim$(Fgcolor$)) Or Len(Trim$(Bgcolor$))) then
            if ~Fnvalidhexcolor(Fgcolor$) then let Fgcolor$="W"
            if ~Fnvalidhexcolor(Bgcolor$) then let Bgcolor$="W"
            if Len(Trim$(Fgcolor$))=6 then let Fgcolor$="#"&Fgcolor$
            if Len(Trim$(Bgcolor$))=6 then let Bgcolor$="#"&Bgcolor$
            let Fgcolor$=Trim$(Fgcolor$)
            let Bgcolor$=Trim$(Bgcolor$)
            let Color$="/"&Fgcolor$&":"&Bgcolor$
         end if
   ! .!
         #Select# Lwrc$(Trim$(Type$)) #Case# "c"
            let Sunken$="S"
         #Case Else#
            let Sunken$=""
         #End Select#
      end if
      let Fncolor$=Sunken$&Color$
   fnend
MAKEINDEX: !  Calculate Index Based On Field Type   (Button Or Otherwise)
   def Fnmakeindex$(Type$,Index)
      #Select# Lwrc$(Trim$(Type$)) #Case#  "button"
         let Fnmakeindex$="B"&Str$(fnKeyBase+Index)
      #Case Else#
         let Fnmakeindex$=Str$(fnKeyBase+Index)
      #End Select#
   fnend
!
REMOVEPROTECTEDATTRIBUTE: ! Strip Protected Attribute
   def Fnremoveprotectedattribute$*128(Wrkattr$*128;___,Ploop,Spot)
      for Ploop = 1 to Len(Wrkattr$)
         if (Spot:=Pos(Wrkattr$,"[",Ploop))>0 then
            let Wrkattr$(Ploop:Spot-1)=Srep$(Wrkattr$(Ploop:Spot-1),"p","")
            let Wrkattr$(Ploop:Spot-1)=Srep$(Wrkattr$(Ploop:Spot-1),"P","")
            let Ploop = Pos(Wrkattr$,"]",Spot)
            if Ploop<1 then
               let Ploop=Len(Wrkattr$)+5
            end if
         else
            let Wrkattr$(Ploop:Len(Wrkattr$)) = Srep$(Wrkattr$(Ploop:Len(Wrkattr$)),"p","")
            let Wrkattr$(Ploop:Len(Wrkattr$)) = Srep$(Wrkattr$(Ploop:Len(Wrkattr$)),"P","")
            let Ploop=Len(Wrkattr$)+5
         end if
      next Ploop
      let Fnremoveprotectedattribute$=Wrkattr$
   fnend
!
ATTRIBUTE: ! Check For A Specific Attribute
   def Fnattribute(Searchfor$,Listviewindex,[[Screencontrols]];___,Parent$,Control,Startp,Endp,Attribute$*255,Broken) ! Returns True If Theres An L Attribute
      if Listviewindex And Listviewindex<=Udim(Mat Parent$) then
         let Parent$=Parent$(Listviewindex)
         for Control=1 to Udim(Mat Parent$)
            if Parent$(Control)=Parent$ then
               let Broken=0
               let Attribute$=Attr$(Control)
               do While (Startp:=Pos(Attribute$,"["))>0
                  if (Endp:=Pos(Attribute$,"]",Startp)) then
                     let Attribute$(Startp:Endp)=""
                  else
                     let Broken=1
                  end if
               loop Until Broken
               if ~Broken then
                  if Pos(Lwrc$(Attribute$),Lwrc$(Searchfor$))>0 then
                     let Fnattribute=1
                     let Control=Udim(Mat Parent$)
                  end if
               end if
            end if
         next Control
      end if
   fnend
!
! *****************************************************************
! ********************** Input Listview Fields ********************
! *****************************************************************
INPUTLISTVIEWFIELDS: ! Create A Grid Containing All Listview Columns
   def Fninputlistviewfields(&Mode, &Control, Mat Screenio$,Mat Screenio,[[Screencontrols]];___,Window,Function,Weditor,Spec$*60,Index,Columns,Key$,Lastchild,Wfields,Inputrow,Currentcolumn,Direction,Fromindex,Toindex,Fkeyvalue$,WGrid,LSpec$*64,eRow,eCol,lWidth,Rows,Cols)
!
      if Control>0 And Lwrc$(Trim$(Fieldtype$(Control)))="listview" then
         let Weditor=Fngeteditorwindow
!
! .       ! Open Window to the Left with the row captions
         let Window=Fnopengridheadingswindow(14,15,Vposition(Control),Hposition(Control))
         let Fnprintgridheadingswindow(Window,15)
!
         if fn43 then
            execute "config keyboard C000 1300" ! Ctrl <- To Shift F9  (Fkey 19)
            execute "config keyboard C100 1500" ! Ctrl -> To Shift F10 (Fkey 21)
         else
            execute "config keyboard 7600 1300" ! Ctrl <- To Shift F9  (Fkey 19)
            execute "config keyboard 7500 1500" ! Ctrl -> To Shift F10 (Fkey 21)
         end if
         execute "config keyboard 0B00 0A0A0A636F6E206B657920636C6561720D" ! Shift F1 Key To "con key clear<CR>"
!
         let Fngeteditorposition(eRow,eCol)
         let LSpec$=Fncalculatelistviewheaders$(Mat Draw_Lv_Caption$, Mat Draw_Lv_Width, Mat Draw_Lv_Spec$,Control,[[Screencontrols]],Active,Columns)

         let eRow=VPosition(Control)
         let eCol=HPosition(Control)
         let fnCalculateRealPosition(eRow,eCol)
         let lWidth=Width(Control)
         let fnGetScreenSize(Rows,Cols)
         let eRow=Min(RowS-14,eRow)

         ! Open it at position of editor window + position of listview, width of listview, height of 10
         open #(wGrid:=fnGetFileNumber): "srow="&str$(ERow)&",scol="&str$(eCol)&",rows=13,cols="&str$(lwidth),display,outin

         do
! .          ! Draw Listview Header
            let Spec$=Fncalculatelistviewheaders$(Mat Draw_Lv_Caption$, Mat Draw_Lv_Width, Mat Draw_Lv_Spec$,Control,[[Screencontrols]],Active,Columns)
            let Spec$=Srep$(Uprc$(Spec$),"LIST","GRID")
            let Spec$(1:pos(Spec$,"/")-1)="1,1,GRID 13"

            if fn42 then
               mat Draw_Lv_Spec$=("C 255,^nosort") ! Reset All Specs To Attribute Grid Specs
            else
               mat Draw_Lv_Spec$=("C 255") ! Reset All Specs To Attribute Grid Specs
            end if
            for Index=1 to Udim(Mat Draw_Lv_Width)
               let Draw_Lv_Width(Index)=Max(1,Draw_Lv_Width(Index))
            next Index
!
            print #wGrid, fields Spec$ : (Mat Draw_Lv_Caption$, Mat Draw_Lv_Width, Mat Draw_Lv_Spec$)
!
! .         ! Populate Listview with Column Data
            let Fnloadlistchlddata(Control,Columns,Mat Draw_Lv_Data$,[[Screencontrols]])
!
            let Spec$=Fncalculatelistviewspec$(Control,[[Screencontrols]])
            let Spec$=Srep$(Uprc$(Spec$),"LIST","GRID")
            let Spec$(1:pos(Spec$,"/")-1)="1,1,GRID 13"
            let Fkeyvalue$=","&Fnmakeindex$(Fieldtype$(Control),Control)
            print #wGrid, fields Spec$&",="&Fkeyvalue$ : (Mat Draw_Lv_Data$)
!
! .         ! Next Input from Grid
            if Udim(Mat Draw_Lv_Data$) And Sum(Mat Draw_Lv_Width) then
               input #wGrid, fields Spec$&",CELL,ALL"&Fkeyvalue$ : (Mat Draw_Lv_Data$)
               let Currentcolumn=Curcol
            else
               input #0, fields "1,2,C 1,AEX" : Key$
               let Currentcolumn=0
            end if
            let Function=Fkey
!
! .         ! Store Results Back into Child Arrays
            let Fnsavelistchlddata(Control,Columns,Mat Draw_Lv_Data$,[[Screencontrols]])
!
            if Function=0 then
               let Function=1500+Control
            end if

            if Function=19 Or Function=21 then ! Ctrl Left Arrow (Shift Column)
               let Direction=Function-20 ! -1 For Left, 1 For Right
               if Currentcolumn>0 And Currentcolumn<=Columns And Currentcolumn+Direction>0 And Currentcolumn+Direction<=Columns then
                  let Fromindex=Fnfindlistviewchild(Currentcolumn,Control,[[Screencontrols]])
                  let Toindex=Fnfindlistviewchild(Currentcolumn+Direction,Control,[[Screencontrols]])
                  let Fnswapcontrolarrays(Fromindex,Toindex,[[Screencontrols]])
                  let Curfld(1,(Columns*(Currow-1))+Currentcolumn+Direction)
               else
                  print Bell
                  let Curfld(1,(Columns*(Currow-1))+Currentcolumn)
               end if
            end if
            if Function=1000 then ! Add Column
               let Fnaddlistviewchild(Parent$(Control),[[Screencontrols]])
            end if
            if Function=1001 then ! Delete Column
! .            ! Find Current Column. Delete That One. Shift All Others.
               let Fromindex=Fnfindlistviewchild(Currentcolumn,Control,[[Screencontrols]])
!
               for Index=Fromindex to Udim(Mat Controlname$)-1
                  let Fncopycontrolarrays(Index,Index+1,[[Screencontrols]])
               next Index
               let Fnresizecontrolarrays(Udim(Mat Controlname$)-1,[[Screencontrols]])
            end if
            if Function=1300 then
               let Wfields=Fngetfieldswindow
               let Fncolorfieldsactive(1)
               do
                  let Fngetfieldsspec(Spec$)
                  rinput #Wfields, fields Spec$ : Inputrow
                  let Function=Fkey
                  if Function=1300 Or Function=0 Or Function=201 then
                     let Fnaddcurrentlistchld(Parent$(Control),[[Screencontrols]])
                     let Function=0
!
                     let Spec$=Fncalculatelistviewheaders$(Mat Draw_Lv_Caption$, Mat Draw_Lv_Width, Mat Draw_Lv_Spec$,Control,[[Screencontrols]],Active,Columns)
                     let Spec$=Srep$(Uprc$(Spec$),"LIST","GRID")
                     let Spec$(1:pos(Spec$,"/")-1)="1,1,GRID 13"

                     mat Draw_Lv_Spec$=("C 255") ! Reset All Specs To Attribute Grid Specs
                     for Index=1 to Udim(Mat Draw_Lv_Width)
                        let Draw_Lv_Width(Index)=Max(1,Draw_Lv_Width(Index))
                     next Index
                     print #wGrid, fields Spec$ : (Mat Draw_Lv_Caption$, Mat Draw_Lv_Width, Mat Draw_Lv_Spec$)
                     let Fnloadlistchlddata(Control,Columns,Mat Draw_Lv_Data$,[[Screencontrols]])
                     let Spec$=Fncalculatelistviewspec$(Control,[[Screencontrols]])
                     let Spec$=Srep$(Uprc$(Spec$),"LIST","GRID")
                     let Spec$(1:pos(Spec$,"/")-1)="1,1,GRID 13"

                     let Fkeyvalue$=","&Fnmakeindex$(Fieldtype$(Control),Control)
                     print #wGrid, fields Spec$&",="&Fkeyvalue$ : (Mat Draw_Lv_Data$)
                  end if
               loop While Function=0
               if Function=1500+Control then
                  let Function=0
               end if
               let Fncolorfieldsactive(0)
            end if
         loop Until Function>1100 Or Function=99 Or Function=98 Or Function=93 Or Function=44
         close #Window: ! Close Gridheadings Window
         close #wGrid: ! Close Grid editing window
         execute "config keyboard clear"
         let Fninputlistviewfields=Function
      else
         let Mode=0 ! Reset Mode For Invalid Control
      end if
   fnend
!
FINDLISTVIEWCHILD: ! Finds The "Nth" Listview Child
   def Fnfindlistviewchild(N,Control,[[Screencontrols]];___,Index,Count)
      do While (Index:=Index+1)<= Udim(Mat Fieldtype$)
         if Lwrc$(Trim$(Fieldtype$(Index)))="listchld" And Parent$(Index)=Parent$(Control) then
            let Count+=1
         end if
      loop Until Count=N
      let Fnfindlistviewchild=Index
   fnend
!
COUNTCOLUMNS: ! Count The Columns Of A Listview Control
   def Fncountcolumns(Parent$,[[Screencontrols]];___,Index,Count)
      for Index=1 to Udim(Mat Fieldtype$)
         if Lwrc$(Trim$(Fieldtype$(Index)))="listchld" And Parent$(Index)=Parent$ then
            let Count+=1
         end if
      next Index
      let Fncountcolumns=Count
   fnend
!
OPENGRIDHEADINGSWINDOW: !  Open The Attributes Window In A Place It Wont Be Off The Screen
   def Fnopengridheadingswindow(Rowsize,Colsize,Row,Col;___,Window,Rows,Cols)
      let Fncalculaterealposition(Row, Col)
      let Row=Max(2,Row) !  Try To The Left
      let Col=Max(2,Col-Colsize-1)
      let fnGetScreenSize(Rows,Cols)
      let Row=Min(RowS-RowSize,Row)
      open #(Window:=Fngetfilenumber) : "SROW="&Str$(Row)&",SCOL="&Str$(Col)&",ROWS="&Str$(Rowsize)&",COLS="&Str$(Colsize)&",Border=S",display,outin
      let Fnopengridheadingswindow=Window
   fnend
!
PRINTGRIDHEADINGSWINDOW: ! Print The Grid Headings To The Given Window
   def Fnprintgridheadingswindow(Window,Width)
      dim Gh_Caption$(1),Gh_Width(1),Gh_Spec$(1)
      dim Gh_Data$(11)
!
      let Gh_Caption$(1)=""
      let Gh_Width(1)=Width
      if fn42 then
         let Gh_Spec$(1)="CR 18,^nosort"
      else
         let Gh_Spec$(1)="CR 18"
      end if
!
      dim Lv_Buttons$(2)
      dim Lv_Buttonsspec$(2)*32
!
      let Lv_Buttonsspec$(1)="13,1,CC 14,/W:W,B1000"
      let Lv_Buttonsspec$(2)="14,1,CC 14,/W:W,B1001"
!
      let Lv_Buttons$(1)="Add Column"
      let Lv_Buttons$(2)="Delete Column"
!
      let Gh_Data$(1)="Control Name-" !:
      let Gh_Data$(2)="Field Name-" !:
      let Gh_Data$(3)="Caption-" !:
      let Gh_Data$(4)="Data Width-" !:
      let Gh_Data$(5)="Display Width-" !:
      let Gh_Data$(6)="Justify-" !:
      let Gh_Data$(7)="FgColor-" !:
      let Gh_Data$(8)="BgColor-" !:
      let Gh_Data$(9)="Attributes-" !:
      let Gh_Data$(10)="Column Spec-" !:
      let Gh_Data$(11)="Date Disk Fmt-"
!
      print #Window, fields "1,1,GRID 12/16,HEADERS,/W:W" : (Mat Gh_Caption$, Mat Gh_Width, Mat Gh_Spec$)
      print #Window, fields "1,1,GRID 12/16,=" : (Mat Gh_Data$)
      print #Window, fields Mat Lv_Buttonsspec$ : Mat Lv_Buttons$
   fnend
!
SAVELISTCHLDDATA: ! Saves The Listview Child Data Back To The Screencontrols Objects
   def Fnsavelistchlddata(Control,Columns,Mat Data$,[[Screencontrols]];___,Index,Dummy$)
      for Index=1 to Udim(Data$)
         #Select# Int((Index-1)/Columns)+1 #Case# 1
            let Controlname$(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]]))=Trim$(Data$(Index))(1:20)
         #Case# 2
            let Fieldname$(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]]))=Trim$(Data$(Index))(1:30)
         #Case# 3
            let Description$(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]]))=Trim$(Data$(Index))(1:60)
         #Case# 4
            let Specwidth(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]]))=Val(Data$(Index)) conv IGNORE
         #Case# 5
            let Width(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]]))=Val(Data$(Index)) conv IGNORE
         #Case# 6
            let Dummy$=Trim$(Uprc$(Data$(Index)))(Len(Trim$(Data$(Index))):Len(Trim$(Data$(Index))))
            if Dummy$="C" Or Dummy$="U" Or Dummy$="R" Or Dummy$="L" or Dummy$="" then
               let Justify$(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]]))=Dummy$
            end if
         #Case# 7
            let Fgcolor$(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]]))=Trim$(Data$(Index))(1:6)
         #Case# 8
            let Bgcolor$(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]]))=Trim$(Data$(Index))(1:6)
         #Case# 9
            let Attr$(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]]))=Trim$(Data$(Index))
         #Case# 10
            let Data$(Index)=fnFixDateSpec$(Data$(Index))
            let Cnvrtin$(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]]))=Trim$(Data$(Index))
         #Case# 11
            let Data$(Index)=fnFixDateSpec$(Data$(Index))
            let CnvrtOut$(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]]))=Trim$(Data$(Index))
         #End Select#
      next Index
   fnend
!
LOADLISTCHLDDATA: ! Loads The Listview Child Data From The Screencontrols Objects
   def Fnloadlistchlddata(Control,Columns,Mat Data$,[[Screencontrols]];___,Index)
      mat Data$(11*Columns)
      for Index=1 to Udim(Data$)
         #Select# Int((Index-1)/Columns)+1 #Case# 1
            let Data$(Index)=Controlname$(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]]))
         #Case# 2
            let Data$(Index)=Fieldname$(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]]))
         #Case# 3
            let Data$(Index)=Description$(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]]))
         #Case# 4
            let Data$(Index)=Str$(Specwidth(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]])))
         #Case# 5
            let Data$(Index)=Str$(Width(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]])))
         #Case# 6
            let Data$(Index)=Justify$(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]]))
         #Case# 7
            let Data$(Index)=Fgcolor$(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]]))
         #Case# 8
            let Data$(Index)=Bgcolor$(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]]))
         #Case# 9
            let Data$(Index)=Attr$(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]]))
         #Case# 10
            let Data$(Index)=Cnvrtin$(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]]))
         #Case# 11
            let Data$(Index)=CnvrtOut$(Fnfindlistviewchild(Mod(Index-1,Columns)+1,Control,[[Screencontrols]]))
         #End Select#
      next Index
   fnend
!
!  #Autonumber# 33000,2
! *****************************************************************
! *********************** Input Control Attr **********************
! *****************************************************************
PREFORMEDITORINPUT: !
   def Fnpreformeditorinput(&Mode, &Control, Mat Screenio$,Mat Screenio,[[Screencontrols]];___,Window,Function,Field,Weditor,Data$*255,Spec$*60,Fgcolorindex,Bgcolorindex,Justifysub,Functioneditsub,Listviewindex,Specwidthindex,Temp_Fgcolor$,Temp_Bgcolor$,Csopenstring$,Screen$,BorderSize,ScreenAttr$*255)
      dim Static_Lastcontrol, Static_Curfld, Oas_Spec$(1)*60, Oas_Data$(1)*1000, Oas_Captionspec$(1), Oas_Captiondata$(1)*30, Oas_Tooltip$(1)*2000, Oas_Inputspec$(1)*60, Oas_Inputdata$(1)*2000, Oas_InputTooltip$(1)*2000, Oas_Subs(1), Oas_Buttons(1)
      if Control>0 then
         let Weditor=Fngeteditorwindow
         let Fngenerateoaspecs(Fieldtype$(Control) ,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,Mat Oas_Buttons)
         if Udim(Mat Oas_Spec$) then
            let Window=Fnopenobjectattributeswindow(Control,Max(Udim(Mat Oas_Spec$),Udim(Mat Oas_Captionspec$)),32,[[Screencontrols]])
            print #Window, fields Mat Oas_Captionspec$ : Mat Oas_Captiondata$
            let Fnobjecttoscreen(Control,Mat Oas_Subs,Mat Oas_Data$,Mat Oas_Spec$,[[Screencontrols]])
!
            if (Justifysub:=Srch(Mat Oas_Subs,Sf_Justify)) > 0 then
               let Fnpopulatejustify(Oas_Spec$(Justifysub),Window)
            end if
            if (Functioneditsub:=Srch(Mat Oas_Subs,Sf_Function))>0 then
               print #Window, fields Fnfunctioneditspec$(Oas_Spec$(Functioneditsub),Functioneditsub) : "Edit"
            end if
            if (Functioneditsub:=Srch(Mat Oas_Subs,Sf_Cnvrtin))>0 then
               print #Window, fields Fnfunctioneditspec$(Oas_Spec$(Functioneditsub),Functioneditsub) : "Edit"
            end if
            ! if (Functioneditsub:=Srch(Mat Oas_Subs,Sf_Cnvrtout))>0 then
            !    print #Window, fields Fnfunctioneditspec$(Oas_Spec$(Functioneditsub),Functioneditsub) : "Edit"
            ! end if
            if (Functioneditsub:=Srch(Mat Oas_Subs,Sf_Picture))>0 then
               print #Window, fields Fnfunctioneditspec$(Oas_Spec$(Functioneditsub),Functioneditsub) : "Select"
            end if
!
            let Fncopyoasinputspec(Mat Oas_Inputspec$,Mat Oas_Inputdata$,mat Oas_InputTooltip$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,Mat Oas_Buttons)
! .!
            do
               if Static_Lastcontrol=Control then
                  let Curfld(Static_Lastcurfld)
               end if
               print #Window, fields Mat Oas_Spec$, help mat Oas_Tooltip$ : Mat Oas_Data$
               input #Window, fields Mat Oas_Inputspec$, help mat Oas_InputTooltip$ : Mat Oas_Inputdata$
               let Function=Fkey
               let Fncopybackoasinputspec(Mat Oas_Inputspec$,Mat Oas_Inputdata$,Mat Oas_Spec$,Mat Oas_Data$,Mat Oas_Subs,Mat Oas_Buttons)
! .!
               let Fnsetlastcurfld(Control, Curfld)
               if Function=0 then
                  let Function=1500+Control
               end if
! .!
               if Function>1000 And Function<=1000+Udim(Mat Oas_Subs) then
                  let Field=Function-1000
                  #Select# Oas_Subs(Field) #Case# Sf_Fgcolor # Sf_Bgcolor
                     let Fgcolorindex=Srch(Mat Oas_Subs,Sf_Fgcolor)
                     let Bgcolorindex=Srch(Mat Oas_Subs,Sf_Bgcolor)
!
                     if Fgcolorindex>0 Or Bgcolorindex>0 then
                        let Oas_Data$(Field)=fnColorPicker$(Oas_Data$(Field),0,0,"Select Color",Function)

                        if Trim$(Oas_Data$(field))="" then ! Setting either to "" sets all to ""
                           if bgcolorindex>0 then let oas_data$(bgColorIndex)=""
                           if fgColorIndex>0 then let oas_data$(fgColorIndex)=""
                        else if oas_subs(field)=sf_bgcolor then
                           if fgColorIndex>0 then
                              if trim$(oas_data$(fgcolorindex))="" then
                                 let oas_data$(fgColorIndex)="W"
                              end if
                           end if
                        end if

                        if Fgcolorindex>0 then let Temp_Fgcolor$=Oas_Data$(Fgcolorindex) else let Temp_Fgcolor$="W"
                        if Bgcolorindex>0 then let Temp_Bgcolor$=Oas_Data$(Bgcolorindex) else let Temp_Bgcolor$="W"

                        let Fnadjustspeccolor(Oas_Spec$(Field),Oas_Data$(Field))
                        print #Window, fields Oas_Spec$(Field) : Oas_Data$(Field) ! Update Button Color

                        let Fndrawcontrol(Weditor,Control,Mat Screenio$,Mat Screenio,[[Screencontrols]],0,Temp_Fgcolor$,Temp_Bgcolor$) ! Update Control
                     end if

                  #Case# Sf_Function # Sf_Cnvrtin # Sf_Cnvrtout
                     if len(trim$(Oas_Data$(Field))) and Exists(Fncustomfilenameof$(Oas_Data$(Field))) then
                        let Fneditcustomfunction(Oas_Data$(Field))
                     else
                        let Oas_Data$(Field)=Fnselectfunctiondialog$(Oas_Data$(Field),Function,2000+Oas_Subs(Field),fnSubType(FieldType$(Control)))
                     end if

                  #Case# Sf_Picture
                     if lwrc$(trim$(fieldtype$(Control)))="filter" then
                        let Oas_Data$(Field)=fnSelectFilterTarget$(Oas_Data$(Field),Control,[[ScreenControls]])
                     else
                        ! if Fnclientserver then let Csopenstring$="@:"
                        open #(Filenumber:=Fngetfilenumber): "name=open:"&Csopenstring$&"*.gif;*.jpg;*.bmp;*.ico;*.png, recl=1024", external, input error IGNORE
                        if File(Filenumber)=0 then
                           let Oas_Data$(Field)=File$(Filenumber)
!
                           let Picture$(Control)=Oas_Data$(Field) ! Update Picture
                           let Fndrawcontrol(Weditor,Control,Mat Screenio$,Mat Screenio,[[Screencontrols]])
                        end if
                        if File(Filenumber)>-1 then close #Filenumber:
                     end if
!
                  #Case# Sf_Parent
                     if (Lwrc$(Trim$(Fieldtype$(Control)))="search") or (lwrc$(trim$(fieldtype$(Control)))="filter") then
                        let Listviewindex=Srch(Mat Fieldtype$,"LISTVIEW")
                        if Listviewindex>0 then
                           let Fnsetsearchlistview(Control,Listviewindex,[[Screencontrols]])
                           let Oas_Data$(Field)=Parent$(Control)
                           let Specwidthindex=Srch(Mat Oas_Subs,-1*Sf_Specwidth)
                           if Specwidthindex>0 then
                              let Oas_Data$(Specwidthindex)=Str$(Specwidth(Control))
                           end if
                           let Fndrawcontrol(Weditor,Control,Mat Screenio$,Mat Screenio,[[Screencontrols]]) ! Update Control
                        end if
                     end if

                  #Case# Sf_FieldName
                     if Lwrc$(Trim$(Fieldtype$(Control)))="screen" then
                        Let Screen$=Fnselectscreen$
                        If Trim$(Screen$)<>"" Then
                           Let Fieldname$(Control)=Screen$
                           Let Oas_Data$(Field)=Screen$
                           let fnReadChildScreenSize(Control,mat ScreenIO$,mat ScreenIO,[[ScreenControls]])
                           let Function=1500+Control
                        End If

                        let Fndrawcontrol(Weditor,Control,Mat Screenio$,Mat Screenio,[[Screencontrols]]) ! Update Control
                     end if
! .!
                  #End Select#
                  let fnChangeForceVisibility(0)
               end if
! .!
            loop Until Function>1100 Or Function=99 Or Function=98 Or Function=93 Or Function=44 Or Function=19
            let Fncopybackoasinputspec(Mat Oas_Inputspec$,Mat Oas_Inputdata$,Mat Oas_Spec$,Mat Oas_Data$,Mat Oas_Subs,mat Oas_Buttons)
            let Fnscreentoobject(Control,Mat Oas_Subs,Mat Oas_Data$,[[Screencontrols]])
            if Window and file(Window)>-1 then close #Window:
            let Fnpreformeditorinput=Function
         else
            let Mode=0
         end if
      else
         let Mode=0 ! Reset Mode To Default For Invalid Control Number
      end if
   fnend

   dim SF_TargetField$(1)*64
   dim SF_FilterType$(3)

   dim SF_Spec$(3)*64, SF_Data$(3)*64
   def fnSelectFilterTarget$*255(TargetString$*255,Control,[[ScreenControls]];___,Index,Count,Window,SaveTarget$*255)
      open #(Window:=fnGetFileNumber): "srow=10,scol=30,rows=7,cols=40,border=S",display,outin
      print #Window, fields "1,1,CC 30;3,1,CR 15;4,1,CR 15;7,18,CC 10,/W:W,B55;7,29,CC 10,/W:W,B99" : "Select Target Field","Field: ","Filter Type: ","Ok","Cancel"

      let TargetString$=uprc$(TargetString$)
      let SaveTarget$=TargetString$

      if len(trim$(Parent$(Control))) then
         let Count=fnCountColumns(Parent$(Control),[[Screencontrols]])
      end if
      mat SF_TargetField$(Count+1)
      let SF_TargetField$(1)="0 - All"
      for Index=1 to Count
         let SF_TargetField$(Index+1)=str$(Index)
      next Index

      let SF_FilterType$(1)="LEADING"
      let SF_FilterType$(2)="WORD"
      let SF_FilterType$(3)="ALL"

      print #Window, fields "3,16,15/COMBO 64,=,SELECT" : mat SF_TargetField$
      print #Window, fields "4,16,COMBO 15,=,SELECT" : mat SF_FilterType$

      let SF_Spec$(1)="3,16,15/COMBO 64,/W:W,SELECT"
      let SF_Spec$(2)="4,16,COMBO 15,/W:W,SELECT"
      let SF_Spec$(3)="5,14,CHECK 15"

      if pos(TargetString$,",") then
         if lwrc$(TargetString$)(1:4)="full" then
            let SF_Data$(1)="0"
         else
            let SF_Data$(1)=str$(int(max(fnReturnValue(TargetString$(1:pos(TargetString$,",")-1)),0)))
         end if
         let TargetString$(1:pos(TargetString$,","))=""
         if SF_Data$(1)="0" then let sf_Data$(1)="0 - All"
      else
         let SF_Data$(1)=str$(int(max(fnReturnValue(TargetString$),0)))
         let TargetString$=""
      end if

      if pos(TargetString$,",") then
         let SF_Data$(2)=TargetString$(1:pos(TargetString$,",")-1)
         let TargetString$(1:pos(TargetString$,","))=""

         if SF_Data$(2)<>"LEADING" and SF_Data$(2)<>"WORD" and SF_Data$(2)<>"ALL" then
            let SF_Data$(2)="ALL"
         end if
      else
         let SF_Data$(2)="ALL"
         let TargetString$=""
      end if

      if len(TargetString$) then
         let SF_Data$(3)="^Case Sensitive"
      else
         let SF_Data$(3)="Case Sensitive"
      end if

      do
         rinput #Window, fields mat SF_Spec$ : mat SF_Data$
         if SF_Data$(1)(1:1)="0" then let SF_Data$(1)="0"
         let SF_Data$(1)=str$(int(max(0,fnReturnValue(SF_Data$(1))))) ! Enforce its a positive integer
      loop until fkey=55 or fkey=99 or fkey=93

      close #Window:

      if fkey=55 then
         if Sf_Data$(1)="0" then let SaveTarget$="FULLROW" else let SaveTarget$=Sf_Data$(1)
         let SaveTarget$=SaveTarget$&","&SF_Data$(2)
         if SF_Data$(3)(1:1)="^" then let SaveTarget$=SaveTarget$&",CASE"
      end if
      let fnSelectFilterTarget$=SaveTarget$
   fnend

   dim CF_Target$(1)*255
   def fnCleanFilter(&Target$;___,Index)
      let Target$=uprc$(Target$)

      str2mat(Target$,mat CF_Target$,",")
      mat CF_Target$(3)

      for Index=1 to udim(mat CF_Target$)
         let CF_Target$(Index)=trim$(CF_Target$(Index))
      next Index

      if lwrc$(CF_Target$(1))(1:4)="full" then
         let CF_Target$(1)="0"
      else
         let CF_Target$(1)=str$(int(max(0,fnReturnValue(CF_Target$(1)))))
      end if

      if CF_Target$(2)<>"LEADING" and CF_Target$(2)<>"WORD" and CF_Target$(2)<>"ALL" then
         let CF_Target$(2)="ALL"
      end if

      if trim$(CF_Target$(3))><"" then
         let CF_Target$(3)="CASE"
      end if

      if val(CF_Target$(1))=0 then
         let CF_Target$(1)="FULLROW"
      end if

      mat2str(mat CF_Target$,Target$,",")
   fnend
!
   def Fnfunctioneditspec$*80(Spec$*80,Index;___,Row,Col,Length)
      let Row=Val(Spec$(1:Pos(Spec$,",")-1))
      let Spec$(1:Pos(Spec$,","))=""
      let Col=Val(Spec$(1:Pos(Spec$,",")-1))
      let Spec$(1:Pos(Spec$,","))=""
      if Pos(Spec$(1:4),"/") then
         let Length=Val(Spec$(1:Pos(Spec$,"/")-1)) conv IGNORE
      else
         let Length=Val(Spec$(3:Pos(Spec$,",")-1)) conv IGNORE
      end if
!
      let Fnfunctioneditspec$=Str$(Row)&","&Str$(Col+Length+1)&",4/CC 6,/W:W,B"&Str$(1000+Index)
   fnend

!
SETCURFLD: !  Set  The Curfld Of The Control
   def Fnsetlastcurfld(Control,Cfld)
      let Static_Lastcontrol=Control
      let Static_Lastcurfld=Cfld
   fnend
!
COPYOASINPUTSPEC: ! Copy The Oas Input Specs To The Input Spec Arrays
   def Fncopyoasinputspec(Mat Inspec$,Mat Indata$, Mat InHelp$, Mat Allspec$, Mat Alldata$, mat AllHelp$, Mat Allsubs, Mat Buttons;___,Index,Count)
      mat Inspec$(0) : mat Indata$(0) : mat InHelp$(0)
      for Index=1 to Udim(Mat Allsubs)
         if ~Buttons(Index) then
            let Count=Udim(Mat Inspec$)+1
            mat Inspec$(Count) : mat Indata$(Count) : mat InHelp$(Count)
            let Inspec$(Count)=Allspec$(Index)
            let Indata$(Count)=Alldata$(Index)
            let InHelp$(Count)=AllHelp$(Index)
         end if
      next Index
   fnend
!
COPYBACKOASINPUTSPEC: ! Copy The Oas Input Specs Back To The All Spec Arrays
   def Fncopybackoasinputspec(Mat Inspec$,Mat Indata$, Mat Allspec$, Mat Alldata$, Mat Allsubs, Mat Buttons;___,Index,Count)
      let Count=0
      for Index=1 to Udim(Mat Allsubs)
         if ~Buttons(Index) then
            let Count+=1
            let Allspec$(Index)=Inspec$(Count)
            let Alldata$(Index)=Indata$(Count)
         end if
      next Index
   fnend
!
ADJUSTSPECCOLOR: ! Adjust The Background Color Of The Given Spec
   def Fnadjustspeccolor(&Spec$,Color$*60;___,Fc$)
      if Pos(Spec$,",/") then
         if Fnvalidhexcolor(Color$) then
            if Len(Trim$(Color$))=6 then
               let Spec$(Pos(Spec$,",/")+1:Pos(Spec$,",",Pos(Spec$,",/")+1)-1) = Fnbuildcolor$(Color$)
            else
               if Uprc$(Trim$(Color$))="T" then
                  let Spec$(Pos(Spec$,",/")+1:Pos(Spec$,",",Pos(Spec$,":"))-1) = "/#FFFFFF:"&Trim$(Color$)
               else
                  let Spec$(Pos(Spec$,",/")+1:Pos(Spec$,",",Pos(Spec$,":"))-1) = "/#000000:"&Trim$(Color$)
               end if
            end if
         else
            let Spec$(Pos(Spec$,":")+1:Pos(Spec$,",",Pos(Spec$,":"))-1) = "W"
         end if
      end if
   fnend
!
OPENOBJECTATTRIBUTESWINDOW: !  Open The Attributes Window In A Place It Wont Be Off The Screen
   def Fnopenobjectattributeswindow(Control,Rowsize,Colsize,[[Screencontrols]];___,Window,Row,Col,Screenrowsize,Screencolsize,BorderSize)
      let Row=Vposition(Control)
      let Col=Hposition(Control)
      if (lwrc$(trim$(FieldType$(Control)))="frame" or lwrc$(trim$(FieldType$(Control)))="screen") and gridlines(Control) then let bordersize=1
      let Fncalculaterealposition(Row, Col)
      let Fngetscreensize(Screenrowsize,Screencolsize)
      let Row=Row+Max(Height(Control),1)+1+bordersize !  Try It Below First
      let Col=Col
      if (Row)+(Rowsize+1)>Screenrowsize then !  If It Doesnt Fit Below
         let Row=(Row-2-Bordersize)-(Rowsize+2) !   Try It Above
      end if
      if (Row)+(Rowsize+1)>Screenrowsize then !  If It Still Doesnt Fit
         let Row=Screenrowsize-(Rowsize+1) ! Move It So It Does Fit
      end if
      if (Col)+(Colsize)>Screencolsize then !  If It Doesnt Fit To The Right
         let Col=Col+Width(Control)-(Colsize) !  Try It To The Left
      end if
      if (Col)+(Colsize)>Screencolsize then ! If It Still Doesnt Fit
         let Col=Screencolsize-(Colsize+1) ! Move It So It Does Fit
      end if
      open #(Window:=Fngetfilenumber) : "SROW="&Str$(Row)&",SCOL="&Str$(Col)&",ROWS="&Str$(Rowsize)&",COLS="&Str$(Colsize)&",Border=S,Caption=Control "&Str$(Control),display,outin
      let Fnopenobjectattributeswindow=Window
   fnend
!
CALCULATEREALPOSITION: !  Calculates The Real Position Of An Object From Window 0
   def Fncalculaterealposition(&Row,&Col;___,Editrow, Editcol)
      let Fngeteditorposition(Editrow,Editcol)
      let Row+=Editrow-1
      let Col+=Editcol-1
   fnend
!
GENERATEOASPECS: ! Generate The Specs Based On Control Type)
   def Fngenerateoaspecs(Type$,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,Mat Oas_Buttons)
      let Fnresetoaspecs(Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
!
      #Select# Trim$(Lwrc$(Type$))   #Case#  "c"
         let Fnaddoaspec("Name:",Sf_Controlname,50,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Field:",Sf_Fieldname,50,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Data Width:",-1*Sf_Specwidth,3,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Caption Field:",Sf_Description,60,Mat Oas_Captionspec$, Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Attributes:",Sf_Attr,128,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Validation:",Sf_Function,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Foreground Color:",Sf_Fgcolor,6,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Background Color:",Sf_Bgcolor,6,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Justification Spec:",Sf_Justify,2,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Tooltip Text:",Sf_Tooltip,1000,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Conversion:",Sf_Cnvrtin,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Disk Date Format:",Sf_Cnvrtout,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("User Data:",Sf_Userdata,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Protected:",-1*Sf_Protected,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Invisible:",-1*Sf_Invisible,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
!
      #Case#  "search"
         let Fnaddoaspec("Name:",Sf_Controlname,50,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Data Width:",-1*Sf_Specwidth,3,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Caption Field:",Sf_Description,60,Mat Oas_Captionspec$, Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Validation:",Sf_Function,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Foreground Color:",Sf_Fgcolor,6,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Background Color:",Sf_Bgcolor,6,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Attributes:",Sf_Attr,128,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Set Listview:",Sf_Parent,10,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Tooltip Text:",Sf_Tooltip,1000,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("User Data:",Sf_Userdata,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Protected:",-1*Sf_Protected,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Invisible:",-1*Sf_Invisible,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)

      #Case#  "filter"
         let Fnaddoaspec("Name:",Sf_Controlname,50,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Data Width:",-1*Sf_Specwidth,3,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Caption Field:",Sf_Description,60,Mat Oas_Captionspec$, Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Validation:",Sf_Function,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Foreground Color:",Sf_Fgcolor,6,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Background Color:",Sf_Bgcolor,6,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Attributes:",Sf_Attr,128,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Set Listview:",Sf_Parent,10,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Tooltip Text:",Sf_Tooltip,1000,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("User Data:",Sf_Userdata,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Protected:",-1*Sf_Protected,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Invisible:",-1*Sf_Invisible,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Target Details:",Sf_Picture,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Target Details (mat Picture$) - Click this button to set the selection type for BR to use for the listview. You can also type the selection string directly in here.")
!
      #Case#  "caption"
         let Fnaddoaspec("Name:",Sf_Controlname,50,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Caption:",Sf_Description,60,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Caption (mat Description$) - The text to display.")
         let Fnaddoaspec("Field:",Sf_Fieldname,50,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Field (mat FieldName$) - Use this to tie the caption to a field on disk. Leave this blank if you hardcode the caption.")
         let Fnaddoaspec("Function:",Sf_Function,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Click Event Function (mat Function$) - The function specified here will be run whenever the user clicks on the control.")
         let Fnaddoaspec("Foreground Color:",Sf_Fgcolor,6,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Background Color:",Sf_Bgcolor,6,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Justification Spec:",Sf_Justify,2,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Attributes:",Sf_Attr,128,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Tooltip Text:",Sf_Tooltip,1000,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Conversion:",Sf_Cnvrtin,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("User Data:",Sf_Userdata,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Protected:",-1*Sf_Protected,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Invisible:",-1*Sf_Invisible,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
! .       !
      #Case# "p"
         let Fnaddoaspec("Name:",Sf_Controlname,50,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Picture File:",Sf_Picture,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Picture File (mat Picture$) - Enter or select the image file to display.")
         let Fnaddoaspec("Caption:",Sf_Description,60,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Caption (mat Description$) - The caption to display with the picture.")
         let Fnaddoaspec("Field:",Sf_Fieldname,50,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Field (mat FieldName$) - Use this to tie the picture to a field on disk. Leave this blank if you hardcode the picture.")
         let Fnaddoaspec("Attributes:",Sf_Attr,128,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Function:",Sf_Function,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Click Event Function (mat Function$) - The function specified here will be run whenever the user clicks on the control.")
         let Fnaddoaspec("Background Color:",Sf_Bgcolor,6,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Tooltip Text:",Sf_Tooltip,1000,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Conversion:",Sf_Cnvrtin,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("User Data:",Sf_Userdata,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Protected:",-1*Sf_Protected,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Invisible:",-1*Sf_Invisible,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)

      #Case# "calendar"
         let Fnaddoaspec("Name:",Sf_Controlname,50,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Field:",Sf_Fieldname,50,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Target Control:",Sf_Picture,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Caption:",Sf_Description,60,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Attributes:",Sf_Attr,128,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Function:",Sf_Function,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Click Event Function (mat Function$) - The function specified here will be run whenever the user clicks on the control.")
         let Fnaddoaspec("Background Color:",Sf_Bgcolor,6,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Tooltip Text:",Sf_Tooltip,1000,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("User Data:",Sf_Userdata,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Protected:",-1*Sf_Protected,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Invisible:",-1*Sf_Invisible,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         ! Needs a button to select the Target Control
         ! or perhaps just specify the function or just have it generate a picture with a function.
         !  it would be just as simple to say in the "Generate", "please select a target control." and then it just generates a P control
         !  with the calendar icon for the image and the function that calls mikhails function.

!
      #Case# "check"
         let Fnaddoaspec("Name:",Sf_Controlname,50,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Field:",Sf_Fieldname,50,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Caption:",Sf_Description,60,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Caption (mat Description$) - The text to display with the checkbox.")
         let Fnaddoaspec("Truth Value:",Sf_Truevalue,60,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Falsehood Value:",Sf_Falsevalue,60,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Validation:",Sf_Function,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Attributes:",Sf_Attr,128,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Foreground Color:",Sf_Fgcolor,6,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Background Color:",Sf_Bgcolor,6,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Tooltip Text:",Sf_Tooltip,1000,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("User Data:",Sf_Userdata,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Protected:",-1*Sf_Protected,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Invisible:",-1*Sf_Invisible,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
!
      #Case#  "button"
         let Fnaddoaspec("Name:",Sf_Controlname,50,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Caption:",Sf_Description,60,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Caption (mat Description$) - The text to display on the button.")
         let Fnaddoaspec("Field:",Sf_Fieldname,50,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Field (mat FieldName$) - Use this to tie the buttons Caption to a field on disk. Leave this blank if you hardcode the caption.")
         let Fnaddoaspec("Function:",Sf_Function,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Click Event Function (mat Function$) - The function specified here will be run whenever the user clicks on the button.")
         let Fnaddoaspec("Attributes:",Sf_Attr,128,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Foreground Color:",Sf_Fgcolor,6,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Background Color:",Sf_Bgcolor,6,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Tooltip Text:",Sf_Tooltip,1000,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Conversion:",Sf_Cnvrtin,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("User Data:",Sf_Userdata,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Protected:",-1*Sf_Protected,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Invisible:",-1*Sf_Invisible,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
!
      #Case# "listview"
         let Fnaddoaspec("Name:",Sf_Controlname,50,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Caption Field:",Sf_Description,60,Mat Oas_Captionspec$, Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Sort Column:",-1*Sf_Specwidth,2,Mat Oas_Captionspec$, Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Sort Column (mat SpecWidth) - The sort column for the listview. Recommended if there is a search box, as BR uses this for the field to search.")
         let Fnaddoaspec("Filter:",Sf_Function,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Filter Function (mat Function$) - Filter Function for the listview. This function will be called once for each record in the data file. Return true to include it and false to exclude it from the listview. See the documentation for more details.")
         let Fnaddoaspec("Header FG Color:",Sf_Fgcolor,6,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Foreground Color (mat FgColor$) - Click to select the Foreground Color for the listview headers.")
         let Fnaddoaspec("Header BG Color:",Sf_Bgcolor,6,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Background Color (mat BgColor$) - Click to select the Background Color for the listview headers.")
         let Fnaddoaspec("Attributes:",Sf_Attr,128,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Attributes (mat Attr$) - Business Rules Control Attributes for the listview headers. This can be any valid BR Attribute specification for Listviews.")
         let Fnaddoaspec("User Data:",Sf_Userdata,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Protected:",-1*Sf_Protected,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Invisible:",-1*Sf_Invisible,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("MultiSelect:",-1*Sf_Multiselect,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         if fn42 then
            let Fnaddoaspec("Gridlines:",-1*Sf_GridLines,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         end if
!
      #Case#  "frame"
         let Fnaddoaspec("Border:",-1*Sf_GridLines,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Border (mat GridLines) - Put a border on the frame.")
         let Fnaddoaspec("Name:",Sf_Controlname,50,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Caption:",Sf_Description,60,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Caption (mat Description$) - Caption for the frame's Border.")
         let Fnaddoaspec("Picture File:",Sf_Picture,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Picture (mat Picture$) - Picture to use for background of frame. Use this feature to place controls on top of pictures.")
         let Fnaddoaspec("Foreground Color:",Sf_Fgcolor,6,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Background Color:",Sf_Bgcolor,6,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Color Attr:",Sf_Attr,128,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Color Attributes (mat Attr$) - Color Attributes for the frame.")
         let Fnaddoaspec("User Data:",Sf_Userdata,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Invisible:",-1*Sf_Invisible,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
! .       !
      #Case# "screen"
         let Fnaddoaspec("Name:",Sf_Controlname,50,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Screen:",Sf_Fieldname,18,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,1,"Screen (mat FieldName$) - Select the target screen here.")
         let Fnaddoaspec("Function:",Sf_Function,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Function (mat Function$) - Use this field to specify any values that need to be passed into the child screen. Example: ""ParentKey$=CurrentKey$"".")
         let Fnaddoaspec("User Data:",Sf_Userdata,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Protected:",-1*Sf_Protected,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Invisible:",-1*Sf_Invisible,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
!
      #Case#  "combo"
         let Fnaddoaspec("Name:",Sf_Controlname,50,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Field:",Sf_Fieldname,50,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Data Width:",-1*Sf_Specwidth,3,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Caption Field:",Sf_Description,60,Mat Oas_Captionspec$, Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Attributes:",Sf_Attr,128,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Populate:",Sf_Function,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Populate Function (mat Function$) - Populate and Validate event function. This function will be run when ScreenIO tries to populate the combo box, and any data placed in an array called mat ReturnData$ will be put in the combo box.")
         let Fnaddoaspec("Foreground Color:",Sf_Fgcolor,6,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Background Color:",Sf_Bgcolor,6,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Tooltip Text:",Sf_Tooltip,1000,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Conversion:",Sf_Cnvrtin,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("User Data:",Sf_Userdata,255,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Protected:",-1*Sf_Protected,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         let Fnaddoaspec("Invisible:",-1*Sf_Invisible,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons)
         if fn42 then
            let Fnaddoaspec("Select Only:",-1*Sf_GridLines,1,Mat Oas_Captionspec$,Mat Oas_Captiondata$,Mat Oas_Spec$,Mat Oas_Data$,mat Oas_Tooltip$,Mat Oas_Subs,mat Oas_Buttons,0,"Select Only (mat GridLines) - Select this to make a Selection Box instead of a Combo Box.")
         end if
      #End Select#
   fnend
!
RESETOASPECS: ! Reset Oa Specs
   def Fnresetoaspecs(Mat Cspec$,Mat Cdata$,Mat Spec$,Mat Dat$,mat TTip$,Mat Subs,mat Buttons)
!
      mat Cspec$(0)
      mat Cdata$(0)
      mat Spec$(0)
      mat Dat$(0)
      mat TTip$(0)
      mat Subs(O)
      mat Buttons(0)
!
   fnend

   def fnDefaultTooltip$*255(Sub)
      #Select# Sub #Case# Sf_ControlName
         let fnDefaultTooltip$="Control Name (mat ControlName$) - Use to reference control in code, example: let Invisible(ctl_ControlName)=0"
      #Case# Sf_FieldName
         let fnDefaultTooltip$="Field Name (mat FieldName$) - Name of the field in the data file for when control is tied directly to data file."
      #Case# -1*Sf_SpecWidth
         let fnDefaultTooltip$="Spec Width (mat SpecWidth) - Maximum allowed width for the data. The user will be stopped from typing more characters then this."
      #Case# Sf_Description
         let fnDefaultTooltip$="Description (mat Description$) - Control Name of the control that is the caption for this control. The specified control's movement will be tied to this control, to make screen design more convenient."
      #Case# Sf_Attr
         let fnDefaultTooltip$="Attribute (mat Attr$) - Business Rules Control Attributes for the control. This can be references to attributes defined in your brconfig.sys file, or hardcoded control attributes."
      #Case# Sf_Function
         let fnDefaultTooltip$="Function (mat Function$) - Validation function for the control. The selected function will be run any time the data in this control changes. This can be used to update related fields on the screen."
      #Case# sf_fgcolor
         let fnDefaultTooltip$="Foreground Color (mat FgColor$) - Click to select the Foreground Color for the control."
      #Case# sf_bgcolor
         let fnDefaultTooltip$="Background Color (mat BgColor$) - Click to select the Background Color for the control."
      #Case# Sf_Justify
         let fnDefaultTooltip$="Justification Spec (mat Justify$) - Business Rules Justification Spec: C=Center, R=Right, L=Lowercase and U=Uppercase."
      #Case# Sf_Tooltip
         let fnDefaultTooltip$="Tooltip Text (mat Tooltip$) - Help text to be shown when the user hovers the mouse over this control."
      #Case# Sf_CnvrtIn
         let fnDefaultTooltip$="Conversion Spec (mat CnvrtIn$) - ScreenIO Conversion Spec, choose from any valid FMT(, PIC( or DATE( spec."
      #Case# Sf_CnvrtOut
         let fnDefaultTooltip$="Disk Date Format (mat CnvrtOut$) - Use this field in conjunction with the Conversion field, to unpack a date field that is stored on disk like DATE(YYMMDD), in order to enable ScreenIO's Date Processing for dates that aren't Julian."
      #Case# Sf_UserData
         let fnDefaultTooltip$="UserData (mat UserData$) - Whatever typed here will be available in an array called Mat UserData$ that can be examined by your functions. To access this value in a function, use UserData$(ControlIndex). This value is not used by ScreenIO."
      #Case# -1*Sf_Protected
         let fnDefaultTooltip$="Protected (mat Protected) - If this is checked, the control will be kept out of the input fields statement and will be read only to the user."
      #Case# -1*Sf_Invisible
         let fnDefaultTooltip$="Invisible (mat Invisible) - If this is checked, the control will be kept off the screen, making it invisible to the user."
      #Case# Sf_Parent
         let fnDefaultTooltip$="Parent Control (mat Parent$) - Click this button to tie the filter/search box to a listview. Should be done automatically if you added the listview first."
      #Case# Sf_TrueValue
         let fnDefaultTooltip$="True Value (mat TrueValue$) - The value to save in the data if the box is checked. (Used when reading too.)"
      #Case# Sf_FalseValue
         let fnDefaultTooltip$="False Value (mat FalseValue$) - The value to save in the data if the box is unchecked. (Used when reading too.)"
      #Case# -1*Sf_GridLines
         let fnDefaultTooltip$="Grid Lines (mat GridLines) - Draw Gridlines to make a listview look like a grid."
      #Case# -1*Sf_MultiSelect
         let fnDefaultTooltip$="Multiselect (mat Multiselect) - Check this checkbox to make a multiselect listview. Use mat SelectedKeys$ in your functions to see which records are selected."
      #End Select#
   fnend

!
ADDOASPEC: ! Add A Spec
   def Fnaddoaspec(Caption$*30,Sub,Width,Mat Cspec$,Mat Cdata$,Mat Spec$,Mat Dat$, mat Ttip$,Mat Subs, mat Buttons;ForceButton,Tooltip$*255,___,Index)
!
      let Index=Udim(Mat Cspec$)+1
      mat Cspec$(Index)
      mat Cdata$(Index)
      mat Spec$(Index)
      mat Dat$(Index)
      mat TTip$(Index)
      mat Subs(Index)
      mat Buttons(Index)

      if Tooltip$="" then
         let Tooltip$=fnDefaultTooltip$(Sub)
      end if

      let fnFixTooltips(Tooltip$)

      let Cspec$(Index)=Str$(Index)&",1,"&Str$(Int(Len(Caption$)*4/5)+2)&"/CL "&Str$(Len(Caption$))
      let Cdata$(Index)=Caption$
      let TTip$(Index)=Tooltip$
      let Subs(Index)=Sub
      let Buttons(Index)=0
!
      #Select# Sub #Case# Sf_Fgcolor # Sf_Bgcolor # Sf_Parent
         let Spec$(Index)=Str$(Index)&","&Str$(Int(Len(Caption$)*4/5)+4)&","&Str$(Min(32-(Int(Len(Caption$)*4/5)+2),Width+3))&"/CC "&Str$(Width)&",/W:W,B"&Str$(1000+Index)
         let Buttons(Index)=1
!
      #Case# Sf_Justify
         let Spec$(Index)=Str$(Index)&","&Str$(Int(Len(Caption$)*4/5)+3)&","&Str$(Min(32-(Int(Len(Caption$)*4/5)+2),Width+3))&"/COMBO "&Str$(Width)&",/W:#FFFF77"
!
      #Case# Sf_Function # Sf_Cnvrtin # Sf_Cnvrtout # Sf_Picture
         let Spec$(Index)=Str$(Index)&","&Str$(Int(Len(Caption$)*4/5)+3)&","&Str$(32-(Int(Len(Caption$)*4/5)+8))&"/V "&Str$(Width)&",S/W:#FFFF77"
!
      #Case# -1*Sf_Protected # -1*Sf_Invisible # -1*Sf_Multiselect # -1*Sf_GridLines
         let Spec$(Index)=Str$(Index)&","&Str$(Int(Len(Caption$)*4/5)+3)&","&Str$(32-(Int(Len(Caption$)*4/5)+2))&"/CHECK "&Str$(Width)
!
      #Case Else#
         let Spec$(Index)=Str$(Index)&","&Str$(Int(Len(Caption$)*4/5)+3)&","&Str$(32-(Int(Len(Caption$)*4/5)+2))&"/V "&Str$(Width)&",S/W:#FFFF77"

         if ForceButton then
            let Spec$(Index)=Str$(Index)&","&Str$(Int(Len(Caption$)*4/5)+4)&","&Str$(30-(Int(Len(Caption$)*4/5)+2))&"/CC "&Str$(Width)&",/W:W,B"&Str$(1000+Index)
            let Buttons(Index)=1
         end if
!
      #End Select#
!
   fnend
!
OBJECTTOSCREEN: ! Put Object Data Into Input Data Based On Type
   def Fnobjecttoscreen(Control,Mat Oas_Subs,Mat Oas_Data$,Mat Oas_Spec$,[[Screencontrols]];___,Index)
      for Index=1 to Udim(Mat Oas_Subs)
         #Select# Oas_Subs(Index)   #Case# Sf_Controlname
            let Oas_Data$(Index)=Controlname$(Control)
!
         #Case# Sf_Fieldname
            let Oas_Data$(Index)=Fieldname$(Control)
!
         #Case# Sf_Description
            let Oas_Data$(Index)=Description$(Control)
!
         #Case# -1*Sf_Specwidth
            let Oas_Data$(Index)=Str$(Specwidth(Control))
!
         #Case# Sf_Truevalue
            let Oas_Data$(Index)=Truevalue$(Control)
!
         #Case# Sf_Falsevalue
            let Oas_Data$(Index)=Falsevalue$(Control)
!
         #Case# Sf_Function
            let Oas_Data$(Index)=Function$(Control)
!
         #Case# Sf_Picture
            let Oas_Data$(Index)=Picture$(Control)
!
         #Case# Sf_Fgcolor
            let Oas_Data$(Index)=Fgcolor$(Control)
            let Fnadjustspeccolor(Oas_Spec$(Index),Oas_Data$(Index))
!
         #Case# Sf_Bgcolor
            let Oas_Data$(Index)=Bgcolor$(Control)
            let Fnadjustspeccolor(Oas_Spec$(Index),Oas_Data$(Index))
!
         #Case# Sf_Justify
            let Oas_Data$(Index)="C"&Justify$(Control)
!
         #Case# Sf_Parent
            let Oas_Data$(Index)=Parent$(Control)
!
         #Case# Sf_Attr
            let Oas_Data$(Index)=Attr$(Control)
!
         #Case# -1*Sf_Protected
            if Protected(Control) then
               let Oas_Data$(Index)="^"
            else
               let Oas_Data$(Index)=""
            end if
!
         #Case# -1*Sf_Invisible
            if Invisible(Control) then
               let Oas_Data$(Index)="^"
            else
               let Oas_Data$(Index)=""
            end if
!
         #Case# Sf_Tooltip
            let Oas_Data$(Index)=Tooltip$(Control)
!
         #Case# Sf_Cnvrtin
            let Oas_Data$(Index)=Cnvrtin$(Control)
!
         #Case# Sf_Cnvrtout
            let Oas_Data$(Index)=Cnvrtout$(Control)
!
         #Case# -1*Sf_Multiselect
            if Multiselect(Control) then
               let Oas_Data$(Index)="^"
            else
               let Oas_Data$(Index)=""
            end if
!
         #Case# -1*Sf_GridLines
            if GridLines(Control) then
               let Oas_Data$(Index)="^"
            else
               let Oas_Data$(Index)=""
            end if

         #Case# Sf_Userdata
            let Oas_Data$(Index)=Userdata$(Control)
!
         #End Select#
      next Index
   fnend
!
SCREENTOOBJECT: !  Put Input Data Back In  The Objects
   def Fnscreentoobject(Control,Mat Oas_Subs,Mat Oas_Data$,[[Screencontrols]];___,Index,Tempwidth,Choice,Askedalready,Temp)
!
      for Index=1 to Udim(Mat Oas_Subs)
         #Select# Oas_Subs(Index)   #Case#    Sf_Controlname
            let Fnsavetoarray$(Control,Mat Controlname$,Srep$(Trim$(Oas_Data$(Index))," ","_"))
!
         #Case# Sf_Fieldname
            let Fnsavetoarray$(Control,Mat Fieldname$,Oas_Data$(Index))
!
         #Case# -1*Sf_Specwidth
            let Tempwidth=-999
            let Tempwidth = Val(Oas_Data$(Index)) conv IGNORE
            if Tempwidth>-999 then
               if Lwrc$(Trim$(Fieldtype$(Control)))="listview" then
                  let Temp=Tempwidth
               else
                  let Temp=Max(Tempwidth,1)
               end if
               let Fnsavetoarray(Control,Mat Specwidth,Temp)
            end if
!
         #Case# Sf_Description
            let Fnsavetoarray$(Control,Mat Description$,Oas_Data$(Index))
!
         #Case# Sf_Truevalue
            let Fnsavetoarray$(Control,Mat Truevalue$,Oas_Data$(Index))
!
         #Case# Sf_Falsevalue
            let Fnsavetoarray$(Control,Mat Falsevalue$,Oas_Data$(Index))
!
         #Case# Sf_Function
            let Fnsavetoarray$(Control,Mat Function$,Oas_Data$(Index))
!
         #Case# Sf_Picture
            if lwrc$(trim$(fieldType$(Control)))="filter" then
               fnCleanFilter(Oas_Data$(Index))
            end if
            let Fnsavetoarray$(Control,Mat Picture$,Oas_Data$(Index))
!
         #Case# Sf_Fgcolor
            if Trim$(Oas_Data$(Index))="" or Fnvalidhexcolor(Oas_Data$(Index)) then
               let Fnsavetoarray$(Control,Mat Fgcolor$,Oas_Data$(Index))
            end if
!
         #Case# Sf_Bgcolor
            if trim$(oas_data$(Index))="" or Fnvalidhexcolor(Oas_Data$(Index)) then
               let Fnsavetoarray$(Control,Mat Bgcolor$,Oas_Data$(Index))
            end if
!
         #Case# Sf_Justify
            if Fnvalidjustify(Oas_Data$(Index)) then
               let Fnsavetoarray$(Control,Mat Justify$,Trim$(Oas_Data$(Index)(2:2)))
            end if
!
         #Case# Sf_Parent
            if Fnfindtarget(Oas_Data$(Index),[[Screencontrols]]) then
               let Fnsavetoarray$(Control,Mat Parent$,Oas_Data$(Index))
            end if
!
         #Case# Sf_Attr
            let Fnsavetoarray$(Control,Mat Attr$,Oas_Data$(Index))
!
         #Case# -1*Sf_Protected
            if Oas_Data$(Index)(1:1)="^" then
               let Temp=1
            else
               let Temp=0
            end if
            let Fnsavetoarray(Control,Mat Protected,Temp)
!
         #Case# -1*Sf_Invisible
            if Oas_Data$(Index)(1:1)="^" then
               let Temp=1
            else
               let Temp=0
            end if
            let Fnsavetoarray(Control,Mat Invisible,Temp)
!
         #Case# Sf_Tooltip
            let Fnsavetoarray$(Control,Mat Tooltip$,Oas_Data$(Index))
!
         #Case# Sf_Cnvrtin
            let Oas_Data$(Index)=fnFixDateSpec$(Oas_Data$(Index))
            let Fnsavetoarray$(Control,Mat Cnvrtin$,Oas_Data$(Index))
!
         #Case# Sf_Cnvrtout
            let Oas_Data$(Index)=fnFixDateSpec$(Oas_Data$(Index))
            let Fnsavetoarray$(Control,Mat Cnvrtout$,Oas_Data$(Index))
!
         #Case# -1*Sf_Multiselect
            if Oas_Data$(Index)(1:1)="^" then let Temp=1 else let Temp=0
            let Fnsavetoarray(Control,Mat Multiselect,Temp)
!
         #Case# -1*Sf_GridLines
            if Oas_Data$(Index)(1:1)="^" then let Temp=1 else let Temp=0
            let Fnsavetoarray(Control,Mat GridLines,Temp)

         #Case# Sf_Userdata
            let Fnsavetoarray$(Control,Mat Userdata$,Oas_Data$(Index))
!
         #End Select#
      next Index
   fnend

   def fnFixDateSpec$*255(DateSpec$*255;___,P)
      let P=pos(uprc$(DateSpec$),"DATE$(")
      if P>0 then
         let DateSpec$(P+4:P+5)="(" ! Remove $ if its there after a date$ thing
      end if
      let fnFixDateSpec$=DateSpec$
   fnend
!
   def Fnsavetoarray$(Control,Mat Array$,Value$*1000;___,Index)
      if Trim$(Value$)<>Trim$(Array$(Control)) then
         let Array$(Control)=Value$
         if Udim(Mat Selectedcontrols)>=Control And Selectedcontrols(Control) then
            if ~Askedalready then
               let Choice=Msgbox("Would you like to copy the changes to all selected controls?","Change Many?","yN","QST")
               let Askedalready=1
            end if
            if Choice=2 then
               for Index=1 to Udim(Mat Selectedcontrols)
                  if Selectedcontrols(Index) then
                     let Array$(Index)=Value$
                  end if
               next Index
            end if
         end if
      end if
   fnend
   def Fnsavetoarray(Control,Mat Array,Value;___,Index)
      if Value<>Array(Control) then
         let Array(Control)=Value
         if Udim(Mat Selectedcontrols)>=Control And Selectedcontrols(Control) then
            if ~Askedalready then
               let Choice=Msgbox("Would you like to copy the changes to all selected controls?","Change Many?","yN","QST")
               let Askedalready=1
            end if
            if Choice=2 then
               for Index=1 to Udim(Mat Selectedcontrols)
                  if Selectedcontrols(Index) then
                     let Array(Index)=Value
                  end if
               next Index
            end if
         end if
      end if
   fnend
!
   dim Justifyoptions$(1)
VALIDJUSTIFY: ! Validates The Justification Selection
   def Fnvalidjustify(Justify$)
      if Srch(Mat Justifyoptions$,Trim$(Justify$))>0 then let Fnvalidjustify=1
   fnend
!
FINDTARGET: !
   def Fnfindtarget(Parent$,[[Screencontrols]];___,Index)
      for Index=1 to Udim(Mat Fieldtype$)
         if Fieldtype$(Index)="LISTVIEW" And Parent$(Index)=Parent$ then
            let Fnfindtarget=Index
         end if
      next Index
   fnend
!
POPULATEJUSTIFY: ! Populate The Justification Textbox
   def Fnpopulatejustify(Spec$*40,Window)
      mat Justifyoptions$(5)
      let Justifyoptions$(1)="C" !:
      let Justifyoptions$(2)="CC" !:
      let Justifyoptions$(3)="CR" !:
      let Justifyoptions$(4)="CU" !:
      let Justifyoptions$(5)="CL"
!
      print #Window, fields Spec$(1:Pos(Spec$,",",-1))&"=" : Mat Justifyoptions$
   fnend

   def fnFixAllChildScreenSize(mat ScreenIO$,mat ScreenIO,[[ScreenControls]];___,Index)
      for Index=1 to udim(mat FieldType$)
         #Select# lwrc$(trim$(FieldType$(Index))) #Case# "screen"
            let fnReadChildScreenSize(Index,mat ScreenIO$,mat ScreenIO,[[ScreenControls]])
         #End Select#
      next Index
   fnend

   def fnReadChildScreenSize(Index,mat ScreenIO$,mat ScreenIO,[[ScreenControls]];___,BorderSize,ScreenAttr$*255)
      Let Width(Index)=Fnreadunopenednumber("screenio",trim$(FieldName$(Index)),Si_Hsize)
      Let Height(Index)=Fnreadunopenednumber("screenio",trim$(FieldName$(Index)),Si_VSize)
      let Gridlines(Index)=fnReadUnopenedNumber("screenio",trim$(FieldName$(Index)),Si_Border)
      let ScreenAttr$=fnReadUnopenedDescription$("screenio",trim$(FieldName$(Index)),Si_Attributes)

      if pos(lwrc$(trim$(ScreenAttr$)),"border") then let GridLines(Index)=1

      if GridLines(Index) then let BorderSize=2

      if Width(Index)+BorderSize>ScreenIO(si_HSize) then let ScreenIO(si_HSize)=Width(Index)+BorderSize
      if Height(Index)+BorderSize>ScreenIO(si_VSize) then let ScreenIO(si_VSize)=Height(Index)+BorderSize
      let VPosition(Index)=min(VPosition(Index),ScreenIO(si_vsize)-Height(Index)+1-(BorderSize/2))
      let HPosition(Index)=min(HPosition(Index),ScreenIO(si_hsize)-Width(Index)+1-(BorderSize/2))
   fnend
!
! #Autonumber# 35000,1
! =============================== File Read/Write ===========================
! = This Next Section And These Variables Are All For File Reads And Writes =
! ===========================================================================
   dim Screenfld$(1)*1000, Screenfld(1), Tempscreenfld$(1)*1000, Tempscreenfld(1), Tempscreenio$(1)*255, Tempscreenio(1), Fscreenio, Fscreenfld, Static_Screenname$
READSCREEN: ! Read The Screen And Populate The Given Arrays
   def Fnreadscreen(Screenname$,Mat Screenio$, Mat Screenio, [[Screencontrols]];SkipPreserve,___, Index)
      let Screenname$=Uprc$(Trim$(Screenname$))
      if Trim$(Screenname$)="" then
!
         mat Screenio$=("") : mat Screenio=(0)
         let Fnresizecontrolarrays(0, [[Screencontrols]])
!
         let Screenio(Si_Vsize)=24
         let Screenio(Si_Hsize)=80
!
         let Control=0
!
         let Fnreadscreen=1 ! New Screen Initialized
         let Static_Screenname$=Screenname$
         let Fnpreservescreenarrays(Mat Screenio$,Mat Screenio,[[Screencontrols]])
      else
! .   ! Load Screen
         read #Fscreenio, using Form$(Fscreenio), key=Fnkey$(Fscreenio,Screenname$), release: Mat Screenio$, Mat Screenio nokey IGNORE
         if File(Fscreenio)=0 then
!
            restore #Fscreenfld, key=Fnkey$(Fscreenfld,Screenname$): nokey IGNORE
!
            let Fnresizecontrolarrays(0, [[Screencontrols]])
!
            do While File(Fscreenfld)=0
               read #Fscreenfld, using Form$(Fscreenfld), release: Mat Screenfld$, Mat Screenfld eof IGNORE
!
               if File(Fscreenfld)=0 And Trim$(Screenfld$(Sf_Screencode))=Trim$(Screenname$) then
                  let Index=Udim(Mat Controlname$)+1
                  let Fnresizecontrolarrays(Index, [[Screencontrols]])
!
                  let Controlname$(Index)=Screenfld$(Sf_Controlname) !:
                  let Fieldname$(Index)=Screenfld$(Sf_Fieldname) !:
                  let Description$(Index)=Screenfld$(Sf_Description) !:
                  let Vposition(Index)=Screenfld(Sf_Vposition) !:
                  let Hposition(Index)=Screenfld(Sf_Hposition) !:
                  let Fieldtype$(Index)=Screenfld$(Sf_Fieldtype) !:
                  let Specwidth(Index)=Screenfld(Sf_Specwidth) !:
                  let Width(Index)=Screenfld(Sf_Width) !:
                  let Height(Index)=Screenfld(Sf_Height) !:
                  let Truevalue$(Index)=Screenfld$(Sf_Truevalue) !:
                  let Falsevalue$(Index)=Screenfld$(Sf_Falsevalue) !:
                  let Function$(Index)=Screenfld$(Sf_Function) !:
                  let Picture$(Index)=Screenfld$(Sf_Picture)
                  let Parent$(Index)=Screenfld$(Sf_Parent) !:
                  let Fgcolor$(Index)=Screenfld$(Sf_Fgcolor) !:
                  let Bgcolor$(Index)=Screenfld$(Sf_Bgcolor) !:
                  let Justify$(Index)=Screenfld$(Sf_Justify) !:
                  let Attr$(Index)=Screenfld$(Sf_Attr) !:
                  let Protected(Index)=Screenfld(Sf_Protected) !:
                  let Invisible(Index)=Screenfld(Sf_Invisible) !:
                  let Tooltip$(Index)=Screenfld$(Sf_Tooltip) !:
                  let Cnvrtin$(Index)=Screenfld$(Sf_Cnvrtin) !:
                  let Cnvrtout$(Index)=Screenfld$(Sf_Cnvrtout) !:
                  let Multiselect(Index)=Screenfld(Sf_Multiselect) !:
                  let GridLines(Index)=Screenfld(Sf_GridLines) !:
                  let Userdata$(Index)=Screenfld$(Sf_Userdata)
               end if
            loop While Trim$(Screenfld$(Sf_Screencode))=Trim$(Screenname$)
            let Fnreadscreen=1 !  Screen Read Successful
            if ~SkipPreserve then
               let Static_Screenname$=Screenname$
               let Fnpreservescreenarrays(Mat Screenio$,Mat Screenio,[[Screencontrols]])
            end if
            let fnFixAllChildScreenSize(mat ScreenIO$,mat ScreenIO,[[ScreenControls]])
         else
            let Fnreadscreen=0 !  Screen Not Found
         end if
      end if
   fnend
!
   def fnLaunchScreen(ScreenCode$;Number,___,Filenumber,DesignerPath$)
      ! Build a proc to run the screen
      open #(Filenumber:=Fngetfilenumber): "name=launch"&session$&str$(Number)&".$$$, replace", display, output
      print #Filenumber: "proc noecho"
      if exists(srep$(setting_ScreenIOPath$&".br","screenio.br","design.br")) then
         print #Filenumber: "load "&srep$(setting_ScreenIOPath$&".br","screenio.br","design")
      else
         print #Filenumber: "load "&setting_ScreenIOPath$
      end if
      print #Filenumber: "5 let fnAutoCallScreen("""&ScreenCode$&""")"
      print #Filenumber: "6 execute ""system"""
      print #Filenumber: "run"
      close #Filenumber:

      execute "system -C -M "&Fngetbrexe$&" -"&Fngetwbcfg$&" proc launch"&session$&str$(Number)&".$$$"
   fnend

WRITESCREEN: !  Write The Results To Disk
   def Fnwritescreen(Mat Screenio$, Mat Screenio, [[Screencontrols]];WaitForComplete,___,Index,Writeerror,BackupFile)
!
      if Len(Trim$(Screenio$(Si_Screencode)))>0 then
         let ScreenIO(si_version)+=1
         let fnWriteBackup(mat ScreenIO$,mat ScreenIO, [[ScreenControls]])

         let Screenio(Si_Modifydate)=Days(Date$("mm/dd/ccyy"),"mm/dd/ccyy")
         let Screenio$(Si_ModifyUser)=Login_name$
         if (Trim$(Static_Screenname$)<>Trim$(Screenio$(Si_Screencode))) then
            restore #Fscreenio, key=Fnkey$(Fscreenio,Screenio$(Si_Screencode)): nokey IGNORE
            if File(Fscreenio)<>0 then
               let Screenio(Si_Createdate)=Days(Date$("mm/dd/ccyy"),"mm/dd/ccyy")
               let Screenio$(Si_CreateUser)=Login_name$
               write #Fscreenio, using Form$(Fscreenio) : Mat Screenio$, Mat Screenio
               let Writeerror=0
            else
               let Choice=Msgbox(Trim$(Screenio$(Si_Screencode))&" already exists. Do you wish to overwrite it?","Confirm overwrite","yN","QST")
               if Choice=2 then ! 2 Is Yes
                  rewrite #Fscreenio, using Form$(Fscreenio),key=Fnkey$(Fscreenio,Screenio$(Si_Screencode)) : Mat Screenio$, Mat Screenio
                  ! let Fndeleteallfields(Screenio$(Si_Screencode))
                  let Writeerror=0
               else
                  let Writeerror=1
               end if
            end if
         else
            restore #Fscreenio, key=Fnkey$(Fscreenio,Screenio$(Si_Screencode)): nokey IGNORE
            if File(Fscreenio)=0 then
               rewrite #Fscreenio, using Form$(Fscreenio), key=Fnkey$(Fscreenio,Screenio$(Si_Screencode)) : Mat Screenio$, Mat Screenio
               ! let Fndeleteallfields(Screenio$(Si_Screencode))
               let Writeerror=0
            else ! Record Must Have Been Deleted By An Outside Process
               write #Fscreenio, using Form$(Fscreenio) : Mat Screenio$, Mat Screenio
               ! let Fndeleteallfields(Screenio$(Si_Screencode))
               let Writeerror=0
            end if
         end if

         if ~Writeerror then
            ! Restore ScreenFld file to first one for that screen.
            mat ScreenFld$=("") : mat ScreenFld=(0)
            let ScreenFld$(sf_screencode)=ScreenIO$(si_ScreenCode)
            restore #fScreenfld, key=fnBuildKey$("screenfld", mat ScreenFld$, mat Screenfld) : nokey Ignore
            let Index=0
            ! Loop through and update all the records that are there first.
            do until Index>=udim(mat ControlName$) or file(fScreenFld)
               read #fScreenFld, using form$(fScreenFld) : mat ScreenFld$, mat ScreenFld eof Ignore
               if file(fScreenFld)=0 and ScreenFld$(sf_ScreenCode)=ScreenIO$(si_ScreenCode) then
                  ! Each entry of the loop, if the read screenflds matches this screen, update the record.
                  let Index+=1
                  let fnBuildScreenFld(ScreenIO$(si_ScreenCode),mat ScreenFld$,mat ScreenFld,Index,[[ScreenControls]])
                  rewrite #fScreenFld, using form$(fScreenFld) : mat ScreenFld$, mat ScreenFld
               end if
            loop while ScreenFld$(sf_ScreenCode)=ScreenIO$(si_ScreenCode)

            ! Go through the file and delete any extras.
            do while file(fScreenFld)=0 and ScreenFld$(sf_ScreenCode)=ScreenIO$(si_ScreenCode)
               read #fScreenFld, using form$(fScreenFld) : mat ScreenFld$, mat ScreenFld eof Ignore
               if file(fScreenFld)=0 and ScreenFld$(sf_ScreenCode)=ScreenIO$(si_ScreenCode) then
                  delete #fScreenFld:
               end if
            loop

            ! Now save the rest
            for Index=Index+1 to Udim(Mat Controlname$)
               let fnBuildScreenFld(ScreenIO$(si_ScreenCode),mat ScreenFld$,mat ScreenFld,Index,[[ScreenControls]])
               write #Fscreenfld, using Form$(Fscreenfld) : Mat Screenfld$, Mat Screenfld
            next Index

            ! Break any locks
            restore #fScreenFld, release:

            let Fncompilehelperlibrary(Mat Screenio$,Mat Screenio,[[Screencontrols]],"",WaitForComplete)
!
            let Static_Screenname$=Screenio$(Si_Screencode)
            let Fnpreservescreenarrays(Mat Screenio$,Mat Screenio,[[Screencontrols]])
         end if
      else
         let Msgbox("Window Name cannot be blank when saving screen.","Error","OK","ERR")
         let Writeerror=1 !  No Screen Name Passed In
      end if
!
      let Fnwritescreen=~Writeerror
   fnend

   def fnBuildScreenFld(ScreenCode$*64,mat ScreenFld$,mat ScreenFld,Index,[[ScreenControls]])
      let Screenfld$(Sf_Screencode) = Screenio$(Si_Screencode) !:
      let Screenfld$(Sf_Controlname) = Controlname$(Index) !:
      let Screenfld$(Sf_Fieldname) = Fieldname$(Index) !:
      let Screenfld$(Sf_Description) = Description$(Index) !:
      let Screenfld(Sf_Vposition) = Vposition(Index) !:
      let Screenfld(Sf_Hposition) = Hposition(Index) !:
      let Screenfld$(Sf_Fieldtype) = Fieldtype$(Index) !:
      let Screenfld(Sf_Specwidth) = Specwidth(Index) !:
      let Screenfld(Sf_Width) = Width(Index) !:
      let Screenfld(Sf_Height) = Height(Index) !:
      let Screenfld$(Sf_Truevalue) = Truevalue$(Index) !:
      let Screenfld$(Sf_Falsevalue) = Falsevalue$(Index) !:
      let Screenfld$(Sf_Function) = Function$(Index)
      let Screenfld$(Sf_Picture) = Picture$(Index) !:
      let Screenfld$(Sf_Parent) = Parent$(Index) !:
      let Screenfld$(Sf_Fgcolor) = Fgcolor$(Index) !:
      let Screenfld$(Sf_Bgcolor) = Bgcolor$(Index) !:
      let Screenfld$(Sf_Justify) = Justify$(Index) !:
      let Screenfld$(Sf_Attr) = Attr$(Index) !:
      let Screenfld(Sf_Protected) = Protected(Index) !:
      let Screenfld(Sf_Invisible) = Invisible(Index) !:
      let Screenfld$(Sf_Tooltip) = Tooltip$(Index) !:
      let Screenfld$(Sf_Cnvrtin) = Cnvrtin$(Index) !:
      let Screenfld$(Sf_Cnvrtout) = Cnvrtout$(Index) !:
      let Screenfld(Sf_Multiselect) = Multiselect(Index) !:
      let Screenfld(Sf_GridLines) = GridLines(Index) !:
      let Screenfld$(Sf_Userdata) = Userdata$(Index)
   fnend
!
CLOSESCREENFILES: !  Closes The Screen Files If They Are Open
   def Fnclosescreenfiles
      if Fscreenio<>0 And File(Fscreenio)<>-1 then
         let Fnclosefile(Fscreenio,"screenio","",1)
      end if
      if Fscreenfld<>0 And File(Fscreenfld)<>-1 then
         let Fnclosefile(Fscreenfld,"screenfld","",1)
      end if
   fnend
!
OPENSCREENFILES: ! Open The Screen Files If They Aren't open yet
   def Fnopenscreenfiles(Mat Screenio$,Mat Screenio)
      if Fscreenio=0 Or File(Fscreenio)=-1 then
         let Fscreenio=Fnopen("screenio",Mat Screenio$, Mat Screenio, Mat Form$)
         mat Tempscreenio$(Udim(Mat Screenio$))
         mat Tempscreenio(Udim(Mat Screenio))
      end if
      if Fscreenfld=0 Or File(Fscreenfld)=-1 then
         let Fscreenfld=Fnopen("screenfld",Mat Screenfld$, Mat Screenfld, Mat Form$)
         mat Tempscreenfld$(Udim(Mat Screenfld$))
         mat Tempscreenfld(Udim(Mat Screenfld))
      end if
   fnend
!
DELETESCREEN: ! Deletes The Given Screen
   def Fndeletescreen(Screencode$)
      delete #Fscreenio, key=Fnkey$(Fscreenio,Screencode$): nokey IGNORE
      let Fndeleteallfields(Screencode$)
   fnend
!
READALLSCREENCODES: ! Read All The Screen Codes From The Screenio File
   def Fnreadallscreencodes(Mat List$,Mat Create,Mat Modify,Mat Vers,mat CreateUser$,mat ModifyUser$,mat Project$,mat Notes$)
      restore #Fscreenio:
      mat List$(0) !:
      mat Create(0) !:
      mat Modify(0) !:
      mat Vers(0) !:
      mat CreateUser$(0) !:
      mat ModifyUser$(0) !:
      mat Project$(0) !:
      mat Notes$(0)
      do While File(Fscreenio)=0
         read #Fscreenio, using Form$(Fscreenio), release: Mat Tempscreenio$, Mat Tempscreenio eof IGNORE
         if File(Fscreenio)=0 then
            mat List$(Udim(Mat List$)+1) !:
            mat Create(Udim(Mat List$)) !:
            mat Modify(Udim(Mat List$)) !:
            mat Vers(udim(mat List$)) !:
            mat CreateUser$(udim(mat list$)) !:
            mat ModifyUser$(udim(mat List$)) !:
            mat Project$(udim(mat List$)) !:
            mat Notes$(udim(mat List$))
            let List$(Udim(Mat List$))=Tempscreenio$(Si_Screencode) !:
            let Create(Udim(Mat List$))=Tempscreenio(Si_Createdate) !:
            let Modify(Udim(Mat List$))=Tempscreenio(Si_Modifydate) !:
            let Vers(udim(mat List$))=TempScreenIO(si_Version) !:
            let CreateUser$(udim(Mat List$))=TempScreenIO$(Si_CreateUser) !:
            let ModifyUser$(udim(mat List$))=TempScreenIO$(si_ModifyUser) !:
            let Project$(udim(mat List$))=TempScreenIO$(si_project) !:
            let Notes$(udim(mat List$))=TempScreenIO$(si_notes)
         end if
      loop
   fnend
!
DELETEALLFIELDS: ! Delete All  The Controls For The Associated Screen So They Can Be Resaved
   def Fndeleteallfields(Screenname$)
      restore #Fscreenfld,key=Fnkey$(Fscreenfld,Screenname$): nokey IGNORE
      do While File(Fscreenfld)=0
         read #Fscreenfld, using Form$(Fscreenfld) : Mat Tempscreenfld$, Mat Tempscreenfld eof IGNORE
         if File(Fscreenfld)=0 And Trim$(Tempscreenfld$(Sf_Screencode))=Trim$(Screenname$) then
            delete #Fscreenfld:
         end if
      loop While Trim$(Tempscreenfld$(Sf_Screencode))=Trim$(Screenname$)
   fnend
!
RESIZECONTROLARRAYS: !  Resize The Given Arrays  To The Given Size
   def Fnresizecontrolarrays(Newsize, [[Screencontrols]])
      mat Controlname$(Newsize) !:
      mat Fieldname$(Newsize) !:
      mat Description$(Newsize) !:
      mat Vposition(Newsize) !:
      mat Hposition(Newsize) !:
      mat Fieldtype$(Newsize) !:
      mat Specwidth(Newsize) !:
      mat Width(Newsize) !:
      mat Height(Newsize) !:
      mat Truevalue$(Newsize) !:
      mat Falsevalue$(Newsize) !:
      mat Function$(Newsize) !:
      mat Picture$(Newsize)
      mat Parent$(Newsize) !:
      mat Fgcolor$(Newsize) !:
      mat Bgcolor$(Newsize) !:
      mat Justify$(Newsize) !:
      mat Attr$(Newsize) !:
      mat Protected(Newsize) !:
      mat Invisible(Newsize) !:
      mat Tooltip$(Newsize) !:
      mat Cnvrtin$(Newsize) !:
      mat Cnvrtout$(Newsize) !:
      mat Multiselect(Newsize) !:
      mat GridLines(NewSize) !:
      mat Userdata$(Newsize)
   fnend
!
COPYCONTROLARRAYS: ! Copies All The Values From One Control To Another
   def Fncopycontrolarrays(To,From,[[Screencontrols]])
      let Controlname$(To)=Controlname$(From) !:
      let Fieldname$(To)=Fieldname$(From) !:
      let Description$(To)=Description$(From) !:
      let Vposition(To)=Vposition(From) !:
      let Hposition(To)=Hposition(From) !:
      let Fieldtype$(To)=Fieldtype$(From) !:
      let Specwidth(To)=Specwidth(From) !:
      let Width(To)=Width(From) !:
      let Height(To)=Height(From) !:
      let Truevalue$(To)=Truevalue$(From) !:
      let Falsevalue$(To)=Falsevalue$(From) !:
      let Function$(To)=Function$(From) !:
      let Picture$(To)=Picture$(From)
      let Parent$(To)=Parent$(From) !:
      let Fgcolor$(To)=Fgcolor$(From) !:
      let Bgcolor$(To)=Bgcolor$(From) !:
      let Justify$(To)=Justify$(From) !:
      let Attr$(To)=Attr$(From) !:
      let Protected(To)=Protected(From) !:
      let Invisible(To)=Invisible(From) !:
      let Tooltip$(To)=Tooltip$(From) !:
      let Cnvrtin$(To)=Cnvrtin$(From) !:
      let Cnvrtout$(To)=Cnvrtout$(From) !:
      let Multiselect(To)=Multiselect(From) !:
      let GridLines(To)=GridLines(From) !:
      let Userdata$(To)=Userdata$(From)
   fnend
!
SWAPCONTROLARRAYS: ! Swaps Two Control Arrays
   def Fnswapcontrolarrays(To,From,[[Screencontrols]];___,Controlname$*50,Fieldname$*50,Description$*255,Vposition,Hposition,Fieldtype$,Specwidth,Width,Height,Truevalue$*60,Falsevalue$*60,Function$*255,Picture$*255,Parent$*20,Fgcolor$,Bgcolor$,Protected,Invisible,Tooltip$*255,Cnvrtin$*255,Cnvrtout$*255,Multiselect,Userdata$*255,GridLines,Justify$,Attr$*255)
      let Controlname$=Controlname$(To) !:
      let Fieldname$=Fieldname$(To) !:
      let Description$=Description$(To) !:
      let Vposition=Vposition(To) !:
      let Hposition=Hposition(To) !:
      let Fieldtype$=Fieldtype$(To) !:
      let Specwidth=Specwidth(To) !:
      let Width=Width(To) !:
      let Height=Height(To) !:
      let Truevalue$=Truevalue$(To) !:
      let Falsevalue$=Falsevalue$(To) !:
      let Function$=Function$(To) !:
      let Picture$=Picture$(To)
      let Parent$=Parent$(To) !:
      let Fgcolor$=Fgcolor$(To) !:
      let Bgcolor$=Bgcolor$(To) !:
      let Justify$=Justify$(To) !:
      let Attr$=Attr$(To) !:
      let Protected=Protected(To) !:
      let Invisible=Invisible(To) !:
      let Tooltip$=Tooltip$(To) !:
      let Cnvrtin$=Cnvrtin$(To) !:
      let Cnvrtout$=Cnvrtout$(To) !:
      let Multiselect=Multiselect(To) !:
      let GridLines=GridLines(To) !:
      let Userdata$=Userdata$(To)
!
      let Controlname$(To)=Controlname$(From) !:
      let Fieldname$(To)=Fieldname$(From) !:
      let Description$(To)=Description$(From) !:
      let Vposition(To)=Vposition(From) !:
      let Hposition(To)=Hposition(From) !:
      let Fieldtype$(To)=Fieldtype$(From) !:
      let Specwidth(To)=Specwidth(From) !:
      let Width(To)=Width(From) !:
      let Height(To)=Height(From) !:
      let Truevalue$(To)=Truevalue$(From) !:
      let Falsevalue$(To)=Falsevalue$(From) !:
      let Function$(To)=Function$(From) !:
      let Picture$(To)=Picture$(From) !:
      let Parent$(To)=Parent$(From)
      let Fgcolor$(To)=Fgcolor$(From) !:
      let Bgcolor$(To)=Bgcolor$(From) !:
      let Justify$(To)=Justify$(From) !:
      let Attr$(To)=Attr$(From) !:
      let Protected(To)=Protected(From) !:
      let Invisible(To)=Invisible(From) !:
      let Tooltip$(To)=Tooltip$(From) !:
      let Cnvrtin$(To)=Cnvrtin$(From) !:
      let Cnvrtout$(To)=Cnvrtout$(From) !:
      let Multiselect(To)=Multiselect(From) !:
      let GridLines(To)=GridLines(From) !:
      let Userdata$(To)=Userdata$(From)
!
      let Controlname$(From)=Controlname$ !:
      let Fieldname$(From)=Fieldname$ !:
      let Description$(From)=Description$ !:
      let Vposition(From)=Vposition !:
      let Hposition(From)=Hposition !:
      let Fieldtype$(From)=Fieldtype$ !:
      let Specwidth(From)=Specwidth !:
      let Width(From)=Width !:
      let Height(From)=Height !:
      let Truevalue$(From)=Truevalue$ !:
      let Falsevalue$(From)=Falsevalue$ !:
      let Function$(From)=Function$ !:
      let Picture$(From)=Picture$ !:
      let Parent$(From)=Parent$
      let Fgcolor$(From)=Fgcolor$ !:
      let Bgcolor$(From)=Bgcolor$ !:
      let Justify$(From)=Justify$ !:
      let Attr$(From)=Attr$ !:
      let Protected(From)=Protected !:
      let Invisible(From)=Invisible !:
      let Tooltip$(From)=Tooltip$ !:
      let Cnvrtin$(From)=Cnvrtin$ !:
      let Cnvrtout$(From)=Cnvrtout$ !:
      let Multiselect(From)=Multiselect !:
      let GridLines(From)=GridLines !:
      let Userdata$(From)=Userdata$
   fnend
!
EXPORTSCREEN: ! Exports The Screen To A User Selected File
   def Fnexportscreen(Mat Screenio$,Mat Screenio,[[Screencontrols]];___,Fexportfile,Index,Csopenstring$)
      open #(Fexportfile:=Fngetfilenumber): "name=save:"&Csopenstring$&"*.sio,new,recl="&Str$(Max(Rln(Fscreenio),Rln(Fscreenfld))),internal,output,sequential error IGNORE
      if File(Fexportfile)=0 then
         let fnWriteExport(fExportFile,mat ScreenIO$,mat ScreenIO,[[ScreenControls]])

         close #Fexportfile:
         let Fnexportscreen=1
      end if
   fnend

   def fnWriteBackup(mat ScreenIO$,mat ScreenIO,[[ScreenControls]];___,FileName$*255,Index)
      if ~exists("screen\backup") then
         execute "mkdir screen\backup" error Ignore
      end if

      let Filename$=uprc$(trim$(ScreenIO$(si_screencode)))
      let Index=0
      do while (Index+=1)<=len(Filename$)
         if ~pos("ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",FileName$(Index:Index)) then
            let FileName$(Index:Index)=""
            Index-=1
         end if
      loop

      open #(Backupfile:=fnGetFileNumber): "name=screen\backup\"&lwrc$(Filename$)&".sio,replace,recl="&Str$(Max(Rln(Fscreenio),Rln(Fscreenfld))),internal,output,sequential error IGNORE
      if File(Backupfile)=0 then
         let fnWriteExport(Backupfile,mat ScreenIO$,mat ScreenIO,[[ScreenControls]])
         close #Backupfile: error Ignore
         let fnWriteBackup=1
      end if
   fnend

   def fnWriteExport(Fexportfile,Mat Screenio$,Mat Screenio,[[Screencontrols]];___,TargetVersion,Index)
      ! Record Version of Save
      let TargetVersion=version(fScreenIO)+version(fscreenfld)
      let Version(FExportFile,TargetVersion)

      write #Fexportfile, using Form$(Fscreenio) : Mat Screenio$, Mat Screenio
      for Index=1 to Udim(Mat Controlname$)
         let fnBuildScreenFld(ScreenIO$(si_ScreenCode),mat ScreenFld$,mat ScreenFld,Index,[[ScreenControls]])
         write #Fexportfile, using Form$(Fscreenfld) : Mat Screenfld$, Mat Screenfld
      next Index
   fnend

   dim FIO$(1)*1023,FIO(1),MapS(1),MapN(1)

   def fnImportRecordVersion(F,mat T$,mat T;Details)
      let fnSetImportDetails(F,mat FIO$,mat FIO,mat MapS,mat MapN,mat T$,mat T,mat Form$,Details)

      read #F, using form$(F) : mat FIO$,mat FIO error Ignore
      if file(F)=0 then
         let fnApplyMapping(mat FIO$,mat FIO,mat T$,mat T,mat MapS,mat MapN)
         let fnImportRecordVersion=1
      end if
   fnend

   def fnApplyMapping(Mat F$,mat F,mat T$,mat T,mat MS,mat MN;___,Index)
      for Index=1 to udim(mat F$)
         if MS(Index)>0 then
            let T$(MS(Index))=F$(Index)
         end if
      next Index
      for Index=1 to udim(mat F)
         if MN(Index)>0 then
            let T(MN(Index))=F(Index)
         end if
      next Index
   fnend

   def fnSetImportDetails(F,mat F$,mat F,mat MapS,mat MapN,mat T$,mat T,mat Form$;Details,___,Index)

      if Version(F)=Version(FSCreenFld)+Version(FScreenIO) then
         ! Current Version - just take it all from ScreenIO and ScreenFlds
         mat F$(udim(mat T$))
         mat F(udim(mat T))

         mat MapS(udim(mat F$))
         mat MapN(udim(mat F))

         ! Current Version. Just set 1:1 mapping here.
         for Index=1 to udim(mat MapS)
            let MapS(Index)=Index
         next Index
         for Index=1 to udim(mat MapN)
            let MapN(Index)=Index
         next Index

         mat Form$(max(udim(mat Form$),F)) ! Make room in forms array
         if ~Details then
            let Form$(F)=Form$(FScreenIO)
         else
            let Form$(F)=Form$(FScreenFLD)
         end if
      else
         if ~Details then
            ! ScreenIO File Versions
            #Select# Version(F) #Case# 35
               ! Version 35, current as of 5/5/2019
               ! Header - ScreenIO Record
               mat F$(37) : mat F(12)

               mat MapS(udim(mat F$))
               mat MapN(udim(mat F))

               mat Form$(max(udim(mat Form$),F)) ! Make room in forms array
               let Form$(F)="form V 18,V 60,POS 82,V 255,V 60,2*C 6,V 18,13*V 255,POS 3743,V 80,POS 3825,V 255,POS 4086,2*V 30,POS 4148,V 64,2*V 255,POS 4725,5*V 255,POS 6002,5*V 255,POS 79,B 1,BH 2,POS 3742,B 1,POS 3823,BH 2,POS 4080,2*BH 3,POS 4146,2*B 1,POS 4722,BH 3,POS 6000,2*B 1,POS 7277,BH 4"
               let Form$(F)=cform$(form$(F))

               let MapS(1)=si_SCREENCODE !:
               let MapS(2)=si_CAPTION !:
               let MapS(3)=si_ATTRIBUTES !:
               let MapS(4)=si_PICTURE !:
               let MapS(5)=si_FGCOLOR !:
               let MapS(6)=si_BGCOLOR !:
               let MapS(7)=si_FILELAY !:
               let MapS(8)=si_ENTERFN !:
               let MapS(9)=si_INITFN !:
               let MapS(10)=si_READFN !:
               let MapS(11)=si_LOADFN !:
               let MapS(12)=si_WRITEFN !:
               let MapS(13)=si_WAITFN
               let MapS(14)=si_LOCKEDFN !:
               let MapS(15)=si_MERGEFN !:
               let MapS(16)=si_LOOPFN !:
               let MapS(17)=si_NOKEYFN !:
               let MapS(18)=si_PRELISTVIEWFN !:
               let MapS(19)=si_POSTLISTVIEWFN !:
               let MapS(20)=si_EXITFN !:
               let MapS(21)=si_WINDCAP !:
               let MapS(22)=si_INPUTATTR !:
               let MapS(23)=si_CREATEUSER !:
               let MapS(24)=si_MODIFYUSER !:
               let MapS(25)=si_DEBUGSCREEN !:
               let MapS(26)=si_DEBUGKEY
               let MapS(27)=si_DEBUGPARENTKEY !:
               let MapS(28)=si_DEBUGPATH !:
               let MapS(29)=si_DEBUGPASSED !:
               let MapS(30)=si_PROTECTEDTEXT !:
               let MapS(31)=si_PROTECTEDCHECK !:
               let MapS(32)=si_PROTECTEDBUTTON !:
               let MapS(33)=si_OTHERCHANGES !:
               let MapS(34)=si_MYCHANGES !:
               let MapS(35)=si_LOCKWINDOW !:
               let MapS(36)=si_ACTIVECOLOR !:
               let MapS(37)=si_USERDATA

               let MapN(1)=si_VSIZE !:
               let MapN(2)=si_HSIZE !:
               let MapN(3)=si_BORDER !:
               let MapN(4)=si_WAITTIME !:
               let MapN(5)=si_CREATEDATE !:
               let MapN(6)=si_MODIFYDATE !:
               let MapN(7)=si_READINDEX !:
               let MapN(8)=si_RETURNINDEX !:
               let MapN(9)=si_DEBUGRECORD !:
               let MapN(10)=si_SCREENIOLOCKING !:
               let MapN(11)=si_SCREENIOMERGE !:
               let MapN(12)=si_VERSION
            #Case# 0
               ! Legacy Cases, Importing from backups saved Prior to May 2019. We only support the most recent one. Prior to that imports won't be compatible importing into future versions.
               ! Header - ScreenIO Record
               mat F$(35) : mat F(12)

               mat MapS(udim(mat F$))
               mat MapN(udim(mat F))

               mat Form$(max(udim(mat Form$),F)) ! Make room in forms array
               let Form$(F)="form V 18,V 60,POS 82,V 255,V 60,2*C 6,V 18,13*V 255,POS 3743,V 80,POS 3825,V 255,POS 4088,V 64,2*V 255,POS 4665,5*V 255,POS 5942,5*V 255,POS 79,B 1,BH 2,POS 3742,B 1,POS 3823,BH 2,POS 4080,2*BH 3,2*B 1,POS 4662,BH 3,POS 5940,2*B 1,POS 7217,BH 4"
               let Form$(F)=cform$(form$(F))

               let MapS(1)=si_SCREENCODE !:
               let MapS(2)=si_CAPTION !:
               let MapS(3)=si_ATTRIBUTES !:
               let MapS(4)=si_PICTURE !:
               let MapS(5)=si_FGCOLOR !:
               let MapS(6)=si_BGCOLOR !:
               let MapS(7)=si_FILELAY !:
               let MapS(8)=si_ENTERFN !:
               let MapS(9)=si_INITFN !:
               let MapS(10)=si_READFN !:
               let MapS(11)=si_LOADFN !:
               let MapS(12)=si_WRITEFN !:
               let MapS(13)=si_WAITFN !:
               let MapS(14)=si_LOCKEDFN !:
               let MapS(15)=si_MERGEFN !:
               let MapS(16)=si_LOOPFN !:
               let MapS(17)=si_NOKEYFN
               let MapS(18)=si_PRELISTVIEWFN !:
               let MapS(19)=si_POSTLISTVIEWFN !:
               let MapS(20)=si_EXITFN !:
               let MapS(21)=si_WINDCAP !:
               let MapS(22)=si_INPUTATTR !:
               let MapS(23)=si_DEBUGSCREEN !:
               let MapS(24)=si_DEBUGKEY !:
               let MapS(25)=si_DEBUGPARENTKEY !:
               let MapS(26)=si_DEBUGPATH !:
               let MapS(27)=si_DEBUGPASSED !:
               let MapS(28)=si_PROTECTEDTEXT !:
               let MapS(29)=si_PROTECTEDCHECK !:
               let MapS(30)=si_PROTECTEDBUTTON !:
               let MapS(31)=si_OTHERCHANGES !:
               let MapS(32)=si_MYCHANGES !:
               let MapS(33)=si_LOCKWINDOW
               let MapS(34)=si_ACTIVECOLOR !:
               let MapS(35)=si_USERDATA

               let MapN(1)=si_VSIZE !:
               let MapN(2)=si_HSIZE !:
               let MapN(3)=si_BORDER !:
               let MapN(4)=si_WAITTIME !:
               let MapN(5)=si_CREATEDATE !:
               let MapN(6)=si_MODIFYDATE !:
               let MapN(7)=si_READINDEX !:
               let MapN(8)=si_RETURNINDEX !:
               let MapN(9)=si_DEBUGRECORD !:
               let MapN(10)=si_SCREENIOLOCKING !:
               let MapN(11)=si_SCREENIOMERGE !:
               let MapN(12)=si_VERSION
            #End Select#
         else
            ! Details - Screen Flds File

            #Select# Version(F) #Case# 35 # 0
               ! Version 35 and Legacy Version 0 are the same, Screen Flds file is the same for both of these versions.
               mat F$(18) : mat F(9)

               mat MapS(udim(mat F$))
               mat MapN(udim(mat F))

               mat Form$(max(udim(mat Form$),F)) ! Make room in forms array
               let Form$(F)="form V 18,2*V 50,V 255,POS 377,V 8,POS 390,2*V 60,2*V 255,V 20,2*C 6,C 1,V 128,POS 1183,3*V 255,POS 1949,V 255,POS 374,B 1,BH 2,POS 385,2*BH 2,B 1,POS 1181,2*B 1,POS 1948,B 1,POS 2204,B 1"
               let Form$(F)=cform$(form$(F))

               let MapS(1)=SF_screencode !:
               let MapS(2)=SF_controlname !:
               let MapS(3)=SF_fieldname !:
               let MapS(4)=SF_description !:
               let MapS(5)=SF_fieldtype !:
               let MapS(6)=SF_truevalue !:
               let MapS(7)=SF_falsevalue !:
               let MapS(8)=SF_function !:
               let MapS(9)=SF_picture
               let MapS(10)=SF_parent !:
               let MapS(11)=SF_fgcolor !:
               let MapS(12)=SF_bgcolor !:
               let MapS(13)=SF_justify !:
               let MapS(14)=SF_attr !:
               let MapS(15)=SF_tooltip !:
               let MapS(16)=SF_cnvrtin !:
               let MapS(17)=SF_cnvrtout !:
               let MapS(18)=SF_userdata

               let MapN(1)=SF_vposition !:
               let MapN(2)=SF_hposition !:
               let MapN(3)=SF_specwidth !:
               let MapN(4)=SF_width !:
               let MapN(5)=SF_height !:
               let MapN(6)=SF_protected !:
               let MapN(7)=SF_invisible !:
               let MapN(8)=SF_multiselect !:
               let MapN(9)=SF_gridlines
            #End Select#
         end if
      end if
   fnend
!
IMPORTSCREEN: ! Imports The Screen From A User Selected File
   def Fnimportscreen(Mat Screenio$,Mat Screenio,[[Screencontrols]];___,Fimportfile,Index,Csopenstring$)
      ! if Fnclientserver then let Csopenstring$="@:"
      open #(Fimportfile:=Fngetfilenumber): "name=open:"&Csopenstring$&"*.sio",internal,input,sequential error IGNORE
      if File(Fimportfile)=0 then
         ! We need to check Version(fImportFile). If it matches the current version, we use the subs and sizes for standard ScreenIO.
         !  if its an older version, we need to load the subs and sizes for that version.
         let fnImportRecordVersion(FImportFile,mat ScreenIO$,mat Screenio)
         ! read #Fimportfile, using Form$(Fscreenio), release: Mat Screenio$, Mat Screenio error IGNORE
!
         let Fnresizecontrolarrays(0, [[Screencontrols]])
!
         do While File(Fimportfile)=0
            ! read #Fimportfile, using Form$(Fscreenfld), release: Mat Screenfld$, Mat Screenfld eof IGNORE
            ! if File(Fimportfile)=0 then
            if fnImportRecordVersion(FImportFile,mat ScreenFld$,mat Screenfld,1) then
               let Index=Udim(Mat Controlname$)+1
               let Fnresizecontrolarrays(Index, [[Screencontrols]])
!
               let Controlname$(Index)=Screenfld$(Sf_Controlname) !:
               let Fieldname$(Index)=Screenfld$(Sf_Fieldname) !:
               let Description$(Index)=Screenfld$(Sf_Description) !:
               let Vposition(Index)=Screenfld(Sf_Vposition) !:
               let Hposition(Index)=Screenfld(Sf_Hposition) !:
               let Fieldtype$(Index)=Screenfld$(Sf_Fieldtype) !:
               let Specwidth(Index)=Screenfld(Sf_Specwidth) !:
               let Width(Index)=Screenfld(Sf_Width) !:
               let Height(Index)=Screenfld(Sf_Height) !:
               let Truevalue$(Index)=Screenfld$(Sf_Truevalue) !:
               let Falsevalue$(Index)=Screenfld$(Sf_Falsevalue) !:
               let Function$(Index)=Screenfld$(Sf_Function) !:
               let Picture$(Index)=Screenfld$(Sf_Picture)
               let Parent$(Index)=Screenfld$(Sf_Parent) !:
               let Fgcolor$(Index)=Screenfld$(Sf_Fgcolor) !:
               let Bgcolor$(Index)=Screenfld$(Sf_Bgcolor) !:
               let Justify$(Index)=Screenfld$(Sf_Justify) !:
               let Attr$(Index)=Screenfld$(Sf_Attr) !:
               let Protected(Index)=Screenfld(Sf_Protected) !:
               let Invisible(Index)=Screenfld(Sf_Invisible) !:
               let Tooltip$(Index)=Screenfld$(Sf_Tooltip) !:
               let Cnvrtin$(Index)=Screenfld$(Sf_Cnvrtin) !:
               let Cnvrtout$(Index)=Screenfld$(Sf_Cnvrtout) !:
               let Multiselect(Index)=Screenfld(Sf_Multiselect) !:
               let GridLines(Index)=Screenfld(Sf_GridLines) !:
               let Userdata$(Index)=Screenfld$(Sf_Userdata)
            end if
         loop
!
         close #Fimportfile:
         let Fnimportscreen=1
      end if
   fnend
!
RECOMPILEALLSCREENS: ! Recompiles Every Screen
   def Fnrecompileallscreens(Mat Screenio$,Mat Screenio,[[Screencontrols]];___,Savescreencode$,Index,time,FileName$)
      dim Tempscreenlist$(1),Tempcreatedate(1),Tempmodifydate(1),TempVersion(1),TempCreateUser$(1)*30,TempModifyUser$(1)*30,TempProject$(1)*255,TempNotes$(1)*255
      dim FailedList$*2047
      let Savescreencode$=Static_Screenname$
      let Fnreadallscreencodes(Mat Tempscreenlist$,Mat Tempcreatedate,Mat Tempmodifydate,mat TempVersion,mat TempCreateUser$,mat TempModifyUser$,mat TempProject$,mat TempNotes$)
!
      if exists("compile[SESSION].$$$") then
         execute "free compile[SESSION].$$$"
      end if

      let FailedList$=""
      for Index=1 to Udim(Mat Tempscreenlist$)
         if Fnreadscreen(Tempscreenlist$(Index),Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
            let Fncompilehelperlibrary(Mat Screenio$,Mat Screenio,[[Screencontrols]],FileName$)
            let fnWaitForFile(FailedList$,lwrc$(trim$(TempScreenList$(Index))),FileName$)
         end if
      next Index
!
      if len(FailedList$) then
         let Msgbox("The following screens took a long time and may have had errors:"&chr$(13)&chr$(13)&FailedList$(3:9999))
      end if

      let Fnreadscreen(Savescreencode$,Mat Screenio$,Mat Screenio,[[Screencontrols]])
   fnend

   def fnWaitForFile(&FailedList$,Screen$;&FileName$,___,Time,Window,ky$,try,x)
      if FileName$="" then let FileName$="compile"&Session$&".$$$"
      do While Exists(FileName$)
         let Sleep(.1)
         let Time+=1
         if Time>20 then
            let FailedList$=FailedList$&", "&Screen$
            Open #(Window:=fnGetFileNumber): "srow=14,scol=45,rows=3,cols=30,n=/#FFFFFF:#FF0000", display, outin
            print #Window, fields "1,1,90/C 120,S" : "We're sorry. The compile process appears to be stuck. Close the open window or press the Space Bar to continue."
            do while kstat$<>"" ! Clear Keyboard Buffer
            loop
            do while exists(FileName$)
               sleep(.1)
               let ky$=kstat$
               if ky$=" " then
                  let try+=1
                  if try=1 then
                     execute "free "&FileName$ error Ignore
                     if exists(FileName$) then
                        print #Window, fields "1,1,90/C 120,S" : "The file is locked. Please close any BR windows or press Space again to force it."
                     end if
                  else if try=2 then
                      do while exists(FileName$)
                         let x+=1
                         let FileName$="compile"&Session$&"-"&str$(x)&".$$$"
                      loop
                  end if
               end if
            loop
            close #Window:
         end if
      loop
   fnend
!
COMPILEHELPERLIBRARY: ! Compiles The Helper Library For The Screen
   def Fncompilehelperlibrary(Mat Screenio$,Mat Screenio,[[Screencontrols]];FileName$,WaitForComplete,___,dummy$*255,SpecialFunction$*255,SpecialFuncCall$*255,Index,Filenumber,Elseif$,Library$*80,Funccall$*255,Longstring$*800,Function$*255,Longstring2$*800,Debugscreen$*64,PathInfo$*511,DebugExt$)
!
      if FileName$="" then let FileName$="compile"&session$&".$$$"

      dim Alreadysetfunctions$(1)*255
      mat Alreadysetfunctions$(0)
      dim Newincludefunctions$(1)*255
      mat Newincludefunctions$(0)
!
      let Fncheckhelperlibfolder
! .   ! Create new display file or replace it
      open #(Filenumber:=Fngetfilenumber) : "name="&setting_ScreenFolder$&"\"&Trim$(Screenio$(Si_Screencode))&".brs, recl=800, replace",display,output
!
! .   ! Print heading to it
      let Fnsetlinenumber(10,10,Filenumber)
      let Fnprintline("! "&setting_ScreenFolder$&"\"&Lwrc$(Trim$(Screenio$(Si_Screencode)))&".br")
      let Fnprintline("! ScreenIO Generated Helper Library for "&Uprc$(Trim$(Screenio$(Si_Screencode)))&" screen")
      let Fnprintline("! Copyright 2008 by Sage AX")
      let Fnprintline("! ")
      let Fnprintline("! Compiled On: "&Date$("mm/dd/ccyy"))
      let Fnprintline("! Version: "&str$(screenio(si_version)))
      let Fnprintline("! ")
      let Fnprintline('! ')
      let Fnprintline('! ')
!
! .   ! Dim Helper Library Variables
      let Fnsetlinenumber(300,10)
      let Fnprintline('! ')
      let Fnprintline('   option retain')
      let Fnprintline('   dim FileIOLinkageSet')
      let Fnprintline('   dim Ret$*255')
      let Fnprintline('   dim PassedData$(1)*255')
      let fnUnpackPData$(mat PData$,ScreenIO$(si_DebugPassed))
      let fnPrintLine('   mat PassedData$('&str$(udim(mat PData$))&')')
      let Fnsetlinenumber(400,1)
      for Index=1 to udim(mat PData$)
         let fnPrintLine('   let PassedData$('&str$(Index)&')="'&srep$(PData$(Index),"""","""""")&'"')
      next Index

      let Fnsetlinenumber(600,10)
      if len(trim$(screenIO$(si_DebugPath))) then
         let Fnprintline('   dim MyF$(1)*255')
         let Fnprintline('   dim MyF(1)')
         let PathInfo$=",0,mat MyF$,mat MyF,"""&trim$(ScreenIO$(si_DebugPath))&""""
      end if

      let Fnprintline('! ')
!
! .   ! Print Main Routine (Links to screen, runs it)
      let Fnsetlinenumber(1000,10)
      let Fnprintline('Main: ! If you run me as a program, I run the '&Lwrc$(Trim$(Screenio$(Si_Screencode)))& ' screen')
      let Fnprintline('   library "'&setting_ScreenIOPath$&'" : fnfm$')
!
      if Len(Trim$(Screenio$(Si_Debugscreen))) then
         let Debugscreen$=Lwrc$(Trim$(Screenio$(Si_Debugscreen)))
      else
         let Debugscreen$=Lwrc$(Trim$(Screenio$(Si_Screencode)))
      end if

      if DebugScreen$(1:1)="%" then
         let fnPrintLine('   let Key$="'&srep$(ScreenIO$(si_DebugKey),"""","""""")&'"')
         let fnPrintLine('   let ParentKey$="'&srep$(ScreenIO$(si_DebugParentKey),"""","""""")&'"')
         let fnPrintLine('   let Record='&str$(ScreenIO(si_DebugRecord)))
         let fnPrintLine('   let Path$="'&srep$(ScreenIO$(si_DebugPath),"""","""""")&'"')
         let fnPrintLine('   let ScreenCode$="'&Trim$(Screenio$(Si_Screencode))&'"')
         if pos(lwrc$(DebugScreen$),".br") or pos(lwrc$(DebugScreen$),".wb") then
            let fnPrintLine('   chain "'&DebugScreen$(2:99)&'",mat PassedData$,Key$,ParentKey$,Record,Path$,ScreenCode$')
         else
            let fnPrintLine('   chain "proc='&DebugScreen$(2:99)&'",mat PassedData$,Key$,ParentKey$,Record,Path$,ScreenCode$')
         end if
      else
         let Fnprintline('   let Ret$=fnfm$("'&Debugscreen$&'","'&Trim$(Screenio$(Si_Debugkey))&'",0,0,"'&Trim$(Screenio$(Si_Debugparentkey))&'",0,0,0,'&str$(ScreenIO(si_debugRecord))&',mat PassedData$'&PathInfo$&')')
      end if
!
      let Fnprintline('   if len(trim$(Ret$)) then')
      let Fnprintline('      print Ret$')
      let Fnprintline('   end if')
      let Fnprintline('   if fkey=93 then execute "system"')
      let Fnprintline('   stop')
      let Fnprintline('! ')
!
! .   ! Print Custom Functions
      let Fnsetlinenumber(5000,1)
      let Fnprintline('CustomFunctions: ! Lines 5000 - 70000 are Custom Functions')
      let Fnprintline('! '&Rpt$("=",60))
      for Index=1 to Udim(Mat Function$)
         let Function$=Trim$(Function$(Index))
         if Function$(1:1)="[" And Pos(Function$,"]") then
            let Function$=Trim$(Function$(Pos(Function$,"]")+1:Len(Function$)))
         end if
         if Function$(1:1)="{" then ! We Have An Internal Function
            if Srch(Alreadysetfunctions$,Lwrc$(Trim$(Function$)))<=0 then
               if Exists(Fncustomfilenameof$(Function$)) then
                  let Fnimportfunction(Function$,Mat Newincludefunctions$)
                  let Fnprintline('! ')
               else
                  let Msgbox("Missing Function: "&Function$,"Where did it go?","OK","ERR")
               end if
               mat Alreadysetfunctions$(Udim(Mat Alreadysetfunctions$)+1)
               let Alreadysetfunctions$(Udim(Mat Alreadysetfunctions$))=Lwrc$(Trim$(Function$))
            end if
         end if
      next Index
      for Index=Si_Enterfn to Si_Exitfn
         let Function$=Trim$(Screenio$(Index))
         if Function$(1:1)="[" And Pos(Function$,"]") then
            let Function$=Trim$(Function$(Pos(Function$,"]")+1:Len(Function$)))
         end if
         if Function$(1:1)="{" then ! We Have An Internal Function
            if Srch(Alreadysetfunctions$,Lwrc$(Trim$(Function$)))<=0 then
               if Exists(Fncustomfilenameof$(Function$)) then
                  let Fnimportfunction(Function$,Mat Newincludefunctions$)
                  let Fnprintline('! ')
               else
                  let Msgbox("Missing Function: "&Function$,"Where did it go?","OK","ERR")
               end if
               mat Alreadysetfunctions$(Udim(Mat Alreadysetfunctions$)+1)
               let Alreadysetfunctions$(Udim(Mat Alreadysetfunctions$))=Lwrc$(Trim$(Function$))
            end if
         end if
      next Index

      if exists(setting_FunctionFolder$) then
         if exists(setting_FunctionFolder$&"defaults\") then
            if exists(setting_FunctionFolder$&"defaults\enter.brs") then
               let fnImportFunction(fnFunctionString$(setting_FunctionFolder$&"defaults\enter.brs"),mat NewIncludeFunctions$)
            end if
            if exists(setting_FunctionFolder$&"defaults\init.brs") then
               let fnImportFunction(fnFunctionString$(setting_FunctionFolder$&"defaults\init.brs"),mat NewIncludeFunctions$)
            end if
            if exists(setting_FunctionFolder$&"defaults\read.brs") then
               let fnImportFunction(fnFunctionString$(setting_FunctionFolder$&"defaults\read.brs"),mat NewIncludeFunctions$)
            end if
            if exists(setting_FunctionFolder$&"defaults\load.brs") then
               let fnImportFunction(fnFunctionString$(setting_FunctionFolder$&"defaults\load.brs"),mat NewIncludeFunctions$)
            end if
            if exists(setting_FunctionFolder$&"defaults\write.brs") then
               let fnImportFunction(fnFunctionString$(setting_FunctionFolder$&"defaults\write.brs"),mat NewIncludeFunctions$)
            end if
            if exists(setting_FunctionFolder$&"defaults\wait.brs") then
               let fnImportFunction(fnFunctionString$(setting_FunctionFolder$&"defaults\wait.brs"),mat NewIncludeFunctions$)
            end if
            if exists(setting_FunctionFolder$&"defaults\locked.brs") then
               let fnImportFunction(fnFunctionString$(setting_FunctionFolder$&"defaults\locked.brs"),mat NewIncludeFunctions$)
            end if
            if exists(setting_FunctionFolder$&"defaults\merge.brs") then
               let fnImportFunction(fnFunctionString$(setting_FunctionFolder$&"defaults\merge.brs"),mat NewIncludeFunctions$)
            end if
            if exists(setting_FunctionFolder$&"defaults\mainloop.brs") then
               let fnImportFunction(fnFunctionString$(setting_FunctionFolder$&"defaults\mainloop.brs"),mat NewIncludeFunctions$)
            end if
            if exists(setting_FunctionFolder$&"defaults\nokey.brs") then
               let fnImportFunction(fnFunctionString$(setting_FunctionFolder$&"defaults\nokey.brs"),mat NewIncludeFunctions$)
            end if
            if exists(setting_FunctionFolder$&"defaults\prelist.brs") then
               let fnImportFunction(fnFunctionString$(setting_FunctionFolder$&"defaults\prelist.brs"),mat NewIncludeFunctions$)
            end if
            if exists(setting_FunctionFolder$&"defaults\postlist.brs") then
               let fnImportFunction(fnFunctionString$(setting_FunctionFolder$&"defaults\postlist.brs"),mat NewIncludeFunctions$)
            end if
            if exists(setting_FunctionFolder$&"defaults\exit.brs") then
               let fnImportFunction(fnFunctionString$(setting_FunctionFolder$&"defaults\exit.brs"),mat NewIncludeFunctions$)
            end if
         end if
      end if
!
      let Index=0
      do While Index<Udim(Mat Newincludefunctions$)
         let Index+=1
         let Function$=Newincludefunctions$(Index)
         if Function$(1:1)="{" then ! We Have An Internal Function
            if Srch(Alreadysetfunctions$,Lwrc$(Trim$(Function$)))<=0 then
               if Exists(Fncustomfilenameof$(Function$)) then
                  let Fnimportfunction(Function$,Mat Newincludefunctions$)
                  let Fnprintline('! ')
               else
                  let Msgbox("Missing Function: "&Function$,"Where did it go?","OK","ERR")
               end if
               mat Alreadysetfunctions$(Udim(Mat Alreadysetfunctions$)+1)
               let Alreadysetfunctions$(Udim(Mat Alreadysetfunctions$))=Lwrc$(Trim$(Function$))
            end if
         end if
      loop
!
      let Fnprintline('! ')
      let Fnprintline('! ')
!
! .   ! Generate String Reference Chart Function
      let Fnsetlinenumber(85000,1)
      let Fnprintline('   def library fnCheckStringFunction(Function$*255)')
      let Elseif$="if "
      for Index=1 to Udim(Mat Function$)
         let Function$=Trim$(Function$(Index))
         if Function$(1:1)="{" then ! We Have A Custom Function
            let Funccall$=Fnreadcustomfunctionstatement$(Function$)
            if Len(Trim$(Funccall$)) then
               let Fnprintline('   '&Elseif$&'Function$ = "'&Function$&'" then')
               let Fnprintline('      let fnCheckStringFunction = '&Str$(Fnstringfunction(Funccall$)))
               let Elseif$="else if "

               if Lwrc$(Trim$(Fieldtype$(Index)))="listview" then
                  ! check if there exists a function in it called "fnInit_FunctionName" and "fnFinal_FunctionName".
                  !  If there is, then add a couple more lines here that add an "else if" for "Init_FunctionName" and Final_FunctionName that point to those functions.
                  !   If there isn't, then add empty if statements lines here.

                  ! Check for if there's an Init Function
                  let SpecialFunction$=fnGetSpecialFunctionHandle$(Function$,"Init_")
                  let Fnprintline('   '&Elseif$&'Function$ = "'&SpecialFunction$&'" then')
                  let Fnprintline('      let fnCheckStringFunction = 0')
                  let SpecialFunction$=fnGetSpecialFunctionHandle$(Function$,"Final_")
                  let Fnprintline('   '&Elseif$&'Function$ = "'&SpecialFunction$&'" then')
                  let Fnprintline('      let fnCheckStringFunction = 0')
               end if

            end if
         end if
      next Index
      for Index=Si_Enterfn to Si_Exitfn
         let Function$=Trim$(Screenio$(Index))
         if Function$(1:1)="{" then ! We Have A Custom Function
            let Funccall$=Fnreadcustomfunctionstatement$(Function$)
            if Len(Trim$(Funccall$)) then
               let Fnprintline('      '&Elseif$&'Function$ = "'&Function$&'" then')
               let Fnprintline('         let fnCheckStringFunction = '&Str$(Fnstringfunction(Funccall$)))
               let Elseif$="else if "
            end if
         end if
      next Index

      if exists(setting_FunctionFolder$) then
         if exists(setting_FunctionFolder$&"defaults\") then
            if exists(setting_FunctionFolder$&"defaults\enter.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\enter.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('      '&Elseif$&'Function$ = "'&Function$&'" then')
                  let Fnprintline('         let fnCheckStringFunction = '&Str$(Fnstringfunction(Funccall$)))
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\init.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\init.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('      '&Elseif$&'Function$ = "'&Function$&'" then')
                  let Fnprintline('         let fnCheckStringFunction = '&Str$(Fnstringfunction(Funccall$)))
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\read.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\read.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('      '&Elseif$&'Function$ = "'&Function$&'" then')
                  let Fnprintline('         let fnCheckStringFunction = '&Str$(Fnstringfunction(Funccall$)))
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\load.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\load.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('      '&Elseif$&'Function$ = "'&Function$&'" then')
                  let Fnprintline('         let fnCheckStringFunction = '&Str$(Fnstringfunction(Funccall$)))
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\write.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\write.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('      '&Elseif$&'Function$ = "'&Function$&'" then')
                  let Fnprintline('         let fnCheckStringFunction = '&Str$(Fnstringfunction(Funccall$)))
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\wait.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\wait.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('      '&Elseif$&'Function$ = "'&Function$&'" then')
                  let Fnprintline('         let fnCheckStringFunction = '&Str$(Fnstringfunction(Funccall$)))
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\locked.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\locked.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('      '&Elseif$&'Function$ = "'&Function$&'" then')
                  let Fnprintline('         let fnCheckStringFunction = '&Str$(Fnstringfunction(Funccall$)))
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\merge.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\merge.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('      '&Elseif$&'Function$ = "'&Function$&'" then')
                  let Fnprintline('         let fnCheckStringFunction = '&Str$(Fnstringfunction(Funccall$)))
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\mainloop.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\mainloop.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('      '&Elseif$&'Function$ = "'&Function$&'" then')
                  let Fnprintline('         let fnCheckStringFunction = '&Str$(Fnstringfunction(Funccall$)))
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\nokey.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\nokey.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('      '&Elseif$&'Function$ = "'&Function$&'" then')
                  let Fnprintline('         let fnCheckStringFunction = '&Str$(Fnstringfunction(Funccall$)))
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\prelist.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\prelist.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('      '&Elseif$&'Function$ = "'&Function$&'" then')
                  let Fnprintline('         let fnCheckStringFunction = '&Str$(Fnstringfunction(Funccall$)))
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\postlist.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\postlist.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('      '&Elseif$&'Function$ = "'&Function$&'" then')
                  let Fnprintline('         let fnCheckStringFunction = '&Str$(Fnstringfunction(Funccall$)))
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\exit.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\exit.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('      '&Elseif$&'Function$ = "'&Function$&'" then')
                  let Fnprintline('         let fnCheckStringFunction = '&Str$(Fnstringfunction(Funccall$)))
                  let Elseif$="else if "
               end if
            end if
         end if
      end if
!
      if Elseif$="else if " then
         let Fnprintline('      else')
         let Fnprintline('         if Function$<>"{{GetData}}" and Function$<>"{{SetData}}" then')
         let Fnprintline('            print "Function ("&function$&") on screen '&Screenio$(si_screenCode)&' is not Supported: The library is out of date or fn not found."')
         let Fnprintline('         end if')
         let Fnprintline('      end if')
      else
         let Fnprintline('      if Function$<>"{{GetData}}" and Function$<>"{{SetData}}" then')
         let Fnprintline('         print "Function ("&function$&") on screen '&Screenio$(si_screenCode)&' is not Supported: The library is out of date or fn not found."')
         let Fnprintline('      end if')
      end if

      let Fnprintline('   fnend')
      let Fnprintline('! ')
      let Fnprintline('! ')
!
! .   ! Print Function Switch
      let Fnsetlinenumber(89000,10)
      let Longstring$='Function$*255,mat Subscripts$,mat PassedData$,&FieldIndex,&FieldText$,&ControlIndex,&Key$,&ExitMode,&RepopulateListviews,&RedrawListviews,&CurrentField,&CurrentField$,&Prefix$,&CurrentKey$,&CurrentRec,&ParentKey$,'
      let LongString$=LongString$&'&DataFile,Window,&CurrentRow,LockUser$,&Path$,&Selecting,mat Disk_F$,mat Disk_F,&OnRead,&TryToContinue,&DisplayOnly,&Active,&RedrawFrames,&RedrawScreens,&RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,'
      let LongString$=LongString$&'mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$'
      let Longstring2$='Function$,mat Subscripts$,mat PassedData$,FieldIndex,FieldText$,ControlIndex,Key$,ExitMode,RepopulateListviews,RedrawListviews,CurrentField,CurrentField$,Prefix$,CurrentKey$,CurrentRec,ParentKey$,'
      let LongString2$=LongString2$&'DataFile,Window,CurrentRow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,'
      let LongString2$=LongString2$&'mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)'


      let Fnprintline('   def library fnFunctionSwitch('&Longstring$&')')
      let Fnprintline('      let fnFunctionSwitch = fnFS('&Longstring2$)
      let Fnprintline('   fnend')
      let Fnprintline('   def library fnFunctionSwitch$*255('&Longstring$&')')
      let Fnprintline('      let fnFunctionSwitch$ = fnFS$('&Longstring2$)
      let Fnprintline('   fnend')
      let Fnprintline('   def library fnFunctionSwitch1('&Longstring$&')')
      let Fnprintline('      let fnFunctionSwitch1 = fnFS('&Longstring2$)
      let Fnprintline('   fnend')
      let Fnprintline('   def library fnFunctionSwitch1$*255('&Longstring$&')')
      let Fnprintline('      let fnFunctionSwitch1$ = fnFS$('&Longstring2$)
      let Fnprintline('   fnend')
      let Fnprintline('   def library fnFunctionSwitch2('&Longstring$&')')
      let Fnprintline('      let fnFunctionSwitch2 = fnFS('&Longstring2$)
      let Fnprintline('   fnend')
      let Fnprintline('   def library fnFunctionSwitch2$*255('&Longstring$&')')
      let Fnprintline('      let fnFunctionSwitch2$ = fnFS$('&Longstring2$)
      let Fnprintline('   fnend')
      let Fnprintline('   def library fnFunctionSwitch3('&Longstring$&')')
      let Fnprintline('      let fnFunctionSwitch3 = fnFS('&Longstring2$)
      let Fnprintline('   fnend')
      let Fnprintline('   def library fnFunctionSwitch3$*255('&Longstring$&')')
      let Fnprintline('      let fnFunctionSwitch3$ = fnFS$('&Longstring2$)
      let Fnprintline('   fnend')
      let Fnprintline('   def library fnFunctionSwitch4('&Longstring$&')')
      let Fnprintline('      let fnFunctionSwitch4 = fnFS('&Longstring2$)
      let Fnprintline('   fnend')
      let Fnprintline('   def library fnFunctionSwitch4$*255('&Longstring$&')')
      let Fnprintline('      let fnFunctionSwitch4$ = fnFS$('&Longstring2$)
      let Fnprintline('   fnend')
      let Fnprintline('   def library fnFunctionSwitch5('&Longstring$&')')
      let Fnprintline('      let fnFunctionSwitch5 = fnFS('&Longstring2$)
      let Fnprintline('   fnend')
      let Fnprintline('   def library fnFunctionSwitch5$*255('&Longstring$&')')
      let Fnprintline('      let fnFunctionSwitch5$ = fnFS$('&Longstring2$)
      let Fnprintline('   fnend')
      let Fnprintline('   def library fnFunctionSwitch6('&Longstring$&')')
      let Fnprintline('      let fnFunctionSwitch6 = fnFS('&Longstring2$)
      let Fnprintline('   fnend')
      let Fnprintline('   def library fnFunctionSwitch6$*255('&Longstring$&')')
      let Fnprintline('      let fnFunctionSwitch6$ = fnFS$('&Longstring2$)
      let Fnprintline('   fnend')
      let Fnprintline('   def library fnFunctionSwitch7('&Longstring$&')')
      let Fnprintline('      let fnFunctionSwitch7 = fnFS('&Longstring2$)
      let Fnprintline('   fnend')
      let Fnprintline('   def library fnFunctionSwitch7$*255('&Longstring$&')')
      let Fnprintline('      let fnFunctionSwitch7$ = fnFS$('&Longstring2$)
      let Fnprintline('   fnend')
!
      let Fnprintline('! ')
      let Fnprintline(' dim DataIsInside')
      let Fnprintline('! ')
!
      let Fnprintline('   def fnFS('&Longstring$&';___,ReturnValue,ReturnValue$*255,Index)')
      let Fnprintline('      gosub FunctionSwitch')
      let Fnprintline('      let fnFS=ReturnValue')
      let Fnprintline('   fnend')
      let Fnprintline('   def fnFS$*255('&Longstring$&';___,ReturnValue,ReturnValue$*255,Index)')
      let Fnprintline('      gosub FunctionSwitch')
      let Fnprintline('      let fnFS$ = ReturnValue$')
      let Fnprintline('   fnend')
!
      let Fnprintline('! ')
      let Fnprintline('! ')
!
      let Fnsetlinenumber(92000,1)
      let Longstring$='library "'&setting_FileIOPath$&'" : fnOpenFile,Fnclosefile,Fngetfilenumber,Fnkey$,FnBuildKey$,Fnreadlayoutarrays,Fndoeslayoutexist,Fnreadallkeys,fnReadRelativeDescription$,fnReadRelUnopenedDescription$,fnReadRelUnopenedNumber,fnUpdateFile,fnLog,fnLogArray,fnSetLogChanges,fnLogChanges,fnErrLog,'
      let Longstring$=Longstring$&'fnReadLayouts,Fnmakeuniquekey$,FnDisplayLength,FnLength,FnReadDescription$,FnReadUnopenedDescription$,fnReadRecordWhere$,fnUniqueKey,fnReadNumber,fnReadUnopenedNumber,fnReadRelativeNumber,fnNotInFile,fnDataCrawler,fnDataEdit,fnShowData,fnCopyfile'
      let Fnprintline('FunctionSwitch: ! Routine to call custom function')
      let Fnprintline('! ')
      let fnPrintLine('   if ~DataIsInside then')
      let fnPrintLine('      let fnPopData(2)')
      let fnPrintLine('      if Function$="{{SetData}}" then let DataIsInside=1')
      let fnPrintLine('   end if')
      let Fnprintline('! ')
      let Fnprintline('   if ~FileIOLinkageSet then')
      let Fnprintline('      '&Longstring$)
      let Fnprintline('      library "'&setting_FileIOPath$&'" : fnMakeSubProc,fnReadMatchingKeys,fnReadAllNewKeys,fnReadFilterKeys,fnReadEntireLayout,fnReadLayoutHeader,fnReadSubs,fnReadLayoutPath$,fnReadKeyFiles,fnAskCombo$,fnRunProcFile,fnBuildProcFile,fnReadLockedUsers,fnShowMessage,fnExportListviewCSV,fnCsvExport,fnCsvImport')
      let Fnprintline('      library "'&setting_ScreenIOPath$&'" : fnCallScreen$,fnFindSubscript,fnFm$,fnfm,fnDisplayScreen,fnGetUniqueName$,fnIsInputSpec,fnIsOutputSpec,fnDays,fnBR42,fnBR43,fnAnimate,fnPrepareAnimation,fnCloseAnimation,fnFunctionBase,fnListSpec$')
      let Fnprintline('      let FileIOLinkageSet=1')
      let Fnprintline('      for Index=1 to udim(mat Subscripts$) : execute (Subscripts$(Index)) : next Index')
      let Fnprintline('   end if')
      let Fnprintline('! ')
!
      let Elseif$="if "
      for Index=1 to Udim(Mat Function$)
         let Function$=Trim$(Function$(Index))
         if Function$(1:1)="[" And Pos(Function$,"]") then
            let Function$=Trim$(Function$(Pos(Function$,"]")+1:Len(Function$)))
         end if
         if Function$(1:1)="#" then ! We Have A Library Function
            let Fnprintline('   '&Elseif$&'Function$ = "'&srep$(Function$,"""","""""")&'" then')
            let Library$=Trim$(Function$(2:Pos(Function$,":")-1))
            let Funccall$=Trim$(Function$(Pos(Function$,":")+1:Len(Function$)))
            if (Len(Library$)) And ~Pos(Library$," ") And ~Pos(Library$,"(") then ! We Have A Properly Formatted Library Function
               if Pos(Funccall$(Pos(Uprc$(Funccall$),"FN"):Len(Funccall$)),"(") then
                  let Fnprintline('      library "'&Trim$(Library$)&'" : '&Funccall$(Pos(Uprc$(Funccall$),"FN"):Pos(Funccall$,"(")-1))
               else
                  let Fnprintline('      library "'&Trim$(Library$)&'" : '&Funccall$(Pos(Uprc$(Funccall$),"FN"):Len(Funccall$)))
               end if
            end if
            if Fnstringfunction(Funccall$) then
               let Fnprintline('      let ReturnValue$ = '&Funccall$)
            else
               let Fnprintline('      let ReturnValue = '&Funccall$)
            end if
            let Elseif$="else if "
         end if
         if Function$(1:1)="{" then ! We Have A Custom Function
            let Funccall$=Fnreadcustomfunctionstatement$(Function$)
            if Len(Trim$(Funccall$)) then
               let Fnprintline('   '&Elseif$&'Function$ = "'&Function$&'" then')
               if Fnstringfunction(Funccall$) then
                  let Fnprintline('      let ReturnValue$ = '&Funccall$)
               else
                  let Fnprintline('      let ReturnValue = '&Funccall$)
               end if
               let Elseif$="else if "

               if Lwrc$(Trim$(Fieldtype$(Index)))="listview" then
                  ! check if there exists a function in it called "fnInit_FunctionName" and "fnFinal_FunctionName".
                  !  If there is, then add a couple more lines here that add an "else if" for "Init_FunctionName" and Final_FunctionName that point to those functions.
                  !   If there isn't, then add empty if statements lines here.

                  ! Check for if there's an Init Function
                  let SpecialFuncCall$=fnGetSpecialFunctionName$(Function$,"Init_")
                  let SpecialFunction$=fnGetSpecialFunctionHandle$(Function$,"Init_")
                  let Fnprintline('   '&Elseif$&'Function$ = "'&SpecialFunction$&'" then')
                  if fnCheckForFunction(Function$,SpecialFuncCall$) then
                     let Fnprintline('      let '&SpecialFuncCall$)
                  end if

                  ! Check for if there's an Init Function
                  let SpecialFuncCall$=fnGetSpecialFunctionName$(Function$,"Final_")
                  let SpecialFunction$=fnGetSpecialFunctionHandle$(Function$,"Final_")
                  let Fnprintline('   '&Elseif$&'Function$ = "'&SpecialFunction$&'" then')
                  if fnCheckForFunction(Function$,SpecialFuncCall$) then
                     let Fnprintline('      let '&SpecialFuncCall$)
                  end if
               end if
            end if
         end if
      next Index

      for Index=Si_Enterfn to Si_Exitfn
         let Function$=Trim$(Screenio$(Index))
         if Function$(1:1)="[" And Pos(Function$,"]") then
            let Function$=Trim$(Function$(Pos(Function$,"]")+1:Len(Function$)))
         end if
         if Function$(1:1)="#" then ! We Have A Library Function
            let Fnprintline('   '&Elseif$&'Function$ = "'&srep$(Function$,"""","""""")&'" then')
            let Library$=Trim$(Function$(2:Pos(Function$,":")-1))
            let Funccall$=Trim$(Function$(Pos(Function$,":")+1:Len(Function$)))
            if (Len(Library$)) And ~Pos(Library$," ") And ~Pos(Library$,"(") then ! We Have A Properly Formatted Library Function
               if Pos(Funccall$(Pos(Uprc$(Funccall$),"FN"):Len(Funccall$)),"(") then
                  let Fnprintline('      library "'&Trim$(Library$)&'" : '&Funccall$(Pos(Uprc$(Funccall$),"FN"):Pos(Funccall$,"(")-1))
               else
                  let Fnprintline('      library "'&Trim$(Library$)&'" : '&Funccall$(Pos(Uprc$(Funccall$),"FN"):Len(Funccall$)))
               end if
            end if
            if Fnstringfunction(Funccall$) then
               let Fnprintline('      let ReturnValue$ = '&Funccall$)
            else
               let Fnprintline('      let ReturnValue = '&Funccall$)
            end if
            let Elseif$="else if "
         end if
         if Function$(1:1)="{" then ! We Have A Custom Function
            let Funccall$=Fnreadcustomfunctionstatement$(Function$)
            if Len(Trim$(Funccall$)) then
               let Fnprintline('   '&Elseif$&'Function$ = "'&Function$&'" then')
               if Fnstringfunction(Funccall$) then
                  let Fnprintline('      let ReturnValue$ = '&Funccall$)
               else
                  let Fnprintline('      let ReturnValue = '&Funccall$)
               end if
               let Elseif$="else if "
            end if
         end if
      next Index

      if exists(setting_FunctionFolder$) then
         if exists(setting_FunctionFolder$&"defaults\") then
            if exists(setting_FunctionFolder$&"defaults\enter.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\enter.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('   '&Elseif$&'Function$ = "'&Function$&'" then')
                  if Fnstringfunction(Funccall$) then
                     let Fnprintline('      let ReturnValue$ = '&Funccall$)
                  else
                     let Fnprintline('      let ReturnValue = '&Funccall$)
                  end if
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\init.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\init.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('   '&Elseif$&'Function$ = "'&Function$&'" then')
                  if Fnstringfunction(Funccall$) then
                     let Fnprintline('      let ReturnValue$ = '&Funccall$)
                  else
                     let Fnprintline('      let ReturnValue = '&Funccall$)
                  end if
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\read.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\read.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('   '&Elseif$&'Function$ = "'&Function$&'" then')
                  if Fnstringfunction(Funccall$) then
                     let Fnprintline('      let ReturnValue$ = '&Funccall$)
                  else
                     let Fnprintline('      let ReturnValue = '&Funccall$)
                  end if
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\load.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\load.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('   '&Elseif$&'Function$ = "'&Function$&'" then')
                  if Fnstringfunction(Funccall$) then
                     let Fnprintline('      let ReturnValue$ = '&Funccall$)
                  else
                     let Fnprintline('      let ReturnValue = '&Funccall$)
                  end if
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\write.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\write.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('   '&Elseif$&'Function$ = "'&Function$&'" then')
                  if Fnstringfunction(Funccall$) then
                     let Fnprintline('      let ReturnValue$ = '&Funccall$)
                  else
                     let Fnprintline('      let ReturnValue = '&Funccall$)
                  end if
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\wait.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\wait.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('   '&Elseif$&'Function$ = "'&Function$&'" then')
                  if Fnstringfunction(Funccall$) then
                     let Fnprintline('      let ReturnValue$ = '&Funccall$)
                  else
                     let Fnprintline('      let ReturnValue = '&Funccall$)
                  end if
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\locked.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\locked.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('   '&Elseif$&'Function$ = "'&Function$&'" then')
                  if Fnstringfunction(Funccall$) then
                     let Fnprintline('      let ReturnValue$ = '&Funccall$)
                  else
                     let Fnprintline('      let ReturnValue = '&Funccall$)
                  end if
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\merge.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\merge.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('   '&Elseif$&'Function$ = "'&Function$&'" then')
                  if Fnstringfunction(Funccall$) then
                     let Fnprintline('      let ReturnValue$ = '&Funccall$)
                  else
                     let Fnprintline('      let ReturnValue = '&Funccall$)
                  end if
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\mainloop.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\mainloop.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('   '&Elseif$&'Function$ = "'&Function$&'" then')
                  if Fnstringfunction(Funccall$) then
                     let Fnprintline('      let ReturnValue$ = '&Funccall$)
                  else
                     let Fnprintline('      let ReturnValue = '&Funccall$)
                  end if
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\nokey.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\nokey.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('   '&Elseif$&'Function$ = "'&Function$&'" then')
                  if Fnstringfunction(Funccall$) then
                     let Fnprintline('      let ReturnValue$ = '&Funccall$)
                  else
                     let Fnprintline('      let ReturnValue = '&Funccall$)
                  end if
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\prelist.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\prelist.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('   '&Elseif$&'Function$ = "'&Function$&'" then')
                  if Fnstringfunction(Funccall$) then
                     let Fnprintline('      let ReturnValue$ = '&Funccall$)
                  else
                     let Fnprintline('      let ReturnValue = '&Funccall$)
                  end if
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\postlist.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\postlist.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('   '&Elseif$&'Function$ = "'&Function$&'" then')
                  if Fnstringfunction(Funccall$) then
                     let Fnprintline('      let ReturnValue$ = '&Funccall$)
                  else
                     let Fnprintline('      let ReturnValue = '&Funccall$)
                  end if
                  let Elseif$="else if "
               end if
            end if
            if exists(setting_FunctionFolder$&"defaults\exit.brs") then
               let Function$=fnFunctionString$(setting_FunctionFolder$&"defaults\exit.brs")
               let Funccall$=Fnreadcustomfunctionstatement$(Function$)
               if Len(Trim$(Funccall$)) then
                  let Fnprintline('   '&Elseif$&'Function$ = "'&Function$&'" then')
                  if Fnstringfunction(Funccall$) then
                     let Fnprintline('      let ReturnValue$ = '&Funccall$)
                  else
                     let Fnprintline('      let ReturnValue = '&Funccall$)
                  end if
                  let Elseif$="else if "
               end if
            end if
         end if
      end if
!
      if Elseif$="else if " then
         let Fnprintline('   else')
         let Fnprintline('      if Function$<>"{{GetData}}" and Function$<>"{{SetData}}" then')
         let Fnprintline('         print "Function ("&function$&") on screen '&Screenio$(si_screenCode)&' is not Supported: The library is out of date or fn not found."')
         let Fnprintline('      end if')
         let Fnprintline('   end if')
      else
         let Fnprintline('   if Function$<>"{{GetData}}" and Function$<>"{{SetData}}" then')
         let Fnprintline('      print "Function ("&function$&") on screen '&Screenio$(si_screenCode)&' is not Supported: The library is out of date or fn not found."')
         let Fnprintline('   end if')
      end if
!
      let Fnprintline('! ')
      let fnPrintLine('   if ~DataIsInside or Function$="{{GetData}}" then')
      let fnPrintLine('      let fnPushData(2)')
      let fnPrintLine('      let DataIsInside=0')
      let fnPrintLine('   end if')

      let Fnprintline('return')
      let Fnprintline('! ')
!
! .   ! Print End of Program
      let Fnsetlinenumber(99000,10)
      let Fnprintline('OPEN: !   ***** Function  To Call Library Openfile And Proc Subs')
      let Fnprintline('   def Fnopen(Filename$*255, Mat F$, Mat F, Mat Form$; Inputonly, Keynum, Dont_Sort_Subs, Path$*255, Mat Descr$, Mat Field_Widths,Supress_Prompt,Ignore_Errors,Suppress_Log,mat DateFmt$,___,Index)')
      let Fnprintline('      dim _FileIOSubs$(1)*800, _loadedsubs$(1)*32')
      let Fnprintline('      let Fnopen=Fnopenfile(Filename$, Mat F$, Mat F, Mat Form$, Inputonly, Keynum, Dont_Sort_Subs, Path$, Mat Descr$, Mat Field_Widths, Mat _FileIOSubs$, Supress_Prompt,Ignore_Errors,Program$,Suppress_Log,mat DateFmt$)')
      let Fnprintline('      if srch(_loadedsubs$,uprc$(Filename$))<=0 then : mat _loadedsubs$(UDIM(_loadedsubs$)+1) : _loadedsubs$(UDIM(_loadedsubs$))=uprc$(Filename$) : for Index=1 to Udim(Mat _Fileiosubs$) : execute (_Fileiosubs$(Index)) : next Index')
      let Fnprintline('   fnend')
      let Fnprintline('! ')

      let Fnsetlinenumber(99980,10)
      let Fnprintline('IGNORE: continue')
      let Fnprintline('REPEAT: retry')
!
      close #Filenumber:
!
      if exists(setting_ScreenFolder$&"\popmem") then
         execute "copy "&setting_ScreenFolder$&"\popmem "&setting_ScreenFolder$&"\popmem.$$$"
      else
         execute "list pack endpack >"&setting_ScreenFolder$&"\popmem.$$$"
         execute "list ScreenIODims endScreenIODims >>"&setting_ScreenFolder$&"\popmem.$$$"
         execute "list ScreenDesignerDims endScreenDesignerDims >>"&setting_ScreenFolder$&"\popmem.$$$"
      end if

! .   ! Build Compile Proc
      open #(Filenumber:=Fngetfilenumber): "name="&FileName$&", replace", display, output
      print #Filenumber: "proc noecho"
      print #Filenumber: "subproc "&setting_ScreenFolder$&"\"&Lwrc$(Trim$(Screenio$(Si_Screencode)))&".brs"
      print #Filenumber: "subproc "&setting_ScreenFolder$&"\popmem.$$$"
      if Exists(setting_ScreenFolder$&"\"&Lwrc$(Trim$(Screenio$(Si_Screencode)))&".br") then
         print #Filenumber: "replace "&setting_ScreenFolder$&"\"&Lwrc$(Trim$(Screenio$(Si_Screencode)))&".br"
      else
         print #Filenumber: "save "&setting_ScreenFolder$&"\"&Lwrc$(Trim$(Screenio$(Si_Screencode)))&".br"
      end if
      print #Filenumber: "skip 4 if err==0"
      print #Filenumber: "skip 1 if err<>302"
      print #Filenumber: "pause"
      print #Filenumber: "print 'Error #'&str$(err)&' in Screen: "&trim$(screenio$(si_screencode))&". Press enter to continue.'"
      print #filenumber: "pause"
      print #Filenumber: "system"
      close #Filenumber:
!
! .   ! Compile Helper Library
      execute "system -C -M "&Fngetbrexe$&" -"&Fngetwbcfg$&" proc "&FileName$
      if WaitForComplete then
         let fnWaitForFile(dummy$,"",fileName$)
      end if
   fnend
!
COMPILESCREEN: ! Compiles One Screen's Helper Library By Screen Code (Callable From Code)
   def library fnCompileScreen(ScreenCode$*18;WaitForComplete,___,Success)
      let fnSettings ! Also includes library linkage to FileIO
      let Fnopenscreenfiles(Mat Screenio$,Mat Screenio)
      if Fnreadscreen(Uprc$(Trim$(ScreenCode$)),Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
         let Fncompilehelperlibrary(Mat Screenio$,Mat Screenio,[[Screencontrols]],"",WaitForComplete)
         let Success=1
      end if
      let fnCompileScreen=Success
   fnend
!
CHECKSCREENERRORS: ! Runs The Same Validation The "To Do" Debug Listview Shows, Callable From Code
   def library fnCheckScreenErrors(ScreenCode$*18,Mat ErrObject,Mat ErrField,Mat ErrMessage$,Mat ErrType;___,Success,ErrCnt,Index)
      let fnSettings ! Also includes library linkage to FileIO
      let Fnopenscreenfiles(Mat Screenio$,Mat Screenio)
      let Db_Warning=1 ! Normally set by Fnpaintdebugwindow, which never runs headless
      let Db_Error=2
      if Fnreadscreen(Uprc$(Trim$(ScreenCode$)),Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
         let Fnvalidatefields(Mat Screenio$,Mat Screenio,[[Screencontrols]])
         let ErrCnt=Udim(Mat Debugerror_Object)
         mat ErrObject(ErrCnt) : mat ErrField(ErrCnt) : mat ErrMessage$(ErrCnt) : mat ErrType(ErrCnt)
         for Index=1 to ErrCnt
            let ErrObject(Index)=Debugerror_Object(Index)
            let ErrField(Index)=Debugerror_Field(Index)
            let ErrMessage$(Index)=Debugerror_Message$(Index)
            let ErrType(Index)=Debugerror_Type(Index)
         next Index
         let Success=1
      end if
      let fnCheckScreenErrors=Success
   fnend
!
PRINTLINE: ! Prints A Line With A Line Number
   def Fnprintline(String$*800;SkipNumber)
      if SkipNumber then
         print #Static_Compilefile: "      "&String$
      else
         print #Static_Compilefile: Cnvrt$("PIC(#####)",Static_Linenumber)&" "&String$
         let Static_Linenumber+=Static_Increment
      end if
   fnend
SETLINENUMBER: ! Sets The Printline Linenumber, Increment, Filenumber
   def Fnsetlinenumber(Linenumber,Increment;Filenumber)
      let Static_Increment=Increment
      let Static_Linenumber=Linenumber
      if Filenumber then
         let Static_Compilefile=Filenumber
      end if
   fnend
!
   def fnGetSpecialFunctionName$*30(FunctionName$*255,Insert$)
      if FunctionName$(1:1)="{" then let FunctionName$(1:1)="fn"
      if FunctionName$(len(FunctionName$):len(FunctionName$))="}" then let FunctionName$=FunctionName$(1:len(FunctionName$)-1)
      let FunctionName$(3:2)=Insert$
      let FunctionName$=srep$(FunctionName$,"$","")
      let fnGetSpecialFunctionName$=FunctionName$(1:30)
   fnend

   def fnGetSpecialFunctionHandle$*255(FunctionHandle$*255,Insert$)
      let FunctionHandle$(2:1)=lwrc$(Insert$)
      let fnGetSpecialFunctionHandle$=FunctionHandle$
   fnend

   ! Reads the indicated file and looks for a definition of the given function.
   def fnCheckForFunction(Function$*255;Search$*255,___,FileNumber,String$*800,FoundIt)
      let Function$=Fncustomfilenameof$(Function$)
!
      open #(Filenumber:=Fngetfilenumber): "name="&Function$,display,input error IGNORE
      do While File(Filenumber)=0
         linput #Filenumber: String$ eof IGNORE
         if file(FileNumber)=0 then
            if pos(lwrc$(String$),lwrc$("def "&Search$(1:len(Search$)-1)))>0 then
               let FoundIt=1
            end if
         end if
      loop until FoundIt

      close #FileNumber:
      let fnCheckForfunction=FoundIt
   fnend

dim Const$(1)*1024, ConstName$(1)*255
dim CurrentSelect$*255, CurrentCase$(1)*255
dim Define$, Include$, Select$, Case$, CaseElse$, EndSelect$

IMPORTFUNCTION: ! Imports The Function Text From A .Brs File
   def Fnimportfunction(Function$*255,Mat Newinclude$;___,Filenumber,String$*800, ConstIndex, ConstantPosition, SkipNextOne, Constnamestartpos, Constnameendpos, Selectposition,Caseposition,Caseindex,Currentcasechunk,Nextcasechunk)
      let Function$=Fncustomfilenameof$(Function$)
!
      library setting_LexiPath$ : fnApplyLexi
      let fnApplyLexi(Function$,"tempfile[SESSION].brs",1)

      open #(Filenumber:=Fngetfilenumber): "name=tempfile[SESSION].brs",display,input error IGNORE
      if File(Filenumber)=0 then

         let Fnprintline('! Imported From "'&Function$&'"')
         do While File(Filenumber)=0
            linput #Filenumber: String$ eof IGNORE
            if File(Filenumber)=0 then
               ! Maintain Spacing
               if Trim$(String$)="" then let String$=rpt$(" ",setting_Pad_Functions)&"!"

               ! Process Include Statements
               if Pos(Lwrc$(String$),"#include") then
                  mat Newinclude$(Udim(Mat Newinclude$)+1)
                  let Newinclude$(Udim(Mat Newinclude$))=Trim$(String$(Pos(Lwrc$(String$),"#include")+8:Len(String$)))
               end if

               ! Print Line to File
               let fnPrintLine(String$,SkipNextOne)

               ! Check if we need to Skip Next One
               if Trim$(String$)(Len(Trim$(String$))-1:Len(Trim$(String$))) = "!:" then
                  let Skipnextone=1
               else
                  let SkipNextOne=0
               end if
            end if
         loop
         close #Filenumber:
      end if
   fnend

   def FnFindIncludes(Function$*255,Mat Newinclude$;___,Filenumber,String$*800,FI_Function$*255)
      let Function$=Fncustomfilenameof$(Function$)
!
      open #(Filenumber:=Fngetfilenumber): "name="&Function$,display,input error IGNORE
      if File(Filenumber)=0 then

         do While File(Filenumber)=0
            linput #Filenumber: String$ eof IGNORE
            if File(Filenumber)=0 then

               ! Process Include Statements
               if Pos(lwrc$(String$),"#include") then
                  let FI_Function$=lwrc$(Trim$(String$(Pos(Lwrc$(String$),"#include")+8:Len(String$))))
                  if srch(mat NewInclude$,FI_Function$)<=0 then
                     mat Newinclude$(Udim(Mat Newinclude$)+1)
                     let Newinclude$(Udim(Mat Newinclude$))=FI_Function$
                  end if
               end if
            end if
         loop
         close #Filenumber:
      end if
   fnend
!
CUSTOMFILENAMEOF: ! Extracts The File Name For A {Filename} Style Fn Reference
   def Fncustomfilenameof$*255(Function$*255)
      let Function$=Lwrc$(Function$)
      if ~Exists(setting_FunctionFolder$) then execute "mkdir "&setting_FunctionFolder$
      let Function$=Trim$(Function$)
      if Function$(1:1)="{" then
         let Function$=Function$(2:Len(Function$))
      end if
      if Function$(Len(Function$):Len(Function$))="}" then
         let Function$=Function$(1:Len(Function$)-1)
      end if
      let Function$=setting_FunctionFolder$&Function$&".brs"
      let Fncustomfilenameof$=Function$
   fnend
   def fnFunctionName$*255(Function$*255)
      let Function$=Lwrc$(Function$)
      let Function$=Trim$(Function$)
      if Function$(1:1)="{" then
         let Function$=Function$(2:Len(Function$))
      end if
      if Function$(Len(Function$):Len(Function$))="}" then
         let Function$=Function$(1:Len(Function$)-1)
      end if
   fnend
   def fnFunctionString$*255(FileName$*255)
      let FileName$=srep$(lwrc$(FileName$),lwrc$(setting_FunctionFolder$),"")
      let FileName$=srep$(lwrc$(FileName$),".brs","")
      let FileName$="{"&FileName$&"}"
      let fnFunctionString$=FileName$
   fnend
!
READAVAILABLEFUNCTIONS: ! Reads All Helper Function Files Into An Array
   def Fnreadavailablefunctions(Mat Functions$;___,Dirfile,Dummy$*255)
      let Fnreadfiles(Mat Functions$,setting_FunctionFolder$,"brs",1,1)
   fnend
!
   def Fnreadfiles(Mat Files$,Folder$*255;Extension$,Cleararray,Createfolder,Includeextensions,&Mask$,___,Dirfile,Dummy$*255,DirMask$*400)
      if Cleararray then mat Files$(0)
!
      if Createfolder then
         if ~Exists(Folder$) then execute "mkdir "&Folder$
      end if

      if folder$(len(Folder$):len(Folder$))="\" then let folder$=folder$(1:len(folder$)-1)
!
      if ~Len(Trim$(Extension$)) then let Extension$="*"

      if len(trim$(Mask$)) then
         let DirMask$=Folder$&"\"&fnCleanMask$(Mask$)&"."&Lwrc$(Extension$)
      else
         let DirMask$=Folder$&"\*."&Lwrc$(Extension$)
      end if
!
      execute "dir "&DirMask$&" >dirlist.[SESSION]" error IGNORE
      open #(Dirfile:=Fngetfilenumber) : "Name=dirlist.[SESSION]", display,input
      do
         linput #Dirfile: Dummy$ eof IGNORE
         if File(Dirfile)=0 And ~Pos(Dummy$,"<DIR>") then
            if Extension$="*" Or lwrc$(Extension$)=lwrc$(fnFindExtension$(dummy$)) then
               mat Files$(Udim(Files$)+1) !:
               let Files$(Udim(Files$))=Lwrc$(Trim$(Dummy$(44:99))(1:32))
               if Pos(Lwrc$(Files$(Udim(Files$))),".")>0 then
                  let Files$(Udim(Files$))=Files$(Udim(Files$))(1:Pos(Lwrc$(Files$(Udim(Files$))),".",-1)-1)
                  if Includeextensions then
                     if Extension$="*" then
                        let Files$(Udim(Files$))=Files$(Udim(Files$))&"."&lwrc$(fnFindExtension$(dummy$))
                     else
                        let Files$(Udim(Files$))=Files$(Udim(Files$))&"."&Extension$
                     end if
                  end if
               end if
            end if
         end if
      loop While File(Dirfile)=0
      close #Dirfile:
      execute "free dirlist.[SESSION]"
   fnend

   def fnFindExtension$(DirListLine$*255;___,D,P)
      if len(Trim$(DirListLine$(11:13))) then
         let fnFindExtension$=DirListLine$(11:13)
      else
         let DirListLine$=rtrm$(DirListLine$)
         let P=len(DirListLine$)
         let D=pos(DirListLine$,".",-1)
         if D>0 then
            let fnFindExtension$=DirListLine$(D+1:P)
         end if
      end if
   fnend
!
   def fnCleanMask$*80(&Mask$;___,Index,OutMask$*80)
      let Mask$=trim$(Mask$)
      if pos(Mask$,"\") then
         let Mask$=Mask$(pos(Mask$,"\"):len(Mask$))
      end if
      if pos(Mask$,".") then
         let Mask$=Mask$(1:pos(Mask$,"."))
      end if
      let OutMask$=""
      for Index=1 to len(Mask$)
         if pos("abcdefghijklmnopqrstuvwxyz?*",lwrc$(Mask$(Index:Index))) then
            let OutMask$=OutMask$&Mask$(Index:Index)
         end if
      next Index
      let Mask$=OutMask$
      let fnCleanMask$=OutMask$
   fnend
!
READCUSTOMFUNCTION: ! Reads The Given Custom Function Into A Long String With Embedded Crs (Chr$(13))
   def Fnreadcustomfunction$*2000(Filename$*255;___,Filenumber,String$*800,Functiontext$*2000,Done)
      let Filename$=Fncustomfilenameof$(Filename$)
!
      if Exists(Filename$) then
         open #(Filenumber:=Fngetfilenumber): "name="&Filename$,display,input error IGNORE
         if File(Filenumber)=0 then
            do While File(Filenumber)=0
               linput #Filenumber: String$ eof IGNORE
               if File(Filenumber)=0 then
                  if Len(String$)+1+Len(Functiontext$)<2000 then
                     let Functiontext$=Functiontext$&hex$("0D0A")&String$
                  else
                     let Done=1
                  end if
               end if
            loop Until Done
            close #Filenumber:
         end if
      end if
      let Fnreadcustomfunction$=Functiontext$
   fnend
!
READCUSTOMFUNCTIONSTATEMENT: ! Reads And Calculates The Custom Function Call Statement From The Given File
   def Fnreadcustomfunctionstatement$*255(Filename$*255;___,Filenumber,String$*800,Functioncall$*800,Done,Starfound,Comma,Semicolon,Leftparen,Rightparen,Numberend)
!
      let Filename$=Fncustomfilenameof$(Filename$)
!
      if Exists(Filename$) then
         open #(Filenumber:=Fngetfilenumber): "name="&Filename$,display,input error IGNORE
         if File(Filenumber)=0 then
            do While File(Filenumber)=0
               linput #Filenumber: String$ eof IGNORE
               if File(Filenumber)=0 then
                  if Pos(Lwrc$(String$),"def fn") then
                     let Functioncall$=String$
                     let Done=1
                  end if
               end if
            loop Until Done
            close #Filenumber:
         end if
      end if
!
      if Len(Trim$(Functioncall$)) then
         let Functioncall$=Functioncall$(Pos(Lwrc$(Functioncall$),"def fn")+4:Len(Functioncall$))
         if Pos(Functioncall$,"(;") then let Functioncall$=Functioncall$(1:Pos(Functioncall$,"(;")-1)
         if Pos(Functioncall$,";") then let Functioncall$=Functioncall$(1:Pos(Functioncall$,";")-1)&")"
         let Functioncall$=Srep$(Functioncall$,"&","")
!
         do While (Starfound:=Pos(Functioncall$,"*"))
            let Comma=Pos(Functioncall$,",",Starfound)
            let Semicolon=Pos(Functioncall$,";",Starfound)
            let Leftparen=Pos(Functioncall$,"(",Starfound)
            let Rightparen=Pos(Functioncall$,")",Starfound)
            if Comma<Starfound then let Comma=9999
            if Semicolon<Starfound then let Semicolon=9999
            if Leftparen<Starfound then let Leftparen=9999
            if Rightparen<Starfound then let Rightparen=9999
            let Numberend=Min(Comma,Semicolon,Leftparen,Rightparen)-1
            let Functioncall$(Starfound:Numberend)=""
         loop
      end if
!
      let Fnreadcustomfunctionstatement$=Functioncall$
!
   fnend
!
CREATENEWFUNCTION: ! Creates A New Blank Function File
   def Fncreatenewfunction(Function$*255;FunctionType,SubType,___,Filename$*255,Filenumber,Padding$)
!
      let Filename$=Fncustomfilenameof$(Function$)
      let Function$=Trim$(Function$)
      if Function$(1:1)="{" then let Function$=Function$(2:Len(Function$))
      if Function$(Len(Function$):Len(Function$))="}" then let Function$=Function$(1:Len(Function$)-1)

      let Padding$=rpt$(" ",setting_Pad_Functions)
!
      if ~Exists(Filename$) then
         open #(Filenumber:=Fngetfilenumber): "name="&Filename$&",new,recl=800",display,output error IGNORE
         if File(Filenumber)=0 then
            print #Filenumber: Padding$&"! "&Filename$
            print #Filenumber: Padding$&"! Created on "&Date$("mm/dd/ccyy")
            print #Filenumber: Padding$&"!"
            print #Filenumber: Padding$&"! fn"&Function$&" - This function ..."
            print #Filenumber: Padding$&"!"

            if setting_DetailedComments then
               let fnPrintCustomFunctionComment(FileNumber,FunctionType,SubType)
            end if

            print #Filenumber: Padding$&"!"
            print #Filenumber: Padding$&"def fn"&Function$
            print #Filenumber: Padding$
            print #Filenumber: Padding$
            print #Filenumber: Padding$&"fnend"
            if FunctionType=2000+sf_function and SubType=4 then
               print #Filenumber: Padding$
               print #Filenumber: Padding$
               print #Filenumber: Padding$&"! This function is run before the listview starts loading. Put any code here"
               print #Filenumber: Padding$&"!  that you need to run prior to loading the listview."
               print #Filenumber: Padding$&"def "&fnGetSpecialFunctionName$("fn"&Function$,"Init_")
               print #Filenumber: Padding$
               print #Filenumber: Padding$
               print #Filenumber: Padding$&"fnend"
               print #Filenumber: Padding$
               print #Filenumber: Padding$&"! This function is run after the listview has finished loading. Put any code here"
               print #Filenumber: Padding$&"!  that you want to run when the listview finishes populating."
               print #Filenumber: Padding$&"def "&fnGetSpecialFunctionName$("fn"&Function$,"Final_")
               print #Filenumber: Padding$
               print #Filenumber: Padding$
               print #Filenumber: Padding$&"fnend"
            end if
            close #Filenumber:
         end if
      end if
   fnend

   def fnPrintCustomFunctionComment(FileNumber,FunctionType,SubType;___,Padding$)
      let Padding$=rpt$(" ",setting_Pad_Functions)
      print #Filenumber: Padding$&"!"
      print #Filenumber: Padding$&"! Fill in the comment above with a description of what this"
      print #Filenumber: Padding$&"! particular function does."
      print #Filenumber: Padding$&"!"
      print #Filenumber: Padding$&"!"
      #Select# FunctionType #Case# 0
      #Case# 1000+si_enterfn
         print #Filenumber: Padding$&"! This is an Enter Event Function. When selected as the Enter"
         print #Filenumber: Padding$&"! Event for your screen, this function runs after the screen"
         print #Filenumber: Padding$&"! has loaded but before the screen is drawn and before the"
         print #Filenumber: Padding$&"! record is read."
      #Case# 1000+si_initfn
         print #Filenumber: Padding$&"! This is an Initialize Event Function. When selected as the Init"
         print #Filenumber: Padding$&"! Event for your screen, this function runs only when the user is"
         print #Filenumber: Padding$&"! adding a new record to the data file. Use this event in your Add/Edit"
         print #Filenumber: Padding$&"! screens to initialize the new record and preform any other tasks that"
         print #Filenumber: Padding$&"! need to run each time a record is added. It is not run when Reading"
         print #Filenumber: Padding$&"! an existing record (See the Read Event for that)."
      #Case# 1000+si_readfn
         print #Filenumber: Padding$&"! This is a Read Event Function."
         print #Filenumber: Padding$&"! "
         print #Filenumber: Padding$&"! When used in an Add/Edit screen, this function runs"
         print #Filenumber: Padding$&"! only when the user is editing an existing record in"
         print #Filenumber: Padding$&"! a data file. Use this event to unpack the new record"
         print #Filenumber: Padding$&"! and preform any other tasks that need to run at read time."
         print #Filenumber: Padding$&"! This function runs just after the record is read. It is"
         print #Filenumber: Padding$&"! not run when Adding a record. (See Initialize Event)"
         print #Filenumber: Padding$&"!"
         print #Filenumber: Padding$&"! When used in a Listview screen, this function runs each time"
         print #Filenumber: Padding$&"! the user's selection on the listview has changed. You can use it"
         print #Filenumber: Padding$&"! to update related fields when the listview selection changes"
         print #Filenumber: Padding$&"! in realtime. It can slow things down, so use it with caution"
         print #Filenumber: Padding$&"! and make sure your code here is as effecient as possible."
      #Case# 1000+si_loadfn
         print #Filenumber: Padding$&"! This is a Load Event Function. It runs after the record is"
         print #Filenumber: Padding$&"! read and the screen has finished loading, but before the"
         print #Filenumber: Padding$&"! screen is run. Use it to perform user interactions and other"
         print #Filenumber: Padding$&"! tasks that you want to run after the screen is drawn and"
         print #Filenumber: Padding$&"! before starting your program."
      #Case# 1000+si_writefn
         print #Filenumber: Padding$&"! This is a PreWrite Event Function. When used in an Add/Edit screen,"
         print #Filenumber: Padding$&"! this function runs only when the user exited the screen and chose"
         print #Filenumber: Padding$&"! to save the data. This function is run before the data is written."
         print #Filenumber: Padding$&"!"
         print #Filenumber: Padding$&"! This is a good place to do full record validations that can't be"
         print #Filenumber: Padding$&"! done as you're going along. You can cancel the Exit by setting"
         print #Filenumber: Padding$&"! ExitMode to 0."
      #Case# 1000+si_waitfn
         print #Filenumber: Padding$&"! This is a Wait Event Function. It is called when the user has"
         print #Filenumber: Padding$&"! been idle for a long time (configurable in Screen Attributes)."
         print #Filenumber: Padding$&"! If not specified, the default ScreenIO Idle Message window"
         print #Filenumber: Padding$&"! appears instead. Ues this function to change the default"
         print #Filenumber: Padding$&"! idle behavior for your program."
      #Case# 1000+si_lockedfn
         print #Filenumber: Padding$&"! This is a Locked Event Function. Use this to override the default"
         print #Filenumber: Padding$&"! ScreenIO Locked Record behavior. This is run whenever a user attempts"
         print #Filenumber: Padding$&"! to edit a record but the record is locked (currently being edited) by"
         print #Filenumber: Padding$&"! another user."
      #Case# 1000+si_mergefn
         print #Filenumber: Padding$&"! This is a Merge Event Function. Its called when standard record"
         print #Filenumber: Padding$&"! locking is disabled and instead multiple users are allowed to"
         print #Filenumber: Padding$&"! edit the record, and the system attempts to merge their changes."
         print #Filenumber: Padding$&"! If you select that option, screenIO automatically merges the changes."
         print #Filenumber: Padding$&"! You can use this Merge function to override the default ScreenIO"
         print #Filenumber: Padding$&"! merging behavior."
      #Case# 1000+si_loopfn
         print #Filenumber: Padding$&"! This is a Main Loop Event Function. This code is run every time"
         print #Filenumber: Padding$&"! the user does anything on your screen. Use it to handle special"
         print #Filenumber: Padding$&"! user interactions such as custom Fkeys and double clicks."
      #Case# 1000+si_nokeyfn
         print #Filenumber: Padding$&"! This is a NoKey Event Function. This function is called"
         print #Filenumber: Padding$&"! any time the selected key is not found when attempting to"
         print #Filenumber: Padding$&"! edit. If this function is not specified, ScreenIO Defaults"
         print #Filenumber: Padding$&"! to displaying a message to the end user indicating that the"
         print #Filenumber: Padding$&"! key could not be found."
      #Case# 1000+si_prelistviewfn
         print #Filenumber: Padding$&"! This is a Pre-Listview Populate Event Function. When used in"
         print #Filenumber: Padding$&"! a Listview Screen, this code is run just prior to the listview"
         print #Filenumber: Padding$&"! being populated. Use this function to open related reference"
         print #Filenumber: Padding$&"! data files that you want to read during the populate, or to"
         print #Filenumber: Padding$&"! preposition the record pointer in the data file."
      #Case# 1000+si_postlistviewfn
         print #Filenumber: Padding$&"! This is a Post-Populate Listview Event Function. When used in"
         print #Filenumber: Padding$&"! a Listview Screen, this code runs just after the listview is"
         print #Filenumber: Padding$&"! populated. Use it to close data files you might have opened"
         print #Filenumber: Padding$&"! during Pre-Populate."
      #Case# 1000+si_exitfn
         print #Filenumber: Padding$&"! This is an Exit Event Function. You can use it to close data"
         print #Filenumber: Padding$&"! files that you opened during the Enter event. It runs when the"
         print #Filenumber: Padding$&"! screen is already closing, and the record has already been"
         print #Filenumber: Padding$&"! written. It is too late to cancel the close here."
      #Case# 2000+sf_function
         if ~SubType or SubType=1 then
            print #Filenumber: Padding$&"! This is a Click Event function. It runs when the user Clicks"
            print #Filenumber: Padding$&"! on the Control it is the click event for."
         else if SubType=2 then
            print #Filenumber: Padding$&"! This is a Validate Event Function. This function runs any time"
            print #Filenumber: Padding$&"! the control has been changed by the user."
            print #Filenumber: Padding$&"!"
            print #Filenumber: Padding$&"! (To make it run as soon as it is changed, consider adding the"
            print #Filenumber: Padding$&"! ""X"" attribute to the control.)"
         else if SubType=3 then
            print #Filenumber: Padding$&"! This function is both the Populate and Validate functions"
            print #Filenumber: Padding$&"! for a Combo Box control. To use it, set the contents of an"
            print #Filenumber: Padding$&"! array called ReturnData$ and ScreenIO will populate that"
            print #Filenumber: Padding$&"! data into the Combo Box."
            print #Filenumber: Padding$&"!"
            print #Filenumber: Padding$&"! It is also a Validate event, so make sure to have your function"
            print #Filenumber: Padding$&"! return true in order accept the users changes to the control."
         else if SubType=4 then
            print #Filenumber: Padding$&"! This function is the Filter function for the listview. It is run"
            print #Filenumber: Padding$&"! as the listview is being populated, and it runs once for every"
            print #Filenumber: Padding$&"! record in the data file, so be careful to make your code run as"
            print #Filenumber: Padding$&"! quickly as possible."
            print #Filenumber: Padding$&"!"
            print #Filenumber: Padding$&"! Here you can unpack special fields from the data on disk to"
            print #Filenumber: Padding$&"! the listview if you want to, or color the row by returning html"
            print #Filenumber: Padding$&"! or an [ATTRIBUTE] substitution from your brconfig.sys (or"
            print #Filenumber: Padding$&"! settings.sys) file."
            print #Filenumber: Padding$&"!"
            print #Filenumber: Padding$&"! You can also test the data and include or exclude rows in the data"
            print #Filenumber: Padding$&"! file. If your Filter function returns 1 (True) or non-blank (for example,"
            print #Filenumber: Padding$&"! a Color or [Attribute]), then the row is included in the listview."
            print #Filenumber: Padding$&"! If your function returns 0 (False) or Blank, then the row is excluded."
            print #Filenumber: Padding$&"!"
            print #Filenumber: Padding$&"! Make sure your filter function returns something. If you want to"
            print #Filenumber: Padding$&"! see all the rows in the list, make your function return 1 (True)."
            print #Filenumber: Padding$&"!"
            print #Filenumber: Padding$&"! Use the fnInit_ and fnFinal_ functions below, to open and close any needed"
            print #Filenumber: Padding$&"! reference data files, initialize counters, and stuff like that."
         else if SubType=5 then
            print #Filenumber: Padding$&"! This function should not be used for Child Screen controls. Instead"
            print #Filenumber: Padding$&"! of linking to a custom function, use the field to pass in parameters"
            print #Filenumber: Padding$&"! to your Child Screen. "
         end if
      #Case# 2000+sf_cnvrtin
         print #Filenumber: Padding$&"! This is a ConvertIn Function. Normally, you would specify a"
         print #Filenumber: Padding$&"! ScreenIO Conversion Spec such as FMT(, PIC( or DATE( instead"
         print #Filenumber: Padding$&"! of linking to a custom function. This custom function won't"
         print #Filenumber: Padding$&"! be run by ScreenIO."
      #Case# 2000+sf_cnvrtout
         print #Filenumber: Padding$&"! This is a ConvertOut Function. It isn't supported yet."
         print #Filenumber: Padding$&"! This custom function won't be run by ScreenIO."
      #End Select#
   fnend

   def fnSubType(FieldType$)
      #Select# lwrc$(trim$(FieldType$)) #Case# "p" # "button" # "caption" # "calendar"
         let fnSubType=1
      #Case# "c" # "search" # "filter" # "check"
         let fnSubType=2
      #Case# "combo"
         let fnSubType=3
      #Case# "listview"
         let fnSubType=4
      #Case# "screen"
         let fnSubType=5
      #Case Else#
         let fnSubType=0
      #End Select#
   fnend
!
EDITCUSTOMFUNCTION: ! Launches Code Editor To Edit The Given Function File
   def Fneditcustomfunction(Filename$*255)
!
      let Filename$=Fncustomfilenameof$(Filename$)
!
      if Exists(Filename$) then
         execute "system -C -M start "&os_filename$(Filename$)
      end if
   fnend
!
   def library Fnselectevent$*255(&Current$;&Returnfkey)
      let Fnselectevent$=Fnselectfunctiondialog$(Current$,Returnfkey)
   fnend
!
   dim FunctionSelection(1)

SELECTFUNCTIONDIALOG: ! Displays The Select Function Dialog.
   def Fnselectfunctiondialog$*255(Current$*255;&Returnfkey,FunctionType,SubType,___,SelectionCount,FunctionName$*255,Screenrows,Screencols,Rpos,Cpos,Window,Textboxwindow,Selectedfunction$*255,Functiontext$*2000,Currentselection,Newselection,Currentfield,Buttontext$,Tempselection,Index,Done,FilterBox$*60)
!
      dim Lvsf_Name$(1)
      dim Lvsf_Width(1)
      dim Lvsf_Spec$(1)
      dim Lvsf_Fnfl$(1)*80
!
      let Lvsf_Name$(1)="Function Files"
      let Lvsf_Width(1)=25
      let Lvsf_Spec$(1)="C 80,X"
!
      let Selectedfunction$=Current$(1:28)
      !let Selectedfunction$=fnFunctionName$(Lwrc$(Current$(1:28)))
      ! let Selectedfunction$=Selectedfunction$(10:Len(Selectedfunction$)-4)
!
      let Fnreadavailablefunctions(Mat Lvsf_Fnfl$)
!
      let Newselection=1
      let Currentfield=1
!
      let Fngetscreensize(Screenrows,Screencols)
      if ~Screenrows Or ~Screencols then
         let Fnreadscreensize(Screenrows,Screencols)
      end if
!
      let Rpos=Int((Screenrows-24)/2)
      let Cpos=Int((Screencols-85)/2)
!
      open #(Window:=Fngetfilenumber) : "srow="&Str$(Rpos)&",scol="&Str$(Cpos)&",rows=24,cols=85,border=S,caption=Select Function", display, outin
      open #(Textboxwindow:=Fngetfilenumber) : "srow=2,scol=28,rows=20,cols=56,parent="&Str$(Window),display,outin
!
      print #Window, fields "2,2,LIST 20/25,HEADERS,/W:W" : (Mat Lvsf_Name$,Mat Lvsf_Width,Mat Lvsf_Spec$)
      print #Window, fields "2,2,LIST 20/25,=" : (Mat Lvsf_Fnfl$)
      print #Window, fields "2,2,LIST 20/25,SORT" : 1
      print #Window, fields "23,42,CC 6,/W:W,B34;23,50,CC 6,/W:W,B35;23,58,CC 6,/W:W,B99;23,66,12/CC 16,/W:W,B37" : "New","Ok","Cancel","Affected Screens"
      print #Window, fields "23,2,P 1/2,,1004" : setting_ImagePath$&"\search.png"
!
      execute "config keyboard clear"
      execute "config keyboard 0B00 0A0A0A636F6E206B657920636C6561720D" ! Shift F1 Key To "con key clear<CR>"
!
      execute "config keyboard 0B 0F00" ! Up To Shift F5 (Fkey 15)
      execute "config keyboard 0A 1000" ! Dn To Shift F6 (Fkey 16)
!
      execute "config keyboard 09 1100" ! Tab To Shift F7 (Fkey 17)
      execute "config keyboard 07 1100" ! Shift Tab To Shift F7 (Fkey 17)
!
      do
         if Udim(Mat Lvsf_Fnfl$) then
            if Newselection<>Currentselection then
               let Functiontext$=Fnreadcustomfunction$(Lvsf_Fnfl$(Newselection))
               if fn42ia then
                  let FunctionText$=srep$(FunctionText$,hex$("0D0A"),hex$("0D"))
                  let FunctionText$=srep$(FunctionText$,hex$("0A"),hex$("0D"))
                  let FunctionText$=srep$(FunctionText$,hex$("0D"),hex$("0D0A"))
                  if fn42jd then
                     print #Textboxwindow, fields "1,1,1120/C 2000,S^ENTER_CRLF" : Functiontext$
                  else
                     print #Textboxwindow, fields "1,1,1120/C 2000,S^ENTER-CRLF" : Functiontext$
                  end if
               else
                  print #Textboxwindow, fields "1,1,1120/C 2000,S" : Functiontext$
               end if
               let Currentselection=Newselection
            end if
         end if
!
         if Currentfield=2 then
            let Curfld(Currentfield,Currentselection)
         else
            let Curfld(Currentfield)
         end if

         if fn43 and setting_FunctionSel_Filter then
            let FilterBox$="23,5,35/FILTER 28,X/W:W,2,2,FULLROW,ALL"
         else
            let FilterBox$="23,5,35/SEARCH 28,X/W:W,2,2"
         end if

         if Udim(Mat Lvsf_Fnfl$) then
            print #Window, fields FilterBox$ : Selectedfunction$
            if Currentfield=1 then
               input #Window, fields FilterBox$&";2,2,LIST 20/25,ROWSUB,SELONE,1005" : Selectedfunction$,NewSelection error ignore
            else
               input #Window, fields FilterBox$&";2,2,LIST 20/25,ROWSUB,SELONE,-1" : Selectedfunction$,NewSelection error ignore
            end if
            ! if (udim(mat FunctionSelection)) then
            !    let NewSelection=FunctionSelection(1)
            ! else
            !    let NewSelection=-1
            ! end if
            /* if SelectionCount>0 then
               input #Window, fields "2,2,LIST 20/25,ROWSUB,SELONE,NOWAIT" : NewSelection
            else
               let NewSelection=-1
            end if */
         else
            rinput #Window, fields "23,5,35/C 28,X" : Selectedfunction$
         end if
!
         let Selectedfunction$=Trim$(Selectedfunction$)(1:28)
         for Index=1 to Len(Selectedfunction$)
            if ~Pos("abcdefghijklmnopqrstuvwxyz0123456789_",Lwrc$(Selectedfunction$(Index:Index))) then
               let Selectedfunction$(Index:Index)="_"
            end if
         next Index
!
         if Currentfield=1 then ! We Are In The Search Box
            if Fkey=15 then ! Up
               let Currentfield=2
               let Tempselection=Srch(Mat Lvsf_Fnfl$,Lwrc$(Trim$(Selectedfunction$)))
               if Tempselection>0 then let Newselection=Tempselection
            end if
            if Fkey=16 then ! Dn
               let Currentfield=2
               let Tempselection=Srch(Mat Lvsf_Fnfl$,Lwrc$(Trim$(Selectedfunction$)))
               if Tempselection>0 then let Newselection=Tempselection
            end if
         else ! We Are In The Listview
            if Fkey=15 then ! Up
               if Newselection<=1 then let Currentfield=1 else let Newselection-=1
            end if
            if Fkey=16 then ! Dn
               if Newselection=>Udim(Lvsf_Fnfl$) then let Currentfield=1 else let Newselection+=1
            end if
         end if
         if Fkey=17 Or Fkey=200 then ! Tab Or Shift Tab Or Click On Other Control
            if Currentfield=1 then let Currentfield=2 else let Currentfield=1
            If Currentfield=2 Then
               if fn42 then Input #Window, Fields "2,2,LIST 20/25,ROWSUB,NEXT,NOWAIT" : Newselection
            End If
         end if
         if Fkey=1005 then ! Listview Clicked On
            let Currentfield=2
            if fn42 then Input #Window, Fields "2,2,LIST 20/25,ROWSUB,NEXT,NOWAIT" : Newselection
         end if
         if Fkey=1004 then ! Search Box Clicked On
            let Currentfield=1
         end if
         if Fkey=34 then ! New Button Clicked On
            if len(trim$(SelectedFunction$)) then
               if 2=Msgbox("Do you wish to create "&Selectedfunction$&".brs","Proceed?","yN","QST") then
                  let Fncreatenewfunction(Selectedfunction$,FunctionType,SubType)
                  let Fneditcustomfunction(Selectedfunction$)
                  let Fnreadavailablefunctions(Mat Lvsf_Fnfl$)
                  let Currentfield=2
                  let Newselection=Srch(Mat Lvsf_Fnfl$,Lwrc$(Trim$(Selectedfunction$)))
                  if Newselection>0 then let Fkey(35) ! New Button Also Selects
                  print #Window, fields "2,2,LIST 20/25,=" : (Mat Lvsf_Fnfl$)
               end if
            else
               let msgbox("Please type a name for your new function.","No Name Given")
            end if
         end if
         if Fkey=37 then
            dim SelFunction(1)
            dim SelFunction$(1)*255

            let SelFunction(1)=1
            let SelFunction$(1)="{"&Lvsf_Fnfl$(Newselection)&"}"
            let Done=fnCEAffectedScreenList(mat SelFunction,mat SelFunction$)
            let fkey(-1) ! Clear fkey
         end if
      loop Until Fkey=99 Or Fkey=35 Or ((Fkey>1100) And (Fkey<1699)) Or Fkey=98 Or Fkey=93 Or Done
!
      execute "config keyboard clear"
!
      if Fkey=35 then
         let Selectedfunction$=Lvsf_Fnfl$(Newselection)
         let Selectedfunction$="{"&Trim$(Selectedfunction$)&"}"
      else
         let Selectedfunction$=Current$
      end if
      if Fkey<>99 And Fkey<>35 then
         let Returnfkey=Fkey
      end if
      if Done then
         let ReturnFkey=99
      end if
!
      let Fnselectfunctiondialog$=Selectedfunction$
!
      if TextBoxWindow and File(TextboxWindow)>-1 then close #Textboxwindow:
      if Window and File(Window)>-1 then close #Window:
!
   fnend
!
! *****************************************************************
! ******************* Validate And Render Screen ******************
! *****************************************************************
VALIDATEFIELDS: !  Validate All Data And Populate Todo Listview
   def Fnvalidatefields(Mat Screenio$, Mat Screenio, [[Screencontrols]];___,Index,Index,Mode,Object,Message$*255,Jndex,Goodfunk,Funk$*255,LVCount,BadLV)
!
      let Fncleardebuglistview
!
! .       !  Validate Header Fields
      if Trim$(Screenio$(Si_Screencode))="" then
         let Fnprinttodebuglistview(Inputattributesmode,Si_Screencode,"Window Name cannot be blank.",Db_Error)
      end if
!
      if Trim$(Screenio$(Si_Picture))<>"" And ~Exists(Screenio$(Si_Picture)) then
         let Fnprinttodebuglistview(Inputattributesmode,Si_Picture,"Picture does not exist.",Db_Error)
      end if
!
      if Trim$(Screenio$(Si_Filelay))="" then
         let Fnprinttodebuglistview(SelectFilelayMode,si_filelay,"You should enter a file layout.",Db_Warning)
      end if
!
      if Trim$(Screenio$(Si_Filelay))<>"" And ~Fndoeslayoutexist(Screenio$(Si_Filelay)) then
         let Fnprinttodebuglistview(SelectFilelayMode,si_filelay,"File layout not found.",Db_Error)
      end if

      let LVCount=BadLV=0
      for Index=1 to udim(mat ControlName$)
         if lwrc$(trim$(FieldType$(Index)))="listview" then
            let LVCount+=1
            let BadLV=Index
         end if
      next Index

      if LVCount>1 then
         let Fnprinttodebuglistview(InputEditorMode,BadLV,"You have 2 listviews. One of them will be inactive when running your screen.",Db_Warning)
      end if
!
      for Index=1 to Udim(Mat Controlname$)
         if Lwrc$(Trim$(Fieldtype$(Index)))<>"listchld" then
            let Mode=1
            if ~Fnvalidspec(Index,Mat Screenio$,Mat Screenio, [[Screencontrols]],Mode,Object,Message$) then
               let Fnprinttodebuglistview(Mode,Object,Message$,Db_Error)
            end if
            if ~Fnvalidattribute(Attr$(Index),FieldType$(Index)) then
               let Fnprinttodebuglistview(Inputeditormode,Index,"Invalid attribute Specified for Control "&Str$(Index)&".",Db_Error)
            end if
         end if
!
         if Function$(Index)<>"" And Function$(Index)(1:1)<>"{" And Function$(Index)(1:1)<>"[" And Function$(Index)(1:1)<>"%" And Function$(Index)(1:1)<>"#" then
            let Funk$=Trim$(Function$(Index))
            let Goodfunk=0
            for Jndex=1 to Len(Funk$)
               if ~Pos("abcdefghijklmnopqrstuvwxyz",Lwrc$(Funk$(Jndex:Jndex))) then let Goodfunk=1
            next Jndex
            if ~Goodfunk then
               let Fnprinttodebuglistview(Inputeditormode,Index,"Control "&Str$(Index)&"'s Function doesn't look right. It doesn't do anything.",Db_Warning)
            end if
         end if
!
         if Trim$(Controlname$(Index))="" And Trim$(Fieldname$(Index))="" then
            #Select# Lwrc$(Trim$(Fieldtype$(Index))) #Case# "listchld" # "c"
               let Fnprinttodebuglistview(Inputeditormode,Index,"Control "&Str$(Index)&" has no source. It needs either a Control Name or a Field Name.",Db_Warning)
            #Case# "button" # "caption" # "picture"
               if Trim$(Description$(Index))="" then
                  let Fnprinttodebuglistview(Inputeditormode,Index,"Control "&Str$(Index)&" has no source. It needs either a Control Name or a Caption.",Db_Warning)
               end if
            #End Select#
         end if
!
         #Select# Lwrc$(Trim$(Fieldtype$(Index))) #Case# "c"
            if Trim$(Fieldname$(Index))="" then
!                Let Fnprinttodebuglistview(Inputeditormode,Index,"Control "&Str$(Index)&" is not tied to a field.",Db_Warning)
            end if
!
         #Case# "button"
            if Trim$(Function$(Index))="" then
               let Fnprinttodebuglistview(Inputeditormode,Index,"Control "&Str$(Index)&" has no function.",Db_Warning)
            end if
!
         #Case# "p"
            if Trim$(Picture$(Index))="" then
!              Let Fnprinttodebuglistview(Inputeditormode,Index,"Control "&Str$(Index)&" has no picture assigned.",Db_Warning)
            else if ~Exists(Trim$(Picture$(Index))) then
               let Fnprinttodebuglistview(Inputeditormode,Index,"Picture File "&Trim$(Picture$(Index))&" could not be found.",Db_Error)
            end if

         #Case# "calendar"
            ! $$$$$  Give a warning if its not tied to any text box

!
         #Case# "caption"
            if Trim$(Description$(Index))="" then
!               Let Fnprinttodebuglistview(Inputeditormode,Index,"Control "&Str$(Index)&" has no caption set.",Db_Warning)
            end if
!
         #Case# "listview"
            if ~Fncountcolumns(Parent$(Index),[[Screencontrols]]) then
               let Fnprinttodebuglistview(Inputlistviewmode,Index,"Listview "&Str$(Index)&" has no columns.",Db_Error)
            end if

         #Case# "search"
            if ~(Target:=Fnfindtarget(Parent$(Index),[[Screencontrols]])) then
               let Fnprinttodebuglistview(Inputeditormode,Index,"Search Box "&Str$(Index)&" is not tied to a listview.",Db_Error)
            else if Specwidth(Target)=0 then
               let Fnprinttodebuglistview(Inputeditormode,Target,"Listview "&Str$(Index)&" has a Search Box but no Sort Column.",Db_Warning)
            end if

         #Case# "filter"
            if ~(Target:=Fnfindtarget(Parent$(Index),[[Screencontrols]])) then
               let Fnprinttodebuglistview(Inputeditormode,Index,"Filter Box "&Str$(Index)&" is not tied to a listview.",Db_Error)
            else
               let fnCleanFilter(Picture$(Index))
               if lwrc$(Picture$(Index))(1:4)><"full" then
                  if val(Picture$(Index)(1:pos(Picture$(Index),",")-1))>fnCountColumns(Parent$(Index),[[Screencontrols]]) then
                     let fnPrintToDebugListview(InputEditorMode,Index,"Filter Box "&str$(Index)&" is tied to a column that doesn't exist.",Db_Error)
                  end if
               end if
            end if
!
         #Case# "screen"
            If lwrc$(trim$(FieldName$(Index)))=lwrc$(trim$(screenio$(si_screencode))) then
               let Fnprinttodebuglistview(Inputeditormovemode,Index,"It's probably not a good idea to place a screen on top of itself.",Db_Error)
            end if
         #End Select#
      next Index
      let Fnvalidatefields=1 !   True For Now
!
   fnend
!
RENDERSCREEN: ! Draw All Valid Controls On The Screen
   def Fnrenderscreen(Mat Screenio$, Mat Screenio, [[ScreenControls]];Dontclear,___,Index,Window,Arrayindex)
      dim Renderspec$(1)*255, Renderdata$(1)*255
!
      mat Renderspec$(0)
      mat Renderdata$(0)
!
      let Window=Fngeteditorwindow
      let fnDrawFrames(Window,mat ScreenIO$,mat ScreenIO,[[ScreenControls]])
      let fnDrawScreens(Window,mat ScreenIO$,mat ScreenIO,[[ScreenControls]])

      for Index=1 to Udim(Mat Controlname$)
         if ((Lwrc$(Trim$(Fieldtype$(Index)))<>"listview") And (Lwrc$(Trim$(Fieldtype$(Index)))<>"listchld") And (Lwrc$(Trim$(Fieldtype$(Index)))<>"frame") And (Lwrc$(Trim$(Fieldtype$(Index)))<>"screen")) then
            if Fnvalidspec(Index,Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
               let Arrayindex=Udim(Mat Renderspec$)+1
               mat Renderdata$(Arrayindex)
               mat Renderspec$(Arrayindex)
               let Renderdata$(Arrayindex)=Fncalculatedata$(Index,[[Screencontrols]])
               let Renderspec$(Arrayindex)=Fncalculatespec$(Window,Index,[[Screencontrols]],0,1)
            end if
         end if
      next Index

      let fnChangeForceVisibility(1)
      if ~Dontclear then
         print #Window: Newpage
         let DotsPrinted=0 ! Dots were erased
         let SettingTempDots=0
      end if
      print #Window, fields Mat Renderspec$ : Mat Renderdata$
      let fnChangeForceVisibility(0)

      let Fndrawalllistviews(Window,Mat Screenio$,Mat Screenio,[[Screencontrols]])
      let Fntrytopopulatelistviews(Window,Mat Screenio$,Mat Screenio,[[Screencontrols]])
   fnend
!
VALIDSPEC: ! Returns True If A Spec Is Valid, Sets Object, Control, Message If Not
   def Fnvalidspec(Control,Mat Screenio$,Mat Screenio, [[Screencontrols]];&Mode,&Object,&Message$,_,Index,Valid,Testrow, Testcol,frameControl,otherControl,Inside,SetInside)
      let Valid=1 !  Spec Starts Out Valid
      if Hposition(Control)+(Width(Control)+(2*(lwrc$(trim$(Fieldtype$(Control)))=="combo"))-1)>Screenio(Si_Hsize) then
         let Valid=0 ! Not Valid
         if Mode then
            let Mode=Inputeditormode
            let Object=Control
            let Message$="Control is outside right boundary of Window."
         end if
      end if
      if Vposition(Control)+(Max(Height(Control),1)-1)>Screenio(Si_Vsize) then
         let Valid=0
         if Mode then
            let Mode=Inputeditormode
            let Object=Control
            let Message$="Control is outside bottom boundary of Window."
         end if
      end if
      if Valid then ! If Still Valid
         if Lwrc$(Trim$(Fieldtype$(Control)))<>"listchld" and Lwrc$(Trim$(Fieldtype$(Control)))<>"screen" then
            for Index=1 to Control-1
               let SetInside=0
               let Inside=0
               if Lwrc$(Trim$(Fieldtype$(Index)))<>"listchld" and Lwrc$(Trim$(Fieldtype$(Control)))<>"screen" then
                  if Lwrc$(Trim$(Fieldtype$(Control)))="frame" and Lwrc$(Trim$(Fieldtype$(Index)))="listview" or Lwrc$(Trim$(Fieldtype$(Index)))="frame" and Lwrc$(Trim$(Fieldtype$(Control)))="listview" or Lwrc$(Trim$(Fieldtype$(Control)))<>"frame" and Lwrc$(Trim$(Fieldtype$(Index)))<>"frame" then
                     for Testrow=Vposition(Control) to Vposition(Control)+Max(1,Height(Control))-1
                        for Testcol=Hposition(Control) to Hposition(Control)+Width(Control)+(2*(lwrc$(trim$(Fieldtype$(Control)))=="combo"))-1
                           if Fncontrolisinside(Testrow,Testcol,Vposition(Index),Hposition(Index),Width(Index)+(2*(lwrc$(trim$(Fieldtype$(Index)))=="combo")),Height(Index)) then
                              let Valid=0
                              if Mode then
                                 let Mode=Inputeditormovemode
                                 let Object=Control
                                 if Lwrc$(Trim$(Fieldtype$(Control)))<>"frame" and Lwrc$(Trim$(Fieldtype$(Index)))<>"frame" then
                                    let Message$="Control "&Str$(Control)&" overlaps control "&Str$(Index) &"."
                                 else
                                    let Message$="BR doesn't support a listview on a frame."
                                 end if
                              end if
                              let Testcol=Hposition(Control)+Width(Control)+(2*(lwrc$(trim$(Fieldtype$(Control)))=="combo"))-1
                              let Testrow=Vposition(Control)+Max(1,Height)-1
                              goto ENDTEST ! We Found A Problem, We Can Stop Searching
                           end if
                        next Testcol
                     next Testrow
                  else if lwrc$(trim$(fieldtype$(Control)))="frame" or lwrc$(trim$(fieldtype$(Index)))="frame" then
                     if lwrc$(trim$(fieldtype$(Control)))="frame" then
                        let framecontrol=Control
                        let othercontrol=index
                     else
                        let frameControl=Index
                        let OtherControl=Control
                     end if
                     for Testrow=Vposition(OtherControl) to Vposition(OtherControl)+Max(1,Height(OtherControl))-1
                        for Testcol=Hposition(OtherControl) to Hposition(OtherControl)+Width(OtherControl)+(2*(lwrc$(trim$(Fieldtype$(OtherControl)))=="combo"))-1
                           if ~SetInside then
                              let Inside=fnControlIsInside(TestRow,TestCol,VPosition(frameControl),Hposition(frameControl),Width(frameControl),Height(frameControl))
                              let SetInside=1
                           else
                              if Inside<>fnControlIsInside(TestRow,TestCol,VPosition(frameControl),Hposition(frameControl),Width(frameControl),Height(frameControl)) then
                                 let Valid=0
                                 if Mode then
                                    let Mode=InputEditorMoveMode
                                    let Object=OtherControl
                                    let Message$="Control "&Str$(OtherControl)&" is halfway outside of a frame."
                                 end if
                              end if
                           end if
                        next TestCol
                     next TestRow
                  end if
               end if
            next Index
         end if
      end if
ENDTEST: ! End Of The Test Here
      let Fnvalidspec=Valid
   fnend
!

   dim ValidSpecAttributes$(1)*128
   dim ValidSpecAttributes(1)

   def Fnvalidattribute(Attribute$*128,FieldType$;___,Visibility)
      if len(trim$(Attribute$)) then
         if udim(mat ValidSpecAttributes$)=1 and ValidSpecAttributes$(1)="" then
            mat ValidSpecAttributes$(0)
            mat ValidSpecAttributes(0)
         end if
         let i=srch(mat ValidSpecAttributes$,Attribute$)
         if i<1 then
            let i=udim(mat ValidSpecAttributes$)+1
            mat ValidSpecAttributes$(i)
            mat ValidSpecAttributes(i)
            let ValidSpecAttributes$(i)=Attribute$

            let Visibility=fnForceVisibility
            let fnChangeForceVisibility(0)
            if lwrc$(trim$(FieldType$))="check" and Pos("0123456789",Attribute$(1:1)) then
               let Attribute$(1:1)="" ! strip the number thats breaking design
            end if
            print #0, fields "3,3,C 1,"&Attribute$ : "" error _InvalidAttribute
            let ValidSpecAttributes(i)=1
            _INVALIDATTRIBUTE: ! Invalid Attribute
            let fnChangeForceVisibility(Visibility)
         end if
         let Fnvalidattribute=ValidSpecAttributes(i)
      else
         let Fnvalidattribute=1
      end if
   fnend

   dim ValidWindowAttributes$(1)*128
   dim ValidWindowAttributes(1)

   def Fnvalidframe(Attribute$*128;___,x,i)
      if len(trim$(Attribute$)) then
         if udim(mat ValidWindowAttributes$)=1 and ValidWindowAttributes$(1)="" then
            mat ValidWindowAttributes$(0)
            mat ValidWindowAttributes(0)
         end if
         let i=srch(mat ValidWindowAttributes$,Attribute$)
         if i<1 then
            let i=udim(mat ValidWindowAttributes$)+1
            mat ValidWindowAttributes$(i)
            mat ValidWindowAttributes(i)
            let ValidWindowAttributes$(i)=Attribute$
            open #(x:=fnGetFileNumber) : "srow=2,scol=2,rows=1,cols=1"&attribute$,display,outin error _InvalidFrame
            close #x:
            let ValidWindowAttributes(i)=1
            _INVALIDframe: ! Invalid Frame
         end if
         let fnValidFrame=ValidWindowAttributes(i)
      else
         let Fnvalidframe=1
      end if
   fnend
!
CONTROLISINSIDE: ! Return True If The Given Position Is Inside The Given Control Boundaries
   def Fncontrolisinside(Testrow,Testcol,Row,Col,Width,Height)
      if Height=0 then let Height=1
      if Testrow=>Row And Testrow<=Row+Height-1 And Testcol=>Col And Testcol<=Col+Width-1 then
         let Fncontrolisinside=1
      else
         let Fncontrolisinside=0
      end if
   fnend
!
!  #Autonumber# 39000,1
! *****************************************************************
! ******************** Add New Controls ***************************
! *****************************************************************
   dim Gaps(1)
   def Fnfindavailablevposition(;&Hpos,&Width,___,Index,Row,Found)
      mat Gaps(Screenio(Si_Vsize))
      if ~Hpos then let Hpos=Int(Screenio(Si_Hsize)/4)
      if ~Width then let Width=18
      let Row=1
      do While Row<Screenio(Si_Vsize)-1
         let Row+=1
         if ~Gaps(Row) then
            let Found=Fncheckrow(Row,Hpos,Width,[[Screencontrols]])
         end if
      loop Until Found
      if ~Found then ! Screen Needs To Be Made Bigger
         let Screenio(Si_Vsize)+=1
         let Found=Screenio(Si_Vsize)-1
      end if
      let Fnfindavailablevposition=Found
   fnend
!
   def Fncheckrow(Row,Hpos,Width,[[Screencontrols]];___,Index,Found,Testcol)
      do While Index<Udim(Mat Controlname$)
         let Index+=1
         for Testcol=Hpos to Hpos+Width
            if lwrc$(trim$(fieldtype$(index)))="frame" then
               if gridlines(index) then
                  if Fncontrolisinside(Row,Testcol,Vposition(Index)-1,Hposition(Index),Width(Index),1) then let Found=1
                  if Fncontrolisinside(Row,Testcol,Vposition(Index)+Height(Index),Hposition(Index),Width(Index),1) then let Found=1
               end if
            else
               if Fncontrolisinside(Row,Testcol,Vposition(Index),Hposition(Index),Width(Index),Height(Index)) then let Found=1
            end if
         next Testcol
      loop Until Found
      if ~Found then
         let Fncheckrow=Row
      end if
   fnend
!
   def Fnskipagap(;___,X)
      let X=Fnfindavailablevposition
      if X then let Gaps(X)=1
   fnend
!
   def Fnresizescreen(Mat Screenio$,Mat Screenio,[[Screencontrols]];___,Rightedge,Bottomedge)
      for Index=1 to Udim(Mat Hposition)
         let Rightedge=Max(Rightedge,Hposition(Index)+Width(Index)-1)
         let Bottomedge=Max(Bottomedge,Vposition(Index)+Height(Index)-1)
      next Index
!
      let Screenio(Si_Vsize)=Max(5,Bottomedge+1)
      let Screenio(Si_Hsize)=Max(30,Rightedge+4)
   fnend
!
   def Fntheresalistview(Mat Fieldtype$;___,Index,Listview)
      for Index=1 to Udim(Mat Fieldtype$)
         if Lwrc$(Trim$(Fieldtype$(Index)))="listview" then let Listview=1
      next Index
      let Fntheresalistview=Listview
   fnend
!
   def fnFindExitRow(mat ScreenIO$,mat ScreenIO,[[ScreenControls]];___,Index,FoundExitRow)
      for Index=1 to udim(mat ControlName$)
         if ControlName$(Index)="Cancel_Button" or ControlName$(Index)="Save_Button" or ControlName$(Index)="Select_Button" then
            let FoundExitRow=Index
         end if
         if ControlName$(Index)="Add_Button" or ControlName$(Index)="Edit_Button" then
            let FoundExitRow=Index
         end if
      next Index
      if FoundExitRow=0 then
         for Index=1 to udim(mat Function$)
            if pos(lwrc$(Function$(Index)),"exitmode") and pos(lwrc$(Function$(Index)),"quit") then
               let FoundExitRow=Index
            end if
         next Index
      end if
      if FoundExitRow then
         let fnFindExitRow=VPosition(FoundExitRow)
      end if
   fnend

   dim Screens$(1)
   def fnAddAEButtons(mat ScreenIO$,mat ScreenIO,[[ScreenControls]];Target$,Row,Col,NoAdd,NoEdit,NoDelete,&Add,&Edit,&DeleteButton,___,Index,FindListview,Column)
      if Target$="" then
         ! library "fileio" : fnAskCombo$ Linkage already established
         let Fnreadallscreencodes(Mat Tempscreenlist$,Mat Tempcreatedate,Mat Tempmodifydate,mat TempVersion,mat TempCreateUser$,mat TempModifyUser$,mat TempProject$,mat TempNotes$)

         let Target$=fnAskCombo$(mat TempScreenList$,"Select target:")
      end if

      for Index=1 to udim(mat FieldType$)
         if lwrc$(trim$(FieldType$))="listview" then
            let FindListview=Index
         end if
      next Index

      if ~Row then let Row=fnFindExitRow(mat ScreenIO$,mat ScreenIO,[[ScreenControls]])
      if ~Row then let fnSkipAGap

      if ~Col then
         if FindListview then
            let Col=HPosition(FindListview)
         else
            let Col=10
         end if
      end if

      if ~NoAdd then
         let Add=fnAddButton([[ScreenControls]])
         if Add then
            if ~Row then let Row=VPosition(Add)
            let Width(Add)=10
            let VPosition(Add)=Row
            let HPosition(Add)=Col
            let ControlName$(Add)="Add_Button"
            let Description$(Add)="Add"
            let Function$(Add)="["&uprc$(Target$)&"]"
            let FGColor$(Add)="W"
            let BGColor$(Add)="W"
            let Col+=12 ! Move over for Next Button
         end if
      end if

      if ~NoEdit then
         let Edit=fnAddButton([[ScreenControls]])
         if Edit then
            let Width(Edit)=10
            let VPosition(Edit)=Row
            let HPosition(Edit)=Col
            let ControlName$(Edit)="Edit_Button"
            let Description$(Edit)="Edit"
            let Function$(Edit)="["&uprc$(Target$)&"]Record=CurrentRec"
            let FGColor$(Edit)="W"
            let BGColor$(Edit)="W"
            let Col+=12 ! Move over for Next Button
         end if
      end if

      if ~NoDelete then
         ! Add Delete Button
         let DeleteButton=fnAddButton([[ScreenControls]])
         if DeleteButton then
            let Width(DeleteButton)=10
            let VPosition(DeleteButton)=Row
            let HPosition(DeleteButton)=Col
            let ControlName$(DeleteButton)="Delete_Button"
            let Description$(DeleteButton)="Delete"
            let Function$(DeleteButton)="{deletelistviewrecord}"
            let FGColor$(DeleteButton)="W"
            let BGColor$(DeleteButton)="W"
            let Col+=12 ! Move over for Next Button
         end if
      end if
   fnend

   def Fnaddexitbuttons(Mat Screenio$,Mat Screenio,[[Screencontrols]];Row,&CancelButton,&OkButton,___,Cancel,Save,Index,Rightedge)
      ! IF there's AE buttons, use that row
      !  if not, use the skipagap logic
      if ~Row then let Row=fnFindExitRow(mat ScreenIO$,mat ScreenIO,[[ScreenControls]])
      if ~Row then let Fnskipagap
!
      for Index=1 to Udim(Mat Hposition)
         let Rightedge=Max(Rightedge,Hposition(Index)+Width(Index)-1)
      next Index
      if ~Rightedge then let Rightedge=Screenio(Si_Hsize)-4
      let Rightedge=Max(Rightedge,24)
!
      let Cancel=Fnaddbutton([[Screencontrols]])
      if ~Row then let Row=VPosition(Cancel)
      let Vposition(Cancel)=Row
      let Width(Cancel)=10
      let Hposition(Cancel)=Rightedge-Width(Cancel)+1
      let Controlname$(Cancel)="Cancel_Button"
      let Description$(Cancel)="Cancel"
      let Function$(Cancel)="let ExitMode=QuitOnly"
      let FGColor$(Cancel)="W"
      let BGColor$(Cancel)="W"
!
      let Save=Fnaddbutton([[Screencontrols]])
      let Width(Save)=10
      let Vposition(Save)=Row
      let Hposition(Save)=Hposition(Cancel)-2-Width(Save)
      let FGColor$(Save)="W"
      let BGColor$(Save)="W"
!
      if Fntheresalistview(Mat Fieldtype$) then
         let Controlname$(Save)="Select_Button"
         let Description$(Save)="Select"
         let Function$(Save)="let ExitMode=SelectAndQuit"
      else
         let Controlname$(Save)="Save_Button"
         let Description$(Save)="Save"
         let Function$(Save)="let ExitMode=SaveAndQuit"
      end if
      let fnAddExitButtons=Save

      let CancelButton=Cancel
      let OkButton=Save
!
! .   ! let Description$(Save)="Ok" ! Uncomment this line to make it use OK for the save button.
   fnend
!
ADDEMPTYFIELD: ! Add An Empty Field To The Editor Arrays
   def Fnaddemptyfield([[Screencontrols]];Skipplacement,SpecifyRow,___,Index)
      let Fnresizecontrolarrays(Index:=Udim(Controlname$)+ 1,[[Screencontrols]])
      let Width(Index)=18
      if SpecifyRow then
         let VPosition(Index)=SpecifyRow
      else if ~Skipplacement then
         let Vposition(Index)=Fnfindavailablevposition(Hposition(Index),Width(Index)) ! Sets Hposition To 1/4th The Screen Size Also
      else
         let Vposition(Index)=1 ! in case it has to be something..
      end if
      let Height(Index)=1
      let Fnaddemptyfield=Index
   fnend
!
   def fnAddAndColorCurrentField([[Screencontrols]],mat ScreenIO$,mat ScreenIO;Name$*50,Description$*255,Type$*30,DateSpec$*64,&CaptionIndex,SpecifyRow,___,Index,RelatedControl)
      let Index=fnAddCurrentField([[ScreenControls]],ScreenIO(si_hsize),Name$,Description$,Type$,DateSpec$,CaptionIndex,SpecifyRow)
      if Index then
         let Fgcolor$(Index)="W"
         let Bgcolor$(Index)="W"
         if Trim$(Screenio$(Si_Fgcolor))<>"" then
            if (Relatedcontrol:=Srch(Mat Controlname$,Description$(Index)))>0 then
               let Fgcolor$(Relatedcontrol)=Trim$(Screenio$(Si_Fgcolor))
            end if
         end if
      end if
      let fnAddAndColorCurrentField=Index
   fnend

ADDCURRENTFIELD: ! Add The Current Field To The Editor Arrays
   def Fnaddcurrentfield([[Screencontrols]],Screenwidth;Name$*50,Description$*255,Type$*30,DateSpec$*64,&CaptionField,SpecifyRow,___,Index,Captiondisplaywidth,Vpos,Hpos,NoFieldSel)
      if Name$="" and Description$="" and Type$="" then
         if Fngetfieldscount then
            if ~Fnreadfields(Name$,Description$,Type$,DateSpec$) then
               let NoFieldSel=1 ! Abort
            end if
         else
            let NoFieldSel=1
         end if
      end if
      if ~NoFieldSel then
         ! Add Field
         if Len(Trim$(Description$)) then let Description$=Description$&": "
         let Captiondisplaywidth=Int(Len(Trim$(Description$))*4/5)+2
         let Index=fnAddTextField([[Screencontrols]],SpecifyRow)
         let Fieldtype$(Index)="C"
         let Controlname$(Index)="Field_"&Trim$(Name$)(1:44)
         let Description$(Index)="Caption_"&Trim$(Name$)(1:42)
         let Fieldname$(Index)=Trim$(Name$)
         let Width(Index)=Fndisplaylength(Type$)
         let Specwidth(Index)=Width(Index)
         let Width(Index)=Min(Width(Index),40)
         let Hposition(Index)=Max(Captiondisplaywidth+2,Hposition(Index))
         let Width(Index)=Min(Width(Index),Screenwidth-Hposition(Index))
         let Vpos=Vposition(Index)
         let Hpos=Hposition(Index)
!
         if len(trim$(DateSpec$)) then
            ! Then let dateSpec$ = the default DateFormatDisplay from ScreenIO.ini.
            let CnvrtIn$(Index)="DATE("&setting_DateFormatDisplay$&")"
            if ~pos(lwrc$(DateSpec$),"julian") then
               let CnvrtOut$(Index)="DATE("&DateSpec$&")"
            end if
         end if

         let Fnaddcurrentfield=Index
         let Index=fnAddCaption([[Screencontrols]])
         let Fieldtype$(Index)="caption"
         let Controlname$(Index)="Caption_"&Trim$(Name$)(1:42)
         let Description$(Index)=Trim$(Description$)
         let Justify$(Index)="R"
         let Vposition(Index)=Vpos
         let Hposition(Index)=Hpos-(Captiondisplaywidth+1)
         let Width(Index)=Captiondisplaywidth
         let Specwidth(Index)=Len(Trim$(Description$))


         let CaptionField=Index
      end if
   fnend
!
ADDTEXTFIELD: ! Add A  Textbox Field
   def Fnaddtextfield([[Screencontrols]];SpecifyRow,___,Index)
      let Index=Fnaddemptyfield([[Screencontrols]],0,SpecifyRow)
      let Fieldtype$(Index)="C"
      let Specwidth(Index)=Width(Index)
      let Parent$(Index)=Fngenerateuniquelvname$(Mat Parent$,"Textbox")
      let Fnaddtextfield=Index
   fnend
!
ADDCAPTION: ! Add A Caption Field
   def Fnaddcaption([[Screencontrols]];___,Index)
      let Index=Fnaddemptyfield([[Screencontrols]])
      let Fieldtype$(Index)="caption"
      let Specwidth(Index)=Width(Index)
      let Parent$(Index)=Fngenerateuniquelvname$(Mat Parent$,"Caption")
      let Fnaddcaption=Index
   fnend
!
ADDSCREEN: ! Add An Entire Screen As A Clickable Field
   Def Fnaddscreen([[Screencontrols]];___,Index,Screen$)
      Let Screen$=Fnselectscreen$
      If Trim$(Screen$)<>"" Then
         Let Index=Fnaddemptyfield([[Screencontrols]])
         Let Fieldtype$(Index)="screen"
         Let Fieldname$(Index)=Screen$
         let Parent$(Index)=Fngenerateuniquelvname$(Mat Parent$,"Screen")

         let fnReadChildScreenSize(Index,mat ScreenIO$,mat ScreenIO,[[ScreenControls]])

         Let Function$(Index)="ParentKey$=CurrentKey$"
         let fnAddScreen=Index
      End If
   Fnend
!
ADDBUTTON: ! Add A Button
   def Fnaddbutton([[Screencontrols]];___,Index)
      let Index=Fnaddemptyfield([[Screencontrols]])
      let Fieldtype$(Index)="button"
      let Specwidth(Index)=Width(Index)
      let Parent$(Index)=Fngenerateuniquelvname$(Mat Parent$,"Button")
      let Fnaddbutton=Index
   fnend
!
ADDCOMBO: ! Add a Combo Box to the Screen
   def fnAddCombo([[ScreenControls]];___,Index)
      let Index=Fnaddemptyfield([[Screencontrols]])
      let Fieldtype$(Index)="combo"
      let Specwidth(Index)=Width(Index)
      let FnaddCombo=Index
   fnend

ADDCHECKBOX: ! Add A Checkbox To The Screen
   def Fnaddcheckbox([[Screencontrols]];___,Index)
      let Index=Fnaddemptyfield([[Screencontrols]])
      let Fieldtype$(Index)="check"
      let Truevalue$(Index)="1"
      let Falsevalue$(Index)="0"
      let Specwidth(Index)=Width(Index)
      let Fnaddcheckbox=Index
   fnend
!
ADDPICTURE: ! Add A Picture
   def Fnaddpicture([[Screencontrols]];___,Index)
      let Index=Fnaddemptyfield([[Screencontrols]])
      let Fieldtype$(Index)="P"
      let Width(Index)=10
      let Height(Index)=5
      let Fnaddpicture=Index
   fnend

AddFrame: ! Add A Picture
   def FnaddFrame([[Screencontrols]];___,Index)
      let Index=Fnaddemptyfield([[Screencontrols]])
      let Fieldtype$(Index)="frame"
      let Gridlines(Index)=1
      let Parent$(Index)=Fngenerateuniquelvname$(Mat Parent$,"Frame")
      let Width(Index)=40
      let Height(Index)=5
      let FnaddFrame=Index
   fnend
!
ADDLISTVIEW: ! Add A Listview
   def Fnaddlistview([[Screencontrols]];SkipEmptyChild,___,Index)
      let Index=Fnaddemptyfield([[Screencontrols]])
      let Fieldtype$(Index)="LISTVIEW"
      let Width(Index)=40
      let Height(Index)=11
      let Parent$(Index)=Fngenerateuniquelvname$(Mat Parent$)
      let Fnaddlistview=Index
!
      if ~SkipEmptyChild then
         let Index=Fnaddlistviewchild(Parent$(Index),[[Screencontrols]])
         let Description$(Index)="Empty Listview"
         let Width(Index)=40
      end if
   fnend
!
ADDLISTVIEWCHILD: ! Add A Listview Column
   def Fnaddlistviewchild(Parent$,[[Screencontrols]];___,Index)
      let Index=Fnaddemptyfield([[Screencontrols]],1)
      let Fieldtype$(Index)="LISTCHLD"
      let Width(Index)=10
      let Parent$(Index)=Parent$
      let Fnaddlistviewchild=Index
   fnend
!
ADDSEARCHBOX: ! Add A Searchbox Field
   def Fnaddsearchbox([[Screencontrols]];Mode,Control,___,Index,Listviewindex,Captionindex)
!
      let Index=Fnaddemptyfield([[Screencontrols]],1)
      let Fieldtype$(Index)="SEARCH"
      let Specwidth(Index)=Width(Index)
      let Hposition(Index)=3
!
      if (Mode=Inputeditormode Or Mode=Inputeditormovemode Or Mode=Inputlistviewmode) And Fieldtype$(Control)="LISTVIEW" then
         let Parent$(Index)=Parent$(Control)
         let Fnsetsearchlistview(Index,Control,[[Screencontrols]],1)
      else
         let Listviewindex=Srch(Mat Fieldtype$,"LISTVIEW")
         if Listviewindex>0 then
            let Fnsetsearchlistview(Index,Listviewindex,[[Screencontrols]],1)
         else
            let Vposition(Index)=Fnfindavailablevposition(Hposition(Index),Width(Index))
         end if
      end if
!
      let Captionindex=Fnaddemptyfield([[Screencontrols]],1)
      let Fieldtype$(Captionindex)="P"
      let Picture$(Captionindex)=setting_ImagePath$&"\search.png"
      let Width(Captionindex)=2
      let Height(Captionindex)=1
      let Hposition(Captionindex)=Hposition(Index)-2
      let Vposition(Captionindex)=Vposition(Index)
!
      let Controlname$(Captionindex)=Fngenerateuniquelvname$(Mat Controlname$,"SearchPic_")
      let Description$(Index)=Controlname$(Captionindex)
!
      let Fnaddsearchbox=Index
   fnend

ADDFILTERBOX: ! Add A Filter Box Field
   def Fnaddfilterbox([[Screencontrols]];Mode,Control,___,Index,Listviewindex,Captionindex)
      if fn43 then
         ! Add field, make it a filter
         let Index=Fnaddemptyfield([[Screencontrols]],1)
         let Fieldtype$(Index)="FILTER"
         let Specwidth(Index)=Width(Index)
         let Hposition(Index)=3
   !
         ! Find listview
         if Control and (Mode=Inputeditormode Or Mode=Inputeditormovemode Or Mode=Inputlistviewmode) And Fieldtype$(Control)="LISTVIEW" then
            let Parent$(Index)=Parent$(Control)
            let Fnsetsearchlistview(Index,Control,[[Screencontrols]],1)
         else
            let Listviewindex=Srch(Mat Fieldtype$,"LISTVIEW")
            if Listviewindex>0 then
               let Fnsetsearchlistview(Index,Listviewindex,[[Screencontrols]],1)
            else
               let Vposition(Index)=Fnfindavailablevposition(Hposition(Index),Width(Index))
            end if
         end if
   !
         ! Set default parameters
         let Picture$(Index)="0,ALL" ! Column, Filter Type, Case

         ! Add magnifying glass icon
         let Captionindex=Fnaddemptyfield([[Screencontrols]],1)
         let Fieldtype$(Captionindex)="P"
         let Picture$(Captionindex)=setting_ImagePath$&"\search.png"
         let Width(Captionindex)=2
         let Height(Captionindex)=1
         let Hposition(Captionindex)=Hposition(Index)-2
         let Vposition(Captionindex)=Vposition(Index)
   !
         ! Tie magnifying glass icon to Filter Box so they move together
         let Controlname$(Captionindex)=Fngenerateuniquelvname$(Mat Controlname$,"SearchPic_")
         let Description$(Index)=Controlname$(Captionindex)
   !
         let Fnaddfilterbox=Index
      else
         let msgbox("Filters are only available in BR 4.3 and higher.")
      end if
   fnend

!
ADDCalendar: ! Add A Calendar
   def Fnaddcalendar([[Screencontrols]];___,Index)
      let Index=Fnaddemptyfield([[Screencontrols]])
      let Fieldtype$(Index)="CALENDAR"
      let Width(Index)=10
      let Height(Index)=5

      ! $$$$$ perhaps just preset function to be what it should be, like the shortcuts from the menu

      let Fnaddcalendar=Index
   fnend

!
ADDCURRENTLISTCHLD: ! Add The Current Field As A Listview Child
   def Fnaddcurrentlistchld(Parent$,[[Screencontrols]];Name$*50,Description$*255,Type$*30,DateSpec$*64,___,Index,NoField)
      if Name$="" and Description$="" and Type$="" then
         if Fngetfieldscount then
            if ~fnreadfields(Name$,Description$,Type$,DateSpec$) then
               let NoField=1
            end if
         else
            let NoField=1
         end if
      end if
      if ~NoField then
         let Index=Fnaddemptyfield([[Screencontrols]],1)
         let Fieldtype$(Index)="LISTCHLD"
         let Controlname$(Index)="Field_"&Trim$(Name$)(1:44)
         let Description$(Index)=Trim$(Description$)
         let Fieldname$(Index)=Trim$(Name$)
         let Specwidth(Index)=Fndisplaylength(Type$)
         let Width(Index)=Min(Specwidth(Index),40)
         let Parent$(Index)=Parent$
         if len(trim$(DateSpec$)) then
            ! Then let dateSpec$ = the default DateFormatDisplay from ScreenIO.ini.
            let CnvrtIn$(Index)="DATE("&setting_DateFormatDisplay$&")"
            if ~pos(lwrc$(DateSpec$),"julian") then
               let CnvrtOut$(Index)="DATE("&DateSpec$&")"
            end if
         end if

         let Fnaddcurrentlistchld=Index
      end if
   fnend
!
GENERATEUNIQUELVNAME: ! Generate A Unique Name For A Lv
   def Fngenerateuniquelvname$(Mat Parent$;Prefix$,___,Index,Test)
      if ~Len(Prefix$) then let Prefix$="LV"
      do
      loop Until (Srch(Mat Parent$,Prefix$&Str$(Index:=Index+1))<1)
      let Fngenerateuniquelvname$=Prefix$&Str$(Index)
   fnend
!
SETSEARCHLISTVIEW: ! Point The Search Box To A Listview Control
   def Fnsetsearchlistview(Index,Listviewindex,[[Screencontrols]];Move,___,Childindex)
      let Parent$(Index)=Parent$(Listviewindex)
      if Move then
         let Width(Index)=Width(Listviewindex)-2
         let Hposition(Index)=Hposition(Listviewindex)+2
         let Vposition(Index)=Max(1,Vposition(Listviewindex)-1) ! Default Searchbox To Top
! .   !   let Vposition(Index)=Vposition(Listviewindex)+Height(listviewindex)
      end if
      for Childindex=1 to Udim(Mat Fieldtype$)
         if Fieldtype$(Childindex)="LISTCHLD" And Parent$(Childindex)=Parent$(Listviewindex) then
            let Specwidth(Index)=Max(Specwidth(Index),Specwidth(Childindex))
         end if
      next Childindex
   fnend

   dim CenterSpec$(11)*64,CenterText$(11)*64

   def fnChangeControlType(Mat Screenio$,Mat Screenio,Control,[[Screencontrols]];___,Key$,Function,Instr,Index,FieldType$,Changed,_control,_type)

      if ~fnControlCanSwitch(Control,[[ScreenControls]]) then let Control=0

      for Index=1 to 8
         let CenterSpec$(Index)=str$(Index)&",1,CC 24"
      next Index
      let CenterSpec$(9)="10,1,24/C 40"
      let CenterSpec$(10)="11,1,24/C 40"
      let CenterSpec$(11)="13,7,CC 12,/W:W,B17"

      mat CenterText$=("")
      let CenterText$(1)="Click on the Control"
      let CenterText$(2)="that you want to change"
      let CenterText$(3)=""
      let CenterText$(4)="Then, click on the"
      let CenterText$(5)="button in the toolbox"
      let CenterText$(6)="for the control type"
      let CenterText$(7)="you want to change it to"
      let CenterText$(8)="or press ESC to cancel"

      let CenterText$(9)="Control:"
      let CenterText$(10)="Type:"

      let CenterText$(11)="Convert"

      let _control=9
      let _type=10

      let fnChangeForceVisibility(0)
      open #(Instr:=Fngetfilenumber) : "SROW=3,SCOL=3,ROWS=13,COLS=24,Border=S,Caption=Change Control",display,outin
      print #Instr, fields mat CenterSpec$ : mat CenterText$

      do
         if Control then
            let CenterText$(_control)="Control: "&fnControlDescription$(Control,[[ScreenControls]],1)(1:32)
         else
            let CenterText$(_control)="Control: None"
         end if
         let CenterText$(_type)="Type: "&FieldType$

         print #Instr, fields mat CenterSpec$ : mat CenterText$

         input #0, fields "1,2,C 1,AEX" : Key$
         let Function=Fkey

         if Function>=1400 And Function<1500 then !  Process Button
            let FieldType$=fnFieldTypeCanSwitch$(Fnreadbutton$(Function))
         end if

         if Function>=1500 And Function<=1500+Udim(Mat Controlname$) then
            if fnControlCanSwitch(Function-1500,[[ScreenControls]]) then
               let Control=Function-1500
            end if
         end if

         if Function=17 then
            ! Switch the control type
            if fnSwitchControl(Control,FieldType$,[[ScreenControls]]) then
               let Changed=1
            end if
         end if

      loop until Function=99 or Function=93 or Function=44 or Function=19 or Changed or Function>=1100 and Function<1400

      close #Instr:
   fnend

   def fnFieldTypeCanSwitch$(ButtonText$)
      #Select# lwrc$(ButtonText$) #Case# "field" # "text box"
         let fnFieldTypeCanSwitch$="C"
      #Case# "caption"
         let fnFieldTypeCanSwitch$="caption"
      #Case# "check box"
         let fnFieldTypeCanSwitch$="check"
      #Case# "combo box"
         let fnFieldTypeCanSwitch$="combo"
      #Case# "button"
         let fnFieldTypeCanSwitch$="button"
      #Case# "picture"
         let fnFieldTypeCanSwitch$="P"
      #End Select#
   fnend

   def fnControlCanSwitch(Control,[[ScreenControls]])
      if Control and Control<=udim(mat FieldType$) then
         #Select# lwrc$(trim$(FieldType$(Control))) #Case# "c" # "caption" # "check" # "combo" # "button" # "p"
            let fnControlCanSwitch=1
         #End Select#
      end if
   fnend

   def fnSourceType(FieldType$)
      #Select# lwrc$(trim$(FieldType$)) #Case# "c" # "combo"
         let fnSourceType=1
      #Case Else#
         let fnSourceType=0
      #End Select#
   fnend

   def fnSwitchControl(Control,TargetType$,[[ScreenControls]];___,SourceType,TargetType,RelatedIndex,NewDescription)
      if Control and len(trim$(TargetType$)) then
         if fnControlCanSwitch(Control,[[ScreenControls]]) then
            ! Need to fill in the details of how this happens when control types
            !  aren't purely compatible

            ! In Sourcetype 2 Fields, Description is a hardcoded value; in Sourcetype 1 fields, description is a link to another field.
            let SourceType=fnSourceType(FieldType$(Control))
            let TargetType=fnSourceType(TargetType$)

            ! if we change from C spec to Checkbox or Radio Button spec, then
            !  we need to read description from related control and delete related control.
            if lwrc$(trim$(TargetType$))=="check" then
               ! if its a source type that has related controls, and if there's a related control.
               if (Relatedindex:=Fnfindrelatedcontrol(Control,[[Screencontrols]])) then
                  ! if related control is a caption
                  if lwrc$(trim$(fieldType$(RelatedIndex)))="caption" then
                     let Description$(Control)=trim$(Description$(RelatedIndex))
                     if Description$(Control)(len(Description$(Control)):len(Description$(Control)))=":" then
                        let Description$(Control)(len(Description$(Control)):len(Description$(Control)))=""
                     end if

                     let Fndeletecontrol(RelatedIndex,Mat Screenio$,Mat Screenio,[[Screencontrols]]) ! Delete related control
                     let NewDescription=1
                  end if
               end if
            end if

            ! If we change from one target type and another, have to erase the Description$ value
            if SourceType><TargetType and ~NewDescription then
               let Description$(Control)=""
            end if



            ! We switch the actual control type here
            let FieldType$(Control)=TargetType$
            let fnSwitchControl=1
         end if
      end if
   fnend
!
!  #Autonumber# 40000,10
! ===================== Screen Functions ===================
! = These Variables Are Used Only In Full Screen Functions =
! ==========================================================
   dim Static_Screenvsize
   dim Static_Screenhsize
!
REDRAWENTIRESCREEN: !  Close And Reopen And Redraw The Entire Screen
   def Fnredrawentirescreen(&Wtoolbar,&Wdebug,&Weditor,Mat Screenio$, Mat Screenio, [[Screencontrols]])
!
      let Fnclosetoolbarwindow
      let Fnclosedebugwindow
      let Fncloseeditorwindow
!
      let Fnopenmainwindows(Mat Screenio$, Mat Screenio)
      let Fndisplaywindowsmenu
!
      let Fnpainttoolbarwindow(Mat Screenio$, Mat Screenio)
      let Fnpaintdebugwindow
!
   fnend
!
!  #Autonumber# 41000,10
OPENMAINWINDOWS: !  Open Main  Window,   Updating Size And Caption
   def Fnopenmainwindows(Mat Screenio$, Mat Screenio;___, Titlebar$*120,Windowvsize, Windowhsize, Windowvposition, Windowhposition, Windowattributes$*140,Toolbarwidth, Toolbarheight, Debugminheight, Debugmaxheight, Bordersize)
!
      let Debugminheight=9
      let Debugmaxheight=11
!
      if Screenio(Si_Border) Or Pos(Uprc$(Screenio$(Si_Attributes)),"BORDER") then
         let Bordersize=2
      end if
!
      if Trim$(Screenio$(Si_Screencode))="" And Trim$(Screenio$(Si_Caption))="" then
         let Titlebar$="ScreenIO Program Generation System"
      else
         let Titlebar$="ScreenIO Program Generation System - Editing"
         if Trim$(Screenio$(Si_Screencode))<>"" then
            let Titlebar$=Titlebar$ & "  " & Trim$(Screenio$(Si_Screencode))
         end if
         if Trim$(Screenio$(Si_Caption))<>"" then
            let Titlebar$=Titlebar$&' "'&Screenio$(Si_Caption)&'"'
         end if
      end if
!
      let Toolbarwidth=26
      let Static_Screenvsize=Max(Screenio(Si_Vsize),24)+Debugminheight+2+2+Bordersize
      let Static_Screenhsize=Max(Screenio(Si_Hsize),80)+Toolbarwidth+2+2+Bordersize
      open #0: "ROWS=" & Str$(Static_Screenvsize) & ", COLS="&Str$(Static_Screenhsize)&", Caption="&Titlebar$, display, outin
!
      let Toolbarheight=Static_Screenvsize-2
      let Fnopentoolbarwindow(Toolbarheight,Toolbarwidth)
!
      let Windowvposition=Max(0,Int((Static_Screenvsize-(Debugmaxheight+2)-(Screenio(Si_Vsize)+Bordersize+2))/2))+2
      let Windowhposition=Max(0,Int((Static_Screenhsize-(Toolbarwidth+2)-(Screenio(Si_Hsize)+Bordersize))/2))+(Toolbarwidth+2)+1
      let Fnopeneditorwindow(Windowvposition, Windowhposition, Mat Screenio$, Mat Screenio)
!
      let Fnopendebugwindow(Static_Screenvsize,Static_Screenhsize,Toolbarwidth,Debugmaxheight,Windowvposition+Screenio(Si_Vsize)+Bordersize+2)
!
   fnend
!
GETSCREENSIZE: ! Returns The Static Screen Size
   def Fngetscreensize(;&Vsize,&Hsize)
      let Vsize=Static_Screenvsize
      let Hsize=Static_Screenhsize
   fnend
!
!  #Autonumber# 42000,5
!  ======================= Debug Window ======================
!  = These Variables Are Used Only In Debug Window Functions =
!  ===========================================================
   dim Debugheadings$(3),Debugwidths(3), Debugspec$(3)
   dim Debugobject(1) ,Debugfield(1) ,Debugmessage$(1)*255
   dim Debugclearobject(1),Debugclearfield(1),Debugclearmessage$(1)*255
!
   dim Debug_Start(1), Debug_End(1), Debug_Color$(1)
!
!  Parallel accumulator so validation results are readable headlessly (no GUI window needed) -
!  added for fnCheckScreenErrors, see COMPILESCREEN's neighbor below
   dim Debugerror_Object(0), Debugerror_Field(0), Debugerror_Message$(0)*255, Debugerror_Type(0)
!
OPENDEBUGWINDOW: !  Open Debug Window,  Set  "Static" Variables
   def Fnopendebugwindow(Screenvsize,Screenhsize,Toolbarwidth,Debugmaxheight,Topofspace;___,Windowvposition,Windowhposition)
!
      let Static_Debugvsize=Min(Screenvsize-Topofspace,Debugmaxheight)
      let Windowvposition=Screenvsize-Static_Debugvsize
!
      let Windowhposition=Toolbarwidth+4
      let Static_Debughsize=Screenhsize-Windowhposition
!
      open #(Static_Wdebug:=Fngetfilenumber): "SROW=" & Str$(Windowvposition) & ", SCOL=" & Str$(Windowhposition) & ",   ROWS=" & Str$(Static_Debugvsize) & ",   COLS="& Str$(Static_Debughsize)&",   Border=S,   Caption=Debug", display, outin
!
   fnend
!
PAINTDEBUGWINDOW: !  Puts  The Listview In The Debug Window
   def Fnpaintdebugwindow
!
      let Debugheadings$(1)="Object" ! Hidden Field
      let Debugwidths(1)=0
      let Debugspec$(1)="N 5"
      let Debugheadings$(2)="Field" ! Hidden Field
      let Debugwidths(2)=0
      let Debugspec$(2)="N 5"
      let Debugheadings$(3)="To Do:   "
      let Debugwidths(3)=76
      let Debugspec$(3)="CC 255"
!
      let Db_Warning=1
      let Db_Error=2
!
      let Static_Debuglistview$="1,1,LIST "&Str$(Static_Debugvsize)&"/"&Str$(Static_Debughsize)
!
      print #Static_Wdebug, fields Static_Debuglistview$&",HEADERS,/W:W,1200" : (Mat Debugheadings$, Mat Debugwidths, Mat Debugspec$)
      let Fncleardebuglistview
   fnend
!
COLORDEBUGACTIVE: !  Colors  The Debug Window Yellow If Its Active
   def Fncolordebugactive(;Active,_,Rowcount)
!
      if Active then
         if Static_Debugactive then ! Do Nothing
         else
            let Static_Debugactive=1
            input #Static_Wdebug, fields Static_Debuglistview$ & ",ROWCNT,ALL,NOWAIT" : Rowcount
            if Rowcount then
!
               let Debug_Start(1)=1
               let Debug_End(1)=Rowcount
               let Debug_Color$(1)="/#000000:#FFFF77"
               print #Static_Wdebug, fields Static_Debuglistview$ & ",ATTR" : (Mat Debug_Start, Mat Debug_End, Mat Debug_Color$)
            end if
         end if
      else
         if Static_Debugactive then
            let Static_Debugactive=0
            input #Static_Wdebug, fields Static_Debuglistview$ & ",ROWCNT,ALL,NOWAIT" : Rowcount
            if Rowcount then
               let Debug_Start(1)=1
               let Debug_End(1)=Rowcount
               let Debug_Color$(1)="/#000000:#FFFFFF"
               print #Static_Wdebug, fields Static_Debuglistview$ & ",ATTR" : (Mat Debug_Start, Mat Debug_End, Mat Debug_Color$)
            end if
         end if
      end if
   fnend
!
CLEARDEBUGLISTVIEW: !   Clear The Debug List  View
   def Fncleardebuglistview
      mat Debugclearobject(0) : mat Debugclearfield(0) : mat Debugclearmessage$(0)
      mat Debugerror_Object(0) : mat Debugerror_Field(0) : mat Debugerror_Message$(0) : mat Debugerror_Type(0)
      if Static_Wdebug<>0 and File(Static_Wdebug)<>-1 then
         print #Static_Wdebug, fields Static_Debuglistview$ &",=,1200" : (Mat Debugclearobject, Mat Debugclearfield, Mat Debugclearmessage$)
      end if
   fnend
!
PRINTTODEBUGLISTVIEW: !  Prints Items To The Debug Listview
   def Fnprinttodebuglistview(Object,Field,Message$*255,Errtype;___,Populate$)
!
      mat Debugerror_Object(Udim(Mat Debugerror_Object)+1)
      mat Debugerror_Field(Udim(Mat Debugerror_Field)+1)
      mat Debugerror_Message$(Udim(Mat Debugerror_Message$)+1)
      mat Debugerror_Type(Udim(Mat Debugerror_Type)+1)
      let Debugerror_Object(Udim(Mat Debugerror_Object))=Object
      let Debugerror_Field(Udim(Mat Debugerror_Field))=Field
      let Debugerror_Message$(Udim(Mat Debugerror_Message$))=Message$
      let Debugerror_Type(Udim(Mat Debugerror_Type))=Errtype
!
      if Static_Wdebug<>0 and File(Static_Wdebug)<>-1 then
         if Clear then
            let Populate$=",="
         else
            let Populate$=",+"
         end if
!
         let Debugobject(1)=Object
         let Debugfield(1)=Field
         let Debugmessage$(1)=Message$
!
         print #Static_Wdebug, fields Static_Debuglistview$ & Populate$ & ",1200" : (Mat Debugobject, Mat Debugfield, Mat Debugmessage$)
         input #Static_Wdebug, fields Static_Debuglistview$ & ",ROWCNT,ALL,NOWAIT" : Rowcount
!
         let Debug_Start(1)=Rowcount
         let Debug_End(1)=Rowcount
!
         #Select# Errtype #Case# Db_Warning
            let Debug_Color$(1)="/#0033FF"
         #Case# Db_Error
            let Debug_Color$(1)="/#AA0000"
         #Case Else#
            let Debug_Color$(1)="/#000000"
         #End Select#
!
         if Static_Debugactive then
            let Debug_Color$(1)=Debug_Color$(1) & ":#FFFF77"
         else
            let Debug_Color$(1)=Debug_Color$(1) & ":#FFFFFF"
         end if
!
         print #Static_Wdebug, fields Static_Debuglistview$ & ",ATTR,1200" : (Mat Debug_Start, Mat Debug_End, Mat Debug_Color$)
      end if
!
   fnend
!
READDEBUG: !  Reads The Debug Listview To Return The Last Thing The User Clicked On
   def Fnreaddebug(&Object;&Field,&Message$)
      input #Static_Wdebug, fields Static_Debuglistview$&",ROW,SEL,NOWAIT" : (Mat Debugobject, Mat Debugfield, Mat Debugmessage$)
!
      let Object=Debugobject(1)
      let Field=Debugfield(1)
      let Message$=Debugmessage$(1) soflow IGNORE
!
   fnend
!
GETDEBUGSPEC: !  Return Debug Listview Spec For Input
   def Fngetdebugspec(&Spec$)
      let Spec$ = Static_Debuglistview$&",ROWSUB,SELONE, 1200"
   fnend
!
GETDEBUGWINDOW: ! Returns The Debug Window Number
   def Fngetdebugwindow
      let Fngetdebugwindow=Static_Wdebug
   fnend
!
CLOSEDEBUGWINDOW: !  Close The Debug Window,  If Open
   def Fnclosedebugwindow
      if Static_Wdebug And File(Static_Wdebug<>-1) then
         close #Static_Wdebug:
      end if
      let Static_Wdebug=0
   fnend
!
!  #Autonumber# 43000,10
!  ======================= Toolbar Window ======================
!  = These Variables Are Used Only In Toolbar Window Functions =
!  =============================================================
   dim Static_Toolbarvsize, Static_Toolbarhsize
   dim Static_Wtoolbar
!
   def Fnopentoolbarwindow(Toolbarvsize,Toolbarhsize)
      let Static_Toolbarvsize=Toolbarvsize
      let Static_Toolbarhsize=Toolbarhsize
      open #(Static_Wtoolbar:=Fngetfilenumber): "SROW=2,SCOL=2,ROWS="&Str$(Static_Toolbarvsize)&",COLS="&Str$(Static_Toolbarhsize)&", Border=S, Caption=Toolbar", display, outin
   fnend
!
PAINTTOOLBARWINDOW: !  Paint The Toolbar
   def Fnpainttoolbarwindow(Mat Screenio$,Mat Screenio;___,Numberofbuttons,ButtonRows)
!
      let Numberofbuttons=Fninitializebuttons
      let ButtonRows=int((NumberOfButtons+1)/2)
!
      let Fnopenattributeswindow(Static_Wtoolbar)
      let Fnopenfieldswindow(Static_Wtoolbar,Static_Toolbarvsize,ButtonRows+2)
      let Fnopenbuttonwindow(Static_Wtoolbar,Static_Toolbarvsize,ButtonRows)
!
      let Fnpaintattributeswindow(Mat Screenio$,Mat Screenio)
      let Fnpaintfieldswindow
      let Fnpaintbuttonwindow
!
   fnend
!
GETTOOLBARWINDOW: ! Return Toolbar Window Number
   def Fngettoolbarwindow
      let Fngettoolbarwindow=Static_Wtoolbar
   fnend
!
CLOSETOOLBARWINDOW: !  Close The Toolbar Window,  If Open
   def Fnclosetoolbarwindow
!
      let Fncloseattributeswindow
      let Fnclosefieldswindow
      let Fnclosebuttonwindow
!
      if Static_Wtoolbar And File(Static_Wtoolbar<>-1) then
         close #Static_Wtoolbar:
      end if
      let Static_Wtoolbar=0
   fnend
!
!  #Autonumber# 44000,10
! ====================== Attributes Window =======================
! = These Variables Are Used Only In Attributes Window Functions =
! ================================================================
!
   dim Wattributes
   dim Attributecaptions$(1)
   dim Attributecapspec$(1)
   dim Attributespec$(1)*60
   dim Attributedata$(1)*255
   dim AttributeTtip$(1)*255
   dim Attributesubs(1)
!
OPENATTRIBUTESWINDOW: !  Open  The Attributes Window And Set The Statics
   def Fnopenattributeswindow(Wtoolbar)
      open #(Wattributes:=Fngetfilenumber) : "SROW=2,SCOL=2,ROWS=15,COLS=24,Border=S,Caption=Window Attributes,Parent="&Str$(Wtoolbar),display,outin
   fnend
!
PAINTATTRIBUTESWINDOW: !  Paint  The Attributes Window
   def Fnpaintattributeswindow(Mat Screenio$, Mat Screenio;___,I)
      let Fndefineattributeswindow(Mat Attributecaptions$, Mat Attributecapspec$,Mat Attributespec$,Mat Attributedata$,mat AttributeTtip$,Mat Attributesubs)
!
      let Fnfiletoscreen(Mat Screenio$,Mat Screenio, Mat Attributedata$, Mat Attributesubs)
      print #Wattributes, fields Mat Attributecapspec$ : Mat Attributecaptions$
      print #Wattributes, fields Mat Attributespec$, help mat AttributeTTip$ : Mat Attributedata$
   fnend
!
GETATTRIBUTESSPEC: !  Return  The Input Arrays
   def Fngetattributespec(Mat Spec$, Mat Data$, Mat TTip$, Mat Subs;___,Index)
      let Fndefineattributeswindow(Mat Attributecaptions$, Mat Attributecapspec$,Mat Attributespec$,Mat Attributedata$,mat AttributeTtip$,Mat Attributesubs)
!
      mat Spec$(Udim(Mat Attributespec$))=Attributespec$
      mat Data$(Udim(Mat Attributedata$))=Attributedata$
      mat Subs(Udim(Mat Attributesubs))=Attributesubs
      mat TTip$(Udim(mat AttributeTtip$))=AttributeTTip$
!
      for Index=1 to Udim(Mat Spec$)
         let Spec$(Index)=Srep$(Uprc$(Spec$(Index)),",S,",",/#000000:#FFFF77,")
      next Index
!
   fnend
!
SETINPUTATTRIBUTESCONTROL: ! Set The Attributes Control Based On The Fkey Passed In
   def Fnsetinputattributescontrol(Function)
      let Fndefineattributeswindow(Mat Attributecaptions$, Mat Attributecapspec$,Mat Attributespec$,Mat Attributedata$,mat AttributeTTip$,Mat Attributesubs)
      let Fnsetinputattributescontrol=Attributesubs(Function-1100)
   fnend
!
COLORATTRIBUTEACTIVE: ! Return The Input Arrays
   def Fncolorattributeactive(Active,Mat Screenio$,Mat Screenio;___,Index)
!
      let Fndefineattributeswindow(Mat Attributecaptions$, Mat Attributecapspec$,Mat Attributespec$,Mat Attributedata$,mat AttributeTTip$,Mat Attributesubs)
      let Fnfiletoscreen(Mat Screenio$,Mat Screenio, Mat Attributedata$,Mat Attributesubs)
      let Fnadjustcolorbuttons(Mat Attributespec$,Mat Attributedata$,Mat Attributesubs)
! .    !
      if Active then
         for Index=1 to Udim(Mat Attributespec$)
            let Attributespec$(Index)=Srep$(Uprc$(Attributespec$(Index)),",S,",",S/#000000:#FFFF77,")
         next Index
      else
         for Index=1 to Udim(Mat Attributespec$)
            let Attributespec$(Index)=Srep$(Uprc$(Attributespec$(Index)),",S,",",S/#000000:#FFFFFF,")
         next Index
      end if
!
      print #Wattributes, fields Mat Attributespec$, help mat AttributeTTip$ : Mat Attributedata$
!
   fnend
!
!
GETATTRIBUTESWINDOW: ! Return Attributes Window Number
   def Fngetattributeswindow
      let Fngetattributeswindow = Wattributes
   fnend
!
CLOSEATTRIBUTESWINDOW: !  Close The Attributes Window,   If Open
   def Fncloseattributeswindow
      if Wattributes And File(Wattributes<>-1) then
         close #Wattributes:
      end if
      let Wattributes=0
   fnend
!
!   #Autonumber# 45000,5
!  ====================== Fields Window =======================
!  = These Variables Are Used Only In Fields Window Functions =
!  ============================================================
!
   dim Fieldsheadings$(4),Fieldswidths(4), Fieldsspec$(4)
   dim Fieldsname$(1)*30,Fieldsdescription$(1)*60,Fieldstype$(1),FieldsDateSpec$(1)*64
   dim Fields_Start(1),Fields_End(1),Fields_Color$(1)
!
   dim Static_Fieldslistview$*80
   dim Static_Fieldscount
   dim Static_Fieldsvsize, Static_Fieldshsize
   dim Static_Wfields
!
OPENFIELDSWINDOW: !  Open  The Fields Window Here
   def Fnopenfieldswindow(Wtoolbar,Toolbarvsize,Buttonsize)
      let Static_Fieldsvsize=Toolbarvsize - Buttonsize - 19
      let Static_Fieldshsize=24
      open #(Static_Wfields:=Fngetfilenumber) : "SROW=19,SCOL=2,ROWS="&Str$(Static_Fieldsvsize)&",COLS="&Str$(Static_Fieldshsize)&",Border=S, Caption=Field List,Parent="&Str$(Wtoolbar),display,outin
   fnend
!
PAINTFIELDSWINDOW: !  Put The Listview In The Fields Window Here
   def Fnpaintfieldswindow
!
      let Fieldsheadings$(1)="Name"
      let Fieldswidths(1)=9
      let Fieldsspec$(1)="V 50"
      let Fieldsheadings$(2)="Description"
      let Fieldswidths(2)=14
      let Fieldsspec$(2)="V 255"
      let Fieldsheadings$(3)="Type"
      let Fieldswidths(3)=5
      let Fieldsspec$(3)="V 30"
      let Fieldsheadings$(4)="Date"
      let Fieldswidths(4)=3
      let Fieldsspec$(4)="V 64"
!
      let Static_Fieldslistview$="1,1,LIST "&Str$(Static_Fieldsvsize)&"/"&Str$(Static_Fieldshsize)
!
      print #Static_Wfields, fields Static_Fieldslistview$&",HEADERS,/W:W,1300" : (Mat Fieldsheadings$, Mat Fieldswidths, Mat Fieldsspec$)
   fnend
!
COLORFIELDSACTIVE: !  Colors The Debug Window Yellow If Its Active
   def Fncolorfieldsactive(;Active,_,Rowcount)
      if Active then
         if Static_Fieldsactive then ! Do Nothing
         else
            let Static_Fieldsactive=1
            input #Static_Wfields, fields Static_Fieldslistview$ & ",ROWCNT,ALL,NOWAIT" : Rowcount
            if Rowcount then
               let Fields_Start(1)=1
               let Fields_End(1)=Rowcount
               let Fields_Color$(1)="/#000000:#FFFF77"
               print #Static_Wfields, fields Static_Fieldslistview$ & ",ATTR,1300" : (Mat Fields_Start, Mat Fields_End, Mat Fields_Color$)
            end if
         end if
      else
         if Static_Fieldsactive then
            let Static_Fieldsactive=0
            input #Static_Wfields, fields Static_Fieldslistview$ & ",ROWCNT,ALL,NOWAIT" : Rowcount
            if Rowcount then
               let Fields_Start(1)=1 !:
               let Fields_End(1)=Rowcount
               let Fields_Color$(1)="/#000000:#FFFFFF"
               print #Static_Wfields, fields Static_Fieldslistview$ & ",ATTR,1300" : (Mat Fields_Start, Mat Fields_End, Mat Fields_Color$)
            end if
         else ! Do Nothing
         end if
      end if
   fnend
!
REPOPULATEFIELDSLISTVIEW: !  Prints  Items  To  The Debug Listview
   def Fnrepopulatefieldslistview(Layoutname$;&Prefix$)
!
      if Trim$(Layoutname$)<>"" And Fndoeslayoutexist(Screenio$(Si_Filelay)) then
         let fnClearLayoutCache
         let Fnreadlayoutarrays(Layoutname$,Prefix$,Mat Fieldsssubs$,Mat Fieldsnsubs$,Mat Fieldssspec$,Mat Fieldsnspec$,Mat Fieldssdescription$,Mat Fieldsndescription$,mat FieldsSPos,mat FieldsNPos,0,mat FieldsSDateSpec$,mat FieldsNDateSpec$)
!
         print #Static_Wfields, fields Static_Fieldslistview$ & ",=,1300" : (Mat Fieldsssubs$, Mat Fieldssdescription$, Mat Fieldssspec$, mat FieldsSDateSpec$)
         print #Static_Wfields, fields Static_Fieldslistview$ & ",+,1300" : (Mat Fieldsnsubs$, Mat Fieldsndescription$, Mat Fieldsnspec$, mat FieldsNDateSpec$)
         let Static_Fieldscount=Udim(Mat Fieldsssubs$) + Udim(Mat Fieldsnsubs$)
!
      else
         mat Fieldsssubs$(0) : mat Fieldssspec$(0) : mat Fieldssdescription$(0) : mat FieldsSDateSpec$(0)
         print #Static_Wfields, fields Static_Fieldslistview$ & ",=,1300" : (Mat Fieldsssubs$, Mat Fieldssspec$, Mat Fieldssdescription$, mat FieldsSDateSpec$)
         let Static_Fieldscount=0
      end if
   fnend
!
READFIELDS: ! Reads The Debug Listview To Return The Last Thing The User Clicked On
   def Fnreadfields(&Name$,&Description$,&Type$;&DateSpec$)
      mat Fieldsname$(1) : mat Fieldsdescription$(1) : mat Fieldstype$(1) : mat FieldsDateSpec$(1)
!
      input #Static_Wfields, fields Static_Fieldslistview$&",ROW,SEL,NOWAIT" : (Mat Fieldsname$, Mat Fieldsdescription$, Mat Fieldstype$, mat FieldsDateSpec$)
      if udim(mat Fieldsname$) and udim(mat Fieldsdescription$) and udim(mat FieldsType$) then
         let Name$=Trim$(Fieldsname$(1))(1:50)
         let Description$=Trim$(Fieldsdescription$(1))(1:255)
         let Type$=Trim$(Fieldstype$(1))(1:30)
         if udim(mat FieldsDateSpec$) then
            let DateSpec$=FieldsDateSpec$(1)
         end if

         let fnReadFields=1
      end if
   fnend
!
GETFIELDSSPEC: !  Returns  The Fields Listview Spec For Input
   def Fngetfieldsspec(&Spec$)
      let Spec$=Static_Fieldslistview$&",ROWSUB,SELONE,1300"
   fnend
!
GETFIELDSCOUNT: ! Returns The Fields Count
   def Fngetfieldscount
      let Fngetfieldscount=Static_Fieldscount
   fnend
!
GETFIELDSWINDOW: ! Return  The Fields Window Number
   def Fngetfieldswindow
      let Fngetfieldswindow=Static_Wfields
   fnend
!
CLOSEFIELDSWINDOW: !   Close  The Debug Window,   If Open
   def Fnclosefieldswindow
      if Static_Wfields And File(Static_Wfields<>-1) then
         close #Static_Wfields:
      end if
      let Static_Wfields=0
   fnend
!
! #Autonumber# 46000,5
! ==================== Buttons Window =========================
! = These Variables Are Used Only In Buttons Window Functions =
! =============================================================
!
   dim Static_Wbutton
   dim Static_Buttonvsize
   dim Buttonspec$(1)*30
   dim Static_Buttonfkey
   dim Buttons$(1)*30, Buttontooltip$(1)*1000
!
INITIALIZEBUTTONS: !   Initialize The Buttons Static Variables
   def Fninitializebuttons(;___,Index)
      let Fndefinebuttons(Mat Buttons$, Mat Buttontooltip$)
      let Fninitializebuttons=Udim(Mat Buttons$)
   fnend

   dim ValidDelim$*64
   def fnFixTooltips(mat X$;___,Index,TtipVer,Delim$,ItsValid,Jndex)
      if fn42 then let TTipVer=4 else let TTipVer=3
      let ValidDelim$=";:|\`~!@#$%^&*()-_=+{[}]'"",<.>/?"
      for Index=1 to udim(mat X$)

         if len(trim$(x$(Index))) then
            let ItsValid=0

            if fnIsDigit(x$(Index)(1:1)) then
               let Delim$=x$(Index)(len(x$(Index)):len(x$(Index)))
               if Delim$=x$(Index)(2:2) then
                  if ~Pos(x$(Index)(3:len(x$(Index))-1),Delim$) then
                     let ItsValid=1
                  end if
               else if x$(Index)(2:2)=";" then
                  if ~pos(x$(Index)(3:len(x$(Index))),";") then
                     let X$(Index)=x$(Index)&";"
                     let ItsValid=1
                  end if
               end if
            end if

            if ~ItsValid then
               let Jndex=0
               do while Jndex<len(ValidDelim$)
                  let Jndex+=1
               loop while pos(x$(Index),ValidDelim$(Jndex:Jndex))
               if pos(x$(Index),ValidDelim$(Jndex:Jndex)) then
                  let X$(Index)=srep$(x$(Index),";",":")
                  let Jndex=pos(ValidDelim$,";")
               end if

               let X$(Index)=str$(TtipVer)&ValidDelim$(Jndex:Jndex)&X$(Index)&ValidDelim$(Jndex:Jndex)

            end if
         end if
      next Index
   fnend

   def fnIsDigit(x$;___,Index,NotNumber)
      for Index=1 to len(x$)
         if ~Pos("0123456789",X$(Index:Index)) then
            let NotNumber=1
         end if
      next Index
      let fnIsDigit=~NotNumber
   fnend
!
OPENBUTTONWINDOW: !  Open  The Buttons Window And Set  The Statics
   def Fnopenbuttonwindow(Wtoolbar,Toolbarvsize,Buttonsize;___,Buttonhposition,Buttonvposition,Buttonhsize,Buttonvsize)
      open #(Static_Wbutton:=Fngetfilenumber) : "SROW="&Str$(Toolbarvsize-Buttonsize)&",SCOL=2,ROWS="&Str$(Buttonsize)&", COLS=24, Border=S, Caption=Toolbox, Parent="&Str$(Wtoolbar),display,outin
      let Static_Buttonvsize=Buttonsize
      let Static_Buttonfkey=1400
   fnend
!
PAINTBUTTONWINDOW: !  Paint  The Buttons On  The Window
   def Fnpaintbuttonwindow(;___,Index)
      mat Buttonspec$(Udim(Mat Buttons$))
      for Index=1 to Udim(Mat Buttons$)
         let Buttonspec$(Index)=Str$(int((Index-1)/2)+1)&","&str$(2+(11*Mod((Index-1),2)))&","&str$(11-Mod((Index),2))&"/CC 22,/W:W,B"&Str$(Static_Buttonfkey+Index)
      next Index
      print #Static_Wbutton, fields Mat Buttonspec$, help Mat Buttontooltip$ : Mat Buttons$
   fnend
!
READBUTTON: !  Read Which Button  Was  Pressed
   def Fnreadbutton$*30(;Fkeyvalue,_,Index)
      if Fkeyvalue=0 then let Fkeyvalue=Fkey
!
      if Fkeyvalue>Static_Buttonfkey And Fkeyvalue<=Static_Buttonfkey+Udim(Buttons$) then
         let Fnreadbutton$=Buttons$(Fkeyvalue-Static_Buttonfkey)
      end if
   fnend
!
GETBUTTONWINDOW: ! Return Attributes Window Number
   def Fngetbuttonwindow
      let Fngetbuttonwindow = Static_Wbutton
   fnend
!
CLOSEBUTTONWINDOW: !   Close  The Button  Window,   If Open
   def Fnclosebuttonwindow
      if Static_Wbutton And File(Static_Wbutton<>-1) then
         close #Static_Wbutton:
      end if
      let Static_Wbutton=0
   fnend
!
!   #Autonumber# 47000,10
!  ====================== Editor Window =======================
!  = These Variables Are Used Only In Editor Window Functions =
!  ============================================================
!
   dim Static_Weditor,Static_Editorvpos,Static_Editorhpos
   dim Static_Wcontainer,Static_Containervpos,Static_Containerhpos
!
OPENEDITORWINDOW: !  Open The Editor Window
   def Fnopeneditorwindow(Windowvposition, Windowhposition, Mat Screenio$, Mat Screenio;___,Bordersize,Caption$*80,Hpos,Vpos)
!
      let Static_Editorhpos=1
      let Static_Editorvpos=1
      if Screenio(Si_Border) Or Pos(Uprc$(Screenio$(Si_Attributes)),"BORDER") then
         let Bordersize=2
         let Static_Editorhpos=2
         let Static_Editorvpos=2
      end if
!
      if Trim$(Screenio$(Si_Caption))<>"" then
         let Caption$=",CAPTION=Editor -  "&Trim$(Screenio$(Si_Caption))
      else
         let Caption$=",CAPTION=Editor"
      end if
!
      open #(Static_Wcontainer:=Fngetfilenumber): "SROW="&Str$(Windowvposition)&",SCOL="&Str$(Windowhposition)&",ROWS="&Str$(Screenio(Si_Vsize)+Bordersize)&",COLS="&Str$(Screenio(Si_Hsize)+Bordersize)&",BORDER=S"&Caption$,display,outin
!
      let Static_Containervpos=Windowvposition
      let Static_Containerhpos=Windowhposition
!
      let Static_Weditor=Fnopenwindow(Static_Editorvpos,Static_Editorhpos,Mat Screenio$, Mat Screenio,Static_Wcontainer)
!
   fnend
!
GETEDITORWINDOW: !  Return  Window Number For Main Editor Window
   def Fngeteditorwindow
      let Fngeteditorwindow=Static_Weditor
   fnend
!
GETEDITORPOSITION: !  Return Window Position For Main Editor Window
   def Fngeteditorposition(;&Vpos,&Hpos)
      let Vpos=Static_Editorvpos+Static_Containervpos-1
      let Hpos=Static_Editorhpos+Static_Containerhpos-1
   fnend
!
CLOSEEDITORWINDOW: !  Close Editor Window If Its Open
   def Fncloseeditorwindow
      if Static_Weditor then
         if File(Static_Weditor)<>-1 then
            close #Static_Weditor:
         end if
         let Static_Weditor=0
         let Static_Editorhpos=0
         let Static_Editorvpos=0
      end if
!
      if Static_Wcontainer then
         if File(Static_Wcontainer)<>-1 then
            close #Static_Wcontainer:
         end if
!
         let Static_Wcontainer=0
         let Static_Containervpos=0
         let Static_Containerhpos=0
      end if
   fnend

   def fnCheckForUpdates(;___,Connection,V,String$*1000,Window)
      open #(Window:=fnGetFileNumber): "srow=10,scol=40,rows=1,cols=30,Border=S",display,outin
      print #Window, fields "1,1,CC 30" : "Contacting Server..."
      open #(Connection:=fnGetFileNumber): "name=http://www.sageax.com/downloads/ScreenIOVersion.txt, http=client",display,outin error Ignore
      if file(Connection)=0 then
         print #Connection: " " ! Required in BR 4.2. You have to print something to the connection before you can input from it. Optional in 4.3+
         linput #Connection: String$ eof Ignore
         close #Connection:
         close #Window:
         let V=-999
         let V=Val(String$) conv Ignore
         if V=-999 then
            let msgbox("There was an error checking the latest version on the Server. Check your internet connection, or try again later."&hex$("0D0A0D0A")&"If the problem persists, please contact Gabriel Bakker at gabriel.bakker@gmail.com.","Connection Failed","Ok","EXCL")
         else if V>fnVersion then
            if (2==msgbox("A newer version (ScreenIO v"&str$(V)&") is available. (You're currently running ScreenIO v"&str$(fnVersion)&")."&hex$("0D0A0D0A")&"Would you like to download the update from our website?","Update Y/N?","Yn","QST")) then
               execute "sy -C -M start http://www.sageax.com/downloads/ScreenIO.zip"
            end if
         else
            let msgbox("Your version is up to date!"&hex$("0D0A0D0A")&"You are running ScreenIO v"&str$(fnVersion)&", the current version.","ScreenIO is Up to Date","Ok","EXCL")
         end if
      else
         let msgbox("The server, www.sageax.com, could not be reached. Check your internet connection, or try again later."&hex$("0D0A0D0A")&"If the problem persists, please contact Gabriel Bakker at gabriel.bakker@gmail.com.","Connection Failed","Ok","EXCL")
         close #Window:
         if file(Connection)><-1 then close #Connection:
      end if
   fnend
!
!  #Autonumber# 48000,2
!  ======================================================================
!  ============================ Definitions =============================
!  ======================================================================
!  These Functions Define The Way The Windows Menu,  Buttons,  Etc Look
!  And The Actions Associated With Them
!
DEFINEWINDOWSMENU: !  Define The Windows Menu
   def Fndefinewindowsmenu(Mat M$, Mat Pgm$, Mat Status$;___,Index)
!
      restore DEFINEWINDOWSMENU
      data "&File","","","  &New","new","E","  &Load","load","E","  &Save and Compile","save","E","  &Compile","recompileone","E","  Save and &Test","saveandtest","E","  -","","","  E&xport Screen","export","E","  &Import Screen","import","E","  -","","","  &Purge ScreenFlds File","purge","E","  Recompile &All Screens","recompile","E","  -","","","  &FileIO","fileio","E","  New &Window","newwindow","E","  &Run Application","brconsole","E","  &Explore Local Folder","windowsexplorer","E","  -","","","  &Quit","quit","E"
      data "&Options","","", "  Click To &Move","clickmove","ECX", "  Preview &Listviews","poplist","ECX", "  Real-Time &Filters","filter","EC"
      data "&Tools","","", "  Power &Search","search","E", "  &Code Explorer","codeexplore","E", "  -","","", "  &Generate Screen","generatescreen","E", "  &Generate Code","generatecode","E", "  -","","", "  &Orphaned Functions","orphanedfunctions","E"
      data "&Control","","","  Add &Field","field","E","  Add E&xit Buttons","exit buttons","E","  Add &Add/Edit Buttons","ae buttons","E","  Add Add/Edit/&Delete Buttons","aed buttons","E","  -","","","  Add &Text Box","text box","E","  Add &Caption","caption","E","  Add C&heck Box","check box","E","  Add C&ombo Box","combo box","E","  Add &Listview","listview","E","  Add &Search Box","search box","E","  Add F&ilter Box","filter box","E","  Add &Button","button","E","  Add &Picture","picture","E"
      ! data "  Add C&alendar Button","calendar","E"
      data "  Add &Frame","frame","E","  Add Sc&reen","screen","E","  -","","","  S&kip a Space","skip a space","E","  -","","","  Change Control T&ype","changetype","E"
      data "&Screen","","","  &Adjust Screen Size","resize screen","E","  &Move Controls","movemode","E","  &Draw Movement Grid","drawdots","E","  Visit &Checklist","debuglist","E","  -","","","  Set &FG Color","setfgcolor","E","  Set &BG Color","setbgcolor","E","  Select File &Layout","selectlayout","E","  Set &Events","events","E","  Set Tab &Order","taborder","E","  -","","","  Configure &Debug","debug","E","  Configure &Styles","protected","E","  -","","","  &Test Screen","test","E"
      data "&Help","","","  &Documentation","help","E","  &Recent Changes","recentchanges","E","  -","","","  Check for &Updates","checkupdates","E","  &About","about","E"
!
      mat M$(0) : mat Pgm$(0) : mat Status$(0)
READNEXTMENU: ! Read The Next Menu Option Here
      mat M$(Udim(Mat M$)+1) : mat Pgm$(Udim(Mat M$)) : mat Status$(Udim(Mat M$))
      read M$(Udim(Mat M$)), Pgm$(Udim(Mat M$)), Status$(Udim(Mat M$)) eof DONEREADMENU
      goto READNEXTMENU
DONEREADMENU: !  Finished Reading The Menu

      let fnSettings

! .   ! Apply Checkmark Environment Variables
      for Index=1 to Udim(Mat Pgm$)
         if Pos(Uprc$(Status$(Index)),"C") then
            if Pos(Uprc$(Trim$(Env$(Pgm$(Index)))),"Y") then
               if ~(Pos(Uprc$(Status$(Index)),"X")) then
                  let Status$(Index)=Status$(Index)&"X"
               end if
            else if Pos(Uprc$(Trim$(Env$(Pgm$(Index)))),"N") then
               let Status$(Index)=Srep$(Uprc$(Status$(Index)),"X","")
            else
               ! No env dollar, use ini file, then update setenv
               #Select# lwrc$(trim$(Pgm$(Index))) #Case# "clickmove"
                  if Setting_ClickToMove then
                     if ~(Pos(Uprc$(Status$(Index)),"X")) then
                        let Status$(Index)=Status$(Index)&"X"
                     end if
                  else
                     let Status$(Index)=Srep$(Uprc$(Status$(Index)),"X","")
                  end if
               #Case# "poplist"
                  if Setting_PreviewListviews then
                     if ~(Pos(Uprc$(Status$(Index)),"X")) then
                        let Status$(Index)=Status$(Index)&"X"
                     end if
                  else
                     let Status$(Index)=Srep$(Uprc$(Status$(Index)),"X","")
                  end if
               #Case# "filter"
                  if Setting_RealtimeFilters then
                     if ~(Pos(Uprc$(Status$(Index)),"X")) then
                        let Status$(Index)=Status$(Index)&"X"
                     end if
                  else
                     let Status$(Index)=Srep$(Uprc$(Status$(Index)),"X","")
                  end if
               ! #Case# "debugmode"
               !    if setting_DebugMode then
               !       if ~(Pos(Uprc$(Status$(Index)),"X")) then
               !          let Status$(Index)=Status$(Index)&"X"
               !       end if
               !    else
               !       let Status$(Index)=Srep$(Uprc$(Status$(Index)),"X","")
               !    end if
               #End Select#

               if Pos(Uprc$(Status$(Index)),"X") then
                  let Setenv(Pgm$(Index),"Y")
               else
                  let Setenv(Pgm$(Index),"N")
               end if
            end if
         end if
      next Index

   fnend
!
PROCESSWINDOWSMENU: !   Process A  Command From  The Windows Menu
   def Fnprocesswindowsmenu(Mat Screenio$, Mat Screenio,[[Screencontrols]];___,Screen$)
!
      dim Menunew, Menuload, Menusave, Menuquit, Menuabout, MenuRecentChanges, Menuhelp, Menuevents, Menutaborder, Menuexport, Menuimport, Menurecompile, Menutest, Menurecompileone, Menupurge, Menudebug, Menufgcolor, Menubgcolor, Menuselectlayout, Menumovement, Menudebuglist, Menufieldslist, Menuaddcontrol, MenuProtected
!
      let Menunew=1 : let Menuload=2 : let Menusave=3 : let Menuquit=4 !:
      let Menuabout=5 : let Menuhelp=6 : let Menuevents=7 : let Menutaborder=8 !:
      let Menuexport=9 : let Menuimport=10 : let Menurecompile=11 : let Menutest=12 !:
      let Menurecompileone=13 : let Menupurge=14 : let Menudebug=15 !:
      let Menufgcolor=16 : let Menubgcolor=17 : let Menuselectlayout=18 : let Menumovement=19 !:
      let Menudebuglist=20 : let Menufieldslist=21 : let Menuaddcontrol=22 : let MenuProtected=23 : let MenuRecentChanges=24 : MenuCheckUpdates=25
!
      #Select# Lwrc$(Menu$) #Case# "new"
         if Fnoktoproceed(Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
            let Fnreadscreen("",Mat Screenio$,Mat Screenio,[[Screencontrols]])
            let Fnprocesswindowsmenu=Menunew
         end if

      #Case# "load"
         if Fnoktoproceed(Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
            let Screen$=Fnselectscreen$
            if Trim$(Screen$)<>"" then
               if Fnreadscreen(Screen$,Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
                  let Fnprocesswindowsmenu=Menuload
               else
                  let Msgbox("Error Reading Screen - Screen not  found","Error","OK","ERR")
               end if
            end if
         end if

      #Case# "recompileone"
         if Fncompilehelperlibrary(Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
            let Fnprocesswindowsmenu=Menurecompileone
         end if

      #Case# "save"
         if Fnwritescreen(Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
            let Fnprocesswindowsmenu=Menusave
         end if

      #Case# "saveandtest"
         if fnWriteScreen(Mat ScreenIO$,mat ScreenIO,[[ScreenControls]],1) then
            execute "system -C -M "&Fngetbrexe$&" -"&Fngetwbcfg$&" run "&setting_ScreenFolder$&"\"&Trim$(Screenio$(Si_Screencode))
            let fnProcessWindowsMenu=MenuTest
         end if

      #Case# "quit"
         if Fnoktoproceed(Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
            let Fnprocesswindowsmenu=Menuquit
         end if

      #Case# "brconsole"
         execute "system -C -M "&Fngetbrexe$&" -"&Fngetwbcfg$

      #Case# "windowsexplorer"
         execute "system -C start "&os_filename$(".")

      #Case# "newwindow"
         execute "system -C -M "&Fngetbrexe$&" -"&Fngetwbcfg$&" run "&setting_ScreenIOPath$

      #Case# "fileio"
         execute "system -C -M "&Fngetbrexe$&" -"&Fngetwbcfg$&" run "&setting_FileIOPath$

      #Case# "export"
         if Fnexportscreen(Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
            let Fnprocesswindowsmenu=Menuexport
         end if
!
      #Case# "import"
         if Fnoktoproceed(Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
            if Fnimportscreen(Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
               let Fnprocesswindowsmenu=Menuimport
            end if
         end if
!
      #Case# "recompile"
         if Fnoktoproceed(Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
            let Fnrecompileallscreens(Mat Screenio$,Mat Screenio,[[Screencontrols]])
            let Fnprocesswindowsmenu=Menurecompile
         end if
!
      #Case# "purge"
         if Fnoktoproceed(Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
            let Fnclosescreenfiles
            if Exists("screen\temp.dat") then
               print "There is already temp data present. Please Delete it and retry."
               pause  ! Give Programmer Chance To Recover.
            end if
            if Exists("screen\oldscreenfld.dat") then execute "free screen\oldscreenfld.dat"
            if Exists("screen\oldscreenfld.key") then execute "free screen\oldscreenfld.key"
            if Exists("screen\oldscreenfld.ky2") then execute "free screen\oldscreenfld.ky2"
            execute "copy screen\screenfld.dat screen\temp.dat -d"
            execute "rename screen\screenfld.dat screen\oldscreenfld.dat"
            execute "rename screen\temp.dat screen\screenfld.dat"
            execute "rename screen\screenfld.key screen\oldscreenfld.key"
            execute "rename screen\screenfld.ky2 screen\oldscreenfld.ky2"
            let Fnupdatefile("screenfld")
            let Fnopenscreenfiles(Mat Screenio$,Mat Screenio)
            let Fnprocesswindowsmenu=Menupurge
         end if
!
      #Case# "test"
         if Len(Trim$(Screenio$(Si_Screencode))) And Exists(setting_ScreenFolder$&"\"&Trim$(Screenio$(Si_Screencode))&".br") then
            execute "system -C -M "&Fngetbrexe$&" -"&Fngetwbcfg$&" run "&setting_ScreenFolder$&"\"&Trim$(Screenio$(Si_Screencode))
            let Fnprocesswindowsmenu=Menutest
         else
            let Msgbox("You must save your screen before testing it.")
         end if
      #Case# "help"
         execute "system -C -M start http://www.brwiki.com/index.php?title=ScreenIO_Library"
         let Fnprocesswindowsmenu=Menuhelp
      #Case# "recentchanges"
         if exists("recentchanges.txt") then execute "system -C -M start recentchanges.txt"
         let Fnprocesswindowsmenu=MenuRecentChanges
      #Case# "about"
         let Fnshowabout
         let Fnprocesswindowsmenu=Menuabout
      #Case# "checkupdates"
         let fnCheckForUpdates
         let fnProcessWindowsMenu=MenuCheckUpdates
      #Case# "events"
         let Fnprocesswindowsmenu=Menuevents
      #Case# "taborder"
         let Fnprocesswindowsmenu=Menutaborder
      #Case# "debug"
         let Fnprocesswindowsmenu=Menudebug
      #Case# "protected"
         let Fnprocesswindowsmenu=MenuProtected
      #Case# "field"
         let Fnprocesswindowsmenu=Menufieldslist
      #Case# "text box" # "caption" # "check box" # "listview" # "search box" # "button" # "picture" # "skip a space" # "frame" # "screen" # "combo box" # "filter box" # "calendar"
         let Fnprocesswindowsmenu=Menuaddcontrol
      #Case# "movemode"
         let Fnprocesswindowsmenu=Menumovement
      #Case# "debuglist"
         let Fnprocesswindowsmenu=Menudebuglist
      #Case# "setfgcolor"
         let Fnprocesswindowsmenu=Menufgcolor
      #Case# "setbgcolor"
         let Fnprocesswindowsmenu=Menubgcolor
      #Case# "selectlayout"
         let Fnprocesswindowsmenu=Menuselectlayout
      #Case# "changetype"
         let fnChangeControlType(Mat Screenio$,Mat Screenio,Control,[[Screencontrols]])
      #Case# "resize screen"
         let Fnresizescreen(Mat Screenio$,Mat Screenio,[[Screencontrols]])
      #Case# "exit buttons"
         let Fnaddexitbuttons(Mat Screenio$,Mat Screenio,[[Screencontrols]])
      #Case# "ae buttons"
         let FnaddAEbuttons(Mat Screenio$,Mat Screenio,[[Screencontrols]],"",0,0,0,0,1) ! Suppress Delete Button
      #Case# "aed buttons"
         let FnaddAEbuttons(Mat Screenio$,Mat Screenio,[[Screencontrols]])
      #Case# "search"
         let fnPowerSearch
      #Case# "codeexplore"
         let fnCodeExplore(Mat ScreenIO$, mat ScreenIO, [[ScreenControls]])
      #Case# "orphanedfunctions"
         let fnOrphanedFunctions
      #Case# "generatecode"
         let fnGenerateCode(Mat ScreenIO$, mat ScreenIO, [[ScreenControls]])
      #Case# "generatescreen"
         if Fnoktoproceed(Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
            let FnGenerateScreen(Mat Screenio$,Mat Screenio,[[Screencontrols]])
         end if
      #Case# "drawdots"
         let SettingTempDots=1
         let DotsPrinted=0
         let fnProcessWindowsMenu=MenuMovement
      #Case Else#
         input Menu Status: Mat Status$
         if Menu and Menu<=udim(mat Status$) then
            if Pos(Uprc$(Status$(Menu)),"C") then
               if Pos(Uprc$(Status$(Menu)),"X") then
                  let Setenv(Menu$,"Y")
               else
                  let Setenv(Menu$,"N")
               end if
            end if
         end if
      #End Select#
   fnend
!
DEFINEBUTTONS: ! Define Toolbar Buttons
   def Fndefinebuttons(Mat Buttons$, Mat Tooltip$)
      mat Buttons$(14) : mat Tooltip$(14)
!
      let Buttons$(1)="Field" !:
      let Tooltip$(1)="Add the selected Database Field"
!
      let Buttons$(2)="Text Box" !:
      let Tooltip$(2)="Add a blank Text Box field"
!
      let Buttons$(3)="Caption" !:
      let Tooltip$(3)="Add an empty Caption"
!
      let Buttons$(4)="Check Box" !:
      let Tooltip$(4)="Add a blank Check Box field"
!
      let Buttons$(5)="Combo Box" !:
      let Tooltip$(5)="Add a combo box control."
!
      let Buttons$(6)="Listview" !:
      let Tooltip$(6)="Add a listview control"
!
      let Buttons$(7)="Search Box" !:
      let Tooltip$(7)="Add a Search Box to a Listview Control"
!
      let Buttons$(8)="Filter Box" !:
      let Tooltip$(8)="Add a BR filter box. (4.3+)"

      let Buttons$(9)="Button" !:
      let Tooltip$(9)="Add a Button"
!
      let Buttons$(10)="Picture" !:
      let Tooltip$(10)="Add a Picture"
!
      let buttons$(11)="~ Calendar ~"
      let tooltip$(11)="Add button that links to a date picker.(Coming Soon)"

      let Buttons$(12)="Frame" !:
      let Tooltip$(12)="Add a border for visual grouping."
!
      let Buttons$(13)="Screen" !:
      let Tooltip$(13)="Add an entire screen as a child control."

      let Buttons$(14)="Skip a Space" !:
      let Tooltip$(14)="Skip the next row for Automatic Placement"

      let fnFixTooltips(mat Tooltip$)
   fnend
!
PROCESSBUTTONS: ! Process A Button Click Here
   def Fnprocessbutton(Button$,&Mode,&Control,Mat Screenio$,Mat Screenio,[[Screencontrols]];___,Newcontrol,Relatedcontrol)
      #Select# Button$ #Case# "field"
         let Newcontrol=FnaddAndColorcurrentfield([[Screencontrols]],mat ScreenIO$,mat ScreenIO)
         if Newcontrol then
            let Mode=Inputeditormovemode
            let Control=Newcontrol
         end if
!
      #Case# "text box"
         let Newcontrol=Fnaddtextfield([[Screencontrols]])
         if Newcontrol then
            let Mode=Inputeditormovemode
            let Control=Newcontrol
            let Fgcolor$(Newcontrol)="W"
            let Bgcolor$(Newcontrol)="W"
         end if
!
      #Case# "caption"
         let Newcontrol=Fnaddcaption([[Screencontrols]])
         if Newcontrol then
            let Mode=Inputeditormovemode
            let Control=Newcontrol
            if Trim$(Screenio$(Si_Fgcolor))<>"" then
               let Fgcolor$(Newcontrol)=Trim$(Screenio$(Si_Fgcolor))
            end if
         end if
!
      #Case# "check box"
         let Newcontrol=Fnaddcheckbox([[Screencontrols]])
         if Newcontrol then
            let Mode=Inputeditormovemode
            let Control=Newcontrol
         end if
         if Trim$(Screenio$(Si_Fgcolor))<>"" then
            let Fgcolor$(Newcontrol)=Trim$(Screenio$(Si_Fgcolor))
         end if
!
      #Case# "search box"
         let Newcontrol=Fnaddsearchbox([[Screencontrols]],Mode,Control)
         if Newcontrol then
            let Mode=Inputeditormovemode
            let Control=Newcontrol
            let Fgcolor$(Newcontrol)="W"
            let Bgcolor$(Newcontrol)="W"
         end if
!
      #Case# "filter box"
         let Newcontrol=FnAddFilterBox([[Screencontrols]],Mode,Control)
         if Newcontrol then
            let Mode=Inputeditormovemode
            let Control=Newcontrol
            let Fgcolor$(Newcontrol)="W"
            let Bgcolor$(Newcontrol)="W"
         end if

      #Case# "calendar"
         let Newcontrol=FnAddCalendar([[Screencontrols]],Mode,Control)
         if Newcontrol then
            let Mode=Inputeditormovemode
            let Control=Newcontrol
            let Fgcolor$(Newcontrol)="W"
            let Bgcolor$(Newcontrol)="W"
         end if

      #Case# "listview"
         let Newcontrol=Fnaddlistview([[Screencontrols]])
         if Newcontrol then
            let Mode=Inputeditormovemode
            let Control=Newcontrol
            let Fgcolor$(Newcontrol)="W"
            let Bgcolor$(Newcontrol)="W"
         end if
!
      #Case# "button"
         let Newcontrol=Fnaddbutton([[Screencontrols]])
         if Newcontrol then
            let Mode=Inputeditormovemode
            let Control=Newcontrol
            let Fgcolor$(Newcontrol)="W"
            let Bgcolor$(Newcontrol)="W"
         end if
!
      #Case# "picture"
         let Newcontrol=Fnaddpicture([[Screencontrols]])
         if Newcontrol then
            let Mode=Inputeditormovemode
            let Control=Newcontrol
         end if
      #Case# "screen"
         Let Newcontrol=Fnaddscreen([[Screencontrols]])
         If Newcontrol Then
            Let Mode=Inputeditormovemode
            Let Control=Newcontrol
         End If
!
      #Case# "frame"
         let NewControl=fnAddFrame([[Screencontrols]])
         if NewControl then
            let Mode=InputEditorMoveMode
            let Control=NewControl
         end if

      #Case# "combo box"
         let NewControl=fnAddCombo([[Screencontrols]])
         if NewControl then
            let Mode=InputEditorMoveMode
            let Control=NewControl
         end if

      #Case# "skip a space"
         let Fnskipagap
!
      #Case Else#
         let Msgbox("This control type is not supported yet.","Control not supported","Ok","INF")
!
      #End Select#
   fnend
!
   dim WarnedYet
   dim TempClip$*100000
   def Fnaddtoclipboard(&ClipBoard$,Control,[[Screencontrols]];___,Child)

      let TempClip$=""
      let fnClipboardAdd(TempClip$,Control,[[ScreenControls]])
!
! .   ! Add listview children to clipboard also.
      if Lwrc$(Fieldtype$(Control))="listview" then
         for Child=1 to Udim(Mat Fieldtype$)
            if Parent$(Child)=Parent$(Control) And Lwrc$(Fieldtype$(Child))="listchld" then
               let fnClipboardAdd(TempClip$,Child,[[Screencontrols]])
            end if
         next Child
      end if

      if len(ClipBoard$)=0 then let WarnedYet=0

      if len(ClipBoard$)+len(TempClip$)>999999 then
         if ~WarnedYet then
            let msgbox("The Clipboard cannot hold that many controls.","Clipboard is full")
            let WarnedYet=1
         end if
      else
         let ClipBoard$=ClipBoard$&TempClip$
         let fnAddToClipboard=1
      end if
   fnend

   def fnClipboardAdd(&Clip$,Control,[[ScreenControls]])
      let Clip$=Clip$&Trim$(Controlname$(Control))&"_#_" !:
      let Clip$=Clip$&Trim$(Fieldname$(Control))&"_#_" !:
      let Clip$=Clip$&Trim$(Description$(Control))&"_#_" !:
      let Clip$=Clip$&Str$(Vposition(Control))&"_#_" !:
      let Clip$=Clip$&Str$(Hposition(Control))&"_#_" !:
      let Clip$=Clip$&Trim$(Fieldtype$(Control))&"_#_" !:
      let Clip$=Clip$&Str$(Specwidth(Control))&"_#_" !:
      let Clip$=Clip$&Str$(Width(Control))&"_#_" !:
      let Clip$=Clip$&Str$(Height(Control))&"_#_"
      let Clip$=Clip$&Trim$(Truevalue$(Control))&"_#_" !:
      let Clip$=Clip$&Trim$(Falsevalue$(Control))&"_#_" !:
      let Clip$=Clip$&Trim$(Function$(Control))&"_#_" !:
      let Clip$=Clip$&Trim$(Picture$(Control))&"_#_" !:
      let Clip$=Clip$&Trim$(Parent$(Control))&"_#_" !:
      let Clip$=Clip$&Trim$(Fgcolor$(Control))&"_#_" !:
      let Clip$=Clip$&Trim$(Bgcolor$(Control))&"_#_" !:
      let Clip$=Clip$&Trim$(Justify$(Control))&"_#_" !:
      let Clip$=Clip$&Trim$(Attr$(Control))&"_#_"
      let Clip$=Clip$&Str$(Multiselect(Control))&"_#_" !:
      let Clip$=Clip$&Str$(GridLines(Control))&"_#_" !:
      let Clip$=Clip$&Str$(Protected(Control))&"_#_" !:
      let Clip$=Clip$&Str$(Invisible(Control))&"_#_" !:
      let Clip$=Clip$&Trim$(Tooltip$(Control))&"_#_" !:
      let Clip$=Clip$&Trim$(Cnvrtin$(Control))&"_#_" !:
      let Clip$=Clip$&Trim$(Cnvrtout$(Control))&"_#_" !:
      let Clip$=Clip$&Trim$(Userdata$(Control))&"_#_" !:
      let Clip$=Clip$&"#!!#"&Chr$(13)
   fnend

   def Fnaddcontrolsfromclipboard(&Clipboard$,[[Screencontrols]];___,Added)
      let Clipboard$=Srep$(Clipboard$,Chr$(13),"") ! Strip Cr's
      do While Pos(Clipboard$,"#!!#")
! .      ! Read one control and add it to screen
         let Added+=Fnaddcontrolfromclip(Clipboard$,[[Screencontrols]])
! .      ! Strip it from Clipboard
         if Pos(Clipboard$,"#!!#") then
            let Clipboard$(1:Pos(Clipboard$,"#!!#")+3)=""
         end if
      loop
      if Added then let Fnaddcontrolsfromclipboard=1
   fnend
   def Fnaddcontrolfromclip(&Clipboard$,[[Screencontrols]];___,Controlname$*50,Fieldname$*50,Description$*255,Vposition,Hposition,Fieldtype$,Specwidth,Width,Height,Truevalue$*60,Falsevalue$*60,Function$*255,Picture$*255,Parent$*20,Fgcolor$,Bgcolor$,Protected,Invisible,Tooltip$*255,Cnvrtin$*255,Cnvrtout$*255,Multiselect,GridLines,Userdata$*255,Justify$,Attr$*255,Control)
      let Broken=0
      if ~Broken then let Controlname$=Fngetclip$(Broken,Clipboard$,"_#_") soflow BADCLIPBOARD
      if ~Broken then let Fieldname$=Fngetclip$(Broken,Clipboard$,"_#_") soflow BADCLIPBOARD
      if ~Broken then let Description$=Fngetclip$(Broken,Clipboard$,"_#_") soflow BADCLIPBOARD
      if ~Broken then let Vposition=Val(Fngetclip$(Broken,Clipboard$,"_#_")) conv BADCLIPBOARD
      if ~Broken then let Hposition=Val(Fngetclip$(Broken,Clipboard$,"_#_")) conv BADCLIPBOARD
      if ~Broken then let Fieldtype$=Fngetclip$(Broken,Clipboard$,"_#_") soflow BADCLIPBOARD
      if ~Broken then let Specwidth=Val(Fngetclip$(Broken,Clipboard$,"_#_")) conv BADCLIPBOARD
      if ~Broken then let Width=Val(Fngetclip$(Broken,Clipboard$,"_#_")) conv BADCLIPBOARD
      if ~Broken then let Height=Val(Fngetclip$(Broken,Clipboard$,"_#_")) conv BADCLIPBOARD
      if ~Broken then let Truevalue$=Fngetclip$(Broken,Clipboard$,"_#_") soflow BADCLIPBOARD
      if ~Broken then let Falsevalue$=Fngetclip$(Broken,Clipboard$,"_#_") soflow BADCLIPBOARD
      if ~Broken then let Function$=Fngetclip$(Broken,Clipboard$,"_#_") soflow BADCLIPBOARD
      if ~Broken then let Picture$=Fngetclip$(Broken,Clipboard$,"_#_") soflow BADCLIPBOARD
      if ~Broken then let Parent$=Fngetclip$(Broken,Clipboard$,"_#_") soflow BADCLIPBOARD
      if ~Broken then let Fgcolor$=Fngetclip$(Broken,Clipboard$,"_#_") soflow BADCLIPBOARD
      if ~Broken then let Bgcolor$=Fngetclip$(Broken,Clipboard$,"_#_") soflow BADCLIPBOARD
      if ~Broken then let Justify$=Fngetclip$(Broken,Clipboard$,"_#_") soflow BADCLIPBOARD
      if ~Broken then let Attr$=Fngetclip$(Broken,Clipboard$,"_#_") soflow BADCLIPBOARD
      if ~Broken then let Multiselect=Val(Fngetclip$(Broken,Clipboard$,"_#_")) conv BADCLIPBOARD
      if ~Broken then let GridLines=Val(Fngetclip$(Broken,Clipboard$,"_#_")) conv BADCLIPBOARD
      if ~Broken then let Protected=Val(Fngetclip$(Broken,Clipboard$,"_#_")) conv BADCLIPBOARD
      if ~Broken then let Invisible=Val(Fngetclip$(Broken,Clipboard$,"_#_")) conv BADCLIPBOARD
      if ~Broken then let Tooltip$=Fngetclip$(Broken,Clipboard$,"_#_") soflow BADCLIPBOARD
      if ~Broken then let Cnvrtin$=Fngetclip$(Broken,Clipboard$,"_#_") soflow BADCLIPBOARD
      if ~Broken then let Cnvrtout$=Fngetclip$(Broken,Clipboard$,"_#_") soflow BADCLIPBOARD
      if ~Broken then let Userdata$=Fngetclip$(Broken,Clipboard$,"_#_") soflow BADCLIPBOARD
      if ~Broken then
         let Control=Fnaddemptyfield([[Screencontrols]],1) !:
         let Controlname$(Control)=Controlname$ !:
         let Fieldname$(Control)=Fieldname$ !:
         let Description$(Control)=Description$ !:
         let Vposition(Control)=Vposition !:
         let Hposition(Control)=Hposition !:
         let Fieldtype$(Control)=Fieldtype$ !:
         let Specwidth(Control)=Specwidth !:
         let Width(Control)=Width !:
         let Height(Control)=Height !:
         let Truevalue$(Control)=Truevalue$ !:
         let Falsevalue$(Control)=Falsevalue$ !:
         let Function$(Control)=Function$ !:
         let Picture$(Control)=Picture$
         let Parent$(Control)=Parent$ !:
         let Fgcolor$(Control)=Fgcolor$ !:
         let Bgcolor$(Control)=Bgcolor$ !:
         let Justify$(Control)=Justify$ !:
         let Attr$(Control)=Attr$ !:
         let Protected(Control)=Protected !:
         let Invisible(Control)=Invisible !:
         let Tooltip$(Control)=Tooltip$ !:
         let Cnvrtin$(Control)=Cnvrtin$ !:
         let Cnvrtout$(Control)=Cnvrtout$ !:
         let Multiselect(Control)=Multiselect !:
         let GridLines(Control)=GridLines !:
         let Userdata$(Control)=Userdata$ !:
         let Fnaddcontrolfromclip=1
      else
         print Bell;
      end if
   fnend
!
   def Fngetclip$*255(&Broken,&Clipboard$,Terminator$)
      if Pos(Clipboard$,Terminator$)>0 then
         let Fngetclip$=Trim$(Clipboard$(1:Pos(Clipboard$,Terminator$)-1)) soflow BADCLIPBOARD
         let Clipboard$(1:Pos(Clipboard$,Terminator$)+Len(Terminator$)-1)=""
      else
         let Broken=1
      end if
   fnend
BADCLIPBOARD: let Broken=1 : continue
!
!
DEFINEATTRIBUTESWINDOW: !  Define Window Attributes Input Fields
   def Fndefineattributeswindow(Mat Attributecaptions$, Mat Attributecapspec$,Mat Attributespec$,Mat Attributedata$,mat AttributeTTip$,Mat Attributesubs;___,Index,TTLev)
!
      mat Attributecaptions$(21) : mat Attributecapspec$(21) !:
      mat Attributespec$(21) : mat Attributedata$(21) !:
      mat AttributeTtip$(21) : mat Attributesubs(21)
!
      let Attributecaptions$(1)= "Window Name:" !:
      let Attributecapspec$(1)= "1,1,C 12" !:
      let Attributespec$(1)= "1,16,9/CU 18,S,1101" !:
      let Attributesubs(1)= Si_Screencode !:
      let AttributeTtip$(1)="The name of the screen, required in order to save the screen."
!
      let Attributecaptions$(2)= "Project:" !:
      let Attributecapspec$(2)= "2,1,C 8" !:
      let Attributespec$(2)= "2,9,16/V 255,S,1102" !:
      let Attributesubs(2)= Si_project !:
      let AttributeTtip$(2)="The project this screen is associated with. Optional Notes field."
      !
      let Attributecaptions$(3)= "Notes:" !:
      let Attributecapspec$(3)= "3,1,5/C 6" !:
      let Attributespec$(3)= "3,7,18/V 255,S,1103" !:
      let Attributesubs(3)=Si_Notes !:
      let AttributeTtip$(3)="Notes. Can be anything you want."
!
      let Attributecaptions$(4)= "Caption:" !:
      let Attributecapspec$(4)= "4,1,C 8" !:
      let Attributespec$(4)= "4,9,16/V 60,S,1104" !:
      let Attributesubs(4)= Si_Caption !:
      let AttributeTtip$(4)="Caption to display in the windows taskbar when running screen."
       !
      let Attributecaptions$(5)= "Rows:" !:
      let Attributecapspec$(5)= "5,1,C 5" !:
      let Attributespec$(5)= "5,8,5/CR 3,S,1105" !:
      let Attributesubs(5)=-1*Si_Vsize !:
      let AttributeTtip$(5)="Height of screen in Rows."
!
      let Attributecaptions$(6)= "Cols:" !:
      let Attributecapspec$(6)= "5,14,C 5" !:
      let Attributespec$(6)= "5,20,5/CR 3,S,1106" !:
      let Attributesubs(6)=-1*Si_Hsize !:
      let AttributeTtip$(6)="Width of screen in columns."
!
      let Attributecaptions$(7)= "Attributes:" !:
      let Attributecapspec$(7)= "6,1,C 11" !:
      let Attributespec$(7)= "6,12,13/V 255,S,1107" !:
      let Attributesubs(7)=Si_Attributes !:
      let AttributeTtip$(7)="Attributes to use when opening the window"
!
      let Attributecaptions$(8)= "Border:" !:
      let Attributecapspec$(8)= "7,1,6/C 7" !:
      let Attributespec$(8)= "7,7,CHECK 1,,1108" !:
      let Attributesubs(8)=-1*Si_Border !:
      let AttributeTtip$(8)="Check to add a window border."
!
      let Attributecaptions$(9)= "Cap:" !:
      let Attributecapspec$(9)= "7,9,C 4" !:
      let Attributespec$(9)= "7,13,12/V 80,S,1109" !:
      let Attributesubs(9)=Si_Windcap !:
      let AttributeTtip$(9)="Caption to place on the border, if a border is checked."
!
      let Attributecaptions$(10)= "Picture:" !:
      let Attributecapspec$(10)= "8,1,C 8" !:
      let Attributespec$(10)= "8,9,16/V 60,S,1110" !:
      let Attributesubs(10)=Si_Picture !:
      let AttributeTtip$(10)="Background image for the window."
!
      let Attributecaptions$(11)= "Read Key:" !:
      let Attributecapspec$(11)= "9,1,7/C 9" !:
      let Attributespec$(11)= "9,9,CR 3,S,1111" !:
      let Attributesubs(11)=-1*Si_Readindex !:
      let AttributeTtip$(11)="Here you indicate which key to use when reading the file. The default is 0 (relative) for fast reading of listviews, and 1 for add/edit screens."
!
      let Attributecaptions$(12)= "Return Key:" !:
      let Attributecapspec$(12)= "9,13,8/C 11" !:
      let Attributespec$(12)= "9,22,CR 3,S,1112" !:
      let Attributesubs(12)=-1*Si_Returnindex !:
      let AttributeTtip$(12)="Which key to use when returning the user action to the calling program. Fnfm will return the selected or edited records key (using this number to say which key) as its return value."
!
      let Attributecaptions$(13)= "Input Attr:" !:
      let Attributecapspec$(13)= "10,1,C 11" !:
      let Attributespec$(13)= "10,12,13/V 255,S,1113" !:
      let Attributesubs(13)=Si_Inputattr !:
      let AttributeTtip$(13)="This is the attribute that ScreenIO will use for the active field, the field that the cursor is currently in."
!
      let Attributecaptions$(14)= "Wait Time:" !:
      let Attributecapspec$(14)= "11,1,C 10" !:
      let Attributespec$(14)= "11,20,5/CR 3,S,1114" !:
      let Attributesubs(14)=-1*Si_Waittime !:
      let AttributeTtip$(14)="If you specify a wait time here, screenio will timeout and call your wait function after the specified time of inactivity in your screen."
!
      let Attributecaptions$(15)= "Dont Lock:" !:
      let Attributecapspec$(15)= "12,1,9/C 10" !:
      let Attributespec$(15)= "12,10,CHECK 1,,1115" !:
      let Attributesubs(15)=-1*Si_ScreenIOLocking !:
      let AttributeTtip$(15)="Check this box to force the screen to never lock the records, even on editing. If the user attempts to save data and the record wasn't locked, ScreenIO will attempt to do its own record locking to resolve any conflicts."

      let Attributecaptions$(16)= "Auto Merge:" !:
      let Attributecapspec$(16)= "12,12,10/C 11" !:
      let Attributespec$(16)= "12,22,CHECK 1,,1116" !:
      let Attributesubs(16)=-1*Si_ScreenIOMerge !:
      let AttributeTtip$(16)="Check this box for screenio to automatically attempt to merge data based on timestamp any time record locking is disabled and two users change the same record. If this is unchecked, a guided merge will be performed using ""postit notes""."

      let Attributecaptions$(17)= "Color:. /" !:
      let Attributecapspec$(17)= "13,1,8/C 14" !:
      let Attributespec$(17)= "13,10,C 6,/W:W,B1117" !:
      let Attributesubs(17)=Si_Fgcolor !:
      let AttributeTtip$(17)="Foreground color to use for the screen, and for the default for newly added text controls."
!
      let Attributecaptions$(18)= ":" !:
      let Attributecapspec$(18)= "13,16,CC 2" !:
      let Attributespec$(18)= "13,18,C 6,/W:W,B1118" !:
      let Attributesubs(18)=Si_Bgcolor !:
      let AttributeTtip$(18)="Background color to use for the screen, and for the default for newly added textbox controls."
!
      let Attributecaptions$(19)= "File Layout:" !:
      let Attributecapspec$(19)= "14,1,11/C 12" !:
      let Attributespec$(19)= "14,12,12/CC 18,/W:W,B1119" !:
      let Attributesubs(19)=Si_Filelay !:
      let AttributeTtip$(19)="Select the file layout, to tie your screen directly to a data file."
!
      let Attributecaptions$(20)= "" !:
      let Attributecapspec$(20)= "15,1,C 1" !:
      let Attributespec$(20)= "15,2,10/CC 17,/W:W,B1120" !:
      let Attributedata$(20)= "Set Screen Events" !:
      let Attributesubs(20)= 0 !:
      let AttributeTtip$(20)="Set the window level event functions here."
!
      let Attributecaptions$(21)= "" !:
      let Attributecapspec$(21)= "15,2,C 1" !:
      let Attributespec$(21)= "15,14,10/CC 15,/W:W,B1121" !:
      let Attributedata$(21)= "Set Tab Order" !:
      let Attributesubs(21)= 0 !:
      let AttributeTtip$(21)="Use this button to change the tab order."

      let fnFixTooltips(mat AttributeTTip$)
   fnend
!
! =============================
! =    End Function Blocks    =
! =============================
!
DISPLAYWINDOWSMENU: !  Display The Windows Menu
   def Fndisplaywindowsmenu(;___,Index)
      dim M$(1)*30, Pgm$(1), Status$(1)
      let Fndefinewindowsmenu(Mat M$,Mat Pgm$, Mat Status$)
!
      display Menu: Mat M$, Mat Pgm$, Mat Status$
   fnend
!
CLEARWINDOWSMENU: ! Display The Windows Menu
   def Fnclearwindowsmenu
      dim Mclear$(1), Pgmclear$(1), Statusclear$(1)
!
      mat Mclear$(0) : mat Pgmclear$(0) : mat Statusclear$(0)
!
      display Menu: Mat Mclear$, Mat Pgmclear$, Mat Statusclear$
   fnend
!
SHOWABOUT: !   *****  This Shows  The About Page
   def Fnshowabout(;___,About, Cover, X$, function )
      open #(About:=Fngetfilenumber) : "srow=5,scol=20,rows=23,cols=60,Border=S", display,outin
      print #About, fields "2,8,P 7/18,,35" : setting_ImagePath$&"\sageax.png:ISOTROPIC"
      print #About, fields "2,30,CC 30" : "Screen IO Library - Designer"
      print #About, fields "4,30,CC 30" : "Copyright 2008 Gabriel Bakker"
      print #About, fields "6,30,CC 30" : "Sage AX"
      print #About, fields "7,30,CC 30,U/#0000FF:W,35" : "http://www.sageax.com"
      print #About, fields "10,2,CC 58" : "This library was designed as an addon for FileIO"
      print #About, fields "11,2,CC 58" : "to be an all in one program generation system."
      print #About, fields "13,2,CC 58" : "Special thanks to Chris Shields for helping to salvage"
      print #About, fields "14,2,CC 58" : "the source code after a disasterous theft."
      print #About, fields "16,2,CC 58" : "Special thanks to Susan Smith for support, testing,"
      print #About, fields "17,2,CC 58" : "ideas and extensive encouragement during development."
      print #About, fields "19,2,CC 58" : "Special thanks to Mikhail Zheleznov for encouragement,"
      print #About, fields "20,2,CC 58" : "enthusiasm, many new ideas, and hours of testing."
      print #About, fields "22,15,CC 10,/W:W,B37;22,35,CC 10,/W:W,B38" : "OK","Thank You"
      print #About, fields "23,40,CR 20" : "Version "&str$(fnVersion)
      open #(Cover:=Fngetfilenumber) : "srow=12,scol=2,rows=1,cols=3,parent="&Str$(About),display, outin
      do
         let x$=""
         rinput #About, fields "12,3,CU 1,AEX" : X$
         let Function=fkey
         #Select# Function #Case# 35
            execute "system -c -M start http://www.sageax.com"
         #Case# 38 or X$="S"
            let fnSupporters
         #End Select#
      loop Until Function=37 Or Function=99 Or Function=0 or fkey=93 or function=93 ! Esc,  Enter,  Or Ok Button or exit button
      close #Cover:
      close #About:
   fnend
!
dim SupporterSpec$(8)*32, SupporterOut$(8)*64, SupporterName$(36)*64
!
Supporters: !   *****  This Shows  The About Page
   def FnSupporters(;___,About,X$,function,I,SmoothScroll,Counter,NameIndex,DisplayFrom,SuppressNames,Index,Looping)
      let SupporterName$(1)="Susan Smith" !:
      let SupporterName$(2)="SMS Software" !:
      let SupporterName$(3)="" !:
      let SupporterName$(4)="Bart Fusco" !:
      let SupporterName$(5)="Foxtree IPM" !:
      let SupporterName$(6)="" !:
      let SupporterName$(7)="Percy J Comeaux" !:
      let SupporterName$(8)="Erisa" !:
      let SupporterName$(9)="" !:
      let SupporterName$(10)="George Tisdale" !:
      let SupporterName$(11)="Tisdale Certified Public Accountants" !:
      let SupporterName$(12)="" !:
      let SupporterName$(13)="Luis Gomez and John Curry" !:
      let SupporterName$(14)="Commercial Legal Software" !:
      let SupporterName$(15)="" !:
      let SupporterName$(16)="Pete Klug"
      let SupporterName$(17)="Commercial Testing Laboratory" !:
      let SupporterName$(18)="" !:
      let SupporterName$(19)="Richard Forrester" !:
      let SupporterName$(20)="Sys-Corp Services" !:
      let SupporterName$(21)="" !:
      let SupporterName$(22)="Mike Storlazzi" !:
      let SupporterName$(23)="Payrolls Unlimited" !:
      let SupporterName$(24)="" !:
      let SupporterName$(25)="Doug Meenen and Stephen Koger" !:
      let SupporterName$(26)="Management Advisory Computer Systems" !:
      let SupporterName$(27)="" !:
      let SupporterName$(28)="and of course" !:
      let SupporterName$(29)="Gordon Dye and Gary Hoff for their" !:
      let SupporterName$(30)="" !:
      let SupporterName$(31)="hard work and dedication to the Business Rules language," !:
      let SupporterName$(32)="which has kept us all in business doing what we love."
      let SupporterName$(33)="" !:
      let SupporterName$(34)="Without Business Rules, there would be no ScreenIO." !:
      let SupporterName$(35)=" " !:
      let SupporterName$(36)=""


      let SmoothScroll=fn43
      execute "CONFIG ATTRIBUTE [SUPPORTERS] ,font=Arial:Large:Slant"
      open #(About:=Fngetfilenumber) : "srow=9,scol=26,rows=21,cols=60,FONT.LABELS=Comic Sans MS:bold:slant,Border=S", display,outin
      print #About, fields "1,2,CC 58,[SUPPORTERS]" : "Special Thanks to all the early adopters of ScreenIO"
      print #About, fields "21,2,CC 58,[SUPPORTERS]" : "Without you, this would never have been possible."

      let DisplayFrom=1
      ! let SuppressNames=1

      do
         if Counter=0 then
            let Counter=20
            let NameIndex+=1
            if NameIndex=37 then
               ! End of the list. Pause, then restart.
               let fnPause(2,x$,function)
               let NameIndex=1
               let DisplayFrom=1
               let Increment=0
               let SuppressNames=7
            end if
            if SuppressNames then let SuppressNames-=1
         end if
         if SmoothScroll then let Counter-=1 else let Counter-=10

         if Counter=0 then
            if DisplayFrom<=udim(SupporterOut$) and SupporterOut$(DisplayFrom)><"" then
                if mod(displayfrom,2)=1 then  ! Scrunch up together at the top
                   let Increment-=1
                   let Counter+=10
                end if
                let DisplayFrom+=1
            end if
         end if

         if DisplayFrom>8 then
            let DisplayFrom=1
            let Increment=0
            ! End of page. Pause, set SuppressNames to clear, and cont.
            let fnPause(2,x$,function)
            let SuppressNames=udim(mat SupporterOut$)
         end if

         ! Calculate the specs
         for I=4 to 18 step 2
            let SupporterSpec$((I/2)-1)=str$(I+Increment+(Counter/10))&",1,CC 60"
         next I

         ! Calculate the names
         mat SupporterOut$=("")
         if NameIndex<=8 then
            mat SupporterOut$(8-NameIndex+1:8)=SupporterName$(1:NameIndex)
         else
            mat SupporterOut$(1:8)=SupporterName$(NameIndex-8+1:NameIndex)
         end if

         ! Apply SuppresssNames to clear screen of prev. page
         for Index=1 to udim(mat SupporterOut$)
            if Index<=SuppressNames then
               let SupporterOut$(Index)=""
            end if
         next Index

         ! Print
         ! print #About, fields "1,1,N 3;2,1,N 3" : DisplayFrom,Increment   ! Debug output
         print #About, fields mat SupporterSpec$(DisplayFrom:udim(mat SupporterOut$)) : mat SupporterOut$(DisplayFrom:udim(mat SupporterOut$))

         ! Pause
         if function><99 and unhex$(x$)><"6300" and x$><" " then
            if SmoothScroll then
               let fnPause(.05,x$,function)
            else
               let fnPause(.5,x$,function)
            end if
         end if

         ! Erase
         if ~SmoothScroll then
            mat SupporterOut$=("")
            print #About, fields mat SupporterSpec$(DisplayFrom:udim(mat SupporterOut$)) : mat SupporterOut$(DisplayFrom:udim(mat SupporterOut$))
         end if

         ! Loop
      loop Until Function=99 or function=93 or Unhex$(x$)="6300" or x$=" " ! Press Esc or space bar
      close #About:
   fnend

   def fnPause(Howlong;&thekey$,&function,___,looping)
      do
         let Sleep(.05)
         let x$=kstat$
         let function=fkey
         let looping+=.05
      loop until looping>=HowLong or Function=99 or unhex$(x$)="6300"
   fnend
!
OKTOPROCEED: !   ***** Ask The User If They Are Sure  They Want  To Proceed
   def Fnoktoproceed(Mat Screenio$,Mat Screenio,[[Screencontrols]];___,Choice,Yes,No,Cancel)
      if (~Fncheckscreenarrays(Mat Screenio$,Mat Screenio,[[Screencontrols]])) then
         let Yes=2 : let No=3 : let Cancel=4 ! Msgbox Return Constants
         let Choice=Msgbox("Warning: If you proceed you will overwrite all changes. Would you like to save your changes first?","Save Changes?","Ync","QST")
         #Select# Choice #Case# Yes
            if Fnwritescreen(Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
               let Fnoktoproceed=1
            else
               let Fnoktoproceed=0
            end if
         #Case# No
            let Fnoktoproceed=1
         #Case# Cancel
            let Fnoktoproceed=0
         #Case Else#
            let Fnoktoproceed=0
         #End Select#
      else
         let Fnoktoproceed=1
      end if
   fnend
!
   dim P_Screenio$(1)*255,P_Screenio(1), P_Controlname$(1)*50, P_Fieldname$(1)*50, P_Description$(1)*255, P_Vposition(1), P_Hposition(1), P_Fieldtype$(1)*8, P_Specwidth(1), P_Width(1), P_Height(1), P_Truevalue$(1)*60, P_Falsevalue$(1)*60, P_Function$(1)*255, P_Picture$(1)*255, P_Parent$(1)*20, P_Fgcolor$(1)*6, P_Bgcolor$(1)*6, P_Justify$(1)*1, P_Attr$(1)*128, P_Multiselect(1),P_GridLines(1), P_Protected(1), P_Invisible(1), P_Tooltip$(1)*1000,P_Cnvrtin$(1)*255,P_Cnvrtout$(1)*255, P_Userdata$(1)*255
!
PRESERVESCREENARRAYS: !  Preserves The State Of The Screen Arrays
   def Fnpreservescreenarrays(Mat Screenio$,Mat Screenio,[[Screencontrols]])
!
      mat P_Screenio$(Udim(Mat Screenio$)) = Screenio$ !:
      mat P_Screenio(Udim(Mat Screenio)) = Screenio !:
      mat P_Controlname$(Udim(Mat Controlname$)) = Controlname$ !:
      mat P_Fieldname$(Udim(Mat Fieldname$)) = Fieldname$ !:
      mat P_Description$(Udim(Mat Description$)) = Description$ !:
      mat P_Vposition(Udim(Mat Vposition)) = Vposition !:
      mat P_Hposition(Udim(Mat Hposition)) = Hposition !:
      mat P_Fieldtype$(Udim(Mat Fieldtype$)) = Fieldtype$ !:
      mat P_Specwidth(Udim(Mat Specwidth)) = Specwidth !:
      mat P_Width(Udim(Mat Width)) = Width !:
      mat P_Height(Udim(Mat Height)) = Height
      mat P_Truevalue$(Udim(Mat Truevalue$)) = Truevalue$ !:
      mat P_Falsevalue$(Udim(Mat Falsevalue$)) = Falsevalue$ !:
      mat P_Function$(Udim(Mat Function$)) = Function$ !:
      mat P_Picture$(Udim(Mat Picture$)) = Picture$ !:
      mat P_Parent$(Udim(Mat Parent$)) = Parent$ !:
      mat P_Fgcolor$(Udim(Mat Fgcolor$)) = Fgcolor$ !:
      mat P_Bgcolor$(Udim(Mat Bgcolor$)) = Bgcolor$ !:
      mat P_Justify$(Udim(Mat Justify$)) = Justify$ !:
      mat P_Attr$(Udim(Mat Attr$)) = Attr$ !:
      mat P_Protected(Udim(Mat Protected)) = Protected !:
      mat P_Invisible(Udim(Mat Invisible)) = Invisible
      mat P_Tooltip$(Udim(Mat Tooltip$)) = Tooltip$ !:
      mat P_Cnvrtin$(Udim(Mat Cnvrtin$)) = Cnvrtin$ !:
      mat P_Cnvrtout$(Udim(Mat Cnvrtout$)) = Cnvrtout$ !:
      mat P_Multiselect(Udim(Mat Multiselect)) = Multiselect !:
      mat P_GridLines(Udim(Mat GridLines)) = GridLines !:
      mat P_Userdata$(Udim(Mat Userdata$)) = Userdata$
   fnend
!
CHECKSCREENARRAYS: !  Check The State Of The Screen Arrays
   def Fncheckscreenarrays(Mat Screenio$,Mat Screenio,[[Screencontrols]];___,Failed)
!
      let Failed=Failed Or (~Fnsameas(Mat Screenio$,Mat P_Screenio$))
      let Failed=Failed Or (~Fnsamea(Mat Screenio,Mat P_Screenio))
      let Failed=Failed Or (~Fnsameas(Mat Controlname$,Mat P_Controlname$))
      let Failed=Failed Or (~Fnsameas(Mat Fieldname$,Mat P_Fieldname$))
      let Failed=Failed Or (~Fnsameas(Mat Description$,Mat P_Description$))
      let Failed=Failed Or (~Fnsamea(Mat Vposition,Mat P_Vposition))
      let Failed=Failed Or (~Fnsamea(Mat Hposition,Mat P_Hposition))
      let Failed=Failed Or (~Fnsameas(Mat Fieldtype$,Mat P_Fieldtype$))
      let Failed=Failed Or (~Fnsamea(Mat Specwidth,Mat P_Specwidth))
      let Failed=Failed Or (~Fnsamea(Mat Width,Mat P_Width))
      let Failed=Failed Or (~Fnsamea(Mat Height,Mat P_Height))
      let Failed=Failed Or (~Fnsameas(Mat Truevalue$,Mat P_Truevalue$))
      let Failed=Failed Or (~Fnsameas(Mat Falsevalue$,Mat P_Falsevalue$))
      let Failed=Failed Or (~Fnsameas(Mat Function$,Mat P_Function$))
      let Failed=Failed Or (~Fnsameas(Mat Picture$,Mat P_Picture$))
      let Failed=Failed Or (~Fnsameas(Mat Parent$,Mat P_Parent$))
      let Failed=Failed Or (~Fnsameas(Mat Fgcolor$,Mat P_Fgcolor$))
      let Failed=Failed Or (~Fnsameas(Mat Bgcolor$,Mat P_Bgcolor$))
      let Failed=Failed Or (~Fnsameas(Mat Justify$,Mat P_Justify$))
      let Failed=Failed Or (~Fnsameas(Mat Attr$,Mat P_Attr$))
      let Failed=Failed Or (~Fnsamea(Mat Protected,Mat P_Protected))
      let Failed=Failed Or (~Fnsamea(Mat Protected,Mat P_Protected))
      let Failed=Failed Or (~Fnsameas(Mat Tooltip$,Mat P_Tooltip$))
      let Failed=Failed Or (~Fnsameas(Mat Cnvrtin$,Mat P_Cnvrtin$))
      let Failed=Failed Or (~Fnsameas(Mat Cnvrtout$,Mat P_Cnvrtout$))
      let Failed=Failed Or (~Fnsamea(Mat Multiselect,Mat P_Multiselect))
      let Failed=Failed Or (~Fnsamea(Mat GridLines,Mat P_GridLines))
      let Failed=Failed Or (~Fnsameas(Mat Userdata$,Mat P_Userdata$))
      let Fncheckscreenarrays=(~Failed)
   fnend
!
! .! Change the width without marking the screen data as changed.
   def Fnchangespecwidth(Index,Width)
      let Specwidth(Index)=Width
      if Udim(Mat Specwidth)=Udim(Mat P_Specwidth) then
         let P_Specwidth(Index)=Width
      end if
! .   ! if the sizes dont match then we're changed anyway.
      if Udim(Mat Specwidth)=Udim(Mat Undo_Specwidth) then
         let Undo_Specwidth(Index)=Width
      end if
   fnend
!
   dim Undo_Screenio$(1)*255,Undo_Screenio(1)
   dim Undo_Controlname$(1)*50, Undo_Fieldname$(1)*50, Undo_Description$(1)*255
   dim Undo_Vposition(1), Undo_Hposition(1), Undo_Fieldtype$(1)*8, Undo_Specwidth(1), Undo_Width(1), Undo_Height(1)
   dim Undo_Truevalue$(1)*60, Undo_Falsevalue$(1)*60
   dim Undo_Function$(1)*255, Undo_Picture$(1)*255, Undo_Parent$(1)*20
   dim Undo_Fgcolor$(1)*6, Undo_Bgcolor$(1)*6, Undo_Justify$(1)*1, Undo_Attr$(1)*128, Undo_Multiselect(1), Undo_GridLines(1)
   dim Undo_Protected(1), Undo_Invisible(1), Undo_Tooltip$(1)*1000,Undo_Cnvrtin$(1)*255,Undo_Cnvrtout$(1)*255, Undo_Userdata$(1)*255
!
   def Fnpreserveundo(Mat Screenio$,Mat Screenio,[[Screencontrols]])
      mat Undo_Screenio$(Udim(Mat Screenio$)) = Screenio$
      mat Undo_Screenio(Udim(Mat Screenio)) = Screenio
      mat Undo_Controlname$(Udim(Mat Controlname$)) = Controlname$
      mat Undo_Fieldname$(Udim(Mat Fieldname$)) = Fieldname$
      mat Undo_Description$(Udim(Mat Description$)) = Description$
      mat Undo_Vposition(Udim(Mat Vposition)) = Vposition
      mat Undo_Hposition(Udim(Mat Hposition)) = Hposition
      mat Undo_Fieldtype$(Udim(Mat Fieldtype$)) = Fieldtype$
      mat Undo_Specwidth(Udim(Mat Specwidth)) = Specwidth
      mat Undo_Width(Udim(Mat Width)) = Width
      mat Undo_Height(Udim(Mat Height)) = Height
      mat Undo_Truevalue$(Udim(Mat Truevalue$)) = Truevalue$
      mat Undo_Falsevalue$(Udim(Mat Falsevalue$)) = Falsevalue$
      mat Undo_Function$(Udim(Mat Function$)) = Function$
      mat Undo_Picture$(Udim(Mat Picture$)) = Picture$
      mat Undo_Parent$(Udim(Mat Parent$)) = Parent$
      mat Undo_Fgcolor$(Udim(Mat Fgcolor$)) = Fgcolor$
      mat Undo_Bgcolor$(Udim(Mat Bgcolor$)) = Bgcolor$
      mat Undo_Justify$(Udim(Mat Justify$)) = Justify$
      mat Undo_Attr$(Udim(Mat Attr$)) = Attr$
      mat Undo_Protected(Udim(Mat Protected)) = Protected
      mat Undo_Invisible(Udim(Mat Invisible)) = Invisible
      mat Undo_Tooltip$(Udim(Mat Tooltip$)) = Tooltip$
      mat Undo_Cnvrtin$(Udim(Mat Cnvrtin$)) = Cnvrtin$
      mat Undo_Cnvrtout$(Udim(Mat Cnvrtout$)) = Cnvrtout$
      mat Undo_Multiselect(Udim(Mat Multiselect)) = Multiselect
      mat Undo_GridLines(Udim(Mat GridLines)) = GridLines
      mat Undo_Userdata$(Udim(Mat Userdata$)) = Userdata$
   fnend
!
   def Fncheckundo(Mat Screenio$,Mat Screenio,[[Screencontrols]];___,Failed)
      let Failed=Failed Or (~Fnsameas(Mat Screenio$,Mat Undo_Screenio$))
      let Failed=Failed Or (~Fnsamea(Mat Screenio,Mat Undo_Screenio))
      let Failed=Failed Or (~Fnsameas(Mat Controlname$,Mat Undo_Controlname$))
      let Failed=Failed Or (~Fnsameas(Mat Fieldname$,Mat Undo_Fieldname$))
      let Failed=Failed Or (~Fnsameas(Mat Description$,Mat Undo_Description$))
      let Failed=Failed Or (~Fnsamea(Mat Vposition,Mat Undo_Vposition))
      let Failed=Failed Or (~Fnsamea(Mat Hposition,Mat Undo_Hposition))
      let Failed=Failed Or (~Fnsameas(Mat Fieldtype$,Mat Undo_Fieldtype$))
      let Failed=Failed Or (~Fnsamea(Mat Specwidth,Mat Undo_Specwidth))
      let Failed=Failed Or (~Fnsamea(Mat Width,Mat Undo_Width))
      let Failed=Failed Or (~Fnsamea(Mat Height,Mat Undo_Height))
      let Failed=Failed Or (~Fnsameas(Mat Truevalue$,Mat Undo_Truevalue$))
      let Failed=Failed Or (~Fnsameas(Mat Falsevalue$,Mat Undo_Falsevalue$))
      let Failed=Failed Or (~Fnsameas(Mat Function$,Mat Undo_Function$))
      let Failed=Failed Or (~Fnsameas(Mat Picture$,Mat Undo_Picture$))
      let Failed=Failed Or (~Fnsameas(Mat Parent$,Mat Undo_Parent$))
      let Failed=Failed Or (~Fnsameas(Mat Fgcolor$,Mat Undo_Fgcolor$))
      let Failed=Failed Or (~Fnsameas(Mat Bgcolor$,Mat Undo_Bgcolor$))
      let Failed=Failed Or (~Fnsameas(Mat Justify$,Mat Undo_Justify$))
      let Failed=Failed Or (~Fnsameas(Mat Attr$,Mat Undo_Attr$))
      let Failed=Failed Or (~Fnsamea(Mat Protected,Mat Undo_Protected))
      let Failed=Failed Or (~Fnsamea(Mat Protected,Mat Undo_Protected))
      let Failed=Failed Or (~Fnsameas(Mat Tooltip$,Mat Undo_Tooltip$))
      let Failed=Failed Or (~Fnsameas(Mat Cnvrtin$,Mat Undo_Cnvrtin$))
      let Failed=Failed Or (~Fnsameas(Mat Cnvrtout$,Mat Undo_Cnvrtout$))
      let Failed=Failed Or (~Fnsamea(Mat Multiselect,Mat Undo_Multiselect))
      let Failed=Failed Or (~Fnsamea(Mat GridLines,Mat Undo_GridLines))
      let Failed=Failed Or (~Fnsameas(Mat Userdata$,Mat Undo_Userdata$))
      let Fncheckundo=(~Failed)
   fnend

   ! This function checks the Created By and Modified By lists to determine if this ScreenIO operation
   !  is worked on by more then one programmer or by just one.
   def fnMultiProgrammers(mat CList$,mat MList$;___,Index,Multiprogrammers,Programmer$*30)
      for Index=1 to udim(mat CList$)
         if trim$(CList$(Index))><"" then
            if trim$(programmer$)="" then let Programmer$=CList$(Index)
            if trim$(lwrc$(Programmer$))><trim$(lwrc$(CList$(Index))) then
               let MultiProgrammers=1
               let Index=udim(mat CList$)+1 ! Exit the for loop
            end if
         end if
      next Index
      if ~Multiprogrammers then
         for Index=1 to udim(mat MList$)
            if trim$(MList$(Index))><"" then
               if trim$(programmer$)="" then let Programmer$=MList$(Index)
               if trim$(lwrc$(Programmer$))><trim$(lwrc$(MList$(Index))) then
                  let MultiProgrammers=1
                  let Index=udim(mat MList$)+1 ! Exit the for loop
               end if
            end if
         next Index
      end if
      let fnMultiprogrammers=Multiprogrammers
   fnend
!
!
!  #Autonumber# 60000,2
SELECTSCREEN: !  Print Screen Selection Window
   def Fnselectscreen$*64(;SelectOtherFiles,___,Window,Selectedscreen$*64,Choice,Rowsub,S$*255,TempScreen$*255,HelpText$*255,HL$,FilterBox$*64,ShowUserNames)
      dim Ss_Caption$(6),Ss_Width(6),Ss_Spec$(6)
      dim Ss_Screencodes$(1),Ss_Createdates(1),Ss_Modifydates(1),SS_Version(1),SS_CreateUser$(1)*30,SS_ModifyUser$(1)*30,SS_Project$(1)*255,SS_Notes$(1)*255

      do
         let Fnreadallscreencodes(Mat Ss_Screencodes$,Mat Ss_Createdates,Mat Ss_Modifydates,mat SS_Version,mat SS_CreateUser$,mat SS_ModifyUser$,mat SS_Project$,mat SS_Notes$)
         if Udim(Mat Ss_Screencodes$) then
            execute "config keyboard 04 1000" ! Remap Del As Shift F6 (Fkey 16)
            execute "config keyboard 0B00 0A0A0A636F6E206B657920636C6561720D" ! Shift F1 Key To "con key clear<CR>"

            let Ss_Caption$(1)="Screen Code"
            let Ss_Width(1)=16
            let Ss_Spec$(1)="C 18"
            ! let Ss_Spec$(1)="C 18,L"

            let Ss_Caption$(2)="Project"
            let Ss_Width(2)=8
            let Ss_Spec$(2)="V 255"

            let Ss_Caption$(3)="Modified"
            let Ss_Caption$(4)="Created"
            mat Ss_Width(3:4)=(9)
            mat Ss_Spec$(3:4)=("DATE(m/dd/ccyy)")
!            mat Ss_Spec$(2:3)=("DATE(m/dd/ccyy),L")
!
            let SS_Caption$(5)="Version"
            let SS_Width(5)=5
            let SS_Spec$(5)="N 7"

            let SS_Caption$(6)="Notes"
            let SS_Width(6)=16
            let SS_Spec$(6)="V 255"


            if fnMultiProgrammers(mat SS_CreateUser$,mat SS_ModifyUSer$) then
               ! Show the User Name columns only for screenio operations worked on by more then 1 programmer.
               !  They just needlessly crowd up the interface on single user systems.
               mat SS_Caption$(8)
               mat SS_Width(8)
               mat SS_Spec$(8)

               ! Move Notes to the End
               let SS_Caption$(8)=SS_Caption$(6)
               let SS_Width(8)=SS_Width(6)
               let SS_Spec$(8)=SS_Spec$(6)

               ! Move Vers to the End
               let SS_Caption$(7)=SS_Caption$(5)
               let SS_Width(7)=SS_Width(5)
               let SS_Spec$(7)=SS_Spec$(5)

               ! Move "Created Date" over a spot
               let SS_Caption$(5)=SS_Caption$(4)
               let SS_Width(5)=SS_Width(4)
               let SS_Spec$(5)=SS_Spec$(4)


               let SS_Caption$(4)="By"
               let SS_Width(4)=5
               let SS_Spec$(4)="V 30"

               let SS_Caption$(6)="By"
               let SS_Width(6)=5
               let SS_Spec$(6)="V 30"

               let ShowUserNames=1
            end if

            if fn42 then let HL$="4;" else let HL$="3;"

            if Udim(Mat Ss_Screencodes$)>23 then let Ss_Width(1)-=1
            let HelpText$=HL$&"Accept the selection;"&HL$&"Cancel without selecting anything.;"

            open #(Window:=Fngetfilenumber): "SROW=3,SCOL=15,ROWS=25,COLS=75,Border=S,Caption=Load File",display,outin

            print #Window, fields "25,54,CC 9,/W:W,B37;25,65,CC 10,/W:W,B99", help HelpText$ : "Ok","Cancel"
            let HelpText$=HL$&"Launch this screen in a new editor window;"
            print #Window, fields "25,2,13/CC 15,/W:W,B42", help HelpText$ : "Launch Screen"
            if SelectOtherFiles then
               let HelpText$=HL$&"Select a program or proc file to run instead of running a screen directly.;"
               print #Window, fields "25,17,10/CC 12,/W:W,B43", help HelpText$ : "Select Pgm"
            end if
            print #Window, fields "1,1,LIST 23/75,HEADERS,/W:W" : (Mat Ss_Caption$, Mat Ss_Width, Mat Ss_Spec$)

            if ShowUserNames then
               print #Window, fields "1,1,LIST 23/75,=" : (Mat Ss_Screencodes$,mat SS_Project$,Mat Ss_Modifydates,mat SS_ModifyUser$,Mat Ss_Createdates,mat SS_CreateUser$,Mat SS_Version,mat SS_Notes$)
            else
               print #Window, fields "1,1,LIST 23/75,=" : (Mat Ss_Screencodes$,mat SS_Project$,Mat Ss_Modifydates,Mat Ss_Createdates,Mat SS_Version,mat SS_Notes$)
            end if

            print #Window, fields "1,1,LIST 23/75,SORT" : 1
!
            if fn43 and setting_Load_Filter then
               let FilterBox$="24,1,FILTER 75,/W:W,1,1,FULLROW,ALL"
            else
               let FilterBox$="24,1,SEARCH 75,/W:W,1,1"
            end if

            do
!               do
                  input #Window, fields FilterBox$&";1,1,LIST 23/75,ROWSUB,SELONE,37" : S$,Rowsub error ignore
!               loop while fkey=105 or fkey=106
               if RowSub then let Selectedscreen$=Ss_Screencodes$(Rowsub)
               if Fkey=16 And Trim$(Selectedscreen$)<>"" then
                  let Choice=Msgbox("Are you sure you want to completly delete "&Trim$(Selectedscreen$)&" ?","Delete","yN","QST")
                  if Choice=2 then ! 2 Is Yes
                     let Fndeletescreen(Trim$(Selectedscreen$))
                  end if
               end if
               if Fkey=42 And Trim$(Selectedscreen$)<>"" then
                  let FnLaunchScreen(Trim$(Selectedscreen$))
               end if
               if fkey=43 then
                  let TempScreen$=fnSelectFile$
                  if TempScreen$><"" then
                     let SelectedScreen$="%"&trim$(TempScreen$)(1:63)
                  else
                     let fkey(-1)
                  end if
               end if
            loop Until Fkey=99 Or Fkey=93 or Fkey=37 Or fkey=43 or Fkey=0 Or Fkey=201 Or (Fkey=16 And Choice=2)
            if Fkey=37 Or Fkey=0 Or Fkey=201 or fkey=43 then
               let Fnselectscreen$=Selectedscreen$
            end if
            close #Window:
            execute "config keyboard clear" ! Reset Keyboard After Routine Exits
         else
            let Msgbox("There are no saved screens to load.","Load","ok","INF")
         end if
      loop Until Fkey=99 or Fkey=93 Or Fkey=37 Or fkey=43 or Fkey=201 Or Fkey=0 Or Udim(Mat Ss_Screencodes$)=0
   fnend

   def fnSelectFile$*64(;___,SelectFile)
      open #(SelectFile:=Fngetfilenumber): "name=open:\*.*, recl=1023",external,input error Ignore
      if File(SelectFile)>-1 then
         let fnSelectFile$=file$(SelectFile)(1:64)
         close #SelectFile:
      end if
   fnend
!
SELECTLAYOUT: !  Print Screen Selection Window
   def Fnselectlayout$(Current$;&Function,___,Window,Selectedlayout$,X$,FilterBox$*64)

      dim Sl_Caption$(1),Sl_Width(1),Sl_Spec$(1)
      dim Sl_Layouts$(1)
      let Fnreadlayouts(Mat Sl_Layouts$)
      if Udim(Mat Sl_Layouts$) then
         if fn43 and setting_Load_Filter then
            let FilterBox$="23,1,30/FILTER 18,/W:W,1,1,FULLROW,ALL"
         else
            let FilterBox$="23,1,30/SEARCH 18,/W:W,1,1"
         end if

         open #(Window:=Fngetfilenumber): "SROW=4,SCOL=35,ROWS=24,COLS=30,Border=S,Caption=Select Layout",display,outin
         let Sl_Caption$(1)="File Layout"
         let Sl_Width(1)=30
         let Sl_Spec$(1)="CC 18"
         if Udim(Mat Sl_Layouts$)>23 then let Ss_Width(1)-=1
         print #Window, fields "24,2,CC 8,/W:W,B37;24,11,CC 8,/W:W,B40;24,20,CC 8,/W:W,B99" : "Ok","Clear","Cancel"
         print #Window, fields "1,1,LIST 22/30,HEADERS,/W:W" : (Mat Sl_Caption$, Mat Sl_Width, Mat Sl_Spec$)
         print #Window, fields "1,1,LIST 22/30,=" : (Mat Sl_Layouts$)
         print #Window, fields "1,1,LIST 22/30,SORT" : 1
         do
            input #Window, fields FilterBox$&";1,1,LIST 22/30,ROW,SELONE,37" : X$, Selectedlayout$
         loop Until Fkey=99 Or Fkey=37 Or Fkey=0 Or Fkey=201 Or Fkey=40 Or ((Fkey>1100) And (Fkey<1699)) Or (Fkey=98) Or (Fkey=93) Or (Fkey=44) Or (Fkey=19)
         #Select# Fkey #Case# 37 # 0 # 201
            let Fnselectlayout$=Selectedlayout$
         #Case# 40
            let Fnselectlayout$=""
         #Case Else#
            let Fnselectlayout$=Current$
         #End Select#
         close #Window:
         if ((Fkey>1100) And (Fkey<1699)) Or (Fkey=98) Or (Fkey=93) Or (Fkey=44) Or (Fkey=19) then
            let Function=Fkey
         end if
      else
         let Msgbox("There are no file layouts found.","Select","ok","INF")
      end if
!
   fnend
!
   dim Se_Capspec$(1)*40
   dim Se_Descr$(1)*40
   dim Se_Butspec$(1)*40
   dim Se_Buttext$(1)
   dim Se_Inspec$(1)*30
   dim Se_InTTip$(1)*255
!
!
   dim Se_Ssubs$(1)*25
   dim Se_Nsubs$(1)*25
   dim Se_Sspec$(1)*20
   dim Se_Nspec$(1)*20
   dim Se_Sdescr$(1)*40
   dim Se_Ndescr$(1)*40
   dim Se_Prefix$
!
SELECTEVENTS: ! Opens A Child Window To Select Event Handler Functions
   def Fnselectevents(Mat Screenio$, Mat Screenio;&Function,___,Window,Eventsub)
!
      if (Udim(Mat Se_Capspec$)<>(1+Si_Exitfn-Si_Enterfn)) then
! .      ! Initialize Events Window
         let Fnreadlayoutarrays("screenio",Se_Prefix$,Mat Se_Ssubs$,Mat Se_Nsubs$,Mat Se_Sspec$,Mat Se_Nspec$,Mat Se_Sdescr$,Mat Se_Ndescr$)
         mat Se_Capspec$(1+Si_Exitfn-Si_Enterfn)
         mat Se_Descr$(1+Si_Exitfn-Si_Enterfn)
         mat Se_Butspec$(1+Si_Exitfn-Si_Enterfn)
         mat Se_Buttext$(1+Si_Exitfn-Si_Enterfn)
         mat Se_Inspec$(1+Si_Exitfn-Si_Enterfn)
         mat Se_InTTip$(1+Si_Exitfn-si_Enterfn)
!
         for Eventsub=Si_Enterfn to Si_Exitfn
            let Se_Capspec$(1+Eventsub-Si_Enterfn)=Str$(1+Eventsub-Si_Enterfn)&",1,20/CR 25"
            let Se_Descr$(1+Eventsub-Si_Enterfn)=Se_Sdescr$(Eventsub)(1:24)&":"
            let Se_Butspec$(1+Eventsub-Si_Enterfn)=Str$(1+Eventsub-Si_Enterfn)&",56,CC 4,/W:W,B"&Str$(31+Eventsub-Si_Enterfn)
            let Se_Buttext$(1+Eventsub-Si_Enterfn)="Edit"
            let Se_Inspec$(1+Eventsub-Si_Enterfn)=Str$(1+Eventsub-Si_Enterfn)&",22,32/V 255,/W:#FFFF77"
            let Se_InTTip$(1+EventSub-Si_EnterFn)=trim$(Se_Sdescr$(Eventsub))&" event function. The Screen Level Event functions run when various Screen Level Events are triggered. See the documentation at http://www.brwiki.com keyword ""ScreenIO"" for more details."
         next Eventsub
      end if

      let fnFixTooltips(mat Se_InTTip$)
!
      open #(Window:=Fngetfilenumber): "SROW=10,SCOL=26,ROWS="&Str$(1+Si_Exitfn-Si_Enterfn)&",COLS=60,Border=S,Caption=Configure Event Handlers",display,outin
      print #Window, fields Mat Se_Capspec$ : Mat Se_Descr$
      print #Window, fields Mat Se_Butspec$ : Mat Se_Buttext$
!
      do
         rinput #Window, fields Mat Se_Inspec$, help mat Se_InTTip$ : Mat Screenio$(Si_Enterfn:Si_Exitfn)
         let Function=Fkey
!
         if Function>30 And Function<(32+Si_Exitfn-Si_Enterfn) then
            let Eventsub=Si_Enterfn+Fkey-31
            if len(trim$(ScreenIO$(EventSub))) and Exists(Fncustomfilenameof$(Screenio$(Eventsub))) then
               let Fneditcustomfunction(Screenio$(Eventsub))
            else
               let Screenio$(Eventsub)=Fnselectfunctiondialog$(Screenio$(Eventsub),Function,1000+EventSub)
            end if
         end if
      loop Until Function=99 Or Function=98 Or Function=93 Or ((Function>1100) And (Function<1699)) Or Function=44 Or Function=19
!
      if Window and file(Window)>-1 then close #Window:
!
   fnend

   dim DebugOutTTip$(1)*255
   dim DebugInTTip$(5)*255
!
CONFIGUREDEBUG: ! Opens A Child Window To Configure The Debug Command
   def Fnconfiguredebug(Mat Screenio$, Mat Screenio;&Function,___,Window,Routinename$*64,Newscreen$*64,Record$)
      open #(Window:=Fngetfilenumber): "SROW=11,SCOL=31,ROWS=6,COLS=50,Border=S,Caption=Configure Debug Command",display,outin
      print #Window, fields "1,1,16/CR 20;2,1,16/CR 20;3,1,16/CR 20;4,1,16/CR 20;5,1,16/CR 20;6,1,16/CR 20" : "Launch Screen:","Key$:","ParentKey$:","Record:","Path:","mat PassedData:"
!
      let DebugOutTTip$(1)="Select the screen to run when testing this screen."
      let DebugInTTip$(1)="Enter the value to pass in for Key$ when testing."
      let DebugInTTip$(2)="Enter the value to pass in for ParentKey$ when testing."
      let DebugInTTip$(3)="Enter the value to pass in for Record when testing."
      let DebugInTTip$(4)="Enter the optional alternate data path to use when testing. See the fileio documentation for more details on this parameter. If you don't know what its for, you don't need it."
      let DebugInTTip$(5)="Enter the values to use for mat PassedData$ when testing, seperated by commas."

      let fnFixTooltips(mat DebugOutTTip$)
      let fnFixTooltips(mat DebugInTTip$)

      do
         if Trim$(Screenio$(Si_Debugscreen))="" then
            let Routinename$="Self"
         else
            let Routinename$=Trim$(Screenio$(Si_Debugscreen))
         end if

         let Record$=str$(screenio(si_DebugRecord))

         print #Window, fields "1,20,17/CC 64,/W:W,B31", help mat DebugOutTTip$ : Routinename$
         rinput #Window, fields "2,18,21/V 255,/W:#FFFF77;3,18,21/V 255,/W:#FFFF77;4,18,21/V 18,/W:#FFFF77;5,18,21/V 255,/W:#FFFF77;6,18,21/V 255,/W:#FFFF77", help mat DebugInTtip$ : Screenio$(Si_Debugkey),Screenio$(Si_Debugparentkey),Record$,ScreenIO$(si_DebugPath), ScreenIO$(si_debugPassed)
         let ScreenIO(si_DebugRecord)=val(Record$) conv Ignore
         let Function=Fkey
!
         if Function=31 then
! .         !Select the screen to use
            let Newscreen$=Fnselectscreen$(1)
            if Newscreen$<>"" then
               if Lwrc$(Trim$(Newscreen$))=Lwrc$(Trim$(Screenio$(Si_Screencode))) then
                  let Routinename$="Self"
                  let Screenio$(Si_Debugscreen)=""
               else
                  let Routinename$=Screenio$(Si_Debugscreen)=Trim$(Newscreen$)
               end if
            end if
         end if
      loop Until Function=99 Or Function=98 Or Function=93 Or ((Function>1100) And (Function<1699)) Or Function=44 Or Function=19
!
      close #Window:
!
   fnend

ConfigureProtected: ! Configure The Appearance of Protected Controls
   def FnconfigureProtected(Mat Screenio$, Mat Screenio;&Function,___,Window)
      open #(Window:=Fngetfilenumber): "SROW=11,SCOL=36,ROWS=10,COLS=40,Border=S,Caption=Configure Protected Style Attribute",display,outin
      print #Window, fields "1,1,17/CR 20;2,1,17/CR 20;3,1,17/CR 20;5,1,17/CR 20;6,1,17/CR 20;7,1,17/CR 20;9,1,17/CR 20;10,1,17/CR 20" : "Protected Text:","Protected Checkbox:","Protected Button:","Other Changes Color:","My Changes Color:","Lock Message Color:","Active Color:","UserData:"
!
      do
         rinput #Window, fields "1,19,21/V 255,/W:#FFFF77;2,19,21/V 255,/W:#FFFF77;3,19,21/V 255,/W:#FFFF77;5,19,21/V 255,/W:#FFFF77;6,19,21/V 255,/W:#FFFF77;7,19,21/V 255,/W:#FFFF77;9,19,21/V 255,/W:#FFFF77;10,19,21/V 255,/W:#FFFF77" : mat ScreenIO$(si_ProtectedText:si_ProtectedButton),mat ScreenIO$(si_OtherChanges:si_ActiveColor),ScreenIO$(si_userdata)
         let Function=Fkey
      loop Until Function=99 Or Function=98 Or Function=93 Or ((Function>1100) And (Function<1699)) Or Function=44 Or Function=19
      close #Window:
   fnend

!
TRYTOCLOSE: !  Function Closes A Window If It Was Open
   def Fntrytoclose(Windownumber)
      if Windownumber then
         if File(Windownumber)<>-1 then
            close #Windownumber:
         end if
         let Windownumber=0
      end if
   fnend
!
FILETOSCREEN: !  Converts Given File To String Based On Passed Subscripts
   def Fnfiletoscreen(Mat F$,Mat F,Mat Screen$,Mat Subs;___,_I)
      for _I=1 to Udim(Mat Subs)
         if Subs(_I) >0 then
            let Screen$(_I)=F$(Subs(_I))
         else if Subs(_I) < 0 then
            if Abs(Subs(_I))=Si_Border or abs(Subs(_I))=Si_ScreenIOLocking or abs(Subs(_I))=Si_ScreenIOMerge then
               if F(Abs(Subs(_I))) then
                  let Screen$(_I)="^"
               else
                  let Screen$(_I)=""
               end if
            else
               let Screen$(_I)=Str$(F(Abs(Subs(_I))))
            end if
         end if
      next _I
   fnend
!
SCREENTOFILE: !  Converts Given File To String Based On Passed Subscripts
   def Fnscreentofile(Mat F$,Mat F,Mat Screen$,Mat Subs;___,_I)
      for _I=1 to Udim(Mat Subs)
         if Subs(_I) >0 then
            let F$(Subs(_I))=Screen$(_I)
         else if Subs(_I) < 0 then
            if Abs(Subs(_I))=Si_Border or abs(subs(_i))=si_screenioLocking or abs(subs(_i))=si_ScreenIOMerge then
               if Screen$(_I)(1:1)="^" then
                  let F(Abs(Subs(_I)))=1
               else
                  let F(Abs(Subs(_I)))=0
               end if
            else
               let F(Abs(Subs(_I)))=Val(Screen$(_I)) conv IGNORE
            end if
         end if
      next _I
   fnend
!
SAMEAS: !   ***** Compares Two String Arrays Returning True If Same
   def Fnsameas(Mat A$,Mat B$;___,Failed,Index)
      if Udim(Mat A$)=Udim(Mat B$) then
         for Index=1 to Udim(Mat A$)
            if Trim$(A$(Index))<>Trim$(B$(Index)) then let Failed=1
         next Index
         let Fnsameas=(~(Failed))
      end if
   fnend
!
SAMEA: !   ***** Compares  Two Number Arrays Returning True If Same
   def Fnsamea(Mat A,Mat B;___,Failed,Index)
      if Udim(Mat A)=Udim(Mat B) then
         for Index=1 to Udim(Mat A)
            if A(Index)<>B(Index) then let Failed=1
         next Index
         let Fnsamea=(~(Failed))
      end if
   fnend
!
SEARCHCLOSELY: !   ***** Searches Mat A$ Looking For A Partial Match To B$ And Optionally C$ (Case Insensitive)
   def Fnsearchclosely(Mat A$,B$;C$,___,Index,Found)
      for Index=1 to Udim(Mat A$)
         if Trim$(C$)="" then
            if Pos(Lwrc$(A$(Index)),Lwrc$(B$)) then let Found=Index
         else
            if Pos(Lwrc$(A$(Index)),Lwrc$(B$)) And Pos(Lwrc$(A$(Index)),Lwrc$(C$)) then let Found=Index
         end if
      next Index
      let Fnsearchclosely=Found
   fnend
!
TESTATTRIBUTES: !  Tests The User Attributes
   def Fntestattributes(Attributes$*255,Vpos,Hpos;___,Weditor)
      let fnChangeForceVisibility(0)
      open #(Weditor:=Fngetfilenumber): "SROW=" & Str$(Vpos) & ", SCOL=" & Str$(Hpos) & ", ROWS=1, COLS=1, " & Screenio$(Si_Attributes), display, outin error IGNORE
      if File(Weditor)=-1 then
         let Fntestattributes=0
      else
         let Fntestattributes=1
         close #Weditor:
      end if
   fnend

   dim PreserveNonGui$*10000
   dim PreserveNonGuiRows
   dim PreserveNonGuiCols

PRESERVENONGUI: ! Preserve the Non Gui Window
   def fnPreserveNonGui
      let Fnreadscreensize(PreserveNonGuiRows,PreserveNonGuiCols,0)
      input #0, fields "1,1,C "&str$(PreserveNonGuiRows*PreserveNonGuiCols)&",G" : PreserveNonGui$
      execute "config gui on"
   fnend

   def fnRestoreNonGui
      execute "config gui off"
      open #0: "rows="&str$(PreserveNonGuiRows)&", cols="&str$(PreserveNonGuiCols),display,outin
      print #0, fields "1,1,C "&str$(PreserveNonGuiRows*PreserveNonGuiCols) : PreserveNonGui$
   fnend

!
dim ScreenSize(4), FontSize(2)
READSCREENSIZE: ! Return The Screen Size Of Window 0 In Terms Of Rows And Columns
   def fnReadScreenSize(&Rows,&Cols;ParentWindow)
      if ~fn42e then
         let fnOldReadScreenSize(Rows,Cols,ParentWindow)
      else
         let file(ParentWindow,"USABLE_RECT",mat ScreenSize)
         let file(ParentWindow,"FONTSIZE",mat FontSize)
         let Rows=(ScreenSize(4)/FontSize(1))
         let Cols=(ScreenSize(3)/FontSize(2))
      end if
   fnend

   def FnOldreadscreensize(&Rows,&Cols;ParentWindow,___,Ffile,String$*2000,Srow,Scol,Erow,Ecol,Position)
      if env$("guimode")<>"ON" then
         let Rows=val(env$("screensize_rows")) conv Ignore
         let Cols=val(env$("screensize_cols")) conv Ignore
         if ~Rows then let Rows=24
         if ~Cols then let Cols=80
      else
         execute "Status Files >[SESSION].tmp"
         open #(Ffile:=Fngetfilenumber) : "name=[SESSION].tmp",display,input
!
         do While File(Ffile)=0
            linput #Ffile: String$ eof IGNORE
         loop Until String$(1:5)="-----"
         do While File(Ffile)=0
            linput #Ffile: String$ eof IGNORE
         loop Until (Lwrc$(String$)(1:4)="open") And Trim$(String$(Pos(String$,"#")+1:Pos(String$,"#")+5))=str$(ParentWindow)
         if File(Ffile)=0 then
            linput #Ffile: String$ eof IGNORE
         end if
!
         close #Ffile:
         execute "Free [SESSION].tmp" error RetryFiveTimes
!
         if (Position:=Pos(Uprc$(String$),"SROW=")) then
            let Srow=Val(String$(Position+5:Pos(String$,",",Position)-1)) conv IGNORE
         end if
         if (Position:=Pos(Uprc$(String$),"SCOL=")) then
            let Scol=Val(String$(Position+5:Pos(String$,",",Position)-1)) conv IGNORE
         end if
         if (Position:=Pos(Uprc$(String$),"EROW=")) then
            let Erow=Val(String$(Position+5:Pos(String$,",",Position)-1)) conv IGNORE
         end if
         if (Position:=Pos(Uprc$(String$),"ECOL=")) then
            let Ecol=Val(String$(Position+5:Pos(String$,",",Position)-1)) conv IGNORE
         end if
         if Srow And Erow then let Rows=Erow-Srow+1
         if Scol And Ecol then let Cols=Ecol-Scol+1
      end if
   fnend

! **********************************************************************
! Functions To Get Info From Config.Sys Files. By Susan Smith. Updated By Gabriel Bakker - To Save Time By Running Only Once.
   dim Configfile$*300
   dim Executablefile$*300
!
   def Fngetwbcfg$*255
      if Configfile$="" then
         let Fnreadconfigandexe
      end if
      let Fngetwbcfg$=Configfile$
   fnend
!
   def Fngetbrexe$*255
      if Executablefile$="" then
         let Fnreadconfigandexe
      end if
      let Fngetbrexe$=Executablefile$
   fnend
!
   dim Configstat$*30000
   def Fnreadconfigandexe(;___,Cr$,Filenumber,Qstart,Qend)
      let Cr$=Hex$("0D0A")
      execute "status files >TEMPFILE.[session]"
      if Exists("TEMPFILE.[session]") then
         open #(Filenumber:=Fngetfilenumber): "name=TEMPFILE.[session],eol=none",display,input error IGNORE
         if ~File(Filenumber) then
            linput #Filenumber: Configstat$
            close #Filenumber:
!
            let Qstart=Pos(Uprc$(Configstat$),"CONFIG FILE")
            if Qstart>0 then
               let Configfile$=Configstat$(Qstart+13:Qstart+300)
               let Qend=Pos(Configfile$,Cr$)
               let Configfile$=Configfile$(1:Qend-1)
               if Configfile$(1:1)=":" then let Configfile$=Os_Filename$(Configfile$)
            end if
!
            let Qstart=Pos(Uprc$(Configstat$),"EXECUTABLE FILE")
            if Qstart>0 then
               let Executablefile$=Configstat$(Qstart+17:Qstart+300)
               let Qend=Pos(Executablefile$,Cr$)
               let Executablefile$=Executablefile$(1:Qend-1)
               if Executablefile$(1:1)=":" then let Executablefile$=Os_Filename$(Executablefile$)
            end if
         end if
      end if
      if Exists("c:\TEMPFILE.[session]") then execute "free TEMPFILE.[session] -N"
   fnend

   def library fnMakeScreen(;layout$,LaunchScreen,___,NoLaunch,ExternalLaunch)
      if LaunchScreen then ExternalLaunch=1 else NoLaunch=1
      if fnWarnMessage then execute "system"
      let fnSettings ! Also includes library linkage to FileIO
      let Fndefineinputmodes
      let Fnopenscreenfiles(Mat Screenio$,Mat Screenio)

      let ScreenIO$(si_filelay)=layout$
      let fnGenerateScreen(Mat ScreenIO$,mat ScreenIO,[[ScreenControls]],NoLaunch,ExternalLaunch)       ! Change it to always launch both screens in an external process or don't, depending on what they say.
   fnend

   dim GS_Data$(7)
   dim GS_Field$(1)*64,GS_FieldSpec$(1)*32,GS_FieldDesc$(1)*255,GS_DateSpec$(1)*64,GS_LaunchList$(1)*64

   def fnGenerateScreen(Mat ScreenIO$, mat ScreenIO, [[ScreenControls]];NoLaunch,ExternalLaunch,___,Generate,NewField,Index,ListviewField,Rightedge,TitleField,StopHere,OpenOtherWindow,CaptionIndex,CancelButton,SaveButton,AddButton,EditButton,DeleteButton)
      let GS_Layout=1 : GS_BuildListview=2 : GS_NameListview=3 : GS_BuildAddEdit=4
      let GS_NameAddEdit=5 : GS_BuildCombo=6 : GS_NameCombo=7

      mat GS_LaunchList$(0)

      ! Set Input Defaults
      let GS_Data$(GS_BuildListview)=GS_Data$(GS_BuildAddEdit)="^"
      if len(trim$(ScreenIO$(si_filelay))) then
         let GS_Data$(GS_Layout)=GS_LastChoice$=trim$(ScreenIO$(si_filelay))
         let GS_Data$(GS_NameListview)=uprc$(Trim$(ScreenIO$(si_FileLay)))(1:14)&"LIST"
         let GS_Data$(GS_NameAddEdit)=uprc$(Trim$(ScreenIO$(si_FileLay)))(1:14)&"EDIT"
         let GS_Data$(GS_NameCombo)=uprc$(Trim$(ScreenIO$(si_FileLay)))(1:13)&"COMBO"
      end if
      let Generate=fnInputMainPage(mat GS_Data$)
      if Generate then
         ! Put the generate screen code here.
         if GS_Data$(GS_BuildListview)(1:1)="^" then ! Create Listview Screen
            let Generate=fnInputFields(GS_Data$(GS_Layout),"Select fields for Listview",mat GS_Field$,mat GS_FieldSpec$,mat GS_FieldDesc$,mat GS_DateSpec$)

            if Generate then
               let FnReadScreen("",Mat Screenio$,Mat Screenio,[[ScreenControls]]) ! Init Blank Screen
               let fnGenerateHeader(GS_Data$(GS_NameListview),GS_Data$(GS_Layout),mat ScreenIO$,mat ScreenIO)

               mat Gaps=(0)
               let TitleField=fnAddATitle(GS_Data$(GS_Layout),[[ScreenControls]],mat ScreenIO$,mat ScreenIO)
               let Fnskipagap
               let Fnskipagap

               ! Add a listview, make it big
               let ListviewField=fnAddListview([[ScreenControls]],1)
               let HPosition(ListviewField)=10
               let Width(ListviewField)=ScreenIO(si_HSize)-18
               let Height(ListviewField)=ScreenIO(si_VSize)-8
               let Fgcolor$(ListviewField)="W"
               let Bgcolor$(ListviewField)="W"

               ! Add some columns
               for Index=1 to udim(mat GS_Field$)
                  let NewField=fnAddCurrentListChld(Parent$(ListviewField),[[ScreenControls]],gs_Field$(Index),gs_fieldDesc$(Index),gs_FieldSpec$(Index),gs_DateSpec$(Index))
               next Index

               ! Add a Filter box
               if fn43 then
                  let NewField=FnAddFilterbox([[ScreenControls]],Inputeditormode,ListviewField)
               else
                  let NewField=FnAddSearchbox([[ScreenControls]],Inputeditormode,ListviewField)
               end if

               let SpecWidth(ListviewField)=1 ! Set it to search 1st column
               let Fgcolor$(NewField)="W"
               let Bgcolor$(NewField)="W"

               ! Add Exit Buttons
               let fnAddExitButtons(mat ScreenIO$,mat ScreenIO,[[ScreenControls]])

               ! If there's also an add/edit screen then
               if GS_Data$(GS_BuildAddEdit)(1:1)="^" then ! Create Add/Edit Screen
                  ! Add Add/Edit/Delete buttons
                  let fnAddAEButtons(mat ScreenIO$,mat ScreenIO,[[ScreenControls]],GS_Data$(GS_NameAddEdit))
               end if

               ! Save the screen
               if Fnwritescreen(Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
                  let fnLaunchLater(gs_Data$(gs_NameListview))
               else
                  let msgbox("Error saving listview screen.")
                  let StopHere=1
               end if
            end if
         end if

         if ~StopHere then
            if GS_Data$(GS_BuildAddEdit)(1:1)="^" then ! Create Add/Edit Screen
               let Generate=fnInputFields(GS_Data$(GS_Layout),"Select fields for Add/Edit",mat GS_Field$,mat GS_FieldSpec$,mat GS_FieldDesc$,mat GS_DateSpec$)
               if Generate then

                  let FnReadScreen("",Mat Screenio$,Mat Screenio,[[Screencontrols]]) ! Init Blank Screen
                  let fnGenerateHeader(GS_Data$(GS_NameAddEdit),GS_Data$(GS_Layout),mat ScreenIO$,mat ScreenIO,1)
                  mat Gaps=(0)
                  let TitleField=fnAddATitle(GS_Data$(GS_Layout),[[ScreenControls]],mat ScreenIO$,mat ScreenIO,1)
                  let Fnskipagap

                  ! Add a bunch of edit fields
                  for Index=1 to udim(mat GS_Field$)
                     let NewField=FnAddAndColorCurrentField([[Screencontrols]],mat ScreenIO$,mat ScreenIO,GS_Field$(Index),GS_FieldDesc$(Index),GS_FieldSpec$(Index),GS_DateSpec$(Index))
                  next Index

                  ! Shrink title to match width of widest control
                  let RightEdge=0
                  for Index=1 to Udim(Mat Hposition)
                     if Index><TitleField then
                        let Rightedge=Max(Rightedge,Hposition(Index)+Width(Index)-1)
                     end if
                  next Index
                  let Width(TitleField)=RightEdge-8

                  ! Resize Screen
                  let Fnresizescreen(Mat Screenio$,Mat Screenio,[[Screencontrols]])

                  ! Add Exit Buttons
                  let fnAddExitButtons(mat ScreenIO$,mat ScreenIO,[[ScreenControls]])

                  ! Save the screen
                  if Fnwritescreen(Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
                     let fnLaunchLater(gs_Data$(GS_NameAddEdit))
                  else
                     let msgbox("Error saving Add/Edit Screen.")
                     let StopHere=1
                  end if
               end if
            end if
         end if

         if ~StopHere then
            if GS_Data$(GS_BuildCombo)(1:1)="^" then ! Create Combo Screen
               let Generate=fnInputFields(GS_Data$(GS_Layout),"Select fields for Combo Screen Listview",mat GS_Field$,mat GS_FieldSpec$,mat GS_FieldDesc$,mat GS_DateSpec$)
               if Generate then

                  let FnReadScreen("",Mat Screenio$,Mat Screenio,[[Screencontrols]]) ! Init Blank Screen
                  let fnGenerateHeader(GS_Data$(GS_NameCombo),GS_Data$(GS_Layout),mat ScreenIO$,mat ScreenIO,1)
                  mat Gaps=(0)
                  let TitleField=fnAddATitle(GS_Data$(GS_Layout),[[ScreenControls]],mat ScreenIO$,mat ScreenIO,1)
                  let Fnskipagap

                  ! Add a listview on the left
                  let ListviewField=fnAddListview([[ScreenControls]],1)
                  let HPosition(ListviewField)=5
                  let Width(ListviewField)=max(int((ScreenIO(si_HSize)-10)/2),10)
                  let Height(ListviewField)=ScreenIO(si_VSize)-8
                  let Fgcolor$(ListviewField)="W"
                  let Bgcolor$(ListviewField)="W"

                  ! Add some columns
                  for Index=1 to udim(mat GS_Field$)
                     let NewField=fnAddCurrentListChld(Parent$(ListviewField),[[ScreenControls]],gs_Field$(Index),gs_fieldDesc$(Index),gs_FieldSpec$(Index),GS_DateSpec$(Index))
                  next Index

                  ! Add a Search box
                  if fn43 then
                     let NewField=FnAddFilterbox([[ScreenControls]],Inputeditormode,ListviewField)
                  else
                     let NewField=FnAddSearchbox([[ScreenControls]],Inputeditormode,ListviewField)
                  end if
                  let SpecWidth(ListviewField)=1 ! Set it to search 1st column
                  let Fgcolor$(NewField)="W"
                  let Bgcolor$(NewField)="W"

                  let Generate=fnInputFields(GS_Data$(GS_Layout),"Select fields for Combo Screen Edit",mat GS_Field$,mat GS_FieldSpec$,mat GS_FieldDesc$,mat GS_DateSpec$)
                  if Generate then
                     mat Gaps=(0)
                     let fnSkipAGap
                     let fnSkipAGap
                     ! Add a bunch of edit fields (on the right half)
                     for Index=1 to udim(mat GS_Field$)
                        let NewField=FnAddAndColorCurrentField([[Screencontrols]],mat ScreenIO$,mat ScreenIO,GS_Field$(Index),GS_FieldDesc$(Index),GS_FieldSpec$(Index),GS_DateSpec$(Index),CaptionIndex,Index+2)
                        let HPosition(CaptionIndex)=HPosition(ListviewField)+Width(ListviewField)+5
                        let Width(CaptionIndex)=10

                        let HPosition(NewField)=HPosition(CaptionIndex)+Width(CaptionIndex)+2
                        let Width(NewField)=min(max(ScreenIO(si_HSize)-HPosition(NewField)-5,5),Width(NewField))
                        let Function$(NewField)="{listviewcombovalfld}"
                        if Index=1 then let ControlName$(NewField)="FirstField"
                     next Index

                     ! Assign a read function and mainloop to make it ignore user changes when listview sel changes too.
                     let ScreenIO$(si_Readfn)="{listviewcomboread}"
                     let ScreenIO$(si_Loopfn)="{listviewcombomain}"

                     ! Assign a listview postpopulate function that calls read
                     ! let ScreenIO$(si_PostListviewFn)="{listviewcombopost}"

                     ! Add Exit Buttons
                     let fnAddExitButtons(mat ScreenIO$,mat ScreenIO,[[ScreenControls]],0,CancelButton,SaveButton)
                     let Function$(SaveButton)="{listviewcombosave}"
                     let Description$(SaveButton)="Save"
                     let Description$(CancelButton)="Quit"

                     ! Add Add/Delete Buttons
                     let fnAddAEButtons(mat ScreenIO$,mat ScreenIO,[[ScreenControls]],"nothing",VPosition(SaveButton),0,0,1,0,AddButton,EditButton,DeleteButton)
                     if AddButton then
                        let Function$(AddButton)="{listviewcomboadd}"
                     end if
                     if DeleteButton then
                        let Function$(DeleteButton)="{listviewcombodelete}"
                     end if

                     ! Save the screen
                     if Fnwritescreen(Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
                        let fnLaunchLater(gs_Data$(GS_NameCombo))
                     else
                        let msgbox("Error saving Combo Screen.")
                        let StopHere=1
                     end if
                  end if
               end if
            end if
         end if
         if ~NoLaunch then let fnLaunchScreens
      end if
   fnend
   def fnLaunchLater(ScreenName$;___,I)
      let I=udim(mat GS_LaunchList$)+1
      mat GS_LaunchList$(I)
      let GS_LaunchList$(I)=ScreenName$
   fnend
   def fnLaunchScreens(;___,I)
      for i=1 to udim(mat GS_LaunchList$)
         if ExternalLaunch or i < udim(mat GS_LaunchList$) then
            let fnLaunchScreen(GS_LaunchList$(i),i) ! Normal mode launches all but 1 which it keeps in memory. External launches all.
         end if
      next i
   fnend

   def fnAddATitle(FileDescription$,[[ScreenControls]],mat ScreenIO$,mat ScreenIO;Edit,___,Index)
      let Index=fnAddCaption([[ScreenControls]])
      let Controlname$(Index)="Title"
      if Edit then
         let Description$(Index)="Edit "&uprc$(FileDescription$(1:1))&lwrc$(FileDescription$(2:18))
      else
         let Description$(Index)=uprc$(FileDescription$(1:1))&lwrc$(FileDescription$(2:18))&" List"
      end if
      let Justify$(Index)="C"
      let Hposition(Index)=6
      let Width(Index)=ScreenIO(si_hsize)-14
      let Specwidth(Index)=Len(Trim$(Description$(Index)))
      let fnAddATitle=Index
   fnend

   dim GS_Cap$(6),GS_CapSpec$(6)*50,GS_Spec$(7)*50,GS_Combo$*50,GS_LastChoice$,GS_Layouts$(1)
   def fnInputMainPage(mat GS_Data$;___,Window,Done,Function,Cfld,SRows,SCols,Row,Col)
      let fnReadScreenSize(SRows,SCols)
      let Row=max(1,int((SRows-9)/2))
      let Col=max(1,int((Scols-40)/2))
      open #(Window:=fnGetFileNumber): `srow={{Row}},scol={{Col}},rows=9,cols=40,border=s,caption=Generate Screens`,display,outin
      ! Build Caption Specs
      let GS_CapSpec$(1)="2,2,CR 10" : let GS_Cap$(1)="Layout: "
      let GS_CapSpec$(2)="4,2,CR 10" : let GS_Cap$(2)="Listview: "
      let GS_CapSpec$(3)="5,2,CR 10" : let GS_Cap$(3)="Add/Edit: "
      let GS_CapSpec$(4)="8,20,CC 8,/W:W,B5" : let GS_Cap$(4)="Generate"
      let GS_CapSpec$(5)="8,30,CC 8,/W:W,B99" : let GS_Cap$(5)="Cancel"
      let GS_CapSpec$(6)="6,2,CR 10" : let GS_Cap$(6)="Cmb Scrn: "

      ! Build Input Specs
      let GS_Combo$="2,13,COMBO 18,=,SELECT"
      let GS_Spec$(GS_Layout)="2,13,COMBO 18,X/W:W,SELECT"
      let GS_Spec$(GS_BuildListview)="4,13,CHECK 1,/W:W"
      let GS_Spec$(GS_BuildAddEdit)="5,13,CHECK 1,/W:W"
      let GS_Spec$(GS_NameListview)="4,15,C 18,/W:W"
      let GS_Spec$(GS_NameAddEdit)="5,15,C 18,/W:W"
      let GS_Spec$(GS_BuildCombo)="6,13,CHECK 1,/W:W"
      let GS_Spec$(GS_NameCombo)="6,15,C 18,/W:W"

      ! Print Captions
      print #Window, fields mat GS_CapSpec$ : mat GS_Cap$

      ! Read File Layouts
      let Fnreadlayouts(Mat GS_Layouts$)

      ! Populate Combo Box
      mat GS_Layouts$(udim(mat GS_Layouts$)+1) ! Add blank one
      print #Window, fields GS_Combo$ : mat GS_Layouts$

      ! Check for match on the combo box
      if srch(mat GS_Layouts$,GS_Data$(1))<=0 then
         let GS_Data$(GS_Layout)=GS_LastChoice$=""
         let GS_Data$(GS_NameListview)=""
         let GS_Data$(GS_NameAddEdit)=""
         let GS_Data$(GS_NameCombo)=""
      end if

      do until Done
         rinput #Window, fields mat GS_Spec$ : mat GS_Data$
         let Function=fkey
         let Cfld=Curfld
         let Curfld(Cfld,Function)

         if GS_LastChoice$><GS_Data$(GS_Layout) then
            let GS_Data$(GS_NameListview)=uprc$(Trim$(GS_Data$(GS_Layout)))(1:14)&"LIST"
            let GS_Data$(GS_NameAddEdit)=uprc$(Trim$(GS_Data$(GS_Layout)))(1:14)&"EDIT"
            let GS_Data$(GS_NameCombo)=uprc$(Trim$(GS_Data$(GS_Layout)))(1:13)&"COMBO"
            let GS_LastChoice$=GS_Data$(GS_Layout)
         end if

         let fnCleanString(GS_Data$(GS_NameListview))
         let fnCleanString(GS_Data$(GS_NameAddEdit))
         let fnCleanString(GS_Data$(GS_NameCombo))

         #Select# Function #Case# 5
            if len(trim$(gs_data$(GS_Layout))) and (Gs_data$(GS_BuildListview)(1:1)="^" and len(trim$(gs_data$(GS_NameListview)))) or (Gs_data$(GS_BuildAddEdit)(1:1)="^" and len(trim$(gs_data$(GS_NameAddEdit)))) or (Gs_data$(GS_BuildCombo)(1:1)="^" and len(trim$(gs_data$(GS_NameCombo)))) then
               let Done=1
            else
               let msgbox("You must select a file layout, check at least 1 box above, and enter a valid screen name.","Nothing to do.")
            end if
         #Case# 99 # 93
            let Done=-1
         #End Select#
      loop

      Close #Window:

      if Done=1 then
         let fnInputMainPage=1
      end if
   fnend

   dim IF_SFields$(1)*64,IF_NFields$(1)*64
   dim IF_SFieldsSpec$(1)*32,IF_NFieldsSpec$(1)*32
   dim IF_SFieldsDescription$(1)*255,IF_NFieldsDescription$(1)*255
   dim IF_SPos(1), IF_NPos(1)
   dim IF_SDateSpec$(1)*64,IF_NDateSpec$(1)*64

   dim RowSelected(1)
   def fnInputFields(Layout$,Caption$*40,mat SelectedFields$,mat SelectedSpec$,mat SelectedDescription$,mat SelectedDateSpec$;___,ListSpec$,Row,Col,Rows,sRows,sCols,Window,Done,Function,Cfld,Prefix$,SelCount,Index)
      ! Read Fields
      let Fnreadlayoutarrays(Layout$,Prefix$,Mat IF_SFields$,Mat IF_NFields$,Mat IF_SFieldsSpec$,Mat IF_NFieldsSpec$,Mat IF_SFieldsDescription$,Mat IF_NFieldsDescription$,mat IF_SPos,mat IF_NPos,0,mat IF_SDateSpec$,mat IF_NDateSpec$)

      let fnReadScreenSize(sRows,sCols)
      let Rows=sRows-8 : Rows=max(Rows,6) : Rows=min(Rows,udim(mat IF_SFields$)+udim(mat IF_NFields$)+5)   ! Total Rows
      let Col=max(1,int((scols-42)/2)) : Row=max(1,int((srows-(rows+2))/2))                                ! Position in Center

      open #(Window:=fnGetFileNumber): `srow={{Row}},scol={{Col}},rows={{Rows}},cols=40,border=s`,display,outin

      ! Print listview
      let Fieldsheadings$(1)="Name"
      let Fieldswidths(1)=9
      let Fieldsspec$(1)="V 50"
      let Fieldsheadings$(2)="Description"
      let Fieldswidths(2)=14
      let Fieldsspec$(2)="V 255"
      let Fieldsheadings$(3)="Type"
      let Fieldswidths(3)=5
      let Fieldsspec$(3)="V 30"
      let Fieldsheadings$(4)="Date"
      let Fieldswidths(4)=3
      let Fieldsspec$(4)="V 64"

      let ListSpec$="3,1,LIST "&str$(Rows-4)&"/40"

      print #Window, fields ListSpec$&",HEADERS,/W:W,1300" : (Mat Fieldsheadings$, Mat Fieldswidths, Mat Fieldsspec$)

      ! Print Exit Buttons
      print #Window, fields str$(rows)&",20,CC 8,/W:W,B7;"&str$(rows)&",30,CC 8,/W:W,B99" : "Generate","Cancel"
      print #Window, fields "1,1,CC 40" : Caption$

      ! Populate Listview
      print #Window, fields ListSpec$&",=,1300" : (Mat IF_SFields$, Mat IF_SFieldsDescription$, Mat IF_SFieldsSpec$, mat IF_SDateSpec$)
      print #Window, fields ListSpec$&",+,1300" : (Mat IF_NFields$, Mat IF_NFieldsDescription$, Mat IF_NFieldsSpec$, mat IF_NDateSpec$)

      do until Done
         rinput #Window, fields ListSpec$&",ROWCNT,SEL" : SelCount
         mat RowSelected(SelCount) ! We do it the old way so its compatible with both ways
         rinput #Window, fields ListSpec$&",ROWSUB,SEL,NOWAIT" : mat RowSelected

         let Function=fkey
         let Cfld=Curfld
         let Curfld(Cfld,Function)

         #Select# Function #Case# 7

            ! Return Selected Fields
            ! Clear the arrays first
            mat SelectedFields$(0)
            mat SelectedSpec$(0)
            mat SelectedDescription$(0)
            mat SelectedDateSpec$(0)

            ! Loop through selected, and build them into passback arrays
            for Index=1 to udim(mat RowSelected)
               if RowSelected(Index)<=udim(mat IF_SFields$) then
                  mat SelectedFields$(udim(mat SelectedFields$)+1)
                  mat SelectedSpec$(udim(mat SelectedFields$))
                  mat SelectedDescription$(udim(mat SelectedFields$))
                  mat SelectedDateSpec$(udim(mat SelectedFields$))

                  let SelectedFields$(udim(mat SelectedFields$))=IF_SFields$(RowSelected(Index))
                  let SelectedSpec$(udim(mat SelectedFields$))=IF_SFieldsSpec$(RowSelected(Index))
                  let SelectedDescription$(udim(mat SelectedFields$))=IF_SFieldsDescription$(RowSelected(Index))
                  let SelectedDateSpec$(udim(mat SelectedFields$))=IF_SDateSpec$(RowSelected(Index))
               else
                  mat SelectedFields$(udim(mat SelectedFields$)+1)
                  mat SelectedSpec$(udim(mat SelectedFields$))
                  mat SelectedDescription$(udim(mat SelectedFields$))
                  mat SelectedDateSpec$(udim(mat SelectedFields$))

                  let SelectedFields$(udim(mat SelectedFields$))=IF_NFields$(RowSelected(Index)-udim(IF_SFields$))
                  let SelectedSpec$(udim(mat SelectedFields$))=IF_NFieldsSpec$(RowSelected(Index)-udim(IF_SFields$))
                  let SelectedDescription$(udim(mat SelectedFields$))=IF_NFieldsDescription$(RowSelected(Index)-udim(IF_SFields$))
                  let SelectedDateSpec$(udim(mat SelectedFields$))=IF_NDateSpec$(RowSelected(Index)-udim(IF_SFields$))
               end if
            next Index

            let Done=1
         #Case# 99 # 93
            let Done=-1
         #End Select#
      loop

      Close #Window:

      if Done=1 then
         let fnInputFields=1
      end if
   fnend

   def fnCleanString(&String$;___,Index)
      do
         let Index+=1
         if Index<=len(String$) then
            if pos("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",uprc$(String$(Index:Index)))<=0 then
               let String$(Index:Index)=""
               let Index-=1
            end if
         end if
      loop while Index<len(String$)
   fnend

   def fnGenerateHeader(ScreenName$,Layout$,mat ScreenIO$,mat ScreenIO;AddBorder)
      let screenio$(SI_screencode)=uprc$(ScreenName$)
      let screenio$(SI_filelay)=Layout$
      let screenio(SI_vsize)=24
      let screenio(SI_hsize)=80
      let screenio(SI_createdate)=screenio(SI_modifydate)=days(date$)
      let screenIO$(si_createUser)=ScreenIO$(si_modifyUser)=login_name$
      let screenio(si_border)=AddBorder
   fnend

   dim GeneratedCode$*20000
   dim DisplayListview$(1)*255
   def fnGenerateCode(Mat ScreenIO$, mat ScreenIO, [[ScreenControls]];___,Index,SpecList$*20000,DataList$*20000,HelpList$*20000,Crlf$,InputHelp,OutputHelp)
      GeneratedCode$=""

      ! Commonly Used Strings
      let CrLf$=chr$(13)&chr$(10)

      let ScreenName$=uprc$(trim$(ScreenIO$(si_screencode))(1:1))&LWRC$(TRIM$(ScreenIO$(si_screencode))(2:18))
      let LayoutName$=uprc$(TRIM$(ScreenIO$(si_filelay))(1:1))&LWRC$(TRIM$(ScreenIO$(si_filelay))(2:99))

      ! Arrays
      dim Output_Data$(1)*1000,Output_Spec$(1)*255, Output_Help$(1)*1050
      dim Input_Data$(1)*1000,Input_Data(1),Input_Spec$(1)*255, Input_Help$(1)*1050, Input_Old$(1)*1000

      ! Generate Specs
      let Fngenerateoutputspecs(0,Mat Output_Data$,Mat Output_Spec$,Mat Output_Help$,Mat Output_S$,Mat Output_Screensubs$,[[Screencontrols]],mat ControlSpec$)
      let Fngenerateinputspecs(0,Mat Input_Data$,Mat Input_Data,Mat Input_Spec$,Mat Input_Subs,Mat Input_Help$,Mat Input_Old$,Mat F$,Mat F,Mat Input_FieldsSSubs$,Mat Input_FieldsNSubs$,Mat Input_S$,Mat Input_Screensubs$,Input_ListViewIndex,[[Screencontrols]],mat ControlSpec$)

      mat Input_Spec$(udim(mat Input_Spec$)-udim(mat Input_Data))

      for Index=1 to udim(mat Output_Help$)
         if trim$(Output_Help$(Index))<>"" then
            let OutputHelp=1
         end if
      next Index
      for Index=1 to udim(mat Input_Help$)
         if trim$(Input_Help$(Index))<>"" then
            let InputHelp=1
         end if
      next Index

      ! Build Header
      let fnGC(" ! "&ScreenName$&" - Copyright "&DATE$("CCYY")&" by Sage AX")
      let fnGC(" ! This program is the "&ScreenName$&" screen auto-generated by ScreenIO")
      let fnGC(" ! ")
      let fnGC(" !  Created: "&DATE$(ScreenIO(si_createdate),"MM/DD/CCYY")&" by "&ScreenIO$(si_createuser))
      let fnGC(" ! Modified: "&DATE$(ScreenIO(si_modifydate),"MM/DD/CCYY")&" by "&Screenio$(si_modifyUser))
      let fnGC(" ! ")
      let fnGC
      let fnGC("    open #0: ""rows="&str$(screenio(si_VSize))&", cols="&str$(screenIO(si_HSize))&""", display, outin")
      let fnGC("    library : fnShow"&ScreenName$)
      let fnGC("    let fnShow"&ScreenName$)
      let fnGC
      let fnGC("    stop")
      let fnGC(" ! ")
      let fnGC
      let fnGC(" def library fnShow"&ScreenName$&"(;Key$,Row,Col,___,Exitmode)")
      let fnGC

      ! Build Variable Declarations
      let fnGC("    ! Declare Variables")
      let fnGC("    dim Form$(1)*255")
      if LayoutName$<>"" then let fnGC("    dim "&LayoutName$&"$(1)*255,"&LayoutName$&"(1)")
      let fnGC

      if Udim(Mat Output_Data$) then
         let fnGC("    dim "&ScreenName$&"_Output_Spec$("&STR$(UDim(Output_Data$))&")*255,"&ScreenName$&"_Output_Data$("&STR$(UDim(Output_Data$))&")*1000",1)
         if OutputHelp then let fnGC(","&ScreenName$&"_Output_Help$("&STR$(UDim(Output_Data$))&")*260",1)
         let fnGC
      end if

      if Udim(Mat Input_Data$) then
         let fnGC("    dim "&ScreenName$&"_Input_Spec$("&STR$(UDim(Input_Data$))&")*255,"&ScreenName$&"_Input_Data$("&STR$(UDim(Input_Data$))&")*1000",1)
         if InputHelp then let fnGC(","&ScreenName$&"_Input_Help$("&STR$(UDim(Input_Data$))&")*260",1)
         let fnGC
      end if

      dim GC_ListSpec$*255,GC_Caption$(1)*255,GC_Width(1),GC_Spec$(1)*255

      ! Listview Variables
      if Udim(mat Input_Data) then
         for Index=1 to udim(mat FieldType$)
            if lwrc$(Trim$(FieldType$(Index)))="listview" then
               let fnGC
               let fnGC("   ! Define Listviews")
               let GC_ListSpec$=fnCalculateListviewHeaders$(mat GC_Caption$,mat GC_Width,mat GC_Spec$,Index,[[ScreenControls]])
               let fnGC("   dim "&ScreenName$&"_"&Parent$(Index)&"_Captions$("&str$(udim(GC_Caption$))&"), "&ScreenName$&"_"&Parent$(Index)&"_Widths("&str$(udim(GC_Caption$))&"), "&ScreenName$&"_"&Parent$(Index)&"_Specs$("&str$(udim(GC_Caption$))&")*255")
               let fnGC("   dim "&ScreenName$&"_"&Parent$(Index)&"_Spec$*255")
               let fnGC
               let fnGC("   read "&ScreenName$&"_"&Parent$(Index)&"_Spec$")
               let fnGC("   data """&GC_Listspec$&"""")
               let fnGC("   read mat "&ScreenName$&"_"&Parent$(Index)&"_Captions$")
               let fnGC("   data ",1)
               for Jndex=1 to udim(mat GC_Caption$)
                  if Jndex=udim(mat GC_caption$) then
                     let fnGC(""""&GC_Caption$(Jndex)&"""")
                  else
                     let fnGC(""""&GC_Caption$(Jndex)&""", ",1)
                  end if
               next Jndex
               let fnGC("   read mat "&ScreenName$&"_"&Parent$(Index)&"_Widths")
               let fnGC("   data ",1)
               for Jndex=1 to udim(mat GC_Width)
                  if Jndex=udim(mat GC_Width) then
                     let fnGC(str$(GC_Width(Jndex)))
                  else
                     let fnGC(str$(GC_Width(Jndex))&", ",1)
                  end if
               next Jndex
               let fnGC("   read mat "&ScreenName$&"_"&Parent$(Index)&"_Specs$")
               let fnGC("   data ",1)
               for Jndex=1 to udim(mat GC_Spec$)
                  if Jndex=udim(mat GC_Spec$) then
                     let fnGC(""""&GC_Spec$(Jndex)&"""")
                  else
                     let fnGC(""""&GC_Spec$(Jndex)&""", ",1)
                  end if
               next Jndex
               mat DisplayListview$(udim(mat DisplayListview$)+1)
               let DisplayListview$(udim(mat DisplayListview$))="    print #"&ScreenName$&"_Window, fields "&ScreenName$&"_"&Parent$(Index)&"_Spec$ : (mat "&ScreenName$&"_"&Parent$(Index)&"_Captions$, mat "&ScreenName$&"_"&Parent$(Index)&"_Widths, mat "&ScreenName$&"_"&Parent$(Index)&"_Specs$)"
            end if
         next Index
      end if

      ! TODO: FrameWindow Variables

      let fnGC

      ! Build Read Statements
      for Index = 1 to UDim(Output_Data$)
         let SpecList$=SpecList$&""""&Output_Spec$(Index)&""""
         let DataList$=DataList$&""""&Output_Data$(Index)&""""
         let HelpList$=HelpList$&""""&Output_Help$(Index)&""""
         if Index < UDim(Output_Data$) then
            if Mod(Index,4)=0 and Index > 1 then
               let SpecList$=SpecList$&CrLf$&"    data "
               let DataList$=DataList$&CrLf$&"    data "
               let HelpList$=HelpList$&CrLf$&"    data "
            else if Mod(Index,2)=0 and Index > 1 then
               let SpecList$=SpecList$&CrLf$&"    data "
               let DataList$=DataList$&","
               let HelpList$=HelpList$&","
            else
               let SpecList$=SpecList$&","
               let DataList$=DataList$&","
               let HelpList$=HelpList$&","
            end if
         end if
      next Index

      ! Add Read Statements for Output Controls
      if Udim(Mat Output_Data$) then
         let fnGC("    ! Read Specs for Output Controls")
         let fnGC("    read mat "&ScreenName$&"_Output_Spec$")
         let fnGC("    data "&SpecList$)
         let fnGC
         let fnGC("    read mat "&ScreenName$&"_Output_Data$")
         let fnGC("    data "&DataList$)
         let fnGC
         if OutputHelp then
            let fnGC("    read mat "&ScreenName$&"_Output_Help$")
            let fnGC("    data "&HelpList$)
            let fnGC
         end if
      end if

      let SpecList$=""
      let HelpList$=""
      for Index = 1 to UDim(Input_Spec$)
         let SpecList$=SpecList$&""""&Input_Spec$(Index)&""""
         let HelpList$=HelpList$&""""&Input_Help$(Index)&""""
         if Index < UDim(Input_Data$) then
            if Mod(Index,4)=0 and Index > 1 then
               let SpecList$=SpecList$&CrLf$&"    data "
               let HelpList$=HelpList$&CrLf$&"    data "
            else if Mod(Index,2)=0 and Index > 1 then
               let SpecList$=SpecList$&CrLf$&"    data "
               let HelpList$=HelpList$&","
            else
               let SpecList$=SpecList$&","
               let HelpList$=HelpList$&","
            end if
         end if
      next Index

      if udim(mat Input_Spec$) then
         ! Read Statements for Input Controls
         let fnGC("    ! Read Specs for Input Controls")
         let fnGC("    read mat "&ScreenName$&"_Input_Spec$")
         let fnGC("    data "&SpecList$)
         let fnGC
         if InputHelp then
            let fnGC("    read mat "&ScreenName$&"_Input_Help$")
            let fnGC("    data "&HelpList$)
            let fnGC
         end if
      end if

      ! Build Code to Read Data File
      if LayoutName$<>"" then
         let fnGC("    ! Open Data File")
         let fnGC("    library """&setting_FileIOPath$&""": Fngetfilenumber, Fnopenfile, Fnuniquekey")
         let fnGC("    let "&LayoutName$&"file=Fnopen("""&LayoutName$&""",mat "&LayoutName$&"$,mat "&LayoutName$&",mat Form$)")

         let fnGC("    ! Read Data File")
         let fnGC
         !   ! Read data file
         !   if len(trim$(key$)) then
         !      Read #FarmFile, using form$(FarmFile), key=key$ : mat Farm$ mat Farm
         !      let fnUnpackFarmFile(mat Farm$,mat Farm,mat Detail_Data$)
         !
         !      ! If there's a read event, call it here
         !      let fnReadFarmEvent
         !   else
         !      ! call init function here
         !      let fnInitFarmEvent
         !   end if
      end if

      let fnGC
      let fnGC("    ! Open Screen")
      let fnGC("    open #("&ScreenName$&"_Window:=Fngetfilenumber): """&fnMakeWindowSpec$(1,1,mat ScreenIO$,mat ScreenIO)&""",display,outin")
      let fnGC

      ! Change this code to handle open statements properly

      ! TODO: Add Code to Open Frames
      !   ! Open any frames here
      !   open #(FrameWindows(1):=fnGetFileNumber) : "row=20,col=20,rows=3,cols=10",display,outin
      !   open #(FrameWindows(2):=fnGetFileNumber) : "row=5,col=60,rows=3,cols=10",display,outin
      !
      !
      !   ! x (Frame windows come from two places -
      !   ! x  1 - Multi-Line Textboxes, Buttons and Captions
      !   ! x  2 - Frame Controls
      !
      !   ! x Open any child screens here by compiling the code for the entire child
      !   ! x  screen following this whole process into a function
      !   ! x  and calling that function from here.
      !   ! x  worry about this later.

      !
      !   execute "config force visibility on"
      !

      if Udim(Mat Output_Data$) then
         if OutputHelp then
            let fnGC("    print #"&ScreenName$&"_Window, fields mat "&ScreenName$&"_Output_Spec$, help mat "&ScreenName$&"_Output_Help$ : mat "&ScreenName$&"_Output_Data$")
         else
            let fnGC("    print #"&ScreenName$&"_Window, fields mat "&ScreenName$&"_Output_Spec$ : mat "&ScreenName$&"_Output_Data$")
         end if
      end if

      for Index=1 to udim(mat DisplayListview$)
         if len(trim$(DisplayListview$(Index))) then
            let fnGC(DisplayListview$(Index))
         end if
      next Index

      !   populate listview here too
      let fnGC("    ! Main input loop here")
      let fnGC("    do")
      if udim(mat Input_Data$) then
         if InputHelp then
            let fnGC("       rinput #"&ScreenName$&"_Window, fields mat "&ScreenName$&"_Input_Spec$, help mat "&ScreenName$&"_Input_Help$ : mat "&ScreenName$&"_Input_Data$")
         else
            let fnGC("       rinput #"&ScreenName$&"_Window, fields mat "&ScreenName$&"_Input_Spec$ : mat "&ScreenName$&"_Input_Data$")
         end if
      else

      end if
      let fnGC("       let Function=fkey")
!
!      let fnGC("       let fnDetail_Process(Function)")
!
      let fnGC("    loop Until ExitMode")

      !
      !   execute "config forcevisibility off"
      !
      !   ! Close Files Here
      !   let fnCloseFile(FarmFile)
      !
      !   ! Close all frames
      !   for Index=1 to udim(mat FrameWindows)
      !      close #FrameWindows(Index):
      !   next Index
      !
      !   for Index=1 to udim(mat ScreenWindows)
      !      close #ScreenWindows:
      !   next Index
      !   close #Detail_Window:
      !
      let fnGC(" fnend")
      let fnGC

      if LayoutName$<>"" then
         let fnGC(" !")
         let fnGC(" ! #Auto"&"number# 99000,10")
         let fnGC(" OPEN: ! ***** Function To Call Library Openfile And Proc Subs")
         let fnGC("    def Fnopen(Filename$*255, Mat F$, Mat F, Mat Form$; Inputonly, Keynum, Dont_Sort_Subs, Path$*255, Mat Descr$, Mat Field_Widths,Supress_Prompt,Ignore_Errors,Suppress_Log,mat DateFmt$,___,Index)")
         let fnGC('       dim _FileIOSubs$(1)*800, _Loadedsubs$(1)*80')
         let fnGC('       let Fnopen=Fnopenfile(Filename$, Mat F$, Mat F, Mat Form$, Inputonly, Keynum, Dont_Sort_Subs, Path$, Mat Descr$, Mat Field_Widths, Mat _FileIOSubs$, Supress_Prompt,Ignore_Errors,Program$,Suppress_Log,mat DateFmt$)')
         let fnGC('       if Srch(_Loadedsubs$,Uprc$(Filename$))<=0 then : mat _Loadedsubs$(Udim(_Loadedsubs$)+1) : let _Loadedsubs$(Udim(_Loadedsubs$))=Uprc$(Filename$) : for Index=1 to Udim(Mat _Fileiosubs$) : execute (_Fileiosubs$(Index)) : next Index')
         let fnGC('    fnend')
      end if

      let fnGC(" !")
      let fnGC(" ! #Auto"&"number# 99500,10")
      let fnGC(" IGNORE: continue")

      let SetEnv("clipboard",GeneratedCode$)
   fnend

   def fnGC(;string$*1024,NoCrLf)
      if NoCrLf then
         let GeneratedCode$=GeneratedCode$&String$
      else
         let GeneratedCode$=GeneratedCode$&String$&Crlf$
      end if
   fnend

!  #AutoNumber# 65000,1
!  =================================================
!  ================= Power Search ==================
!  =================================================
!
!  #Define# [[SearchResults]] = "mat PSLV_Source$,mat PSLV_Path$,mat PSLV_Text$,mat PSLV_Color$,mat PSLV_RefNumber"

   dim PSLV_Spec$
   dim PSLV_Cap$(5)*30,PSLV_Width(5),PSLV_Spec$(5)
   dim PS_CapSpec$(26)*30, PS_Caption$(26)*30, PS_Helptext$(26)*255
   dim PS_Spec$(15)*30, PS_Data$(14)*255, PS_Data(1), PS_DataHelp$(15)*255
   dim PSLV_Source$(1)*30
   dim PSLV_Path$(1)*255
   dim PSLV_Text$(1)*255
   dim PSLV_Color$(1)
   dim PSLV_RefNumber(1)
   dim PSLV_Selected(1)

   dim ScreenIO_SSubs$(1)*255
   dim ScreenIO_NSubs$(1)*255

   dim ScreenFld_SSubs$(1)*255
   dim ScreenFld_NSubs$(1)*255

   def fnSaveIniFile(mat PS_Data$)
      open #(IniFile:=fnGetFileNumber) : "name="&setting_ScreenFolder$&"\powersearch.ini, recl="&str$(udim(mat PS_Data$)*255)&", replace",internal,output
      write #Inifile, using "form "&str$(udim(mat PS_Data$))&"*V 255" : mat PS_Data$
      close #IniFile:
   fnend

   ! Define the Search Screen Here
   dim PS_Initialize

   def fnInitializePowerSearch(&PSLV_Spec$,mat PS_Spec$,mat PS_CapSpec$,mat PS_Data$,mat PS_DataHelp$,mat PS_Caption$,mat PSLV_Cap$,mat PSLV_Width,mat PSLV_Spec$;___,Dummy$,iniFile)
      if ~PS_Initialize then
         ! Read ScreenIO Column Numbers
         let fnReadSubs("screenio",mat ScreenIO_SSubs$,mat ScreenIO_NSubs$,Dummmy$)
         let fnReadSubs("screenfld",mat ScreenFld_SSubs$,mat ScreenFld_Nsubs$,Dummy$)

         execute "config userlevel 0"

         ! Initialize PowerSearch Results Listview
         let PSLV_Spec$="7,3,LIST 20/83"

         ! Initialize PowerSearch Results Listview Columns
         let PSLV_Cap$(1)="Source"
         let PSLV_Width(1)=9
         let PSLV_Spec$(1)="C 30"

         let PSLV_Cap$(2)="Path"
         let PSLV_Width(2)=25
         let PSLV_Spec$(2)="C 255"

         let PSLV_Cap$(3)="Text"
         let PSLV_Width(3)=80
         let PSLV_Spec$(3)="C 255"

         let PSLV_Cap$(4)="Color"
         let PSLV_Width(4)=0
         let PSLV_Spec$(4)="C 15"

         let PSLV_Cap$(5)="Ref"
         let PSLV_Width(5)=0
         let PSLV_Spec$(5)="N 20"

         mat PSLV_Source$(0)
         mat PSLV_Path$(0)
         mat PSLV_Text$(0)
         mat PSLV_Color$(0)
         mat PSLV_RefNumber(0)

         mat PSLV_Selected(0)

         ! Initialize PowerSearch Subscripts
         let _ps_SearchText=1
         let _ps_Folder=2
         let _ps_IncludeSubs=3
         let _ps_Mask=4
         let _ps_SearchAllExt=5
         let _ps_UseAltExt=6
         let _ps_AltExt=7
         let _ps_AltExtObject=8
         let _ps_AltExtSource=9
         let _ps_Screen=10
         let _ps_Layout=11
         let _ps_Function=12
         let _ps_Path=13
         let _ps_HelperLib=14
         let _ps_SearchResults=15

         ! Initialize PowerSearch Input Specs
         let PS_Spec$(_ps_SearchText)="5,24,42/SEARCH 255,/W:W,7,3"
         let PS_Spec$(_ps_Folder)="4,24,15/V 255,/W:W"
         let PS_Spec$(_ps_IncludeSubs)="4,40,12/CHECK 18"
         let PS_Spec$(_ps_mask)="4,59,7/V 80,/W:W"

         let PS_Spec$(_ps_SearchAllExt)="3,24,12/CHECK 18"
         let PS_Spec$(_ps_UseAltExt)="3,40,6/CHECK 25"
         let PS_Spec$(_ps_AltExt)="3,47,CU 3,/W:W"
         let PS_Spec$(_ps_AltExtObject)="3,51,7/RADIO 25,1"
         let PS_Spec$(_ps_AltExtSource)="3,59,7/RADIO 25,1"

         let PS_Spec$(_ps_Screen)="1,4,13/CHECK 25"
         let PS_Spec$(_ps_Layout)="2,4,13/CHECK 25"
         let PS_Spec$(_ps_Function)="3,4,13/CHECK 25"
         let PS_Spec$(_ps_Path)="4,4,13/CHECK 25"
         let PS_Spec$(_ps_HelperLib)="5,4,13/CHECK 25"

         let PS_Spec$(_ps_SearchResults)=PSLV_Spec$&",ROWCNT,SEL"

         let PS_DataHelp$(_ps_SearchText)="3;Enter the text to search for.;"
         let PS_DataHelp$(_ps_Folder)="3;Enter an alternate path to search. Use the BR "":"" operator to specify an absolute path. When using an absolute path, we are limited to a Text Only Search. If you want to search inside BR Object Files, you must specify a relative path.;"
         let PS_DataHelp$(_ps_IncludeSubs)="3;Search in Subdirectories. May take a while. Modify dirlist.sch to filter the search directories.;"
         let PS_DataHelp$(_ps_mask)="3;This is the mask. Do not enter anything other then letters and the traditional * and ? mask operators. Do not enter a file extension or a path in this field.;"
         let PS_DataHelp$(_ps_SearchAllExt)="3;Search all other files of all extensions. The program will test each file to if it is an ASCII file, and it will only search them if they are ascii files.;"
         let PS_DataHelp$(_ps_UseAltExt)="3;Search inside the specified folder for files of this alternate extension.;"
         let PS_DataHelp$(_ps_AltExt)="3;Alternate Extension to Search\nEnter extension only (LIB and not *.LIB);"
         let PS_DataHelp$(_ps_AltExtObject)="3;Treat Alternate Extension files as BR Program Files;"
         let PS_DataHelp$(_ps_AltExtSource)="3;Treat Alternate Extension files as Text Files;"
         let PS_DataHelp$(_ps_Screen)="3;Search the Screen Files;"
         let PS_DataHelp$(_ps_Layout)="3;Search the File Layouts;"
         let PS_DataHelp$(_ps_Function)="3;Search the Screen Functions;"
         let PS_DataHelp$(_ps_Path)="3;Search the specified folder for .brs, .wbs, .br and .wb files.;"
         let PS_DataHelp$(_ps_HelperLib)="3;Search your compiled Screen Helper Functions. You shouldn't really be searching for these. Search your ScreenIO Screen Functions instead.;"
         let PS_DataHelp$(_ps_SearchResults)="3;;"

         ! Initialize PowerSearch Input Data
         if exists(""&setting_ScreenFolder$&"\powersearch.ini") then
            open #(IniFile:=fnGetFileNumber) : "name="&setting_ScreenFolder$&"\powersearch.ini",internal,input,sequential
            read #IniFile, using "form "&str$(udim(mat PS_Data$))&"*V 255" : mat PS_Data$ error ignore
            if file(IniFile)<>0 then
               Close #IniFile:
               goto UseDefaults
            end if
            close #IniFile:
         else
            UseDefaults: ! use default settings, read failed.
            let PS_Data$(_ps_Folder)="."
            let PS_Data$(_ps_IncludeSubs)="^Incl Subfolders"
            let PS_Data$(_ps_Mask)="*"
            let PS_Data$(_ps_SearchAllExt)="Search All Exts"
            let PS_Data$(_ps_Screen)="^Screen Files"
            let PS_Data$(_ps_Layout)="^File Layouts"
            let PS_Data$(_ps_Function)="^Screen Functions"
            let PS_Data$(_ps_Path)="^Folder"
            let PS_Data$(_ps_HelperLib)="Compiled Screens"
            let PS_Data$(_ps_UseAltExt)="Alt Ext: "
            let PS_Data$(_ps_AltExt)="LIB"
            let PS_Data$(_ps_AltExtObject)="^BR File"
            let PS_Data$(_ps_AltExtSource)="Text File"
         end if

         ! Initialize PowerSearch Buttons and Caption Specs
         let PS_CapSpec$(1)="1,30,CC 26"    ! Power Search
         let PS_CapSpec$(2)="5,17,6/CR 8"    ! Search:
         let PS_CapSpec$(3)="4,17,6/CR 8"    ! Folder:
         let PS_CapSpec$(4)="5,67,CC 9,/W:W,B35"  ! Search
         let PS_CapSpec$(5)="5,77,9/CC 9,/W:W,B34"  ! Clear All
         let PS_CapSpec$(6)="28,3,10/CC 17,/W:W,B36"   ! Launch Item
         let PS_CapSpec$(7)="28,14,17/CC 26,/W:W,B37" ! Affected Screen List

         let PS_CapSpec$(8)="28,68,8/CC 11,/W:W,B38" ! Export List
         let PS_CapSpec$(9)="28,77,CC 8,/W:W,B39" ! Print List

         let PS_CapSpec$(10)="28,37,8/CC 14,/W:W,B40" ! Load Results
         let PS_CapSpec$(11)="28,46,8/CC 12,/W:W,B41" ! Save Results
         let PS_CapSpec$(12)="28,55,8/CC 11,/W:W,B42" ! Save As...

         LET PS_CapSpec$(13)="3,67,CC 1,/#000000:#00FF00,B43" ! Mark Green
         LET PS_CapSpec$(14)="3,69,CC 1,/#000000:#FFFF00,B51" ! Mark Yellow
         LET PS_CapSpec$(15)="3,71,CC 1,/#000000:#FF0000,B53" ! Mark Red
         LET PS_CapSpec$(16)="3,73,CC 1,/#000000:#0000FF,B54" ! Mark Blue
         LET PS_CapSpec$(17)="3,75,CC 1,/#000000:#FFFFFF,B45" ! Mark White
!
         LET PS_CapSpec$(18)="3,77,CC 1,/#FFFFFF:#008000,B46" ! Clear Green
         LET PS_CapSpec$(19)="3,79,CC 1,/#FFFFFF:#808000,B47" ! Clear Yellow
         LET PS_CapSpec$(20)="3,81,CC 1,/#FFFFFF:#800000,B55" ! Clear Red
         LET PS_CapSpec$(21)="3,83,CC 1,/#FFFFFF:#000080,B56" ! Clear Blue
         LET PS_CapSpec$(22)="3,85,CC 1,/#000000:#FFFFFF,B48" ! Clear White

         let PS_CapSpec$(23)="4,77,9/CC 7,/W:W,B49" ! Clear Item
         let PS_CapSpec$(24)="4,67,9/CC 11,/W:W,B50" ! Sort Colors

         let PS_CapSpec$(25)="4,54,4/CR 6" ! Mask:
         let PS_CapSpec$(26)="2,69,14/CC 15,/W:W,B52" ! Save Ini

         ! Initialize PowerSearch Buttons and Captions
         let PS_Caption$(1)="Power Search"
         let PS_Caption$(2)="Search: "
         let PS_Caption$(3)="Folder: "
         let PS_Caption$(4)="Search"
         let PS_Caption$(5)="Clear All"
         let PS_Caption$(6)="Launch"
         let PS_Caption$(7)="Affected Screens"
         let PS_Caption$(8)="Export"
         let PS_Caption$(9)="Print"
         let PS_Caption$(10)="Load.."
         let PS_Caption$(11)="Save"
         let PS_Caption$(12)="Save As.."
         let PS_Caption$(13)=" " ! Mark Green
         let PS_Caption$(14)=" " ! Mark Yellow
         let PS_Caption$(15)=" " ! Mark Red
         let PS_Caption$(16)=" " ! Mark Blue
         let PS_Caption$(17)=" " ! Mark White
         let PS_Caption$(18)="x" ! Clear Green
         let PS_Caption$(19)="x" ! Clear Yellow
         let PS_Caption$(20)="x" ! Clear Red
         let PS_Caption$(21)="x" ! Clear Blue
         let PS_Caption$(22)="x" ! Clear White
         let PS_Caption$(23)="Clear"
         let PS_Caption$(24)="Sort Colors"
         let PS_Caption$(25)="Mask: "
         let PS_Caption$(26)="Set Defaults"

         mat PS_HelpText$(1:3)=("3;;")
         let PS_HelpText$(4)="3;Search. Search without clearing to add to the previous results.;"
         let PS_HelpText$(5)="3;Clear the list to preform a new search.;"
         let PS_HelpText$(6)="3;Launches the selected items. If the item is a file, launch it in your BR Code Editor of choice. If its a screen, Load it in the background.;"
         let PS_HelpText$(7)="3;Opens a window showing all the screens that use the currently selected items.;"
         let PS_HelpText$(8)="3;Exports the Search Results to a Text File.;"
         let PS_HelpText$(9)="3;Prints the Search Results to the Printer.;"
         let PS_HelpText$(10)="3;Loads a previously saved Search Results file so you can work with it.;"
         let PS_HelpText$(11)="3;Saves the Results to an internal file so you can work with them later.;"
         let PS_HelpText$(12)="3;Saves the Results to an internal file so you can work with them later.;"
         let PS_HelpText$(13)="3;Mark these lines Green.;"
         let PS_HelpText$(14)="3;Mark these lines Yellow.;"
         let PS_HelpText$(15)="3;Mark these lines Red.;"
         let PS_HelpText$(16)="3;Mark these lines Blue.;"
         let PS_HelpText$(17)="3;Mark these lines White.;"
         let PS_HelpText$(18)="3;Clear all Green Items.;"
         let PS_HelpText$(19)="3;Clear all Yellow Items.;"
         let PS_HelpText$(20)="3;Clear all Red Items.;"
         let PS_HelpText$(21)="3;Clear all Blue Items.;"
         let PS_HelpText$(22)="3;Clear all White Items.;"
         let PS_HelpText$(23)="3;Clear Selected Items.;"
         let PS_HelpText$(24)="3;Sort the list based on color.;"
         let PS_HelpText$(25)="3;;"
         let PS_HelpText$(26)="3;Save the Search Settings to be used as defaults later.;"

         let PS_Initialize=1
      end if
   fnend

   def fnPowerSearch(;___,Function,PowerSearch,RowCount)

      ! Open the child window
      Open #(PowerSearch:=fnGetFileNumber): "srow=4,scol=10,rows=29,cols=87,Border=s", display, outin

      let fnInitializePowerSearch(PSLV_Spec$,mat PS_Spec$,mat PS_CapSpec$,mat PS_Data$,mat PS_DataHelp$,mat PS_Caption$,mat PSLV_Cap$,mat PSLV_Width,mat PSLV_Spec$)

      print #PowerSearch, fields mat PS_CapSpec$, help mat PS_HelpText$ : mat PS_Caption$
      print #PowerSearch, fields PSLV_Spec$&",HEADERS,/W:W" : (mat PSLV_Cap$, mat PSLV_Width, mat PSLV_Spec$)

      ! Predraw listview if any data belongs in it
      let fnUpdateResults(PSLV_Spec$,[[SearchResults]])
      do
         print #PowerSearch, fields mat PS_Spec$(1:udim(mat PS_Spec$)-1) : mat PS_Data$
         if udim(mat PSLV_Source$) then
            input #PowerSearch, fields mat PS_Spec$, help mat PS_DataHelp$ : mat PS_Data$,RowCount
            mat PSLV_Selected(RowCount)
            input #PowerSearch, fields PSLV_Spec$&",ROWSUB,SEL,NOWAIT" : mat PSLV_Selected
         else
            input #PowerSearch, fields mat PS_Spec$(1:udim(mat PS_Spec$)-1), help mat PS_DataHelp$ : mat PS_Data$
         end if

         let Function=fkey

         #Select# Function #Case# 34
            ! Clear List
            let fnClearResults([[SearchResults]])
            let fnUpdateResults(PSLV_Spec$,[[SearchResults]])

         #Case# 35
            ! Search
            let fnSearch(mat PS_Data$,[[SearchResults]])
            let fnUpdateResults(PSLV_Spec$,[[SearchResults]])

         #Case# 0
            if udim(mat PSLV_Source$)=0 then
               let fnSearch(mat PS_Data$,[[SearchResults]])
               let fnUpdateResults(PSLV_Spec$,[[SearchResults]])
            end if

         #Case# 36
            ! Jump To Item
            let fnJumpTo(mat PSLV_Selected,[[SearchResults]])

         #Case# 37
            ! Affected Screen List
            let fnAffectedScreenList(mat PSLV_Selected,[[SearchResults]])

         #Case# 38
            ! Export
            let fnPrintListToFile([[SearchResults]])
         #Case# 39
            ! Print
            let fnPrintListToPrinter([[SearchResults]])

         #Case# 40
            ! Load
            let fnLoadResultsFile([[SearchResults]])
            let fnUpdateResults(PSLV_Spec$,[[SearchResults]])
         #Case# 41
            ! Save
            let fnSaveResultsFile([[SearchResults]])
         #Case# 42
            ! Save As..
            let fnSaveResultsFileAs([[SearchResults]])

         #Case# 43
            ! Mark Green
            let fnMarkSelection("#00FF00",mat PSLV_Selected,[[SearchResults]])
            let fnUpdateResults(PSLV_Spec$,[[SearchResults]],1)
         #Case# 51
            ! Mark Yellow
            let fnMarkSelection("#FFFF00",mat PSLV_Selected,[[SearchResults]])
            let fnUpdateResults(PSLV_Spec$,[[SearchResults]],1)
         #Case# 53
            ! Mark Red
            let fnMarkSelection("#FF0000",mat PSLV_Selected,[[SearchResults]])
            let fnUpdateResults(PSLV_Spec$,[[SearchResults]],1)
         #Case# 54
            ! Mark Blue
            let fnMarkSelection("#0050FF",mat PSLV_Selected,[[SearchResults]])
            let fnUpdateResults(PSLV_Spec$,[[SearchResults]],1)
         #Case# 45
            ! Mark White
            let fnMarkSelection("#FFFFFF",mat PSLV_Selected,[[SearchResults]])
            let fnUpdateResults(PSLV_Spec$,[[SearchResults]],1)
         #Case# 46
            ! Clear Green
            let fnClearSelection("#00FF00",[[SearchResults]])
            let fnUpdateResults(PSLV_Spec$,[[SearchResults]])
         #Case# 47
            ! Clear Yellow
            let fnClearSelection("#FFFF00",[[SearchResults]])
            let fnUpdateResults(PSLV_Spec$,[[SearchResults]])
         #Case# 55
            ! Clear Red
            let fnClearSelection("#FF0000",[[SearchResults]])
            let fnUpdateResults(PSLV_Spec$,[[SearchResults]])
         #Case# 56
            ! Clear Blue
            let fnClearSelection("#0050FF",[[SearchResults]])
            let fnUpdateResults(PSLV_Spec$,[[SearchResults]])
         #Case# 48
            ! Clear White
            let fnClearSelection("#FFFFFF",[[SearchResults]])
            let fnUpdateResults(PSLV_Spec$,[[SearchResults]])
         #Case# 49
            ! Clear Item
            let fnClearItem(mat PSLV_Selected,[[SearchResults]])
            let fnUpdateResults(PSLV_Spec$,[[SearchResults]])
         #Case# 50
            ! Sort Colors
            let fnUpdateResults(PSLV_Spec$,[[SearchResults]])
            print #PowerSearch, fields PSLV_Spec$&",SORT" : 4

         #Case# 52
            let fnsaveInifile(mat PS_Data$)

         #End Select#

      loop Until Function=99 Or Function=93 Or fkey=93

      close #Powersearch:
   fnend

   dim pslv_start(1)
   dim pslv_end(1)
   dim pslv_attr$(1)
   dim pslv_outcolor$(1)

   def fnUpdateResults(ListSpec$*30,[[SearchResults]];ColorOnly,___,Index,Bold,LastSource$*30,LastPath$*255)
      if ~ColorOnly then
         print #PowerSearch, fields ListSpec$&",=" : ([[SearchResults]])
      end if

      mat pslv_start(0) : mat pslv_end(0) : mat pslv_attr$(0) : let lastindex=0
      mat pslv_outcolor$(udim(mat pslv_color$))=pslv_color$

      for Index=1 to udim(mat pslv_color$)
         ! Alternate bold and not bold every time source changes.
         if LastSource$<>pslv_Source$(Index) or LastPath$<>fnComparePath$(pslv_source$(Index),pslv_Path$(Index)) then
            let LastSource$=pslv_Source$(Index)
            let LastPath$=fnComparePath$(pslv_source$(Index),pslv_Path$(Index))
            let Bold=~Bold
         end if

         ! Specify the color from color$
         if Bold then
            let pslv_OutColor$(Index)="/#000000:"&pslv_Color$(Index)
         else
            let pslv_OutColor$(Index)="/#000000:"&srep$(pslv_Color$(Index),"FF","E0")
         end if
      next Index

      ! Borrow the SetColors function from ScreenIO
      let fnSetColors(mat pslv_outcolor$,mat pslv_start,mat pslv_end,mat pslv_attr$)

      print #PowerSearch, fields ListSpec$&",attr" : (mat pslv_start,mat pslv_end,mat pslv_attr$)

      print #PowerSearch, fields "27,3,C 30" : str$(udim(mat pslv_source$))&" results found..."
   fnend

   def fnComparePath$*255(Source$*30,Path$*255)
      if lwrc$(Source$)="screen" then
         let fnComparePath$=Path$(1:pos(Path$,"\"))
      else
         let fnComparePath$=Path$
      end if
   fnend

   def fnMarkSelection(Color$,mat Selected,[[SearchResults]];___,Index)
      for Index=1 to udim(mat Selected)
         let PSLV_Color$(Selected(Index))=Color$
      next Index
   fnend
   def fnClearSelection(Color$,[[SearchResults]];___,Index)
      if (2==msgbox("This will remove any "&fnColorName$(Color$)&" items from the list. Are you sure?","Delete All"&fnColorName$(Color$),"yN","QST")) then
         let Index=0
         do while Index<udim(mat PSLV_Color$)
            let Index+=1
            if PSLV_Color$(Index)=Color$ then
               ! Remove Entry from List
               let fnRemoveItem(Index,[[SearchResults]])
               let Index-=1
            end if
         loop
      end if
      mat PSLV_Selected(0)
   fnend
   def fnClearItem(mat Selected,[[SearchResults]];___,Index,Jndex)
      if (2==msgbox("This will remove all the currently selected items from the list. Are you sure?","Delete Current Selection","yN","QST")) then
         for Index=1 to udim(mat Selected)
            ! Remove Selected(Index) from list
            let fnRemoveItem(Selected(Index),[[SearchResults]])
            for Jndex=Index+1 to udim(mat Selected)
               let Selected(Jndex)-=1
            next Jndex
         next Index
      end if
      mat Selected(0)
   fnend

   dim AlreadyDone$(1)*255
   ! Jump To Item
   def fnJumpTo(mat Selected,[[SearchResults]];___,Index,DoneAScreen,DoneAHelperLib,Screen$,FirstSlashPos)
      mat AlreadyDone$(0)
      for Index=1 to udim(mat Selected)
         if lwrc$(trim$(pslv_source$(Selected(Index))))="screen" then
            let Screen$=PSLV_Path$(Selected(Index))(1:(FirstSlashPos:=pos(PSLV_Path$(Selected(Index)),"\"))-1)
            let fnLaunchScreen(trim$(Screen$))

            !if ~DoneAScreen then
            !   ! if this item is a screen, load the screen, redraw it, then come back here.
            !   if Fnoktoproceed(Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
            !      let Screen$=PSLV_Path$(Selected(Index))(1:(FirstSlashPos:=pos(PSLV_Path$(Selected(Index)),"\"))-1)
            !      if Trim$(Screen$)<>"" then
            !         if Fnreadscreen(Screen$,Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
            !            let fnRedrawScreen(mat ScreenIO$,mat ScreenIO,[[ScreenControls]])
            !
            !            if pos(PSLV_Path$(Selected(Index)),"\",FirstSlashPos+1) then ! Its from screenflds
            !               let Mode=Inputeditormode
            !               let Control=PSLV_RefNumber(Selected(Index))
            !            else ! its from ScreenIO
            !               if pos(lwrc$(PSLV_Path$(Selected(Index))),"fn$") then
            !                  let Mode=SelectEventsMode
            !               else
            !                  let Mode=InputAttributesMode
            !                  let Control=PSLV_RefNumber(Selected(Index))
            !               end if
            !            end if
            !            let DoneAScreen=1
            !         else
            !            let Msgbox("Error Reading Screen - Screen not  found","Error","OK","ERR")
            !         end if
            !      end if
            !   end if
            !end if
         else if lwrc$(trim$(pslv_source$(Selected(Index))))="helper library" then
            if ~DoneAHelperLib then
               let msgbox("Don't Edit your Compiled Helper Libraries. Instead, edit the functions they're built from.","Warning","Ok","EXCL")
               let DoneAHelperLib=1
            end if
         else if lwrc$(trim$(pslv_source$(Selected(Index))))="layout" and ~pos(pslv_path$(Selected(Index)),".") then
            ! if this item is a function, launch it in editor
            if srch(mat AlreadyDone$,lwrc$(trim$(pslv_path$(selected(index)))))<1 then
            ! Launch it in notepad
               sleep(.1)
               execute "system -C -M start notepad "&os_filename$(trim$(pslv_path$(Selected(index)))) error Ignore

               mat AlreadyDone$(udim(mat alreadyDone$)+1)
               let AlreadyDone$(udim(mat AlreadyDone$))=lwrc$(trim$(pslv_path$(selected(index))))
            end if
         else
            ! if this item is a function, launch it in editor
            if srch(mat AlreadyDone$,lwrc$(trim$(pslv_path$(selected(index)))))<1 then
               sleep(.1)
               ! if its a .BR file then
               if ".br"=trim$(lwrc$(pslv_path$(selected(index)))(pos(pslv_path$(selected(index)),".",-1):len(pslv_path$(selected(index))))) or ".wb"=trim$(lwrc$(pslv_path$(selected(index)))(pos(pslv_path$(selected(index)),".",-1):len(pslv_path$(selected(index))))) then
                  ! Launch it in BR
                  execute "system -C -M "&Fngetbrexe$&" -"&Fngetwbcfg$&" load "&trim$(pslv_path$(selected(index)))
               else if lwrc$("."&ps_data$(_ps_altext))=trim$(lwrc$(pslv_path$(selected(index)))(pos(pslv_path$(selected(index)),".",-1):len(pslv_path$(selected(index))))) and ps_data$(_ps_altextobject)(1:1)="^" then
                  ! Its a BR file with the alt ext
                  execute "system -C -M "&Fngetbrexe$&" -"&Fngetwbcfg$&" load "&trim$(pslv_path$(selected(index)))
               else
                  ! Launch it in default editor
                  execute "system -C -M start "&os_filename$(trim$(pslv_path$(Selected(index)))) error Ignore
               end if

               mat AlreadyDone$(udim(mat alreadyDone$)+1)
               let AlreadyDone$(udim(mat AlreadyDone$))=lwrc$(trim$(pslv_path$(selected(index))))
            end if
         end if
      next Index
   fnend

   def fnRedrawScreen(mat ScreenIO$,mat ScreenIO,[[ScreenControls]];NotPowerSearch)
      if ~(Fnsameas(Mat Displayref_Screenio$,Mat Screenio$) And Fnsamea(Mat Displayref_Screenio,Mat Screenio)) then

         Close #PowerSearch:
         let Fnredrawentirescreen(Wtoolbar,Wdebug,Weditor,Mat Screenio$, Mat Screenio, [[Screencontrols]])
!
         mat Displayref_Screenio$=Screenio$
         mat Displayref_Screenio=Screenio
!
         let Fnrepopulatefieldslistview(Screenio$(Si_Filelay))
         let Displayref_Screenio$(Si_Filelay)=Screenio$(Si_Filelay)

         if ~NotPowerSearch then
            ! Open the child window
            Open #(PowerSearch:=fnGetFileNumber): "srow=4,scol=10,rows=29,cols=87,Border=s", display, outin

            let fnInitializePowerSearch(PSLV_Spec$,mat PS_Spec$,mat PS_CapSpec$,mat PS_Data$,mat PS_DataHelp$,mat PS_Caption$,mat PSLV_Cap$,mat PSLV_Width,mat PSLV_Spec$)

            print #PowerSearch, fields mat PS_CapSpec$, help mat PS_HelpText$ : mat PS_Caption$
            print #PowerSearch, fields PSLV_Spec$&",HEADERS,/W:W" : (mat PSLV_Cap$, mat PSLV_Width, mat PSLV_Spec$)

            ! Predraw listview if any data belongs in it
            let fnUpdateResults(PSLV_Spec$,[[SearchResults]])
         end if
      end if
      let fnRenderScreen(mat ScreenIO$,mat ScreenIO,[[ScreenControls]])
   fnend

   dim AffectedScreens$(1)
   dim AS_Caption$(1)
   dim AS_Width(1)
   dim AS_Spec$(1)

   dim AF_Selection(1)

   def fnAffectedScreenList(mat Selected,[[SearchResults]];___,Index,Window,AFSelCount,function,SaveScreenCode$,FileName$*255)

      ! Build list of affected screens
      mat AffectedScreens$(0)
      let fnFindAffectedScreens(mat AffectedScreens$,mat Selected,[[SearchResults]])

      if udim(mat AffectedScreens$)=0 then
         let msgbox("No screens are affected.","Nothing Found")
      else
         ! Define Listview
         let AS_Caption$(1)="Affected Screens"
         let AS_Width(1)=30
         let AS_Spec$(1)="CC 18"

         ! Open Window
         open #(Window:=fnGetFileNumber) : "srow=5,scol=30,rows=15,cols=30,border=s",display,outin

         ! Paint Window
         print #Window, fields "1,1,LIST 14/30,HEADERS,/W:W" : (mat AS_Caption$,mat AS_Width,mat AS_Spec$)
         print #Window, fields "1,1,LIST 14/30,=" : (mat AffectedScreens$)
         print #Window, fields "15,1,14/CC 16,/W:W,B30;15,16,CC 14,/W:W,B31" : "Recompile Screen","Load Screen"

         do
            input #Window, fields "1,1,LIST 14/30,ROWCNT,SEL" : AFSelCount
            let Function=fkey
            mat Af_Selection(AfSelCount)
            input #Window, fields "1,1,LIST 14/30,ROWSUB,SEL,NOWAIT" : mat AF_Selection

            if function=30 then ! Recompile Selected Screens
               let Savescreencode$=Static_Screenname$

               if exists("compile[SESSION].$$$") then
                  execute "free compile[SESSION].$$$"
               end if

               let FailedList$=""
               for Index=1 to udim(mat af_selection)
                  if Fnreadscreen(AffectedScreens$(Af_Selection(Index)),Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
                     let Fncompilehelperlibrary(Mat Screenio$,Mat Screenio,[[Screencontrols]],FileName$)
                     let fnWaitForFile(FailedList$,AffectedScreens$(Af_Selection(Index)),FileName$)
                  end if
               next Index

               if len(FailedList$) then
                  let Msgbox("The following screens took a long time and may have had errors:"&chr$(13)&chr$(13)&FailedList$(3:9999))
               end if

               let Fnreadscreen(Savescreencode$,Mat Screenio$,Mat Screenio,[[Screencontrols]])
            end if

            if function=31 then ! Load Screen
               let FnLaunchScreen(Trim$(AffectedScreens$(AF_Selection(1))))

            !   if Fnoktoproceed(Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
            !      if Fnreadscreen(AffectedScreens$(AF_Selection(1)),Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
            !         let fnRedrawScreen(mat ScreenIO$,mat ScreenIO,[[ScreenControls]])

            !         ! Repaint Window
            !         open #(Window:=fnGetFileNumber) : "srow=5,scol=30,rows=15,cols=30,border=s",display,outin
            !         print #Window, fields "1,1,LIST 14/30,HEADERS" : (mat AS_Caption$,mat AS_Width,mat AS_Spec$)
            !         print #Window, fields "1,1,LIST 14/30,=" : (mat AffectedScreens$)
            !         print #Window, fields "15,1,14/CC 16,/W:W,B30;15,16,CC 14,/W:W,B31" : "Recompile Screen","Load Screen"

            !      else
            !         let Msgbox("Error Reading Screen - Screen not  found","Error","OK","ERR")
            !      end if
            !   end if
            end if

         loop until function=99 or function=93 or fkey=93
         Close #Window:
      end if
   fnend

   def fnFindAffectedScreens(mat AffectedScreens$,mat Selected,[[SearchResults]];___,Function$*255,Index,Jndex)
      for Index=1 to udim(mat Selected)
         #Select# lwrc$(trim$(PSLV_Source$(Selected(Index)))) #Case# "screen"
            ! if its a screen, throw it on the list
            let fnAddAFScreen(PSLV_Path$(Selected(Index))(1:pos(PSLV_Path$(Selected(Index)),"\")-1),mat AffectedScreens$)

         #Case# "function"
            ! If its a function, search for it in all the screens
            let Function$=fnFunctionString$(pslv_Path$(Selected(Index)))

            mat SearchScreenIO$(udim(mat ScreenIO$))
            mat SearchScreenIO(udim(mat ScreenIO))
            mat SearchScreenFld$(udim(mat ScreenFld$))
            mat SearchScreenFld(udim(mat ScreenFld))

            restore #FScreenIO:
            restore #FScreenFld:

            do until file(FScreenIO)
               read #FScreenIO, using form$(FScreenIO), release : mat SearchScreenIO$, mat SearchScreenIO eof Ignore
               if file(fScreenIO)=0 then
                  for Jndex=si_enterfn to si_exitfn
                     if lwrc$(trim$(SearchScreenIO$(Jndex)))=lwrc$(trim$(Function$)) then
                        let fnAddAFScreen(SearchScreenIO$(si_Screencode),mat AffectedScreens$)
                     end if
                  next Jndex
               end if
            loop
            do until file(FScreenFld)
               read #FScreenFld, using form$(FScreenFld), release : mat SearchScreenFld$, mat SearchScreenFld eof Ignore
               if file(FScreenFld)=0 then
                  if lwrc$(trim$(SearchScreenFld$(sf_function)))=lwrc$(trim$(Function$)) then
                     let fnAddAfScreen(SearchScreenFld$(sf_ScreenCode),mat affectedScreens$)
                  end if
                  if lwrc$(trim$(SearchScreenFld$(sf_cnvrtin)))=lwrc$(trim$(Function$)) then
                     let fnAddAfScreen(SearchScreenFld$(sf_ScreenCode),mat affectedScreens$)
                  end if
                  if lwrc$(trim$(SearchScreenFld$(sf_cnvrtout)))=lwrc$(trim$(Function$)) then
                     let fnAddAfScreen(SearchScreenFld$(sf_ScreenCode),mat affectedScreens$)
                  end if
               end if
            loop

         #Case# "helper library"
            ! if its a helper lib throw the screen on the list
            let fnAddAFScreen(PSLV_Path$(Selected(Index))(pos(PSLV_Path$(Selected(Index)),"\",-1)+1:pos(PSLV_Path$(Selected(Index)),".",-1)-1),mat AffectedScreens$)

         #Case# "layout"
            ! If its a file layout Search ScreenIO, add all screens that have a match in ScreenIO(si_filelay)
            let Function$=PSLV_Path$(Selected(Index))(pos(PSLV_Path$(Selected(Index)),"\",-1)+1:len(pslv_path$(Selected(Index))))

            mat SearchScreenIO$(udim(mat ScreenIO$))
            mat SearchScreenIO(udim(mat ScreenIO))

            restore #FScreenIO:
            restore #FScreenFld:

            do until file(FScreenIO)
               read #FScreenIO, using form$(FScreenIO), release : mat SearchScreenIO$, mat SearchScreenIO eof Ignore
               if file(fScreenIO)=0 then
                  if lwrc$(trim$(SearchScreenIO$(si_filelay)))=lwrc$(trim$(Function$)) then
                     let fnAddAFScreen(SearchScreenIO$(si_Screencode),mat AffectedScreens$)
                  end if
               end if
            loop

         #End Select#
      next Index
   fnend

   def fnAddAFScreen(Screen$,mat Screens$)
      if srch(mat Screens$,lwrc$(trim$(Screen$)))<1 then
         mat Screens$(udim(mat Screens$)+1)
         let Screens$(udim(mat Screens$))=lwrc$(trim$(Screen$))
      end if
   fnend

   def fnLoadResultsFile([[SearchResults]])
      ! Browse for a file
      Open #(filenumber:=fnGetFileNumber): "name=open:.\*.res", internal, input, sequential error Ignore
      if FileNumber and file(FileNumber)>-1 then
         let fnLoadResults(FileNumber,[[SearchResults]])
         let ResultsFileName$=file$(filenumber)
         close #filenumber:
      end if
   fnend
   def fnSaveResultsFile([[SearchResults]];___,FileNumber)
      if trim$(ResultsFilename$)="" then
         let fnSaveResultsFileAs([[SearchResults]])
      else
         Open #(FileNumber:=fnGetFileNumber): "name="&ResultsFileName$&", recl=1024, replace", internal, output, sequential
         if FileNumber and file(FileNumber)>-1 then
            let fnSaveResults(FileNumber,[[SearchResults]])
            Close #FileNumber:
         end if
      end if
   fnend
   dim ResultsFileName$*255
   def fnSaveResultsFileAs([[SearchResults]];___,FileNumber)
      ! Browse for a file
      Open #(filenumber:=fnGetFileNumber): "name=save:.\*.res, recl=1024,replace", internal, output, sequential error Ignore
      if FileNumber and file(FileNumber)>-1 then
         let fnSaveResults(FileNumber,[[SearchResults]])
         let ResultsFileName$=file$(filenumber)
         close #filenumber:
      end if
   fnend
   def fnSaveResults(FileNumber,[[SearchResults]];___,Index)
      Write #FileNumber, using "form BH 3" : udim(mat PSLV_Source$)
      for Index=1 to udim(mat pslv_Source$)
         Write #FileNumber, using "form V 30,V 255,V 255,V 15,N 20" : PSLV_Source$(Index),PSLV_Path$(Index),PSLV_Text$(Index),PSLV_Color$(Index),PSLV_RefNumber(Index)
      next Index
   fnend
   def fnLoadResults(FileNumber,[[SearchResults]];___,Count,Index)
      Read #FileNumber, using "form BH 3" : Count
      mat PSLV_Source$(Count)
      mat PSLV_Path$(Count)
      mat PSLV_Text$(Count)
      mat PSLV_Color$(Count)
      mat PSLV_RefNumber(Count)
      for Index=1 to Count
         Read #FileNumber, using "form V 30,V 255,V 255,V 15,N 20" : PSLV_Source$(Index),PSLV_Path$(Index),PSLV_Text$(Index),PSLV_Color$(Index),PSLV_RefNumber(Index)
      next Index
   fnend

   def fnClearResults([[SearchResults]])
      if (2==msgbox("This will remove all results from the list. Are you sure?","Clear all Results","yN","QST")) then
         mat PSLV_Source$(0)
         mat PSLV_Path$(0)
         mat PSLV_Text$(0)
         mat PSLV_Color$(0)
         mat PSLV_RefNumber(0)
         mat PSLV_Selected(0)
      end if
   fnend

   def fnRemoveItem(Item,[[SearchResults]];___,Index)
      for Index=Item to udim(mat PSLV_Source$)-1
         let PSLV_Source$(Index)=PSLV_Source$(Index+1)
         let PSLV_Path$(Index)=PSLV_Path$(Index+1)
         let PSLV_Text$(Index)=PSLV_Text$(Index+1)
         let PSLV_Color$(Index)=PSLV_Color$(Index+1)
         let PSLV_RefNumber(Index)=PSLV_RefNumber(Index+1)
      next Index
      mat PSLV_Source$(udim(mat PSLV_Source$)-1)
      mat PSLV_Path$(udim(mat PSLV_Source$))
      mat PSLV_Text$(udim(mat PSLV_Source$))
      mat PSLV_Color$(udim(mat PSLV_Source$))
      mat PSLV_RefNumber(udim(mat PSLV_Source$))
   fnend

   dim Warned

   def fnAddResult([[SearchResults]],Source$*30,Path$*255,Text$*255;RefNumber,Color$,___,Index)
      let Index=udim(mat PSLV_Source$)+1
      if fn42 or Index<4100 then
         mat PSLV_Source$(Index)
         mat PSLV_Path$(Index)
         mat PSLV_Text$(Index)
         mat PSLV_Color$(Index)
         mat PSLV_RefNumber(Index)

         if color$="" then let color$="#FFFFFF"

         let PSLV_Source$(Index)=trim$(Source$)
         let PSLV_Path$(Index)=trim$(Path$)
         let PSLV_Text$(Index)=trim$(Text$)
         let PSLV_Color$(Index)=trim$(Color$)
         let PSLV_RefNumber(Index)=RefNumber
      else
         if ~Warned then
            let msgbox("We ran out of memory to display all the results we found. Try running your search under BR 4.2 or Higher.","BR Data Structure Limitation","Ok","ERR")
            let Warned=1
         end if
      end if
   fnend

   ! Execute the Search based on PS_Data$ and populate [[SearchResults]]
   def fnSearch(mat PS_Data$,[[SearchResults]];___,MWindow)
      open #(MWindow:=fnGetFileNumber) : "SROW=14,SCOL=20,ROWS=3,COLS=60,BORDER=S",display,outin
      print #MWindow, fields "2,2,CC 58" : "Searching. Please wait..."

      let Warned=0
      if PS_Data$(_ps_screen)(1:1)="^" then
         print #MWindow, fields "2,2,CC 58" : "Searching Screens. Please wait..."
         let fnSearchScreen(PS_Data$(_ps_SearchText),[[SearchResults]])
      end if
      if PS_Data$(_ps_layout)(1:1)="^" then
         print #MWindow, fields "2,2,CC 58" : "Searching File Layouts. Please wait..."
         let fnSearchFileLay(PS_Data$(_ps_SearchText),[[SearchResults]])
      end if
      if PS_Data$(_ps_function)(1:1)="^" then
         print #MWindow, fields "2,2,CC 58" : "Searching Screen Functions. Please wait..."
         let fnSearchFunctions(PS_Data$(_ps_SearchText),[[SearchResults]])
      end if
      if PS_Data$(_ps_helperlib)(1:1)="^" then
         print #MWindow, fields "2,2,CC 58" : "Searching Compiled Helper Libraries. Please wait..."
         let fnSearchHelperLibs(PS_Data$(_ps_SearchText),[[SearchResults]])
      end if
      if PS_Data$(_ps_path)(1:1)="^" or PS_Data$(_ps_usealtext)(1:1)="^" then
         if len(trim$(ps_data$(_ps_folder))) and exists(trim$(ps_data$(_ps_folder))) and trim$(ps_data$(_ps_folder))<>"\" then
            if ps_data$(_ps_IncludeSubs)(1:1)=="^" then
               print #MWindow, fields "2,2,CC 58" : "Searching Folder and Subfolders. Please wait..."
            else
               print #MWindow, fields "2,2,CC 58" : "Searching Folder. Please wait..."
            end if
            let fnSearchPrograms(PS_Data$(_ps_SearchText),PS_Data$(_ps_Folder),ps_data$(_ps_mask),ps_data$(_ps_AltExt),(PS_Data$(_ps_path)(1:1)=="^"),(ps_data$(_ps_UseAltExt)(1:1)=="^"),(ps_data$(_ps_AltExtObject)(1:1)=="^"),(ps_data$(_ps_IncludeSubs)(1:1)=="^"),(ps_data$(_ps_SearchAllExt)(1:1)=="^"),(PS_Data$(_ps_function)(1:1)=="^"),[[SearchResults]],MWindow)
         end if
      end if
      close #MWindow:
   fnend


   dim SearchScreenIO$(1)*1023, SearchScreenIO(1)
   dim SearchScreenFld$(1)*1023, SearchScreenFld(1)

   def fnSearchScreen(&Text$,[[SearchResults]];___,I,Control,LastScreen$,Prefix$)
      mat SearchScreenIO$(udim(mat ScreenIO$))
      mat SearchScreenIO(udim(mat ScreenIO))
      mat SearchScreenFld$(udim(mat ScreenFld$))
      mat SearchScreenFld(udim(mat ScreenFld))

      restore #FScreenIO:
      restore #FScreenFld:

      do until file(FScreenIO)
         read #FScreenIO, using form$(FScreenIO), release : mat SearchScreenIO$, mat SearchScreenIO eof Ignore
         if file(fScreenIO)=0 then
            for I=1 to udim(mat SearchScreenIO$)
               if pos(lwrc$(SearchScreenIO$(I)),lwrc$(trim$(Text$))) then
                  let fnAddResult([[SearchResults]],"Screen",lwrc$(SearchScreenIO$(si_screencode))&"\"&lwrc$(ScreenIO_SSubs$(I))&"$",SearchScreenIO$(I),fnFieldOnScreen(I)) ! Match Found
               end if
            next I
         end if
      loop
      do until file(FScreenFld)
         read #FScreenFld, using form$(FScreenFld), release : mat SearchScreenFld$, mat SearchScreenFld eof Ignore
         if LastScreen$<>SearchScreenFld$(sf_screencode) then
            let Control=0
            let LastScreen$=SearchScreenFld$(sf_ScreenCode)
            read #FScreenIO, using form$(FScreenIO), key=fnKey$(FScreenIO,LastScreen$), release : mat SearchScreenIO$, mat SearchScreenIO nokey Ignore
            if file(fScreenIO)=0 then
               let fnReadLayoutArrays(SearchScreenIO$(si_filelay),Prefix$)
            else
               Prefix$=""
            end if
         end if
         let Control+=1
         if file(FScreenFld)=0 then
            for I=1 to udim(mat SearchScreenFld$)
               if ((I><sf_FieldName) and pos(lwrc$(SearchScreenFld$(I)),lwrc$(trim$(Text$)))) or ((I=sf_FieldName) and pos(lwrc$(trim$(Prefix$)&trim$(SearchScreenFld$(I))),lwrc$(trim$(Text$)))) then
                  let fnAddResult([[SearchResults]],"Screen",lwrc$(SearchScreenFld$(sf_screencode))&"\"&fnFieldHandle$(mat SearchScreenFld$,mat SearchScreenFld)&"\"&lwrc$(ScreenFLD_SSubs$(I))&"$",SearchScreenFld$(I),Control) ! Match Found
               end if
            next I
         end if
      loop
   fnend

   def fnFieldHandle$*200(mat ScreenFld$,mat Screenfld)
      if trim$(ScreenFld$(sf_controlname))<>"" then
         let fnFieldHandle$=lwrc$(ScreenFld$(sf_FieldType))&":"&ScreenFld$(sf_ControlName)
      else if trim$(ScreenFld$(sf_fieldname))<>"" then
         let fnFieldHandle$=lwrc$(ScreenFld$(sf_FieldType))&":<"&ScreenFld$(sf_FieldName)&">"
      else if trim$(ScreenFld$(sf_Description))<>"" and lwrc$(ScreenFld$(sf_fieldtype))=="caption" or lwrc$(ScreenFld$(sf_fieldtype))=="button" then
         let fnFieldHandle$=lwrc$(ScreenFld$(sf_FieldType))&":"""&ScreenFld$(sf_Description)&""""
      else if trim$(ScreenFld$(sf_picture))<>"" and lwrc$(ScreenFld$(sf_fieldtype))=="p" then
         let fnFieldHandle$=lwrc$(ScreenFld$(sf_FieldType))&":"""&ScreenFld$(sf_picture)&""""
      else if trim$(ScreenFld$(sf_function))<>"" and lwrc$(ScreenFld$(sf_fieldtype))=="caption" or lwrc$(ScreenFld$(sf_fieldtype))=="button" then
         let fnFieldHandle$=lwrc$(ScreenFld$(sf_FieldType))&":"""&ScreenFld$(sf_Description)&""""
      else
         if lwrc$(ScreenFld$(sf_FieldType))="listchld" or lwrc$(ScreenFld$(sf_FieldType))="listview" then
            let fnFieldHandle$=lwrc$(ScreenFld$(sf_FieldType))&":["&Str$(ScreenFld(sf_Vposition))&","&Str$(ScreenFld(sf_Hposition))&",list "&str$(screenFld(sf_Width))&"/"&str$(ScreenFld(sf_Height))&"]"
         else
            let fnFieldHandle$=lwrc$(ScreenFld$(sf_FieldType))&":["&Str$(ScreenFld(sf_Vposition))&","&Str$(ScreenFld(sf_Hposition))&","&Fncalculatefieldtype$(ScreenFld$(sf_Fieldtype),ScreenFld$(sf_Justify),ScreenFld(sf_Width),ScreenFld(sf_Specwidth),ScreenFld(sf_Height))&"]"
         end if
      end if
   fnend

   dim d1$(1)*36, d2$(1)*36, d3$(1)*36, d4$(1)*36, d5$(1)*255
   dim as_reference(1), ReadFieldOnScreen
   def fnFieldOnScreen(I)
      if ~ReadFieldOnScreen then
         let Fndefineattributeswindow(mat d1$,mat d2$,mat d3$,mat d4$,mat d5$,mat as_Reference)
         let ReadFieldOnScreen=1
      end if
      let fnFieldOnScreen=max(0,srch(mat as_Reference,I))
   fnend

   dim StringOfText$*10000
   def fnSearchTextFile(FileName$*255,&Text$,[[SearchResults]],Type$*40;Path$*255,___,TextFile)
      open #(TextFile:=fnGetFileNumber): "name="&FileName$, display, input error Ignore
      if file(TextFile)=0 then
         if Path$="" then let Path$=FileName$
         do until file(TextFile)
            linput #TextFile: StringOfText$ error Ignore
            if file(TextFile)=0 then
               if pos(lwrc$(StringOfText$),lwrc$(trim$(text$))) then
                  let fnShrinkAround(StringOfText$,trim$(Text$),150)
                  let fnAddResult([[SearchResults]],Type$,Path$,StringOfText$)
               end if
            end if
         loop
         close #TextFile:
      end if
   fnend

   def fnShrinkAround(&Longstring$,SearchString$*255,Size;___,X,Q,S,E)
      let Longstring$=Trim$(LongString$)
      if len(Longstring$)>Size then
         let Q=int(Size/4)
         let X=pos(lwrc$(LongString$),lwrc$(SearchString$))
         if X>0 then
            let S=max(1,X-Q)
            let E=min(len(LongString$),S+Size-1)
            let S=max(1,E-Size+1)
            let LongString$=LongString$(S:E)
         else
            let LongString$=Longstring$(1:Size)
         end if
      end if
   fnend

   dim FileList$(1)*255
   dim SearchSSubs$(1)*255, SearchNSubs$(1)*255
   def fnSearchFileLay(&Text$,[[SearchResults]];___,Index,LayoutPath$*255,Prefix$,Jndex)
      ! Text File Search
      let LayoutPath$=fnReadLayoutPath$
      let fnReadLayouts(mat FileList$)

      for Index=1 to udim(Mat FileList$)
         let fnSearchTextFile(LayoutPath$&FileList$(Index),Text$,[[SearchResults]],"Layout")
         let fnReadLayoutArrays(FileList$(Index),Prefix$,mat SearchSSubs$,mat SearchNSubs$)
         for Jndex=1 to udim(mat SearchSSubs$)
            if pos(lwrc$(trim$(Prefix$)&Trim$(SearchSSUbs$(Jndex))),lwrc$(trim$(Text$))) then
               let fnAddResult([[SearchResults]],"Layout",lwrc$("filelay\"&FileList$(Index))&"\"&lwrc$(trim$(Prefix$)&Trim$(SearchSSUbs$(Jndex)))&"$",lwrc$(trim$(Prefix$)&Trim$(SearchSSUbs$(Jndex)))&"$") ! Match Found
            end if
         next Jndex
         for Jndex=1 to udim(mat SearchNSubs$)
            if pos(lwrc$(trim$(Prefix$)&Trim$(SearchNSUbs$(Jndex))),lwrc$(trim$(Text$))) then
               let fnAddResult([[SearchResults]],"Layout",lwrc$("filelay\"&FileList$(Index))&"\"&lwrc$(trim$(Prefix$)&Trim$(SearchNSUbs$(Jndex))),lwrc$(trim$(Prefix$)&Trim$(SearchNSUbs$(Jndex)))) ! Match Found
            end if
         next Jndex
      next Index
   fnend

   def fnSearchFunctions(&Text$,[[SearchResults]];___,Index)
      ! Text File Search
      let Fnreadfiles(mat FileList$,setting_FunctionFolder$,"brs",1,0,1)

      for Index=1 to udim(Mat FileList$)
         let fnSearchTextFile(setting_FunctionFolder$&FileList$(Index),Text$,[[SearchResults]],"Function")
      next Index

      if exists(setting_FunctionFolder$&"defaults\") then
         let Fnreadfiles(mat FileList$,setting_FunctionFolder$&"defaults\","brs",1,0,1)
         for Index=1 to udim(Mat FileList$)
            let fnSearchTextFile(setting_FunctionFolder$&"defaults\"&FileList$(Index),Text$,[[SearchResults]],"Function")
         next Index
      end if
   fnend

   def fnSearchHelperLibs(&Text$,[[SearchResults]];___,Index)
      ! Text File Search
      let Fnreadfiles(mat FileList$,"screenio","brs",1,0,1)

      for Index=1 to udim(Mat FileList$)
         let fnSearchTextFile(""&setting_ScreenFolder$&"\"&FileList$(Index),Text$,[[SearchResults]],"Helper Library")
      next Index
   fnend

   def fnNewExt(FileName$*128;AltExt$,___,Ext$,Position)
      let Position=pos(FileName$,".",-1)
      if Position then let Ext$=FileName$(Position+1:len(Filename$))
      #Select# lwrc$(trim$(Ext$)) #Case# "brs" # "wbs" # "br" # "wb" # lwrc$(trim$(AltExt$)) # "bak"
      #Case Else#
         if ~pos(lwrc$(FileName$),"brlog.txt") and ~pos(lwrc$(FileName$),"fileio.log") and ~pos(lwrc$(FileName$),"dir.doc") then
            fnNewExt=1
         end if
      #End Select#
   fnend

   dim taString$*2000
   def fnValidAsciiFile(Filename$*128;___,FileN)
      open #(FileN:=fnGetFileNumber): "name="&FileName$&", recl=2000", display, input error SkipThisFile
      if file(FileN)=0 then
         linput #FileN: taString$ error Ignore
         if file(FileN)=0 then
            let fnValidAsciiFile=fnAscii(String$)
         end if
      end if
      close #FileN:
      SkipThisFile: ! Jumps here if we can't even open it
   fnend

   def fnAscii(&string$;___,Char,Index)
      let fnAscii=1
      do while (index:=index+1)<=len(String$)
         let Char=ord(string$(index:index))
         if (Char<32 and Char><10 and Char><13 and Char><26) or Char>=127 then
            let fnAscii=0
            exit do
         end if
      loop
   fnend

   dim Directory$*9999
   def fnBuildFolderList(mat list$;Folder$*255,___,FolderFile,lastchar)
      if folder$="" then let Folder$=br_filename$(os_filename$(".")) ! Current dir first
      let LastChar=len(Folder$)
      if folder$(LastChar:LastChar)="\" then let Folder$=Folder$(1:LastChar-1)
      mat list$(1)
      let list$(1)=Folder$ ! Current dir first
      if ~exists("dirlist.sch") then execute "system -M dir """&os_filename$(Folder$)&""" /s /b /ad >dirlist.sch"
      open #(FolderFile:=fnGetFileNumber): "name=dirlist.sch, recl=2000", display, input
      do until file(FolderFile)
         linput #FolderFile : directory$ eof Ignore
         if file(FolderFile)=0 then
            if br_filename$(trim$(directory$))(1:1)<>":" and pos(br_filename$(trim$(directory$))," ")=0 and pos(directory$,".svn")=0 and pos(directory$,"filelay\version")=0 then
               mat List$(udim(mat List$)+1)
               let List$(udim(mat List$))=br_filename$(Directory$)
            end if
         end if
      loop

      close #FolderFile:
      ! execute "*free dirlist.sch"
   fnend


   dim AlreadySearched$(1)*255
   dim WarnedAboutFolder
   dim SearchFolders$(1)*255
   dim FileFolderList$(1)*255

   dim AllExtFiles$(1)*255
   def fnSearchPrograms(&Text$,&Folder$,&Mask$,&AltExt$,UseStandard,UseAltExt,AltExtObject,IncludeSubfolders,IncludeAllExt,SuppressFunctionFolder,[[SearchResults]];MWindow,___,Index,WaitCount,CompileNumber,WaitTime,SaidSomething,ProcFile,DirIndex,FolderListIndex,TestAltExt$,NumberOfFiles)
      if IncludeSubfolders then
         ! Build a DirList$
         let fnBuildFolderList(mat SearchFolders$,Folder$)
      else
         mat SearchFolders$(1)
         let SearchFolders$(1)=Folder$
      end if

      if MWindow then print #MWindow, fields "2,2,CC 58" : "Searching Folder: Finding Files. Please wait..."

      ! Text File Search
      mat FileList$(0) : mat FileFolderList$(0)
      for DirIndex=1 to udim(mat SearchFolders$)
         if ~SuppressFunctionFolder or os_filename$(SearchFolders$(DirIndex))><os_filename$(setting_FunctionFolder$) then
            if UseStandard then
               let Fnreadfiles(mat FileList$,trim$(SearchFolders$(DirIndex)),"brs",0,0,1,Mask$)
               let fnReadFiles(mat FileList$,trim$(SearchFolders$(DirIndex)),"wbs",0,0,1,Mask$)
            end if
            if UseAltExt and ~AltExtObject then
               let fnReadFiles(mat FileList$,trim$(SearchFolders$(DirIndex)),lwrc$(AltExt$),0,0,1,Mask$)
            end if

            if IncludeAllExt then ! Then check for all extensions and add the others in here if they're valid text files.
               if UseAltExt then TestAltExt$=AltExt$ else TestAltExt$=""
               mat AllExtFiles$(0)
               let fnReadFiles(mat AllExtFiles$,trim$(SearchFolders$(DirIndex)),"",0,0,1,Mask$)
               for Index=1 to udim(mat AllExtFiles$)
                  if fnNewExt(AllExtFiles$(Index),TestAltExt$) and fnValidAsciiFile(SearchFolders$(DirIndex)&"\"&AllExtFiles$(Index)) then
                     mat FileList$(udim(mat FileList$)+1)
                     let FileList$(udim(mat FileList$))=AllExtFiles$(Index)
                  end if
               next Index
            end if

            ! Record which folder to use later.
            let FolderIndex=udim(mat FileFolderList$)+1
            mat FileFolderList$(udim(mat FileList$))

            if udim(mat FileFolderList$)>=FolderIndex then
               mat FileFolderList$(FolderIndex:udim(mat FileFolderList$))=(SearchFolders$(DirIndex))
            end if
         end if
      next DirIndex

      mat AlreadySearched$(udim(mat FileList$))

      if MWindow then print #MWindow, fields "2,2,CC 58" : "Searching Folder: Searching Ascii Files. Please wait..."
      for Index=1 to udim(Mat FileList$)
         let AlreadySearched$(Index)=lwrc$(trim$(FileFolderList$(Index)&"\"&filelist$(Index)))
         let fnSearchTextFile(trim$(FileFolderList$(Index))&"\"&FileList$(Index),Text$,[[SearchResults]],"Program")
      next Index

      if MWindow then print #MWindow, fields "2,2,CC 58" : "Searching Folder: Finding BR Object Files. Please wait..."

      ! Also search for .br and .wb files
      if Folder$(1:1)=":" then
         if ~WarnedAboutFolder then
            let Msgbox("Warning: It is not possible to search for BR Object files outside of your BR path. Only Source files will be searched.","Warning:")
            let WarnedAboutFolder=1
         end if
      else
         mat FileList$(0) : mat FileFolderList$(0)
         for DirIndex=1 to udim(mat SearchFolders$)
            if ~SuppressFunctionFolder or os_filename$(SearchFolders$(DirIndex))><os_filename$(setting_FunctionFolder$) then
               if UseStandard then
                  let Fnreadfiles(mat FileList$,trim$(SearchFolders$(DirIndex)),"br ",0,0,1,Mask$)
                  let fnReadFiles(mat FileList$,trim$(SearchFolders$(DirIndex)),"wb ",0,0,1,Mask$)
               end if
               if UseAltExt and AltExtObject then
                  let fnReadFiles(mat FileList$,trim$(SearchFolders$(DirIndex)),lwrc$(AltExt$),0,0,1,Mask$)
               end if

               let FolderIndex=udim(mat FileFolderList$)+1
               mat FileFolderList$(udim(mat FileList$))

               if udim(mat FileFolderList$)>=FolderIndex then
                  mat FileFolderList$(FolderIndex:udim(mat FileFolderList$))=(SearchFolders$(DirIndex))
               end if
            end if
         next DirIndex

         if MWindow then print #MWindow, fields "2,2,CC 58" : "Searching Folder: Building Decompile Proc. Please wait..."
         for Index=1 to udim(Mat FileList$)
            if Srch(mat alreadySearched$,lwrc$(trim$(FileFolderList$(Index)&"\"&FileList$(Index)))&"s")<1 and Srch(mat alreadySearched$,lwrc$(trim$(FileFolderList$(Index)&"\"&srep$(FileList$(Index),".wb",".brs"))))<1 then
               if lwrc$(trim$(FileList$(Index)))<>"screenio.br" then
                  if ~ProcFile then let ProcFile=fnOpenDecompileProc(CompileNumber)
                  let fnBuildDecompileProc(fileList$(Index),FileFolderList$(Index),ProcFile)
                  let NumberOfFiles+=1
               end if
            end if
         next Index
         if MWindow then print #MWindow, fields "2,2,CC 58" : "Searching Folder: Decompiling BR Programs. Please wait..."
         if ProcFile then let fnCloseDecompileProc(ProcFile,CompileNumber)

         let WaitCount=timer
         let WaitTime=NumberOfFiles*.3 ! seconds
         let SaidSomething=0
         do while exists("compile"&str$(CompileNumber)&".$$$")
            sleep(.1)
            if timer-WaitCount>WaitTime then
               if (2==msgbox("We've been waiting a long time. There were "&str$(NumberOfFiles)&" files to decompile. Could something have gotten stuck, perhaps? Do you want to wait longer?","Wait Longer?","Yn")) then
                  let WaitCount=Timer
                  let SaidSomething=1
               end if
            end if
         loop until timer-WaitCount>WaitTime

         if exists("compile"&str$(CompileNumber)&".$$$") then
            let msgbox("Search Failed for .BR files","Error")
            execute "free compile"&str$(CompileNumber)&".$$$" error Ignore
            if exists("compile"&str$(CompileNumber)&".$$$") then let CompileNumber+=1
         else if SaidSomething then
            let msgbox("We were able to recover the search.")
         end if

         if MWindow then print #MWindow, fields "2,2,CC 58" : "Searching Folder: Searching BR Programs. Please wait..."
         for Index=1 to udim(Mat FileList$)
            if exists("temp_"&lwrc$(trim$(filelist$(index)))&".brs") then
               let fnSearchTextFile("temp_"&lwrc$(trim$(filelist$(index)))&".brs",Text$,[[SearchResults]],"Program",trim$(FileFolderList$(Index))&"\"&FileList$(Index))
               execute "free ""temp_"&lwrc$(trim$(filelist$(index)))&".brs"""
            end if
         next Index
      end if
   fnend

   def fnOpenDecompileProc(&CompileNumber;___,FileNumber)
      open #(Filenumber:=Fngetfilenumber): "name=compile"&str$(CompileNumber)&".$$$, replace", display, output error TryNextNumber
      print #Filenumber: "proc noecho"
      let fnOpenDecompileProc=FileNumber
   fnend

   TryNextNumber: ! Try a new number
   let CompileNumber+=1
   retry

   def fnCloseDecompileProc(FileNumber,CompileNumber)
      print #Filenumber: "system"
      close #Filenumber:
!
! .   ! Extract Source Code
      execute "system -C -M "&Fngetbrexe$&" -"&Fngetwbcfg$&" proc compile"&str$(CompileNumber)&".$$$"
   fnend

   def fnBuildDecompileProc(FileName$*255,Folder$*255,FileNumber)
      print #Filenumber: "load """&trim$(folder$)&"\"&Trim$(FileName$)&""""
      print #FileNumber: "list >""temp_"&lwrc$(trim$(FileName$))&".brs"""
   fnend

   def fnPrintListToFile([[SearchResults]];___,FileNumber,filename$*255)
      ! Browse for a file
      Open #(filenumber:=fnGetFileNumber): "name=save:.\*.txt, recl=1024,replace", display, output error Ignore
      if FileNumber and file(FileNumber)>-1 then
         let fnPrintList(FileNumber,[[SearchResults]])
         let filename$=file$(filenumber)
         close #filenumber:
         execute "system -M -C start ""Launching"" """&os_filename$(filename$)&""""
      end if
   fnend

   def fnPrintListToPrinter([[SearchResults]])
      ! Open the printer
      let fnPrinterSys
      Open #255: "name=preview:/default, recl=1024", display, output
      print #255: "[LANDSCAPE][A4PAPER][SETFONT(SystemPC)][LPI(8)][CPI(16)]";
      let fnPrintList(255, [[SearchResults]])
      close #255:
   fnend

   def fnPrintList(FileNumber,[[SearchResults]];___,Index,SourceLen,PathLen,TextLen,Printer)
      if FileNumber=255 then let Printer=1
      let SourceLen=7
      let PathLen=5
      let TextLen=5
      for Index=1 to udim(mat pslv_source$)
         let SourceLen=max(SourceLen,len(pslv_Source$(Index)))
         let PathLen=max(PathLen,len(pslv_path$(Index)))
         let TextLen=max(TextLen,len(pslv_text$(Index)))
      next Index
      print #Filenumber: "PowerSearch: """&trim$(ps_data$(_ps_searchtext))&""" Folder: """&trim$(ps_data$(_ps_folder))&""" "&date$("Day, Month dd, ccyy")&", "&time$
      print #FileNumber:
      print #Filenumber: srep$(rpad$(" Source",SourceLen)," ","_")&" "&srep$(rpad$(" Path",PathLen)," ","_")&" "&srep$(rpad$(" Text",TextLen)," ","_")
      for Index=1 to udim(mat pslv_source$)
         if Printer then
            if pslv_color$(Index)="#FFFFFF" then
               print #FileNumber: "[SETCOLOR(#000000)]";
            else
               print #FileNumber: "[SETCOLOR("&pslv_Color$(Index)&")]";
            end if
         end if
         print #Filenumber: rpad$(trim$(pslv_source$(index)),SourceLen)&" "&rpad$(trim$(pslv_path$(index)),PathLen)&" "&rpad$(trim$(pslv_text$(index)),TextLen);
         if ~Printer then
            print #FileNumber: " "&fnColorName$(pslv_Color$(Index))
         else
            print #Filenumber:
         end if
      next Index
   fnend

   def fnPrintListToPrinterSimple(mat Data$)
      ! Open the printer
      Open #255: "name=preview:/default, recl=1024", display, output
      let fnPrintListSimple(255, mat Data$)
      close #255:
   fnend

   def fnPrintListSimple(FileNumber,mat Data$;___,Index)
      for Index=1 to udim(mat data$)
         print #Filenumber: data$(Index)
      next Index
   fnend


   def fnColorName$(color$)
      #Select# uprc$(trim$(color$(2:7))) #Case# "FFFFFF"
         let fnColorName$="White"
      #Case# "FFFF00"
         let fnColorName$="Yellow"
      #Case# "00FF00"
         let fnColorName$="Green"
      #End select#
   fnend

   dim PrinterSysSet
   def fnPrinterSys ! Activate Printer.Sys commands
      if ~PrinterSysSet then
         execute "config PRINTER TYPE NWP select WIN:"
         execute "config PRINTER TYPE NWP select PREVIEW:"

         execute 'config PRINTER NWP [SETCOLOR(CCCCCCC)], "\Ecolor=''CCCCCCC''"'
         execute 'config PRINTER NWP [CPI(NNN)], "\E(sNNNH"'
         execute 'config PRINTER NWP [LPI(NNN)], "\E&lNNND"'
         execute 'config PRINTER NWP [SETFONT(FontName)], "\Efont=''FontName''"'
         execute 'config PRINTER NWP [A4PAPER], "\E&l26A" ! 210mm x 297mm'
         execute 'config PRINTER NWP [LANDSCAPE], "\E&l1O"'
         let PrinterSysSet=1
      end if
   fnend

!  #AutoNumber# 68000,2
!  =================================================
!  ================= Code Explorer =================
!  =================================================

   dim CELV_Spec$
   dim CELV_Cap$(2)*30,CeLV_Width(2),CeLV_Spec$(2)
   dim ce_CapSpec$(2)*30, ce_Caption$(2)*30

   dim CELV_Path$(1)*255
   dim CELV_Location$(1)*255
   dim CELV_Selected(1)

   def fnCodeExplore(mat ScreenIO$,mat ScreenIO,[[ScreenControls]];___,Function,CodeExplore,RowCount,Done)
      ! Initialize PowerSearch Results Listview
      let CELV_Spec$="1,1,LIST 22/50"

      ! Initialize PowerSearch Results Listview Columns
      let ceLV_Cap$(1)="Function"
      let ceLV_Width(1)=20
      let ceLV_Spec$(1)="C 255"

      let ceLV_Cap$(2)="Location"
      let ceLV_Width(2)=10
      let ceLV_Spec$(2)="C 255"

      mat ceLV_Path$(0)
      mat ceLV_Location$(0)

      ! Initialize Code Explorer Buttons and Caption Specs
      mat ce_CapSpec$(2) : mat ce_Caption$(2)
      let ce_CapSpec$(1)="23,3,10/CC 17,/W:W,B36"   ! Jump To Item
      let ce_CapSpec$(2)="23,14,15/CC 26,/W:W,B37" ! Affected Screen List

      let ce_Caption$(1)="Launch"
      let ce_Caption$(2)="Affected Screens"

      Open #(CodeExplore:=fnGetFileNumber): "srow=4,scol=30,rows=23,cols=50,Border=s,Caption=Code Explorer", display, outin

      print #CodeExplore, fields mat ce_CapSpec$ : mat ce_Caption$
      print #CodeExplore, fields CELV_Spec$&",HEADERS,/W:W" : (mat ceLV_Cap$, mat ceLV_Width, mat ceLV_Spec$)

      let fnPopulateCodeExplore(mat celv_path$,mat celv_location$,mat ScreenIO$,mat ScreenIO,[[ScreenControls]])

      if udim(mat celv_path$) then
         ! Predraw listview if any data belongs in it
         print #CodeExplore, fields CELV_Spec$&",=" : (mat celv_path$,mat celv_location$)
         do
            input #CodeExplore, fields CELV_Spec$&",ROWCNT,SEL" : RowCount
            mat ceLV_Selected(RowCount)
            input #CodeExplore, fields CELV_Spec$&",ROWSUB,SEL,NOWAIT" : mat ceLV_Selected

            let Function=fkey

            #Select# Function #Case# 36
               ! Jump To Item
               let fnCEJumpTo(mat ceLV_Selected,mat celv_path$)

            #Case# 37
               ! Affected Screen List
               let Done=fnCEAffectedScreenList(mat ceLV_Selected,mat celv_path$)

            #End Select#

         loop Until Function=99 Or Function=98 Or Function=93 Or ((Function>1100) And (Function<1699)) Or Function=19 or fkey=93 or Done
      else
         let msgbox("No functions are defined in the current screen.","Nothing to display")
      end if
      if CodeExplore and file(CodeExplore)>-1 then close #CodeExplore:
   fnend

   def fnPopulateCodeExplore(mat Path$,mat Location$,mat ScreenIO$,mat ScreenIO,[[ScreenControls]];___,Index,Loc$*255)
      for Index=si_enterfn to si_exitfn
         if len(trim$(ScreenIO$(Index))) then
            let fnAddCEResult(trim$(ScreenIO$(Index)),mat Path$,mat Location$,fnEventName$(-1,Index))
         end if
      next Index

      for Index=1 to udim(mat ControlName$)
         if len(trim$(Function$(Index))) then
            let fnAddCEResult(trim$(Function$(Index)),mat Path$,mat Location$,fnEventName$(Index,1,[[ScreenControls]]))
         end if
         if len(trim$(CnvrtIn$(Index))) then
            let fnAddCEResult(trim$(Function$(Index)),mat Path$,mat Location$,fnEventName$(Index,2,[[ScreenControls]]))
         end if
         if len(trim$(CnvrtOut$(Index))) then
            let fnAddCEResult(trim$(Function$(Index)),mat Path$,mat Location$,fnEventName$(Index,3,[[ScreenControls]]))
         end if
      next Index

      if exists(setting_FunctionFolder$) then
         if exists(setting_FunctionFolder$&"defaults\") then
            if exists(setting_FunctionFolder$&"defaults\enter.brs") then
               let fnAddCEResult(fnFunctionString$(setting_FunctionFolder$&"defaults\enter.brs"),mat Path$,mat Location$,"Default Screen Enter Event")
            end if
            if exists(setting_FunctionFolder$&"defaults\init.brs") then
               let fnAddCEResult(fnFunctionString$(setting_FunctionFolder$&"defaults\init.brs"),mat Path$,mat Location$,"Default Screen Init Event")
            end if
            if exists(setting_FunctionFolder$&"defaults\read.brs") then
               let fnAddCEResult(fnFunctionString$(setting_FunctionFolder$&"defaults\read.brs"),mat Path$,mat Location$,"Default Screen Read Event")
            end if
            if exists(setting_FunctionFolder$&"defaults\load.brs") then
               let fnAddCEResult(fnFunctionString$(setting_FunctionFolder$&"defaults\load.brs"),mat Path$,mat Location$,"Default Screen Load Event")
            end if
            if exists(setting_FunctionFolder$&"defaults\write.brs") then
               let fnAddCEResult(fnFunctionString$(setting_FunctionFolder$&"defaults\write.brs"),mat Path$,mat Location$,"Default Screen Write Event")
            end if
            if exists(setting_FunctionFolder$&"defaults\wait.brs") then
               let fnAddCEResult(fnFunctionString$(setting_FunctionFolder$&"defaults\wait.brs"),mat Path$,mat Location$,"Default Screen Wait Event")
            end if
            if exists(setting_FunctionFolder$&"defaults\locked.brs") then
               let fnAddCEResult(fnFunctionString$(setting_FunctionFolder$&"defaults\locked.brs"),mat Path$,mat Location$,"Default Screen Locked Event")
            end if
            if exists(setting_FunctionFolder$&"defaults\merge.brs") then
               let fnAddCEResult(fnFunctionString$(setting_FunctionFolder$&"defaults\merge.brs"),mat Path$,mat Location$,"Default Screen Merge Event")
            end if
            if exists(setting_FunctionFolder$&"defaults\mainloop.brs") then
               let fnAddCEResult(fnFunctionString$(setting_FunctionFolder$&"defaults\mainloop.brs"),mat Path$,mat Location$,"Default Screen Mainloop Event")
            end if
            if exists(setting_FunctionFolder$&"defaults\nokey.brs") then
               let fnAddCEResult(fnFunctionString$(setting_FunctionFolder$&"defaults\nokey.brs"),mat Path$,mat Location$,"Default Screen Nokey Event")
            end if
            if exists(setting_FunctionFolder$&"defaults\prelist.brs") then
               let fnAddCEResult(fnFunctionString$(setting_FunctionFolder$&"defaults\prelist.brs"),mat Path$,mat Location$,"Default Screen PreList Event")
            end if
            if exists(setting_FunctionFolder$&"defaults\postlist.brs") then
               let fnAddCEResult(fnFunctionString$(setting_FunctionFolder$&"defaults\postlist.brs"),mat Path$,mat Location$,"Default Screen PostList Event")
            end if
            if exists(setting_FunctionFolder$&"defaults\exit.brs") then
               let fnAddCEResult(fnFunctionString$(setting_FunctionFolder$&"defaults\exit.brs"),mat Path$,mat Location$,"Default Screen Exit Event")
            end if
         end if
      end if
!
   fnend
   def fnEventName$*255(Control,Type;[[ScreenControls]])
      if Control<0 then
         ! Window Level Event, no Control Given
         let fnEventName$="Screen "&fnWindowFunction$(Type)&" Event"
      else
         ! Control Given. Check its type to get Verb.
         !  Pull Description out of its name or whatever is available.
         if len(trim$(ControlName$(Control))) then
            let fnEventName$=ControlName$(Control)&" control's "&fnEventVerb$(FieldType$(Control),Type)&" Event"
         else if len(trim$(FieldName$(Control))) then
            let fnEventName$=FieldName$(Control)&" field's "&fnEventVerb$(FieldType$(Control),Type)&" Event"
         else
            let fnEventName$="Control "&str$(Control)&"'s "&fnEventVerb$(FieldType$(Control),Type)&" Event"
         end if
      end if
   fnend

   def fnWindowFunction$*64(Type)
      #Select# Type #Case# si_ENTERFN
         let fnWindowFunction$="Enter"
      #Case# si_INITFN
         let fnWindowFunction$="Initialize"
      #Case# si_READFN
         let fnWindowFunction$="Read"
      #Case# si_LOADFN
         let fnWindowFunction$="Load"
      #Case# si_WRITEFN
         let fnWindowFunction$="Write"
      #Case# si_WAITFN
         let fnWindowFunction$="Wait"
      #Case# si_LOCKEDFN
         let fnWindowFunction$="Record Locked"
      #Case# si_MERGEFN
         let fnWindowFunction$="Merge Function"
      #Case# si_LOOPFN
         let fnWindowFunction$="Main Loop"
      #Case# si_NOKEYFN
         let fnWindowFunction$="Nokey"
      #Case# si_PRELISTVIEWFN
         let fnWindowFunction$="Listview Prepopulate"
      #Case# si_POSTLISTVIEWFN
         let fnWindowFunction$="Listview Postpopulate"
      #Case# si_EXITFN
         let fnWindowFunction$="Exit"
      #End Select#
   fnend

   def fnEventVerb$*64(Type$*255,Type)
      ! Check Control Type for Basic Verb
      #Select# lwrc$(trim$(Type$)) #Case# "button" # "p" # "caption" # "screen"
         let fnEventVerb$="Click"
      #Case# "c" # "search" # "filter"
         let fnEventVerb$="Validate"
      #Case# "listview"
         let fnEventVerb$="Filter"
      #End Select#

      ! Apply Type Override
      #Select# Type #Case# 2
         let fnEventVerb$="ConvertIn"
      #Case# 3
         let fnEventVerb$="ConvertOut"
      #End Select#
   fnend

   def fnAddCEResult(Function$*255,mat Path$;mat Location$,Loc$*255,___,Index)
      let Index=udim(mat Path$)+1

      mat Path$(Index)
      mat Location$(Index)

      let Path$(Index)=trim$(Function$)
      let Location$(Index)=trim$(Loc$)
   fnend

   ! Jump To Item
   def fnceJumpTo(mat Selected,mat Path$;___,Index,DoneAScreen,DoneAHelperLib,Screen$)
      for Index=1 to udim(mat Selected)
         if trim$(path$(selected(index)))(1:1)="{" then
            ! if this item is a function, launch it in editor
            sleep(.1)
            execute "system -C -M start "&os_filename$(fnCustomFileNameOf$(trim$(path$(Selected(index))))) error Ignore
         end if
      next Index
   fnend


   def fnCeAffectedScreenList(mat selected,mat Path$;___,Index,Window,AFSelCount,function,SaveScreenCode$,Done,FileName$*255)
      ! Build list of affected screens
      mat AffectedScreens$(0)
      let fnCEFindAffectedScreens(mat AffectedScreens$,mat Selected,mat Path$)

      if udim(mat AffectedScreens$)=0 then
         let msgbox("No screens are affected.","Nothing Found")
      else
         ! Define Listview
         let AS_Caption$(1)="Affected Screens"
         let AS_Width(1)=30
         let AS_Spec$(1)="CC 18"

         ! Open Window
         open #(Window:=fnGetFileNumber) : "srow=5,scol=30,rows=15,cols=30,border=s",display,outin

         ! Paint Window
         print #Window, fields "1,1,LIST 14/30,HEADERS,/W:W" : (mat AS_Caption$,mat AS_Width,mat AS_Spec$)
         print #Window, fields "1,1,LIST 14/30,=" : (mat AffectedScreens$)
         print #Window, fields "15,1,14/CC 16,/W:W,B30;15,16,CC 14,/W:W,B31" : "Recompile Screen","Load Screen"

         do
            input #Window, fields "1,1,LIST 14/30,ROWCNT,SEL" : AFSelCount
            let Function=fkey
            mat Af_Selection(AfSelCount)
            input #Window, fields "1,1,LIST 14/30,ROWSUB,SEL,NOWAIT" : mat AF_Selection

            if function=30 then ! Recompile Selected Screens
               let Savescreencode$=Static_Screenname$

               if exists("compile[SESSION].$$$") then
                  execute "free compile[SESSION].$$$"
               end if

               let FailedList$=""
               for Index=1 to udim(mat af_selection)
                  if Fnreadscreen(AffectedScreens$(Af_Selection(Index)),Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
                     let Fncompilehelperlibrary(Mat Screenio$,Mat Screenio,[[Screencontrols]],FileName$)
                     let fnWaitForFile(FailedList$,AffectedScreens$(Af_Selection(Index)),FileName$)
                  end if
               next Index

               if len(FailedList$) then
                  let Msgbox("The following screens took a long time and may have had errors:"&chr$(13)&chr$(13)&FailedList$(3:9999))
               end if

               let Fnreadscreen(Savescreencode$,Mat Screenio$,Mat Screenio,[[Screencontrols]])
            end if


            if function=31 then ! Load Screen
               let fnLaunchScreen(trim$(AffectedScreens$(AF_Selection(1))))
            !   if Fnoktoproceed(Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
            !      if Fnreadscreen(AffectedScreens$(AF_Selection(1)),Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
            !         let fnRedrawScreen(mat ScreenIO$,mat ScreenIO,[[ScreenControls]],1)
            !
            !         let Done=1
            !      else
            !         let Msgbox("Error Reading Screen - Screen not  found","Error","OK","ERR")
            !      end if
            !   end if
            end if
         loop until function=99 or function=93 or fkey=93 or Done
         if function=93 or fkey=93 or Done then let fnCEAffectedScreenList=1

         if Window and file(Window)>-1 then Close #Window:
      end if
   fnend

   def fnceFindAffectedScreens(mat AffectedScreens$,mat Selected,mat Path$;___,Function$*255,Index,Jndex)
      for Index=1 to udim(mat Selected)

         ! If its a function, search for it in all the screens
         let Function$=Path$(Selected(Index))

         mat SearchScreenIO$(udim(mat ScreenIO$))
         mat SearchScreenIO(udim(mat ScreenIO))
         mat SearchScreenFld$(udim(mat ScreenFld$))
         mat SearchScreenFld(udim(mat ScreenFld))

         restore #FScreenIO:
         restore #FScreenFld:

         do until file(FScreenIO)
            read #FScreenIO, using form$(FScreenIO), release : mat SearchScreenIO$, mat SearchScreenIO eof Ignore
            if file(fScreenIO)=0 then
               for Jndex=si_enterfn to si_exitfn
                  if lwrc$(trim$(SearchScreenIO$(Jndex)))=lwrc$(trim$(Function$)) then
                     let fnAddAFScreen(SearchScreenIO$(si_Screencode),mat AffectedScreens$)
                  end if
               next Jndex
            end if
         loop
         do until file(FScreenFld)
            read #FScreenFld, using form$(FScreenFld), release : mat SearchScreenFld$, mat SearchScreenFld eof Ignore
            if file(FScreenFld)=0 then
               if lwrc$(trim$(SearchScreenFld$(sf_function)))=lwrc$(trim$(Function$)) then
                  let fnAddAfScreen(SearchScreenFld$(sf_ScreenCode),mat affectedScreens$)
               end if
               if lwrc$(trim$(SearchScreenFld$(sf_cnvrtin)))=lwrc$(trim$(Function$)) then
                  let fnAddAfScreen(SearchScreenFld$(sf_ScreenCode),mat affectedScreens$)
               end if
               if lwrc$(trim$(SearchScreenFld$(sf_cnvrtout)))=lwrc$(trim$(Function$)) then
                  let fnAddAfScreen(SearchScreenFld$(sf_ScreenCode),mat affectedScreens$)
               end if
            end if
         loop

      next Index
   fnend

   dim of_selected(1)
   dim of_Functions$(1)*255
   dim of_Function$*255
   def fnPopulateOrphanedFunctions(mat Functions$;___,Index,Jndex)
      ! Search functions folder and grab all the functions
      let Fnreadavailablefunctions(mat Functions$)

      ! Add the {}s
      for Index=1 to udim(mat Functions$)
         if Functions$(Index)(1:1)<>"{" then let Functions$(Index)(1:0)="{"
         if Functions$(Index)(len(Functions$(Index)):len(Functions$(Index)))<>"}" then let Functions$(Index)=Functions$(Index)&"}"
      next Index

      ! Duplicate that list.
      mat of_Functions$(udim(mat Functions$))=Functions$

      !  Loop through the duplicated list and delete any functions that are NOT used, in the end you'll have a list of all functions that ARE used
      let Index=0
      do while (Index+=1)<=udim(mat Functions$)
         mat AffectedScreens$(0)
         let of_Selected(1)=Index
         let fnceFindAffectedScreens(mat AffectedScreens$,mat of_Selected,mat Functions$)

         if udim(mat AffectedScreens$)=0 then
            ! If it is not used, remove it from the list
            for Jndex=Index to udim(mat Functions$)-1
               let Functions$(Jndex)=Functions$(Jndex+1)
            next Jndex
            mat Functions$(udim(mat Functions$)-1)
            let Index-=1 ! Go back down one because we removed one.
         end if
      loop

      !  Go through those functions with a parser written off of the Function Loading technology that searches for any functions that are #included. if they're not there, add them to the list.
      let Index=0
      do while (Index+=1)<=udim(mat Functions$)
         let of_Function$=Functions$(Index)
         let FnFindIncludes(of_Function$,mat Functions$)
      loop

      ! Go through the first list and delete any found in the second list, what you're left with is just the ones that are orphaned.
      let Index=0
      do while (Index+=1)<=udim(mat of_Functions$)
         if srch(mat Functions$,of_Functions$(Index))>0 then
            ! remove it from the list
            for Jndex=Index to udim(mat of_Functions$)-1
               let of_Functions$(Jndex)=of_Functions$(Jndex+1)
            next Jndex
            mat of_Functions$(udim(mat of_Functions$)-1)
            let Index-=1 ! Go back down one because we removed one.
         end if
      loop

      mat Functions$(udim(mat of_Functions$))=of_Functions$ ! Copy it back to return it
   fnend

   dim OF_Function$(1)*255

   dim OFLV_Spec$
   dim OFLV_Cap$(1)*30,OFLV_Width(1),OFLV_Spec$(1)

   def fnOrphanedFunctions(;___,Function,OrphanedFunctions,of_Selected,LoadMessage)
      ! Initialize PowerSearch Results Listview
      let OFLV_Spec$="1,1,LIST 22/30"

      ! Initialize PowerSearch Results Listview Columns
      let OFLV_Cap$(1)="Function"
      let OFLV_Width(1)=25
      let OFLV_Spec$(1)="C 255"

      mat OF_Function$(0)

      ! ! Initialize PowerSearch Buttons and Caption Specs
      mat ce_CapSpec$(1) : mat ce_Caption$(1)
      let ce_CapSpec$(1)="23,11,10/CC 17,/W:W,B36"   ! Print List

      let ce_Caption$(1)="Print"

      Open #(OrphanedFunctions:=fnGetFileNumber): "srow=4,scol=40,rows=23,cols=30,Border=s", display, outin

      print #OrphanedFunctions, fields mat ce_CapSpec$ : mat ce_Caption$
      print #OrphanedFunctions, fields OFLV_Spec$&",HEADERS,/W:W" : (mat OFLV_Cap$, mat OFLV_Width, mat OFLV_Spec$)

      Open #(LoadMessage:=fnGetFileNumber): "srow=13,scol=32,rows=3,cols=46,Border=s", display, outin
      Print #LoadMessage, fields "2,1,CC 40": "Loading .. Please Wait .."

      let fnPopulateOrphanedFunctions(mat OF_Function$)

      close #LoadMessage:

      if udim(mat OF_Function$) then
         ! Predraw listview if any data belongs in it
         print #OrphanedFunctions, fields OFLV_Spec$&",=" : (mat OF_Function$)
         do
            input #OrphanedFunctions, fields OFLV_Spec$&",ROWSUB,SELONE" : of_Selected

            let Function=fkey

            #Select# Function #Case# 36
               ! Print List
               fnPrintListToPrinterSimple(mat OF_Function$)
            #End Select#

         loop Until Function=99 Or Function=98 Or Function=93 Or ((Function>1100) And (Function<1699)) Or Function=19 or fkey=93
      else
         let msgbox("No Orphaned Functions found.","Nothing to display")
      end if
      if OrphanedFunctions and file(OrphanedFunctions)>-1 then close #OrphanedFunctions:
   fnend
!
!  #Autonumber# 70000,20
!  =================================================
!  =============== Screen Io Library ===============
!  =================================================
!   !                                             !
FM: !    This Is Where All The Magic Happens      !
    !                                             !
    !  *************               *************  !

   def library Fnfm$*255(Screenname$;Keyval$*255,Srow,Scol,Parent_Key$*255,Parent_Window,Display_Only,Dontredolistview,Recordval,Mat Passeddata$,Usemyf,Mat Myf$,Mat Myf,Path$*255,Selecting,SaveDontAsk)

      ! This function contains hidden code that prepares the memory and reticulates the splines.
      !  then calls fnScreenIO to run your screen.

      let Fnfm$=Fnmasterfm$(Screenname$,Keyval$,Srow,Scol,Parent_Key$,Parent_Window,Display_Only,Dontredolistview,Recordval,Path$,Selecting,0,0,0,Mat Passeddata$,Usemyf,Mat Myf$,Mat Myf,SaveDontAsk) !  #Autonumber# 70400,20
   fnend

!  #Autonumber# 71000,1
   ! Alternate Calls for Fnfm Above
   def library Fndisplayscreen(Screenname$;Keyval$*255,Srow,Scol,Parent_Key$*255,Parent_Window,Recordval,Path$*255,Selecting)
      let Fndisplayscreen=Val(Fnmasterfm$(Screenname$,Keyval$,Srow,Scol,Parent_Key$,Parent_Window,1,1,Recordval,Path$,Selecting))
   fnend
!
   def library Fnfm(Screenname$;Keyval$*255,Srow,Scol,Parent_Key$*255,Parent_Window,Display_Only,Dontredolistview,Recordval,Mat Passeddata$,Usemyf,Mat Myf$,Mat Myf,Path$*255,Selecting,SaveDontAsk,___,Returnvalue)
      let Fnfm=Fnreturnvalue(Fnmasterfm$(Screenname$,Keyval$,Srow,Scol,Parent_Key$,Parent_Window,Display_Only,Dontredolistview,Recordval,Path$,Selecting,0,0,0,Mat Passeddata$,Usemyf,Mat Myf$,Mat Myf,SaveDontAsk))
   fnend

   def fnMaster$*255(Screenname$;Keyval$*255,Srow,Scol,Parent_Key$*255,Parent_Window,Display_Only,Dontredolistview,Recordval,Path$*255,Selecting,Active,ForceThisIndex,Editing,Mat Passeddata$,Usemyf,Mat Myf$,Mat Myf,SaveDontAsk)
      let fnMaster$=fnMasterFm$(Screenname$,Keyval$,Srow,Scol,Parent_Key$,Parent_Window,Display_Only,Dontredolistview,Recordval,Path$,Selecting,Active,ForceThisIndex,Editing,Mat Passeddata$,Usemyf,Mat Myf$,Mat Myf,SaveDontAsk)
   fnend
   !
   def Fnmasterfm$*255(Screenname$;&Keyval$,Srow,Scol,&Parent_Key$,Parent_Window,Display_Only,Dontredolistview,Recordval,&Path_$,Selecting,Active,ForceThisIndex,Editing,Mat Passeddata$,Usemyf,Mat My_f$,Mat My_f,&SaveDontAsk,___,Exitmode,Lastrow,OutOfMemory)
      let fnCheckSerialMessage
      if Screenname$<>"" then
         let fnSettings
         let fnDefineExitModes

         ! We have to save this early to ensure its
         ! not clobbered in fnpushmemory
         ! but we also want to store passedInF$
         ! on the stack in case its changed
         ! in another screen further down so we
         ! need a 3rd set of temp variables
         mat AnotherTempMyF$(udim(mat My_F$))=My_F$
         mat AnotherTempMyF(udim(mat My_F))=My_F

         if ~Editing then
            if Loadedscreencount then
               let OutOfMemory=Fnpushmemory
            else
               let fnClearAllArrays
            end if
         end if

         if ~OutofMemory then
            if UseMyF then
               mat PassedInF$(udim(mat AnotherTempMyF$))=AnotherTempMyF$
               mat PassedInF(udim(mat AnotherTempMyF))=AnotherTempMyF
            end if

            let Loadedscreencount+=1
!
            mat OtherChanged_S_Data$(0)
            mat OtherChanged_S_Subs(0)
            mat Changed_S_Data$(0)
            mat Changed_S_Subs(0)
            mat Other_S_Data$(0)
            mat Other_S_Subs(0)

            do
               let Fnmasterfm$=Fnscreenio$(Screenname$,ExitMode,Keyval$,Srow,Scol,Parent_Key$,Parent_Window,Display_Only,Recordval,Path_$,Selecting,Active,ForceThisIndex,Editing,Mat Passeddata$,Usemyf,Mat PassedInF$,Mat PassedInF,SaveDontAsk)
            loop while ExitMode=Reload or ExitMode=AutoReload
!
            ! We have to save this to ensure its
            ! not clobbered in fnpopmemory
            if UseMyF then
               mat AnotherTempMyF$(udim(mat PassedInF$))=PassedInF$
               mat AnotherTempMyF(udim(mat PassedInF))=PassedInF
            end if
!
            let Loadedscreencount-=1
            if ~Editing then
               if Loadedscreencount then let Fnpopmemory((Display_Only or Dontredolistview or (fkey==93)))
            end if

            if UseMyF then
               mat My_F$(udim(mat AnotherTempMyF$))=AnotherTempMyF$
               mat My_F(udim(mat AnotherTempMyF))=AnotherTempMyF
            end if

         end if
      else
         let Msgbox("No routine name was given.")
      end if
      let fnCheckSerialSlowdown(12)
   fnend

   def fnWarnMessage(;___,ExpireDate,Invalid)
      let ExpireDate=days(fnScreenIOExpireDate$,"mm/dd/ccyy")
      if ~(fnCheckLicense or fnCheckFile) then
         if Env$("ScreenIOWarnMessage")><"Checked" then
            if days(date$("mm/dd/ccyy"),"mm/dd/ccyy")<ExpireDate then
               if fn43 then
                  let msgbox(`A ScreenIO License could not be found. You may play around with it freely until {{Date$(ExpireDate,"Month, DD CCYY")}}. After that, you will no longer be able to use the ScreenIO Designer, and the ScreenIO programs you have created will start to run more slowly.

                              Please contact Business Rules Corp for support, and obtain a valid license file before that time. Make sure to distribute your license file to all of your customers as well.

                              Gordon Dye of Business Rules Corp: (248)619-0400 or gordon.dye@brulescorp.com
                              Gabriel Bakker of Sage AX: (469) 223 5476 or gabriel.bakker@gmail.com`,"License File not Found")
               else
                  let msgbox("ScreenIO License not found. This copy expires on "&Date$(ExpireDate,"Month, DD CCYY"))
               end if
               SetEnv("ScreenIOWarnMessage","Checked")
            else
               if fn43 then
                  let msgbox(`A ScreenIO License could not be found. This copy expired on {{Date$(ExpireDate,"Month, DD CCYY")}}. You are no longer able to use the ScreenIO Designer, and the ScreenIO programs you have written will start to slow down.

                              Please contact Business Rules Corp for support and obtain a valid license file. Make sure to distribute your license file to all of your customers as well.

                              Gordon Dye of Business Rules Corp: (248)619-0400 or gordon.dye@brulescorp.com
                              Gabriel Bakker of Sage AX: (469) 223 5476 or gabriel.bakker@gmail.com`,"License File not Found")
               else
                  let msgbox("ScreenIO License not found. This copy expired on "&Date$(ExpireDate,"Month, DD CCYY"))
               end if
               let Invalid=1
            end if
         end if
      end if
      let fnWarnMessage=Invalid
   fnend

   def fnCheckSerialMessage ! Check that the Serial File is valid. If its not valid, print a warning message.
      if ~fnCheckSerial then
         if Env$("ScreenIOSerialMessage")><"Checked" then
            ! let msgbox("Your free trial period is over, and we were not able to detect a valid Business Rules ScreenIO License. Please contact Business Rules Corp or Sage AX to purchase a license.")
            let msgbox("This copy of ScreenIO is unlicensed. It expired on "&Date$(days(fnScreenIOExpireDate$,"mm/dd/ccyy"),"Month DD, CCYY")&"."&hex$("0D0A0D0A")&"Please make sure you have a valid license file. Contact your Software Vendor or contact Business Rules Corp for support."&hex$("0D0A0D0A")&"Gordon Dye of Business Rules Corp: (248) 619-0400 or gordon.dye@brulescorp.com"&hex$("0D0A")&"Gabriel Bakker of Sage AX: (469) 223 5476 or gabriel.bakker@gmail.com","License File not Found")
            SetEnv("ScreenIOSerialMessage","Checked")
         end if
      end if
   fnend

   def fnCheckSerialSlowdown(;SlowdownMultiply) ! Check that the Serial File is valid. If its not valid, slow things down.
      if ~SlowDownMultiply then let SlowDownMultiply=1

      if ~fnCheckSerial(SlowDownFactor) then
         Sleep(SlowDownFactor * SlowDownMultiply)
      end if
   fnend

   def fnScreenIOExpireDate$="12/31/2023"

   def fnCheckSerial(;&SlowDownFactor,___,ExpireDate$)
      ! Check the BR Serial, check if ScreenIO is active?
      ! Check inactive date?
      ! Calculate Slowdown factor?
      if fnCheckLicense or fnCheckFile then
         let fnCheckSerial=1
      else
         ! Demo Mode
         let ExpireDate$=fnScreenIOExpireDate$
         if days(date$("mm/dd/ccyy"),"mm/dd/ccyy")<days(ExpireDate$,"mm/dd/ccyy") then
            let fnCheckSerial=1
         else
            let fnCheckSerial=0
            let SlowDownFactor=min((0.002*(days(date$("mm/dd/ccyy"),"mm/dd/ccyy")-days(ExpireDate$,"mm/dd/ccyy"))),.8)
         end if
      end if
   fnend

   def fnCheckLicense
      if fn432c and trim$(env$("license.screenio"))>="2.0" then
         let fnCheckLicense=1
      else if trim$(env$("license.screenio"))="" and ~fn433 and fnCheckLicenseWorkAround>=2 then
         let fnCheckLicense=1
      end if
   fnend

   def fnCheckLicenseWorkAround(;___,FileNumber,String$*255,P,V)
      let fnSettings
      execute "st env 'license.screenio""' >check[session].out" error Check2Failed
      open #(FileNumber:=fnGetFileNumber) : "name=check[session].out, recl=255", display, input error Ignore
      do until file(FileNumber)
         linput #FileNumber: String$ error Ignore
         if File(FileNumber)=0 and ~pos(lwrc$(String$),"""clipboard""") and pos(lwrc$(String$),"license.screenio""") then
            let p=pos(lwrc$(String$)," is ")
            if p>0 then
               let String$=String$(p+4:len(String$))
               let String$=trim$(String$,"""")
               let V=val(String$)
               let fnCheckLicenseWorkAround=V
            end if
         end if
      loop until V
      close #FileNumber:
      execute "*free check[session].out" error Ignore
      Check2Failed: ! We come here if Check License 2 fails.
   fnend

   def fnCheckFile
      if ~fn433 and exists("sio.lic") then
         library "sio.lic" : fnCSXYCWQLSKJAFLANL error Ignore
         if fnCSXYCWQLSKJAFLANL(12073) then
            let fnCheckFile=1
         end if
      end if
   fnend

!  #Autonumber# 75000,2

ScreenIODims: !
   dim F$(1)*1000,F(1),S$(1)*1000
   dim Screensubs$(1)*80
   dim Read_F$(1)*1000,Read_F(1)
   dim Disk_F$(1)*1000,Disk_F(1)
!
   dim Save_F$(1)*1000,Save_F(1),Save_S$(1)*1000
!
   dim Selectedkeys$(1)*255
   dim Selectedrecords(1)

   dim VisibleKeys$(1)*255
   dim VisibleRecords(1)
!
   dim S_Data$(1)*1000,S_Data(1),S_Spec$(1)*255, S_Help$(1)*1050, S_Old$(1)*1000
   dim Temp_S_Spec$(1)*255
   dim Old_Data(1)

   dim Save_S_Data$(1)*1000
   dim Save_S_Subs(1)
   dim Changed_S_Data$(1)*1000
   dim Changed_S_Subs(1)
   dim Other_S_Data$(1)*1000
   dim Other_S_Subs(1)
   dim OtherChanged_S_Data$(1)*1000
   dim OtherChanged_S_Subs(1)

   dim ReturnData$(1)*255
   dim ControlSpec$(1)*128
   dim Screeniossubs$(1)*40
   dim Screenionsubs$(1)*40

   dim TempIndex
   dim TempControl
   dim TempField
   dim FoundAlready
EndScreenIODims: !
!
   dim Loadedscreencount
   def library fnFunctionBase=fnKeyBase
   def fnStickyBase=fnKeyBase+500
   def fnKeyBase=(fnBase+(200*LoadedScreenCount))
   def fnBase=1500

   dim PassedInF$(1)*1023,PassedInF(1)
   dim AnotherTempMyF$(1)*1023,AnotherTempMyF(1)


   def Fnscreenio$*255(Routinename$,&ExitMode;&Key$,Row,Col,&Parentkey$,Parentwindow,Displayonly,Record,&Path$,Selecting,Active,ForceThisIndex,Editing,Mat Passeddata$,Usemyf,Mat Myf$,Mat Myf,&SaveDontAsk,___,Fdatafile,Wwindow,Function,Kp$,Prefix$,Index,Currentfield,CurrentField$*50,S_CurrentField$*50,Screenrows,Screencols,Turnguibackoff,Librarylinkage,Oldrows,Oldcols,Oldwindowcaption$*255,Fscreenio,Fscreenfld,Screenioprefix$,Subscriptsalreadyset,Currentkey$*255,CurrentRec,S_CurrentRec,Listviewindex,Returnwindownumber,_Bordersize,Currentrow,S_Currentrow,Myfread,Forceindex,X,ForceVisibility,RedrawFrames,RedrawScreens,RepopulateCombo,NextRow)
      let Fnestablishlibrarylinkage

      mat F(0)=(0)
      mat F$(0)=("")
      mat S$(0)=("")

      let ExitMode=0
!
      let Fnreadlayoutarrays("screenio",Screenioprefix$,Mat Screeniossubs$,Mat Screenionsubs$)
!
!     If Exists(Lwrc$(Routinename$)&".br") Then
!        Execute "LOAD "&Lwrc$(Routinename$)&", RESIDENT"
!     End If
!
      let Routinename$=Uprc$(Trim$(Routinename$))

      let Fnopenscreenfiles(Mat Screenio$,Mat Screenio)
      if Fnreadscreen(Routinename$, Mat Screenio$, Mat Screenio, [[Screencontrols]],1) then !  Successful Read
         let Fnclosescreenfiles

         let Fninitializescreen
         if Displayonly then
            if TryToContinue then ! if we forced the continue then
               ! We must be in ReadOnly mode because we forced the continue
               !  rather then because of the DisplayOnly parameter,
               !  so screenio locking is off, and we should just pause
               input #0, fields Str$(Row+1)&","&Str$(Col+1)&",C 1,AEX" : Kp$
            else
               ! We're here because of DisplayOnly parameter. Pass back
               !  the window number and then suppress it to keep the window
               !  from being closed. The Calling Program will close it later.
               let Returnwindownumber=Wwindow
               let Wwindow=0
            end if
         else
            let Fnrunscreen
         end if
         let Fnclosescreen
         if Returnwindownumber then
            let Key$=Str$(Returnwindownumber)
         end if
      else
         let Fnclosescreenfiles

         let Msgbox("The screen "&Trim$(Routinename$)&" could not be found.")
      end if
      let Fnscreenio$=Key$
   fnend
!
   dim QuitOnly,SaveAndQuit,SelectAndQuit,QuitOther,AskSaveAndQuit,Reload,AutoReload
   def fnDefineExitModes ! Configure Exit Value Constants
      let Quitonly=1
      let Saveandquit=2
      let Selectandquit=3
      let Quitother=4
      let Asksaveandquit=5
      let Reload=6
      let AutoReload=7
   fnend

! .! =================================================================
INITIALIZESCREEN: ! This Function Contains The Portion Of The Runtime Engine For Loading And Displaying Your Screen
! .! =================================================================
   def Fninitializescreen(;___,R_,C_,WarnWindow,PopulateRowOne)
!
      mat Selectedkeys$(0)
      mat Selectedrecords(0)

      mat VisibleKeys$(0)
      mat Visiblerecords(0)

      if Screenio(Si_Border) Or Pos(Uprc$(Screenio$(Si_Attributes)),"BORDER") then
         let _Bordersize=2
      end if
!
      if Env$("guimode")<>"" then
         if Fnrequiresgui(Mat Screenio$,Mat Screenio, [[Screencontrols]]) then
            if Env$("guimode")="OFF" then
               let fnPreserveNonGui
               let Turnguibackoff=1
            end if
!
            let FnReadScreensize(Rows,Cols,ParentWindow)
!
            if Row and Col then
               let R_=Row-1-(_Bordersize/2)
               let C_=Col-1-(_Bordersize/2)
            end if
            if pos(lwrc$(screenio$(Si_Attributes)),"parent=none")<1 then
               if (R_+Screenio(Si_Vsize)+_Bordersize)>Rows Or (C_+Screenio(Si_Hsize)+_Bordersize)>Cols then
                  if ParentWindow then
                     if (2==msgbox("This window ("&trim$(screenio$(si_screencode))&") is bigger then its parent window (#"&str$(parentwindow)&"). Do you wish to debug?","Error","yN")) then
                        pause
                     end if
                     let ExitMode=1
                  else
                     let Oldrows=Rows
                     let Oldcols=Cols
                     let Rows=Max(R_+Screenio(Si_Vsize)+_Bordersize,Rows)
                     let Cols=Max(C_+Screenio(Si_Hsize)+_Bordersize,Cols)
                     open #0: "rows="&Str$(Rows)&", cols="&Str$(Cols),display,outin
                  end if
               end if
            end if
            if Trim$(Screenio$(Si_Caption))<>"" then
               if Len(Trim$(Env$("Window_Caption"))) then
                  let Oldwindowcaption$=Trim$(Env$("Window_Caption"))
               end if
               print #0, border: Trim$(Screenio$(Si_Caption))
               let Setenv("Window_Caption",Trim$(Screenio$(Si_Caption)))
            end if
!            Let Fnclearwindowsmenu
         end if
      else
         if Fnrequiresgui(Mat Screenio$, Mat Screenio, [[Screencontrols]]) then
            print "This screen requires a new gui version of BR"
            let Exitmode=1
         end if
      end if
!
      if ~Row Or ~Col then
         if Rows=0 Or Cols=0 then
            let Fnreadscreensize(Rows,Cols,ParentWindow)
         end if
         let Row=Int((Rows-(Screenio(Si_Vsize)+_Bordersize))/2)+1+Int(_Bordersize/2)
         let Col=Int((Cols-(Screenio(Si_Hsize)+_Bordersize))/2)+1+Int(_Bordersize/2)
      end if
!
      if ~Exitmode then
         let fnSetforcevisibility(0)

         let Wwindow=Fnopenwindow(Row,Col,Mat Screenio$,Mat Screenio,Parentwindow,DisplayOnly,ForceThisIndex,Active,Editing)
!
         let fnResetForceVisibility
         let Fninitializemats(Mat S$,Mat Screensubs$,[[Screencontrols]])
         let Fnexecutesetsubscripts(Mat Screensubs$,"sio_")
         let Fnexecutesetsubscripts(Mat Controlname$,"ctl_")
         let fnExecuteUniqueSubscripts(Mat ControlName$,"ctl_")

         mat Fieldsssubs$(0)
         mat Fieldsnsubs$(0)
!
         if ~Editing or Pos(Uprc$(Env$("filter")),"Y") then
            if ~Editing and Setting_EnableLogging then
               let fnLog("ScreenIO: Entering "&ScreenIO$(si_screencode)&" screen.",setting_ScreenFolder$&"\"&ScreenIO$(Si_ScreenCode))
            end if

            if Trim$(Screenio$(Si_Filelay))<>"" And Fndoeslayoutexist(Trim$(Screenio$(Si_Filelay))) then
               if Usemyf then
                  mat F$(Udim(Mat Myf$))
                  mat F(Udim(Mat Myf))
                  if ~Sum(Myf) then
                     for Index=1 to Udim(Mat Myf$)
                        if Len(Trim$(Myf$(Index))) then
                           let Myfread=1
                        end if
                     next Index
                  else
                     let Myfread=1
                  end if
               else
                  let Fdatafile=Fnopen(Trim$(Screenio$(Si_Filelay)),Mat F$,Mat F,Mat Form$,0,Screenio(Si_Readindex),0,Path$)
               end if

!    .         ! Read the Layout
               let Fnreadlayoutarrays(Trim$(Screenio$(Si_Filelay)),Prefix$,Mat Fieldsssubs$,Mat Fieldsnsubs$,Mat Fieldssspec$,Mat Fieldsnspec$,Mat Fieldssdescription$,Mat Fieldsndescription$,mat FieldsSPos,mat FieldsNPos,0,mat FieldsSDateSpec$,mat FieldsNDateSpec$)
               for Index=1 to Udim(Mat Fieldsssubs$)
                  let Fieldsssubs$(Index)=Lwrc$(Trim$(Fieldsssubs$(Index)))
               next Index
               for Index=1 to Udim(Mat Fieldsnsubs$)
                  let Fieldsnsubs$(Index)=Lwrc$(Trim$(Fieldsnsubs$(Index)))
               next Index

!    .         ! Here is where we link to our DEFAULT ENTER event
               if exists(setting_FunctionFolder$&"defaults\") then
                  if exists(setting_FunctionFolder$&"defaults\enter.brs") then
                     let fnExecute(fnFunctionString$(setting_FunctionFolder$&"defaults\enter.brs"))
                  end if
               end if
!
!    .         ! Here is where we link to our ENTER event
               if Len(Trim$(Screenio$(Si_Enterfn))) then
                  let Fnexecute(Screenio$(Si_Enterfn))
               end if
!
               let TryToContinue=0

               ! Read the File
               if Key$<>"" then
                  if DisplayOnly then
                     read #Fdatafile, using Form$(Fdatafile), key=Fnkey$(Fdatafile,Key$), release : Mat F$, Mat F nokey Ignore
                  else if ScreenIO(si_ScreenIOLocking) then
                     ! We have to read the record first to ensure the record isn't locked by any legacy applications.
                     let WarnWindow=fnDisplayLoadMessage

                     let fnSetRetryPoint("ErrorLocked1")
                     ErrorLocked1Retry: ! Error Locked Retry Point
                     read #Fdatafile, using Form$(Fdatafile), key=Fnkey$(Fdatafile,Key$) : Mat F$, Mat F nokey Ignore locked ErrorFileIsLocked
                     ErrorLocked1Continue: ! Error Locked Continue Point

                     close #WarnWindow:
                     if TryToContinue then
                        read #Fdatafile, using Form$(Fdatafile), key=Fnkey$(Fdatafile,Key$), release : Mat F$, Mat F nokey Ignore
                     end if
                     if ~ExitMode then
                        reread #Fdatafile, using Form$(Fdatafile), release : Mat F$, Mat F nokey Ignore
                     end if
                  else
                     let WarnWindow=fnDisplayLoadMessage

                     let fnSetRetryPoint("ErrorLocked2")
                     ErrorLocked2Retry: ! Error Locked Retry Point
                     read #Fdatafile, using Form$(Fdatafile), key=Fnkey$(Fdatafile,Key$) : Mat F$, Mat F nokey IGNORE locked ErrorFileIsLocked
                     ErrorLocked2Continue: ! Error Locked Continue Point

                     Close #WarnWindow:
                     if TryToContinue then
                        read #Fdatafile, using Form$(Fdatafile), key=Fnkey$(Fdatafile,Key$), release : Mat F$, Mat F nokey Ignore
                        let DisplayOnly=1
                     end if
                  end if
                  mat Read_F$(udim(mat F$))=F$
                  mat Read_F(udim(mat F))=F
!
                  if File(Fdatafile)<>0 then ! Key Not Found
                     if Exitmode=0 then

                        ! .   ! Here's where we link to our NoKey event
                        if Len(Trim$(Screenio$(Si_nokeyfn))) then
                           let Fnexecute(Screenio$(Si_NoKeyFn))
                        else

                           if exists(setting_FunctionFolder$&"defaults\") then
                              if exists(setting_FunctionFolder$&"defaults\nokey.brs") then
                                 let fnExecute(fnFunctionString$(setting_FunctionFolder$&"defaults\nokey.brs"))
                              else
                                 let Msgbox("The '"&Key$&"' record could not be found.","Not Found","Ok","Err")
                                 let Exitmode=1
                              end if
                           else
                              let Msgbox("The '"&Key$&"' record could not be found.","Not Found","Ok","Err")
                              let Exitmode=1
                           end if
                        end if
                     end if
                  else
                     let Currentkey$=Fnbuildkey$(Trim$(Screenio$(Si_Filelay)),Mat F$,Mat F,Screenio(Si_Returnindex))
                     let CurrentRec=rec(FDataFile)

                     if exists(setting_FunctionFolder$&"defaults\") then
                        if exists(setting_FunctionFolder$&"defaults\read.brs") then
                           let fnExecute(fnFunctionString$(setting_FunctionFolder$&"defaults\read.brs"))
                        end if
                     end if

!    .               ! Here is where we link to our READ event
                     if ~Editing and Setting_EnableLogging then let fnLogArray(mat F$,mat F,"ScreenIO: Reading "&Screenio$(Si_Filelay)&" file, Record: "&str$(CurrentRec),setting_ScreenFolder$&"\"&ScreenIO$(Si_ScreenCode))
                     if Len(Trim$(Screenio$(Si_Readfn))) then
                        let Fnexecute(Screenio$(Si_Readfn))
                     end if
                  end if
               else if Record>0 then
                  if DisplayOnly then
                     read #Fdatafile, using Form$(Fdatafile), rec=Record, release : Mat F$, Mat F norec Ignore
                  else if ScreenIO(si_ScreenIOLocking) then
                     ! We have to read the record first to ensure the record isn't locked by any legacy applications.
                     let WarnWindow=fnDisplayLoadMessage

                     let fnSetRetryPoint("ErrorLocked3")
                     ErrorLocked3Retry: ! Error Locked Retry Point
                     read #Fdatafile, using Form$(Fdatafile), rec=Record : Mat F$, Mat F norec Ignore locked ErrorFileIsLocked
                     ErrorLocked3Continue: ! Error Locked Continue Point

                     close #WarnWindow:
                     if TrytoContinue then
                        read #Fdatafile, using Form$(Fdatafile), rec=Record, release : Mat F$, Mat F norec Ignore
                     end if
                     if ~ExitMode then
                        reread #Fdatafile, using Form$(Fdatafile), release : Mat F$, Mat F norec Ignore
                     end if
                  else
                     let WarnWindow=fnDisplayLoadMessage

                     let fnSetRetryPoint("ErrorLocked4")
                     ErrorLocked4Retry: ! Error Locked Retry Point
                     read #Fdatafile, using Form$(Fdatafile), rec=Record : Mat F$, Mat F norec Ignore locked ErrorFileIsLocked
                     ErrorLocked4Continue: ! Error Locked Continue Point

                     close #WarnWindow:
                     if TryToContinue then
                        read #Fdatafile, using Form$(Fdatafile), rec=Record, release : Mat F$, Mat F nokey Ignore
                        let DisplayOnly=1
                     end if
                  end if

                  mat Read_F$(udim(mat F$))=F$
                  mat Read_F(udim(mat F))=F
!
                  if File(Fdatafile)<>0 then ! Key Not Found
                     if Exitmode=0 then
                        if Len(Trim$(Screenio$(Si_nokeyfn))) then
                           let Fnexecute(Screenio$(Si_NoKeyFn))
                        else
                           if exists(setting_FunctionFolder$&"defaults\") then
                              if exists(setting_FunctionFolder$&"defaults\nokey.brs") then
                                 let fnExecute(fnFunctionString$(setting_FunctionFolder$&"defaults\nokey.brs"))
                              else
                                 let Msgbox("The '"&Key$&"' record could not be found.","Not Found","Ok","Err")
                                 let Exitmode=1
                              end if
                           else
                              let Msgbox("The '"&Key$&"' record could not be found.","Not Found","Ok","Err")
                              let Exitmode=1
                           end if
                        end if
                     end if
                  else
!    .               ! Here is where we link to our READ event
                     let Currentkey$=Fnbuildkey$(Trim$(Screenio$(Si_Filelay)),Mat F$,Mat F,Screenio(Si_Returnindex))
                     let CurrentRec=rec(FDataFile)
                     if ~Editing and Setting_EnableLogging then let fnLogArray(mat F$,mat F,"ScreenIO: Reading "&Screenio$(Si_Filelay)&" file, Record: "&str$(CurrentRec)&" Key: "&CurrentKey$,setting_ScreenFolder$&"\"&ScreenIO$(Si_ScreenCode))

                     if exists(setting_FunctionFolder$&"defaults\") then
                        if exists(setting_FunctionFolder$&"defaults\read.brs") then
                           let fnExecute(fnFunctionString$(setting_FunctionFolder$&"defaults\read.brs"))
                        end if
                     end if

                     if Len(Trim$(Screenio$(Si_Readfn))) then
                        let Fnexecute(Screenio$(Si_Readfn))
                     end if
                  end if
               else if Usemyf And Myfread then
                  mat F$=Myf$
                  mat F=Myf

                  mat Read_F$(udim(mat F$))=F$
                  mat Read_F(udim(mat F))=F
!
                  if exists(setting_FunctionFolder$&"defaults\") then
                     if exists(setting_FunctionFolder$&"defaults\read.brs") then
                        let fnExecute(fnFunctionString$(setting_FunctionFolder$&"defaults\read.brs"))
                     end if
                  end if

!    .            ! Here is where we link to our READ event
                  if ~Editing and Setting_EnableLogging then let fnLogArray(mat F$,mat F,"ScreenIO: Data passed in",setting_ScreenFolder$&"\"&ScreenIO$(Si_ScreenCode))
                  if Len(Trim$(Screenio$(Si_Readfn))) then
                     let Fnexecute(Screenio$(Si_Readfn))
                  end if
               else
                  mat Read_F$(udim(mat F$))=F$
                  mat Read_F(udim(mat F))=F

!    .            ! Here is where we link to our INITIALIZE event
                  if exists(setting_FunctionFolder$&"defaults") then
                     if exists(setting_FunctionFolder$&"defaults\init.brs") then
                        let fnExecute(fnFunctionString$(setting_FunctionFolder$&"defaults\init.brs"))
                     end if
                  end if

                  if Len(Trim$(Screenio$(Si_Initfn))) then
                     let Fnexecute(Screenio$(Si_Initfn))
                  end if
                  if ~Editing and Setting_EnableLogging then let fnLogArray(mat F$,mat F,"ScreenIO: Initializing Record for "&Screenio$(Si_Filelay)&" file.",setting_ScreenFolder$&"\"&ScreenIO$(Si_ScreenCode))
               end if
            else
               mat Read_F$(udim(mat F$))=F$
               mat Read_F(udim(mat F))=F

               if exists(setting_FunctionFolder$&"defaults\") then
                  if exists(setting_FunctionFolder$&"defaults\enter.brs") then
                     let fnExecute(fnFunctionString$(setting_FunctionFolder$&"defaults\enter.brs"))
                  end if
               end if

!    .         ! Here is where we link to our ENTER event
               if Len(Trim$(Screenio$(Si_Enterfn))) then
                  let Fnexecute(Screenio$(Si_Enterfn))
               end if
            end if
         end if
      end if

! .   ! Draw the screen and populate any listviews
      if ~Exitmode then
         if Displayonly then let Forceindex=Wwindow+1000
         if ForceThisIndex then let ForceIndex=ForceThisIndex

         let fnPopulateCombo(Wwindow,Fdatafile,Mat Fieldsssubs$,Mat Fieldsnsubs$,Mat S$,Mat Screensubs$,Mat Form$,[[Screencontrols]],0,(Editing and ~Pos(Uprc$(Env$("filter")),"Y")),Editing)
!
! .      Predisplay Output Specs
         let fnChangeForceVisibility(0)
         let fnDrawFrames(WWindow,mat ScreenIO$,mat ScreenIO,[[ScreenControls]],1,ForceIndex)
         if ~Editing then let fnDrawScreens(WWindow,mat ScreenIO$,mat ScreenIO,[[ScreenControls]],1,ForceIndex)
         let Fngenerateoutputspecs(WWindow,Mat S_Data$,Mat S_Spec$,Mat S_Help$,Mat S$,Mat Screensubs$,[[Screencontrols]],mat ControlSpec$,Forceindex)
         let fnChangeforcevisibility(1)
         if Udim(Mat S_Spec$) then
            print #Wwindow, fields Mat S_Spec$, help Mat S_Help$ : Mat S_Data$
         end if
         mat Temp_S_Spec$(Udim(Mat S_Spec$))=S_Spec$
!
! .      Predisplay Input Specs
         let Fngenerateinputspecs(WWindow,Mat S_Data$,Mat S_Data,Mat S_Spec$,Mat S_Subs,Mat S_Help$,Mat S_Old$,Mat F$,Mat F,Mat Fieldsssubs$,Mat Fieldsnsubs$,Mat S$,Mat Screensubs$,Listviewindex,[[Screencontrols]],mat ControlSpec$,Forceindex)
         if ~(Udim(Mat S_Data)) then
            print #Wwindow, fields Mat S_Spec$, help Mat S_Help$ : Mat S_Data$
         end if
!
         if fnTheresAListview(mat FieldType$) then
            let Fndrawalllistviews(Wwindow,Mat Screenio$,Mat Screenio,[[Screencontrols]],1,Forceindex)
            let Lastrow=Fnpopulatealllistviews(Wwindow,Fdatafile,Mat Fieldsssubs$,Mat Fieldsnsubs$,Mat S$,Mat Screensubs$,Mat Form$,mat ListviewRecords,[[Screencontrols]],0,(Editing and ~Pos(Uprc$(Env$("filter")),"Y")),Editing,PopulateRowOne,Displayonly)
            mat Old_Data=(0) ! Clear information so it forces read again.
            Mat Rlv_Savereaddata$=("")
            if fn43 then let CurrentRow=PopulateRowOne  ! In 4.3, sorted listviews don't start at the top, so we have to force them.
            let S_CurrentRow=0
            if Listviewindex And Currentrow<>S_Currentrow then
               let Curfld(Udim(Mat S_Data$)+1,Currentrow)
            end if
            mat Old_Data(Udim(Mat S_Data))

            ! Preread the listview in case they have a read event, so it runs the currently selected item first
            if ListviewIndex and udim(mat s_data) and (~DisplayOnly or len(trim$(screenio$(si_readfn)))) then
               let s_data(1)=1
               let Fnreadlistviews(Function,Mat F$, Mat F, Currentkey$,CurrentRec,Mat Selectedkeys$,Mat Selectedrecords,mat VisibleKeys$,mat VisibleRecords,Mat S_Data,Mat S_Spec$,Listviewindex,Mat Old_Data,Wwindow,Fdatafile,Mat Form$, Mat Screenio$, Mat Screenio, [[Screencontrols]],NextRow)
            end if
         end if

         if ~Editing or Pos(Uprc$(Env$("filter")),"Y") or LEN(TRIM$(SCREENIO$(SI_LOADFN))) then
            if Displayonly then
! .            redisplay Output Specs
               if RedrawFrames or RedrawScreens then let scr_freeze
               if RepopulateCombo then let fnPopulateCombo(Wwindow,Fdatafile,Mat Fieldsssubs$,Mat Fieldsnsubs$,Mat S$,Mat Screensubs$,Mat Form$,[[Screencontrols]],0,0,0,RepopulateCombo) : RepopulateCombo=0
               if RedrawFrames then let fnDrawFrames(WWindow,mat ScreenIO$,mat ScreenIO,[[ScreenControls]],1,ForceIndex, RedrawFrames) : let RedrawFrames=0
               if RedrawScreens then let fnDrawScreens(WWindow,mat ScreenIO$,mat ScreenIO,[[ScreenControls]],1,ForceIndex, RedrawScreens) : let RedrawScreens=0

               let Fngenerateoutputspecs(WWindow,Mat S_Data$,Mat S_Spec$,Mat S_Help$,Mat S$,Mat Screensubs$,[[Screencontrols]],mat ControlSpec$,Forceindex)
               if Udim(Mat S_Spec$) then
                  print #Wwindow, fields Mat S_Spec$, help Mat S_Help$ : Mat S_Data$
               end if
               mat Temp_S_Spec$(Udim(Mat S_Spec$))=S_Spec$
!
! .!    .      redisplay Input Specs
               let Fngenerateinputspecs(WWindow,Mat S_Data$,Mat S_Data,Mat S_Spec$,Mat S_Subs,Mat S_Help$,Mat S_Old$,Mat F$,Mat F,Mat Fieldsssubs$,Mat Fieldsnsubs$,Mat S$,Mat Screensubs$,Listviewindex,[[Screencontrols]],mat ControlSpec$,Forceindex)
               if ~(Udim(Mat S_Data)) then
                  print #Wwindow, fields Mat S_Spec$, help Mat S_Help$ : Mat S_Data$
               end if
            end if
         end if

         ! Link to the default Load event.
         if exists(setting_FunctionFolder$&"defaults\") then
            if exists(setting_FunctionFolder$&"defaults\load.brs") then
               let fnExecute(fnFunctionString$(setting_FunctionFolder$&"defaults\load.brs"))
            end if
         end if

 !       ! Here is where we link to our LOAD event
         IF LEN(TRIM$(SCREENIO$(SI_LOADFN))) THEN
            LET FNEXECUTE(SCREENIO$(SI_LOADFN))
         END IF
      end if
!
   fnend
!
! .! =================================================================
RUNSCREEN: ! This Function Contains The Portion Of The Runtime Engine For Actually Using Your Screen.
! .! =================================================================
   def Fnrunscreen(;___,Waittime,Ch,Theresanl,SaveScreenData,LoopAgain,WarnWindow,FindStickies,Position,Listviewspec$*40,MaxRow,DefaultMainloopFunction,DebugYN)
!
      if exists(setting_FunctionFolder$&"defaults\") then
         if exists(setting_FunctionFolder$&"defaults\mainloop.brs") then
            let DefaultMainloopFunction=1
         end if
      end if

      let Fkey(-1)

      mat Save_F(Udim(Mat F))=F
      mat Save_F$(Udim(Mat F$))=F$
      mat Save_S$(Udim(Mat S$))=S$
!
      do Until Exitmode
! .! .   If There's Output Specs, Generate Output Specs And Print Output Controls (Buttons, Pictures, Captions)
         if RepopulateCombo then
            let fnPopulateCombo(Wwindow,Fdatafile,Mat Fieldsssubs$,Mat Fieldsnsubs$,Mat S$,Mat Screensubs$,Mat Form$,[[Screencontrols]],0,0,0,RepopulateCombo)
            let RepopulateCombo=0
         end if
         if RedrawFrames then
            scr_freeze
            let fnDrawFrames(WWindow,mat ScreenIO$,mat ScreenIO,[[ScreenControls]],1,ForceIndex,RedrawFrames)
            let RedrawFrames=0
         end if
         if RedrawScreens then
            scr_freeze
            let fnDrawScreens(WWindow,mat ScreenIO$,mat ScreenIO,[[ScreenControls]],1,ForceIndex,RedrawScreens)
            let RedrawScreens=0
         end if

         let fnEraseInvisible(WWindow,[[ScreenControls]])

         let Fngenerateoutputspecs(WWindow,Mat S_Data$,Mat S_Spec$,Mat S_Help$,Mat S$,Mat Screensubs$,[[Screencontrols]],mat ControlSpec$)
         if Udim(Mat S_Spec$) then
            let fnChangeForceVisibility(1)
            let Fnblankoldsfields$(Mat S_Spec$,Mat Temp_S_Spec$,Wwindow)
            print #Wwindow, fields Mat S_Spec$, help Mat S_Help$ : Mat S_Data$
            let fnResetForceVisibility
         end if
         mat Temp_S_Spec$(Udim(Mat S_Spec$))=S_Spec$
!
         ! we need to do the same thing for input specs that we do for output specs, in case invisible changed.
         !  but we need to make sure this only happens if it has to.
         ! dim Temp_SI_Spec$(1)*255
         let Fngenerateinputspecs(WWindow,Mat S_Data$,Mat S_Data,Mat S_Spec$,Mat S_Subs,Mat S_Help$,Mat S_Old$,Mat F$,Mat F,Mat Fieldsssubs$,Mat Fieldsnsubs$,Mat S$,Mat Screensubs$,Listviewindex,[[Screencontrols]],mat ControlSpec$)
         ! if udim(mat Temp_SI_Spec$) then
         !    let Fnblankoldsfields$(Mat S_Spec$,Mat Temp_SI_Spec$,Wwindow)
         ! end if
         ! mat Temp_SI_Spec$(Udim(Mat S_Spec$))=S_Spec$


         if Listviewindex then let Theresanl=Fnattribute("L",Listviewindex,[[Screencontrols]])
!
         if Screenio(Si_Waittime) then
            let Waittime=Screenio(Si_Waittime)
         else
            let Waittime=-1
         end if
!
         if Udim(Mat S_Data$) + Udim(Mat S_Data) then
!

            ! Handle repositioning of Current Row by Record or by Row if either is given.
            if Listviewindex then

               ! If CurrentRow is negative, treat like CurrentRec is negative.
               if CurrentRow<>S_CurrentRow and CurrentRec=S_CurrentRec and CurrentRow<0 then
                  let CurrentRec=CurrentRow
                  let CurrentRow=S_CurrentRow
               end if

               if CurrentRec<>S_CurrentRec then
                  if CurrentRec<0 then
                     let Listviewspec$=S_Spec$(Udim(Mat S_Spec$))
                     let Listviewspec$=Listviewspec$(1:Pos(Listviewspec$,",",-1)-1)
                     let Listviewspec$=Listviewspec$(1:Pos(Listviewspec$,",",-1)-1)

                     if fn43 then
                        input #WWindow, fields Listviewspec$&",ROWSUB,ALL,DISPLAYED_ORDER,NOWAIT" : mat PopulateSortedSubs
                        let MaxRow=udim(mat PopulateSortedSubs)

                        if CurrentRec=-1 then
                           let CurrentRow=PopulateSortedSubs(1)
                        else if CurrentRec<=-2 then
                           let CurrentRow=PopulateSortedSubs(MaxRow)
                        else if CurrentRec>-2 and CurrentRec<-1 then
                           let CurrentRow=PopulateSortedSubs(max(min(1,int(MaxRow*(CurrentRec+1)*(-1))),MaxRow))
                        else if CurrentRec>-1 and CurrentRec<0 then
                           let CurrentRow=PopulateSortedSubs(max(min(1,int(MaxRow*CurrentRec*(-1))),MaxRow))
                        end if
                     else
                        input #WWindow, fields Listviewspec$&",ROWCNT,ALL" : MaxRow

                        if CurrentRec=-1 then
                           let CurrentRow=1
                        else if CurrentRec<=-2 then
                           let CurrentRow=MaxRow
                        else if CurrentRec>-2 and CurrentRec<-1 then
                           let CurrentRow=max(min(1,int(MaxRow*(CurrentRec+1)*(-1))),MaxRow)
                        else if CurrentRec>-1 and CurrentRec<0 then
                           let CurrentRow=max(min(1,int(MaxRow*CurrentRec*(-1))),MaxRow)
                        end if
                     end if
                  else if CurrentRec>0 then
                     if srch(mat LV_Records,CurrentRec)>0 then
                        let CurrentRow=srch(mat ListviewRecords,CurrentRec)
                     end if
                  end if
               end if
               if Currentrow<>S_Currentrow then
                  let Curfld(Udim(Mat S_Data$)+1,Currentrow)
               end if
            end if

            mat Old_Data(Udim(Mat S_Data))
            ! mat Old_Data(Udim(Mat S_Data))=S_Data
            ! let msgbox("Setting Old_Data(1)="&str$(Old_Data(1))&" : S_Data(1)="&str$(S_Data(1)))
!
            ! Apply CurrentField$ if its been changed.
            if CurrentField$<>S_CurrentField$ then
               if CurrentField$<>"" then
                  let TempControl=0
                  let TempField=0
                  let FoundAlready=0
                  let Function=0

                  for tempIndex=1 to udim(mat ControlName$)
                     if lwrc$(trim$(CurrentField$))=lwrc$(fnUniqueName$(mat ControlName$,tempIndex)) then
                        let TempControl=TempIndex
                        let FoundAlready=1
                     else if ((~FoundAlready) and (lwrc$(trim$(CurrentField$))=lwrc$(trim$(ControlName$(tempIndex))))) then
                        let TempControl=TempIndex
                     end if
                  next tempIndex
                  if TempControl then
                     let tempField=srch(mat s_subs,tempcontrol)
                  end if
                  if TempField>0 then let CurrentField=TempField
               end if
            end if

            if Listviewindex And Currentfield=Udim(Mat S_Spec$) then
               if function=106 or function=105 then
                  let Curfld(Currentfield,CurrentRow)
               end if
            else ! If Current Field Is Not The Listview Then Update Current Field Too.
               if CurrentField then let Curfld(Currentfield,Function)
            end if
!
            ! Draw the Record Locking information on the screen
            if udim(mat Other_S_Data$) then
               ! Check to see if the other user changed anything
               let fnFindChanges(mat Other_S_Data$,mat Other_S_Subs,mat S_Data$,mat S_Subs,mat OtherChanged_S_Data$,mat OtherChanged_S_Subs)
               mat Other_S_Data$(0)
               mat Other_S_Subs(0)
            end if

            if udim(mat OtherChanged_S_Subs) then
               ! If they did, then color their changes pink. (Make color defineable)
               let Fngenerateinputspecs(WWindow,Mat S_Data$,Mat S_Data,Mat S_Spec$,Mat S_Subs,Mat S_Help$,Mat S_Old$,Mat F$,Mat F,Mat Fieldsssubs$,Mat Fieldsnsubs$,Mat S$,Mat Screensubs$,Listviewindex,[[Screencontrols]],mat ControlSpec$,0,mat OtherChanged_S_Subs)
            end if

            ! Draw the Yellow stickynotes that contain the users changes.
            mat ChangeWindowNumbers(udim(mat Changed_S_Subs))
            for Index=1 to udim(mat Changed_S_Subs)
               if Changed_S_Subs(Index)>0 then
                  if ChangeWindowNumbers(Index)=0 then
                     let fnOpenSticky(Index,Changed_S_Data$(Index),ChangeWindowNumbers(Index),Changed_S_Subs(Index),Rows,Cols,Row,Col,[[ScreenControls]])
                  end if
               end if
            next Index

            ! Save Screen Data for later
            if ~SaveScreenData then
               mat Save_S_Data$(udim(mat S_Data$))=S_Data$
               mat Save_S_Subs(udim(mat S_Subs))=S_Subs
               let SaveScreenData=1
            end if

            ! Print Screen Data
            let fnChangeforcevisibility(1)
            do
               let LoopAgain=0

               let fnSetRetryPoint("Timeout1")
               Timeout1Retry: ! Timeout Retry Point
               if ~(Udim(Mat S_Data$)) then
                  if Len(Trim$(Screenio$(Si_Inputattr))) then
                     rinput #Wwindow, fields Mat S_Spec$, attr Screenio$(Si_Inputattr), wait=Waittime : Mat S_Data timeout TIMEOUTERROR error Ignore
                  else
                     rinput #Wwindow, fields Mat S_Spec$, wait=Waittime : Mat S_Data timeout TIMEOUTERROR error Ignore
                  end if
               else
                  if Len(Trim$(Screenio$(Si_Inputattr))) then
                     rinput #Wwindow, fields Mat S_Spec$, attr Screenio$(Si_Inputattr), wait=Waittime, help Mat S_Help$ : Mat S_Data$, Mat S_Data timeout TIMEOUTERROR error Ignore
                  else
                     rinput #Wwindow, fields Mat S_Spec$, wait=Waittime, help Mat S_Help$ : Mat S_Data$, Mat S_Data timeout TIMEOUTERROR error Ignore
                  end if
               end if
               Timeout1Continue: ! Timeout Continue Point

               if udim(s_data)<1 then
                  mat s_data(1)
                  if ListviewIndex and Multiselect(ListviewIndex) then
                     let s_data(1)=0
                  else
                     let s_data(1)=currentrow
                  end if
               end if
               ! print nxtfld; curfld : fkey linput X$
               let Function=Fkey
               let Currentfield=Curfld
               let NextField=NxtFld

               ! Make L Attribute Work In Listviews - Special Thanks To Susan Smith (Possibly deprecated, looks like BR just works this way by default now.)
               ! If there's an L, and they're in the listview, at the top or bottom, and we're here cause they pressed Up or Dn, then go back in the loop, don't let it loop around.
               if (Theresanl And Udim(Mat S_Data) And Currentfield=Udim(Mat S_Data$)+1 And (((Function=105 Or Function=90) And Currow=1) Or ((Function=106 Or Function=91) And Currow=Lastrow))) then
                  let LoopAgain=1
               end if

               ! If they press escape, erase all the yellow stickies and make them go away.
               if Function=99 and udim(mat ChangeWindowNumbers) then
                  let fnCloseAllStickies(mat ChangeWindowNumbers,mat Changed_S_Subs,mat Changed_S_Data$)
                  let LoopAgain=1
               end if

               ! If they click on one of the stickies, then put their changes
               !  into mat s_data and go back up again.
               if Function>fnStickyBase and Function<=fnStickyBase+udim(mat changed_S_subs) then
                  let Index=srch(mat S_Subs,changed_s_subs(Function-fnStickyBase))
                  if Index>0 and Index<udim(mat s_data$) then
                     let s_data$(Index)=Changed_S_Data$(Function-fnStickyBase)
                     close #ChangeWindowNumbers(Function-fnStickyBase):
                     let fnConsolidateDirect(mat ChangeWindowNumbers,Function-fnStickyBase)
                     let fnConsolidateDirect(mat Changed_S_Subs,Function-fnStickyBase)
                     let fnConsolidateDirects(mat Changed_S_Data$,Function-fnStickyBase)
                  end if
                  let LoopAgain=1
               end if

               if ~fn42ia then ! after this version we handle multiline textboxes another way
                  if CurrentField<=udim(mat S_Subs) and (Function=0 or Function=fnKeyBase+s_subs(CurrentField)) and fnMultilineTextbox(S_Subs(CurrentField),[[ScreenControls]]) then ! enter in a multi-line textbox
                     let Position=(((Currow-1)*Width(S_Subs(CurrentField)))+Curcol) ! Find The Position
                     if len(trim$(s_data$(CurrentField)))<=specwidth(S_Subs(CurrentField))-3 then ! if there's room for an Enter
                        let s_Data$(CurrentField)(Position:Position-1)=Chr$(13)&Chr$(10)
                        let Position+=2 ! Move to after the crlf$
                        let s_Data$(CurrentField)=srep$(trim$(s_Data$(CurrentField)),Chr$(1),"")&Chr$(1)
                     else
                        print bell
                     end if
                     let Position=min(Position,SpecWidth(S_Subs(CurrentField)))
                     let s_Spec$(CurrentField)=fnSetCurserPosition$(S_Spec$(CurrentField),Position)
                     let LoopAgain=1
                     let Curfld(CurrentField)
                  end if
               end if
            loop While LoopAgain

            if ~fn42ia then ! after this version we handle multiline textboxes another way
               For Index=1 to udim(mat S_Subs)
                  if fnMultilineTextbox(S_Subs(Index),[[ScreenControls]]) then
                     let s_Data$(Index)=srep$(s_Data$(Index),Chr$(1),"")
                  end if
               next Index
            end if

            let fnResetForceVisibility
            if CurrentField>0 and CurrentField<=udim(mat S_Subs) then
               let CurrentField$=fnUniqueName$(mat ControlName$,S_Subs(CurrentField))
               let S_CurrentField$=CurrentField$
            else
               let CurrentField$=fnUniqueName$(mat ControlName$,ListviewIndex)
               let S_CurrentField$=CurrentField$
            end if

! .         ! Read the listviews if there are any
            ! This function breaks curfld by inputting from the grid. this means we have to monkey around a lot more above.
            !  At this point, s_data(1) represents the count.
            ! let TempCurfld=Curfld ! this logic didn't work, because 2d controls
            let Fnreadlistviews(Function,Mat F$, Mat F, Currentkey$,CurrentRec,Mat Selectedkeys$,Mat Selectedrecords,mat VisibleKeys$,mat VisibleRecords,Mat S_Data,Mat S_Spec$,Listviewindex,Mat Old_Data,Wwindow,Fdatafile,Mat Form$, Mat Screenio$, Mat Screenio, [[Screencontrols]],NextRow)
            ! let Curfld(TempCurfld)
            ! At this point, s_data(1) represents the current row.
            if Listviewindex then
               let Currentrow=S_Currentrow=S_Data(1)
               let S_CurrentRec=CurrentRec
            end if
!
            if Function=99 And Fnsearchclosely(Mat Function$,"exitmode","quitonly") then
! .            ! They pressed esc but the program already has exit buttons, so simply ignore latest changes
            else
               let Fnvalidateandsave(Mat S_Data$,Mat S_Spec$,Mat S_Subs,Mat S_Old$,Mat F$,Mat F,Mat Fieldsssubs$,Mat Fieldsnsubs$,Mat S$,Mat Screensubs$,[[Screencontrols]])
            end if
!
         else ! Nothing Is Selected
! .         ! so preform a hidden input
            let fnChangeForceVisibility(0)

            let fnSetRetryPoint("Timeout2")
            Timeout2Retry: ! Timeout Retry Point
            input #0, fields Str$(Row+1)&","&Str$(Col+1)&",C 1,AEX", wait=Waittime : Kp$ error TimeoutError
            Timeout2Continue: ! Timeout Continue Point

            let Function=Fkey
            let fnResetForceVisibility
         end if
!
         let Fnrespondtouseraction(Function,Exitmode,Currentfield,CurrentField$,Mat S_Subs,[[Screencontrols]],WWindow,SaveDontAsk)
!
         if Exitmode=Asksaveandquit then
            if ~Fnsamea(Mat Save_F,Mat F) Or ~Fnsameas(Mat Save_F$,Mat F$) Or ~Fnsameas(Mat Save_S$,Mat S$) then
               if len(trim$(screenio$(si_filelay))) then
                  if UseMyF then
                     let Ch=Msgbox("The data has changed. Do you want to accept the changes?","Save?","ynC","QST")
                  else
                     let Ch=Msgbox("The record has changed. Would you like to save the record?","Save?","ynC","QST")
                  end if
               else ! No file layout, can't save
                  let Ch=3
               end if
               let Exitmode=0
               if Ch=2 then let Exitmode=Saveandquit
               if Ch=3 then let Exitmode=Quitonly
            else
               let Exitmode=Quitonly
            end if
         end if
         if Exitmode=Saveandquit then
! .         ! Execute our preWRITE Event Here
            if exists(setting_FunctionFolder$&"defaults\") then
               if exists(setting_FunctionFolder$&"defaults\write.brs") then
                  let fnExecute(fnFunctionString$(setting_FunctionFolder$&"defaults\write.brs"))
               end if
            end if

            if Len(Trim$(Screenio$(Si_Writefn))) then
               let Fnexecute(Screenio$(Si_Writefn))
               if ExitMode=0 and ParentWindow and fkey=92 then ! Probably Tabs and the exit was cancelled
                  ! Set the current tab back
                  input #ParentWindow, fields str$(Row+1)&","&str$(col+1)&",C 1,,NOWAIT" : dummy$
                  print #ParentWindow, fields str$(Row+1)&","&str$(col+1)&",C 1" : ""
               end if
            end if
         end if
!
         if Exitmode=Saveandquit then
            if Usemyf then
               mat Myf$=F$
               mat Myf=F
            else if Udim(S_Data$)>0 And Fdatafile And File(Fdatafile)>=0 then
               mat Disk_F$(udim(Read_F$))=("")
               mat Disk_F(udim(Read_F))=(0)
               let WarnWindow=fnDisplayLoadMessage
               if Key$<>"" then

                  let fnSetRetryPoint("ErrorLocked1exit")
                  ErrorLocked1ExitRetry: ! Error Locked Retry Point
                  read #FDataFile, using form$(FDataFile), key=fnKey$(FDataFile,Key$) : Mat Disk_F$, mat Disk_F locked ErrorFileLockedOnExit
                  ErrorLocked1ExitContinue: ! Error Locked Continue Point

                  let fnSetLogChanges(mat Read_F$,mat Disk_F)
               else if Record<>0 then

                  let fnSetRetryPoint("ErrorLocked2exit")
                  ErrorLocked2ExitRetry: ! Error Locked Retry Point
                  read #FDataFile, using form$(FDataFile), rec=Record : Mat Disk_F$,mat Disk_F locked ErrorFileLockedOnExit
                  ErrorLocked2ExitContinue: ! Error Locked Continue Point

                  let fnSetLogChanges(mat Read_F$,mat Disk_F)
               end if
               close #WarnWindow:
               if ~fnSameAS(mat Disk_F$,mat Read_F$) or ~fnSameA(Mat Disk_F,mat Read_F) then
                  if Setting_EnableLogging then
                     let fnLogChanges(mat Disk_F$,mat Disk_F,"ScreenIO: "&ScreenIO$(si_ScreenCode)&" screen attempting to Merge changes in "&Screenio$(Si_Filelay)&" file, Record: "&str$(rec(FDataFile))&" Key: "&Key$&" Other User",Program$&"\Screen: "&Screenio$(si_ScreenCode),ScreenIO$(si_FileLay))
                     let fnLogChanges(mat F$,mat F,"ScreenIO: "&ScreenIO$(si_ScreenCode)&" screen attempting to Merge changes in "&Screenio$(Si_Filelay)&" file, Record: "&str$(rec(FDataFile))&" Key: "&Key$&" My Changes",Program$&"\Screen: "&Screenio$(si_ScreenCode),ScreenIO$(si_FileLay))
                  end if
                  if Len(Trim$(Screenio$(Si_Mergefn))) then   ! If a merge function is given
                     let Fnexecute(Screenio$(Si_Mergefn))     ! use it
                  else if ScreenIO(si_ScreenIoMerge) then     ! If we selected "Auto Merge"
                     for Index=1 to udim(mat F$)              ! take my changes and merge them into Other's Changes
                        if trim$(F$(Index))<>trim$(Read_F$(Index)) then
                           let Disk_F$(Index)=F$(Index)
                        end if
                     next Index
                     for Index=1 to udim(mat F)
                        if F(Index)<>Read_F(Index) then
                           let Disk_F(Index)=F(Index)
                        end if
                     next Index
                     mat F$=Disk_F$
                     mat F=Disk_F
                  else if exists(setting_FunctionFolder$&"defaults\") and exists(setting_FunctionFolder$&"defaults\merge.brs") then
                     let fnExecute(fnFunctionString$(setting_FunctionFolder$&"defaults\merge.brs"))
                  else                                        ! Otherwise, allow the user to merge the records.
                     ! here we need to check if there's an ini setting for Debug then allow them to debug here.
                     let DebugYN=0
                     if setting_debug_locked_msg then
                        let DebugYN=msgbox("We detected changes to this record that were made by another user. You have to make your changes again. Would you like to debug this message?","Debug??","Yn","QST")
                     else
                        let msgbox("We detected changes to this record that were made by another user. You have to make your changes again.","Record Changed by Another User")
                     end if

                     if DebugYN=2 then pause

                     let CurrentKey$=Key$
                     let ExitMode=Reload

                     ! Save old record to detect what other user changed
                     mat Other_S_Data$(udim(mat Save_S_Data$))=Save_S_Data$
                     mat Other_S_Subs(udim(mat Save_S_Subs))=Save_S_Subs

                     ! Detect what I changed
                     let Findstickies=1
                  end if
               end if

               if ExitMode=SaveAndQuit then
                  if Key$<>"" then
                     rewrite #Fdatafile, using Form$(Fdatafile), key=Fnkey$(Fdatafile,Key$) : Mat F$, Mat F
                     if Setting_EnableLogging then let fnLogChanges(mat F$,mat F,"ScreenIO: Updating "&Screenio$(Si_Filelay)&" file, Record: "&str$(rec(FDataFile))&" Key: "&Key$,setting_ScreenFolder$&"\"&ScreenIO$(Si_ScreenCode))
                  else if Record<>0 then
                     rewrite #Fdatafile, using Form$(Fdatafile), rec=Record : Mat F$, Mat F
                     if Setting_EnableLogging then let fnLogChanges(mat F$,mat F,"ScreenIO: Updating "&Screenio$(Si_Filelay)&" file, Record: "&str$(rec(FDataFile)),setting_ScreenFolder$&"\"&ScreenIO$(Si_ScreenCode))
                  else
                     write #Fdatafile, using Form$(Fdatafile) : Mat F$, Mat F
                     if Setting_EnableLogging then let fnLogArray(mat F$,mat F,"ScreenIO: Writing "&Screenio$(Si_Filelay)&" file, Record: "&str$(rec(FDataFile)),setting_ScreenFolder$&"\"&ScreenIO$(Si_ScreenCode))
                  end if
               end if
            end if
         end if
      loop
!
! .   ! Set Return Key
      if Exitmode>Quitonly And ExitMode<>QuitOther and ExitMode<>Reload and Trim$(Screenio$(Si_Filelay))<>"" then
         let Currentkey$=Fnbuildkey$(Trim$(Screenio$(Si_Filelay)),Mat F$,Mat F,Screenio(Si_Returnindex))
         if Currentkey$="" then
            if FDataFile then
               let Currentkey$=Str$(Rec(Fdatafile)) ! Pass Back Record If Key Doesn't exist
            else if UseMyF then
               let CurrentKey$="1"  ! If there's no data file, if its a UseMyF screen, can't pass back record, just return true.
            end if
         end if
      end if

      let fnCloseAllStickies(mat ChangeWindowNumbers,mat Changed_S_Subs,mat Changed_S_Data$)
      if FindStickies then let fnFindChanges(mat S_Data$,mat S_Subs,mat Save_S_Data$,mat Save_S_Subs,mat Changed_S_Data$,mat Changed_S_Subs)

   fnend

! .! =================================================================
CLOSESCREEN: ! This Function Contains The Portion Of The Runtime Engine That Closes Your Screen And Returns.
! .! =================================================================
   def Fnclosescreen
      if ~Editing and Setting_EnableLogging then
         let fnLog("ScreenIO: Leaving Screen "&ScreenIO$(si_screenCode),setting_ScreenFolder$&"\"&ScreenIO$(Si_ScreenCode))
      end if
      if ~Editing or Pos(Uprc$(Env$("filter")),"Y") then
! .   ! Execute our EXIT Event Here
         if exists(setting_FunctionFolder$&"defaults\") then
            if exists(setting_FunctionFolder$&"defaults\exit.brs") then
               let fnExecute(fnFunctionString$(setting_FunctionFolder$&"defaults\exit.brs"))
            end if
         end if

         if Len(Trim$(Screenio$(Si_Exitfn))) then
            let Fnexecute(Screenio$(Si_Exitfn))
         end if
      end if
!
      if Exitmode>Quitonly then
         let Key$=Currentkey$
      else
         let Key$="" ! Cancel Forces No Return Value
      end if
!
! .   ! Close Data Files
      if Fdatafile And File(Fdatafile)>=0 then
         let Fnclosefile(Fdatafile,Trim$(Screenio$(Si_Filelay)),Path$,1)
      end if
!
! .   ! Close Child Window
      if Wwindow And File(Wwindow)<>-1 then
         close #Wwindow:
      end if
!
!      If Librarylinkage Then
!         Execute "clear "&Lwrc$(Routinename$)&" status"
!      End If
!
! .   ! Restore all screen settings to previous values
      if Oldrows And Oldcols then
         open #0: "rows="&Str$(Oldrows)&",cols="&Str$(Oldcols), display, outin
      end if
      if Len(Oldwindowcaption$) then
         print #0, border: Oldwindowcaption$
         let Setenv("Window_Caption",Oldwindowcaption$)
      end if
      let fnResetForceVisibility
      if Turnguibackoff then
         let fnRestoreNonGui
      end if
   fnend

   def fnMultilineTextbox(Index,[[ScreenControls]])
      if Height(Index)>1 and FieldType$(Index)="C" then
         let fnMultilineTextbox=1
      end if
   fnend

   def fnSetCurserPosition$*255(Spec$*255,Position;___,AttrPos,EndPos)
      let EndPos=AttrPos=pos(Spec$,",",pos(Spec$,",",pos(Spec$,",")+1)+1)+1
      do while pos("0123456789",Spec$(EndPos:EndPos))
         let EndPos+=1
      loop
      let EndPos-=1
      let Spec$(AttrPos:EndPos)=str$(Position)
      let fnSetCurserPosition$=Spec$
   fnend

FindChanges: ! Examine two arrays and find the differences, adding them to a third array
   def fnFindChanges(mat S_Data$,mat S_Subs,mat Save_S_Data$,mat Save_S_Subs,mat Changed_S_Data$,mat Changed_S_Subs;___,Index,X,Z)
      for Index=1 to udim(mat S_Subs)
         let X=srch(mat Save_S_Subs,S_Subs(Index))
         if X<1 or trim$(Save_S_Data$(X))<>trim$(S_Data$(Index)) then
            let Z=udim(mat Changed_S_Data$)+1
            mat Changed_S_Data$(Z)
            mat Changed_S_Subs(Z)

            let Changed_S_Data$(Z)=S_Data$(Index)
            let Changed_S_Subs(Z)=S_Subs(Index)
         end if
      next Index
   fnend

!
UniqueName: ! Return a unique name for the control by adding the count
   def fnUniqueName$*54(mat ControlName$,Control;___,Index,Enumerator,Count)
      for Index=1 to udim(mat ControlName$)
         if lwrc$(trim$(ControlName$(Index)))=lwrc$(trim$(ControlName$(Control))) then
            let Count+=1
            if Index<=Control then
               let Enumerator+=1
            end if
         end if
      next Index
      if Count>1 or trim$(ControlName$(Control))="" then
         let fnUniqueName$=trim$(ControlName$(Control))&str$(Enumerator)
      else
         let fnUniqueName$=trim$(ControlName$(Control))
      end if
   fnend
   def library fnGetUniqueName$*54(Mat ControlName$,Control)=fnUniqueName$(Mat ControlName$,Control)

   dim Rlv_Subs(1)
   dim Rlv_Readdata$(1)*1000
   dim Rlv_Savereaddata$(1)*1000
   dim ListviewRecords(1)
   dim Rlv_VisibleData$(1)*1000
   dim Rlv_Start(1),Rlv_End(1),Rlv_SortOrder(1)
   dim VisibleF$(1)*1023,VisibleF(1)
   dim RLV_OldVisible(1),RLV_OldVisibleMask(1)

   dim VisibleMask(1)
!
READLISTVIEWS: ! This Function Reads The Listview On The Screen If There Is One.
   def Fnreadlistviews(Function,Mat F$, Mat F, &Currentkey$,&CurrentRec,Mat Selectedkeys$,Mat Selectedrecords,mat VisibleKeys$,mat VisibleRecords,Mat S_Data,Mat S_Spec$,Listviewindex,Mat Old_Data,Wwindow,Fdatafile,Mat Form$, Mat Screenio$, Mat Screenio, [[Screencontrols]],&NextRow;___,Listviewspec$*40,Index,Anythingchanged,Multiselect,Numberofcolumns,numofRows,VisibleRows)
!
      if Listviewindex And Listviewindex<=Udim(Mat Multiselect) and ~Protected(ListviewIndex) and ~Invisible(ListviewIndex) then ! If There's a listview
         let Listviewspec$=S_Spec$(Udim(Mat S_Spec$))
         let Listviewspec$=Listviewspec$(1:Pos(Listviewspec$,",",-1)-1)
         let Listviewspec$=Listviewspec$(1:Pos(Listviewspec$,",",-1)-1)
         let Numberofcolumns=Fncountcolumns(Parent$(Listviewindex),[[Screencontrols]])+1
!
! .      ! If its multiselect then read mat SelectedKeys$ and mat SelectedRecords
         if Multiselect(Listviewindex) then
! .         ! Read the selected records from the listview
            mat Rlv_Readdata$(S_Data(1)*Numberofcolumns)
            input #Wwindow, fields Listviewspec$&",ROW,SEL,NOWAIT" : Mat Rlv_Readdata$

            ! $$$$$ Discuss with Gordon, why is this necessary?
            !  This is happening because when nothing is selected, s_data(1) has 40 in it. Easy to reproduce, just unselect everything
            !  on expense listview.
            !  The ROWCNT,SEL is returning 40 but the ROW,SEL,NOWAIT is returning 0 elements.
            ! For now, the following code should hopefully keep it from bombing.
            ! Seems like ROWCNT,SEL returns ROWSUB,SELONE for last thing selected if nothing is selected.

            ! if udim(mat Rlv_ReadData$)<S_Data(1)*NumberOfColumns then
            !    let S_Data(1)=int(udim(mat Rlv_ReadData$)/NumberOfColumns)
            ! end if
!
! .         ! Read the keys array from the data file
            if ~Fnsameas(Mat Rlv_Savereaddata$,Mat Rlv_Readdata$) then
               mat Rlv_Savereaddata$(Udim(Mat Rlv_Readdata$))=Rlv_Readdata$
               mat Selectedkeys$(S_Data(1))
               mat Selectedrecords(S_Data(1))
!
               if Fdatafile And File(Fdatafile)>=0 then
                  for Index=1 to Udim(Mat Selectedrecords)
                     let Selectedrecords(Index)=Val(Rlv_Readdata$((Index*Numberofcolumns)))
                     let Selectedkeys$(Index)=Fnreadcurrentkey$(Selectedrecords(Index),Fdatafile,Mat F$,Mat F,Mat Form$,Mat Screenio$)
                  next Index
               else
                  mat Rlv_Subs(S_Data(1))
                  input #Wwindow, fields Listviewspec$&",ROWSUB,SEL,NOWAIT" : Mat Rlv_Subs
                  for Index=1 to Udim(Mat Selectedrecords)
                     let Selectedrecords(Index)=Val(Rlv_Readdata$((Index*Numberofcolumns)))
                     let Selectedkeys$(Index)=Str$(Rlv_Subs(Index))
                  next Index
               end if
               let Anythingchanged=1
            end if
!
            let Multiselect=1
         end if

         if Fn42 then ! Use fn42+ NEXT for greater control over the listview
            input #Wwindow, fields Listviewspec$&",ROWSUB,NEXT,NOWAIT" : S_Data(1)
         else
            input #Wwindow, fields Listviewspec$&",ROWSUB,CUR,NOWAIT" : S_Data(1)
         end if

         if fn43 and fnUsesVisibleVars then
            ! Read VisibleKeys$ And VisibleRecords
            INPUT #Wwindow, FIELDS ListviewSpec$&",rowcnt,all,nowait" : numofrows

            mat VisibleMask(numofrows)

            input #Wwindow, fields ListviewSpec$&",mask,,nowait" : mat VisibleMask

            let VisibleRows=sum(mat VisibleMask)
            if VisibleRows then
               if (VisibleRows*NumberofColumns) <= 268400 then

                  ! 268 MB is the max size of an array in BR 4.3. If there's more data than that in the listview,
                  ! then we can't read mat VisibleKeys$ or mat VisibleRows. 
                  ! They're probably not useful for listviews that large anyway.
           
                  mat Rlv_ReadData$(VisibleRows*Numberofcolumns)
                  mat Rlv_SortOrder(NumOfRows)

                  ! let Rlv_Start(1)=(NumOfRows-VisibleRows)+1
                  ! let Rlv_Endn(1)=NumOfRows
                  ! input #Wwindow, fields Listviewspec$&",row,range,displayed_order,nowait" : Rlv_Start(1),Rlv_End(1),Mat Rlv_Readdata$

                  ! Calculate the mat Start and mat End necessary to read the data
                  ! We're using a trick here. Looks like BR Returns displayed_order with all the
                  !  filter-showing rows at the end. So we just read the last however many rows
                  !  of our mat SortOrder and use it for our Starts and Ends, and they're already in
                  !  displayed order for us
                  input #WWindow, fields Listviewspec$&",rowsub,all,displayed_order,nowait": mat Rlv_SortOrder

                  if ~fnSameA(mat Rlv_OldVisibleMask,mat VisibleMask) or ~fnSameA(mat Rlv_OldVisible,mat Rlv_SortOrder) then
                     mat RLV_OldVisibleMask(udim(mat VisibleMask))=VisibleMask
                     mat RLV_OldVisible(udim(mat Rlv_SortOrder))=Rlv_SortOrder

                     mat Rlv_Start(VisibleRows)=Rlv_SortOrder(udim(mat Rlv_SortOrder)-VisibleRows+1:udim(mat Rlv_SortOrder))
                     mat Rlv_End(VisibleRows)=Rlv_Start

                     input #WWindow, fields Listviewspec$&",row,range,nowait" : mat Rlv_Start, mat Rlv_End, (mat Rlv_ReadData$)

                     mat VisibleKeys$(sum(mat VisibleMask))
                     mat VisibleRecords(sum(mat VisibleMask))
                     mat VisibleF$(udim(mat F$)) : mat VisibleF(udim(mat F))
                     for Index=1 to udim(mat VisibleRecords)
                        let VisibleRecords(Index)=Val(Rlv_Readdata$(Index*Numberofcolumns))
                        let VisibleKeys$(Index)=Fnreadcurrentkey$(VisibleRecords(Index),Fdatafile,Mat VisibleF$,Mat VisibleF,Mat Form$,Mat Screenio$)
                     next Index
                  end if
               end if
            end if
         end if
!
! .      ! Read CurrentKey$
         if ~Fnsamea(Mat Old_Data,Mat S_Data) then
            if Fdatafile And File(Fdatafile)>=0 then
               mat Rlv_Readdata$(Numberofcolumns)
               if Fn42 then
                  input #Wwindow, fields Listviewspec$&",ROW,NEXT,NOWAIT" : Mat Rlv_Readdata$
               else
                  input #Wwindow, fields Listviewspec$&",ROW,CUR,NOWAIT" : Mat Rlv_Readdata$
               end if
               let Currentkey$=Fnreadcurrentkey$(Val(Rlv_Readdata$(Numberofcolumns)),Fdatafile,Mat F$,Mat F,Mat Form$,Mat Screenio$)
               let CurrentRec=Val(Rlv_Readdata$(Numberofcolumns))
            else
               let Currentkey$=Str$(S_Data(1))
               let CurrentRec=S_Data(1)
            end if

            let Anythingchanged=1
            mat Old_Data(Udim(Mat S_Data))=S_Data
!
            if ~Multiselect then
               mat Selectedkeys$(1) : mat Selectedrecords(1)
               let Selectedkeys$(1)=Currentkey$
               let Selectedrecords(1)=CurrentRec
            end if
         end if

         if Anythingchanged then
! .         ! Here is where we link to our READ event for Listviews
            if Len(Trim$(Screenio$(Si_Readfn))) then
               let Fnexecute(Screenio$(Si_Readfn))
            end if
         end if
      end if
   fnend

   def fnUsesVisibleVars
      ! This function should check if the screen uses VisibleRecords or VisibleKeys$ maybe.
      !  or it should check some faster way if the screen needs them or not. Or just leave this out.

      let fnUsesVisibleVars=1
   fnend
!
READCURRENTKEY: ! Read The Current Record And Build Currentkey$
   def Fnreadcurrentkey$*255(Record,Fdatafile,Mat F$,Mat F,Mat Form$,Mat Screenio$)
      if Record then
! .      ! Read new record
         read #Fdatafile, using Form$(Fdatafile), rec=Record, release: Mat F$, Mat F norec IGNORE
         let Fnreadcurrentkey$=Fnbuildkey$(Trim$(Screenio$(Si_Filelay)),Mat F$,Mat F,Screenio(Si_Returnindex))
      end if
   fnend
!
REQUIRESGUI: ! Returns True If Any Control Requires Gui
   def Fnrequiresgui(Mat Screenio$, Mat Screenio, [[Screencontrols]])
      let Fnrequiresgui=1 ! Non-Gui Compatability Doesn't work yet
   fnend
!
INITIALIZEMATS: ! Initialize The Mat S Array For Dumb (Mute) Screen Controls
   def Fninitializemats(Mat S$,Mat Screensubs$,[[Screencontrols]];___,Index)
      mat S$(0)
      mat Screensubs$(0)
!
      for Index=1 to Udim(Mat Controlname$)
         #Select# Lwrc$(Trim$(Fieldtype$(Index))) #Case# "caption" # "button" # "p" # "combo"
            if Trim$(Fieldname$(Index))="" then
               if Len(Trim$(Controlname$(Index))) then
                  if srch(mat ScreenSubs$,lwrc$(trim$(controlname$(index))))<1 then
                     mat S$(Udim(Mat S$)+1)
                     mat Screensubs$(Udim(Mat S$))
                     let S$(Udim(Mat S$))=Fncalculatedata$(Index,[[Screencontrols]],0,1)
                     let Screensubs$(Udim(Mat S$))=Lwrc$(Trim$(Controlname$(Index)))
                  end if
               end if
            end if
         #Case# "c" # "listchld" # "check" # "search" # "filter"
            if Trim$(Fieldname$(Index))="" then
               if Len(Trim$(Controlname$(Index))) then
                  if srch(mat ScreenSubs$,lwrc$(trim$(controlname$(index))))<1 then
                     mat S$(Udim(Mat S$)+1)
                     mat Screensubs$(Udim(Mat S$))
                     let Screensubs$(Udim(Mat S$))=Lwrc$(Trim$(Controlname$(Index)))
                  end if
               end if
            end if
         #End Select#
      next Index
   fnend
!
   dim OldInvisible
   dim EraseSpec$(1)*255, EraseData$(1)
   def fnEraseInvisible(Window,[[ScreenControls]];___,Index,jndex)
      mat EraseSpec$(udim(mat FieldType$))
      mat OldInvisible(udim(mat Invisible))

      for Index=1 to udim(mat FieldType$)
         if Invisible(Index) and ~OldInvisible(Index) then ! If its invisible and it used to not be
            if fnIsInput(FieldType$(Index)) then ! We only care about input controls, output are handled elsewhere.
               let Jndex+=1
               let EraseSpec$(Jndex)=str$(VPosition(Index))&","&str$(HPosition(Index))&",C 1"
            end if
         end if
      next Index

      mat OldInvisible=Invisible

      if Jndex then ! If anything found, then erase it.
         mat EraseSpec$(Jndex)
         mat EraseData$(Jndex)
         print #Window, fields mat EraseSpec$ : mat EraseData$
      end if
   fnend

   dim Blankdata$(1)
   def Fnblankoldsfields$(Mat Spec$,Mat Oldspec$,Window;___,Index,Outdex,H,V,W,T$,Oh,Ov,Ow,Ot$)
      if Udim(Mat Spec$)=Udim(Mat Oldspec$) then
         for Index=1 to Udim(Mat Spec$)
!
            let Fnparsespec(Oldspec$(Index),Oh,Ov,Ow,Ot$)
            let Fnparsespec(Spec$(Index),H,V,W,T$)
!
            if Uprc$(T$)="C" And Uprc$(Ot$)="C" And (Oh<>H Or Ov<>V Or Ow>W) then
! .            ! Save it
               let Outdex+=1
               let Oldspec$(Outdex)=Oldspec$(Index)(1:Pos(Oldspec$(Index),",",Pos(Oldspec$(Index),",",Pos(Oldspec$(Index),",")+1)+1)-1)&",/W:W"
            end if
         next Index
         mat Oldspec$(Outdex)
      end if
      for Index=1 to Udim(Mat Oldspec$)
         let Oldspec$(Index)=Oldspec$(Index)(1:Pos(Oldspec$(Index),",",Pos(Oldspec$(Index),",",Pos(Oldspec$(Index),",")+1)+1)-1)&",/W:W"
      next Index
!
      if udim(mat OldSpec$) then
         mat Blankdata$(Udim(Mat Oldspec$))=("")
         print #Wwindow, fields Mat Oldspec$ : Mat Blankdata$
      end if
   fnend

!  $$$$$ The following code doesn't support Radio Buttons or Listviews
   def Fnparsespec(Spec$*255,&H,&V,&W,&Type$)
      let H=V=W=0
      let V=Val(Spec$(1:Pos(Spec$,",")-1)) conv IGNORE
      let Spec$=Spec$(Pos(Spec$,",")+1:Len(Spec$))
      let H=Val(Spec$(1:Pos(Spec$,",")-1)) conv IGNORE
      let Spec$=Spec$(Pos(Spec$,",")+1:Len(Spec$))
      let Spec$=Spec$(Pos(Spec$,"/")+1:Len(Spec$))
      let Type$=Spec$(1:1)
      if Pos(Spec$,",",3) then let Spec$=Spec$(3:Pos(Spec$,",",3))
      let W=Val(Spec$) conv IGNORE
   fnend
!
   dim TempFileName$*1023
GENERATEOUTPUTSPECS: ! Generate The Specs For Output Only Controls
   def Fngenerateoutputspecs(Window,Mat S_Data$,Mat S_Spec$,Mat S_Help$,Mat S$,Mat Screensubs$,[[Screencontrols]],mat ControlSpec$;Forceindex,___,Index,Outdex,Subindex,Position)
      mat S_Data$(0) : mat S_Spec$(0) : mat S_Help$(0)
      mat ControlSpec$(udim(mat ControlName$))
      for Index=1 to Udim(Mat Controlname$)
         if ~Invisible(Index) then
            #Select# Lwrc$(Trim$(Fieldtype$(Index))) #Case# "caption" # "button" # "p"
               let Outdex=Udim(Mat S_Data$)+1
               mat S_Data$(Outdex)
               mat S_Spec$(Outdex)
               mat S_Help$(Outdex)

               ! Read from mat S$ if its S$, or F$ and F if its them. If its neither, set it from description.
               if Trim$(Fieldname$(Index))="" And Trim$(Controlname$(Index))<>"" And (Subindex:=Srch(Mat Screensubs$,Lwrc$(Trim$(Controlname$(Index)))))>0 then
                  let S_Data$(Outdex)=S$(Subindex)
               else if trim$(fieldName$(Index))><"" then
                  if Fnisnumber(Mat Fieldsssubs$,Mat Fieldsnsubs$,Fieldname$(Index)) then
                     let Position=Srch(Mat Fieldsnsubs$,Lwrc$(Trim$(Fieldname$(Index))))
                     if Position>0 then
                        let S_Data$(Outdex)=Str$(F(Position))
                     end if
                  else
                     let Position=Srch(Mat Fieldsssubs$,Lwrc$(Trim$(Fieldname$(Index))))
                     if Position>0 then
                        let S_Data$(Outdex)=F$(Position)
                     end if
                  end if
               else
                  let S_Data$(Outdex)=Fncalculatedata$(Index,[[Screencontrols]],0,1)
               end if
!
! .            ! Apply Conversion in if possible
               if Cnvrtin$(Index)(1:1)="{" Or Cnvrtin$(Index)(1:1)="#" then
                  let TempData$=S_Data$(OutDex)
                  let Fnconvertin(TempData$,Cnvrtin$(Index),Index,Outdex)
                  if TempData$<>S_Data$(Outdex) then let S_Data$(Outdex)=TempData$
               else if Len(Trim$(Cnvrtin$(Index))) then
                  let S_Data$(Outdex)=trim$(Cnvrt$(fnUnpackConvertSpec$(Index,[[ScreenControls]]),Val(S_Data$(Outdex)))) error IGNORE
               end if

               ! After 4.2 and Higher, we now have to check to ensure the image file exists because BR now gives error 760 if it doesnt.
               !  we have to do this in a painful and slow way in order to preserve the case of the file name while stripping off
               !  the optional image parameters that cause the exists function to fail
               if Lwrc$(Trim$(Fieldtype$(Index)))="p" and fn42 then
                  let TempFileName$=s_data$(outdex)
                  if pos(lwrc$(tempfilename$),":isotropic") then let TempFileName$=TempFileName$(1:pos(lwrc$(tempfilename$),":isotropic")-1)
                  if pos(lwrc$(tempfilename$),":noresize") then let TempFileName$=TempFileName$(1:pos(lwrc$(tempfilename$),":noresize")-1)
                  if pos(lwrc$(tempfilename$),":tile") then let TempFileName$=TempFileName$(1:pos(lwrc$(tempfilename$),":tile")-1)
                  if ~len(trim$(tempfilename$)) or ~exists(tempfilename$) then
                     let s_data$(outdex)=setting_ImagePath$&"\nothing.gif"
                  end if
               end if

               let Specwidth(Index)=Len(S_Data$(Outdex))

               let S_Spec$(Outdex)=Fncalculatespec$(Window,Index,[[Screencontrols]])
               if (Trim$(Function$(Index))="" Or Protected(Index)) And Lwrc$(Trim$(Fieldtype$(Index)))<>"button" then
                  let S_Spec$(Outdex)=S_Spec$(Outdex)(1:Pos(S_Spec$(Outdex),",",-1)-1)&",-1"
               end if
               if Forceindex then
                  if Lwrc$(Trim$(Fieldtype$(Index)))="button" then
                     let S_Spec$(Outdex)=S_Spec$(Outdex)(1:Pos(S_Spec$(Outdex),",",-1)-1)&",B"&Str$(Forceindex)
                  else
                     let S_Spec$(Outdex)=S_Spec$(Outdex)(1:Pos(S_Spec$(Outdex),",",-1)-1)&","&Str$(Forceindex)
                  end if
               end if
!
               let S_Help$(Outdex)=Fncalculatehelp$(Tooltip$(Index))
               let ControlSpec$(Index)=S_Spec$(OutDex)
!
            #Case# "c" # "search" # "combo" # "filter"
               if Protected(Index) then ! Show Input Controls As Output Controls If They Are Protected.
                  let Outdex=Udim(Mat S_Data$)+1
                  mat S_Data$(Outdex)
                  mat S_Spec$(Outdex)
                  mat S_Help$(Outdex)
!
                  ! Read from mat S$ if its S$, or F$ and F if its them. If its neither, leave it blank.
                  if Trim$(Fieldname$(Index))="" And Trim$(Controlname$(Index))<>"" And (Subindex:=Srch(Mat Screensubs$,Lwrc$(Trim$(Controlname$(Index)))))>0 then
                     let S_Data$(Outdex)=S$(Subindex)
                  else if trim$(fieldName$(Index))><"" then
                     if Fnisnumber(Mat Fieldsssubs$,Mat Fieldsnsubs$,Fieldname$(Index)) then
                        let Position=Srch(Mat Fieldsnsubs$,Lwrc$(Trim$(Fieldname$(Index))))
                        if Position>0 then
                           let S_Data$(Outdex)=Str$(F(Position))
                        end if
                     else
                        let Position=Srch(Mat Fieldsssubs$,Lwrc$(Trim$(Fieldname$(Index))))
                        if Position>0 then
                           let S_Data$(Outdex)=F$(Position)
                        end if
                     end if
                  else
                     let S_Data$(Outdex)=""
                  end if

!                 ! Apply Conversion From Disk
                  ! Only implemented for Dates in C fields and Listview Children
                  if Lwrc$(CnvrtOut$(Index))(1:5)="date(" and Lwrc$(Trim$(Fieldtype$(Index)))="c" then
                     if fnIsDigit(S_Data$(Outdex)) then
                        let S_Data$(Outdex)=str$(days(val(S_Data$(Outdex)),fnDateMask$(CnvrtOut$(Index)))) error IGNORE
                     else
                        let S_Data$(Outdex)=str$(days(S_Data$(Outdex),fnDateMask$(CnvrtOut$(Index)))) error IGNORE
                     end if
                  end if

! .               ! Apply Conversion in if possible
                  if Cnvrtin$(Index)(1:1)="{" Or Cnvrtin$(Index)(1:1)="#" then
                     let TempData$=S_Data$(OutDex)
                     let Fnconvertin(TempData$,Cnvrtin$(Index),Index,Outdex)
                     if TempData$<>S_Data$(Outdex) then let S_Data$(Outdex)=TempData$
                  else if Len(Trim$(Cnvrtin$(Index))) then
                     let S_Data$(Outdex)=trim$(Cnvrt$(fnUnpackConvertSpec$(Index,[[ScreenControls]]),Val(S_Data$(Outdex)))) error IGNORE
                  end if
! .!
                  let S_Spec$(Outdex)=Fncalculatespec$(Window,Index,[[Screencontrols]])
                  let S_Help$(Outdex)=Fncalculatehelp$(Tooltip$(Index))
                  if Forceindex then
                     let S_Spec$(Outdex)=S_Spec$(Outdex)(1:Pos(S_Spec$(Outdex),",",-1)-1)&","&Str$(Forceindex)
                  end if
                  let ControlSpec$(Index)=S_Spec$(OutDex)
               end if
! .!
            #Case# "check"
               if Protected(Index) then ! Show Input Controls As Output Controls If They Are Protected.
                  let Outdex=Udim(Mat S_Data$)+1
                  mat S_Data$(Outdex)
                  mat S_Spec$(Outdex)
                  mat S_Help$(Outdex)
! .   !
                  if Trim$(Fieldname$(Index))="" And Trim$(Controlname$(Index))<>"" And (Subindex:=Srch(Mat Screensubs$,Lwrc$(Trim$(Controlname$(Index)))))>0 then
                     let S_Data$(Outdex)=Fninchecked$(S$(Subindex),Truevalue$(Index))&Fncalculatedata$(Index,[[Screencontrols]],0,1)
                     let Specwidth(Index)=Len(S_Data$(Outdex))+1 ! (1 For The Checkmark)
                  else
                     if Fnisnumber(Mat Fieldsssubs$,Mat Fieldsnsubs$,Fieldname$(Index)) then
                        let Position=Srch(Mat Fieldsnsubs$,Lwrc$(Trim$(Fieldname$(Index))))
                        if Position>0 then
                           let S_Data$(Outdex)=Fninchecked$(Str$(F(Position)),Truevalue$(Index))&Fncalculatedata$(Index,[[Screencontrols]],0,1)
                        end if
                     else
                        let Position=Srch(Mat Fieldsssubs$,Lwrc$(Trim$(Fieldname$(Index))))
                        if Position>0 then
                           let S_Data$(Outdex)=Fninchecked$(F$(Position),Truevalue$(Index))&Fncalculatedata$(Index,[[Screencontrols]],0,1)
                        end if
                     end if
                  end if
! .   !
                  let S_Spec$(Outdex)=Fncalculatespec$(Window,Index,[[Screencontrols]])
                  let S_Help$(Outdex)=Fncalculatehelp$(Tooltip$(Index))
                  if Forceindex then
                     let S_Spec$(Outdex)=S_Spec$(Outdex)(1:Pos(S_Spec$(Outdex),",",-1)-1)&","&Str$(Forceindex)
                  end if
                  let ControlSpec$(Index)=S_Spec$(OutDex)
               end if
!
            #Case Else#
! .           ! Ignore all non-protected or Invisible controls
!
            #End Select#
         end if
      next Index
   fnend
!
   def fnDateMask$*64(Spec$*64;___,P) ! Pulls the Date Mask out of a Date Spec
      let Spec$=trim$(Spec$(6:70))
      let P=len(Spec$)
      if Spec$(P:P)=")" then let Spec$=Spec$(1:P-1)
      let fnDateMask$=Spec$
   fnend

   def library fnIsOutputSpec(type$)=fnIsOutput(Type$)
   def fnIsOutput(Type$)
      #Select# lwrc$(trim$(type$)) #Case# "caption" # "button" # "p" # "frame" # "screen"
         let fnIsOutput=1
      #Case Else#
          let fnIsOutput=0
      #End Select#
   fnend

   def library fnIsInputSpec(type$)=fnIsInput(Type$)
   def fnIsInput(type$)
      #Select# lwrc$(trim$(type$)) #Case# "c" # "search" # "check" # "combo" # "filter"
         let fnIsInput=1
      #Case Else#
         let fnIsInput=0
      #End Select#
   fnend
!
GENERATEINPUTSPECS: ! Generate The Specs For Input From All Io Controls
   def Fngenerateinputspecs(Window,Mat S_Data$,Mat S_Data,Mat S_Spec$,Mat S_Subs,Mat S_Help$,Mat S_Old$,Mat F$,Mat F,Mat Fieldsssubs$,Mat Fieldsnsubs$,Mat S$,Mat Screensubs$,&Listviewindex,[[Screencontrols]],mat ControlSpec$;Forceindex,mat OtherChanged_S_Subs,___,Index,Outdex,Subindex,Position,DateFormat$,P)

      mat S_Data$(0) : mat S_Spec$(0) : mat S_Subs(0) : mat S_Data(0) : mat S_Help$(0)
      mat ControlSpec$(udim(mat ControlName$))

      for Index=1 to Udim(Mat Controlname$) ! Loop Once For Regular Fields
         if ~Protected(Index) And ~Invisible(Index) then
            #Select# Lwrc$(Trim$(Fieldtype$(Index))) #Case# "c" # "search" # "combo" # "filter"
               let Outdex=Udim(Mat S_Data$)+1
               mat S_Data$(Outdex)
               mat S_Spec$(Outdex)
               mat S_Subs(Outdex)
               mat S_Help$(Outdex)

               if Trim$(Fieldname$(Index))="" And Trim$(Controlname$(Index))<>"" And (Subindex:=Srch(Mat Screensubs$,Lwrc$(Trim$(Controlname$(Index)))))>0 then
                  let S_Data$(Outdex)=S$(Subindex)
               else
                  if Fnisnumber(Mat Fieldsssubs$,Mat Fieldsnsubs$,Fieldname$(Index)) then
                     let Position=Srch(Mat Fieldsnsubs$,Lwrc$(Trim$(Fieldname$(Index))))
                     if Position>0 then
                        let S_Data$(Outdex)=Str$(F(Position))
                     end if
                  else
                     let Position=Srch(Mat Fieldsssubs$,Lwrc$(Trim$(Fieldname$(Index))))
                     if Position>0 then
                        let S_Data$(Outdex)=F$(Position)
                     end if
                  end if
               end if

! .            ! Apply Conversion From Disk
               ! Only implemented for Dates in C fields and Listview Children
               if Lwrc$(CnvrtOut$(Index))(1:5)="date(" and Lwrc$(Trim$(Fieldtype$(Index)))="c" then
                  if fnIsDigit(S_Data$(Outdex)) then
                     let S_Data$(Outdex)=str$(days(val(S_Data$(Outdex)),fnDateMask$(CnvrtOut$(Index)))) error IGNORE
                  else
                     let S_Data$(Outdex)=str$(days(S_Data$(Outdex),fnDateMask$(CnvrtOut$(Index)))) error IGNORE
                  end if
               end if

! .            ! Apply Conversion if possible...
               if Cnvrtin$(Index)(1:1)="{" Or Cnvrtin$(Index)(1:1)="#" then
                  let TempData$=S_Data$(OutDex)
                  let Fnconvertin(TempData$,Cnvrtin$(Index),Index,Outdex)
                  if TempData$<>S_Data$(Outdex) then let S_Data$(Outdex)=TempData$
               else if Len(Trim$(Cnvrtin$(Index))) then
                  let S_Data$(Outdex)=trim$(Cnvrt$(fnUnpackConvertSpec$(Index,[[ScreenControls]]),Val(S_Data$(Outdex)))) error IGNORE
               end if


               let S_Spec$(Outdex)=Fncalculatespec$(Window,Index,[[Screencontrols]],0,0,(srch(mat OtherChanged_S_Subs,Index)>0))
               let S_Subs(Outdex)=Index
               let S_Help$(Outdex)=Fncalculatehelp$(Tooltip$(Index))
               if Forceindex then
                  let S_Spec$(Outdex)=S_Spec$(Outdex)(1:Pos(S_Spec$(Outdex),",",-1)-1)&","&Str$(Forceindex)
               end if
               let ControlSpec$(Index)=S_Spec$(OutDex)
! .!
            #Case# "check"
               let Outdex=Udim(Mat S_Data$)+1
               mat S_Data$(Outdex)
               mat S_Spec$(Outdex)
               mat S_Subs(Outdex)
               mat S_Help$(Outdex)
! .!
               if Trim$(Fieldname$(Index))="" And Trim$(Controlname$(Index))<>"" And (Subindex:=Srch(Mat Screensubs$,Lwrc$(Trim$(Controlname$(Index)))))>0 then
                  let S_Data$(Outdex)=Fninchecked$(S$(Subindex),Truevalue$(Index))&Fncalculatedata$(Index,[[Screencontrols]],0,1)
                  let Specwidth(Index)=Len(S_Data$(Outdex))+1 ! (1 For The Checkmark)
               else
                  if Fnisnumber(Mat Fieldsssubs$,Mat Fieldsnsubs$,Fieldname$(Index)) then
                     let Position=Srch(Mat Fieldsnsubs$,Lwrc$(Trim$(Fieldname$(Index))))
                     if Position>0 then
                        let S_Data$(Outdex)=Fninchecked$(Str$(F(Position)),Truevalue$(Index))&Fncalculatedata$(Index,[[Screencontrols]],0,1)
                     end if
                  else
                     let Position=Srch(Mat Fieldsssubs$,Lwrc$(Trim$(Fieldname$(Index))))
                     if Position>0 then
                        let S_Data$(Outdex)=Fninchecked$(F$(Position),Truevalue$(Index))&Fncalculatedata$(Index,[[Screencontrols]],0,1)
                     end if
                  end if
               end if
! .!
               let S_Spec$(Outdex)=Fncalculatespec$(Window,Index,[[Screencontrols]],0,0,(srch(mat OtherChanged_S_Subs,Index)>0))
               let S_Subs(Outdex)=Index
               let S_Help$(Outdex)=Fncalculatehelp$(Tooltip$(Index))
               if Forceindex then
                  let S_Spec$(Outdex)=S_Spec$(Outdex)(1:Pos(S_Spec$(Outdex),",",-1)-1)&","&Str$(Forceindex)
               end if

               let ControlSpec$(Index)=S_Spec$(OutDex)
! .!
            #Case Else#
! .! .         Ignore All Output Controls
! .!
            #End Select#
         end if
      next Index
      for Index=1 to Udim(Mat Controlname$) ! Loop Again For Listviews - They Must Come Last
         if ~Protected(Index) And ~Invisible(Index) then
            #Select# Lwrc$(Trim$(Fieldtype$(Index))) #Case# "listview"
               mat S_Data(Udim(Mat S_Data)+1)
               mat S_Spec$(Udim(Mat S_Spec$)+1)
!
               let Listviewindex=Index
               let S_Spec$(Udim(Mat S_Spec$))=Fncalculatelistviewspec$(Index,[[Screencontrols]])
               if Multiselect(Index) then
                  let S_Spec$(Udim(Mat S_Spec$))=S_Spec$(Udim(Mat S_Spec$))&",ROWCNT,SEL"
               else
                  let S_Spec$(Udim(Mat S_Spec$))=S_Spec$(Udim(Mat S_Spec$))&",ROWSUB,SELONE"
               end if
               let ControlSpec$(Index)=S_Spec$(Udim(Mat S_Spec$))

            #Case Else#
! .            Ignore All other Controls
!
            #End Select#
         end if
      next Index
      mat S_Old$(Udim(Mat S_Data$))=S_Data$
   fnend
!
   def Fninchecked$(Test$*255,Truevalue$*255)
      if trim$(Test$)=trim$(Truevalue$) then
         let Fninchecked$="^"
      end if
   fnend

   def Fnoutchecked$(Test$*255,Truevalue$*255,Falsevalue$*255,&Return$)
      if Test$(1:1)="^" then
         let Return$=Truevalue$
      else
         if lwrc$(trim$(FalseValue$))<>"~ignore~" then
            let Return$=Falsevalue$
         end if
      end if
   fnend
!
dim TempData$*8000

VALIDATEANDSAVE: ! Validate And Save The Controls
   def Fnvalidateandsave(Mat S_Data$,Mat S_Spec$,Mat S_Subs,Mat S_Old$,Mat F$,Mat F,Mat Fieldsssubs$,Mat Fieldsnsubs$,Mat S$,Mat Screensubs$,[[Screencontrols]];___,Index,Position,Subindex,Return$*255,Number$*1000)
      for Index=1 to Udim(Mat S_Subs)
         if ~Protected(S_Subs(Index)) then ! Should Never Be Protected Because Protected Is Never Added To The Input In The First Place.
            if Trim$(S_Old$(Index))<>Trim$(S_Data$(Index)) then
               #Select# Lwrc$(Trim$(Fieldtype$(S_Subs(Index)))) #Case# "c" # "search" # "combo" # "filter"
! .   ! .         ! First apply screencontrol validation to data value
                  let TempData$=S_Data$(Index)
                  if Trim$(Function$(S_Subs(Index)))="" Or Fnvalidatecontrol(TempData$,Function$(S_Subs(Index)),Index,S_Subs(Index)) then
                     if TempData$<>S_Data$(Index) then let S_Data$(Index)=TempData$
                     if Trim$(Fieldname$(S_Subs(Index)))="" And Trim$(Controlname$(S_Subs(Index)))<>"" And (Subindex:=Srch(Mat Screensubs$,Lwrc$(Trim$(Controlname$(S_Subs(Index))))))>0 then
                        if Uprc$(Cnvrtin$(S_Subs(Index))(1:5))="DATE(" And Pos(Cnvrtin$(S_Subs(Index)),")")>0 then
                           let Number=fnCheckDays(S_Data$(Index),Cnvrtin$(S_Subs(Index)))
                           if Number then
                              let S$(Subindex)=str$(Number)
                           end if
                        else
                           let Number$=S_Data$(Index)
                           if Uprc$(Cnvrtin$(S_Subs(Index))(1:4))="PIC(" And Pos(Cnvrtin$(S_Subs(Index)),")")>0 then
                              ! If its pic, we want to ignore all the insertion characters when we turn it back into a number.
                              let Number$=fnUnCnvrt$(Number$(1:255),CnvrtIn$(S_Subs(Index)))
                           end if
                           if fnEnforceNumber(CnvrtIn$(S_Subs(Index))) then
                              let Number=Val(Number$) conv IgnoreNumber_SField
                              let S$(Subindex)=str$(Number)
                              IgnoreNumber_SField: ! Jump here when bad number entered
                           else
                              let S$(Subindex)=Number$
                           end if
                        end if

                        ! Apply Conversion To Disk
                        ! Only implemented for Dates in C fields and Listview Children
                        if Lwrc$(CnvrtOut$(S_Subs(Index)))(1:5)="date(" and Lwrc$(Trim$(Fieldtype$(S_Subs(Index))))="c" then
                           let S$(Subindex)=date$(val(S$(Subindex)),fnDateMask$(CnvrtOut$(S_Subs(Index)))) error IGNORE
                        end if

                     else
                        if Fnisnumber(Mat Fieldsssubs$,Mat Fieldsnsubs$,Fieldname$(S_Subs(Index))) then
                           let Position=Srch(Mat Fieldsnsubs$,Lwrc$(Trim$(Fieldname$(S_Subs(Index)))))
                           if Position>0 then
                              if Uprc$(Cnvrtin$(S_Subs(Index))(1:5))="DATE(" And Pos(Cnvrtin$(S_Subs(Index)),")")>0 then
                                 let Number=fnCheckDays(S_Data$(Index),Cnvrtin$(S_Subs(Index)))
                                 if Number then
                                    let F(Position)=Number
                                 end if
                              else
                                 let Number$=S_Data$(Index)
                                 if Uprc$(Cnvrtin$(S_Subs(Index))(1:4))="PIC(" And Pos(Cnvrtin$(S_Subs(Index)),")")>0 then
                                    ! If its pic, we want to ignore all the insertion characters when we turn it back into a number.
                                    let Number$=fnUnCnvrt$(Number$(1:255),CnvrtIn$(S_Subs(Index)))
                                 end if

                                 let Number=Val(Number$) conv IgnoreNumber
                                 let F(Position)=Number
                                 IgnoreNumber: ! Jump here when bad number entered
                              end if

                              ! Apply Conversion To Disk
                              ! Only implemented for Dates in C fields and Listview Children
                              if Lwrc$(CnvrtOut$(S_Subs(Index)))(1:5)="date(" and Lwrc$(Trim$(Fieldtype$(S_Subs(Index))))="c" then
                                 let F(Position)=date(F(Position),fnDateMask$(CnvrtOut$(S_Subs(Index)))) error IGNORE
                              end if

                           end if
                        else
                           let Position=Srch(Mat Fieldsssubs$,Lwrc$(Trim$(Fieldname$(S_Subs(Index)))))
                           if Position>0 then


                              if Uprc$(Cnvrtin$(S_Subs(Index))(1:5))="DATE(" And Pos(Cnvrtin$(S_Subs(Index)),")")>0 then
                                 let Number=fnCheckDays(S_Data$(Index),Cnvrtin$(S_Subs(Index)))
                                 if Number then
                                    let F$(Position)=str$(Number)
                                 end if
                              else

                                 if Uprc$(Cnvrtin$(S_Subs(Index))(1:4))="PIC(" And Pos(Cnvrtin$(S_Subs(Index)),")")>0 then
                                    ! If its pic, we want to ignore all the insertion characters when we turn it back into a number.
                                    let S_Data$(Index)=fnUnCnvrt$(S_Data$(Index),CnvrtIn$(S_Subs(Index)))
                                 end if

                                 if fnEnforceNumber(CnvrtIn$(S_Subs(Index))) then
                                    let Number=Val(S_Data$(Index)) conv IgnoreNumber_InString
                                    let F$(Position)=str$(Number)
                                    IgnoreNumber_InString: ! Jump here when bad number entered
                                 else
                                    let F$(Position)=S_Data$(Index)
                                 end if
                              end if

                              ! Apply Conversion To Disk
                              ! Only implemented for Dates in C fields and Listview Children
                              if Lwrc$(CnvrtOut$(S_Subs(Index)))(1:5)="date(" and Lwrc$(Trim$(Fieldtype$(S_Subs(Index))))="c" then
                                 let F$(Position)=date$(val(F$(Position)),fnDateMask$(CnvrtOut$(S_Subs(Index)))) error IGNORE
                              end if

                           end if
                        end if
                     end if
                  else
                     if TempData$<>S_Data$(Index) then let S_Data$(Index)=TempData$
                  end if
               #Case# "check"
                  let TempData$=S_Data$(Index)
                  if Trim$(Function$(S_Subs(Index)))="" Or Fnvalidatecontrol(TempData$,Function$(S_Subs(Index)),Index,S_Subs(Index)) then
                     if TempData$<>S_Data$(Index) then let S_Data$(Index)=TempData$
                     if Trim$(Fieldname$(S_Subs(Index)))="" And Trim$(Controlname$(S_Subs(Index)))<>"" And (Subindex:=Srch(Mat Screensubs$,Lwrc$(Trim$(Controlname$(S_Subs(Index))))))>0 then
                        let Fnoutchecked$(S_Data$(Index),Truevalue$(S_Subs(Index)),Falsevalue$(S_Subs(Index)),S$(Subindex))
                     else

                        if Fnisnumber(Mat Fieldsssubs$,Mat Fieldsnsubs$,Fieldname$(S_Subs(Index))) then
                           let Position=Srch(Mat Fieldsnsubs$,Lwrc$(Trim$(Fieldname$(S_Subs(Index)))))
                           if Position>0 then
                              let Return$=str$(f(position))
                              let Fnoutchecked$(S_Data$(Index),Truevalue$(S_Subs(Index)),Falsevalue$(S_Subs(Index)),Return$)
                              let F(Position)=Fnreturnvalue(Return$)
                           end if
                        else
                           let Position=Srch(Mat Fieldsssubs$,Lwrc$(Trim$(Fieldname$(S_Subs(Index)))))
                           if Position>0 then
                              let Fnoutchecked$(S_Data$(Index),Truevalue$(S_Subs(Index)),Falsevalue$(S_Subs(Index)),F$(Position))
                           end if
                        end if
                     end if
                  else
                     if TempData$<>S_Data$(Index) then let S_Data$(Index)=TempData$
                  end if
! .   !
               #Case Else#
! .   ! .         Ignore All Output Controls
! .   !
               #End Select#
            end if
         end if
      next Index
   fnend

   def fnEnforceNumber(CnvrtIn$*255)
      let CnvrtIn$=uprc$(Trim$(CnvrtIn$))
      if CnvrtIn$="N" or CnvrtIn$(1:2)="N " then
         let fnEnforceNumber=1
      end if
   fnend
!
   def fnUncnvrt$*255(Number$*255,PicSpec$*255;___,CheckFor$*255,ContainsB,ContainsD,ContainsS,ContainsPM,Index)
      if pos(uprc$(CheckFor$),"B") then let ContainsB=1
      if pos(uprc$(CheckFor$),"D") then let ContainsD=1
      ! if pos(uprc$(CheckFor$),"$") then let ContainsS=1
      ! if pos(uprc$(CheckFor$),"-") then let ContainsPM=1
      ! if pos(uprc$(CheckFor$),"+") then let ContainsPM=1

      let CheckFor$=PicSpec$(5:Pos(PicSpec$,")")-1)
      let CheckFor$=srep$(CheckFor$,"Z","")
      let CheckFor$=srep$(CheckFor$,"z","")
      let CheckFor$=srep$(CheckFor$,".","")
      let CheckFor$=srep$(CheckFor$,"#","")
      let CheckFor$=srep$(CheckFor$,"-","")
      let CheckFor$=srep$(CheckFor$,"^","")
      let CheckFor$=srep$(CheckFor$,"B","")
      let CheckFor$=srep$(CheckFor$,"b","")
      let CheckFor$=srep$(CheckFor$,"D","")
      let CheckFor$=srep$(CheckFor$,"d","")
      let CheckFor$=trim$(CheckFor$)
      let Number$=trim$(Number$)

      for Index=1 to len(CheckFor$)
         let Number$=srep$(Number$,CheckFor$(Index:Index),"")
      next Index

      if ContainsB then let Number$=srep$(Number$," ","")
      if ContainsD then let Number$=srep$(Number$,"-","")

      ! Right now we're handling $,+,- in another way, but this other way has the problem mentioned below.
      ! if ContainsS then let Number$=srep$(Number$,"$","")
      ! if ContainsPM then
      !    if pos(Number$,"-") then
      !       let Number$="-"&srep$(Number$,"-","")
      !    end if
      !    let Number$=srep$(Number$,"+","")
      ! end if
      ! $$$$$ The above code won't work when pic forces display of a trailing sign. This logic will still think the trailing sign was an operator error.

      let fnUncnvrt$=Number$
   fnend


CONVERTIN: ! Call Custom Conversion Functions
   def Fnconvertin(&Fieldtext$,Function$*255;ControlIndex,Fieldindex)
      let Fnconvertin=Fnexecute(Function$,Controlindex,Fieldtext$,Fieldindex)
   fnend
!
VALIDATECONTROL: ! Validate A Control Based On Its Validation Routine Or Function Routine
   def Fnvalidatecontrol(&Data$,Validatefunction$*255;Fieldindex,Controlindex)
      if Validatefunction$(1:1)="|" then
! .      ! Preform Predefined Validation Routines Here
      else
         let Fnvalidatecontrol=Fnexecute(Validatefunction$,Controlindex,Data$,Fieldindex)
      end if
   fnend
!
PASSFILTER: ! Test To See If This Record Passes The Filter For A Listview
   def Fnpassfilter$(Mat F$, Mat F,Filterfunction$*255;ControlIndex)
      if Len(Trim$(Filterfunction$)) then
         let Fnpassfilter$=Fnexecute$(Filterfunction$,ControlIndex)
      else
         let Fnpassfilter$="1"
      end if
   fnend
!
ISNUMBER: ! Returns True If Control Is A Number
   def Fnisnumber(Mat Fieldsssubs$,Mat Fieldsnsubs$,Fieldname$*50)
      if Srch(Mat Fieldsnsubs$,Lwrc$(Trim$(Fieldname$)))>0 then
         let Fnisnumber=1
      end if
   fnend

! ************************************************
! *   Date Parser Routine - BR's is too picky    *
! ************************************************

   def library fnDays(String$*255;DateSpec$*255)
      let fnDays=fnCheckDays(String$,DateSpec$)
   fnend

dim Number(3)
dim Format(3)
dim Order(3)
dim Dates(3)
dim f_day, f_month, f_year

   def fnCheckDays(String$*255;DateSpec$*255,___,Month,Day,Year,Delimit$,i,Number,failed,forceyear,TempSpec$*255,Temp$*255,TempNum,TempMonth,TempYear,TestYear) ! Function to extract the date value out of a text file
      ! Thank you CLS for the idea to do relative days with + and -
      #Select# String$(1:1) #Case# "-"
         let Temp$=trim$(lwrc$(String$))
         let TempNum=-123456789
         let TempNum=val(Temp$(2:len(Temp$)-1)) conv Ignore
         if TempNum><-123456789 then
            let Temp$=Temp$(len(Temp$):len(Temp$))

            if Temp$="w" then
               let fnCheckDays=days(Date$("mm/dd/ccyy"),"mm/dd/ccyy")-(TempNum*7) conv Ignore
            else if Temp$="y" then
               let fnCheckDays=days(Date$("mm/dd")&"/"&str$(val(Date$("ccyy"))-TempNum),"mm/dd/ccyy") conv Ignore
            else if Temp$="m" then
               let TempYear=val(Date$("ccyy"))

               let TempMonth=val(date$("mm"))
               let TempMonth-=TempNum
               if TempMonth<1 then let TempMonth+=12 : let TempYear-=1

               let fnCheckDays=days(cnvrt$("PIC(##)",TempMonth)&"/"&Date$("dd")&"/"&str$(TempYear),"mm/dd/ccyy") conv Ignore
            else if Temp$="d" then
               let fnCheckDays=days(Date$("mm/dd/ccyy"),"mm/dd/ccyy")-TempNum conv Ignore
            else
               let fnCheckDays=days(Date$("mm/dd/ccyy"),"mm/dd/ccyy")-val(string$(2:999)) conv Ignore
            end if
         end if
      #Case# "+"
         let Temp$=trim$(lwrc$(String$))
         let TempNum=-123456789
         let TempNum=val(Temp$(2:len(Temp$)-1)) conv Ignore
         if TempNum><-123456789 then
            let Temp$=Temp$(len(Temp$):len(Temp$))

            if Temp$="w" then
               let fnCheckDays=days(Date$("mm/dd/ccyy"),"mm/dd/ccyy")+(TempNum*7) conv Ignore
            else if Temp$="y" then
               let fnCheckDays=days(Date$("mm/dd")&"/"&str$(val(Date$("ccyy"))+TempNum),"mm/dd/ccyy") conv Ignore
            else if Temp$="m" then
               let TempYear=val(Date$("ccyy"))

               let TempMonth=val(date$("mm"))
               let TempMonth+=TempNum
               if TempMonth>12 then let TempMonth-=12 : let TempYear+=1

               let fnCheckDays=days(cnvrt$("PIC(##)",TempMonth)&"/"&Date$("dd")&"/"&str$(TempYear),"mm/dd/ccyy") conv Ignore
            else if Temp$="d" then
               let fnCheckDays=days(Date$("mm/dd/ccyy"),"mm/dd/ccyy")+TempNum conv Ignore
            else
               let fnCheckDays=days(Date$("mm/dd/ccyy"),"mm/dd/ccyy")+val(string$(2:999)) conv Ignore
            end if
         end if
      #Case Else#
         let F_day=1
         let F_month=2
         let F_year=3

         let Not_Read=-1
         let Not_Given=-2

         mat Number(3)
         mat Order(3)

         ! Detect order of date spec
         if Pos(DateSpec$,"(") and Pos(DateSpec$,")") then
            let DateSpec$=uprc$(DateSpec$(Pos(DateSpec$,"(")+1:Pos(DateSpec$,")")-1)) ! Trim out Parens
            let TempSpec$=srep$(DateSpec$,"DAY","") ! Ignore Day Spec
            let Format(F_Month)=pos(TempSpec$,"M")
            let Format(F_Day)=pos(TempSpec$,"D")
            let Format(F_Year)=pos(TempSpec$,"Y")
         else
            ! default to month, day, year
            let Format(F_Month)=1
            let Format(F_Day)=4
            let Format(F_Year)=7
         end if

         ! Sort them to get relative order
         mat Order=aidx(Format)

         ! Consolidate them, we don't care about ones that weren't there
         let fnConsolidateBlanks(mat Order,mat format)

         mat Dates=(Not_Given)

         ! Detect Delimiter used, if any
         if pos(String$,"/") then
            let Delimit$="/"
         else if pos(String$,"-") then
            let Delimit$="-"
         else if pos(String$,",") then
            let Delimit$=","
         else if pos(String$,".") then
            let Delimit$="."
         end if

         ! Are there delimiters?
         if pos(String$,Delimit$) then ! There are. So check if theres a year

            let String$=trim$(String$)
            mat Number=(Not_Read)

            if pos(String$,Delimit$,pos(String$,Delimit$)+1) then
               ! There are three delimiters
               let Number(1)=val(String$(1:pos(String$,Delimit$)-1)) conv Ignore
               let Number(2)=val(String$(pos(String$,Delimit$)+1:pos(String$,Delimit$,pos(String$,Delimit$)+1)-1)) conv Ignore
               let Number(3)=val(String$(pos(String$,Delimit$,pos(String$,Delimit$)+1)+1:len(String$))) conv Ignore
               if Number(3)=Not_Read then
                  let Number(3)=val(String$(pos(String$,Delimit$,pos(String$,Delimit$)+1)+1:pos(String$,Delimit$,pos(String$,Delimit$)+1)+4)) conv Ignore
               end if
               if Number(3)=Not_Read then
                  let Number(3)=val(String$(pos(String$,Delimit$,pos(String$,Delimit$)+1)+1:pos(String$,Delimit$,pos(String$,Delimit$)+1)+2)) conv Ignore
               end if
               if Number(3)=Not_Read then
                  let Number(3)=val(String$(pos(String$,Delimit$,pos(String$,Delimit$)+1)+1:pos(String$,Delimit$,pos(String$,Delimit$)+1)+1)) conv Ignore
               end if
            else
               ! There are only 2 values
               let Number(1)=val(String$(1:pos(String$,Delimit$)-1)) conv Ignore
               let Number(2)=val(String$(pos(String$,Delimit$)+1:len(string$))) conv Ignore
               if Number(2)=Not_Read then
                  let Number(2)=val(String$(pos(String$,Delimit$)+1:pos(String$,Delimit$)+4)) conv Ignore
               end if
               if Number(2)=Not_Read then
                  let Number(2)=val(String$(pos(String$,Delimit$)+1:pos(String$,Delimit$)+2)) conv Ignore
               end if
               if Number(2)=Not_Read then
                  let Number(2)=val(String$(pos(String$,Delimit$)+1:pos(String$,Delimit$)+1)) conv Ignore
               end if
               let Number(3)=Not_Given
            end if

            ! Here, we go from mat Number to Year Month and Day
            for i=1 to udim(mat number)
               if number(i)=Not_Read then
                  let Failed=1
               end if
               if number(i)>1800 then
                  let forceyear=i
               end if
            next i

            if ~failed then
               if ForceYear then
                  ! if any of them are greater then 1800 then its a year
                  ! so ignore order given and suck year up as a year
                  let Dates(f_year)=number(forceyear)
                  let fnConsolidateDirect(mat Number,forceyear)
                  let fnConsolidateChild(mat Order,f_year)
               end if

               ! take the remaining values from their given places
               for i=1 to udim(mat order)
                  let dates(order(i))=number(i)
               next i
            end if
         else
            ! There are no delimiters, so do it by position
            let Number=Not_Read
            let String$=trim$(String$(1:8))
            let Number=val(string$) conv Ignore
            if Number=Not_Read then
               let Failed=1
            end if

            if ~Failed then
               if mod(len(string$),2) then let string$="0"&string$ ! Make string an even length
               if len(String$)=2 then                ! 1 number given
                  if udim(order)>1 then               ! if there's more then one needed
                     let Failed=1                     ! we failed
                  else                                ! otherwise use the number
                     let dates(order(1))=val(string$)
                  end if
               else if len(string$)=4 then           ! 2 nums or a year
                  if udim(order)=1 and order(1)=f_year then ! if we only gave them a year
                     let dates(f_year)=val(string$) ! then its a year
                  else if udim(order)=2 then          ! if we gave them 2 numbers
                     let dates(order(1))=val(string$(1:2))
                     let dates(order(2))=val(string$(3:4))
                  else
                     let Failed=1
                  end if
               else if len(string$)=6 then           ! 3 nums or 1 nums and a year
                  if udim(order)=2 and (order(1)=f_year or order(2)=f_year) then  ! 1 num and 1 year
                     if order(1)=f_year then
                        let dates(order(1))=val(string$(1:4))
                        let dates(order(2))=val(string$(5:6))
                     else if order(2)=f_year then
                        let dates(order(1))=val(string$(1:2))
                        let dates(order(2))=val(string$(3:6))
                     end if
                  else if udim(order)=3 then
                     let dates(order(1))=val(string$(1:2))
                     let dates(order(2))=val(string$(3:4))
                     let dates(order(3))=val(string$(5:6))
                  else
                     let failed=1
                  end if
               else if len(string$)=8 then
                  if udim(mat order)=3 then
                     if order(1)=f_year then
                        let dates(order(1))=val(string$(1:4))
                        let dates(order(2))=val(string$(5:6))
                        let dates(order(3))=val(string$(7:8))
                     else if order(2)=f_year then
                        let dates(order(1))=val(string$(1:2))
                        let dates(order(2))=val(string$(3:6))
                        let dates(order(3))=val(string$(7:8))
                     else if order(3)=f_year then
                        let dates(order(1))=val(string$(1:2))
                        let dates(order(2))=val(string$(3:4))
                        let dates(order(3))=val(string$(5:8))
                     end if
                  else
                     let failed=1
                  end if
               else
                  let failed=1
               end if
            end if
         end if

         if ~failed then
            ! if Day or month aren't given, default them
            if Dates(f_month)<1 then let Dates(f_month)=val(date$("mm"))
            if Dates(f_day)<1 then let Dates(f_day)=1

            if Dates(f_year)=Not_Given then
               ! if they didn't give a year, then use closest year
               let Dates(f_year)=fnFindClosestYear(Dates(f_month),Dates(f_day))
            else if Dates(f_year)>=0 and Dates(f_year)<100 then
               ! if they gave a 2 digit year then use BR's internal function to turn it into a 4 digit year
               let Dates(f_year)=val(date$(days(cnvrt$("pic(##)",Dates(f_year)),"yy"),"ccyy"))
            end if

            let fnCheckDays=days(cnvrt$("pic(##)",Dates(f_month))&"/"&cnvrt$("pic(##)",Dates(f_day))&"/"&cnvrt$("pic(####)",Dates(f_year)),"mm/dd/ccyy") conv Ignore
         else
            let fnCheckDays=days(String$,DateSpec$) error IGNORE
         end if
      #End Select#
   fnend

   ! Tries to make a date using prior year, current year, and next year, and returns the one closest to today.
   def fnFindClosestYear(Month,Day;___,TestDate,Y,Year,Difference,BestDate,BestYear,Today)
      let Year=val(date$("ccyy"))
      let Today=Days(Date$("mm/dd/ccyy"),"mm/dd/ccyy")
      for Y=Year-1 to Year+1
         let TestDate=days(str$(Day)&"/"&str$(Month)&"/"&str$(Y),"dd/mm/ccyy")
         if abs(Today-TestDate)<abs(Today-BestDate) then
            let BestDate=TestDate
            let BestYear=Y
         end if
      next Y
      if ~BestYear then let BestYear=Year
      let fnFindClosestYear=BestYear
   fnend

   def fnConsolidateBlanks(mat Order,mat Format;___,i,j)
      for i=1 to udim(mat Order)
         if format(order(i)) then
            let Order(i-j)=Order(i)
         else
            let j+=1
         end if
      next i
      mat Order((i-1)-j)
   fnend
   def fnConsolidateDirect(mat Array,Number;___,i,j)
      for i=1 to udim(mat Array)
         if i<>Number then
            let Array(i-j)=Array(i)
         else
            let j+=1
         end if
      next i
      mat Array((i-1)-j)
   fnend
   def fnConsolidateDirects(mat Array$,Number;___,i,j)
      for i=1 to udim(mat Array$)
         if i<>Number then
            let Array$(i-j)=Array$(i)
         else
            let j+=1
         end if
      next i
      mat Array$((i-1)-j)
   fnend
   def fnConsolidateChild(mat Array,number;___,i,j)
      for i=1 to udim(mat Array)
         if array(i)<>number then
            let Array(i-j)=Array(i)
         else
            let j+=1
         end if
      next i
      mat Array((i-1)-j)
   fnend

   def fnOpenSticky(Index,Text$*1000,&Window,Control,Rows,Cols,Row,Col,[[ScreenControls]];___,R,C,H,W,Color$*255,Sunken$,Spec$*255) ! Open yellow sticky note on the screen
      let R=VPosition(Control)+1
      let C=HPosition(Control)+2
      let H=Height(Control)
      let W=Width(Control)

      let R+=Row-1
      let C+=Col-1

      if R+H-1>Rows then let R=Rows-H+1
      if R<0 then
         let H+=(R-1)
         let R=1
      end if
      if C+W-1>Cols then let C=Cols-W+1
      if C<0 then
         let W+=(C-1)
         let C=1
      end if

      if len(trim$(ScreenIO$(si_MyChanges))) then
         let Color$=trim$(ScreenIO$(si_MyChanges))
      else
         let Color$="/#000000:#FFFF00"
      end if
      if lwrc$(trim$(FieldType$(control)))="c" or lwrc$(trim$(FieldType$(control)))="search" or lwrc$(trim$(FieldType$(control)))="filter" then let Sunken$="S"

      open #(Window:=fnGetFileNumber): "SRow="&str$(R)&",scol="&str$(C)&",rows="&str$(max(1,H))&",cols="&str$(W),display,outin
      let Spec$="1,1,"&fnCalculateFieldType$(FieldType$(Control),Justify$(Control),W,SpecWidth(Control),H,Attr$(Control))&","&Sunken$&Color$&","&str$(fnStickyBase+Index)
      print #Window, fields Spec$ : Text$
   fnend
!
   def fnCloseAllStickies(mat Windows, mat Subs, mat Data$;___,Index)
      for Index=1 to udim(mat Windows)
         close #Windows(Index):
      next Index
      mat Windows(0)
      mat Subs(0)
      mat Data$(0)
   fnend
!
RESPONDTOUSERACTION: ! Respond To The Users Action Here, Setting Exitmode If Necessary
   def Fnrespondtouseraction(Function,&Exitmode,&Currentfield,&CurrentField$,Mat Subs,[[Screencontrols]];Window,SaveDontAsk,___,KeyVal$*255,RecordVal,Parent_Key$*255,Dummy$*255,Dummy,LoopAgain,Control)
!
! .   ! Esc Button
      if Function=99 then
         if ~Fnsearchclosely(Mat Function$,"exitmode","quitonly") then
            if fnTheresAListview(mat FieldType$) then
               let ExitMode=QuitOnly
            else
               if Savedontask then
                  let Exitmode=Saveandquit
               else
                  let Exitmode=Asksaveandquit
               end if
            end if
         end if
      end if
!
      if Function=0 then
         if fnTheresAListview(mat FieldType$) then
            let Exitmode=Selectandquit
         end if
      end if

      do
         let LoopAgain=0
         if Function<fnKeyBase and Function>fnBase then
            ! Go back up a level
            if fnTheresAListview(Mat FieldType$) then
               let ExitMode=SelectAndQuit
            else
               if Savedontask then
                  let Exitmode=Saveandquit
               else
                  let Exitmode=Asksaveandquit
               end if
            end if
         end if
!
         if Function>fnKeyBase And Function<=fnKeyBase+Udim(Mat Controlname$) then
            let Control=Function-fnKeyBase
            if ~Protected(Control) And Trim$(Fnremoveprotectedattribute$(Attr$(Control)))=Trim$(Attr$(Control)) then

               #Select# Lwrc$(Trim$(Fieldtype$(Control))) #Case# "button" # "caption" # "p"
                  if Trim$(Function$(Control))<>"" then
                     let Fnexecute(Function$(Control),Control)
                  end if
               #Case# "c"
                  if (Newfield:=Srch(Mat Subs,Control))>0 then
                     let Currentfield=Newfield
                  end if
               #Case# "search" # "filter"
                  let Exitmode=Selectandquit     ! This makes "enter" on search box exit
!
               #Case# "screen"
                  ! if trim$(Function$(Control))<>"" then
                  let Dummy$="["&FieldName$(Control)&"]"&function$(Control)
                  let Fnparsescreeninfo(Dummy$,Keyval$,Parent_Key$,Dummy,Dummy,Dummy,Dummy,Dummy,Recordval,ParentKey$)
                  scr_freeze
                  let fnMaster$(fieldname$(Control),Keyval$,VPosition(Control),HPosition(Control),Parent_Key$,Window,0,0,RecordVal,Path$)
                  scr_freeze
                  let fnMaster$(fieldname$(Control),Keyval$,VPosition(Control),HPosition(Control),Parent_Key$,Window,1,0,RecordVal,Path$,0,0,Function)
                  ! end if
               #Case Else#
! .! .            ! Ignore other control types
! .!
               #End Select#

               if fkey<>Function then
                  let Function=Fkey
                  let LoopAgain=1
               end if
            end if
         end if
      loop while LoopAgain
!
      if Function=93 Or Fkey=93 then
         if fnTheresAListview(mat FieldType$) then
            let ExitMode=QuitOnly
         else
            if Savedontask then
               let Exitmode=Saveandquit
            else
               let Exitmode=Asksaveandquit
            end if
         end if
      end if
!
      if Function=92 Or Fkey=92 then
         if Fntheresalistview(Mat Fieldtype$) then
            let Exitmode=Selectandquit
         else
            let Exitmode=Saveandquit
         end if
      end if

      if DefaultMainloopFunction then
         let fnExecute(fnFunctionString$(setting_FunctionFolder$&"defaults\mainloop.brs"))
      end if
!
! .   ! Here's where we link to our MainLoop event
      if Len(Trim$(Screenio$(Si_Loopfn))) then
         let Fnexecute(Screenio$(Si_Loopfn))
      end if
!
   fnend

!
!  #Autonumber# 84000,5
OPENWINDOW: ! Opens A User Screen
   def Fnopenwindow(Vpos,Hpos,Mat Screenio$, Mat Screenio;Parent,DisplayOnly,ForceThisindex,Active,Editing,___,Windowattributes$*1024,Wwindow,Fgcolor$,Bgcolor$,ForceIndex)
!
      let WindowAttributes$=fnMakeWindowSpec$(VPos,HPos,mat ScreenIO$,mat ScreenIO,Parent,DisplayOnly,Active,Editing)
      let Wwindow:=Fngetfilenumber(-1)
!
      if Displayonly then let Forceindex=Wwindow+1000
      if ForceThisIndex then let ForceIndex=ForceThisIndex

      if Forceindex And Fn42 then
         let Windowattributes$ = Windowattributes$ & ", Fkey=" & Str$(ForceIndex)
      end if
!
      open #Wwindow: WindowAttributes$, display, outin

      if ForceIndex and ~fn42 then
         print #Wwindow, fields "1,1,C "&str$(Screenio(Si_Vsize)*Screenio(Si_Hsize))&",/W:T,"&Str$(Forceindex) : "" ! Make it hot
      end if
!
      let Fnopenwindow=Wwindow
!
   fnend

   def fnMakeWindowSpec$*1024(Vpos,Hpos,Mat Screenio$, Mat Screenio;Parent,DisplayOnly,Active,Editing,___,Windowattributes$*1024,Fgcolor$,Bgcolor$)
      if Trim$(Screenio$(Si_Picture))<>"" then
         let Windowattributes$=", Picture="&Screenio$(Si_Picture)
      end if
!
      if Trim$(Screenio$(Si_Attributes))<>"" then
         if Fntestattributes(Screenio$(Si_Attributes),Vpos,Hpos) then
            let Windowattributes$ = Windowattributes$ & ", " & Screenio$(Si_Attributes)
         end if
      end if
!
      if ((Active or ~DisplayOnly) and len(trim$(screenio$(si_activecolor))) and fnTestAttributes(ScreenIO$(Si_ActiveColor),VPos,HPos)) then
         let WindowAttributes$ = WindowAttributes$ & ", N=" & ScreenIO$(si_activecolor)
      else if Active and Editing then
         let WindowAttributes$=WindowAttributes$&", N=/#000000:#FFFF00"
      else if (Trim$(Screenio$(Si_Fgcolor))<>"" Or Trim$(Screenio$(Si_Bgcolor))<>"") And ~Pos(Uprc$(Windowattributes$),"N=") then
         let Fgcolor$=Trim$(Screenio$(Si_Fgcolor))
         let Bgcolor$=Trim$(Screenio$(Si_Bgcolor))
         if Fgcolor$="" then let Fgcolor$="W"
         if Bgcolor$="" then let Bgcolor$="W"
         if Len(Fgcolor$)=6 then let Fgcolor$="#"&Fgcolor$
         if Len(Bgcolor$)=6 then let Bgcolor$="#"&Bgcolor$
!
         let Windowattributes$=Windowattributes$&", N=/"&Fgcolor$&":"&Bgcolor$
      end if
!
      if Screenio(Si_Border) then
         let Windowattributes$ = Windowattributes$ & ", Border=S"
      end if
!
      if Trim$(Screenio$(Si_Windcap))<>"" then
         let Windowattributes$ = Windowattributes$ & ", Caption=" & Trim$(Screenio$(Si_Windcap))
      end if
!
      if Parent=-1 then
         if fn42 then let Windowattributes$ = Windowattributes$ & ", Parent=None"
      else if Parent then
         let Windowattributes$ = Windowattributes$ & ", Parent=" & Str$(Parent)
      end if

      let fnMakeWindowSpec$="SROW=" & Str$(Vpos) & ", SCOL=" & Str$(Hpos) & ", ROWS=" & Str$(Screenio(Si_Vsize)) & ", COLS=" & Str$(Screenio(Si_Hsize)) & Windowattributes$
   fnend


   ! Color Picker
   dim ColorShades$(38)
   def fnColorPicker$(Old$;Row,Column,ViewText$,&Function,___,Window,Index,Current$,Hcode$,Currentspec$*32,Hcodespec$,Sel,Colorrow,Colorcol,Lastindex,Oldhcode$,Newindex)

      let Scr_Freeze
      if ~Row then let Row=14 : let Column=38

      mat Colorspec$(38) : mat Colortext$(38)
      mat Captionspec$(2) : mat Captiontext$(2)

      mat ColorText$=("")

      if ColorShades$(1)="" then
         for Index=1 to Udim(mat Colorspec$)
            let ColorShades$(Index)=fnButtonColor2$(Index)
         next Index
      end if

      let Hcodespec$="6,8,8/CU 6,X"
      let Hcode$=Old$
      if ~Fnvalidhexcolor(Hcode$) then let Hcode$="W"
      let Currentspec$="6,19,CC 20,"&Fnbuildcolor$(Hcode$)&",B14"
      let Current$=Viewtext$
      let Captiontext$(1)="Color Picker"
      let Captionspec$(1)="1,3,C 14,[TB]"
      let Captiontext$(2)="HTML:"
      let Captionspec$(2)="6,2,CR 5,[TB]"

      open #(Window:=Fngetfilenumber(100)): "sRow="&Str$(Row)&",sCol="&Str$(Column)&",Rows=7,Cols=40,Border=S",display,outin
      print #Window, fields Mat Captionspec$ : Mat Captiontext$
      print #Window, fields "4,5,CC 8,/W:W,B7001;4,17,CC 8,/W:W,B7002;4,29,CC 8,/W:W,B7003" : "W","T",""
      print #Window, fields "1,35,CC 5,/W:W,B8000" : "Reset"
      do
         mat ColorText$=("")
         for Index=1 to udim(mat ColorSpec$)
            let Colorrow=2
            let Colorcol=Index+1
            let Colorspec$(Index)=Str$(Colorrow)&","&Str$(Colorcol)&",C 1,"&ColorShades$(Index)&",B71"&cnvrt$("pic(##)",Index)
            if (lwrc$(ColorShades$(Index))(11:16)=lwrc$(OldHCode$)) then
               let Colortext$(Index)="*"
            end if
         next Index
         print #Window, fields Mat Colorspec$ : Mat Colortext$
         print #Window, fields Currentspec$ : Current$
         rinput #Window, fields Hcodespec$ : Hcode$
         let Sel=Fkey : if Sel=0 then let Sel=14
         if Sel>7000 then
            #Select# Sel #Case# 7001
               let Hcode$ = "W"
            #Case# 7002
               let Hcode$ = "T"
            #Case# 7003
               let Hcode$ = ""
            #Case# 8000
               for Index=1 to Udim(mat Colorspec$)
                  let ColorShades$(Index)=fnButtonColor2$(Index)
               next Index
            #Case Else#
               let ColorShades$(Sel-7100)=FnSelectShadeColor$(ColorShades$(Sel-7100),Sel-7100,1+Row,(Sel-7099)+Column) ! Row is 2, Col is Index+1
               let Hcode$ =ColorShades$(Sel-7100)(11:16)
            #End Select#
         end if
         if Hcode$<>Oldhcode$ then ! If Hcode$ Changed Then
            if Hcode$="" Or Fnvalidhexcolor(Hcode$) then
               let Oldhcode$=Hcode$
            else
               let Hcode$=Oldhcode$
            end if
         end if
         let Currentspec$=Currentspec$(1:Pos(Currentspec$,"/")-1)&Fnbuildcolor$(Hcode$)&",B14"
      loop Until (Sel=14) Or (Sel=99) Or ((Sel>1100) And (Sel<1699)) Or (Sel=98) Or (Sel=93) Or (Sel=44) Or (Sel=19) or Fkey=93
      if Sel=99 then
         let Fncolorpicker$=Old$
      else
         let Fncolorpicker$=Hcode$
      end if
      if (Sel<>14) And (Sel<>99) then let Function=Sel
      close #Window:
   fnend

   dim ShadeSpec$(36)*32,ShadeText$(36)

   def FnSelectShadeColor$(SCode$,Index;SRow,SCol,___,Window,Row,Col,Sel,X$,ShadeIndex,StartCol,StartRow,ShadeColor$)
      if len(SCode$)=6 then let Scode$=fnBuildColor$(SCode$)
      if ~SRow then let SRow=10
      if ~SCol then let SCol=30

      let StartCol=6
      let StartRow=1
      mat ShadeText$=("")

      for Row=1 to 6
         for Col=1 to 6
            let ShadeIndex=(Row-1)*6+Col
            let ShadeColor$=FnShadeColor$(Index,Row,Col)
            let ShadeSpec$(ShadeIndex)=str$(Row)&","&str$(Col)&",C 1,"&ShadeColor$&",B71"&str$(Row)&str$(Col)
            if lwrc$(ShadeColor$)=lwrc$(SCode$) then
               let ShadeText$(ShadeIndex)="*"
               let StartCol=Col
               let StartRow=Row
            end if
         next Col
      next Row

      let SCol=max(2,SCol-StartCol)
      let SRow=max(2,(SRow-StartRow)+1)

      open #(Window:=fnGetFileNumber): "srow="&str$(SRow)&",scol="&str$(SCol)&",rows=6,cols=6,border=s", display, outin

      print #Window, fields Mat ShadeSpec$ : Mat ShadeText$
      let X$=""
      rinput #0, fields "2,2,C 1,AEX" : X$
      let Sel=Fkey : if Sel=0 then let Sel=14
      if Sel>7100 then
         let SCode$=fnShadeColor$(Index,val(str$(Sel)(3:3)),val(str$(sel)(4:4)))
      end if

      let fnSelectShadeColor$=SCode$
      close #Window:
   fnend

   dim Colorspec$(216)*31,Colortext$(216)
   dim Captionspec$(2),Captiontext$(2)

COLORPICKERH: !   ***** Allows The User To Select A Color And Returns Hex
   def Fncolorpickerh$(Old$;Row,Column,Viewtext$,&Function,___,Window,Index,Current$,Hcode$,Currentspec$*32,Hcodespec$,Sel,Colorrow,Colorcol,Lastindex,Oldhcode$,Newindex)
      let Scr_Freeze
      if ~Row then let Row=14 : let Column=38
      mat ColorSpec$(216) :  mat ColorText$(216)
      mat CaptionSpec$(2) :  mat CaptionText$(2)

      for Index=1 to Udim(Colorspec$)
         let Colorrow=Int((Index-1)/36)+2 !:
         let Colorcol=Mod(Index-1,36)+3 !:
         let Colorspec$(Index)=Str$(Colorrow)&","&Str$(Colorcol)&",C 1,"&Fnbuttoncolor$(Colorrow,Colorcol)&",B7"&Str$(Colorrow)&Cnvrt$("pic(##)",Colorcol)
         if (Fnbuttoncolor$(Colorrow,Colorcol)(11:16)=Old$) then !:
            let Colortext$(Index)="*" !:
            let Lastindex=Index !:
            let Oldhcode$=Old$ !:
         else !:
            let Colortext$(Index)=" "
      next Index
      let Hcodespec$="11,8,8/CU 6,X"
      let Hcode$=Old$
      if ~Fnvalidhexcolor(Hcode$) then let Hcode$="W"
      let Currentspec$="11,19,CC 20,"&Fnbuildcolor$(Hcode$)&",B14"
      let Current$=Viewtext$
      let Captiontext$(1)="Color Picker"
      let Captionspec$(1)="1,3,C 14,[TB]"
      let Captiontext$(2)="HTML:"
      let Captionspec$(2)="11,2,CR 5,[TB]"
      open #(Window:=Fngetfilenumber(100)): "sRow="&Str$(Row)&",sCol="&Str$(Column)&",Rows=12,Cols=40,Border=S",display,outin
      print #Window, fields Mat Captionspec$ : Mat Captiontext$
      print #Window, fields "9,5,CC 8,,B7001;9,17,CC 8,,B7002;9,29,CC 8,,B7003" : "W","T",""
      do
         print #Window, fields Mat Colorspec$ : Mat Colortext$
         print #Window, fields Currentspec$ : Current$
         rinput #Window, fields Hcodespec$ : Hcode$
         let Sel=Fkey : if Sel=0 then let Sel=14
         if Sel>7000 then
            #Select# Sel #Case# 7001
               let Hcode$ = "W"
            #Case# 7002
               let Hcode$ = "T"
            #Case# 7003
               let Hcode$ = ""
            #Case Else#
               let Hcode$ = Fnbuttoncolor$(Val(Str$(Sel)(2:2)),Val(Str$(Sel)(3:4)))(11:16)
            #End Select#
         end if
         if Hcode$<>Oldhcode$ then ! If Hcode$ Changed Then
            if Hcode$="" Or Fnvalidhexcolor(Hcode$) then
               if Lastindex then let Colortext$(Lastindex)=" "
               let Oldhcode$=Hcode$
               let Lastindex=Fnsearchclosely(Mat Colorspec$,":#"&Hcode$)
               if Lastindex then let Colortext$(Lastindex)="*"
            else
               let Hcode$=Oldhcode$
            end if
         end if
         let Currentspec$=Currentspec$(1:Pos(Currentspec$,"/")-1)&Fnbuildcolor$(Hcode$)&",B14"
      loop Until (Sel=14) Or (Sel=99) Or ((Sel>1100) And (Sel<1699)) Or (Sel=98) Or (Sel=93) Or (Sel=44) Or (Sel=19)
      if Sel=99 then
         let Fncolorpickerh$=Old$
      else
         let Fncolorpickerh$=Hcode$
      end if
      if (Sel<>14) And (Sel<>99) then let Function=Sel
      close #Window:
   fnend
!
BUTTONCOLOR: !   ***** Returns Fg/Bg Color 0f A Specific Button
   def Fnbuttoncolor$(Row,Col;___,R,G,B)
      let R=Int((Col-3)/6)
      let G=Mod((Col-3),6)
      let B=7-Row
      let Fnbuttoncolor$=Fnbuildcolor$(Fnpattern$(R)&Fnpattern$(G)&Fnpattern$(B))
   fnend
   def Fnbuttoncolor2$(Index;___,R,G,B)
      let fnButtonRGB(Index,R,G,B)
      let Fnbuttoncolor2$=Fnbuildcolor$(Fnpattern2$(R)&Fnpattern2$(G)&Fnpattern2$(B))
   fnend

   def fnShadeColor$(Index,Row,Col;___,R,G,B,Brightness,Contrast)
      let fnButtonRGB(Index,R,G,B)
      let Contrast=(6-Row)/5
      let Brightness=(Col-1)/5

      let R=6-R
      let G=6-G
      let B=6-B

      let R*=Contrast
      let G*=Contrast
      let B*=Contrast

      let R=6-R
      let G=6-G
      let B=6-B

      let R*=Brightness
      let G*=Brightness
      let B*=Brightness

      let fnShadeColor$=fnBuildColor$(fnPattern2$(R)&fnPattern2$(G)&fnPattern2$(B))
   fnend

   def fnButtonRGB(Index,&R,&G,&B)
      if Index<=1 then
         let R=6
         let G=6
         let B=6
      else if Index<=2 then
         let R=0
         let G=0
         let B=0
      else if Index<=8 then
         let R=6
         let G=Index-2
         let B=0
      else if Index<=14 then
         let R=14-Index
         let G=6
         let B=0
      else if Index<=20 then
         let R=0
         let G=6
         let B=Index-14
      else if Index<=26 then
         let R=0
         let G=26-Index
         let B=6
      else if Index<=32 then
         let R=Index-26
         let G=0
         let B=6
      else if Index<=38 then
         let R=6
         let G=0
         let B=38-Index
      end if
   fnend

!
BUILDCOLOR: !   ***** Builds A Forground And Background That Match
   def Fnbuildcolor$(Bkg$;___,Number)
      #Select# Len(Trim$(Bkg$)) #Case# 6
         let Number=10
         let Number=Val(Bkg$(3:3)) conv IGNORE
         if Number<9 then
            let Fnbuildcolor$="/#FFFFFF:#"&Bkg$
         else
            let Fnbuildcolor$="/#000000:#"&Bkg$
         end if
      #Case Else#
         let Fnbuildcolor$="/W:W"
      #End Select#
   fnend
!
PATTERN: !   ****** Returns A Hex Code Pattern Based On Entered Number
   def Fnpattern$(X)
      #Select# X #Case#  0
         let Fnpattern$="00"
      #Case#  1
         let Fnpattern$="33"
      #Case# 2
         let Fnpattern$="66"
      #Case# 3
         let Fnpattern$="99"
      #Case# 4
         let Fnpattern$="CC"
      #Case# 5
         let Fnpattern$="FF"
      #End Select#
   fnend

   def Fnpattern2$(X)
      let X*=255
      let X/=6
      let fnPattern2$=unhex$(chr$(X))
   fnend
!
VALIDHEXCOLOR: !   ***** Returns 1  If Valid Color
   def Fnvalidhexcolor(Hc$;___,Index,Invalid)
      #Select# Trim$(Hc$) #Case# "W" # "T"
         let Fnvalidhexcolor=1
      #Case Else#
         if len(Hc$)=6 then
            for Index=1 to 6
               if ~(Pos("0123456789ABCDEF",Hc$(Index:Index))) then let Invalid=1
            next Index
         else
            let Invalid=1
         end if
         let Fnvalidhexcolor=~Invalid
      #End Select#
   fnend

   dim ReadSettings
   def fnSettings
      if ~ReadSettings then
         let fnDefaultSettings
         if exists("screenio.ini") then
            execute "*subproc screenio.ini"
         else if exists("screenio\screenio.ini") then
            execute "*subproc screenio\screenio.ini"
         else if exists("\screenio.ini") then
            execute "*subproc \screenio.ini"
         else if exists("\screenio\screenio.ini") then
            execute "*subproc \screenio\screenio.ini"
         end if
         let ReadSettings=1

         let fnParseSettings

         library setting_FileIOPath$ : Fnopenfile, Fnclosefile, Fngetfilenumber, Fnkey$, Fnbuildkey$, Fnreadlayoutarrays, Fndoeslayoutexist, Fnreadallkeys, Fnreadlayouts, Fndisplaylength, Fnupdatefile, fnReadNumber, fnReadLayoutPath$, FnReadsubs, fnReadUnopenedNumber,fnReadUnopenedDescription$,fnLog,fnLogArray,fnSetLogChanges,fnLogChanges,fnRunProcFile,fnBuildProcFile,fnReadLockedUsers, fnAskCombo$, fnClearLayoutCache
      end if
   fnend
!
EXECUTE: ! Execute Custom Code Call Here
   def Fnexecute(Function$*255;&Controlindex,&Fieldtext$,&Fieldindex,___,Pound$)
      let Pound$="#"
      #Select# Function$(1:1) #Case# Pound$ # "{"
         let Fnexecute=Fnexecutefunction(Function$)
      #Case# "["
         let Fnexecute=Fnreturnvalue(Fnexecutescreen$(Function$))
      #Case# "%"
         chain Function$(2:Len(Function$))
      #Case Else#
         execute Function$
      #End Select#
   fnend
   def Fnexecute$(Function$*255;&Controlindex,&Fieldtext$,&Fieldindex,___,Pound$)
      let Pound$="#"
      #Select# Function$(1:1) #Case# Pound$ # "{"
         let Fnexecute$=Fnexecutefunction$(Function$)
      #Case# "["
         let Fnexecute$=Fnexecutescreen$(Function$)
      #Case# "%"
         chain Function$(2:Len(Function$))
      #Case Else#
         execute Function$
      #End Select#
   fnend
   def fnExecuteGetData(Function$*255,mat ReturnData$;ControlIndex,FieldText$,FieldIndex)
      let Pound$="#"
      #Select# Function$(1:1) #Case# Pound$ # "{"
         let FnexecuteGetData=Fnexecutefunction(Function$)
      #End Select#
   fnend
!
CALLSCREEN: ! Use Executescreen To Launch A Screenio Screen. (Use This When Calling Screenio Screens From Code From Within Other Screenio Screens.)
   def library Fncallscreen$*255(Screen$*255;Keyval$*255,Parent_Key$*255,Display_Only,Parent_Window,Dontredolistview,Recordval,mat PassedData$,UseMyF,mat MyF$,mat MyF,Path$*255,Selecting)
      if Screen$(1:1)<>"[" then let Screen$(1:0)="["
      if Screen$(Len(Screen$):Len(Screen$))<>"]" then let Screen$=Screen$&"]"
      let Fncallscreen$=Fnexecutescreen$(Screen$,Keyval$,Parent_Key$,Display_Only,Parent_Window,Dontredolistview,Recordval,mat PassedData$,UseMyF,mat MyF$,mat MyF,Path$,Selecting)
   fnend
!
EXECUTESCREEN: ! Push All Arrays Onto Stack And Jump To Another Screen
   def Fnexecutescreen$*255(Screen$*255;Keyval$*255,Parent_Key$*255,Display_Only,Parent_Window,Dontredolistview,Recordval,mat PassedData$,UseMyF,mat MyF$,mat MyF,_Path$*255,Selecting,___,Target_Row,Target_Col,Pth$*255)
      if _Path$<>"" then let Pth$=_Path$ else let Pth$=Path$
      let Fnparsescreeninfo(Screen$,Keyval$,Parent_Key$,Display_Only,Parent_Window,Dontredolistview,Target_Row,Target_Col,Recordval,ParentKey$)
      let Fnexecutescreen$=Fnmasterfm$(Screen$,Keyval$,Target_Row,Target_Col,Parent_Key$,Parent_Window,Display_Only,Dontredolistview,Recordval,Pth$,Selecting,0,0,0,mat PassedData$,UseMyF,mat MyF$,mat MyF)
   fnend
!
   def Fnparsescreeninfo(&Screen$,&Key$,&Parentkey$,&Displayonly,&Parentwindow,&Dontredolistview,&Targetrow,&Targetcol,&Record;ThisParentKey$*255,___,Dividerposition,Endscreencode)
      let Endscreencode=Dividerposition=Pos(Screen$,"(")
      if Dividerposition < Pos(Screen$,"]") then
         let Targetrow=Val(Screen$(Pos(Screen$,"(")+1:Pos(Screen$,",")-1)) conv IGNORE
         let Targetcol=Val(Screen$(Pos(Screen$,",")+1:Pos(Screen$,")")-1)) conv IGNORE
      end if
!
      let Dividerposition=Pos(Screen$,"]")
!
      if Endscreencode=0 then
         let Endscreencode=Dividerposition
      else if Dividerposition=0 then
         let Endscreencode=Endscreencode
      else
         let Endscreencode=Min(Dividerposition,Endscreencode)
      end if
!
      if Dividerposition then
         if Trim$(Screen$(Dividerposition+1:Len(Screen$)))<>"" then
            if Trim$(Screen$(Dividerposition+1:Len(Screen$)))(1:1)="{" Or Trim$(Screen$(Dividerposition+1:Len(Screen$)))(1:1)="#" then
               let Key$=Fnexecutefunction$(Trim$(Screen$(Dividerposition+1:Len(Screen$))))
            else if Trim$(Screen$(Dividerposition+1:Len(Screen$)))(1:1)="*" then
               execute Trim$(Screen$(Dividerposition+1:Len(Screen$)))
            else
               execute ""&Trim$(Screen$(Dividerposition+1:Len(Screen$)))
            end if
         end if
!
         let Screen$=Uprc$(Screen$(2:Endscreencode-1))
      else if Endscreencode then
         let Screen$=Uprc$(Screen$(2:Endscreencode-1))
      else
         let Screen$=Uprc$(Screen$(2:Len(Screen$)))
      end if
      let Screen$=Trim$(Screen$)
   fnend

   ! Clear all screenio arrays in case they've been sullied by a
   !  previous screen.
   def fnClearAllArrays
      mat S$(0) : mat F$(0) : mat F(0) : mat FieldsSSubs$(0) : mat FieldsNSubs$(0) : mat ScreenSubs$(0) : mat Form$(0) : mat S_Subs(0) : mat TempData$(0)
      mat Temp_S_Spec$(0) : mat SelectedRecords(0) : mat SelectedKeys$(0) : mat VisibleKeys$(0) : mat VisibleRecords(0) : mat Save_S$(0) : mat Save_F(0) : mat Save_F$(0)
      mat Save_S_Subs(0) : mat Save_S_Data$(0) : mat Changed_S_Subs(0) : mat Changed_S_Data$(0) : mat Other_S_Subs(0) : mat Other_S_Data$(0)
      mat OtherChanged_S_Subs(0) : mat OtherChanged_S_Data$(0) : mat Read_F(0)
      mat Read_F$(0) : mat FrameKeys$(0) : mat FrameSpecControl$(0) : mat FrameWindows(0) : mat ScreenKeys$(0) : mat ScreenWindows(0)
!
      mat Controlname$(0) : mat Fieldname$(0) : mat Function$(0) : mat CnvrtIn$(0) : mat Specwidth(0)
      mat Screenio$(0) : mat Screenio(0) : mat Description$(0) : mat Vposition(0) : mat Hposition(0) : mat Fieldtype$(0) : mat Width(0)
      mat Height(0) : mat Truevalue$(0) : mat Falsevalue$(0) : mat Picture$(0) : mat Parent$(0) : mat Fgcolor$(0) : mat Bgcolor$(0)
      mat Justify$(0) : mat Attr$(0) : mat Protected(0) : mat Invisible(0) : mat Tooltip$(0) : mat CnvrtOut$(0) : mat MultiSelect(0)
      mat GridLines(0) : mat UserData$(0) : mat S_Old$(0) : mat S_Data$(0) : mat S_Data(0) : mat S_Spec$(0)
   fnend
!
! #Autonumber# 90000,2
STACK: ! Functions To Manage The Stack
   dim Stack$(1)*255
   dim Longstack$(1)*2047
   dim Stack(1)
!
   dim Undostack$(1)*255
   dim Undolongstack$(1)*2047
   dim Undostack(1)

   dim Size1(1)
   dim Size2(1)
   dim Size3(1)
!
   def Fnpushmemory(;___,StringArrays,Numberofstringarrays,LongString$*800)
      ! Test how much we're about to push.
      let Longstring$="[[Screencontrols1]]"
      let Longstring$=Longstring$&"[[Screencontrols2]]"
      let Numberofstringarrays=Len(Longstring$)-Len(Srep$(Longstring$,"$",""))
      let StringArrays=Udim(Mat Controlname$)*Numberofstringarrays+Udim(Mat Screenio$)
      let StringArrays+=udim(Mat Screensubs$)+udim(Mat S$)+udim(Mat Form$)+udim(Mat F$)
      let StringArrays+=udim(Mat Fieldsssubs$)+udim(Mat Fieldsnsubs$)+udim(Mat Temp_S_Spec$)
      let StringArrays+=udim(Mat Fieldssdescription$)+udim(Mat FieldsNdescription$)+udim(Mat Fieldssspec$)+udim(Mat Fieldsnspec$)
      let StringArrays+=udim(Mat Fieldssdatespec$)+udim(Mat FieldsNdateSpec$)
      let StringArrays+=udim(Mat Selectedkeys$)+udim(Mat Save_S$)+udim(Mat Save_F$)
      let StringArrays+=udim(Mat Visiblekeys$)
      let StringArrays+=udim(mat Save_S_Data$)+udim(mat Changed_S_Data$)+udim(mat Other_S_Data$)
      let StringArrays+=udim(mat OtherChanged_S_Data$)+udim(mat Read_F$)+udim(mat FrameKeys$)+udim(mat FrameSpecControl$)+Udim(ScreenKeys$)

      if ~fn42 and (udim(mat Stack$)+StringArrays>4000 or udim(mat LongStack$)>400 or udim(mat Stack)>20000) then
         let msgbox("We didn't have enough memory to load this screen. Consider upgrading to BR 4.2 or don't load so many screens at one time.","Out of Memory")
         let fnPushMemory=1 ! Out of memory Error
      else
         let fnPushData(0,1)
      end if
   fnend
   def Fnpopmemory(;Dontredolistview)
      let fnPopData
!
      let Fnexecutesetsubscripts(Mat Screensubs$,"sio_")
      let Fnexecutesetsubscripts(Mat Controlname$,"ctl_")
      let fnExecuteUniqueSubscripts(Mat ControlName$,"ctl_")

      let Fnexecutesetsubscripts(Mat Fieldsnsubs$,Prefix$)
      let Fnexecutesetsubscripts(Mat Fieldsssubs$,Prefix$)
!
      let Fnestablishlibrarylinkage
!
      if Wwindow=0 Or File(Wwindow)=-1 then
         let Wwindow=Fnopenwindow(Row,Col,Mat Screenio$,Mat Screenio)
         let fnDrawFrames(WWindow,mat ScreenIO$,mat ScreenIO,[[ScreenControls]],1)
         let fnDrawScreens(WWindow,mat ScreenIO$,mat ScreenIO,[[ScreenControls]],1)
         let Fndrawalllistviews(Wwindow,Mat Screenio$,Mat Screenio,[[Screencontrols]],1)
         let Dontredolistview=0 ! Force Redo Listview If Window Has To Be Rebuilt.
         let RepopulateCombo=1 ! Force Repuplate Combo if Window has to be rebuilt.
      end if
!
      if ~Dontredolistview then
         let Lastrow=Fnpopulatealllistviews(Wwindow,Fdatafile,Mat Fieldsssubs$,Mat Fieldsnsubs$,Mat S$,Mat Screensubs$,Mat Form$,mat ListviewRecords,[[Screencontrols]])
         mat Old_Data=(0) ! Clear information so it forces read again.
         Mat Rlv_Savereaddata$=("")
         let S_CurrentRow=0
      end if
   fnend
!
Pack: ! Pack Data Functions
!
   dim ScreenData$(1)*255
   dim ScreenLongData$(1)*2047
   dim ScreenData(1)

   ! AltStack:
   !  0 - Regular Stack - This is used when loading a screen from inside another screen.
   !  1 - Undo Stack - This is used when tracking undo history while editing a screen
   !  2 - Custom Function Parameter Stack - This is used to pass the bulk of screen data into your helper library in 2 simple variables.
   !
   def fnPushData(;AltStack,Wipe)
      if AltStack<>2 then
         let fnPush$(mat PassedInF$,AltStack,Wipe)
         let fnPush(mat PassedInF,AltStack,Wipe)
         let Fnpush$(Mat S$,AltStack,Wipe)
         let Fnpush$(Mat F$,AltStack,Wipe)
         let Fnpush(Mat F,AltStack,Wipe)

         let Fnpush$(Mat FieldsSsubs$,AltStack,Wipe)
         let Fnpush$(Mat FieldsNsubs$,AltStack,Wipe)

         let Fnpush$(Mat Screensubs$,AltStack,Wipe)
         let Fnpush$(Mat Form$,AltStack,Wipe)
         let fnPush(Mat S_Subs,AltStack,Wipe)
         let fnPushValue$(TempData$,AltStack,Wipe)

         let Fnpush$(Mat Temp_S_Spec$,AltStack,Wipe)
         let fnPush(mat Old_Data,AltStack,Wipe)
         let fnPush$(mat Rlv_SaveReadData$,AltStack,Wipe)
      end if

      let Fnpush$(Mat FieldsSdescription$,AltStack,Wipe)
      let Fnpush$(Mat FieldsNdescription$,AltStack,Wipe)
      let Fnpush$(Mat FieldsSspec$,AltStack,Wipe)
      let Fnpush$(Mat FieldsNspec$,AltStack,Wipe)
      let Fnpush$(Mat FieldsSdatespec$,AltStack,Wipe)
      let Fnpush$(Mat FieldsNdateSpec$,AltStack,Wipe)

      let Fnpush(Mat SelectedRecords,AltStack,Wipe)
      let Fnpush$(Mat SelectedKeys$,AltStack,Wipe)
      let Fnpush(Mat VisibleRecords,AltStack,Wipe)
      let Fnpush$(Mat VisibleKeys$,AltStack,Wipe)
      let Fnpush$(Mat Save_S$,AltStack,Wipe)
      let Fnpush(Mat Save_F,AltStack,Wipe)
      let Fnpush$(Mat Save_F$,AltStack,Wipe)

      let fnpush(mat Save_S_Subs,AltStack,Wipe)
      let fnpush$(mat Save_S_Data$,AltStack,Wipe)
      let fnpush(Mat Changed_S_Subs,AltStack,Wipe)
      let fnpush$(mat Changed_S_Data$,AltStack,Wipe)
      let fnpush(Mat Other_S_Subs,AltStack,Wipe)
      let fnpush$(mat Other_S_Data$,AltStack,Wipe)
      let fnpush(Mat OtherChanged_S_Subs,AltStack,Wipe)
      let fnpush$(mat OtherChanged_S_Data$,AltStack,Wipe)
      let fnPush(mat Read_F,AltStack,Wipe)
      let fnPush$(mat Read_F$,AltStack,Wipe)
      let fnPush$(mat ControlSpec$,AltStack,Wipe)
!
      let Fnpushscreen(Mat Screenio$, Mat Screenio, [[Screencontrols]],AltStack,Wipe)
   fnend
   def fnPopData(;AltStack)
      let Fnpopscreen(Mat Screenio$, Mat Screenio, [[Screencontrols]],AltStack)
!
      let fnPop$(mat ControlSpec$,AltStack)
      let fnPop$(mat Read_F$,AltStack)
      let fnPop(mat Read_F,AltStack)
      let fnpop$(mat OtherChanged_S_Data$,AltStack)
      let fnpop(Mat OtherChanged_S_Subs,AltStack)
      let fnpop$(mat Other_S_Data$,AltStack)
      let fnpop(Mat Other_S_Subs,AltStack)
      let fnpop$(mat Changed_S_Data$,AltStack)
      let fnpop(Mat Changed_S_Subs,AltStack)
      let fnpop$(mat Save_S_Data$,AltStack)
      let fnpop(mat Save_S_Subs,AltStack)

      let Fnpop$(Mat Save_F$,AltStack)
      let Fnpop(Mat Save_F,AltStack)
      let Fnpop$(Mat Save_S$,AltStack)
      let Fnpop$(Mat Visiblekeys$,AltStack)
      let Fnpop(Mat Visiblerecords,AltStack)
      let Fnpop$(Mat Selectedkeys$,AltStack)
      let Fnpop(Mat Selectedrecords,AltStack)

      let Fnpop$(Mat FieldsNdateSpec$,AltStack)
      let Fnpop$(Mat FieldsSdatespec$,AltStack)
      let Fnpop$(Mat FieldsNspec$,AltStack)
      let Fnpop$(Mat FieldsSspec$,AltStack)
      let Fnpop$(Mat FieldsNdescription$,AltStack)
      let Fnpop$(Mat FieldsSdescription$,AltStack)

      if AltStack<>2 then
         let fnPop$(mat Rlv_SaveReadData$,AltStack)
         let fnPop(Mat Old_Data,AltStack)
         let Fnpop$(Mat Temp_S_Spec$,AltStack)

         let fnPopValue$(TempData$,AltStack)
         let fnPop(Mat S_Subs,AltStack)
         let Fnpop$(Mat Form$,AltStack)
         let Fnpop$(Mat Screensubs$,AltStack)

         let Fnpop$(Mat Fieldsnsubs$,AltStack)
         let Fnpop$(Mat Fieldsssubs$,AltStack)

         let Fnpop(Mat F,AltStack)
         let Fnpop$(Mat F$,AltStack)
         let Fnpop$(Mat S$,AltStack)
         let fnPop(mat PassedInF,AltStack)
         let fnPop$(mat PassedInF$,AltStack)
      end if
   fnend

   def fnPushScreen(Mat ScreenIO$, Mat ScreenIO, [[ScreenControls]];AltStack,Wipe,___,Stack1,Stack2,Stack3)

      if AltStack=1 then
         let Stack1=udim(mat UndoStack$)
         let Stack2=udim(mat UndoLongStack$)
         let Stack3=udim(mat UndoStack)
      end if

      if AltStack<>2 then
         let Fnpush$(Mat Controlname$,AltStack,Wipe)
         let Fnpush$(Mat Fieldname$,AltStack,Wipe)
         let Fnpush$(Mat Function$,AltStack,Wipe)
         let Fnpush$(Mat CnvrtIn$,AltStack,Wipe)
         let Fnpush(Mat Specwidth,AltStack,Wipe)
      end if

      let Fnpush$(Mat Screenio$,AltStack,Wipe)
      let Fnpush(Mat Screenio,AltStack,Wipe)
      let Fnpush$(Mat Description$,AltStack,Wipe)
      let Fnpush(Mat Vposition,AltStack,Wipe)
      let Fnpush(Mat Hposition,AltStack,Wipe)
      let Fnpush$(Mat Fieldtype$,AltStack,Wipe)
      let Fnpush(Mat Width,AltStack,Wipe)
      let Fnpush(Mat Height,AltStack,Wipe)
      let Fnpush$(Mat Truevalue$,AltStack,Wipe)
      let Fnpush$(Mat Falsevalue$,AltStack,Wipe)
      let Fnpush$(Mat Picture$,AltStack,Wipe)
      let Fnpush$(Mat Parent$,AltStack,Wipe)
      let Fnpush$(Mat Fgcolor$,AltStack,Wipe)
      let Fnpush$(Mat Bgcolor$,AltStack,Wipe)
      let Fnpush$(Mat Justify$,AltStack,Wipe)
      let Fnpush$(Mat Attr$,AltStack,Wipe)
      let Fnpush(Mat Protected,AltStack,Wipe)
      let Fnpush(Mat Invisible,AltStack,Wipe)
      let fnpush$(Mat Tooltip$,AltStack,Wipe)
      let Fnpush$(Mat CnvrtOut$,AltStack,Wipe)
      let Fnpush(Mat MultiSelect,AltStack,Wipe)
      let Fnpush(Mat GridLines,AltStack,Wipe)
      let fnPush$(Mat UserData$,AltStack,Wipe)
      let fnPush$(Mat S_Old$,AltStack,Wipe)
      let fnPush$(Mat S_Data$,AltStack,Wipe)
      let fnPush(Mat S_Data,AltStack,Wipe)
      let fnPush$(Mat S_Spec$,AltStack,Wipe)
      let fnPush$(Mat FrameKeys$,AltStack,Wipe)
      let fnPush$(Mat FrameSpecControl$,AltStack,Wipe)
      let fnPush(Mat FrameWindows,AltStack,Wipe)
      let fnPush$(Mat ScreenKeys$,AltStack,Wipe)
      let fnPush(Mat ScreenWindows,AltStack,Wipe)

      if AltStack=1 then
         if udim(mat Size1)=0 or udim(mat Size2)=0 or udim(mat Size3)=0 or Size1(udim(mat Size1))+Size2(udim(mat Size2))+Size3(udim(mat Size3)) then
            mat Size1(udim(mat Size1)+1)
            mat Size2(udim(mat Size1))
            mat Size3(udim(mat Size1))
         end if

         let Size1(udim(mat Size1))=udim(mat UndoStack$)-Stack1
         let Size2(udim(mat Size1))=udim(mat UndoLongStack$)-Stack2
         let Size3(udim(mat Size1))=udim(mat UndoStack)-Stack3
      end if
   fnend

   def fnPopScreen(Mat ScreenIO$, Mat ScreenIO, [[ScreenControls]];AltStack)
      let fnPop(Mat ScreenWindows,AltStack)
      let fnPop$(Mat ScreenKeys$,AltStack)
      let fnPop(Mat FrameWindows,AltStack)
      let fnPop$(Mat FrameSpecControl$,AltStack)
      let fnPop$(Mat FrameKeys$,AltStack)
      let fnPop$(Mat S_Spec$,AltStack)
      let fnPop(Mat S_Data,AltStack)
      let fnPop$(Mat S_Data$,AltStack)
      let fnPop$(Mat S_Old$,AltStack)
      let fnPop$(Mat UserData$,AltStack)
      let fnpop(Mat GridLines,AltStack)
      let fnpop(Mat MultiSelect,AltStack)
      let Fnpop$(Mat CnvrtOut$,AltStack)
      let Fnpop$(Mat Tooltip$,AltStack)
      let Fnpop(Mat Invisible,AltStack)
      let Fnpop(Mat Protected,AltStack)
      let Fnpop$(Mat Attr$,AltStack)
      let Fnpop$(Mat Justify$,AltStack)
      let Fnpop$(Mat Bgcolor$,AltStack)
      let Fnpop$(Mat Fgcolor$,AltStack)
      let Fnpop$(Mat Parent$,AltStack)
      let Fnpop$(Mat Picture$,AltStack)
      let Fnpop$(Mat Falsevalue$,AltStack)
      let Fnpop$(Mat Truevalue$,AltStack)
      let Fnpop(Mat Height,AltStack)
      let Fnpop(Mat Width,AltStack)
      let Fnpop$(Mat Fieldtype$,AltStack)
      let Fnpop(Mat Hposition,AltStack)
      let Fnpop(Mat Vposition,AltStack)
      let Fnpop$(Mat Description$,AltStack)
      let Fnpop(Mat Screenio,AltStack)
      let Fnpop$(Mat Screenio$,AltStack)

      if AltStack<>2 then
         let Fnpop(Mat Specwidth,AltStack)
         let Fnpop$(Mat CnvrtIn$,AltStack)
         let Fnpop$(Mat Function$,AltStack)
         let Fnpop$(Mat Fieldname$,AltStack)
         let Fnpop$(Mat Controlname$,AltStack)
      end if

      if AltStack=1 then
         mat Size1(udim(mat Size1)-1)
         mat Size2(udim(mat Size1))
         mat Size3(udim(mat Size1))
      end if
   fnend
!
   def Fnpush$(Mat Array$;Altstack,Wipe)
      if Altstack=1 then
         let Fnpush$=Fnpusharray$(Mat Array$,Mat Undostack$,Mat Undolongstack$)
      else if AltStack=2 then
         let Fnpush$=Fnpusharray$(Mat Array$,Mat ScreenData$,Mat ScreenLongData$)
      else
         let Fnpush$=Fnpusharray$(Mat Array$,Mat Stack$,Mat Longstack$)
      end if
      if Wipe then
         mat Array$(0)
      end if
   fnend
   def Fnpop$(Mat Array$;Altstack)
      if Altstack=1 then
         let Fnpop$=Fnpoparray$(Mat Array$,Mat Undostack$,Mat Undolongstack$)
      else if AltStack=2 then
         if udim(mat ScreenData$) then
            let Fnpop$=Fnpoparray$(Mat Array$,Mat ScreenData$,Mat ScreenLongData$)
         else
            let fnPopErrorMessage
         end if
      else
         let Fnpop$=Fnpoparray$(Mat Array$,Mat Stack$,Mat Longstack$)
      end if
   fnend
   def Fnpush(Mat Array;Altstack,Wipe)
      if Altstack=1 then
         let Fnpush=Fnpusharray(Mat Array,Mat Undostack)
      else if AltStack=2 then
         let Fnpush=Fnpusharray(Mat Array,Mat ScreenData)
      else
         let Fnpush=Fnpusharray(Mat Array,Mat Stack)
      end if
      if Wipe then
         mat Array(0)
      end if
   fnend
   def Fnpop(Mat Array;Altstack)
      if Altstack=1 then
         let Fnpop=Fnpoparray(Mat Array,Mat Undostack)
      else if AltStack=2 then
         if udim(mat ScreenData) then
            let fnPop=fnPopArray(Mat Array,Mat ScreenData)
         else
            let fnPopErrorMessage
         end if
      else
         let Fnpop=Fnpoparray(Mat Array,Mat Stack)
      end if
   fnend

   def fnPopErrorMessage
      print "Error. Unable to unpack the stack when calling a Custom Screen Function."
      print "If this error happens after updating ScreenIO, then you need to recompile"
      print "all your screens for the upgrade. Choose File -> Recompile All Screens"
      pause
   fnend

   dim PushValue$(1)*2047,PushValue(1)
   def fnPushValue$(&Var$;Altstack,Wipe)
      mat PushValue$(1)
      let PushValue$(1)=Var$
      let fnPush$(mat PushValue$,AltStack,Wipe)
      if Wipe then let Var$=""
   fnend
   def fnPopValue$(&Var$;Altstack)
      let fnPop$(mat PushValue$,AltStack)
      let Var$=PushValue$(1)
   fnend
   def fnPushValue(&Var;Altstack,Wipe)
      mat PushValue(1)
      let PushValue(1)=Var
      let fnPush(mat PushValue,Altstack,Wipe)
      if Wipe then let Var=0
   fnend
   def fnPopValue(&Var;Altstack)
      let fnPop(mat PushValue,Altstack)
      let Var=PushValue(1)
   fnend

   dim PushWorkArray$(1)*4000
   def Fnpusharray$(Mat Array$,Mat Stack$,Mat Longstack$;___,Startindex,Endindex,Size,Index)
      mat PushWorkArray$(udim(mat Array$))=Array$
      for Index=1 to Udim(Mat PushWorkArray$)
         if Len(PushWorkArray$(Index))>255 then
            mat Longstack$(Udim(Mat Longstack$)+1)
            let Longstack$(Udim(Mat Longstack$))=PushWorkArray$(Index)
            let PushWorkArray$(Index)="[[[loNgsTaCk]]]"
         end if
      next Index
!
      let Startindex=Udim(Mat Stack$)+1
      let Size=Udim(Mat PushWorkArray$)
      let Endindex=Startindex+Size-1
      mat Stack$(Endindex+1)
      if Size then
         mat Stack$(Startindex:Endindex)=PushWorkArray$
      end if
      let Stack$(Endindex+1)=Str$(Size)
   fnend
   def Fnpoparray$(Mat Array$,Mat Stack$,Mat Longstack$;___,Startindex,Endindex,Size,Index)
      let Endindex=Udim(Mat Stack$)-1
      let Size=Val(Stack$(Endindex+1))
      let Startindex=Endindex-Size+1
      mat Array$(Size)
      if Size then
         mat Array$=Stack$(Startindex:Endindex)
      end if
      mat Stack$(Startindex-1)
!
      for Index=Udim(Mat Array$) to 1 step -1
         if Array$(Index)="[[[loNgsTaCk]]]" then
            let Array$(Index)=Longstack$(Udim(Mat Longstack$))
            mat Longstack$(Udim(Mat Longstack$)-1)
         end if
      next Index
   fnend
   def Fnpusharray(Mat Array,Mat Stack;___,Startindex,Endindex,Size)
      let Startindex=Udim(Mat Stack)+1
      let Size=Udim(Mat Array)
      let Endindex=Startindex+Size-1
      mat Stack(Endindex+1)
      if Size then
         mat Stack(Startindex:Endindex)=Array
      end if
      let Stack(Endindex+1)=Size
   fnend
   def Fnpoparray(Mat Array,Mat Stack;___,Startindex,Endindex,Size)
      let Endindex=Udim(Mat Stack)-1
      let Size=Stack(Endindex+1)
      let Startindex=Endindex-Size+1
      mat Array(Size)
      if Size then
         mat Array=Stack(Startindex:Endindex)
      end if
      mat Stack(Startindex-1)
   fnend
EndPack: ! Done with Pack Data Functions
!
! #Autonumber# 92000,5
! .! ==================================================================
UNDO: ! All The Functions Necessary For Undo Operations Reside Here.
! .! ==================================================================
   def Fnundo(Mat Screenio$,Mat Screenio,[[Screencontrols]])
      if Udim(Mat Size1)>1 then
         let Fnpushscreen(Mat Screenio$,Mat Screenio,[[Screencontrols]]) ! Push Onto Redo Stack
         let Fnpopscreen(Mat Screenio$,Mat Screenio,[[Screencontrols]],1) ! Pop From Undo Stack
         let Fnpopscreen(Mat Screenio$,Mat Screenio,[[Screencontrols]],1)
!
         let Fnpushscreen(Mat Screenio$,Mat Screenio,[[Screencontrols]],1)
         let Fnpreserveundo(Mat Screenio$,Mat Screenio,[[Screencontrols]])
         let Fnundo=1 ! Success
      else
         print Bell;
      end if
   fnend
!
   def Fnredo(Mat Screenio$,Mat Screenio,[[Screencontrols]])
      if Udim(Mat Stack$)>1 then
         let Fnpopscreen(Mat Screenio$,Mat Screenio,[[Screencontrols]]) ! Pop From Redo Stack
         let Fnpushscreen(Mat Screenio$,Mat Screenio,[[Screencontrols]],1) ! Push On Undo Stack
         let Fnpreserveundo(Mat Screenio$,Mat Screenio,[[Screencontrols]])
         let Fnredo=1 ! Success
      else
         print Bell;
      end if
   fnend
!
   dim Numberofstringarrays
!
   def Fncheckpoint(Mat Screenio$,Mat Screenio,[[Screencontrols]];Dontclearredo,___,Longstring$*800,Purgeamount)
      if ~Fncheckundo(Mat Screenio$,Mat Screenio,[[Screencontrols]]) then
!
         if ~Numberofstringarrays then
            let Longstring$="[[Screencontrols1]]"
            let Longstring$=Longstring$&"[[Screencontrols2]]"
            let Numberofstringarrays=Len(Longstring$)-Len(Srep$(Longstring$,"$",""))
         end if
         let Purgeamount=Udim(Mat Controlname$)*Numberofstringarrays+Udim(Mat Screenio$)+udim(mat FrameKeys$)+udim(mat FrameSpecControl$)+udim(mat WindowKeys$)
         let Fnpurgebackofstack(Mat Undostack$,Mat Undolongstack$,Mat Undostack,Purgeamount)
!
         let Fnpushscreen(Mat Screenio$,Mat Screenio,[[Screencontrols]],1) ! Push On Undo Stack
         let Fnpreserveundo(Mat Screenio$,Mat Screenio,[[Screencontrols]])
!
         if ~Dontclearredo then mat Stack$(0) : mat Longstack$(0) : mat Stack(0)
      end if
   fnend
!
   def Fnpurgebackofstack(Mat Stack$,Mat Longstack$,Mat Stack;Howmuch,___,Index)
      do While Udim(Mat Undostack$)>(4000-Howmuch) Or Udim(Mat Undolongstack$)>400 Or Udim(Mat Stack)>20000
         let Fnpurgefromstack$(Mat Stack$,Mat Size1)
         let Fnpurgefromstack$(Mat Longstack$,Mat Size2)
         let Fnpurgefromstack(Mat Stack,Mat Size3)
      loop
   fnend
!
   def Fnpurgefromstack$(Mat Stack$,Mat Size;___,Index)
      for Index=Size(1)+1 to Udim(Mat Stack$)
         let Stack$(Index-Size(1))=Stack$(Index)
      next Index
      mat Stack$(Udim(Mat Stack$)-Size(1))
!
      for Index=2 to Udim(Mat Size)
         let Size(Index-1)=Size(Index)
      next Index
      mat Size(Udim(Mat Size)-1)
   fnend
!
   def Fnpurgefromstack(Mat Stack,Mat Size;___,Index)
      for Index=Size(1)+1 to Udim(Mat Stack)
         let Stack(Index-Size(1))=Stack(Index)
      next Index
      mat Stack(Udim(Mat Stack)-Size(1))
!
      for Index=2 to Udim(Mat Size)
         let Size(Index-1)=Size(Index)
      next Index
      mat Size(Udim(Mat Size)-1)
   fnend
!
! *************************************************
!    Screen Helper Library Folder Change Upgrade
! *************************************************
   dim _Screenio$(1)*255, _Screenio
   def Fncheckhelperlibfolder(;___,Screenfile,Configfile,Sysalreadythere,Foundascreen,Choice)
      if ~Exists(setting_ScreenFolder$&"\") then
         if (2<>Msgbox("Your ScreenIO Screen Helper Library Folder is missing or has not been generated yet. Would you like to regenerate it? You will not be able to run any ScreenIO programs until you complete this process.","Update Process: Regenerate Helper Libraries?","Yn","QST")) then
            print "I cannot proceed without this file. Please repair the folder or run the regerate process."
            pause  ! Give Programmer Chance To Recover.
            stop
         end if
!
         execute "mkdir "&setting_ScreenFolder$
!
         let Choice=Msgbox("Would you like me to clean up any unnecessary old Screen Helper Libraries I find? I will move them to the "&setting_ScreenFolder$&"\archive folder.","Update Process: Clean Up Files?","Yn","QST")
         if Choice=2 then execute "mkdir "&setting_ScreenFolder$&"\archive"
!
! .      ! $$$$$ Make sure this update code is Client Server compatable.
!
         let Screenfile=Fnopen("screenio",Mat _Screenio$,Mat _Screenio,Mat Form$,1)
         if Exists(""&setting_ScreenFolder$&"\screenio.sys") then let Sysalreadythere=1
         open #(Configfile:=Fngetfilenumber): "name="&setting_ScreenFolder$&"\screenio.sys, use", display, output
!
         if ~Sysalreadythere then
            print #Configfile: "rem Your ScreenIO Helper Libraries have been moved into a new folder"
            print #Configfile: "rem called '"&setting_ScreenFolder$&"\'. If you referenced any of these files in your"
            print #Configfile: "rem existing code, you may need to update those references. We have"
            print #Configfile: "rem generated this brconfig file of substitution statements to aid"
            print #Configfile: "rem in this process. To use it simply add 'include "&setting_ScreenFolder$&"\screenio.sys'"
            print #Configfile: "rem to your brconfig.sys file."
            print #Configfile: "rem "
            print #Configfile: "rem WARNING: If any of the following substitution statements conflict with"
            print #Configfile: "rem one of your file names you will not be able to use them. Carefully"
            print #Configfile: "rem inspect these files to ensure they do not conflict with the names of"
            print #Configfile: "rem any of your data files. If they do, you will not be able to use the"
            print #Configfile: "rem substitution statements because they will affect your data files as"
            print #Configfile: "rem well as your program name references. You will have to remove those"
            print #Configfile: "rem lines from this file before using this file, and manually fix all"
            print #Configfile: "rem the references in your existing code to any programs who's names"
            print #Configfile: "rem conflict with your data files."
            print #Configfile: "rem "
            print #Configfile: "rem If you have any questions about this process, please visit"
            print #Configfile: "rem http://www.brwiki.com/index.php?title=ScreenIO_Library#Update_Process"
            print #Configfile: "rem or contact Gabriel Bakker at gabriel.bakker@gmail.com."
            print #Configfile:
         end if
!
         do While File(Screenfile)=0
            read #Screenfile, using Form$(Screenfile) : Mat _Screenio$, Mat _Screenio eof IGNORE
            if File(Screenfile)=0 then
               if Exists(Lwrc$(_Screenio$(Si_Screencode))&".br") then
                  let Foundascreen=1
                  if Choice=2 then execute "rename "&Lwrc$(_Screenio$(Si_Screencode))&".br "&setting_ScreenFolder$&"\archive\"&Lwrc$(_Screenio$(Si_Screencode))&".br"
                  print #Configfile: "substitute "&Lwrc$(_Screenio$(Si_Screencode))&" "&setting_ScreenFolder$&"\"&Lwrc$(_Screenio$(Si_Screencode))
               end if
               if Choice=2 And Exists(Lwrc$(_Screenio$(Si_Screencode))&".brs") then
                  execute "rename "&Lwrc$(_Screenio$(Si_Screencode))&".brs "&setting_ScreenFolder$&"\archive\"&Lwrc$(_Screenio$(Si_Screencode))&".brs"
               end if
            end if
         loop
! .      ! if FoundAScreen then
! .      !    print #ConfigFile: "setenv ScreenSysIncluded 1"
! .      ! end if
         close #Configfile:
         close #Screenfile:
         if ~Foundascreen And ~Sysalreadythere then execute "free "&setting_ScreenFolder$&"\screenio.sys"
         if Exists(setting_ScreenFolder$&"\screenio.sys") then
            let Msgbox("If you referenced any of your screenio helper libraries in any of your existing programs, you may have to update those references. Please review this information in notepad while I compile your new helper libraries.","Update Process: screenio.sys Substitution Statements","Ok")
            execute "system -c start notepad "&setting_ScreenFolder$&"\screenio.sys"
         end if
         let Fnrecompileallscreens(Mat Screenio$,Mat Screenio,[[Screencontrols]])
      end if
!
! .   ! UnComment the following code to automatically install screenio.sys
! .   ! if env$("ScreenSysIncluded")<>"1" then
! .   !    if exists(setting_ScreenFolder$&"\screenio.sys") then
! .   !       open #(ConfigFile:=fnGetFileNumber): "name="&fnGetWbCfg$&", use", display, output
! .   !       print #ConfigFile: "include "&setting_ScreenFolder$&"\screenio.sys"
! .   !       close #ConfigFile:
! .   !       execute "config include "&setting_ScreenFolder$&"\screenio.sys"
! .   !    end if
! .   ! end if
   fnend
!
   def Fnestablishlibrarylinkage
      let Fncheckhelperlibfolder
      if Exists(setting_ScreenFolder$&"\"&Lwrc$(Routinename$)&".br") then
         library setting_ScreenFolder$&"\"&Routinename$&".br" : Fnfunctionswitch$, Fnfunctionswitch, Fncheckstringfunction error TRYLIBRARYLINKAGE1
         let Librarylinkage=1
         goto LIBRARYLINKAGEDONE
TRYLIBRARYLINKAGE1: ! Linkage 0 Didn't work, try 1
         library setting_ScreenFolder$&"\"&Routinename$&".br" : Fnfunctionswitch1$, Fnfunctionswitch1, Fncheckstringfunction error TRYLIBRARYLINKAGE2
         let Librarylinkage=2
         goto LIBRARYLINKAGEDONE
TRYLIBRARYLINKAGE2: ! Linkage 1 Didn't work, try 2
         library setting_ScreenFolder$&"\"&Routinename$&".br" : Fnfunctionswitch2$, Fnfunctionswitch2, Fncheckstringfunction error TRYLIBRARYLINKAGE3
         let Librarylinkage=3
         goto LIBRARYLINKAGEDONE
TRYLIBRARYLINKAGE3: ! Linkage 2 Didn't work, try 3
         library setting_ScreenFolder$&"\"&Routinename$&".br" : Fnfunctionswitch3$, Fnfunctionswitch3, Fncheckstringfunction error TRYLIBRARYLINKAGE4
         let Librarylinkage=4
         goto LIBRARYLINKAGEDONE
TRYLIBRARYLINKAGE4: ! Linkage 3 Didn't work, try 4
         library setting_ScreenFolder$&"\"&Routinename$&".br" : Fnfunctionswitch4$, Fnfunctionswitch4, Fncheckstringfunction error TRYLIBRARYLINKAGE5
         let Librarylinkage=5
         goto LIBRARYLINKAGEDONE
TRYLIBRARYLINKAGE5: ! Linkage 4 Didn't work, try 5
         library setting_ScreenFolder$&"\"&Routinename$&".br" : Fnfunctionswitch5$, Fnfunctionswitch5, Fncheckstringfunction error TRYLIBRARYLINKAGE6
         let Librarylinkage=6
         goto LIBRARYLINKAGEDONE
TRYLIBRARYLINKAGE6: ! Linkage 5 Didn't work, try 6
         library setting_ScreenFolder$&"\"&Routinename$&".br" : Fnfunctionswitch6$, Fnfunctionswitch6, Fncheckstringfunction error TRYLIBRARYLINKAGE7
         let Librarylinkage=7
         goto LIBRARYLINKAGEDONE
TRYLIBRARYLINKAGE7: ! Linkage 6 Didn't work, try 7
         library setting_ScreenFolder$&"\"&Routinename$&".br" : Fnfunctionswitch7$, Fnfunctionswitch7, Fncheckstringfunction
         let Librarylinkage=8
         goto LIBRARYLINKAGEDONE
LIBRARYLINKAGEDONE: ! Linkage Has Been Set
         let Subscriptsalreadyset=0 ! We Must Reset All Subscripts When We Come Back From A Window
      else
         let Librarylinkage=0
      end if
   fnend
!
   dim Subscripts$(1)*800, DataIsInside
EXECUTEFUNCTION: ! Execute Custom Function Call
   def Fnexecutefunction(Function$*255;___,Repopulatelistviews,RedrawListviews)
      if Librarylinkage then
         let Fngeneratesubscripts(Mat Subscripts$)

         ! Pack Screen Data
         Mat ScreenData(0)
         Mat ScreenData$(0)
         Mat ScreenLongData$(0)

         if Function$="{{SetData}}" then
            let fnPushData(2) ! Pack Screen Data
            let DataIsInside=1
         else if ~DataIsInside then
            let fnPushData(2) ! Pack Screen Data
         end if

         if Fnstringfunction(Function$) then
            #Select# Librarylinkage #Case# 1
               let Fnexecutefunction=Fnreturnvalue(Fnfunctionswitch$(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)) error OutOfDateHelperLib
            #Case# 2
               let Fnexecutefunction=Fnreturnvalue(Fnfunctionswitch1$(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)) error OutOfDateHelperLib
            #Case# 3
               let Fnexecutefunction=Fnreturnvalue(Fnfunctionswitch2$(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)) error OutOfDateHelperLib
            #Case# 4
               let Fnexecutefunction=Fnreturnvalue(Fnfunctionswitch3$(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)) error OutOfDateHelperLib
            #Case# 5
               let Fnexecutefunction=Fnreturnvalue(Fnfunctionswitch4$(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)) error OutOfDateHelperLib
            #Case# 6
               let Fnexecutefunction=Fnreturnvalue(Fnfunctionswitch5$(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)) error OutOfDateHelperLib
            #Case# 7
               let Fnexecutefunction=Fnreturnvalue(Fnfunctionswitch6$(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)) error OutOfDateHelperLib
            #Case# 8
               let Fnexecutefunction=Fnreturnvalue(Fnfunctionswitch7$(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)) error OutOfDateHelperLib
            #End Select#
         else
            #Select# Librarylinkage #Case# 1
               let Fnexecutefunction=Fnfunctionswitch(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$) error OutOfDateHelperLib
            #Case# 2
               let Fnexecutefunction=Fnfunctionswitch1(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$) error OutOfDateHelperLib
            #Case# 3
               let Fnexecutefunction=Fnfunctionswitch2(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$) error OutOfDateHelperLib
            #Case# 4
               let Fnexecutefunction=Fnfunctionswitch3(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$) error OutOfDateHelperLib
            #Case# 5
               let Fnexecutefunction=Fnfunctionswitch4(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$) error OutOfDateHelperLib
            #Case# 6
               let Fnexecutefunction=Fnfunctionswitch5(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$) error OutOfDateHelperLib
            #Case# 7
               let Fnexecutefunction=Fnfunctionswitch6(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$) error OutOfDateHelperLib
            #Case# 8
               let Fnexecutefunction=Fnfunctionswitch7(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$) error OutOfDateHelperLib
            #End Select#
         end if

         if ~DataIsInside or Function$="{{GetData}}" then
            let fnPopData(2)
            let DataIsInside=0
         end if

         if RedrawListviews then
            let Fndrawalllistviews(Wwindow,Mat Screenio$,Mat Screenio,[[Screencontrols]],1)
         end if
         if RedrawListviews or Repopulatelistviews then
            let Lastrow=Fnpopulatealllistviews(Wwindow,Fdatafile,Mat Fieldsssubs$,Mat Fieldsnsubs$,Mat S$,Mat Screensubs$,Mat Form$,mat ListviewRecords,[[Screencontrols]])
            mat Old_Data=(0) ! Clear information so it forces read again.
            Mat Rlv_Savereaddata$=("")
            let S_CurrentRow=0
         end if
      else
         print "Missing Helper Library. Recompile your screen."
         print
         print "If you don't know why you're seeing this message, call your Vendor for support."
         print "Type ""GO"" and press [Enter] to Ignore the error and try to continue."
         pause
      end if
      _EF_ExitFunction: ! End the Execute Function routine here
   fnend
   OutOfDateHelperLib: ! Helper Library is Out of Date
      print "Helper Library is Out of Date. Recompile your screen."
      print "If you recently installed an update, you may need to Recompile All Screens."
      print
      print "If you don't know why you're seeing this message, call your Vendor for support."
      print "Type ""GO"" and press [Enter] to Ignore the error and try to continue."
      pause
   goto _EF_ExitFunction

   def Fnexecutefunction$*1000(Function$*255;___,Repopulatelistviews,RedrawListviews)
      if Librarylinkage then
         let Fngeneratesubscripts(Mat Subscripts$)

         ! Pack Screen Data
         Mat ScreenData(0)
         Mat ScreenData$(0)
         Mat ScreenLongData$(0)

         if Function$="{{SetData}}" then
            let fnPushData(2) ! Pack Screen Data
            let DataIsInside=1
         else if ~DataIsInside then
            let fnPushData(2) ! Pack Screen Data
         end if

         if Fnstringfunction(Function$) then
            #Select# Librarylinkage #Case# 1
               let Fnexecutefunction$=Fnfunctionswitch$(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
            #Case# 2
               let Fnexecutefunction$=Fnfunctionswitch1$(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
            #Case# 3
               let Fnexecutefunction$=Fnfunctionswitch2$(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
            #Case# 4
               let Fnexecutefunction$=Fnfunctionswitch3$(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
            #Case# 5
               let Fnexecutefunction$=Fnfunctionswitch4$(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
            #Case# 6
               let Fnexecutefunction$=Fnfunctionswitch5$(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
            #Case# 7
               let Fnexecutefunction$=Fnfunctionswitch6$(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
            #Case# 8
               let Fnexecutefunction$=Fnfunctionswitch7$(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
            #End Select#
         else
            #Select# Librarylinkage #Case# 1
               let Fnexecutefunction$=Str$(Fnfunctionswitch(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$))
            #Case# 2
               let Fnexecutefunction$=Str$(Fnfunctionswitch1(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$))
            #Case# 3
               let Fnexecutefunction$=Str$(Fnfunctionswitch2(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$))
            #Case# 4
               let Fnexecutefunction$=Str$(Fnfunctionswitch3(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$))
            #Case# 5
               let Fnexecutefunction$=Str$(Fnfunctionswitch4(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$))
            #Case# 6
               let Fnexecutefunction$=Str$(Fnfunctionswitch5(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$))
            #Case# 7
               let Fnexecutefunction$=Str$(Fnfunctionswitch6(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$))
            #Case# 8
               let Fnexecutefunction$=Str$(Fnfunctionswitch7(Function$,Mat Subscripts$,mat PassedData$,Fieldindex,Fieldtext$,Controlindex,Key$,Exitmode,Repopulatelistviews,RedrawListviews,Currentfield,CurrentField$,Prefix$,Currentkey$,CurrentRec,Parentkey$,Fdatafile,Wwindow,Currentrow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$))
            #End Select#
         end if

         if ~DataIsInside or Function$="{{GetData}}" then
            let fnPopData(2)
            let DataIsInside=0
         end if

         if RedrawListviews then
            let Fndrawalllistviews(Wwindow,Mat Screenio$,Mat Screenio,[[Screencontrols]],1)
         end if
         if RedrawListviews or Repopulatelistviews then
            let Lastrow=Fnpopulatealllistviews(Wwindow,Fdatafile,Mat Fieldsssubs$,Mat Fieldsnsubs$,Mat S$,Mat Screensubs$,Mat Form$,mat ListviewRecords,[[Screencontrols]])
            mat Old_Data=(0) ! Clear information so it forces read again.
            Mat Rlv_Savereaddata$=("")
            let S_CurrentRow=0
         end if
      else
         print "Missing Helper Library"
      end if
   fnend
!
GENERATESUBSCRIPTS: ! Generates The Subscripts That Get Passed Into User Defined Functions
   def Fngeneratesubscripts(Mat Subscripts$;___,Index,Subindex)
      if ~Subscriptsalreadyset then ! If They're already set then leave them alone
         mat Subscripts$(0)
!
! .      ! fileio subscripts for mat f$ and mat f
         let Fnaddarraytosubs(Mat Subscripts$,Trim$(Prefix$),Mat Fieldsssubs$)
         let Fnaddarraytosubs(Mat Subscripts$,Trim$(Prefix$),Mat Fieldsnsubs$)
!
! .      ! fileIO Subscripts for mat ScreenIO$ and mat ScreenIO
         let Fnaddarraytosubs(Mat Subscripts$,Trim$(Screenioprefix$),Mat Screeniossubs$)
         let Fnaddarraytosubs(Mat Subscripts$,Trim$(Screenioprefix$),Mat Screenionsubs$)
!
! .      ! screenio subscripts for mat s$ (based on Control Name field)
         let Fnaddarraytosubs(Mat Subscripts$,"sio_",Mat Screensubs$)
!
! .      ! Control Subs based on Control Name field
         let Fnaddarraytosubs(Mat Subscripts$,"ctl_",Mat Controlname$)
         let fnAddUniqueArrayToSubs(Mat Subscripts$,"ctl_",Mat Controlname$)
!
! .      ! Exitmode Literals such as SaveAndQuit and QuitOnly
         let Fnaddtosubsarray("let QuitOnly="&Str$(Quitonly),Mat Subscripts$)
         let Fnaddtosubsarray("let SaveAndQuit="&Str$(Saveandquit),Mat Subscripts$)
         let Fnaddtosubsarray("let SelectAndQuit="&Str$(Selectandquit),Mat Subscripts$)
         let Fnaddtosubsarray("let QuitOther="&Str$(Quitother),Mat Subscripts$)
         let Fnaddtosubsarray("let AskSaveAndQuit="&Str$(Asksaveandquit),Mat Subscripts$)
         let Fnaddtosubsarray("let Reload="&Str$(Reload),Mat Subscripts$)
         let Fnaddtosubsarray("let AutoReload="&Str$(AutoReload),Mat Subscripts$)
         let Fnaddtosubsarray("let FkeyPgUp=90",Mat Subscripts$)
         let Fnaddtosubsarray("let FkeyPgDn=91",Mat Subscripts$)
         let Fnaddtosubsarray("let FkeyUp=102",Mat Subscripts$)
         let Fnaddtosubsarray("let FkeyDn=104",Mat Subscripts$)
         let Fnaddtosubsarray("let FkeyLeft=103",Mat Subscripts$)
         let Fnaddtosubsarray("let FkeyRight=109",Mat Subscripts$)
         let Fnaddtosubsarray("let FkeyUpFld=105",Mat Subscripts$)
         let Fnaddtosubsarray("let FkeyDnFld=106",Mat Subscripts$)
         let Fnaddtosubsarray("let FkeyEsc=99",Mat Subscripts$)
         let Fnaddtosubsarray("let FkeyWinClose=93",Mat Subscripts$)
         let Fnaddtosubsarray("let FkeyHome=112",Mat Subscripts$)
         let Fnaddtosubsarray("let FkeyEnd=113",Mat Subscripts$)
         let Fnaddtosubsarray("let FkeyFldPlus=114",Mat Subscripts$)
         let Fnaddtosubsarray("let FkeyFldMinus=115",Mat Subscripts$)
         let Fnaddtosubsarray("let FkeyClick=201",Mat Subscripts$)
         let Fnaddtosubsarray("let FkeyDblClick=202",Mat Subscripts$)
         let Fnaddtosubsarray("let FkeyRightClick=100",Mat Subscripts$)
!
         let Subscriptsalreadyset=1
      end if
   fnend
   def Fnaddarraytosubs(Mat Subscripts$,Pre$,Mat String$;___,Index)
      for Index=1 to Udim(Mat String$)
         if Len(Trim$(String$(Index))) then
            let Fnaddtosubsarray("let "&Pre$&Trim$(String$(Index))(1:30-Len(Trim$(Pre$)))&"="&Str$(Index),Mat Subscripts$)
         end if
      next Index
   fnend

!
   dim Tempsetsubscripts$(1)*800
EXECUTESETSUBSCRIPTS: ! Execute A Subscripts List Setting The Subscripts
   def Fnexecutesetsubscripts(Mat Subs$,Prefix$;___,Index)
      if fnCheckBeforeExecuteSubs(Prefix$) then
         mat Tempsetsubscripts$(0)
         for Index=1 to Udim(Mat Subs$)
            if Len(Trim$(Subs$(Index))) then
               let Fnaddtosubsarray("let "&Trim$(Prefix$)&Trim$(Subs$(Index))(1:30-Len(Trim$(Prefix$)))&"="&Str$(Index),Mat Tempsetsubscripts$)
            end if
         next Index
         for Index=1 to Udim(Mat Tempsetsubscripts$)
            execute Tempsetsubscripts$(Index)
         next Index
      end if
   fnend

   dim AlreadyKnow$(1)*40
   dim AlreadyKnow(1)

   def fnCheckBeforeExecuteSubs(Prefix$;___,Index,foundYet)
      ! check arrays to see if we already know
      if (Index:=Srch(mat AlreadyKnow$,lwrc$(ScreenIO$(si_ScreenCode))&"|&|"&lwrc$(Prefix$)))>0 then
         let FoundYet=AlreadyKnow(Index)
      else
         do
            for Index=si_enterfn to si_exitfn
               if (FoundYet:=fnCheckSingleFunction(Prefix$,ScreenIO$(Index))) then exit Do
            next Index
            for Index=1 to udim(mat function$)
               if (FoundYet:=fnCheckSingleFunction(Prefix$,Function$(Index))) then exit Do
               if (FoundYet:=fnCheckSingleFunction(Prefix$,CnvrtIn$(Index))) then exit Do
               if (FoundYet:=fnCheckSingleFunction(Prefix$,CnvrtOut$(Index))) then exit Do
            next Index
         loop while 0
         let Index=udim(mat AlreadyKnow$)+1
         mat AlreadyKnow$(Index)
         mat AlreadyKnow(Index)
         let AlreadyKnow$(Index)=lwrc$(ScreenIO$(si_ScreenCode))&"|&|"&lwrc$(Prefix$)
         let AlreadyKnow(Index)=FoundYet
      end if

      let fnCheckBeforeExecuteSubs=FoundYet
   fnend

   def fnCheckSingleFunction(Prefix$,String$*255)
      if ~pos("{#%",trim$(String$)(1:1)) then
         if trim$(String$)(1:1)="[" then let String$(1:pos(String$,"]"))=""
         if pos(String$,Prefix$) then let fnCheckSingleFunction=1
      end if
   fnend

   dim UniqueControlName$(1)*54
   def fnExecuteUniqueSubscripts(Mat Controlname$,Prefix$)
      let fnGetUniqueControlName(Mat UniqueControlName$,Mat ControlName$)
      let fnExecuteSetSubscripts(Mat UniqueControlName$,Prefix$)
   fnend

   def fnAddUniqueArrayToSubs(Mat Subscripts$,Prefix$,Mat ControlName$)
      let fnGetUniqueControlName(Mat UniqueControlName$,Mat ControlName$)
      let fnAddArrayToSubs(Mat Subscripts$,Prefix$,Mat UniqueControlName$)
   fnend

   def fnGetUniqueControlName(Mat UniqueControlName$,Mat ControlName$;___,Index)
      mat UniqueControlName$(udim(mat controlname$))
      for Index=1 to udim(mat UniqueControlName$)
         let UniqueControlName$(Index)=fnUniqueName$(mat ControlName$,Index)
      next Index
   fnend

!
   dim Addtosubscount
ADDTOSUBSARRAY: ! Adds Subscripts To A Processing Effecient Array
   def Fnaddtosubsarray(String$*50,Mat Subs$;___,Index)
!
      let Addtosubscount+=1
      let Index=Udim(Mat Subs$)
!
      if Index=0 Or Addtosubscount>31 then
         gosub ADDNEWONE
      else
         let Subs$(Index)=Subs$(Index)&": "&String$ soflow ERRORADDNEWONE
      end if
   fnend
!
ERRORADDNEWONE: gosub ADDNEWONE : continue
ADDNEWONE: ! Add A New Sub Line
   let Addtosubscount=1
   let Index+=1
   mat Subs$(Index)
   let Subs$(Index)="*"&String$
   return
!
FINDSUBSCRIPT: ! This Function Finds A Subscript And Returns Its Number
   def library Fnfindsubscript(Mat Subscripts$,Prefix$,String$*40;___,Index,Subscript,Position,Equals,Colon)
      do While Index<Udim(Mat Subscripts$)
         let Index+=1
         if (Position:=Pos(Lwrc$(Subscripts$(Index))," "&Lwrc$(Trim$(Prefix$))&Lwrc$(Trim$(String$)))) then
            let Subscript=-1
            let Equals=Pos(Subscripts$(Index),"=",Position)
            let Colon=Pos(Subscripts$(Index),":",Position)
            if ~Colon then let Colon=Len(Subscripts$(Index))+1
            let Subscript=Val(Subscripts$(Index)(Equals+1:Colon-1)) conv IGNORE
         end if
      loop Until Subscript>0
      let Fnfindsubscript=Subscript
   fnend
!
   def fnSetForcevisibility(Set)
      let ForceVisibility=fnForceVisibility
      let fnChangeForceVisibility(Set,1)
   fnend
   def fnResetForceVisibility
      let fnChangeForceVisibility(ForceVisibility,1)
   fnend
   def fnChangeForceVisibility(Set;Forced,___,Needed,I)
      for I=1 to udim(mat FrameKeys$)
         if trim$(FrameKeys$(I))<>"" then
            let Needed=1
         end if
      next I
      if Needed or Forced then
         if Set then
            if CurrentFVStatus><2 then
               execute "config force visibility on"
               let CurrentFVStatus=2
            end if
         else
            if CurrentFVStatus><1 then
               execute "config force visibility off"
               let CurrentFVStatus=1
            end if
         end if
      end if
   fnend
   dim CurrentFVStatus
   def fnForceVisibility(;___,filenumber,Line$*255,Done,FVStat)
      if CurrentFVStatus then
         let fnForceVisibility=CurrentFVStatus-1
      else
         execute "status config >config."&session$
         open #(filenumber:=fnGetFileNumber): "name=config."&session$,display,input
         do while file(filenumber)=0
            linput #filenumber: line$ eof Ignore
            if pos(uprc$(line$),"FORCE VISIBILITY") then
               if pos(uprc$(line$),"ON") then
                  let FVStat=1
               end if
               let Done=1
            end if
         loop while not done
         close #Filenumber:
         execute "free config."&session$
         let fnForceVisibility=FVStat
         let CurrentFVStatus=FVStat+1
      end if
   fnend

STRINGFUNCTION: ! This Returns True If The Passed In Function Is A String
   def Fnstringfunction(Function$*255;___,Start,Paren)
      if Trim$(Function$(1:1))="{" then
         if Librarylinkage then
            let Fnstringfunction=Fncheckstringfunction(Function$) error ErrorLoadingCustomLibrary
         else
            let Function$=Fnreadcustomfunctionstatement$(Function$)
         end if
      end if
      if Trim$(Function$(1:1))<>"{" then
         let Start=Pos(Lwrc$(Function$),"fn")
         let Paren=Pos(Function$,"(",Start)
         if Paren=0 then let Paren=Len(Function$)
         let Fnstringfunction=Pos(Function$(Start:Paren),"$")
      end if
   fnend
!
ErrorLoadingCustomLibrary: ! Error handler for errors that happen when trying to call your custom helper library
   if err=2280 then
      print "There is a compile error in one of your Custom Functions for your screen,"
      print "that is preventing ScreenIO from linking to it. To see what the error is"
      print "type the following commands: "
      print "load "&setting_ScreenFolder$&"\"&Trim$(Screenio$(Si_Screencode))
      print "replace"
      print
      print "This will cause BR to attempt to recompile your screen, showing you the actual error."
      print
      print "or type ""GO"" and I will attempt to run those commands for you."
      pause
      open #(X:=fnGetFileNumber): "name=tmp[session].$$$, replace",display,output
      print #X: "load "&setting_ScreenFolder$&"\"&Trim$(Screenio$(Si_Screencode))
      print #X: "replace"
      close #X:
      execute "proc tmp[session].$$$"
   else
      print "Error "&str$(err)&" occurred linking to your custom helper library. There may be an error in one of your custom functions."
   end if
   stop

RETURNVALUE: ! Convert A String To A Number According To Special Rules
   def Fnreturnvalue(Value$*1000;___,Number)
      let Number=1 ! If Conversion Failed, Then Its A Non-Null String, Return True
      let Number=Val(Value$) conv IGNORE
      let Fnreturnvalue=Number
   fnend

   def fnDisplayLoadMessage(;___,Window)
      let fnChangeForceVisibility(0)
      let Window=fnOpenCenteredWindow(3,50,1,trim$(screenio$(si_lockwindow)))
      print #Window, fields "1,1,CC 50;2,1,CC 50;3,1,CC 50" : "Now Reading Record - Requesting Write Permission", !_
                                                                   "If you see this message for more then a", !_
                                                                  "few seconds the record is probably in use."
      let fnDisplayLoadMessage=Window
      let fnResetForceVisibility
   fnend

   def fnAskLockError(;LockUser$*800,FileName$*255,___,Window,Function,Button2$)
      if ScreenIO(si_screenioLocking) then
         let Button2$="Continue"
      else
         let Button2$="Read Only"
      end if
      let fnChangeForceVisibility(0)
      let Window=fnOpenCenteredWindow(4,60,1,trim$(screenio$(si_lockwindow)),Row,Col)
      print #Window, fields "1,1,60/CC "&str$(len(Filename$)+25) : "File Sharing Violation - "&FileName$
      print #Window, fields "2,1,CC 60" : "This record is currently in use by"
      print #Window, fields "3,1,60/CC "&str$(len(LockUser$)+5) : "user "&Lockuser$
      print #Window, fields "4,10,CC 10,/W:W,B40;4,25,CC 10,/W:W,B41;4,40,CC 10,/W:W,B42" : "Retry",Button2$,"Cancel"
      do
         input #0, fields Str$(Row+1)&","&Str$(Col+1)&",C 1,AEX" : Kp$
         let Function=Fkey
         if Function=99 then let Function=42
         if Function=0 then let Function=40
      loop while Function<40 or Function>42
      let fnAskLockError=Function-39
      close #Window:
      let fnResetForceVisibility
   fnend

   def fnOpenCenteredWindow(Rows,Cols;B,Spec$*255,&Row,&Col,___,Rs,Cs,ScreenRows,ScreenCols,Window)
      if B then
         let RS=Rows+2
         let CS=Cols+2
         let Spec$=Spec$&",Border=S"
      else
         let RS=Rows
         let CS=Cols
      end if
      if Env$("guimode")="ON" then
         let Fnreadscreensize(ScreenRows,ScreenCols)
      else
         let ScreenRows=24 : let ScreenCols=80
      end if
      let Row=Int((ScreenRows-(rs))/2)+2
      let Col=Int((ScreenCols-(cs))/2)+2

      open #(Window:=Fngetfilenumber): "SROW="&Str$(Row)&",SCOL="&Str$(Col)&",ROWS="&str$(Rows)&",COLS="&str$(Cols)&Spec$,display,outin
      let fnOpenCenteredWindow=Window
   fnend
!
   dim LockUser$(1)*255
   def Fnretrylockederror(Key$*255,Filenumber;OnRead,___,LockUser$*800,Choice,_ErrLine,_ErrNumber,__Usr$*80,Index)
      let _ErrLine=Line
      let _ErrNumber=Err
      if Pos("0061_4148",Cnvrt$("PIC(####)",Err)) then
         let fnReadLockedUsers(mat LockUser$)
         let Lockuser$=""
         if udim(mat LockUser$) then
            let LockUser$=LockUser$(1)
            for Index=2 to udim(mat lockuser$)
               let LockUser$=LockUser$&" and "&Lockuser$(Index)
            next Index
         end if
!
! .      ! Here is where we link to our LOCKED event
         if Len(Trim$(Screenio$(Si_Lockedfn))) then
            let Fnretrylockederror=Fnexecute(Screenio$(Si_Lockedfn))
         else if exists(setting_FunctionFolder$&"defaults\") and exists(setting_FunctionFolder$&"defaults\locked.brs") then
            let Fnretrylockederror=fnExecute(fnFunctionString$(setting_FunctionFolder$&"defaults\locked.brs"))
         else
            if OnRead then
               let Choice=fnAskLockError(LockUser$,File$(FileNumber))
               if Choice=1 or Choice=2 then
                  let fnRetryLockedError=Choice
               end if
            else
               let Choice=Msgbox("The current record is locked in file #"&Str$(Filenumber)&', "'&File$(Filenumber)&'", by user '&Trim$(LockUser$)&". Do you want to retry?","Record Locked","Okc","Qst")
               if Choice=1 then
                  let Fnretrylockederror=1
               end if
            end if
         end if
      end if
   fnend
   def Fnretrytimeouterror(;___,Window,Rows,Cols,Row,Col,Count)
      if Len(Screenio$(Si_Waitfn)) then
         let fnResetForceVisibility
         let Fnretrytimeouterror=Fnexecute(Screenio$(Si_Waitfn))
      else if exists(setting_FunctionFolder$&"defaults\") and exists(setting_FunctionFolder$&"defaults\wait.brs") then
         let fnResetForceVisibility
         let Fnretrytimeouterror=fnExecute(fnFunctionString$(setting_FunctionFolder$&"defaults\wait.brs"))
      else
         let fnChangeForceVisibility(0)
         let Window=fnOpenCenteredWindow(3,40,1,trim$(screenio$(si_lockwindow)))
         print #Window, fields "1,1,CC 40" : "Your system has been idle for some time."
         print #Window, fields "2,1,CC 40" : "Press any key to continue or you will"
         print #Window, fields "3,1,CC 40" : "be logged out automatically."
         do While Count<300 ! 30 Seconds
            let Count+=1
            let Sleep(.1)
            if Len(Kstat$) then
               let Fnretrytimeouterror=1
               exit do
            end if
         loop
         close #Window:
      end if
      let fnChangeForceVisibility(1)
   fnend

   ! We cannot count on the BR error retry and continue locations if we're calling custom code because they might be overwriting those errors in their own functions.
   !  So we implement our own here, for the places where custom code could be called (Locked Errors and Timeouts)

   dim RetryPoint$
   def fnSetRetryPoint(RP$)
      let RetryPoint$=RP$
   fnend
   RetrySpecial: ! Our special version of the Retry command
      #Select# lwrc$(RetryPoint$) #Case# "errorlocked1"
          goto ErrorLocked1Retry
      #Case# "errorlocked2"
          goto ErrorLocked2Retry
      #Case# "errorlocked3"
          goto ErrorLocked3Retry
      #Case# "errorlocked4"
          goto ErrorLocked4Retry
      #Case# "errorlocked1exit"
          goto ErrorLocked1ExitRetry
      #Case# "errorlocked2exit"
          goto ErrorLocked2ExitRetry
      #Case# "timeout1"
          goto Timeout1Retry
      #Case# "timeout2"
          goto Timeout2Retry
      #End Select#
   retry ! Fall through at least try regular retry

   ContinueSpecial: ! Our special version of the Continue command
      #Select# lwrc$(RetryPoint$) #Case# "errorlocked1"
          goto ErrorLocked1Continue
      #Case# "errorlocked2"
          goto ErrorLocked2Continue
      #Case# "errorlocked3"
          goto ErrorLocked3Continue
      #Case# "errorlocked4"
          goto ErrorLocked4Continue
      #Case# "errorlocked1exit"
          goto ErrorLocked1ExitContinue
      #Case# "errorlocked2exit"
          goto ErrorLocked2ExitContinue
      #Case# "timeout1"
          goto Timeout1Continue
      #Case# "timeout2"
          goto Timeout2Continue
      #End Select#
   continue ! Fall through at least try regular continue

! #Autonumber# 99000,10
OPEN: ! ***** Function To Call Library Openfile And Proc Subs
   def Fnopen(Filename$*255, Mat F$, Mat F, Mat Form$; Inputonly, Keynum, Dont_Sort_Subs, Path$*255, Mat Descr$, Mat Field_Widths,Supress_Prompt,Ignore_Errors,Suppress_Log,mat DateFmt$,___,Index)
      dim _FileIOSubs$(1)*800, _Loadedsubs$(1)*80
      let Fnopen=Fnopenfile(Filename$, Mat F$, Mat F, Mat Form$, Inputonly, Keynum, Dont_Sort_Subs, Path$, Mat Descr$, Mat Field_Widths, Mat _FileIOSubs$, Supress_Prompt,Ignore_Errors,Program$,Suppress_Log,mat DateFmt$)
      if Srch(_Loadedsubs$,Uprc$(Filename$))<=0 then : mat _Loadedsubs$(Udim(_Loadedsubs$)+1) : let _Loadedsubs$(Udim(_Loadedsubs$))=Uprc$(Filename$) : for Index=1 to Udim(Mat _Fileiosubs$) : execute (_Fileiosubs$(Index)) : next Index
   fnend

!
! #Autonumber# 99500,10
IGNORE: continue

RetryFiveTimes: !
   let RetryFiveTimes+=1
   if RetryFiveTimes<10 then retry
   continue
!
dim RetryAction
dim TryToContinue
ErrorFileIsLocked: ! Ask The User To Retry Or Abort
   let RetryAction=Fnretrylockederror(Key$,Fdatafile,1)
   if RetryAction=1 then
      goto RetrySpecial
   else if RetryAction=2 then
      let TryToContinue=1
   else
      let Exitmode=1
      goto ContinueSpecial
   end if

ErrorFileLockedOnExit: ! Ask The User To Retry Or Abort
   if Fnretrylockederror(Key$,Fdatafile) then
      goto RetrySpecial
   else
      let Exitmode=0 ! Cancel the exit
      goto ContinueSpecial
   end if
!
TimeoutError: ! A Timeout Has Occured
   if Fnretrytimeouterror then
      goto RetrySpecial
   else
      let Exitmode=1
      goto ContinueSpecial
   end if
