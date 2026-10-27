! Fileio - Copyright February 2006 By Gabriel Bakker #Autonumber# 10,10
!    Distributed Open Source As A Christmas Gift To the BR Community
! This Library Houses All File Maintenance Operations
!
!  Created: 3/28/2006
! Modified: 6/06/2026
!
def fnVersion=135
!
!
! #Autonumber# 500,1
! If You Run This Library As A Program, It Will Function As A Data
! Crawler That Will Allow You To View The Raw Data In Your Datafiles
!
! To Update A Datafile, Just Simply Increase The Version Number
! Then Make Any Change You Like - Add Fields, Remove Fields, Rearrange
! Fields, Change Keys, etc.
!
! Then Just Run Your Software Normally - Upon First Time, Version
! Discrepancy Is Detected, And File Is Updated Dynamically.
!
! Note: Do Not Change Your Subscript Names Between Versions.
! They Can Be Rearranged, And You Can Insert New Data, But The Fileio
! Library Uses The Subscript Names To Ensure The Proper Data Is Placed
! In The Correct Spot In The New Version Of The Data File During The
! Update.
!
! Global Settings Such As The Default File Layout Path May Be Set
! By creating a simple procfile called fileio.ini, a procfile that
! resides in the current path and setting the appropriate values.
!
! Recent Changes have been moved to FileIOUpdateLog.txt
   goto DIMS
!
! #Autonumber# 900,2
   goto TestFileIO

! #Autonumber# 1000,2
SETTINGS: ! ***** Set Global Defaults For The Library Here
   def FnDefaultSettings
      let EnforceDupkeys=1  ! Enforce that key number 1 is unique key
      let Defaultfilelayoutpath$="filelay\" ! Path To Your File Layouts
      let FileLayoutExtension$="" ! Extension for your File Layouts
      let Promptonfilecreate=1 ! Ask User Before Creating New Files
      let PromptOnUpdate=2 ! 0 - Suppress Prompt, 1- Show Prompt, 2- Use PromptOnFileCreate
      let Createlogfile=0  ! 1 to turn on Logging. Caution, the log file can get big very quickly.
      let StartFileNumber=1 ! Set above 255 to avoid conflicts with legacy programs.
      let CheckIndex=0 ! Automatically Update Indexes (Use for partial fileio implementations, disable for full fileio installations.)
      let CompressColumns=0 ! Shrink or Expand Columns in Data Crawler by Default
      let MaxColWidth=20 ! Max Default Column Width in Data Crawler
      let NewLine$=Chr$(13)&Chr$(10) ! Default CRLF
      let LogLibrary$="" ! Log Library to use, defaults to None (use FileIO's internal log functionality)
      let LogLayout$="" ! Log file layout, defaults to Internal File (for use with FileIO's internal log functionality)
      let AnimateDatacrawler=1 ! Use ScreenIO Animation for Datacrawler (if available, will not cause error if not available)
      let GenerateScreenBtn=1 ! Use ScreenIO's fnMakeScreen function to generate screens from within fileio.
      let TemplatePath$="filelay\template\" ! Default Template Path
      let IgnoreLayouts$="" ! List any Ignore Layouts here.
      let CloseFileSimple=0 ! Use simple comparison for fnCloseFile
      let AuditPath$="auditbr\" ! Backup Path to use for Auditing Files
      let ScreenIOPath$="screenio.br" ! Default search location for ScreenIO Library (for fnAnimate in Data Crawler.)
      let FilterBoxFileList=0 ! Use a Filter Box for the Layout Listview (1=Filter Box, 0=Search Box)
      let FilterBoxData=1 ! Use a Filter Box for the Data Crawler (1=Filter Box, 0=Search Box)
      let SaveSelectedCols$="savecols" ! Path and File name of a file used to save user preferences, which cols to export per file by default.
      let DateFormatExport$='m/d/cy'  ! Format of Dates when Exporting to CSV
      let DateFormatDisplay$='m/d/cy' ! Format of Dates when displaying in Data Crawler
      let BypassFixRpt=0 ! Set this to 1 to increase performance, set it to 0 if you have extremly large file layouts.
      let SuppressLoggingErr=0 ! Set this to 1 to suppress the "File is locked on the server" error message when the log file cannot be written to.
      let EmailLibrary$="" ! Specify a custom email library here to use your own emailing program. This must be a BR library containing a library function that sends the email in your custom way, called fnSendMail(Emailaddress$*255,EmailMessage$*10000;Subject$*255,Invoicefile$*255,noprompt,BCCEmail$*255,mat CCEmails$,CCAsTo)
   fnend

   def fnReadSettings(mat SSettingNames$,mat SSettings$,mat NSettingNames$,mat NSettings$, &ReadSettings; ___, !_
      Defaultfilelayoutpath$*255, NewLine$*255, LogLibrary$*255, Promptonfilecreate, PromptOnUpdate, Createlogfile, !_
      EnforceDupkeys, StartFileNumber, CheckIndex, CompressColumns, MaxColWidth, LogLibrary$*255, LogLayout$, !_
      AnimateDatacrawler, GenerateScreenBtn, TemplatePath$*255, IgnoreLayouts$*255, CloseFileSimple, Star$, !_
      AuditPath$*255, ScreenIOPath$*255, FileLayoutExtension$, FilterBoxFileList, FilterBoxData, SaveSelectedCols$*64,!_
      DateFormatExport$*64, DateFormatDisplay$*64, BypassFixRpt, SuppressLoggingErr,EmailLibrary$*64)

      let Star$=fnNeedStar$

      ! Read Defaults
      let fnDefaultSettings

      ! Read Custom Settings
      if exists("fileio.ini") then
         execute Star$&"subproc fileio.ini"
      else if exists("fileio\fileio.ini") then
         execute Star$&"subproc fileio\fileio.ini"
      else if exists("\fileio.ini") then
         execute Star$&"subproc \fileio.ini"
      end if

      ! Detect fnAnimate routines, enable/disable Loading Animation
      if len(trim$(ScreenIOPath$)) and exists(ScreenIOPath$) then
         if AnimateDataCrawler then
            library ScreenIOPath$ : fnAnimate, fnPrepareAnimation, fnCloseAnimation, fnMakeScreen
         end if
         if GenerateScreenBtn then
            library ScreenIOPath$ : fnMakeScreen
         end if
      else
         let AnimateDatacrawler=0
         let GenerateScreenBtn=0
      end if

      ! Calculate Special Settings
      if LogLayout$="" and exists(DefaultFileLayoutPath$&"logfile"&FileLayoutExtension$) then let LogLayout$="logfile"
      if LogLayout$<>"" then let IgnoreLayouts$=IgnoreLayouts$&","&LogLayout$
      let IgnoreLayouts$=lwrc$(IgnoreLayouts$)
      if PromptOnUpdate=2 then let PromptOnUpdate=Promptonfilecreate

      ! Load Settings Engine
      let SSettingNames$(1)="layoutpath"
      let SSettingNames$(2)="newline"
      let SSettingNames$(3)="loglibrary"
      let SSettingNames$(4)="loglayout"
      let SSettingNames$(5)="templatepath"
      let SSettingNames$(6)="ignorelayouts"
      let SSettingNames$(7)="screeniopath"
      let SSettingNames$(8)="auditpath"
      let ssettingnames$(9)="layoutextension"
      let ssettingNames$(10)="saveselectedcols"
      let ssettingNames$(11)="dateformatexport"
      let ssettingNames$(12)="dateformatdisplay"
      let ssettingNames$(13)="emaillibrary"

      let NSettingNames$(1)="promptonfilecreate"
      let NSettingNames$(2)="createlogfile"
      let NSettingNames$(3)="enforcedupkeys"
      let NSettingNames$(4)="startfilenumber"
      let NSettingNames$(5)="checkindex"
      let NSettingNames$(6)="compresscolumns"
      let NSettingNames$(7)="maxcolwidth"
      let NSettingNames$(8)="animatedatacrawler"
      let nsettingnames$(9)="closefilesimple"
      let nSettingNames$(10)="filterboxfilelist"
      let nSettingNames$(11)="filterboxdata"
      let nSettingNames$(12)="promptonupdate"
      let nSettingNames$(13)="generatescreenbtn"
      let nSettingNames$(14)="bypassfixrpt"
      let nSettingNames$(15)="suppressloggingerr"

      let SSettings$(1)=Defaultfilelayoutpath$
      let SSettings$(2)=NewLine$
      let SSettings$(3)=LogLibrary$
      let SSettings$(4)=LogLayout$
      let SSettings$(5)=TemplatePath$
      let SSettings$(6)=IgnoreLayouts$
      let SSettings$(7)=ScreenIOPath$
      let SSettings$(8)=AuditPath$
      let ssettings$(9)=FileLayoutExtension$
      let ssettings$(10)=SaveSelectedCols$
      let ssettings$(11)=DateFormatExport$
      let ssettings$(12)=DateFormatDisplay$
      let sSettings$(13)=EmailLibrary$

      let NSettings(1)=Promptonfilecreate
      let NSettings(2)=Createlogfile
      let NSettings(3)=EnforceDupkeys
      let NSettings(4)=StartFileNumber
      let NSettings(5)=CheckIndex
      let NSettings(6)=CompressColumns
      let NSettings(7)=MaxColWidth
      let NSettings(8)=AnimateDatacrawler
      let NSettings(9)=CloseFileSimple
      let NSettings(10)=filterboxfilelist
      let NSettings(11)=filterboxData
      let NSettings(12)=PromptOnUpdate
      let NSettings(13)=GenerateScreenBtn
      let NSettings(14)=BypassFixRpt
      let NSettings(15)=SuppressLoggingErr

      let ReadSettings=1
   fnend

   dim ReadSettings
   dim SSettingNames$(13),SSettings$(13)*255
   dim NSettingNames$(15),NSettings(15)

   def fnSettings$*255(SettingName$;___,SettingSub)
      if ~ReadSettings then let fnReadSettings(mat SSettingNames$,mat SSettings$,mat NSettingNames$,mat NSettings$,ReadSettings)
      let SettingSub=srch(mat SSettingNames$,lwrc$(SettingName$))
      if SettingSub>0 then let fnSettings$=SSettings$(SettingSub)
   fnend
   def fnSettings(SettingName$;___,SettingSub)
      if ~ReadSettings then let fnReadSettings(mat SSettingNames$,mat SSettings$,mat NSettingNames$,mat NSettings$,ReadSettings)
      let SettingSub=srch(mat NSettingNames$,lwrc$(SettingName$))
      if SettingSub>0 then let fnSettings=NSettings(SettingSub)
   fnend
   def library fnFileIO_Settings$*255(SettingName$)=fnSettings$(SettingName$)
   def library fnFileIO_Settings(SettingName$)=fnSettings(SettingName$)

   dim StarsChecked
   def fnNeedStar$
      if StarsChecked then
         if StarsChecked=-1 then let fnNeedStar$="*"
      else
         if Env$("guimode")="ON" then
            let StarsChecked=1
         else
            let StarsChecked=-1
            let fnNeedStar$="*"
         end if
      end if
   fnend

TestFileIO: ! Test partial indexes here
   print "Partial Index Tests:"
   let String1$=String2$="StartDate(5:8)"
   let Position=10
   let Length=8
   let fnReadPartialSyntax(String1$,Position,"startdate","position")
   let fnReadPartialSyntax(String2$,Length,"startdate","length")
   if String1$="StartDate" and String2$="StartDate" and Position=14 and Length=4 then
      print "Test 1: StartDate(5:8)  - Passed"
   else
      print "Test 1: StartDate(5:8)  - Failed"
   end if

   let String1$=String2$="StartDate(1:4)"
   let Position=10
   let Length=8
   let fnReadPartialSyntax(String1$,Position,"startdate","position")
   let fnReadPartialSyntax(String2$,Length,"startdate","length")
   if String1$="StartDate" and String2$="StartDate" and Position=10 and Length=4 then
      print "Test 2: StartDate(1:4)  - Passed"
   else
      print "Test 2: StartDate(1:4)  - Failed"
   end if

   ! This code tests the fnCompressIndexParms function:
   print
   print "fnCompressIndexParms:"
   let X$="1/3/10" : let Y$="2/4/3"
   let fnCompressIndexParms(X$,Y$)
   print "Positions: "&X$;
   if X$="1/10" then print "         - Passed" else print "         - Failed"
   print "Lengths: "&Y$;
   if Y$="6/3" then print "            - Passed" else print "            - Failed"

   let X$="1/3/10" : let Y$="2/4U/3"
   let fnCompressIndexParms(X$,Y$)
   print "Positions: "&X$;
   if X$="1/3/10" then print "       - Passed" else print "       - Failed"
   print "Lengths: "&Y$;
   if Y$="2/4U/3" then print "         - Passed" else print "         - Failed"

   if exists("filelay\customer.lay") then
      ! Test fnBuildKey
      print
      print "fnBuildKey:"

      dim TestKey$*64

      library : fnBuildKey$
      mat Customer$(20) : mat Customer(29)
      let Customer$(1)="7922"
      let Customer$(2)="Acme Hammers"
      let Customer$(5)="Duncanville"
      let Customer$(9)="4692235476"
      let TestKey$=fnBuildKey$("customer",mat Customer$,mat Customer)
      if TestKey$="7922" then
         print "Test 1: "&TestKey$&"            - Passed"
      else
         print "Test 1: "&TestKey$&"            - Failed"
      end if

      let TestKey$=fnBuildKey$("customer",mat Customer$,mat Customer,2)
      if TestKey$="Dunca2235476CME" then
         print "Test 2: "&TestKey$&" - Passed"
      else
         print "Test 2: "&TestKey$&" - Failed"
      end if
   end if
stop

! #Autonumber# 2000,10
DIMS: ! Dimension Statements For Data Crawler
   dim Lvdir_Headings$(1)*30,Lvdir_Widths(1),Lvdir_Fieldforms$(1),lvdir_Listing$(1)*128
   dim Dc_Data$(1)*1024,Dc_Data(1),Dc_Forms$(1)*2000,Dc_Dfdescr$(1)*80,dc_dateformats$(1)*50,Dc_Dflabel$(1)*80,Dc_Dfshow(1),Dc_SDateSpec$(1)*64,DC_NDateSpec$(1)*64
   dim Csv_Data$(1)*4000,Csv_Data(1),Csv_Forms$(1)*2000,Csv_Dfdescr$(1)*80, csv_dateformats$(1)*50
   dim Dc_Widths(1),Fieldforms$(1),Dc_Outputrow$(1)*1024,Dc_Records(1)
   dim dc_Savedata$(1)*1024, dc_Savesubs(1)
   dim dc_Deleterow(1),dc_Colorstart(1),dc_Colorend(1),dc_Color$(1)
   dim dc_Changeddata$(1)*1024, dc_Changedsubs(1)
   dim _Dummy$*255,_Dummy,_Logging
   dim IncludeCols$(1), UIOptions$(13), SelectedRecords(1),Records(1)
   dim Search$*80

   dim FilterBox$*64
   dim BypassDateProcessing$*20
!
   if Trim$(Env$("guimode"))="" then
      print "DataCrawler Mode only works with New Gui version of BR"
      stop
   end if
   let Turnguibackoff=(Env$("guimode")=="OFF")
   if Turnguibackoff then execute "config gui on"
!
   let Lvdir_Headings$(1)="File Layouts" !:
   let Lvdir_Widths(1)=38 !:
   let Lvdir_Fieldforms$(1)="CC 30"

   let UIOptions$(1)="quitbutton"
   let UIOptions$(2)="exportbutton"
   let UIOptions$(3)="importbutton"
   let UIOptions$(4)="columnsbutton"
   let UIOptions$(5)="keybutton"
   let UIOptions$(6)="deletebutton"
   let UIOptions$(7)="savebutton"
   let UIOptions$(8)="addbutton"
   let UIOptions$(9)="search"
   let UIOptions$(10)="border"
   let UIOptions$(11)="caption"
   let UIOptions$(12)="recl"
   let UIOptions$(13)="position"
   mat IncludeCols$(0) ! We're including all cols

   library : Fnreadlayouts,fnShowData,fnGetFileNumber, fnLog, fnLogArray, fnSearchLegacyReadStatements
!
SELECTDATAFILE: ! ***** Datafile Selection Routine #Autonumber# 7000,5

   let fnReadLayouts(Mat Lvdir_Listing$)
   let fnCheckForNewExtension(mat LvDir_Listing$)
   let fnIgnoreLayouts(mat LvDir_Listing$)

   let fnReadScreenS(ScreenRows,ScreenCols)

   open #(Dc_Window:=Fngetfilenumber): "srow=2,scol="&str$(int((ScreenCols-39)/2))&",rows="&str$(ScreenRows-2)&",cols=39,Caption= Select File ... ENTER - View / F5 - Edit ,Border=S",display,outin

   if Udim(Mat Lvdir_Listing$)>15 then let Lvdir_Widths(1)-=2 ! Make Room For Scrollbar

   let _Logging=fnSettings("createlogfile")
   let _GenerateScreen=fnSettings("generatescreenbtn")

   dim HT$(1)*2000
   ! let HT$(1)="3;Run Once to set the Start Reference Point. Then test an Operation on your Files. Run again to display all changes found in the selected files.;"

   print #Dc_Window, fields str$(ScreenRows-5)&",3,CC 10,/W:W,B43;"&str$(ScreenRows-5)&",27,CC 10,/W:W,B44" : "Quit","View"
   print #Dc_Window, fields str$(ScreenRows-5)&",15,CC 10,/W:W,B47", help "3;Run Once to set the Start Reference Point. Then test an Operation on your Files. Run again to display all changes found in the selected files.;"  : "Compare"
   if _GenerateScreen then
      print #Dc_Window, fields str$(ScreenRows-2)&",10,10/CC 20,/W:W,B49;"&str$(ScreenRows-2)&",21,9/CC 20,/W:W,B45" : "Generate Screen","Generate Code"
   else
      print #Dc_Window, fields str$(ScreenRows-2)&",10,CC 20,/W:W,B45" : "Generate Code"
   end if

   ! print #Dc_Window, fields str$(ScreenRows-3)&",3,5/CC 20,/W:W,B50", help "3;Search non-fileio programs to see which programs access the given file and all their associated read statements." : "Search Reads"
   print #Dc_Window, fields str$(ScreenRows-3)&",32,CC 6,/W:W,B8", help "3;Check for Updates (F8);" : "v"&str$(fnVersion)
   print #Dc_Window, fields str$(ScreenRows-2)&",32,CC 6,/W:W,B9", help "3;View FileIO Recent Changes;" : "Log"
   print #Dc_Window, fields str$(ScreenRows-3)&",10,CC 20,/W:W,B46" : "New Layout Wizard"
   print #Dc_Window, fields str$(ScreenRows-3)&",2,CC 6,/W:W,B48", help "3;Export All Selected Data Files to CSV;" : "Export"
   print #Dc_Window, fields "1,2,LIST "&str$(ScreenRows-8)&"/37,HEADERS,/W:W" : (Mat Lvdir_Headings$, Mat Lvdir_Widths, Mat Lvdir_Fieldforms$)
   print #Dc_Window, fields "1,2,LIST "&str$(ScreenRows-8)&"/37,=" : (Mat Lvdir_Listing$)
   print #Dc_Window, fields "1,2,LIST "&str$(ScreenRows-8)&"/37,SORT" : 1
   ! print #Dc_Window, fields str$(ScreenRows-4)&",12,C" : "Show Raw Data"

   if fn43 and fnSettings("filterboxfilelist")  then
      let FilterBox$=str$(ScreenRows-7)&",2,FILTER 37,/W:W,1,2,FULLROW,ALL"
   else
      let FilterBox$=str$(ScreenRows-7)&",2,SEARCH 37,/W:W,1,2"
   end if

   do
      if BypassDateProcessing then
         print #Dc_Window, fields str$(ScreenRows-4)&",9,CC 22,N" : "F7 - Unpack Dates: Off"
      else
         print #Dc_Window, fields str$(ScreenRows-4)&",9,CC 22,N" : "F7 - Unpack Dates: On"
      end if

      input #Dc_Window, fields FilterBox$&";1,2,LIST "&str$(ScreenRows-8)&"/37,ROWCNT,SEL,44" : Search$,Count
      mat SelectedRecords(Count)
      input #Dc_Window, fields "1,2,LIST "&str$(ScreenRows-8)&"/37,ROWSUB,SEL,NOWAIT" : mat SelectedRecords
      input #Dc_Window, fields "1,2,LIST "&str$(ScreenRows-8)&"/37,ROWSUB,CUR,NOWAIT" : Chosen

      ! let BypassDateProcessing:=(BypassDateProcessing$(1:1)=="^")

      let Dc_Key=Fkey

      mat Records(0) ! We're including all records

      if Dc_Key=0 Or Dc_Key=201 then let Dc_Key=44 ! Ok Button
      if Dc_Key=99 then let Dc_Key=43 ! Esc Button
      if Dc_Key=93 then let Dc_Key=43
      if Dc_Key=44 then ! Ok Selected
         let fnClearCache
         let fnShowData(Lvdir_Listing$(Chosen),0,0,0,0,0,1,"","","","","Data Crawler",mat Records,mat IncludeCols$,mat UIOptions$,D$,D,D$,"count",D$,D$,D$,D$,D$,D,1,BypassDateProcessing)
         if fkey=93 then let dc_key=43   ! pass windows X click back to parent
      end if
      if Dc_Key=7 then
         let BypassDateProcessing=~BypassDateProcessing
      end if
      if Dc_Key=5 then
         let fnClearCache
         let fnShowData(Lvdir_Listing$(Chosen),1,0,0,0,0,1,"","","","","Data Editor",mat Records,mat IncludeCols$,mat UIOptions$,D$,D,D$,"count",D$,D$,D$,D$,D$,D,1,BypassDateProcessing)
      end if
      if Dc_Key=45 then
         let fnGenerateCode(Lvdir_listing$(Chosen))
      end if
      if Dc_Key=46 then
         let fnLayoutWizard

         ! Refresh Listview
         let fnReadLayouts(mat Lvdir_Listing$)
         let fnIgnoreLayouts(mat LvDir_Listing$)
         print #Dc_Window, fields "1,2,LIST "&str$(ScreenRows-8)&"/37,=" : (Mat Lvdir_Listing$)
         print #Dc_Window, fields "1,2,LIST "&str$(ScreenRows-8)&"/37,SORT" : 1
      end if
      if Dc_Key=49 then ! Generate Screen using ScreenIO
         let fnMakeScreen(Lvdir_listing$(Chosen),1) error OldScreenIO
      end if
      if Dc_Key=8 then
         let fnCheckForUpdates
      end if
      if Dc_Key=9 then
         if exists("FileIOUpdateLog.txt") then execute "sy -C -M start FileIOUpdateLog.txt"
      end if
      if Dc_Key=47 then
         let fnCallAudit(mat SelectedRecords,mat lvdir_listing$)
      end if
      if Dc_Key=48 then
         let fnExportSelectedFiles(mat SelectedRecords,mat Lvdir_listing$)
      end if
      if Dc_Key=50 then
         let fnSearchLegacyReadStatements(Lvdir_listing$(Chosen))
         ! $$$$$ Later, make a fnSearchLegacyReadStatements that supports Multi Select
      end if

      if fkey=93 then let dc_key=43   ! pass windows X click back to parent
   loop Until Dc_Key=43
   close #Dc_Window:
!
ENDDATACRAWLER: ! #Autonumber# 8000,10
   if Turnguibackoff then execute "config gui off"
   if fkey=93 then
      execute "system"
   end if
   stop

OldScreenIO: ! Error this old version of ScreenIO doesn't support this feature.
   if (1==msgbox(`This feature is not supported in this older version of ScreenIO.

      Please upgrade to the latest ScreenIO by downloading it from:
      http://www.sageax.com/downloads/ScreenIO.zip.

      Would you like us to download it for you?`,"Upgrade ScreenIO","yN")) then
      execute "system -C -M start http://www.sageax.com/downloads/ScreenIO.zip"
   end if
   continue
!
! #Autonumber# 10000,1
! *****************
! ** DATACRAWLER **
! *****************

   dim SearchNow$*999
   dim DcSpec$(2)*60
   dim filterF$(1)*1023,FilterF(1)

   def library Fndataedit( !_
      Filelay$;   !_   The file layout to view
      srow$,      !_   The start row to position the grid
      scol$,      !_   The start column to position the grid
      rows$,      !_   The height of the grid
      cols$,      !_   The width of the grid
      ___,SRow,SCol,Rows,Cols)

      let SRow=val(srow$) conv Ignore
      let SCol=val(scol$) conv Ignore
      let Rows=val(rows$) conv Ignore
      let Cols=val(cols$) conv Ignore

      library : fnShowData
      let fndataedit=fnShowData(fileLay$,1,SRow,SCol,Rows,Cols)
   fnend

   def library Fndatacrawler(Filelay$;srow$,scol$,rows$,cols$,___,SRow,SCol,Rows,Cols)
      let SRow=val(srow$) conv Ignore
      let SCol=val(scol$) conv Ignore
      let Rows=val(rows$) conv Ignore
      let Cols=val(cols$) conv Ignore

      library : fnShowData
      let Fndatacrawler=fnShowData(fileLay$,0,SRow,SCol,Rows,Cols)
   fnend

   def fnCalculateSize(&sRow,&sCol,&Rows,&Cols,Edit,mat Element$,Mat Filter$;___,ScreenRows,ScreenCols,MinRows,MinCols,MaxRows,MaxCols,MinSRow,MinSCol,AdjRows,AdjCols)
      let fnReadScreenS(ScreenRows,ScreenCols)
      let fnCalculateSizeLimits(mat Element$,Edit,ScreenRows,ScreenCols,Rows,Cols,MinRows,MinCols,MaxRows,MaxCols,MinSRow,MinSCol,mat Filter$)

      ! Size it within limits
      let Rows=max(min(Rows,MaxRows),MinRows)
      let Cols=max(min(Cols,MaxCols),MinCols)

      ! Center it if position isn't given
      if ~sRow then let sRow=int((ScreenRows-Rows)/2)+1
      if ~sCol then let sCol=int((ScreenCols-Cols)/2)+1

      let AdjRows=int((ScreenRows+MaxRows)/2)
      let AdjCols=int((ScreenCols+MaxCols)/2)

      ! Adjust it to fit it on screen
      sRow=max(min(sRow,AdjRows-Rows),MinsRow)
      sCol=max(min(sCol,AdjCols-Cols),MinsCol)
   fnend

   ! If Include is blank (not given), then include everything.
   def fnPrepIncludeUI$(mat IncludeUI$;___,Index,Empty)
      if fnIsEmptyS(mat IncludeUI$) then
         ! Default UI Options
         mat IncludeUI$(10)
         let IncludeUI$(1)="quitbutton"
         let IncludeUI$(2)="exportbutton"
         let IncludeUI$(3)="importbutton"
         let IncludeUI$(4)="columnsbutton"
         let IncludeUI$(5)="deletebutton"
         let IncludeUI$(6)="savebutton"
         let IncludeUI$(7)="addbutton"
         let IncludeUI$(8)="search"
         let IncludeUI$(9)="border"
         let IncludeUI$(10)="caption"
      end if

   fnend

   def fnIsEmptys(mat A$;___,Index,Empty)
      let Empty=1
      for Index=1 to udim(Mat A$)
         if A$(Index)<>"" then let empty=0
      next Index
      let fnIsEmptys=Empty
   fnend
   def fnIsEmpty(mat A;___,Index,Empty)
      let Empty=1
      for Index=1 to udim(Mat A)
         if A(Index) then let empty=0
      next Index
      let fnIsEmpty=Empty
   fnend
   def library fnEmpty(mat A)=fnIsEmpty(mat A)
   def library fnEmptyS(mat A$)=fnIsEmptyS(mat A$)

   def fnClearUI(mat OutputSpec$,mat InputSpec$,mat OutputData$,mat InputData$)
      mat OutputSpec$(0)
      mat OutputData$(0)
      mat InputSpec$(0)
      mat InputData$(0)
      let ButtonCount=0
   fnend

   dim ButtonCount,MaxButtonColumns
   def fnButtonRows
      if ButtonCount then
         let fnButtonRows=int((ButtonCount-1)/MaxButtonColumns)+1
      end if
   fnend

   def fnButtonSpec$*36(ButtonFkey,row,cols;___,ButtonCol,ButtonRow)
      let ButtonCount+=1
      let ButtonRow=int((ButtonCount-1)/MaxButtonColumns)
      let ButtonCol=mod(ButtonCount-1,MaxButtonColumns)+1
      let fnButtonSpec$=Str$(row-ButtonRow)&","&str$(cols-((8*(ButtonCol))-1))&","&"7/CC 10,/W:W,B"&str$(ButtonFkey)
   fnend

   def fnAddButton(mat OutputSpec$,mat OutputData$,rows,Cols,ButtonFkey,Data$)
      let fnAddObject(mat OutputSpec$,mat OutputData$,fnButtonSpec$(ButtonFKey,rows,Cols),data$)
   fnend

   def fnAddObject(mat OutputSpec$,mat OutputData$,Spec$*40,Data$;___,Index)
      let Index=udim(mat OutputSpec$)+1
      mat OutputSpec$(Index)
      mat OutputData$(Index)
      let OutputSpec$(Index)=Spec$
      let OutputData$(Index)=Data$
      let fnAddObject=Index
   fnend

   def fnCalculateSizeLimits(mat Element$,Edit,ScreenRows,ScreenCols,&Rows,&Cols,&MinRows,&MinCols,&MaxRows,&MaxCols,&MinSRow,&MinSCol,mat Filter$;___,Index,BCount,BCols,o_border,ButtonRows)

      ! Set Defaults
      let MaxRows=ScreenRows
      let MaxCols=ScreenCols
      let MinSRow=1
      let MinSCol=1
      let MinRows=3
      let MinCols=10

      for Index=1 to udim(mat Element$)
         #Select# lwrc$(trim$(Element$(Index))) #Case# "importbutton" # "addbutton" # "deletebutton" # "savebutton"
            if Edit then let BCount+=1
         #Case# "columnsbutton" # "exportbutton" # "keybutton" # "quitbutton"
            let BCount+=1
         #Case# "search"
            let MinRows+=1
            let MinCols=max(MinCols,20)
         #Case# "grid"
         #Case# "border" # "caption" # "recl"
            let o_border=1
         #End Select#
      next Index

      if o_border then ! Expand to include border
         let MaxRows-=2 : let MaxCols-=2
         let MinsRow+=1 : let MinsCol+=1
      end if

      ! Default Size if not given
      if ~Rows then let Rows=MaxRows
      if ~Cols then let Cols=MaxCols

      ! calculate how many columns we need
      if bcount<5 or bcount<=(Cols-2)/8 then
         let MaxButtonColumns=bcount
      else
         let MaxButtonColumns=int((bcount-1)/2)+1
      end if

      ! Expand to include buttons
      if BCount then
         let ButtonRows=int((BCount-1)/MaxButtonColumns)+1
         let MinRows+=ButtonRows
         if ButtonRows>1 then
            let BCols=MaxButtonColumns
         else
            let BCols=mod((BCount-1),MaxButtonColumns)+1
         end if
         let MinCols=Max(MinCols,(8*(BCols-1))+10)
      end if

      ! Add a row for filters
      if ~fnIsEmptys(mat Filter$) then
         let MinRows+=1
      end if
   fnend

   def fnBuildUI(mat Element$,mat OS$,mat IS$,mat OD$,mat ID$,mat FilterFields$,mat FilterForm$,mat FilterCompare$,mat FilterCaption$,mat FilterDefaults$,mat FilterSubs,mat FilterValSubs,mat ColumnNames$,mat FilterKey,&GridSpec$,Edit,Rows,Cols;&o_caption,&o_border,&o_recl,&o_position,&SearchSub,___,o_search,Index,Grid$,FirstRow,FilterPosition,Sub,FilterString$,FilterEndString$)
      let FirstRow=1
      if fn43 and fnSettings("filterboxdata") then
         let FilterString$="FILTER"
         let FilterEndString$=",FULLROW,ALL"
      else
         let FilterString$="SEARCH"
         let FilterEndString$=""
      end if

      if ~fnIsEmptyS(mat FilterFields$) then
         let FirstRow+=1
         let FilterPosition=1
         mat FilterForm$(udim(mat FilterFields$))
         mat FilterCompare$(udim(mat FilterFields$))
         mat FilterCaption$(udim(mat FilterFields$))
         mat FilterDefaults$(udim(mat FilterFields$))
         mat FilterSubs(udim(mat FilterFields$))
         mat FilterValSubs(udim(mat FilterFields$))
         mat FilterKey(udim(mat FilterFields$))

         for Index=1 to udim(mat filterfields$)
            if len(trim$(filterfields$(Index))) then
               let sub=srch(mat ColumnNames$,lwrc$(trim$(filterfields$(Index))))
               if sub>0 then
                  let fnAddObject(mat OS$,mat OD$,"1,"&str$(FilterPosition)&",CR "&str$(len(FilterCaption$(Index))),FilterCaption$(Index))
                  let FilterPosition+=len(FilterCaption$(Index))+1
                  let FilterValSubs(Index)=fnAddObject(mat IS$,mat ID$,"1,"&str$(FilterPosition)&","&FilterForm$(Index),FilterDefaults$(Index))
                  let FilterPosition+=fnLengthOf(FilterForm$(Index))+2
                  let FilterSubs(Index)=sub
               end if
            end if
         next Index
      end if
      for Index=1 to udim(mat Element$)
         #Select# lwrc$(trim$(Element$(Index))) #Case# "columnsbutton"
            let fnAddButton(mat OS$,mat OD$,Rows,Cols,55,"Columns")
         #Case# "exportbutton"
            let fnAddButton(mat OS$,mat OD$,Rows,Cols,56,"Export")
         #Case# "importbutton"
            if Edit then let fnAddButton(mat OS$,mat OD$,Rows,Cols,57,"Import")
         #Case# "addbutton"
            if Edit then let fnAddButton(mat OS$,mat OD$,Rows,Cols,15,"Add")
         #Case# "savebutton"
            if Edit then let fnAddButton(mat OS$,mat OD$,Rows,Cols,5,"Save (F5)")
         #Case# "deletebutton"
            if Edit then let fnAddButton(mat OS$,mat OD$,Rows,Cols,16,"Delete")
         #Case# "keybutton"
            let fnAddButton(mat OS$,mat OD$,Rows,Cols,4,"Jump (F4)")
         #Case# "quitbutton"
            let fnAddButton(mat OS$,mat OD$,Rows,Cols,54,"Quit")
         #Case# "search"
            if exists("images\search.png") then
               let SearchSub=fnAddObject(mat IS$,mat ID$,str$(firstrow)&",3,"&FilterString$&" "&str$(cols-12)&",/W:W,2,1"&FilterEndString$,"")
               let fnAddObject(mat OS$,mat OD$,str$(firstrow)&",1,P 1/2","images\search.png")
            else
               let SearchSub=fnAddObject(mat IS$,mat ID$,str$(firstrow)&",1,"&FilterString$&" "&str$(cols-10)&",/W:W,2,1"&FilterEndString$,"")
            end if
            let fnAddObject(mat OS$,mat OD$,str$(firstrow)&","&str$(cols-8)&",CC 8,/W:W,B70","Refresh")
            let o_search=1
         #Case# "border"
            let o_border=1
         #Case# "caption"
            let o_caption=1
            let o_border=1
         #Case# "recl"
            let o_recl=1
            let o_caption=1
            let o_border=1
         #Case# "position"
            let o_position=1
         #End Select#
      next Index

      if Edit then
         let fnAddObject(mat IS$,mat ID$,str$(FirstRow+o_search)&",1,GRID "&str$(rows-((firstrow-1)+o_search+fnButtonRows))&"/"&str$(cols)&",ROWCNT,CHG","")
         let GridSpec$=str$(FirstRow+o_search)&",1,GRID "&str$(rows-((firstrow-1)+o_search+fnButtonRows))&"/"&str$(cols)
      else
         let fnAddObject(mat IS$,mat ID$,str$(FirstRow+o_search)&",1,LIST "&str$(rows-((firstrow-1)+o_search+fnButtonRows))&"/"&str$(cols)&",ROWSUB,SELONE","")
         let GridSpec$=str$(FirstRow+o_search)&",1,LIST "&str$(rows-((firstrow-1)+o_search+fnButtonRows))&"/"&str$(cols)
      end if
      mat ID$(udim(mat ID$)-1) ! Remove Data element for list; it has to be given as a Scalar
   fnend

   def fnCheckForUpdates(;___,Connection,V,String$*1000,Window)
      if fn43 then
         open #(Window:=fnGetFileNumber): "srow=10,scol=20,rows=1,cols=30,Border=S",display,outin
         print #Window, fields "1,1,CC 30" : "Contacting Server..."
         open #(Connection:=fnGetFileNumber): "name=http://www.sageax.com/downloads/FileIOVersion.txt, http=client",display,outin
         if file(Connection)=0 then
            linput #Connection: String$ eof Ignore
            close #Connection:
            close #Window:
            let V=-999
            let V=Val(String$) conv Ignore
            if V=-999 then
               let msgbox("There was an error checking the latest version on the Server. Check your internet connection, or try again later."&hex$("0D0A0D0A")&"If the problem persists, please contact Gabriel Bakker at gabriel.bakker@gmail.com.","Connection Failed","Ok","EXCL")
            else if V>fnVersion then
               if (2==msgbox("A newer version (FileIO v"&str$(V)&") is available. (You're currently running FileIO v"&str$(fnVersion)&")."&hex$("0D0A0D0A")&"Would you like to download the update from our website?","Update Y/N?","Yn","QST")) then
                  execute "sy -C -M start http://www.sageax.com/downloads/FileIO.zip"
               end if
            else
               let msgbox("Your version is up to date!"&hex$("0D0A0D0A")&"You are running FileIO v"&str$(fnVersion)&", the current version.","FileIO is Up to Date","Ok","EXCL")
            end if
         else
            let msgbox("The server, www.sageax.com, could not be reached. Check your internet connection, or try again later."&hex$("0D0A0D0A")&"If the problem persists, please contact Gabriel Bakker at gabriel.bakker@gmail.com.","Connection Failed","Ok","EXCL")
            close #Window:
            if file(Connection)><-1 then close #Connection:
         end if
      else
         let msgbox("This feature requires BR 4.3+")
      end if
   fnend

   def fnPrepareWindow(&sRow,&sCol,&Rows,&Cols,Edit,mat Includebuttons$,&Caption$,&GridSpec$,mat Inputspec$,mat OutputSpec$,mat Inputdata$,mat OutputData$,&o_position,mat FilterFields$,mat FilterForm$,mat FilterCompare$,mat FilterCaption$,mat FilterDefaults$,mat FilterSubs,mat FilterValSubs,mat ColumnNames$,mat FilterKey,&Searchsub;___,o_caption,o_border,o_recl)
      let fnPrepIncludeUI$(Mat Includebuttons$)

      let fnCalculateSize(sRow,sCol,Rows,Cols,Edit,mat Includebuttons$,mat FilterFields$)
      let fnClearUI(mat OutputSpec$,mat InputSpec$,mat OutputData$,mat InputData$)
      let fnBuildUI(mat Includebuttons$,mat OutputSpec$,mat InputSpec$,mat OutputData$,mat InputData$,mat FilterFields$,mat FilterForm$,mat FilterCompare$,mat FilterCaption$,mat FilterDefaults$,mat FilterSubs,mat FilterValSubs,mat ColumnNames$,mat FilterKey,GridSpec$,Edit,Rows,Cols,o_caption,o_border,o_recl,o_position,SearchSub)

      ! if setting recl or
      if Caption$="" and o_Caption then let Caption$="View '"&Filelay$&"' File"
      if o_Recl then let Caption$=Caption$&" ... Recl="&str$(rln(datafile))
      if o_Border then
         if len(Caption$) then let Caption$=Caption$&","
         let Caption$=Caption$&"Border=S"
      end if
   fnend

   dim TextDisplay$*255
   dim BadRead$(1)*20000

   def fnPopulateGrid(Window,GridSpec$,Layout$,KeyMatch$*255,SearchMatch$*255,mat Records,mat IncludeColumns$,mat ColumnNames$,RecordSize,Datafile,mat Dc_Data$,mat Dc_Data,mat dc_forms$,&SearchNow$,mat Dc_Records,mat dc_DeleteRow,KeyNumber,&LastRec$,DisplaySub,&DisplayConvert$,mat FilterCompare$,mat FilterSubs,mat FilterValSubs,mat FilterKey,mat InputData$;IncludeRecordNumbers,mat dc_dateformats$,datedisplayformat$,BypassDateProcessing,___,SomethingFound,Or_Recordlocation,Clearflag$*1,Index,Animate,bIncludeColumns,Sub,bRecords,RecPointer,Stopreading,Action,TempKey$*255,RowCount,ReadCount,LastTime,BadReadFile)

      execute "config keyboard 6300 2200" ! ESC To Ctrl-F8 (Fkey 34)
      execute "config keyboard 0B00 0A0A0A636F6E206B657920636C6561720D" ! Shift F1 Key To "con key clear<CR>"
      on fkey 34 gosub AbortLoading

      let Animate=fnSettings("animatedatacrawler")
      mat dc_Outputrow$(0) : mat dc_Records(0) : mat dc_Deleterow(0)
      let Clearflag$="="
      if Animate then let fnPrepareAnimation

      let RecordSize=udim(mat Widths)

      let bIncludeColumns=(~fnIsEmptys(mat IncludeColumns$))
      let bRecords=(~fnIsEmpty(mat Records))

      if len(keymatch$) and kln(datafile)>0 then
         let keymatch$=rtrm$(keymatch$(1:kln(datafile)))
         restore #Datafile, search>=keymatch$:
      end if

      mat BadRead$(0) ! Clear Bad Record Reads

      mat Dc_SDateSpec$(udim(mat Dc_Data$))
      if udim(mat Dc_SDateSpec$) then mat Dc_SDateSpec$=dc_dateformats$(1:udim(mat Dc_Data$))
      mat Dc_NDateSpec$(udim(mat Dc_Data))
      if udim(mat Dc_NDateSpec$) Then mat Dc_NDateSpec$=dc_dateformats$(udim(mat Dc_Data$)+1:udim(mat Dc_DateFormats$))

      do  ! Read Data
         let LastTime=Timer
         do while file(datafile)<>10
            if bRecords then
               let RecPointer+=1
               if RecPointer<=udim(mat Records) then
                  read #datafile, using Dc_Forms$(datafile), rec=Records(RecPointer), release : Mat dc_Data$,Mat dc_Data error Ignore
               else
                  let Stopreading=1
               end if
            else
               read #datafile, using Dc_Forms$(datafile),release : Mat dc_Data$,Mat dc_Data error Ignore
            end if

            if ~file(datafile) and ~Stopreading then
               let ReadCount+=1
               let Action=fnPassesFilter(mat dc_Data$,mat dc_Data,mat FilterCompare$,mat FilterValSubs,mat FilterSubs,mat InputData$,mat FilterKey)
               if Action=1 then
                  if ~len(Keymatch$) or KeyMatch$=fnbuildKey$(Layout$,mat dc_data$,mat dc_data,KeyNumber)(1:len(Keymatch$)) then
                     if ~len(SearchMatch$) or fnSearchIn(SearchMatch$,mat Dc_Data$,mat Dc_Data,mat Dc_SDateSpec$,mat Dc_NDateSpec$,datedisplayformat$,BypassDateProcessing) then
                        if ~len(SearchNow$) or fnSearchIn(SearchNow$,mat Dc_Data$,mat Dc_Data,mat Dc_SDateSpec$,mat Dc_NDateSpec$,datedisplayformat$,BypassDateProcessing) then
                           let RowCount+=1
                           let Somethingfound=1
                           let Or_Recordlocation=Udim(Mat dc_Outputrow$)
                           mat dc_Outputrow$(Udim(dc_Outputrow$)+Recordsize) ! Add Room
                           mat dc_Deleterow(Udim(Mat dc_Records) + 1) ! Add Row To Delete From
                           mat dc_Records(Udim(Mat dc_Records) + 1)
                           let dc_Records(Udim(Mat dc_Records))=Rec(datafile) ! Save Record Number For Later
                           if IncludeRecordNumbers then
                              let dc_OutputRow$(Or_Recordlocation+IncludeRecordNumbers)=str$(rec(Datafile))
                           end if

                           if bIncludeColumns then
                              for Index=1 to udim(mat IncludeColumns$)
                                 let Sub=srch(mat ColumnNames$,IncludeColumns$(Index))
                                 if Sub>udim(mat dc_data$) then
                                    let dc_OutputRow$(Or_RecordLocation+Index+IncludeRecordNumbers)= fnfmtndate$(dc_Data(sub-udim(mat Dc_Data$)),dc_dateformats$(sub),"DATE(JULIAN)",BypassDateProcessing)
                                 else if Sub>0 then
                                    let dc_OutputRow$(Or_RecordLocation+Index+IncludeRecordNumbers)=fnfmtsdate$(dc_Data$(Sub),dc_dateformats$(Sub),"DATE(JULIAN)",BypassDateProcessing)
                                 end if
                              next Index
                           else
                              for Index=1 to Udim(Mat dc_Data$) ! Copy Strings
                                 let dc_Outputrow$(Or_Recordlocation+Index+IncludeRecordNumbers)= fnfmtsdate$(dc_Data$(Index),dc_dateformats$(Index),"DATE(JULIAN)",BypassDateProcessing)
                              next Index

                              for Index=1 to Udim(Mat dc_Data) ! Copy Numerics
                                 let dc_Outputrow$(Or_Recordlocation+Index+IncludeRecordNumbers+Udim(Mat dc_Data$))=fnfmtndate$(dc_Data(Index),dc_dateformats$(Index+Udim(Mat dc_Data$)),"DATE(JULIAN)",BypassDateProcessing)
                              next Index
                           end if
                        end if
                     end if
                  else
                     let StopReading=1
                  end if
               else if Action<0 then
                  let Action=Action*-1

                  mat FilterF$(udim(mat dc_data$))=("")
                  mat FilterF(udim(mat dc_Data))=(0)

                  ! take the filter that failed
                  if FilterSubs(Action)>udim(mat FilterF$) then ! use filter to find the subscript
                     let FilterF(FilterSubs(Action)-udim(mat FilterF$))=val(inputdata$(FilterValSubs(Action))) conv Ignore
                  else
                     let FilterF$(FilterSubs(Action))=InputData$(FilterValSubs(Action))
                  end if

                  ! use subscript to build an empty f$ and f with the data
                  ! use fnBuildKey$ and Keynum
                  if kln(datafile)>0 and ~fnIsEmpty(mat FilterF) or ~fnIsEmptyS(mat FilterF$) then
                     let TempKey$=fnBuildKey$(Layout$,mat FilterF$,mat FilterF,Keynumber)
                     restore #datafile, search>=Trim$(TempKey$): nokey StopReading
                  end if
               else if Action=2 then
                  StopReading: let StopReading=1 ! dont like it but its the simplest way to do it in this language.
               end if
               if Animate then
                  let TextDisplay$=""
                  if DisplaySub then
                     if DisplaySub=-2 then
                        let TextDisplay$=lpad$(str$(ReadCount),len(LastRec$)) ! Count of Rows Read
                     else if DisplaySub=-3 then
                        let TextDisplay$=lpad$(str$(RowCount),len(LastRec$))  ! Count of Rows Added
                     else if DisplaySub<0 then ! All others use record number
                        let TextDisplay$=lpad$(str$(rec(DataFile)),len(LastRec$))
                     else if DisplaySub<=udim(mat dc_Data$) then
                        let TextDisplay$=trim$(dc_data$(DisplaySub))
                     else
                        if ~len(DisplayConvert$) then
                           let TextDisplay$=str$(dc_data(DisplaySub-udim(mat dc_data$)))
                        else
                           let TextDisplay$=cnvrt$(DisplayConvert$,dc_data(DisplaySub-udim(mat dc_data$))) conv Ignore
                        end if
                     end if
                  end if
                  if len(trim$(LastRec$)) then
                     if len(TextDisplay$) then let TextDisplay$=TextDisplay$&" of "
                     let TextDisplay$=TextDisplay$&LastRec$
                  end if

                  let fnAnimate(TextDisplay$)
               end if
            else
               if file(DataFile)=20 then
                  if (fn43 and udim(mat BadRead$)<13420) or udim(mat BadRead$)<=40 then
                     mat BadRead$(udim(BadRead$)+1)
                     reread #DataFile, using "form C "&str$(rln(datafile)) : BadRead$(udim(BadRead$)) error Ignore
                  end if
               end if
            end if

         loop until Stopreading or fkey=99 or Udim(Mat dc_Outputrow$)+Recordsize>1000 or (udim(mat dc_OutputRow$) and RowCount<=20 and (Timer-LastTime>2))

         print #Window, fields GridSpec$&","&Clearflag$ : Mat dc_Outputrow$
         mat dc_Outputrow$(0) ! Clear Already Used Data To Go Back For More
         let Clearflag$="+"
      loop Until StopReading or File(datafile)=10 or fkey=99 ! Until Eof Or Abort

      if udim(mat BadRead$) then
         if (2==msgbox("There were "&str$(udim(mat BadRead$))&" records that couldn't be read with the current file layout. Do you want to see them?","Some records could not be read: Debug?","yN","QST")) then
            open #(BadReadFile:=fnGetFileNumber): "name=@:badread[SESSION].out, recl="&str$(rln(datafile))&",replace", display, output
            for Index=1 to udim(mat BadRead$)
               let fnProgressBar(Index/udim(mat BadRead$))
               print #BadReadFile: BadRead$(Index)
            next Index
            close #BadReadFile:
            let fnCloseBar
            execute "system -@ -C -M start "&os_filename$("@:badread[SESSION].out")
         end if
      end if

      execute "config keyboard clear"
      on fkey 34 ignore

      if Animate then let fnCloseAnimation
      let fnPopulateGrid=SomethingFound
   fnend

   AbortLoading: ! Abort the loading of the listview here
      let StopReading=1
      let fkey(99)
   return

   def fnPassesFilter(mat dc_Data$,mat dc_Data,mat FilterCompare$,mat FilterValSubs,mat FilterSubs,mat InputData$,mat FilterKey;___,Index,Passing)
      let Passing=1 ! Give it a fighting chance (in case there are no filters)
      do while (Index:=Index+1)<=udim(mat FilterSubs)
         if filterSubs(Index)>0 then
            if Len(FilterCompare$(Index)) then
               let Passing=0
               if pos(FilterCompare$(Index),"*") then ! Fuzzy Search
                  if FilterSubs(Index)>udim(Mat dc_Data$) then
                     if len(trim$(InputData$(FilterValSubs(Index)))) and fnIsnumber(trim$(InputData$(FilterValSubs(Index)))) then
                        if pos(str$(dc_Data(FilterSubs(Index)-udim(mat Dc_Data$))),trim$(InputData$(FilterValSubs(Index)))) then
                           ! It passes this filter
                           let Passing=1
                        else
                           ! Failed numeric filter test
                        end if
                     else
                        let Passing=1
                     end if
                  else
                     if len(trim$(InputData$(FilterValSubs(Index)))) then
                        if pos(dc_Data$(FilterSubs(Index)),trim$(InputData$(FilterValSubs(Index)))) then
                           ! It passes this filter
                           let Passing=1
                        else
                           ! Failed numeric filter test
                        end if
                     else
                        let Passing=1
                     end if
                  end if
               end if
               if pos(FilterCompare$(Index),">") then
                  if FilterSubs(Index)>udim(Mat dc_Data$) then
                     if len(trim$(InputData$(FilterValSubs(Index)))) and fnIsnumber(trim$(InputData$(FilterValSubs(Index)))) then
                        if dc_Data(FilterSubs(Index)-udim(mat Dc_Data$))>val(InputData$(FilterValSubs(Index))) then
                           ! It passes this filter
                           let Passing=1
                        else
                           ! Failed numeric filter test
                        end if
                     else
                        let Passing=1
                     end if
                  else
                     if len(trim$(InputData$(FilterValSubs(Index)))) then
                        if dc_Data$(FilterSubs(Index))>InputData$(FilterValSubs(Index)) then
                           ! It passes this filter
                           let Passing=1
                        else
                           ! Failed numeric filter test
                        end if
                     else
                        let Passing=1
                     end if
                  end if
               end if
               if pos(FilterCompare$(Index),"<") then
                  if FilterSubs(Index)>udim(Mat dc_Data$) then
                     if len(trim$(InputData$(FilterValSubs(Index)))) and fnIsnumber(trim$(InputData$(FilterValSubs(Index)))) then
                        if dc_Data(FilterSubs(Index)-udim(mat Dc_Data$))<val(InputData$(FilterValSubs(Index))) then
                           ! It passes this filter
                           let Passing=1
                        else
                           ! Failed numeric filter test
                        end if
                     else
                        let Passing=1
                     end if
                  else
                     if len(trim$(InputData$(FilterValSubs(Index)))) then
                        if dc_Data$(FilterSubs(Index))<InputData$(FilterValSubs(Index)) then
                           ! It passes this filter
                           let Passing=1
                        else
                           ! Failed numeric filter test
                        end if
                     else
                        let Passing=1
                     end if
                  end if
               end if
               if pos(FilterCompare$(Index),"=") then
                  if FilterSubs(Index)>udim(Mat dc_Data$) then
                     if len(trim$(InputData$(FilterValSubs(Index)))) and fnIsnumber(trim$(InputData$(FilterValSubs(Index)))) then
                        if dc_Data(FilterSubs(Index)-udim(mat Dc_Data$))=val(InputData$(FilterValSubs(Index))) then
                           ! It passes this filter
                           let Passing=1
                        else
                           ! Failed numeric filter test
                        end if
                     else
                        let Passing=1
                     end if
                  else
                     if len(trim$(InputData$(FilterValSubs(Index)))) then
                        if trim$(dc_Data$(FilterSubs(Index)))=trim$(InputData$(FilterValSubs(Index))) then
                           ! It passes this filter
                           let Passing=1
                        else
                           ! Failed numeric filter test
                        end if
                     else
                        let Passing=1
                     end if
                  end if
               end if
            end if
         end if
      loop while Passing

      ! Index will be the one it failed on if it failed
      if ~Passing then ! Check filter key and return action
         if FilterKey(Index)=1 then
            let Passing=Index*-1
         else if FilterKey(Index)=-1 then
            let Passing=2
         end if
      end if

      let fnPassesFilter=Passing
   fnend

   dim GridSpec$*60
   dim OutputSpec$(1)*60
   dim OutputData$(1)
   dim InputSpec$(1)*60
   dim InputData$(1)*255
   dim Widths(1)
   dim Description$(1)*255
   dim ColumnNames$(1)*255

   dim FilterSubs(1)
   dim FilterValSubs(1)

   dim IncludeColumns$(1)*50
   dim Includebuttons$(1)
   dim FieldPositions(1)

   dim LastRec$*255
   dim DisplayFieldConvert$*255

   def fnGetDateWidth(in_fmt$;___,DateWidth)
      let DateWidth=len(fnDoubleDateDigits$(in_fmt$))
      if ~DateWidth then let DateWidth=8 ! Default to a reasonable width
      let fnGetDateWidth=DateWidth
   fnend

   !--------------------------------------------------
   ! the purpose of this function is to return a date format where each symbol is doubled up,
   ! example: accepts mdy, returns mmddyy
   ! example: accepts cy/m/d, returns CCYY/MM/DD
   ! this function is useful when calcualting the width of a column for displaying on a listview
   ! because it's easy to find the width by taking LEN('MM/DD/CCYY')
   def fndoubledatedigits$ (in_fmt$;___,out_fmt$,delimiter$)
      in_fmt$ = uprc$(trim$(in_fmt$))
      for index_=1 to len(in_fmt$)
         delimiterpos = pos('.-/, ',in_fmt$(index_:index_))
         if delimiterpos then
            delimiter$ = in_fmt$(index_:index_)
         end if
      next index_
      out_fmt$ = srep$(srep$(srep$(srep$(srep$(in_fmt$,'.','') ,'-',''),'/',''),',',''),' ','')
      if out_fmt$='MDY' or out_fmt$='MMDDYY' then
         if delimiter$<>'' then
            out_fmt$='MM'&delimiter$&'DD'&delimiter$&'YY'
         else
            out_fmt$='MMDDYY'
         end if
      else if out_fmt$='MCY' or out_fmt$='MMCCYY' then
         if delimiter$<>'' then
            out_fmt$='MM'&delimiter$&'CCYY'
         else
            out_fmt$='MMCCYY'
         end if
      else if out_fmt$='MDCY' or out_fmt$='MMDDCCYY' then
         if delimiter$<>'' then
            out_fmt$='MM'&delimiter$&'DD'&delimiter$&'CCYY'
         else
            out_fmt$='MMDDCCYY'
         end if
      else if out_fmt$='DMCY' or out_fmt$='DDMMCCYY' then
         if delimiter$<>'' then
            out_fmt$='DD'&delimiter$&'MM'&delimiter$&'CCYY'
         else
            out_fmt$='DDMMCCYY'
         end if
      else if out_fmt$='CYMD' or out_fmt$='CCYYMMDD' then
         if delimiter$<>'' then
            out_fmt$='CCYY'&delimiter$&'MM'&delimiter$&'DD'
         else
            out_fmt$='CCYYMMDD'
         end if
      else
         out_fmt$='' ! explicitly clear if format not recognized
      end if
      fndoubledatedigits$ = out_fmt$
   fnend
   !--------------------------------------------------
   def library fnShowData(FileLay$*128;Edit,sRow,sCol,Rows,Cols,KeyNumber,Caption$*127,Path$*255,KeyMatch$*255,SearchMatch$*255,CallingProgram$*255,mat Records,mat IncludeCols$,mat IncludeUI$,mat ColumnDescription$,mat ColumnWidths,mat ColumnForms$,DisplayField$*80,mat FilterFields$,mat FilterForm$,mat FilterCompare$,mat FilterCaption$,mat FilterDefaults$,mat FilterKey,IncludeRecordNumbers,BypassDateProcessing,___,Window,Index,X$,Key,Key$,Rowcount,Shouldsave,Saveindex,Saveloop,Saverecordsub,Recordsize,Deleteindex,Rebuildcolor,Changedrowcount,Oldchangeddatasize,Oldchangedsubssize,Somethingfound,Logging,Animate,InputFlag,Sub,IncludeCol,TestConvert,RecordNum,o_position,DisplaySub,SearchSub,AlreadyWarned,MergeIndex,MergeFound,MergeFromStart,MergeFromEnd,MergeToStart,MergeToEnd)
      library : Fngetfilenumber, fnOpenFile, fnCloseFile, fnreadlayoutarrays, fnbuildKey$, fnSetLogChanges, fnLogChanges, fnLog, fnLogArray, fnProgressBar, fnCloseBar, fnSelectDataCrawlerCols
      mat FilterSubs(0)
      mat FilterValSubs(0)

      if CallingProgram$="" then let CallingProgram$="FileIO's fnShowData"
      let Logging=fnSettings("createlogfile")

      if Logging then
         if Edit then
            let fnLog("Edit "&trim$(FileLay$)&" file.",CallingProgram$)
         else
            let fnLog("View "&trim$(FileLay$)&" file.",CallingProgram$)
         end if
      end if

      ! Make copies of any optional arrays we need to change
      ! in case they aren't given and we can't change the original
      mat IncludeColumns$(udim(mat IncludeCols$))=IncludeCols$
      mat Includebuttons$(udim(mat IncludeUI$))=IncludeUI$
      let SearchNow$=""

      if ~keynumber then KeyNumber=-1 ! Default to Relative for preformance
      if Edit and ~fn42 then let KeyNumber=1 ! Must open keyed due to bug in 4.1 and earlier

      let Datafile=Fnopen(Filelay$,Mat dc_Data$,Mat dc_Data,Mat Dc_Forms$,(~Edit),KeyNumber,0,path$,Mat dc_Dfdescr$,Mat dc_Widths,0,0,0,mat dc_dateformats$)

      if datafile then

         ! Return field names to be used later when populating grid
         let fngetfieldnames(Filelay$,mat ColumnNames$,mat FieldPositions)

         let fnLwrcThis(mat IncludeColumns$)
         let fnLwrcthis(mat IncludeCols$)
         let fnLwrcThis(mat ColumnNames$)

         let fnPrepareWindow(sRow,sCol,Rows,Cols,Edit,mat Includebuttons$,Caption$,GridSpec$,mat Inputspec$,mat OutputSpec$,mat Inputdata$,mat OutputData$,o_Position,mat FilterFields$,mat FilterForm$,mat FilterCompare$,mat FilterCaption$,mat FilterDefaults$,mat FilterSubs,mat FilterValSubs,mat ColumnNames$,mat FilterKey,SearchSub)

         open #(Window:=Fngetfilenumber) : "sRow="&str$(srow)&",sCol="&str$(scol)&",Rows="&str$(rows)&",Cols="&str$(cols)&",Caption="&Caption$,display,outin

         print #Window, fields mat OutputSpec$ : mat OutputData$

         let datedisplayformat$ = fnSettings$("dateformatdisplay")

         do  ! Whole Thing

            let LastRec$=DisplayField$
            if len(DisplayField$) then
               if lwrc$(displayfield$)="rec" then
                  let LastRec$=str$(lrec(DataFile))
                  let DisplaySub=-1
               else if lwrc$(displayfield$)="count" or lwrc$(displayfield$)="readcount" then
                  let LastRec$=str$(lrec(DataFile))
                  let DisplaySub=-2
               else if lwrc$(displayfield$)="findcount" then
                  let DisplaySub=-3
               else
                  if (sub:=srch(mat ColumnNames$,lwrc$(trim$(displayfield$))))>0 then
                     let DisplaySub=Sub
                  end if
               end if
            end if

            let Fncalculatefieldforms(Filelay$,mat ColumnNames$,Mat Fieldforms$,mat Widths,mat Description$,Mat dc_Widths,Mat dc_Dfdescr$,mat dc_dateformats$,mat IncludeColumns$,mat IncludeCols$,mat ColumnDescription$,mat ColumnWidths,mat ColumnForms$,mat FieldPositions,o_position,DisplaySub,DisplayFieldConvert$,datedisplayformat$,BypassDateProcessing)

            if DisplaySub>0 then

               read #datafile, using dc_forms$(Datafile), last : mat dc_data$, mat dc_data error Ignore

               if file(datafile)=0 then

                  if DisplaySub>udim(mat dc_data$) then
                     if DisplaySub<=udim(mat dc_Data$)+udim(mat dc_Data) then
                        if ~len(DisplayFieldConvert$) then
                           let LastRec$=str$(dc_data(DisplaySub-udim(mat dc_data$)))
                        else
                           let LastRec$=cnvrt$(DisplayFieldConvert$,dc_data(DisplaySub-udim(mat dc_data$))) conv Ignore
                        end if
                     end if
                  else
                     let LastRec$=dc_data$(DisplaySub)
                  end if
               end if
            end if

            If IncludeRecordNumbers then
               mat Widths(udim(mat Widths)+1)
               mat Description$(udim(mat Description$)+1)
               mat FieldForms$(udim(mat FieldForms$)+1)
               for Index=udim(mat Widths) to 2 step -1
                  let Widths(Index)=Widths(Index-1)
                  let Description$(Index)=Description$(Index-1)
                  let FieldForms$(Index)=FieldForms$(Index-1)
               next Index
               let Widths(1)=5
               let Description$(1)="Rec"
               let FieldForms$(1)="N 16"
            end if

            let Recordsize=Udim(Mat Widths)
            let ColsChanged=0
            mat dc_Blank$(Recordsize)
            print #Window, fields GridSpec$&",HEADERS,/W:W" : (Mat Description$,Mat Widths,Mat Fieldforms$)

            let Changedrowcount=0 : mat dc_Changeddata$(0) : mat dc_Changedsubs(0)

            restore #datafile:
            if kln(datafile)>0 and trim$(Key$)<>"" then
               restore #datafile, search>=Trim$(Key$): nokey ClearKey
            end if
            if RecordNum then
               restore #datafile, rec=RecordNum: norec ClearRec
            end if

            let SomethingFound=fnPopulateGrid(Window,GridSpec$,FileLay$,KeyMatch$,SearchMatch$,mat Records,mat IncludeColumns$,mat ColumnNames$,RecordSize,Datafile,mat Dc_Data$,mat Dc_Data,mat dc_forms$,SearchNow$,mat Dc_Records,mat dc_DeleteRow,KeyNumber,LastRec$,DisplaySub,DisplayFieldConvert$,mat FilterCompare$,mat FilterSubs,mat FilterValSubs,mat FilterKey,mat InputData$,IncludeRecordNumbers,mat dc_dateformats$,datedisplayformat$,BypassDateProcessing)
            let AlreadyWarned=0

            print #Window, fields mat InputSpec$(1:udim(mat InputSpec$)-1) : mat InputData$

            do  ! Input Data
               if RebuildColor then gosub UPDATECOLORS
               if Somethingfound then
                  if udim(mat InputData$) then
                     input #Window, fields mat InputSpec$ : mat InputData$, Rowcount
                  else
                     input #Window, fields mat InputSpec$ : Rowcount
                  end if
                  let Key=Fkey
                  if Key=54 then let Key=99
               else
                  if Edit and (2==Msgbox("There is no data in the file, or no records match the current search criteria. Would you like to add a row?","File Empty","YN","EXCL")) then
                     let Key=15 ! Add A Row
                     let Somethingfound=1
                  else
                     if ~AlreadyWarned then let MsgBox("Data File is Empty or no records match the current search criteria.","File Empty") : AlreadyWarned=1
                     if udim(mat InputData$) then
                        input #Window, fields mat InputSpec$(1:udim(mat InputSpec$)-1) : mat InputData$
                        let Key=Fkey
                        if Key=54 then let Key=99
                     else
                        let Key=99
                     end if
                  end if
               end if
               let Shouldsave=0

               #Select# Key #Case# 15 and Edit
                  gosub MergeNewChanges   ! Get any additional changes since the last time

                  print #Window, fields GridSpec$&",+" : Mat dc_Blank$ ! Add A Blank Row
                  mat dc_Records(Udim(Mat dc_Records)+1)
                  mat dc_Deleterow(Udim(Mat dc_Records))
                  let Curfld(1,((Udim(Mat dc_Records)-1)*Recordsize) + 1)

               #Case# 16 and Edit
                  let dc_Deleterow(Currow)=dc_Deleterow(Currow)+1 ! Toggle Deleted
                  let Rebuildcolor = 1

               #Case# 55
                  if Changedrowcount Or (Edit and Rowcount) or Sum(Mat dc_Deleterow) then NeedsSave=1 else NeedsSave=0
                  let ColsChanged=fnSelectDataCrawlerCols(mat dc_Dfdescr$,mat IncludeColumns$,mat ColumnNames$,rows,cols,NeedsSave,0,FileLay$)
                  if ColsChanged = 2 then ShouldSave = 2

               #Case# 56
                  let fnCSV_Export(FileLay$,Keynumber,Key$,RecordNum,mat Records,SearchMatch$,KeyMatch$,SearchNow$)
               #Case# 57 and Edit
                  let fnCSV_Import(FileLay$)

               #Case# 4 # 99 # 93 # 70
                  if Edit and (Changedrowcount Or Rowcount Or Sum(Mat dc_Deleterow)) then
                     let Shouldsave=Msgbox("All unsaved changes will be lost. Do you want to Save first?","Search Warning","YNC","EXCL")
                  end if
               #End Select#
            loop Until ((Key=99 or Key=93 Or Key=4 or Key=70) And Shouldsave<>4) Or Key=5 or Key=57 or (Key=55 And ColsChanged) ! F4 Changes Settings, F5 Saves Settings, 70 is Search, needs to redraw

            if Edit and (Key=5 Or Shouldsave=2) then gosub SaveChangedData

            if Key=4 then let Fninputkey(Key$,RecordNum,datafile,rows,cols,Window)

            if key=70 then
               let SearchNow$=trim$(InputData$(SearchSub))  ! If there's a search box, its always first cause the grids always last so this should work but it would be better to use a subscript.
               ! let InputData$(SearchSub)=""
            end if

         loop Until Key=99 or Key=93 or fkey=93

         if Edit then let InputFlag=1 else let InputFlag=-1
         let fnclosefile(datafile,filelay$,path$,InputFlag)
         if Logging then let fnLog("Close "&trim$(FileLay$)&" file.",CallingProgram$)
      end if
      close #Window:
   fnend

ClearKey: ! Invalid Key Entered
   let Msgbox("Key Not Found")
   let Key$=""
   continue

ClearRec: ! Invalid Record Entered
   let Msgbox("Record not found")
   let RecordNum=0
   continue

Tryagain: ! Try Again
   if fkey=99 or fkey=93 then
      continue
   else
      retry
   end if

DECONVERSIONFAILED: ! Conversion Failed Saving Numeric Field
   let Testconvert=dc_Data(sub-udim(mat Dc_data$)) ! Keep Existing Value, New Value Failed
   continue

MergeNewChanges: ! Save new changes into the Changed Subs and Data arrays
   if Rowcount then ! If There Are Already Changes Made, Save Them To Backup Arrays
      mat dc_Savedata$(Recordsize*Rowcount) ! Make Room
      mat dc_Savesubs(Rowcount) ! Make Room
      input #Window, fields GridSpec$&",ROWSUB,CHG,NOWAIT" : Mat dc_Savesubs
      input #Window, fields GridSpec$&",ROW,CHG,NOWAIT" : Mat dc_Savedata$

      let SaveRecordSize=RecordSize-IncludeRecordNumbers

      for MergeIndex=1 to udim(mat dc_SaveSubs)
         let MergeFromStart=((MergeIndex-1)*RecordSize)+1+IncludeRecordNumbers
         let MergeFromEnd=MergeIndex*RecordSize

         let MergeFound=srch(mat dC_ChangedSubs,dc_SaveSubs(MergeIndex))
         if MergeFound>0 then
            ! Find the Data to Update
            let MergeToStart=((MergeFound-1)*SaveRecordSize)+1
            let MergeToEnd=MergeFound*SaveRecordSize
         else
            ! Add Rows to Update
            let MergeToStart=udim(mat Dc_ChangedData$)+1
            let MergeToEnd=udim(mat Dc_changedData$)+SaveRecordSize

            let MergeFound=udim(mat Dc_ChangedSubs)+1

            mat Dc_ChangedData$(MergeToend)
            mat Dc_ChangedSubs(MergeFound)
         end if

         ! Merge It
         mat dc_ChangedData$(MergeToStart:MergeToEnd)=dc_SaveData$(MergeFromStart:MergeFromEnd)
         let dc_ChangedSubs(MergeFound)=dc_SaveSubs(MergeIndex)
      next MergeIndex

      let Changedrowcount=Udim(Mat dc_Changedsubs)
   end if
return

dim SaveMessage$*255,UpdateCount,AddCount,DeleteCount
SaveChangedData: ! Save all the changed records in the data crawler
   let SaveMessage$="" : let UpdateCount=0 : let AddCount=0 : let DeleteCount=0

   gosub MergeNewChanges   ! Get any additional changes since the last time
   let SaveRecordSize=RecordSize-IncludeRecordNumbers

   if (~fnIsEmptys(mat IncludeColumns$)) then let IncludeCol=1
   ! Save Prerecorded Changes
   for Saveloop = 1 to Changedrowcount
      let Saverecordsub=((Saveloop-1)*SaveRecordSize)
      if dc_Deleterow(dc_Changedsubs(Saveloop))=0 then ! Skip It If Its Deleted
         mat dc_Data$=("") : mat Dc_Data=(0)
         if dc_Records(dc_Changedsubs(Saveloop)) then
            read #datafile, using Dc_Forms$(datafile), rec=dc_Records(dc_Changedsubs(Saveloop)) : Mat dc_Data$, Mat dc_Data
            if Logging then let fnSetLogChanges(mat dc_Data$,mat dc_Data)
         end if

!        Convert Strings Back To Numbers And Assign Back To File Arrays
         for SaveIndex=1 to SaveRecordSize
            if IncludeCol then
               let Sub=srch(mat ColumnNames$,IncludeColumns$(SaveIndex))
            else
               let Sub=SaveIndex
            end if
            if Sub>udim(mat dc_data$) then
               let TestConvert=val(fnfmtsdate$(dc_ChangedData$(SaveRecordSub+saveindex),"DATE(JULIAN)",dc_dateformats$(sub),BypassDateProcessing)) conv DeConversionFailed
               let dc_data(sub-udim(mat Dc_data$))=TestConvert
            else if Sub>0 then
               let dc_data$(sub)=fnfmtsdate$(dc_ChangedData$(SaveRecordSub+SaveIndex),"DATE(JULIAN)",dc_dateformats$(Sub),BypassDateProcessing)
            end if
         next SaveIndex

!        Save The Data
         if dc_Records(dc_Changedsubs(Saveloop)) then
            rewrite #datafile, using Dc_Forms$(datafile) : Mat dc_Data$, Mat dc_Data
            if Logging then let fnLogChanges(mat dc_Data$,mat dc_Data,"Update """&FileLay$&""" Record: "&str$(rec(datafile)),CallingProgram$,FileLay$)
            let UpdateCount+=1
         else
            write #datafile, using Dc_Forms$(datafile) : Mat dc_Data$, Mat dc_Data
            if Logging then let fnLogArray(Mat dc_Data$,mat dc_Data,"Write """&FileLay$&""" Record: "&str$(rec(datafile))&" Data: ",CallingProgram$)
            let AddCount+=1
         end if
      end if
   next Saveloop

   ! Delete the records that need to be deleted
   for Deleteindex=1 to Udim(Mat dc_Deleterow)
      if dc_Deleterow(Deleteindex) then
         if dc_Records(Deleteindex) then
            delete #datafile, rec=dc_Records(Deleteindex):
            if Logging then let fnLog("Delete """&FileLay$&""" Record: "&str$(dc_Records(Deleteindex)),CallingProgram$)
            let DeleteCount+=1
         end if
         let dc_Deleterow(Deleteindex)=2 ! Clear Them To White Next Round
      end if
   next Deleteindex
   if Edit then gosub UPDATECOLORS
   let Crlf$=Hex$("0D0A")
   let Msgbox("Update Complete!"&Crlf$&Crlf$&str$(AddCount)&" records Added"&Crlf$&str$(UpdateCount)&" records Updated"&Crlf$&str$(DeleteCount)&" records Deleted","Update")
return

!  Save New Changes
!   mat dc_Savedata$(Recordsize*Rowcount) ! Make Room
!   mat dc_Savesubs(Rowcount)             ! Make Room
!   input #Window, fields GridSpec$&",ROWSUB,CHG,NOWAIT" : Mat dc_Savesubs
!   input #Window, fields GridSpec$&",ROW,CHG,NOWAIT" : Mat dc_Savedata$

!  One Record At A Time
!   for Saveloop = 1 to Rowcount
!      let Saverecordsub=((Saveloop-1)*Recordsize)
!      if dc_Deleterow(dc_Savesubs(Saveloop))=0 then ! Skip It If Its Deleted
!         mat dc_Data$=("") : mat Dc_Data=(0)
!         if dc_Records(dc_Savesubs(Saveloop)) then
!            read #datafile, using Dc_Forms$(datafile), rec=dc_Records(dc_Savesubs(Saveloop)) : Mat dc_Data$, Mat dc_Data
!            if Logging then let fnSetLogChanges(mat dc_Data$,mat dc_Data)
!         end if

!         for SaveIndex=1 to RecordSize
!            if IncludeCol then
!               let Sub=srch(mat ColumnNames$,IncludeColumns$(SaveIndex))
!            else
!               let Sub=SaveIndex
!            end if

!            if Sub>udim(mat dc_data$) then
!               let TestConvert=val(dc_Savedata$(SaveRecordSub+saveindex)) conv DeConversionFailed
!               let dc_data(sub-udim(mat Dc_data$))=TestConvert
!            else if Sub>0 then
!               let dc_data$(sub)=dc_Savedata$(SaveRecordSub+SaveIndex)
!            end if
!         next SaveIndex

!        Save The Data
!         if dc_Records(dc_Savesubs(Saveloop)) then
!            rewrite #datafile, using Dc_Forms$(datafile) : Mat dc_Data$, Mat dc_Data
!            if Logging then let fnLogChanges(mat dc_Data$,mat dc_Data,"Update """&FileLay$&""" Record: "&str$(rec(datafile)),CallingProgram$,FileLay$)
!         else
!            write #datafile, using Dc_Forms$(datafile) : Mat dc_Data$, Mat dc_Data
!            if Logging then let fnLogArray(Mat dc_Data$,mat dc_Data,"Write """&FileLay$&""" Record: "&str$(rec(datafile))&" Data: ",CallingProgram$)
!         end if
!      end if
!   next Saveloop


SELECTDATACRAWLERCOLS: ! **** Open Window to Select Display Columns for Data Crawler ****
   def library fnselectdatacrawlercols(mat Field_Desc$,mat IncludeColumns$,mat ColumnNames$,Rows,Cols;NeedsSave,Export,FileLay$*128,___,Verb$,sRow,sCol,ScreenRows,ScreenCols,Row,Col,fK,CloseWindow,ShouldSave,ItemsPerpage,Index,Jndex,ColumnsNotPassed)
      library : fnGetFileNumber

      dim Input_Spec$(1)*255,Input_Data$(1)*1000
      if Export then let Verb$="export" else let Verb$="display"

      let fnReadScreenS(ScreenRows,ScreenCols)

      ! Grow to minimum reasonable size
      let rows=max(rows,8)
      let cols=max(cols,48)

      let rows=min(ScreenRows,Rows)
      let cols=min(ScreenCols,Cols)

      mat Input_Spec$(UDim(mat Field_Desc$))
      mat Input_Data$(UDim(mat Field_Desc$))

      ! Open main window
      let SRow=Int((ScreenRows-Rows) / 2) + 1
      let SCol=Int((ScreenCols-Cols) / 2) + 1

      open #(ColSel_Window:=Fngetfilenumber): "SROW="&Str$(SRow)&", SCOL="&Str$(SCol)&", ROWS="&str$(rows)&", COLS="&str$(cols),display,outin
      if export then
         print #ColSel_Window, fields str$(rows)&","&str$(cols-10)&",CC 10,/W:W,B55" : "OK"
      else
         print #ColSel_Window, fields str$(rows)&","&str$(cols-22)&",CC 10,/W:W,B55" : "OK"
         print #ColSel_Window, fields str$(rows)&","&str$(cols-10)&",CC 10,/W:W,B54" : "Cancel"
      end if
      print #ColSel_Window, fields str$(rows)&","&str$(cols-34)&",CC 10,/W:W,B56" : "Select All"
      print #ColSel_Window, fields str$(rows)&","&str$(cols-46)&",10/CC 11,/W:W,B57" : "Select None"
      if cols>60 then
         print #ColSel_Window, fields str$(rows)&",2,"&str$(cols-49)&"/C 55" : "Choose data columns to "&Verb$
      end if

      dim ColSel_Tabs(1)
      dim TabAttr$*50

      if fnIsEmptyS(mat IncludeColumns$) and len(FileLay$) then
         let ColumnsNotPassed=1
         let fnReadLastColumnsUsed(mat IncludeColumns$,FileLay$)
      end if

      let ItemsPerpage=(rows-4)*int(Cols/19)

      let Row = 2
      let Col = 2
      let ThisTab = 0
      For Index = 1 To UDim(mat Input_Spec$)
         If Row = 2 And Col = 2 Then  ! Open a child window
            let ThisTab+=1
            mat ColSel_Tabs(ThisTab)
            if UDim(mat Input_Spec$) > ItemsPerpage then TabAttr$=", TAB=Page "&Str$(ThisTab) else TabAttr$=", BORDER=S, CAPTION=Column List"
            open #(ColSel_Tabs(ThisTab):=Fngetfilenumber): "SROW=2, SCOL=2, ROWS="&str$(rows-3)&", COLS="&str$(cols-2)&TabAttr$&", PARENT="&Str$(ColSel_Window),display,outin
         End If

         let Input_Spec$(Index)=Str$(Row)&","&Str$(Col)&",18/check 1000,,"&str$(1500+Index)
         let Input_Data$(Index)=Field_Desc$(Mod(Index-1,UDim(mat Field_Desc$))+1)

         if fnIsEmptys(mat IncludeColumns$) or srch(mat IncludeColumns$,ColumnNames$(Index))>0 then
            let Input_Data$(Index) = "^"&Input_Data$(Index)
         end if

         let Row+=1
         If Row > Rows-3 And Col+18+19 > Cols Then
            let Row = 2
            let Col = 2
         Else If Row > Rows-3 Then
            let Col +=19
            let Row = 2
         End If
      Next Index

      do
         do
            let ThisTab = CURTAB(ColSel_Tabs(1))
            For TabIndex = 1 To UDim(ColSel_Tabs)
               If ColSel_Tabs(TabIndex) = ThisTab Then CurrentTabIndex=TabIndex
            Next TabIndex
            let StartCol = 1 + (CurrentTabIndex - 1) * ItemsPerpage
            let EndCol = Min(CurrentTabIndex * ItemsPerpage, UDim(Input_Spec$))
            rinput #ThisTab, fields mat Input_Spec$(StartCol:EndCol) : mat Input_Data$(StartCol:EndCol)
            let fK=fkey

            if fK=56 then ! Select All
               for Index=1 to udim(mat Input_Data$)
                  let Input_Data$(Index)=trim$(Input_Data$(Index))
                  if Input_Data$(Index)(1:1)<>"^" then
                     let Input_Data$(Index)(999:1000)=""
                     let Input_Data$(Index)(1:0)="^"
                  end if
               next Index
            else if fK=57 then ! Select None
               for Index=1 to udim(mat Input_Data$)
                  if Input_Data$(Index)(1:1)="^" then
                     let Input_Data$(Index)(1:1)=""
                  end if
               next Index
            end if
         loop Until fK=0 or fK=99 or fK=93 or fK=54 or fK=55 ! 0,55: OK; 99,93,54: Cancel

         let CloseWindow=1
         if fK=0 or fK=55 then
            if NeedsSave then
               let Shouldsave=Msgbox("All unsaved changes will be lost. Do you want to Save first?","Search Warning","YNC","EXCL")
               if ShouldSave=2 then fnSelectDataCrawlerCols=2
               if ShouldSave=3 then fnSelectDataCrawlerCols=1
               if ShouldSave=4 then CloseWindow=0
            else
               let fnSelectDataCrawlerCols=1
            end if
            if CloseWindow then
               mat IncludeColumns$(0)
               for Index = 1 To UDim(Input_Data$)
                  if Input_Data$(Index)(1:1)="^" then
                     let Jndex=udim(mat IncludeColumns$)+1
                     mat IncludeColumns$(Jndex)
                     let IncludeColumns$(Jndex)=ColumnNames$(Index)
                  end if
               next Index
               if udim(mat IncludeColumns$)=udim(mat Input_Data$) then
                  mat IncludeColumns$(0)
               end if
            end if
         else
            let fnselectdatacrawlercols=0
         end if
      loop Until CloseWindow

      For ThisTab = 1 To UDim(ColSel_Tabs)
         close #(ColSel_Tabs(ThisTab)):
      Next ThisTab

      close #ColSel_Window:

      if ColumnsNotPassed then
         let fnSaveLastColumnsUsed(mat IncludeColumns$,FileLay$)
      end if

   fnend

def fnReadLastColumnsUsed(mat IncludeColumns$,FileLay$*64;___,SaveSelectedCols$*64,FileName$*68,KeyFile$*68,ColsFile,NumOfCols)
   let SaveSelectedCols$=fnSettings$("saveselectedcols")
   let FileName$=SaveSelectedCols$&".dat"
   let KeyFile$=SaveSelectedCols$&".key"

   if exists(FileName$) and exists(KeyFile$) then
      open #(ColsFile:=fnGetFileNumber): "name="&FileName$&", kfname="&KeyFile$&", recl=10000, kps=1, kln=18, use",internal, outin, keyed
      read #ColsFile, key=rpad$(FileLay$(1:18),18) : FileLay$,NumOfCols nokey RLCU_Failed
      mat IncludeColumns$(NumOfCols)
      reread #ColsFile : FileLay$, NumOfCols, mat IncludeColumns$

   end if

   RLCU_Failed: ! Jump here if can't find the record
   if (ColsFile) and file(ColsFile)><-1 then close #ColsFile: : let ColsFile=0
fnend

def fnSaveLastColumnsUsed(mat IncludeColumns$,FileLay$*64;___,SaveSelectedCols$*64,FileName$*68,KeyFile$*68,ColsFile,NumOfCols)
   let SaveSelectedCols$=fnSettings$("saveselectedcols")
   let FileName$=SaveSelectedCols$&".dat"
   let KeyFile$=SaveSelectedCols$&".key"
   open #(ColsFile:=fnGetFileNumber): "name="&FileName$&", kfname="&KeyFile$&", recl=10000, kps=1, kln=18, use",internal, outin, keyed

   read #ColsFile, key=rpad$(FileLay$(1:18),18) : nokey Ignore
   if file(ColsFile)=0 then
      rewrite #ColsFile : FileLay$(1:18), udim(mat IncludeColumns$), mat IncludeColumns$
   else
      write #ColsFile : FileLay$(1:18), udim(mat IncludeColumns$), mat IncludeColumns$
   end if

   close #ColsFile:
fnend

def library fnCsvImport(Layout$*64;SupressDialog,FileName$*300,ImportModeKey,___,OkToRun)
   if SupressDialog then
      if trim$(Filename$)><"" and exists(trim$(FileName$)) then
         let OkToRun=1
      else
         if trim$(FileName$)="" then
            let msgbox("The output file name was not given.","File Not Passed","Ok","ERR")
         else
            let msgbox("File ("&trim$(Filename$)&") could not be found.","File not Found","Ok","ERR")
         end if
      end if
   else
      if fnCSVImportDlg(Layout$,Filename$,ImportModeKey) then
         let OkToRun=1
      end if
   end if

   if OkToRun then
      let fnImportFromCSV(Layout$,Filename$,ImportModeKey)
   end if
fnend

def fnExportSelectedFiles(Mat Sel,mat Files$;___,CSVExportPath$*255,CSVExportIndex,GlobalProgressBar,Rows,Cols,SRow,Scol,Size,Percent,ToSpot)

   ! Input Path
   library : fnClientServer, fnCsvExport

   if Fnclientserver then
      let CSVExportPath$="@:Folders"
   else
      let CSVExportPath$="Folders"
   end if
   OPEN #(CSVFile:=fngetfilenumber): "name=SAVE:"&CSVExportPath$&",recl=32000,replace",DISPLAY,OUTPUT IOERR IGNORE
   if File(CSVFile) = 0 then
      let CSVExportPath$=File$(CSVFile)
      close #CSVFile:

      ! Delete the temp file we made with the file select dialog and make the folder
      execute "*free """&CSVExportPath$&""""
      execute "*mkdir """&CSVExportPath$&""""

      if udim(mat Sel)>1 then
                     ! First, Detect Size and Position.
         let fnReadScreenS(Rows,Cols)
         let Size=int(Cols*.6666)    ! 78 Size should be .666*ScreenWidth
         let SRow=int(Rows*0.75)           ! Row should be near the bottom of the window
         let SCol=min(Rows-4,int((Cols-Size)/2)) ! 2  SCol should be int(ScreenWidth-Size/2)

         open #(GlobalProgressBar:=fnGetFileNumber): "SRow="&str$(SRow)&",SCol="&str$(SCol)&",Rows=2,Cols="&str$(Size)&",Caption=Overall Progress,Border=S",display,outin
      end if

      ! Loop through all files and call fnCSVExport
      for CSVExportIndex=1 to udim(mat Sel)
         ! let fnUpdateProgressBar(CSVExportIndex/udim(mat Sel),"",0,0,0,"Exporting Datafiles",Files$(Sel(CSVExportIndex)))
         ! let fnUpdateProgressBar(CSVExportIndex/udim(mat Sel),"",0,0,0,"Exporting Datafiles",os_filename$(CSVExportPath$&"\"&Files$(Sel(CSVExportIndex))&".csv"))

         if GlobalProgressBar then
            let ToSpot=Min(Int((CSVExportIndex/udim(mat Sel))*Size),Size)
            print #GlobalProgressBar, fields "1,1,"&str$(ToSpot)&"/C 1,S/W:"&pb_Color$&";2,1,CC "&str$(Size) : "","Current File: "&Files$(Sel(CSVExportIndex))&" ("&str$(CSVExportIndex)&"/"&str$(udim(mat Sel))&")"
         end if

         ! Export that file to CSV
         let fnCSVExport(Files$(Sel(CSVExportIndex)),1,CSVExportPath$&"\"&Files$(Sel(CSVExportIndex))&".csv",1,-1)

      next CSVExportIndex
      ! let fnCloseProgressBar
      let msgbox("Export Complete!","Success","Ok","EXCL")
      if GlobalProgressBar then
         close #GlobalProgressBar:
      end if
   else
      /* print `Opening File:
      Code: {{File(CSVFile)}}
      Name: {{File$(CSVFile)}}`
      pause */
   end if
fnend

   ! Dialog Type:
   !  0 - Legacy, Regular Dialog
   !  1 - Suppress Dialog
   !  2 - Full Dialog: Ask Which Columns to use.
   !  3 - Ask which columns only.

def library fnCsvExport(Layout$*64;DialogType,Filename$*300,IncludeRecNums,KeyNumber,StartKey$,KeyMatch$,Startrec,mat Records,SearchMatch$,Launch,___,SearchNow$,OkToRun)
   library : fnReadLayoutHeader,fnReadLayoutArrays,fnOpenFile, fnGetFileNumber
   if DialogType=1 or DialogType=3 then
      if trim$(Filename$)><"" then
         let OkToRun=1
      else
         ! Randomly Generate the file name now when its not given and dialog is skipped.
         let FileName$=fnGenerateFileName$("@:csvexpt","csv")
         let OkToRun=1
      end if
   else
      if fnCsvExportDlg(Filename$,IncludeRecNums,DialogType) then
         let OkToRun=1
      end if
   end if

   if OkToRun then
      let fnExportToCSV(Layout$,Filename$,IncludeRecNums,KeyNumber,StartKey$,StartRec,mat Records,SearchMatch$,KeyMatch$,SearchNow$,DialogType)
      if Launch then
         execute "sy -C -M start """" """&os_filename$(FileName$)&""""
      end if
   end if
fnend

def fnCSV_Import(Layout$*64;___,Filename$*300,UseKey)
   library : fnReadLayoutHeader,fnReadLayoutArrays,fnOpenFile, fnGetFileNumber
   if fnCSVImportDlg(Layout$,Filename$,UseKey) then
      let fnImportFromCSV(Layout$,Filename$,UseKey)
   end if
fnend

def fnCSV_Export(Layout$*64;Keynumber,&Key$,&RecordNum,mat Records,&SearchMatch$,&KeyMatch$,&SearchNow$,___,Filename$*300,IncludeRecords,DialogType)
   if fnCsvExportDlg(Filename$,IncludeRecords,DialogType) then
      let fnExportToCSV(Layout$,Filename$,IncludeRecords,KeyNumber,Key$,RecordNum,mat Records,SearchMatch$,KeyMatch$,SearchNow$,DialogType)
   end if
fnend

def fnfmtsdate$*1024 (candi_date$*1024,informat$,outformat$;BypassDateProcessing,___,fmtsdate$*1024,fmtsdate)
   if ~BypassDateProcessing and trim$(informat$)<>'' and trim$(outformat$)<>'' then
      if pos(lwrc$(informat$),"julian") or pos(lwrc$(informat$),"serial") or pos(lwrc$(informat$),"days") then
         let fmtsdate=val(candi_date$)
      else
         let fmtsdate=days(candi_date$,informat$)
      end if

      if pos(lwrc$(outformat$),"julian") or pos(lwrc$(outformat$),"serial") or pos(lwrc$(outformat$),"days") then
         let fmtsdate$=str$(fmtsdate)
      else
         let fmtsdate$ = date$(fmtsdate, outformat$)
      end if

      ! if couldn't convert or empty, then use original value
      if fmtsdate$='' then fmtsdate$ = candi_date$
   else
      let fmtsdate$ = candi_date$
   end if
   let fnfmtsdate$ = fmtsdate$
fnend

def fnfmtndate$ (candi_date,informat$,outformat$;BypassDateProcessing,___,fmtndate$*64,fmtndate)
   if ~BypassDateProcessing and trim$(informat$)<>'' and trim$(outformat$)<>'' then
      if pos(lwrc$(informat$),"julian") or pos(lwrc$(informat$),"serial") or pos(lwrc$(informat$),"days") then
         let fmtndate=candi_date
      else
         let fmtndate=days(candi_date,informat$)
      end if
      if pos(lwrc$(outformat$),"julian") or pos(lwrc$(outformat$),"serial") or pos(lwrc$(informat$),"days") then
         let fmtndate$=str$(fmtndate)
      else
         let fmtndate$ = date$(fmtndate, outformat$)
      end if

      ! if couldn't convert, then use original value
      if fmtndate$='' then fmtndate$ = str$(candi_date)
   else ! non-date numeric value
      let fmtndate$ = str$(candi_date)
   end if
   let fnfmtndate$ = fmtndate$
fnend

dim CsvFieldNames$(1)*128,CSVFieldPositions(1)
dim CsvSDateSpec$(1)*64,CsvNDateSpec$(1)*64
dim Csv_PrintStr$*2000

EXPORTTOCSV: ! **** Export a data file to CSV format
   def fnExportToCSV(Layout$*64,CSVFile$*300,UseRecNums;Keynumber,&Key$,&RecordNum,mat Records,&SearchMatch$,&KeyMatch$,&SearchNow$,DialogType,___,CSVFile,Datafile,bRecNum,ScreenRows,ScreenCols,fmtdate$,csv_numindx,DontSortSubs,SuppressPrompt)
      let Csv_PrintStr$=""  ! This is really a local variable, its dimmed to conserve Workstack Memory.

      library : fnReadLayoutHeader,fnReadLayoutArrays,fnOpenFile, fnGetFileNumber, fnSelectDataCrawlerCols

      OPEN #(CSVFile:=fngetfilenumber): "name="&CSVFile$&",recl=32000,replace",DISPLAY,OUTPUT IOERR IGNORE

      if file(CSVFile)==-1 and wbversion$<"4.32k" then ! In some versions of BR, selecting a file on the client needs the following fix.
         ! Try again to see if CSV file is really an absolute path
         if CSVFile$(1:2)="@:" and CSVFile$(4:4)=":" and pos("ABCDEFGHIJKLMNOPQRSTUVWXYZ",uprc$(CSVFile$(3:3))) then
            ! If its on the client, and if it has a Drive letter then a :, then we probably need another colon.
            let CSVFile$(1:2)="@::"
            OPEN #(CSVFile:=fngetfilenumber): "name="&CSVFile$&",recl=32000,replace",DISPLAY,OUTPUT IOERR IGNORE
         end if
      end if

      if File(CSVFile) = 0 then
         ! Print field names in first line
         let fnGetFieldNames(Layout$,mat CsvFieldNames$,mat CSVFieldPositions)

         if UseRecNums then print #CSVFile: "&RECNUM,";
         mat CSV_Data$=("") : mat CSV_Data=(0)
         let Datafile=fnOpen(Layout$,mat Csv_Data$,mat Csv_Data,mat Csv_Forms$,1,Keynumber,Dont_Sort_Subs:=0,path$:='',Mat Csv_Dfdescr$, Mat dummy,SuppressPrompt:=1,0,0,mat csv_dateformats$)
         if DataFile and file(DataFile)=0 then ! File opened successfully
            if udim(mat csv_data$)=0 then mat CsvSDateSpec$(0) else mat CsvSDateSpec$(udim(mat csv_data$))=CSV_DateFormats$(1:udim(mat csv_data$))
            if udim(mat csv_data)=0 then mat CsvNDateSpec$(0) else mat CSVNDateSpec$(udim(mat Csv_Data))=csv_DateFormats$(udim(mat Csv_Data$)+1:udim(mat CSV_DateFormats$))

            if DialogType=2 or DialogType=3 then
               let fnReadScreenS(ScreenRows,ScreenCols)

               let ColsChanged=fnSelectDataCrawlerCols(mat Csv_Dfdescr$,mat IncludeColumns$,mat CsvFieldNames$,ScreenRows,ScreenCols,0,1,Layout$)
               if not udim(mat IncludeColumns$) then
                  ! include ALL columns
                  mat IncludeColumns$(udim(mat CsvFieldNames$))= CsvFieldNames$
               end if
            else
               ! include ALL columns
               mat IncludeColumns$(udim(mat CsvFieldNames$))= CsvFieldNames$
            end if

            for FInd = 1 to UDim(IncludeColumns$)
               print #CSVFile: IncludeColumns$(FInd);
               if FInd < UDim(IncludeColumns$) then
                  print #CSVFile: ",";
               else
                  print #CSVFile:
               end if
            next FInd

            if kln(datafile)>0 and trim$(Key$)<>"" then
               restore #datafile, search>=Trim$(Key$): nokey ClearKey
            end if
            if RecordNum then
               restore #datafile, rec=RecordNum: norec ClearRec
            end if

            let bRecNum=(~fnIsEmpty(mat Records))

            let csv_dateexportformat$=fnSettings$("dateformatexport")
            do
               read #Datafile, using Csv_Forms$(Datafile), release : Mat Csv_Data$,Mat Csv_Data error Ignore

               if File(DataFile)=0 then
                  if KeyNumber<=0 and lrec(DataFile)>0 then let fnUpdateProgressBar(rec(DataFile)/lrec(DataFile),"",0,0,0,"Exporting "&Layout$,"Record: "&str$(rec(DataFile))&"/"&str$(lrec(DataFile)))
                  if ~bRecNum or srch(mat Records,rec(datafile))>0 then
                     if ~len(Keymatch$) or KeyMatch$=fnbuildKey$(Layout$,mat Csv_Data$,mat Csv_Data,Keynumber)(1:len(Keymatch$)) then
                        if ~len(SearchMatch$) or fnSearchIn(SearchMatch$,mat Csv_Data$,mat Csv_Data,mat CSVSDateSpec$,mat CSVNDateSpec$,csv_dateexportformat$) then
                           if ~len(SearchNow$) or fnSearchIn(SearchNow$,mat Csv_Data$,mat Csv_Data,mat CSVSDateSpec$,mat CSVNDateSpec$,csv_dateexportformat$) then
                              if UseRecNums then print #CSVFile: STR$(REC(Datafile))&",";
                              for FInd = 1 to UDim(CsvFieldNames$)
                                 if srch(mat IncludeColumns$,CsvFieldNames$(FInd))>0 then

                                    if FInd <= UDim(Csv_Data$) then
                                       csv_printstr$ = fnfmtsdate$ (Csv_Data$(FInd),csv_dateformats$(FInd),csv_dateexportformat$)
                                       print #CSVFile: """"&SRep$(csv_printstr$,"""","""""")&"""";
                                    else
                                       csv_numindx = FInd - UDim(Csv_Data$)
                                       if csv_dateformats$(FInd)<>'' then
                                          print #CSVFile: '"'&fnfmtndate$ (Csv_Data(csv_numindx),csv_dateformats$(FInd),csv_dateexportformat$)&'"';
                                       else ! non-date numeric value
                                          print #CSVFile: Csv_Data(csv_numindx);
                                       end if
                                    end if
                                    if FInd < UDim(CsvFieldNames$) and IncludeColumns$(udim(IncludeColumns$))<>CsvFieldNames$(FInd) then
                                       print #CSVFile: ",";
                                    else
                                       print #CSVFile:
                                    end if
                                 end if
                              next FInd
                           end if
                        end if
                     end if
                  end if
               end if
            loop until file(datafile)=10

            if KeyNumber<=0 then let fnCloseProgressBar
            close #Datafile:
         else
            if DataFile=0 then
               print #CSVFile: "Data File Not Found for layout: "&Layout$
            else
               print #CSVFile: "Error Opening Data File for layout: "&Layout$
               if file(DataFile)><-1 then
                  close #DataFile:
               end if
            end if
         end if
         close #CSVFile:

         if DialogType><1 and DialogType><3 then let MsgBox("Export complete!")
      else
         MsgBox("Error: could not open output file!")
      end if
   fnend
!
   def library Fnclientserver(;___,Serverfolder$*255,Clientfolder$*255)
       if wbversion$(1:3)>="4.3" then
          if lwrc$(trim$(env$("br_model")))="client/server" then
             let fnClientServer=1
          else
             let fnClientServer=0
          end if
       else
          let Serverfolder$=Os_Filename$(".")
          let Clientfolder$=Os_Filename$("@:.")
          if Clientfolder$(Len(Clientfolder$):Len(Clientfolder$))<>"\" then
             let Clientfolder$=Clientfolder$&"\"
          end if
          if Serverfolder$(Len(Serverfolder$):Len(Serverfolder$))<>"\" then
             let Serverfolder$=Serverfolder$&"\"
          end if
          if Lwrc$(Trim$(Serverfolder$))=Lwrc$(Trim$(Clientfolder$)) then
             let Fnclientserver=0
          else
             let Fnclientserver=1
          end if
       end if
   fnend

def fnCSVExportDlg(&CSVPath$,&UseRecNums;&DialogType,___,Dialog,KeyP,CSVFile,UseRecNums$*50,SelectColumns$*50,FileString$*255,Rows,Cols)
    library : fnReadLayoutHeader,fnClientServer

    dim Keys$(1)*80,KeyDesc$(1)*80,SrcFieldNames$(1)*80
    let fnReadScreenS(Rows,Cols)

    OPEN #(Dialog:=fnGetFileNumber) : "SROW="&STR$(INT((Rows - 7) / 2))&",SCOL="&STR$(INT((Cols - 30) / 2))&",ROWS=7,COLS=30,CAPTION=Export to CSV,BORDER=S",display,outin
    PRINT #Dialog, fields "1,1,C 20;2,22,CC 8,/W:W,B62" : "CSV Data File","Browse"
    PRINT #Dialog, fields "7,12,CC 8,/W:W,B61" : "Export!"
    PRINT #Dialog, fields "7,22,CC 8,/W:W,B60" : "Cancel"
    if fnClientServer then
       let FileString$="@:CSV files (*.csv) |*.csv"
    else
       let FileString$="CSV files (*.csv) |*.csv"
    end if

    if len(trim$(CSVPath$)) then
       open #(CSVFile:=fnGetFileNumber): "name="&CSVPath$&",recl=32000,new",display,output,error Ignore
       if file(CSVFile)=0 then
          ! Path is good
       else
          if file(CSVFile)<>-1 then close #CSVFile:
          OPEN #(CSVFile:=fngetfilenumber): "name=SAVE:"&CSVPath$&",recl=32000,replace",DISPLAY,OUTPUT IOERR IGNORE
       end if
    else
       OPEN #(CSVFile:=fngetfilenumber): "name=SAVE:"&FileString$&",recl=32000,replace",DISPLAY,OUTPUT IOERR IGNORE
    end if

    if File(CSVFile) = 0 then
        let CSVPath$=File$(CSVFile)
        close #CSVFile:

        let UseRecNums$ = "Include Record Numbers"
        if UseRecNums then let UseRecNums$(1:0)="^"

        let SelectColumns$="Select Columns"
        if DialogType=2 then let SelectColumns$(1:0)="^"

        do
            RINPUT #Dialog, fields "2,1,20/V 300,P;4,1,CHECK 30;5,1,CHECK 30" : CSVPath$,UseRecNums$,SelectColumns$

            let KeyP=FKey

            if KeyP=62 then
                ! browse for a new file
                OPEN #(CSVFile:=fngetfilenumber): "name=SAVE:"&FileString$&",recl=32000,replace",DISPLAY,OUTPUT IOERR IGNORE
                if File(CSVFile) = 0 then
                    let CSVPath$=File$(CSVFile)
                    close #CSVFile:
                end if
            end if
        loop Until KeyP = 60 or KeyP = 61 or KeyP = 99 or KeyP=93

        if UseRecNums$(1:1)="^" then UseRecNums=1 else UseRecNums=0
        if SelectColumns$(1:1)="^" then DialogType=2 else DialogType=0

        if KeyP = 61 then
            ! do export
            let fnCsvExportDlg=1
        end if
    end if

    CLOSE #Dialog:
fnend


IMPORTFROMCSV: ! **** Import data from an external CSV file
def fnImportFromCSV(Layout$,&Filename$,KeyNum;___,Datafile,RecNum$,CharInd,NumQ,CSVFile,Indx)
    library : fnBuildKey$,fnCloseFile, fnReadCSVLine$

    dim CSVLine$*32000
    dim SrcFieldNames$(1)*80

    OPEN #(CSVFile:=fngetfilenumber): "name="&Filename$,DISPLAY,INPUT IOERR IGNORE
    if File(CSVFile) = 0 then
        RESTORE #CSVFile:
        LINPUT #CSVFile: CSVLine$

        let FieldCnt=fnExtractCSVHeader(CSVLine$,mat SrcFieldNames$)
        let fnLwrcThis(mat SrcFieldNames$)

        let fnGetFieldNames(Layout$,mat CsvFieldNames$,mat CSVFieldPositions)

        ! Make the comparison case insensitive by lwrcing everything
        for Indx=1 to udim(mat SrcFieldNames$)
           let SrcFieldNames$(Indx)=lwrc$(SrcFieldNames$(Indx))
        next Indx
        for Indx=1 to udim(mat CsvFieldNames$)
           let CsvFieldNames$(Indx)=lwrc$(CsvFieldNames$(Indx))
        next Indx

        if KeyNum > 0 then
            let Datafile=Fnopen(Layout$,Mat Csv_Data$,Mat Csv_Data,Mat Csv_Forms$,0,KeyNum)
        else
            let Datafile=Fnopen(Layout$,Mat Csv_Data$,Mat Csv_Data,Mat Csv_Forms$)
        end if

        let fnClearCSVApplyMessages

        do
            let CSVLine$=fnReadCSVLine$(CSVFile)
            if File(CSVFile) = 0 then
                let fnExtractCSVLine(CSVLine$,mat Csv_Data$,mat Csv_Data,mat CsvFieldNames$,mat SrcFieldNames$)

                if fnDisplayCSVApplyMessages then
                    ! There were no errors, or they chose Ignore
                    if KeyNum > 0 then
                        ! attempt to rewrite
                        REWRITE #DataFile, USING Csv_Forms$(Datafile), Key=fnBuildKey$(Layout$, mat Csv_Data$, mat Csv_Data, KeyNum) : mat Csv_Data$, mat Csv_Data ERROR IGNORE
                        if File(DataFile) = 21 then
                            WRITE #Datafile, USING Csv_Forms$(Datafile) : mat Csv_Data$, mat Csv_Data
                        end if
                    else if KeyNum = 0 then
                        RecNum$=CSVLine$(1:POS(CSVLine$,",")-1)
                        REWRITE #DataFile, USING Csv_Forms$(Datafile), Rec=VAL(RecNum$) : mat Csv_Data$, mat Csv_Data ERROR IGNORE
                        if File(DataFile) = 21 then
                            WRITE #Datafile, USING Csv_Forms$(Datafile) : mat Csv_Data$, mat Csv_Data
                        end if
                    else
                        WRITE #Datafile, USING Csv_Forms$(Datafile) : mat Csv_Data$, mat Csv_Data
                    end if
                else
                    ! They chose abort
                    exit do
                end if
            end if
        loop Until File(CSVFile) <> 0

        let fnCloseFile(Datafile,Layout$)
    else
        let msgbox("Error "&str$(err)&" Opening File "&Filename$,"File Error","Ok","Err")
    end if
fnend

dim TempString$*100000
def fnReadCSV$*100000(CsvFile)
   let fnReadLongLine(TempString$,CSVFile)
   let fnReadCSV$=TempString$
fnend

def library fnReadCSVLine$*100000(CSVFile)
   let fnReadLongLine(TempString$,CSVFile)
   let fnReadCSVLine$=TempString$
fnend

dim CSVLineBuf$*100000
def fnReadLongLine(&CSVLine$,CSVFile)
   let CSVLine$=""
   do while file(CSVFile)=0
      let CSVLineBuf$=""
      linput #CSVFile: CSVLineBuf$ error ignore
      if file(CSVFile)=0 then
         let CSVLine$=CSVLine$&CSVLineBuf$
      end if
   loop until Mod(fnCountCharacter(CsvLine$,""""),2)=0
fnend

! Fast way to count number of occurances of given char in a string
def fnCountCharacter(&String$,Char$)=len(String$)-len(srep$(String$,Char$,""))

def fnCSVImportDlg(Layout$,&CSVPath$,&KeyNum;___,Dialog,Key,FileName$*255,CSVPath2$*300,Key$*160,Index,Sel$,CSVFile,CSVLine$*32000,FileChanged,FileString$*255,Rows,Cols,CurrentField,FunctionKey)
    library : fnReadLayoutHeader,Fnclientserver

    dim Keys$(1)*80,KeyDesc$(1)*80,KeyOptions$(1)*160,SrcFieldNames$(1)*80
    let fnReadScreenS(Rows,Cols)

    OPEN #(Dialog:=fnGetFileNumber) : "SROW="&STR$(INT((Rows - 7) / 2))&",SCOL="&STR$(INT((Cols - 30) / 2))&",ROWS=7,COLS=30,CAPTION=Import from CSV,BORDER=S",display,outin
    PRINT #Dialog, fields "1,1,C 20;2,22,CC 8,/W:W,B62" : "CSV Data File","Browse"
    PRINT #Dialog, fields "7,22,CC 8,/W:W,B60" : "Cancel"

    fnReadLayoutHeader(Layout$,FileName$,mat Keys$,mat KeyDesc$,0)

    if fn42 then Sel$=",SELECT" else Sel$=""
    if len(Trim$(CSVPath$))=0 then
       if Pos(FileName$,".") > 0 then CSVPath$=FileName$(1:POS(FileName$,"."))&"csv" else CSVPath$=FileName$&".csv"
    end if
    FileChanged = 1
    do
        ! Check whether selected file exists and if so, look for &RECNUM field
        CSVPath2$=CSVPath$
        if FileChanged then
            FileChanged = 0
            if File(CSVFile) >< -1 then CLOSE #CSVFile:
            OPEN #(CSVFile=fngetfilenumber): "name="&CSVPath$,DISPLAY,INPUT IOERR IGNORE
        end if
        if File(CSVFile) = 0 then  ! File exists and is open
            PRINT #Dialog, fields "4,1,C 26" : "Update Records Using Key"

            RESTORE #CSVFile:
            LINPUT #CSVFile: CSVLine$
            let fnExtractCSVHeader(CSVLine$,mat SrcFieldNames$)
            if lwrc$(trim$(SrcFieldNames$(1),"&")) = "recnum" then
                mat KeyOptions$(UDim(KeyDesc$) + 2)
                KeyOptions$(2)="Record Number"
            else
                mat KeyOptions$(UDim(KeyDesc$) + 1)
            end if
            KeyOptions$(1)="None (append all records)"
            for Index = 1+UDim(KeyOptions$)-UDim(KeyDesc$) to UDim(KeyOptions$)
                 KeyOptions$(Index) = STR$(Index+UDim(KeyDesc$)-UDim(KeyOptions$))&" - "&Keys$(Index+UDim(KeyDesc$)-UDim(KeyOptions$))&" ("&KeyDesc$(Index+UDim(KeyDesc$)-UDim(KeyOptions$))&")"
            next Index
            PRINT #Dialog, fields "5,1,26/COMBO 160,= "&Sel$ : mat KeyOptions$

            if KeyNum=-1 then
               let Key$=KeyOptions$(1)
            else if KeyNum=0 and udim(mat KeyOptions$)>=2 and KeyOptions$(2)="Record Number" then
               let Key$=KeyOptions$(1)
            else
               if udim(mat KeyOptions$)>=2 and KeyOptions$(2)="Record Number" then
                  let Key$=KeyOptions$(KeyNum+2)
               else
                  let Key$=KeyOptions$(KeyNum+1)
               end if
            end if

            let Curfld(CurrentField,FunctionKey)
            RINPUT #Dialog, fields "2,1,20/C 300,AEX;5,1,26/COMBO 160,"&Sel$ : CSVPath$,Key$
            let FunctionKey=fkey
            let CurrentField=Curfld
        else                  ! File doesn't exist; don't show any other input fields
            Key$=""
            print #Dialog, fields "7,11,CC 8" : ""
            PRINT #Dialog, fields "4,1,C 26;5,1,C 26" : "",""
            RINPUT #Dialog, fields "2,1,20/C 300,AEX" : CSVPath$
        end if
        Key=FKey

        if Key = 62 then
            ! try to open file by browsing
            FileChanged = 0
            if File(CSVFile) >< -1 then CLOSE #CSVFile:

            if fnClientServer then
               let FileString$="@:CSV files (*.csv) |*.csv"
            else
               let FileString$="CSV files (*.csv) |*.csv"
            end if

            OPEN #(CSVFile=fngetfilenumber): "name=OPEN:"&FileString$,DISPLAY,INPUT IOERR IGNORE
            if File(CSVFile) = 0 then
               CSVPath$=File$(CSVFile)
            else
               FileChanged = 1
            end if
        end if
        if CSVPath2$<>CSVPath$ then
            ! retry file using contents of text box
            FileChanged = 1
        end if
        if Key$="" then
           print #Dialog, fields "7,12,CC 8" : ""
        else
           print #Dialog, fields "7,12,CC 8,/W:W,B61" : "Import!"
        end if

    loop until Key = 60 or Key = 61 or Key = 99 or Key=93

    if Key = 61 then
        ! get data key number; -1 = append all, 0 = use recnum
        if Key$="Record Number" then
            KeyNum=0
        else if Key$(1:4)="None" then
            KeyNum=-1
        else
            KeyNum=Val(Key$(1:Pos(Key$," ")-1))
        end if

        ! do the import
        let fnCSVImportDlg=1
    end if
    if file(CSVFile)><-1 then close #CSVFile:
    close #Dialog:
fnend

def fnStripQuotes(mat A$;___,Index)
   for Index=1 to udim(mat A$)
      let A$(Index)=trim$(A$(Index),"""")
   next Index
fnend

EXTRACTCSVHEADER: ! Extract field names from a CSV header line into an array
   def fnExtractCSVHeader(&Line$,mat FieldNames$)
      Line$=TRIM$(Line$)
      ChunkStart=1 : FieldCnt=0
      for CharInd = 1 to LEN(Line$)
        if Line$(CharInd:CharInd)="," then
            FieldCnt = FieldCnt + 1
            mat FieldNames$(FieldCnt)
            if CharInd=ChunkStart then FieldNames$(FieldCnt)="" else FieldNames$(FieldCnt)=Line$(ChunkStart:CharInd-1)
            ChunkStart=CharInd+1
         else if CharInd=LEN(Line$) then
            FieldCnt = FieldCnt + 1
            mat FieldNames$(FieldCnt)
            FieldNames$(FieldCnt)=Line$(ChunkStart:CharInd)
         end if
      next CharInd
      let fnStripQuotes(mat FieldNames$)
      fnExtractCSVHeader=FieldCnt
   fnend

   def fnExtractCSVLine(&Line$,mat SValues$,mat NValues,mat DestFieldNames$,mat SrcFieldNames$;___,ChunkStart,CurField,CharInd,Chunk$*4000,NumInd,StrInd)
      let Line$=TRIM$(Line$)
      let ChunkStart=1 : let CurField=1
      mat SValues$=("")
      mat NValues=(0)

      for CharInd = 0 to LEN(Line$)
         if Line$(CharInd+1:CharInd+1)="," or CharInd=LEN(Line$) then
             ! grab chunk to parse
             let Chunk$=rtrm$(Line$(ChunkStart:CharInd)) ! RTRM, BR doesn't store trailing spaces anyway.
             let NextField = 0

             ! print line$ : print chunk$ : pause ! Debug line

             if Chunk$(1:1)<>"""" or Mod(fnNumEndingQuotes(Chunk$),2)=1 then
                ! Either has no beg qoute (not quoted) or has both
                ! beginning and ending qoute, process it. Otherwise, go
                ! back for more.

                if Chunk$(1:1)="""" and Mod(fnNumEndingQuotes(Chunk$),2)=1 then
                   let Chunk$=SREP$(Chunk$(2:LEN(Chunk$)-1),"""""","""") ! Substitute out inner Qoutes, and Strip out Qoutes
                end if
                ! if len(Trim$(Chunk$)) then ! If there's something left ! Commented out by GSB .. if a field is empty, we want to clear the value, not ignore it.
                let fnApplyCSVField(Chunk$,mat SValues$,mat NValues,mat DestFieldNames$,SrcFieldNames$(CurField))
                ! end if
                let NextField = 1
             end if

             if NextField then
                 ! CharInd=CharInd+2
                 ChunkStart=CharInd +2
                 CurField = CurField + 1
             end if
         end if
      next CharInd
   fnend

   ! Old Logic here replaced by the above code.
   ! Old Logic for Numbers (Without beginning quote):
   !  for NumInd=UDim(SValues$)+1 to UDim(SValues$)+Udim(NValues)
   !     if DestFieldNames$(NumInd)=SrcFieldNames$(CurField) then NValues(NumInd - UDim(SValues$))=Val(Chunk$)
   !  next NumInd

   ! Old Logic for Strings (With Beginning Qoute):
   !  for StrInd=1 to UDim(SValues$)
   !     if DestFieldNames$(StrInd)=SrcFieldNames$(CurField) then SValues$(StrInd)=Chunk$
   !  next StrInd

   def fnApplyCSVField(&SourceData$,mat SValues$,mat NValues, mat DestFieldNames$,&SourceFieldName$;___,Index)
      let Index=srch(mat DestFieldNames$,SourceFieldName$)
      if Index>=1 and Index<=udim(SValues$)+udim(NValues) then
         if Index>Udim(SValues$) then
            if fnIsNumber(Chunk$) then
               let NValues(Index-udim(SValues$))=val(Chunk$)
            else
               if ~ErrorImportMessage then ! If not asked yet, then ask.
                  ! Conversion Error, Field was not a number when it should have been
                  mat FieldsConv$(udim(Mat FieldsConv$)+1)
                  let FieldsConv$(udim(mat FieldsConv$))=SourceFieldName$
               end if
            end if
         else
            let SValues$(Index)=Chunk$
         end if
      else
         ! Field could not be found, report it later
         if SourceFieldName$<>"&recnum" then
            mat FieldsMissing$(udim(FieldsMissing$)+1)
            let FieldsMissing$(udim(FieldsMissing$))=SourceFieldName$
         end if
      end if
   fnend

   dim FieldsMissing$(1)*127
   dim FieldsConv$(1)*127

   def fnClearCSVApplyMessages
      mat FieldsMissing$(0)
      mat FieldsConv$(0)
   fnend

   dim MessageText$*4000
   def fnDisplayCSVApplyMessages
      if udim(mat FieldsMissing$)+udim(mat fieldsconv$) then ! If there were errors,
         let fnBuildMessageText(MessageText$,mat FieldsMissing$,mat FieldsConv$)
         if (2==msgbox(MessageText$,"Import Error","Yn","ERR")) then
            let fnDisplayCSVApplyMessages=0
         else
            let fnDisplayCSVApplyMessages=1
         end if
      else
         let fnDisplayCSVApplyMessages=1
      end if
   fnend

   def fnBuildMessageText(&MessageText$,mat Missing$,mat Conv$;___,Index,np$,nl$)
      let np$=hex$("0D0A0D0A")
      let nl$=hex$("0D0A")

      let MessageText$="Errors were encountered during the import process."
      if udim(mat Missing$) then
         let MessageText$=MessageText$&np$&"The following fields could not be found in the data file and will be ignored if you continue:"&nl$
         for Index=1 to udim(mat Missing$)
            let MessageText$=MessageText$&Missing$(Index)&", "
         next Index
         let messagetext$=MessageText$(1:len(MessageText$)-2) ! Chop off final ","
      end if
      if udim(mat Conv$) then
         let MessageText$=MessageText$&np$
         if udim(mat Missing$) then
            let MessageText$=MessageText$&"Additionally, t"
         else
            let MessageText$=MessageText$&"T"
         end if
         let MessageText$=MessageText$&"he following fields were numeric fields that contained string data, and will be ignored if you continue:"&nl$
         for Index=1 to udim(mat Conv$)
            let MessageText$=MessageText$&Conv$(Index)&", "
         next Index
         let messagetext$=MessageText$(1:len(MessageText$)-2) ! Chop off final ","
      end if
      let messagetext$=MessageText$&np$&"Do you wish to Stop the Import process?"
      let fnClearCSVApplyMessages
   fnend

   ! that delicate nervous shake
   ! upon discovering a pause
   ! left behind by mistake
   ! like a sock in the kaverns of kroz

   def fnNumEndingQuotes(Chunk$*4000;___,CharInd,QuoteCnt)
      QuoteCnt = 0
      for CharInd = LEN(Chunk$) to 2 STEP -1
         if Chunk$(CharInd:CharInd)="""" then QuoteCnt += 1
      next CharInd
      fnNumEndingQuotes = QuoteCnt
   fnend

   ! discovered in some dusty function
   ! that you thought was always working
   ! abandoned like a lost conjunction
   ! a dangerous pause, secretly lurking

   def fnLwrcThis(mat A$;___,Index)
      for Index=1 to udim(mat A$)
         let A$(Index)=lwrc$(A$(Index))
      next Index
   fnend

   ! what is this pause
   ! and why is it there?
   ! why is it forgotten,
   ! abandoned somewhere?

!
dim outColumnNames$(1)*255
CALCULATEFIELDFORMS: ! ***** Calculate Field Forms From Widths And Num Of Strings/Numerics
   def Fncalculatefieldforms(layout$,mat ColumnNames$,Mat Fieldforms$,mat outWidths,mat outDescription$,Mat Widths,Mat Description$,mat dateformats$,Mat IncludeColumns$,mat OriginalIncludeColumn$,mat ColumnDescription$,mat ColumnWidths,mat ColumnForms$,mat FieldPositions;bShowPositions,displaySub,&DisplayFieldConvert$,datedisplayformat$,BypassDateProcessing,___,Index,CompressColumns,MaxColWidth,Sub,bColumnDescription,bColumnWidth,bOriginalInclude,bColumnForms)

      ! Prepare width calculation
      let CompressColumns=fnSettings("compresscolumns")
      let MaxColWidth=fnSettings("maxcolwidth")

      ! Prepare Column Descriptions and Widths
      let bColumnWidth=~fnIsEmpty(mat ColumnWidths)
      let bColumnForms=~fnIsEmptys(mat ColumnForms$)
      let bColumnDescription=~fnIsEmptys(mat ColumnDescription$)
      let bOriginalInclude=~fnIsEmptyS(mat OriginalIncludeColumn$)

      if ~fnISEmptys(mat IncludeColumns$) then
         ! Size temp arrays
         mat outWidths(udim(mat IncludeColumns$))
         mat outDescription$(udim(mat IncludeColumns$))
         mat outColumnNames$(udim(mat IncludeColumns$))
         mat Fieldforms$(Udim(Mat outWidths))

         ! Sort through IncludeColumns and place columns in the grid in order.
         for Index=1 to udim(mat IncludeColumns$)
            let Sub=srch(mat ColumnNames$,IncludeColumns$(Index))
            if Sub>0 then  ! found it
               if ~BypassDateProcessing and dateformats$(sub)<>'' then
                  ! We need to set FieldForms$ to DisplayDateFormat whenever the field is a date field (has anything under dc_DateFormat)
                  let outWidths(Index)=fnGetDateWidth(datedisplayformat$)
                  let Fieldforms$(Index)="DATE("&datedisplayformat$&")"
               else
                  let outWidths(Index)=Widths(Sub)
                  let Fieldforms$(Index)="C "&str$(outWidths(index))
               end if

               let outDescription$(Index)=Description$(Sub)
               if bShowPositions then let outDescription$(Index)(1:0)=str$(FieldPositions(Sub))&" - "
               let outColumnNames$(Index)=IncludeColumns$(Index)
            end if
         next Index
      else
         mat outWidths(udim(mat Widths))
         mat Fieldforms$(Udim(Mat outWidths))

         for index=1 to udim(mat Widths)
            if ~BypassDateProcessing and dateformats$(index)<>'' then
               ! We need to set FieldForms$ to DisplayDateFormat whenever the field is a date field (has anything under dc_DateFormat)
               let outWidths(index)=fnGetDateWidth(datedisplayformat$)
               let Fieldforms$(Index)="DATE("&datedisplayformat$&")"
            else
               let outWidths(index)=Widths(index)
               let Fieldforms$(Index)="C "&str$(outWidths(index))
            end if
         next index

         mat outDescription$(udim(mat Description$))
         mat outColumnNames$(udim(mat ColumnNames$))=ColumnNames$
         for Index=1 to udim(Mat Description$)
            let outDescription$(Index)=Description$(Index)
            if bShowPositions then let outDescription$(Index)(1:0)=str$(FieldPositions(Index))&" - "
         next Index
      end if

      for Index=1 to Udim(Mat outWidths)
         if bColumnDescription then
            if bOriginalInclude then
               ! interpret ColumnDescription and ColumnWidth as matching original include
               let Sub=srch(mat OriginalIncludeColumn$,outColumnNames$(Index))
               if Sub>0 and Sub<=udim(mat ColumnDescription$) then let OutDescription$(Index)=ColumnDescription$(Sub)
            else
               ! interpret columndescription and Columnwidth as matching file record
               if Index<udim(mat ColumnDescription$) then
                  let outDescription$(Index)=ColumnDescription$(Index)
               end if
            end if
         end if

         if ~CompressColumns then
            let outWidths(Index)=Max(outWidths(Index),Len(outDescription$(Index)))
         end if
         let outWidths(Index)=Min(outWidths(Index),MaxColWidth)

         if bColumnForms then
            if bOriginalInclude then
               ! interpret ColumnForms as matching original include
               let Sub=srch(mat OriginalIncludeColumn$,outColumnNames$(Index))
               if Sub>0 and Sub<=udim(mat ColumnForms$) and len(trim$(ColumnForms$(Sub))) then let FieldForms$(Index)=ColumnForms$(Sub)
            else
               ! interpret ColumnForms as matching file record
               if Index<udim(mat ColumnForms$) and len(trim$(ColumnForms$(Index))) then
                  let FieldForms$(Index)=ColumnForms$(Index)
               end if
            end if
         end if

         if bColumnWidth then
            if bOriginalInclude then
               ! interpret ColumnDescription and ColumnWidth as matching original include
               let Sub=srch(mat OriginalIncludeColumn$,outColumnNames$(Index))
               if Sub>0 and Sub<=udim(mat ColumnWidths) then let outWidths(Index)=ColumnWidths(Sub)
            else
               ! interpret columndescription and Columnwidth as matching file record
               if Index<=udim(mat ColumnWidths) then
                  let outWidths(Index)=ColumnWidths(Index)
               end if
            end if
         end if

      next Index

      if DisplaySub>0 and DisplaySub<=udim(mat ColumnNames$) then
         let Sub=srch(mat outColumnNames$,ColumnNames$(DisplaySub))
         if Sub>0 then
            let DisplayFieldConvert$=FieldForms$(Sub)
         end if
      end if
   fnend

GETFIELDNAMES: ! Get the field names from the layout file in strings first, numerics last order
   def fnGetFieldNames(Layout$*255,mat FieldNames$,mat Positions)
      dim StringSubs$(1)*80,NumSubs$(1)*80,StringSpecs$(1)*80,NumSpecs$(1)*80,StringDesc$(1)*80,NumDesc$(1)*80,StringPos(1),NumPos(1)
      fnReadLayoutArrays(Layout$,prefix$,mat StringSubs$,mat NumSubs$,mat StringSpecs$,mat NumSpecs$,mat StringDesc$,mat NumDesc$,mat StringPos,mat NumPos,0)
      let SubCnt=UDim(StringSubs$)+UDim(NumSubs$)
      mat FieldNames$(SubCnt)
      if udim(StringSubs$) then mat FieldNames$(1:udim(StringSubs$))=StringSubs$
      if udim(mat NumSubs$) then mat FieldNames$(udim(StringSubs$)+1:udim(mat FieldNames$))=NumSubs$
      mat Positions(SubCnt)
      if udim(mat StringPos) then mat Positions(1:udim(mat StringPos))=StringPos
      if udim(mat NumPos) then mat Positions(udim(mat StringPos)+1:udim(mat Positions))=NumPos
   fnend

!
dim InputKeyField$(2)
! #Autonumber# 13000,10
INPUTKEY: ! ***** Prompts The User For The Key To Look Up In The Datafile
   def Fninputkey(&Key$,&RecordNum,Datafile,rows,cols;parentwindow,___,Window,Field$,srow,scol,viewlength,Length,Height,RecordLen)
      let Height=1
      let RecordLen=len(str$(lrec(datafile)))+1
      if kln(Datafile)>0 then
         ! let Height+=1
         let length=kln(Datafile)
      end if

      ! Uncomment the Hight code above and the Record num code below to
      !  enable both at the same time here. They also need to be enabled
      !  both at the same time in fnShowData by opening file twice,
      !  and using the correct file channel to search by key or by
      !  record number

      let srow=int((rows-Height)/2)+1
      let viewlength=min(cols-2,max(length,RecordLen)+4)
      let viewlength=max(viewlength,15)
      let scol=int((cols-viewlength)/2)+1
      open #(Window:=Fngetfilenumber) : "srow="&str$(srow)&",scol="&Str$(scol)&",rows="&str$(Height)&",cols="&Str$(viewlength)&",Caption= Jump to ... ,Border=S,Parent="&str$(parentwindow),display,output

      mat InputKeyField$(Height)
      if kln(DataFile)>0 then
         ! print #Window, fields "1,1,CR 4;2,1,CR 4" : "Key:","Rec:"
         print #Window, fields "1,1,CR 4" : "Key:"
         let InputKeyField$(1)="1,6,"&str$(min(ViewLength-6,Length))&"/C "&Str$(Length)
         ! let InputKeyField$(2)="2,6,"&str$(min(ViewLength-6,RecordLen))&"/N "&Str$(RecordLen)
         rinput #Window, fields mat InputKeyField$ : Key$ ! ,RecordNum conv Tryagain
      else
         print #Window, fields "1,1,CR 4" : "Rec:"
         let InputKeyField$(1)="1,6,"&str$(min(ViewLength-6,RecordLen))&"/N "&Str$(RecordLen)
         input #Window, fields mat InputKeyField$ : RecordNum conv Tryagain
      end if
      if fkey=99 or fkey=93 then let RecordNum=0 : let Key$=""

      close #Window:
   fnend
!
UPDATECOLORS: ! ***** Update Listview Colors
   mat dc_Colorstart(0) !:
   mat dc_Colorend(0) !:
   mat dc_Color$(0) ! Clear Color Markings
   for Deleteindex=1 to Udim(Mat dc_Deleterow)
      if dc_Deleterow(Deleteindex) then ! If Row Is Marked For Deletion, Show It In Red
         mat dc_Colorstart(Udim(Mat dc_Colorstart)+1) !:
         mat dc_Colorend(Udim(Mat dc_Colorstart)) !:
         mat dc_Color$(Udim(Mat dc_Colorstart)) ! Make Room !:
         let dc_Colorstart(Udim(Mat dc_Colorstart)) = (((Deleteindex-1) * Recordsize)+1) !:
         let dc_Colorend(Udim(Mat dc_Colorstart)) = (Deleteindex * Recordsize)
         if dc_Deleterow(Deleteindex)=1 then !:
            let dc_Color$(Udim(Mat dc_Colorstart)) = "/#FF0000:#FFFF00" ! Red With Yellow Background !:
         else !:
            let dc_Color$(Udim(Mat dc_Colorstart)) = "/#000000:#FFFFFF" ! Black With White Background !:
            let dc_Deleterow(Deleteindex)=0
      end if
   next Deleteindex
   if (Udim(Mat dc_Colorstart)) then !:
      print #Window, fields GridSpec$&",ATTR" : (Mat dc_Colorstart, Mat dc_Colorend, Mat dc_Color$)
   return
!

dim SearchFor$*999
dim SearchIn$*4000
def fnSearchIn(&Search$,mat F$,mat F;mat SDateFormat$,mat NDateFormat$,DateFormatDisplay$,BypassDateProcessing,___,SearchChunk$*64,Index,Found,Number,Passing)
   let SearchFor$=Search$

   do while len(SearchFor$)
      if pos(SearchFor$," ") then
         let SearchChunk$=lwrc$(trim$(SearchFor$(1:pos(SearchFor$," "))))
         let SearchFor$(1:pos(SearchFor$," "))=""
         let SearchFor$=trim$(SearchFor$)
      else
         let SearchChunk$=lwrc$(trim$(SearchFor$))
         let SearchFor$=""
      end if

      let Found=0
      do
         for Index=1 to udim(mat F$)
            let SearchIn$=lwrc$(F$(Index))
            if ~BypassDateProcessing and len(trim$(SDateFormat$(Index))) then
               let SearchIn$=fnfmtsdate$(SearchIn$,SDateFormat$(Index),DateFormatDisplay$)
            end if
            if pos(SearchIn$,SearchChunk$) then
               let Found=1
               exit do      ! We're done searching as soon as we found it anywhere
            end if
         Next Index
         ! if fnIsNumber(SearchChunk$(1:120)) then
            for Index=1 to udim(mat f)
               let SearchIn$=str$(f(Index))
               if ~BypassDateProcessing and len(trim$(NDateFormat$(Index))) then
                  let SearchIn$=fnfmtndate$(f(Index),NDateFormat$(Index),DateFormatDisplay$)
               end if
               if pos(SearchIn$,SearchChunk$) then
                  let Found=1
                  exit do   ! We're done searching as soon as we found it anywhere
               end if
            next Index
         ! end if
      loop until 1
   loop while Found         ! Every chunk has to be found for it to be legit.
   let fnSearchIn=Found
fnend

def fnIsNumber(String$*120;___,TestNumber)
   let TestNumber=val(String$) Conv NotNumber
   let fnIsNumber=1
   NotNumber: ! Not a number
fnend

! #Autonumber# 15000,2
dim TemplateProg$(1)*255,TemplateDesc$(1)*255,TemplateNum(1),TemplateChoice$*255
GenerateCode: ! This function generates code if code templates are available
   def fnGenerateCode(FileLay$;___,TemplateChoice)
      library : fnAskCombo$
      mat TemplateProg$(0)
      mat TemplateDesc$(0)

      ! Read the Templates Directory
      let fnReadTemplates(mat TemplateProg$,mat TemplateDesc$,mat TemplateNum)

      if udim(mat TemplateDesc$) then
         let TemplateChoice$=fnAskCombo$(mat TemplateDesc$,"Select Template")

         ! code templates are library functions. They can do their own input/output.
         let TemplateChoice=srch(mat TemplateDesc$,TemplateChoice$)
         if TemplateChoice>0 then
            library TemplateProg$(TemplateChoice) : fnTemplateList, fnRunTemplate
            let fnRunTemplate(TemplateNum(TemplateChoice),fileLay$)
         end if

      else
         let msgbox("No valid templates were found.","No Templates")
      end if
   fnend

   def library fnAskCombo$*255(mat Description$;Caption$*60,Default$*255,___,Window,Choice$*255,ScreenRows,ScreenCols,SRow,SCol)
      library : fnGetFileNumber
      if Caption$="" then let Caption$="Select"

      let fnReadScreenS(ScreenRows,ScreenCols)

      let SRow=int((ScreenRows-3)/2)+1
      let SCol=int((ScreenCols-20)/2)+1

      ! Open child window
      open #(Window:=Fngetfilenumber): "SROW="&str$(srow)&", SCOL="&str$(scol)&", ROWS=3, COLS=20, Border=S, Caption="&Caption$,display,outin

      let choice$=Default$

      ! allow user to select code template
      print #Window, fields "3,7,CC 7,/W:W,B0" : "Ok"
      print #Window, fields "1,2,17/COMBO 255,=,SELECT" : mat Description$
      rinput #Window, fields "1,2,17/COMBO 255,/W:W,SELECT" : Choice$

      close #Window:
      let fnAskCombo$=Choice$
   fnend

   ! Define Listviews
   dim Layoutwizard_LV1_Captions$(1), Layoutwizard_LV1_Widths(1), Layoutwizard_LV1_Specs$(1)
   dim Layoutwizard_LV1_Spec$*40, LayoutWizard_LV1_PopSpec$*40

   ! Declare Variables
   dim lw_Output_Spec$(17)*60,lw_Output_Data$(17)*60
   dim lw_Input_Spec$(5)*255,lw_Input_Data$(5)*1000
   dim OpenString$(1)*999
LayoutWizard: ! This function gives a dialog from which programmers can quickly generate file layouts
   def fnLayoutWizard(;___,Window,ScreenRows,ScreenCols,SRow,SCol,ExitMode,Generate,Function,FileBrowser,Index,Jndex,Curfield)

      let fnReadScreenS(ScreenRows,ScreenCols)

      let SRow=int((ScreenRows-22)/2)+1
      let SCol=int((ScreenCols-60)/2)+1

      ! Read Specs for Output Controls
      LayoutWizardData: restore LayoutWizardData ! Restore Data Statements

      read mat lw_Output_Spec$
      data "22,44,14/CC 15,/W:W,B1504","2,1,11/C 12"
      data "7,1,13/C 15","12,1,13/C 15"
      data "22,27,14/CC 6,/W:W,B1508","17,1,13/C 15"
      data "1,1,8/CR 9","1,41,8/CC 6,/W:W,B1513"

      data "1,51,8/CC 8,/W:W,B1514","2,16,8/CC 4,/W:W,B1515"
      data "7,16,8/CC 4,/W:W,B1516","12,16,8/CC 4,/W:W,B1517"
      data "17,16,8/CC 4,/W:W,B1518","2,27,8/CC 5,/W:W,B1520"
      data "2,41,8/CC 9,/W:W,B1521","2,51,8/CC 8,/W:W,B1522"
      data "22,4,17/CC 16,/W:W,B1523"

      read mat lw_Output_Data$
      data "Generate Layout","Open String:","Read Statement:","Form Statement:"
      data "Done","Dim Statements:","Program:","Browse"
      data "Search","Scan","Scan","Scan","Scan"
      data "Paste","Clear All","Scan All"
      data "Open Scratch Pad"

      ! Read Specs for Input Controls
      read mat lw_Input_Spec$
      data "1,10,28/V 999,S/W:W"
      data "3,1,GRID 4/60,ROW,ALL"
      data "8,1,240/V 999,^ENTER_CRLFS/W:W","13,1,240/V 999,^ENTER_CRLFS/W:W"
      data "18,1,240/V 999,^ENTER_CRLFS/W:W"

      read Layoutwizard_LV1_Spec$
      data "3,1,GRID 4/60,HEADERS,/W:W"
      read Layoutwizard_LV1_Pop$
      data "3,1,GRID 4/60,="

      ! Fix for earlier versions of BR that don't support ENTER_CRLFS
      if ~fn42ia then
         for Index=1 to udim(mat lw_Input_Spec$)
            let lw_Input_Spec$(Index)=srep$(lw_Input_Spec$(Index),"^ENTER_CRLFS","")
         next Index
      else if ~fn42j then
         for Index=1 to udim(mat lw_Input_Spec$)
            let lw_Input_Spec$(Index)=srep$(lw_Input_Spec$(Index),"^ENTER_CRLFS","^ENTER-CRLFS")
         next Index
      end if

      read mat Layoutwizard_LV1_Captions$
      data "Open String"
      read mat Layoutwizard_LV1_Widths
      data 40
      read mat Layoutwizard_LV1_Specs$
      data "V 999,E"

      read lw_Generate,lw_Done,lw_Browse,lw_ScanProgram,lw_ScanOpen,lw_ScanRead,lw_ScanForm,lw_ScanDim,lw_PasteOpen,lw_ClearAll,lw_ScanAll,lw_OpenScratchPad
      data 1504,1508,1513,1514,1515,1516,1517,1518,1520,1521,1522,1523

      read lw_ProgramName,lw_ReadString,lw_FormString,lw_DimString
      data 1,2,3,4

      let fnBuildSrchHelp(1)

      ! Open Screen
      open #(Window:=Fngetfilenumber): "SROW="&str$(srow)&", SCOL="&str$(scol)&", ROWS=22, COLS=60, Border=S, Caption=File Layout Wizard",display,outin

      print #Window, fields mat lw_Output_Spec$ : mat lw_Output_Data$
      print #Window, fields Layoutwizard_LV1_Spec$ : (mat Layoutwizard_LV1_Captions$, mat Layoutwizard_LV1_Widths, mat Layoutwizard_LV1_Specs$)

      ! Main input loop here
      do
         ! Trim spaces in mat open string
         let Jndex=0
         for Index=1 to udim(mat OpenString$)
            if len(trim$(OpenString$(Index))) then
               let Jndex+=1
               let OpenString$(Jndex)=trim$(OpenString$(Index))
            end if
         next Index
         mat OpenString$(jndex+1) : let Openstring$(Jndex+1)="" ! add 1

         let Curfld(Curfield,Function)
         ! populate it
         print #Window, fields Layoutwizard_LV1_Pop$ : mat Openstring$
         rinput #Window, fields mat lw_Input_Spec$ : mat lw_Input_Data$(1:1),mat OpenString$,mat lw_Input_Data$(2:4)
         let Function=fkey
         let Curfield=curfld

         #Select# Function #Case# 99 # 93 # lw_Done
            let ExitMode=1
         #Case# lw_Browse
            ! Browse for a data file
            open #(FileBrowser:=fngetfilenumber): "name=OPEN:.|*.wb;*.br,recl=1000",external,INPUT IOERR IGNORE
            if file(FileBrowser)>-1 then
               let lw_Input_Data$(lw_ProgramName)=file$(FileBrowser)
               close #FileBrowser:
               if lwrc$(lw_input_data$(lw_ProgramName))(1:2)="c:" then
                  let lw_input_data$(lw_ProgramName)=lw_input_data$(lw_ProgramName)(3:999)
                  let fnScanAll(mat lw_Input_Data$,mat OpenString$)
               end if
            end if
         #Case# lw_ScanProgram
            let fnSearchPrograms(mat OpenString$,lw_input_data$(lw_programName),1)
         #Case# lw_ScanOpen
            let fnSearchOpenString(mat lw_Input_Data$,mat OpenString$,1)
         #Case# lw_ScanRead
            let fnSearchRead(mat lw_Input_Data$,mat OpenString$,1)
         #Case# lw_ScanForm
            let fnSearchForm(mat lw_Input_Data$,1)
         #Case# lw_ScanDim
            let fnSearchDim(mat lw_Input_Data$,1)
         #Case# lw_ScanAll
            let fnScanAll(mat lw_Input_Data$,mat OpenString$)
         #Case# lw_ClearAll
            mat OpenString$(1)=("")
            let lw_Input_Data$(lw_ReadString)=""
            let lw_Input_Data$(lw_FormString)=""
            let lw_Input_Data$(lw_DimString)=""
         #Case# lw_PasteOpen
            mat OpenString$(0)
            let sd_dim$=env$("clipboard")
            let sd_dim$=srep$(sd_dim$,chr$(13),chr$(10))
            let sd_dim$=srep$(sd_dim$,chr$(10)&chr$(10),chr$(10))
            do while pos(sd_dim$,chr$(10))
               mat OpenString$(udim(mat OpenString$)+1)
               let Openstring$(udim(mat OpenString$))=trim$(sd_dim$(1:pos(sd_dim$,chr$(10))-1))
               let sd_dim$(1:pos(sd_dim$,chr$(10)))=""
            loop
            if len(trim$(sd_dim$)) then
               mat OpenString$(udim(mat OpenString$)+1)
               let Openstring$(udim(mat OpenString$))=trim$(sd_dim$)
               let sd_dim$=""
            end if
         #Case# lw_OpenScratchPad
            let fnOpenScratchFile
         #Case# lw_Generate
            let ExitMode=fnGenerateLay(mat OpenString$,lw_Input_Data$(lw_ReadString),lw_Input_Data$(lw_FormString),lw_Input_Data$(lw_DimString),1)
         #End Select#

      loop Until ExitMode

      close #Window:
   fnend

   def fnScanAll(mat lw_Input_Data$,mat OpenString$)
      if fnIsEmptys(mat OpenString$) then let fnSearchOpenString(mat lw_Input_Data$,mat OpenString$,1)
      let fnSearchRead(mat lw_Input_Data$,mat OpenString$,1)
      let fnSearchForm(mat lw_Input_Data$,1)
      let fnSearchDim(mat lw_Input_Data$,1)
   fnend

   ! 1) Program Name - Search all programs for open statements for the given file name
   ! if found, return program name and open statements
   dim FileList$(1)*255, sp_FileName$(1)*255
   def fnSearchPrograms(mat Openstring$,Folder$*255;___,Index,OpenIndex,FileName$*255,FileIndex,G$)

      if pos(Folder$,"\") then let Folder$=Folder$(1:pos(Folder$,"\",-1)-1)
      mat sp_FileName$(0)
      for OpenIndex=1 to udim(mat Openstring$)
         let FileName$=lwrc$(trim$(fnExtractFileName$(OpenString$(OpenIndex))))
         if len(FileName$) and srch(mat sp_Filename$,FileName$)<=0 then
            let FileIndex=udim(mat sp_fileName$)+1
            mat sp_FileName$(FileIndex)
            let sp_FileName$(FileIndex)=FileName$
         end if
      next OpenIndex

      if udim(mat sp_FileName$) then
         mat FileList$(0)
         library : fnReadFiles
         let fnReadFiles(mat FileList$,trim$(Folder$),"br ",1,0,1)
         let fnReadFiles(mat FileList$,trim$(Folder$),"wb ",0,0,1)

         for Index=1 to udim(Mat FileList$)
            if lwrc$(trim$(FileList$(Index)))<>"screenio.br" then
               let fnBuildProc("load """&trim$(folder$)&"\"&Trim$(fileList$(Index))&"""")
               let G$=">"
               for fileIndex=1 to udim(mat sp_FileName$)
                  let fnBuildProc("list 'open' '"&sp_FileName$(fileIndex)&"' "&G$&"temp.[wsid]")
                  let G$=">>"
               next fileIndex
               let fnBuildProc("run srchhelp")
               let fnBuildProc("skip "&str$(udim(mat sp_FileName$)*2+4)&" if code")
               let fnProcPrintToFile(trim$(folder$)&"\"&Trim$(fileList$(Index)))
               let fnBuildProc("load """&trim$(folder$)&"\"&Trim$(fileList$(Index))&"""")
               for fileIndex=1 to udim(mat sp_FileName$)
                  let fnProcListToFile("'open' '"&sp_FileName$(fileIndex)&"'")
               next fileIndex
            end if
         next Index

         let fnProcShowFile
         let fnRunProc
      end if
   fnend

   dim ResultString$*800,so_FileName$*127,so_results$(1)*800,so_files$(1)*127,so_count(1)

   ! 2) Open String - list all "open" and "internal" statements
   def fnSearchOpenString(mat lw_Input_Data$,mat OpenString$;DontShowFile,___,Resultsfile,Index,largest,largeindex,Jndex)
      if len(trim$(lw_input_data$(lw_programName))) then
         let fnBuildProc("load """&trim$(lw_input_data$(lw_programName))&"""")
         let fnProcListToFile("'open' 'internal'")
         if ~DontShowfile then let fnProcShowFile
         let fnClearTempFile
         let fnRunProc

         if exists("work.[wsid]") then
            open #(Resultsfile:=fnGetFilenumber): "name=work.[wsid],recl=800",display,input
            mat so_results$(0) : mat so_Files$(0) : mat so_Count(0)
            do until file(ResultsFile)
               linput #ResultsFile: ResultString$ error Ignore
               if file(ResultsFile)=0 then
                  let so_Filename$=lwrc$(trim$(fnExtractFileName$(ResultString$)))
                  if len(so_fileName$) then
                     let Index=udim(mat so_results$)+1
                     mat so_results$(Index)
                     let so_results$(Index)=trim$(Resultstring$)
                     let Index=srch(mat so_files$,so_FileName$)
                     if Index>0 then
                        let so_Count(Index)+=1
                     else
                        let Index=udim(mat so_Files$)+1
                        mat so_Files$(Index) : mat so_Count(Index)
                        let so_Files$(Index)=so_Filename$
                        let so_Count(Index)+=1
                     end if
                  end if
               end if
            loop
            close #ResultsFile:

            for index=1 to udim(mat so_Count)
               if so_Count(Index)>Largest then
                  let Largest=so_Count(Index)
                  let LargeIndex=Index
               end if
            next Index

            let Jndex=0
            for Index=1 to udim(mat so_results$)
               if so_Files$(LargeIndex)=lwrc$(trim$(fnExtractFileName$(so_results$(Index)))) then
                  let Jndex+=1
                  let so_results$(Jndex)=so_results$(Index)
               end if
            next Index
            mat so_results$(Jndex)
            if Jndex then
               mat OpenString$(Jndex)=so_results$
            end if
         end if
      end if
   fnend

   ! 3) Read Statement - Parse Open String, look for file number
   ! or variable name. list all read statements with that file
   ! number or variable name
   dim Var$*255
   def fnSearchRead(mat lw_Input_Data$,mat OpenString$;DontShowFile,___,KeyIndex,AnyThing,ResultsFile,Largest,LargeIndex)
      if len(trim$(lw_input_data$(lw_programName))) then

         for KeyIndex=1 to udim(mat OpenString$)
            ! parse the open statements
            if len(trim$(OpenString$(KeyIndex))) then
               let Var$=fnExtractOpenVar$(OpenString$(KeyIndex))                        ! Attempt to find open variable
               let fnBuildProc("load """&trim$(lw_input_data$(lw_programName))&"""")
               let fnProcListToFile("'read' '#"&Var$&"'")
               let AnyThing=1
            end if
         next KeyIndex

         if ~AnyThing then
            ! Scan the given file for all read statements if Open string didn't work
            let fnBuildProc("load """&trim$(lw_input_data$(lw_programName))&"""")
            let fnProcListToFile("'read'")
         end if

         if ~DontShowFile then let fnProcShowFile
         let fnClearTempFile
         let fnRunProc

         if exists("work.[wsid]") then
            open #(Resultsfile:=fnGetFilenumber): "name=work.[wsid],recl=800",display,input
            mat so_results$(0)
            do until file(ResultsFile)
               linput #ResultsFile: ResultString$ error Ignore
               if file(ResultsFile)=0 then
                  let Index=udim(mat so_results$)+1
                  mat so_results$(Index)
                  let so_results$(Index)=trim$(Resultstring$)
                  if len(so_results$(Index))>Largest then
                     let Largest=len(so_results$(Index))
                     let LargeIndex=Index
                  end if
               end if
            loop
            close #ResultsFile:
            if LargeIndex then let lw_Input_Data$(lw_ReadString)=so_results$(LargeIndex)
         end if
      end if
   fnend


   ! 4) Form Statement - Parse Read Statement, look for "Using lineref". If lineref is not a variable,
   ! (doesn't contain a "$"), then list that line. If it does contain a dollar sign, then list that
   ! variable to see where it gets set.
   dim LineRef$*800
   def fnSearchForm(mat lw_Input_Data$;DontShowFile,___,NoProc,Index,LargeIndex,Largest,Resultsfile)
      if len(trim$(lw_input_data$(lw_programName))) then
         if len(trim$(lw_Input_data$(lw_readString))) then
            let Lineref$=fnExtractLineref$(lw_Input_data$(lw_readString))               ! Attempt to find read string
            if LineRef$="" then
               let NoProc=1
            else if lwrc$(LineRef$(1:5))="""form" then
               let lw_Input_Data$(lw_FormString)=trim$(LineRef$,"""")
               let Noproc=1
            else if pos(LineRef$,"$") then
               let fnBuildProc("load """&trim$(lw_input_data$(lw_programName))&"""")
               let fnBuildProc("list '"&LineRef$&"' >temp.[wsid]")                      ! Attempt to use line ref
               let fnBuildProc("run srchhelp")                                          ! check if it worked
               let fnBuildProc("skip printregular if code")                             ! if it failed, jump to regular print
               let fnBuildProc("load """&trim$(lw_input_data$(lw_programName))&"""")    ! if it worked, then use it
               let fnProcListToFile(LineRef$)
               let fnBuildProc("skip finished")                                         ! Skip regular print if it worked
            else
               let fnBuildProc("load """&trim$(lw_input_data$(lw_programName))&"""")
               let fnBuildProc("list "&LineRef$&" >temp.[wsid]")                        ! Attempt to use line ref
               let fnBuildProc("run srchhelp")                                          ! check if it worked
               let fnBuildProc("skip printregular if code")                             ! if it failed, jump to regular print
               let fnBuildProc("load """&trim$(lw_input_data$(lw_programName))&"""")    ! if it worked, then use it
               let fnProcListToFile(LineRef$,1)
               let fnBuildProc("skip finished")                                         ! Skip regular print if it worked
            end if
         end if
         if ~NoProc then
            let fnBuildProc(":printregular")
            let fnBuildProc("load """&trim$(lw_input_data$(lw_programName))&"""")
            let fnProcListToFile("form")
            let fnBuildProc(":finished")
            if ~DontShowFile then let fnProcShowFile
            let fnClearTempFile
            let fnRunProc

            if exists("work.[wsid]") then
               open #(Resultsfile:=fnGetFilenumber): "name=work.[wsid],recl=800",display,input
               mat so_results$(0)
               do until file(ResultsFile)
                  linput #ResultsFile: ResultString$ error Ignore
                  if file(ResultsFile)=0 then
                     let Index=udim(mat so_results$)+1
                     mat so_results$(Index)
                     let so_results$(Index)=trim$(Resultstring$)
                     if len(so_results$(Index))>Largest then
                        let Largest=len(so_results$(Index))
                        let LargeIndex=Index
                     end if
                  end if
               loop
               close #ResultsFile:
               if LargeIndex then let lw_Input_Data$(lw_FormString)=so_results$(LargeIndex)
            end if

         end if
      end if
   fnend

   dim sd_Arrays$(1)*127
   dim sd_Dim$*20000

   ! 5) Dim Statement - Parse Read Statement, look for any "Mat" variables. for each one thats found, load
   ! the program, list 'dim' 'arrayname'. If no read statement, list all dims
   def fnSearchDim(mat lw_Input_Data$;DontShowFile,___,tpos,string$*999,sPos,cPos,xPos,Index,ResultsFile)
      if len(trim$(lw_input_data$(lw_programName))) then
         let fnBuildProc("load """&trim$(lw_input_data$(lw_programName))&"""")
         if len(trim$(lw_Input_data$(lw_readString))) then
            mat sd_Arrays$(0)
            let tPos=0
            let string$=lwrc$(trim$(lw_Input_Data$(lw_readString)))
            do while (tPos:=pos(string$,"mat"))
               let cPos=pos(String$,",",tpos+4)
               let sPos=pos(String$," ",tpos+4)
               if cPos and sPos then
                  let xPos=min(cPos,sPos) ! whichever comes first
               else
                  let xPos=max(cPos,sPos) ! whichever one there is
               end if
               if ~xPos then let xPos=len(String$)+1 ! the rest of the string

               let Var$=trim$(String$(tpos+3:xPos-1))
               let string$=String$(xPos-1:len(string$))
               let fnProcListToFile("'dim' '"&Var$&"('")
               let Index=udim(mat sd_arrays$)+1
               mat sd_Arrays$(Index)
               let sd_Arrays$(Index)=Var$
            loop
         else
            let fnProcListToFile("dim")
         end if
         if ~DontShowFile then let fnProcShowFile
         let fnClearTempFile
         let fnRunProc

         if exists("work.[wsid]") then
            open #(Resultsfile:=fnGetFilenumber): "name=work.[wsid],recl=800",display,input
            let sd_Dim$=""
            do until file(ResultsFile)
               linput #ResultsFile: ResultString$ error Ignore
               if file(ResultsFile)=0 then
                  let sd_Dim$=sd_Dim$&lwrc$(trim$(ResultString$))
               end if
            loop
            let lw_Input_Data$(lw_DimString)="dim "
            for Index=1 to udim(mat sd_Arrays$)
               let lw_Input_Data$(lw_DimString)=lw_Input_Data$(lw_DimString)&sd_Arrays$(Index)&"("&str$(fnReadArraySize(sd_dim$,sd_arrays$(Index)))&"), "
            next Index
            close #ResultsFile:
         end if
      end if
   fnend


   def library Fnreadfiles(Mat Files$,Folder$*255;Extension$,Cleararray,Createfolder,Includeextensions,UseWindowsDIR,___,Dirfile,Dummy$*255,DirMask$*400,Star$)
      ! Note: The UseWindowsDIR parameter uses the windows Dir command instead of BRs in order to read long file names. It will not work under linux.

      let Star$=fnNeedStar$
      if ClearArray then mat Files$(0)
!
      if CreateFolder then
         if ~Exists(Folder$) then execute Star$&"mkdir "&Folder$
      end if
!
      if ~Len(Trim$(Extension$)) then let Extension$="*"
      let DirMask$=Folder$&"\*."&Lwrc$(Extension$)
!
      if UseWindowsDIR then
         let fnWindowsReadFiles
      else
         let fnStandardReadFiles
      end if
   fnend

   ! These two functions act globally like they're a part of fnReadFiles above.
   def fnWindowsReadFiles(;___,FileName$*255,Ext$*255)
      execute Star$&"system -M dir "&os_filename$(DirMask$)&" >dirlist."&Session$ error SkipReadWindows
      open #(Dirfile:=Fngetfilenumber) : "Name=dirlist.[SESSION], recl=255", display,input
      do
         linput #Dirfile: Dummy$ eof IGNORE
         if File(Dirfile)=0 and Dummy$(3:3)="/" and Dummy$(6:6)="/" and ~Pos(Dummy$,"<DIR>") then
            let FileName$=Trim$(Dummy$(40:999))
            let Ext$=""
            if Pos(FileName$,".")>0 then
               let Ext$=FileName$(pos(FileName$,".",-1)+1:999)
               if ~IncludeExtensions then
                  let FileName$(pos(FileName$,".",-1):999)=""
               end if
            end if

            if Extension$="*" Or Uprc$(Ext$)=Uprc$(Extension$) then
               mat Files$(Udim(Files$)+1)
               let Files$(Udim(Files$))=FileName$
            end if
         end if
      loop While File(Dirfile)=0
      close #Dirfile:
      SkipReadWindows: !
      execute Star$&"free dirlist.[SESSION]"
   fnend

   ! These two functions act globally like they're a part of fnReadFiles above.
   def fnStandardReadFiles
      execute Star$&"dir "&DirMask$&" >dirlist.[SESSION]" error skipreadStandard
      open #(Dirfile:=Fngetfilenumber) : "Name=dirlist.[SESSION]", display,input
      do
         linput #Dirfile: Dummy$ eof IGNORE
         if File(Dirfile)=0 And ~Pos(Dummy$,"<DIR>") then
            if Extension$="*" Or Uprc$(Dummy$(11:13))=Uprc$(Extension$) then
               if lwrc$(Dummy$(1:13))><"directory of " then
                  if ~(pos(Dummy$," Files, ") and pos(Dummy$," Kilobytes Used, ") and pos(Dummy$," Kilobytes Free")) then
                     mat Files$(Udim(Files$)+1)
                     let Files$(Udim(Files$))=Lwrc$(Trim$(Dummy$(44:99))(1:32))
                     if Pos(Lwrc$(Files$(Udim(Files$))),".")>0 then
                        let Files$(Udim(Files$))=Files$(Udim(Files$))(1:Pos(Lwrc$(Files$(Udim(Files$))),".")-1)
                        if Includeextensions then
                           let Files$(Udim(Files$))=Files$(Udim(Files$))&"."&lwrc$(Dummy$(11:13))
                        end if
                     end if
                  end if
               end if
            end if
         end if
      loop While File(Dirfile)=0
      close #Dirfile:
      skipReadStandard: !
      execute Star$&"free dirlist.[SESSION]"
   fnend

   def fnExtractFileName$*255(&OpenString$)=fnExtractName$("name=",OpenString$)
   def fnExtractKeyFileName$*255(&OpenString$)=fnExtractName$("kfname=",OpenString$)
   def fnExtractName$*255(SearchString$,&OpenString$;___,tpos,ReturnName$*255,spos,SearchStringLen)
      let tpos=pos(lwrc$(OpenString$),SearchString$)
      if tpos then
         let SearchStringLen=len(SearchString$)
         let ReturnName$=OpenString$(tpos+SearchStringLen:pos(lwrc$(OpenString$),",",tpos+SearchStringLen)-1)

         let spos=pos(ReturnName$,"/")
         if spos then   ! If linux style, reverse to be Windows style
            let ReturnName$=ReturnName$(spos+1:len(ReturnName$))&"\"&ReturnName$(1:spos-1)
         end if
         let fnExtractName$=ReturnName$
      end if
   fnend

   def fnExtractOpenVar$*512(&OpenString$;___,Var$*512,Index,tPos,Return$*512)
      let tPos=pos(OpenString$,"#")
      let Var$=OpenString$(tpos:pos(OpenString$,":",tpos+1))

      ! Skip past any junk characters such as ( and " "
      do until (Index:=Index+1)>len(Var$)
      loop until pos("0123456789abcdefghijklmnopqrstuvwxyz",lwrc$(Var$(Index:Index)))

      ! read the first contiguous string of characters thats either a number or a variable
      do while Index<=len(Var$) and pos("0123456789abcdefghijklmnopqrstuvwxyz",lwrc$(Var$(Index:Index)))
         let Return$=Return$&Var$(Index:Index)
         let Index+=1
      loop
      let fnExtractOpenVar$=Return$
   fnend

   def fnExtractLineref$*800(&ReadString$;___,Var$*800,Index,tPos,Return$*512,bQuotesOn)
      let tPos=pos(lwrc$(ReadString$),"using")
      if tpos>0 then
         let Var$=trim$(ReadString$(tpos+5:len(ReadString$)))

         do while (Index:=Index+1)<=len(Var$)
            if Var$(Index:Index)="""" then let bQuotesOn=~bQuotesOn
            let Return$=Return$&Var$(Index:Index)
         loop until (~bQuotesOn and (Var$(Index:Index)=="," or Var$(Index:Index)==":"))
         if Return$(len(Return$):len(Return$))="," then let Return$=Return$(1:len(Return$)-1)
         if Return$(len(Return$):len(Return$))=":" then let Return$=Return$(1:len(Return$)-1)
         let fnExtractLineRef$=trim$(Return$)
      end if
   fnend

   ! Proc File Engine
   ! **********************
   dim ProcFileNumber, ProcCompileNumber

   TryNextNumber: ! Try a new number
   let CompileNumber+=1
   retry

   def fnOpenProc
      open #(ProcFileNumber:=Fngetfilenumber): "name=compile"&str$(CompileNumber)&".$$$, replace", display, output error TryNextNumber
      print #ProcFileNumber: "proc noecho"
   fnend

   def fnBuildSrchHelp(;Nowait)
      if ~exists("srchhelp.br") then
         let fnBuildProc("00010 DIM RECORD$*800")
         let fnBuildProc("00020 OPEN #1: ""Name= temp.[wsid]"", DISPLAY, INPUT")
         let fnBuildProc("00030 LINPUT #1: RECORD$ EOF STOP1")
         let fnBuildProc("00040 STOP")
         let fnBuildProc("00050 STOP1: STOP 1")
         let fnBuildProc("save srchhelp.br")
         let fnRunProc(Nowait)
      end if
   fnend

   def library fnBuildProcFile(String$*255)=fnBuildProc(String$)
   def fnBuildProc(String$*255)
      if ~ProcFileNumber then let fnOpenProc
      print #ProcFileNumber: String$
   fnend

   def library fnRunProcFile(;NoWait)=fnRunProc(Nowait)
   def fnRunProc(;NoWait,___,C$,Star$)
      let Star$=fnNeedStar$
      if ProcFileNumber then
         print #ProcFileNumber: "system"
         close #ProcFileNumber:
         let ProcFileNumber=0
         if NoWait then let C$=" -C"
         ! execute "type compile"&str$(CompileNumber)&".$$$"
         ! pause
         execute Star$&"system"&C$&" -M "&Fngetbrexe$&" -"&Fngetwbcfg$&" proc compile"&str$(CompileNumber)&".$$$"
      end if
   fnend

   def fnProcPrintToFile(String$*255)
      let fnBuildProc("open #1: ""name=filelay\scratchpaper.brs"",display,output")
      let fnBuildProc("print #1: """&String$&"""")
      let fnBuildProc("close #1: ")
   fnend
   def fnProcListtoFile(String$*255;DontAddQuotes)
      if ~DontAddQuotes then
         if String$(1:1)<>"'" then let String$(1:0)="'"
         if String$(len(String$):len(String$))<>"'" then let String$=String$&"'"
      end if
      let fnBuildProc("list "&String$&" >>filelay\scratchpaper.brs")
      let fnBuildProc("list "&String$&" >>work."&wsid$) ! use this WSID, not the procs WSID
   fnend
   def fnClearTempFile
      if exists ("work.[WSID]") then execute fnNeedStar$&"free work.[WSID]"
   fnend
   def fnProcShowFile
      let fnBuildProc(fnNeedStar$&"system -C -M start filelay\scratchpaper.brs")
   fnend
   def fnOpenScratchFile
      execute fnNeedStar$&"system -C -M start filelay\scratchpaper.brs"
   fnend

! **********************************************************************
! Functions To Get Info From Config.Sys Files. By Susan Smith.
!  Updated By Gabriel Bakker, To Save Time By Running Only Once.
!
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
   def Fnreadconfigandexe(;___,Cr$,Filenumber,Qstart,Qend,Star$)
      let Star$=fnNeedStar$
      let Cr$=Hex$("0D0A")
      execute Star$&"status files >TEMPFILE.[session]"
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
      if Exists("c:\TEMPFILE.[session]") then execute Star$&"free TEMPFILE.[session] -N"
   fnend


   dim gl_filename$*127,gl_Ver,gl_Pre$, gl_recl, gl_Name$*127
   dim gl_kfname$(1)*127,gl_kpos$(1)*50,gl_klen$(1)*50,gl_kdescription$(1)*255
   dim gl_subs$(1)*127,gl_descr$(1)*127,gl_Form$(1)*50,gl_Extra$(1)*255
   dim gl_TempSubs$(1)*127,gl_TempDescr$(1)*127,gl_TempForm$(1)*50,gl_Mapping(1)

   dim gl_kfName$*127
   dim gl_ErrorMessage$*512
   dim gl_TempFileName$*127
   dim FormString$*32000
   def libarary fnGenerateLayout(mat Open_string$,Read_string$*999,Form_string$*20000,Dim_String$*999;DisplayFile)=fnGenerateLay(mat Open_String$,Read_String$,Form_String$,Dim_String$,DisplayFile)
   def fnGenerateLay(mat OpenString$,&ReadString$,&_FormString$,&DimString$;DisplayFile,___,Index,TFile,TPos,KeyIndex,Size,Jndex,FailedRead,FailedForm,FailedMatch,FailedHeader,FailedKey,fPos,Width,kpPos,klPos,kpos,klen)
      let FormString$=_FormString$

      ! Attempt to parse data, or at least get as far as we can
      !  Give error message when we get stuck
      !  Generate the layout with success message when it works
      !  Return ExitMode when success

      ! Eventually we can call this code from a function that
      !  searches someones software suite.

      ! Clear values
      mat gl_kfname$(0) : mat gl_kpos$(0)
      mat gl_klen$(0) : mat gl_kDescription$(0)
      let gl_FileName$=gl_Pre$=gl_Name$=""
      let gl_kfName$=gl_ErrorMessage$=gl_TempFileName$=""
      let gl_Ver=gl_recl=0

      let KeyIndex=0

      for OpenIndex=1 to udim(mat OpenString$)
         ! Parse Open String
         if len(Openstring$(OpenIndex)) then
            let gl_TempfileName$=fnExtractName$("name=",OpenString$(OpenIndex))
            if ~len(gl_Filename$) then let gl_FileName$=gl_TempfileName$

            if len(gl_FileName$) and gl_FileName$=gl_TempFileName$ then
               let gl_kfname$=fnExtractName$("kfname=",OpenString$(OpenIndex))

               if len(gl_kfname$) then
                  open #(tFile:=fnGetFileNumber): "name="&gl_filename$&", kfname="&gl_kfname$, internal, input, keyed error Ignore
                  let KeyIndex=udim(mat gl_kfname$)+1
                  mat gl_kfname$(KeyIndex) : mat gl_kpos$(KeyIndex)
                  mat gl_klen$(KeyIndex) : mat gl_kDescription$(KeyIndex)
                  let gl_kfName$(KeyIndex)=gl_kfname$
               else
                  open #(tFile:=fnGetFileNumber): "name="&gl_filename$, internal, input, relative error Ignore
               end if

               if file(tFile)=0 then
                  let gl_ver=version(tFile)
                  let gl_Name$=gl_filename$(pos(gl_filename$,"\",-1)+1:len(gl_filename$))
                  if pos(gl_Name$,".") then
                     let gl_Name$=gl_Name$(1:pos(gl_Name$,".")-1)
                  end if
                  let gl_Name$=gl_Name$(1:18)
                  let gl_Pre$=trim$(gl_Name$)(1:4)&"_"
                  let gl_recl=rln(tFile)
                  if kps(tFile)>-1 then
                     let gl_kpos$(KeyIndex)=""
                     let gl_klen$(KeyIndex)=""
                     let Index=0
                     do while kps(tFile,(Index:=Index+1))>-1
                        let gl_kpos$(KeyIndex)=gl_kpos$(KeyIndex)&str$(kps(tFile,Index))&"/"
                        let gl_klen$(KeyIndex)=gl_klen$(KeyIndex)&str$(kln(tFile,Index))&"/"
                     loop
                     let gl_kpos$(KeyIndex)=gl_kpos$(KeyIndex)(1:len(gl_kpos$(KeyIndex))-1)
                     let gl_klen$(KeyIndex)=gl_klen$(KeyIndex)(1:len(gl_klen$(KeyIndex))-1)
                  end if
                  close #tfile:
               end if
            end if
         end if
      next OpenIndex

      if ~len(gl_filename$) then let FailedHeader=1

      mat gl_TempSubs$(0) : mat gl_TempDescr$(0) : mat gl_TempForm$(0) : mat gl_Mapping(0)
      mat gl_Subs$(0) : mat gl_Descr$(0) : mat gl_Form$(0) : mat gl_Extra$(0)
      if len(ReadString$) and len(FormString$) then

         ! Parse Read String
         ! unpack read string
         ! search in form string for each array
         ! use array size from form string to expand each array into one giant list of subscripts
         let tPos=pos(ReadString$,":",-1)
         do while len(var$:=fnExtractChunk$(ReadString$,TPos))
            if lwrc$(var$(1:3))="mat" then
               let Size=fnReadArraySize(DimString$,var$(5:len(var$)))
               if Size then
                  let Index=udim(mat gl_TempSubs$)
                  mat gl_TempSubs$(Index+Size) : mat gl_TempDescr$(Index+Size)
                  for Jndex=Index+1 to Index+Size
                     if pos(var$,"$") then
                        let gl_TempSubs$(Jndex)=srep$(Var$(5:len(var$)),"$","")&str$(Jndex-Index)&"$"
                     else
                        let gl_TempSubs$(Jndex)=Var$(5:len(var$))&str$(Jndex-Index)
                     end if
                     let gl_TempDescr$(Jndex)=srep$(Var$(5:len(var$)),"$","")&str$(Jndex-Index)
                  next Jndex
                  if pos(var$,"$") then
                     let gl_TempSubs$(Index+Size)=srep$(Var$(5:len(var$)),"$","")&"L$"
                  else
                     let gl_TempSubs$(Index+Size)=Var$(5:len(var$))&"L"
                  end if

               else
                  FailedRead=1
               end if
            else
               let Index=udim(mat gl_TempSubs$)+1
               mat gl_TempSubs$(Index) : mat gl_TempDescr$(Index)
               let gl_TempSubs$(Index)=Var$
               let gl_TempDescr$(Index)=srep$(Var$,"$","")
            end if
         loop until FailedRead

         ! Parse Form String
         ! 1) Unpack form string
         let fnUnpackFormString(FormString$)

         let tPos=pos(lwrc$(FormString$),"form ")
         if tPos then let tPos+=4 else let FailedForm=1

         let fPos=0

         do while len(var$:=fnExtractForm$(FormString$,TPos))
            if lwrc$(var$(1:4))="pos " then
               let fPos=val(var$(5:len(Var$)))-1 conv Ignore
            else if lwrc$(var$(1:2))="x " then
               let fPos+=val(var$(3:len(Var$))) conv Ignore
            else
               let Index=udim(mat gl_TempForm$)+1
               mat gl_TempForm$(Index)
               let gl_TempForm$(Index)=Var$

               ! Find width
               let Width=fnLengthOf(Var$)

               if Width then
                  ! expand Mapping
                  mat gl_Mapping(max(udim(Mat gl_Mapping),fPos+Width))
                  mat gl_Mapping(fpos+1:fPos+Width)=(Index)
               else
                  let FailedForm=1
               end if
               let fPos+=Width
            end if
         loop until FailedForm

         let Index=0
         let LastNum=-1
         let StartPos=0

         ! Read Map, find length of consequetive vars
         do while (Index:=Index+1)<=udim(mat gl_Mapping)+1
            if Index>udim(mat gl_Mapping) or LastNum<>gl_Mapping(Index) then
               if LastNum<>-1 then

                  ! Found one, Process it
                  let Jndex=udim(mat gl_Subs$)+1
                  mat gl_Subs$(Jndex)
                  mat gl_Descr$(Jndex)
                  mat gl_Form$(Jndex)
                  mat gl_Extra$(Jndex)

                  if LastNum then
                     if Index-StartPos=fnLengthOf(gl_TempForm$(LastNum)) then
                        ! Its good, use it
                        if udim(mat gl_TempSubs$)>=LastNum then
                           let gl_Subs$(Jndex)=gl_TempSubs$(LastNum)
                           let gl_Descr$(Jndex)=gl_TempDescr$(LastNum)
                        else
                           let gl_Subs$(Jndex)="_"
                           let gl_Descr$(Jndex)=""
                        end if
                        let gl_Form$(Jndex)=gl_TempForm$(LastNum)
                     else
                        ! Error. Set it and return error.
                        if udim(mat gl_Tempsubs$)>=LastNum then
                           let gl_Subs$(Jndex)=gl_TempSubs$(LastNum)
                           let gl_Descr$(Jndex)=gl_TempDescr$(LastNum)
                        else
                           let gl_Subs$(Jndex)="_"
                           let gl_Descr$(Jndex)=""
                        end if
                        let gl_Form$(Jndex)="C "&str$(Index-StartPos)
                        let gl_Extra$(Jndex)="Error. Width: "&str$(Index-StartPos)&" but Form: "&gl_TempForm$(LastNum)
                        let FailedMatch=1
                     end if
                  else
                     ! unknown make it an X
                     let gl_Subs$(Jndex)="_"
                     let gl_Form$(Jndex)="X "&str$(Index-StartPos)
                     let gl_Descr$(Jndex)="Unknown / Unused"
                  end if
               end if
               if Index<=udim(mat gl_Mapping) then let LastNum=gl_Mapping(Index)
               let StartPos=Index
            end if
         loop
      else
         if ~len(ReadString$) then let FailedRead=1
         if ~len(FormString$) then let FailedForm=1
      end if

      ! Figure out Keys, mat gl_kpos$,mat gl_klen$,mat gl_kDescription$
      for KeyIndex=1 to udim(mat gl_KDescription$)
         ! Read each chunk of gl_kPos$ and gl_kLen$
         let KpPos=KlPos=0
         do while (kpos:=fnExtractKPS(gl_kPos$(KeyIndex),kpPos))
            let klen=fnExtractKLN(gl_kLen$(KeyIndex),klPos)
            if kLen then
               ! must do a reverse lookup against mat gl_Mapping
               ! to calculate mat gl_kDescription$

               let Index=kPos-1
               let LastNum=-1

               ! Read Map, find consequetive nums
               do while (Index:=Index+1)<klen+kpos
                  if Index<=udim(mat gl_Mapping) then
                     if LastNum<>gl_Mapping(Index) then
                        ! Found one, Process it
                        if len(gl_Kdescription$(KeyIndex)) then let gl_kDescription$(KeyIndex)=gl_kDescription$(KeyIndex)&"/"
                        if gl_Mapping(Index)<=udim(mat gl_TempSubs$) and gl_Mapping(Index)>0 then
                           let gl_kDescription$(KeyIndex)=gl_kDescription$(KeyIndex)&srep$(gl_tempSubs$(gl_Mapping(Index)),"$","")
                        else
                           let gl_kDescription$(KeyIndex)=gl_kDescription$(KeyIndex)&"Unknown"
                           let FailedKey=1
                        end if

                        let LastNum=gl_Mapping(Index)
                     end if
                  end if
               loop
            else
               if len(gl_Kdescription$(KeyIndex)) then let gl_kDescription$(KeyIndex)=gl_kDescription$(KeyIndex)&"/"
               let gl_kDescription$(KeyIndex)=gl_kDescription$(KeyIndex)&"Unknown"
               let FailedKey=1
            end if
         loop
      next KeyIndex

      ! if name is blank then generate a work filename
      if ~len(gl_Name$) then let gl_Name$="templayout"&session$
      ! if Recl matches gl_Mapping then autogenerate recl
      if gl_Recl=udim(gl_Mapping) then let gl_Recl=0

      ! Burn Layout
      let fnWriteLay(gl_Name$,gl_filename$,gl_Ver,gl_Pre$,mat gl_kfname$,mat gl_kdescription$,mat gl_subs$,mat gl_descr$,mat gl_Form$,gl_recl,mat gl_Extra$,DisplayFile)

      ! if errors in Header or Detail, print message box
      let gl_ErrorMessage$=""
      if FailedHeader then let gl_ErrorMessage$=gl_ErrorMessage$&"We were unable to properly build the Header. Check your open statements."&chr$(13)&chr$(10)
      if FailedKey then let gl_ErrorMessage$=gl_ErrorMessage$&"We were unable to figure out the keys. Check your open and read statements."&chr$(13)&chr$(10)
      if FailedRead then let gl_ErrorMessage$=gl_ErrorMessage$&"We were unable to figure out the variable names. Check your read statement and dim statement."&chr$(13)&chr$(10)
      if FailedForm then let gl_ErrorMessage$=gl_ErrorMessage$&"We were unable to figure out the form specs. Check your form statement."&chr$(13)&chr$(10)
      if FailedMatch then let gl_ErrorMessage$=gl_ErrorMessage$&"There was a problem matching your layout specs. Check your Read, Dim and Form statements."&chr$(13)&chr$(10)

      ! Return error
      if FailedRead or FailedForm or FailedMatch or FailedHeader or FailedKey then
         let msgbox(gl_ErrorMessage$,"I need more information.","Ok")
      else
         let fnGenerateLay=1
      end if
   fnend

   def library fnWriteLayout(Name$,filename$*127,Ver,Pre$,mat kfname$,mat kdescription$,mat subs$,mat descr$,mat Form$;Recl,mat Extra$,DisplayFile)=fnWriteLay(Name$,filename$,Ver,Pre$,mat kfname$,mat kdescription$,mat subs$,mat descr$,mat Form$,Recl,mat Extra$)
   def fnWriteLay(Name$,filename$*127,Ver,Pre$,mat kfname$,mat kdescription$,mat subs$,mat descr$,mat Form$;Recl,mat Extra$,___,FileNumber,Index,WidestSub,WidestDescr,WidestForm,Filelayoutpath$*255,FileLayoutExtension$)

      let Filelayoutpath$=fnSettings$("layoutpath")
      let FileLayoutExtension$=fnSettings$("layoutextension")

      library : fnGetFileNumber

      open #(FileNumber:=fnGetFileNumber): "name="&Filelayoutpath$&Name$&FileLayoutExtension$&", recl=1000,replace",display,output
      print #FileNumber: filename$&", "&Pre$&", "&str$(Ver)
      for Index=1 to udim(mat KfName$)
         print #FileNumber: KfName$(Index)&", "&KDescription$(Index)
      next Index
      if Recl then
         print #FileNumber: "recl="&str$(Recl)
      end if

      ! Minimums
      let WidestSub=10
      let WidestDescr=30
      let WidestForm=6
      ! Calculate width of output
      for Index=1 to udim(mat Subs$)
         let WidestSub=max(WidestSub,len(Subs$(Index)))
         let WidestDescr=max(WidestDescr,len(Descr$(Index)))
         let WidestForm=max(WidestForm,len(Form$(Index)))
      next Index
      print #FileNumber: rpt$("=",WidestSub+2+WidestDescr+2+WidestForm)
      for Index=1 to udim(mat Subs$)
         if Index<=udim(mat Extra$) and len(Extra$(Index)) then
            print #FileNumber: rpad$(Subs$(Index)&", ",WidestSub+2)&rPad$(Descr$(Index)&", ",WidestDescr+2)&lPad$(Form$(Index),WidestForm)&", "&Extra$(Index)
         else
            print #FileNumber: rpad$(Subs$(Index)&", ",WidestSub+2)&rPad$(Descr$(Index)&", ",WidestDescr+2)&lPad$(Form$(Index),WidestForm)
         end if
      next Index
      close #FileNumber:

      if FileLayoutExtension$="" or FileLayoutExtension$="." then
         if DisplayFile then execute fnNeedStar$&"sy -C -M start notepad "&Filelayoutpath$&name$ ! Have to force notepad because there's no ext to assoc in windows.
      else
         if DisplayFile then execute fnNeedStar$&"sy -C -M start "&Filelayoutpath$&name$&FileLayoutExtension$  ! Just call default program, they have an ext to associate.
      end if
   fnend

   dim fs_Chunk$*800
   dim fs_Replace$*2000
   def fnUnpackFormString(&FormString$;___,pLevel,sPos,ePos,nPos,Index,Num)
      ! unpack the form string
      !  needs to handle:
      !   form C 10,DATE(mm/dd/ccyy),2*(C 10),2*(C 15,C 10),4*(C 15,FMT(##),3*FMT(###))
      !   form C 10,DATE(mm/dd/ccyy),C 10,C 10,C 15,C 10,C 15,C 10,C 15,FMT(##),FMT(###),FMT(###),FMT(###),C 15,FMT(##),FMT(###),FMT(###),FMT(###),C 15,FMT(##),FMT(###),FMT(###),FMT(###),C 15,FMT(##),FMT(###),FMT(###),FMT(###)

      do while (sPos:=pos(FormString$,"*"))    ! find first *
         do while FormString$(Spos+1:Spos+1)=" "
            let FormString$(Spos+1:Spos+1)=""
         loop
         ! Find Chunk
         if FormString$(sPos:sPos+1)="*(" then ! if next char is "("
            let ePos=sPos                      ! find matching ")"
            do                           ! go through string counting
               let ePos+=1               ! parens until we're at match
               if FormString$(ePos:ePos)="(" then let pLevel+=1
               if FormString$(ePos:ePos)=")" then let pLevel-=1
            loop while pLevel
            let fs_Chunk$=FormString$(sPos+2:ePos-1)&","
         else ! if its not a "*(" then
            let ePos=pos(FormString$,",",sPos) ! look for the next ","
            if ~ePos then let ePos=len(FormString$)+1
            let fs_Chunk$=FormString$(sPos+1:ePos-1)&","
            let ePos-=1
         end if

         ! Find Number
         let nPos=sPos
         do while (nPos:=nPos-1)
         loop while pos("0123456789 ",FormString$(nPos:nPos))
         let Num=val(srep$(FormString$(nPos+1:sPos-1)," ",""))

         ! Then Substitute
         let fs_Replace$=rpt$(fs_Chunk$,Num)
         let fs_Replace$=fs_Replace$(1:len(fs_Replace$)-1)
         let FormString$(nPos+1:ePos)=fs_Replace$
      loop        !     go until there's no *
   fnend

   !  needs to handle:
   !   form C 10,DATE(mm/dd/ccyy),2*(C 10),2*(C 15,C 10),4*(C 15,FMT(##),3*FMT(###))
   !   form C 10,DATE(mm/dd/ccyy),C 10,C 10,2*(C 15,C 10),4*(C 15,FMT(##),3*FMT(###))
   !   form C 10,DATE(mm/dd/ccyy),C 10,C 10,C 15,C 10,C 15,C 10,4*(C 15,FMT(##),3*FMT(###))
   !   form C 10,DATE(mm/dd/ccyy),C 10,C 10,C 15,C 10,C 15,C 10,C 15,FMT(##),3*FMT(###),C 15,FMT(##),3*FMT(###),C 15,FMT(##),3*FMT(###),C 15,FMT(##),3*FMT(###)
   !   form C 10,DATE(mm/dd/ccyy),C 10,C 10,C 15,C 10,C 15,C 10,C 15,FMT(##),FMT(###),FMT(###),FMT(###),C 15,FMT(##),FMT(###),FMT(###),FMT(###),C 15,FMT(##),FMT(###),FMT(###),FMT(###),C 15,FMT(##),FMT(###),FMT(###),FMT(###)

   def fnExtractChunk$*255(&ReadString$,&tPos;___,cPos,sPos,xPos)
      do while (ReadString$(tPos+1:tPos+1)=" ")
         let tPos+=1
      loop
      let cPos=pos(readString$,",",tpos+1)
      let sPos=pos(readString$," ",tpos+1)
      if lwrc$(ReadString$(tPos+1:sPos-1))="mat" then
         let sPos=pos(readString$," ",sPos+1)
      end if
      if cPos and sPos then
         let xPos=min(cPos,sPos)
      else
         let xPos=max(cPos,sPos)
      end if
      if ~xPos then let xPos=len(ReadString$)+1
      let fnExtractChunk$=trim$(ReadString$(tPos+1:xPos-1))
      if ~cPos then let cPos=len(ReadString$)+1
      let tPos=cPos
   fnend

   def fnExtractForm$*255(&FormString$,&tPos;___,xPos)
      let xPos=pos(FormString$,",",tpos+1)
      if ~xPos then let xPos=len(FormString$)+1
      let fnExtractForm$=trim$(FormString$(tPos+1:xPos-1))
      let tPos=xPos
   fnend

   def fnExtractKPS(&KPSString$,&tPos;___,xPos,kpos)
      let xPos=pos(KPSString$,"/",tpos+1)
      if ~xPos then let xPos=len(KPSString$)+1
      let kpos=val(KPSString$(tPos+1:xPos-1)) conv Ignore
      let fnExtractKPS=kpos
      let tPos=xPos
   fnend

   def fnExtractKLN(&KLNString$,&tPos;___,xPos,klen)
      let xPos=pos(KLNString$,"/",tpos+1)
      if ~xPos then let xPos=len(KLNString$)+1
      let klen=val(KLNString$(tPos+1:xPos-1)) conv Ignore
      let fnExtractKLN=klen
      let tPos=xPos
   fnend

   def fnReadArraySize(&DimString$,Varname$*255;___,tPos,Size$,pPos)
      let tPos=pos(lwrc$(DimString$),lwrc$(Varname$))
      if tPos then tPos+=len(VarName$)
      if DimString$(tpos:tpos)="(" then
         let pPos=pos(Dimstring$,")",tpos+1)
         if pPos then
            let Size$=DimString$(tPos+1:pPos-1)
            let fnReadArraySize=0
            let fnReadArraySize=val(Size$) conv Ignore
         end if
      end if
   fnend

!
! #Autonumber# 19000,10
FILEIOLIBRARY: ! ********************* File Library ********************
!
!
GETFILENUMBER: ! This Function Finds The Next Empty File Channel
   def library Fngetfilenumber(;Start,Count,___,I)
      if Start=-1 then
         let Start=fnSettings("startfilenumber")
      end if
      if (Start) then let Start-=1
      let Count=max(Count,1)
      do
         if Start>=199 and Start<300 then let Start=300 : let I=0 ! Skip over the invalid 200s
         if File(Start:=Start+1)=-1 then
            let I=I+1
         else
            let I=0
         end if
      loop until I=Count
      let Fngetfilenumber=(Start-(Count-1))
   fnend

   def fnResetErrorHandling
      if IgnoreErrors then
         on error goto ReturnFailed
      else
         on error system  ! Turn Error Checking Back Off
      end if
   fnend
!
! SupressPrompt suppresses the "File Not Found, Create?" prompt
! SupressPrompt = 1 for Don't Create the File, don't error, just don't open it (return 0)
! SupressPrompt = 2 Don't Prompt, Always Create the file
!
! #Autonumber# 20000,5
OPENFILE: ! This Function Opens The Requested File And Returns Filenum
   def library Fnopenfile(&Filename$, Mat F$, Mat F, Mat Form$;Inputonly,Keynum,Dont_Sort_Subs,&Path$,Mat Description$,Mat Fieldwidths,Mat FileIOSubs$,SupressPrompt,IgnoreErrors,CallingProgram$*255,SuppressLog,mat FileIODateFmt$,___,Filenumber,Stringsize,Numbersize,Dummy,Index,Ver,Promptoncreate,Oktocreate,Createlogfile,Form$*2000,StartFileNumber,CountFileNumber,FileLay$*255,CheckIndex,LogLayout$,TempCheckIndex)
      dim Keyname$(1)*255,Kpos$(1)*255,Klen$(1)*255
      dim Fm$*8000,Message$*60
      dim LayoutPath$*255
      let Fm$=Message$=""

      library : Fngetfilenumber, Fnlog, Fnerrlog
      if IgnoreErrors then on error goto ReturnFailed

      let PromptOnCreate=Fnsettings("promptonfilecreate")
      let EnforceDupkeys=Fnsettings("enforcedupkeys")
      let StartFileNumber=Fnsettings("startfilenumber")

      let CheckIndex=Fnsettings("checkindex")
      if lwrc$(trim$(FileName$))=lwrc$(trim$(fnSettings$("loglayout"))) then let CheckIndex=0

      if SuppressLog then
         let CreateLogFile=0
      else
         let Createlogfile=Fnsettings("createlogfile")
      end if

      if Not (Keynum) then let Keynum=1
      if Trim$(Path$)<>"" And Path$(Len(Path$):Len(Path$))<>"\" then let Path$=Path$&"\"
      let Filelay$=Filename$ ! Make Backup So That We Can Use This Later For Versioning Logic
      if Fnreadfilelayout(Filename$,Recl$,Mat Keyname$,Mat Kpos$,Mat Klen$,Fm$, Stringsize, Numbersize,Dont_Sort_Subs,Ver,Mat Description$,Mat Fieldwidths,Mat FileIOSubs$,dont_cform:=0,mat FileIODateFmt$) then ! Reads Layout And Applies Subscripts
         if fn42 then
            let Form$=fm$(1:2000)
         else
            let Form$=trim$(fm$(1:255))
         end if
         if Not Exists(Path$&Filename$) then
            if SupressPrompt then
               let OkToCreate=SupressPrompt-1
            else if Promptoncreate then
               let Message$=Path$&Filename$
               if Len(Trim$(Message$))>41 then let Message$=Message$(1:38)&"..."
               let Message$='Should I create "'&Message$&'"?'
               let Oktocreate=Fnmessagebox(Message$,"File Not Found")
            else
               let Oktocreate=1
            end if
            if Oktocreate then
               let Fncreate(Filename$,Recl$,Mat Keyname$,Mat Kpos$,Mat Klen$,Ver,Filelay$,Path$)
            end if
         end if
         if Exists(Path$&Filename$) then
            if Inputonly then
               do
                  if Udim(Mat Keyname$)>0 and KeyNum>0 then
                     let fnCheckIndex(Path$&FileName$,Path$&Keyname$(KeyNum),Kpos$(KeyNum),Klen$(KeyNum),CheckIndex,CreateLogFile,KeyNum,EnforceDupkeys,CallingProgram$)
                     open #(Filenumber:=Fngetfilenumber(StartFileNumber)): "name="&Path$&Filename$&", kfname="&Path$&Keyname$(Keynum)&",shr",internal, input, keyed ioerr ERROR_OPENFILE
                  else
                     open #(Filenumber:=Fngetfilenumber(StartFileNumber)): "name="&Path$&Filename$&",shr",internal, input, relative ioerr ERROR_OPENFILE
                  end if
               loop While Fnwrongversion(Filenumber,Filelay$,Ver,Path$)
            else
               do
                  if Udim(Mat Keyname$)>0 and KeyNum>0 then
                     let fnCheckIndex(Path$&FileName$,Path$&Keyname$(KeyNum),Kpos$(KeyNum),Klen$(KeyNum),CheckIndex,CreateLogFile,KeyNum,EnforceDupkeys,CallingProgram$)
                     open #(Filenumber:=Fngetfilenumber(StartFileNumber,udim(KeyName$))): "name="&Path$&Filename$&", kfname="&Path$&Keyname$(Keynum)&",shr",internal, outin, keyed ioerr ERROR_OPENFILE
                  else
                     if KeyNum>=-1 then
                        open #(Filenumber:=Fngetfilenumber(StartFileNumber,udim(KeyName$)+1)): "name="&Path$&Filename$&",shr",internal, outin, relative ioerr ERROR_OPENFILE
                     else
                        open #(Filenumber:=Fngetfilenumber(StartFileNumber)): "name="&Path$&Filename$&",shr",internal, outin, relative ioerr ERROR_OPENFILE
                     end if
                  end if
               loop While Fnwrongversion(Filenumber,Filelay$,Ver,Path$)
               let CountFileNumber=FileNumber
               if KeyNum>=-1 then
                  for Index=1 to Udim(Keyname$) ! Outin Requires All Keys To Be Opened
                     if Index<>Keynum then
                        let fnCheckIndex(Path$&FileName$,Path$&Keyname$(Index),Kpos$(Index),Klen$(Index),CheckIndex,CreateLogFile,Index,EnforceDupkeys,CallingProgram$)
                        let CountFileNumber+=1
                        open #(CountFileNumber): "name="&Path$&Filename$&", kfname="&Path$&Keyname$(Index)&",shr",internal, outin, keyed
                        mat Form$(Max(Udim(Mat Form$),CountFileNumber))
                        let Form$(CountFileNumber)=Form$
                     end if
                  next Index
               end if
            end if
            mat Form$(Max(Udim(Mat Form$),Filenumber))
            let Form$(Filenumber)=Form$
            mat F$(Stringsize)
            mat F(Numbersize)
            let Fnopenfile=Filenumber
            let LogLayout$=fnSettings$("loglayout")
            if Createlogfile and lwrc$(FileLay$)<>lwrc$(LogLayout$) then let Fnlog("Open "&Filename$&" file.",CallingProgram$)
         else
            if Createlogfile then let Fnlog("Error: Failed to open "&Filename$&" file - File Not Found",CallingProgram$,1)
         end if
      else
         print "Unable to open file layout: "&Filename$
         print "Make sure it exists, and its not currently in use."
         pause
         stop
      end if
      exitfnOpen: ! Exit Fn Open
   fnend
ERROR_OPENFILE: ! An Error Was Found Opening The File
   if IgnoreErrors then goto ReturnFailed
   print "Error parsing file layout or opening file "&filename$&": "&Str$(Err)&" on line: "&Str$(Line)
   if err=608 then
      print "Open Permission Conflict. If the file has already been opened Input Only,"
      print "then it cannot be opened OutIn. Change the earlier open to OutIn."
   else if err=4152 then
      print "A key specified in your file layout could not be found."
      print "Check your file layout header for errors."
   else
      print "Check your file layout header for errors."
   end if
   
   dim ErrorLogFilename$*255
   let ErrorLogFilename$="FileIO_ErrorLog"&Session$&"_"&Date$("ccyymmdd")&"_"&time$(1:2)&time$(4:5)&time$(7:8)&".txt"
   let ErrorLogFileRetryCount=0
   execute "status >"&ErrorLogFilename$
   execute "status stacks >>"&ErrorLogFilename$
   print "Error Log Written to: "&ErrorLogFilename$

   pause  ! Give User A Chance To Check Variables
   execute "system"


ErrorLogFileLocked: ! 
   sleep(0.1)
   let ErrorLogFileRetryCount+=1
   if ErrorLogFileRetryCount<5 then
      retry
   else
      print "Error Log File Locked. Unable to Write Complete Error Log."
      pause
      execute "system"
   end if


ReturnFailed: ! Open failed but keep going
   if createlogfile then let fnLog("Error: Failed to open file "&filename$&" or its keys: "&Str$(Err)&" on fileio line: "&Str$(Line),callingprogram$,1)
   goto exitfnOpen

!
! #Autonumber# 21000,10
CREATE: ! This Should Create The Given File If It Does Not Exist
      def Fncreate(Filename$*255,Recl$,Mat Keys$,Mat Kpos$,Mat Klen$,Ver,Filelay$*255;Path$*255,___,Index,Filenumber)
         if Udim(Mat Keys$)>0 then
            let fnCompressIndexParms(KPos$(1),KLen$(1))
            open #(Filenumber:=Fngetfilenumber): "Name="&Path$&Filename$&", "&Recl$&", kfname="&Path$&Keys$(1)&", kps="&Kpos$(1)&", kln="&Klen$(1)&",new",internal,output,keyed
         else
            open #(Filenumber:=Fngetfilenumber): "Name="&Path$&Filename$&", "&Recl$&",new", internal, output, relative
         end if
         let Version(Filenumber,Ver)
         close #Filenumber:
         for Index=2 to Udim(Mat Keys$)
            let fnCompressIndexParms(KPos$(Index),KLen$(Index))
            execute fnNeedStar$&"index "&Path$&Filename$&" "&Path$&Keys$(Index)&" "&Kpos$(Index)&" "&Klen$(Index)&" dupkeys replace -N"
         next Index
         let Fncreateversionsaveinfo(Filelay$)
      fnend
!
CREATEVERSIONSAVEINFO: ! Backs Up The File Layout And Saves Version Information
      def Fncreateversionsaveinfo(Filelay$*255;Savelay,Newlay,Filename$*255,Prefix$,Dummy$*255,Keyname$,Vers$,Filelayoutpath$*255,FileLayoutExtension$,Oldfilelayout$)
         let Filelayoutpath$=fnSettings$("layoutpath") ! Retrieve Settings
         let FileLayoutExtension$=fnSettings$("layoutextension")

         if ~Exists(Filelayoutpath$&"version") then
            execute fnNeedStar$&"mkdir "&Filelayoutpath$&"version"
         end if
         open #(Newlay:=Fngetfilenumber): "Name="&Filelayoutpath$&Filelay$&FileLayoutExtension$&",recl=511", display,input
         input #Newlay: Filename$,Prefix$,Vers$
         open #(Savelay:=Fngetfilenumber): "Name="&Filelayoutpath$&"version\"&Filelay$&"."&Trim$(Str$(Val((Vers$))))&FileLayoutExtension$&",recl=511, replace", display, output
         print #Savelay: Fncalculatebackupfilename$(Trim$(Filename$))&", o"&Trim$(Prefix$)&", "&Trim$(Vers$)
         linput #Newlay: Dummy$
         do While Uprc$(Dummy$(1:5))<>"RECL=" and Dummy$(1:4)<>"===="
            print #Savelay: Fncalculatebackupfilename$(Dummy$(1:Pos(Dummy$,",")-1)) & Trim$(Dummy$(Pos(Dummy$,","):Len(Dummy$)))
            linput #Newlay: Dummy$
         loop
COPYNEXTLINE: ! Copy The Rest Of The File
         print #Savelay: Trim$(Dummy$)
         linput #Newlay: Dummy$ eof DONECOPYLINES
         goto COPYNEXTLINE
DONECOPYLINES: ! File Is Finished
         close #Newlay:
         close #Savelay:
      fnend
!
CHECKVERSIONSAVEINFO: ! Ensures Version Save Information Exists
      def Fncheckversionsaveinfo(Filelay$*255,Ver;___,Filelayoutpath$*255,FileLayoutExtension$)
         let Filelayoutpath$=fnSettings$("layoutpath")
         let FileLayoutExtension$=fnSettings$("layoutextension")
         if ~(Trim$(Filelay$(pos(Trim$(Filelay$),".",-1):Len(Trim$(Filelay$))))="."&Trim$(Str$(Ver))) then ! IF this is a version file we're opening, don't create a version save on it.
            if (~Exists(Filelayoutpath$&"version")) Or (~Exists(Filelayoutpath$&"version\"&Filelay$&"."&Trim$(Str$(Ver))&FileLayoutExtension$)) then   ! if its not there, then make it.
               let Fncreateversionsaveinfo(Filelay$)
            end if
         end if
      fnend
!
CALCULATEBACKUPFILENAME: !  Returns The Backup File Name Of The Given File Name
      def Fncalculatebackupfilename$*255(Newfilename$*255;___,Lastslash)
         let Lastslash=Pos(Newfilename$,"\",-1)
         let Newfilename$(Lastslash+1:Lastslash)="o"
         let Fncalculatebackupfilename$=Newfilename$
      fnend
!
CALCULATENEWFILENAME: ! Returns The New File Name Of The Given Backup File Name
      def Fncalculatenewfilename$*255(Backupfilename$*255;___,Lastslash)
         let Lastslash=Pos(Backupfilename$,"\",-1)
         if Backupfilename$(Lastslash+1:Lastslash+1)="o" then
            let Backupfilename$(Lastslash+1:Lastslash+1)=""
         end if
         let Fncalculatenewfilename$=Backupfilename$
      fnend
!
! #Autonumber# 22000,2
CheckIndex: ! Checks to ensure Indexes are up to date
      def fnCheckIndex(MainFile$*255,KeyFile$*255,Kpos$*50,Klen$*50,CheckIndex;Logging,Index,EnforceDupkeys,&CallingProgram$,___,Dupkeys)
         if EnforceDupkeys and Index=1 then let Dupkeys=0 else let Dupkeys=1
         if Exists(KeyFile$) then
            if CheckIndex then
               if fnGetFileDT$(KeyFile$)<>fnGetFileDT$(MainFile$) then
                  let fnRebuildIndex(MainFile$,Keyfile$,Kpos$,Klen$,1,Logging,Dupkeys,CallingProgram$)
               end if
            end if
         else
            let fnRebuildIndex(MainFile$,KeyFile$,Kpos$,Klen$,0,Logging,Dupkeys,CallingProgram$)
         end if
      fnend

ReIndexAllFiles: ! Rebuilds every index in the system
      def library fnReIndexAllFiles(;___,Index)
         library : fnReIndex, fnReadLayouts
         let fnReadLayouts(mat Reindex$)
         for Index=1 to udim(mat Reindex$)
            let fnReIndex(Reindex$(Index))
         next Index
      fnend

      dim Reindex$(1)*255
      dim RebuildRecl$*255
      dim RebuildIndexes$(1)*255
      dim RebuildKPos$(1)*255
      dim RebuildKLen$(1)*255
      dim Dummy$(1)*255
      dim Dummy(1)

      ! Included for backwards compatibility
      def library fnRendix(DataFile$*255;CallingProgram$*255) ! .. there was a typeo in an earlier version.
         library : fnReIndex
         let fnrendix=fnReIndex(DataFile$,CallingProgram$)
      fnend
      ! Included for compatibility with Susans version, thanks Susan Smith from SMS Software for the Q_INDEX parameter and adding the PATH$ parameter to this function.
      def library fnRebuildKeys(DataFile$*255;Q_INDEX,PATH$*255,CallingProgram$*255)
         library : fnReIndex
         let fnRebuildKeys=fnReIndex(DataFile$,CallingProgram$,Q_INDEX,PATH$)
      fnend
ReIndex: ! Rebuilds all indexes for a given data file
      def library fnReIndex(DataFile$*255;CallingProgram$*255,IndexNum,Path$*255,___,Index,Dummy,Dummy2,Dummy3)
         if CallingProgram$="" then let CallingProgram$="Unknown"
         let fnReadFileLayout(DataFile$,RebuildRecl$,mat RebuildIndexes$,mat RebuildKPos$,mat RebuildKLen$,ReadForm$,Dummy,Dummy2,0,Dummy3,mat dummy$,mat dummy)
         for Index=1 to udim(mat RebuildIndexes$)
            if IndexNum=0 or IndexNum=Index then
               if exists(RebuildIndexes$(Index)) then
                  let fnRebuildIndex(Path$&DataFile$,Path$&RebuildIndexes$(Index),RebuildKPos$(Index),RebuildKLen$(Index),1,0,0,CallingProgram$)
               else
                  let fnRebuildIndex(Path$&DataFile$,Path$&RebuildIndexes$(Index),RebuildKPos$(Index),RebuildKLen$(Index),0,0,0,CallingProgram$)
               end if
            end if
         next Index
      fnend

RebuildIndex: ! Rebuilds an Index that was missing or incomplete
      def fnRebuildIndex(MainFile$*255,KeyFile$*255,Kpos$*50,Klen$*50;Update,Logging,Dupkeys,&CallingProgram$)
         let fnCompressIndexParms(KPos$,KLen$)

         if Update then
            if Dupkeys then
               execute fnNeedStar$&"index "&MainFile$&" "&KeyFile$&" "&Kpos$&" "&Klen$&" dupkeys replace shr -N" error Ignore
            else
               execute fnNeedStar$&"index "&MainFile$&" "&KeyFile$&" "&Kpos$&" "&Klen$&" replace shr -N" error Ignore
            end if
         else
            if Dupkeys then
               execute fnNeedStar$&"index "&MainFile$&" "&KeyFile$&" "&Kpos$&" "&Klen$&" dupkeys shr -N" error Ignore
            else
               execute fnNeedStar$&"index "&MainFile$&" "&KeyFile$&" "&Kpos$&" "&Klen$&" shr -N" error Ignore
            end if
         end if
         if Logging then let fnLog("FileIO Autocreate Index "&MainFile$&" "&KeyFile$&" "&Kpos$&" "&Klen$,CallingProgram$,1)
      fnend

      dim IP_Positions$(1),IP_Lens$(1)
      dim IP_Positions(1),IP_Lens(1),IP_Mod$(1)
      dim Op_Positions(1),Op_Lens(1),Op_Mod$(1)

      def fnCompressIndexParms(&Kpos$,&Klen$;___,Index,PreviousSpot,StartCurrent,LengthCurrent,ModCurrent$,OutDex,Digits)
         ! A length may end in a modifier (U, YB, Y ...). Adjacent segments merge when both have none or both U,
         !  or a Y segment (year = its first 2 digits) absorbs unmodified ones. YB never merges (BH 2 = YYMM).
         let fnStr2Mat(KPos$,mat IP_Positions$,"/")
         let fnStr2Mat(Klen$,mat IP_Lens$,"/")

         mat IP_Positions(udim(mat IP_Positions$))
         mat IP_Lens(udim(mat IP_Lens$))
         mat IP_Mod$(udim(mat IP_Lens$))

         for Index=1 to udim(mat Ip_Positions)
            let IP_Positions(Index)=val(Ip_Positions$(Index)) conv ErrorCompressing
            LET IP_LENS$(INDEX)=UPRC$(TRIM$(IP_LENS$(INDEX))) : LET DIGITS=0
            DO WHILE DIGITS<LEN(IP_LENS$(INDEX)) AND POS("0123456789",IP_LENS$(INDEX)(DIGITS+1:DIGITS+1))
               LET DIGITS+=1
            LOOP
            LET IP_MOD$(INDEX)=IP_LENS$(INDEX)(DIGITS+1:LEN(IP_LENS$(INDEX)))
            LET IP_LENS(INDEX)=VAL(IP_LENS$(INDEX)(1:DIGITS)) CONV ERRORCOMPRESSING
         next Index

         mat Op_Positions(0)
         mat Op_Lens(0)
         mat Op_Mod$(0)

         let StartCurrent=IP_Positions(1)
         let LengthCurrent=IP_Lens(1)
         let ModCurrent$=IP_Mod$(1)

         for Index=2 to udim(mat IP_Positions)
            if StartCurrent+LengthCurrent-1<>IP_Positions(Index)-1 or NOT ((IP_MOD$(INDEX)=MODCURRENT$ AND (MODCURRENT$="" OR MODCURRENT$="U")) OR (MODCURRENT$="Y" AND IP_MOD$(INDEX)="")) THEN ! If end of previous position is any different then right before current position, or the modifiers can't be merged
               ! We have a gap, or Modifier Changed, save the entries and reset for the next time before processing this new spot.
               let OutDex=udim(mat Op_Positions)+1
               mat Op_Positions(OutDex) : mat Op_Lens(OutDex) : mat Op_Mod$(OutDex)
               let Op_Positions(OutDex)=StartCurrent
               let Op_Lens(OutDex)=LengthCurrent
               let Op_Mod$(OutDex)=ModCurrent$

               let StartCurrent=IP_Positions(Index) ! Record next start position.
               let LengthCurrent=0

               let ModCurrent$=Ip_Mod$(Index)
            end if

            let LengthCurrent+=IP_Lens(Index) ! Add in the start length
         next Index

         if LengthCurrent then
            let OutDex=udim(mat Op_Positions)+1
            mat Op_Positions(OutDex) : mat Op_Lens(OutDex) : mat Op_Mod$(OutDex)
            let Op_Positions(OutDex)=StartCurrent
            let Op_Lens(OutDex)=LengthCurrent
            let Op_Mod$(OutDex)=ModCurrent$
         end if

         let Kpos$=Klen$=""

         for Index=1 to udim(mat Op_Positions)
            let KPos$=KPos$&str$(Op_Positions(Index))&"/"
            LET KLen$=KLen$&STR$(Op_Lens(Index))&Op_Mod$(Index)&"/"
         next Index

         let KPos$=KPos$(1:len(KPos$)-1) ! Strip off final "/"
         let KLen$=KLen$(1:len(KLen$)-1) ! Strip off final "/"
      fnend

      ErrorCompressing: !
         print "There was an error calculating the Index values when generating the index."
         print "One of the parameters could not be matched in your subscripts."
         print IP_Positions$(Index)
         print IP_Lens$(Index)
         pause ! Give programmer chance to check values
      stop

      def fnStr2Mat(String$*10000,mat Matrix$;Delim$,___,Index,Position)
         if Delim$="" then let Delim$="," ! Default Delimiter
         mat Matrix$(0)
         do while (Position:=pos(String$,Delim$))>0
            let Index=udim(mat Matrix$)+1
            mat Matrix$(Index)
            let Matrix$(Index)=String$(1:Position-1)
            let String$(1:Position)=""
         loop
         let Index=udim(mat Matrix$)+1
         mat Matrix$(Index)
         let Matrix$(Index)=String$
      fnend

RemoveDeletes: ! ***** Remove Deleted Records - From Susan Smith
      def library fnRemoveDeletes(LayoutName$*255;Path$*255,CallingProgram$*255,DontError,___,OrigFile$*100,TempFile$*100,FileName$*255)
         library : fnReIndex,fnReadLayoutHeader
   !
         let A=fnReadLayoutHeader(LayoutName$,FileName$)
         let OrigFile$=FileName$
         let TempFile$="RemoveDeletes_"&Session$
   !
         ! If Q_Tempfile$ Exists,
         execute "rename "&Path$&OrigFile$&" "&Path$&TempFile$&" -N" error SkipRemoveDeletes
         execute "copy "&Path$&TempFile$&" "&Path$&OrigFile$&" -D -N"
         if exists(Path$&OrigFile$) then execute fnNeedStar$&"free "&Path$&TempFile$&" -N"

         let fnReIndex(LayoutName$,CallingProgram$,0,Path$) ! Reindex the file
         let fnRemoveDeletes=1
         SkipRemoveDeletes: ! Skip Removing the deletes when the file is in use.
      fnend

WRONGVERSION: ! Checks Version, Closes And Updates Files If Wrong Version
      def Fnwrongversion(Filenumber,Filelay$*255,Ver;Path$*255,___,Old)
         if (Old:=Version(Filenumber))>=Ver then
            let Fnwrongversion=0 ! Success
            let Fncheckversionsaveinfo(Filelay$,Ver)
         else
            close #Filenumber:
            let Fnupdate(Filelay$,Old,Path$)
            let Fnwrongversion=1 ! Failure, But Version Was Fixed, So Go Back And Reopen It
         end if
      fnend

dim UpdateMessages$(1)*80, PrintedYet
!

dim Dummy$
! #Autonumber# 23000,5
UPDATE: ! Updates File To Latest Version
      def Fnupdate(Filelay$*255,Oldver;&Path$,__,Index,Oldfile,Newfile,Opre$,Npre$,Nndex,Oldfilename$*255,Lastupdatedkey,Errindex,Lastpercent,Reccount,Useraborted,Interval,Numrecs,Oldfilelay$*255,Star$,LayoutPath$*128,FileLayoutExtension$)

         let LongMessage$="The file layout has been updated. Before proceeding, we must update the data file to the newest version. "
         let LongMessage$(99999:0)="Choose Yes to continue, or No to Abort.\n\nIf you recently got an update, choose Yes.\n\n"
         let LongMessage$(99999:0)="If you don't know why you're seeing this message, choose No to Abort and then contact your vendor for support."
         let LongMessage$=srep$(LongMessage$,"\n",hex$("0D0A"))

         if ~fnSettings("promptonupdate") or (2==msgbox(LongMessage$,"Update","yn","QST")) then ! If don't Prompt, or if they chose "Yes"
            let Star$=fnNeedStar$
            mat UpdateMessages$(0) : let PrintedYet=0
            let Layoutpath$=fnSettings$("layoutpath")
            let FileLayoutExtension$=fnSettings$("layoutextension")

            on error goto FILEINUSE ! Call Rollback Processing For No Changes Made
            ! open #(Window:=fnGetFileNumber): "SRow=11,SCol=2,Rows=1,Cols=78,Caption=,Border=S",display,outin
!
            dim Fm$(1)*1024,Nf$(1)*2048,Nf(1),Of$(1)*2048,Of(1),Nssubs$(1)*80,Ossubs$(1)*80,Nnsubs$(1)*80,Onsubs$(1)*80,Okeys$(1)*80
            dim NsSpec$(1),OsSpec$(1),NnSpec$(1),OnSpec$(1)
            dim NsDes$(1)*255,OsDes$(1)*255,NnDes$(1)*255,OnDes$(1)*255
            dim NsPos(1),OsPos(1),NnPos(1),OnPos(1)
            dim NsDate$(1)*64,OsDate$(1)*64,NnDate$(1)*64,OnDate$(1)*64
!
            library : Fnopenfile, Fnclosefile, Fnreadsubs, fnReadLayoutArrays
!
            let Oldfilelay$="version\"&Filelay$&"."&Str$(Oldver)
!
            if Exists(Layoutpath$&Oldfilelay$&FileLayoutExtension$) then
               let Fnfindindexes(Oldfilelay$,Oldfilename$,Mat Okeys$)
               let fnprint(mat UpdateMessages$,"Making Backup Copy of "&Path$&Fncalculatenewfilename$(Oldfilename$))
               execute Star$&"copy "&Path$&Fncalculatenewfilename$(Oldfilename$)&" "&Path$&Oldfilename$&" -N -D"
               execute Star$&"copy "&Path$&Fncalculatenewfilename$(Oldfilename$)&" "&Path$&Fncalculatenewfilename$(Oldfilename$)&".bak -N"
               execute Star$&"free "&Path$&Fncalculatenewfilename$(Oldfilename$)&" -N"

               on error goto FILEINUSEKEY ! Call Rollback Processing For File Changed And Some Keys

               for Index=1 to Udim(Okeys$)
                  let fnprint(mat UpdateMessages$,"Making Backup Copy of "&Path$&Fncalculatenewfilename$(Okeys$(Index)))
                  execute Star$&"copy "&Path$&Fncalculatenewfilename$(Okeys$(Index))&" "&Fncalculatenewfilename$(Okeys$(Index))&".bak -N"
                  execute Star$&"free "&Path$&Fncalculatenewfilename$(Okeys$(Index))&" -N"
               next Index

               on error goto ROLLBACKINFULL ! Call Rollback Processing For File / All Keys Changed

               let G_Updating=1
               let fnprint(mat UpdateMessages$,"Opening old version of file.")
               let Oldfile=Fnopen(Oldfilelay$,Mat Of$,Mat Of, Mat Fm$,0,-1,0,Path$,Dummy$,Dummy,0,0,1)
               ! let Fnreadsubs(Oldfilelay$,Mat Ossubs$,Mat Onsubs$,Opre$)
               let fnReadLayoutArrays(OldFileLay$,OPre$,mat OsSubs$,mat OnSubs$,mat OsSpec$,mat OnSpec$,mat OsDes$,mat OnDes$,mat OsPos,mat OnPos,0,mat OsDate$,mat OnDate$)
               let fnprint(mat UpdateMessages$,"Creating new version of file.")
               let Newfile=Fnopen(Filelay$,Mat Nf$,Mat Nf,Mat Fm$,0,0,0,Path$,Dummy$,Dummy,2,0,1) ! Will Automatically Create
               ! let Fnreadsubs(Filelay$,Mat Nssubs$,Mat Nnsubs$,Npre$)
               let fnReadLayoutArrays(Filelay$,Npre$,mat Nssubs$,mat Nnsubs$,mat NsSpec$,mat NnSpec$,mat NsDes$,mat NnDes$,mat NsPos,mat NnPos,0,mat NsDate$,mat NnDate$)
               let fnprint(mat UpdateMessages$,"Preforming File Update. SHIFT-A to abort.")
               let Numrecs=Lrec(Oldfile)

               READOLDRECORD: ! Read The Old Record Here
               read #Oldfile, using Fm$(Oldfile), release: Mat Of$, Mat Of eof DONEUPDATING

               let fnUpdateProgressBar((Reccount+=1)/Numrecs,"",.01,0,.15," Updating '"&Filelay$&"' File - Please Wait ","Preforming File Update. Completed: "&Str$(Reccount)&" / "&Str$(Numrecs)&". Press SHIFT-A to abort.")

               mat NF$=("")
               mat NF=(0)

               for Index=1 to Udim(Ossubs$) ! Copy String Values
                  if (Nndex:=Srch(Mat Nssubs$,Ossubs$(Index)))>0 then
                     ! If there are dates, convert them from the from format to the to format.
                     let NF$(Nndex)=trim$(fnfmtsdate$(Of$(Index),osDate$(Index),NsDate$(Nndex)))
                  end if
               next Index
               for Index=1 to Udim(Onsubs$) ! Copy Number Values
                  if (Nndex:=Srch(Mat Nnsubs$,Onsubs$(Index)))>0 then
                     ! If there are dates, convert them from the from format to the to format.
                     let NF(Nndex)=val(fnfmtNdate$(OF(Index),onDate$(Index),NnDate$(Nndex))) conv UpdateFallbackNumber
                  end if
               next Index
               write #Newfile, using Fm$(Newfile) : Mat Nf$, Mat Nf
               if Kstat$="A" then let Useraborted=1 : goto ROLLBACKINFULL
               goto READOLDRECORD
               DONEUPDATING: ! We Are Finished
               let Fnclosefile(Oldfile,Oldfilelay$)
               let Fnclosefile(Newfile,Filelay$)

               close #Window:
               fnCloseProgressBar

               let G_Updating=0 ! We Are Done Updating
            else
               print "Error: Unable to locate old version file layout: "&Layoutpath$&Oldfilelay$&FileLayoutExtension$
               pause
               execute "system"
            end if
            let fnResetErrorHandling
         else
            print "Error: User Aborted"
            pause
            execute "system"
         end if
      fnend

UpdateFallbackNumber: ! Fallback if date conversion fails in updating a number
   let Nf(Nndex)=Of(Index)
continue
UpdateFallbackString: ! Fallback if date conversion fails in updating a number
   let Nf$(Nndex)=Of$(Index)
continue

!
! Error Checking Rollback Update Routine.       #Autonumber# 23600,5
ROLLBACKINFULL: ! Close All Files And Roll Back
   on error system
   let UpdateErrorRecieved=Err
   let UpdateErrorLine=Line
   if Oldfile then let Fnclosefile(Oldfile,Oldfilelay$)
   if Newfile then let Fnclosefile(Newfile,Filelay$)
   let Lastupdatedkey=Udim(Okeys$) ! Set Value To Roll Back All Indexes
!
FILEINUSEKEY: ! Error In Second Part. Partially Roll Back
   on error system
   if UpdateErrorRecieved=0 then let UpdateErrorRecieved=Err
   if UpdateErrorLine=0 then let UpdateErrorLine=Line
   print Mat UpdateMessages$
   print "Error encountered or User abort: Rolling back to previous version. Type GO[ENTER] to Quit."
   let PrintedYet=1
   if ~Lastupdatedkey then let Lastupdatedkey=Index-1
   for Errindex=1 to Lastupdatedkey ! Roll Back All Successful Indexes
      if Exists(Path$&Okeys$(Errindex)) then !:
         execute Star$&"copy "&Path$&Fncalculatenewfilename$(Okeys$(Errindex))&".bak "&Path$&Fncalculatenewfilename$(Okeys$(Errindex)) ! Copy Backup File To Origional File
   next Errindex
   if Exists(Path$&Oldfilename$) then !:
      execute Star$&"copy "&Path$&Fncalculatenewfilename$(Oldfilename$)&".bak "&Path$&Fncalculatenewfilename$(Oldfilename$)
!
FILEINUSE: ! Error In First Part
   on error system
   if ~PrintedYet then
      print Mat UpdateMessages$
      print "Error encountered or User abort: Rolling back to previous version. Type GO[ENTER] to Quit."
      let PrintedYet=1
   end if
   if UpdateErrorRecieved=0 then let UpdateErrorRecieved=Err
   if UpdateErrorLine=0 then let UpdateErrorLine=Line
   print Fnerrormessage$(UpdateErrorRecieved,UpdateErrorLine)
   pause
   execute "system"
!
! #Autonumber# 23800,5
ERRORMESSAGES: ! Return The Proper Error Message For Rollback Errors
   def Fnerrormessage$*80(Errornum,Errorline)
      do
         if Str$(Errorline)(1:2)="21" then
            let Fnerrormessage$="Error during create: Check heading information in file layout."
            exit do
         end if
         if Errornum=4148 then
            let Fnerrormessage$="The file was in use. Please close all other copies of BR and try again."
            exit do
         end if
         if Useraborted then
            let Fnerrormessage$="User Aborted."
            exit do
         end if
         let Fnerrormessage$="Error updating file: "&Str$(Errornum)&" occured on line: "&Str$(Errorline)
         exit do
      loop
   fnend

   def fnPrint(mat UpdateMessages$,Message$*80;___,Index)
      ! print #Window, fields "1,1,C 78" : Message$
      let fnUpdateProgressBar(0,"",.01,0,.15," Updating '"&Filelay$&"' File - Please Wait ",Message$)

      let Index=udim(mat UpdateMessages$)+1
      mat UpdateMessages$(Index)
      let UpdateMessages$(Index)=Message$
   fnend

! #Autonumber# 24000,2
FINDINDEXES: ! ***** Reads A File Layout And Finds All Indexes
   def Fnfindindexes(Layoutname$*255;&Filename$,Mat Keys$)
      ! Included for Backwards Compatability
      library : fnReadLayoutHeader
      let fnFindIndexes=fnReadLayoutHeader(LayoutName$,FileName$,Mat Keys$)
   fnend

ReadEntireLayout: ! Reads the entire layout into arrays
   def library fnReadEntireLayout(Layoutname$*255;&Filename$,&Prefix$,Mat Keys$,Mat KeyDescription$,Mat Ssubs$,Mat Nsubs$,Mat Sspec$,Mat Nspec$,Mat Sdescription$,Mat Ndescription$,Mat Spos,Mat Npos,mat sdatefmt$,mat ndatefmt$,___,FileNumber)
      library : fnReadLayoutHeader, fnReadLayoutArrays
      let filenumber=fnReadLayoutHeader(Layoutname$,Filename$,mat Keys$,mat KeyDescription$,1,Prefix$)
      let fnReadEntireLayout=fnReadLayoutArrays(Layoutname$,Prefix$,Mat Ssubs$,Mat Nsubs$,Mat Sspec$,Mat Nspec$,Mat Sdescription$,Mat Ndescription$,Mat Spos,Mat Npos,FileNumber,mat sdatefmt$,mat ndatefmt$)
   fnend

ReadLayoutHeader: ! Reads the layout header and returns Arrays
   def library FnReadLayoutHeader(Layoutname$*255;&Filename$,Mat Keys$,Mat KeyDescription$,LeaveOpen,&Prefix$,___,Count,Keyname$*255,Description$*255,Vers$*80,BKeys,BKeyDescription,Line$*512,LayoutPath$*128,FileLayoutExtension$)
      library : fnGetFileNumber

      let LayoutName$=trim$(LayoutName$)
      let Layoutpath$=fnSettings$("layoutpath")
      let FileLayoutExtension$=fnSettings$("layoutextension")

      if trim$(layoutname$)<>"" and Exists(Layoutpath$&Layoutname$&FileLayoutExtension$) then
         if Fnsmatrixpresent(Mat Keys$) then let Bkeys=1
         if FnSMatrixPresent(Mat KeyDescription$) then let BKeyDescription=1

         if BKeys then mat Keys$(0)
         if BKeyDescription then mat KeyDescription$(0)

         if ~fnOpenLayout(LayoutPath$&LayoutName$&FileLayoutExtension$) then goto ErrorReadFileLayout

         let Line$=fnLayoutLinput$
         if uprc$(Line$)<>"#EOF#" then
            let fnReadHeading(Line$,Filename$,Prefix$,Vers$)
         else
            print "Incomplete Layout."
            goto ErrorReadFileLayout
         end if

         let Line$=fnLayoutLinput$
         if uprc$(Line$)<>"#EOF#" then
            let fnReadKeys(Line$,KeyName$,Description$)
         else
            print "Incomplete Layout."
            goto ErrorReadFileLayout
         end if

         do While Uprc$(Keyname$(1:4))<>"RECL" and KeyName$(1:4)<>"===="
            let Count+=1
            if BKeys then
               mat Keys$(Count)
               let Keys$(Count)=trim$(Keyname$)
            end if
            if BKeyDescription then
               Mat KeyDescription$(Count)
               let KeyDescription$(Count)=trim$(Description$)
            end if

            let Line$=fnLayoutLinput$
            if uprc$(Line$)<>"#EOF#" then
               let fnReadKeys(Line$,KeyName$,Description$)
            else
               print "Incomplete Layout."
               goto ErrorReadFileLayout
            end if
         loop
         if Uprc$(KeyName$(1:4))="RECL" Then
            let Line$=fnLayoutLinput$
            if uprc$(Line$)="#EOF#" then
               print "Incomplete Layout."
               goto ErrorReadFileLayout
            end if
         end if
      end if
      if LeaveOpen then
         let fnReadLayoutHeader=1
      else
         let FnReadLayoutHeader=Count
      end if
   fnend

READSUBS: ! Read File Layout, Returning All Subscripts As An Array
   def library Fnreadsubs(Filename$*255,Mat Ssubs$,Mat Nsubs$,&Prefix$)
      ! Included for Backwards Compatability Only
      library : fnReadLayoutArrays
      let fnReadLayoutArrays(Filename$,Prefix$,mat SSubs$,mat NSubs$)
   fnend
!
READLAYOUTARRAYS: ! Read File Layout, Returning Everything As Some Arrays
   def library Fnreadlayoutarrays(Layoutname$*255,&Prefix$;Mat Ssubs$,Mat Nsubs$,Mat Sspec$,Mat Nspec$,Mat Sdescription$,Mat Ndescription$,Mat Spos,Mat Npos,AlreadyOpenFileNumber,mat sdateformat$,mat ndateformat$,mat S4thCol$,mat N4thCol$,___,Index,Dummy$*512,Dummy2$*255,Subname$*255,Layout,Description$*255,Spec$*255,Column4$*255,Bssubs,Bnsubs,Bsdescription,Bndescription,Bsspec,Bnspec,Bspos,Bnpos,Bsdateformat,Bndateformat,Bs4thCol,Bn4thCol,Position,Count,Line$*512,DateFormat$*50)
      library : fnGetFileNumber
!
      let LayoutName$=Trim$(LayoutName$)
      let Position=1
      let Layoutpath$=fnSettings$("layoutpath") ! Read File Layout Path
      let FileLayoutExtension$=fnSettings$("layoutextension")
!
      if trim$(layoutname$)<>"" and Exists(Layoutpath$&Layoutname$&FileLayoutExtension$) then
         if Fnsmatrixpresent(Mat Ssubs$) then let Bssubs=1
         if Fnsmatrixpresent(Mat Nsubs$) then let Bnsubs=1
         if Fnsmatrixpresent(Mat Sspec$) then let Bsspec=1
         if Fnsmatrixpresent(Mat Nspec$) then let Bnspec=1
         if Fnsmatrixpresent(Mat Sdescription$) then let Bsdescription=1
         if Fnsmatrixpresent(Mat Ndescription$) then let Bndescription=1
         if Fnsmatrixpresent(mat sdateformat$) then let Bsdateformat=1
         if Fnsmatrixpresent(mat ndateformat$) then let Bndateformat=1
         if Fnsmatrixpresent(mat S4thCol$) then let bS4thCol=1
         if Fnsmatrixpresent(mat N4thCol$) then let bN4thCol=1
         if Fnnmatrixpresent(Mat Spos) then let Bspos=1
         if Fnnmatrixpresent(Mat Npos) then let Bnpos=1
!
         if Bssubs then mat Ssubs$(0)
         if Bnsubs then mat Nsubs$(0)
         if Bsspec then mat Sspec$(0)
         if Bnspec then mat Nspec$(0)
         if Bsdescription then mat Sdescription$(0)
         if Bndescription then mat Ndescription$(0)
         if bsdateformat then mat sdateformat$(0)
         if bndateformat then mat ndateformat$(0)
         if bS4thCol then mat bS4thCol$(0)
         if bN4thCol then mat bN4thCol$(0)
         if Bspos then mat Spos(0)
         if Bnpos then mat Npos(0)
!
         if AlreadyOpenFileNumber then
            ! Then we're already there.
            ! Otherwise, (below) we get the prefix and skip to the details
         else
            if ~fnOpenLayout(LayoutPath$&LayoutName$&FileLayoutExtension$) then goto ErrorReadFileLayout
            let Line$=fnLayoutLinput$
            if uprc$(Line$)<>"#EOF#" then
               let fnReadHeading(Line$,Dummy$,Prefix$,Dummy2$)
               let Prefix$=Trim$(Prefix$)
            else
               print "Incomplete Layout."
               goto ErrorReadFileLayout
            end if
            do
               let Line$=fnLayoutLinput$
               if uprc$(Line$)="#EOF#" then
                  print "Incomplete Layout."
                  goto ErrorReadFileLayout
               end if
            loop While Uprc$(Line$(1:4))<>"RECL" and Line$(1:4)<>"===="
            if Uprc$(Line$(1:4))="RECL" Then
               let Line$=fnLayoutLinput$
               if uprc$(Line$)="#EOF#" then
                  print "Incomplete Layout."
                  goto ErrorReadFileLayout
               end if
            end if
         end if
READNEXTLAYOUTLINE: ! Read The Next Line For Processing
         let Line$=fnLayoutLinput$
         if uprc$(Line$)="#EOF#" then goto DONEREADLAYOUTARRAYS

         let fnParseDetailLayoutLine(Line$,SubName$,Description$,Spec$,DateFormat$,Column4$)

         if Trim$(Uprc$(Spec$))(1:2)<>"X " then
            if Trim$(Subname$)<>"" then
               if fnStringSpec(Subname$,Spec$) then
                  let Count+=1
                  if Bssubs then
                     mat Ssubs$(Udim(Ssubs$)+1)
                     let Ssubs$(Udim(Ssubs$))=Trim$(Srep$(Subname$,"$",""))
                  end if
                  if Bsspec then
                     mat Sspec$(Udim(Sspec$)+1)
                     let Sspec$(Udim(Sspec$))=Trim$(Spec$)
                  end if
                  if Bsdescription then
                     mat Sdescription$(Udim(Sdescription$)+1)
                     let Sdescription$(Udim(Sdescription$))=Trim$(Description$)
                  end if
                  if bsdateformat then
                     mat sdateformat$(udim(sdateformat$)+1)
                     let sdateformat$(udim(sdateformat$))=dateformat$
                  end if
                  if bs4thcol then
                     mat s4thcol$(udim(s4thCol$)+1)
                     let s4thcol$(udim(s4thCol$))=Column4$
                  end if
                  if Bspos then
                     mat Spos(Udim(Spos)+1)
                     let Spos(Udim(Spos))=Position
                  end if
               else
                  if Bnsubs then
                     mat Nsubs$(Udim(Nsubs$)+1)
                     let Nsubs$(Udim(Nsubs$))=Trim$(Subname$)
                  end if
                  if Bnspec then
                     mat Nspec$(Udim(Nspec$)+1)
                     let Nspec$(Udim(Nspec$))=Trim$(Spec$)
                  end if
                  if Bndescription then
                     mat Ndescription$(Udim(Ndescription$)+1)
                     let Ndescription$(Udim(Ndescription$))=Trim$(Description$)
                  end if
                  if Bndateformat then
                     mat ndateformat$(udim(ndateformat$)+1)
                     let ndateformat$(udim(ndateformat$))=dateformat$
                  end if
                  if bn4thcol then
                     mat n4thcol$(udim(n4thCol$)+1)
                     let n4thcol$(udim(n4thCol$))=Column4$
                  end if
                  if Bnpos then
                     mat Npos(Udim(Npos)+1)
                     let Npos(Udim(Npos))=Position
                  end if
               end if
            end if
         end if
         let Position+=Fnlengthof(Trim$(Spec$))
         goto READNEXTLAYOUTLINE
DONEREADLAYOUTARRAYS: ! We Finished With All The File Layout
         let fnReadLayoutArrays=Count
      end if
   fnend

   def fnStringSpec(Var$*80,Spec$*80;___,Type$,P)
      let Type$=uprc$(trim$(Spec$))
      if pos(Type$," ") then let Type$=Type$(1:pos(Type$," ")-1)

      #Select# Type$ #Case# "C" # "V" # "CC" # "CR"
         let fnStringSpec=1
      #Case# "B" # "BL" # "BH" # "D" # "DH" # "DL" # "DT" # "L" # "N" # "NZ" # "PD" # "S" # "ZD"
         let fnStringSpec=0
      #Case# "G" # "GF" # "GZ"
         if pos(Var$,"$") then let fnStringSpec=1
      #Case Else#
         if pos(Var$,"$") then let fnStringSpec=1
      #End Select#
   fnend

ReadKeyFiles: ! This function reads the key file list of a file layout
   def library fnReadKeyFiles(layout$,mat keys$;___,filename$*255)
      ! Included for Backwards Compatability
      let fnFindIndexes(layout$,filename$,mat keys$)
   fnend

BuildKey: ! This function builds a key off of mat F$ and mat F
   def library fnBuildKey$*255(layout$*30,mat f$,mat f;keynum,___,Value$*255,SPos,EPos,UpperCase,filename$*80,prefix$,Index,KeyPart$*30,KeyFields$*80,Key$*255)

      dim BK_Keys$(1)*80
      dim BK_KeyFields$(1)*80
      dim BK_SSubs$(1)*80
      dim BK_NSubs$(1)*80
      dim BK_SSpec$(1)*80
      dim BK_NSpec$(1)*80
      dim BK_LastLayout$*30

      if (trim$(layout$)<>"") and (udim(mat f$)+udim(mat F)) then
         if Layout$<>BK_LastLayout$ then
            library : fnReadEntireLayout, fnKey$

            mat BK_Keys$(0)
            mat BK_KeyFields$(0)

            let fnReadEntireLayout(layout$,filename$,prefix$,mat BK_Keys$,mat BK_KeyFields$,mat BK_SSubs$,mat BK_NSubs$,mat BK_SSpec$,mat BK_NSpec$)

            for Index=1 to udim(mat BK_sSubs$)
               let BK_sSubs$(Index)=lwrc$(BK_sSubs$(Index))
            next Index
            for Index=1 to udim(mat BK_nSubs$)
               let BK_nSubs$(Index)=lwrc$(BK_nSubs$(Index))
            next Index

            let BK_LastLayout$=Layout$
         end if

         if udim(mat BK_Keys$) then

            if KeyNum=0 then let KeyNum=1
            let KeyFields$=lwrc$(trim$(BK_KeyFields$(KeyNum)))

            do
               if POS(KeyFields$,"/") then
                  let KeyPart$=KeyFields$(1:pos(KeyFields$,"/")-1)
                  let KeyFields$(1:pos(KeyFields$,"/"))=""
               else
                  let KeyPart$=KeyFields$
                  let KeyFields$=""
               end if

               ! Here, we need to interpret the (5:8) style Partial specs
               !  And we also need to handle -U for uppercase.
               let SPos=EPos=UpperCase

               let fnExtractKeyFormat(Keypart$,SPos,EPos,UpperCase)

               let Value$=""
               if (Index:=srch(mat BK_sSubs$,KeyPart$))>0 then
                  let Value$=rpad$(rtrm$(F$(Index))(1:fnLengthOf(BK_sSpec$(Index))),fnLengthOf(BK_sSpec$(Index)))
               else if (Index:=srch(mat BK_nSubs$,KeyPart$))>0 then
                  let Value$=cnvrt$(BK_nSpec$(Index),F(Index))
               end if
               if SPos or EPos then let Value$=Value$(SPos:EPos)
               if UpperCase then let Value$=Uprc$(Value$)
               let Key$=Key$&Value$
            loop while len(KeyFields$)

            let fnBuildKey$=Key$
         end if
      end if
   fnend

   def fnExtractKeyFormat(&KeyPart$;&SPos,&Epos,&Upper,___,PS,PE,Parens$,Dash)
      let KeyPart$=trim$(KeyPart$)
      ! Takes a string and pulls out the () stuff.
      let PS=pos(KeyPart$,"(")
      if PS then
         let PE=pos(KeyPart$,")")
         if PE then
            let Parens$=KeyPart$(PS+1:PE-1)
            let KeyPart$(PS:PE)=""
            let str2mat(Parens$,mat Parens$,":")
            if udim(mat Parens$)>1 then
               let SPos=val(Parens$(1))
               let EPos=val(Parens$(2))
            end if
         end if
      end if

      ! Next strip any "-xx" modifier (U, YB, Y ...) - only U changes the key value
      let KeyPart$=trim$(KeyPart$)
      IF (DASH:=POS(KEYPART$,"-"))>0 THEN
         IF LWRC$(TRIM$(KEYPART$(DASH+1:LEN(KEYPART$))))="u" THEN LET UPPER=1
         LET KEYPART$=TRIM$(KEYPART$(1:DASH-1))
      end if
   fnend

!
! #Autonumber# 25000,5
CLOSEFILE: ! ***** Close A File, Closing All Indexes == Use Only With Files Opened I/O With This Library
   def library Fnclosefile(Filenumber, Filelay$*255;Path$*255,Out,___,Remaining,Filename$*255,CloseFileSimple)

      dim CF_DummyFileName$*255, CF_DummyFileName2$*255
      ! Out forces not checking if its input or outin - use to increase speed
      !  when you know for a fact the file is opened outin
      !  -1 will force input, 1 will force output, 0 or not specified will check.

      let CloseFileSimple=fnSettings("closefilesimple")

      if Out=-1 or (~Out and fnInput(FileNumber)) then
         close #FileNumber:
      else
         let Remaining=Fnfindindexes(Filelay$,Filename$)

         if CloseFileSimple or ~fn418 then
            let Filename$=srep$(uprc$(filename$),"[WSID]",Wsid$)
            let Filename$=srep$(uprc$(filename$),"[SESSION]",Session$)
         end if

         if kln(FileNumber)=-1 then let Remaining+=1
         do While Filenumber<=999
            if ~CloseFileSimple and fn418 then
               let SleepRetryCount=0
               let CF_DummyFileName$=uprc$(os_filename$(file$(filenumber))) error SleepRetryCount
               let SleepRetryCount=0
               let CF_DummyFileName2$=uprc$(os_filename$(Path$&filename$)) error SleepRetryCount
               if CF_DummyFileName$=CF_DummyFileName2$ then
                  close #(Filenumber): ! Close Only If Its This File
                  let Remaining-=1
               end if
            else
               if POS(uprc$(file$(Filenumber)),"\"&uprc$(Filename$)) OR uprc$(file$(Filenumber))=uprc$(Filename$) then
                  close #(Filenumber): ! Close Only If Its This File
                  let Remaining-=1
               end if
            end if
            let Filenumber+=1
         loop While Remaining>0
      end if
   fnend

   def fnInput(FileNumber;___,DisplayFile,Line$*255,Star$)
      let Star$=fnNeedStar$
      library : fnGetFileNumber
      if exists(`fileinfo.{{session$}}`) then execute `{{Star$}}free fileinfo.{{session$}} -N`
      execute `{{Star$}}status files >fileinfo.{{session$}}`
      open #(DisplayFile:=fnGetFileNumber): "name=fileinfo."&session$, display, input
      ReadNextInfoLine: ! Check the next input line
         linput #DisplayFile: Line$ eof DoneInput
         if pos(lwrc$(Line$),"open file #"&lpad$(str$(FileNumber),3)) then
            linput #DisplayFile: Line$
            if pos(lwrc$(line$),"input") then
               let fnInput=1
            end if
            goto DoneInput
         end if
      goto ReadNextInfoLine
      DoneInput: ! Done fnInput Here
      Close #DisplayFile:
      execute `{{Star$}}free fileinfo.{{Session$}} -N` error Ignore
   fnend
!
! #Autonumber# 25500,2
MAKESUBPROC: ! Read File Layout, Returning All Subscripts As A Procfile
   def library Fnmakesubproc(Filename$*255;Mat Subs$,mat f$,mat f,___,AnFWasGiven,Index,Dummy$*512,Dummy2$*255,Subname$*255,Description$*255,Spec$*255,Layout,Subs,Prefix$*255,LayoutPath$*255,Stringsize,Numbersize,Line$*512,Star$,DateFormat$*50)
      let Star$=fnNeedStar$
      let Layoutpath$=fnSettings$("layoutpath")
      let FileLayoutExtension$=fnSettings$("layoutextension")

      if ~fnopenlayout(layoutpath$&filename$&FileLayoutExtension$) then goto ERRORREADFILELAYOUT
      if fnSMatrixPresent(mat Subs$) then
         mat Subs$(0)
      else
         open #(Subs:=Fngetfilenumber): "Name=subs.$$$, replace", display, output
      end if
      if fnSMatrixPresent(mat F$) and fnNMatrixPresent(mat F) then
         let AnFWasGiven=1
      end if

      let Line$=fnLayoutLinput$
      if uprc$(Line$)<>"#EOF#" then
         let fnReadHeading(Line$,Dummy$,Prefix$,Dummy2$)
         let Prefix$=Trim$(Prefix$)
      else
         print "Incomplete Layout."
         goto ErrorReadFileLayout
      end if

      do
         let Line$=fnLayoutLinput$
         if uprc$(Line$)="#EOF#" then
            print "Incomplete Layout."
            goto ErrorReadFileLayout
         end if
      loop While Uprc$(Line$(1:4))<>"RECL" and Line$(1:4)<>"===="
      if Uprc$(Line$(1:4))="RECL" Then
         let Line$=fnLayoutLinput$
         if uprc$(Line$)="#EOF#" then
            print "Incomplete Layout."
            goto ErrorReadFileLayout
         end if
      end if
!
READNEXTSUBPROCLINE: ! Read The Next Line For Processing
      let Line$=trim$(fnLayoutLinput$)

      if uprc$(Line$)="#EOF#" then goto DONEMAKESUBPROC
      let fnParseDetailLayoutLine(Line$,SubName$,Description$,Spec$,DateFormat$)

      if Trim$(Uprc$(Spec$))(1:2)<>"X " then
         if Trim$(Subname$)<>"" then
            if fnStringSpec(Subname$,Spec$)  then
               let Stringsize+=1
               if Subs then
                  print #Subs: "let "&Trim$(Prefix$)&Trim$(Srep$(Subname$,"$",""))&"="&Str$(Stringsize)
               else
                  let fnAddToSubsArray("let "&Trim$(Prefix$)&Trim$(Srep$(Subname$,"$",""))&"="&Str$(Stringsize),mat Subs$,Star$)
               end if
            else
               let Numbersize+=1
               if Subs then
                  print #Subs: "let "&Trim$(Prefix$)&Trim$(Subname$)&"="&Str$(Numbersize)
               else
                  let fnAddToSubsArray("let "&Trim$(Prefix$)&Trim$(Subname$)&"="&Str$(Numbersize),mat Subs$,Star$)
               end if
            end if
         end if
      end if
      goto READNEXTSUBPROCLINE
DONEMAKESUBPROC: ! We Finished With All The File Layout
      if Subs then close #Subs:
      if AnFWasGiven then
         mat F$(StringSize)
         mat F(NumberSize)
      end if
   fnend


dim AddToSubsCount
AddToSubsArray: ! Adds subscripts to a processing effecient array
   def fnAddToSubsArray(String$*70,mat Subs$,Star$;___,Index)

      let AddToSubsCount+=1
      let Index=udim(mat Subs$)

      if Index=0 or AddToSubsCount>31 or (~fn418 and len(Subs$(Index))>127) then
         gosub AddNewOne
      else
         let Subs$(Index)=Subs$(Index)&":"&String$ SoFlow ErrorAddNewOne
      end if
   fnend

   ErrorAddNewOne: gosub AddNewOne : continue
   AddNewOne: ! Add a new Sub line
      let AddToSubsCount=1
      let Index+=1
      mat Subs$(Index)
      let Subs$(Index)=Star$&String$
   return

   dim Dummy2$(1)*255
   dim Dummy3$(1)*255
   dim Dummy4$(1)*255
   dim Dummy5$(1)*255
   dim ReadForm$*10000
   def library fnReadForm$*10000(Filename$*255;___,Dummy$*255,Dummy,Dummy2,Dummy3)
      let fnReadFileLayout(Filename$,Dummy$,mat Dummy$,mat Dummy2$,mat Dummy3$,ReadForm$,Dummy,Dummy2,0,Dummy3,mat Dummy4$,mat Dummy,mat Dummy5$,1)
      let fnReadForm$=ReadForm$
   fnend
   def library fnReadFormAndSubs(filename$,mat subs$,&readform$,&stringsize,&numbersize)
      let fnReadFileLayout(filename$,dummy$,mat dummy$,mat dummy2$,mat dummy3$,readform$,stringsize,numbersize,0,dummy3,mat dummy4$,mat dummy,mat subs$)
   fnend

   dim LayoutNames$(1)*255
   dim LayoutStart(1)

   dim LayoutData$(1)*511
   dim LayoutLine$*511

   dim CurrentLayout, LayoutPosition

   def library fnClearLayoutCache=fnClearCache
   def fnClearCache
      mat LayoutNames$(0) : mat LayoutStart(0) : mat LayoutData$(0)
   fnend

   def fnOpenLayout(LayoutName$*255;___,Layout)
      let LayoutName$=lwrc$(trim$(LayoutName$))
      let CurrentLayout=srch(mat LayoutNames$,LayoutName$)
      if CurrentLayout>0 then
         ! Found, read it from memory
         let fnOpenLayout=1
      else
         library : fnGetFileNumber
         let CurrentLayout=udim(mat LayoutNames$)+1
         mat LayoutNames$(CurrentLayout)
         mat LayoutStart(CurrentLayout)

         let LayoutPosition=udim(mat LayoutData$)+1

         let LayoutStart(CurrentLayout)=LayoutPosition
         let LayoutNames$(CurrentLayout)=LayoutName$

         ! Read it from the disk and place it in Memory
         open #(Layout:=Fngetfilenumber): "Name="&LayoutName$&",recl=511,shr", display, input error Ignore
         if file(Layout) then
            if exists(LayoutName$) then
               print `There was an error {{err}} opening your file layout.`
            else
               print `Your file layout {{LayoutName$}} could not be found.`
            end if
         else
            do while file(Layout)=0
               linput #Layout: LayoutLine$ eof Ignore
               if file(Layout)=0 then
                  if len(trim$(LayoutLine$)) and trim$(layoutline$)(1:1)<>"!" then
                     mat LayoutData$(LayoutPosition)
                     let LayoutData$(LayoutPosition)=LayoutLine$
                     let LayoutPosition+=1
                     let fnOpenLayout=1
                  end if
               end if
            loop
            close #Layout:
         end if
         mat LayoutData$(LayoutPosition)
         let LayoutData$(LayoutPosition)="#EOF#"
      end if
      let LayoutPosition=LayoutStart(CurrentLayout)
   fnend

   def fnLayoutLinput$*512
      if CurrentLayout and LayoutPosition then
         if LayoutPosition<=udim(mat LayoutData$) then
            let fnLayoutLinput$=srep$(LayoutData$(LayoutPosition),chr$(9),' ')

            let LayoutPosition+=1
         end if
      end if
   fnend

   def fnReadChunk$*255(&Line$;___,P,Chunk$*255)
      let P=pos(line$,",")
      if P>0 then
         let Chunk$=trim$(line$(1:P-1))
         let line$(1:P)=""
      else
         let Chunk$=trim$(line$)
         let Line$=""
      end if
      let fnReadChunk$=Chunk$
   fnend

   dim LineChunks$(1)*255
   def fnParseDetailLayoutLine(Line$*1000,&SubName$,&Description$,&Spec$,&DateFormat$;&Optional4thCol$,___,P,Column4$*255)
      let SubName$=fnReadChunk$(Line$)
      let Description$=fnReadChunk$(Line$)
      let Spec$=fnReadChunk$(Line$)
      let Column4$=fnReadChunk$(Line$)
      let Optional4thCol$=Column4$ soflow Ignore
      let DateFormat$="" ! Default to blank it out.
      if uprc$(column4$(1:5))='DATE[' and column4$(len(column4$):inf)=']' or uprc$(column4$(1:5))='DATE(' and column4$(len(column4$):inf)=')' then
         let dateformat$ = uprc$(column4$(6:len(column4$)-1))
      end if
   fnend

   dim FormStatement$*10000
   dim dateformat$*50
!
! #Autonumber# 26000,5
READFILELAYOUT: ! Read Filelayout, Modify All Parameters, Apply Subscripts
   def Fnreadfilelayout(&Filename$,&Recl$,Mat Keyname$,Mat Kpos$,Mat Klen$,&Form$,&Stringsize,&Numbersize,Dont_Sort_Subs,&Ver,Mat Description$,Mat Fieldwidths;Mat Subs$,DontCForm,mat dateformats$,___,Position,Prefix$,Laststring,Lastnumber,Subs,Line$*512,CalcRecl,Star$,FileLayoutExtension$,DateFormat$*50,BypassFixRpt)

      library : Fnaddtoform

      dim Rfl_Sdescr$(1)*80,Rfl_Ndescr$(1)*80,Rfl_Descr$(1)*80,Rfl_Swidth(1),Rfl_Nwidth(1),Rfl_Width(1)
      dim StringForm$*4000, NumberForm$*4000
      dim Keyname$*255,Description$*255,Tempform$*80,Subname$*80,Ver$*80

      let StringForm$=NumberForm$=""
      let Keyname$=Description$=Tempform$=Subname$=Ver$=""
      mat Keyname$(0) : mat Kpos$(0) : mat Klen$(0) : mat Rfl_Sdescr$(0) : mat Rfl_Ndescr$(0) : mat Rfl_Descr$(0) : mat Rfl_Swidth(0) : mat Rfl_Nwidth(0) : mat Rfl_Width(0) : mat rfl_sdateformats$(0) : mat rfl_ndateformats$(0)  : mat rfl_dateformats$(0)
      let Stringsize=0 : let Numbersize=0 : let Form$=""

      let Star$=fnNeedStar$
      let Layoutpath$=fnSettings$("layoutpath")
      let FileLayoutExtension$=fnSettings$("layoutextension")
      let BypassFixRpt=fnSettings("bypassfixrpt")

      if ~fnOpenLayout(LayoutPath$&FileName$&FileLayoutExtension$) then goto ErrorReadFileLayout

      if fnSMatrixPresent(mat Subs$) then
         mat Subs$(0)
      else
         open #(Subs:=Fngetfilenumber): "Name=subs.$$$, replace", display, output
      end if

      let Line$=fnLayoutLinput$
      if uprc$(Line$)<>"#EOF#" then
         let fnReadHeading(Line$,Filename$,Prefix$,Ver$)
         let Ver=Val(Ver$) error ERRORREADFILELAYOUT
         let Prefix$=Trim$(Prefix$) : let Filename$=Trim$(Filename$)
      else
         print "Incomplete Layout."
         goto ErrorReadFileLayout
      end if

      let Line$=fnLayoutLinput$
      if uprc$(Line$)<>"#EOF#" then
         let fnReadKeys(Line$,KeyName$,Description$)
      else
         print "Incomplete Layout."
         goto ErrorReadFileLayout
      end if

      do While Uprc$(Keyname$(1:4))<>"RECL" and KeyName$(1:4)<>"===="
         mat Keyname$(Udim(Keyname$)+1) !:
         mat Kpos$(Udim(Keyname$)) !:
         mat Klen$(Udim(Keyname$))
         let Keyname$(Udim(Keyname$))=Trim$(Keyname$) !:
         let Kpos$(Udim(Kpos$))=Trim$(Description$) !:
         let Klen$(Udim(Klen$))=Trim$(Description$)

         let Line$=fnLayoutLinput$
         if uprc$(Line$)<>"#EOF#" then
            let fnReadKeys(Line$,KeyName$,Description$)
         else
            print "Incomplete Layout."
            goto ErrorReadFileLayout
         end if
      loop

      if KeyName$(1:4)="====" then
         let CalcRecl=1
      else
         let Recl$=Trim$(Keyname$)
         let Line$=fnLayoutLinput$
         if uprc$(Line$)="#EOF#" then
            print "Incomplete Layout."
            goto ErrorReadFileLayout
         end if
      end if
!
      let Position=1
READNEXTLINE: ! Read The Next Line For Processing
      let Line$=fnLayoutLinput$
      if uprc$(Line$)="#EOF#" then goto DoneReadLayout

      let fnParseDetailLayoutLine(Line$,SubName$,Description$,Tempform$,DateFormat$)

      let Fncheckkeys(Mat Kpos$,Mat Klen$,Trim$(Subname$),Position,Trim$(Tempform$)) error ERRORREADFILELAYOUT
      if Trim$(Tempform$)<>"" then
         if Trim$(Uprc$(Tempform$))(1:2)<>"X " then
            mat Rfl_Descr$(Udim(Mat Rfl_Descr$)+1)
            let Rfl_Descr$(Udim(Mat Rfl_Descr$))=Trim$(Description$)
            mat Rfl_Width(Udim(Mat Rfl_Width)+1)
            let Rfl_Width(Udim(Mat Rfl_Width))=Fndisplaylengthof(Trim$(Tempform$))
            mat rfl_dateformats$(udim(rfl_dateformats$)+1)
            let rfl_dateformats$(udim(rfl_dateformats$))=dateformat$
            if fnStringSpec(Subname$,Tempform$) then
               let Stringsize+=1
               if Subs then
                  print #Subs: Trim$(Prefix$)&Trim$(Srep$(Subname$,"$",""))&"="&Str$(Stringsize)
               else
                  let fnAddToSubsArray(Trim$(Prefix$)&Trim$(Srep$(Subname$,"$",""))&"="&Str$(Stringsize),mat Subs$,Star$)
               end if
               if Laststring<>Position And Position<>1 then let Stringform$=Stringform$&"POS "&Str$(Position)&","
               let Fnaddtoform(Stringform$,Trim$(Tempform$))
               let Laststring=Position+Fnlengthof(Trim$(Tempform$))
               mat Rfl_Sdescr$(Stringsize)
               let Rfl_Sdescr$(Stringsize)=Trim$(Description$)
               mat Rfl_Swidth(Stringsize)
               let Rfl_Swidth(Stringsize)=Fndisplaylengthof(Trim$(Tempform$))
               mat rfl_sdateformats$(stringsize)
               let rfl_sdateformats$(stringsize)=dateformat$
            else
               let Numbersize+=1
               if Subs then
                  print #Subs: Trim$(Prefix$)&Trim$(Subname$)&"="&Str$(Numbersize)
               else
                  let fnAddToSubsArray(Trim$(Prefix$)&Trim$(Subname$)&"="&Str$(Numbersize),mat Subs$,Star$)
               end if
               if Lastnumber<>Position then let Numberform$=Numberform$&"POS "&Str$(Position)&","
               let Fnaddtoform(Numberform$,Trim$(Tempform$))
               let Lastnumber=Position+Fnlengthof(Trim$(Tempform$))
               mat Rfl_Ndescr$(Numbersize)
               let Rfl_Ndescr$(Numbersize)=Trim$(Description$)
               mat Rfl_Nwidth(Numbersize)
               let Rfl_Nwidth(Numbersize)=Fndisplaylengthof(Trim$(Tempform$))
               mat rfl_ndateformats$(Numbersize)
               let rfl_ndateformats$(Numbersize)=dateformat$
            end if
         end if
         let Fnaddtoform(Form$,Trim$(Tempform$))
         let Position+=Fnlengthof(Trim$(Tempform$))
      end if
      goto READNEXTLINE
DONEREADLAYOUT: ! We Finished With All The File Layout
      if CalcRecl then let Recl$="recl="&str$(position-1)
      let fnCheckUprc(mat Kpos$,mat Klen$)
      if ~Dont_Sort_Subs then let Form$=Stringform$&Numberform$
      if ~BypassFixRpt then let fnFindAndFixRpt(Form$)
      let Form$="form "&Form$(1:(Len(Form$)-1))
      if DontCForm then
         ! At least strip out all extra spaces.
         do while pos(Form$,"  ")
            let Form$=srep$(Form$,"  "," ")
         loop
      else
         let FormStatement$=Form$ ! Save this for debugging
         let Form$=Cform$(Form$) error IGNORE
      end if
      if Fnsmatrixpresent(Mat Description$) then
         if Dont_Sort_Subs then ! Resize And Copy Unsorted
            mat Description$(Udim(Mat Rfl_Descr$))=Rfl_Descr$
         else ! Resize And Sort And Copy Seperately
            mat Description$(Stringsize+Numbersize) ! Resize
            if Stringsize>0 then mat Description$(1:Stringsize)=Rfl_Sdescr$ ! Copy Strings
            if Numbersize>0 then mat Description$(Stringsize+1:Stringsize+Numbersize)=Rfl_Ndescr$ ! Copy Numbers
         end if
      end if

      if Fnsmatrixpresent(Mat dateformats$) then
         if Dont_Sort_Subs then ! Resize And Copy Unsorted
            mat dateformats$(udim(rfl_dateformats$))=rfl_dateformats$
         else ! Resize And Sort And Copy Seperately
            mat dateformats$(Stringsize+Numbersize) ! Resize
            if Stringsize>0 then mat dateformats$(1:Stringsize)=rfl_sdateformats$
            if Numbersize>0 then mat dateformats$(Stringsize+1:Stringsize+Numbersize)=rfl_Ndateformats$
         end if
      end if

      if Fnnmatrixpresent(Mat Fieldwidths) then
         if Dont_Sort_Subs then ! Resize And Copy Unsorted
            mat Fieldwidths(Udim(Mat Rfl_Width))=Rfl_Width
         else ! Resize And Sort And Copy Seperately
            mat Fieldwidths(Stringsize+Numbersize) ! Resize
            if Stringsize>0 then mat Fieldwidths(1:Stringsize)=Rfl_Swidth ! Copy Strings
            if Numbersize>0 then mat Fieldwidths(Stringsize+1:Stringsize+Numbersize)=Rfl_Nwidth ! Copy Numbers
         end if
      end if
      if Subs then close #Subs:
      let Fnreadfilelayout=1 ! Success!
      ExitfnReadFileLayout: ! Exit fnReadFileLayout
   fnend
ERRORREADFILELAYOUT: ! Error Encountered Parsing File Layout
   if IgnoreErrors then goto exitfnReadFileLayout
   print "Error parsing file layout: "&Str$(Err)&" on line: "&Str$(Line)
   if Line=27060 then print "Look for a missing comma in your detail lines."
   if Line=25110 then print "Check for proper definition of your keyfiles, terminated by a 'recl=' line."
   if Line=25525 then print "Subscript too long. Look for a missing comma in your detail lines."
   if Line=56825 then print "Invalid Form statement: form "&Form$(1:(Len(Form$)-1))
   if Line=25062 then print "Problem Parsing Version Parameter: "&Ver$
   pause  ! Give User A Chance To Parse Variables
execute "system"
!
! #Autonumber# 27000,2
CHECKKEYS: ! Routine To Check If A Given Subname Matches Part Of A Key Spec
   def Fncheckkeys(Mat Kpos$,Mat Klen$,Subname$*50,Position,Spec$*30;___,Index)
      let Subname$=Srep$(Subname$,"$","")
      for Index=1 to Udim(Mat Kpos$)
         let fnSubstituteKeys(KPos$(Index),Klen$(Index),Subname$,Position,fnLengthOf(Spec$))
      next Index
   fnend

   dim Tmp_Kpos$(1)*80, Tmp_Klen$(1)*80
   def fnSubstituteKeys(&Kpos$,&Klen$,Subname$*50,Position,Length;___,Index)
      let str2mat(KPos$,mat Tmp_Kpos$,"/")
      let str2mat(KLen$,mat Tmp_KLen$,"/")
      for Index=1 to udim(mat Tmp_Kpos$)
         let fnSubstituteKey(Tmp_Kpos$(Index),Tmp_Klen$(Index),Subname$,Position,Length)
      next Index
      let mat2str(mat Tmp_Kpos$,KPos$,"/")
      let mat2str(mat Tmp_Klen$,Klen$,"/")
   fnend

   def fnSubstituteKey(&KPos$,&KLen$,Subname$*50,Position,Length)
      let fnReadPartialSyntax(KPos$,Position,Subname$,"pos")
      let Kpos$=fnSubstitute$(Kpos$,Subname$,str$(Position))
      let fnReadPartialSyntax(Klen$,Length,Subname$,"len")
      let KLen$=fnSubstitute$(Klen$,Subname$,str$(Length))
   fnend

   def fnFindSubname$*80(KeyString$*255;___,P,M)
      let P=pos(KeyString$,"(")
      let M=pos(KeyString$,"-")
      if P>0 then let P-=1 else let P=len(KeyString$)
      if M>0 then
         let M-=1
         let P=min(M,P)
      end if
      let fnFindSubname$=KeyString$(1:P)
   fnend

   ! This function parses the Partial Index syntax. Example:
   !  data\customer.ky2, StartDate(5:8)/StartDate(1:4)/Status
   dim Parens$(1)
   def fnReadPartialSyntax(&KeyString$,&Position,Subname$*50,Switch$;___,Parens$,Adjustment,ParenStart,ParenEnd)
      ! If the sub matches, then we need to check if there's any "()" stuff
      !  if there is, then adjust accordingly
      if (ParenStart:=pos(KeyString$,"(")) then                     ! if we have a "("
         if uprc$(fnFindSubname$(KeyString$))=uprc$(Subname$) then   ! If it matches the sub

            let ParenEnd=pos(KeyString$,")")
            let Parens$=KeyString$(ParenStart+1:ParenEnd-1)

            ! Pull it out of KeyString$
            let KeyString$(ParenStart:ParenEnd)=""

            ! Parse the amounts out of Parens$
            let str2mat(Parens$,mat Parens$,":")

            if udim(mat Parens$)>1 then
               #Select# lwrc$(Switch$(1:1)) #Case# "p"
                  ! For position we want:
                  let Position+=val(Parens$(1))-1
               #Case# "l"
                  let Position=1+val(Parens$(2))-val(Parens$(1))
               #End Select#
            end if
         end if
      end if
   fnend

   def fnSubstitute$*255(KeyString$*255,Subname$*50,Value$;___,P)
      if (P:=pos(KeyString$,"-"))>0 then let P-=1 else let P=len(KeyString$)
      if uprc$(KeyString$(1:P))=uprc$(Subname$) then
         let KeyString$(1:P)=Value$
      end if
      let fnSubstitute$=KeyString$
   fnend

   def fnCheckUprc(Mat Kpos$,mat Klen$;___,Index,seg,dash)
      ! Move each segment's "-xx" modifier (U, YB, Y ...) to follow its length: Kln= 1/1BY/1/20
      for Index=1 to Udim(Mat Kpos$)
         LET STR2MAT(KPOS$(INDEX),MAT TMP_KPOS$,"/")
         LET STR2MAT(KLEN$(INDEX),MAT TMP_KLEN$,"/")
         FOR SEG=1 TO UDIM(MAT TMP_KPOS$)
            IF (DASH:=POS(TMP_KPOS$(SEG),"-"))>0 THEN LET TMP_KPOS$(SEG)=TMP_KPOS$(SEG)(1:DASH-1)
            IF (DASH:=POS(TMP_KLEN$(SEG),"-"))>0 THEN LET TMP_KLEN$(SEG)=TMP_KLEN$(SEG)(1:DASH-1)&UPRC$(TMP_KLEN$(SEG)(DASH+1:LEN(TMP_KLEN$(SEG))))
         NEXT SEG
         LET MAT2STR(MAT TMP_KPOS$,KPOS$(INDEX),"/")
         LET MAT2STR(MAT TMP_KLEN$,KLEN$(INDEX),"/")
      next Index
   fnend

   def fnReadHeading(Line$*512,&FileName$,&Prefix$,&Ver$)
      let fnTakeThing$(Line$,FileName$)
      let fnTakeThing$(Line$,Prefix$)
      let fnTakeThing$(Line$,Ver$)
   fnend

   def fnReadKeys(Line$*512,&KeyName$,&Description$)
      let fnTakeThing$(Line$,KeyName$)
      let fnTakeThing$(Line$,Description$)
   fnend

   def fnTakeThing$(&Line$,&Thing$)
      if Pos(Line$,",") then
         let Thing$=Trim$(Srep$(Line$(1:pos(Line$,",")-1),Chr$(9)," "))
         let Line$=Line$(pos(Line$,",")+1:len(Line$))
      else
         let Thing$=trim$(srep$(Line$,Chr$(9)," "))
         let Line$=""
      end if
   fnend

LENGTHOF: ! ***** Returns The Length Of A Given Spec
   def library fnLength(Spec$)
      let FnLength=FnLengthOf(Spec$)
   fnend
   def Fnlengthof(Spec$*40;___,_Speclen,LENOF_W$*40,LENOF_DOTPOS)
      let Spec$=Spec$&" " ! This Will Make Sure We At Least Have 1 Space
      if Uprc$(Spec$(1:3))="PIC" then
         let _Speclen=Len(trim$(Spec$))-5 ! Pic(##) Returns 2
      else if Uprc$(Spec$(1:3))="FMT" then
         let _Speclen=Len(trim$(Spec$))-5 ! Pic(##) Returns 2
      else if Uprc$(Spec$(1:5))="DATE(" then
         let _Speclen=Len(trim$(Spec$))-6 ! DATE(mm/dd/ccyy) Returns 10
      else if Uprc$(Spec$(1:2))="S " then
         let _Speclen=4
      else if Uprc$(Spec$(1:2))="D " then
         let _Speclen=8
      else if Uprc$(Spec$(1:2))="L " then
         let _Speclen=9
      else
         LET LENOF_W$=SPEC$(POS(SPEC$," "):LEN(SPEC$)) : LET LENOF_DOTPOS=POS(LENOF_W$,".") : IF LENOF_DOTPOS THEN LET LENOF_W$=LENOF_W$(1:LENOF_DOTPOS-1) ! Strip decimal count/variable name -- VAL() errors (and can crash) on a non-numeric decimal suffix such as a variable name (e.g. BH 4.PRICE_)
         LET _SPECLEN=INT(VAL(LENOF_W$)) ERROR ERRORREADFILELAYOUT
      end if
      let Fnlengthof=_Speclen
   fnend
!
! #Autonumber# 27600,10
DISPLAYLENGTHOF: ! ***** Returns The Display Length Of A Given Spec
   def library FnDisplayLength(Spec$)
      let fnDisplayLength=fndisplaylengthof(Spec$)
   fnend
   def Fndisplaylengthof(Spec$;_Speclen)
      let Spec$=uprc$(Spec$)
      let _Speclen=Fnlengthof(Spec$)
      let Spec$=Spec$&" "
      if Pos("S PDL D DLDHDTBLBHB N ZDG ",Spec$(1:2)) then ! If Numeric Spec
         if Spec$(1:2)="PD" then ! Pd Is Different
            let _Speclen=(2*_Speclen)-1+2
         else if Spec$(1:2)="N " or Spec$(1:2)="ZD" or Spec$(1:2)="G " then
            if pos(Spec$,".") then let _Speclen+=1 ! Add 1 for the potential "."
            if Spec$(1:2)="ZD" then let _Speclen+=1 ! Add one of the potential "-"
         else if Spec$(1:2)="L " then ! L keeps max precision 15 decimals plus . and -
            let _SpecLen=17
         else ! All The Others Are About The Same
            let _Speclen=Len(Str$(256**_Speclen))+2
         end if
      end if
      let Fndisplaylengthof=_Speclen
   fnend
!
! #Autonumber# 28000,10
SMATRIXPRESENT: ! ***** Returns True If Optional String Array Is Given
   def Fnsmatrixpresent(;Mat X$)
      if Env$("GUIMODE")="" then ! Non Gui Versions Of Br
         let Fnsmatrixpresent=Udim(X$) ! Don't support regular test
      else

         on error goto SMATRIXNOTPRESENT
         let Fnsmatrixpresent=1 ! Assume True
         mat X$(Udim(X$)) ! Redimension Array To Test If Its Real
         goto ENDSMATRIXPRESENT

         SMATRIXNOTPRESENT: ! Error Means Optional Matrix Not Given
         let Fnsmatrixpresent=0 ! It Wasn't there

         ENDSMATRIXPRESENT: ! We Are Finished
         if G_Updating then
            on error goto ROLLBACKINFULL
         else
            let fnResetErrorHandling ! Turn Off Error Checking
         end if
      end if
   fnend
!
! #Autonumber# 28500,10
NMATRIXPRESENT: ! ***** Returns True If Optional Numeric Array Is Given
   def Fnnmatrixpresent(;Mat X)
      if Env$("GUIMODE")="" then ! Non Gui Versions Of Br
         let Fnnmatrixpresent=Udim(X) ! Don't support regular test
      else
         on error goto NMATRIXNOTPRESENT
         let Fnnmatrixpresent=1 ! Assume True
         mat X(Udim(X)) ! Redimension Array To Test If Its Real
         goto ENDNMATRIXPRESENT
NMATRIXNOTPRESENT: ! Error Means Optional Matrix Not Given
         let Fnnmatrixpresent=0 ! It Wasn't there
ENDNMATRIXPRESENT: ! We Are Finished
         if G_Updating then !:
            on error goto ROLLBACKINFULL !:
         else !:
            let fnResetErrorHandling ! Turn Off Error Checking
      end if
   fnend
!
! #Autonumber# 29000,10
ADDTOFORM: ! ***** This Function Adds Spec$ To Form$ Checking For Repetition. Thanks To Mikhail Zheleznov For The Formula.
   def library Fnaddtoform(&Form$,Spec$*40;_Lastspec$*40,_Repetition,_Lastchunk$*40)
      let _Lastchunk$=Fnlastchunk$(Form$)
      let _Lastspec$=Fnextractspec$(_Lastchunk$)
      let _Repetition=Fnextractrepetition(_Lastchunk$)
      if Trim$(Uprc$(Spec$))=Trim$(Uprc$(_Lastspec$)) then
         let Form$=Form$(1:Len(Form$)-1-Len(_Lastchunk$))
         let Form$=Form$ & Fnbuildchunk$(_Repetition+1,_Lastspec$) & ","
      else
         let Form$=Form$&Spec$&","
      end if
   fnend
!
! #Autonumber# 29500,10
BUILDCHUNK: ! ***** Builds A Chunk Of A Form Statment
   def Fnbuildchunk$*40(Repetition,Spec$)
      if Repetition > 1 then
         let Fnbuildchunk$=Str$(Repetition)&"*"&Spec$
      else
         let Fnbuildchunk$=Spec$
      end if
   fnend
!
! #Autonumber# 29600,10
EXTRACTREPETITION: ! ***** Parses A Spec Statement To Get The Rep Count
   def Fnextractrepetition(Spec$*40)
      if Pos(Spec$,"*") then
         let Fnextractrepetition=Val(Spec$(1:Pos(Spec$,"*")-1))
      else
         let Fnextractrepetition=1
      end if
   fnend
!
! #Autonumber# 29700,10
EXTRACTSPEC: ! ***** Parses A Spec Statement To Get The Raw Spec
   def Fnextractspec$*40(Spec$*40)
      if Pos(Spec$,"*") then
         let Fnextractspec$=Spec$(Pos(Spec$,"*")+1:Len(Spec$))
      else
         let Fnextractspec$=Spec$
      end if
   fnend
!
! #Autonumber# 29800,10
LASTCHUNK: ! ***** Extracts The Final Chunk From A Form Statement
   def Fnlastchunk$*40(&Form$) ! Pass By Ref To Save On Workstack
      let Fnlastchunk$=Form$(Pos(Form$,",",-2)+1:Len(Form$)-1)
   fnend
!
FINDANDFIXRPT: ! Searches Your Form Statement For All Subsets Of It That May Be Shortened
   def Fnfindandfixrpt(&Form$;___,Size,Position) ! Pass And Return Byref To Save On Workstack
      dim Chunk$(1)*127
      dim SearchChunk$*4096
      let Fnparseform(Mat Chunk$,Form$)
      for Size=2 to int(Udim(Mat Chunk$)/2)
         for Position = 1 to Udim(Mat Chunk$)-Size+1
            let Fnstringtogether$(Mat Chunk$(Position:Position+Size-1),SearchChunk$)
            let Fnfixrpt(Form$,SearchChunk$)
         next Position
      next Size
   fnend
!
PARSEFORM: ! Parse Your Form Splitting Out Chunks Into An Array
   def Fnparseform(Mat Chunk$,&Form$;___,Position,Lastposition)
      mat Chunk$(0)
      do While (Position:=Pos(Form$,",",Position+1))
         mat Chunk$(Udim(Mat Chunk$)+1)
         let Chunk$(Udim(Mat Chunk$))=Form$(Lastposition+1:Position)
         let Lastposition:=Position
      loop
   fnend
!
STRINGTOGETHER: ! Build String Out Of Array
   def Fnstringtogether$(Mat Chunk$,&String$) ! Pass Byref To Save Workstack
      let String$=""
      for Index=1 to Udim(Mat Chunk$)
         let String$(4096:0)=Chunk$(Index)
      next Index
   fnend
!
FIXRPT: ! Function To Fix Repeating Paterns In Form Statements, Thanks To Luis Gomez And Cls
   def Fnfixrpt(&Tf$,&Strip$;___,Rpt_Time) ! Pass Byref To Save Workstack
      let Rpt_Time=Int(Len(Tf$)/Len(Strip$))
      do While Pos(Tf$,","&Strip$)>0
         if Rpt_Time>1 then ! Dont put 1*(blahblahblah) because thats stupid
            let Tf$=Srep$(Tf$,","&Rpt$(Strip$,Rpt_Time),","&Str$(Rpt_Time)&"*("&Strip$(1:len(Strip$)-1)&"),")
         end if
      loop While (Rpt_Time-=1)>1
   fnend
!
! #Autonumber# 34000,10
UpdateFile: ! Library call to ensure a file is up to date

   def library fnUpdateFile(FileLayout$;___,FileNumber)
      library : fnOpenFile
      dim UpdateForm$(1)*2000
      dim UpdateData$(1)*255
      dim UpdateData(1)

      let FileNumber=fnOpen(FileLayout$,mat UpdateData$,mat UpdateData,mat UpdateForm$,1)
      Close #FileNumber:
   fnend

READDESCRIPTIONS: ! ***** This Function Returns A String Field From A File Given A Key
   def library Fnreaddescription$*255(Fl,Subscript,Key$*255,Mat F$,Mat F,Mat Fm$;DontChangeKey)
      let fnReadDescription$=fnReadDes$(Fl,Subscript,Key$,mat f$,mat f,mat fm$,DontChangeKey)
   fnend
   def fnReadDes$*255(Fl,Subscript,Key$*255,mat f$,mat f,mat fm$;DontChangeKey)
      mat F$=("") !:
      mat F=(0)
      if ~DontChangeKey then
         let key$=Rpad$(Trim$(Key$)(1:Kln(Fl)),Kln(Fl))
      end if
      read #Fl, using Fm$(Fl), key=key$, release : Mat F$, Mat F nokey IGNORE
      let FnReadDes$=trim$(F$(Subscript)(1:255))
   fnend
READUNOPENEDDESCRIPTION: ! ***** This function returns a string field from a given key and file
   def library fnReadUnopenedDescription$*255(layoutname$,key$*255;Field,DontChangeKey,___,filenumber)
      dim ReadUnopened$(1)*1000, ReadUnopened(1), ReadUnopenedForm$(1)*1000
      library : fnOpenFile
      if ~Field then let Field=2
      let FileNumber=fnOpen(layoutname$,mat ReadUnopened$,mat ReadUnopened,mat ReadUnopenedForm$,1)
      let fnReadUnopenedDescription$=fnReadDes$(FileNumber,Field,key$,mat ReadUnopened$,mat ReadUnopened,mat ReadUnopenedForm$,DontChangeKey)
      close #FileNumber:
   fnend

READNUMBER: ! ***** This Function Returns A Numeric Field From A File Given A Key
   def library Fnreadnumber(Fl,Subscript,Key$*255,Mat F$,Mat F,Mat Fm$;DontChangeKey)
      let fnReadNumber=fnReadNum(Fl,Subscript,Key$,Mat f$,mat f,mat fm$,DontChangeKey)
   fnend
READNUM: ! ***** This Function Returns A Numeric Field From A File Given A Key
   def Fnreadnum(Fl,Subscript,Key$*255,Mat F$,Mat F,Mat Fm$;DontChangeKey)
      mat F$=("") !:
      mat F=(0)
      if ~DontChangeKey then
         let key$=Rpad$(Trim$(Key$)(1:Kln(Fl)),Kln(Fl))
      end if
      read #Fl, using Fm$(Fl), key=key$ : Mat F$, Mat F nokey IGNORE
      let Fnreadnum=F(Subscript)
   fnend
ReadUnopenedNumber: ! ***** This Function Returns A Numeric Field From A File Given A Key
   def library fnReadUnopenedNumber(layoutname$,key$*255;Field,DontChangeKey,___,filenumber)
      library : fnOpenFile
      if ~Field then let Field=1
      let FileNumber=fnOpen(layoutname$,mat ReadUnopened$,mat ReadUnopened,mat ReadUnopenedForm$,1)
      let fnReadUnopenedNumber=fnReadNum(FileNumber,Field,key$,mat ReadUnopened$,mat ReadUnopened,mat ReadUnopenedForm$,DontChangeKey)
      close #FileNumber:
   fnend

ReadRelative: ! These functions read a relative file by record number and return a single field
   ! ***** This Function Returns A String Field From A File Given A record
   def library Fnreadrelativedescription$*255(Fl,Subscript,RecordNumber,Mat F$,Mat F,Mat Fm$)
      let fnReadrelativeDescription$=fnReadrelativeDes$(Fl,Subscript,RecordNumber,mat f$,mat f,mat fm$)
   fnend
   def fnReadrelativeDes$*255(Fl,Subscript,RecordNumber,mat f$,mat f,mat fm$)
      mat F$=("")
      mat F=(0)
      read #Fl, using Fm$(Fl), rec=RecordNumber, release : Mat F$, Mat F norec IGNORE
      let FnReadrelativeDes$=F$(Subscript)
   fnend
   ! ***** This function returns a string field from a record and file
   def library fnReadRelUnopenedDescription$*255(layoutname$,RecordNumber;Field,___,filenumber)
      library : fnOpenFile
      if ~Field then let Field=2
      let FileNumber=fnOpen(layoutname$,mat ReadUnopened$,mat ReadUnopened,mat ReadUnopenedForm$,1)
      let fnReadRelUnopenedDescription$=fnReadRelativeDes$(FileNumber,Field,RecordNumber,mat ReadUnopened$,mat ReadUnopened,mat ReadUnopenedForm$)
      close #FileNumber:
   fnend

   ! ***** This Function Returns A Numeric Field From A File Given A record
   def library Fnreadrelativenumber(Fl,Subscript,RecordNumber,Mat F$,Mat F,Mat Fm$)
      let Fnreadrelativenumber=fnReadRelativeNum(Fl,Subscript,RecordNumber,mat F$,mat f,mat fm$)
   fnend

   def fnReadRelativeNum(Fl,Subscript,RecordNumber,Mat F$,Mat F,Mat Fm$)
      mat F$=("") !:
      mat F=(0)
      read #Fl, using Fm$(Fl), rec=RecordNumber : Mat F$, Mat F norec IGNORE
      let Fnreadrelativenum=F(Subscript)
   fnend

   def library fnReadRelUnopenedNumber(layoutname$,RecordNumber;Field,___,filenumber)
      library : fnOpenFile
      if ~Field then let Field=1
      let FileNumber=fnOpen(layoutname$,mat ReadUnopened$,mat ReadUnopened,mat ReadUnopenedForm$,1)
      let fnReadRelUnopenedNumber=fnReadRelativeNum(FileNumber,Field,RecordNumber,mat ReadUnopened$,mat ReadUnopened,mat ReadUnopenedForm$)
      close #FileNumber:
   fnend

ReadRecordWhere: ! Search a file for a record based on a filter
   def library fnReadRecordWhere$*255(layoutName$,SearchSub,SearchKey$*255,ReturnSub;___,FileNumber,ReturnValue$*255)
      library : fnOpenFile
      let FileNumber=fnOpen(layoutName$,mat ReadUnopened$,mat ReadUnopened,mat ReadUnopenedForm$,1)
      if FileNumber then
         do while file(filenumber)=0
            read #FileNumber, using ReadUnopenedForm$(FileNumber), release : mat ReadUnopened$,mat ReadUnopened error Ignore
            if File(FileNumber)=0 then
               if lwrc$(trim$(ReadUnopened$(SearchSub)))=lwrc$(trim$(SearchKey$)) then
                  let ReturnValue$=ReadUnopened$(ReturnSub)(1:255)
               end if
            end if
         loop until len(trim$(ReturnValue$))
         close #FileNumber:
      end if
      let fnReadRecordWhere$=ReturnValue$
   fnend

!
UNIQUEKEY: ! ***** This Function Searches A File To See If A Key Is Unique
   def library Fnuniquekey(Fl,Key$*255)
      restore #Fl, key=Key$: nokey UNIQUEKEYNOTFOUND
      let Fnuniquekey=0 ! False - Key Is Found So Its Not Unique
      goto ENDUNIQUEKEY
UNIQUEKEYNOTFOUND: ! Key Not Found
      let Fnuniquekey=1 ! True - Key Not Found So It Must Be Unique
ENDUNIQUEKEY: fnend
!
! #Autonumber# 36000,10
READALLKEYS: ! ***** Reads A Given String Element (And Optionally A Second Element) From Every Record Of A File Into Given Arrays
   def library Fnreadallkeys(Fl,Mat F$,Mat F,Mat Fm$,Sub1,Mat Out1$;Sub2,Mat Out2$,Index)
      mat Out1$(0)
      if Sub2 then mat Out2$(0)
      restore #Fl:
NEXTREADALLKEYS: ! Read Next Record
      read #Fl, using Fm$(Fl),release: Mat F$, Mat F eof DONEREADALLKEYS
      mat Out1$(Index:=Udim(Mat Out1$)+1) !:
      let Out1$(Index)=F$(Sub1)
      if Sub2 then !:
         mat Out2$(Index) !:
         let Out2$(Index)=F$(Sub2)
      goto NEXTREADALLKEYS
DONEREADALLKEYS: ! We Finished Reading Here
   fnend
!
! #Autonumber# 36300,10
READMATCHINGKEYS: ! ***** Reads A Given String Element (And Optionally A Second Element) From Every Record Of A File Into Given Arrays Only When Key Element Matches Specified Key. Key Must Match Specified Element Key.
   def library Fnreadmatchingkeys(Fl,Mat F$,Mat F,Mat Fm$,Key$,Keyfld,Sub1,Mat Out1$;Sub2,Mat Out2$,Index)
      mat Out1$(0)
      if Sub2 then mat Out2$(0)
      restore #Fl, key=Key$: nokey DONEREADMATCHINGKEYS
NEXTREADMATCHINGKEYS: ! Read Next Record
      read #Fl, using Fm$(Fl),release: Mat F$, Mat F eof IGNORE
      if (File(Fl)=10) Or (F$(Keyfld)<>Key$) then goto DONEREADMATCHINGKEYS
      mat Out1$(Index:=Udim(Mat Out1$)+1) !:
      let Out1$(Index)=F$(Sub1)
      if Sub2 then !:
         mat Out2$(Index) !:
         let Out2$(Index)=F$(Sub2)
      goto NEXTREADMATCHINGKEYS
DONEREADMATCHINGKEYS: ! We Finished Reading Here
   fnend
!
! #Autonumber# 36600,10
READALLNEWKEYS: ! ***** This Version Of Our Popular Fileio Library Function Reads Only New Items Into The Array.
   def library Fnreadallnewkeys(Fl,Mat F$,Mat F,Mat Fm$,Sub1,Mat Out1$;Dont_Reset,Sub2,Mat Out2$,Index)
      if ~Dont_Reset then mat Out1$(0)
      if (~Dont_Reset) And (Sub2) then mat Out2$(0)
      restore #Fl:

      NEXTREADALLNEWKEYS: ! Read Next Record
         read #Fl, using Fm$(Fl),release: Mat F$, Mat F eof DONEREADALLNEWKEYS
         if Srch(Mat Out1$,F$(Sub1))<1 then ! If Not Found Then
            mat Out1$(Index:=Udim(Mat Out1$)+1) !:
            let Out1$(Index)=F$(Sub1)
            if Sub2 then !:
               mat Out2$(Index) !:
               let Out2$(Index)=F$(Sub2)
         end if
      goto NEXTREADALLNEWKEYS
      DONEREADALLNEWKEYS: ! We Finished Reading Here
   fnend
!
! #Autonumber# 37000,10
READFILTERKEYS: ! ***** Read Matching Keys, But It Also Supports Optional Filters And Up To Four Arrays May Be Populated At Once. If Readlarger=True Then Read All Larger Keys. Function By Mikhail Zheleznov
   def library Fnreadfilterkeys(Fl,Mat F$,Mat F,Mat Fm$,Key$,Keyfld,Sub1,Mat Out1$;Filter$,Filter_Sub,Readlarger,Sub2,Mat Out2$, Sub3, Mat Out3$, Sub4,Mat Out4$, Index)
      mat Out1$(0)
      if Sub2 then mat Out2$(0)
      if Sub3 then mat Out3$(0)
      if Sub4 then mat Out4$(0)
      restore #Fl, key=Key$: nokey DONEREADFILTERKEYS
NEXTREADFILTERKEYS: ! Read Next Record
      read #Fl, using Fm$(Fl),release: Mat F$, Mat F eof IGNORE
      if (File(Fl)=10) Or (~Readlarger And (F$(Keyfld)<>Key$)) Or (Readlarger And (F$(Keyfld)<Key$)) then goto DONEREADFILTERKEYS
      if (Filter$ ~= "" And F$(Filter_Sub) ~= Filter$) then goto NEXTREADFILTERKEYS
      mat Out1$(Index:=Udim(Mat Out1$)+1) !:
      let Out1$(Index)=F$(Sub1)
      if Sub2 then !:
         mat Out2$(Index) !:
         let Out2$(Index)=F$(Sub2)
      if Sub3 then !:
         mat Out3$(Index) !:
         let Out3$(Index)=F$(Sub3)
      if Sub4 then !:
         mat Out4$(Index) !:
         let Out4$(Index)=F$(Sub4)
      goto NEXTREADFILTERKEYS
DONEREADFILTERKEYS: ! We Finished Reading Here
   fnend
!
! #Autonumber# 38000,10
MAKEUNIQUEKEYS: ! ***** Builds A Unique Key For Given File Of Kylen Length
   def library Fnmakeuniquekey$*255(Fl;Random,Prepend$,___,Index,Size)
      let Size=kln(fl)-len(Prepend$)
      library : Fnuniquekey
      dim Mukindexs(1)
      mat Mukindexs(Size)=(0)
      if Random then
         randomize
         for Index=1 to udim(MukIndexs)
            let MukIndexs(Index)=int(rnd*35)
         next Index
      end if
      do While Not Fnuniquekey(Fl,Prepend$&Fnbuildkeyforunique$(Mat Mukindexs))
         if Random then
            for Index=1 to udim(MukIndexs)
               let MukIndexs(Index)=int(rnd*35)
            next Index
         else
            let Mukindexs(1)+=1
            for Index=1 to Udim(Mukindexs)-1
               if Mukindexs(Index)>35 then let Mukindexs(Index)=0 : let Mukindexs(Index+1)+=1
            next Index
            if Mukindexs(Udim(Mukindexs))>35 then let Msgbox("The system cannot sustain more then "&Str$(35**Udim(Mukindexs))&" of these. Please delete old ones and try again.")
         end if
      loop Until Mukindexs(Udim(Mukindexs))>35
      let Fnmakeuniquekey$=Prepend$&Fnbuildkeyforunique$(Mat Mukindexs)
   fnend
!
! #Autonumber# 38500,10
BUILDKEYFORUNIQUES: ! Builds A Key Out Of The Byte Matrix Given
   def Fnbuildkeyforunique$*255(Mat Bkfuindexs;___,Index,Key$*255)
      for Index=Udim(Bkfuindexs) to 1 step -1
         if bkfuindexs(Index)<10 then
            let Key$=Key$&str$(bkfuIndexs(Index))
         else
            let Key$=Key$&Chr$(Bkfuindexs(Index)+55)
         end if
      next Index
      let Fnbuildkeyforunique$=Key$
   fnend
!
! #Autonumber# 39000,10
SEARCHCLOSELY: ! ***** Searches Mat A$ Looking For A Partial Match To B$
   def Fnsearchclosely(Mat A$,B$;___,Index,Found)
      for Index=1 to Udim(Mat A$)
         if Pos(A$(Index),B$) then let Found=Index
      next Index
      let Fnsearchclosely=Found
   fnend

dim __Usr$*10000
!
! #Autonumber# 39500,5
ReadLockedUsers: ! ***** Read all users of the locked file into the given array
   def library fnReadLockedUsers(mat Users$;___,LockFile)
      library : fnGetFileNumber
      execute "Status locks >ERTMP[SESSION]"
      open #(Lockfile:=Fngetfilenumber): "NAME=ERTMP[SESSION]",display,input
      do While __Usr$(1:1)<>"-"
         linput #Lockfile: __Usr$
      loop
      mat Users$(0)
      do until file(LockFile) ! until EOF
         linput #Lockfile: __Usr$ error Ignore
         if file(LockFile)=0 then
            if 1>srch(mat Users$,lwrc$(trim$(__Usr$(26:36)))) then
               mat Users$(udim(mat Users$)+1)
               let Users$(udim(mat Users$))=trim$(lwrc$(__Usr$(26:36)))
            end if
         end if
      loop
      close #Lockfile:
      execute "free ERTMP[SESSION]"
   fnend
!
! #Autonumber# 40000,10
! ****************
! **  Log File  **
! ****************

   def library fnViewLogFile(;ShowQuit,ShowColumns,ShowExport,___,LogLayout$*255,FileLayoutExtension$,LayoutPath$*255,Index)

      if env$("guimode")="OFF" then execute "config gui on"
      let LogLayout$=fnSettings$("loglayout")
      let LayoutPath$=fnSettings$("layoutpath")
      let FileLayoutExtension$=fnSettings$("layoutextension")

      if len(trim$(loglayout$)) and exists(layoutpath$&loglayout$&FileLayoutExtension$) then
         if lwrc$(trim$(LogLayout$))="logfile" then
            ! Build list of columns to show
            dim Columns$(6),W(6),Descr$(6),Forms$(6)
            let Columns$(1)="username" : W(1)=10  : Descr$(1)="Username" : Forms$(1)=""
            let Columns$(2)="program"  : W(2)=12  : Descr$(2)="Program"  : Forms$(2)=""
            let Columns$(3)="session"  : W(3)=4   : Descr$(3)="#"        : Forms$(3)=""
            let Columns$(4)="date"     : W(4)=8   : Descr$(4)="Date"     : Forms$(4)="DATE(mm/dd/ccyy)"
            let Columns$(5)="time"     : W(5)=7   : Descr$(5)="Time"     : Forms$(5)="CC 8"
            let Columns$(6)="message"  : W(6)=200 : Descr$(6)="Message"  : Forms$(6)=""

            ! Configure filters for fnShowData for the LogFile
            dim FilterFields$(2), filterForm$(2), filterDefaults$(2), filterCompare$(2), filterCaption$(2), filterkey(2)
            let FilterFields$(1)="date" : let FilterForm$(1)="DATE(mm/dd/ccyy)" : let FilterDefaults$(1)=str$(days(date$)) : let FilterCompare$(1)=">=" : let FilterCaption$(1)="From Date" : let FilterKey(1)=1
            let FilterFields$(2)="date" : let FilterForm$(2)="DATE(mm/dd/ccyy)" : let FilterDefaults$(2)=str$(days(date$)) : let FilterCompare$(2)="<=" : let FilterCaption$(2)="To Date"   : let FilterKey(2)=-1

            ! Configure the UI for the LogFile
            dim ShowLogUI$(1)
            mat ShowLogUI$(3+ShowQuit+ShowColumns+ShowExport)

            let Index=0
            if ShowQuit then let ShowLogUI$(Index+=1)="quitbutton"
            if ShowExport then let ShowLogUI$(Index+=1)="exportbutton"
            if ShowColumns then let ShowLogUI$(Index+=1)="columnsbutton"
            let ShowLogUI$(Index+=1)="search"
            let ShowLogUI$(Index+=1)="border"
            let ShowLogUI$(Index+=1)="caption"

            ! Show the log file using fnShowData
            library : fnShowData
            let fnShowData("logfile",0,0,0,20,74,1,"Review Log File","","","",Program$,Dummy,mat Columns$,mat ShowLogUI$,mat Descr$,mat W,mat Forms$,"date",mat FilterFields$,mat FilterForm$,mat FilterCompare$,mat FilterCaption$,mat FilterDefaults$,mat FilterKey)
         else
            let fnShowData(LogLayout$,0,0,0,20,74,0,"Review Log File","","","",Program$)
         end if
      else if exists("fileio.log") then
         execute "system -C -M start notepad fileio.log"
      end if
   fnend

ERRLOG: ! ***** Log An Error Entry
   def library Fnerrlog(String$*255;CallingProgram$*255,___,Filehandle)
      library : fnLog
      let fnLog("Error("&Str$(Err)&":"&Str$(Line)&") "&String$,CallingProgram$)
   fnend

   dim LogChanges$(1)*1024, LogChanges(1)
   dim LogSSubs$(1)*255,LogNSubs$(1)*255
   def library fnSetLogChanges(mat f$,mat F)
      mat LogChanges$(udim(mat F$))=F$
      mat LogChanges(udim(mat F))=F
   fnend
   def library fnLogChanges(mat f$,mat F;String$*1048,CallingProgram$*255,Layout$,___,Index,D$)
      library : fnLog, fnReadSubs
      if len(Layout$) then
         let fnReadSubs(Layout$,mat LogSSubs$,mat LogNSubs$,D$)
      else
         mat LogSSubs$(udim(mat F$)) : mat LogNSubs$(udim(mat F))
         for Index=1 to udim(mat F$)
            let LogSSubs$(Index)="String "&str$(Index)
         next Index
         for Index=1 to udim(mat F)
            let LogNSubs$(Index)="Number "&str$(Index)
         next Index
      end if

      let String$=String$&" Changed: "
      for Index=1 to min(udim(mat F$),udim(mat LogChanges$))
         if trim$(F$(Index))<>trim$(LogChanges$(Index)) then
            if len(String$&" "&LogSSubs$(Index)&":"""&trim$(LogChanges$(Index))&""" to """&trim$(f$(Index))&""".")<512 then
               let String$=String$&" "&LogSSubs$(Index)&":"""&trim$(LogChanges$(Index))&""" to """&trim$(f$(Index))&"""."
            else if len(String$&" skipped -")<512 then
               let String$=String$&" skipped -"
            end if
         end if
      next Index
      for Index=1 to min(udim(mat F),udim(mat LogChanges))
         if F(Index)<>LogChanges(Index) then
            if len(String$&" "&LogNSubs$(Index)&":"""&str$(LogChanges(Index))&""" to """&str$(f(Index))&""".") < 512 then
               let String$=String$&" "&LogNSubs$(Index)&":"""&str$(LogChanges(Index))&""" to """&str$(f(Index))&"""."
            end if
         end if
      next Index

      let fnLog(String$(1:512),CallingProgram$)
   fnend

LogArray: ! ***** Log an array and a message
   def library fnLogArray(mat F$,mat F;String$*512,CallingProgram$*255,___,Length,Index,FileNumber)
      library : fnlog

      for Index=1 to udim(mat F$)
         if len(String$)+len(f$(Index))+2>512 then
            let fnLog(String$,CallingProgram$)
            let String$=""
         end if
         let String$=String$&trim$(F$(Index)(1:500))&", "
      next Index
      for Index=1 to udim(mat F)
         if len(String$)+len(str$(f(Index)))+2>512 then
            let fnLog(String$,CallingProgram$)
            let String$=""
         end if
         let String$=String$&str$(F(Index))(1:500)&", "
      next Index
      let fnLog(String$,CallingProgram$)
   fnend

   dim LogData$(1)*512
   dim LogData(1)
   dim LogForm$(1)*256

LOG: ! ***** Log An Entry
   def library Fnlog(String$*512;CallingProgram$*255,ForceTextfile,___,Filehandle,LogLibrary$*255,LogLayout$,SuppressLoggingErr)
      let LogLibrary$=fnSettings$("loglibrary")
      let LogLayout$=fnSettings$("loglayout")
      let SuppressLoggingErr=fnSettings("suppressloggingerr")

      if ~ForceTextfile and len(trim$(LogLibrary$)) then
         library LogLibrary$ : fnFileIOLog
         if len(trim$(LogLayout$)) then
            let fnLog=fnFileIOLog(String$,Login_Name$,Session$,days(Date$("mm/dd/ccyy"),"mm/dd/ccyy"),Time$("hh:mm:ss"),CallingProgram$(len(CallingProgram$)-39:len(CallingProgram$)))
         else
            if len(CallingProgram$) then let CallingProgram$=CallingProgram$&" - "
            let fnLog=fnFileIOLog(CallingProgram$(len(CallingProgram$)-39:len(CallingProgram$))&String$)
         end if
      else if ~ForceTextfile and len(trim$(LogLayout$)) then
         library : fnOpenFile,fnCloseFile
         let FileHandle=fnOpen(LogLayout$,mat LogData$,mat LogData,mat LogForm$,0,0,0,"",mat Dummy$,mat Dummy,0,1)
         if FileHandle then
            let LogData$(log_Program)=CallingProgram$(len(CallingProgram$)-39:len(CallingProgram$))
            let LogData$(log_Username)=Login_Name$
            let LogData$(log_Session)=Session$
            let LogData$(log_Time)=Time$("hh:mm:ss")
            let LogData$(log_Message)=String$(1:255)
            let LogData(log_date)=days(Date$("mm/dd/ccyy"),"mm/dd/ccyy")

            write #FileHandle, using LogForm$(FileHandle) : mat LogData$,mat LogData error ErrorUseTextFile
            let fnCloseFile(FileHandle,LogLayout$,"",1)
         else
            goto ErrorUseTextFile
         end if
      else
         UseTextFile: ! Use a text logfile.
         let LoggingRetryCount=0
         library : Fngetfilenumber
         open #(Filehandle:=Fngetfilenumber) : "Name=FileIO.log, use, recl=658",display,output locked RetryLogging
         if file(filehandle)<>-1 then
            print #Filehandle: "User: "&Login_Name$&" - Session ID: "&Session$&" - Date: "&Date$("mm/dd/ccyy")&" - "&Time$("hh:mm:ss")&" - Program: "&CallingProgram$&": "&String$
            close #Filehandle:
         end if
      end if
   fnend

ErrorUseTextFile: ! Couldn't write to log file, msg user and use text
   if ~SuppressLoggingErr then let msgbox("A file is locked on the server. Please restart the server if the problem continues.")
goto UseTextFile

dim LoggingRetryCount

RetryLogging: !
   if LoggingRetryCount<20 then
      let LoggingRetryCount+=1
      sleep(.1)
      retry
   else
      let LoggingRetryCount=0
      continue
   end if

!
! #Autonumber# 42000,10
NOTINFILE: ! ***** Search A Given Spot In A File For A Given String, Return True If Not Found
   def library Fnnotinfile(String$*100,Filename$,Sub;Path$,___,Filenumber)
      library : Fnopenfile,Fnreadallkeys
      dim F$(1)*255,F(1),Fmmm$(1)*2000,Filelist$(1)*255
      let Filenumber=Fnopen(Filename$,Mat F$,Mat F,Mat Fmmm$,1,0,0,Path$)
      let Fnreadallkeys(Filenumber,Mat F$,Mat F,Mat Fmmm$,Sub,Mat Filelist$)
      if Fnsearchclosely(Mat Filelist$,String$)=0 then let Fnnotinfile=1
      close #Filenumber: !:
   fnend

GetFileDateTime: ! Performs a directory listing to get the date of a file
   def library fnGetFileDateTime$(FileName$*255)=fnGetFileDT$(FileName$)
   def fnGetFileDT$(FileName$*255;___,DirFile,Dummy$*255,Star$)
      let Star$=fnNeedStar$
      library : Fngetfilenumber
      execute Star$&"dir "&FileName$&" >xxx[SESSION]"
      open #(Dirfile:=Fngetfilenumber) : "Name=xxx[SESSION]", display,input
      do
         linput #Dirfile: Dummy$ eof Ignore
         if file(DirFile)=0 then
            if lwrc$(trim$(Dummy$(46:99)))=lwrc$(trim$(FileName$(pos(FileName$,"\",-1)+1:len(FileName$)))) then
               let fnGetFileDT$=Dummy$(27:42)
            end if
         end if
      loop while file(DirFile)=0
      close #Dirfile:
      let ErrorRetrycount=0
      execute Star$&"free xxx[SESSION] -n" error RetryCount
   fnend
!
! #Autonumber# 43000,10
READLAYOUTS: ! ***** Reads Into A Given Array The List Of File Layouts
   def library Fnreadlayouts(Mat Dirlist$;OverrideExtension$,___,Dummy$*255,Dirfile,FileLayoutExtension$,Layoutpath$*255,Star$)
      let Star$=fnNeedStar$
      library : Fngetfilenumber

      let Layoutpath$=fnSettings$("layoutpath")
      let FileLayoutExtension$=fnSettings$("layoutextension")
      if OverrideExtension$><"" then let FileLayoutExtension$=OverrideExtension$

      mat Dirlist$(0)
      execute star$&"dir "&layoutPath$&"*"&FileLayoutExtension$&" >xxx" error DoneReadingFileNames
      open #(Dirfile:=Fngetfilenumber) : "Name=xxx", display,input
      READFILENAME: ! Read The Next File Name
      linput #Dirfile: Dummy$ eof DONEREADINGFILENAMES
      if trim$(uprc$(dummy$(11:13)))=trim$(uprc$(FileLayoutExtension$(2:4))) and ~pos(dummy$,"<DIR>") then
         mat dirlist$(udim(dirlist$)+1)
         let dummy$=trim$(dummy$(44:99))
         if FileLayoutExtension$<>'' and FileLayoutExtension$><"." then
            let dummy$=dummy$(1:pos(lwrc$(dummy$),lwrc$(FileLayoutExtension$))-1)
         end if
         dirlist$(udim(dirlist$))=dummy$(1:30)
      end if
      goto READFILENAME
      DONEREADINGFILENAMES: ! Finished
      if DirFile and file(DirFile)>-1 then close #Dirfile:
      execute Star$&"free xxx"
   fnend


   def library fnDirVersionHistoryFiles(Layout$,mat DirList$;BypassExtension$,___,Dummy$*255,Dirfile,LayoutPath$*128,Star$)
      let Layoutpath$=fnSettings$("layoutpath")

      let Star$=fnNeedStar$

      library : Fngetfilenumber

      mat Dirlist$(0)
      if exists("tmpdir[session]") then execute Star$&"free tmpdir[session]"
      execute star$&"dir "&layoutPath$&"version\"&Layout$&"* >tmpdir[session]" error Ignore
      if exists("tmpdir[session]") then
         open #(Dirfile:=Fngetfilenumber) : "Name=tmpdir[session]", display,input
         ReadVersionFileName: ! Read The Next File Name
         linput #Dirfile: Dummy$ eof DoneReadVersionFiles
         if fnTestVersionHistoryFile(Dummy$,BypassExtension$) then
            mat dirlist$(udim(dirlist$)+1)
            let dummy$=trim$(dummy$(44:99))
            let dirlist$(udim(dirlist$))=dummy$(1:30)
         end if
         goto ReadVersionFileName
         DoneReadVersionFiles: ! Finished
         close #Dirfile:

         execute Star$&"free tmpdir[session]"
      end if
   fnend

   def fnTestVersionHistoryFile(Line$*255;BypassExtension$)
      if BypassExtension$="" or trim$(uprc$(Line$(11:13)))><trim$(uprc$(BypassExtension$(2:4))) then
         if ~pos(Line$,"<DIR>") and Line$(1:13)><"Directory of " and ~pos(Line$,"Kilobytes Used,") then
            let fnTestVersionHistoryFile=1
         end if
      end if
   fnend
!
DOESLAYOUTEXIST: ! Return True If Layout Exists In The Layouts Folder
   def library Fndoeslayoutexist(Layout$;___,Layoutpath$*255,FileLayoutExtension$)
      let Layoutpath$=fnSettings$("layoutpath")
      let FileLayoutExtension$=fnSettings$("layoutextension")
      let Layout$=trim$(Layout$)

      if trim$(layout$)<>"" then
         let fndoeslayoutexist = exists(layoutpath$&layout$&FileLayoutExtension$)
      end if
   fnend

LayoutPath: ! This funtion reads the layout path
   def library FnReadLayoutPath$*255=fnSettings$("layoutpath")
   def library FnReadLayoutExtension$=fnSettings$("layoutextension")

ReadTemplates: ! ***** Reads Into A Given Array The List Of File Layouts
   dim TemplateList$(1)
   dim TemplateDescription$(1)*255
   def fnReadTemplates(Mat Dirlist$,mat TemplateDesc$,mat TemplateNum;___,Dummy$*255,Dirfile,TemplatePath$*255,Index,Spot,Jndex,Star$)
      let Star$=fnNeedStar$
      library : Fngetfilenumber
      let TemplatePath$=fnSettings$("templatepath")
      mat TemplateList$(0)
      execute Star$&"dir "&TemplatePath$&" >xxx" error Ignore
      if exists("xxx") then
         open #(Dirfile:=Fngetfilenumber) : "Name=xxx", display,input
         READtemplateNAME: ! Read The Next File Name
         linput #Dirfile: Dummy$ eof DONEREADINGtemplateNAMES
         if (trim$(lwrc$(Dummy$(11:13)))="wb" or trim$(lwrc$(Dummy$(11:13)))="br") And ~Pos(Dummy$,"<DIR>") then
            mat TemplateList$(Udim(TemplateList$)+1) !:
            let TemplateList$(Udim(TemplateList$))=Trim$(Dummy$(44:99))(1:30)
         end if
         goto READtemplateNAME
         DONEREADINGtemplateNAMES: ! Finished
         close #Dirfile:
         execute Star$&"free xxx"
      end if

      mat DirList$(0) : mat TemplateDesc$(0) : mat TemplateNum(0)
      for Index=1 to udim(mat TemplateList$)
         ! attempt library linkage

         library TemplatePath$&TemplateList$(Index) : fnTemplateList, fnRunTemplate error SkipThisTemplate
         let fnTemplateList(mat TemplateDescription$) error SkipThisTemplate

         let Spot=udim(mat DirList$)
         mat DirList$(udim(mat TemplateDescription$)+Spot)
         mat DirList$(Spot+1:Spot+udim(mat TemplateDescription$))=(TemplatePath$&TemplateList$(Index))
         mat TemplateDesc$(udim(mat TemplateDescription$)+Spot)
         mat TemplateDesc$(Spot+1:Spot+udim(mat TemplateDescription$))=TemplateDescription$
         mat TemplateNum(udim(mat TemplateDescription$)+Spot)
         for Jndex=1 to udim(mat TemplateDescription$)
            let TemplateNum(Spot+Jndex)=Jndex
         next Jndex
         SkipThisTemplate: ! Skip to here if a file isn't a template.
      next Index
   fnend

   ! Ignore layouts we're supposed to ignore.
   def fnIgnoreLayouts(mat LvDir_Listing$;___,_IgnoreLayouts$*255,dc_Index,dc_Jndex)
      let _IgnoreLayouts$=fnSettings$("ignorelayouts")
      for dc_Index=1 to udim(mat lvdir_listing$)
         if ~pos(lwrc$(_IgnoreLayouts$),lwrc$(trim$(lvdir_listing$(dc_index)))) then
            let dc_Jndex+=1
            let lvDir_Listing$(dc_Jndex)=lvDir_Listing$(dc_Index)
         end if
      next dc_Index
      mat lvDir_Listing$(dc_Jndex)
   fnend
!
! #Autonumber# 50000,10
RenameLayouts: ! Rename Layouts
   let fnRenameLayoutExtension
   if fkey=93 then execute "system"
   stop

   dim TmpDirList$(1)*128
   def fnCheckForNewExtension(mat LvDir_Listing$)
      if udim(mat Lvdir_Listing$)=0 and len(trim$(fnSettings$("layoutextension")))>0  then
         let fnReadLayouts(Mat TmpDirList$,".")
         if udim(mat TmpDirList$) then
            dim LongMessage$*10000
            let LongMessage$="I'm not seeing any layouts but I found some using your old layout extension. Would you like to "
            let LongMessage$(99999:0)="run the Rename Layout Extension Wizard to rename all your layout files to use the new "
            let LongMessage$(99999:0)="layout extension? (You can run the Rename Layout Extension Wizard at any time by loading "
            let LongMessage$(99999:0)="fileio and typing ""run 50000"", though you should only do that when you actually want to change the extension.)"
            if (2==msgbox(LongMessage$,"New Layout Extension Detected","yN","QST")) then
               let Count=fnRenameLayoutExtension
               let Fnreadlayouts(Mat Lvdir_Listing$)
               let msgbox("We renamed "&str$(Count)&" layouts and layout history files. Please test every data file in your system and then archive your old file layouts so you don't accidentally change the wrong ones.","Upgrade Complete")
            end if
         end if
      end if
   fnend

   def fnRenameLayoutExtension(;___,Count)
      library : fnGetFileNumber
      let ToExt$=fnSettings$("layoutextension")
      let FromExt$="."
      open #(Window:=fnGetFileNumber): "srow=10,scol=30,rows=3,cols=25,border=s,caption=Change Extension",display,outin
      print #Window, fields "1,1,CR 10;2,1,CR 10" : "From Ext: ", "To Ext: "
      print #Window, fields "3,1,CC 25" : "Press Enter to Continue"
      do
         rinput #Window, fields "1,12,V 10,/W:W;2,12,V 10,/W:W" : FromExt$,ToExt$
      loop until fkey=99 or fkey=93 or fkey=0
      close #Window:
      execute "con gui off"
      if fkey=0 then let Count=fnRenameLayouts(FromExt$,ToExt$)
      execute "con gui on"
      let fnRenameLayoutExtension=Count
   fnend

   dim LayoutRename$(1)*128
   dim VersionRename$(1)*128
   def fnRenameLayouts(FromExt$,ToExt$;___,Index,Jndex,LayoutPath$*128,Count)
      let Layoutpath$=fnSettings$("layoutpath")
      library : fnReadLayouts, fnDirVersionHistoryFiles
      let fnReadLayouts(mat LayoutRename$,FromExt$)
      for Index=1 to udim(mat LayoutRename$)
         if ~exists(LayoutPath$&LayoutRename$(Index)&ToExt$) then
            execute "copy """&LayoutPath$&LayoutRename$(Index)&FromExt$&""" """&LayoutPath$&LayoutRename$(Index)&ToExt$&""""
            let Count+=1
         else
            print "Bypassing - Already Exists: "&LayoutPath$&LayoutRename$(Index)&ToExt$
         end if
         let fnDirVersionHistoryFiles(LayoutRename$(Index),mat VersionRename$,ToExt$)
         for Jndex=1 to udim(mat VersionRename$)
            if ~exists(LayoutPath$&"version\"&VersionRename$(Jndex)&ToExt$) then
               execute "copy """&LayoutPath$&"version\"&VersionRename$(Jndex)&FromExt$&""" """&LayoutPath$&"version\"&VersionRename$(Jndex)&ToExt$&""""
               let Count+=1
            else
               print "Bypassing - Already Exists: "&LayoutPath$&"version\"&VersionRename$(Jndex)&ToExt$
            end if
         next Jndex
      next Index
      print "Copied "&str$(Count)&" files."
      let fnRenameLayouts=Count
   fnend

MESSAGEBOX: ! ***** Displays A Message Box In New Or Old Gui
   def Fnmessagebox(Message$*60;Title$*20,_Window,_Choice,_Kp$)
      library : Fngetfilenumber
      if Trim$(Env$("guimode"))="" then ! Old Gui Version
         open #(_Window:=Fngetfilenumber): "SROW=10,SCOL=10,EROW=14,ECOL=69,Border=S,Caption="&Title$,display,outin
         print #_Window: Newpage
         print #_Window, fields "2,1,CC 60" : Message$
         print #_Window, fields "4,1,CR 29" : "Answer (Y/N):"
         do
            rinput #_Window, fields "4,31,C 1" : _Kp$
         loop Until (Fkey=0 And (Uprc$(_Kp$)="Y" Or Uprc$(_Kp$)="N")) Or Fkey=99
         if Fkey=0 And Uprc$(_Kp$)="Y" then let Fnmessagebox=1 else let Fnmessagebox=0
         close #_Window:
      else ! New Gui Version
         let _Choice=Msgbox(Message$,Title$,"okC")
         if _Choice=1 then let Fnmessagebox=1 else let Fnmessagebox=0
      end if
   fnend

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
KEY: ! ***** This Function Calculates The Key For A File
   def library Fnkey$*255(Filenumber, Key$*255)
      let Fnkey$=Rpad$(Key$,Kln(Filenumber))
   fnend

SortKeys: ! This function will sort the records given in the mat Keys$
   ! array into the order specified by a given key file.

   dim SortKey$(1)*255
   dim Sorted(1)

   def library fnSortKeys(mat Keys$,Layout$,DataFile,mat F$,mat F,mat Form$;KeyNum,___,Index)
      library : fnBuildKey$
      mat SortKey$(udim(mat Keys$))
      mat Sorted(udim(mat Keys$))

      for Index=1 to udim(mat Keys$)
         read #DataFile, using form$(DataFile), key=keys$(Index), release : mat F$, mat F
         if file(DataFile)=0 then
            let SortKey$(Index)=fnBuildKey$(Layout$,mat F$,mat F,KeyNum)
         end if
      next Index

      mat Sorted=aidx(SortKey$)
      mat SortKey$=Keys$

      for Index=1 to udim(mat Keys$)
         let Keys$=SortKey$(Sorted(Index))
      next Index
   fnend

   dim OpenStatementList$(1)*127

SearchLegacyReadStatements: ! This function searches all your programs to see which ones open this file, and lists any read and write statements from those programs.
   def library fnSearchLegacyReadStatements(Layout$*64;OutputFile$*64,___,OutputFile,SearchFileName$)
      let msgbox("We're Sorry! This functionality has not been implemented yet.","Not Implemented")
      /*

      if OutputFile$="" then let OutputFile$=layout$&"_reads.out"
      execute "free "&OutputFile$

      ! First, get the file name from the layout !! $$$$$ Fix the following code later to parse it from the name inside the layout.
      let SearchFileName$=Layout$
      let OpenStatementList$="01000 OPEN #5: ""name="&SearchFileName$&",internal,input,relative"
      let fnSearchPrograms(mat OpenStatementList$)

      ! First, search all programs, just wb and br files, for programs that open the given file.
      ! If any are found, then search for all open statements.
      !    For each open statement found, print it
      !    and also then print all read and write statements to that given file after that, into the layout$&".out" file.



 */







   fnend





   dim StatFile$(1)*255
   dim AuditKeys$(1)*255
   dim FileList$(1)*255
   dim statHeadings$(1)
   dim StatWidth(1)
   dim StatForm$(1)

BeginAudit: ! ***** This function will create an Audit Comparison folder for all your data files.
   def library fnBeginAudit(;BackupFolder$*80,Path$*255,mat SelectedFiles$,___,Index,FileName$*255,Jndex)
      if trim$(BackupFolder$)="" then let BackupFolder$=fnSettings$("auditpath")
      library : fnCopyDataFiles
      let fnCopyDataFiles(BackupFolder$,Path$,mat SelectedFiles$) ! ,2)
   fnend

   dim CallAuditFileList$(1)*255
   def fnCallAudit(Mat Sel,mat Files$;Path$*255,___,Index)

      ! Convert mat Selection and mat Files$ into mat Selected Files
      mat CallAuditFileList$(udim(mat Sel))
      for Index=1 to udim(mat CallAuditFileList$)
         let CallAuditFileList$(Index)=Files$(Sel(Index))
      next Index

      let fnCompareFiles(mat CallAuditFileList$,Path$)
      let fnSetFiles(mat CallAuditFileList$,Path$)
   fnend

   def fnSetFiles(;mat SelectedFiles$,Path$*255)
      library : fnBeginAudit
      let fnBeginAudit("",Path$,mat SelectedFiles$)
   fnend

   def fnCompareFiles(;mat SelectedFiles$,Path$*255,___,BackupFolder$*255)
      let BackupFolder$=fnSettings$("auditpath")
      let fnAddTrailingSlash(BackupFolder$)
      if exists(BackupFolder$) then
         library : fnCompare
         let fnCompare(BackupFolder$,BackupFolder$&"audit.txt",1,0,Path$,mat SelectedFiles$)
      end if
   fnend

   def fnCleanFilename$*255(FileName$*255)
      let fnCleanFilename$=srep$(Filename$,":","")
   fnend

   Compare: ! ***** This function will compare two data sets
   def library FnCompare(;BackupFolder$*80,Logfile$*80,Printer,DontClose,Path$*255,mat SelectedLayouts$,___,Count,Index,NewFile,OldFile,OutFile,FileName$*255,TotalRecords,CurRecMessage$*255,LastUpdateMessageTime)
      dim FileList$(1)*255
      dim NewF$(1)*1024,NewF(1)
      dim OldF$(1)*1024,OldF(1)
      dim CompareForm$(1)*255
      dim Records(1)

      dim Dummy$(1)*1024
      dim Dummy(1)

      if trim$(BackupFolder$)="" then let BackupFolder$=fnSettings$("auditpath")

      let fnAddTrailingSlash(BackupFolder$)
      let fnAddTrailingSlash(Path$)
      if Path$="\" then let Path$=""

      library : fnReadLayouts, fnOpenFile, fnGetFileNumber, fnBuildKey$, FnReadLayoutHeader, fnProgressBar, fnCloseBar
      let fnPrinterSys

      if len(trim$(LogFile$)) then
         open #(OutFile:=fnGetFileNumber): "name="&LogFile$&",recl=2048,use", display,output
      end if

      if Printer then
         open #255: "name=preview:/,recl=2048",display,output
         print #255: "[Landscape][A4PAPER][SetFont(Lucida Console)][CPI(15)]"
      end if

      if OutFile then print #OutFile: "File Compare started at "&Time$&" on "&Date$("month dd, ccyy")
      if Printer then print #255: "File Compare started at "&Time$&" on "&Date$("month dd, ccyy")

      if ~exists(BackupFolder$) then
         if OutFile then print #OutFile: "Backup Folder not Found."
         if Printer then print #255: "Backup Folder not Found."
      else
         if fnValidMat(mat SelectedLayouts$) then
            mat FileList$(udim(SelectedLayouts$))=SelectedLayouts$
         else
            let fnReadLayouts(mat FileList$)
         end if

         for Index=1 to udim(mat FileList$)
            let fnReadLayoutHeader(FileList$(Index),FileName$)
            if exists(Path$&FileName$) and exists(BackupFolder$&fnCleanFileName$(Path$&FileName$)) then

               let NewFile=fnOpen(FileList$(Index),mat NewF$,mat NewF,mat Compareform$,1,-1,0,Path$,mat Dummy$,mat Dummy,1)
               if NewFile then

                  ! Open OldFile, using same info as New File
                  open #(OldFile:=fnGetFileNumber) : "name="&BackupFolder$&fnCleanFileName$(Path$&FileName$),Internal,Outin,Relative error Ignore
                  if file(OldFile)=0 then
                     mat CompareForm$(max(udim(mat CompareForm$),OldFile))
                     let CompareForm$(OldFile)=CompareForm$(NewFile)
                     mat OldF$(udim(mat NewF$)) : mat OldF(udim(mat NewF))

                     let TotalRecords=(max(1,lrec(NewFile)+lrec(OldFile)))

                     if OutFile then print #OutFile: "Comparing File: "&FileList$(Index)
                     if Printer then print #255: "Comparing File: "&FileList$(Index)

                     mat Records(0)=(0)
                     let Count=0
                     do until file(NewFile)=10 ! eof
                        read #NewFile, using Compareform$(NewFile) : mat NewF$,mat NewF error Ignore
                        if file(NewFile)=0 then
                           Mat Records(udim(Mat Records)+1)
                           let Records(udim(Mat Records))=rec(NewFile)

                           read #OldFile, using Compareform$(OldFile), rec=rec(NewFile) : mat OldF$,mat OldF norec Ignore

                           if File(OldFile) then
                              ! Log a Record is Added message
                              if OutFile then
                                 print #Outfile: "Record "&str$(rec(NewFile))&" was added with key: '"&fnBuildKey$(FileList$(Index),mat NewF$,mat NewF)&"', The Data was:";
                                 let fnPrintArrays$(OutFile,mat NewF$,mat NewF)
                              end if

                              if Printer then
                                 print #255: "[GREEN]Record "&str$(rec(NewFile))&" was added with key: '"&fnBuildKey$(FileList$(Index),mat NewF$,mat NewF)&"', The Data was:";
                                 let fnPrintArrays$(255,mat NewF$,mat NewF)
                                 print #255: "[BLACK]";
                              end if
                           else
                              ! Compare two records, log both records
                              if fnSameas(mat NewF$,mat OldF$) and fnSameA(mat NewF,mat OldF) then
                                 ! Do nothing, we're fine
                              else
                                 if OutFile then
                                    print #Outfile: "Record "&str$(rec(NewFile))&" with key: '"&fnBuildKey$(FileList$(Index),mat NewF$,mat NewF)&"' was changed."
                                    print #OutFile: "The Data was: ";
                                    let fnPrintArrays$(OutFile,mat OldF$,mat OldF)
                                    print #OutFile: "   It is now: ";
                                    let fnPrintArrays$(Outfile,mat NewF$,mat NewF)
                                 end if

                                 if Printer then
                                    print #255: "Record "&str$(rec(NewFile))&" with key: '"&fnBuildKey$(FileList$(Index),mat NewF$,mat NewF)&"' was changed."
                                    print #255: "The Data was: ";
                                    let fnPrintArrays$(255,mat OldF$,mat OldF,1,mat NewF$,mat NewF,14)
                                    print #255: "   It is now: ";
                                    let fnPrintArrays$(255,mat NewF$,mat NewF,1,mat OldF$,mat OldF,14)
                                 end if
                              end if
                           end if
                        else if file(newfile)<>10 then
                           ! Log an Error Reading File message
                           if OutFile then print #Outfile: "Warning: Error Reading Record "&str$(rec(NewFile))&" in the current data. Record Skipped."
                           if Printer then print #255: "[RED]Warning: Error Reading Record "&str$(rec(NewFile))&" in the current data. Record Skipped.[BLACK]"
                        end if
                        let Count+=1
                        if (Timer-LastUpdateMessageTime)>.2 then
                           let LastUpdateMessageTime=Timer
                           let CurRecMessage$=" ("&str$(Count)&"/"&str$(TotalRecords)&")"
                        end if
                        let fnProgressBar(Count/TotalRecords,"",0,0,0,"Comparing Files","Checking for Adds/Edits, File "&str$(Index)&"/"&str$(udim(mat FileList$))&" ("&FileList$(Index)&")"&CurRecMessage$)
                     loop
                     restore #OldFile:
                     do until file(OldFile)=10 ! Eof
                        read #OldFile, using CompareForm$(OldFile) : mat OldF$,mat OldF error Ignore
                        if file(OldFile)=0 then
                           if srch(Records,rec(OldFile))<1 then
                              if OutFile then
                                 print #Outfile: "Record "&str$(rec(OldFile))&" was deleted with key: '"&fnBuildKey$(FileList$(Index),mat OldF$,mat OldF)&"', The Data was:";
                                 let fnPrintArrays$(OutFile,mat OldF$,mat OldF)
                              end if
                              if Printer then
                                 print #255: "[RED]Record "&str$(rec(OldFile))&" was deleted with key: '"&fnBuildKey$(FileList$(Index),mat OldF$,mat OldF)&"', The Data was:";
                                 let fnPrintArrays$(255,mat OldF$,mat OldF)
                                 print #255: "[BLACK]";
                              end if
                           end if
                        else if file(OldFile)<>10 then
                           ! Log an Error Reading File message
                           if OutFile then
                              print #Outfile: "Warning: Error Reading Record "&str$(rec(OldFile))&" in the history data. Record Skipped."
                           end if

                           if Printer then
                              print #255: "[RED]Warning: Error Reading Record "&str$(rec(OldFile))&" in the history data. Record Skipped.[BLACK]"
                           end if
                        end if
                        let Count+=1
                        if (Timer-LastUpdateMessageTime)>.2 then
                           let LastUpdateMessageTime=Timer
                           let CurRecMessage$=" ("&str$(Count)&"/"&str$(TotalRecords)&")"
                        end if
                        let fnProgressBar(Count/TotalRecords,"",0,0,0,"Comparing Files","Checking for Deletes, File "&str$(Index)&"/"&str$(udim(mat FileList$))&" ("&FileList$(Index)&")"&CurRecMessage$)
                     loop

                     Close #OldFile:
                     let fnCloseBar
                  end if
                  Close #NewFile:
               end if
            else
               if ~exists(Path$&FileName$) then
                  if OutFile then print #OutFile: "Cannot Compare File: "&FileList$(Index)&" - The Data File doesn't exist"
                  if Printer then print #255: "Cannot Compare File: "&FileList$(Index)&" - The Data File doesn't exist"
               end if
               if ~exists(BackupFolder$&fnCleanFilename$(Path$&FileName$)) then
                  if OutFile then print #OutFile: "Cannot Compare File: "&FileList$(Index)&" - The Backup of the File doesn't exist."
                  if Printer then print #255: "Cannot Compare File: "&FileList$(Index)&" - The Backup of the File doesn't exist."
               end if
            end if
         next Index
      end if

      if OutFile then Close #OutFile:
      if Printer and ~DontClose then Close #255:

      let fnCompare=1
   fnend

   def fnPrintArrays$(FileNumber,mat F$,mat F;Color,mat Of$,mat Of,Length,___,Index)
      for Index=1 to udim(mat F$)
         let Length+=len(f$(Index))+2
         if Length>120 and FileNumber=255 then print #FileNumber: : let Length=0
         if Color and trim$(Of$(Index))<>trim$(F$(Index)) then
            print #FileNumber: "[Red]"&trim$(F$(Index))&", "&"[Black]";
         else
            print #FileNumber: trim$(F$(Index))&", ";
         end if
      next Index
      for Index=1 to udim(mat F)
         let Length+=len(str$(f(Index)))+2
         if Length>128 and FileNumber=255 then print #FileNumber: : let Length=0
         if Color and Of(Index)<>F(Index) then
            print #FileNumber: "[Red]"&str$(F(Index))&", "&"[Black]";
         else
            print #FileNumber: str$(F(Index))&", ";
         end if
      next Index
      print #Filenumber:
   fnend

   dim PrinterSysSet
   def fnPrinterSys ! Activate Printer.Sys commands
      if ~PrinterSysSet then
         execute "config PRINTER TYPE NWP select WIN:"
         execute "config PRINTER TYPE NWP select PREVIEW:"

         execute 'config PRINTER NWP [RED], "\Ecolor=''#A00000''"'
         execute 'config PRINTER NWP [GREEN], "\Ecolor=''#00A000''"'
         execute 'config PRINTER NWP [BLACK], "\Ecolor=''#000000''"'
         execute 'config PRINTER NWP [CPI(NNN)], "\E(sNNNH"'
         execute 'config PRINTER NWP [SETFONT(FontName)], "\Efont=''FontName''"'
         execute 'config PRINTER NWP [A4PAPER], "\E&l26A" ! 210mm x 297mm'
         execute 'config PRINTER NWP [LANDSCAPE], "\E&l1O"'
         let PrinterSysSet=1
      end if
   fnend

   def fnAddTrailingSlash(&Folder$)
      if Folder$(len(Folder$):len(Folder$))<>"\" then
         let Folder$=Folder$&"\"
      end if
   fnend

   def fnValidMat(mat X$;___,Index,Valid)  ! Checks to see if the given string array has any layouts in it
      do while ((Index:=Index+1)<=udim(mat X$))
         if len(X$(Index)) then Valid=1
      loop until Valid
      let fnValidMat=Valid
   fnend

   ! This function will copy all or some of your data files to a backup folder.
   def library fnCopyDataFiles(BackupFolder$*255;Path$*255,mat SelectedLayouts$,SkipKeys,___,Index,FileName$*255,Jndex,Status,StatusCount,Dummy)
      library : fnReadLayouts, FnReadLayoutHeader, fnCopyFile, fnGetFileNumber

      let fnAddTrailingSlash(BackupFolder$)
      let fnAddTrailingSlash(Path$)
      if Path$="\" then let Path$=""

      if ~exists(BackupFolder$) then execute "mkdir "&BackupFolder$

      open #(status:=fnGetFileNumber): "srow=5,scol=10,rows=15,cols=60, border=s, caption=Progress",display,outin

      let StatHeadings$(1)="File"
      let StatWidth(1)=58
      let StatForm$(1)="CC 255"

      print #status, fields "1,1,LIST 15/60,HEADERS,/W:W" : (mat StatHeadings$,mat StatWidth, mat StatForm$)

      if fnValidMat(mat SelectedLayouts$) then
         mat FileList$(udim(SelectedLayouts$))=SelectedLayouts$
      else
         let fnReadLayouts(mat FileList$)
      end if

      for Index=1 to udim(Mat FileList$)
         if lwrc$(trim$(FileList$(Index)))<>"logfile" then
            let fnReadLayoutHeader(FileList$(Index),FileName$,Mat AuditKeys$)
            if exists(Path$&Filename$) then
               let fnMakeSurePathExists(fnCleanFilename$(Path$&fileName$),BackupFolder$)
               let StatFile$(1)=Path$&filename$
               print #Status, fields "1,1,LIST 15/60,+" : mat StatFile$
               let StatusCount+=1
               let Curfld(1,StatusCount)
               input #Status, fields "1,1,LIST 15/60,ROWSUB,SEL,NOWAIT" : Dummy

               ! execute "copy "&FileName$&" "&BackupFolder$&FileName$&" -S -N"
               let fnCopyFile(Path$&FileName$,Backupfolder$&fnCleanFilename$(Path$&fileName$))

               if SkipKeys=2 then ! 2 means clear, 1 means skip, 0 means include
                  for Jndex=1 to udim(Mat AuditKeys$)
                     if exists(BackupFolder$&fnCleanFilename$(Path$&AuditKeys$(Jndex))) then
                        execute "*free "&BackupFolder$&fnCleanFilename$(Path$&AuditKeys$(Jndex))
                     end if
                  next Jndex
               else
                  for Jndex=1 to udim(Mat AuditKeys$)
                     let fnMakeSurePathExists(fnCleanFilename$(Path$&AuditKeys$(Jndex)),BackupFolder$)

                     let StatFile$(1)=AuditKeys$(Jndex)
                     print #Status, fields "1,1,LIST 15/60,+" : mat StatFile$
                     let StatusCount+=1
                     let Curfld(1,StatusCount)
                     input #Status, fields "1,1,LIST 15/60,ROWSUB,SEL,NOWAIT" : Dummy

                     ! execute "copy "&AuditKeys$(Jndex)&" "&BackupFolder$&AuditKeys$(Jndex)&" -S -N"
                     let fnCopyFile(Path$&AuditKeys$(Jndex),BackupFolder$&fnCleanFilename$(Path$&AuditKeys$(Jndex)))
                  next Jndex
               end if
            end if
         end if
      next Index

      close #Status:
   fnend

   dim Chunk$*10000
   def library fnCopyFile(FromFile$*255,ToFile$*255;NoProgressBar,___,FromFile,ToFile,Written)
      let ProgressBar=~NoProgressBar

      library : fnGetFileNumber

      open #(FromFile:=fnGetFileNumber): "name="&FromFile$&",recl=10000,shr",external,input
      open #(ToFile:=fnGetFileNumber): "name="&ToFile$&",recl=10000,replace",external,output

      ReadNextRec: ! Read the next record and process it
         let Written=0
         read #FromFile, using CopyFile : Chunk$ eof DoneCopying ioerr ShortRec
         if ~Written then write #ToFile, using CopyFile : Chunk$

         if ProgressBar and lrec(FromFile) then let fnUpdateProgressBar(rec(FromFile)/lrec(FromFile),"",0,0,0,"Transferring '"&FromFile$&"' File")
      goto ReadNextRec

      DoneCopying: ! Done Copying the file here

      if ProgressBar then let fnCloseProgressBar

      close #FromFile:
      close #ToFile:
   fnend

   CopyFile: form C 10000

   ShortRec: ! Process short record at EOF
      let C=Cnt
      if err><4271 then let msgbox("Error during copying. Please try again.") : goto DoneCopying
      reread #FromFile, using CopyFile : Chunk$
      ! let Chunk$=rtrm$(Chunk$,chr$(0))
      rln(ToFile,C)
      write #ToFile, using "form C "&str$(C) : Chunk$(1:C)
      let Written=1
   continue


   dim PBarSpec$(1),PBarDot$(1)
   dim pb_StartTime,pb_LastPercent,pb_Window,pb_NewGui,pb_pTime,pb_Size,pb_Color$
   dim pb_PrintedLastMessageRow$*255,pb_OpenedMessageRows

   def library fnProgressBar(Percent;Color$,ProgressAfter,ProgressThreshhold,UpdateThreshhold,Caption$*255,MessageRow$*255)=fnUpdateProgressBar(Percent,Color$,ProgressAfter,ProgressThreshhold,UpdateThreshhold,Caption$,MessageRow$)
   def library fnCloseBar=fnCloseProgressBar
   def fnUpdateProgressBar(Percent;Color$,ProgressAfter,ProgressThreshhold,UpdateThreshhold,Caption$*255,MessageRow$*255,___,MessageRows,Index,FromSpot,ToSpot,SRow,SCol,Rows,Cols)
      ! Initialize Defaults
      if ~ProgressAfter then let ProgressAfter=.8            ! 3/4ths of a Second
      if ~ProgressThreshhold then let ProgressThreshhold=.45 ! About 45 percent.
      if ~UpdateThreshhold then let UpdateThreshhold=.4      ! 4/10th of a Second

      if len(Caption$) then let Caption$=",Caption="&Caption$

      library : fnGetFileNumber

      ! Save Color
      if Len(Color$) then let pb_Color$=Color$
      if ~len(pb_Color$) then let pb_Color$="#00FF00"

      ! Initialize Start Time
      if ~pb_StartTime then let pb_StartTime=Timer

      if pb_Window and pb_OpenedMessageRows and MessageRow$><pb_PrintedLastMessageRow$ then
         print #pb_Window, fields "2,1,"&str$(pb_Size)&"/CC 255" : MessageRow$
         let MessageRow$=pb_PrintedLastMessageRow$
      end if

      if fnProgressBarTime(pb_StartTime,ProgressAfter,Percent,ProgressThreshhold) then ! If its time to open the progress bar
         if ~pb_Window then ! if the pb_window isn't open yet, check if we need to open it
            ! Open Window

            ! First, Detect Size and Position.
            let fnReadScreenS(Rows,Cols)
            let pb_Size=int(Cols*.6666)    ! 78 Size should be .666*ScreenWidth
            let SRow=int(Rows/2)           ! 11 SRow should be int(half of the window) - 1
            let SCol=int((Cols-pb_Size)/2) ! 2  SCol should be int(ScreenWidth-Size/2)
            let MessageRows=1 : pb_OpenedMessageRows=0
            if len(MessageRow$) then let MessageRows+=1 : let pb_OpenedMessageRows=1

            open #(pb_Window:=fnGetFileNumber): "SRow="&str$(SRow)&",SCol="&str$(SCol)&",Rows="&str$(MessageRows)&",Cols="&str$(pb_Size)&Caption$&",Border=S",display,outin

            ! Initialize Window, Detect Gui Mode, Configure dot positions.
            if env$("guimode")="ON" then
               let pb_NewGui=1
            else
               mat PBarSpec$(pb_Size) : mat PBarDot$(pb_Size)
               for Index=1 to pb_Size
                  let PBarSpec$(Index)="1,"&Str$(Index)&",C 1"
               next Index
               mat PBarDot$=(".")
               print #pb_Window, fields mat PBarSpec$ : mat PBarDot$
               mat PBarDot$=("o")
            end if
         end if

         if pb_Window and pb_pTime+UpdateThreshhold<Timer then ! We're printing already, and its been long enough.
            if (Percent*pb_Size)-pb_LastPercent>=1 then
               let FromSpot=Max(int(pb_LastPercent),1)
               let ToSpot=Min(Int(Percent*pb_Size),pb_Size)
               if pb_NewGui then
                  print #pb_Window, fields "1,1,"&str$(ToSpot)&"/C 1,S/W:"&pb_Color$ : ""   ! Probably much faster in new gui, a single control.
               else
                  print #pb_Window, fields mat PBarSpec$(FromSpot:ToSpot) : mat PBarDot$(FromSpot:ToSpot)
               end if
               let pb_LastPercent=Percent*pb_Size
            end if
            let pb_pTime=Timer
         end if
      end if
   fnend

   def fnCloseProgressBar(;___,FromSpot,ToSpot)
      if pb_Window then
         ! Print end of Progress Bar
         let FromSpot=Max(int(pb_Lastpercent),1)
         let ToSpot=pb_Size
         if FromSpot<=ToSpot then
            if pb_NewGui then
               print #pb_Window, fields "1,1,"&str$(ToSpot)&"/C 1,S/W:"&pb_Color$ : ""
            else
               print #pb_Window, fields mat PBarSpec$(FromSpot:ToSpot) : mat PBarDot$(FromSpot:ToSpot)
            end if
         end if
         ! Close Progress Bar
         close #pb_Window:
      end if

      ! Also reset all progress bar saved parms for next time.
      let pb_Window=pb_LastPercent=pb_StartTime=pb_NewGui=pb_pTime=pb_Size=0
   fnend

   ! Progress Bar Calculations. fnEnoughProgress is the basic formula. fnProgressBarTime calls it with 1, 2, and 3 for Multipliers.
   def fnEnoughProgress(Multiplier,StartTime,ProgressAfter,Percent,Threshhold)=((StartTime+(ProgressAfter*Multiplier))<Timer and Percent<(Threshhold*Multiplier))
   def fnProgressBarTime(ST,PA,PCT,T)=(fnEnoughProgress(1,ST,PA,PCT,T) or fnEnoughProgress(2,ST,PA,PCT,T) or fnEnoughProgress(3,ST,PA,PCT,T))

   def fnMakeSurePathExists(Filename$*255;Path$*255)
      do while pos(FileName$,"\")
         let Path$=Path$&FileName$(1:pos(FileName$,"\"))
         let FileName$=fileName$(pos(FileName$,"\")+1:len(Filename$))
         if ~Exists(Path$) then execute "mkdir "&path$
      loop
   fnend

   def library fnShowMessage(Message$*54;___,WinNumber)
      library : fnGetFileNumber
      open #(WinNumber:=fnGetFileNumber): "SROW=10,SCOL=12,ROWS=3,COLS=56,BORDER=S",display,outin
      print #WinNumber, fields "2,2,CC 54" : Message$
      let fnShowMessage=WinNumber
   fnend

   ! This function reads an environment variable on the client under client server.
   def library fnClientEnv$*255(EnvKey$;___,F,Value$*255)
      library : fnGetFileNumber
      ! Make a cmd file
      open #(F:=fnGetFileNumber): "name=@:temp[session].cmd, replace", display, output
      print #F: "echo %"&EnvKey$&"% > tempout"&session$&".txt"
      close #f:
      execute "system -@ -M temp"&session$&".cmd"
      open #(F:=fnGetFileNumber): "name=@:tempout[session].txt", display, input
      linput #f: Value$
      close #f:
      let fnClientEnv$=rtrm$(Value$)
   fnend

   dim rowval$(1)*255,printrow$*1000

   dim start(1),ender(1),mask(1)
   DIM HEADERS$(1)*50,EXWIDTHS(1),EXFORMS$(1)*50,HEADERS$*2000, SortOrder(1)
   dim ListData$(1)*1023, ListRow$(1)*1023
   dim SelectedRows(1)

   def library fnExportListviewCSV(Window,SPEC$;GenFileName,Delim$,Filename$*255,___,WaitWin,CS,NumOfCols,turn,instance,n,m,SortNext,Format$*64,Selno,Selected)
      if fn43 then
         library : fnGetFileNumber,fnShowMessage

         if ~len(trim$(Delim$)) then let delim$='","'
         let WaitWin=fnShowMessage("Exporting... Please Wait.")

         ! Query the Listview Header
         input #Window, fields Spec$&",HEADERS,,nowait ": (MAT HEADERS$,MAT EXWIDTHS,MAT EXFORMS$)
         let Mat2str(Mat Headers$,Headers$,'","')

         ! Read the Listview Filter
         input #Window, fields Spec$&",mask,,nowait" : (mat mask)
         ! Read number of columns
         input #Window, fields Spec$&",colcnt,all,nowait" : numofcols

         ! Handle any Sorting that has occurred.
         input #Window, fields Spec$&",rowsub,all,displayed_order,nowait": MAT SortOrder

         input #Window, fields Spec$&",rowcnt,sel,nowait ": Selno
         if Selno>1 And Msgbox("Do you ONLY want to include selected items in your report?","List Report","Yn","QST")=2 then
            let Selected=1
            mat SelectedRows(Selno)
            input #Window, fields Spec$&",rowsub,sel,nowait": Mat SelectedRows
         else
            let Selected=0
         end if

         ! Calculate the mat Start and mat End necessary to read the data
         ! We're using a trick here. Looks like BR Returns displayed_order with all the
         !  filter-showing rows at the end. So we just read the last however many rows
         !  of our mat SortOrder and use it for our Starts and Ends, and they're already in
         !  displayed order for us
         mat start(sum(mask))=SortOrder(udim(mat SortOrder)-sum(mask)+1:udim(mat SortOrder))
         mat ender(sum(mask))=start

         ! Make enough room for the data we're reading
         mat ListData$(numofcols*udim(mat start))
         mat ListRow$(numofcols)

         ! Read the data in the order sorted
         let M=0
         for n=1 to udim(mat Start)
            if ~Selected or srch(mat SelectedRows,Start(n))>0 then ! If not "selection only" or if this is part of the selection
               let M+=1
               input #Window, fields spec$&",row,range,nowait" : start(n), ender(n), (mat ListRow$)
               mat ListData$(((M-1)*numofcols)+1:M*numofcols)=ListRow$
            end if
         next n

         mat ListData$(numOfCols*M)

         ! Find a unique name
         if GenFileName then
            let FileName$=fnGenerateFileName$("@:csvexpt","csv")
         end if

         ! Open the data file
         if (len(trim$(Filename$))) then
            open #(CS:=fnGetFileNumber): "NAME="&Filename$&",replace,recl=2000",display,output
         else
            OPEN #(CS:=fnGetFileNumber): "NAME=SAVE:CSV files (*.csv) |*.csv,replace,RECL=2000", display, output
            let FileName$=file$(CS)
         end if

         ! Print Header Line
         print #CS: '"'&Headers$&'"'

         ! Loop through data and print the CSV file one line at a time.
         let turn=0
         do
            mat ListRow$(numofcols)
            for n=1 to numofcols
               let ListRow$(n)=trim$(listdata$(n+turn))
               ! Apply Conversion if needed
               if lwrc$(trim$(ExForms$(n)(1:5)))="date(" or lwrc$(trim$(ExForms$(n)(1:4)))="fmt(" or lwrc$(trim$(ExForms$(n)(1:4)))="pic(" then
                  let Format$=ExForms$(n)
                  if pos(Format$,",") then
                     let Format$=Format$(1:pos(Format$,",")-1)
                  end if
                  let ListRow$(n)=cnvrt$(Format$,val(ListRow$(n))) error Ignore
               end if
            next n
            let m=0
            for n=1 to numofcols
               let m+=1
               if n<=udim(mat exwidths) and exwidths(n)=0 then
                  let fnRemoveColumn(m,mat ListRow$)
                  let m-=1
               end if
            next n

            let mat2str(mat ListRow$,printrow$,delim$)
            print #CS: '"'&printrow$&'"'

            let printrow$=""
            let turn=turn+numofcols
         loop while turn<udim(mat listdata$)

         close #CS:

         ! Launch the file in the default application ..
         execute "sy -C -M -@ start "&os_filename$(FileName$)
         Close #Waitwin:
      else
         msgbox("Export from Listview requires BR 4.3 or higher.","Export Failed")
      end if
   fnend

   def fnGenerateFileName$*255(Base$*255,Extension$;___,FileName$*255,Instance)
      if len(Extension$) and Extension$(1:1)><"." then let Extension$(1:0)="."
      let FileName$=Base$&Session$&date$("mmdddyy")&time$(1:2)&time$(4:5)&time$(7:8)&Extension$
      do while exists(FileName$)
         let Instance+=1
         let FileName$=Base$&Session$&date$("mmdddyy")&time$(1:2)&time$(4:5)&time$(7:8)&str$(Instance)&Extension$
      loop

      let fnGenerateFileName$=FileName$
   fnend

   def fnRemoveColumn(col,mat Array$;___,i)
      for i=Col to udim(mat Array$)-1
         let Array$(i)=Array$(i+1)
      next i
      mat Array$(udim(mat Array$)-1)
   fnend

   BadEmailLibrary: ! Jump here if email can't be sent.
      let msgbox("The email could not be sent. The custom EmailLibrary$ specified in your fileio.ini file is invalid, or missing the fnSendMail function.","Error")
   continue

   dim EmailConf$(1)*1024,EmailConf(1),EmailConf,form$(1)*255
   dim CCEmailString$*10000
   dim EmailAddressString$*10256
   def library FnSendEmail(Emailaddress$*255,EmailMessage$*10000;Subject$*255,Invoicefile$*255,noprompt,BCCEmail$*255,mat CCEmails$,CCAsTo,___,Resultfile,Success,Outputstring$*1024,Index,EmailLibrary$*64)

      let EmailLibrary$=fnSettings$("emaillibrary")

      if len(EmailLibrary$) then
         if exists(EmailLibrary$) then
            library EmailLibrary$ : fnSendMail error BadEmailLibrary
            let fnSendEmail=fnSendMail(EmailAddress$,EmailMessage$,Subject$,InvoiceFile$,NoPrompt,BCCEmail$,mat CCEmails$,CCAsTo) error BadEmailLibrary
         else
            let msgbox("The Custom EmailLibrary$ specified in fileio.ini could not be found.","Error")
         end if
      else
         library : fnOpenFile, fnGetFileNumber, fnDoesLayoutExist
         if fnDoesLayoutExist("emailcfg") then
            if exists("sendemail.exe") then
               let EmailConf=fnOpen("emailcfg",mat EmailConf$,mat EmailConf,mat Form$,1,0,0,"",d$,D,0,0,1)
               read #EmailConf, using form$(EmailConf),rec=1 : mat EmailConf$,mat EmailConf norec Ignore
               if file(EmailConf)=0 then
                  if Exists("EmailLog.[WSID]") then execute "*free EmailLog.[WSID]"
                  if EmailMessage$="" then let EmailMessage$=" "
                  let EmailMessage$=srep$(EmailMessage$,hex$("0D"),hex$("0A"))
                  let EmailMessage$=srep$(EmailMessage$,hex$("0A0A"),hex$("0A"))
                  let EmailMessage$=srep$(EmailMessage$,hex$("0A"),"\n")
                  if len(BCCEmail$) then let BCCEmail$(1:0)=" -bcc "
                  let CCEmailString$=""
                  for Index=1 to udim(mat CCEmails$)
                     if len(trim$(CCEmails$(Index))) then
                        if len(trim$(CCEmailString$)) then let CCEmailString$=CCEmailString$&" "
                        let CCEmailString$=CCEmailString$&CCEmails$(Index)
                     end if
                  next Index

                  let EmailAddressString$=Emailaddress$

                  if CCAsTo then
                     if len(trim$(EmailAddressString$)) then let EmailAddressString$=EmailAddressString$&" "
                     let EmailAddressString$=EmailAddressString$&CCEmailString$
                     let CCEmailString$=""
                  end if

                  if len(trim$(CCEmailString$)) then let CCEmailString$=" -cc "&CCEmailString$

                  if len(trim$(InvoiceFile$)) then
                     execute 'sy -M -s -t120 sendemail -s '&EmailConf$(conf_server)&' -t '&EmailAddressString$&' -f '&EmailConf$(conf_fromaddr)&' -xu '&EmailConf$(conf_UserAccount)&' -xp '&EmailConf$(conf_password)&' -u "'&Subject$&'" -m "'&EmailMessage$&'" -a "'&os_filename$(InvoiceFile$)&'"'&CCEmailSTring$&BCCEmail$&' -v -q -l EmailLog.'&Wsid$
                  else
                     execute 'sy -M -s -t120 sendemail -s '&EmailConf$(conf_server)&' -t '&EmailAddressString$&' -f '&EmailConf$(conf_fromaddr)&' -xu '&EmailConf$(conf_UserAccount)&' -xp '&EmailConf$(conf_password)&' -u "'&Subject$&'" -m "'&EmailMessage$&'"'&CCEmailSTring$&BCCEmail$&' -v -q -l EmailLog.'&Wsid$
                  end if
                  execute 'type EmailLog.[WSID] >>EmailLog.txt'
                  open #(Resultfile:=Fngetfilenumber): "name=EmailLog.[WSID],recl=512",display,input
                  do Until File(Resultfile)
                     linput #Resultfile: Outputstring$ eof IGNORE
                     if Pos(Outputstring$,"Email was sent successfully!") then let Success=1
                  loop
                  close #Resultfile:
                  execute '*free EmailLog.[WSID]'
                  let FnSendEmail=Success
                  if Success and ~noprompt then LET MSGBOX("Email was sent successfully!","Email Sent")
               else
                  let msgbox("Email account not configured. Please enter the appropriate information in the emailcfg file.","Error")
               end if
            else
               let msgbox("SendEmail.exe program not found. Please include it with your software. This program can be downloaded for free from the internet.","Error")
            end if
         else
            let msgbox("The Email Configuration File is missing. Please add the emailcfg file layout to your layout folder. It is included in the latest versions of fileio.","Error")
         end if
      end if
   fnend

   def library fnSubstituteStringCode(&String$,Code$*2048;SubstituteChar$,___,SCS$,SCE$,Prefix$,SubString$,LastPlaceSearched,Value$*255)
      execute Code$

      if SubstituteChar$="" then let SubstituteChar$="[]"
      let SubstituteChar$=Rpad$(SubstituteChar$,2)
      let SCS$=SubstituteChar$(1:1) : let SCE$=SubstituteChar$(2:2)

      do while (LastPlaceSearched:=pos(String$,SCS$,LastPlaceSearched+1))
         let SubString$=fnExtractSubstring$(String$,SCS$,SCE$)
         execute "Value$="&Substring$ error SkipThis
         let String$=srep$(String$,trim$(SCS$&Substring$&Sce$),Value$)

         SkipThis: ! Jump here if error executing Substring
      loop
   fnend

   def library fnStandardTime$(MT$;Seconds,___,H,M,S,P)
      library : fnParseTime, fnBuildTime$
      let fnParseTime(MT$,H,M,S,P)
      let fnStandardTime$=fnBuildTime$(H,M,S,P,0,Seconds)
   fnend

   def library fnMilitaryTime$(ST$;Seconds,___,H,M,S,P)
      library : fnParseTime, fnBuildTime$
      let fnParseTime(ST$,H,M,S,P)
      let fnMilitaryTime$=fnBuildTime$(H,M,S,P,1,Seconds)
   fnend

def library fnCalculateHours(timein$,tout$,daysin,daysout;___,hrin,hrout,minin,minout,secin,secout,total,totalout)
   ! this function returns the hours between timein and tout, which must be passed in as hhmmss in string form
   let hrin=val(timein$(1:2))
   let hrout=val(tout$(1:2))
   let minin=val(timein$(3:4))
   let minout=val(tout$(3:4))
   let secin=val(timein$(5:6))
   let secout=val(tout$(5:6))

   let daycount=daysout-daysin

   if daycount>=2 then
      ! add 24 hours for each full day
      let total+=24*(daycount-1)
   end if

   if daycount>=1 then
      ! first day trough midnight calculation
      total+=(24-hrin)
      if minin<>0 then
         total-=((minin)/60)
      end if
      if secin<>0 then
         total-=(secin/3600)
      end if
      ! last day from midnight calculation
      total+=hrout
      total+=(minout/60)
      total+=(secout/3600)
   else
      ! in same day
      total+=hrout-hrin
      if minin<>0 then
         total-=((minin)/60)
      end if
      if secin<>0 then
         total-=(secin/3600)
      end if
      total+=(minout/60)
      total+=(secout/3600)
   end if
   let totalout=round(total,2)
   if totalout=0 then let totalout=.01 ! set to a few seconds minimum
   let fnCalculateHours=totalout
fnend


   def library fnBuildTime$(H,M,S,P;Military,Seconds,___,P$,H$,M$,S$)
      let M$=":"&cnvrt$("PIC(##)",M)
      if Seconds then let S$=":"&cnvrt$("PIC(##)",S)

      if Military then
         if P then let H+=12 : let P=0
      else
         if H>12 then let H-=12 : let P=1
         if P then let P$="pm" else let P$="am"
      end if

      let H$=str$(H)

      let fnBuildTime$=H$&M$&S$&P$
   fnend

   def library fnParseTime(T$,&H,&M,&S,&P;___,Colon)
      let T$=lwrc$(T$)

      if pos(T$,"p")>0 then let P=1
      let T$=srep$(T$,"a","")
      let T$=srep$(T$,"p","")
      let T$=srep$(T$,"m","")

      let H=fnParseNextColon(T$)
      let M=fnParseNextColon(T$)
      let S=fnParseNextColon(T$)
   fnend

   def fnParseNextColon(&T$;___,Colon)
      let Colon=pos(T$,":")
      if Colon>0 then
         let fnParseNextColon=val(T$(1:Colon-1))
         let T$(1:Colon)=""
      else
         let fnParseNextColon=val(T$)
         let T$=""
      end if
   fnend

   dim SubStringSubs$(1)*255,SubNumericSubs$(1)*255
   def library fnSubstituteString(&String$,FileLayout$,mat F$,mat F;SubstituteChar$,___,SCS$,SCE$,Prefix$,SubString$,LastPlaceSearched)
      if SubstituteChar$="" then let SubstituteChar$="[]"
      let SubstituteChar$=Rpad$(SubstituteChar$,2)
      let SCS$=SubstituteChar$(1:1) : let SCE$=SubstituteChar$(2:2)

      ! Read Layout:
      library : fnReadLayoutArrays
      let fnReadLayoutArrays(FileLayout$,Prefix$,mat SubStringSubs$,mat SubNumericSubs$)

      do while (LastPlaceSearched:=pos(String$,SCS$,LastPlaceSearched+1))
         let SubString$=fnExtractSubstring$(String$,SCS$,SCE$)
         if lwrc$(Substring$(1:len(Prefix$)))=lwrc$(Prefix$) then ! If its a match for the given file then
            let String$=srep$(String$,trim$(SCS$&Substring$&SCE$),fnSubMatchValue$(Substring$(len(Prefix$)+1:99),mat SubStringSubs$,mat SubNumericSubs$,mat F$,mat F))
         end if
      loop
   fnend

   def fnSubMatchValue$*1023(Substring$,mat StringSubs$,mat NumSubs$,mat F$,mat F;___,Index,CaseUpper,CaseLower,CaseTitle)
      if pos(Substring$,"::U") then
         let Substring$=srep$(Substring$,"::U","")
         let CaseUpper=1
      else if pos(Substring$,"::L") then
         let Substring$=srep$(Substring$,"::L","")
         let CaseLower=1
      else if pos(Substring$,"::T") then
         let Substring$=srep$(Substring$,"::T","")
         let CaseTitle=1
      end if

      let Index=fnFindMatch(Substring$,mat StringSubs$)
      if Index>0 then
         if CaseUpper then
            let fnSubMatchValue$=uprc$(trim$(F$(Index)))
         else if CaseLower then
            let fnSubMatchValue$=lwrc$(trim$(F$(Index)))
         else if CaseTitle then
            let fnSubMatchValue$=fnTitleCase$(trim$(F$(Index)))
         else
            let fnSubMatchValue$=trim$(F$(Index))
         end if
      else
         let Index=fnFindMatch(Substring$,mat NumSubs$)
         if Index>0 then
            let fnSubMatchValue$=str$(f(Index))
         end if
      end if
   fnend

   def fnTitleCase$*1023(String$*1023;___,Index,AfterASpace,StringOut$*1023)
      let AfterASpace=1
      for Index=1 to len(String$)
         if AfterASpace then
            let StringOut$(9999:0)=uprc$(String$(Index:Index))
            let AfterASpace=0
         else
            let StringOut$(9999:0)=lwrc$(String$(Index:Index))
         end if
         if String$(Index:Index)=" " then let AfterASpace=1
      next Index
      let fnTitleCase$=StringOut$
   fnend

   def fnFindMatch(Sub$,mat Subs$;___,Index)
      for Index=1 to udim(mat Subs$)
         let Subs$(Index)=lwrc$(Subs$(Index))
      next Index
      let fnFindMatch=srch(mat Subs$,lwrc$(Sub$))
   fnend

   dim TempES$*10000
   def fnExtractSubstring$(&String$,SCS$,SCE$;___,P)
      if (P:=pos(String$,SCS$)) then
         let TempES$=String$(P+1:10000+P)
         if pos(TempES$,SCE$) then let TempES$=TempES$(1:pos(TempES$,SCE$)-1)

         let fnExtractSubstring$=TempES$(1:18)
      end if
   fnend

READSCREENSIZE: ! Return The Screen Size Of Window 0 In Terms Of Rows And Columns
   dim ScreenSize(4), FontSize(2)
   def library fnReadScreenSize(&Rows,&Cols;ParentWindow)=fnReadScreenS(Rows,Cols,ParentWindow)
   def fnReadScreenS(&Rows,&Cols;ParentWindow)
      if env$("guimode")><"ON" then
         let Rows=24
         let Cols=80
      else if ~fn42e then
         let fnOldReadScreenSize(Rows,Cols,ParentWindow)
      else
         let file(ParentWindow,"USABLE_RECT",mat ScreenSize)
         let file(ParentWindow,"FONTSIZE",mat FontSize)
         let Rows=(ScreenSize(4)/FontSize(1))
         let Cols=(ScreenSize(3)/FontSize(2))
      end if
   fnend

   def FnOldreadscreensize(&Rows,&Cols;ParentWindow,___,Ffile,String$*2000,Srow,Scol,Erow,Ecol,Position,Star$)
      let Star$=fnNeedStar$
      execute Star$&"Status Files >[SESSION].tmp"
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
      execute Star$&"Free [SESSION].tmp"
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
   fnend

   def fn43=(val(wbversion$(1:3))>=4.3)
   def fn42e=(wbversion$>="4.20e")
   def fn42=(val(wbversion$(1:3))>=4.2)
   def fn418=((val(wbversion$(1:4))>=4.18) or fn42)
   def fn42ia=(wbversion$>="4.20ia")
   def fn42j=(wbversion$>="4.20j")
!
! #Autonumber# 99000,10
OPEN: ! ***** Function To Call Library Openfile And Proc Subs
      def Fnopen(Filename$*255, Mat F$, Mat F, Mat Form$; Inputonly, Keynum, Dont_Sort_Subs, Path$*255, Mat Descr$, Mat Field_Widths,Supress_Prompt,Ignore_Errors,Suppress_Log,mat DateFmt$,___,Index)
         dim _FileIOSubs$(1)*800, _Loadedsubs$(1)*80
         let Fnopen=Fnopenfile(Filename$, Mat F$, Mat F, Mat Form$, Inputonly, Keynum, Dont_Sort_Subs, Path$, Mat Descr$, Mat Field_Widths, Mat _FileIOSubs$, Supress_Prompt,Ignore_Errors,Program$,Suppress_Log,mat DateFmt$)
         if Srch(_Loadedsubs$,Uprc$(Filename$))<=0 then : mat _Loadedsubs$(Udim(_Loadedsubs$)+1) : let _Loadedsubs$(Udim(_Loadedsubs$))=Uprc$(Filename$) : for Index=1 to Udim(Mat _Fileiosubs$) : execute (_Fileiosubs$(Index)) : next Index
      fnend
!
! #Autonumber# 99900,5
IGNORE: continue
RetryCount: !
   if ErrorRetryCount<5 then
      let ErrorRetryCount+=1
      retry
   else
      let ErrorRetryCount=0
      continue
   end if

SleepRetryCount: !
   sleep(.1)
   if SleepRetryCount<5 then
      let SleepRetryCount+=1
      retry
   else
      let SleepRetryCount=0
      continue
   end if
