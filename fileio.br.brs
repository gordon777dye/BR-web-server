00010 ! Fileio - Copyright February 2006 By Gabriel Bakker #Autonumber# 10,10
00020 !    Distributed Open Source As A Christmas Gift To the BR Community
00030 ! This Library Houses All File Maintenance Operations
00040 ! 
00050 !  Created: 3/28/2006
00060 ! Modified: 6/06/2026
00070 ! 
00080    def FNVERSION=135
00090 ! 
00100 ! 
00500 ! #Autonumber# 500,1
00501 ! If You Run This Library As A Program, It Will Function As A Data
00502 ! Crawler That Will Allow You To View The Raw Data In Your Datafiles
00503 ! 
00504 ! To Update A Datafile, Just Simply Increase The Version Number
00505 ! Then Make Any Change You Like - Add Fields, Remove Fields, Rearrange
00506 ! Fields, Change Keys, etc.
00507 ! 
00508 ! Then Just Run Your Software Normally - Upon First Time, Version
00509 ! Discrepancy Is Detected, And File Is Updated Dynamically.
00510 ! 
00511 ! Note: Do Not Change Your Subscript Names Between Versions.
00512 ! They Can Be Rearranged, And You Can Insert New Data, But The Fileio
00513 ! Library Uses The Subscript Names To Ensure The Proper Data Is Placed
00514 ! In The Correct Spot In The New Version Of The Data File During The
00515 ! Update.
00516 ! 
00517 ! Global Settings Such As The Default File Layout Path May Be Set
00518 ! By creating a simple procfile called fileio.ini, a procfile that
00519 ! resides in the current path and setting the appropriate values.
00520 ! 
00521 ! Recent Changes have been moved to FileIOUpdateLog.txt
00522    goto Dims
00523 ! 
00900 ! #Autonumber# 900,2
00902    goto Testfileio
00904 ! 
01000 ! #Autonumber# 1000,2
01002 Settings: ! ***** Set Global Defaults For The Library Here
01004    def FNDEFAULTSETTINGS
01006       let ENFORCEDUPKEYS=1            !Enforce that key number 1 is unique key
01008       let DEFAULTFILELAYOUTPATH$="filelay\"  !Path To Your File Layouts
01010       let FILELAYOUTEXTENSION$=""     !Extension for your File Layouts
01012       let PROMPTONFILECREATE=1        !Ask User Before Creating New Files
01014       let PROMPTONUPDATE=2            !0 - Suppress Prompt, 1- Show Prompt, 2- Use PromptOnFileCreate
01016       let CREATELOGFILE=0             !1 to turn on Logging. Caution, the log file can get big very quickly.
01018       let STARTFILENUMBER=1           !Set above 255 to avoid conflicts with legacy programs.
01020       let CHECKINDEX=0                !Automatically Update Indexes (Use for partial fileio implementations, disable for full fileio installations.)
01022       let COMPRESSCOLUMNS=0           !Shrink or Expand Columns in Data Crawler by Default
01024       let MAXCOLWIDTH=20              !Max Default Column Width in Data Crawler
01026       let NEWLINE$=CHR$(13)&CHR$(10)  !Default CRLF
01028       let LOGLIBRARY$=""              !Log Library to use, defaults to None (use FileIO's internal log functionality)
01030       let LOGLAYOUT$=""               !Log file layout, defaults to Internal File (for use with FileIO's internal log functionality)
01032       let ANIMATEDATACRAWLER=1        !Use ScreenIO Animation for Datacrawler (if available, will not cause error if not available)
01034       let GENERATESCREENBTN=1         !Use ScreenIO's fnMakeScreen function to generate screens from within fileio.
01036       let TEMPLATEPATH$="filelay\template\"  !Default Template Path
01038       let IGNORELAYOUTS$=""           !List any Ignore Layouts here.
01040       let CLOSEFILESIMPLE=0           !Use simple comparison for fnCloseFile
01042       let AUDITPATH$="auditbr\"       !Backup Path to use for Auditing Files
01044       let SCREENIOPATH$="screenio.br"  !Default search location for ScreenIO Library (for fnAnimate in Data Crawler.)
01046       let FILTERBOXFILELIST=0         !Use a Filter Box for the Layout Listview (1=Filter Box, 0=Search Box)
01048       let FILTERBOXDATA=1             !Use a Filter Box for the Data Crawler (1=Filter Box, 0=Search Box)
01050       let SAVESELECTEDCOLS$="savecols"  !Path and File name of a file used to save user preferences, which cols to export per file by default.
01052       let DATEFORMATEXPORT$='m/d/cy'  !Format of Dates when Exporting to CSV
01054       let DATEFORMATDISPLAY$='m/d/cy'  !Format of Dates when displaying in Data Crawler
01056       let BYPASSFIXRPT=0              !Set this to 1 to increase performance, set it to 0 if you have extremly large file layouts.
01058       let SUPPRESSLOGGINGERR=0        !Set this to 1 to suppress the "File is locked on the server" error message when the log file cannot be written to.
01060       let EMAILLIBRARY$=""            !Specify a custom email library here to use your own emailing program. This must be a BR library containing a library function that sends the email in your custom way, called fnSendMail(Emailaddress$*255,EmailMessage$*10000;Subject$*255,Invoicefile$*255,noprompt,BCCEmail$*255,mat CCEmails$,CCAsTo)
01062    fnend 
01064 ! 
01076    def FNREADSETTINGS(MAT SSETTINGNAMES$,MAT SSETTINGS$,MAT NSETTINGNAMES$,MAT NSETTINGS$, &READSETTINGS; ___, DEFAULTFILELAYOUTPATH$*255, NEWLINE$*255, LOGLIBRARY$*255, PROMPTONFILECREATE, PROMPTONUPDATE, CREATELOGFILE, ENFORCEDUPKEYS, STARTFILENUMBER, CHECKINDEX, COMPRESSCOLUMNS, MAXCOLWIDTH, LOGLIBRARY$*255, LOGLAYOUT$, ANIMATEDATACRAWLER, GENERATESCREENBTN, TEMPLATEPATH$*255, IGNORELAYOUTS$*255, CLOSEFILESIMPLE, STAR$, AUDITPATH$*255, SCREENIOPATH$*255, FILELAYOUTEXTENSION$, FILTERBOXFILELIST, FILTERBOXDATA, SAVESELECTEDCOLS$*64, DATEFORMATEXPORT$*64, DATEFORMATDISPLAY$*64, BYPASSFIXRPT, SUPPRESSLOGGINGERR,EMAILLIBRARY$*64)
01078 ! 
01080       let STAR$=FNNEEDSTAR$
01082 ! 
01084 ! .  ! Read Defaults
01086       let FNDEFAULTSETTINGS
01088 ! 
01090 ! .  ! Read Custom Settings
01092       if EXISTS("fileio.ini") then 
01094          execute STAR$&"subproc fileio.ini"
01096       else if EXISTS("fileio\fileio.ini") then 
01098          execute STAR$&"subproc fileio\fileio.ini"
01100       else if EXISTS("\fileio.ini") then 
01102          execute STAR$&"subproc \fileio.ini"
01104       end if 
01106 ! 
01108 ! .  ! Detect fnAnimate routines, enable/disable Loading Animation
01110       if LEN(TRIM$(SCREENIOPATH$)) AND EXISTS(SCREENIOPATH$) then 
01112          if ANIMATEDATACRAWLER then 
01114             library SCREENIOPATH$ : FNANIMATE, FNPREPAREANIMATION, FNCLOSEANIMATION, FNMAKESCREEN
01116          end if 
01118          if GENERATESCREENBTN then 
01120             library SCREENIOPATH$ : FNMAKESCREEN
01122          end if 
01124       else 
01126          let ANIMATEDATACRAWLER=0
01128          let GENERATESCREENBTN=0
01130       end if 
01132 ! 
01134 ! .  ! Calculate Special Settings
01136       if LOGLAYOUT$="" AND EXISTS(DEFAULTFILELAYOUTPATH$&"logfile"&FILELAYOUTEXTENSION$) then let LOGLAYOUT$="logfile"
01138       if LOGLAYOUT$<>"" then let IGNORELAYOUTS$=IGNORELAYOUTS$&","&LOGLAYOUT$
01140       let IGNORELAYOUTS$=LWRC$(IGNORELAYOUTS$)
01142       if PROMPTONUPDATE=2 then let PROMPTONUPDATE=PROMPTONFILECREATE
01144 ! 
01146 ! .  ! Load Settings Engine
01148       let SSETTINGNAMES$(1)="layoutpath"
01150       let SSETTINGNAMES$(2)="newline"
01152       let SSETTINGNAMES$(3)="loglibrary"
01154       let SSETTINGNAMES$(4)="loglayout"
01156       let SSETTINGNAMES$(5)="templatepath"
01158       let SSETTINGNAMES$(6)="ignorelayouts"
01160       let SSETTINGNAMES$(7)="screeniopath"
01162       let SSETTINGNAMES$(8)="auditpath"
01164       let SSETTINGNAMES$(9)="layoutextension"
01166       let SSETTINGNAMES$(10)="saveselectedcols"
01168       let SSETTINGNAMES$(11)="dateformatexport"
01170       let SSETTINGNAMES$(12)="dateformatdisplay"
01172       let SSETTINGNAMES$(13)="emaillibrary"
01174 ! 
01176       let NSETTINGNAMES$(1)="promptonfilecreate"
01178       let NSETTINGNAMES$(2)="createlogfile"
01180       let NSETTINGNAMES$(3)="enforcedupkeys"
01182       let NSETTINGNAMES$(4)="startfilenumber"
01184       let NSETTINGNAMES$(5)="checkindex"
01186       let NSETTINGNAMES$(6)="compresscolumns"
01188       let NSETTINGNAMES$(7)="maxcolwidth"
01190       let NSETTINGNAMES$(8)="animatedatacrawler"
01192       let NSETTINGNAMES$(9)="closefilesimple"
01194       let NSETTINGNAMES$(10)="filterboxfilelist"
01196       let NSETTINGNAMES$(11)="filterboxdata"
01198       let NSETTINGNAMES$(12)="promptonupdate"
01200       let NSETTINGNAMES$(13)="generatescreenbtn"
01202       let NSETTINGNAMES$(14)="bypassfixrpt"
01204       let NSETTINGNAMES$(15)="suppressloggingerr"
01206 ! 
01208       let SSETTINGS$(1)=DEFAULTFILELAYOUTPATH$
01210       let SSETTINGS$(2)=NEWLINE$
01212       let SSETTINGS$(3)=LOGLIBRARY$
01214       let SSETTINGS$(4)=LOGLAYOUT$
01216       let SSETTINGS$(5)=TEMPLATEPATH$
01218       let SSETTINGS$(6)=IGNORELAYOUTS$
01220       let SSETTINGS$(7)=SCREENIOPATH$
01222       let SSETTINGS$(8)=AUDITPATH$
01224       let SSETTINGS$(9)=FILELAYOUTEXTENSION$
01226       let SSETTINGS$(10)=SAVESELECTEDCOLS$
01228       let SSETTINGS$(11)=DATEFORMATEXPORT$
01230       let SSETTINGS$(12)=DATEFORMATDISPLAY$
01232       let SSETTINGS$(13)=EMAILLIBRARY$
01234 ! 
01236       let NSETTINGS(1)=PROMPTONFILECREATE
01238       let NSETTINGS(2)=CREATELOGFILE
01240       let NSETTINGS(3)=ENFORCEDUPKEYS
01242       let NSETTINGS(4)=STARTFILENUMBER
01244       let NSETTINGS(5)=CHECKINDEX
01246       let NSETTINGS(6)=COMPRESSCOLUMNS
01248       let NSETTINGS(7)=MAXCOLWIDTH
01250       let NSETTINGS(8)=ANIMATEDATACRAWLER
01252       let NSETTINGS(9)=CLOSEFILESIMPLE
01254       let NSETTINGS(10)=FILTERBOXFILELIST
01256       let NSETTINGS(11)=FILTERBOXDATA
01258       let NSETTINGS(12)=PROMPTONUPDATE
01260       let NSETTINGS(13)=GENERATESCREENBTN
01262       let NSETTINGS(14)=BYPASSFIXRPT
01264       let NSETTINGS(15)=SUPPRESSLOGGINGERR
01266 ! 
01268       let READSETTINGS=1
01270    fnend 
01272 ! 
01274    dim READSETTINGS
01276    dim SSETTINGNAMES$(13),SSETTINGS$(13)*255
01278    dim NSETTINGNAMES$(15),NSETTINGS(15)
01280 ! 
01282    def FNSETTINGS$*255(SETTINGNAME$;___,SETTINGSUB)
01284       if ~READSETTINGS then let FNREADSETTINGS(MAT SSETTINGNAMES$,MAT SSETTINGS$,MAT NSETTINGNAMES$,MAT NSETTINGS$,READSETTINGS)
01286       let SETTINGSUB=SRCH(MAT SSETTINGNAMES$,LWRC$(SETTINGNAME$))
01288       if SETTINGSUB>0 then let FNSETTINGS$=SSETTINGS$(SETTINGSUB)
01290    fnend 
01292    def FNSETTINGS(SETTINGNAME$;___,SETTINGSUB)
01294       if ~READSETTINGS then let FNREADSETTINGS(MAT SSETTINGNAMES$,MAT SSETTINGS$,MAT NSETTINGNAMES$,MAT NSETTINGS$,READSETTINGS)
01296       let SETTINGSUB=SRCH(MAT NSETTINGNAMES$,LWRC$(SETTINGNAME$))
01298       if SETTINGSUB>0 then let FNSETTINGS=NSETTINGS(SETTINGSUB)
01300    fnend 
01302    def library FNFILEIO_SETTINGS$*255(SETTINGNAME$)=FNSETTINGS$(SETTINGNAME$)
01304    def library FNFILEIO_SETTINGS(SETTINGNAME$)=FNSETTINGS(SETTINGNAME$)
01306 ! 
01308    dim STARSCHECKED
01310    def FNNEEDSTAR$
01312       if STARSCHECKED then 
01314          if STARSCHECKED=-1 then let FNNEEDSTAR$="*"
01316       else 
01318          if ENV$("guimode")="ON" then 
01320             let STARSCHECKED=1
01322          else 
01324             let STARSCHECKED=-1
01326             let FNNEEDSTAR$="*"
01328          end if 
01330       end if 
01332    fnend 
01334 ! 
01336 Testfileio: ! Test partial indexes here
01338    print "Partial Index Tests:"
01340    let STRING1$=STRING2$="StartDate(5:8)"
01342    let POSITION=10
01344    let LENGTH=8
01346    let FNREADPARTIALSYNTAX(STRING1$,POSITION,"startdate","position")
01348    let FNREADPARTIALSYNTAX(STRING2$,LENGTH,"startdate","length")
01350    if STRING1$="StartDate" AND STRING2$="StartDate" AND POSITION=14 AND LENGTH=4 then 
01352       print "Test 1: StartDate(5:8)  - Passed"
01354    else 
01356       print "Test 1: StartDate(5:8)  - Failed"
01358    end if 
01360 ! 
01362    let STRING1$=STRING2$="StartDate(1:4)"
01364    let POSITION=10
01366    let LENGTH=8
01368    let FNREADPARTIALSYNTAX(STRING1$,POSITION,"startdate","position")
01370    let FNREADPARTIALSYNTAX(STRING2$,LENGTH,"startdate","length")
01372    if STRING1$="StartDate" AND STRING2$="StartDate" AND POSITION=10 AND LENGTH=4 then 
01374       print "Test 2: StartDate(1:4)  - Passed"
01376    else 
01378       print "Test 2: StartDate(1:4)  - Failed"
01380    end if 
01382 ! 
01384 ! .! This code tests the fnCompressIndexParms function:
01386    print 
01388    print "fnCompressIndexParms:"
01390    let X$="1/3/10" : let Y$="2/4/3"
01392    let FNCOMPRESSINDEXPARMS(X$,Y$)
01394    print "Positions: "&X$;
01396    if X$="1/10" then print "         - Passed" else print "         - Failed"
01398    print "Lengths: "&Y$;
01400    if Y$="6/3" then print "            - Passed" else print "            - Failed"
01402 ! 
01404    let X$="1/3/10" : let Y$="2/4U/3"
01406    let FNCOMPRESSINDEXPARMS(X$,Y$)
01408    print "Positions: "&X$;
01410    if X$="1/3/10" then print "       - Passed" else print "       - Failed"
01412    print "Lengths: "&Y$;
01414    if Y$="2/4U/3" then print "         - Passed" else print "         - Failed"
01416 ! 
01418    if EXISTS("filelay\customer.lay") then 
01420 ! .  ! Test fnBuildKey
01422       print 
01424       print "fnBuildKey:"
01426 ! 
01428       dim TESTKEY$*64
01430 ! 
01432       library : FNBUILDKEY$
01434       mat CUSTOMER$(20) : mat CUSTOMER(29)
01436       let CUSTOMER$(1)="7922"
01438       let CUSTOMER$(2)="Acme Hammers"
01440       let CUSTOMER$(5)="Duncanville"
01442       let CUSTOMER$(9)="4692235476"
01444       let TESTKEY$=FNBUILDKEY$("customer",MAT CUSTOMER$,MAT CUSTOMER)
01446       if TESTKEY$="7922" then 
01448          print "Test 1: "&TESTKEY$&"            - Passed"
01450       else 
01452          print "Test 1: "&TESTKEY$&"            - Failed"
01454       end if 
01456 ! 
01458       let TESTKEY$=FNBUILDKEY$("customer",MAT CUSTOMER$,MAT CUSTOMER,2)
01460       if TESTKEY$="Dunca2235476CME" then 
01462          print "Test 2: "&TESTKEY$&" - Passed"
01464       else 
01466          print "Test 2: "&TESTKEY$&" - Failed"
01468       end if 
01470    end if 
01472    stop 
01474 ! 
02000 ! #Autonumber# 2000,10
02010 Dims: ! Dimension Statements For Data Crawler
02020    dim LVDIR_HEADINGS$(1)*30,LVDIR_WIDTHS(1),LVDIR_FIELDFORMS$(1),LVDIR_LISTING$(1)*128
02030    dim DC_DATA$(1)*1024,DC_DATA(1),DC_FORMS$(1)*2000,DC_DFDESCR$(1)*80,DC_DATEFORMATS$(1)*50,DC_DFLABEL$(1)*80,DC_DFSHOW(1),DC_SDATESPEC$(1)*64,DC_NDATESPEC$(1)*64
02040    dim CSV_DATA$(1)*4000,CSV_DATA(1),CSV_FORMS$(1)*2000,CSV_DFDESCR$(1)*80, CSV_DATEFORMATS$(1)*50
02050    dim DC_WIDTHS(1),FIELDFORMS$(1),DC_OUTPUTROW$(1)*1024,DC_RECORDS(1)
02060    dim DC_SAVEDATA$(1)*1024, DC_SAVESUBS(1)
02070    dim DC_DELETEROW(1),DC_COLORSTART(1),DC_COLOREND(1),DC_COLOR$(1)
02080    dim DC_CHANGEDDATA$(1)*1024, DC_CHANGEDSUBS(1)
02090    dim _DUMMY$*255,_DUMMY,_LOGGING
02100    dim INCLUDECOLS$(1), UIOPTIONS$(13), SELECTEDRECORDS(1),RECORDS(1)
02110    dim SEARCH$*80
02120 ! 
02130    dim FILTERBOX$*64
02140    dim BYPASSDATEPROCESSING$*20
02150 ! 
02160    if TRIM$(ENV$("guimode"))="" then 
02170       print "DataCrawler Mode only works with New Gui version of BR"
02180       stop 
02190    end if 
02200    let TURNGUIBACKOFF=(ENV$("guimode")=="OFF")
02210    if TURNGUIBACKOFF then execute "config gui on"
02220 ! 
02230    let LVDIR_HEADINGS$(1)="File Layouts" !:
         let LVDIR_WIDTHS(1)=38 !:
         let LVDIR_FIELDFORMS$(1)="CC 30"
02240 ! 
02250    let UIOPTIONS$(1)="quitbutton"
02260    let UIOPTIONS$(2)="exportbutton"
02270    let UIOPTIONS$(3)="importbutton"
02280    let UIOPTIONS$(4)="columnsbutton"
02290    let UIOPTIONS$(5)="keybutton"
02300    let UIOPTIONS$(6)="deletebutton"
02310    let UIOPTIONS$(7)="savebutton"
02320    let UIOPTIONS$(8)="addbutton"
02330    let UIOPTIONS$(9)="search"
02340    let UIOPTIONS$(10)="border"
02350    let UIOPTIONS$(11)="caption"
02360    let UIOPTIONS$(12)="recl"
02370    let UIOPTIONS$(13)="position"
02380    mat INCLUDECOLS$(0)                !We're including all cols
02390 ! 
02400    library : FNREADLAYOUTS,FNSHOWDATA,FNGETFILENUMBER, FNLOG, FNLOGARRAY, FNSEARCHLEGACYREADSTATEMENTS
02410 ! 
07000 Selectdatafile: ! ***** Datafile Selection Routine #Autonumber# 7000,5
07005 ! 
07010    let FNREADLAYOUTS(MAT LVDIR_LISTING$)
07015    let FNCHECKFORNEWEXTENSION(MAT LVDIR_LISTING$)
07020    let FNIGNORELAYOUTS(MAT LVDIR_LISTING$)
07025 ! 
07030    let FNREADSCREENS(SCREENROWS,SCREENCOLS)
07035 ! 
07040    open #(DC_WINDOW:=FNGETFILENUMBER): "srow=2,scol="&STR$(INT((SCREENCOLS-39)/2))&",rows="&STR$(SCREENROWS-2)&",cols=39,Caption= Select File ... ENTER - View / F5 - Edit ,Border=S",display,outin 
07045 ! 
07050    if UDIM(MAT LVDIR_LISTING$)>15 then let LVDIR_WIDTHS(1)-=2  !Make Room For Scrollbar
07055 ! 
07060    let _LOGGING=FNSETTINGS("createlogfile")
07065    let _GENERATESCREEN=FNSETTINGS("generatescreenbtn")
07070 ! 
07075    dim HT$(1)*2000
07080 ! .! let HT$(1)="3;Run Once to set the Start Reference Point. Then test an Operation on your Files. Run again to display all changes found in the selected files.;"
07085 ! 
07090    print #DC_WINDOW, fields STR$(SCREENROWS-5)&",3,CC 10,/W:W,B43;"&STR$(SCREENROWS-5)&",27,CC 10,/W:W,B44" : "Quit","View"
07095    print #DC_WINDOW, fields STR$(SCREENROWS-5)&",15,CC 10,/W:W,B47", help "3;Run Once to set the Start Reference Point. Then test an Operation on your Files. Run again to display all changes found in the selected files.;" : "Compare"
07100    if _GENERATESCREEN then 
07105       print #DC_WINDOW, fields STR$(SCREENROWS-2)&",10,10/CC 20,/W:W,B49;"&STR$(SCREENROWS-2)&",21,9/CC 20,/W:W,B45" : "Generate Screen","Generate Code"
07110    else 
07115       print #DC_WINDOW, fields STR$(SCREENROWS-2)&",10,CC 20,/W:W,B45" : "Generate Code"
07120    end if 
07125 ! 
07130 ! .! print #Dc_Window, fields str$(ScreenRows-3)&",3,5/CC 20,/W:W,B50", help "3;Search non-fileio programs to see which programs access the given file and all their associated read statements." : "Search Reads"
07135    print #DC_WINDOW, fields STR$(SCREENROWS-3)&",32,CC 6,/W:W,B8", help "3;Check for Updates (F8);" : "v"&STR$(FNVERSION)
07140    print #DC_WINDOW, fields STR$(SCREENROWS-2)&",32,CC 6,/W:W,B9", help "3;View FileIO Recent Changes;" : "Log"
07145    print #DC_WINDOW, fields STR$(SCREENROWS-3)&",10,CC 20,/W:W,B46" : "New Layout Wizard"
07150    print #DC_WINDOW, fields STR$(SCREENROWS-3)&",2,CC 6,/W:W,B48", help "3;Export All Selected Data Files to CSV;" : "Export"
07155    print #DC_WINDOW, fields "1,2,LIST "&STR$(SCREENROWS-8)&"/37,HEADERS,/W:W" : (MAT LVDIR_HEADINGS$, MAT LVDIR_WIDTHS, MAT LVDIR_FIELDFORMS$)
07160    print #DC_WINDOW, fields "1,2,LIST "&STR$(SCREENROWS-8)&"/37,=" : (MAT LVDIR_LISTING$)
07165    print #DC_WINDOW, fields "1,2,LIST "&STR$(SCREENROWS-8)&"/37,SORT" : 1
07170 ! .! print #Dc_Window, fields str$(ScreenRows-4)&",12,C" : "Show Raw Data"
07175 ! 
07180    if FN43 AND FNSETTINGS("filterboxfilelist") then 
07185       let FILTERBOX$=STR$(SCREENROWS-7)&",2,FILTER 37,/W:W,1,2,FULLROW,ALL"
07190    else 
07195       let FILTERBOX$=STR$(SCREENROWS-7)&",2,SEARCH 37,/W:W,1,2"
07200    end if 
07205 ! 
07210    do 
07215       if BYPASSDATEPROCESSING then 
07220          print #DC_WINDOW, fields STR$(SCREENROWS-4)&",9,CC 22,N" : "F7 - Unpack Dates: Off"
07225       else 
07230          print #DC_WINDOW, fields STR$(SCREENROWS-4)&",9,CC 22,N" : "F7 - Unpack Dates: On"
07235       end if 
07240 ! 
07245       input #DC_WINDOW, fields FILTERBOX$&";1,2,LIST "&STR$(SCREENROWS-8)&"/37,ROWCNT,SEL,44" : SEARCH$,COUNT
07250       mat SELECTEDRECORDS(COUNT)
07255       input #DC_WINDOW, fields "1,2,LIST "&STR$(SCREENROWS-8)&"/37,ROWSUB,SEL,NOWAIT" : MAT SELECTEDRECORDS
07260       input #DC_WINDOW, fields "1,2,LIST "&STR$(SCREENROWS-8)&"/37,ROWSUB,CUR,NOWAIT" : CHOSEN
07265 ! 
07270 ! .  ! let BypassDateProcessing:=(BypassDateProcessing$(1:1)=="^")
07275 ! 
07280       let DC_KEY=FKEY
07285 ! 
07290       mat RECORDS(0)                  !We're including all records
07295 ! 
07300       if DC_KEY=0 OR DC_KEY=201 then let DC_KEY=44  !Ok Button
07305       if DC_KEY=99 then let DC_KEY=43  !Esc Button
07310       if DC_KEY=93 then let DC_KEY=43
07315       if DC_KEY=44 then ! Ok Selected
07320          let FNCLEARCACHE
07325          let FNSHOWDATA(LVDIR_LISTING$(CHOSEN),0,0,0,0,0,1,"","","","","Data Crawler",MAT RECORDS,MAT INCLUDECOLS$,MAT UIOPTIONS$,D$,D,D$,"count",D$,D$,D$,D$,D$,D,1,BYPASSDATEPROCESSING)
07330          if FKEY=93 then let DC_KEY=43  !pass windows X click back to parent
07335       end if 
07340       if DC_KEY=7 then 
07345          let BYPASSDATEPROCESSING=~BYPASSDATEPROCESSING
07350       end if 
07355       if DC_KEY=5 then 
07360          let FNCLEARCACHE
07365          let FNSHOWDATA(LVDIR_LISTING$(CHOSEN),1,0,0,0,0,1,"","","","","Data Editor",MAT RECORDS,MAT INCLUDECOLS$,MAT UIOPTIONS$,D$,D,D$,"count",D$,D$,D$,D$,D$,D,1,BYPASSDATEPROCESSING)
07370       end if 
07375       if DC_KEY=45 then 
07380          let FNGENERATECODE(LVDIR_LISTING$(CHOSEN))
07385       end if 
07390       if DC_KEY=46 then 
07395          let FNLAYOUTWIZARD
07400 ! 
07405 ! .     ! Refresh Listview
07410          let FNREADLAYOUTS(MAT LVDIR_LISTING$)
07415          let FNIGNORELAYOUTS(MAT LVDIR_LISTING$)
07420          print #DC_WINDOW, fields "1,2,LIST "&STR$(SCREENROWS-8)&"/37,=" : (MAT LVDIR_LISTING$)
07425          print #DC_WINDOW, fields "1,2,LIST "&STR$(SCREENROWS-8)&"/37,SORT" : 1
07430       end if 
07435       if DC_KEY=49 then ! Generate Screen using ScreenIO
07440          let FNMAKESCREEN(LVDIR_LISTING$(CHOSEN),1) error Oldscreenio
07445       end if 
07450       if DC_KEY=8 then 
07455          let FNCHECKFORUPDATES
07460       end if 
07465       if DC_KEY=9 then 
07470          if EXISTS("FileIOUpdateLog.txt") then execute "sy -C -M start FileIOUpdateLog.txt"
07475       end if 
07480       if DC_KEY=47 then 
07485          let FNCALLAUDIT(MAT SELECTEDRECORDS,MAT LVDIR_LISTING$)
07490       end if 
07495       if DC_KEY=48 then 
07500          let FNEXPORTSELECTEDFILES(MAT SELECTEDRECORDS,MAT LVDIR_LISTING$)
07505       end if 
07510       if DC_KEY=50 then 
07515          let FNSEARCHLEGACYREADSTATEMENTS(LVDIR_LISTING$(CHOSEN))
07520 ! .     ! $$$$$ Later, make a fnSearchLegacyReadStatements that supports Multi Select
07525       end if 
07530 ! 
07535       if FKEY=93 then let DC_KEY=43   !pass windows X click back to parent
07540    loop UNTIL DC_KEY=43
07545    close #DC_WINDOW: 
07550 ! 
08000 Enddatacrawler: ! #Autonumber# 8000,10
08010    if TURNGUIBACKOFF then execute "config gui off"
08020    if FKEY=93 then 
08030       execute "system"
08040    end if 
08050    stop 
08060 ! 
08070 Oldscreenio: ! Error this old version of ScreenIO doesn't support this feature.
08130    if (1==MSGBOX("This feature is not supported in this older version of ScreenIO."&HEX$("0d0a")&""&HEX$("0d0a")&"Please upgrade to the latest ScreenIO by downloading it from:"&HEX$("0d0a")&"http://www.sageax.com/downloads/ScreenIO.zip."&HEX$("0d0a")&""&HEX$("0d0a")&"Would you like us to download it for you?","Upgrade ScreenIO","yN")) then 
08140       execute "system -C -M start http://www.sageax.com/downloads/ScreenIO.zip"
08150    end if 
08160    continue 
08170 ! 
10000 ! #Autonumber# 10000,1
10001 ! *****************
10002 ! ** DATACRAWLER **
10003 ! *****************
10004 ! 
10005    dim SEARCHNOW$*999
10006    dim DCSPEC$(2)*60
10007    dim FILTERF$(1)*1023,FILTERF(1)
10008 ! 
10015    def library FNDATAEDIT( FILELAY$; SROW$, SCOL$, ROWS$, COLS$, ___,SROW,SCOL,ROWS,COLS)
10016 ! 
10017       let SROW=VAL(SROW$) conv IGNORE
10018       let SCOL=VAL(SCOL$) conv IGNORE
10019       let ROWS=VAL(ROWS$) conv IGNORE
10020       let COLS=VAL(COLS$) conv IGNORE
10021 ! 
10022       library : FNSHOWDATA
10023       let FNDATAEDIT=FNSHOWDATA(FILELAY$,1,SROW,SCOL,ROWS,COLS)
10024    fnend 
10025 ! 
10026    def library FNDATACRAWLER(FILELAY$;SROW$,SCOL$,ROWS$,COLS$,___,SROW,SCOL,ROWS,COLS)
10027       let SROW=VAL(SROW$) conv IGNORE
10028       let SCOL=VAL(SCOL$) conv IGNORE
10029       let ROWS=VAL(ROWS$) conv IGNORE
10030       let COLS=VAL(COLS$) conv IGNORE
10031 ! 
10032       library : FNSHOWDATA
10033       let FNDATACRAWLER=FNSHOWDATA(FILELAY$,0,SROW,SCOL,ROWS,COLS)
10034    fnend 
10035 ! 
10036    def FNCALCULATESIZE(&SROW,&SCOL,&ROWS,&COLS,EDIT,MAT ELEMENT$,MAT FILTER$;___,SCREENROWS,SCREENCOLS,MINROWS,MINCOLS,MAXROWS,MAXCOLS,MINSROW,MINSCOL,ADJROWS,ADJCOLS)
10037       let FNREADSCREENS(SCREENROWS,SCREENCOLS)
10038       let FNCALCULATESIZELIMITS(MAT ELEMENT$,EDIT,SCREENROWS,SCREENCOLS,ROWS,COLS,MINROWS,MINCOLS,MAXROWS,MAXCOLS,MINSROW,MINSCOL,MAT FILTER$)
10039 ! 
10040 ! .  ! Size it within limits
10041       let ROWS=MAX(MIN(ROWS,MAXROWS),MINROWS)
10042       let COLS=MAX(MIN(COLS,MAXCOLS),MINCOLS)
10043 ! 
10044 ! .  ! Center it if position isn't given
10045       if ~SROW then let SROW=INT((SCREENROWS-ROWS)/2)+1
10046       if ~SCOL then let SCOL=INT((SCREENCOLS-COLS)/2)+1
10047 ! 
10048       let ADJROWS=INT((SCREENROWS+MAXROWS)/2)
10049       let ADJCOLS=INT((SCREENCOLS+MAXCOLS)/2)
10050 ! 
10051 ! .  ! Adjust it to fit it on screen
10052       let SROW=MAX(MIN(SROW,ADJROWS-ROWS),MINSROW)
10053       let SCOL=MAX(MIN(SCOL,ADJCOLS-COLS),MINSCOL)
10054    fnend 
10055 ! 
10056 ! .! If Include is blank (not given), then include everything.
10057    def FNPREPINCLUDEUI$(MAT INCLUDEUI$;___,INDEX,EMPTY)
10058       if FNISEMPTYS(MAT INCLUDEUI$) then 
10059 ! .     ! Default UI Options
10060          mat INCLUDEUI$(10)
10061          let INCLUDEUI$(1)="quitbutton"
10062          let INCLUDEUI$(2)="exportbutton"
10063          let INCLUDEUI$(3)="importbutton"
10064          let INCLUDEUI$(4)="columnsbutton"
10065          let INCLUDEUI$(5)="deletebutton"
10066          let INCLUDEUI$(6)="savebutton"
10067          let INCLUDEUI$(7)="addbutton"
10068          let INCLUDEUI$(8)="search"
10069          let INCLUDEUI$(9)="border"
10070          let INCLUDEUI$(10)="caption"
10071       end if 
10072 ! 
10073    fnend 
10074 ! 
10075    def FNISEMPTYS(MAT A$;___,INDEX,EMPTY)
10076       let EMPTY=1
10077       for INDEX=1 to UDIM(MAT A$)
10078          if A$(INDEX)<>"" then let EMPTY=0
10079       next INDEX
10080       let FNISEMPTYS=EMPTY
10081    fnend 
10082    def FNISEMPTY(MAT A;___,INDEX,EMPTY)
10083       let EMPTY=1
10084       for INDEX=1 to UDIM(MAT A)
10085          if A(INDEX) then let EMPTY=0
10086       next INDEX
10087       let FNISEMPTY=EMPTY
10088    fnend 
10089    def library FNEMPTY(MAT A)=FNISEMPTY(MAT A)
10090    def library FNEMPTYS(MAT A$)=FNISEMPTYS(MAT A$)
10091 ! 
10092    def FNCLEARUI(MAT OUTPUTSPEC$,MAT INPUTSPEC$,MAT OUTPUTDATA$,MAT INPUTDATA$)
10093       mat OUTPUTSPEC$(0)
10094       mat OUTPUTDATA$(0)
10095       mat INPUTSPEC$(0)
10096       mat INPUTDATA$(0)
10097       let BUTTONCOUNT=0
10098    fnend 
10099 ! 
10100    dim BUTTONCOUNT,MAXBUTTONCOLUMNS
10101    def FNBUTTONROWS
10102       if BUTTONCOUNT then 
10103          let FNBUTTONROWS=INT((BUTTONCOUNT-1)/MAXBUTTONCOLUMNS)+1
10104       end if 
10105    fnend 
10106 ! 
10107    def FNBUTTONSPEC$*36(BUTTONFKEY,ROW,COLS;___,BUTTONCOL,BUTTONROW)
10108       let BUTTONCOUNT+=1
10109       let BUTTONROW=INT((BUTTONCOUNT-1)/MAXBUTTONCOLUMNS)
10110       let BUTTONCOL=MOD(BUTTONCOUNT-1,MAXBUTTONCOLUMNS)+1
10111       let FNBUTTONSPEC$=STR$(ROW-BUTTONROW)&","&STR$(COLS-((8*(BUTTONCOL))-1))&","&"7/CC 10,/W:W,B"&STR$(BUTTONFKEY)
10112    fnend 
10113 ! 
10114    def FNADDBUTTON(MAT OUTPUTSPEC$,MAT OUTPUTDATA$,ROWS,COLS,BUTTONFKEY,DATA$)
10115       let FNADDOBJECT(MAT OUTPUTSPEC$,MAT OUTPUTDATA$,FNBUTTONSPEC$(BUTTONFKEY,ROWS,COLS),DATA$)
10116    fnend 
10117 ! 
10118    def FNADDOBJECT(MAT OUTPUTSPEC$,MAT OUTPUTDATA$,SPEC$*40,DATA$;___,INDEX)
10119       let INDEX=UDIM(MAT OUTPUTSPEC$)+1
10120       mat OUTPUTSPEC$(INDEX)
10121       mat OUTPUTDATA$(INDEX)
10122       let OUTPUTSPEC$(INDEX)=SPEC$
10123       let OUTPUTDATA$(INDEX)=DATA$
10124       let FNADDOBJECT=INDEX
10125    fnend 
10126 ! 
10127    def FNCALCULATESIZELIMITS(MAT ELEMENT$,EDIT,SCREENROWS,SCREENCOLS,&ROWS,&COLS,&MINROWS,&MINCOLS,&MAXROWS,&MAXCOLS,&MINSROW,&MINSCOL,MAT FILTER$;___,INDEX,BCOUNT,BCOLS,O_BORDER,BUTTONROWS)
10128 ! 
10129 ! .  ! Set Defaults
10130       let MAXROWS=SCREENROWS
10131       let MAXCOLS=SCREENCOLS
10132       let MINSROW=1
10133       let MINSCOL=1
10134       let MINROWS=3
10135       let MINCOLS=10
10136 ! 
10137       for INDEX=1 to UDIM(MAT ELEMENT$)
10138          if LWRC$(TRIM$(ELEMENT$(INDEX))) = "importbutton" OR LWRC$(TRIM$(ELEMENT$(INDEX))) = "addbutton" OR LWRC$(TRIM$(ELEMENT$(INDEX))) = "deletebutton" OR LWRC$(TRIM$(ELEMENT$(INDEX))) = "savebutton" then ! #Select# lwrc$(trim$(Element$(Index))) #Case# "importbutton" # "addbutton" # "deletebutton" # "savebutton"
10139             if EDIT then let BCOUNT+=1
10140          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "columnsbutton" OR LWRC$(TRIM$(ELEMENT$(INDEX))) = "exportbutton" OR LWRC$(TRIM$(ELEMENT$(INDEX))) = "keybutton" OR LWRC$(TRIM$(ELEMENT$(INDEX))) = "quitbutton" then ! #Case# "columnsbutton" # "exportbutton" # "keybutton" # "quitbutton"
10141             let BCOUNT+=1
10142          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "search" then ! #Case# "search"
10143             let MINROWS+=1
10144             let MINCOLS=MAX(MINCOLS,20)
10145          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "grid" then ! #Case# "grid"
10146          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "border" OR LWRC$(TRIM$(ELEMENT$(INDEX))) = "caption" OR LWRC$(TRIM$(ELEMENT$(INDEX))) = "recl" then ! #Case# "border" # "caption" # "recl"
10147             let O_BORDER=1
10148          end if                       !#End Select#
10149       next INDEX
10150 ! 
10151       if O_BORDER then ! Expand to include border
10152          let MAXROWS-=2 : let MAXCOLS-=2
10153          let MINSROW+=1 : let MINSCOL+=1
10154       end if 
10155 ! 
10156 ! .  ! Default Size if not given
10157       if ~ROWS then let ROWS=MAXROWS
10158       if ~COLS then let COLS=MAXCOLS
10159 ! 
10160 ! .  ! calculate how many columns we need
10161       if BCOUNT<5 OR BCOUNT<=(COLS-2)/8 then 
10162          let MAXBUTTONCOLUMNS=BCOUNT
10163       else 
10164          let MAXBUTTONCOLUMNS=INT((BCOUNT-1)/2)+1
10165       end if 
10166 ! 
10167 ! .  ! Expand to include buttons
10168       if BCOUNT then 
10169          let BUTTONROWS=INT((BCOUNT-1)/MAXBUTTONCOLUMNS)+1
10170          let MINROWS+=BUTTONROWS
10171          if BUTTONROWS>1 then 
10172             let BCOLS=MAXBUTTONCOLUMNS
10173          else 
10174             let BCOLS=MOD((BCOUNT-1),MAXBUTTONCOLUMNS)+1
10175          end if 
10176          let MINCOLS=MAX(MINCOLS,(8*(BCOLS-1))+10)
10177       end if 
10178 ! 
10179 ! .  ! Add a row for filters
10180       if ~FNISEMPTYS(MAT FILTER$) then 
10181          let MINROWS+=1
10182       end if 
10183    fnend 
10184 ! 
10185    def FNBUILDUI(MAT ELEMENT$,MAT OS$,MAT IS$,MAT OD$,MAT ID$,MAT FILTERFIELDS$,MAT FILTERFORM$,MAT FILTERCOMPARE$,MAT FILTERCAPTION$,MAT FILTERDEFAULTS$,MAT FILTERSUBS,MAT FILTERVALSUBS,MAT COLUMNNAMES$,MAT FILTERKEY,&GRIDSPEC$,EDIT,ROWS,COLS;&O_CAPTION,&O_BORDER,&O_RECL,&O_POSITION,&SEARCHSUB,___,O_SEARCH,INDEX,GRID$,FIRSTROW,FILTERPOSITION,SUB,FILTERSTRING$,FILTERENDSTRING$)
10186       let FIRSTROW=1
10187       if FN43 AND FNSETTINGS("filterboxdata") then 
10188          let FILTERSTRING$="FILTER"
10189          let FILTERENDSTRING$=",FULLROW,ALL"
10190       else 
10191          let FILTERSTRING$="SEARCH"
10192          let FILTERENDSTRING$=""
10193       end if 
10194 ! 
10195       if ~FNISEMPTYS(MAT FILTERFIELDS$) then 
10196          let FIRSTROW+=1
10197          let FILTERPOSITION=1
10198          mat FILTERFORM$(UDIM(MAT FILTERFIELDS$))
10199          mat FILTERCOMPARE$(UDIM(MAT FILTERFIELDS$))
10200          mat FILTERCAPTION$(UDIM(MAT FILTERFIELDS$))
10201          mat FILTERDEFAULTS$(UDIM(MAT FILTERFIELDS$))
10202          mat FILTERSUBS(UDIM(MAT FILTERFIELDS$))
10203          mat FILTERVALSUBS(UDIM(MAT FILTERFIELDS$))
10204          mat FILTERKEY(UDIM(MAT FILTERFIELDS$))
10205 ! 
10206          for INDEX=1 to UDIM(MAT FILTERFIELDS$)
10207             if LEN(TRIM$(FILTERFIELDS$(INDEX))) then 
10208                let SUB=SRCH(MAT COLUMNNAMES$,LWRC$(TRIM$(FILTERFIELDS$(INDEX))))
10209                if SUB>0 then 
10210                   let FNADDOBJECT(MAT OS$,MAT OD$,"1,"&STR$(FILTERPOSITION)&",CR "&STR$(LEN(FILTERCAPTION$(INDEX))),FILTERCAPTION$(INDEX))
10211                   let FILTERPOSITION+=LEN(FILTERCAPTION$(INDEX))+1
10212                   let FILTERVALSUBS(INDEX)=FNADDOBJECT(MAT IS$,MAT ID$,"1,"&STR$(FILTERPOSITION)&","&FILTERFORM$(INDEX),FILTERDEFAULTS$(INDEX))
10213                   let FILTERPOSITION+=FNLENGTHOF(FILTERFORM$(INDEX))+2
10214                   let FILTERSUBS(INDEX)=SUB
10215                end if 
10216             end if 
10217          next INDEX
10218       end if 
10219       for INDEX=1 to UDIM(MAT ELEMENT$)
10220          if LWRC$(TRIM$(ELEMENT$(INDEX))) = "columnsbutton" then ! #Select# lwrc$(trim$(Element$(Index))) #Case# "columnsbutton"
10221             let FNADDBUTTON(MAT OS$,MAT OD$,ROWS,COLS,55,"Columns")
10222          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "exportbutton" then ! #Case# "exportbutton"
10223             let FNADDBUTTON(MAT OS$,MAT OD$,ROWS,COLS,56,"Export")
10224          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "importbutton" then ! #Case# "importbutton"
10225             if EDIT then let FNADDBUTTON(MAT OS$,MAT OD$,ROWS,COLS,57,"Import")
10226          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "addbutton" then ! #Case# "addbutton"
10227             if EDIT then let FNADDBUTTON(MAT OS$,MAT OD$,ROWS,COLS,15,"Add")
10228          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "savebutton" then ! #Case# "savebutton"
10229             if EDIT then let FNADDBUTTON(MAT OS$,MAT OD$,ROWS,COLS,5,"Save (F5)")
10230          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "deletebutton" then ! #Case# "deletebutton"
10231             if EDIT then let FNADDBUTTON(MAT OS$,MAT OD$,ROWS,COLS,16,"Delete")
10232          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "keybutton" then ! #Case# "keybutton"
10233             let FNADDBUTTON(MAT OS$,MAT OD$,ROWS,COLS,4,"Jump (F4)")
10234          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "quitbutton" then ! #Case# "quitbutton"
10235             let FNADDBUTTON(MAT OS$,MAT OD$,ROWS,COLS,54,"Quit")
10236          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "search" then ! #Case# "search"
10237             if EXISTS("images\search.png") then 
10238                let SEARCHSUB=FNADDOBJECT(MAT IS$,MAT ID$,STR$(FIRSTROW)&",3,"&FILTERSTRING$&" "&STR$(COLS-12)&",/W:W,2,1"&FILTERENDSTRING$,"")
10239                let FNADDOBJECT(MAT OS$,MAT OD$,STR$(FIRSTROW)&",1,P 1/2","images\search.png")
10240             else 
10241                let SEARCHSUB=FNADDOBJECT(MAT IS$,MAT ID$,STR$(FIRSTROW)&",1,"&FILTERSTRING$&" "&STR$(COLS-10)&",/W:W,2,1"&FILTERENDSTRING$,"")
10242             end if 
10243             let FNADDOBJECT(MAT OS$,MAT OD$,STR$(FIRSTROW)&","&STR$(COLS-8)&",CC 8,/W:W,B70","Refresh")
10244             let O_SEARCH=1
10245          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "border" then ! #Case# "border"
10246             let O_BORDER=1
10247          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "caption" then ! #Case# "caption"
10248             let O_CAPTION=1
10249             let O_BORDER=1
10250          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "recl" then ! #Case# "recl"
10251             let O_RECL=1
10252             let O_CAPTION=1
10253             let O_BORDER=1
10254          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "position" then ! #Case# "position"
10255             let O_POSITION=1
10256          end if                       !#End Select#
10257       next INDEX
10258 ! 
10259       if EDIT then 
10260          let FNADDOBJECT(MAT IS$,MAT ID$,STR$(FIRSTROW+O_SEARCH)&",1,GRID "&STR$(ROWS-((FIRSTROW-1)+O_SEARCH+FNBUTTONROWS))&"/"&STR$(COLS)&",ROWCNT,CHG","")
10261          let GRIDSPEC$=STR$(FIRSTROW+O_SEARCH)&",1,GRID "&STR$(ROWS-((FIRSTROW-1)+O_SEARCH+FNBUTTONROWS))&"/"&STR$(COLS)
10262       else 
10263          let FNADDOBJECT(MAT IS$,MAT ID$,STR$(FIRSTROW+O_SEARCH)&",1,LIST "&STR$(ROWS-((FIRSTROW-1)+O_SEARCH+FNBUTTONROWS))&"/"&STR$(COLS)&",ROWSUB,SELONE","")
10264          let GRIDSPEC$=STR$(FIRSTROW+O_SEARCH)&",1,LIST "&STR$(ROWS-((FIRSTROW-1)+O_SEARCH+FNBUTTONROWS))&"/"&STR$(COLS)
10265       end if 
10266       mat ID$(UDIM(MAT ID$)-1)        !Remove Data element for list; it has to be given as a Scalar
10267    fnend 
10268 ! 
10269    def FNCHECKFORUPDATES(;___,CONNECTION,V,STRING$*1000,WINDOW)
10270       if FN43 then 
10271          open #(WINDOW:=FNGETFILENUMBER): "srow=10,scol=20,rows=1,cols=30,Border=S",display,outin 
10272          print #WINDOW, fields "1,1,CC 30" : "Contacting Server..."
10273          open #(CONNECTION:=FNGETFILENUMBER): "name=http://www.sageax.com/downloads/FileIOVersion.txt, http=client",display,outin 
10274          if FILE(CONNECTION)=0 then 
10275             linput #CONNECTION: STRING$ eof IGNORE
10276             close #CONNECTION: 
10277             close #WINDOW: 
10278             let V=-999
10279             let V=VAL(STRING$) conv IGNORE
10280             if V=-999 then 
10281                let MSGBOX("There was an error checking the latest version on the Server. Check your internet connection, or try again later."&HEX$("0D0A0D0A")&"If the problem persists, please contact Gabriel Bakker at gabriel.bakker@gmail.com.","Connection Failed","Ok","EXCL")
10282             else if V>FNVERSION then 
10283                if (2==MSGBOX("A newer version (FileIO v"&STR$(V)&") is available. (You're currently running FileIO v"&STR$(FNVERSION)&")."&HEX$("0D0A0D0A")&"Would you like to download the update from our website?","Update Y/N?","Yn","QST")) then 
10284                   execute "sy -C -M start http://www.sageax.com/downloads/FileIO.zip"
10285                end if 
10286             else 
10287                let MSGBOX("Your version is up to date!"&HEX$("0D0A0D0A")&"You are running FileIO v"&STR$(FNVERSION)&", the current version.","FileIO is Up to Date","Ok","EXCL")
10288             end if 
10289          else 
10290             let MSGBOX("The server, www.sageax.com, could not be reached. Check your internet connection, or try again later."&HEX$("0D0A0D0A")&"If the problem persists, please contact Gabriel Bakker at gabriel.bakker@gmail.com.","Connection Failed","Ok","EXCL")
10291             close #WINDOW: 
10292             if FILE(CONNECTION)><-1 then close #CONNECTION: 
10293          end if 
10294       else 
10295          let MSGBOX("This feature requires BR 4.3+")
10296       end if 
10297    fnend 
10298 ! 
10299    def FNPREPAREWINDOW(&SROW,&SCOL,&ROWS,&COLS,EDIT,MAT INCLUDEBUTTONS$,&CAPTION$,&GRIDSPEC$,MAT INPUTSPEC$,MAT OUTPUTSPEC$,MAT INPUTDATA$,MAT OUTPUTDATA$,&O_POSITION,MAT FILTERFIELDS$,MAT FILTERFORM$,MAT FILTERCOMPARE$,MAT FILTERCAPTION$,MAT FILTERDEFAULTS$,MAT FILTERSUBS,MAT FILTERVALSUBS,MAT COLUMNNAMES$,MAT FILTERKEY,&SEARCHSUB;___,O_CAPTION,O_BORDER,O_RECL)
10300       let FNPREPINCLUDEUI$(MAT INCLUDEBUTTONS$)
10301 ! 
10302       let FNCALCULATESIZE(SROW,SCOL,ROWS,COLS,EDIT,MAT INCLUDEBUTTONS$,MAT FILTERFIELDS$)
10303       let FNCLEARUI(MAT OUTPUTSPEC$,MAT INPUTSPEC$,MAT OUTPUTDATA$,MAT INPUTDATA$)
10304       let FNBUILDUI(MAT INCLUDEBUTTONS$,MAT OUTPUTSPEC$,MAT INPUTSPEC$,MAT OUTPUTDATA$,MAT INPUTDATA$,MAT FILTERFIELDS$,MAT FILTERFORM$,MAT FILTERCOMPARE$,MAT FILTERCAPTION$,MAT FILTERDEFAULTS$,MAT FILTERSUBS,MAT FILTERVALSUBS,MAT COLUMNNAMES$,MAT FILTERKEY,GRIDSPEC$,EDIT,ROWS,COLS,O_CAPTION,O_BORDER,O_RECL,O_POSITION,SEARCHSUB)
10305 ! 
10306 ! .  ! if setting recl or
10307       if CAPTION$="" AND O_CAPTION then let CAPTION$="View '"&FILELAY$&"' File"
10308       if O_RECL then let CAPTION$=CAPTION$&" ... Recl="&STR$(RLN(DATAFILE))
10309       if O_BORDER then 
10310          if LEN(CAPTION$) then let CAPTION$=CAPTION$&","
10311          let CAPTION$=CAPTION$&"Border=S"
10312       end if 
10313    fnend 
10314 ! 
10315    dim TEXTDISPLAY$*255
10316    dim BADREAD$(1)*20000
10317 ! 
10318    def FNPOPULATEGRID(WINDOW,GRIDSPEC$,LAYOUT$,KEYMATCH$*255,SEARCHMATCH$*255,MAT RECORDS,MAT INCLUDECOLUMNS$,MAT COLUMNNAMES$,RECORDSIZE,DATAFILE,MAT DC_DATA$,MAT DC_DATA,MAT DC_FORMS$,&SEARCHNOW$,MAT DC_RECORDS,MAT DC_DELETEROW,KEYNUMBER,&LASTREC$,DISPLAYSUB,&DISPLAYCONVERT$,MAT FILTERCOMPARE$,MAT FILTERSUBS,MAT FILTERVALSUBS,MAT FILTERKEY,MAT INPUTDATA$;INCLUDERECORDNUMBERS,MAT DC_DATEFORMATS$,DATEDISPLAYFORMAT$,BYPASSDATEPROCESSING,___,SOMETHINGFOUND,OR_RECORDLOCATION,CLEARFLAG$*1,INDEX,ANIMATE,BINCLUDECOLUMNS,SUB,BRECORDS,RECPOINTER,STOPREADING,ACTION,TEMPKEY$*255,ROWCOUNT,READCOUNT,LASTTIME,BADREADFILE)
10319 ! 
10320       execute "config keyboard 6300 2200"  !ESC To Ctrl-F8 (Fkey 34)
10321       execute "config keyboard 0B00 0A0A0A636F6E206B657920636C6561720D"  !Shift F1 Key To "con key clear<CR>"
10322       on fkey 34 gosub Abortloading
10323 ! 
10324       let ANIMATE=FNSETTINGS("animatedatacrawler")
10325       mat DC_OUTPUTROW$(0) : mat DC_RECORDS(0) : mat DC_DELETEROW(0)
10326       let CLEARFLAG$="="
10327       if ANIMATE then let FNPREPAREANIMATION
10328 ! 
10329       let RECORDSIZE=UDIM(MAT WIDTHS)
10330 ! 
10331       let BINCLUDECOLUMNS=(~FNISEMPTYS(MAT INCLUDECOLUMNS$))
10332       let BRECORDS=(~FNISEMPTY(MAT RECORDS))
10333 ! 
10334       if LEN(KEYMATCH$) AND KLN(DATAFILE)>0 then 
10335          let KEYMATCH$=RTRM$(KEYMATCH$(1:KLN(DATAFILE)))
10336          restore #DATAFILE, search>=KEYMATCH$: 
10337       end if 
10338 ! 
10339       mat BADREAD$(0)                 !Clear Bad Record Reads
10340 ! 
10341       mat DC_SDATESPEC$(UDIM(MAT DC_DATA$))
10342       if UDIM(MAT DC_SDATESPEC$) then mat DC_SDATESPEC$=DC_DATEFORMATS$(1:UDIM(MAT DC_DATA$))
10343       mat DC_NDATESPEC$(UDIM(MAT DC_DATA))
10344       if UDIM(MAT DC_NDATESPEC$) then mat DC_NDATESPEC$=DC_DATEFORMATS$(UDIM(MAT DC_DATA$)+1:UDIM(MAT DC_DATEFORMATS$))
10345 ! 
10346       do                              !Read Data
10347          let LASTTIME=TIMER
10348          do WHILE FILE(DATAFILE)<>10
10349             if BRECORDS then 
10350                let RECPOINTER+=1
10351                if RECPOINTER<=UDIM(MAT RECORDS) then 
10352                   read #DATAFILE, using DC_FORMS$(DATAFILE), rec=RECORDS(RECPOINTER), release: MAT DC_DATA$,MAT DC_DATA error IGNORE
10353                else 
10354                   let STOPREADING=1
10355                end if 
10356             else 
10357                read #DATAFILE, using DC_FORMS$(DATAFILE),release: MAT DC_DATA$,MAT DC_DATA error IGNORE
10358             end if 
10359 ! 
10360             if ~FILE(DATAFILE) AND ~STOPREADING then 
10361                let READCOUNT+=1
10362                let ACTION=FNPASSESFILTER(MAT DC_DATA$,MAT DC_DATA,MAT FILTERCOMPARE$,MAT FILTERVALSUBS,MAT FILTERSUBS,MAT INPUTDATA$,MAT FILTERKEY)
10363                if ACTION=1 then 
10364                   if ~LEN(KEYMATCH$) OR KEYMATCH$=FNBUILDKEY$(LAYOUT$,MAT DC_DATA$,MAT DC_DATA,KEYNUMBER)(1:LEN(KEYMATCH$)) then 
10365                      if ~LEN(SEARCHMATCH$) OR FNSEARCHIN(SEARCHMATCH$,MAT DC_DATA$,MAT DC_DATA,MAT DC_SDATESPEC$,MAT DC_NDATESPEC$,DATEDISPLAYFORMAT$,BYPASSDATEPROCESSING) then 
10366                         if ~LEN(SEARCHNOW$) OR FNSEARCHIN(SEARCHNOW$,MAT DC_DATA$,MAT DC_DATA,MAT DC_SDATESPEC$,MAT DC_NDATESPEC$,DATEDISPLAYFORMAT$,BYPASSDATEPROCESSING) then 
10367                            let ROWCOUNT+=1
10368                            let SOMETHINGFOUND=1
10369                            let OR_RECORDLOCATION=UDIM(MAT DC_OUTPUTROW$)
10370                            mat DC_OUTPUTROW$(UDIM(DC_OUTPUTROW$)+RECORDSIZE)  !Add Room
10371                            mat DC_DELETEROW(UDIM(MAT DC_RECORDS) + 1)  !Add Row To Delete From
10372                            mat DC_RECORDS(UDIM(MAT DC_RECORDS) + 1)
10373                            let DC_RECORDS(UDIM(MAT DC_RECORDS))=REC(DATAFILE)  !Save Record Number For Later
10374                            if INCLUDERECORDNUMBERS then 
10375                               let DC_OUTPUTROW$(OR_RECORDLOCATION+INCLUDERECORDNUMBERS)=STR$(REC(DATAFILE))
10376                            end if 
10377 ! 
10378                            if BINCLUDECOLUMNS then 
10379                               for INDEX=1 to UDIM(MAT INCLUDECOLUMNS$)
10380                                  let SUB=SRCH(MAT COLUMNNAMES$,INCLUDECOLUMNS$(INDEX))
10381                                  if SUB>UDIM(MAT DC_DATA$) then 
10382                                     let DC_OUTPUTROW$(OR_RECORDLOCATION+INDEX+INCLUDERECORDNUMBERS)= FNFMTNDATE$(DC_DATA(SUB-UDIM(MAT DC_DATA$)),DC_DATEFORMATS$(SUB),"DATE(JULIAN)",BYPASSDATEPROCESSING)
10383                                  else if SUB>0 then 
10384                                     let DC_OUTPUTROW$(OR_RECORDLOCATION+INDEX+INCLUDERECORDNUMBERS)=FNFMTSDATE$(DC_DATA$(SUB),DC_DATEFORMATS$(SUB),"DATE(JULIAN)",BYPASSDATEPROCESSING)
10385                                  end if 
10386                               next INDEX
10387                            else 
10388                               for INDEX=1 to UDIM(MAT DC_DATA$)  !Copy Strings
10389                                  let DC_OUTPUTROW$(OR_RECORDLOCATION+INDEX+INCLUDERECORDNUMBERS)= FNFMTSDATE$(DC_DATA$(INDEX),DC_DATEFORMATS$(INDEX),"DATE(JULIAN)",BYPASSDATEPROCESSING)
10390                               next INDEX
10391 ! 
10392                               for INDEX=1 to UDIM(MAT DC_DATA)  !Copy Numerics
10393                                  let DC_OUTPUTROW$(OR_RECORDLOCATION+INDEX+INCLUDERECORDNUMBERS+UDIM(MAT DC_DATA$))=FNFMTNDATE$(DC_DATA(INDEX),DC_DATEFORMATS$(INDEX+UDIM(MAT DC_DATA$)),"DATE(JULIAN)",BYPASSDATEPROCESSING)
10394                               next INDEX
10395                            end if 
10396                         end if 
10397                      end if 
10398                   else 
10399                      let STOPREADING=1
10400                   end if 
10401                else if ACTION<0 then 
10402                   let ACTION=ACTION*-1
10403 ! 
10404                   mat FILTERF$(UDIM(MAT DC_DATA$))=("")
10405                   mat FILTERF(UDIM(MAT DC_DATA))=(0)
10406 ! 
10407 ! .              ! take the filter that failed
10408                   if FILTERSUBS(ACTION)>UDIM(MAT FILTERF$) then ! use filter to find the subscript
10409                      let FILTERF(FILTERSUBS(ACTION)-UDIM(MAT FILTERF$))=VAL(INPUTDATA$(FILTERVALSUBS(ACTION))) conv IGNORE
10410                   else 
10411                      let FILTERF$(FILTERSUBS(ACTION))=INPUTDATA$(FILTERVALSUBS(ACTION))
10412                   end if 
10413 ! 
10414 ! .              ! use subscript to build an empty f$ and f with the data
10415 ! .              ! use fnBuildKey$ and Keynum
10416                   if KLN(DATAFILE)>0 AND ~FNISEMPTY(MAT FILTERF) OR ~FNISEMPTYS(MAT FILTERF$) then 
10417                      let TEMPKEY$=FNBUILDKEY$(LAYOUT$,MAT FILTERF$,MAT FILTERF,KEYNUMBER)
10418                      restore #DATAFILE, search>=TRIM$(TEMPKEY$): nokey Stopreading
10419                   end if 
10420                else if ACTION=2 then 
10421 Stopreading:      let STOPREADING=1   !dont like it but its the simplest way to do it in this language.
10422                end if 
10423                if ANIMATE then 
10424                   let TEXTDISPLAY$=""
10425                   if DISPLAYSUB then 
10426                      if DISPLAYSUB=-2 then 
10427                         let TEXTDISPLAY$=LPAD$(STR$(READCOUNT),LEN(LASTREC$))  !Count of Rows Read
10428                      else if DISPLAYSUB=-3 then 
10429                         let TEXTDISPLAY$=LPAD$(STR$(ROWCOUNT),LEN(LASTREC$))  !Count of Rows Added
10430                      else if DISPLAYSUB<0 then ! All others use record number
10431                         let TEXTDISPLAY$=LPAD$(STR$(REC(DATAFILE)),LEN(LASTREC$))
10432                      else if DISPLAYSUB<=UDIM(MAT DC_DATA$) then 
10433                         let TEXTDISPLAY$=TRIM$(DC_DATA$(DISPLAYSUB))
10434                      else 
10435                         if ~LEN(DISPLAYCONVERT$) then 
10436                            let TEXTDISPLAY$=STR$(DC_DATA(DISPLAYSUB-UDIM(MAT DC_DATA$)))
10437                         else 
10438                            let TEXTDISPLAY$=CNVRT$(DISPLAYCONVERT$,DC_DATA(DISPLAYSUB-UDIM(MAT DC_DATA$))) conv IGNORE
10439                         end if 
10440                      end if 
10441                   end if 
10442                   if LEN(TRIM$(LASTREC$)) then 
10443                      if LEN(TEXTDISPLAY$) then let TEXTDISPLAY$=TEXTDISPLAY$&" of "
10444                      let TEXTDISPLAY$=TEXTDISPLAY$&LASTREC$
10445                   end if 
10446 ! 
10447                   let FNANIMATE(TEXTDISPLAY$)
10448                end if 
10449             else 
10450                if FILE(DATAFILE)=20 then 
10451                   if (FN43 AND UDIM(MAT BADREAD$)<13420) OR UDIM(MAT BADREAD$)<=40 then 
10452                      mat BADREAD$(UDIM(BADREAD$)+1)
10453                      reread #DATAFILE, using "form C "&STR$(RLN(DATAFILE)) : BADREAD$(UDIM(BADREAD$)) error IGNORE
10454                   end if 
10455                end if 
10456             end if 
10457 ! 
10458          loop UNTIL STOPREADING OR FKEY=99 OR UDIM(MAT DC_OUTPUTROW$)+RECORDSIZE>1000 OR (UDIM(MAT DC_OUTPUTROW$) AND ROWCOUNT<=20 AND (TIMER-LASTTIME>2))
10459 ! 
10460          print #WINDOW, fields GRIDSPEC$&","&CLEARFLAG$ : MAT DC_OUTPUTROW$
10461          mat DC_OUTPUTROW$(0)         !Clear Already Used Data To Go Back For More
10462          let CLEARFLAG$="+"
10463       loop UNTIL STOPREADING OR FILE(DATAFILE)=10 OR FKEY=99  !Until Eof Or Abort
10464 ! 
10465       if UDIM(MAT BADREAD$) then 
10466          if (2==MSGBOX("There were "&STR$(UDIM(MAT BADREAD$))&" records that couldn't be read with the current file layout. Do you want to see them?","Some records could not be read: Debug?","yN","QST")) then 
10467             open #(BADREADFILE:=FNGETFILENUMBER): "name=@:badread[SESSION].out, recl="&STR$(RLN(DATAFILE))&",replace", display, output 
10468             for INDEX=1 to UDIM(MAT BADREAD$)
10469                let FNPROGRESSBAR(INDEX/UDIM(MAT BADREAD$))
10470                print #BADREADFILE: BADREAD$(INDEX)
10471             next INDEX
10472             close #BADREADFILE: 
10473             let FNCLOSEBAR
10474             execute "system -@ -C -M start "&OS_FILENAME$("@:badread[SESSION].out")
10475          end if 
10476       end if 
10477 ! 
10478       execute "config keyboard clear"
10479       on fkey 34 ignore 
10480 ! 
10481       if ANIMATE then let FNCLOSEANIMATION
10482       let FNPOPULATEGRID=SOMETHINGFOUND
10483    fnend 
10484 ! 
10485 Abortloading: ! Abort the loading of the listview here
10486    let STOPREADING=1
10487    let FKEY(99)
10488    return 
10489 ! 
10490    def FNPASSESFILTER(MAT DC_DATA$,MAT DC_DATA,MAT FILTERCOMPARE$,MAT FILTERVALSUBS,MAT FILTERSUBS,MAT INPUTDATA$,MAT FILTERKEY;___,INDEX,PASSING)
10491       let PASSING=1                   !Give it a fighting chance (in case there are no filters)
10492       do WHILE (INDEX:=INDEX+1)<=UDIM(MAT FILTERSUBS)
10493          if FILTERSUBS(INDEX)>0 then 
10494             if LEN(FILTERCOMPARE$(INDEX)) then 
10495                let PASSING=0
10496                if POS(FILTERCOMPARE$(INDEX),"*") then ! Fuzzy Search
10497                   if FILTERSUBS(INDEX)>UDIM(MAT DC_DATA$) then 
10498                      if LEN(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) AND FNISNUMBER(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) then 
10499                         if POS(STR$(DC_DATA(FILTERSUBS(INDEX)-UDIM(MAT DC_DATA$))),TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) then 
10500 ! .                       ! It passes this filter
10501                            let PASSING=1
10502                         else 
10503 ! .                       ! Failed numeric filter test
10504                         end if 
10505                      else 
10506                         let PASSING=1
10507                      end if 
10508                   else 
10509                      if LEN(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) then 
10510                         if POS(DC_DATA$(FILTERSUBS(INDEX)),TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) then 
10511 ! .                       ! It passes this filter
10512                            let PASSING=1
10513                         else 
10514 ! .                       ! Failed numeric filter test
10515                         end if 
10516                      else 
10517                         let PASSING=1
10518                      end if 
10519                   end if 
10520                end if 
10521                if POS(FILTERCOMPARE$(INDEX),">") then 
10522                   if FILTERSUBS(INDEX)>UDIM(MAT DC_DATA$) then 
10523                      if LEN(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) AND FNISNUMBER(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) then 
10524                         if DC_DATA(FILTERSUBS(INDEX)-UDIM(MAT DC_DATA$))>VAL(INPUTDATA$(FILTERVALSUBS(INDEX))) then 
10525 ! .                       ! It passes this filter
10526                            let PASSING=1
10527                         else 
10528 ! .                       ! Failed numeric filter test
10529                         end if 
10530                      else 
10531                         let PASSING=1
10532                      end if 
10533                   else 
10534                      if LEN(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) then 
10535                         if DC_DATA$(FILTERSUBS(INDEX))>INPUTDATA$(FILTERVALSUBS(INDEX)) then 
10536 ! .                       ! It passes this filter
10537                            let PASSING=1
10538                         else 
10539 ! .                       ! Failed numeric filter test
10540                         end if 
10541                      else 
10542                         let PASSING=1
10543                      end if 
10544                   end if 
10545                end if 
10546                if POS(FILTERCOMPARE$(INDEX),"<") then 
10547                   if FILTERSUBS(INDEX)>UDIM(MAT DC_DATA$) then 
10548                      if LEN(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) AND FNISNUMBER(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) then 
10549                         if DC_DATA(FILTERSUBS(INDEX)-UDIM(MAT DC_DATA$))<VAL(INPUTDATA$(FILTERVALSUBS(INDEX))) then 
10550 ! .                       ! It passes this filter
10551                            let PASSING=1
10552                         else 
10553 ! .                       ! Failed numeric filter test
10554                         end if 
10555                      else 
10556                         let PASSING=1
10557                      end if 
10558                   else 
10559                      if LEN(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) then 
10560                         if DC_DATA$(FILTERSUBS(INDEX))<INPUTDATA$(FILTERVALSUBS(INDEX)) then 
10561 ! .                       ! It passes this filter
10562                            let PASSING=1
10563                         else 
10564 ! .                       ! Failed numeric filter test
10565                         end if 
10566                      else 
10567                         let PASSING=1
10568                      end if 
10569                   end if 
10570                end if 
10571                if POS(FILTERCOMPARE$(INDEX),"=") then 
10572                   if FILTERSUBS(INDEX)>UDIM(MAT DC_DATA$) then 
10573                      if LEN(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) AND FNISNUMBER(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) then 
10574                         if DC_DATA(FILTERSUBS(INDEX)-UDIM(MAT DC_DATA$))=VAL(INPUTDATA$(FILTERVALSUBS(INDEX))) then 
10575 ! .                       ! It passes this filter
10576                            let PASSING=1
10577                         else 
10578 ! .                       ! Failed numeric filter test
10579                         end if 
10580                      else 
10581                         let PASSING=1
10582                      end if 
10583                   else 
10584                      if LEN(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) then 
10585                         if TRIM$(DC_DATA$(FILTERSUBS(INDEX)))=TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX))) then 
10586 ! .                       ! It passes this filter
10587                            let PASSING=1
10588                         else 
10589 ! .                       ! Failed numeric filter test
10590                         end if 
10591                      else 
10592                         let PASSING=1
10593                      end if 
10594                   end if 
10595                end if 
10596             end if 
10597          end if 
10598       loop WHILE PASSING
10599 ! 
10600 ! .  ! Index will be the one it failed on if it failed
10601       if ~PASSING then ! Check filter key and return action
10602          if FILTERKEY(INDEX)=1 then 
10603             let PASSING=INDEX*-1
10604          else if FILTERKEY(INDEX)=-1 then 
10605             let PASSING=2
10606          end if 
10607       end if 
10608 ! 
10609       let FNPASSESFILTER=PASSING
10610    fnend 
10611 ! 
10612    dim GRIDSPEC$*60
10613    dim OUTPUTSPEC$(1)*60
10614    dim OUTPUTDATA$(1)
10615    dim INPUTSPEC$(1)*60
10616    dim INPUTDATA$(1)*255
10617    dim WIDTHS(1)
10618    dim DESCRIPTION$(1)*255
10619    dim COLUMNNAMES$(1)*255
10620 ! 
10621    dim FILTERSUBS(1)
10622    dim FILTERVALSUBS(1)
10623 ! 
10624    dim INCLUDECOLUMNS$(1)*50
10625    dim INCLUDEBUTTONS$(1)
10626    dim FIELDPOSITIONS(1)
10627 ! 
10628    dim LASTREC$*255
10629    dim DISPLAYFIELDCONVERT$*255
10630 ! 
10631    def FNGETDATEWIDTH(IN_FMT$;___,DATEWIDTH)
10632       let DATEWIDTH=LEN(FNDOUBLEDATEDIGITS$(IN_FMT$))
10633       if ~DATEWIDTH then let DATEWIDTH=8  !Default to a reasonable width
10634       let FNGETDATEWIDTH=DATEWIDTH
10635    fnend 
10636 ! 
10637 ! .!--------------------------------------------------
10638 ! .! the purpose of this function is to return a date format where each symbol is doubled up,
10639 ! .! example: accepts mdy, returns mmddyy
10640 ! .! example: accepts cy/m/d, returns CCYY/MM/DD
10641 ! .! this function is useful when calcualting the width of a column for displaying on a listview
10642 ! .! because it's easy to find the width by taking LEN('MM/DD/CCYY')
10643    def FNDOUBLEDATEDIGITS$ (IN_FMT$;___,OUT_FMT$,DELIMITER$)
10644       let IN_FMT$ = UPRC$(TRIM$(IN_FMT$))
10645       for INDEX_=1 to LEN(IN_FMT$)
10646          let DELIMITERPOS = POS('.-/, ',IN_FMT$(INDEX_:INDEX_))
10647          if DELIMITERPOS then 
10648             let DELIMITER$ = IN_FMT$(INDEX_:INDEX_)
10649          end if 
10650       next INDEX_
10651       let OUT_FMT$ = SREP$(SREP$(SREP$(SREP$(SREP$(IN_FMT$,'.','') ,'-',''),'/',''),',',''),' ','')
10652       if OUT_FMT$='MDY' OR OUT_FMT$='MMDDYY' then 
10653          if DELIMITER$<>'' then 
10654             let OUT_FMT$='MM'&DELIMITER$&'DD'&DELIMITER$&'YY'
10655          else 
10656             let OUT_FMT$='MMDDYY'
10657          end if 
10658       else if OUT_FMT$='MCY' OR OUT_FMT$='MMCCYY' then 
10659          if DELIMITER$<>'' then 
10660             let OUT_FMT$='MM'&DELIMITER$&'CCYY'
10661          else 
10662             let OUT_FMT$='MMCCYY'
10663          end if 
10664       else if OUT_FMT$='MDCY' OR OUT_FMT$='MMDDCCYY' then 
10665          if DELIMITER$<>'' then 
10666             let OUT_FMT$='MM'&DELIMITER$&'DD'&DELIMITER$&'CCYY'
10667          else 
10668             let OUT_FMT$='MMDDCCYY'
10669          end if 
10670       else if OUT_FMT$='DMCY' OR OUT_FMT$='DDMMCCYY' then 
10671          if DELIMITER$<>'' then 
10672             let OUT_FMT$='DD'&DELIMITER$&'MM'&DELIMITER$&'CCYY'
10673          else 
10674             let OUT_FMT$='DDMMCCYY'
10675          end if 
10676       else if OUT_FMT$='CYMD' OR OUT_FMT$='CCYYMMDD' then 
10677          if DELIMITER$<>'' then 
10678             let OUT_FMT$='CCYY'&DELIMITER$&'MM'&DELIMITER$&'DD'
10679          else 
10680             let OUT_FMT$='CCYYMMDD'
10681          end if 
10682       else 
10683          let OUT_FMT$=''              !explicitly clear if format not recognized
10684       end if 
10685       let FNDOUBLEDATEDIGITS$ = OUT_FMT$
10686    fnend 
10687 ! .!--------------------------------------------------
10688    def library FNSHOWDATA(FILELAY$*128;EDIT,SROW,SCOL,ROWS,COLS,KEYNUMBER,CAPTION$*127,PATH$*255,KEYMATCH$*255,SEARCHMATCH$*255,CALLINGPROGRAM$*255,MAT RECORDS,MAT INCLUDECOLS$,MAT INCLUDEUI$,MAT COLUMNDESCRIPTION$,MAT COLUMNWIDTHS,MAT COLUMNFORMS$,DISPLAYFIELD$*80,MAT FILTERFIELDS$,MAT FILTERFORM$,MAT FILTERCOMPARE$,MAT FILTERCAPTION$,MAT FILTERDEFAULTS$,MAT FILTERKEY,INCLUDERECORDNUMBERS,BYPASSDATEPROCESSING,___,WINDOW,INDEX,X$,KEY,KEY$,ROWCOUNT,SHOULDSAVE,SAVEINDEX,SAVELOOP,SAVERECORDSUB,RECORDSIZE,DELETEINDEX,REBUILDCOLOR,CHANGEDROWCOUNT,OLDCHANGEDDATASIZE,OLDCHANGEDSUBSSIZE,SOMETHINGFOUND,LOGGING,ANIMATE,INPUTFLAG,SUB,INCLUDECOL,TESTCONVERT,RECORDNUM,O_POSITION,DISPLAYSUB,SEARCHSUB,ALREADYWARNED,MERGEINDEX,MERGEFOUND,MERGEFROMSTART,MERGEFROMEND,MERGETOSTART,MERGETOEND)
10689       library : FNGETFILENUMBER, FNOPENFILE, FNCLOSEFILE, FNREADLAYOUTARRAYS, FNBUILDKEY$, FNSETLOGCHANGES, FNLOGCHANGES, FNLOG, FNLOGARRAY, FNPROGRESSBAR, FNCLOSEBAR, FNSELECTDATACRAWLERCOLS
10690       mat FILTERSUBS(0)
10691       mat FILTERVALSUBS(0)
10692 ! 
10693       if CALLINGPROGRAM$="" then let CALLINGPROGRAM$="FileIO's fnShowData"
10694       let LOGGING=FNSETTINGS("createlogfile")
10695 ! 
10696       if LOGGING then 
10697          if EDIT then 
10698             let FNLOG("Edit "&TRIM$(FILELAY$)&" file.",CALLINGPROGRAM$)
10699          else 
10700             let FNLOG("View "&TRIM$(FILELAY$)&" file.",CALLINGPROGRAM$)
10701          end if 
10702       end if 
10703 ! 
10704 ! .  ! Make copies of any optional arrays we need to change
10705 ! .  ! in case they aren't given and we can't change the original
10706       mat INCLUDECOLUMNS$(UDIM(MAT INCLUDECOLS$))=INCLUDECOLS$
10707       mat INCLUDEBUTTONS$(UDIM(MAT INCLUDEUI$))=INCLUDEUI$
10708       let SEARCHNOW$=""
10709 ! 
10710       if ~KEYNUMBER then let KEYNUMBER=-1  !Default to Relative for preformance
10711       if EDIT AND ~FN42 then let KEYNUMBER=1  !Must open keyed due to bug in 4.1 and earlier
10712 ! 
10713       let DATAFILE=FNOPEN(FILELAY$,MAT DC_DATA$,MAT DC_DATA,MAT DC_FORMS$,(~EDIT),KEYNUMBER,0,PATH$,MAT DC_DFDESCR$,MAT DC_WIDTHS,0,0,0,MAT DC_DATEFORMATS$)
10714 ! 
10715       if DATAFILE then 
10716 ! 
10717 ! .     ! Return field names to be used later when populating grid
10718          let FNGETFIELDNAMES(FILELAY$,MAT COLUMNNAMES$,MAT FIELDPOSITIONS)
10719 ! 
10720          let FNLWRCTHIS(MAT INCLUDECOLUMNS$)
10721          let FNLWRCTHIS(MAT INCLUDECOLS$)
10722          let FNLWRCTHIS(MAT COLUMNNAMES$)
10723 ! 
10724          let FNPREPAREWINDOW(SROW,SCOL,ROWS,COLS,EDIT,MAT INCLUDEBUTTONS$,CAPTION$,GRIDSPEC$,MAT INPUTSPEC$,MAT OUTPUTSPEC$,MAT INPUTDATA$,MAT OUTPUTDATA$,O_POSITION,MAT FILTERFIELDS$,MAT FILTERFORM$,MAT FILTERCOMPARE$,MAT FILTERCAPTION$,MAT FILTERDEFAULTS$,MAT FILTERSUBS,MAT FILTERVALSUBS,MAT COLUMNNAMES$,MAT FILTERKEY,SEARCHSUB)
10725 ! 
10726          open #(WINDOW:=FNGETFILENUMBER) : "sRow="&STR$(SROW)&",sCol="&STR$(SCOL)&",Rows="&STR$(ROWS)&",Cols="&STR$(COLS)&",Caption="&CAPTION$,display,outin 
10727 ! 
10728          print #WINDOW, fields MAT OUTPUTSPEC$ : MAT OUTPUTDATA$
10729 ! 
10730          let DATEDISPLAYFORMAT$ = FNSETTINGS$("dateformatdisplay")
10731 ! 
10732          do                           !Whole Thing
10733 ! 
10734             let LASTREC$=DISPLAYFIELD$
10735             if LEN(DISPLAYFIELD$) then 
10736                if LWRC$(DISPLAYFIELD$)="rec" then 
10737                   let LASTREC$=STR$(LREC(DATAFILE))
10738                   let DISPLAYSUB=-1
10739                else if LWRC$(DISPLAYFIELD$)="count" OR LWRC$(DISPLAYFIELD$)="readcount" then 
10740                   let LASTREC$=STR$(LREC(DATAFILE))
10741                   let DISPLAYSUB=-2
10742                else if LWRC$(DISPLAYFIELD$)="findcount" then 
10743                   let DISPLAYSUB=-3
10744                else 
10745                   if (SUB:=SRCH(MAT COLUMNNAMES$,LWRC$(TRIM$(DISPLAYFIELD$))))>0 then 
10746                      let DISPLAYSUB=SUB
10747                   end if 
10748                end if 
10749             end if 
10750 ! 
10751             let FNCALCULATEFIELDFORMS(FILELAY$,MAT COLUMNNAMES$,MAT FIELDFORMS$,MAT WIDTHS,MAT DESCRIPTION$,MAT DC_WIDTHS,MAT DC_DFDESCR$,MAT DC_DATEFORMATS$,MAT INCLUDECOLUMNS$,MAT INCLUDECOLS$,MAT COLUMNDESCRIPTION$,MAT COLUMNWIDTHS,MAT COLUMNFORMS$,MAT FIELDPOSITIONS,O_POSITION,DISPLAYSUB,DISPLAYFIELDCONVERT$,DATEDISPLAYFORMAT$,BYPASSDATEPROCESSING)
10752 ! 
10753             if DISPLAYSUB>0 then 
10754 ! 
10755                read #DATAFILE, using DC_FORMS$(DATAFILE), LAST : MAT DC_DATA$, MAT DC_DATA error IGNORE
10756 ! 
10757                if FILE(DATAFILE)=0 then 
10758 ! 
10759                   if DISPLAYSUB>UDIM(MAT DC_DATA$) then 
10760                      if DISPLAYSUB<=UDIM(MAT DC_DATA$)+UDIM(MAT DC_DATA) then 
10761                         if ~LEN(DISPLAYFIELDCONVERT$) then 
10762                            let LASTREC$=STR$(DC_DATA(DISPLAYSUB-UDIM(MAT DC_DATA$)))
10763                         else 
10764                            let LASTREC$=CNVRT$(DISPLAYFIELDCONVERT$,DC_DATA(DISPLAYSUB-UDIM(MAT DC_DATA$))) conv IGNORE
10765                         end if 
10766                      end if 
10767                   else 
10768                      let LASTREC$=DC_DATA$(DISPLAYSUB)
10769                   end if 
10770                end if 
10771             end if 
10772 ! 
10773             if INCLUDERECORDNUMBERS then 
10774                mat WIDTHS(UDIM(MAT WIDTHS)+1)
10775                mat DESCRIPTION$(UDIM(MAT DESCRIPTION$)+1)
10776                mat FIELDFORMS$(UDIM(MAT FIELDFORMS$)+1)
10777                for INDEX=UDIM(MAT WIDTHS) to 2 step -1
10778                   let WIDTHS(INDEX)=WIDTHS(INDEX-1)
10779                   let DESCRIPTION$(INDEX)=DESCRIPTION$(INDEX-1)
10780                   let FIELDFORMS$(INDEX)=FIELDFORMS$(INDEX-1)
10781                next INDEX
10782                let WIDTHS(1)=5
10783                let DESCRIPTION$(1)="Rec"
10784                let FIELDFORMS$(1)="N 16"
10785             end if 
10786 ! 
10787             let RECORDSIZE=UDIM(MAT WIDTHS)
10788             let COLSCHANGED=0
10789             mat DC_BLANK$(RECORDSIZE)
10790             print #WINDOW, fields GRIDSPEC$&",HEADERS,/W:W" : (MAT DESCRIPTION$,MAT WIDTHS,MAT FIELDFORMS$)
10791 ! 
10792             let CHANGEDROWCOUNT=0 : mat DC_CHANGEDDATA$(0) : mat DC_CHANGEDSUBS(0)
10793 ! 
10794             restore #DATAFILE: 
10795             if KLN(DATAFILE)>0 AND TRIM$(KEY$)<>"" then 
10796                restore #DATAFILE, search>=TRIM$(KEY$): nokey Clearkey
10797             end if 
10798             if RECORDNUM then 
10799                restore #DATAFILE, rec=RECORDNUM: norec Clearrec
10800             end if 
10801 ! 
10802             let SOMETHINGFOUND=FNPOPULATEGRID(WINDOW,GRIDSPEC$,FILELAY$,KEYMATCH$,SEARCHMATCH$,MAT RECORDS,MAT INCLUDECOLUMNS$,MAT COLUMNNAMES$,RECORDSIZE,DATAFILE,MAT DC_DATA$,MAT DC_DATA,MAT DC_FORMS$,SEARCHNOW$,MAT DC_RECORDS,MAT DC_DELETEROW,KEYNUMBER,LASTREC$,DISPLAYSUB,DISPLAYFIELDCONVERT$,MAT FILTERCOMPARE$,MAT FILTERSUBS,MAT FILTERVALSUBS,MAT FILTERKEY,MAT INPUTDATA$,INCLUDERECORDNUMBERS,MAT DC_DATEFORMATS$,DATEDISPLAYFORMAT$,BYPASSDATEPROCESSING)
10803             let ALREADYWARNED=0
10804 ! 
10805             print #WINDOW, fields MAT INPUTSPEC$(1:UDIM(MAT INPUTSPEC$)-1) : MAT INPUTDATA$
10806 ! 
10807             do                        !Input Data
10808                if REBUILDCOLOR then gosub Updatecolors
10809                if SOMETHINGFOUND then 
10810                   if UDIM(MAT INPUTDATA$) then 
10811                      input #WINDOW, fields MAT INPUTSPEC$ : MAT INPUTDATA$, ROWCOUNT
10812                   else 
10813                      input #WINDOW, fields MAT INPUTSPEC$ : ROWCOUNT
10814                   end if 
10815                   let KEY=FKEY
10816                   if KEY=54 then let KEY=99
10817                else 
10818                   if EDIT AND (2==MSGBOX("There is no data in the file, or no records match the current search criteria. Would you like to add a row?","File Empty","YN","EXCL")) then 
10819                      let KEY=15       !Add A Row
10820                      let SOMETHINGFOUND=1
10821                   else 
10822                      if ~ALREADYWARNED then let MSGBOX("Data File is Empty or no records match the current search criteria.","File Empty") : let ALREADYWARNED=1
10823                      if UDIM(MAT INPUTDATA$) then 
10824                         input #WINDOW, fields MAT INPUTSPEC$(1:UDIM(MAT INPUTSPEC$)-1) : MAT INPUTDATA$
10825                         let KEY=FKEY
10826                         if KEY=54 then let KEY=99
10827                      else 
10828                         let KEY=99
10829                      end if 
10830                   end if 
10831                end if 
10832                let SHOULDSAVE=0
10833 ! 
10834                if KEY = 15 AND EDIT then ! #Select# Key #Case# 15 and Edit
10835                   gosub Mergenewchanges  !Get any additional changes since the last time
10836 ! 
10837                   print #WINDOW, fields GRIDSPEC$&",+" : MAT DC_BLANK$  !Add A Blank Row
10838                   mat DC_RECORDS(UDIM(MAT DC_RECORDS)+1)
10839                   mat DC_DELETEROW(UDIM(MAT DC_RECORDS))
10840                   let CURFLD(1,((UDIM(MAT DC_RECORDS)-1)*RECORDSIZE) + 1)
10841 ! 
10842                else if KEY = 16 AND EDIT then ! #Case# 16 and Edit
10843                   let DC_DELETEROW(CURROW)=DC_DELETEROW(CURROW)+1  !Toggle Deleted
10844                   let REBUILDCOLOR = 1
10845 ! 
10846                else if KEY = 55 then ! #Case# 55
10847                   if CHANGEDROWCOUNT OR (EDIT AND ROWCOUNT) OR SUM(MAT DC_DELETEROW) then let NEEDSSAVE=1 else let NEEDSSAVE=0
10848                   let COLSCHANGED=FNSELECTDATACRAWLERCOLS(MAT DC_DFDESCR$,MAT INCLUDECOLUMNS$,MAT COLUMNNAMES$,ROWS,COLS,NEEDSSAVE,0,FILELAY$)
10849                   if COLSCHANGED = 2 then let SHOULDSAVE = 2
10850 ! 
10851                else if KEY = 56 then ! #Case# 56
10852                   let FNCSV_EXPORT(FILELAY$,KEYNUMBER,KEY$,RECORDNUM,MAT RECORDS,SEARCHMATCH$,KEYMATCH$,SEARCHNOW$)
10853                else if KEY = 57 AND EDIT then ! #Case# 57 and Edit
10854                   let FNCSV_IMPORT(FILELAY$)
10855 ! 
10856                else if KEY = 4 OR KEY = 99 OR KEY = 93 OR KEY = 70 then ! #Case# 4 # 99 # 93 # 70
10857                   if EDIT AND (CHANGEDROWCOUNT OR ROWCOUNT OR SUM(MAT DC_DELETEROW)) then 
10858                      let SHOULDSAVE=MSGBOX("All unsaved changes will be lost. Do you want to Save first?","Search Warning","YNC","EXCL")
10859                   end if 
10860                end if                 !#End Select#
10861             loop UNTIL ((KEY=99 OR KEY=93 OR KEY=4 OR KEY=70) AND SHOULDSAVE<>4) OR KEY=5 OR KEY=57 OR (KEY=55 AND COLSCHANGED)  !F4 Changes Settings, F5 Saves Settings, 70 is Search, needs to redraw
10862 ! 
10863             if EDIT AND (KEY=5 OR SHOULDSAVE=2) then gosub Savechangeddata
10864 ! 
10865             if KEY=4 then let FNINPUTKEY(KEY$,RECORDNUM,DATAFILE,ROWS,COLS,WINDOW)
10866 ! 
10867             if KEY=70 then 
10868                let SEARCHNOW$=TRIM$(INPUTDATA$(SEARCHSUB))  !If there's a search box, its always first cause the grids always last so this should work but it would be better to use a subscript.
10869 ! .           ! let InputData$(SearchSub)=""
10870             end if 
10871 ! 
10872          loop UNTIL KEY=99 OR KEY=93 OR FKEY=93
10873 ! 
10874          if EDIT then let INPUTFLAG=1 else let INPUTFLAG=-1
10875          let FNCLOSEFILE(DATAFILE,FILELAY$,PATH$,INPUTFLAG)
10876          if LOGGING then let FNLOG("Close "&TRIM$(FILELAY$)&" file.",CALLINGPROGRAM$)
10877       end if 
10878       close #WINDOW: 
10879    fnend 
10880 ! 
10881 Clearkey: ! Invalid Key Entered
10882    let MSGBOX("Key Not Found")
10883    let KEY$=""
10884    continue 
10885 ! 
10886 Clearrec: ! Invalid Record Entered
10887    let MSGBOX("Record not found")
10888    let RECORDNUM=0
10889    continue 
10890 ! 
10891 Tryagain: ! Try Again
10892    if FKEY=99 OR FKEY=93 then 
10893       continue 
10894    else 
10895       retry 
10896    end if 
10897 ! 
10898 Deconversionfailed: ! Conversion Failed Saving Numeric Field
10899    let TESTCONVERT=DC_DATA(SUB-UDIM(MAT DC_DATA$))  !Keep Existing Value, New Value Failed
10900    continue 
10901 ! 
10902 Mergenewchanges: ! Save new changes into the Changed Subs and Data arrays
10903    if ROWCOUNT then ! If There Are Already Changes Made, Save Them To Backup Arrays
10904       mat DC_SAVEDATA$(RECORDSIZE*ROWCOUNT)  !Make Room
10905       mat DC_SAVESUBS(ROWCOUNT)       !Make Room
10906       input #WINDOW, fields GRIDSPEC$&",ROWSUB,CHG,NOWAIT" : MAT DC_SAVESUBS
10907       input #WINDOW, fields GRIDSPEC$&",ROW,CHG,NOWAIT" : MAT DC_SAVEDATA$
10908 ! 
10909       let SAVERECORDSIZE=RECORDSIZE-INCLUDERECORDNUMBERS
10910 ! 
10911       for MERGEINDEX=1 to UDIM(MAT DC_SAVESUBS)
10912          let MERGEFROMSTART=((MERGEINDEX-1)*RECORDSIZE)+1+INCLUDERECORDNUMBERS
10913          let MERGEFROMEND=MERGEINDEX*RECORDSIZE
10914 ! 
10915          let MERGEFOUND=SRCH(MAT DC_CHANGEDSUBS,DC_SAVESUBS(MERGEINDEX))
10916          if MERGEFOUND>0 then 
10917 ! .        ! Find the Data to Update
10918             let MERGETOSTART=((MERGEFOUND-1)*SAVERECORDSIZE)+1
10919             let MERGETOEND=MERGEFOUND*SAVERECORDSIZE
10920          else 
10921 ! .        ! Add Rows to Update
10922             let MERGETOSTART=UDIM(MAT DC_CHANGEDDATA$)+1
10923             let MERGETOEND=UDIM(MAT DC_CHANGEDDATA$)+SAVERECORDSIZE
10924 ! 
10925             let MERGEFOUND=UDIM(MAT DC_CHANGEDSUBS)+1
10926 ! 
10927             mat DC_CHANGEDDATA$(MERGETOEND)
10928             mat DC_CHANGEDSUBS(MERGEFOUND)
10929          end if 
10930 ! 
10931 ! .     ! Merge It
10932          mat DC_CHANGEDDATA$(MERGETOSTART:MERGETOEND)=DC_SAVEDATA$(MERGEFROMSTART:MERGEFROMEND)
10933          let DC_CHANGEDSUBS(MERGEFOUND)=DC_SAVESUBS(MERGEINDEX)
10934       next MERGEINDEX
10935 ! 
10936       let CHANGEDROWCOUNT=UDIM(MAT DC_CHANGEDSUBS)
10937    end if 
10938    return 
10939 ! 
10940    dim SAVEMESSAGE$*255,UPDATECOUNT,ADDCOUNT,DELETECOUNT
10941 Savechangeddata: ! Save all the changed records in the data crawler
10942    let SAVEMESSAGE$="" : let UPDATECOUNT=0 : let ADDCOUNT=0 : let DELETECOUNT=0
10943 ! 
10944    gosub Mergenewchanges              !Get any additional changes since the last time
10945    let SAVERECORDSIZE=RECORDSIZE-INCLUDERECORDNUMBERS
10946 ! 
10947    if (~FNISEMPTYS(MAT INCLUDECOLUMNS$)) then let INCLUDECOL=1
10948 ! .! Save Prerecorded Changes
10949    for SAVELOOP = 1 to CHANGEDROWCOUNT
10950       let SAVERECORDSUB=((SAVELOOP-1)*SAVERECORDSIZE)
10951       if DC_DELETEROW(DC_CHANGEDSUBS(SAVELOOP))=0 then ! Skip It If Its Deleted
10952          mat DC_DATA$=("") : mat DC_DATA=(0)
10953          if DC_RECORDS(DC_CHANGEDSUBS(SAVELOOP)) then 
10954             read #DATAFILE, using DC_FORMS$(DATAFILE), rec=DC_RECORDS(DC_CHANGEDSUBS(SAVELOOP)) : MAT DC_DATA$, MAT DC_DATA
10955             if LOGGING then let FNSETLOGCHANGES(MAT DC_DATA$,MAT DC_DATA)
10956          end if 
10957 ! 
10958 !        Convert Strings Back To Numbers And Assign Back To File Arrays
10959          for SAVEINDEX=1 to SAVERECORDSIZE
10960             if INCLUDECOL then 
10961                let SUB=SRCH(MAT COLUMNNAMES$,INCLUDECOLUMNS$(SAVEINDEX))
10962             else 
10963                let SUB=SAVEINDEX
10964             end if 
10965             if SUB>UDIM(MAT DC_DATA$) then 
10966                let TESTCONVERT=VAL(FNFMTSDATE$(DC_CHANGEDDATA$(SAVERECORDSUB+SAVEINDEX),"DATE(JULIAN)",DC_DATEFORMATS$(SUB),BYPASSDATEPROCESSING)) conv Deconversionfailed
10967                let DC_DATA(SUB-UDIM(MAT DC_DATA$))=TESTCONVERT
10968             else if SUB>0 then 
10969                let DC_DATA$(SUB)=FNFMTSDATE$(DC_CHANGEDDATA$(SAVERECORDSUB+SAVEINDEX),"DATE(JULIAN)",DC_DATEFORMATS$(SUB),BYPASSDATEPROCESSING)
10970             end if 
10971          next SAVEINDEX
10972 ! 
10973 !        Save The Data
10974          if DC_RECORDS(DC_CHANGEDSUBS(SAVELOOP)) then 
10975             rewrite #DATAFILE, using DC_FORMS$(DATAFILE) : MAT DC_DATA$, MAT DC_DATA
10976             if LOGGING then let FNLOGCHANGES(MAT DC_DATA$,MAT DC_DATA,"Update """&FILELAY$&""" Record: "&STR$(REC(DATAFILE)),CALLINGPROGRAM$,FILELAY$)
10977             let UPDATECOUNT+=1
10978          else 
10979             write #DATAFILE, using DC_FORMS$(DATAFILE) : MAT DC_DATA$, MAT DC_DATA
10980             if LOGGING then let FNLOGARRAY(MAT DC_DATA$,MAT DC_DATA,"Write """&FILELAY$&""" Record: "&STR$(REC(DATAFILE))&" Data: ",CALLINGPROGRAM$)
10981             let ADDCOUNT+=1
10982          end if 
10983       end if 
10984    next SAVELOOP
10985 ! 
10986 ! .! Delete the records that need to be deleted
10987    for DELETEINDEX=1 to UDIM(MAT DC_DELETEROW)
10988       if DC_DELETEROW(DELETEINDEX) then 
10989          if DC_RECORDS(DELETEINDEX) then 
10990             delete #DATAFILE, rec=DC_RECORDS(DELETEINDEX): 
10991             if LOGGING then let FNLOG("Delete """&FILELAY$&""" Record: "&STR$(DC_RECORDS(DELETEINDEX)),CALLINGPROGRAM$)
10992             let DELETECOUNT+=1
10993          end if 
10994          let DC_DELETEROW(DELETEINDEX)=2  !Clear Them To White Next Round
10995       end if 
10996    next DELETEINDEX
10997    if EDIT then gosub Updatecolors
10998    let CRLF$=HEX$("0D0A")
10999    let MSGBOX("Update Complete!"&CRLF$&CRLF$&STR$(ADDCOUNT)&" records Added"&CRLF$&STR$(UPDATECOUNT)&" records Updated"&CRLF$&STR$(DELETECOUNT)&" records Deleted","Update")
11000    return 
11001 ! 
11002 !  Save New Changes
11003 !   mat dc_Savedata$(Recordsize*Rowcount) ! Make Room
11004 !   mat dc_Savesubs(Rowcount)             ! Make Room
11005 !   input #Window, fields GridSpec$&",ROWSUB,CHG,NOWAIT" : Mat dc_Savesubs
11006 !   input #Window, fields GridSpec$&",ROW,CHG,NOWAIT" : Mat dc_Savedata$
11007 ! 
11008 !  One Record At A Time
11009 !   for Saveloop = 1 to Rowcount
11010 !      let Saverecordsub=((Saveloop-1)*Recordsize)
11011 !      if dc_Deleterow(dc_Savesubs(Saveloop))=0 then ! Skip It If Its Deleted
11012 !         mat dc_Data$=("") : mat Dc_Data=(0)
11013 !         if dc_Records(dc_Savesubs(Saveloop)) then
11014 !            read #datafile, using Dc_Forms$(datafile), rec=dc_Records(dc_Savesubs(Saveloop)) : Mat dc_Data$, Mat dc_Data
11015 !            if Logging then let fnSetLogChanges(mat dc_Data$,mat dc_Data)
11016 !         end if
11017 ! 
11018 !         for SaveIndex=1 to RecordSize
11019 !            if IncludeCol then
11020 !               let Sub=srch(mat ColumnNames$,IncludeColumns$(SaveIndex))
11021 !            else 
11022 !               let Sub=SaveIndex
11023 !            end if
11024 ! 
11025 !            if Sub>udim(mat dc_data$) then
11026 !               let TestConvert=val(dc_Savedata$(SaveRecordSub+saveindex)) conv DeConversionFailed
11027 !               let dc_data(sub-udim(mat Dc_data$))=TestConvert
11028 !            else if Sub>0 then
11029 !               let dc_data$(sub)=dc_Savedata$(SaveRecordSub+SaveIndex)
11030 !            end if
11031 !         next SaveIndex
11032 ! 
11033 !        Save The Data
11034 !         if dc_Records(dc_Savesubs(Saveloop)) then
11035 !            rewrite #datafile, using Dc_Forms$(datafile) : Mat dc_Data$, Mat dc_Data
11036 !            if Logging then let fnLogChanges(mat dc_Data$,mat dc_Data,"Update """&FileLay$&""" Record: "&str$(rec(datafile)),CallingProgram$,FileLay$)
11037 !         else 
11038 !            write #datafile, using Dc_Forms$(datafile) : Mat dc_Data$, Mat dc_Data
11039 !            if Logging then let fnLogArray(Mat dc_Data$,mat dc_Data,"Write """&FileLay$&""" Record: "&str$(rec(datafile))&" Data: ",CallingProgram$)
11040 !         end if
11041 !      end if
11042 !   next Saveloop
11043 ! 
11044 ! 
11045 Selectdatacrawlercols: ! **** Open Window to Select Display Columns for Data Crawler ****
11046    def library FNSELECTDATACRAWLERCOLS(MAT FIELD_DESC$,MAT INCLUDECOLUMNS$,MAT COLUMNNAMES$,ROWS,COLS;NEEDSSAVE,EXPORT,FILELAY$*128,___,VERB$,SROW,SCOL,SCREENROWS,SCREENCOLS,ROW,COL,FK,CLOSEWINDOW,SHOULDSAVE,ITEMSPERPAGE,INDEX,JNDEX,COLUMNSNOTPASSED)
11047       library : FNGETFILENUMBER
11048 ! 
11049       dim INPUT_SPEC$(1)*255,INPUT_DATA$(1)*1000
11050       if EXPORT then let VERB$="export" else let VERB$="display"
11051 ! 
11052       let FNREADSCREENS(SCREENROWS,SCREENCOLS)
11053 ! 
11054 ! .  ! Grow to minimum reasonable size
11055       let ROWS=MAX(ROWS,8)
11056       let COLS=MAX(COLS,48)
11057 ! 
11058       let ROWS=MIN(SCREENROWS,ROWS)
11059       let COLS=MIN(SCREENCOLS,COLS)
11060 ! 
11061       mat INPUT_SPEC$(UDIM(MAT FIELD_DESC$))
11062       mat INPUT_DATA$(UDIM(MAT FIELD_DESC$))
11063 ! 
11064 ! .  ! Open main window
11065       let SROW=INT((SCREENROWS-ROWS) / 2) + 1
11066       let SCOL=INT((SCREENCOLS-COLS) / 2) + 1
11067 ! 
11068       open #(COLSEL_WINDOW:=FNGETFILENUMBER): "SROW="&STR$(SROW)&", SCOL="&STR$(SCOL)&", ROWS="&STR$(ROWS)&", COLS="&STR$(COLS),display,outin 
11069       if EXPORT then 
11070          print #COLSEL_WINDOW, fields STR$(ROWS)&","&STR$(COLS-10)&",CC 10,/W:W,B55" : "OK"
11071       else 
11072          print #COLSEL_WINDOW, fields STR$(ROWS)&","&STR$(COLS-22)&",CC 10,/W:W,B55" : "OK"
11073          print #COLSEL_WINDOW, fields STR$(ROWS)&","&STR$(COLS-10)&",CC 10,/W:W,B54" : "Cancel"
11074       end if 
11075       print #COLSEL_WINDOW, fields STR$(ROWS)&","&STR$(COLS-34)&",CC 10,/W:W,B56" : "Select All"
11076       print #COLSEL_WINDOW, fields STR$(ROWS)&","&STR$(COLS-46)&",10/CC 11,/W:W,B57" : "Select None"
11077       if COLS>60 then 
11078          print #COLSEL_WINDOW, fields STR$(ROWS)&",2,"&STR$(COLS-49)&"/C 55" : "Choose data columns to "&VERB$
11079       end if 
11080 ! 
11081       dim COLSEL_TABS(1)
11082       dim TABATTR$*50
11083 ! 
11084       if FNISEMPTYS(MAT INCLUDECOLUMNS$) AND LEN(FILELAY$) then 
11085          let COLUMNSNOTPASSED=1
11086          let FNREADLASTCOLUMNSUSED(MAT INCLUDECOLUMNS$,FILELAY$)
11087       end if 
11088 ! 
11089       let ITEMSPERPAGE=(ROWS-4)*INT(COLS/19)
11090 ! 
11091       let ROW = 2
11092       let COL = 2
11093       let THISTAB = 0
11094       for INDEX = 1 to UDIM(MAT INPUT_SPEC$)
11095          if ROW = 2 AND COL = 2 then ! Open a child window
11096             let THISTAB+=1
11097             mat COLSEL_TABS(THISTAB)
11098             if UDIM(MAT INPUT_SPEC$) > ITEMSPERPAGE then let TABATTR$=", TAB=Page "&STR$(THISTAB) else let TABATTR$=", BORDER=S, CAPTION=Column List"
11099             open #(COLSEL_TABS(THISTAB):=FNGETFILENUMBER): "SROW=2, SCOL=2, ROWS="&STR$(ROWS-3)&", COLS="&STR$(COLS-2)&TABATTR$&", PARENT="&STR$(COLSEL_WINDOW),display,outin 
11100          end if 
11101 ! 
11102          let INPUT_SPEC$(INDEX)=STR$(ROW)&","&STR$(COL)&",18/check 1000,,"&STR$(1500+INDEX)
11103          let INPUT_DATA$(INDEX)=FIELD_DESC$(MOD(INDEX-1,UDIM(MAT FIELD_DESC$))+1)
11104 ! 
11105          if FNISEMPTYS(MAT INCLUDECOLUMNS$) OR SRCH(MAT INCLUDECOLUMNS$,COLUMNNAMES$(INDEX))>0 then 
11106             let INPUT_DATA$(INDEX) = "^"&INPUT_DATA$(INDEX)
11107          end if 
11108 ! 
11109          let ROW+=1
11110          if ROW > ROWS-3 AND COL+18+19 > COLS then 
11111             let ROW = 2
11112             let COL = 2
11113          else if ROW > ROWS-3 then 
11114             let COL +=19
11115             let ROW = 2
11116          end if 
11117       next INDEX
11118 ! 
11119       do 
11120          do 
11121             let THISTAB = CURTAB(COLSEL_TABS(1))
11122             for TABINDEX = 1 to UDIM(COLSEL_TABS)
11123                if COLSEL_TABS(TABINDEX) = THISTAB then let CURRENTTABINDEX=TABINDEX
11124             next TABINDEX
11125             let STARTCOL = 1 + (CURRENTTABINDEX - 1) * ITEMSPERPAGE
11126             let ENDCOL = MIN(CURRENTTABINDEX * ITEMSPERPAGE, UDIM(INPUT_SPEC$))
11127             rinput #THISTAB, fields MAT INPUT_SPEC$(STARTCOL:ENDCOL) : MAT INPUT_DATA$(STARTCOL:ENDCOL)
11128             let FK=FKEY
11129 ! 
11130             if FK=56 then ! Select All
11131                for INDEX=1 to UDIM(MAT INPUT_DATA$)
11132                   let INPUT_DATA$(INDEX)=TRIM$(INPUT_DATA$(INDEX))
11133                   if INPUT_DATA$(INDEX)(1:1)<>"^" then 
11134                      let INPUT_DATA$(INDEX)(999:1000)=""
11135                      let INPUT_DATA$(INDEX)(1:0)="^"
11136                   end if 
11137                next INDEX
11138             else if FK=57 then ! Select None
11139                for INDEX=1 to UDIM(MAT INPUT_DATA$)
11140                   if INPUT_DATA$(INDEX)(1:1)="^" then 
11141                      let INPUT_DATA$(INDEX)(1:1)=""
11142                   end if 
11143                next INDEX
11144             end if 
11145          loop UNTIL FK=0 OR FK=99 OR FK=93 OR FK=54 OR FK=55  !0,55: OK; 99,93,54: Cancel
11146 ! 
11147          let CLOSEWINDOW=1
11148          if FK=0 OR FK=55 then 
11149             if NEEDSSAVE then 
11150                let SHOULDSAVE=MSGBOX("All unsaved changes will be lost. Do you want to Save first?","Search Warning","YNC","EXCL")
11151                if SHOULDSAVE=2 then let FNSELECTDATACRAWLERCOLS=2
11152                if SHOULDSAVE=3 then let FNSELECTDATACRAWLERCOLS=1
11153                if SHOULDSAVE=4 then let CLOSEWINDOW=0
11154             else 
11155                let FNSELECTDATACRAWLERCOLS=1
11156             end if 
11157             if CLOSEWINDOW then 
11158                mat INCLUDECOLUMNS$(0)
11159                for INDEX = 1 to UDIM(INPUT_DATA$)
11160                   if INPUT_DATA$(INDEX)(1:1)="^" then 
11161                      let JNDEX=UDIM(MAT INCLUDECOLUMNS$)+1
11162                      mat INCLUDECOLUMNS$(JNDEX)
11163                      let INCLUDECOLUMNS$(JNDEX)=COLUMNNAMES$(INDEX)
11164                   end if 
11165                next INDEX
11166                if UDIM(MAT INCLUDECOLUMNS$)=UDIM(MAT INPUT_DATA$) then 
11167                   mat INCLUDECOLUMNS$(0)
11168                end if 
11169             end if 
11170          else 
11171             let FNSELECTDATACRAWLERCOLS=0
11172          end if 
11173       loop UNTIL CLOSEWINDOW
11174 ! 
11175       for THISTAB = 1 to UDIM(COLSEL_TABS)
11176          close #(COLSEL_TABS(THISTAB)): 
11177       next THISTAB
11178 ! 
11179       close #COLSEL_WINDOW: 
11180 ! 
11181       if COLUMNSNOTPASSED then 
11182          let FNSAVELASTCOLUMNSUSED(MAT INCLUDECOLUMNS$,FILELAY$)
11183       end if 
11184 ! 
11185    fnend 
11186 ! 
11187    def FNREADLASTCOLUMNSUSED(MAT INCLUDECOLUMNS$,FILELAY$*64;___,SAVESELECTEDCOLS$*64,FILENAME$*68,KEYFILE$*68,COLSFILE,NUMOFCOLS)
11188       let SAVESELECTEDCOLS$=FNSETTINGS$("saveselectedcols")
11189       let FILENAME$=SAVESELECTEDCOLS$&".dat"
11190       let KEYFILE$=SAVESELECTEDCOLS$&".key"
11191 ! 
11192       if EXISTS(FILENAME$) AND EXISTS(KEYFILE$) then 
11193          open #(COLSFILE:=FNGETFILENUMBER): "name="&FILENAME$&", kfname="&KEYFILE$&", recl=10000, kps=1, kln=18, use",internal, outin, keyed 
11194          read #COLSFILE, key=RPAD$(FILELAY$(1:18),18) : FILELAY$,NUMOFCOLS nokey Rlcu_Failed
11195          mat INCLUDECOLUMNS$(NUMOFCOLS)
11196          reread #COLSFILE : FILELAY$, NUMOFCOLS, MAT INCLUDECOLUMNS$
11197 ! 
11198       end if 
11199 ! 
11200 Rlcu_Failed: ! Jump here if can't find the record
11201       if (COLSFILE) AND FILE(COLSFILE)><-1 then close #COLSFILE: : let COLSFILE=0
11202    fnend 
11203 ! 
11204    def FNSAVELASTCOLUMNSUSED(MAT INCLUDECOLUMNS$,FILELAY$*64;___,SAVESELECTEDCOLS$*64,FILENAME$*68,KEYFILE$*68,COLSFILE,NUMOFCOLS)
11205       let SAVESELECTEDCOLS$=FNSETTINGS$("saveselectedcols")
11206       let FILENAME$=SAVESELECTEDCOLS$&".dat"
11207       let KEYFILE$=SAVESELECTEDCOLS$&".key"
11208       open #(COLSFILE:=FNGETFILENUMBER): "name="&FILENAME$&", kfname="&KEYFILE$&", recl=10000, kps=1, kln=18, use",internal, outin, keyed 
11209 ! 
11210       read #COLSFILE, key=RPAD$(FILELAY$(1:18),18) : nokey IGNORE
11211       if FILE(COLSFILE)=0 then 
11212          rewrite #COLSFILE : FILELAY$(1:18), UDIM(MAT INCLUDECOLUMNS$), MAT INCLUDECOLUMNS$
11213       else 
11214          write #COLSFILE : FILELAY$(1:18), UDIM(MAT INCLUDECOLUMNS$), MAT INCLUDECOLUMNS$
11215       end if 
11216 ! 
11217       close #COLSFILE: 
11218    fnend 
11219 ! 
11220    def library FNCSVIMPORT(LAYOUT$*64;SUPRESSDIALOG,FILENAME$*300,IMPORTMODEKEY,___,OKTORUN)
11221       if SUPRESSDIALOG then 
11222          if TRIM$(FILENAME$)><"" AND EXISTS(TRIM$(FILENAME$)) then 
11223             let OKTORUN=1
11224          else 
11225             if TRIM$(FILENAME$)="" then 
11226                let MSGBOX("The output file name was not given.","File Not Passed","Ok","ERR")
11227             else 
11228                let MSGBOX("File ("&TRIM$(FILENAME$)&") could not be found.","File not Found","Ok","ERR")
11229             end if 
11230          end if 
11231       else 
11232          if FNCSVIMPORTDLG(LAYOUT$,FILENAME$,IMPORTMODEKEY) then 
11233             let OKTORUN=1
11234          end if 
11235       end if 
11236 ! 
11237       if OKTORUN then 
11238          let FNIMPORTFROMCSV(LAYOUT$,FILENAME$,IMPORTMODEKEY)
11239       end if 
11240    fnend 
11241 ! 
11242    def FNEXPORTSELECTEDFILES(MAT SEL,MAT FILES$;___,CSVEXPORTPATH$*255,CSVEXPORTINDEX,GLOBALPROGRESSBAR,ROWS,COLS,SROW,SCOL,SIZE,PERCENT,TOSPOT)
11243 ! 
11244 ! .! Input Path
11245       library : FNCLIENTSERVER, FNCSVEXPORT
11246 ! 
11247       if FNCLIENTSERVER then 
11248          let CSVEXPORTPATH$="@:Folders"
11249       else 
11250          let CSVEXPORTPATH$="Folders"
11251       end if 
11252       open #(CSVFILE:=FNGETFILENUMBER): "name=SAVE:"&CSVEXPORTPATH$&",recl=32000,replace",display,output ioerr IGNORE
11253       if FILE(CSVFILE) = 0 then 
11254          let CSVEXPORTPATH$=FILE$(CSVFILE)
11255          close #CSVFILE: 
11256 ! 
11257 ! .  ! Delete the temp file we made with the file select dialog and make the folder
11258          execute "*free """&CSVEXPORTPATH$&""""
11259          execute "*mkdir """&CSVEXPORTPATH$&""""
11260 ! 
11261          if UDIM(MAT SEL)>1 then 
11262 ! .                 ! First, Detect Size and Position.
11263             let FNREADSCREENS(ROWS,COLS)
11264             let SIZE=INT(COLS*.6666)  !78 Size should be .666*ScreenWidth
11265             let SROW=INT(ROWS*0.75)   !Row should be near the bottom of the window
11266             let SCOL=MIN(ROWS-4,INT((COLS-SIZE)/2))  !2  SCol should be int(ScreenWidth-Size/2)
11267 ! 
11268             open #(GLOBALPROGRESSBAR:=FNGETFILENUMBER): "SRow="&STR$(SROW)&",SCol="&STR$(SCOL)&",Rows=2,Cols="&STR$(SIZE)&",Caption=Overall Progress,Border=S",display,outin 
11269          end if 
11270 ! 
11271 ! .  ! Loop through all files and call fnCSVExport
11272          for CSVEXPORTINDEX=1 to UDIM(MAT SEL)
11273 ! .     ! let fnUpdateProgressBar(CSVExportIndex/udim(mat Sel),"",0,0,0,"Exporting Datafiles",Files$(Sel(CSVExportIndex)))
11274 ! .     ! let fnUpdateProgressBar(CSVExportIndex/udim(mat Sel),"",0,0,0,"Exporting Datafiles",os_filename$(CSVExportPath$&"\"&Files$(Sel(CSVExportIndex))&".csv"))
11275 ! 
11276             if GLOBALPROGRESSBAR then 
11277                let TOSPOT=MIN(INT((CSVEXPORTINDEX/UDIM(MAT SEL))*SIZE),SIZE)
11278                print #GLOBALPROGRESSBAR, fields "1,1,"&STR$(TOSPOT)&"/C 1,S/W:"&PB_COLOR$&";2,1,CC "&STR$(SIZE) : "","Current File: "&FILES$(SEL(CSVEXPORTINDEX))&" ("&STR$(CSVEXPORTINDEX)&"/"&STR$(UDIM(MAT SEL))&")"
11279             end if 
11280 ! 
11281 ! .     ! Export that file to CSV
11282             let FNCSVEXPORT(FILES$(SEL(CSVEXPORTINDEX)),1,CSVEXPORTPATH$&"\"&FILES$(SEL(CSVEXPORTINDEX))&".csv",1,-1)
11283 ! 
11284          next CSVEXPORTINDEX
11285 ! .  ! let fnCloseProgressBar
11286          let MSGBOX("Export Complete!","Success","Ok","EXCL")
11287          if GLOBALPROGRESSBAR then 
11288             close #GLOBALPROGRESSBAR: 
11289          end if 
11290       else 
11293 ! .  ! print "Opening File:"&hex$("0d0a")&"Code: "&str$(File(CSVFile))&""&hex$("0d0a")&"Name: "&File$(CSVFile)&""
11295       end if                          !pause
11296    fnend 
11297 ! 
11298 ! .! Dialog Type:
11299 ! .!  0 - Legacy, Regular Dialog
11300 ! .!  1 - Suppress Dialog
11301 ! .!  2 - Full Dialog: Ask Which Columns to use.
11302 ! .!  3 - Ask which columns only.
11303 ! 
11304    def library FNCSVEXPORT(LAYOUT$*64;DIALOGTYPE,FILENAME$*300,INCLUDERECNUMS,KEYNUMBER,STARTKEY$,KEYMATCH$,STARTREC,MAT RECORDS,SEARCHMATCH$,LAUNCH,___,SEARCHNOW$,OKTORUN)
11305       library : FNREADLAYOUTHEADER,FNREADLAYOUTARRAYS,FNOPENFILE, FNGETFILENUMBER
11306       if DIALOGTYPE=1 OR DIALOGTYPE=3 then 
11307          if TRIM$(FILENAME$)><"" then 
11308             let OKTORUN=1
11309          else 
11310 ! .     ! Randomly Generate the file name now when its not given and dialog is skipped.
11311             let FILENAME$=FNGENERATEFILENAME$("@:csvexpt","csv")
11312             let OKTORUN=1
11313          end if 
11314       else 
11315          if FNCSVEXPORTDLG(FILENAME$,INCLUDERECNUMS,DIALOGTYPE) then 
11316             let OKTORUN=1
11317          end if 
11318       end if 
11319 ! 
11320       if OKTORUN then 
11321          let FNEXPORTTOCSV(LAYOUT$,FILENAME$,INCLUDERECNUMS,KEYNUMBER,STARTKEY$,STARTREC,MAT RECORDS,SEARCHMATCH$,KEYMATCH$,SEARCHNOW$,DIALOGTYPE)
11322          if LAUNCH then 
11323             execute "sy -C -M start """" """&OS_FILENAME$(FILENAME$)&""""
11324          end if 
11325       end if 
11326    fnend 
11327 ! 
11328    def FNCSV_IMPORT(LAYOUT$*64;___,FILENAME$*300,USEKEY)
11329       library : FNREADLAYOUTHEADER,FNREADLAYOUTARRAYS,FNOPENFILE, FNGETFILENUMBER
11330       if FNCSVIMPORTDLG(LAYOUT$,FILENAME$,USEKEY) then 
11331          let FNIMPORTFROMCSV(LAYOUT$,FILENAME$,USEKEY)
11332       end if 
11333    fnend 
11334 ! 
11335    def FNCSV_EXPORT(LAYOUT$*64;KEYNUMBER,&KEY$,&RECORDNUM,MAT RECORDS,&SEARCHMATCH$,&KEYMATCH$,&SEARCHNOW$,___,FILENAME$*300,INCLUDERECORDS,DIALOGTYPE)
11336       if FNCSVEXPORTDLG(FILENAME$,INCLUDERECORDS,DIALOGTYPE) then 
11337          let FNEXPORTTOCSV(LAYOUT$,FILENAME$,INCLUDERECORDS,KEYNUMBER,KEY$,RECORDNUM,MAT RECORDS,SEARCHMATCH$,KEYMATCH$,SEARCHNOW$,DIALOGTYPE)
11338       end if 
11339    fnend 
11340 ! 
11341    def FNFMTSDATE$*1024 (CANDI_DATE$*1024,INFORMAT$,OUTFORMAT$;BYPASSDATEPROCESSING,___,FMTSDATE$*1024,FMTSDATE)
11342       if ~BYPASSDATEPROCESSING AND TRIM$(INFORMAT$)<>'' AND TRIM$(OUTFORMAT$)<>'' then 
11343          if POS(LWRC$(INFORMAT$),"julian") OR POS(LWRC$(INFORMAT$),"serial") OR POS(LWRC$(INFORMAT$),"days") then 
11344             let FMTSDATE=VAL(CANDI_DATE$)
11345          else 
11346             let FMTSDATE=DAYS(CANDI_DATE$,INFORMAT$)
11347          end if 
11348 ! 
11349          if POS(LWRC$(OUTFORMAT$),"julian") OR POS(LWRC$(OUTFORMAT$),"serial") OR POS(LWRC$(OUTFORMAT$),"days") then 
11350             let FMTSDATE$=STR$(FMTSDATE)
11351          else 
11352             let FMTSDATE$ = DATE$(FMTSDATE, OUTFORMAT$)
11353          end if 
11354 ! 
11355 ! .  ! if couldn't convert or empty, then use original value
11356          if FMTSDATE$='' then let FMTSDATE$ = CANDI_DATE$
11357       else 
11358          let FMTSDATE$ = CANDI_DATE$
11359       end if 
11360       let FNFMTSDATE$ = FMTSDATE$
11361    fnend 
11362 ! 
11363    def FNFMTNDATE$ (CANDI_DATE,INFORMAT$,OUTFORMAT$;BYPASSDATEPROCESSING,___,FMTNDATE$*64,FMTNDATE)
11364       if ~BYPASSDATEPROCESSING AND TRIM$(INFORMAT$)<>'' AND TRIM$(OUTFORMAT$)<>'' then 
11365          if POS(LWRC$(INFORMAT$),"julian") OR POS(LWRC$(INFORMAT$),"serial") OR POS(LWRC$(INFORMAT$),"days") then 
11366             let FMTNDATE=CANDI_DATE
11367          else 
11368             let FMTNDATE=DAYS(CANDI_DATE,INFORMAT$)
11369          end if 
11370          if POS(LWRC$(OUTFORMAT$),"julian") OR POS(LWRC$(OUTFORMAT$),"serial") OR POS(LWRC$(INFORMAT$),"days") then 
11371             let FMTNDATE$=STR$(FMTNDATE)
11372          else 
11373             let FMTNDATE$ = DATE$(FMTNDATE, OUTFORMAT$)
11374          end if 
11375 ! 
11376 ! .  ! if couldn't convert, then use original value
11377          if FMTNDATE$='' then let FMTNDATE$ = STR$(CANDI_DATE)
11378       else ! non-date numeric value
11379          let FMTNDATE$ = STR$(CANDI_DATE)
11380       end if 
11381       let FNFMTNDATE$ = FMTNDATE$
11382    fnend 
11383 ! 
11384    dim CSVFIELDNAMES$(1)*128,CSVFIELDPOSITIONS(1)
11385    dim CSVSDATESPEC$(1)*64,CSVNDATESPEC$(1)*64
11386    dim CSV_PRINTSTR$*2000
11387 ! 
11388 Exporttocsv: ! **** Export a data file to CSV format
11389    def FNEXPORTTOCSV(LAYOUT$*64,CSVFILE$*300,USERECNUMS;KEYNUMBER,&KEY$,&RECORDNUM,MAT RECORDS,&SEARCHMATCH$,&KEYMATCH$,&SEARCHNOW$,DIALOGTYPE,___,CSVFILE,DATAFILE,BRECNUM,SCREENROWS,SCREENCOLS,FMTDATE$,CSV_NUMINDX,DONTSORTSUBS,SUPPRESSPROMPT)
11390       let CSV_PRINTSTR$=""            !This is really a local variable, its dimmed to conserve Workstack Memory.
11391 ! 
11392       library : FNREADLAYOUTHEADER,FNREADLAYOUTARRAYS,FNOPENFILE, FNGETFILENUMBER, FNSELECTDATACRAWLERCOLS
11393 ! 
11394       open #(CSVFILE:=FNGETFILENUMBER): "name="&CSVFILE$&",recl=32000,replace",display,output ioerr IGNORE
11395 ! 
11396       if FILE(CSVFILE)==-1 AND WBVERSION$<"4.32k" then ! In some versions of BR, selecting a file on the client needs the following fix.
11397 ! .     ! Try again to see if CSV file is really an absolute path
11398          if CSVFILE$(1:2)="@:" AND CSVFILE$(4:4)=":" AND POS("ABCDEFGHIJKLMNOPQRSTUVWXYZ",UPRC$(CSVFILE$(3:3))) then 
11399 ! .        ! If its on the client, and if it has a Drive letter then a :, then we probably need another colon.
11400             let CSVFILE$(1:2)="@::"
11401             open #(CSVFILE:=FNGETFILENUMBER): "name="&CSVFILE$&",recl=32000,replace",display,output ioerr IGNORE
11402          end if 
11403       end if 
11404 ! 
11405       if FILE(CSVFILE) = 0 then 
11406 ! .     ! Print field names in first line
11407          let FNGETFIELDNAMES(LAYOUT$,MAT CSVFIELDNAMES$,MAT CSVFIELDPOSITIONS)
11408 ! 
11409          if USERECNUMS then print #CSVFILE: "&RECNUM,";
11410          mat CSV_DATA$=("") : mat CSV_DATA=(0)
11411          let DATAFILE=FNOPEN(LAYOUT$,MAT CSV_DATA$,MAT CSV_DATA,MAT CSV_FORMS$,1,KEYNUMBER,DONT_SORT_SUBS:=0,PATH$:='',MAT CSV_DFDESCR$, MAT DUMMY,SUPPRESSPROMPT:=1,0,0,MAT CSV_DATEFORMATS$)
11412          if DATAFILE AND FILE(DATAFILE)=0 then ! File opened successfully
11413             if UDIM(MAT CSV_DATA$)=0 then mat CSVSDATESPEC$(0) else mat CSVSDATESPEC$(UDIM(MAT CSV_DATA$))=CSV_DATEFORMATS$(1:UDIM(MAT CSV_DATA$))
11414             if UDIM(MAT CSV_DATA)=0 then mat CSVNDATESPEC$(0) else mat CSVNDATESPEC$(UDIM(MAT CSV_DATA))=CSV_DATEFORMATS$(UDIM(MAT CSV_DATA$)+1:UDIM(MAT CSV_DATEFORMATS$))
11415 ! 
11416             if DIALOGTYPE=2 OR DIALOGTYPE=3 then 
11417                let FNREADSCREENS(SCREENROWS,SCREENCOLS)
11418 ! 
11419                let COLSCHANGED=FNSELECTDATACRAWLERCOLS(MAT CSV_DFDESCR$,MAT INCLUDECOLUMNS$,MAT CSVFIELDNAMES$,SCREENROWS,SCREENCOLS,0,1,LAYOUT$)
11420                if NOT UDIM(MAT INCLUDECOLUMNS$) then 
11421 ! .              ! include ALL columns
11422                   mat INCLUDECOLUMNS$(UDIM(MAT CSVFIELDNAMES$))= CSVFIELDNAMES$
11423                end if 
11424             else 
11425 ! .           ! include ALL columns
11426                mat INCLUDECOLUMNS$(UDIM(MAT CSVFIELDNAMES$))= CSVFIELDNAMES$
11427             end if 
11428 ! 
11429             for FIND = 1 to UDIM(INCLUDECOLUMNS$)
11430                print #CSVFILE: INCLUDECOLUMNS$(FIND);
11431                if FIND < UDIM(INCLUDECOLUMNS$) then 
11432                   print #CSVFILE: ",";
11433                else 
11434                   print #CSVFILE: 
11435                end if 
11436             next FIND
11437 ! 
11438             if KLN(DATAFILE)>0 AND TRIM$(KEY$)<>"" then 
11439                restore #DATAFILE, search>=TRIM$(KEY$): nokey Clearkey
11440             end if 
11441             if RECORDNUM then 
11442                restore #DATAFILE, rec=RECORDNUM: norec Clearrec
11443             end if 
11444 ! 
11445             let BRECNUM=(~FNISEMPTY(MAT RECORDS))
11446 ! 
11447             let CSV_DATEEXPORTFORMAT$=FNSETTINGS$("dateformatexport")
11448             do 
11449                read #DATAFILE, using CSV_FORMS$(DATAFILE), release: MAT CSV_DATA$,MAT CSV_DATA error IGNORE
11450 ! 
11451                if FILE(DATAFILE)=0 then 
11452                   if KEYNUMBER<=0 AND LREC(DATAFILE)>0 then let FNUPDATEPROGRESSBAR(REC(DATAFILE)/LREC(DATAFILE),"",0,0,0,"Exporting "&LAYOUT$,"Record: "&STR$(REC(DATAFILE))&"/"&STR$(LREC(DATAFILE)))
11453                   if ~BRECNUM OR SRCH(MAT RECORDS,REC(DATAFILE))>0 then 
11454                      if ~LEN(KEYMATCH$) OR KEYMATCH$=FNBUILDKEY$(LAYOUT$,MAT CSV_DATA$,MAT CSV_DATA,KEYNUMBER)(1:LEN(KEYMATCH$)) then 
11455                         if ~LEN(SEARCHMATCH$) OR FNSEARCHIN(SEARCHMATCH$,MAT CSV_DATA$,MAT CSV_DATA,MAT CSVSDATESPEC$,MAT CSVNDATESPEC$,CSV_DATEEXPORTFORMAT$) then 
11456                            if ~LEN(SEARCHNOW$) OR FNSEARCHIN(SEARCHNOW$,MAT CSV_DATA$,MAT CSV_DATA,MAT CSVSDATESPEC$,MAT CSVNDATESPEC$,CSV_DATEEXPORTFORMAT$) then 
11457                               if USERECNUMS then print #CSVFILE: STR$(REC(DATAFILE))&",";
11458                               for FIND = 1 to UDIM(CSVFIELDNAMES$)
11459                                  if SRCH(MAT INCLUDECOLUMNS$,CSVFIELDNAMES$(FIND))>0 then 
11460 ! 
11461                                     if FIND <= UDIM(CSV_DATA$) then 
11462                                        let CSV_PRINTSTR$ = FNFMTSDATE$ (CSV_DATA$(FIND),CSV_DATEFORMATS$(FIND),CSV_DATEEXPORTFORMAT$)
11463                                        print #CSVFILE: """"&SREP$(CSV_PRINTSTR$,"""","""""")&"""";
11464                                     else 
11465                                        let CSV_NUMINDX = FIND - UDIM(CSV_DATA$)
11466                                        if CSV_DATEFORMATS$(FIND)<>'' then 
11467                                           print #CSVFILE: '"'&FNFMTNDATE$ (CSV_DATA(CSV_NUMINDX),CSV_DATEFORMATS$(FIND),CSV_DATEEXPORTFORMAT$)&'"';
11468                                        else ! non-date numeric value
11469                                           print #CSVFILE: CSV_DATA(CSV_NUMINDX);
11470                                        end if 
11471                                     end if 
11472                                     if FIND < UDIM(CSVFIELDNAMES$) AND INCLUDECOLUMNS$(UDIM(INCLUDECOLUMNS$))<>CSVFIELDNAMES$(FIND) then 
11473                                        print #CSVFILE: ",";
11474                                     else 
11475                                        print #CSVFILE: 
11476                                     end if 
11477                                  end if 
11478                               next FIND
11479                            end if 
11480                         end if 
11481                      end if 
11482                   end if 
11483                end if 
11484             loop UNTIL FILE(DATAFILE)=10
11485 ! 
11486             if KEYNUMBER<=0 then let FNCLOSEPROGRESSBAR
11487             close #DATAFILE: 
11488          else 
11489             if DATAFILE=0 then 
11490                print #CSVFILE: "Data File Not Found for layout: "&LAYOUT$
11491             else 
11492                print #CSVFILE: "Error Opening Data File for layout: "&LAYOUT$
11493                if FILE(DATAFILE)><-1 then 
11494                   close #DATAFILE: 
11495                end if 
11496             end if 
11497          end if 
11498          close #CSVFILE: 
11499 ! 
11500          if DIALOGTYPE><1 AND DIALOGTYPE><3 then let MSGBOX("Export complete!")
11501       else 
11502          let MSGBOX("Error: could not open output file!")
11503       end if 
11504    fnend 
11505 ! 
11506    def library FNCLIENTSERVER(;___,SERVERFOLDER$*255,CLIENTFOLDER$*255)
11507       if WBVERSION$(1:3)>="4.3" then 
11508          if LWRC$(TRIM$(ENV$("br_model")))="client/server" then 
11509             let FNCLIENTSERVER=1
11510          else 
11511             let FNCLIENTSERVER=0
11512          end if 
11513       else 
11514          let SERVERFOLDER$=OS_FILENAME$(".")
11515          let CLIENTFOLDER$=OS_FILENAME$("@:.")
11516          if CLIENTFOLDER$(LEN(CLIENTFOLDER$):LEN(CLIENTFOLDER$))<>"\" then 
11517             let CLIENTFOLDER$=CLIENTFOLDER$&"\"
11518          end if 
11519          if SERVERFOLDER$(LEN(SERVERFOLDER$):LEN(SERVERFOLDER$))<>"\" then 
11520             let SERVERFOLDER$=SERVERFOLDER$&"\"
11521          end if 
11522          if LWRC$(TRIM$(SERVERFOLDER$))=LWRC$(TRIM$(CLIENTFOLDER$)) then 
11523             let FNCLIENTSERVER=0
11524          else 
11525             let FNCLIENTSERVER=1
11526          end if 
11527       end if 
11528    fnend 
11529 ! 
11530    def FNCSVEXPORTDLG(&CSVPATH$,&USERECNUMS;&DIALOGTYPE,___,DIALOG,KEYP,CSVFILE,USERECNUMS$*50,SELECTCOLUMNS$*50,FILESTRING$*255,ROWS,COLS)
11531       library : FNREADLAYOUTHEADER,FNCLIENTSERVER
11532 ! 
11533       dim KEYS$(1)*80,KEYDESC$(1)*80,SRCFIELDNAMES$(1)*80
11534       let FNREADSCREENS(ROWS,COLS)
11535 ! 
11536       open #(DIALOG:=FNGETFILENUMBER) : "SROW="&STR$(INT((ROWS - 7) / 2))&",SCOL="&STR$(INT((COLS - 30) / 2))&",ROWS=7,COLS=30,CAPTION=Export to CSV,BORDER=S",display,outin 
11537       print #DIALOG, fields "1,1,C 20;2,22,CC 8,/W:W,B62" : "CSV Data File","Browse"
11538       print #DIALOG, fields "7,12,CC 8,/W:W,B61" : "Export!"
11539       print #DIALOG, fields "7,22,CC 8,/W:W,B60" : "Cancel"
11540       if FNCLIENTSERVER then 
11541          let FILESTRING$="@:CSV files (*.csv) |*.csv"
11542       else 
11543          let FILESTRING$="CSV files (*.csv) |*.csv"
11544       end if 
11545 ! 
11546       if LEN(TRIM$(CSVPATH$)) then 
11547          open #(CSVFILE:=FNGETFILENUMBER): "name="&CSVPATH$&",recl=32000,new",display,output,error IGNORE
11548          if FILE(CSVFILE)=0 then 
11549 ! .      ! Path is good
11550          else 
11551             if FILE(CSVFILE)<>-1 then close #CSVFILE: 
11552             open #(CSVFILE:=FNGETFILENUMBER): "name=SAVE:"&CSVPATH$&",recl=32000,replace",display,output ioerr IGNORE
11553          end if 
11554       else 
11555          open #(CSVFILE:=FNGETFILENUMBER): "name=SAVE:"&FILESTRING$&",recl=32000,replace",display,output ioerr IGNORE
11556       end if 
11557 ! 
11558       if FILE(CSVFILE) = 0 then 
11559          let CSVPATH$=FILE$(CSVFILE)
11560          close #CSVFILE: 
11561 ! 
11562          let USERECNUMS$ = "Include Record Numbers"
11563          if USERECNUMS then let USERECNUMS$(1:0)="^"
11564 ! 
11565          let SELECTCOLUMNS$="Select Columns"
11566          if DIALOGTYPE=2 then let SELECTCOLUMNS$(1:0)="^"
11567 ! 
11568          do 
11569             rinput #DIALOG, fields "2,1,20/V 300,P;4,1,CHECK 30;5,1,CHECK 30" : CSVPATH$,USERECNUMS$,SELECTCOLUMNS$
11570 ! 
11571             let KEYP=FKEY
11572 ! 
11573             if KEYP=62 then 
11574 ! .            ! browse for a new file
11575                open #(CSVFILE:=FNGETFILENUMBER): "name=SAVE:"&FILESTRING$&",recl=32000,replace",display,output ioerr IGNORE
11576                if FILE(CSVFILE) = 0 then 
11577                   let CSVPATH$=FILE$(CSVFILE)
11578                   close #CSVFILE: 
11579                end if 
11580             end if 
11581          loop UNTIL KEYP = 60 OR KEYP = 61 OR KEYP = 99 OR KEYP=93
11582 ! 
11583          if USERECNUMS$(1:1)="^" then let USERECNUMS=1 else let USERECNUMS=0
11584          if SELECTCOLUMNS$(1:1)="^" then let DIALOGTYPE=2 else let DIALOGTYPE=0
11585 ! 
11586          if KEYP = 61 then 
11587 ! .        ! do export
11588             let FNCSVEXPORTDLG=1
11589          end if 
11590       end if 
11591 ! 
11592       close #DIALOG: 
11593    fnend 
11594 ! 
11595 ! 
11596 Importfromcsv: ! **** Import data from an external CSV file
11597    def FNIMPORTFROMCSV(LAYOUT$,&FILENAME$,KEYNUM;___,DATAFILE,RECNUM$,CHARIND,NUMQ,CSVFILE,INDX)
11598       library : FNBUILDKEY$,FNCLOSEFILE, FNREADCSVLINE$
11599 ! 
11600       dim CSVLINE$*32000
11601       dim SRCFIELDNAMES$(1)*80
11602 ! 
11603       open #(CSVFILE:=FNGETFILENUMBER): "name="&FILENAME$,display,input ioerr IGNORE
11604       if FILE(CSVFILE) = 0 then 
11605          restore #CSVFILE: 
11606          linput #CSVFILE: CSVLINE$
11607 ! 
11608          let FIELDCNT=FNEXTRACTCSVHEADER(CSVLINE$,MAT SRCFIELDNAMES$)
11609          let FNLWRCTHIS(MAT SRCFIELDNAMES$)
11610 ! 
11611          let FNGETFIELDNAMES(LAYOUT$,MAT CSVFIELDNAMES$,MAT CSVFIELDPOSITIONS)
11612 ! 
11613 ! .    ! Make the comparison case insensitive by lwrcing everything
11614          for INDX=1 to UDIM(MAT SRCFIELDNAMES$)
11615             let SRCFIELDNAMES$(INDX)=LWRC$(SRCFIELDNAMES$(INDX))
11616          next INDX
11617          for INDX=1 to UDIM(MAT CSVFIELDNAMES$)
11618             let CSVFIELDNAMES$(INDX)=LWRC$(CSVFIELDNAMES$(INDX))
11619          next INDX
11620 ! 
11621          if KEYNUM > 0 then 
11622             let DATAFILE=FNOPEN(LAYOUT$,MAT CSV_DATA$,MAT CSV_DATA,MAT CSV_FORMS$,0,KEYNUM)
11623          else 
11624             let DATAFILE=FNOPEN(LAYOUT$,MAT CSV_DATA$,MAT CSV_DATA,MAT CSV_FORMS$)
11625          end if 
11626 ! 
11627          let FNCLEARCSVAPPLYMESSAGES
11628 ! 
11629          do 
11630             let CSVLINE$=FNREADCSVLINE$(CSVFILE)
11631             if FILE(CSVFILE) = 0 then 
11632                let FNEXTRACTCSVLINE(CSVLINE$,MAT CSV_DATA$,MAT CSV_DATA,MAT CSVFIELDNAMES$,MAT SRCFIELDNAMES$)
11633 ! 
11634                if FNDISPLAYCSVAPPLYMESSAGES then 
11635 ! .                ! There were no errors, or they chose Ignore
11636                   if KEYNUM > 0 then 
11637 ! .                    ! attempt to rewrite
11638                      rewrite #DATAFILE, using CSV_FORMS$(DATAFILE), key=FNBUILDKEY$(LAYOUT$, MAT CSV_DATA$, MAT CSV_DATA, KEYNUM) : MAT CSV_DATA$, MAT CSV_DATA error IGNORE
11639                      if FILE(DATAFILE) = 21 then 
11640                         write #DATAFILE, using CSV_FORMS$(DATAFILE) : MAT CSV_DATA$, MAT CSV_DATA
11641                      end if 
11642                   else if KEYNUM = 0 then 
11643                      let RECNUM$=CSVLINE$(1:POS(CSVLINE$,",")-1)
11644                      rewrite #DATAFILE, using CSV_FORMS$(DATAFILE), rec=VAL(RECNUM$) : MAT CSV_DATA$, MAT CSV_DATA error IGNORE
11645                      if FILE(DATAFILE) = 21 then 
11646                         write #DATAFILE, using CSV_FORMS$(DATAFILE) : MAT CSV_DATA$, MAT CSV_DATA
11647                      end if 
11648                   else 
11649                      write #DATAFILE, using CSV_FORMS$(DATAFILE) : MAT CSV_DATA$, MAT CSV_DATA
11650                   end if 
11651                else 
11652 ! .                ! They chose abort
11653                   exit do 
11654                end if 
11655             end if 
11656          loop UNTIL FILE(CSVFILE) <> 0
11657 ! 
11658          let FNCLOSEFILE(DATAFILE,LAYOUT$)
11659       else 
11660          let MSGBOX("Error "&STR$(ERR)&" Opening File "&FILENAME$,"File Error","Ok","Err")
11661       end if 
11662    fnend 
11663 ! 
11664    dim TEMPSTRING$*100000
11665    def FNREADCSV$*100000(CSVFILE)
11666       let FNREADLONGLINE(TEMPSTRING$,CSVFILE)
11667       let FNREADCSV$=TEMPSTRING$
11668    fnend 
11669 ! 
11670    def library FNREADCSVLINE$*100000(CSVFILE)
11671       let FNREADLONGLINE(TEMPSTRING$,CSVFILE)
11672       let FNREADCSVLINE$=TEMPSTRING$
11673    fnend 
11674 ! 
11675    dim CSVLINEBUF$*100000
11676    def FNREADLONGLINE(&CSVLINE$,CSVFILE)
11677       let CSVLINE$=""
11678       do WHILE FILE(CSVFILE)=0
11679          let CSVLINEBUF$=""
11680          linput #CSVFILE: CSVLINEBUF$ error IGNORE
11681          if FILE(CSVFILE)=0 then 
11682             let CSVLINE$=CSVLINE$&CSVLINEBUF$
11683          end if 
11684       loop UNTIL MOD(FNCOUNTCHARACTER(CSVLINE$,""""),2)=0
11685    fnend 
11686 ! 
11687 ! Fast way to count number of occurances of given char in a string
11688    def FNCOUNTCHARACTER(&STRING$,CHAR$)=LEN(STRING$)-LEN(SREP$(STRING$,CHAR$,""))
11689 ! 
11690    def FNCSVIMPORTDLG(LAYOUT$,&CSVPATH$,&KEYNUM;___,DIALOG,KEY,FILENAME$*255,CSVPATH2$*300,KEY$*160,INDEX,SEL$,CSVFILE,CSVLINE$*32000,FILECHANGED,FILESTRING$*255,ROWS,COLS,CURRENTFIELD,FUNCTIONKEY)
11691       library : FNREADLAYOUTHEADER,FNCLIENTSERVER
11692 ! 
11693       dim KEYS$(1)*80,KEYDESC$(1)*80,KEYOPTIONS$(1)*160,SRCFIELDNAMES$(1)*80
11694       let FNREADSCREENS(ROWS,COLS)
11695 ! 
11696       open #(DIALOG:=FNGETFILENUMBER) : "SROW="&STR$(INT((ROWS - 7) / 2))&",SCOL="&STR$(INT((COLS - 30) / 2))&",ROWS=7,COLS=30,CAPTION=Import from CSV,BORDER=S",display,outin 
11697       print #DIALOG, fields "1,1,C 20;2,22,CC 8,/W:W,B62" : "CSV Data File","Browse"
11698       print #DIALOG, fields "7,22,CC 8,/W:W,B60" : "Cancel"
11699 ! 
11700       let FNREADLAYOUTHEADER(LAYOUT$,FILENAME$,MAT KEYS$,MAT KEYDESC$,0)
11701 ! 
11702       if FN42 then let SEL$=",SELECT" else let SEL$=""
11703       if LEN(TRIM$(CSVPATH$))=0 then 
11704          if POS(FILENAME$,".") > 0 then let CSVPATH$=FILENAME$(1:POS(FILENAME$,"."))&"csv" else let CSVPATH$=FILENAME$&".csv"
11705       end if 
11706       let FILECHANGED = 1
11707       do 
11708 ! .    ! Check whether selected file exists and if so, look for &RECNUM field
11709          let CSVPATH2$=CSVPATH$
11710          if FILECHANGED then 
11711             let FILECHANGED = 0
11712             if FILE(CSVFILE) >< -1 then close #CSVFILE: 
11713             open #(CSVFILE=FNGETFILENUMBER): "name="&CSVPATH$,display,input ioerr IGNORE
11714          end if 
11715          if FILE(CSVFILE) = 0 then ! File exists and is open
11716             print #DIALOG, fields "4,1,C 26" : "Update Records Using Key"
11717 ! 
11718             restore #CSVFILE: 
11719             linput #CSVFILE: CSVLINE$
11720             let FNEXTRACTCSVHEADER(CSVLINE$,MAT SRCFIELDNAMES$)
11721             if LWRC$(TRIM$(SRCFIELDNAMES$(1),"&")) = "recnum" then 
11722                mat KEYOPTIONS$(UDIM(KEYDESC$) + 2)
11723                let KEYOPTIONS$(2)="Record Number"
11724             else 
11725                mat KEYOPTIONS$(UDIM(KEYDESC$) + 1)
11726             end if 
11727             let KEYOPTIONS$(1)="None (append all records)"
11728             for INDEX = 1+UDIM(KEYOPTIONS$)-UDIM(KEYDESC$) to UDIM(KEYOPTIONS$)
11729                let KEYOPTIONS$(INDEX) = STR$(INDEX+UDIM(KEYDESC$)-UDIM(KEYOPTIONS$))&" - "&KEYS$(INDEX+UDIM(KEYDESC$)-UDIM(KEYOPTIONS$))&" ("&KEYDESC$(INDEX+UDIM(KEYDESC$)-UDIM(KEYOPTIONS$))&")"
11730             next INDEX
11731             print #DIALOG, fields "5,1,26/COMBO 160,= "&SEL$ : MAT KEYOPTIONS$
11732 ! 
11733             if KEYNUM=-1 then 
11734                let KEY$=KEYOPTIONS$(1)
11735             else if KEYNUM=0 AND UDIM(MAT KEYOPTIONS$)>=2 AND KEYOPTIONS$(2)="Record Number" then 
11736                let KEY$=KEYOPTIONS$(1)
11737             else 
11738                if UDIM(MAT KEYOPTIONS$)>=2 AND KEYOPTIONS$(2)="Record Number" then 
11739                   let KEY$=KEYOPTIONS$(KEYNUM+2)
11740                else 
11741                   let KEY$=KEYOPTIONS$(KEYNUM+1)
11742                end if 
11743             end if 
11744 ! 
11745             let CURFLD(CURRENTFIELD,FUNCTIONKEY)
11746             rinput #DIALOG, fields "2,1,20/C 300,AEX;5,1,26/COMBO 160,"&SEL$ : CSVPATH$,KEY$
11747             let FUNCTIONKEY=FKEY
11748             let CURRENTFIELD=CURFLD
11749          else ! File doesn't exist; don't show any other input fields
11750             let KEY$=""
11751             print #DIALOG, fields "7,11,CC 8" : ""
11752             print #DIALOG, fields "4,1,C 26;5,1,C 26" : "",""
11753             rinput #DIALOG, fields "2,1,20/C 300,AEX" : CSVPATH$
11754          end if 
11755          let KEY=FKEY
11756 ! 
11757          if KEY = 62 then 
11758 ! .        ! try to open file by browsing
11759             let FILECHANGED = 0
11760             if FILE(CSVFILE) >< -1 then close #CSVFILE: 
11761 ! 
11762             if FNCLIENTSERVER then 
11763                let FILESTRING$="@:CSV files (*.csv) |*.csv"
11764             else 
11765                let FILESTRING$="CSV files (*.csv) |*.csv"
11766             end if 
11767 ! 
11768             open #(CSVFILE=FNGETFILENUMBER): "name=OPEN:"&FILESTRING$,display,input ioerr IGNORE
11769             if FILE(CSVFILE) = 0 then 
11770                let CSVPATH$=FILE$(CSVFILE)
11771             else 
11772                let FILECHANGED = 1
11773             end if 
11774          end if 
11775          if CSVPATH2$<>CSVPATH$ then 
11776 ! .        ! retry file using contents of text box
11777             let FILECHANGED = 1
11778          end if 
11779          if KEY$="" then 
11780             print #DIALOG, fields "7,12,CC 8" : ""
11781          else 
11782             print #DIALOG, fields "7,12,CC 8,/W:W,B61" : "Import!"
11783          end if 
11784 ! 
11785       loop UNTIL KEY = 60 OR KEY = 61 OR KEY = 99 OR KEY=93
11786 ! 
11787       if KEY = 61 then 
11788 ! .    ! get data key number; -1 = append all, 0 = use recnum
11789          if KEY$="Record Number" then 
11790             let KEYNUM=0
11791          else if KEY$(1:4)="None" then 
11792             let KEYNUM=-1
11793          else 
11794             let KEYNUM=VAL(KEY$(1:POS(KEY$," ")-1))
11795          end if 
11796 ! 
11797 ! .    ! do the import
11798          let FNCSVIMPORTDLG=1
11799       end if 
11800       if FILE(CSVFILE)><-1 then close #CSVFILE: 
11801       close #DIALOG: 
11802    fnend 
11803 ! 
11804    def FNSTRIPQUOTES(MAT A$;___,INDEX)
11805       for INDEX=1 to UDIM(MAT A$)
11806          let A$(INDEX)=TRIM$(A$(INDEX),"""")
11807       next INDEX
11808    fnend 
11809 ! 
11810 Extractcsvheader: ! Extract field names from a CSV header line into an array
11811    def FNEXTRACTCSVHEADER(&LINE$,MAT FIELDNAMES$)
11812       let LINE$=TRIM$(LINE$)
11813       let CHUNKSTART=1 : let FIELDCNT=0
11814       for CHARIND = 1 to LEN(LINE$)
11815          if LINE$(CHARIND:CHARIND)="," then 
11816             let FIELDCNT = FIELDCNT + 1
11817             mat FIELDNAMES$(FIELDCNT)
11818             if CHARIND=CHUNKSTART then let FIELDNAMES$(FIELDCNT)="" else let FIELDNAMES$(FIELDCNT)=LINE$(CHUNKSTART:CHARIND-1)
11819             let CHUNKSTART=CHARIND+1
11820          else if CHARIND=LEN(LINE$) then 
11821             let FIELDCNT = FIELDCNT + 1
11822             mat FIELDNAMES$(FIELDCNT)
11823             let FIELDNAMES$(FIELDCNT)=LINE$(CHUNKSTART:CHARIND)
11824          end if 
11825       next CHARIND
11826       let FNSTRIPQUOTES(MAT FIELDNAMES$)
11827       let FNEXTRACTCSVHEADER=FIELDCNT
11828    fnend 
11829 ! 
11830    def FNEXTRACTCSVLINE(&LINE$,MAT SVALUES$,MAT NVALUES,MAT DESTFIELDNAMES$,MAT SRCFIELDNAMES$;___,CHUNKSTART,CURFIELD,CHARIND,CHUNK$*4000,NUMIND,STRIND)
11831       let LINE$=TRIM$(LINE$)
11832       let CHUNKSTART=1 : let CURFIELD=1
11833       mat SVALUES$=("")
11834       mat NVALUES=(0)
11835 ! 
11836       for CHARIND = 0 to LEN(LINE$)
11837          if LINE$(CHARIND+1:CHARIND+1)="," OR CHARIND=LEN(LINE$) then 
11838 ! .         ! grab chunk to parse
11839             let CHUNK$=RTRM$(LINE$(CHUNKSTART:CHARIND))  !RTRM, BR doesn't store trailing spaces anyway.
11840             let NEXTFIELD = 0
11841 ! 
11842 ! .         ! print line$ : print chunk$ : pause ! Debug line
11843 ! 
11844             if CHUNK$(1:1)<>"""" OR MOD(FNNUMENDINGQUOTES(CHUNK$),2)=1 then 
11845 ! .            ! Either has no beg qoute (not quoted) or has both
11846 ! .            ! beginning and ending qoute, process it. Otherwise, go
11847 ! .            ! back for more.
11848 ! 
11849                if CHUNK$(1:1)="""" AND MOD(FNNUMENDINGQUOTES(CHUNK$),2)=1 then 
11850                   let CHUNK$=SREP$(CHUNK$(2:LEN(CHUNK$)-1),"""""","""")  !Substitute out inner Qoutes, and Strip out Qoutes
11851                end if 
11852 ! .            ! if len(Trim$(Chunk$)) then ! If there's something left ! Commented out by GSB .. if a field is empty, we want to clear the value, not ignore it.
11853                let FNAPPLYCSVFIELD(CHUNK$,MAT SVALUES$,MAT NVALUES,MAT DESTFIELDNAMES$,SRCFIELDNAMES$(CURFIELD))
11854 ! .            ! end if
11855                let NEXTFIELD = 1
11856             end if 
11857 ! 
11858             if NEXTFIELD then 
11859 ! .             ! CharInd=CharInd+2
11860                let CHUNKSTART=CHARIND +2
11861                let CURFIELD = CURFIELD + 1
11862             end if 
11863          end if 
11864       next CHARIND
11865    fnend 
11866 ! 
11867 ! .! Old Logic here replaced by the above code.
11868 ! .! Old Logic for Numbers (Without beginning quote):
11869 ! .!  for NumInd=UDim(SValues$)+1 to UDim(SValues$)+Udim(NValues)
11870 ! .!     if DestFieldNames$(NumInd)=SrcFieldNames$(CurField) then NValues(NumInd - UDim(SValues$))=Val(Chunk$)
11871 ! .!  next NumInd
11872 ! 
11873 ! .! Old Logic for Strings (With Beginning Qoute):
11874 ! .!  for StrInd=1 to UDim(SValues$)
11875 ! .!     if DestFieldNames$(StrInd)=SrcFieldNames$(CurField) then SValues$(StrInd)=Chunk$
11876 ! .!  next StrInd
11877 ! 
11878    def FNAPPLYCSVFIELD(&SOURCEDATA$,MAT SVALUES$,MAT NVALUES, MAT DESTFIELDNAMES$,&SOURCEFIELDNAME$;___,INDEX)
11879       let INDEX=SRCH(MAT DESTFIELDNAMES$,SOURCEFIELDNAME$)
11880       if INDEX>=1 AND INDEX<=UDIM(SVALUES$)+UDIM(NVALUES) then 
11881          if INDEX>UDIM(SVALUES$) then 
11882             if FNISNUMBER(CHUNK$) then 
11883                let NVALUES(INDEX-UDIM(SVALUES$))=VAL(CHUNK$)
11884             else 
11885                if ~ERRORIMPORTMESSAGE then ! If not asked yet, then ask.
11886 ! .              ! Conversion Error, Field was not a number when it should have been
11887                   mat FIELDSCONV$(UDIM(MAT FIELDSCONV$)+1)
11888                   let FIELDSCONV$(UDIM(MAT FIELDSCONV$))=SOURCEFIELDNAME$
11889                end if 
11890             end if 
11891          else 
11892             let SVALUES$(INDEX)=CHUNK$
11893          end if 
11894       else 
11895 ! .     ! Field could not be found, report it later
11896          if SOURCEFIELDNAME$<>"&recnum" then 
11897             mat FIELDSMISSING$(UDIM(FIELDSMISSING$)+1)
11898             let FIELDSMISSING$(UDIM(FIELDSMISSING$))=SOURCEFIELDNAME$
11899          end if 
11900       end if 
11901    fnend 
11902 ! 
11903    dim FIELDSMISSING$(1)*127
11904    dim FIELDSCONV$(1)*127
11905 ! 
11906    def FNCLEARCSVAPPLYMESSAGES
11907       mat FIELDSMISSING$(0)
11908       mat FIELDSCONV$(0)
11909    fnend 
11910 ! 
11911    dim MESSAGETEXT$*4000
11912    def FNDISPLAYCSVAPPLYMESSAGES
11913       if UDIM(MAT FIELDSMISSING$)+UDIM(MAT FIELDSCONV$) then ! If there were errors,
11914          let FNBUILDMESSAGETEXT(MESSAGETEXT$,MAT FIELDSMISSING$,MAT FIELDSCONV$)
11915          if (2==MSGBOX(MESSAGETEXT$,"Import Error","Yn","ERR")) then 
11916             let FNDISPLAYCSVAPPLYMESSAGES=0
11917          else 
11918             let FNDISPLAYCSVAPPLYMESSAGES=1
11919          end if 
11920       else 
11921          let FNDISPLAYCSVAPPLYMESSAGES=1
11922       end if 
11923    fnend 
11924 ! 
11925    def FNBUILDMESSAGETEXT(&MESSAGETEXT$,MAT MISSING$,MAT CONV$;___,INDEX,NP$,NL$)
11926       let NP$=HEX$("0D0A0D0A")
11927       let NL$=HEX$("0D0A")
11928 ! 
11929       let MESSAGETEXT$="Errors were encountered during the import process."
11930       if UDIM(MAT MISSING$) then 
11931          let MESSAGETEXT$=MESSAGETEXT$&NP$&"The following fields could not be found in the data file and will be ignored if you continue:"&NL$
11932          for INDEX=1 to UDIM(MAT MISSING$)
11933             let MESSAGETEXT$=MESSAGETEXT$&MISSING$(INDEX)&", "
11934          next INDEX
11935          let MESSAGETEXT$=MESSAGETEXT$(1:LEN(MESSAGETEXT$)-2)  !Chop off final ","
11936       end if 
11937       if UDIM(MAT CONV$) then 
11938          let MESSAGETEXT$=MESSAGETEXT$&NP$
11939          if UDIM(MAT MISSING$) then 
11940             let MESSAGETEXT$=MESSAGETEXT$&"Additionally, t"
11941          else 
11942             let MESSAGETEXT$=MESSAGETEXT$&"T"
11943          end if 
11944          let MESSAGETEXT$=MESSAGETEXT$&"he following fields were numeric fields that contained string data, and will be ignored if you continue:"&NL$
11945          for INDEX=1 to UDIM(MAT CONV$)
11946             let MESSAGETEXT$=MESSAGETEXT$&CONV$(INDEX)&", "
11947          next INDEX
11948          let MESSAGETEXT$=MESSAGETEXT$(1:LEN(MESSAGETEXT$)-2)  !Chop off final ","
11949       end if 
11950       let MESSAGETEXT$=MESSAGETEXT$&NP$&"Do you wish to Stop the Import process?"
11951       let FNCLEARCSVAPPLYMESSAGES
11952    fnend 
11953 ! 
11954 ! .! that delicate nervous shake
11955 ! .! upon discovering a pause
11956 ! .! left behind by mistake
11957 ! .! like a sock in the kaverns of kroz
11958 ! 
11959    def FNNUMENDINGQUOTES(CHUNK$*4000;___,CHARIND,QUOTECNT)
11960       let QUOTECNT = 0
11961       for CHARIND = LEN(CHUNK$) to 2 step -1
11962          if CHUNK$(CHARIND:CHARIND)="""" then let QUOTECNT += 1
11963       next CHARIND
11964       let FNNUMENDINGQUOTES = QUOTECNT
11965    fnend 
11966 ! 
11967 ! .! discovered in some dusty function
11968 ! .! that you thought was always working
11969 ! .! abandoned like a lost conjunction
11970 ! .! a dangerous pause, secretly lurking
11971 ! 
11972    def FNLWRCTHIS(MAT A$;___,INDEX)
11973       for INDEX=1 to UDIM(MAT A$)
11974          let A$(INDEX)=LWRC$(A$(INDEX))
11975       next INDEX
11976    fnend 
11977 ! 
11978 ! .! what is this pause
11979 ! .! and why is it there?
11980 ! .! why is it forgotten,
11981 ! .! abandoned somewhere?
11982 ! 
11983 ! 
11984    dim OUTCOLUMNNAMES$(1)*255
11985 Calculatefieldforms: ! ***** Calculate Field Forms From Widths And Num Of Strings/Numerics
11986    def FNCALCULATEFIELDFORMS(LAYOUT$,MAT COLUMNNAMES$,MAT FIELDFORMS$,MAT OUTWIDTHS,MAT OUTDESCRIPTION$,MAT WIDTHS,MAT DESCRIPTION$,MAT DATEFORMATS$,MAT INCLUDECOLUMNS$,MAT ORIGINALINCLUDECOLUMN$,MAT COLUMNDESCRIPTION$,MAT COLUMNWIDTHS,MAT COLUMNFORMS$,MAT FIELDPOSITIONS;BSHOWPOSITIONS,DISPLAYSUB,&DISPLAYFIELDCONVERT$,DATEDISPLAYFORMAT$,BYPASSDATEPROCESSING,___,INDEX,COMPRESSCOLUMNS,MAXCOLWIDTH,SUB,BCOLUMNDESCRIPTION,BCOLUMNWIDTH,BORIGINALINCLUDE,BCOLUMNFORMS)
11987 ! 
11988 ! .  ! Prepare width calculation
11989       let COMPRESSCOLUMNS=FNSETTINGS("compresscolumns")
11990       let MAXCOLWIDTH=FNSETTINGS("maxcolwidth")
11991 ! 
11992 ! .  ! Prepare Column Descriptions and Widths
11993       let BCOLUMNWIDTH=~FNISEMPTY(MAT COLUMNWIDTHS)
11994       let BCOLUMNFORMS=~FNISEMPTYS(MAT COLUMNFORMS$)
11995       let BCOLUMNDESCRIPTION=~FNISEMPTYS(MAT COLUMNDESCRIPTION$)
11996       let BORIGINALINCLUDE=~FNISEMPTYS(MAT ORIGINALINCLUDECOLUMN$)
11997 ! 
11998       if ~FNISEMPTYS(MAT INCLUDECOLUMNS$) then 
11999 ! .     ! Size temp arrays
12000          mat OUTWIDTHS(UDIM(MAT INCLUDECOLUMNS$))
12001          mat OUTDESCRIPTION$(UDIM(MAT INCLUDECOLUMNS$))
12002          mat OUTCOLUMNNAMES$(UDIM(MAT INCLUDECOLUMNS$))
12003          mat FIELDFORMS$(UDIM(MAT OUTWIDTHS))
12004 ! 
12005 ! .     ! Sort through IncludeColumns and place columns in the grid in order.
12006          for INDEX=1 to UDIM(MAT INCLUDECOLUMNS$)
12007             let SUB=SRCH(MAT COLUMNNAMES$,INCLUDECOLUMNS$(INDEX))
12008             if SUB>0 then ! found it
12009                if ~BYPASSDATEPROCESSING AND DATEFORMATS$(SUB)<>'' then 
12010 ! .              ! We need to set FieldForms$ to DisplayDateFormat whenever the field is a date field (has anything under dc_DateFormat)
12011                   let OUTWIDTHS(INDEX)=FNGETDATEWIDTH(DATEDISPLAYFORMAT$)
12012                   let FIELDFORMS$(INDEX)="DATE("&DATEDISPLAYFORMAT$&")"
12013                else 
12014                   let OUTWIDTHS(INDEX)=WIDTHS(SUB)
12015                   let FIELDFORMS$(INDEX)="C "&STR$(OUTWIDTHS(INDEX))
12016                end if 
12017 ! 
12018                let OUTDESCRIPTION$(INDEX)=DESCRIPTION$(SUB)
12019                if BSHOWPOSITIONS then let OUTDESCRIPTION$(INDEX)(1:0)=STR$(FIELDPOSITIONS(SUB))&" - "
12020                let OUTCOLUMNNAMES$(INDEX)=INCLUDECOLUMNS$(INDEX)
12021             end if 
12022          next INDEX
12023       else 
12024          mat OUTWIDTHS(UDIM(MAT WIDTHS))
12025          mat FIELDFORMS$(UDIM(MAT OUTWIDTHS))
12026 ! 
12027          for INDEX=1 to UDIM(MAT WIDTHS)
12028             if ~BYPASSDATEPROCESSING AND DATEFORMATS$(INDEX)<>'' then 
12029 ! .           ! We need to set FieldForms$ to DisplayDateFormat whenever the field is a date field (has anything under dc_DateFormat)
12030                let OUTWIDTHS(INDEX)=FNGETDATEWIDTH(DATEDISPLAYFORMAT$)
12031                let FIELDFORMS$(INDEX)="DATE("&DATEDISPLAYFORMAT$&")"
12032             else 
12033                let OUTWIDTHS(INDEX)=WIDTHS(INDEX)
12034                let FIELDFORMS$(INDEX)="C "&STR$(OUTWIDTHS(INDEX))
12035             end if 
12036          next INDEX
12037 ! 
12038          mat OUTDESCRIPTION$(UDIM(MAT DESCRIPTION$))
12039          mat OUTCOLUMNNAMES$(UDIM(MAT COLUMNNAMES$))=COLUMNNAMES$
12040          for INDEX=1 to UDIM(MAT DESCRIPTION$)
12041             let OUTDESCRIPTION$(INDEX)=DESCRIPTION$(INDEX)
12042             if BSHOWPOSITIONS then let OUTDESCRIPTION$(INDEX)(1:0)=STR$(FIELDPOSITIONS(INDEX))&" - "
12043          next INDEX
12044       end if 
12045 ! 
12046       for INDEX=1 to UDIM(MAT OUTWIDTHS)
12047          if BCOLUMNDESCRIPTION then 
12048             if BORIGINALINCLUDE then 
12049 ! .           ! interpret ColumnDescription and ColumnWidth as matching original include
12050                let SUB=SRCH(MAT ORIGINALINCLUDECOLUMN$,OUTCOLUMNNAMES$(INDEX))
12051                if SUB>0 AND SUB<=UDIM(MAT COLUMNDESCRIPTION$) then let OUTDESCRIPTION$(INDEX)=COLUMNDESCRIPTION$(SUB)
12052             else 
12053 ! .           ! interpret columndescription and Columnwidth as matching file record
12054                if INDEX<UDIM(MAT COLUMNDESCRIPTION$) then 
12055                   let OUTDESCRIPTION$(INDEX)=COLUMNDESCRIPTION$(INDEX)
12056                end if 
12057             end if 
12058          end if 
12059 ! 
12060          if ~COMPRESSCOLUMNS then 
12061             let OUTWIDTHS(INDEX)=MAX(OUTWIDTHS(INDEX),LEN(OUTDESCRIPTION$(INDEX)))
12062          end if 
12063          let OUTWIDTHS(INDEX)=MIN(OUTWIDTHS(INDEX),MAXCOLWIDTH)
12064 ! 
12065          if BCOLUMNFORMS then 
12066             if BORIGINALINCLUDE then 
12067 ! .           ! interpret ColumnForms as matching original include
12068                let SUB=SRCH(MAT ORIGINALINCLUDECOLUMN$,OUTCOLUMNNAMES$(INDEX))
12069                if SUB>0 AND SUB<=UDIM(MAT COLUMNFORMS$) AND LEN(TRIM$(COLUMNFORMS$(SUB))) then let FIELDFORMS$(INDEX)=COLUMNFORMS$(SUB)
12070             else 
12071 ! .           ! interpret ColumnForms as matching file record
12072                if INDEX<UDIM(MAT COLUMNFORMS$) AND LEN(TRIM$(COLUMNFORMS$(INDEX))) then 
12073                   let FIELDFORMS$(INDEX)=COLUMNFORMS$(INDEX)
12074                end if 
12075             end if 
12076          end if 
12077 ! 
12078          if BCOLUMNWIDTH then 
12079             if BORIGINALINCLUDE then 
12080 ! .           ! interpret ColumnDescription and ColumnWidth as matching original include
12081                let SUB=SRCH(MAT ORIGINALINCLUDECOLUMN$,OUTCOLUMNNAMES$(INDEX))
12082                if SUB>0 AND SUB<=UDIM(MAT COLUMNWIDTHS) then let OUTWIDTHS(INDEX)=COLUMNWIDTHS(SUB)
12083             else 
12084 ! .           ! interpret columndescription and Columnwidth as matching file record
12085                if INDEX<=UDIM(MAT COLUMNWIDTHS) then 
12086                   let OUTWIDTHS(INDEX)=COLUMNWIDTHS(INDEX)
12087                end if 
12088             end if 
12089          end if 
12090 ! 
12091       next INDEX
12092 ! 
12093       if DISPLAYSUB>0 AND DISPLAYSUB<=UDIM(MAT COLUMNNAMES$) then 
12094          let SUB=SRCH(MAT OUTCOLUMNNAMES$,COLUMNNAMES$(DISPLAYSUB))
12095          if SUB>0 then 
12096             let DISPLAYFIELDCONVERT$=FIELDFORMS$(SUB)
12097          end if 
12098       end if 
12099    fnend 
12100 ! 
12101 Getfieldnames: ! Get the field names from the layout file in strings first, numerics last order
12102    def FNGETFIELDNAMES(LAYOUT$*255,MAT FIELDNAMES$,MAT POSITIONS)
12103       dim STRINGSUBS$(1)*80,NUMSUBS$(1)*80,STRINGSPECS$(1)*80,NUMSPECS$(1)*80,STRINGDESC$(1)*80,NUMDESC$(1)*80,STRINGPOS(1),NUMPOS(1)
12104       let FNREADLAYOUTARRAYS(LAYOUT$,PREFIX$,MAT STRINGSUBS$,MAT NUMSUBS$,MAT STRINGSPECS$,MAT NUMSPECS$,MAT STRINGDESC$,MAT NUMDESC$,MAT STRINGPOS,MAT NUMPOS,0)
12105       let SUBCNT=UDIM(STRINGSUBS$)+UDIM(NUMSUBS$)
12106       mat FIELDNAMES$(SUBCNT)
12107       if UDIM(STRINGSUBS$) then mat FIELDNAMES$(1:UDIM(STRINGSUBS$))=STRINGSUBS$
12108       if UDIM(MAT NUMSUBS$) then mat FIELDNAMES$(UDIM(STRINGSUBS$)+1:UDIM(MAT FIELDNAMES$))=NUMSUBS$
12109       mat POSITIONS(SUBCNT)
12110       if UDIM(MAT STRINGPOS) then mat POSITIONS(1:UDIM(MAT STRINGPOS))=STRINGPOS
12111       if UDIM(MAT NUMPOS) then mat POSITIONS(UDIM(MAT STRINGPOS)+1:UDIM(MAT POSITIONS))=NUMPOS
12112    fnend 
12113 ! 
12114 ! 
12115    dim INPUTKEYFIELD$(2)
13000 ! #Autonumber# 13000,10
13010 Inputkey: ! ***** Prompts The User For The Key To Look Up In The Datafile
13020    def FNINPUTKEY(&KEY$,&RECORDNUM,DATAFILE,ROWS,COLS;PARENTWINDOW,___,WINDOW,FIELD$,SROW,SCOL,VIEWLENGTH,LENGTH,HEIGHT,RECORDLEN)
13030       let HEIGHT=1
13040       let RECORDLEN=LEN(STR$(LREC(DATAFILE)))+1
13050       if KLN(DATAFILE)>0 then 
13060 ! .     ! let Height+=1
13070          let LENGTH=KLN(DATAFILE)
13080       end if 
13090 ! 
13100 ! .  ! Uncomment the Hight code above and the Record num code below to
13110 ! .  !  enable both at the same time here. They also need to be enabled
13120 ! .  !  both at the same time in fnShowData by opening file twice,
13130 ! .  !  and using the correct file channel to search by key or by
13140 ! .  !  record number
13150 ! 
13160       let SROW=INT((ROWS-HEIGHT)/2)+1
13170       let VIEWLENGTH=MIN(COLS-2,MAX(LENGTH,RECORDLEN)+4)
13180       let VIEWLENGTH=MAX(VIEWLENGTH,15)
13190       let SCOL=INT((COLS-VIEWLENGTH)/2)+1
13200       open #(WINDOW:=FNGETFILENUMBER) : "srow="&STR$(SROW)&",scol="&STR$(SCOL)&",rows="&STR$(HEIGHT)&",cols="&STR$(VIEWLENGTH)&",Caption= Jump to ... ,Border=S,Parent="&STR$(PARENTWINDOW),display,output 
13210 ! 
13220       mat INPUTKEYFIELD$(HEIGHT)
13230       if KLN(DATAFILE)>0 then 
13240 ! .     ! print #Window, fields "1,1,CR 4;2,1,CR 4" : "Key:","Rec:"
13250          print #WINDOW, fields "1,1,CR 4" : "Key:"
13260          let INPUTKEYFIELD$(1)="1,6,"&STR$(MIN(VIEWLENGTH-6,LENGTH))&"/C "&STR$(LENGTH)
13270 ! .     ! let InputKeyField$(2)="2,6,"&str$(min(ViewLength-6,RecordLen))&"/N "&Str$(RecordLen)
13280          rinput #WINDOW, fields MAT INPUTKEYFIELD$ : KEY$  !,RecordNum conv Tryagain
13290       else 
13300          print #WINDOW, fields "1,1,CR 4" : "Rec:"
13310          let INPUTKEYFIELD$(1)="1,6,"&STR$(MIN(VIEWLENGTH-6,RECORDLEN))&"/N "&STR$(RECORDLEN)
13320          input #WINDOW, fields MAT INPUTKEYFIELD$ : RECORDNUM conv Tryagain
13330       end if 
13340       if FKEY=99 OR FKEY=93 then let RECORDNUM=0 : let KEY$=""
13350 ! 
13360       close #WINDOW: 
13370    fnend 
13380 ! 
13390 Updatecolors: ! ***** Update Listview Colors
13400    mat DC_COLORSTART(0) !:
         mat DC_COLOREND(0) !:
         mat DC_COLOR$(0)                   !Clear Color Markings
13410    for DELETEINDEX=1 to UDIM(MAT DC_DELETEROW)
13420       if DC_DELETEROW(DELETEINDEX) then ! If Row Is Marked For Deletion, Show It In Red
13430          mat DC_COLORSTART(UDIM(MAT DC_COLORSTART)+1) !:
               mat DC_COLOREND(UDIM(MAT DC_COLORSTART)) !:
               mat DC_COLOR$(UDIM(MAT DC_COLORSTART))  !Make Room !:
               let DC_COLORSTART(UDIM(MAT DC_COLORSTART)) = (((DELETEINDEX-1) * RECORDSIZE)+1) !:
               let DC_COLOREND(UDIM(MAT DC_COLORSTART)) = (DELETEINDEX * RECORDSIZE)
13440          if DC_DELETEROW(DELETEINDEX)=1 then !:
                  let DC_COLOR$(UDIM(MAT DC_COLORSTART)) = "/#FF0000:#FFFF00"  !Red With Yellow Background !:
               else !:
                  let DC_COLOR$(UDIM(MAT DC_COLORSTART)) = "/#000000:#FFFFFF"  !Black With White Background !:
                  let DC_DELETEROW(DELETEINDEX)=0
13450       end if 
13460    next DELETEINDEX
13470    if (UDIM(MAT DC_COLORSTART)) then !:
            print #WINDOW, fields GRIDSPEC$&",ATTR" : (MAT DC_COLORSTART, MAT DC_COLOREND, MAT DC_COLOR$)
13480    return 
13490 ! 
13500 ! 
13510    dim SEARCHFOR$*999
13520    dim SEARCHIN$*4000
13530    def FNSEARCHIN(&SEARCH$,MAT F$,MAT F;MAT SDATEFORMAT$,MAT NDATEFORMAT$,DATEFORMATDISPLAY$,BYPASSDATEPROCESSING,___,SEARCHCHUNK$*64,INDEX,FOUND,NUMBER,PASSING)
13540       let SEARCHFOR$=SEARCH$
13550 ! 
13560       do WHILE LEN(SEARCHFOR$)
13570          if POS(SEARCHFOR$," ") then 
13580             let SEARCHCHUNK$=LWRC$(TRIM$(SEARCHFOR$(1:POS(SEARCHFOR$," "))))
13590             let SEARCHFOR$(1:POS(SEARCHFOR$," "))=""
13600             let SEARCHFOR$=TRIM$(SEARCHFOR$)
13610          else 
13620             let SEARCHCHUNK$=LWRC$(TRIM$(SEARCHFOR$))
13630             let SEARCHFOR$=""
13640          end if 
13650 ! 
13660          let FOUND=0
13670          do 
13680             for INDEX=1 to UDIM(MAT F$)
13690                let SEARCHIN$=LWRC$(F$(INDEX))
13700                if ~BYPASSDATEPROCESSING AND LEN(TRIM$(SDATEFORMAT$(INDEX))) then 
13710                   let SEARCHIN$=FNFMTSDATE$(SEARCHIN$,SDATEFORMAT$(INDEX),DATEFORMATDISPLAY$)
13720                end if 
13730                if POS(SEARCHIN$,SEARCHCHUNK$) then 
13740                   let FOUND=1
13750                   exit do             !We're done searching as soon as we found it anywhere
13760                end if 
13770             next INDEX
13780 ! .     ! if fnIsNumber(SearchChunk$(1:120)) then
13790             for INDEX=1 to UDIM(MAT F)
13800                let SEARCHIN$=STR$(F(INDEX))
13810                if ~BYPASSDATEPROCESSING AND LEN(TRIM$(NDATEFORMAT$(INDEX))) then 
13820                   let SEARCHIN$=FNFMTNDATE$(F(INDEX),NDATEFORMAT$(INDEX),DATEFORMATDISPLAY$)
13830                end if 
13840                if POS(SEARCHIN$,SEARCHCHUNK$) then 
13850                   let FOUND=1
13860                   exit do             !We're done searching as soon as we found it anywhere
13870                end if 
13880             next INDEX
13890 ! .     ! end if
13900          loop UNTIL 1
13910       loop WHILE FOUND                !Every chunk has to be found for it to be legit.
13920       let FNSEARCHIN=FOUND
13930    fnend 
13940 ! 
13950    def FNISNUMBER(STRING$*120;___,TESTNUMBER)
13960       let TESTNUMBER=VAL(STRING$) conv Notnumber
13970       let FNISNUMBER=1
13980 Notnumber: ! Not a number
13990    fnend 
14000 ! 
15000 ! #Autonumber# 15000,2
15002    dim TEMPLATEPROG$(1)*255,TEMPLATEDESC$(1)*255,TEMPLATENUM(1),TEMPLATECHOICE$*255
15004 Generatecode: ! This function generates code if code templates are available
15006    def FNGENERATECODE(FILELAY$;___,TEMPLATECHOICE)
15008       library : FNASKCOMBO$
15010       mat TEMPLATEPROG$(0)
15012       mat TEMPLATEDESC$(0)
15014 ! 
15016 ! .  ! Read the Templates Directory
15018       let FNREADTEMPLATES(MAT TEMPLATEPROG$,MAT TEMPLATEDESC$,MAT TEMPLATENUM)
15020 ! 
15022       if UDIM(MAT TEMPLATEDESC$) then 
15024          let TEMPLATECHOICE$=FNASKCOMBO$(MAT TEMPLATEDESC$,"Select Template")
15026 ! 
15028 ! .     ! code templates are library functions. They can do their own input/output.
15030          let TEMPLATECHOICE=SRCH(MAT TEMPLATEDESC$,TEMPLATECHOICE$)
15032          if TEMPLATECHOICE>0 then 
15034             library TEMPLATEPROG$(TEMPLATECHOICE) : FNTEMPLATELIST, FNRUNTEMPLATE
15036             let FNRUNTEMPLATE(TEMPLATENUM(TEMPLATECHOICE),FILELAY$)
15038          end if 
15040 ! 
15042       else 
15044          let MSGBOX("No valid templates were found.","No Templates")
15046       end if 
15048    fnend 
15050 ! 
15052    def library FNASKCOMBO$*255(MAT DESCRIPTION$;CAPTION$*60,DEFAULT$*255,___,WINDOW,CHOICE$*255,SCREENROWS,SCREENCOLS,SROW,SCOL)
15054       library : FNGETFILENUMBER
15056       if CAPTION$="" then let CAPTION$="Select"
15058 ! 
15060       let FNREADSCREENS(SCREENROWS,SCREENCOLS)
15062 ! 
15064       let SROW=INT((SCREENROWS-3)/2)+1
15066       let SCOL=INT((SCREENCOLS-20)/2)+1
15068 ! 
15070 ! .  ! Open child window
15072       open #(WINDOW:=FNGETFILENUMBER): "SROW="&STR$(SROW)&", SCOL="&STR$(SCOL)&", ROWS=3, COLS=20, Border=S, Caption="&CAPTION$,display,outin 
15074 ! 
15076       let CHOICE$=DEFAULT$
15078 ! 
15080 ! .  ! allow user to select code template
15082       print #WINDOW, fields "3,7,CC 7,/W:W,B0" : "Ok"
15084       print #WINDOW, fields "1,2,17/COMBO 255,=,SELECT" : MAT DESCRIPTION$
15086       rinput #WINDOW, fields "1,2,17/COMBO 255,/W:W,SELECT" : CHOICE$
15088 ! 
15090       close #WINDOW: 
15092       let FNASKCOMBO$=CHOICE$
15094    fnend 
15096 ! 
15098 ! .! Define Listviews
15100    dim LAYOUTWIZARD_LV1_CAPTIONS$(1), LAYOUTWIZARD_LV1_WIDTHS(1), LAYOUTWIZARD_LV1_SPECS$(1)
15102    dim LAYOUTWIZARD_LV1_SPEC$*40, LAYOUTWIZARD_LV1_POPSPEC$*40
15104 ! 
15106 ! .! Declare Variables
15108    dim LW_OUTPUT_SPEC$(17)*60,LW_OUTPUT_DATA$(17)*60
15110    dim LW_INPUT_SPEC$(5)*255,LW_INPUT_DATA$(5)*1000
15112    dim OPENSTRING$(1)*999
15114 Layoutwizard: ! This function gives a dialog from which programmers can quickly generate file layouts
15116    def FNLAYOUTWIZARD(;___,WINDOW,SCREENROWS,SCREENCOLS,SROW,SCOL,EXITMODE,GENERATE,FUNCTION,FILEBROWSER,INDEX,JNDEX,CURFIELD)
15118 ! 
15120       let FNREADSCREENS(SCREENROWS,SCREENCOLS)
15122 ! 
15124       let SROW=INT((SCREENROWS-22)/2)+1
15126       let SCOL=INT((SCREENCOLS-60)/2)+1
15128 ! 
15130 ! .  ! Read Specs for Output Controls
15132 Layoutwizarddata: restore Layoutwizarddata  !Restore Data Statements
15134 ! 
15136       read MAT LW_OUTPUT_SPEC$
15138       data "22,44,14/CC 15,/W:W,B1504","2,1,11/C 12"
15140       data "7,1,13/C 15","12,1,13/C 15"
15142       data "22,27,14/CC 6,/W:W,B1508","17,1,13/C 15"
15144       data "1,1,8/CR 9","1,41,8/CC 6,/W:W,B1513"
15146 ! 
15148       data "1,51,8/CC 8,/W:W,B1514","2,16,8/CC 4,/W:W,B1515"
15150       data "7,16,8/CC 4,/W:W,B1516","12,16,8/CC 4,/W:W,B1517"
15152       data "17,16,8/CC 4,/W:W,B1518","2,27,8/CC 5,/W:W,B1520"
15154       data "2,41,8/CC 9,/W:W,B1521","2,51,8/CC 8,/W:W,B1522"
15156       data "22,4,17/CC 16,/W:W,B1523"
15158 ! 
15160       read MAT LW_OUTPUT_DATA$
15162       data "Generate Layout","Open String:","Read Statement:","Form Statement:"
15164       data "Done","Dim Statements:","Program:","Browse"
15166       data "Search","Scan","Scan","Scan","Scan"
15168       data "Paste","Clear All","Scan All"
15170       data "Open Scratch Pad"
15172 ! 
15174 ! .  ! Read Specs for Input Controls
15176       read MAT LW_INPUT_SPEC$
15178       data "1,10,28/V 999,S/W:W"
15180       data "3,1,GRID 4/60,ROW,ALL"
15182       data "8,1,240/V 999,^ENTER_CRLFS/W:W","13,1,240/V 999,^ENTER_CRLFS/W:W"
15184       data "18,1,240/V 999,^ENTER_CRLFS/W:W"
15186 ! 
15188       read LAYOUTWIZARD_LV1_SPEC$
15190       data "3,1,GRID 4/60,HEADERS,/W:W"
15192       read LAYOUTWIZARD_LV1_POP$
15194       data "3,1,GRID 4/60,="
15196 ! 
15198 ! .  ! Fix for earlier versions of BR that don't support ENTER_CRLFS
15200       if ~FN42IA then 
15202          for INDEX=1 to UDIM(MAT LW_INPUT_SPEC$)
15204             let LW_INPUT_SPEC$(INDEX)=SREP$(LW_INPUT_SPEC$(INDEX),"^ENTER_CRLFS","")
15206          next INDEX
15208       else if ~FN42J then 
15210          for INDEX=1 to UDIM(MAT LW_INPUT_SPEC$)
15212             let LW_INPUT_SPEC$(INDEX)=SREP$(LW_INPUT_SPEC$(INDEX),"^ENTER_CRLFS","^ENTER-CRLFS")
15214          next INDEX
15216       end if 
15218 ! 
15220       read MAT LAYOUTWIZARD_LV1_CAPTIONS$
15222       data "Open String"
15224       read MAT LAYOUTWIZARD_LV1_WIDTHS
15226       data 40
15228       read MAT LAYOUTWIZARD_LV1_SPECS$
15230       data "V 999,E"
15232 ! 
15234       read LW_GENERATE,LW_DONE,LW_BROWSE,LW_SCANPROGRAM,LW_SCANOPEN,LW_SCANREAD,LW_SCANFORM,LW_SCANDIM,LW_PASTEOPEN,LW_CLEARALL,LW_SCANALL,LW_OPENSCRATCHPAD
15236       data 1504,1508,1513,1514,1515,1516,1517,1518,1520,1521,1522,1523
15238 ! 
15240       read LW_PROGRAMNAME,LW_READSTRING,LW_FORMSTRING,LW_DIMSTRING
15242       data 1,2,3,4
15244 ! 
15246       let FNBUILDSRCHHELP(1)
15248 ! 
15250 ! .  ! Open Screen
15252       open #(WINDOW:=FNGETFILENUMBER): "SROW="&STR$(SROW)&", SCOL="&STR$(SCOL)&", ROWS=22, COLS=60, Border=S, Caption=File Layout Wizard",display,outin 
15254 ! 
15256       print #WINDOW, fields MAT LW_OUTPUT_SPEC$ : MAT LW_OUTPUT_DATA$
15258       print #WINDOW, fields LAYOUTWIZARD_LV1_SPEC$ : (MAT LAYOUTWIZARD_LV1_CAPTIONS$, MAT LAYOUTWIZARD_LV1_WIDTHS, MAT LAYOUTWIZARD_LV1_SPECS$)
15260 ! 
15262 ! .  ! Main input loop here
15264       do 
15266 ! .     ! Trim spaces in mat open string
15268          let JNDEX=0
15270          for INDEX=1 to UDIM(MAT OPENSTRING$)
15272             if LEN(TRIM$(OPENSTRING$(INDEX))) then 
15274                let JNDEX+=1
15276                let OPENSTRING$(JNDEX)=TRIM$(OPENSTRING$(INDEX))
15278             end if 
15280          next INDEX
15282          mat OPENSTRING$(JNDEX+1) : let OPENSTRING$(JNDEX+1)=""  !add 1
15284 ! 
15286          let CURFLD(CURFIELD,FUNCTION)
15288 ! .     ! populate it
15290          print #WINDOW, fields LAYOUTWIZARD_LV1_POP$ : MAT OPENSTRING$
15292          rinput #WINDOW, fields MAT LW_INPUT_SPEC$ : MAT LW_INPUT_DATA$(1:1),MAT OPENSTRING$,MAT LW_INPUT_DATA$(2:4)
15294          let FUNCTION=FKEY
15296          let CURFIELD=CURFLD
15298 ! 
15300          if FUNCTION = 99 OR FUNCTION = 93 OR FUNCTION = LW_DONE then ! #Select# Function #Case# 99 # 93 # lw_Done
15302             let EXITMODE=1
15304          else if FUNCTION = LW_BROWSE then ! #Case# lw_Browse
15306 ! .        ! Browse for a data file
15308             open #(FILEBROWSER:=FNGETFILENUMBER): "name=OPEN:.|*.wb;*.br,recl=1000",external,input ioerr IGNORE
15310             if FILE(FILEBROWSER)>-1 then 
15312                let LW_INPUT_DATA$(LW_PROGRAMNAME)=FILE$(FILEBROWSER)
15314                close #FILEBROWSER: 
15316                if LWRC$(LW_INPUT_DATA$(LW_PROGRAMNAME))(1:2)="c:" then 
15318                   let LW_INPUT_DATA$(LW_PROGRAMNAME)=LW_INPUT_DATA$(LW_PROGRAMNAME)(3:999)
15320                   let FNSCANALL(MAT LW_INPUT_DATA$,MAT OPENSTRING$)
15322                end if 
15324             end if 
15326          else if FUNCTION = LW_SCANPROGRAM then ! #Case# lw_ScanProgram
15328             let FNSEARCHPROGRAMS(MAT OPENSTRING$,LW_INPUT_DATA$(LW_PROGRAMNAME),1)
15330          else if FUNCTION = LW_SCANOPEN then ! #Case# lw_ScanOpen
15332             let FNSEARCHOPENSTRING(MAT LW_INPUT_DATA$,MAT OPENSTRING$,1)
15334          else if FUNCTION = LW_SCANREAD then ! #Case# lw_ScanRead
15336             let FNSEARCHREAD(MAT LW_INPUT_DATA$,MAT OPENSTRING$,1)
15338          else if FUNCTION = LW_SCANFORM then ! #Case# lw_ScanForm
15340             let FNSEARCHFORM(MAT LW_INPUT_DATA$,1)
15342          else if FUNCTION = LW_SCANDIM then ! #Case# lw_ScanDim
15344             let FNSEARCHDIM(MAT LW_INPUT_DATA$,1)
15346          else if FUNCTION = LW_SCANALL then ! #Case# lw_ScanAll
15348             let FNSCANALL(MAT LW_INPUT_DATA$,MAT OPENSTRING$)
15350          else if FUNCTION = LW_CLEARALL then ! #Case# lw_ClearAll
15352             mat OPENSTRING$(1)=("")
15354             let LW_INPUT_DATA$(LW_READSTRING)=""
15356             let LW_INPUT_DATA$(LW_FORMSTRING)=""
15358             let LW_INPUT_DATA$(LW_DIMSTRING)=""
15360          else if FUNCTION = LW_PASTEOPEN then ! #Case# lw_PasteOpen
15362             mat OPENSTRING$(0)
15364             let SD_DIM$=ENV$("clipboard")
15366             let SD_DIM$=SREP$(SD_DIM$,CHR$(13),CHR$(10))
15368             let SD_DIM$=SREP$(SD_DIM$,CHR$(10)&CHR$(10),CHR$(10))
15370             do WHILE POS(SD_DIM$,CHR$(10))
15372                mat OPENSTRING$(UDIM(MAT OPENSTRING$)+1)
15374                let OPENSTRING$(UDIM(MAT OPENSTRING$))=TRIM$(SD_DIM$(1:POS(SD_DIM$,CHR$(10))-1))
15376                let SD_DIM$(1:POS(SD_DIM$,CHR$(10)))=""
15378             loop 
15380             if LEN(TRIM$(SD_DIM$)) then 
15382                mat OPENSTRING$(UDIM(MAT OPENSTRING$)+1)
15384                let OPENSTRING$(UDIM(MAT OPENSTRING$))=TRIM$(SD_DIM$)
15386                let SD_DIM$=""
15388             end if 
15390          else if FUNCTION = LW_OPENSCRATCHPAD then ! #Case# lw_OpenScratchPad
15392             let FNOPENSCRATCHFILE
15394          else if FUNCTION = LW_GENERATE then ! #Case# lw_Generate
15396             let EXITMODE=FNGENERATELAY(MAT OPENSTRING$,LW_INPUT_DATA$(LW_READSTRING),LW_INPUT_DATA$(LW_FORMSTRING),LW_INPUT_DATA$(LW_DIMSTRING),1)
15398          end if                       !#End Select#
15400 ! 
15402       loop UNTIL EXITMODE
15404 ! 
15406       close #WINDOW: 
15408    fnend 
15410 ! 
15412    def FNSCANALL(MAT LW_INPUT_DATA$,MAT OPENSTRING$)
15414       if FNISEMPTYS(MAT OPENSTRING$) then let FNSEARCHOPENSTRING(MAT LW_INPUT_DATA$,MAT OPENSTRING$,1)
15416       let FNSEARCHREAD(MAT LW_INPUT_DATA$,MAT OPENSTRING$,1)
15418       let FNSEARCHFORM(MAT LW_INPUT_DATA$,1)
15420       let FNSEARCHDIM(MAT LW_INPUT_DATA$,1)
15422    fnend 
15424 ! 
15426 ! .! 1) Program Name - Search all programs for open statements for the given file name
15428 ! .! if found, return program name and open statements
15430    dim FILELIST$(1)*255, SP_FILENAME$(1)*255
15432    def FNSEARCHPROGRAMS(MAT OPENSTRING$,FOLDER$*255;___,INDEX,OPENINDEX,FILENAME$*255,FILEINDEX,G$)
15434 ! 
15436       if POS(FOLDER$,"\") then let FOLDER$=FOLDER$(1:POS(FOLDER$,"\",-1)-1)
15438       mat SP_FILENAME$(0)
15440       for OPENINDEX=1 to UDIM(MAT OPENSTRING$)
15442          let FILENAME$=LWRC$(TRIM$(FNEXTRACTFILENAME$(OPENSTRING$(OPENINDEX))))
15444          if LEN(FILENAME$) AND SRCH(MAT SP_FILENAME$,FILENAME$)<=0 then 
15446             let FILEINDEX=UDIM(MAT SP_FILENAME$)+1
15448             mat SP_FILENAME$(FILEINDEX)
15450             let SP_FILENAME$(FILEINDEX)=FILENAME$
15452          end if 
15454       next OPENINDEX
15456 ! 
15458       if UDIM(MAT SP_FILENAME$) then 
15460          mat FILELIST$(0)
15462          library : FNREADFILES
15464          let FNREADFILES(MAT FILELIST$,TRIM$(FOLDER$),"br ",1,0,1)
15466          let FNREADFILES(MAT FILELIST$,TRIM$(FOLDER$),"wb ",0,0,1)
15468 ! 
15470          for INDEX=1 to UDIM(MAT FILELIST$)
15472             if LWRC$(TRIM$(FILELIST$(INDEX)))<>"screenio.br" then 
15474                let FNBUILDPROC("load """&TRIM$(FOLDER$)&"\"&TRIM$(FILELIST$(INDEX))&"""")
15476                let G$=">"
15478                for FILEINDEX=1 to UDIM(MAT SP_FILENAME$)
15480                   let FNBUILDPROC("list 'open' '"&SP_FILENAME$(FILEINDEX)&"' "&G$&"temp.[wsid]")
15482                   let G$=">>"
15484                next FILEINDEX
15486                let FNBUILDPROC("run srchhelp")
15488                let FNBUILDPROC("skip "&STR$(UDIM(MAT SP_FILENAME$)*2+4)&" if code")
15490                let FNPROCPRINTTOFILE(TRIM$(FOLDER$)&"\"&TRIM$(FILELIST$(INDEX)))
15492                let FNBUILDPROC("load """&TRIM$(FOLDER$)&"\"&TRIM$(FILELIST$(INDEX))&"""")
15494                for FILEINDEX=1 to UDIM(MAT SP_FILENAME$)
15496                   let FNPROCLISTTOFILE("'open' '"&SP_FILENAME$(FILEINDEX)&"'")
15498                next FILEINDEX
15500             end if 
15502          next INDEX
15504 ! 
15506          let FNPROCSHOWFILE
15508          let FNRUNPROC
15510       end if 
15512    fnend 
15514 ! 
15516    dim RESULTSTRING$*800,SO_FILENAME$*127,SO_RESULTS$(1)*800,SO_FILES$(1)*127,SO_COUNT(1)
15518 ! 
15520 ! .! 2) Open String - list all "open" and "internal" statements
15522    def FNSEARCHOPENSTRING(MAT LW_INPUT_DATA$,MAT OPENSTRING$;DONTSHOWFILE,___,RESULTSFILE,INDEX,LARGEST,LARGEINDEX,JNDEX)
15524       if LEN(TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))) then 
15526          let FNBUILDPROC("load """&TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))&"""")
15528          let FNPROCLISTTOFILE("'open' 'internal'")
15530          if ~DONTSHOWFILE then let FNPROCSHOWFILE
15532          let FNCLEARTEMPFILE
15534          let FNRUNPROC
15536 ! 
15538          if EXISTS("work.[wsid]") then 
15540             open #(RESULTSFILE:=FNGETFILENUMBER): "name=work.[wsid],recl=800",display,input 
15542             mat SO_RESULTS$(0) : mat SO_FILES$(0) : mat SO_COUNT(0)
15544             do UNTIL FILE(RESULTSFILE)
15546                linput #RESULTSFILE: RESULTSTRING$ error IGNORE
15548                if FILE(RESULTSFILE)=0 then 
15550                   let SO_FILENAME$=LWRC$(TRIM$(FNEXTRACTFILENAME$(RESULTSTRING$)))
15552                   if LEN(SO_FILENAME$) then 
15554                      let INDEX=UDIM(MAT SO_RESULTS$)+1
15556                      mat SO_RESULTS$(INDEX)
15558                      let SO_RESULTS$(INDEX)=TRIM$(RESULTSTRING$)
15560                      let INDEX=SRCH(MAT SO_FILES$,SO_FILENAME$)
15562                      if INDEX>0 then 
15564                         let SO_COUNT(INDEX)+=1
15566                      else 
15568                         let INDEX=UDIM(MAT SO_FILES$)+1
15570                         mat SO_FILES$(INDEX) : mat SO_COUNT(INDEX)
15572                         let SO_FILES$(INDEX)=SO_FILENAME$
15574                         let SO_COUNT(INDEX)+=1
15576                      end if 
15578                   end if 
15580                end if 
15582             loop 
15584             close #RESULTSFILE: 
15586 ! 
15588             for INDEX=1 to UDIM(MAT SO_COUNT)
15590                if SO_COUNT(INDEX)>LARGEST then 
15592                   let LARGEST=SO_COUNT(INDEX)
15594                   let LARGEINDEX=INDEX
15596                end if 
15598             next INDEX
15600 ! 
15602             let JNDEX=0
15604             for INDEX=1 to UDIM(MAT SO_RESULTS$)
15606                if SO_FILES$(LARGEINDEX)=LWRC$(TRIM$(FNEXTRACTFILENAME$(SO_RESULTS$(INDEX)))) then 
15608                   let JNDEX+=1
15610                   let SO_RESULTS$(JNDEX)=SO_RESULTS$(INDEX)
15612                end if 
15614             next INDEX
15616             mat SO_RESULTS$(JNDEX)
15618             if JNDEX then 
15620                mat OPENSTRING$(JNDEX)=SO_RESULTS$
15622             end if 
15624          end if 
15626       end if 
15628    fnend 
15630 ! 
15632 ! .! 3) Read Statement - Parse Open String, look for file number
15634 ! .! or variable name. list all read statements with that file
15636 ! .! number or variable name
15638    dim VAR$*255
15640    def FNSEARCHREAD(MAT LW_INPUT_DATA$,MAT OPENSTRING$;DONTSHOWFILE,___,KEYINDEX,ANYTHING,RESULTSFILE,LARGEST,LARGEINDEX)
15642       if LEN(TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))) then 
15644 ! 
15646          for KEYINDEX=1 to UDIM(MAT OPENSTRING$)
15648 ! .        ! parse the open statements
15650             if LEN(TRIM$(OPENSTRING$(KEYINDEX))) then 
15652                let VAR$=FNEXTRACTOPENVAR$(OPENSTRING$(KEYINDEX))  !Attempt to find open variable
15654                let FNBUILDPROC("load """&TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))&"""")
15656                let FNPROCLISTTOFILE("'read' '#"&VAR$&"'")
15658                let ANYTHING=1
15660             end if 
15662          next KEYINDEX
15664 ! 
15666          if ~ANYTHING then 
15668 ! .        ! Scan the given file for all read statements if Open string didn't work
15670             let FNBUILDPROC("load """&TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))&"""")
15672             let FNPROCLISTTOFILE("'read'")
15674          end if 
15676 ! 
15678          if ~DONTSHOWFILE then let FNPROCSHOWFILE
15680          let FNCLEARTEMPFILE
15682          let FNRUNPROC
15684 ! 
15686          if EXISTS("work.[wsid]") then 
15688             open #(RESULTSFILE:=FNGETFILENUMBER): "name=work.[wsid],recl=800",display,input 
15690             mat SO_RESULTS$(0)
15692             do UNTIL FILE(RESULTSFILE)
15694                linput #RESULTSFILE: RESULTSTRING$ error IGNORE
15696                if FILE(RESULTSFILE)=0 then 
15698                   let INDEX=UDIM(MAT SO_RESULTS$)+1
15700                   mat SO_RESULTS$(INDEX)
15702                   let SO_RESULTS$(INDEX)=TRIM$(RESULTSTRING$)
15704                   if LEN(SO_RESULTS$(INDEX))>LARGEST then 
15706                      let LARGEST=LEN(SO_RESULTS$(INDEX))
15708                      let LARGEINDEX=INDEX
15710                   end if 
15712                end if 
15714             loop 
15716             close #RESULTSFILE: 
15718             if LARGEINDEX then let LW_INPUT_DATA$(LW_READSTRING)=SO_RESULTS$(LARGEINDEX)
15720          end if 
15722       end if 
15724    fnend 
15726 ! 
15728 ! 
15730 ! .! 4) Form Statement - Parse Read Statement, look for "Using lineref". If lineref is not a variable,
15732 ! .! (doesn't contain a "$"), then list that line. If it does contain a dollar sign, then list that
15734 ! .! variable to see where it gets set.
15736    dim LINEREF$*800
15738    def FNSEARCHFORM(MAT LW_INPUT_DATA$;DONTSHOWFILE,___,NOPROC,INDEX,LARGEINDEX,LARGEST,RESULTSFILE)
15740       if LEN(TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))) then 
15742          if LEN(TRIM$(LW_INPUT_DATA$(LW_READSTRING))) then 
15744             let LINEREF$=FNEXTRACTLINEREF$(LW_INPUT_DATA$(LW_READSTRING))  !Attempt to find read string
15746             if LINEREF$="" then 
15748                let NOPROC=1
15750             else if LWRC$(LINEREF$(1:5))="""form" then 
15752                let LW_INPUT_DATA$(LW_FORMSTRING)=TRIM$(LINEREF$,"""")
15754                let NOPROC=1
15756             else if POS(LINEREF$,"$") then 
15758                let FNBUILDPROC("load """&TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))&"""")
15760                let FNBUILDPROC("list '"&LINEREF$&"' >temp.[wsid]")  !Attempt to use line ref
15762                let FNBUILDPROC("run srchhelp")  !check if it worked
15764                let FNBUILDPROC("skip printregular if code")  !if it failed, jump to regular print
15766                let FNBUILDPROC("load """&TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))&"""")  !if it worked, then use it
15768                let FNPROCLISTTOFILE(LINEREF$)
15770                let FNBUILDPROC("skip finished")  !Skip regular print if it worked
15772             else 
15774                let FNBUILDPROC("load """&TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))&"""")
15776                let FNBUILDPROC("list "&LINEREF$&" >temp.[wsid]")  !Attempt to use line ref
15778                let FNBUILDPROC("run srchhelp")  !check if it worked
15780                let FNBUILDPROC("skip printregular if code")  !if it failed, jump to regular print
15782                let FNBUILDPROC("load """&TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))&"""")  !if it worked, then use it
15784                let FNPROCLISTTOFILE(LINEREF$,1)
15786                let FNBUILDPROC("skip finished")  !Skip regular print if it worked
15788             end if 
15790          end if 
15792          if ~NOPROC then 
15794             let FNBUILDPROC(":printregular")
15796             let FNBUILDPROC("load """&TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))&"""")
15798             let FNPROCLISTTOFILE("form")
15800             let FNBUILDPROC(":finished")
15802             if ~DONTSHOWFILE then let FNPROCSHOWFILE
15804             let FNCLEARTEMPFILE
15806             let FNRUNPROC
15808 ! 
15810             if EXISTS("work.[wsid]") then 
15812                open #(RESULTSFILE:=FNGETFILENUMBER): "name=work.[wsid],recl=800",display,input 
15814                mat SO_RESULTS$(0)
15816                do UNTIL FILE(RESULTSFILE)
15818                   linput #RESULTSFILE: RESULTSTRING$ error IGNORE
15820                   if FILE(RESULTSFILE)=0 then 
15822                      let INDEX=UDIM(MAT SO_RESULTS$)+1
15824                      mat SO_RESULTS$(INDEX)
15826                      let SO_RESULTS$(INDEX)=TRIM$(RESULTSTRING$)
15828                      if LEN(SO_RESULTS$(INDEX))>LARGEST then 
15830                         let LARGEST=LEN(SO_RESULTS$(INDEX))
15832                         let LARGEINDEX=INDEX
15834                      end if 
15836                   end if 
15838                loop 
15840                close #RESULTSFILE: 
15842                if LARGEINDEX then let LW_INPUT_DATA$(LW_FORMSTRING)=SO_RESULTS$(LARGEINDEX)
15844             end if 
15846 ! 
15848          end if 
15850       end if 
15852    fnend 
15854 ! 
15856    dim SD_ARRAYS$(1)*127
15858    dim SD_DIM$*20000
15860 ! 
15862 ! .! 5) Dim Statement - Parse Read Statement, look for any "Mat" variables. for each one thats found, load
15864 ! .! the program, list 'dim' 'arrayname'. If no read statement, list all dims
15866    def FNSEARCHDIM(MAT LW_INPUT_DATA$;DONTSHOWFILE,___,TPOS,STRING$*999,SPOS,CPOS,XPOS,INDEX,RESULTSFILE)
15868       if LEN(TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))) then 
15870          let FNBUILDPROC("load """&TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))&"""")
15872          if LEN(TRIM$(LW_INPUT_DATA$(LW_READSTRING))) then 
15874             mat SD_ARRAYS$(0)
15876             let TPOS=0
15878             let STRING$=LWRC$(TRIM$(LW_INPUT_DATA$(LW_READSTRING)))
15880             do WHILE (TPOS:=POS(STRING$,"mat"))
15882                let CPOS=POS(STRING$,",",TPOS+4)
15884                let SPOS=POS(STRING$," ",TPOS+4)
15886                if CPOS AND SPOS then 
15888                   let XPOS=MIN(CPOS,SPOS)  !whichever comes first
15890                else 
15892                   let XPOS=MAX(CPOS,SPOS)  !whichever one there is
15894                end if 
15896                if ~XPOS then let XPOS=LEN(STRING$)+1  !the rest of the string
15898 ! 
15900                let VAR$=TRIM$(STRING$(TPOS+3:XPOS-1))
15902                let STRING$=STRING$(XPOS-1:LEN(STRING$))
15904                let FNPROCLISTTOFILE("'dim' '"&VAR$&"('")
15906                let INDEX=UDIM(MAT SD_ARRAYS$)+1
15908                mat SD_ARRAYS$(INDEX)
15910                let SD_ARRAYS$(INDEX)=VAR$
15912             loop 
15914          else 
15916             let FNPROCLISTTOFILE("dim")
15918          end if 
15920          if ~DONTSHOWFILE then let FNPROCSHOWFILE
15922          let FNCLEARTEMPFILE
15924          let FNRUNPROC
15926 ! 
15928          if EXISTS("work.[wsid]") then 
15930             open #(RESULTSFILE:=FNGETFILENUMBER): "name=work.[wsid],recl=800",display,input 
15932             let SD_DIM$=""
15934             do UNTIL FILE(RESULTSFILE)
15936                linput #RESULTSFILE: RESULTSTRING$ error IGNORE
15938                if FILE(RESULTSFILE)=0 then 
15940                   let SD_DIM$=SD_DIM$&LWRC$(TRIM$(RESULTSTRING$))
15942                end if 
15944             loop 
15946             let LW_INPUT_DATA$(LW_DIMSTRING)="dim "
15948             for INDEX=1 to UDIM(MAT SD_ARRAYS$)
15950                let LW_INPUT_DATA$(LW_DIMSTRING)=LW_INPUT_DATA$(LW_DIMSTRING)&SD_ARRAYS$(INDEX)&"("&STR$(FNREADARRAYSIZE(SD_DIM$,SD_ARRAYS$(INDEX)))&"), "
15952             next INDEX
15954             close #RESULTSFILE: 
15956          end if 
15958       end if 
15960    fnend 
15962 ! 
15964 ! 
15966    def library FNREADFILES(MAT FILES$,FOLDER$*255;EXTENSION$,CLEARARRAY,CREATEFOLDER,INCLUDEEXTENSIONS,USEWINDOWSDIR,___,DIRFILE,DUMMY$*255,DIRMASK$*400,STAR$)
15968 ! .  ! Note: The UseWindowsDIR parameter uses the windows Dir command instead of BRs in order to read long file names. It will not work under linux.
15970 ! 
15972       let STAR$=FNNEEDSTAR$
15974       if CLEARARRAY then mat FILES$(0)
15976 ! 
15978       if CREATEFOLDER then 
15980          if ~EXISTS(FOLDER$) then execute STAR$&"mkdir "&FOLDER$
15982       end if 
15984 ! 
15986       if ~LEN(TRIM$(EXTENSION$)) then let EXTENSION$="*"
15988       let DIRMASK$=FOLDER$&"\*."&LWRC$(EXTENSION$)
15990 ! 
15992       if USEWINDOWSDIR then 
15994          let FNWINDOWSREADFILES
15996       else 
15998          let FNSTANDARDREADFILES
16000       end if 
16002    fnend 
16004 ! 
16006 ! .! These two functions act globally like they're a part of fnReadFiles above.
16008    def FNWINDOWSREADFILES(;___,FILENAME$*255,EXT$*255)
16010       execute STAR$&"system -M dir "&OS_FILENAME$(DIRMASK$)&" >dirlist."&SESSION$ error Skipreadwindows
16012       open #(DIRFILE:=FNGETFILENUMBER) : "Name=dirlist.[SESSION], recl=255", display,input 
16014       do 
16016          linput #DIRFILE: DUMMY$ eof IGNORE
16018          if FILE(DIRFILE)=0 AND DUMMY$(3:3)="/" AND DUMMY$(6:6)="/" AND ~POS(DUMMY$,"<DIR>") then 
16020             let FILENAME$=TRIM$(DUMMY$(40:999))
16022             let EXT$=""
16024             if POS(FILENAME$,".")>0 then 
16026                let EXT$=FILENAME$(POS(FILENAME$,".",-1)+1:999)
16028                if ~INCLUDEEXTENSIONS then 
16030                   let FILENAME$(POS(FILENAME$,".",-1):999)=""
16032                end if 
16034             end if 
16036 ! 
16038             if EXTENSION$="*" OR UPRC$(EXT$)=UPRC$(EXTENSION$) then 
16040                mat FILES$(UDIM(FILES$)+1)
16042                let FILES$(UDIM(FILES$))=FILENAME$
16044             end if 
16046          end if 
16048       loop WHILE FILE(DIRFILE)=0
16050       close #DIRFILE: 
16052 Skipreadwindows: ! 
16054       execute STAR$&"free dirlist.[SESSION]"
16056    fnend 
16058 ! 
16060 ! .! These two functions act globally like they're a part of fnReadFiles above.
16062    def FNSTANDARDREADFILES
16064       execute STAR$&"dir "&DIRMASK$&" >dirlist.[SESSION]" error Skipreadstandard
16066       open #(DIRFILE:=FNGETFILENUMBER) : "Name=dirlist.[SESSION]", display,input 
16068       do 
16070          linput #DIRFILE: DUMMY$ eof IGNORE
16072          if FILE(DIRFILE)=0 AND ~POS(DUMMY$,"<DIR>") then 
16074             if EXTENSION$="*" OR UPRC$(DUMMY$(11:13))=UPRC$(EXTENSION$) then 
16076                if LWRC$(DUMMY$(1:13))><"directory of " then 
16078                   if ~(POS(DUMMY$," Files, ") AND POS(DUMMY$," Kilobytes Used, ") AND POS(DUMMY$," Kilobytes Free")) then 
16080                      mat FILES$(UDIM(FILES$)+1)
16082                      let FILES$(UDIM(FILES$))=LWRC$(TRIM$(DUMMY$(44:99))(1:32))
16084                      if POS(LWRC$(FILES$(UDIM(FILES$))),".")>0 then 
16086                         let FILES$(UDIM(FILES$))=FILES$(UDIM(FILES$))(1:POS(LWRC$(FILES$(UDIM(FILES$))),".")-1)
16088                         if INCLUDEEXTENSIONS then 
16090                            let FILES$(UDIM(FILES$))=FILES$(UDIM(FILES$))&"."&LWRC$(DUMMY$(11:13))
16092                         end if 
16094                      end if 
16096                   end if 
16098                end if 
16100             end if 
16102          end if 
16104       loop WHILE FILE(DIRFILE)=0
16106       close #DIRFILE: 
16108 Skipreadstandard: ! 
16110       execute STAR$&"free dirlist.[SESSION]"
16112    fnend 
16114 ! 
16116    def FNEXTRACTFILENAME$*255(&OPENSTRING$)=FNEXTRACTNAME$("name=",OPENSTRING$)
16118    def FNEXTRACTKEYFILENAME$*255(&OPENSTRING$)=FNEXTRACTNAME$("kfname=",OPENSTRING$)
16120    def FNEXTRACTNAME$*255(SEARCHSTRING$,&OPENSTRING$;___,TPOS,RETURNNAME$*255,SPOS,SEARCHSTRINGLEN)
16122       let TPOS=POS(LWRC$(OPENSTRING$),SEARCHSTRING$)
16124       if TPOS then 
16126          let SEARCHSTRINGLEN=LEN(SEARCHSTRING$)
16128          let RETURNNAME$=OPENSTRING$(TPOS+SEARCHSTRINGLEN:POS(LWRC$(OPENSTRING$),",",TPOS+SEARCHSTRINGLEN)-1)
16130 ! 
16132          let SPOS=POS(RETURNNAME$,"/")
16134          if SPOS then ! If linux style, reverse to be Windows style
16136             let RETURNNAME$=RETURNNAME$(SPOS+1:LEN(RETURNNAME$))&"\"&RETURNNAME$(1:SPOS-1)
16138          end if 
16140          let FNEXTRACTNAME$=RETURNNAME$
16142       end if 
16144    fnend 
16146 ! 
16148    def FNEXTRACTOPENVAR$*512(&OPENSTRING$;___,VAR$*512,INDEX,TPOS,RETURN$*512)
16150       let TPOS=POS(OPENSTRING$,"#")
16152       let VAR$=OPENSTRING$(TPOS:POS(OPENSTRING$,":",TPOS+1))
16154 ! 
16156 ! .  ! Skip past any junk characters such as ( and " "
16158       do UNTIL (INDEX:=INDEX+1)>LEN(VAR$)
16160       loop UNTIL POS("0123456789abcdefghijklmnopqrstuvwxyz",LWRC$(VAR$(INDEX:INDEX)))
16162 ! 
16164 ! .  ! read the first contiguous string of characters thats either a number or a variable
16166       do WHILE INDEX<=LEN(VAR$) AND POS("0123456789abcdefghijklmnopqrstuvwxyz",LWRC$(VAR$(INDEX:INDEX)))
16168          let RETURN$=RETURN$&VAR$(INDEX:INDEX)
16170          let INDEX+=1
16172       loop 
16174       let FNEXTRACTOPENVAR$=RETURN$
16176    fnend 
16178 ! 
16180    def FNEXTRACTLINEREF$*800(&READSTRING$;___,VAR$*800,INDEX,TPOS,RETURN$*512,BQUOTESON)
16182       let TPOS=POS(LWRC$(READSTRING$),"using")
16184       if TPOS>0 then 
16186          let VAR$=TRIM$(READSTRING$(TPOS+5:LEN(READSTRING$)))
16188 ! 
16190          do WHILE (INDEX:=INDEX+1)<=LEN(VAR$)
16192             if VAR$(INDEX:INDEX)="""" then let BQUOTESON=~BQUOTESON
16194             let RETURN$=RETURN$&VAR$(INDEX:INDEX)
16196          loop UNTIL (~BQUOTESON AND (VAR$(INDEX:INDEX)=="," OR VAR$(INDEX:INDEX)==":"))
16198          if RETURN$(LEN(RETURN$):LEN(RETURN$))="," then let RETURN$=RETURN$(1:LEN(RETURN$)-1)
16200          if RETURN$(LEN(RETURN$):LEN(RETURN$))=":" then let RETURN$=RETURN$(1:LEN(RETURN$)-1)
16202          let FNEXTRACTLINEREF$=TRIM$(RETURN$)
16204       end if 
16206    fnend 
16208 ! 
16210 ! .! Proc File Engine
16212 ! .! **********************
16214    dim PROCFILENUMBER, PROCCOMPILENUMBER
16216 ! 
16218 Trynextnumber: ! Try a new number
16220    let COMPILENUMBER+=1
16222    retry 
16224 ! 
16226    def FNOPENPROC
16228       open #(PROCFILENUMBER:=FNGETFILENUMBER): "name=compile"&STR$(COMPILENUMBER)&".$$$, replace", display, output error Trynextnumber
16230       print #PROCFILENUMBER: "proc noecho"
16232    fnend 
16234 ! 
16236    def FNBUILDSRCHHELP(;NOWAIT)
16238       if ~EXISTS("srchhelp.br") then 
16240          let FNBUILDPROC("00010 DIM RECORD$*800")
16242          let FNBUILDPROC("00020 OPEN #1: ""Name= temp.[wsid]"", DISPLAY, INPUT")
16244          let FNBUILDPROC("00030 LINPUT #1: RECORD$ EOF STOP1")
16246          let FNBUILDPROC("00040 STOP")
16248          let FNBUILDPROC("00050 STOP1: STOP 1")
16250          let FNBUILDPROC("save srchhelp.br")
16252          let FNRUNPROC(NOWAIT)
16254       end if 
16256    fnend 
16258 ! 
16260    def library FNBUILDPROCFILE(STRING$*255)=FNBUILDPROC(STRING$)
16262    def FNBUILDPROC(STRING$*255)
16264       if ~PROCFILENUMBER then let FNOPENPROC
16266       print #PROCFILENUMBER: STRING$
16268    fnend 
16270 ! 
16272    def library FNRUNPROCFILE(;NOWAIT)=FNRUNPROC(NOWAIT)
16274    def FNRUNPROC(;NOWAIT,___,C$,STAR$)
16276       let STAR$=FNNEEDSTAR$
16278       if PROCFILENUMBER then 
16280          print #PROCFILENUMBER: "system"
16282          close #PROCFILENUMBER: 
16284          let PROCFILENUMBER=0
16286          if NOWAIT then let C$=" -C"
16288 ! .     ! execute "type compile"&str$(CompileNumber)&".$$$"
16290 ! .     ! pause
16292          execute STAR$&"system"&C$&" -M "&FNGETBREXE$&" -"&FNGETWBCFG$&" proc compile"&STR$(COMPILENUMBER)&".$$$"
16294       end if 
16296    fnend 
16298 ! 
16300    def FNPROCPRINTTOFILE(STRING$*255)
16302       let FNBUILDPROC("open #1: ""name=filelay\scratchpaper.brs"",display,output")
16304       let FNBUILDPROC("print #1: """&STRING$&"""")
16306       let FNBUILDPROC("close #1: ")
16308    fnend 
16310    def FNPROCLISTTOFILE(STRING$*255;DONTADDQUOTES)
16312       if ~DONTADDQUOTES then 
16314          if STRING$(1:1)<>"'" then let STRING$(1:0)="'"
16316          if STRING$(LEN(STRING$):LEN(STRING$))<>"'" then let STRING$=STRING$&"'"
16318       end if 
16320       let FNBUILDPROC("list "&STRING$&" >>filelay\scratchpaper.brs")
16322       let FNBUILDPROC("list "&STRING$&" >>work."&WSID$)  !use this WSID, not the procs WSID
16324    fnend 
16326    def FNCLEARTEMPFILE
16328       if EXISTS ("work.[WSID]") then execute FNNEEDSTAR$&"free work.[WSID]"
16330    fnend 
16332    def FNPROCSHOWFILE
16334       let FNBUILDPROC(FNNEEDSTAR$&"system -C -M start filelay\scratchpaper.brs")
16336    fnend 
16338    def FNOPENSCRATCHFILE
16340       execute FNNEEDSTAR$&"system -C -M start filelay\scratchpaper.brs"
16342    fnend 
16344 ! 
16346 ! **********************************************************************
16348 ! Functions To Get Info From Config.Sys Files. By Susan Smith.
16350 !  Updated By Gabriel Bakker, To Save Time By Running Only Once.
16352 ! 
16354    dim CONFIGFILE$*300
16356    dim EXECUTABLEFILE$*300
16358 ! 
16360    def FNGETWBCFG$*255
16362       if CONFIGFILE$="" then 
16364          let FNREADCONFIGANDEXE
16366       end if 
16368       let FNGETWBCFG$=CONFIGFILE$
16370    fnend 
16372 ! 
16374    def FNGETBREXE$*255
16376       if EXECUTABLEFILE$="" then 
16378          let FNREADCONFIGANDEXE
16380       end if 
16382       let FNGETBREXE$=EXECUTABLEFILE$
16384    fnend 
16386 ! 
16388    dim CONFIGSTAT$*30000
16390    def FNREADCONFIGANDEXE(;___,CR$,FILENUMBER,QSTART,QEND,STAR$)
16392       let STAR$=FNNEEDSTAR$
16394       let CR$=HEX$("0D0A")
16396       execute STAR$&"status files >TEMPFILE.[session]"
16398       if EXISTS("TEMPFILE.[session]") then 
16400          open #(FILENUMBER:=FNGETFILENUMBER): "name=TEMPFILE.[session],eol=none",display,input error IGNORE
16402          if ~FILE(FILENUMBER) then 
16404             linput #FILENUMBER: CONFIGSTAT$
16406             close #FILENUMBER: 
16408 ! 
16410             let QSTART=POS(UPRC$(CONFIGSTAT$),"CONFIG FILE")
16412             if QSTART>0 then 
16414                let CONFIGFILE$=CONFIGSTAT$(QSTART+13:QSTART+300)
16416                let QEND=POS(CONFIGFILE$,CR$)
16418                let CONFIGFILE$=CONFIGFILE$(1:QEND-1)
16420                if CONFIGFILE$(1:1)=":" then let CONFIGFILE$=OS_FILENAME$(CONFIGFILE$)
16422             end if 
16424 ! 
16426             let QSTART=POS(UPRC$(CONFIGSTAT$),"EXECUTABLE FILE")
16428             if QSTART>0 then 
16430                let EXECUTABLEFILE$=CONFIGSTAT$(QSTART+17:QSTART+300)
16432                let QEND=POS(EXECUTABLEFILE$,CR$)
16434                let EXECUTABLEFILE$=EXECUTABLEFILE$(1:QEND-1)
16436                if EXECUTABLEFILE$(1:1)=":" then let EXECUTABLEFILE$=OS_FILENAME$(EXECUTABLEFILE$)
16438             end if 
16440          end if 
16442       end if 
16444       if EXISTS("c:\TEMPFILE.[session]") then execute STAR$&"free TEMPFILE.[session] -N"
16446    fnend 
16448 ! 
16450 ! 
16452    dim GL_FILENAME$*127,GL_VER,GL_PRE$, GL_RECL, GL_NAME$*127
16454    dim GL_KFNAME$(1)*127,GL_KPOS$(1)*50,GL_KLEN$(1)*50,GL_KDESCRIPTION$(1)*255
16456    dim GL_SUBS$(1)*127,GL_DESCR$(1)*127,GL_FORM$(1)*50,GL_EXTRA$(1)*255
16458    dim GL_TEMPSUBS$(1)*127,GL_TEMPDESCR$(1)*127,GL_TEMPFORM$(1)*50,GL_MAPPING(1)
16460 ! 
16462    dim GL_KFNAME$*127
16464    dim GL_ERRORMESSAGE$*512
16466    dim GL_TEMPFILENAME$*127
16468    dim FORMSTRING$*32000
16470    def library FNGENERATELAYOUT(MAT OPEN_STRING$,READ_STRING$*999,FORM_STRING$*20000,DIM_STRING$*999;DISPLAYFILE)=FNGENERATELAY(MAT OPEN_STRING$,READ_STRING$,FORM_STRING$,DIM_STRING$,DISPLAYFILE)
16472    def FNGENERATELAY(MAT OPENSTRING$,&READSTRING$,&_FORMSTRING$,&DIMSTRING$;DISPLAYFILE,___,INDEX,TFILE,TPOS,KEYINDEX,SIZE,JNDEX,FAILEDREAD,FAILEDFORM,FAILEDMATCH,FAILEDHEADER,FAILEDKEY,FPOS,WIDTH,KPPOS,KLPOS,KPOS,KLEN)
16474       let FORMSTRING$=_FORMSTRING$
16476 ! 
16478 ! .  ! Attempt to parse data, or at least get as far as we can
16480 ! .  !  Give error message when we get stuck
16482 ! .  !  Generate the layout with success message when it works
16484 ! .  !  Return ExitMode when success
16486 ! 
16488 ! .  ! Eventually we can call this code from a function that
16490 ! .  !  searches someones software suite.
16492 ! 
16494 ! .  ! Clear values
16496       mat GL_KFNAME$(0) : mat GL_KPOS$(0)
16498       mat GL_KLEN$(0) : mat GL_KDESCRIPTION$(0)
16500       let GL_FILENAME$=GL_PRE$=GL_NAME$=""
16502       let GL_KFNAME$=GL_ERRORMESSAGE$=GL_TEMPFILENAME$=""
16504       let GL_VER=GL_RECL=0
16506 ! 
16508       let KEYINDEX=0
16510 ! 
16512       for OPENINDEX=1 to UDIM(MAT OPENSTRING$)
16514 ! .     ! Parse Open String
16516          if LEN(OPENSTRING$(OPENINDEX)) then 
16518             let GL_TEMPFILENAME$=FNEXTRACTNAME$("name=",OPENSTRING$(OPENINDEX))
16520             if ~LEN(GL_FILENAME$) then let GL_FILENAME$=GL_TEMPFILENAME$
16522 ! 
16524             if LEN(GL_FILENAME$) AND GL_FILENAME$=GL_TEMPFILENAME$ then 
16526                let GL_KFNAME$=FNEXTRACTNAME$("kfname=",OPENSTRING$(OPENINDEX))
16528 ! 
16530                if LEN(GL_KFNAME$) then 
16532                   open #(TFILE:=FNGETFILENUMBER): "name="&GL_FILENAME$&", kfname="&GL_KFNAME$, internal, input, keyed error IGNORE
16534                   let KEYINDEX=UDIM(MAT GL_KFNAME$)+1
16536                   mat GL_KFNAME$(KEYINDEX) : mat GL_KPOS$(KEYINDEX)
16538                   mat GL_KLEN$(KEYINDEX) : mat GL_KDESCRIPTION$(KEYINDEX)
16540                   let GL_KFNAME$(KEYINDEX)=GL_KFNAME$
16542                else 
16544                   open #(TFILE:=FNGETFILENUMBER): "name="&GL_FILENAME$, internal, input, relative error IGNORE
16546                end if 
16548 ! 
16550                if FILE(TFILE)=0 then 
16552                   let GL_VER=VERSION(TFILE)
16554                   let GL_NAME$=GL_FILENAME$(POS(GL_FILENAME$,"\",-1)+1:LEN(GL_FILENAME$))
16556                   if POS(GL_NAME$,".") then 
16558                      let GL_NAME$=GL_NAME$(1:POS(GL_NAME$,".")-1)
16560                   end if 
16562                   let GL_NAME$=GL_NAME$(1:18)
16564                   let GL_PRE$=TRIM$(GL_NAME$)(1:4)&"_"
16566                   let GL_RECL=RLN(TFILE)
16568                   if KPS(TFILE)>-1 then 
16570                      let GL_KPOS$(KEYINDEX)=""
16572                      let GL_KLEN$(KEYINDEX)=""
16574                      let INDEX=0
16576                      do WHILE KPS(TFILE,(INDEX:=INDEX+1))>-1
16578                         let GL_KPOS$(KEYINDEX)=GL_KPOS$(KEYINDEX)&STR$(KPS(TFILE,INDEX))&"/"
16580                         let GL_KLEN$(KEYINDEX)=GL_KLEN$(KEYINDEX)&STR$(KLN(TFILE,INDEX))&"/"
16582                      loop 
16584                      let GL_KPOS$(KEYINDEX)=GL_KPOS$(KEYINDEX)(1:LEN(GL_KPOS$(KEYINDEX))-1)
16586                      let GL_KLEN$(KEYINDEX)=GL_KLEN$(KEYINDEX)(1:LEN(GL_KLEN$(KEYINDEX))-1)
16588                   end if 
16590                   close #TFILE: 
16592                end if 
16594             end if 
16596          end if 
16598       next OPENINDEX
16600 ! 
16602       if ~LEN(GL_FILENAME$) then let FAILEDHEADER=1
16604 ! 
16606       mat GL_TEMPSUBS$(0) : mat GL_TEMPDESCR$(0) : mat GL_TEMPFORM$(0) : mat GL_MAPPING(0)
16608       mat GL_SUBS$(0) : mat GL_DESCR$(0) : mat GL_FORM$(0) : mat GL_EXTRA$(0)
16610       if LEN(READSTRING$) AND LEN(FORMSTRING$) then 
16612 ! 
16614 ! .     ! Parse Read String
16616 ! .     ! unpack read string
16618 ! .     ! search in form string for each array
16620 ! .     ! use array size from form string to expand each array into one giant list of subscripts
16622          let TPOS=POS(READSTRING$,":",-1)
16624          do WHILE LEN(VAR$:=FNEXTRACTCHUNK$(READSTRING$,TPOS))
16626             if LWRC$(VAR$(1:3))="mat" then 
16628                let SIZE=FNREADARRAYSIZE(DIMSTRING$,VAR$(5:LEN(VAR$)))
16630                if SIZE then 
16632                   let INDEX=UDIM(MAT GL_TEMPSUBS$)
16634                   mat GL_TEMPSUBS$(INDEX+SIZE) : mat GL_TEMPDESCR$(INDEX+SIZE)
16636                   for JNDEX=INDEX+1 to INDEX+SIZE
16638                      if POS(VAR$,"$") then 
16640                         let GL_TEMPSUBS$(JNDEX)=SREP$(VAR$(5:LEN(VAR$)),"$","")&STR$(JNDEX-INDEX)&"$"
16642                      else 
16644                         let GL_TEMPSUBS$(JNDEX)=VAR$(5:LEN(VAR$))&STR$(JNDEX-INDEX)
16646                      end if 
16648                      let GL_TEMPDESCR$(JNDEX)=SREP$(VAR$(5:LEN(VAR$)),"$","")&STR$(JNDEX-INDEX)
16650                   next JNDEX
16652                   if POS(VAR$,"$") then 
16654                      let GL_TEMPSUBS$(INDEX+SIZE)=SREP$(VAR$(5:LEN(VAR$)),"$","")&"L$"
16656                   else 
16658                      let GL_TEMPSUBS$(INDEX+SIZE)=VAR$(5:LEN(VAR$))&"L"
16660                   end if 
16662 ! 
16664                else 
16666                   let FAILEDREAD=1
16668                end if 
16670             else 
16672                let INDEX=UDIM(MAT GL_TEMPSUBS$)+1
16674                mat GL_TEMPSUBS$(INDEX) : mat GL_TEMPDESCR$(INDEX)
16676                let GL_TEMPSUBS$(INDEX)=VAR$
16678                let GL_TEMPDESCR$(INDEX)=SREP$(VAR$,"$","")
16680             end if 
16682          loop UNTIL FAILEDREAD
16684 ! 
16686 ! .     ! Parse Form String
16688 ! .     ! 1) Unpack form string
16690          let FNUNPACKFORMSTRING(FORMSTRING$)
16692 ! 
16694          let TPOS=POS(LWRC$(FORMSTRING$),"form ")
16696          if TPOS then let TPOS+=4 else let FAILEDFORM=1
16698 ! 
16700          let FPOS=0
16702 ! 
16704          do WHILE LEN(VAR$:=FNEXTRACTFORM$(FORMSTRING$,TPOS))
16706             if LWRC$(VAR$(1:4))="pos " then 
16708                let FPOS=VAL(VAR$(5:LEN(VAR$)))-1 conv IGNORE
16710             else if LWRC$(VAR$(1:2))="x " then 
16712                let FPOS+=VAL(VAR$(3:LEN(VAR$))) conv IGNORE
16714             else 
16716                let INDEX=UDIM(MAT GL_TEMPFORM$)+1
16718                mat GL_TEMPFORM$(INDEX)
16720                let GL_TEMPFORM$(INDEX)=VAR$
16722 ! 
16724 ! .           ! Find width
16726                let WIDTH=FNLENGTHOF(VAR$)
16728 ! 
16730                if WIDTH then 
16732 ! .              ! expand Mapping
16734                   mat GL_MAPPING(MAX(UDIM(MAT GL_MAPPING),FPOS+WIDTH))
16736                   mat GL_MAPPING(FPOS+1:FPOS+WIDTH)=(INDEX)
16738                else 
16740                   let FAILEDFORM=1
16742                end if 
16744                let FPOS+=WIDTH
16746             end if 
16748          loop UNTIL FAILEDFORM
16750 ! 
16752          let INDEX=0
16754          let LASTNUM=-1
16756          let STARTPOS=0
16758 ! 
16760 ! .     ! Read Map, find length of consequetive vars
16762          do WHILE (INDEX:=INDEX+1)<=UDIM(MAT GL_MAPPING)+1
16764             if INDEX>UDIM(MAT GL_MAPPING) OR LASTNUM<>GL_MAPPING(INDEX) then 
16766                if LASTNUM<>-1 then 
16768 ! 
16770 ! .              ! Found one, Process it
16772                   let JNDEX=UDIM(MAT GL_SUBS$)+1
16774                   mat GL_SUBS$(JNDEX)
16776                   mat GL_DESCR$(JNDEX)
16778                   mat GL_FORM$(JNDEX)
16780                   mat GL_EXTRA$(JNDEX)
16782 ! 
16784                   if LASTNUM then 
16786                      if INDEX-STARTPOS=FNLENGTHOF(GL_TEMPFORM$(LASTNUM)) then 
16788 ! .                    ! Its good, use it
16790                         if UDIM(MAT GL_TEMPSUBS$)>=LASTNUM then 
16792                            let GL_SUBS$(JNDEX)=GL_TEMPSUBS$(LASTNUM)
16794                            let GL_DESCR$(JNDEX)=GL_TEMPDESCR$(LASTNUM)
16796                         else 
16798                            let GL_SUBS$(JNDEX)="_"
16800                            let GL_DESCR$(JNDEX)=""
16802                         end if 
16804                         let GL_FORM$(JNDEX)=GL_TEMPFORM$(LASTNUM)
16806                      else 
16808 ! .                    ! Error. Set it and return error.
16810                         if UDIM(MAT GL_TEMPSUBS$)>=LASTNUM then 
16812                            let GL_SUBS$(JNDEX)=GL_TEMPSUBS$(LASTNUM)
16814                            let GL_DESCR$(JNDEX)=GL_TEMPDESCR$(LASTNUM)
16816                         else 
16818                            let GL_SUBS$(JNDEX)="_"
16820                            let GL_DESCR$(JNDEX)=""
16822                         end if 
16824                         let GL_FORM$(JNDEX)="C "&STR$(INDEX-STARTPOS)
16826                         let GL_EXTRA$(JNDEX)="Error. Width: "&STR$(INDEX-STARTPOS)&" but Form: "&GL_TEMPFORM$(LASTNUM)
16828                         let FAILEDMATCH=1
16830                      end if 
16832                   else 
16834 ! .                 ! unknown make it an X
16836                      let GL_SUBS$(JNDEX)="_"
16838                      let GL_FORM$(JNDEX)="X "&STR$(INDEX-STARTPOS)
16840                      let GL_DESCR$(JNDEX)="Unknown / Unused"
16842                   end if 
16844                end if 
16846                if INDEX<=UDIM(MAT GL_MAPPING) then let LASTNUM=GL_MAPPING(INDEX)
16848                let STARTPOS=INDEX
16850             end if 
16852          loop 
16854       else 
16856          if ~LEN(READSTRING$) then let FAILEDREAD=1
16858          if ~LEN(FORMSTRING$) then let FAILEDFORM=1
16860       end if 
16862 ! 
16864 ! .  ! Figure out Keys, mat gl_kpos$,mat gl_klen$,mat gl_kDescription$
16866       for KEYINDEX=1 to UDIM(MAT GL_KDESCRIPTION$)
16868 ! .     ! Read each chunk of gl_kPos$ and gl_kLen$
16870          let KPPOS=KLPOS=0
16872          do WHILE (KPOS:=FNEXTRACTKPS(GL_KPOS$(KEYINDEX),KPPOS))
16874             let KLEN=FNEXTRACTKLN(GL_KLEN$(KEYINDEX),KLPOS)
16876             if KLEN then 
16878 ! .           ! must do a reverse lookup against mat gl_Mapping
16880 ! .           ! to calculate mat gl_kDescription$
16882 ! 
16884                let INDEX=KPOS-1
16886                let LASTNUM=-1
16888 ! 
16890 ! .           ! Read Map, find consequetive nums
16892                do WHILE (INDEX:=INDEX+1)<KLEN+KPOS
16894                   if INDEX<=UDIM(MAT GL_MAPPING) then 
16896                      if LASTNUM<>GL_MAPPING(INDEX) then 
16898 ! .                    ! Found one, Process it
16900                         if LEN(GL_KDESCRIPTION$(KEYINDEX)) then let GL_KDESCRIPTION$(KEYINDEX)=GL_KDESCRIPTION$(KEYINDEX)&"/"
16902                         if GL_MAPPING(INDEX)<=UDIM(MAT GL_TEMPSUBS$) AND GL_MAPPING(INDEX)>0 then 
16904                            let GL_KDESCRIPTION$(KEYINDEX)=GL_KDESCRIPTION$(KEYINDEX)&SREP$(GL_TEMPSUBS$(GL_MAPPING(INDEX)),"$","")
16906                         else 
16908                            let GL_KDESCRIPTION$(KEYINDEX)=GL_KDESCRIPTION$(KEYINDEX)&"Unknown"
16910                            let FAILEDKEY=1
16912                         end if 
16914 ! 
16916                         let LASTNUM=GL_MAPPING(INDEX)
16918                      end if 
16920                   end if 
16922                loop 
16924             else 
16926                if LEN(GL_KDESCRIPTION$(KEYINDEX)) then let GL_KDESCRIPTION$(KEYINDEX)=GL_KDESCRIPTION$(KEYINDEX)&"/"
16928                let GL_KDESCRIPTION$(KEYINDEX)=GL_KDESCRIPTION$(KEYINDEX)&"Unknown"
16930                let FAILEDKEY=1
16932             end if 
16934          loop 
16936       next KEYINDEX
16938 ! 
16940 ! .  ! if name is blank then generate a work filename
16942       if ~LEN(GL_NAME$) then let GL_NAME$="templayout"&SESSION$
16944 ! .  ! if Recl matches gl_Mapping then autogenerate recl
16946       if GL_RECL=UDIM(GL_MAPPING) then let GL_RECL=0
16948 ! 
16950 ! .  ! Burn Layout
16952       let FNWRITELAY(GL_NAME$,GL_FILENAME$,GL_VER,GL_PRE$,MAT GL_KFNAME$,MAT GL_KDESCRIPTION$,MAT GL_SUBS$,MAT GL_DESCR$,MAT GL_FORM$,GL_RECL,MAT GL_EXTRA$,DISPLAYFILE)
16954 ! 
16956 ! .  ! if errors in Header or Detail, print message box
16958       let GL_ERRORMESSAGE$=""
16960       if FAILEDHEADER then let GL_ERRORMESSAGE$=GL_ERRORMESSAGE$&"We were unable to properly build the Header. Check your open statements."&CHR$(13)&CHR$(10)
16962       if FAILEDKEY then let GL_ERRORMESSAGE$=GL_ERRORMESSAGE$&"We were unable to figure out the keys. Check your open and read statements."&CHR$(13)&CHR$(10)
16964       if FAILEDREAD then let GL_ERRORMESSAGE$=GL_ERRORMESSAGE$&"We were unable to figure out the variable names. Check your read statement and dim statement."&CHR$(13)&CHR$(10)
16966       if FAILEDFORM then let GL_ERRORMESSAGE$=GL_ERRORMESSAGE$&"We were unable to figure out the form specs. Check your form statement."&CHR$(13)&CHR$(10)
16968       if FAILEDMATCH then let GL_ERRORMESSAGE$=GL_ERRORMESSAGE$&"There was a problem matching your layout specs. Check your Read, Dim and Form statements."&CHR$(13)&CHR$(10)
16970 ! 
16972 ! .  ! Return error
16974       if FAILEDREAD OR FAILEDFORM OR FAILEDMATCH OR FAILEDHEADER OR FAILEDKEY then 
16976          let MSGBOX(GL_ERRORMESSAGE$,"I need more information.","Ok")
16978       else 
16980          let FNGENERATELAY=1
16982       end if 
16984    fnend 
16986 ! 
16988    def library FNWRITELAYOUT(NAME$,FILENAME$*127,VER,PRE$,MAT KFNAME$,MAT KDESCRIPTION$,MAT SUBS$,MAT DESCR$,MAT FORM$;RECL,MAT EXTRA$,DISPLAYFILE)=FNWRITELAY(NAME$,FILENAME$,VER,PRE$,MAT KFNAME$,MAT KDESCRIPTION$,MAT SUBS$,MAT DESCR$,MAT FORM$,RECL,MAT EXTRA$)
16990    def FNWRITELAY(NAME$,FILENAME$*127,VER,PRE$,MAT KFNAME$,MAT KDESCRIPTION$,MAT SUBS$,MAT DESCR$,MAT FORM$;RECL,MAT EXTRA$,___,FILENUMBER,INDEX,WIDESTSUB,WIDESTDESCR,WIDESTFORM,FILELAYOUTPATH$*255,FILELAYOUTEXTENSION$)
16992 ! 
16994       let FILELAYOUTPATH$=FNSETTINGS$("layoutpath")
16996       let FILELAYOUTEXTENSION$=FNSETTINGS$("layoutextension")
16998 ! 
17000       library : FNGETFILENUMBER
17002 ! 
17004       open #(FILENUMBER:=FNGETFILENUMBER): "name="&FILELAYOUTPATH$&NAME$&FILELAYOUTEXTENSION$&", recl=1000,replace",display,output 
17006       print #FILENUMBER: FILENAME$&", "&PRE$&", "&STR$(VER)
17008       for INDEX=1 to UDIM(MAT KFNAME$)
17010          print #FILENUMBER: KFNAME$(INDEX)&", "&KDESCRIPTION$(INDEX)
17012       next INDEX
17014       if RECL then 
17016          print #FILENUMBER: "recl="&STR$(RECL)
17018       end if 
17020 ! 
17022 ! .  ! Minimums
17024       let WIDESTSUB=10
17026       let WIDESTDESCR=30
17028       let WIDESTFORM=6
17030 ! .  ! Calculate width of output
17032       for INDEX=1 to UDIM(MAT SUBS$)
17034          let WIDESTSUB=MAX(WIDESTSUB,LEN(SUBS$(INDEX)))
17036          let WIDESTDESCR=MAX(WIDESTDESCR,LEN(DESCR$(INDEX)))
17038          let WIDESTFORM=MAX(WIDESTFORM,LEN(FORM$(INDEX)))
17040       next INDEX
17042       print #FILENUMBER: RPT$("=",WIDESTSUB+2+WIDESTDESCR+2+WIDESTFORM)
17044       for INDEX=1 to UDIM(MAT SUBS$)
17046          if INDEX<=UDIM(MAT EXTRA$) AND LEN(EXTRA$(INDEX)) then 
17048             print #FILENUMBER: RPAD$(SUBS$(INDEX)&", ",WIDESTSUB+2)&RPAD$(DESCR$(INDEX)&", ",WIDESTDESCR+2)&LPAD$(FORM$(INDEX),WIDESTFORM)&", "&EXTRA$(INDEX)
17050          else 
17052             print #FILENUMBER: RPAD$(SUBS$(INDEX)&", ",WIDESTSUB+2)&RPAD$(DESCR$(INDEX)&", ",WIDESTDESCR+2)&LPAD$(FORM$(INDEX),WIDESTFORM)
17054          end if 
17056       next INDEX
17058       close #FILENUMBER: 
17060 ! 
17062       if FILELAYOUTEXTENSION$="" OR FILELAYOUTEXTENSION$="." then 
17064          if DISPLAYFILE then execute FNNEEDSTAR$&"sy -C -M start notepad "&FILELAYOUTPATH$&NAME$  !Have to force notepad because there's no ext to assoc in windows.
17066       else 
17068          if DISPLAYFILE then execute FNNEEDSTAR$&"sy -C -M start "&FILELAYOUTPATH$&NAME$&FILELAYOUTEXTENSION$  !Just call default program, they have an ext to associate.
17070       end if 
17072    fnend 
17074 ! 
17076    dim FS_CHUNK$*800
17078    dim FS_REPLACE$*2000
17080    def FNUNPACKFORMSTRING(&FORMSTRING$;___,PLEVEL,SPOS,EPOS,NPOS,INDEX,NUM)
17082 ! .  ! unpack the form string
17084 ! .  !  needs to handle:
17086 ! .  !   form C 10,DATE(mm/dd/ccyy),2*(C 10),2*(C 15,C 10),4*(C 15,FMT(##),3*FMT(###))
17088 ! .  !   form C 10,DATE(mm/dd/ccyy),C 10,C 10,C 15,C 10,C 15,C 10,C 15,FMT(##),FMT(###),FMT(###),FMT(###),C 15,FMT(##),FMT(###),FMT(###),FMT(###),C 15,FMT(##),FMT(###),FMT(###),FMT(###),C 15,FMT(##),FMT(###),FMT(###),FMT(###)
17090 ! 
17092       do WHILE (SPOS:=POS(FORMSTRING$,"*"))  !find first *
17094          do WHILE FORMSTRING$(SPOS+1:SPOS+1)=" "
17096             let FORMSTRING$(SPOS+1:SPOS+1)=""
17098          loop 
17100 ! .     ! Find Chunk
17102          if FORMSTRING$(SPOS:SPOS+1)="*(" then ! if next char is "("
17104             let EPOS=SPOS             !find matching ")"
17106             do                        !go through string counting
17108                let EPOS+=1            !parens until we're at match
17110                if FORMSTRING$(EPOS:EPOS)="(" then let PLEVEL+=1
17112                if FORMSTRING$(EPOS:EPOS)=")" then let PLEVEL-=1
17114             loop WHILE PLEVEL
17116             let FS_CHUNK$=FORMSTRING$(SPOS+2:EPOS-1)&","
17118          else ! if its not a "*(" then
17120             let EPOS=POS(FORMSTRING$,",",SPOS)  !look for the next ","
17122             if ~EPOS then let EPOS=LEN(FORMSTRING$)+1
17124             let FS_CHUNK$=FORMSTRING$(SPOS+1:EPOS-1)&","
17126             let EPOS-=1
17128          end if 
17130 ! 
17132 ! .     ! Find Number
17134          let NPOS=SPOS
17136          do WHILE (NPOS:=NPOS-1)
17138          loop WHILE POS("0123456789 ",FORMSTRING$(NPOS:NPOS))
17140          let NUM=VAL(SREP$(FORMSTRING$(NPOS+1:SPOS-1)," ",""))
17142 ! 
17144 ! .     ! Then Substitute
17146          let FS_REPLACE$=RPT$(FS_CHUNK$,NUM)
17148          let FS_REPLACE$=FS_REPLACE$(1:LEN(FS_REPLACE$)-1)
17150          let FORMSTRING$(NPOS+1:EPOS)=FS_REPLACE$
17152       loop                            !go until there's no *
17154    fnend 
17156 ! 
17158 ! .!  needs to handle:
17160 ! .!   form C 10,DATE(mm/dd/ccyy),2*(C 10),2*(C 15,C 10),4*(C 15,FMT(##),3*FMT(###))
17162 ! .!   form C 10,DATE(mm/dd/ccyy),C 10,C 10,2*(C 15,C 10),4*(C 15,FMT(##),3*FMT(###))
17164 ! .!   form C 10,DATE(mm/dd/ccyy),C 10,C 10,C 15,C 10,C 15,C 10,4*(C 15,FMT(##),3*FMT(###))
17166 ! .!   form C 10,DATE(mm/dd/ccyy),C 10,C 10,C 15,C 10,C 15,C 10,C 15,FMT(##),3*FMT(###),C 15,FMT(##),3*FMT(###),C 15,FMT(##),3*FMT(###),C 15,FMT(##),3*FMT(###)
17168 ! .!   form C 10,DATE(mm/dd/ccyy),C 10,C 10,C 15,C 10,C 15,C 10,C 15,FMT(##),FMT(###),FMT(###),FMT(###),C 15,FMT(##),FMT(###),FMT(###),FMT(###),C 15,FMT(##),FMT(###),FMT(###),FMT(###),C 15,FMT(##),FMT(###),FMT(###),FMT(###)
17170 ! 
17172    def FNEXTRACTCHUNK$*255(&READSTRING$,&TPOS;___,CPOS,SPOS,XPOS)
17174       do WHILE (READSTRING$(TPOS+1:TPOS+1)=" ")
17176          let TPOS+=1
17178       loop 
17180       let CPOS=POS(READSTRING$,",",TPOS+1)
17182       let SPOS=POS(READSTRING$," ",TPOS+1)
17184       if LWRC$(READSTRING$(TPOS+1:SPOS-1))="mat" then 
17186          let SPOS=POS(READSTRING$," ",SPOS+1)
17188       end if 
17190       if CPOS AND SPOS then 
17192          let XPOS=MIN(CPOS,SPOS)
17194       else 
17196          let XPOS=MAX(CPOS,SPOS)
17198       end if 
17200       if ~XPOS then let XPOS=LEN(READSTRING$)+1
17202       let FNEXTRACTCHUNK$=TRIM$(READSTRING$(TPOS+1:XPOS-1))
17204       if ~CPOS then let CPOS=LEN(READSTRING$)+1
17206       let TPOS=CPOS
17208    fnend 
17210 ! 
17212    def FNEXTRACTFORM$*255(&FORMSTRING$,&TPOS;___,XPOS)
17214       let XPOS=POS(FORMSTRING$,",",TPOS+1)
17216       if ~XPOS then let XPOS=LEN(FORMSTRING$)+1
17218       let FNEXTRACTFORM$=TRIM$(FORMSTRING$(TPOS+1:XPOS-1))
17220       let TPOS=XPOS
17222    fnend 
17224 ! 
17226    def FNEXTRACTKPS(&KPSSTRING$,&TPOS;___,XPOS,KPOS)
17228       let XPOS=POS(KPSSTRING$,"/",TPOS+1)
17230       if ~XPOS then let XPOS=LEN(KPSSTRING$)+1
17232       let KPOS=VAL(KPSSTRING$(TPOS+1:XPOS-1)) conv IGNORE
17234       let FNEXTRACTKPS=KPOS
17236       let TPOS=XPOS
17238    fnend 
17240 ! 
17242    def FNEXTRACTKLN(&KLNSTRING$,&TPOS;___,XPOS,KLEN)
17244       let XPOS=POS(KLNSTRING$,"/",TPOS+1)
17246       if ~XPOS then let XPOS=LEN(KLNSTRING$)+1
17248       let KLEN=VAL(KLNSTRING$(TPOS+1:XPOS-1)) conv IGNORE
17250       let FNEXTRACTKLN=KLEN
17252       let TPOS=XPOS
17254    fnend 
17256 ! 
17258    def FNREADARRAYSIZE(&DIMSTRING$,VARNAME$*255;___,TPOS,SIZE$,PPOS)
17260       let TPOS=POS(LWRC$(DIMSTRING$),LWRC$(VARNAME$))
17262       if TPOS then let TPOS+=LEN(VARNAME$)
17264       if DIMSTRING$(TPOS:TPOS)="(" then 
17266          let PPOS=POS(DIMSTRING$,")",TPOS+1)
17268          if PPOS then 
17270             let SIZE$=DIMSTRING$(TPOS+1:PPOS-1)
17272             let FNREADARRAYSIZE=0
17274             let FNREADARRAYSIZE=VAL(SIZE$) conv IGNORE
17276          end if 
17278       end if 
17280    fnend 
17282 ! 
17284 ! 
19000 ! #Autonumber# 19000,10
19010 Fileiolibrary: ! ********************* File Library ********************
19020 ! 
19030 ! 
19040 Getfilenumber: ! This Function Finds The Next Empty File Channel
19050    def library FNGETFILENUMBER(;START,COUNT,___,I)
19060       if START=-1 then 
19070          let START=FNSETTINGS("startfilenumber")
19080       end if 
19090       if (START) then let START-=1
19100       let COUNT=MAX(COUNT,1)
19110       do 
19120          if START>=199 AND START<300 then let START=300 : let I=0  !Skip over the invalid 200s
19130          if FILE(START:=START+1)=-1 then 
19140             let I=I+1
19150          else 
19160             let I=0
19170          end if 
19180       loop UNTIL I=COUNT
19190       let FNGETFILENUMBER=(START-(COUNT-1))
19200    fnend 
19210 ! 
19220    def FNRESETERRORHANDLING
19230       if IGNOREERRORS then 
19240          on error goto Returnfailed
19250       else 
19260          on error system              !Turn Error Checking Back Off
19270       end if 
19280    fnend 
19290 ! 
19300 ! SupressPrompt suppresses the "File Not Found, Create?" prompt
19310 ! SupressPrompt = 1 for Don't Create the File, don't error, just don't open it (return 0)
19320 ! SupressPrompt = 2 Don't Prompt, Always Create the file
19330 ! 
20000 ! #Autonumber# 20000,5
20005 Openfile: ! This Function Opens The Requested File And Returns Filenum
20010    def library FNOPENFILE(&FILENAME$, MAT F$, MAT F, MAT FORM$;INPUTONLY,KEYNUM,DONT_SORT_SUBS,&PATH$,MAT DESCRIPTION$,MAT FIELDWIDTHS,MAT FILEIOSUBS$,SUPRESSPROMPT,IGNOREERRORS,CALLINGPROGRAM$*255,SUPPRESSLOG,MAT FILEIODATEFMT$,___,FILENUMBER,STRINGSIZE,NUMBERSIZE,DUMMY,INDEX,VER,PROMPTONCREATE,OKTOCREATE,CREATELOGFILE,FORM$*2000,STARTFILENUMBER,COUNTFILENUMBER,FILELAY$*255,CHECKINDEX,LOGLAYOUT$,TEMPCHECKINDEX)
20015       dim KEYNAME$(1)*255,KPOS$(1)*255,KLEN$(1)*255
20020       dim FM$*8000,MESSAGE$*60
20025       dim LAYOUTPATH$*255
20030       let FM$=MESSAGE$=""
20035 ! 
20040       library : FNGETFILENUMBER, FNLOG, FNERRLOG
20045       if IGNOREERRORS then on error goto Returnfailed
20050 ! 
20055       let PROMPTONCREATE=FNSETTINGS("promptonfilecreate")
20060       let ENFORCEDUPKEYS=FNSETTINGS("enforcedupkeys")
20065       let STARTFILENUMBER=FNSETTINGS("startfilenumber")
20070 ! 
20075       let CHECKINDEX=FNSETTINGS("checkindex")
20080       if LWRC$(TRIM$(FILENAME$))=LWRC$(TRIM$(FNSETTINGS$("loglayout"))) then let CHECKINDEX=0
20085 ! 
20090       if SUPPRESSLOG then 
20095          let CREATELOGFILE=0
20100       else 
20105          let CREATELOGFILE=FNSETTINGS("createlogfile")
20110       end if 
20115 ! 
20120       if NOT (KEYNUM) then let KEYNUM=1
20125       if TRIM$(PATH$)<>"" AND PATH$(LEN(PATH$):LEN(PATH$))<>"\" then let PATH$=PATH$&"\"
20130       let FILELAY$=FILENAME$          !Make Backup So That We Can Use This Later For Versioning Logic
20135       if FNREADFILELAYOUT(FILENAME$,RECL$,MAT KEYNAME$,MAT KPOS$,MAT KLEN$,FM$, STRINGSIZE, NUMBERSIZE,DONT_SORT_SUBS,VER,MAT DESCRIPTION$,MAT FIELDWIDTHS,MAT FILEIOSUBS$,DONT_CFORM:=0,MAT FILEIODATEFMT$) then ! Reads Layout And Applies Subscripts
20140          if FN42 then 
20145             let FORM$=FM$(1:2000)
20150          else 
20155             let FORM$=TRIM$(FM$(1:255))
20160          end if 
20165          if NOT EXISTS(PATH$&FILENAME$) then 
20170             if SUPRESSPROMPT then 
20175                let OKTOCREATE=SUPRESSPROMPT-1
20180             else if PROMPTONCREATE then 
20185                let MESSAGE$=PATH$&FILENAME$
20190                if LEN(TRIM$(MESSAGE$))>41 then let MESSAGE$=MESSAGE$(1:38)&"..."
20195                let MESSAGE$='Should I create "'&MESSAGE$&'"?'
20200                let OKTOCREATE=FNMESSAGEBOX(MESSAGE$,"File Not Found")
20205             else 
20210                let OKTOCREATE=1
20215             end if 
20220             if OKTOCREATE then 
20225                let FNCREATE(FILENAME$,RECL$,MAT KEYNAME$,MAT KPOS$,MAT KLEN$,VER,FILELAY$,PATH$)
20230             end if 
20235          end if 
20240          if EXISTS(PATH$&FILENAME$) then 
20245             if INPUTONLY then 
20250                do 
20255                   if UDIM(MAT KEYNAME$)>0 AND KEYNUM>0 then 
20260                      let FNCHECKINDEX(PATH$&FILENAME$,PATH$&KEYNAME$(KEYNUM),KPOS$(KEYNUM),KLEN$(KEYNUM),CHECKINDEX,CREATELOGFILE,KEYNUM,ENFORCEDUPKEYS,CALLINGPROGRAM$)
20265                      open #(FILENUMBER:=FNGETFILENUMBER(STARTFILENUMBER)): "name="&PATH$&FILENAME$&", kfname="&PATH$&KEYNAME$(KEYNUM)&",shr",internal, input, keyed ioerr Error_Openfile
20270                   else 
20275                      open #(FILENUMBER:=FNGETFILENUMBER(STARTFILENUMBER)): "name="&PATH$&FILENAME$&",shr",internal, input, relative ioerr Error_Openfile
20280                   end if 
20285                loop WHILE FNWRONGVERSION(FILENUMBER,FILELAY$,VER,PATH$)
20290             else 
20295                do 
20300                   if UDIM(MAT KEYNAME$)>0 AND KEYNUM>0 then 
20305                      let FNCHECKINDEX(PATH$&FILENAME$,PATH$&KEYNAME$(KEYNUM),KPOS$(KEYNUM),KLEN$(KEYNUM),CHECKINDEX,CREATELOGFILE,KEYNUM,ENFORCEDUPKEYS,CALLINGPROGRAM$)
20310                      open #(FILENUMBER:=FNGETFILENUMBER(STARTFILENUMBER,UDIM(KEYNAME$))): "name="&PATH$&FILENAME$&", kfname="&PATH$&KEYNAME$(KEYNUM)&",shr",internal, outin, keyed ioerr Error_Openfile
20315                   else 
20320                      if KEYNUM>=-1 then 
20325                         open #(FILENUMBER:=FNGETFILENUMBER(STARTFILENUMBER,UDIM(KEYNAME$)+1)): "name="&PATH$&FILENAME$&",shr",internal, outin, relative ioerr Error_Openfile
20330                      else 
20335                         open #(FILENUMBER:=FNGETFILENUMBER(STARTFILENUMBER)): "name="&PATH$&FILENAME$&",shr",internal, outin, relative ioerr Error_Openfile
20340                      end if 
20345                   end if 
20350                loop WHILE FNWRONGVERSION(FILENUMBER,FILELAY$,VER,PATH$)
20355                let COUNTFILENUMBER=FILENUMBER
20360                if KEYNUM>=-1 then 
20365                   for INDEX=1 to UDIM(KEYNAME$)  !Outin Requires All Keys To Be Opened
20370                      if INDEX<>KEYNUM then 
20375                         let FNCHECKINDEX(PATH$&FILENAME$,PATH$&KEYNAME$(INDEX),KPOS$(INDEX),KLEN$(INDEX),CHECKINDEX,CREATELOGFILE,INDEX,ENFORCEDUPKEYS,CALLINGPROGRAM$)
20380                         let COUNTFILENUMBER+=1
20385                         open #(COUNTFILENUMBER): "name="&PATH$&FILENAME$&", kfname="&PATH$&KEYNAME$(INDEX)&",shr",internal, outin, keyed 
20390                         mat FORM$(MAX(UDIM(MAT FORM$),COUNTFILENUMBER))
20395                         let FORM$(COUNTFILENUMBER)=FORM$
20400                      end if 
20405                   next INDEX
20410                end if 
20415             end if 
20420             mat FORM$(MAX(UDIM(MAT FORM$),FILENUMBER))
20425             let FORM$(FILENUMBER)=FORM$
20430             mat F$(STRINGSIZE)
20435             mat F(NUMBERSIZE)
20440             let FNOPENFILE=FILENUMBER
20445             let LOGLAYOUT$=FNSETTINGS$("loglayout")
20450             if CREATELOGFILE AND LWRC$(FILELAY$)<>LWRC$(LOGLAYOUT$) then let FNLOG("Open "&FILENAME$&" file.",CALLINGPROGRAM$)
20455          else 
20460             if CREATELOGFILE then let FNLOG("Error: Failed to open "&FILENAME$&" file - File Not Found",CALLINGPROGRAM$,1)
20465          end if 
20470       else 
20475          print "Unable to open file layout: "&FILENAME$
20480          print "Make sure it exists, and its not currently in use."
20485          pause 
20490          stop 
20495       end if 
20500 Exitfnopen: ! Exit Fn Open
20505    fnend 
20510 Error_Openfile: ! An Error Was Found Opening The File
20515    if IGNOREERRORS then goto Returnfailed
20520    print "Error parsing file layout or opening file "&FILENAME$&": "&STR$(ERR)&" on line: "&STR$(LINE)
20525    if ERR=608 then 
20530       print "Open Permission Conflict. If the file has already been opened Input Only,"
20535       print "then it cannot be opened OutIn. Change the earlier open to OutIn."
20540    else if ERR=4152 then 
20545       print "A key specified in your file layout could not be found."
20550       print "Check your file layout header for errors."
20555    else 
20560       print "Check your file layout header for errors."
20565    end if 
20570 ! 
20575    dim ERRORLOGFILENAME$*255
20580    let ERRORLOGFILENAME$="FileIO_ErrorLog"&SESSION$&"_"&DATE$("ccyymmdd")&"_"&TIME$(1:2)&TIME$(4:5)&TIME$(7:8)&".txt"
20585    let ERRORLOGFILERETRYCOUNT=0
20590    execute "status >"&ERRORLOGFILENAME$
20595    execute "status stacks >>"&ERRORLOGFILENAME$
20600    print "Error Log Written to: "&ERRORLOGFILENAME$
20605 ! 
20610    pause                              !Give User A Chance To Check Variables
20615    execute "system"
20620 ! 
20625 ! 
20630 Errorlogfilelocked: ! 
20635    let SLEEP(0.1)
20640    let ERRORLOGFILERETRYCOUNT+=1
20645    if ERRORLOGFILERETRYCOUNT<5 then 
20650       retry 
20655    else 
20660       print "Error Log File Locked. Unable to Write Complete Error Log."
20665       pause 
20670       execute "system"
20675    end if 
20680 ! 
20685 ! 
20690 Returnfailed: ! Open failed but keep going
20695    if CREATELOGFILE then let FNLOG("Error: Failed to open file "&FILENAME$&" or its keys: "&STR$(ERR)&" on fileio line: "&STR$(LINE),CALLINGPROGRAM$,1)
20700    goto Exitfnopen
20705 ! 
20710 ! 
21000 ! #Autonumber# 21000,10
21010 Create: ! This Should Create The Given File If It Does Not Exist
21020    def FNCREATE(FILENAME$*255,RECL$,MAT KEYS$,MAT KPOS$,MAT KLEN$,VER,FILELAY$*255;PATH$*255,___,INDEX,FILENUMBER)
21030       if UDIM(MAT KEYS$)>0 then 
21040          let FNCOMPRESSINDEXPARMS(KPOS$(1),KLEN$(1))
21050          open #(FILENUMBER:=FNGETFILENUMBER): "Name="&PATH$&FILENAME$&", "&RECL$&", kfname="&PATH$&KEYS$(1)&", kps="&KPOS$(1)&", kln="&KLEN$(1)&",new",internal,output,keyed 
21060       else 
21070          open #(FILENUMBER:=FNGETFILENUMBER): "Name="&PATH$&FILENAME$&", "&RECL$&",new", internal, output, relative 
21080       end if 
21090       let VERSION(FILENUMBER,VER)
21100       close #FILENUMBER: 
21110       for INDEX=2 to UDIM(MAT KEYS$)
21120          let FNCOMPRESSINDEXPARMS(KPOS$(INDEX),KLEN$(INDEX))
21130          execute FNNEEDSTAR$&"index "&PATH$&FILENAME$&" "&PATH$&KEYS$(INDEX)&" "&KPOS$(INDEX)&" "&KLEN$(INDEX)&" dupkeys replace -N"
21140       next INDEX
21150       let FNCREATEVERSIONSAVEINFO(FILELAY$)
21160    fnend 
21170 ! 
21180 Createversionsaveinfo: ! Backs Up The File Layout And Saves Version Information
21190    def FNCREATEVERSIONSAVEINFO(FILELAY$*255;SAVELAY,NEWLAY,FILENAME$*255,PREFIX$,DUMMY$*255,KEYNAME$,VERS$,FILELAYOUTPATH$*255,FILELAYOUTEXTENSION$,OLDFILELAYOUT$)
21200       let FILELAYOUTPATH$=FNSETTINGS$("layoutpath")  !Retrieve Settings
21210       let FILELAYOUTEXTENSION$=FNSETTINGS$("layoutextension")
21220 ! 
21230       if ~EXISTS(FILELAYOUTPATH$&"version") then 
21240          execute FNNEEDSTAR$&"mkdir "&FILELAYOUTPATH$&"version"
21250       end if 
21260       open #(NEWLAY:=FNGETFILENUMBER): "Name="&FILELAYOUTPATH$&FILELAY$&FILELAYOUTEXTENSION$&",recl=511", display,input 
21270       input #NEWLAY: FILENAME$,PREFIX$,VERS$
21280       open #(SAVELAY:=FNGETFILENUMBER): "Name="&FILELAYOUTPATH$&"version\"&FILELAY$&"."&TRIM$(STR$(VAL((VERS$))))&FILELAYOUTEXTENSION$&",recl=511, replace", display, output 
21290       print #SAVELAY: FNCALCULATEBACKUPFILENAME$(TRIM$(FILENAME$))&", o"&TRIM$(PREFIX$)&", "&TRIM$(VERS$)
21300       linput #NEWLAY: DUMMY$
21310       do WHILE UPRC$(DUMMY$(1:5))<>"RECL=" AND DUMMY$(1:4)<>"===="
21320          print #SAVELAY: FNCALCULATEBACKUPFILENAME$(DUMMY$(1:POS(DUMMY$,",")-1)) & TRIM$(DUMMY$(POS(DUMMY$,","):LEN(DUMMY$)))
21330          linput #NEWLAY: DUMMY$
21340       loop 
21350 Copynextline: ! Copy The Rest Of The File
21360       print #SAVELAY: TRIM$(DUMMY$)
21370       linput #NEWLAY: DUMMY$ eof Donecopylines
21380       goto Copynextline
21390 Donecopylines: ! File Is Finished
21400       close #NEWLAY: 
21410       close #SAVELAY: 
21420    fnend 
21430 ! 
21440 Checkversionsaveinfo: ! Ensures Version Save Information Exists
21450    def FNCHECKVERSIONSAVEINFO(FILELAY$*255,VER;___,FILELAYOUTPATH$*255,FILELAYOUTEXTENSION$)
21460       let FILELAYOUTPATH$=FNSETTINGS$("layoutpath")
21470       let FILELAYOUTEXTENSION$=FNSETTINGS$("layoutextension")
21480       if ~(TRIM$(FILELAY$(POS(TRIM$(FILELAY$),".",-1):LEN(TRIM$(FILELAY$))))="."&TRIM$(STR$(VER))) then ! IF this is a version file we're opening, don't create a version save on it.
21490          if (~EXISTS(FILELAYOUTPATH$&"version")) OR (~EXISTS(FILELAYOUTPATH$&"version\"&FILELAY$&"."&TRIM$(STR$(VER))&FILELAYOUTEXTENSION$)) then ! if its not there, then make it.
21500             let FNCREATEVERSIONSAVEINFO(FILELAY$)
21510          end if 
21520       end if 
21530    fnend 
21540 ! 
21550 Calculatebackupfilename: !  Returns The Backup File Name Of The Given File Name
21560    def FNCALCULATEBACKUPFILENAME$*255(NEWFILENAME$*255;___,LASTSLASH)
21570       let LASTSLASH=POS(NEWFILENAME$,"\",-1)
21580       let NEWFILENAME$(LASTSLASH+1:LASTSLASH)="o"
21590       let FNCALCULATEBACKUPFILENAME$=NEWFILENAME$
21600    fnend 
21610 ! 
21620 Calculatenewfilename: ! Returns The New File Name Of The Given Backup File Name
21630    def FNCALCULATENEWFILENAME$*255(BACKUPFILENAME$*255;___,LASTSLASH)
21640       let LASTSLASH=POS(BACKUPFILENAME$,"\",-1)
21650       if BACKUPFILENAME$(LASTSLASH+1:LASTSLASH+1)="o" then 
21660          let BACKUPFILENAME$(LASTSLASH+1:LASTSLASH+1)=""
21670       end if 
21680       let FNCALCULATENEWFILENAME$=BACKUPFILENAME$
21690    fnend 
21700 ! 
22000 ! #Autonumber# 22000,2
22002 Checkindex: ! Checks to ensure Indexes are up to date
22004    def FNCHECKINDEX(MAINFILE$*255,KEYFILE$*255,KPOS$*50,KLEN$*50,CHECKINDEX;LOGGING,INDEX,ENFORCEDUPKEYS,&CALLINGPROGRAM$,___,DUPKEYS)
22006       if ENFORCEDUPKEYS AND INDEX=1 then let DUPKEYS=0 else let DUPKEYS=1
22008       if EXISTS(KEYFILE$) then 
22010          if CHECKINDEX then 
22012             if FNGETFILEDT$(KEYFILE$)<>FNGETFILEDT$(MAINFILE$) then 
22014                let FNREBUILDINDEX(MAINFILE$,KEYFILE$,KPOS$,KLEN$,1,LOGGING,DUPKEYS,CALLINGPROGRAM$)
22016             end if 
22018          end if 
22020       else 
22022          let FNREBUILDINDEX(MAINFILE$,KEYFILE$,KPOS$,KLEN$,0,LOGGING,DUPKEYS,CALLINGPROGRAM$)
22024       end if 
22026    fnend 
22028 ! 
22030 Reindexallfiles: ! Rebuilds every index in the system
22032    def library FNREINDEXALLFILES(;___,INDEX)
22034       library : FNREINDEX, FNREADLAYOUTS
22036       let FNREADLAYOUTS(MAT REINDEX$)
22038       for INDEX=1 to UDIM(MAT REINDEX$)
22040          let FNREINDEX(REINDEX$(INDEX))
22042       next INDEX
22044    fnend 
22046 ! 
22048    dim REINDEX$(1)*255
22050    dim REBUILDRECL$*255
22052    dim REBUILDINDEXES$(1)*255
22054    dim REBUILDKPOS$(1)*255
22056    dim REBUILDKLEN$(1)*255
22058    dim DUMMY$(1)*255
22060    dim DUMMY(1)
22062 ! 
22064 ! .  ! Included for backwards compatibility
22066    def library FNRENDIX(DATAFILE$*255;CALLINGPROGRAM$*255)  !.. there was a typeo in an earlier version.
22068       library : FNREINDEX
22070       let FNRENDIX=FNREINDEX(DATAFILE$,CALLINGPROGRAM$)
22072    fnend 
22074 ! .  ! Included for compatibility with Susans version, thanks Susan Smith from SMS Software for the Q_INDEX parameter and adding the PATH$ parameter to this function.
22076    def library FNREBUILDKEYS(DATAFILE$*255;Q_INDEX,PATH$*255,CALLINGPROGRAM$*255)
22078       library : FNREINDEX
22080       let FNREBUILDKEYS=FNREINDEX(DATAFILE$,CALLINGPROGRAM$,Q_INDEX,PATH$)
22082    fnend 
22084 Reindex: ! Rebuilds all indexes for a given data file
22086    def library FNREINDEX(DATAFILE$*255;CALLINGPROGRAM$*255,INDEXNUM,PATH$*255,___,INDEX,DUMMY,DUMMY2,DUMMY3)
22088       if CALLINGPROGRAM$="" then let CALLINGPROGRAM$="Unknown"
22090       let FNREADFILELAYOUT(DATAFILE$,REBUILDRECL$,MAT REBUILDINDEXES$,MAT REBUILDKPOS$,MAT REBUILDKLEN$,READFORM$,DUMMY,DUMMY2,0,DUMMY3,MAT DUMMY$,MAT DUMMY)
22092       for INDEX=1 to UDIM(MAT REBUILDINDEXES$)
22094          if INDEXNUM=0 OR INDEXNUM=INDEX then 
22096             if EXISTS(REBUILDINDEXES$(INDEX)) then 
22098                let FNREBUILDINDEX(PATH$&DATAFILE$,PATH$&REBUILDINDEXES$(INDEX),REBUILDKPOS$(INDEX),REBUILDKLEN$(INDEX),1,0,0,CALLINGPROGRAM$)
22100             else 
22102                let FNREBUILDINDEX(PATH$&DATAFILE$,PATH$&REBUILDINDEXES$(INDEX),REBUILDKPOS$(INDEX),REBUILDKLEN$(INDEX),0,0,0,CALLINGPROGRAM$)
22104             end if 
22106          end if 
22108       next INDEX
22110    fnend 
22112 ! 
22114 Rebuildindex: ! Rebuilds an Index that was missing or incomplete
22116    def FNREBUILDINDEX(MAINFILE$*255,KEYFILE$*255,KPOS$*50,KLEN$*50;UPDATE,LOGGING,DUPKEYS,&CALLINGPROGRAM$)
22118       let FNCOMPRESSINDEXPARMS(KPOS$,KLEN$)
22120 ! 
22122       if UPDATE then 
22124          if DUPKEYS then 
22126             execute FNNEEDSTAR$&"index "&MAINFILE$&" "&KEYFILE$&" "&KPOS$&" "&KLEN$&" dupkeys replace shr -N" error IGNORE
22128          else 
22130             execute FNNEEDSTAR$&"index "&MAINFILE$&" "&KEYFILE$&" "&KPOS$&" "&KLEN$&" replace shr -N" error IGNORE
22132          end if 
22134       else 
22136          if DUPKEYS then 
22138             execute FNNEEDSTAR$&"index "&MAINFILE$&" "&KEYFILE$&" "&KPOS$&" "&KLEN$&" dupkeys shr -N" error IGNORE
22140          else 
22142             execute FNNEEDSTAR$&"index "&MAINFILE$&" "&KEYFILE$&" "&KPOS$&" "&KLEN$&" shr -N" error IGNORE
22144          end if 
22146       end if 
22148       if LOGGING then let FNLOG("FileIO Autocreate Index "&MAINFILE$&" "&KEYFILE$&" "&KPOS$&" "&KLEN$,CALLINGPROGRAM$,1)
22150    fnend 
22152 ! 
22154    dim IP_POSITIONS$(1),IP_LENS$(1)
22156    dim IP_POSITIONS(1),IP_LENS(1),IP_MOD$(1)
22158    dim OP_POSITIONS(1),OP_LENS(1),OP_MOD$(1)
22160 ! 
22162    def FNCOMPRESSINDEXPARMS(&KPOS$,&KLEN$;___,INDEX,PREVIOUSSPOT,STARTCURRENT,LENGTHCURRENT,MODCURRENT$,OUTDEX,DIGITS)
22164 ! .     ! A length may end in a modifier (U, YB, Y ...). Adjacent segments merge when both have none or both U,
22166 ! .     !  or a Y segment (year = its first 2 digits) absorbs unmodified ones. YB never merges (BH 2 = YYMM).
22168       let FNSTR2MAT(KPOS$,MAT IP_POSITIONS$,"/")
22170       let FNSTR2MAT(KLEN$,MAT IP_LENS$,"/")
22172 ! 
22174       mat IP_POSITIONS(UDIM(MAT IP_POSITIONS$))
22176       mat IP_LENS(UDIM(MAT IP_LENS$))
22178       mat IP_MOD$(UDIM(MAT IP_LENS$))
22180 ! 
22182       for INDEX=1 to UDIM(MAT IP_POSITIONS)
22184          let IP_POSITIONS(INDEX)=VAL(IP_POSITIONS$(INDEX)) conv Errorcompressing
22186          let IP_LENS$(INDEX)=UPRC$(TRIM$(IP_LENS$(INDEX))) : let DIGITS=0
22188          do WHILE DIGITS<LEN(IP_LENS$(INDEX)) AND POS("0123456789",IP_LENS$(INDEX)(DIGITS+1:DIGITS+1))
22190             let DIGITS+=1
22192          loop 
22194          let IP_MOD$(INDEX)=IP_LENS$(INDEX)(DIGITS+1:LEN(IP_LENS$(INDEX)))
22196          let IP_LENS(INDEX)=VAL(IP_LENS$(INDEX)(1:DIGITS)) conv Errorcompressing
22198       next INDEX
22200 ! 
22202       mat OP_POSITIONS(0)
22204       mat OP_LENS(0)
22206       mat OP_MOD$(0)
22208 ! 
22210       let STARTCURRENT=IP_POSITIONS(1)
22212       let LENGTHCURRENT=IP_LENS(1)
22214       let MODCURRENT$=IP_MOD$(1)
22216 ! 
22218       for INDEX=2 to UDIM(MAT IP_POSITIONS)
22220          if STARTCURRENT+LENGTHCURRENT-1<>IP_POSITIONS(INDEX)-1 OR NOT ((IP_MOD$(INDEX)=MODCURRENT$ AND (MODCURRENT$="" OR MODCURRENT$="U")) OR (MODCURRENT$="Y" AND IP_MOD$(INDEX)="")) then ! If end of previous position is any different then right before current position, or the modifiers can't be merged
22222 ! .           ! We have a gap, or Modifier Changed, save the entries and reset for the next time before processing this new spot.
22224             let OUTDEX=UDIM(MAT OP_POSITIONS)+1
22226             mat OP_POSITIONS(OUTDEX) : mat OP_LENS(OUTDEX) : mat OP_MOD$(OUTDEX)
22228             let OP_POSITIONS(OUTDEX)=STARTCURRENT
22230             let OP_LENS(OUTDEX)=LENGTHCURRENT
22232             let OP_MOD$(OUTDEX)=MODCURRENT$
22234 ! 
22236             let STARTCURRENT=IP_POSITIONS(INDEX)  !Record next start position.
22238             let LENGTHCURRENT=0
22240 ! 
22242             let MODCURRENT$=IP_MOD$(INDEX)
22244          end if 
22246 ! 
22248          let LENGTHCURRENT+=IP_LENS(INDEX)  !Add in the start length
22250       next INDEX
22252 ! 
22254       if LENGTHCURRENT then 
22256          let OUTDEX=UDIM(MAT OP_POSITIONS)+1
22258          mat OP_POSITIONS(OUTDEX) : mat OP_LENS(OUTDEX) : mat OP_MOD$(OUTDEX)
22260          let OP_POSITIONS(OUTDEX)=STARTCURRENT
22262          let OP_LENS(OUTDEX)=LENGTHCURRENT
22264          let OP_MOD$(OUTDEX)=MODCURRENT$
22266       end if 
22268 ! 
22270       let KPOS$=KLEN$=""
22272 ! 
22274       for INDEX=1 to UDIM(MAT OP_POSITIONS)
22276          let KPOS$=KPOS$&STR$(OP_POSITIONS(INDEX))&"/"
22278          let KLEN$=KLEN$&STR$(OP_LENS(INDEX))&OP_MOD$(INDEX)&"/"
22280       next INDEX
22282 ! 
22284       let KPOS$=KPOS$(1:LEN(KPOS$)-1)  !Strip off final "/"
22286       let KLEN$=KLEN$(1:LEN(KLEN$)-1)  !Strip off final "/"
22288    fnend 
22290 ! 
22292 Errorcompressing: ! 
22294    print "There was an error calculating the Index values when generating the index."
22296    print "One of the parameters could not be matched in your subscripts."
22298    print IP_POSITIONS$(INDEX)
22300    print IP_LENS$(INDEX)
22302    pause                              !Give programmer chance to check values
22304    stop 
22306 ! 
22308    def FNSTR2MAT(STRING$*10000,MAT MATRIX$;DELIM$,___,INDEX,POSITION)
22310       if DELIM$="" then let DELIM$=","  !Default Delimiter
22312       mat MATRIX$(0)
22314       do WHILE (POSITION:=POS(STRING$,DELIM$))>0
22316          let INDEX=UDIM(MAT MATRIX$)+1
22318          mat MATRIX$(INDEX)
22320          let MATRIX$(INDEX)=STRING$(1:POSITION-1)
22322          let STRING$(1:POSITION)=""
22324       loop 
22326       let INDEX=UDIM(MAT MATRIX$)+1
22328       mat MATRIX$(INDEX)
22330       let MATRIX$(INDEX)=STRING$
22332    fnend 
22334 ! 
22336 Removedeletes: ! ***** Remove Deleted Records - From Susan Smith
22338    def library FNREMOVEDELETES(LAYOUTNAME$*255;PATH$*255,CALLINGPROGRAM$*255,DONTERROR,___,ORIGFILE$*100,TEMPFILE$*100,FILENAME$*255)
22340       library : FNREINDEX,FNREADLAYOUTHEADER
22342 ! .!
22344       let A=FNREADLAYOUTHEADER(LAYOUTNAME$,FILENAME$)
22346       let ORIGFILE$=FILENAME$
22348       let TEMPFILE$="RemoveDeletes_"&SESSION$
22350 ! .!
22352 ! .     ! If Q_Tempfile$ Exists,
22354       execute "rename "&PATH$&ORIGFILE$&" "&PATH$&TEMPFILE$&" -N" error Skipremovedeletes
22356       execute "copy "&PATH$&TEMPFILE$&" "&PATH$&ORIGFILE$&" -D -N"
22358       if EXISTS(PATH$&ORIGFILE$) then execute FNNEEDSTAR$&"free "&PATH$&TEMPFILE$&" -N"
22360 ! 
22362       let FNREINDEX(LAYOUTNAME$,CALLINGPROGRAM$,0,PATH$)  !Reindex the file
22364       let FNREMOVEDELETES=1
22366 Skipremovedeletes: ! Skip Removing the deletes when the file is in use.
22368    fnend 
22370 ! 
22372 Wrongversion: ! Checks Version, Closes And Updates Files If Wrong Version
22374    def FNWRONGVERSION(FILENUMBER,FILELAY$*255,VER;PATH$*255,___,OLD)
22376       if (OLD:=VERSION(FILENUMBER))>=VER then 
22378          let FNWRONGVERSION=0         !Success
22380          let FNCHECKVERSIONSAVEINFO(FILELAY$,VER)
22382       else 
22384          close #FILENUMBER: 
22386          let FNUPDATE(FILELAY$,OLD,PATH$)
22388          let FNWRONGVERSION=1         !Failure, But Version Was Fixed, So Go Back And Reopen It
22390       end if 
22392    fnend 
22394 ! 
22396    dim UPDATEMESSAGES$(1)*80, PRINTEDYET
22398 ! 
22400 ! 
22402    dim DUMMY$
23000 ! #Autonumber# 23000,5
23005 Update: ! Updates File To Latest Version
23010    def FNUPDATE(FILELAY$*255,OLDVER;&PATH$,__,INDEX,OLDFILE,NEWFILE,OPRE$,NPRE$,NNDEX,OLDFILENAME$*255,LASTUPDATEDKEY,ERRINDEX,LASTPERCENT,RECCOUNT,USERABORTED,INTERVAL,NUMRECS,OLDFILELAY$*255,STAR$,LAYOUTPATH$*128,FILELAYOUTEXTENSION$)
23015 ! 
23020       let LONGMESSAGE$="The file layout has been updated. Before proceeding, we must update the data file to the newest version. "
23025       let LONGMESSAGE$(99999:0)="Choose Yes to continue, or No to Abort.\n\nIf you recently got an update, choose Yes.\n\n"
23030       let LONGMESSAGE$(99999:0)="If you don't know why you're seeing this message, choose No to Abort and then contact your vendor for support."
23035       let LONGMESSAGE$=SREP$(LONGMESSAGE$,"\n",HEX$("0D0A"))
23040 ! 
23045       if ~FNSETTINGS("promptonupdate") OR (2==MSGBOX(LONGMESSAGE$,"Update","yn","QST")) then ! If don't Prompt, or if they chose "Yes"
23050          let STAR$=FNNEEDSTAR$
23055          mat UPDATEMESSAGES$(0) : let PRINTEDYET=0
23060          let LAYOUTPATH$=FNSETTINGS$("layoutpath")
23065          let FILELAYOUTEXTENSION$=FNSETTINGS$("layoutextension")
23070 ! 
23075          on error goto Fileinuse      !Call Rollback Processing For No Changes Made
23080 ! .        ! open #(Window:=fnGetFileNumber): "SRow=11,SCol=2,Rows=1,Cols=78,Caption=,Border=S",display,outin
23085 ! 
23090          dim FM$(1)*1024,NF$(1)*2048,NF(1),OF$(1)*2048,OF(1),NSSUBS$(1)*80,OSSUBS$(1)*80,NNSUBS$(1)*80,ONSUBS$(1)*80,OKEYS$(1)*80
23095          dim NSSPEC$(1),OSSPEC$(1),NNSPEC$(1),ONSPEC$(1)
23100          dim NSDES$(1)*255,OSDES$(1)*255,NNDES$(1)*255,ONDES$(1)*255
23105          dim NSPOS(1),OSPOS(1),NNPOS(1),ONPOS(1)
23110          dim NSDATE$(1)*64,OSDATE$(1)*64,NNDATE$(1)*64,ONDATE$(1)*64
23115 ! 
23120          library : FNOPENFILE, FNCLOSEFILE, FNREADSUBS, FNREADLAYOUTARRAYS
23125 ! 
23130          let OLDFILELAY$="version\"&FILELAY$&"."&STR$(OLDVER)
23135 ! 
23140          if EXISTS(LAYOUTPATH$&OLDFILELAY$&FILELAYOUTEXTENSION$) then 
23145             let FNFINDINDEXES(OLDFILELAY$,OLDFILENAME$,MAT OKEYS$)
23150             let FNPRINT(MAT UPDATEMESSAGES$,"Making Backup Copy of "&PATH$&FNCALCULATENEWFILENAME$(OLDFILENAME$))
23155             execute STAR$&"copy "&PATH$&FNCALCULATENEWFILENAME$(OLDFILENAME$)&" "&PATH$&OLDFILENAME$&" -N -D"
23160             execute STAR$&"copy "&PATH$&FNCALCULATENEWFILENAME$(OLDFILENAME$)&" "&PATH$&FNCALCULATENEWFILENAME$(OLDFILENAME$)&".bak -N"
23165             execute STAR$&"free "&PATH$&FNCALCULATENEWFILENAME$(OLDFILENAME$)&" -N"
23170 ! 
23175             on error goto Fileinusekey  !Call Rollback Processing For File Changed And Some Keys
23180 ! 
23185             for INDEX=1 to UDIM(OKEYS$)
23190                let FNPRINT(MAT UPDATEMESSAGES$,"Making Backup Copy of "&PATH$&FNCALCULATENEWFILENAME$(OKEYS$(INDEX)))
23195                execute STAR$&"copy "&PATH$&FNCALCULATENEWFILENAME$(OKEYS$(INDEX))&" "&FNCALCULATENEWFILENAME$(OKEYS$(INDEX))&".bak -N"
23200                execute STAR$&"free "&PATH$&FNCALCULATENEWFILENAME$(OKEYS$(INDEX))&" -N"
23205             next INDEX
23210 ! 
23215             on error goto Rollbackinfull  !Call Rollback Processing For File / All Keys Changed
23220 ! 
23225             let G_UPDATING=1
23230             let FNPRINT(MAT UPDATEMESSAGES$,"Opening old version of file.")
23235             let OLDFILE=FNOPEN(OLDFILELAY$,MAT OF$,MAT OF, MAT FM$,0,-1,0,PATH$,DUMMY$,DUMMY,0,0,1)
23240 ! .           ! let Fnreadsubs(Oldfilelay$,Mat Ossubs$,Mat Onsubs$,Opre$)
23245             let FNREADLAYOUTARRAYS(OLDFILELAY$,OPRE$,MAT OSSUBS$,MAT ONSUBS$,MAT OSSPEC$,MAT ONSPEC$,MAT OSDES$,MAT ONDES$,MAT OSPOS,MAT ONPOS,0,MAT OSDATE$,MAT ONDATE$)
23250             let FNPRINT(MAT UPDATEMESSAGES$,"Creating new version of file.")
23255             let NEWFILE=FNOPEN(FILELAY$,MAT NF$,MAT NF,MAT FM$,0,0,0,PATH$,DUMMY$,DUMMY,2,0,1)  !Will Automatically Create
23260 ! .           ! let Fnreadsubs(Filelay$,Mat Nssubs$,Mat Nnsubs$,Npre$)
23265             let FNREADLAYOUTARRAYS(FILELAY$,NPRE$,MAT NSSUBS$,MAT NNSUBS$,MAT NSSPEC$,MAT NNSPEC$,MAT NSDES$,MAT NNDES$,MAT NSPOS,MAT NNPOS,0,MAT NSDATE$,MAT NNDATE$)
23270             let FNPRINT(MAT UPDATEMESSAGES$,"Preforming File Update. SHIFT-A to abort.")
23275             let NUMRECS=LREC(OLDFILE)
23280 ! 
23285 Readoldrecord: ! Read The Old Record Here
23290             read #OLDFILE, using FM$(OLDFILE), release: MAT OF$, MAT OF eof Doneupdating
23295 ! 
23300             let FNUPDATEPROGRESSBAR((RECCOUNT+=1)/NUMRECS,"",.01,0,.15," Updating '"&FILELAY$&"' File - Please Wait ","Preforming File Update. Completed: "&STR$(RECCOUNT)&" / "&STR$(NUMRECS)&". Press SHIFT-A to abort.")
23305 ! 
23310             mat NF$=("")
23315             mat NF=(0)
23320 ! 
23325             for INDEX=1 to UDIM(OSSUBS$)  !Copy String Values
23330                if (NNDEX:=SRCH(MAT NSSUBS$,OSSUBS$(INDEX)))>0 then 
23335 ! .                 ! If there are dates, convert them from the from format to the to format.
23340                   let NF$(NNDEX)=TRIM$(FNFMTSDATE$(OF$(INDEX),OSDATE$(INDEX),NSDATE$(NNDEX)))
23345                end if 
23350             next INDEX
23355             for INDEX=1 to UDIM(ONSUBS$)  !Copy Number Values
23360                if (NNDEX:=SRCH(MAT NNSUBS$,ONSUBS$(INDEX)))>0 then 
23365 ! .                 ! If there are dates, convert them from the from format to the to format.
23370                   let NF(NNDEX)=VAL(FNFMTNDATE$(OF(INDEX),ONDATE$(INDEX),NNDATE$(NNDEX))) conv Updatefallbacknumber
23375                end if 
23380             next INDEX
23385             write #NEWFILE, using FM$(NEWFILE) : MAT NF$, MAT NF
23390             if KSTAT$="A" then let USERABORTED=1 : goto Rollbackinfull
23395             goto Readoldrecord
23400 Doneupdating: ! We Are Finished
23405             let FNCLOSEFILE(OLDFILE,OLDFILELAY$)
23410             let FNCLOSEFILE(NEWFILE,FILELAY$)
23415 ! 
23420             close #WINDOW: 
23425             let FNCLOSEPROGRESSBAR
23430 ! 
23435             let G_UPDATING=0          !We Are Done Updating
23440          else 
23445             print "Error: Unable to locate old version file layout: "&LAYOUTPATH$&OLDFILELAY$&FILELAYOUTEXTENSION$
23450             pause 
23455             execute "system"
23460          end if 
23465          let FNRESETERRORHANDLING
23470       else 
23475          print "Error: User Aborted"
23480          pause 
23485          execute "system"
23490       end if 
23495    fnend 
23500 ! 
23505 Updatefallbacknumber: ! Fallback if date conversion fails in updating a number
23510    let NF(NNDEX)=OF(INDEX)
23515    continue 
23520 Updatefallbackstring: ! Fallback if date conversion fails in updating a number
23525    let NF$(NNDEX)=OF$(INDEX)
23530    continue 
23535 ! 
23540 ! 
23600 ! Error Checking Rollback Update Routine.       #Autonumber# 23600,5
23605 Rollbackinfull: ! Close All Files And Roll Back
23610    on error system 
23615    let UPDATEERRORRECIEVED=ERR
23620    let UPDATEERRORLINE=LINE
23625    if OLDFILE then let FNCLOSEFILE(OLDFILE,OLDFILELAY$)
23630    if NEWFILE then let FNCLOSEFILE(NEWFILE,FILELAY$)
23635    let LASTUPDATEDKEY=UDIM(OKEYS$)    !Set Value To Roll Back All Indexes
23640 ! 
23645 Fileinusekey: ! Error In Second Part. Partially Roll Back
23650    on error system 
23655    if UPDATEERRORRECIEVED=0 then let UPDATEERRORRECIEVED=ERR
23660    if UPDATEERRORLINE=0 then let UPDATEERRORLINE=LINE
23665    print MAT UPDATEMESSAGES$
23670    print "Error encountered or User abort: Rolling back to previous version. Type GO[ENTER] to Quit."
23675    let PRINTEDYET=1
23680    if ~LASTUPDATEDKEY then let LASTUPDATEDKEY=INDEX-1
23685    for ERRINDEX=1 to LASTUPDATEDKEY   !Roll Back All Successful Indexes
23690       if EXISTS(PATH$&OKEYS$(ERRINDEX)) then !:
               execute STAR$&"copy "&PATH$&FNCALCULATENEWFILENAME$(OKEYS$(ERRINDEX))&".bak "&PATH$&FNCALCULATENEWFILENAME$(OKEYS$(ERRINDEX))  !Copy Backup File To Origional File
23695    next ERRINDEX
23700    if EXISTS(PATH$&OLDFILENAME$) then !:
            execute STAR$&"copy "&PATH$&FNCALCULATENEWFILENAME$(OLDFILENAME$)&".bak "&PATH$&FNCALCULATENEWFILENAME$(OLDFILENAME$)
23705 ! 
23710 Fileinuse: ! Error In First Part
23715    on error system 
23720    if ~PRINTEDYET then 
23725       print MAT UPDATEMESSAGES$
23730       print "Error encountered or User abort: Rolling back to previous version. Type GO[ENTER] to Quit."
23735       let PRINTEDYET=1
23740    end if 
23745    if UPDATEERRORRECIEVED=0 then let UPDATEERRORRECIEVED=ERR
23750    if UPDATEERRORLINE=0 then let UPDATEERRORLINE=LINE
23755    print FNERRORMESSAGE$(UPDATEERRORRECIEVED,UPDATEERRORLINE)
23760    pause 
23765    execute "system"
23770 ! 
23800 ! #Autonumber# 23800,5
23805 Errormessages: ! Return The Proper Error Message For Rollback Errors
23810    def FNERRORMESSAGE$*80(ERRORNUM,ERRORLINE)
23815       do 
23820          if STR$(ERRORLINE)(1:2)="21" then 
23825             let FNERRORMESSAGE$="Error during create: Check heading information in file layout."
23830             exit do 
23835          end if 
23840          if ERRORNUM=4148 then 
23845             let FNERRORMESSAGE$="The file was in use. Please close all other copies of BR and try again."
23850             exit do 
23855          end if 
23860          if USERABORTED then 
23865             let FNERRORMESSAGE$="User Aborted."
23870             exit do 
23875          end if 
23880          let FNERRORMESSAGE$="Error updating file: "&STR$(ERRORNUM)&" occured on line: "&STR$(ERRORLINE)
23885          exit do 
23890       loop 
23895    fnend 
23900 ! 
23905    def FNPRINT(MAT UPDATEMESSAGES$,MESSAGE$*80;___,INDEX)
23910 ! .  ! print #Window, fields "1,1,C 78" : Message$
23915       let FNUPDATEPROGRESSBAR(0,"",.01,0,.15," Updating '"&FILELAY$&"' File - Please Wait ",MESSAGE$)
23920 ! 
23925       let INDEX=UDIM(MAT UPDATEMESSAGES$)+1
23930       mat UPDATEMESSAGES$(INDEX)
23935       let UPDATEMESSAGES$(INDEX)=MESSAGE$
23940    fnend 
23945 ! 
24000 ! #Autonumber# 24000,2
24002 Findindexes: ! ***** Reads A File Layout And Finds All Indexes
24004    def FNFINDINDEXES(LAYOUTNAME$*255;&FILENAME$,MAT KEYS$)
24006 ! .  ! Included for Backwards Compatability
24008       library : FNREADLAYOUTHEADER
24010       let FNFINDINDEXES=FNREADLAYOUTHEADER(LAYOUTNAME$,FILENAME$,MAT KEYS$)
24012    fnend 
24014 ! 
24016 Readentirelayout: ! Reads the entire layout into arrays
24018    def library FNREADENTIRELAYOUT(LAYOUTNAME$*255;&FILENAME$,&PREFIX$,MAT KEYS$,MAT KEYDESCRIPTION$,MAT SSUBS$,MAT NSUBS$,MAT SSPEC$,MAT NSPEC$,MAT SDESCRIPTION$,MAT NDESCRIPTION$,MAT SPOS,MAT NPOS,MAT SDATEFMT$,MAT NDATEFMT$,___,FILENUMBER)
24020       library : FNREADLAYOUTHEADER, FNREADLAYOUTARRAYS
24022       let FILENUMBER=FNREADLAYOUTHEADER(LAYOUTNAME$,FILENAME$,MAT KEYS$,MAT KEYDESCRIPTION$,1,PREFIX$)
24024       let FNREADENTIRELAYOUT=FNREADLAYOUTARRAYS(LAYOUTNAME$,PREFIX$,MAT SSUBS$,MAT NSUBS$,MAT SSPEC$,MAT NSPEC$,MAT SDESCRIPTION$,MAT NDESCRIPTION$,MAT SPOS,MAT NPOS,FILENUMBER,MAT SDATEFMT$,MAT NDATEFMT$)
24026    fnend 
24028 ! 
24030 Readlayoutheader: ! Reads the layout header and returns Arrays
24032    def library FNREADLAYOUTHEADER(LAYOUTNAME$*255;&FILENAME$,MAT KEYS$,MAT KEYDESCRIPTION$,LEAVEOPEN,&PREFIX$,___,COUNT,KEYNAME$*255,DESCRIPTION$*255,VERS$*80,BKEYS,BKEYDESCRIPTION,LINE$*512,LAYOUTPATH$*128,FILELAYOUTEXTENSION$)
24034       library : FNGETFILENUMBER
24036 ! 
24038       let LAYOUTNAME$=TRIM$(LAYOUTNAME$)
24040       let LAYOUTPATH$=FNSETTINGS$("layoutpath")
24042       let FILELAYOUTEXTENSION$=FNSETTINGS$("layoutextension")
24044 ! 
24046       if TRIM$(LAYOUTNAME$)<>"" AND EXISTS(LAYOUTPATH$&LAYOUTNAME$&FILELAYOUTEXTENSION$) then 
24048          if FNSMATRIXPRESENT(MAT KEYS$) then let BKEYS=1
24050          if FNSMATRIXPRESENT(MAT KEYDESCRIPTION$) then let BKEYDESCRIPTION=1
24052 ! 
24054          if BKEYS then mat KEYS$(0)
24056          if BKEYDESCRIPTION then mat KEYDESCRIPTION$(0)
24058 ! 
24060          if ~FNOPENLAYOUT(LAYOUTPATH$&LAYOUTNAME$&FILELAYOUTEXTENSION$) then goto Errorreadfilelayout
24062 ! 
24064          let LINE$=FNLAYOUTLINPUT$
24066          if UPRC$(LINE$)<>"#EOF#" then 
24068             let FNREADHEADING(LINE$,FILENAME$,PREFIX$,VERS$)
24070          else 
24072             print "Incomplete Layout."
24074             goto Errorreadfilelayout
24076          end if 
24078 ! 
24080          let LINE$=FNLAYOUTLINPUT$
24082          if UPRC$(LINE$)<>"#EOF#" then 
24084             let FNREADKEYS(LINE$,KEYNAME$,DESCRIPTION$)
24086          else 
24088             print "Incomplete Layout."
24090             goto Errorreadfilelayout
24092          end if 
24094 ! 
24096          do WHILE UPRC$(KEYNAME$(1:4))<>"RECL" AND KEYNAME$(1:4)<>"===="
24098             let COUNT+=1
24100             if BKEYS then 
24102                mat KEYS$(COUNT)
24104                let KEYS$(COUNT)=TRIM$(KEYNAME$)
24106             end if 
24108             if BKEYDESCRIPTION then 
24110                mat KEYDESCRIPTION$(COUNT)
24112                let KEYDESCRIPTION$(COUNT)=TRIM$(DESCRIPTION$)
24114             end if 
24116 ! 
24118             let LINE$=FNLAYOUTLINPUT$
24120             if UPRC$(LINE$)<>"#EOF#" then 
24122                let FNREADKEYS(LINE$,KEYNAME$,DESCRIPTION$)
24124             else 
24126                print "Incomplete Layout."
24128                goto Errorreadfilelayout
24130             end if 
24132          loop 
24134          if UPRC$(KEYNAME$(1:4))="RECL" then 
24136             let LINE$=FNLAYOUTLINPUT$
24138             if UPRC$(LINE$)="#EOF#" then 
24140                print "Incomplete Layout."
24142                goto Errorreadfilelayout
24144             end if 
24146          end if 
24148       end if 
24150       if LEAVEOPEN then 
24152          let FNREADLAYOUTHEADER=1
24154       else 
24156          let FNREADLAYOUTHEADER=COUNT
24158       end if 
24160    fnend 
24162 ! 
24164 Readsubs: ! Read File Layout, Returning All Subscripts As An Array
24166    def library FNREADSUBS(FILENAME$*255,MAT SSUBS$,MAT NSUBS$,&PREFIX$)
24168 ! .  ! Included for Backwards Compatability Only
24170       library : FNREADLAYOUTARRAYS
24172       let FNREADLAYOUTARRAYS(FILENAME$,PREFIX$,MAT SSUBS$,MAT NSUBS$)
24174    fnend 
24176 ! 
24178 Readlayoutarrays: ! Read File Layout, Returning Everything As Some Arrays
24180    def library FNREADLAYOUTARRAYS(LAYOUTNAME$*255,&PREFIX$;MAT SSUBS$,MAT NSUBS$,MAT SSPEC$,MAT NSPEC$,MAT SDESCRIPTION$,MAT NDESCRIPTION$,MAT SPOS,MAT NPOS,ALREADYOPENFILENUMBER,MAT SDATEFORMAT$,MAT NDATEFORMAT$,MAT S4THCOL$,MAT N4THCOL$,___,INDEX,DUMMY$*512,DUMMY2$*255,SUBNAME$*255,LAYOUT,DESCRIPTION$*255,SPEC$*255,COLUMN4$*255,BSSUBS,BNSUBS,BSDESCRIPTION,BNDESCRIPTION,BSSPEC,BNSPEC,BSPOS,BNPOS,BSDATEFORMAT,BNDATEFORMAT,BS4THCOL,BN4THCOL,POSITION,COUNT,LINE$*512,DATEFORMAT$*50)
24182       library : FNGETFILENUMBER
24184 ! 
24186       let LAYOUTNAME$=TRIM$(LAYOUTNAME$)
24188       let POSITION=1
24190       let LAYOUTPATH$=FNSETTINGS$("layoutpath")  !Read File Layout Path
24192       let FILELAYOUTEXTENSION$=FNSETTINGS$("layoutextension")
24194 ! 
24196       if TRIM$(LAYOUTNAME$)<>"" AND EXISTS(LAYOUTPATH$&LAYOUTNAME$&FILELAYOUTEXTENSION$) then 
24198          if FNSMATRIXPRESENT(MAT SSUBS$) then let BSSUBS=1
24200          if FNSMATRIXPRESENT(MAT NSUBS$) then let BNSUBS=1
24202          if FNSMATRIXPRESENT(MAT SSPEC$) then let BSSPEC=1
24204          if FNSMATRIXPRESENT(MAT NSPEC$) then let BNSPEC=1
24206          if FNSMATRIXPRESENT(MAT SDESCRIPTION$) then let BSDESCRIPTION=1
24208          if FNSMATRIXPRESENT(MAT NDESCRIPTION$) then let BNDESCRIPTION=1
24210          if FNSMATRIXPRESENT(MAT SDATEFORMAT$) then let BSDATEFORMAT=1
24212          if FNSMATRIXPRESENT(MAT NDATEFORMAT$) then let BNDATEFORMAT=1
24214          if FNSMATRIXPRESENT(MAT S4THCOL$) then let BS4THCOL=1
24216          if FNSMATRIXPRESENT(MAT N4THCOL$) then let BN4THCOL=1
24218          if FNNMATRIXPRESENT(MAT SPOS) then let BSPOS=1
24220          if FNNMATRIXPRESENT(MAT NPOS) then let BNPOS=1
24222 ! 
24224          if BSSUBS then mat SSUBS$(0)
24226          if BNSUBS then mat NSUBS$(0)
24228          if BSSPEC then mat SSPEC$(0)
24230          if BNSPEC then mat NSPEC$(0)
24232          if BSDESCRIPTION then mat SDESCRIPTION$(0)
24234          if BNDESCRIPTION then mat NDESCRIPTION$(0)
24236          if BSDATEFORMAT then mat SDATEFORMAT$(0)
24238          if BNDATEFORMAT then mat NDATEFORMAT$(0)
24240          if BS4THCOL then mat BS4THCOL$(0)
24242          if BN4THCOL then mat BN4THCOL$(0)
24244          if BSPOS then mat SPOS(0)
24246          if BNPOS then mat NPOS(0)
24248 ! 
24250          if ALREADYOPENFILENUMBER then 
24252 ! .        ! Then we're already there.
24254 ! .        ! Otherwise, (below) we get the prefix and skip to the details
24256          else 
24258             if ~FNOPENLAYOUT(LAYOUTPATH$&LAYOUTNAME$&FILELAYOUTEXTENSION$) then goto Errorreadfilelayout
24260             let LINE$=FNLAYOUTLINPUT$
24262             if UPRC$(LINE$)<>"#EOF#" then 
24264                let FNREADHEADING(LINE$,DUMMY$,PREFIX$,DUMMY2$)
24266                let PREFIX$=TRIM$(PREFIX$)
24268             else 
24270                print "Incomplete Layout."
24272                goto Errorreadfilelayout
24274             end if 
24276             do 
24278                let LINE$=FNLAYOUTLINPUT$
24280                if UPRC$(LINE$)="#EOF#" then 
24282                   print "Incomplete Layout."
24284                   goto Errorreadfilelayout
24286                end if 
24288             loop WHILE UPRC$(LINE$(1:4))<>"RECL" AND LINE$(1:4)<>"===="
24290             if UPRC$(LINE$(1:4))="RECL" then 
24292                let LINE$=FNLAYOUTLINPUT$
24294                if UPRC$(LINE$)="#EOF#" then 
24296                   print "Incomplete Layout."
24298                   goto Errorreadfilelayout
24300                end if 
24302             end if 
24304          end if 
24306 Readnextlayoutline: ! Read The Next Line For Processing
24308          let LINE$=FNLAYOUTLINPUT$
24310          if UPRC$(LINE$)="#EOF#" then goto Donereadlayoutarrays
24312 ! 
24314          let FNPARSEDETAILLAYOUTLINE(LINE$,SUBNAME$,DESCRIPTION$,SPEC$,DATEFORMAT$,COLUMN4$)
24316 ! 
24318          if TRIM$(UPRC$(SPEC$))(1:2)<>"X " then 
24320             if TRIM$(SUBNAME$)<>"" then 
24322                if FNSTRINGSPEC(SUBNAME$,SPEC$) then 
24324                   let COUNT+=1
24326                   if BSSUBS then 
24328                      mat SSUBS$(UDIM(SSUBS$)+1)
24330                      let SSUBS$(UDIM(SSUBS$))=TRIM$(SREP$(SUBNAME$,"$",""))
24332                   end if 
24334                   if BSSPEC then 
24336                      mat SSPEC$(UDIM(SSPEC$)+1)
24338                      let SSPEC$(UDIM(SSPEC$))=TRIM$(SPEC$)
24340                   end if 
24342                   if BSDESCRIPTION then 
24344                      mat SDESCRIPTION$(UDIM(SDESCRIPTION$)+1)
24346                      let SDESCRIPTION$(UDIM(SDESCRIPTION$))=TRIM$(DESCRIPTION$)
24348                   end if 
24350                   if BSDATEFORMAT then 
24352                      mat SDATEFORMAT$(UDIM(SDATEFORMAT$)+1)
24354                      let SDATEFORMAT$(UDIM(SDATEFORMAT$))=DATEFORMAT$
24356                   end if 
24358                   if BS4THCOL then 
24360                      mat S4THCOL$(UDIM(S4THCOL$)+1)
24362                      let S4THCOL$(UDIM(S4THCOL$))=COLUMN4$
24364                   end if 
24366                   if BSPOS then 
24368                      mat SPOS(UDIM(SPOS)+1)
24370                      let SPOS(UDIM(SPOS))=POSITION
24372                   end if 
24374                else 
24376                   if BNSUBS then 
24378                      mat NSUBS$(UDIM(NSUBS$)+1)
24380                      let NSUBS$(UDIM(NSUBS$))=TRIM$(SUBNAME$)
24382                   end if 
24384                   if BNSPEC then 
24386                      mat NSPEC$(UDIM(NSPEC$)+1)
24388                      let NSPEC$(UDIM(NSPEC$))=TRIM$(SPEC$)
24390                   end if 
24392                   if BNDESCRIPTION then 
24394                      mat NDESCRIPTION$(UDIM(NDESCRIPTION$)+1)
24396                      let NDESCRIPTION$(UDIM(NDESCRIPTION$))=TRIM$(DESCRIPTION$)
24398                   end if 
24400                   if BNDATEFORMAT then 
24402                      mat NDATEFORMAT$(UDIM(NDATEFORMAT$)+1)
24404                      let NDATEFORMAT$(UDIM(NDATEFORMAT$))=DATEFORMAT$
24406                   end if 
24408                   if BN4THCOL then 
24410                      mat N4THCOL$(UDIM(N4THCOL$)+1)
24412                      let N4THCOL$(UDIM(N4THCOL$))=COLUMN4$
24414                   end if 
24416                   if BNPOS then 
24418                      mat NPOS(UDIM(NPOS)+1)
24420                      let NPOS(UDIM(NPOS))=POSITION
24422                   end if 
24424                end if 
24426             end if 
24428          end if 
24430          let POSITION+=FNLENGTHOF(TRIM$(SPEC$))
24432          goto Readnextlayoutline
24434 Donereadlayoutarrays: ! We Finished With All The File Layout
24436          let FNREADLAYOUTARRAYS=COUNT
24438       end if 
24440    fnend 
24442 ! 
24444    def FNSTRINGSPEC(VAR$*80,SPEC$*80;___,TYPE$,P)
24446       let TYPE$=UPRC$(TRIM$(SPEC$))
24448       if POS(TYPE$," ") then let TYPE$=TYPE$(1:POS(TYPE$," ")-1)
24450 ! 
24452       if TYPE$ = "C" OR TYPE$ = "V" OR TYPE$ = "CC" OR TYPE$ = "CR" then ! #Select# Type$ #Case# "C" # "V" # "CC" # "CR"
24454          let FNSTRINGSPEC=1
24456       else if TYPE$ = "B" OR TYPE$ = "BL" OR TYPE$ = "BH" OR TYPE$ = "D" OR TYPE$ = "DH" OR TYPE$ = "DL" OR TYPE$ = "DT" OR TYPE$ = "L" OR TYPE$ = "N" OR TYPE$ = "NZ" OR TYPE$ = "PD" OR TYPE$ = "S" OR TYPE$ = "ZD" then ! #Case# "B" # "BL" # "BH" # "D" # "DH" # "DL" # "DT" # "L" # "N" # "NZ" # "PD" # "S" # "ZD"
24458          let FNSTRINGSPEC=0
24460       else if TYPE$ = "G" OR TYPE$ = "GF" OR TYPE$ = "GZ" then ! #Case# "G" # "GF" # "GZ"
24462          if POS(VAR$,"$") then let FNSTRINGSPEC=1
24464       else ! #Case Else#
24466          if POS(VAR$,"$") then let FNSTRINGSPEC=1
24468       end if                          !#End Select#
24470    fnend 
24472 ! 
24474 Readkeyfiles: ! This function reads the key file list of a file layout
24476    def library FNREADKEYFILES(LAYOUT$,MAT KEYS$;___,FILENAME$*255)
24478 ! .  ! Included for Backwards Compatability
24480       let FNFINDINDEXES(LAYOUT$,FILENAME$,MAT KEYS$)
24482    fnend 
24484 ! 
24486 Buildkey: ! This function builds a key off of mat F$ and mat F
24488    def library FNBUILDKEY$*255(LAYOUT$*30,MAT F$,MAT F;KEYNUM,___,VALUE$*255,SPOS,EPOS,UPPERCASE,FILENAME$*80,PREFIX$,INDEX,KEYPART$*30,KEYFIELDS$*80,KEY$*255)
24490 ! 
24492       dim BK_KEYS$(1)*80
24494       dim BK_KEYFIELDS$(1)*80
24496       dim BK_SSUBS$(1)*80
24498       dim BK_NSUBS$(1)*80
24500       dim BK_SSPEC$(1)*80
24502       dim BK_NSPEC$(1)*80
24504       dim BK_LASTLAYOUT$*30
24506 ! 
24508       if (TRIM$(LAYOUT$)<>"") AND (UDIM(MAT F$)+UDIM(MAT F)) then 
24510          if LAYOUT$<>BK_LASTLAYOUT$ then 
24512             library : FNREADENTIRELAYOUT, FNKEY$
24514 ! 
24516             mat BK_KEYS$(0)
24518             mat BK_KEYFIELDS$(0)
24520 ! 
24522             let FNREADENTIRELAYOUT(LAYOUT$,FILENAME$,PREFIX$,MAT BK_KEYS$,MAT BK_KEYFIELDS$,MAT BK_SSUBS$,MAT BK_NSUBS$,MAT BK_SSPEC$,MAT BK_NSPEC$)
24524 ! 
24526             for INDEX=1 to UDIM(MAT BK_SSUBS$)
24528                let BK_SSUBS$(INDEX)=LWRC$(BK_SSUBS$(INDEX))
24530             next INDEX
24532             for INDEX=1 to UDIM(MAT BK_NSUBS$)
24534                let BK_NSUBS$(INDEX)=LWRC$(BK_NSUBS$(INDEX))
24536             next INDEX
24538 ! 
24540             let BK_LASTLAYOUT$=LAYOUT$
24542          end if 
24544 ! 
24546          if UDIM(MAT BK_KEYS$) then 
24548 ! 
24550             if KEYNUM=0 then let KEYNUM=1
24552             let KEYFIELDS$=LWRC$(TRIM$(BK_KEYFIELDS$(KEYNUM)))
24554 ! 
24556             do 
24558                if POS(KEYFIELDS$,"/") then 
24560                   let KEYPART$=KEYFIELDS$(1:POS(KEYFIELDS$,"/")-1)
24562                   let KEYFIELDS$(1:POS(KEYFIELDS$,"/"))=""
24564                else 
24566                   let KEYPART$=KEYFIELDS$
24568                   let KEYFIELDS$=""
24570                end if 
24572 ! 
24574 ! .           ! Here, we need to interpret the (5:8) style Partial specs
24576 ! .           !  And we also need to handle -U for uppercase.
24578                let SPOS=EPOS=UPPERCASE
24580 ! 
24582                let FNEXTRACTKEYFORMAT(KEYPART$,SPOS,EPOS,UPPERCASE)
24584 ! 
24586                let VALUE$=""
24588                if (INDEX:=SRCH(MAT BK_SSUBS$,KEYPART$))>0 then 
24590                   let VALUE$=RPAD$(RTRM$(F$(INDEX))(1:FNLENGTHOF(BK_SSPEC$(INDEX))),FNLENGTHOF(BK_SSPEC$(INDEX)))
24592                else if (INDEX:=SRCH(MAT BK_NSUBS$,KEYPART$))>0 then 
24594                   let VALUE$=CNVRT$(BK_NSPEC$(INDEX),F(INDEX))
24596                end if 
24598                if SPOS OR EPOS then let VALUE$=VALUE$(SPOS:EPOS)
24600                if UPPERCASE then let VALUE$=UPRC$(VALUE$)
24602                let KEY$=KEY$&VALUE$
24604             loop WHILE LEN(KEYFIELDS$)
24606 ! 
24608             let FNBUILDKEY$=KEY$
24610          end if 
24612       end if 
24614    fnend 
24616 ! 
24618    def FNEXTRACTKEYFORMAT(&KEYPART$;&SPOS,&EPOS,&UPPER,___,PS,PE,PARENS$,DASH)
24620       let KEYPART$=TRIM$(KEYPART$)
24622 ! .  ! Takes a string and pulls out the () stuff.
24624       let PS=POS(KEYPART$,"(")
24626       if PS then 
24628          let PE=POS(KEYPART$,")")
24630          if PE then 
24632             let PARENS$=KEYPART$(PS+1:PE-1)
24634             let KEYPART$(PS:PE)=""
24636             let STR2MAT(PARENS$,MAT PARENS$,":")
24638             if UDIM(MAT PARENS$)>1 then 
24640                let SPOS=VAL(PARENS$(1))
24642                let EPOS=VAL(PARENS$(2))
24644             end if 
24646          end if 
24648       end if 
24650 ! 
24652 ! .  ! Next strip any "-xx" modifier (U, YB, Y ...) - only U changes the key value
24654       let KEYPART$=TRIM$(KEYPART$)
24656       if (DASH:=POS(KEYPART$,"-"))>0 then 
24658          if LWRC$(TRIM$(KEYPART$(DASH+1:LEN(KEYPART$))))="u" then let UPPER=1
24660          let KEYPART$=TRIM$(KEYPART$(1:DASH-1))
24662       end if 
24664    fnend 
24666 ! 
24668 ! 
25000 ! #Autonumber# 25000,5
25005 Closefile: ! ***** Close A File, Closing All Indexes == Use Only With Files Opened I/O With This Library
25010    def library FNCLOSEFILE(FILENUMBER, FILELAY$*255;PATH$*255,OUT,___,REMAINING,FILENAME$*255,CLOSEFILESIMPLE)
25015 ! 
25020       dim CF_DUMMYFILENAME$*255, CF_DUMMYFILENAME2$*255
25025 ! .  ! Out forces not checking if its input or outin - use to increase speed
25030 ! .  !  when you know for a fact the file is opened outin
25035 ! .  !  -1 will force input, 1 will force output, 0 or not specified will check.
25040 ! 
25045       let CLOSEFILESIMPLE=FNSETTINGS("closefilesimple")
25050 ! 
25055       if OUT=-1 OR (~OUT AND FNINPUT(FILENUMBER)) then 
25060          close #FILENUMBER: 
25065       else 
25070          let REMAINING=FNFINDINDEXES(FILELAY$,FILENAME$)
25075 ! 
25080          if CLOSEFILESIMPLE OR ~FN418 then 
25085             let FILENAME$=SREP$(UPRC$(FILENAME$),"[WSID]",WSID$)
25090             let FILENAME$=SREP$(UPRC$(FILENAME$),"[SESSION]",SESSION$)
25095          end if 
25100 ! 
25105          if KLN(FILENUMBER)=-1 then let REMAINING+=1
25110          do WHILE FILENUMBER<=999
25115             if ~CLOSEFILESIMPLE AND FN418 then 
25120                let SLEEPRETRYCOUNT=0
25125                let CF_DUMMYFILENAME$=UPRC$(OS_FILENAME$(FILE$(FILENUMBER))) error Sleepretrycount
25130                let SLEEPRETRYCOUNT=0
25135                let CF_DUMMYFILENAME2$=UPRC$(OS_FILENAME$(PATH$&FILENAME$)) error Sleepretrycount
25140                if CF_DUMMYFILENAME$=CF_DUMMYFILENAME2$ then 
25145                   close #(FILENUMBER):  !Close Only If Its This File
25150                   let REMAINING-=1
25155                end if 
25160             else 
25165                if POS(UPRC$(FILE$(FILENUMBER)),"\"&UPRC$(FILENAME$)) OR UPRC$(FILE$(FILENUMBER))=UPRC$(FILENAME$) then 
25170                   close #(FILENUMBER):  !Close Only If Its This File
25175                   let REMAINING-=1
25180                end if 
25185             end if 
25190             let FILENUMBER+=1
25195          loop WHILE REMAINING>0
25200       end if 
25205    fnend 
25210 ! 
25215    def FNINPUT(FILENUMBER;___,DISPLAYFILE,LINE$*255,STAR$)
25220       let STAR$=FNNEEDSTAR$
25225       library : FNGETFILENUMBER
25230       if EXISTS("fileinfo."&SESSION$&"") then execute ""&STAR$&"free fileinfo."&SESSION$&" -N"
25235       execute ""&STAR$&"status files >fileinfo."&SESSION$&""
25240       open #(DISPLAYFILE:=FNGETFILENUMBER): "name=fileinfo."&SESSION$, display, input 
25245 Readnextinfoline: ! Check the next input line
25250       linput #DISPLAYFILE: LINE$ eof Doneinput
25255       if POS(LWRC$(LINE$),"open file #"&LPAD$(STR$(FILENUMBER),3)) then 
25260          linput #DISPLAYFILE: LINE$
25265          if POS(LWRC$(LINE$),"input") then 
25270             let FNINPUT=1
25275          end if 
25280          goto Doneinput
25285       end if 
25290       goto Readnextinfoline
25295 Doneinput: ! Done fnInput Here
25300       close #DISPLAYFILE: 
25305       execute ""&STAR$&"free fileinfo."&SESSION$&" -N" error IGNORE
25310    fnend 
25315 ! 
25500 ! #Autonumber# 25500,2
25502 Makesubproc: ! Read File Layout, Returning All Subscripts As A Procfile
25504    def library FNMAKESUBPROC(FILENAME$*255;MAT SUBS$,MAT F$,MAT F,___,ANFWASGIVEN,INDEX,DUMMY$*512,DUMMY2$*255,SUBNAME$*255,DESCRIPTION$*255,SPEC$*255,LAYOUT,SUBS,PREFIX$*255,LAYOUTPATH$*255,STRINGSIZE,NUMBERSIZE,LINE$*512,STAR$,DATEFORMAT$*50)
25506       let STAR$=FNNEEDSTAR$
25508       let LAYOUTPATH$=FNSETTINGS$("layoutpath")
25510       let FILELAYOUTEXTENSION$=FNSETTINGS$("layoutextension")
25512 ! 
25514       if ~FNOPENLAYOUT(LAYOUTPATH$&FILENAME$&FILELAYOUTEXTENSION$) then goto Errorreadfilelayout
25516       if FNSMATRIXPRESENT(MAT SUBS$) then 
25518          mat SUBS$(0)
25520       else 
25522          open #(SUBS:=FNGETFILENUMBER): "Name=subs.$$$, replace", display, output 
25524       end if 
25526       if FNSMATRIXPRESENT(MAT F$) AND FNNMATRIXPRESENT(MAT F) then 
25528          let ANFWASGIVEN=1
25530       end if 
25532 ! 
25534       let LINE$=FNLAYOUTLINPUT$
25536       if UPRC$(LINE$)<>"#EOF#" then 
25538          let FNREADHEADING(LINE$,DUMMY$,PREFIX$,DUMMY2$)
25540          let PREFIX$=TRIM$(PREFIX$)
25542       else 
25544          print "Incomplete Layout."
25546          goto Errorreadfilelayout
25548       end if 
25550 ! 
25552       do 
25554          let LINE$=FNLAYOUTLINPUT$
25556          if UPRC$(LINE$)="#EOF#" then 
25558             print "Incomplete Layout."
25560             goto Errorreadfilelayout
25562          end if 
25564       loop WHILE UPRC$(LINE$(1:4))<>"RECL" AND LINE$(1:4)<>"===="
25566       if UPRC$(LINE$(1:4))="RECL" then 
25568          let LINE$=FNLAYOUTLINPUT$
25570          if UPRC$(LINE$)="#EOF#" then 
25572             print "Incomplete Layout."
25574             goto Errorreadfilelayout
25576          end if 
25578       end if 
25580 ! 
25582 Readnextsubprocline: ! Read The Next Line For Processing
25584       let LINE$=TRIM$(FNLAYOUTLINPUT$)
25586 ! 
25588       if UPRC$(LINE$)="#EOF#" then goto Donemakesubproc
25590       let FNPARSEDETAILLAYOUTLINE(LINE$,SUBNAME$,DESCRIPTION$,SPEC$,DATEFORMAT$)
25592 ! 
25594       if TRIM$(UPRC$(SPEC$))(1:2)<>"X " then 
25596          if TRIM$(SUBNAME$)<>"" then 
25598             if FNSTRINGSPEC(SUBNAME$,SPEC$) then 
25600                let STRINGSIZE+=1
25602                if SUBS then 
25604                   print #SUBS: "let "&TRIM$(PREFIX$)&TRIM$(SREP$(SUBNAME$,"$",""))&"="&STR$(STRINGSIZE)
25606                else 
25608                   let FNADDTOSUBSARRAY("let "&TRIM$(PREFIX$)&TRIM$(SREP$(SUBNAME$,"$",""))&"="&STR$(STRINGSIZE),MAT SUBS$,STAR$)
25610                end if 
25612             else 
25614                let NUMBERSIZE+=1
25616                if SUBS then 
25618                   print #SUBS: "let "&TRIM$(PREFIX$)&TRIM$(SUBNAME$)&"="&STR$(NUMBERSIZE)
25620                else 
25622                   let FNADDTOSUBSARRAY("let "&TRIM$(PREFIX$)&TRIM$(SUBNAME$)&"="&STR$(NUMBERSIZE),MAT SUBS$,STAR$)
25624                end if 
25626             end if 
25628          end if 
25630       end if 
25632       goto Readnextsubprocline
25634 Donemakesubproc: ! We Finished With All The File Layout
25636       if SUBS then close #SUBS: 
25638       if ANFWASGIVEN then 
25640          mat F$(STRINGSIZE)
25642          mat F(NUMBERSIZE)
25644       end if 
25646    fnend 
25648 ! 
25650 ! 
25652    dim ADDTOSUBSCOUNT
25654 Addtosubsarray: ! Adds subscripts to a processing effecient array
25656    def FNADDTOSUBSARRAY(STRING$*70,MAT SUBS$,STAR$;___,INDEX)
25658 ! 
25660       let ADDTOSUBSCOUNT+=1
25662       let INDEX=UDIM(MAT SUBS$)
25664 ! 
25666       if INDEX=0 OR ADDTOSUBSCOUNT>31 OR (~FN418 AND LEN(SUBS$(INDEX))>127) then 
25668          gosub Addnewone
25670       else 
25672          let SUBS$(INDEX)=SUBS$(INDEX)&":"&STRING$ soflow Erroraddnewone
25674       end if 
25676    fnend 
25678 ! 
25680 Erroraddnewone: gosub Addnewone : continue 
25682 Addnewone: ! Add a new Sub line
25684    let ADDTOSUBSCOUNT=1
25686    let INDEX+=1
25688    mat SUBS$(INDEX)
25690    let SUBS$(INDEX)=STAR$&STRING$
25692    return 
25694 ! 
25696    dim DUMMY2$(1)*255
25698    dim DUMMY3$(1)*255
25700    dim DUMMY4$(1)*255
25702    dim DUMMY5$(1)*255
25704    dim READFORM$*10000
25706    def library FNREADFORM$*10000(FILENAME$*255;___,DUMMY$*255,DUMMY,DUMMY2,DUMMY3)
25708       let FNREADFILELAYOUT(FILENAME$,DUMMY$,MAT DUMMY$,MAT DUMMY2$,MAT DUMMY3$,READFORM$,DUMMY,DUMMY2,0,DUMMY3,MAT DUMMY4$,MAT DUMMY,MAT DUMMY5$,1)
25710       let FNREADFORM$=READFORM$
25712    fnend 
25714    def library FNREADFORMANDSUBS(FILENAME$,MAT SUBS$,&READFORM$,&STRINGSIZE,&NUMBERSIZE)
25716       let FNREADFILELAYOUT(FILENAME$,DUMMY$,MAT DUMMY$,MAT DUMMY2$,MAT DUMMY3$,READFORM$,STRINGSIZE,NUMBERSIZE,0,DUMMY3,MAT DUMMY4$,MAT DUMMY,MAT SUBS$)
25718    fnend 
25720 ! 
25722    dim LAYOUTNAMES$(1)*255
25724    dim LAYOUTSTART(1)
25726 ! 
25728    dim LAYOUTDATA$(1)*511
25730    dim LAYOUTLINE$*511
25732 ! 
25734    dim CURRENTLAYOUT, LAYOUTPOSITION
25736 ! 
25738    def library FNCLEARLAYOUTCACHE=FNCLEARCACHE
25740    def FNCLEARCACHE
25742       mat LAYOUTNAMES$(0) : mat LAYOUTSTART(0) : mat LAYOUTDATA$(0)
25744    fnend 
25746 ! 
25748    def FNOPENLAYOUT(LAYOUTNAME$*255;___,LAYOUT)
25750       let LAYOUTNAME$=LWRC$(TRIM$(LAYOUTNAME$))
25752       let CURRENTLAYOUT=SRCH(MAT LAYOUTNAMES$,LAYOUTNAME$)
25754       if CURRENTLAYOUT>0 then 
25756 ! .     ! Found, read it from memory
25758          let FNOPENLAYOUT=1
25760       else 
25762          library : FNGETFILENUMBER
25764          let CURRENTLAYOUT=UDIM(MAT LAYOUTNAMES$)+1
25766          mat LAYOUTNAMES$(CURRENTLAYOUT)
25768          mat LAYOUTSTART(CURRENTLAYOUT)
25770 ! 
25772          let LAYOUTPOSITION=UDIM(MAT LAYOUTDATA$)+1
25774 ! 
25776          let LAYOUTSTART(CURRENTLAYOUT)=LAYOUTPOSITION
25778          let LAYOUTNAMES$(CURRENTLAYOUT)=LAYOUTNAME$
25780 ! 
25782 ! .     ! Read it from the disk and place it in Memory
25784          open #(LAYOUT:=FNGETFILENUMBER): "Name="&LAYOUTNAME$&",recl=511,shr", display, input error IGNORE
25786          if FILE(LAYOUT) then 
25788             if EXISTS(LAYOUTNAME$) then 
25790                print "There was an error "&STR$(ERR)&" opening your file layout."
25792             else 
25794                print "Your file layout "&LAYOUTNAME$&" could not be found."
25796             end if 
25798          else 
25800             do WHILE FILE(LAYOUT)=0
25802                linput #LAYOUT: LAYOUTLINE$ eof IGNORE
25804                if FILE(LAYOUT)=0 then 
25806                   if LEN(TRIM$(LAYOUTLINE$)) AND TRIM$(LAYOUTLINE$)(1:1)<>"!" then 
25808                      mat LAYOUTDATA$(LAYOUTPOSITION)
25810                      let LAYOUTDATA$(LAYOUTPOSITION)=LAYOUTLINE$
25812                      let LAYOUTPOSITION+=1
25814                      let FNOPENLAYOUT=1
25816                   end if 
25818                end if 
25820             loop 
25822             close #LAYOUT: 
25824          end if 
25826          mat LAYOUTDATA$(LAYOUTPOSITION)
25828          let LAYOUTDATA$(LAYOUTPOSITION)="#EOF#"
25830       end if 
25832       let LAYOUTPOSITION=LAYOUTSTART(CURRENTLAYOUT)
25834    fnend 
25836 ! 
25838    def FNLAYOUTLINPUT$*512
25840       if CURRENTLAYOUT AND LAYOUTPOSITION then 
25842          if LAYOUTPOSITION<=UDIM(MAT LAYOUTDATA$) then 
25844             let FNLAYOUTLINPUT$=SREP$(LAYOUTDATA$(LAYOUTPOSITION),CHR$(9),' ')
25846 ! 
25848             let LAYOUTPOSITION+=1
25850          end if 
25852       end if 
25854    fnend 
25856 ! 
25858    def FNREADCHUNK$*255(&LINE$;___,P,CHUNK$*255)
25860       let P=POS(LINE$,",")
25862       if P>0 then 
25864          let CHUNK$=TRIM$(LINE$(1:P-1))
25866          let LINE$(1:P)=""
25868       else 
25870          let CHUNK$=TRIM$(LINE$)
25872          let LINE$=""
25874       end if 
25876       let FNREADCHUNK$=CHUNK$
25878    fnend 
25880 ! 
25882    dim LINECHUNKS$(1)*255
25884    def FNPARSEDETAILLAYOUTLINE(LINE$*1000,&SUBNAME$,&DESCRIPTION$,&SPEC$,&DATEFORMAT$;&OPTIONAL4THCOL$,___,P,COLUMN4$*255)
25886       let SUBNAME$=FNREADCHUNK$(LINE$)
25888       let DESCRIPTION$=FNREADCHUNK$(LINE$)
25890       let SPEC$=FNREADCHUNK$(LINE$)
25892       let COLUMN4$=FNREADCHUNK$(LINE$)
25894       let OPTIONAL4THCOL$=COLUMN4$ soflow IGNORE
25896       let DATEFORMAT$=""              !Default to blank it out.
25898       if UPRC$(COLUMN4$(1:5))='DATE[' AND COLUMN4$(LEN(COLUMN4$):INF)=']' OR UPRC$(COLUMN4$(1:5))='DATE(' AND COLUMN4$(LEN(COLUMN4$):INF)=')' then 
25900          let DATEFORMAT$ = UPRC$(COLUMN4$(6:LEN(COLUMN4$)-1))
25902       end if 
25904    fnend 
25906 ! 
25908    dim FORMSTATEMENT$*10000
25910    dim DATEFORMAT$*50
25912 ! 
26000 ! #Autonumber# 26000,5
26005 Readfilelayout: ! Read Filelayout, Modify All Parameters, Apply Subscripts
26010    def FNREADFILELAYOUT(&FILENAME$,&RECL$,MAT KEYNAME$,MAT KPOS$,MAT KLEN$,&FORM$,&STRINGSIZE,&NUMBERSIZE,DONT_SORT_SUBS,&VER,MAT DESCRIPTION$,MAT FIELDWIDTHS;MAT SUBS$,DONTCFORM,MAT DATEFORMATS$,___,POSITION,PREFIX$,LASTSTRING,LASTNUMBER,SUBS,LINE$*512,CALCRECL,STAR$,FILELAYOUTEXTENSION$,DATEFORMAT$*50,BYPASSFIXRPT)
26015 ! 
26020       library : FNADDTOFORM
26025 ! 
26030       dim RFL_SDESCR$(1)*80,RFL_NDESCR$(1)*80,RFL_DESCR$(1)*80,RFL_SWIDTH(1),RFL_NWIDTH(1),RFL_WIDTH(1)
26035       dim STRINGFORM$*4000, NUMBERFORM$*4000
26040       dim KEYNAME$*255,DESCRIPTION$*255,TEMPFORM$*80,SUBNAME$*80,VER$*80
26045 ! 
26050       let STRINGFORM$=NUMBERFORM$=""
26055       let KEYNAME$=DESCRIPTION$=TEMPFORM$=SUBNAME$=VER$=""
26060       mat KEYNAME$(0) : mat KPOS$(0) : mat KLEN$(0) : mat RFL_SDESCR$(0) : mat RFL_NDESCR$(0) : mat RFL_DESCR$(0) : mat RFL_SWIDTH(0) : mat RFL_NWIDTH(0) : mat RFL_WIDTH(0) : mat RFL_SDATEFORMATS$(0) : mat RFL_NDATEFORMATS$(0) : mat RFL_DATEFORMATS$(0)
26065       let STRINGSIZE=0 : let NUMBERSIZE=0 : let FORM$=""
26070 ! 
26075       let STAR$=FNNEEDSTAR$
26080       let LAYOUTPATH$=FNSETTINGS$("layoutpath")
26085       let FILELAYOUTEXTENSION$=FNSETTINGS$("layoutextension")
26090       let BYPASSFIXRPT=FNSETTINGS("bypassfixrpt")
26095 ! 
26100       if ~FNOPENLAYOUT(LAYOUTPATH$&FILENAME$&FILELAYOUTEXTENSION$) then goto Errorreadfilelayout
26105 ! 
26110       if FNSMATRIXPRESENT(MAT SUBS$) then 
26115          mat SUBS$(0)
26120       else 
26125          open #(SUBS:=FNGETFILENUMBER): "Name=subs.$$$, replace", display, output 
26130       end if 
26135 ! 
26140       let LINE$=FNLAYOUTLINPUT$
26145       if UPRC$(LINE$)<>"#EOF#" then 
26150          let FNREADHEADING(LINE$,FILENAME$,PREFIX$,VER$)
26155          let VER=VAL(VER$) error Errorreadfilelayout
26160          let PREFIX$=TRIM$(PREFIX$) : let FILENAME$=TRIM$(FILENAME$)
26165       else 
26170          print "Incomplete Layout."
26175          goto Errorreadfilelayout
26180       end if 
26185 ! 
26190       let LINE$=FNLAYOUTLINPUT$
26195       if UPRC$(LINE$)<>"#EOF#" then 
26200          let FNREADKEYS(LINE$,KEYNAME$,DESCRIPTION$)
26205       else 
26210          print "Incomplete Layout."
26215          goto Errorreadfilelayout
26220       end if 
26225 ! 
26230       do WHILE UPRC$(KEYNAME$(1:4))<>"RECL" AND KEYNAME$(1:4)<>"===="
26235          mat KEYNAME$(UDIM(KEYNAME$)+1) !:
               mat KPOS$(UDIM(KEYNAME$)) !:
               mat KLEN$(UDIM(KEYNAME$))
26240          let KEYNAME$(UDIM(KEYNAME$))=TRIM$(KEYNAME$) !:
               let KPOS$(UDIM(KPOS$))=TRIM$(DESCRIPTION$) !:
               let KLEN$(UDIM(KLEN$))=TRIM$(DESCRIPTION$)
26245 ! 
26250          let LINE$=FNLAYOUTLINPUT$
26255          if UPRC$(LINE$)<>"#EOF#" then 
26260             let FNREADKEYS(LINE$,KEYNAME$,DESCRIPTION$)
26265          else 
26270             print "Incomplete Layout."
26275             goto Errorreadfilelayout
26280          end if 
26285       loop 
26290 ! 
26295       if KEYNAME$(1:4)="====" then 
26300          let CALCRECL=1
26305       else 
26310          let RECL$=TRIM$(KEYNAME$)
26315          let LINE$=FNLAYOUTLINPUT$
26320          if UPRC$(LINE$)="#EOF#" then 
26325             print "Incomplete Layout."
26330             goto Errorreadfilelayout
26335          end if 
26340       end if 
26345 ! 
26350       let POSITION=1
26355 Readnextline: ! Read The Next Line For Processing
26360       let LINE$=FNLAYOUTLINPUT$
26365       if UPRC$(LINE$)="#EOF#" then goto Donereadlayout
26370 ! 
26375       let FNPARSEDETAILLAYOUTLINE(LINE$,SUBNAME$,DESCRIPTION$,TEMPFORM$,DATEFORMAT$)
26380 ! 
26385       let FNCHECKKEYS(MAT KPOS$,MAT KLEN$,TRIM$(SUBNAME$),POSITION,TRIM$(TEMPFORM$)) error Errorreadfilelayout
26390       if TRIM$(TEMPFORM$)<>"" then 
26395          if TRIM$(UPRC$(TEMPFORM$))(1:2)<>"X " then 
26400             mat RFL_DESCR$(UDIM(MAT RFL_DESCR$)+1)
26405             let RFL_DESCR$(UDIM(MAT RFL_DESCR$))=TRIM$(DESCRIPTION$)
26410             mat RFL_WIDTH(UDIM(MAT RFL_WIDTH)+1)
26415             let RFL_WIDTH(UDIM(MAT RFL_WIDTH))=FNDISPLAYLENGTHOF(TRIM$(TEMPFORM$))
26420             mat RFL_DATEFORMATS$(UDIM(RFL_DATEFORMATS$)+1)
26425             let RFL_DATEFORMATS$(UDIM(RFL_DATEFORMATS$))=DATEFORMAT$
26430             if FNSTRINGSPEC(SUBNAME$,TEMPFORM$) then 
26435                let STRINGSIZE+=1
26440                if SUBS then 
26445                   print #SUBS: TRIM$(PREFIX$)&TRIM$(SREP$(SUBNAME$,"$",""))&"="&STR$(STRINGSIZE)
26450                else 
26455                   let FNADDTOSUBSARRAY(TRIM$(PREFIX$)&TRIM$(SREP$(SUBNAME$,"$",""))&"="&STR$(STRINGSIZE),MAT SUBS$,STAR$)
26460                end if 
26465                if LASTSTRING<>POSITION AND POSITION<>1 then let STRINGFORM$=STRINGFORM$&"POS "&STR$(POSITION)&","
26470                let FNADDTOFORM(STRINGFORM$,TRIM$(TEMPFORM$))
26475                let LASTSTRING=POSITION+FNLENGTHOF(TRIM$(TEMPFORM$))
26480                mat RFL_SDESCR$(STRINGSIZE)
26485                let RFL_SDESCR$(STRINGSIZE)=TRIM$(DESCRIPTION$)
26490                mat RFL_SWIDTH(STRINGSIZE)
26495                let RFL_SWIDTH(STRINGSIZE)=FNDISPLAYLENGTHOF(TRIM$(TEMPFORM$))
26500                mat RFL_SDATEFORMATS$(STRINGSIZE)
26505                let RFL_SDATEFORMATS$(STRINGSIZE)=DATEFORMAT$
26510             else 
26515                let NUMBERSIZE+=1
26520                if SUBS then 
26525                   print #SUBS: TRIM$(PREFIX$)&TRIM$(SUBNAME$)&"="&STR$(NUMBERSIZE)
26530                else 
26535                   let FNADDTOSUBSARRAY(TRIM$(PREFIX$)&TRIM$(SUBNAME$)&"="&STR$(NUMBERSIZE),MAT SUBS$,STAR$)
26540                end if 
26545                if LASTNUMBER<>POSITION then let NUMBERFORM$=NUMBERFORM$&"POS "&STR$(POSITION)&","
26550                let FNADDTOFORM(NUMBERFORM$,TRIM$(TEMPFORM$))
26555                let LASTNUMBER=POSITION+FNLENGTHOF(TRIM$(TEMPFORM$))
26560                mat RFL_NDESCR$(NUMBERSIZE)
26565                let RFL_NDESCR$(NUMBERSIZE)=TRIM$(DESCRIPTION$)
26570                mat RFL_NWIDTH(NUMBERSIZE)
26575                let RFL_NWIDTH(NUMBERSIZE)=FNDISPLAYLENGTHOF(TRIM$(TEMPFORM$))
26580                mat RFL_NDATEFORMATS$(NUMBERSIZE)
26585                let RFL_NDATEFORMATS$(NUMBERSIZE)=DATEFORMAT$
26590             end if 
26595          end if 
26600          let FNADDTOFORM(FORM$,TRIM$(TEMPFORM$))
26605          let POSITION+=FNLENGTHOF(TRIM$(TEMPFORM$))
26610       end if 
26615       goto Readnextline
26620 Donereadlayout: ! We Finished With All The File Layout
26625       if CALCRECL then let RECL$="recl="&STR$(POSITION-1)
26630       let FNCHECKUPRC(MAT KPOS$,MAT KLEN$)
26635       if ~DONT_SORT_SUBS then let FORM$=STRINGFORM$&NUMBERFORM$
26640       if ~BYPASSFIXRPT then let FNFINDANDFIXRPT(FORM$)
26645       let FORM$="form "&FORM$(1:(LEN(FORM$)-1))
26650       if DONTCFORM then 
26655 ! .     ! At least strip out all extra spaces.
26660          do WHILE POS(FORM$,"  ")
26665             let FORM$=SREP$(FORM$,"  "," ")
26670          loop 
26675       else 
26680          let FORMSTATEMENT$=FORM$     !Save this for debugging
26685          let FORM$=CFORM$(FORM$) error IGNORE
26690       end if 
26695       if FNSMATRIXPRESENT(MAT DESCRIPTION$) then 
26700          if DONT_SORT_SUBS then ! Resize And Copy Unsorted
26705             mat DESCRIPTION$(UDIM(MAT RFL_DESCR$))=RFL_DESCR$
26710          else ! Resize And Sort And Copy Seperately
26715             mat DESCRIPTION$(STRINGSIZE+NUMBERSIZE)  !Resize
26720             if STRINGSIZE>0 then mat DESCRIPTION$(1:STRINGSIZE)=RFL_SDESCR$  !Copy Strings
26725             if NUMBERSIZE>0 then mat DESCRIPTION$(STRINGSIZE+1:STRINGSIZE+NUMBERSIZE)=RFL_NDESCR$  !Copy Numbers
26730          end if 
26735       end if 
26740 ! 
26745       if FNSMATRIXPRESENT(MAT DATEFORMATS$) then 
26750          if DONT_SORT_SUBS then ! Resize And Copy Unsorted
26755             mat DATEFORMATS$(UDIM(RFL_DATEFORMATS$))=RFL_DATEFORMATS$
26760          else ! Resize And Sort And Copy Seperately
26765             mat DATEFORMATS$(STRINGSIZE+NUMBERSIZE)  !Resize
26770             if STRINGSIZE>0 then mat DATEFORMATS$(1:STRINGSIZE)=RFL_SDATEFORMATS$
26775             if NUMBERSIZE>0 then mat DATEFORMATS$(STRINGSIZE+1:STRINGSIZE+NUMBERSIZE)=RFL_NDATEFORMATS$
26780          end if 
26785       end if 
26790 ! 
26795       if FNNMATRIXPRESENT(MAT FIELDWIDTHS) then 
26800          if DONT_SORT_SUBS then ! Resize And Copy Unsorted
26805             mat FIELDWIDTHS(UDIM(MAT RFL_WIDTH))=RFL_WIDTH
26810          else ! Resize And Sort And Copy Seperately
26815             mat FIELDWIDTHS(STRINGSIZE+NUMBERSIZE)  !Resize
26820             if STRINGSIZE>0 then mat FIELDWIDTHS(1:STRINGSIZE)=RFL_SWIDTH  !Copy Strings
26825             if NUMBERSIZE>0 then mat FIELDWIDTHS(STRINGSIZE+1:STRINGSIZE+NUMBERSIZE)=RFL_NWIDTH  !Copy Numbers
26830          end if 
26835       end if 
26840       if SUBS then close #SUBS: 
26845       let FNREADFILELAYOUT=1          !Success!
26850 Exitfnreadfilelayout: ! Exit fnReadFileLayout
26855    fnend 
26860 Errorreadfilelayout: ! Error Encountered Parsing File Layout
26865    if IGNOREERRORS then goto Exitfnreadfilelayout
26870    print "Error parsing file layout: "&STR$(ERR)&" on line: "&STR$(LINE)
26875    if LINE=27060 then print "Look for a missing comma in your detail lines."
26880    if LINE=25110 then print "Check for proper definition of your keyfiles, terminated by a 'recl=' line."
26885    if LINE=25525 then print "Subscript too long. Look for a missing comma in your detail lines."
26890    if LINE=56825 then print "Invalid Form statement: form "&FORM$(1:(LEN(FORM$)-1))
26895    if LINE=25062 then print "Problem Parsing Version Parameter: "&VER$
26900    pause                              !Give User A Chance To Parse Variables
26905    execute "system"
26910 ! 
27000 ! #Autonumber# 27000,2
27002 Checkkeys: ! Routine To Check If A Given Subname Matches Part Of A Key Spec
27004    def FNCHECKKEYS(MAT KPOS$,MAT KLEN$,SUBNAME$*50,POSITION,SPEC$*30;___,INDEX)
27006       let SUBNAME$=SREP$(SUBNAME$,"$","")
27008       for INDEX=1 to UDIM(MAT KPOS$)
27010          let FNSUBSTITUTEKEYS(KPOS$(INDEX),KLEN$(INDEX),SUBNAME$,POSITION,FNLENGTHOF(SPEC$))
27012       next INDEX
27014    fnend 
27016 ! 
27018    dim TMP_KPOS$(1)*80, TMP_KLEN$(1)*80
27020    def FNSUBSTITUTEKEYS(&KPOS$,&KLEN$,SUBNAME$*50,POSITION,LENGTH;___,INDEX)
27022       let STR2MAT(KPOS$,MAT TMP_KPOS$,"/")
27024       let STR2MAT(KLEN$,MAT TMP_KLEN$,"/")
27026       for INDEX=1 to UDIM(MAT TMP_KPOS$)
27028          let FNSUBSTITUTEKEY(TMP_KPOS$(INDEX),TMP_KLEN$(INDEX),SUBNAME$,POSITION,LENGTH)
27030       next INDEX
27032       let MAT2STR(MAT TMP_KPOS$,KPOS$,"/")
27034       let MAT2STR(MAT TMP_KLEN$,KLEN$,"/")
27036    fnend 
27038 ! 
27040    def FNSUBSTITUTEKEY(&KPOS$,&KLEN$,SUBNAME$*50,POSITION,LENGTH)
27042       let FNREADPARTIALSYNTAX(KPOS$,POSITION,SUBNAME$,"pos")
27044       let KPOS$=FNSUBSTITUTE$(KPOS$,SUBNAME$,STR$(POSITION))
27046       let FNREADPARTIALSYNTAX(KLEN$,LENGTH,SUBNAME$,"len")
27048       let KLEN$=FNSUBSTITUTE$(KLEN$,SUBNAME$,STR$(LENGTH))
27050    fnend 
27052 ! 
27054    def FNFINDSUBNAME$*80(KEYSTRING$*255;___,P,M)
27056       let P=POS(KEYSTRING$,"(")
27058       let M=POS(KEYSTRING$,"-")
27060       if P>0 then let P-=1 else let P=LEN(KEYSTRING$)
27062       if M>0 then 
27064          let M-=1
27066          let P=MIN(M,P)
27068       end if 
27070       let FNFINDSUBNAME$=KEYSTRING$(1:P)
27072    fnend 
27074 ! 
27076 ! .! This function parses the Partial Index syntax. Example:
27078 ! .!  data\customer.ky2, StartDate(5:8)/StartDate(1:4)/Status
27080    dim PARENS$(1)
27082    def FNREADPARTIALSYNTAX(&KEYSTRING$,&POSITION,SUBNAME$*50,SWITCH$;___,PARENS$,ADJUSTMENT,PARENSTART,PARENEND)
27084 ! .  ! If the sub matches, then we need to check if there's any "()" stuff
27086 ! .  !  if there is, then adjust accordingly
27088       if (PARENSTART:=POS(KEYSTRING$,"(")) then ! if we have a "("
27090          if UPRC$(FNFINDSUBNAME$(KEYSTRING$))=UPRC$(SUBNAME$) then ! If it matches the sub
27092 ! 
27094             let PARENEND=POS(KEYSTRING$,")")
27096             let PARENS$=KEYSTRING$(PARENSTART+1:PARENEND-1)
27098 ! 
27100 ! .        ! Pull it out of KeyString$
27102             let KEYSTRING$(PARENSTART:PARENEND)=""
27104 ! 
27106 ! .        ! Parse the amounts out of Parens$
27108             let STR2MAT(PARENS$,MAT PARENS$,":")
27110 ! 
27112             if UDIM(MAT PARENS$)>1 then 
27114                if LWRC$(SWITCH$(1:1)) = "p" then ! #Select# lwrc$(Switch$(1:1)) #Case# "p"
27116 ! .              ! For position we want:
27118                   let POSITION+=VAL(PARENS$(1))-1
27120                else if LWRC$(SWITCH$(1:1)) = "l" then ! #Case# "l"
27122                   let POSITION=1+VAL(PARENS$(2))-VAL(PARENS$(1))
27124                end if                 !#End Select#
27126             end if 
27128          end if 
27130       end if 
27132    fnend 
27134 ! 
27136    def FNSUBSTITUTE$*255(KEYSTRING$*255,SUBNAME$*50,VALUE$;___,P)
27138       if (P:=POS(KEYSTRING$,"-"))>0 then let P-=1 else let P=LEN(KEYSTRING$)
27140       if UPRC$(KEYSTRING$(1:P))=UPRC$(SUBNAME$) then 
27142          let KEYSTRING$(1:P)=VALUE$
27144       end if 
27146       let FNSUBSTITUTE$=KEYSTRING$
27148    fnend 
27150 ! 
27152    def FNCHECKUPRC(MAT KPOS$,MAT KLEN$;___,INDEX,SEG,DASH)
27154 ! .  ! Move each segment's "-xx" modifier (U, YB, Y ...) to follow its length: Kln= 1/1BY/1/20
27156       for INDEX=1 to UDIM(MAT KPOS$)
27158          let STR2MAT(KPOS$(INDEX),MAT TMP_KPOS$,"/")
27160          let STR2MAT(KLEN$(INDEX),MAT TMP_KLEN$,"/")
27162          for SEG=1 to UDIM(MAT TMP_KPOS$)
27164             if (DASH:=POS(TMP_KPOS$(SEG),"-"))>0 then let TMP_KPOS$(SEG)=TMP_KPOS$(SEG)(1:DASH-1)
27166             if (DASH:=POS(TMP_KLEN$(SEG),"-"))>0 then let TMP_KLEN$(SEG)=TMP_KLEN$(SEG)(1:DASH-1)&UPRC$(TMP_KLEN$(SEG)(DASH+1:LEN(TMP_KLEN$(SEG))))
27168          next SEG
27170          let MAT2STR(MAT TMP_KPOS$,KPOS$(INDEX),"/")
27172          let MAT2STR(MAT TMP_KLEN$,KLEN$(INDEX),"/")
27174       next INDEX
27176    fnend 
27178 ! 
27180    def FNREADHEADING(LINE$*512,&FILENAME$,&PREFIX$,&VER$)
27182       let FNTAKETHING$(LINE$,FILENAME$)
27184       let FNTAKETHING$(LINE$,PREFIX$)
27186       let FNTAKETHING$(LINE$,VER$)
27188    fnend 
27190 ! 
27192    def FNREADKEYS(LINE$*512,&KEYNAME$,&DESCRIPTION$)
27194       let FNTAKETHING$(LINE$,KEYNAME$)
27196       let FNTAKETHING$(LINE$,DESCRIPTION$)
27198    fnend 
27200 ! 
27202    def FNTAKETHING$(&LINE$,&THING$)
27204       if POS(LINE$,",") then 
27206          let THING$=TRIM$(SREP$(LINE$(1:POS(LINE$,",")-1),CHR$(9)," "))
27208          let LINE$=LINE$(POS(LINE$,",")+1:LEN(LINE$))
27210       else 
27212          let THING$=TRIM$(SREP$(LINE$,CHR$(9)," "))
27214          let LINE$=""
27216       end if 
27218    fnend 
27220 ! 
27222 Lengthof: ! ***** Returns The Length Of A Given Spec
27224    def library FNLENGTH(SPEC$)
27226       let FNLENGTH=FNLENGTHOF(SPEC$)
27228    fnend 
27230    def FNLENGTHOF(SPEC$*40;___,_SPECLEN,LENOF_W$*40,LENOF_DOTPOS)
27232       let SPEC$=SPEC$&" "             !This Will Make Sure We At Least Have 1 Space
27234       if UPRC$(SPEC$(1:3))="PIC" then 
27236          let _SPECLEN=LEN(TRIM$(SPEC$))-5  !Pic(##) Returns 2
27238       else if UPRC$(SPEC$(1:3))="FMT" then 
27240          let _SPECLEN=LEN(TRIM$(SPEC$))-5  !Pic(##) Returns 2
27242       else if UPRC$(SPEC$(1:5))="DATE(" then 
27244          let _SPECLEN=LEN(TRIM$(SPEC$))-6  !DATE(mm/dd/ccyy) Returns 10
27246       else if UPRC$(SPEC$(1:2))="S " then 
27248          let _SPECLEN=4
27250       else if UPRC$(SPEC$(1:2))="D " then 
27252          let _SPECLEN=8
27254       else if UPRC$(SPEC$(1:2))="L " then 
27256          let _SPECLEN=9
27258       else 
27260          let LENOF_W$=SPEC$(POS(SPEC$," "):LEN(SPEC$)) : let LENOF_DOTPOS=POS(LENOF_W$,".") : if LENOF_DOTPOS then let LENOF_W$=LENOF_W$(1:LENOF_DOTPOS-1)  !Strip decimal count/variable name -- VAL() errors (and can crash) on a non-numeric decimal suffix such as a variable name (e.g. BH 4.PRICE_)
27262          let _SPECLEN=INT(VAL(LENOF_W$)) error Errorreadfilelayout
27264       end if 
27266       let FNLENGTHOF=_SPECLEN
27268    fnend 
27270 ! 
27600 ! #Autonumber# 27600,10
27610 Displaylengthof: ! ***** Returns The Display Length Of A Given Spec
27620    def library FNDISPLAYLENGTH(SPEC$)
27630       let FNDISPLAYLENGTH=FNDISPLAYLENGTHOF(SPEC$)
27640    fnend 
27650    def FNDISPLAYLENGTHOF(SPEC$;_SPECLEN)
27660       let SPEC$=UPRC$(SPEC$)
27670       let _SPECLEN=FNLENGTHOF(SPEC$)
27680       let SPEC$=SPEC$&" "
27690       if POS("S PDL D DLDHDTBLBHB N ZDG ",SPEC$(1:2)) then ! If Numeric Spec
27700          if SPEC$(1:2)="PD" then ! Pd Is Different
27710             let _SPECLEN=(2*_SPECLEN)-1+2
27720          else if SPEC$(1:2)="N " OR SPEC$(1:2)="ZD" OR SPEC$(1:2)="G " then 
27730             if POS(SPEC$,".") then let _SPECLEN+=1  !Add 1 for the potential "."
27740             if SPEC$(1:2)="ZD" then let _SPECLEN+=1  !Add one of the potential "-"
27750          else if SPEC$(1:2)="L " then ! L keeps max precision 15 decimals plus . and -
27760             let _SPECLEN=17
27770          else ! All The Others Are About The Same
27780             let _SPECLEN=LEN(STR$(256**_SPECLEN))+2
27790          end if 
27800       end if 
27810       let FNDISPLAYLENGTHOF=_SPECLEN
27820    fnend 
27830 ! 
28000 ! #Autonumber# 28000,10
28010 Smatrixpresent: ! ***** Returns True If Optional String Array Is Given
28020    def FNSMATRIXPRESENT(;MAT X$)
28030       if ENV$("GUIMODE")="" then ! Non Gui Versions Of Br
28040          let FNSMATRIXPRESENT=UDIM(X$)  !Don't support regular test
28050       else 
28060 ! 
28070          on error goto Smatrixnotpresent
28080          let FNSMATRIXPRESENT=1       !Assume True
28090          mat X$(UDIM(X$))             !Redimension Array To Test If Its Real
28100          goto Endsmatrixpresent
28110 ! 
28120 Smatrixnotpresent: ! Error Means Optional Matrix Not Given
28130          let FNSMATRIXPRESENT=0       !It Wasn't there
28140 ! 
28150 Endsmatrixpresent: ! We Are Finished
28160          if G_UPDATING then 
28170             on error goto Rollbackinfull
28180          else 
28190             let FNRESETERRORHANDLING  !Turn Off Error Checking
28200          end if 
28210       end if 
28220    fnend 
28230 ! 
28500 ! #Autonumber# 28500,10
28510 Nmatrixpresent: ! ***** Returns True If Optional Numeric Array Is Given
28520    def FNNMATRIXPRESENT(;MAT X)
28530       if ENV$("GUIMODE")="" then ! Non Gui Versions Of Br
28540          let FNNMATRIXPRESENT=UDIM(X)  !Don't support regular test
28550       else 
28560          on error goto Nmatrixnotpresent
28570          let FNNMATRIXPRESENT=1       !Assume True
28580          mat X(UDIM(X))               !Redimension Array To Test If Its Real
28590          goto Endnmatrixpresent
28600 Nmatrixnotpresent: ! Error Means Optional Matrix Not Given
28610          let FNNMATRIXPRESENT=0       !It Wasn't there
28620 Endnmatrixpresent: ! We Are Finished
28630          if G_UPDATING then !:
                  on error goto Rollbackinfull !:
               else !:
                  let FNRESETERRORHANDLING  !Turn Off Error Checking
28640       end if 
28650    fnend 
28660 ! 
29000 ! #Autonumber# 29000,10
29010 Addtoform: ! ***** This Function Adds Spec$ To Form$ Checking For Repetition. Thanks To Mikhail Zheleznov For The Formula.
29020    def library FNADDTOFORM(&FORM$,SPEC$*40;_LASTSPEC$*40,_REPETITION,_LASTCHUNK$*40)
29030       let _LASTCHUNK$=FNLASTCHUNK$(FORM$)
29040       let _LASTSPEC$=FNEXTRACTSPEC$(_LASTCHUNK$)
29050       let _REPETITION=FNEXTRACTREPETITION(_LASTCHUNK$)
29060       if TRIM$(UPRC$(SPEC$))=TRIM$(UPRC$(_LASTSPEC$)) then 
29070          let FORM$=FORM$(1:LEN(FORM$)-1-LEN(_LASTCHUNK$))
29080          let FORM$=FORM$ & FNBUILDCHUNK$(_REPETITION+1,_LASTSPEC$) & ","
29090       else 
29100          let FORM$=FORM$&SPEC$&","
29110       end if 
29120    fnend 
29130 ! 
29500 ! #Autonumber# 29500,10
29510 Buildchunk: ! ***** Builds A Chunk Of A Form Statment
29520    def FNBUILDCHUNK$*40(REPETITION,SPEC$)
29530       if REPETITION > 1 then 
29540          let FNBUILDCHUNK$=STR$(REPETITION)&"*"&SPEC$
29550       else 
29560          let FNBUILDCHUNK$=SPEC$
29570       end if 
29580    fnend 
29590 ! 
29600 ! #Autonumber# 29600,10
29610 Extractrepetition: ! ***** Parses A Spec Statement To Get The Rep Count
29620    def FNEXTRACTREPETITION(SPEC$*40)
29630       if POS(SPEC$,"*") then 
29640          let FNEXTRACTREPETITION=VAL(SPEC$(1:POS(SPEC$,"*")-1))
29650       else 
29660          let FNEXTRACTREPETITION=1
29670       end if 
29680    fnend 
29690 ! 
29700 ! #Autonumber# 29700,10
29710 Extractspec: ! ***** Parses A Spec Statement To Get The Raw Spec
29720    def FNEXTRACTSPEC$*40(SPEC$*40)
29730       if POS(SPEC$,"*") then 
29740          let FNEXTRACTSPEC$=SPEC$(POS(SPEC$,"*")+1:LEN(SPEC$))
29750       else 
29760          let FNEXTRACTSPEC$=SPEC$
29770       end if 
29780    fnend 
29790 ! 
29800 ! #Autonumber# 29800,10
29810 Lastchunk: ! ***** Extracts The Final Chunk From A Form Statement
29820    def FNLASTCHUNK$*40(&FORM$)        !Pass By Ref To Save On Workstack
29830       let FNLASTCHUNK$=FORM$(POS(FORM$,",",-2)+1:LEN(FORM$)-1)
29840    fnend 
29850 ! 
29860 Findandfixrpt: ! Searches Your Form Statement For All Subsets Of It That May Be Shortened
29870    def FNFINDANDFIXRPT(&FORM$;___,SIZE,POSITION)  !Pass And Return Byref To Save On Workstack
29880       dim CHUNK$(1)*127
29890       dim SEARCHCHUNK$*4096
29900       let FNPARSEFORM(MAT CHUNK$,FORM$)
29910       for SIZE=2 to INT(UDIM(MAT CHUNK$)/2)
29920          for POSITION = 1 to UDIM(MAT CHUNK$)-SIZE+1
29930             let FNSTRINGTOGETHER$(MAT CHUNK$(POSITION:POSITION+SIZE-1),SEARCHCHUNK$)
29940             let FNFIXRPT(FORM$,SEARCHCHUNK$)
29950          next POSITION
29960       next SIZE
29970    fnend 
29980 ! 
29990 Parseform: ! Parse Your Form Splitting Out Chunks Into An Array
30000    def FNPARSEFORM(MAT CHUNK$,&FORM$;___,POSITION,LASTPOSITION)
30010       mat CHUNK$(0)
30020       do WHILE (POSITION:=POS(FORM$,",",POSITION+1))
30030          mat CHUNK$(UDIM(MAT CHUNK$)+1)
30040          let CHUNK$(UDIM(MAT CHUNK$))=FORM$(LASTPOSITION+1:POSITION)
30050          let LASTPOSITION:=POSITION
30060       loop 
30070    fnend 
30080 ! 
30090 Stringtogether: ! Build String Out Of Array
30100    def FNSTRINGTOGETHER$(MAT CHUNK$,&STRING$)  !Pass Byref To Save Workstack
30110       let STRING$=""
30120       for INDEX=1 to UDIM(MAT CHUNK$)
30130          let STRING$(4096:0)=CHUNK$(INDEX)
30140       next INDEX
30150    fnend 
30160 ! 
30170 Fixrpt: ! Function To Fix Repeating Paterns In Form Statements, Thanks To Luis Gomez And Cls
30180    def FNFIXRPT(&TF$,&STRIP$;___,RPT_TIME)  !Pass Byref To Save Workstack
30190       let RPT_TIME=INT(LEN(TF$)/LEN(STRIP$))
30200       do WHILE POS(TF$,","&STRIP$)>0
30210          if RPT_TIME>1 then ! Dont put 1*(blahblahblah) because thats stupid
30220             let TF$=SREP$(TF$,","&RPT$(STRIP$,RPT_TIME),","&STR$(RPT_TIME)&"*("&STRIP$(1:LEN(STRIP$)-1)&"),")
30230          end if 
30240       loop WHILE (RPT_TIME-=1)>1
30250    fnend 
30260 ! 
34000 ! #Autonumber# 34000,10
34010 Updatefile: ! Library call to ensure a file is up to date
34020 ! 
34030    def library FNUPDATEFILE(FILELAYOUT$;___,FILENUMBER)
34040       library : FNOPENFILE
34050       dim UPDATEFORM$(1)*2000
34060       dim UPDATEDATA$(1)*255
34070       dim UPDATEDATA(1)
34080 ! 
34090       let FILENUMBER=FNOPEN(FILELAYOUT$,MAT UPDATEDATA$,MAT UPDATEDATA,MAT UPDATEFORM$,1)
34100       close #FILENUMBER: 
34110    fnend 
34120 ! 
34130 Readdescriptions: ! ***** This Function Returns A String Field From A File Given A Key
34140    def library FNREADDESCRIPTION$*255(FL,SUBSCRIPT,KEY$*255,MAT F$,MAT F,MAT FM$;DONTCHANGEKEY)
34150       let FNREADDESCRIPTION$=FNREADDES$(FL,SUBSCRIPT,KEY$,MAT F$,MAT F,MAT FM$,DONTCHANGEKEY)
34160    fnend 
34170    def FNREADDES$*255(FL,SUBSCRIPT,KEY$*255,MAT F$,MAT F,MAT FM$;DONTCHANGEKEY)
34180       mat F$=("") !:
            mat F=(0)
34190       if ~DONTCHANGEKEY then 
34200          let KEY$=RPAD$(TRIM$(KEY$)(1:KLN(FL)),KLN(FL))
34210       end if 
34220       read #FL, using FM$(FL), key=KEY$, release: MAT F$, MAT F nokey IGNORE
34230       let FNREADDES$=TRIM$(F$(SUBSCRIPT)(1:255))
34240    fnend 
34250 Readunopeneddescription: ! ***** This function returns a string field from a given key and file
34260    def library FNREADUNOPENEDDESCRIPTION$*255(LAYOUTNAME$,KEY$*255;FIELD,DONTCHANGEKEY,___,FILENUMBER)
34270       dim READUNOPENED$(1)*1000, READUNOPENED(1), READUNOPENEDFORM$(1)*1000
34280       library : FNOPENFILE
34290       if ~FIELD then let FIELD=2
34300       let FILENUMBER=FNOPEN(LAYOUTNAME$,MAT READUNOPENED$,MAT READUNOPENED,MAT READUNOPENEDFORM$,1)
34310       let FNREADUNOPENEDDESCRIPTION$=FNREADDES$(FILENUMBER,FIELD,KEY$,MAT READUNOPENED$,MAT READUNOPENED,MAT READUNOPENEDFORM$,DONTCHANGEKEY)
34320       close #FILENUMBER: 
34330    fnend 
34340 ! 
34350 Readnumber: ! ***** This Function Returns A Numeric Field From A File Given A Key
34360    def library FNREADNUMBER(FL,SUBSCRIPT,KEY$*255,MAT F$,MAT F,MAT FM$;DONTCHANGEKEY)
34370       let FNREADNUMBER=FNREADNUM(FL,SUBSCRIPT,KEY$,MAT F$,MAT F,MAT FM$,DONTCHANGEKEY)
34380    fnend 
34390 Readnum: ! ***** This Function Returns A Numeric Field From A File Given A Key
34400    def FNREADNUM(FL,SUBSCRIPT,KEY$*255,MAT F$,MAT F,MAT FM$;DONTCHANGEKEY)
34410       mat F$=("") !:
            mat F=(0)
34420       if ~DONTCHANGEKEY then 
34430          let KEY$=RPAD$(TRIM$(KEY$)(1:KLN(FL)),KLN(FL))
34440       end if 
34450       read #FL, using FM$(FL), key=KEY$ : MAT F$, MAT F nokey IGNORE
34460       let FNREADNUM=F(SUBSCRIPT)
34470    fnend 
34480 Readunopenednumber: ! ***** This Function Returns A Numeric Field From A File Given A Key
34490    def library FNREADUNOPENEDNUMBER(LAYOUTNAME$,KEY$*255;FIELD,DONTCHANGEKEY,___,FILENUMBER)
34500       library : FNOPENFILE
34510       if ~FIELD then let FIELD=1
34520       let FILENUMBER=FNOPEN(LAYOUTNAME$,MAT READUNOPENED$,MAT READUNOPENED,MAT READUNOPENEDFORM$,1)
34530       let FNREADUNOPENEDNUMBER=FNREADNUM(FILENUMBER,FIELD,KEY$,MAT READUNOPENED$,MAT READUNOPENED,MAT READUNOPENEDFORM$,DONTCHANGEKEY)
34540       close #FILENUMBER: 
34550    fnend 
34560 ! 
34570 Readrelative: ! These functions read a relative file by record number and return a single field
34580 ! .! ***** This Function Returns A String Field From A File Given A record
34590    def library FNREADRELATIVEDESCRIPTION$*255(FL,SUBSCRIPT,RECORDNUMBER,MAT F$,MAT F,MAT FM$)
34600       let FNREADRELATIVEDESCRIPTION$=FNREADRELATIVEDES$(FL,SUBSCRIPT,RECORDNUMBER,MAT F$,MAT F,MAT FM$)
34610    fnend 
34620    def FNREADRELATIVEDES$*255(FL,SUBSCRIPT,RECORDNUMBER,MAT F$,MAT F,MAT FM$)
34630       mat F$=("")
34640       mat F=(0)
34650       read #FL, using FM$(FL), rec=RECORDNUMBER, release: MAT F$, MAT F norec IGNORE
34660       let FNREADRELATIVEDES$=F$(SUBSCRIPT)
34670    fnend 
34680 ! .! ***** This function returns a string field from a record and file
34690    def library FNREADRELUNOPENEDDESCRIPTION$*255(LAYOUTNAME$,RECORDNUMBER;FIELD,___,FILENUMBER)
34700       library : FNOPENFILE
34710       if ~FIELD then let FIELD=2
34720       let FILENUMBER=FNOPEN(LAYOUTNAME$,MAT READUNOPENED$,MAT READUNOPENED,MAT READUNOPENEDFORM$,1)
34730       let FNREADRELUNOPENEDDESCRIPTION$=FNREADRELATIVEDES$(FILENUMBER,FIELD,RECORDNUMBER,MAT READUNOPENED$,MAT READUNOPENED,MAT READUNOPENEDFORM$)
34740       close #FILENUMBER: 
34750    fnend 
34760 ! 
34770 ! .! ***** This Function Returns A Numeric Field From A File Given A record
34780    def library FNREADRELATIVENUMBER(FL,SUBSCRIPT,RECORDNUMBER,MAT F$,MAT F,MAT FM$)
34790       let FNREADRELATIVENUMBER=FNREADRELATIVENUM(FL,SUBSCRIPT,RECORDNUMBER,MAT F$,MAT F,MAT FM$)
34800    fnend 
34810 ! 
34820    def FNREADRELATIVENUM(FL,SUBSCRIPT,RECORDNUMBER,MAT F$,MAT F,MAT FM$)
34830       mat F$=("") !:
            mat F=(0)
34840       read #FL, using FM$(FL), rec=RECORDNUMBER : MAT F$, MAT F norec IGNORE
34850       let FNREADRELATIVENUM=F(SUBSCRIPT)
34860    fnend 
34870 ! 
34880    def library FNREADRELUNOPENEDNUMBER(LAYOUTNAME$,RECORDNUMBER;FIELD,___,FILENUMBER)
34890       library : FNOPENFILE
34900       if ~FIELD then let FIELD=1
34910       let FILENUMBER=FNOPEN(LAYOUTNAME$,MAT READUNOPENED$,MAT READUNOPENED,MAT READUNOPENEDFORM$,1)
34920       let FNREADRELUNOPENEDNUMBER=FNREADRELATIVENUM(FILENUMBER,FIELD,RECORDNUMBER,MAT READUNOPENED$,MAT READUNOPENED,MAT READUNOPENEDFORM$)
34930       close #FILENUMBER: 
34940    fnend 
34950 ! 
34960 Readrecordwhere: ! Search a file for a record based on a filter
34970    def library FNREADRECORDWHERE$*255(LAYOUTNAME$,SEARCHSUB,SEARCHKEY$*255,RETURNSUB;___,FILENUMBER,RETURNVALUE$*255)
34980       library : FNOPENFILE
34990       let FILENUMBER=FNOPEN(LAYOUTNAME$,MAT READUNOPENED$,MAT READUNOPENED,MAT READUNOPENEDFORM$,1)
35000       if FILENUMBER then 
35010          do WHILE FILE(FILENUMBER)=0
35020             read #FILENUMBER, using READUNOPENEDFORM$(FILENUMBER), release: MAT READUNOPENED$,MAT READUNOPENED error IGNORE
35030             if FILE(FILENUMBER)=0 then 
35040                if LWRC$(TRIM$(READUNOPENED$(SEARCHSUB)))=LWRC$(TRIM$(SEARCHKEY$)) then 
35050                   let RETURNVALUE$=READUNOPENED$(RETURNSUB)(1:255)
35060                end if 
35070             end if 
35080          loop UNTIL LEN(TRIM$(RETURNVALUE$))
35090          close #FILENUMBER: 
35100       end if 
35110       let FNREADRECORDWHERE$=RETURNVALUE$
35120    fnend 
35130 ! 
35140 ! 
35150 Uniquekey: ! ***** This Function Searches A File To See If A Key Is Unique
35160    def library FNUNIQUEKEY(FL,KEY$*255)
35170       restore #FL, key=KEY$: nokey Uniquekeynotfound
35180       let FNUNIQUEKEY=0               !False - Key Is Found So Its Not Unique
35190       goto Enduniquekey
35200 Uniquekeynotfound: ! Key Not Found
35210       let FNUNIQUEKEY=1               !True - Key Not Found So It Must Be Unique
35220 Enduniquekey: fnend 
35230 ! 
36000 ! #Autonumber# 36000,10
36010 Readallkeys: ! ***** Reads A Given String Element (And Optionally A Second Element) From Every Record Of A File Into Given Arrays
36020    def library FNREADALLKEYS(FL,MAT F$,MAT F,MAT FM$,SUB1,MAT OUT1$;SUB2,MAT OUT2$,INDEX)
36030       mat OUT1$(0)
36040       if SUB2 then mat OUT2$(0)
36050       restore #FL: 
36060 Nextreadallkeys: ! Read Next Record
36070       read #FL, using FM$(FL),release: MAT F$, MAT F eof Donereadallkeys
36080       mat OUT1$(INDEX:=UDIM(MAT OUT1$)+1) !:
            let OUT1$(INDEX)=F$(SUB1)
36090       if SUB2 then !:
               mat OUT2$(INDEX) !:
               let OUT2$(INDEX)=F$(SUB2)
36100       goto Nextreadallkeys
36110 Donereadallkeys: ! We Finished Reading Here
36120    fnend 
36130 ! 
36300 ! #Autonumber# 36300,10
36310 Readmatchingkeys: ! ***** Reads A Given String Element (And Optionally A Second Element) From Every Record Of A File Into Given Arrays Only When Key Element Matches Specified Key. Key Must Match Specified Element Key.
36320    def library FNREADMATCHINGKEYS(FL,MAT F$,MAT F,MAT FM$,KEY$,KEYFLD,SUB1,MAT OUT1$;SUB2,MAT OUT2$,INDEX)
36330       mat OUT1$(0)
36340       if SUB2 then mat OUT2$(0)
36350       restore #FL, key=KEY$: nokey Donereadmatchingkeys
36360 Nextreadmatchingkeys: ! Read Next Record
36370       read #FL, using FM$(FL),release: MAT F$, MAT F eof IGNORE
36380       if (FILE(FL)=10) OR (F$(KEYFLD)<>KEY$) then goto Donereadmatchingkeys
36390       mat OUT1$(INDEX:=UDIM(MAT OUT1$)+1) !:
            let OUT1$(INDEX)=F$(SUB1)
36400       if SUB2 then !:
               mat OUT2$(INDEX) !:
               let OUT2$(INDEX)=F$(SUB2)
36410       goto Nextreadmatchingkeys
36420 Donereadmatchingkeys: ! We Finished Reading Here
36430    fnend 
36440 ! 
36600 ! #Autonumber# 36600,10
36610 Readallnewkeys: ! ***** This Version Of Our Popular Fileio Library Function Reads Only New Items Into The Array.
36620    def library FNREADALLNEWKEYS(FL,MAT F$,MAT F,MAT FM$,SUB1,MAT OUT1$;DONT_RESET,SUB2,MAT OUT2$,INDEX)
36630       if ~DONT_RESET then mat OUT1$(0)
36640       if (~DONT_RESET) AND (SUB2) then mat OUT2$(0)
36650       restore #FL: 
36660 ! 
36670 Nextreadallnewkeys: ! Read Next Record
36680       read #FL, using FM$(FL),release: MAT F$, MAT F eof Donereadallnewkeys
36690       if SRCH(MAT OUT1$,F$(SUB1))<1 then ! If Not Found Then
36700          mat OUT1$(INDEX:=UDIM(MAT OUT1$)+1) !:
               let OUT1$(INDEX)=F$(SUB1)
36710          if SUB2 then !:
                  mat OUT2$(INDEX) !:
                  let OUT2$(INDEX)=F$(SUB2)
36720       end if 
36730       goto Nextreadallnewkeys
36740 Donereadallnewkeys: ! We Finished Reading Here
36750    fnend 
36760 ! 
37000 ! #Autonumber# 37000,10
37010 Readfilterkeys: ! ***** Read Matching Keys, But It Also Supports Optional Filters And Up To Four Arrays May Be Populated At Once. If Readlarger=True Then Read All Larger Keys. Function By Mikhail Zheleznov
37020    def library FNREADFILTERKEYS(FL,MAT F$,MAT F,MAT FM$,KEY$,KEYFLD,SUB1,MAT OUT1$;FILTER$,FILTER_SUB,READLARGER,SUB2,MAT OUT2$, SUB3, MAT OUT3$, SUB4,MAT OUT4$, INDEX)
37030       mat OUT1$(0)
37040       if SUB2 then mat OUT2$(0)
37050       if SUB3 then mat OUT3$(0)
37060       if SUB4 then mat OUT4$(0)
37070       restore #FL, key=KEY$: nokey Donereadfilterkeys
37080 Nextreadfilterkeys: ! Read Next Record
37090       read #FL, using FM$(FL),release: MAT F$, MAT F eof IGNORE
37100       if (FILE(FL)=10) OR (~READLARGER AND (F$(KEYFLD)<>KEY$)) OR (READLARGER AND (F$(KEYFLD)<KEY$)) then goto Donereadfilterkeys
37110       if (FILTER$ ~= "" AND F$(FILTER_SUB) ~= FILTER$) then goto Nextreadfilterkeys
37120       mat OUT1$(INDEX:=UDIM(MAT OUT1$)+1) !:
            let OUT1$(INDEX)=F$(SUB1)
37130       if SUB2 then !:
               mat OUT2$(INDEX) !:
               let OUT2$(INDEX)=F$(SUB2)
37140       if SUB3 then !:
               mat OUT3$(INDEX) !:
               let OUT3$(INDEX)=F$(SUB3)
37150       if SUB4 then !:
               mat OUT4$(INDEX) !:
               let OUT4$(INDEX)=F$(SUB4)
37160       goto Nextreadfilterkeys
37170 Donereadfilterkeys: ! We Finished Reading Here
37180    fnend 
37190 ! 
38000 ! #Autonumber# 38000,10
38010 Makeuniquekeys: ! ***** Builds A Unique Key For Given File Of Kylen Length
38020    def library FNMAKEUNIQUEKEY$*255(FL;RANDOM,PREPEND$,___,INDEX,SIZE)
38030       let SIZE=KLN(FL)-LEN(PREPEND$)
38040       library : FNUNIQUEKEY
38050       dim MUKINDEXS(1)
38060       mat MUKINDEXS(SIZE)=(0)
38070       if RANDOM then 
38080          randomize 
38090          for INDEX=1 to UDIM(MUKINDEXS)
38100             let MUKINDEXS(INDEX)=INT(RND*35)
38110          next INDEX
38120       end if 
38130       do WHILE NOT FNUNIQUEKEY(FL,PREPEND$&FNBUILDKEYFORUNIQUE$(MAT MUKINDEXS))
38140          if RANDOM then 
38150             for INDEX=1 to UDIM(MUKINDEXS)
38160                let MUKINDEXS(INDEX)=INT(RND*35)
38170             next INDEX
38180          else 
38190             let MUKINDEXS(1)+=1
38200             for INDEX=1 to UDIM(MUKINDEXS)-1
38210                if MUKINDEXS(INDEX)>35 then let MUKINDEXS(INDEX)=0 : let MUKINDEXS(INDEX+1)+=1
38220             next INDEX
38230             if MUKINDEXS(UDIM(MUKINDEXS))>35 then let MSGBOX("The system cannot sustain more then "&STR$(35**UDIM(MUKINDEXS))&" of these. Please delete old ones and try again.")
38240          end if 
38250       loop UNTIL MUKINDEXS(UDIM(MUKINDEXS))>35
38260       let FNMAKEUNIQUEKEY$=PREPEND$&FNBUILDKEYFORUNIQUE$(MAT MUKINDEXS)
38270    fnend 
38280 ! 
38500 ! #Autonumber# 38500,10
38510 Buildkeyforuniques: ! Builds A Key Out Of The Byte Matrix Given
38520    def FNBUILDKEYFORUNIQUE$*255(MAT BKFUINDEXS;___,INDEX,KEY$*255)
38530       for INDEX=UDIM(BKFUINDEXS) to 1 step -1
38540          if BKFUINDEXS(INDEX)<10 then 
38550             let KEY$=KEY$&STR$(BKFUINDEXS(INDEX))
38560          else 
38570             let KEY$=KEY$&CHR$(BKFUINDEXS(INDEX)+55)
38580          end if 
38590       next INDEX
38600       let FNBUILDKEYFORUNIQUE$=KEY$
38610    fnend 
38620 ! 
39000 ! #Autonumber# 39000,10
39010 Searchclosely: ! ***** Searches Mat A$ Looking For A Partial Match To B$
39020    def FNSEARCHCLOSELY(MAT A$,B$;___,INDEX,FOUND)
39030       for INDEX=1 to UDIM(MAT A$)
39040          if POS(A$(INDEX),B$) then let FOUND=INDEX
39050       next INDEX
39060       let FNSEARCHCLOSELY=FOUND
39070    fnend 
39080 ! 
39090    dim __USR$*10000
39100 ! 
39500 ! #Autonumber# 39500,5
39505 Readlockedusers: ! ***** Read all users of the locked file into the given array
39510    def library FNREADLOCKEDUSERS(MAT USERS$;___,LOCKFILE)
39515       library : FNGETFILENUMBER
39520       execute "Status locks >ERTMP[SESSION]"
39525       open #(LOCKFILE:=FNGETFILENUMBER): "NAME=ERTMP[SESSION]",display,input 
39530       do WHILE __USR$(1:1)<>"-"
39535          linput #LOCKFILE: __USR$
39540       loop 
39545       mat USERS$(0)
39550       do UNTIL FILE(LOCKFILE)         !until EOF
39555          linput #LOCKFILE: __USR$ error IGNORE
39560          if FILE(LOCKFILE)=0 then 
39565             if 1>SRCH(MAT USERS$,LWRC$(TRIM$(__USR$(26:36)))) then 
39570                mat USERS$(UDIM(MAT USERS$)+1)
39575                let USERS$(UDIM(MAT USERS$))=TRIM$(LWRC$(__USR$(26:36)))
39580             end if 
39585          end if 
39590       loop 
39595       close #LOCKFILE: 
39600       execute "free ERTMP[SESSION]"
39605    fnend 
39610 ! 
40000 ! #Autonumber# 40000,10
40010 ! ****************
40020 ! **  Log File  **
40030 ! ****************
40040 ! 
40050    def library FNVIEWLOGFILE(;SHOWQUIT,SHOWCOLUMNS,SHOWEXPORT,___,LOGLAYOUT$*255,FILELAYOUTEXTENSION$,LAYOUTPATH$*255,INDEX)
40060 ! 
40070       if ENV$("guimode")="OFF" then execute "config gui on"
40080       let LOGLAYOUT$=FNSETTINGS$("loglayout")
40090       let LAYOUTPATH$=FNSETTINGS$("layoutpath")
40100       let FILELAYOUTEXTENSION$=FNSETTINGS$("layoutextension")
40110 ! 
40120       if LEN(TRIM$(LOGLAYOUT$)) AND EXISTS(LAYOUTPATH$&LOGLAYOUT$&FILELAYOUTEXTENSION$) then 
40130          if LWRC$(TRIM$(LOGLAYOUT$))="logfile" then 
40140 ! .        ! Build list of columns to show
40150             dim COLUMNS$(6),W(6),DESCR$(6),FORMS$(6)
40160             let COLUMNS$(1)="username" : let W(1)=10 : let DESCR$(1)="Username" : let FORMS$(1)=""
40170             let COLUMNS$(2)="program" : let W(2)=12 : let DESCR$(2)="Program" : let FORMS$(2)=""
40180             let COLUMNS$(3)="session" : let W(3)=4 : let DESCR$(3)="#" : let FORMS$(3)=""
40190             let COLUMNS$(4)="date" : let W(4)=8 : let DESCR$(4)="Date" : let FORMS$(4)="DATE(mm/dd/ccyy)"
40200             let COLUMNS$(5)="time" : let W(5)=7 : let DESCR$(5)="Time" : let FORMS$(5)="CC 8"
40210             let COLUMNS$(6)="message" : let W(6)=200 : let DESCR$(6)="Message" : let FORMS$(6)=""
40220 ! 
40230 ! .        ! Configure filters for fnShowData for the LogFile
40240             dim FILTERFIELDS$(2), FILTERFORM$(2), FILTERDEFAULTS$(2), FILTERCOMPARE$(2), FILTERCAPTION$(2), FILTERKEY(2)
40250             let FILTERFIELDS$(1)="date" : let FILTERFORM$(1)="DATE(mm/dd/ccyy)" : let FILTERDEFAULTS$(1)=STR$(DAYS(DATE$)) : let FILTERCOMPARE$(1)=">=" : let FILTERCAPTION$(1)="From Date" : let FILTERKEY(1)=1
40260             let FILTERFIELDS$(2)="date" : let FILTERFORM$(2)="DATE(mm/dd/ccyy)" : let FILTERDEFAULTS$(2)=STR$(DAYS(DATE$)) : let FILTERCOMPARE$(2)="<=" : let FILTERCAPTION$(2)="To Date" : let FILTERKEY(2)=-1
40270 ! 
40280 ! .        ! Configure the UI for the LogFile
40290             dim SHOWLOGUI$(1)
40300             mat SHOWLOGUI$(3+SHOWQUIT+SHOWCOLUMNS+SHOWEXPORT)
40310 ! 
40320             let INDEX=0
40330             if SHOWQUIT then let SHOWLOGUI$(INDEX+=1)="quitbutton"
40340             if SHOWEXPORT then let SHOWLOGUI$(INDEX+=1)="exportbutton"
40350             if SHOWCOLUMNS then let SHOWLOGUI$(INDEX+=1)="columnsbutton"
40360             let SHOWLOGUI$(INDEX+=1)="search"
40370             let SHOWLOGUI$(INDEX+=1)="border"
40380             let SHOWLOGUI$(INDEX+=1)="caption"
40390 ! 
40400 ! .        ! Show the log file using fnShowData
40410             library : FNSHOWDATA
40420             let FNSHOWDATA("logfile",0,0,0,20,74,1,"Review Log File","","","",PROGRAM$,DUMMY,MAT COLUMNS$,MAT SHOWLOGUI$,MAT DESCR$,MAT W,MAT FORMS$,"date",MAT FILTERFIELDS$,MAT FILTERFORM$,MAT FILTERCOMPARE$,MAT FILTERCAPTION$,MAT FILTERDEFAULTS$,MAT FILTERKEY)
40430          else 
40440             let FNSHOWDATA(LOGLAYOUT$,0,0,0,20,74,0,"Review Log File","","","",PROGRAM$)
40450          end if 
40460       else if EXISTS("fileio.log") then 
40470          execute "system -C -M start notepad fileio.log"
40480       end if 
40490    fnend 
40500 ! 
40510 Errlog: ! ***** Log An Error Entry
40520    def library FNERRLOG(STRING$*255;CALLINGPROGRAM$*255,___,FILEHANDLE)
40530       library : FNLOG
40540       let FNLOG("Error("&STR$(ERR)&":"&STR$(LINE)&") "&STRING$,CALLINGPROGRAM$)
40550    fnend 
40560 ! 
40570    dim LOGCHANGES$(1)*1024, LOGCHANGES(1)
40580    dim LOGSSUBS$(1)*255,LOGNSUBS$(1)*255
40590    def library FNSETLOGCHANGES(MAT F$,MAT F)
40600       mat LOGCHANGES$(UDIM(MAT F$))=F$
40610       mat LOGCHANGES(UDIM(MAT F))=F
40620    fnend 
40630    def library FNLOGCHANGES(MAT F$,MAT F;STRING$*1048,CALLINGPROGRAM$*255,LAYOUT$,___,INDEX,D$)
40640       library : FNLOG, FNREADSUBS
40650       if LEN(LAYOUT$) then 
40660          let FNREADSUBS(LAYOUT$,MAT LOGSSUBS$,MAT LOGNSUBS$,D$)
40670       else 
40680          mat LOGSSUBS$(UDIM(MAT F$)) : mat LOGNSUBS$(UDIM(MAT F))
40690          for INDEX=1 to UDIM(MAT F$)
40700             let LOGSSUBS$(INDEX)="String "&STR$(INDEX)
40710          next INDEX
40720          for INDEX=1 to UDIM(MAT F)
40730             let LOGNSUBS$(INDEX)="Number "&STR$(INDEX)
40740          next INDEX
40750       end if 
40760 ! 
40770       let STRING$=STRING$&" Changed: "
40780       for INDEX=1 to MIN(UDIM(MAT F$),UDIM(MAT LOGCHANGES$))
40790          if TRIM$(F$(INDEX))<>TRIM$(LOGCHANGES$(INDEX)) then 
40800             if LEN(STRING$&" "&LOGSSUBS$(INDEX)&":"""&TRIM$(LOGCHANGES$(INDEX))&""" to """&TRIM$(F$(INDEX))&""".")<512 then 
40810                let STRING$=STRING$&" "&LOGSSUBS$(INDEX)&":"""&TRIM$(LOGCHANGES$(INDEX))&""" to """&TRIM$(F$(INDEX))&"""."
40820             else if LEN(STRING$&" skipped -")<512 then 
40830                let STRING$=STRING$&" skipped -"
40840             end if 
40850          end if 
40860       next INDEX
40870       for INDEX=1 to MIN(UDIM(MAT F),UDIM(MAT LOGCHANGES))
40880          if F(INDEX)<>LOGCHANGES(INDEX) then 
40890             if LEN(STRING$&" "&LOGNSUBS$(INDEX)&":"""&STR$(LOGCHANGES(INDEX))&""" to """&STR$(F(INDEX))&""".") < 512 then 
40900                let STRING$=STRING$&" "&LOGNSUBS$(INDEX)&":"""&STR$(LOGCHANGES(INDEX))&""" to """&STR$(F(INDEX))&"""."
40910             end if 
40920          end if 
40930       next INDEX
40940 ! 
40950       let FNLOG(STRING$(1:512),CALLINGPROGRAM$)
40960    fnend 
40970 ! 
40980 Logarray: ! ***** Log an array and a message
40990    def library FNLOGARRAY(MAT F$,MAT F;STRING$*512,CALLINGPROGRAM$*255,___,LENGTH,INDEX,FILENUMBER)
41000       library : FNLOG
41010 ! 
41020       for INDEX=1 to UDIM(MAT F$)
41030          if LEN(STRING$)+LEN(F$(INDEX))+2>512 then 
41040             let FNLOG(STRING$,CALLINGPROGRAM$)
41050             let STRING$=""
41060          end if 
41070          let STRING$=STRING$&TRIM$(F$(INDEX)(1:500))&", "
41080       next INDEX
41090       for INDEX=1 to UDIM(MAT F)
41100          if LEN(STRING$)+LEN(STR$(F(INDEX)))+2>512 then 
41110             let FNLOG(STRING$,CALLINGPROGRAM$)
41120             let STRING$=""
41130          end if 
41140          let STRING$=STRING$&STR$(F(INDEX))(1:500)&", "
41150       next INDEX
41160       let FNLOG(STRING$,CALLINGPROGRAM$)
41170    fnend 
41180 ! 
41190    dim LOGDATA$(1)*512
41200    dim LOGDATA(1)
41210    dim LOGFORM$(1)*256
41220 ! 
41230 Log: ! ***** Log An Entry
41240    def library FNLOG(STRING$*512;CALLINGPROGRAM$*255,FORCETEXTFILE,___,FILEHANDLE,LOGLIBRARY$*255,LOGLAYOUT$,SUPPRESSLOGGINGERR)
41250       let LOGLIBRARY$=FNSETTINGS$("loglibrary")
41260       let LOGLAYOUT$=FNSETTINGS$("loglayout")
41270       let SUPPRESSLOGGINGERR=FNSETTINGS("suppressloggingerr")
41280 ! 
41290       if ~FORCETEXTFILE AND LEN(TRIM$(LOGLIBRARY$)) then 
41300          library LOGLIBRARY$ : FNFILEIOLOG
41310          if LEN(TRIM$(LOGLAYOUT$)) then 
41320             let FNLOG=FNFILEIOLOG(STRING$,LOGIN_NAME$,SESSION$,DAYS(DATE$("mm/dd/ccyy"),"mm/dd/ccyy"),TIME$("hh:mm:ss"),CALLINGPROGRAM$(LEN(CALLINGPROGRAM$)-39:LEN(CALLINGPROGRAM$)))
41330          else 
41340             if LEN(CALLINGPROGRAM$) then let CALLINGPROGRAM$=CALLINGPROGRAM$&" - "
41350             let FNLOG=FNFILEIOLOG(CALLINGPROGRAM$(LEN(CALLINGPROGRAM$)-39:LEN(CALLINGPROGRAM$))&STRING$)
41360          end if 
41370       else if ~FORCETEXTFILE AND LEN(TRIM$(LOGLAYOUT$)) then 
41380          library : FNOPENFILE,FNCLOSEFILE
41390          let FILEHANDLE=FNOPEN(LOGLAYOUT$,MAT LOGDATA$,MAT LOGDATA,MAT LOGFORM$,0,0,0,"",MAT DUMMY$,MAT DUMMY,0,1)
41400          if FILEHANDLE then 
41410             let LOGDATA$(LOG_PROGRAM)=CALLINGPROGRAM$(LEN(CALLINGPROGRAM$)-39:LEN(CALLINGPROGRAM$))
41420             let LOGDATA$(LOG_USERNAME)=LOGIN_NAME$
41430             let LOGDATA$(LOG_SESSION)=SESSION$
41440             let LOGDATA$(LOG_TIME)=TIME$("hh:mm:ss")
41450             let LOGDATA$(LOG_MESSAGE)=STRING$(1:255)
41460             let LOGDATA(LOG_DATE)=DAYS(DATE$("mm/dd/ccyy"),"mm/dd/ccyy")
41470 ! 
41480             write #FILEHANDLE, using LOGFORM$(FILEHANDLE) : MAT LOGDATA$,MAT LOGDATA error Errorusetextfile
41490             let FNCLOSEFILE(FILEHANDLE,LOGLAYOUT$,"",1)
41500          else 
41510             goto Errorusetextfile
41520          end if 
41530       else 
41540 Usetextfile: ! Use a text logfile.
41550          let LOGGINGRETRYCOUNT=0
41560          library : FNGETFILENUMBER
41570          open #(FILEHANDLE:=FNGETFILENUMBER) : "Name=FileIO.log, use, recl=658",display,output locked Retrylogging
41580          if FILE(FILEHANDLE)<>-1 then 
41590             print #FILEHANDLE: "User: "&LOGIN_NAME$&" - Session ID: "&SESSION$&" - Date: "&DATE$("mm/dd/ccyy")&" - "&TIME$("hh:mm:ss")&" - Program: "&CALLINGPROGRAM$&": "&STRING$
41600             close #FILEHANDLE: 
41610          end if 
41620       end if 
41630    fnend 
41640 ! 
41650 Errorusetextfile: ! Couldn't write to log file, msg user and use text
41660    if ~SUPPRESSLOGGINGERR then let MSGBOX("A file is locked on the server. Please restart the server if the problem continues.")
41670    goto Usetextfile
41680 ! 
41690    dim LOGGINGRETRYCOUNT
41700 ! 
41710 Retrylogging: ! 
41720    if LOGGINGRETRYCOUNT<20 then 
41730       let LOGGINGRETRYCOUNT+=1
41740       let SLEEP(.1)
41750       retry 
41760    else 
41770       let LOGGINGRETRYCOUNT=0
41780       continue 
41790    end if 
41800 ! 
41810 ! 
42000 ! #Autonumber# 42000,10
42010 Notinfile: ! ***** Search A Given Spot In A File For A Given String, Return True If Not Found
42020    def library FNNOTINFILE(STRING$*100,FILENAME$,SUB;PATH$,___,FILENUMBER)
42030       library : FNOPENFILE,FNREADALLKEYS
42040       dim F$(1)*255,F(1),FMMM$(1)*2000,FILELIST$(1)*255
42050       let FILENUMBER=FNOPEN(FILENAME$,MAT F$,MAT F,MAT FMMM$,1,0,0,PATH$)
42060       let FNREADALLKEYS(FILENUMBER,MAT F$,MAT F,MAT FMMM$,SUB,MAT FILELIST$)
42070       if FNSEARCHCLOSELY(MAT FILELIST$,STRING$)=0 then let FNNOTINFILE=1
42080       close #FILENUMBER: !:
         fnend 
42090 ! 
42100 Getfiledatetime: ! Performs a directory listing to get the date of a file
42110    def library FNGETFILEDATETIME$(FILENAME$*255)=FNGETFILEDT$(FILENAME$)
42120    def FNGETFILEDT$(FILENAME$*255;___,DIRFILE,DUMMY$*255,STAR$)
42130       let STAR$=FNNEEDSTAR$
42140       library : FNGETFILENUMBER
42150       execute STAR$&"dir "&FILENAME$&" >xxx[SESSION]"
42160       open #(DIRFILE:=FNGETFILENUMBER) : "Name=xxx[SESSION]", display,input 
42170       do 
42180          linput #DIRFILE: DUMMY$ eof IGNORE
42190          if FILE(DIRFILE)=0 then 
42200             if LWRC$(TRIM$(DUMMY$(46:99)))=LWRC$(TRIM$(FILENAME$(POS(FILENAME$,"\",-1)+1:LEN(FILENAME$)))) then 
42210                let FNGETFILEDT$=DUMMY$(27:42)
42220             end if 
42230          end if 
42240       loop WHILE FILE(DIRFILE)=0
42250       close #DIRFILE: 
42260       let ERRORRETRYCOUNT=0
42270       execute STAR$&"free xxx[SESSION] -n" error Retrycount
42280    fnend 
42290 ! 
43000 ! #Autonumber# 43000,10
43010 Readlayouts: ! ***** Reads Into A Given Array The List Of File Layouts
43020    def library FNREADLAYOUTS(MAT DIRLIST$;OVERRIDEEXTENSION$,___,DUMMY$*255,DIRFILE,FILELAYOUTEXTENSION$,LAYOUTPATH$*255,STAR$)
43030       let STAR$=FNNEEDSTAR$
43040       library : FNGETFILENUMBER
43050 ! 
43060       let LAYOUTPATH$=FNSETTINGS$("layoutpath")
43070       let FILELAYOUTEXTENSION$=FNSETTINGS$("layoutextension")
43080       if OVERRIDEEXTENSION$><"" then let FILELAYOUTEXTENSION$=OVERRIDEEXTENSION$
43090 ! 
43100       mat DIRLIST$(0)
43110       execute STAR$&"dir "&LAYOUTPATH$&"*"&FILELAYOUTEXTENSION$&" >xxx" error Donereadingfilenames
43120       open #(DIRFILE:=FNGETFILENUMBER) : "Name=xxx", display,input 
43130 Readfilename: ! Read The Next File Name
43140       linput #DIRFILE: DUMMY$ eof Donereadingfilenames
43150       if TRIM$(UPRC$(DUMMY$(11:13)))=TRIM$(UPRC$(FILELAYOUTEXTENSION$(2:4))) AND ~POS(DUMMY$,"<DIR>") then 
43160          mat DIRLIST$(UDIM(DIRLIST$)+1)
43170          let DUMMY$=TRIM$(DUMMY$(44:99))
43180          if FILELAYOUTEXTENSION$<>'' AND FILELAYOUTEXTENSION$><"." then 
43190             let DUMMY$=DUMMY$(1:POS(LWRC$(DUMMY$),LWRC$(FILELAYOUTEXTENSION$))-1)
43200          end if 
43210          let DIRLIST$(UDIM(DIRLIST$))=DUMMY$(1:30)
43220       end if 
43230       goto Readfilename
43240 Donereadingfilenames: ! Finished
43250       if DIRFILE AND FILE(DIRFILE)>-1 then close #DIRFILE: 
43260       execute STAR$&"free xxx"
43270    fnend 
43280 ! 
43290 ! 
43300    def library FNDIRVERSIONHISTORYFILES(LAYOUT$,MAT DIRLIST$;BYPASSEXTENSION$,___,DUMMY$*255,DIRFILE,LAYOUTPATH$*128,STAR$)
43310       let LAYOUTPATH$=FNSETTINGS$("layoutpath")
43320 ! 
43330       let STAR$=FNNEEDSTAR$
43340 ! 
43350       library : FNGETFILENUMBER
43360 ! 
43370       mat DIRLIST$(0)
43380       if EXISTS("tmpdir[session]") then execute STAR$&"free tmpdir[session]"
43390       execute STAR$&"dir "&LAYOUTPATH$&"version\"&LAYOUT$&"* >tmpdir[session]" error IGNORE
43400       if EXISTS("tmpdir[session]") then 
43410          open #(DIRFILE:=FNGETFILENUMBER) : "Name=tmpdir[session]", display,input 
43420 Readversionfilename: ! Read The Next File Name
43430          linput #DIRFILE: DUMMY$ eof Donereadversionfiles
43440          if FNTESTVERSIONHISTORYFILE(DUMMY$,BYPASSEXTENSION$) then 
43450             mat DIRLIST$(UDIM(DIRLIST$)+1)
43460             let DUMMY$=TRIM$(DUMMY$(44:99))
43470             let DIRLIST$(UDIM(DIRLIST$))=DUMMY$(1:30)
43480          end if 
43490          goto Readversionfilename
43500 Donereadversionfiles: ! Finished
43510          close #DIRFILE: 
43520 ! 
43530          execute STAR$&"free tmpdir[session]"
43540       end if 
43550    fnend 
43560 ! 
43570    def FNTESTVERSIONHISTORYFILE(LINE$*255;BYPASSEXTENSION$)
43580       if BYPASSEXTENSION$="" OR TRIM$(UPRC$(LINE$(11:13)))><TRIM$(UPRC$(BYPASSEXTENSION$(2:4))) then 
43590          if ~POS(LINE$,"<DIR>") AND LINE$(1:13)><"Directory of " AND ~POS(LINE$,"Kilobytes Used,") then 
43600             let FNTESTVERSIONHISTORYFILE=1
43610          end if 
43620       end if 
43630    fnend 
43640 ! 
43650 Doeslayoutexist: ! Return True If Layout Exists In The Layouts Folder
43660    def library FNDOESLAYOUTEXIST(LAYOUT$;___,LAYOUTPATH$*255,FILELAYOUTEXTENSION$)
43670       let LAYOUTPATH$=FNSETTINGS$("layoutpath")
43680       let FILELAYOUTEXTENSION$=FNSETTINGS$("layoutextension")
43690       let LAYOUT$=TRIM$(LAYOUT$)
43700 ! 
43710       if TRIM$(LAYOUT$)<>"" then 
43720          let FNDOESLAYOUTEXIST = EXISTS(LAYOUTPATH$&LAYOUT$&FILELAYOUTEXTENSION$)
43730       end if 
43740    fnend 
43750 ! 
43760 Layoutpath: ! This funtion reads the layout path
43770    def library FNREADLAYOUTPATH$*255=FNSETTINGS$("layoutpath")
43780    def library FNREADLAYOUTEXTENSION$=FNSETTINGS$("layoutextension")
43790 ! 
43800 Readtemplates: ! ***** Reads Into A Given Array The List Of File Layouts
43810    dim TEMPLATELIST$(1)
43820    dim TEMPLATEDESCRIPTION$(1)*255
43830    def FNREADTEMPLATES(MAT DIRLIST$,MAT TEMPLATEDESC$,MAT TEMPLATENUM;___,DUMMY$*255,DIRFILE,TEMPLATEPATH$*255,INDEX,SPOT,JNDEX,STAR$)
43840       let STAR$=FNNEEDSTAR$
43850       library : FNGETFILENUMBER
43860       let TEMPLATEPATH$=FNSETTINGS$("templatepath")
43870       mat TEMPLATELIST$(0)
43880       execute STAR$&"dir "&TEMPLATEPATH$&" >xxx" error IGNORE
43890       if EXISTS("xxx") then 
43900          open #(DIRFILE:=FNGETFILENUMBER) : "Name=xxx", display,input 
43910 Readtemplatename: ! Read The Next File Name
43920          linput #DIRFILE: DUMMY$ eof Donereadingtemplatenames
43930          if (TRIM$(LWRC$(DUMMY$(11:13)))="wb" OR TRIM$(LWRC$(DUMMY$(11:13)))="br") AND ~POS(DUMMY$,"<DIR>") then 
43940             mat TEMPLATELIST$(UDIM(TEMPLATELIST$)+1) !:
                  let TEMPLATELIST$(UDIM(TEMPLATELIST$))=TRIM$(DUMMY$(44:99))(1:30)
43950          end if 
43960          goto Readtemplatename
43970 Donereadingtemplatenames: ! Finished
43980          close #DIRFILE: 
43990          execute STAR$&"free xxx"
44000       end if 
44010 ! 
44020       mat DIRLIST$(0) : mat TEMPLATEDESC$(0) : mat TEMPLATENUM(0)
44030       for INDEX=1 to UDIM(MAT TEMPLATELIST$)
44040 ! .     ! attempt library linkage
44050 ! 
44060          library TEMPLATEPATH$&TEMPLATELIST$(INDEX) : FNTEMPLATELIST, FNRUNTEMPLATE error Skipthistemplate
44070          let FNTEMPLATELIST(MAT TEMPLATEDESCRIPTION$) error Skipthistemplate
44080 ! 
44090          let SPOT=UDIM(MAT DIRLIST$)
44100          mat DIRLIST$(UDIM(MAT TEMPLATEDESCRIPTION$)+SPOT)
44110          mat DIRLIST$(SPOT+1:SPOT+UDIM(MAT TEMPLATEDESCRIPTION$))=(TEMPLATEPATH$&TEMPLATELIST$(INDEX))
44120          mat TEMPLATEDESC$(UDIM(MAT TEMPLATEDESCRIPTION$)+SPOT)
44130          mat TEMPLATEDESC$(SPOT+1:SPOT+UDIM(MAT TEMPLATEDESCRIPTION$))=TEMPLATEDESCRIPTION$
44140          mat TEMPLATENUM(UDIM(MAT TEMPLATEDESCRIPTION$)+SPOT)
44150          for JNDEX=1 to UDIM(MAT TEMPLATEDESCRIPTION$)
44160             let TEMPLATENUM(SPOT+JNDEX)=JNDEX
44170          next JNDEX
44180 Skipthistemplate: ! Skip to here if a file isn't a template.
44190       next INDEX
44200    fnend 
44210 ! 
44220 ! .! Ignore layouts we're supposed to ignore.
44230    def FNIGNORELAYOUTS(MAT LVDIR_LISTING$;___,_IGNORELAYOUTS$*255,DC_INDEX,DC_JNDEX)
44240       let _IGNORELAYOUTS$=FNSETTINGS$("ignorelayouts")
44250       for DC_INDEX=1 to UDIM(MAT LVDIR_LISTING$)
44260          if ~POS(LWRC$(_IGNORELAYOUTS$),LWRC$(TRIM$(LVDIR_LISTING$(DC_INDEX)))) then 
44270             let DC_JNDEX+=1
44280             let LVDIR_LISTING$(DC_JNDEX)=LVDIR_LISTING$(DC_INDEX)
44290          end if 
44300       next DC_INDEX
44310       mat LVDIR_LISTING$(DC_JNDEX)
44320    fnend 
44330 ! 
50000 ! #Autonumber# 50000,10
50010 Renamelayouts: ! Rename Layouts
50020    let FNRENAMELAYOUTEXTENSION
50030    if FKEY=93 then execute "system"
50040    stop 
50050 ! 
50060    dim TMPDIRLIST$(1)*128
50070    def FNCHECKFORNEWEXTENSION(MAT LVDIR_LISTING$)
50080       if UDIM(MAT LVDIR_LISTING$)=0 AND LEN(TRIM$(FNSETTINGS$("layoutextension")))>0 then 
50090          let FNREADLAYOUTS(MAT TMPDIRLIST$,".")
50100          if UDIM(MAT TMPDIRLIST$) then 
50110             dim LONGMESSAGE$*10000
50120             let LONGMESSAGE$="I'm not seeing any layouts but I found some using your old layout extension. Would you like to "
50130             let LONGMESSAGE$(99999:0)="run the Rename Layout Extension Wizard to rename all your layout files to use the new "
50140             let LONGMESSAGE$(99999:0)="layout extension? (You can run the Rename Layout Extension Wizard at any time by loading "
50150             let LONGMESSAGE$(99999:0)="fileio and typing ""run 50000"", though you should only do that when you actually want to change the extension.)"
50160             if (2==MSGBOX(LONGMESSAGE$,"New Layout Extension Detected","yN","QST")) then 
50170                let COUNT=FNRENAMELAYOUTEXTENSION
50180                let FNREADLAYOUTS(MAT LVDIR_LISTING$)
50190                let MSGBOX("We renamed "&STR$(COUNT)&" layouts and layout history files. Please test every data file in your system and then archive your old file layouts so you don't accidentally change the wrong ones.","Upgrade Complete")
50200             end if 
50210          end if 
50220       end if 
50230    fnend 
50240 ! 
50250    def FNRENAMELAYOUTEXTENSION(;___,COUNT)
50260       library : FNGETFILENUMBER
50270       let TOEXT$=FNSETTINGS$("layoutextension")
50280       let FROMEXT$="."
50290       open #(WINDOW:=FNGETFILENUMBER): "srow=10,scol=30,rows=3,cols=25,border=s,caption=Change Extension",display,outin 
50300       print #WINDOW, fields "1,1,CR 10;2,1,CR 10" : "From Ext: ", "To Ext: "
50310       print #WINDOW, fields "3,1,CC 25" : "Press Enter to Continue"
50320       do 
50330          rinput #WINDOW, fields "1,12,V 10,/W:W;2,12,V 10,/W:W" : FROMEXT$,TOEXT$
50340       loop UNTIL FKEY=99 OR FKEY=93 OR FKEY=0
50350       close #WINDOW: 
50360       execute "con gui off"
50370       if FKEY=0 then let COUNT=FNRENAMELAYOUTS(FROMEXT$,TOEXT$)
50380       execute "con gui on"
50390       let FNRENAMELAYOUTEXTENSION=COUNT
50400    fnend 
50410 ! 
50420    dim LAYOUTRENAME$(1)*128
50430    dim VERSIONRENAME$(1)*128
50440    def FNRENAMELAYOUTS(FROMEXT$,TOEXT$;___,INDEX,JNDEX,LAYOUTPATH$*128,COUNT)
50450       let LAYOUTPATH$=FNSETTINGS$("layoutpath")
50460       library : FNREADLAYOUTS, FNDIRVERSIONHISTORYFILES
50470       let FNREADLAYOUTS(MAT LAYOUTRENAME$,FROMEXT$)
50480       for INDEX=1 to UDIM(MAT LAYOUTRENAME$)
50490          if ~EXISTS(LAYOUTPATH$&LAYOUTRENAME$(INDEX)&TOEXT$) then 
50500             execute "copy """&LAYOUTPATH$&LAYOUTRENAME$(INDEX)&FROMEXT$&""" """&LAYOUTPATH$&LAYOUTRENAME$(INDEX)&TOEXT$&""""
50510             let COUNT+=1
50520          else 
50530             print "Bypassing - Already Exists: "&LAYOUTPATH$&LAYOUTRENAME$(INDEX)&TOEXT$
50540          end if 
50550          let FNDIRVERSIONHISTORYFILES(LAYOUTRENAME$(INDEX),MAT VERSIONRENAME$,TOEXT$)
50560          for JNDEX=1 to UDIM(MAT VERSIONRENAME$)
50570             if ~EXISTS(LAYOUTPATH$&"version\"&VERSIONRENAME$(JNDEX)&TOEXT$) then 
50580                execute "copy """&LAYOUTPATH$&"version\"&VERSIONRENAME$(JNDEX)&FROMEXT$&""" """&LAYOUTPATH$&"version\"&VERSIONRENAME$(JNDEX)&TOEXT$&""""
50590                let COUNT+=1
50600             else 
50610                print "Bypassing - Already Exists: "&LAYOUTPATH$&"version\"&VERSIONRENAME$(JNDEX)&TOEXT$
50620             end if 
50630          next JNDEX
50640       next INDEX
50650       print "Copied "&STR$(COUNT)&" files."
50660       let FNRENAMELAYOUTS=COUNT
50670    fnend 
50680 ! 
50690 Messagebox: ! ***** Displays A Message Box In New Or Old Gui
50700    def FNMESSAGEBOX(MESSAGE$*60;TITLE$*20,_WINDOW,_CHOICE,_KP$)
50710       library : FNGETFILENUMBER
50720       if TRIM$(ENV$("guimode"))="" then ! Old Gui Version
50730          open #(_WINDOW:=FNGETFILENUMBER): "SROW=10,SCOL=10,EROW=14,ECOL=69,Border=S,Caption="&TITLE$,display,outin 
50740          print #_WINDOW: NEWPAGE
50750          print #_WINDOW, fields "2,1,CC 60" : MESSAGE$
50760          print #_WINDOW, fields "4,1,CR 29" : "Answer (Y/N):"
50770          do 
50780             rinput #_WINDOW, fields "4,31,C 1" : _KP$
50790          loop UNTIL (FKEY=0 AND (UPRC$(_KP$)="Y" OR UPRC$(_KP$)="N")) OR FKEY=99
50800          if FKEY=0 AND UPRC$(_KP$)="Y" then let FNMESSAGEBOX=1 else let FNMESSAGEBOX=0
50810          close #_WINDOW: 
50820       else ! New Gui Version
50830          let _CHOICE=MSGBOX(MESSAGE$,TITLE$,"okC")
50840          if _CHOICE=1 then let FNMESSAGEBOX=1 else let FNMESSAGEBOX=0
50850       end if 
50860    fnend 
50870 ! 
50880 Sameas: !   ***** Compares Two String Arrays Returning True If Same
50890    def FNSAMEAS(MAT A$,MAT B$;___,FAILED,INDEX)
50900       if UDIM(MAT A$)=UDIM(MAT B$) then 
50910          for INDEX=1 to UDIM(MAT A$)
50920             if TRIM$(A$(INDEX))<>TRIM$(B$(INDEX)) then let FAILED=1
50930          next INDEX
50940          let FNSAMEAS=(~(FAILED))
50950       end if 
50960    fnend 
50970 ! 
50980 Samea: !   ***** Compares  Two Number Arrays Returning True If Same
50990    def FNSAMEA(MAT A,MAT B;___,FAILED,INDEX)
51000       if UDIM(MAT A)=UDIM(MAT B) then 
51010          for INDEX=1 to UDIM(MAT A)
51020             if A(INDEX)<>B(INDEX) then let FAILED=1
51030          next INDEX
51040          let FNSAMEA=(~(FAILED))
51050       end if 
51060    fnend 
51070 ! 
51080 Key: ! ***** This Function Calculates The Key For A File
51090    def library FNKEY$*255(FILENUMBER, KEY$*255)
51100       let FNKEY$=RPAD$(KEY$,KLN(FILENUMBER))
51110    fnend 
51120 ! 
51130 Sortkeys: ! This function will sort the records given in the mat Keys$
51140 ! .! array into the order specified by a given key file.
51150 ! 
51160    dim SORTKEY$(1)*255
51170    dim SORTED(1)
51180 ! 
51190    def library FNSORTKEYS(MAT KEYS$,LAYOUT$,DATAFILE,MAT F$,MAT F,MAT FORM$;KEYNUM,___,INDEX)
51200       library : FNBUILDKEY$
51210       mat SORTKEY$(UDIM(MAT KEYS$))
51220       mat SORTED(UDIM(MAT KEYS$))
51230 ! 
51240       for INDEX=1 to UDIM(MAT KEYS$)
51250          read #DATAFILE, using FORM$(DATAFILE), key=KEYS$(INDEX), release: MAT F$, MAT F
51260          if FILE(DATAFILE)=0 then 
51270             let SORTKEY$(INDEX)=FNBUILDKEY$(LAYOUT$,MAT F$,MAT F,KEYNUM)
51280          end if 
51290       next INDEX
51300 ! 
51310       mat SORTED=AIDX(SORTKEY$)
51320       mat SORTKEY$=KEYS$
51330 ! 
51340       for INDEX=1 to UDIM(MAT KEYS$)
51350          let KEYS$=SORTKEY$(SORTED(INDEX))
51360       next INDEX
51370    fnend 
51380 ! 
51390    dim OPENSTATEMENTLIST$(1)*127
51400 ! 
51410 Searchlegacyreadstatements: ! This function searches all your programs to see which ones open this file, and lists any read and write statements from those programs.
51420    def library FNSEARCHLEGACYREADSTATEMENTS(LAYOUT$*64;OUTPUTFILE$*64,___,OUTPUTFILE,SEARCHFILENAME$)
51430       let MSGBOX("We're Sorry! This functionality has not been implemented yet.","Not Implemented")
51450 ! .  !
51460 !       if OutputFile$="" then let OutputFile$=layout$&"_reads.out"
51470 !       execute "free "&OutputFile$
51480 ! 
51490 !       ! First, get the file name from the layout !! $$$$$ Fix the following code later to parse it from the name inside the layout.
51500 !       let SearchFileName$=Layout$
51510 !       let OpenStatementList$="01000 OPEN #5: ""name="&SearchFileName$&",internal,input,relative"
51520 !       let fnSearchPrograms(mat OpenStatementList$)
51530 ! 
51540 !       ! First, search all programs, just wb and br files, for programs that open the given file.
51550 !       ! If any are found, then search for all open statements.
51560 !       !    For each open statement found, print it
51570 !       !    and also then print all read and write statements to that given file after that, into the layout$&".out" file.
51580 ! 
51590 ! 
51600 ! 
51620 ! 
51630 ! 
51640 ! 
51650 ! 
51660 ! 
51670 ! 
51680 ! 
51690    fnend 
51700 ! 
51710 ! 
51720 ! 
51730 ! 
51740 ! 
51750    dim STATFILE$(1)*255
51760    dim AUDITKEYS$(1)*255
51770    dim FILELIST$(1)*255
51780    dim STATHEADINGS$(1)
51790    dim STATWIDTH(1)
51800    dim STATFORM$(1)
51810 ! 
51820 Beginaudit: ! ***** This function will create an Audit Comparison folder for all your data files.
51830    def library FNBEGINAUDIT(;BACKUPFOLDER$*80,PATH$*255,MAT SELECTEDFILES$,___,INDEX,FILENAME$*255,JNDEX)
51840       if TRIM$(BACKUPFOLDER$)="" then let BACKUPFOLDER$=FNSETTINGS$("auditpath")
51850       library : FNCOPYDATAFILES
51860       let FNCOPYDATAFILES(BACKUPFOLDER$,PATH$,MAT SELECTEDFILES$)  !,2)
51870    fnend 
51880 ! 
51890    dim CALLAUDITFILELIST$(1)*255
51900    def FNCALLAUDIT(MAT SEL,MAT FILES$;PATH$*255,___,INDEX)
51910 ! 
51920 ! .  ! Convert mat Selection and mat Files$ into mat Selected Files
51930       mat CALLAUDITFILELIST$(UDIM(MAT SEL))
51940       for INDEX=1 to UDIM(MAT CALLAUDITFILELIST$)
51950          let CALLAUDITFILELIST$(INDEX)=FILES$(SEL(INDEX))
51960       next INDEX
51970 ! 
51980       let FNCOMPAREFILES(MAT CALLAUDITFILELIST$,PATH$)
51990       let FNSETFILES(MAT CALLAUDITFILELIST$,PATH$)
52000    fnend 
52010 ! 
52020    def FNSETFILES(;MAT SELECTEDFILES$,PATH$*255)
52030       library : FNBEGINAUDIT
52040       let FNBEGINAUDIT("",PATH$,MAT SELECTEDFILES$)
52050    fnend 
52060 ! 
52070    def FNCOMPAREFILES(;MAT SELECTEDFILES$,PATH$*255,___,BACKUPFOLDER$*255)
52080       let BACKUPFOLDER$=FNSETTINGS$("auditpath")
52090       let FNADDTRAILINGSLASH(BACKUPFOLDER$)
52100       if EXISTS(BACKUPFOLDER$) then 
52110          library : FNCOMPARE
52120          let FNCOMPARE(BACKUPFOLDER$,BACKUPFOLDER$&"audit.txt",1,0,PATH$,MAT SELECTEDFILES$)
52130       end if 
52140    fnend 
52150 ! 
52160    def FNCLEANFILENAME$*255(FILENAME$*255)
52170       let FNCLEANFILENAME$=SREP$(FILENAME$,":","")
52180    fnend 
52190 ! 
52200 Compare: ! ***** This function will compare two data sets
52210    def library FNCOMPARE(;BACKUPFOLDER$*80,LOGFILE$*80,PRINTER,DONTCLOSE,PATH$*255,MAT SELECTEDLAYOUTS$,___,COUNT,INDEX,NEWFILE,OLDFILE,OUTFILE,FILENAME$*255,TOTALRECORDS,CURRECMESSAGE$*255,LASTUPDATEMESSAGETIME)
52220       dim FILELIST$(1)*255
52230       dim NEWF$(1)*1024,NEWF(1)
52240       dim OLDF$(1)*1024,OLDF(1)
52250       dim COMPAREFORM$(1)*255
52260       dim RECORDS(1)
52270 ! 
52280       dim DUMMY$(1)*1024
52290       dim DUMMY(1)
52300 ! 
52310       if TRIM$(BACKUPFOLDER$)="" then let BACKUPFOLDER$=FNSETTINGS$("auditpath")
52320 ! 
52330       let FNADDTRAILINGSLASH(BACKUPFOLDER$)
52340       let FNADDTRAILINGSLASH(PATH$)
52350       if PATH$="\" then let PATH$=""
52360 ! 
52370       library : FNREADLAYOUTS, FNOPENFILE, FNGETFILENUMBER, FNBUILDKEY$, FNREADLAYOUTHEADER, FNPROGRESSBAR, FNCLOSEBAR
52380       let FNPRINTERSYS
52390 ! 
52400       if LEN(TRIM$(LOGFILE$)) then 
52410          open #(OUTFILE:=FNGETFILENUMBER): "name="&LOGFILE$&",recl=2048,use", display,output 
52420       end if 
52430 ! 
52440       if PRINTER then 
52450          open #255: "name=preview:/,recl=2048",display,output 
52460          print #255: "[Landscape][A4PAPER][SetFont(Lucida Console)][CPI(15)]"
52470       end if 
52480 ! 
52490       if OUTFILE then print #OUTFILE: "File Compare started at "&TIME$&" on "&DATE$("month dd, ccyy")
52500       if PRINTER then print #255: "File Compare started at "&TIME$&" on "&DATE$("month dd, ccyy")
52510 ! 
52520       if ~EXISTS(BACKUPFOLDER$) then 
52530          if OUTFILE then print #OUTFILE: "Backup Folder not Found."
52540          if PRINTER then print #255: "Backup Folder not Found."
52550       else 
52560          if FNVALIDMAT(MAT SELECTEDLAYOUTS$) then 
52570             mat FILELIST$(UDIM(SELECTEDLAYOUTS$))=SELECTEDLAYOUTS$
52580          else 
52590             let FNREADLAYOUTS(MAT FILELIST$)
52600          end if 
52610 ! 
52620          for INDEX=1 to UDIM(MAT FILELIST$)
52630             let FNREADLAYOUTHEADER(FILELIST$(INDEX),FILENAME$)
52640             if EXISTS(PATH$&FILENAME$) AND EXISTS(BACKUPFOLDER$&FNCLEANFILENAME$(PATH$&FILENAME$)) then 
52650 ! 
52660                let NEWFILE=FNOPEN(FILELIST$(INDEX),MAT NEWF$,MAT NEWF,MAT COMPAREFORM$,1,-1,0,PATH$,MAT DUMMY$,MAT DUMMY,1)
52670                if NEWFILE then 
52680 ! 
52690 ! .              ! Open OldFile, using same info as New File
52700                   open #(OLDFILE:=FNGETFILENUMBER) : "name="&BACKUPFOLDER$&FNCLEANFILENAME$(PATH$&FILENAME$),internal,outin,relative error IGNORE
52710                   if FILE(OLDFILE)=0 then 
52720                      mat COMPAREFORM$(MAX(UDIM(MAT COMPAREFORM$),OLDFILE))
52730                      let COMPAREFORM$(OLDFILE)=COMPAREFORM$(NEWFILE)
52740                      mat OLDF$(UDIM(MAT NEWF$)) : mat OLDF(UDIM(MAT NEWF))
52750 ! 
52760                      let TOTALRECORDS=(MAX(1,LREC(NEWFILE)+LREC(OLDFILE)))
52770 ! 
52780                      if OUTFILE then print #OUTFILE: "Comparing File: "&FILELIST$(INDEX)
52790                      if PRINTER then print #255: "Comparing File: "&FILELIST$(INDEX)
52800 ! 
52810                      mat RECORDS(0)=(0)
52820                      let COUNT=0
52830                      do UNTIL FILE(NEWFILE)=10  !eof
52840                         read #NEWFILE, using COMPAREFORM$(NEWFILE) : MAT NEWF$,MAT NEWF error IGNORE
52850                         if FILE(NEWFILE)=0 then 
52860                            mat RECORDS(UDIM(MAT RECORDS)+1)
52870                            let RECORDS(UDIM(MAT RECORDS))=REC(NEWFILE)
52880 ! 
52890                            read #OLDFILE, using COMPAREFORM$(OLDFILE), rec=REC(NEWFILE) : MAT OLDF$,MAT OLDF norec IGNORE
52900 ! 
52910                            if FILE(OLDFILE) then 
52920 ! .                          ! Log a Record is Added message
52930                               if OUTFILE then 
52940                                  print #OUTFILE: "Record "&STR$(REC(NEWFILE))&" was added with key: '"&FNBUILDKEY$(FILELIST$(INDEX),MAT NEWF$,MAT NEWF)&"', The Data was:";
52950                                  let FNPRINTARRAYS$(OUTFILE,MAT NEWF$,MAT NEWF)
52960                               end if 
52970 ! 
52980                               if PRINTER then 
52990                                  print #255: "[GREEN]Record "&STR$(REC(NEWFILE))&" was added with key: '"&FNBUILDKEY$(FILELIST$(INDEX),MAT NEWF$,MAT NEWF)&"', The Data was:";
53000                                  let FNPRINTARRAYS$(255,MAT NEWF$,MAT NEWF)
53010                                  print #255: "[BLACK]";
53020                               end if 
53030                            else 
53040 ! .                          ! Compare two records, log both records
53050                               if FNSAMEAS(MAT NEWF$,MAT OLDF$) AND FNSAMEA(MAT NEWF,MAT OLDF) then 
53060 ! .                             ! Do nothing, we're fine
53070                               else 
53080                                  if OUTFILE then 
53090                                     print #OUTFILE: "Record "&STR$(REC(NEWFILE))&" with key: '"&FNBUILDKEY$(FILELIST$(INDEX),MAT NEWF$,MAT NEWF)&"' was changed."
53100                                     print #OUTFILE: "The Data was: ";
53110                                     let FNPRINTARRAYS$(OUTFILE,MAT OLDF$,MAT OLDF)
53120                                     print #OUTFILE: "   It is now: ";
53130                                     let FNPRINTARRAYS$(OUTFILE,MAT NEWF$,MAT NEWF)
53140                                  end if 
53150 ! 
53160                                  if PRINTER then 
53170                                     print #255: "Record "&STR$(REC(NEWFILE))&" with key: '"&FNBUILDKEY$(FILELIST$(INDEX),MAT NEWF$,MAT NEWF)&"' was changed."
53180                                     print #255: "The Data was: ";
53190                                     let FNPRINTARRAYS$(255,MAT OLDF$,MAT OLDF,1,MAT NEWF$,MAT NEWF,14)
53200                                     print #255: "   It is now: ";
53210                                     let FNPRINTARRAYS$(255,MAT NEWF$,MAT NEWF,1,MAT OLDF$,MAT OLDF,14)
53220                                  end if 
53230                               end if 
53240                            end if 
53250                         else if FILE(NEWFILE)<>10 then 
53260 ! .                       ! Log an Error Reading File message
53270                            if OUTFILE then print #OUTFILE: "Warning: Error Reading Record "&STR$(REC(NEWFILE))&" in the current data. Record Skipped."
53280                            if PRINTER then print #255: "[RED]Warning: Error Reading Record "&STR$(REC(NEWFILE))&" in the current data. Record Skipped.[BLACK]"
53290                         end if 
53300                         let COUNT+=1
53310                         if (TIMER-LASTUPDATEMESSAGETIME)>.2 then 
53320                            let LASTUPDATEMESSAGETIME=TIMER
53330                            let CURRECMESSAGE$=" ("&STR$(COUNT)&"/"&STR$(TOTALRECORDS)&")"
53340                         end if 
53350                         let FNPROGRESSBAR(COUNT/TOTALRECORDS,"",0,0,0,"Comparing Files","Checking for Adds/Edits, File "&STR$(INDEX)&"/"&STR$(UDIM(MAT FILELIST$))&" ("&FILELIST$(INDEX)&")"&CURRECMESSAGE$)
53360                      loop 
53370                      restore #OLDFILE: 
53380                      do UNTIL FILE(OLDFILE)=10  !Eof
53390                         read #OLDFILE, using COMPAREFORM$(OLDFILE) : MAT OLDF$,MAT OLDF error IGNORE
53400                         if FILE(OLDFILE)=0 then 
53410                            if SRCH(RECORDS,REC(OLDFILE))<1 then 
53420                               if OUTFILE then 
53430                                  print #OUTFILE: "Record "&STR$(REC(OLDFILE))&" was deleted with key: '"&FNBUILDKEY$(FILELIST$(INDEX),MAT OLDF$,MAT OLDF)&"', The Data was:";
53440                                  let FNPRINTARRAYS$(OUTFILE,MAT OLDF$,MAT OLDF)
53450                               end if 
53460                               if PRINTER then 
53470                                  print #255: "[RED]Record "&STR$(REC(OLDFILE))&" was deleted with key: '"&FNBUILDKEY$(FILELIST$(INDEX),MAT OLDF$,MAT OLDF)&"', The Data was:";
53480                                  let FNPRINTARRAYS$(255,MAT OLDF$,MAT OLDF)
53490                                  print #255: "[BLACK]";
53500                               end if 
53510                            end if 
53520                         else if FILE(OLDFILE)<>10 then 
53530 ! .                       ! Log an Error Reading File message
53540                            if OUTFILE then 
53550                               print #OUTFILE: "Warning: Error Reading Record "&STR$(REC(OLDFILE))&" in the history data. Record Skipped."
53560                            end if 
53570 ! 
53580                            if PRINTER then 
53590                               print #255: "[RED]Warning: Error Reading Record "&STR$(REC(OLDFILE))&" in the history data. Record Skipped.[BLACK]"
53600                            end if 
53610                         end if 
53620                         let COUNT+=1
53630                         if (TIMER-LASTUPDATEMESSAGETIME)>.2 then 
53640                            let LASTUPDATEMESSAGETIME=TIMER
53650                            let CURRECMESSAGE$=" ("&STR$(COUNT)&"/"&STR$(TOTALRECORDS)&")"
53660                         end if 
53670                         let FNPROGRESSBAR(COUNT/TOTALRECORDS,"",0,0,0,"Comparing Files","Checking for Deletes, File "&STR$(INDEX)&"/"&STR$(UDIM(MAT FILELIST$))&" ("&FILELIST$(INDEX)&")"&CURRECMESSAGE$)
53680                      loop 
53690 ! 
53700                      close #OLDFILE: 
53710                      let FNCLOSEBAR
53720                   end if 
53730                   close #NEWFILE: 
53740                end if 
53750             else 
53760                if ~EXISTS(PATH$&FILENAME$) then 
53770                   if OUTFILE then print #OUTFILE: "Cannot Compare File: "&FILELIST$(INDEX)&" - The Data File doesn't exist"
53780                   if PRINTER then print #255: "Cannot Compare File: "&FILELIST$(INDEX)&" - The Data File doesn't exist"
53790                end if 
53800                if ~EXISTS(BACKUPFOLDER$&FNCLEANFILENAME$(PATH$&FILENAME$)) then 
53810                   if OUTFILE then print #OUTFILE: "Cannot Compare File: "&FILELIST$(INDEX)&" - The Backup of the File doesn't exist."
53820                   if PRINTER then print #255: "Cannot Compare File: "&FILELIST$(INDEX)&" - The Backup of the File doesn't exist."
53830                end if 
53840             end if 
53850          next INDEX
53860       end if 
53870 ! 
53880       if OUTFILE then close #OUTFILE: 
53890       if PRINTER AND ~DONTCLOSE then close #255: 
53900 ! 
53910       let FNCOMPARE=1
53920    fnend 
53930 ! 
53940    def FNPRINTARRAYS$(FILENUMBER,MAT F$,MAT F;COLOR,MAT OF$,MAT OF,LENGTH,___,INDEX)
53950       for INDEX=1 to UDIM(MAT F$)
53960          let LENGTH+=LEN(F$(INDEX))+2
53970          if LENGTH>120 AND FILENUMBER=255 then print #FILENUMBER: : let LENGTH=0
53980          if COLOR AND TRIM$(OF$(INDEX))<>TRIM$(F$(INDEX)) then 
53990             print #FILENUMBER: "[Red]"&TRIM$(F$(INDEX))&", "&"[Black]";
54000          else 
54010             print #FILENUMBER: TRIM$(F$(INDEX))&", ";
54020          end if 
54030       next INDEX
54040       for INDEX=1 to UDIM(MAT F)
54050          let LENGTH+=LEN(STR$(F(INDEX)))+2
54060          if LENGTH>128 AND FILENUMBER=255 then print #FILENUMBER: : let LENGTH=0
54070          if COLOR AND OF(INDEX)<>F(INDEX) then 
54080             print #FILENUMBER: "[Red]"&STR$(F(INDEX))&", "&"[Black]";
54090          else 
54100             print #FILENUMBER: STR$(F(INDEX))&", ";
54110          end if 
54120       next INDEX
54130       print #FILENUMBER: 
54140    fnend 
54150 ! 
54160    dim PRINTERSYSSET
54170    def FNPRINTERSYS                   !Activate Printer.Sys commands
54180       if ~PRINTERSYSSET then 
54190          execute "config PRINTER TYPE NWP select WIN:"
54200          execute "config PRINTER TYPE NWP select PREVIEW:"
54210 ! 
54220          execute 'config PRINTER NWP [RED], "\Ecolor=''#A00000''"'
54230          execute 'config PRINTER NWP [GREEN], "\Ecolor=''#00A000''"'
54240          execute 'config PRINTER NWP [BLACK], "\Ecolor=''#000000''"'
54250          execute 'config PRINTER NWP [CPI(NNN)], "\E(sNNNH"'
54260          execute 'config PRINTER NWP [SETFONT(FontName)], "\Efont=''FontName''"'
54270          execute 'config PRINTER NWP [A4PAPER], "\E&l26A" ! 210mm x 297mm'
54280          execute 'config PRINTER NWP [LANDSCAPE], "\E&l1O"'
54290          let PRINTERSYSSET=1
54300       end if 
54310    fnend 
54320 ! 
54330    def FNADDTRAILINGSLASH(&FOLDER$)
54340       if FOLDER$(LEN(FOLDER$):LEN(FOLDER$))<>"\" then 
54350          let FOLDER$=FOLDER$&"\"
54360       end if 
54370    fnend 
54380 ! 
54390    def FNVALIDMAT(MAT X$;___,INDEX,VALID)  !Checks to see if the given string array has any layouts in it
54400       do WHILE ((INDEX:=INDEX+1)<=UDIM(MAT X$))
54410          if LEN(X$(INDEX)) then let VALID=1
54420       loop UNTIL VALID
54430       let FNVALIDMAT=VALID
54440    fnend 
54450 ! 
54460 ! .! This function will copy all or some of your data files to a backup folder.
54470    def library FNCOPYDATAFILES(BACKUPFOLDER$*255;PATH$*255,MAT SELECTEDLAYOUTS$,SKIPKEYS,___,INDEX,FILENAME$*255,JNDEX,STATUS,STATUSCOUNT,DUMMY)
54480       library : FNREADLAYOUTS, FNREADLAYOUTHEADER, FNCOPYFILE, FNGETFILENUMBER
54490 ! 
54500       let FNADDTRAILINGSLASH(BACKUPFOLDER$)
54510       let FNADDTRAILINGSLASH(PATH$)
54520       if PATH$="\" then let PATH$=""
54530 ! 
54540       if ~EXISTS(BACKUPFOLDER$) then execute "mkdir "&BACKUPFOLDER$
54550 ! 
54560       open #(STATUS:=FNGETFILENUMBER): "srow=5,scol=10,rows=15,cols=60, border=s, caption=Progress",display,outin 
54570 ! 
54580       let STATHEADINGS$(1)="File"
54590       let STATWIDTH(1)=58
54600       let STATFORM$(1)="CC 255"
54610 ! 
54620       print #STATUS, fields "1,1,LIST 15/60,HEADERS,/W:W" : (MAT STATHEADINGS$,MAT STATWIDTH, MAT STATFORM$)
54630 ! 
54640       if FNVALIDMAT(MAT SELECTEDLAYOUTS$) then 
54650          mat FILELIST$(UDIM(SELECTEDLAYOUTS$))=SELECTEDLAYOUTS$
54660       else 
54670          let FNREADLAYOUTS(MAT FILELIST$)
54680       end if 
54690 ! 
54700       for INDEX=1 to UDIM(MAT FILELIST$)
54710          if LWRC$(TRIM$(FILELIST$(INDEX)))<>"logfile" then 
54720             let FNREADLAYOUTHEADER(FILELIST$(INDEX),FILENAME$,MAT AUDITKEYS$)
54730             if EXISTS(PATH$&FILENAME$) then 
54740                let FNMAKESUREPATHEXISTS(FNCLEANFILENAME$(PATH$&FILENAME$),BACKUPFOLDER$)
54750                let STATFILE$(1)=PATH$&FILENAME$
54760                print #STATUS, fields "1,1,LIST 15/60,+" : MAT STATFILE$
54770                let STATUSCOUNT+=1
54780                let CURFLD(1,STATUSCOUNT)
54790                input #STATUS, fields "1,1,LIST 15/60,ROWSUB,SEL,NOWAIT" : DUMMY
54800 ! 
54810 ! .           ! execute "copy "&FileName$&" "&BackupFolder$&FileName$&" -S -N"
54820                let FNCOPYFILE(PATH$&FILENAME$,BACKUPFOLDER$&FNCLEANFILENAME$(PATH$&FILENAME$))
54830 ! 
54840                if SKIPKEYS=2 then ! 2 means clear, 1 means skip, 0 means include
54850                   for JNDEX=1 to UDIM(MAT AUDITKEYS$)
54860                      if EXISTS(BACKUPFOLDER$&FNCLEANFILENAME$(PATH$&AUDITKEYS$(JNDEX))) then 
54870                         execute "*free "&BACKUPFOLDER$&FNCLEANFILENAME$(PATH$&AUDITKEYS$(JNDEX))
54880                      end if 
54890                   next JNDEX
54900                else 
54910                   for JNDEX=1 to UDIM(MAT AUDITKEYS$)
54920                      let FNMAKESUREPATHEXISTS(FNCLEANFILENAME$(PATH$&AUDITKEYS$(JNDEX)),BACKUPFOLDER$)
54930 ! 
54940                      let STATFILE$(1)=AUDITKEYS$(JNDEX)
54950                      print #STATUS, fields "1,1,LIST 15/60,+" : MAT STATFILE$
54960                      let STATUSCOUNT+=1
54970                      let CURFLD(1,STATUSCOUNT)
54980                      input #STATUS, fields "1,1,LIST 15/60,ROWSUB,SEL,NOWAIT" : DUMMY
54990 ! 
55000 ! .                 ! execute "copy "&AuditKeys$(Jndex)&" "&BackupFolder$&AuditKeys$(Jndex)&" -S -N"
55010                      let FNCOPYFILE(PATH$&AUDITKEYS$(JNDEX),BACKUPFOLDER$&FNCLEANFILENAME$(PATH$&AUDITKEYS$(JNDEX)))
55020                   next JNDEX
55030                end if 
55040             end if 
55050          end if 
55060       next INDEX
55070 ! 
55080       close #STATUS: 
55090    fnend 
55100 ! 
55110    dim CHUNK$*10000
55120    def library FNCOPYFILE(FROMFILE$*255,TOFILE$*255;NOPROGRESSBAR,___,FROMFILE,TOFILE,WRITTEN)
55130       let PROGRESSBAR=~NOPROGRESSBAR
55140 ! 
55150       library : FNGETFILENUMBER
55160 ! 
55170       open #(FROMFILE:=FNGETFILENUMBER): "name="&FROMFILE$&",recl=10000,shr",external,input 
55180       open #(TOFILE:=FNGETFILENUMBER): "name="&TOFILE$&",recl=10000,replace",external,output 
55190 ! 
55200 Readnextrec: ! Read the next record and process it
55210       let WRITTEN=0
55220       read #FROMFILE, using Copyfile : CHUNK$ eof Donecopying ioerr Shortrec
55230       if ~WRITTEN then write #TOFILE, using Copyfile : CHUNK$
55240 ! 
55250       if PROGRESSBAR AND LREC(FROMFILE) then let FNUPDATEPROGRESSBAR(REC(FROMFILE)/LREC(FROMFILE),"",0,0,0,"Transferring '"&FROMFILE$&"' File")
55260       goto Readnextrec
55270 ! 
55280 Donecopying: ! Done Copying the file here
55290 ! 
55300       if PROGRESSBAR then let FNCLOSEPROGRESSBAR
55310 ! 
55320       close #FROMFILE: 
55330       close #TOFILE: 
55340    fnend 
55350 ! 
55360 Copyfile: form C 10000
55370 ! 
55380 Shortrec: ! Process short record at EOF
55390    let C=CNT
55400    if ERR><4271 then let MSGBOX("Error during copying. Please try again.") : goto Donecopying
55410    reread #FROMFILE, using Copyfile : CHUNK$
55420 ! .  ! let Chunk$=rtrm$(Chunk$,chr$(0))
55430    let RLN(TOFILE,C)
55440    write #TOFILE, using "form C "&STR$(C) : CHUNK$(1:C)
55450    let WRITTEN=1
55460    continue 
55470 ! 
55480 ! 
55490    dim PBARSPEC$(1),PBARDOT$(1)
55500    dim PB_STARTTIME,PB_LASTPERCENT,PB_WINDOW,PB_NEWGUI,PB_PTIME,PB_SIZE,PB_COLOR$
55510    dim PB_PRINTEDLASTMESSAGEROW$*255,PB_OPENEDMESSAGEROWS
55520 ! 
55530    def library FNPROGRESSBAR(PERCENT;COLOR$,PROGRESSAFTER,PROGRESSTHRESHHOLD,UPDATETHRESHHOLD,CAPTION$*255,MESSAGEROW$*255)=FNUPDATEPROGRESSBAR(PERCENT,COLOR$,PROGRESSAFTER,PROGRESSTHRESHHOLD,UPDATETHRESHHOLD,CAPTION$,MESSAGEROW$)
55540    def library FNCLOSEBAR=FNCLOSEPROGRESSBAR
55550    def FNUPDATEPROGRESSBAR(PERCENT;COLOR$,PROGRESSAFTER,PROGRESSTHRESHHOLD,UPDATETHRESHHOLD,CAPTION$*255,MESSAGEROW$*255,___,MESSAGEROWS,INDEX,FROMSPOT,TOSPOT,SROW,SCOL,ROWS,COLS)
55560 ! .  ! Initialize Defaults
55570       if ~PROGRESSAFTER then let PROGRESSAFTER=.8  !3/4ths of a Second
55580       if ~PROGRESSTHRESHHOLD then let PROGRESSTHRESHHOLD=.45  !About 45 percent.
55590       if ~UPDATETHRESHHOLD then let UPDATETHRESHHOLD=.4  !4/10th of a Second
55600 ! 
55610       if LEN(CAPTION$) then let CAPTION$=",Caption="&CAPTION$
55620 ! 
55630       library : FNGETFILENUMBER
55640 ! 
55650 ! .  ! Save Color
55660       if LEN(COLOR$) then let PB_COLOR$=COLOR$
55670       if ~LEN(PB_COLOR$) then let PB_COLOR$="#00FF00"
55680 ! 
55690 ! .  ! Initialize Start Time
55700       if ~PB_STARTTIME then let PB_STARTTIME=TIMER
55710 ! 
55720       if PB_WINDOW AND PB_OPENEDMESSAGEROWS AND MESSAGEROW$><PB_PRINTEDLASTMESSAGEROW$ then 
55730          print #PB_WINDOW, fields "2,1,"&STR$(PB_SIZE)&"/CC 255" : MESSAGEROW$
55740          let MESSAGEROW$=PB_PRINTEDLASTMESSAGEROW$
55750       end if 
55760 ! 
55770       if FNPROGRESSBARTIME(PB_STARTTIME,PROGRESSAFTER,PERCENT,PROGRESSTHRESHHOLD) then ! If its time to open the progress bar
55780          if ~PB_WINDOW then ! if the pb_window isn't open yet, check if we need to open it
55790 ! .        ! Open Window
55800 ! 
55810 ! .        ! First, Detect Size and Position.
55820             let FNREADSCREENS(ROWS,COLS)
55830             let PB_SIZE=INT(COLS*.6666)  !78 Size should be .666*ScreenWidth
55840             let SROW=INT(ROWS/2)      !11 SRow should be int(half of the window) - 1
55850             let SCOL=INT((COLS-PB_SIZE)/2)  !2  SCol should be int(ScreenWidth-Size/2)
55860             let MESSAGEROWS=1 : let PB_OPENEDMESSAGEROWS=0
55870             if LEN(MESSAGEROW$) then let MESSAGEROWS+=1 : let PB_OPENEDMESSAGEROWS=1
55880 ! 
55890             open #(PB_WINDOW:=FNGETFILENUMBER): "SRow="&STR$(SROW)&",SCol="&STR$(SCOL)&",Rows="&STR$(MESSAGEROWS)&",Cols="&STR$(PB_SIZE)&CAPTION$&",Border=S",display,outin 
55900 ! 
55910 ! .        ! Initialize Window, Detect Gui Mode, Configure dot positions.
55920             if ENV$("guimode")="ON" then 
55930                let PB_NEWGUI=1
55940             else 
55950                mat PBARSPEC$(PB_SIZE) : mat PBARDOT$(PB_SIZE)
55960                for INDEX=1 to PB_SIZE
55970                   let PBARSPEC$(INDEX)="1,"&STR$(INDEX)&",C 1"
55980                next INDEX
55990                mat PBARDOT$=(".")
56000                print #PB_WINDOW, fields MAT PBARSPEC$ : MAT PBARDOT$
56010                mat PBARDOT$=("o")
56020             end if 
56030          end if 
56040 ! 
56050          if PB_WINDOW AND PB_PTIME+UPDATETHRESHHOLD<TIMER then ! We're printing already, and its been long enough.
56060             if (PERCENT*PB_SIZE)-PB_LASTPERCENT>=1 then 
56070                let FROMSPOT=MAX(INT(PB_LASTPERCENT),1)
56080                let TOSPOT=MIN(INT(PERCENT*PB_SIZE),PB_SIZE)
56090                if PB_NEWGUI then 
56100                   print #PB_WINDOW, fields "1,1,"&STR$(TOSPOT)&"/C 1,S/W:"&PB_COLOR$ : ""  !Probably much faster in new gui, a single control.
56110                else 
56120                   print #PB_WINDOW, fields MAT PBARSPEC$(FROMSPOT:TOSPOT) : MAT PBARDOT$(FROMSPOT:TOSPOT)
56130                end if 
56140                let PB_LASTPERCENT=PERCENT*PB_SIZE
56150             end if 
56160             let PB_PTIME=TIMER
56170          end if 
56180       end if 
56190    fnend 
56200 ! 
56210    def FNCLOSEPROGRESSBAR(;___,FROMSPOT,TOSPOT)
56220       if PB_WINDOW then 
56230 ! .     ! Print end of Progress Bar
56240          let FROMSPOT=MAX(INT(PB_LASTPERCENT),1)
56250          let TOSPOT=PB_SIZE
56260          if FROMSPOT<=TOSPOT then 
56270             if PB_NEWGUI then 
56280                print #PB_WINDOW, fields "1,1,"&STR$(TOSPOT)&"/C 1,S/W:"&PB_COLOR$ : ""
56290             else 
56300                print #PB_WINDOW, fields MAT PBARSPEC$(FROMSPOT:TOSPOT) : MAT PBARDOT$(FROMSPOT:TOSPOT)
56310             end if 
56320          end if 
56330 ! .     ! Close Progress Bar
56340          close #PB_WINDOW: 
56350       end if 
56360 ! 
56370 ! .  ! Also reset all progress bar saved parms for next time.
56380       let PB_WINDOW=PB_LASTPERCENT=PB_STARTTIME=PB_NEWGUI=PB_PTIME=PB_SIZE=0
56390    fnend 
56400 ! 
56410 ! .! Progress Bar Calculations. fnEnoughProgress is the basic formula. fnProgressBarTime calls it with 1, 2, and 3 for Multipliers.
56420    def FNENOUGHPROGRESS(MULTIPLIER,STARTTIME,PROGRESSAFTER,PERCENT,THRESHHOLD)=((STARTTIME+(PROGRESSAFTER*MULTIPLIER))<TIMER AND PERCENT<(THRESHHOLD*MULTIPLIER))
56430    def FNPROGRESSBARTIME(ST,PA,PCT,T)=(FNENOUGHPROGRESS(1,ST,PA,PCT,T) OR FNENOUGHPROGRESS(2,ST,PA,PCT,T) OR FNENOUGHPROGRESS(3,ST,PA,PCT,T))
56440 ! 
56450    def FNMAKESUREPATHEXISTS(FILENAME$*255;PATH$*255)
56460       do WHILE POS(FILENAME$,"\")
56470          let PATH$=PATH$&FILENAME$(1:POS(FILENAME$,"\"))
56480          let FILENAME$=FILENAME$(POS(FILENAME$,"\")+1:LEN(FILENAME$))
56490          if ~EXISTS(PATH$) then execute "mkdir "&PATH$
56500       loop 
56510    fnend 
56520 ! 
56530    def library FNSHOWMESSAGE(MESSAGE$*54;___,WINNUMBER)
56540       library : FNGETFILENUMBER
56550       open #(WINNUMBER:=FNGETFILENUMBER): "SROW=10,SCOL=12,ROWS=3,COLS=56,BORDER=S",display,outin 
56560       print #WINNUMBER, fields "2,2,CC 54" : MESSAGE$
56570       let FNSHOWMESSAGE=WINNUMBER
56580    fnend 
56590 ! 
56600 ! .! This function reads an environment variable on the client under client server.
56610    def library FNCLIENTENV$*255(ENVKEY$;___,F,VALUE$*255)
56620       library : FNGETFILENUMBER
56630 ! .  ! Make a cmd file
56640       open #(F:=FNGETFILENUMBER): "name=@:temp[session].cmd, replace", display, output 
56650       print #F: "echo %"&ENVKEY$&"% > tempout"&SESSION$&".txt"
56660       close #F: 
56670       execute "system -@ -M temp"&SESSION$&".cmd"
56680       open #(F:=FNGETFILENUMBER): "name=@:tempout[session].txt", display, input 
56690       linput #F: VALUE$
56700       close #F: 
56710       let FNCLIENTENV$=RTRM$(VALUE$)
56720    fnend 
56730 ! 
56740    dim ROWVAL$(1)*255,PRINTROW$*1000
56750 ! 
56760    dim START(1),ENDER(1),MASK(1)
56770    dim HEADERS$(1)*50,EXWIDTHS(1),EXFORMS$(1)*50,HEADERS$*2000, SORTORDER(1)
56780    dim LISTDATA$(1)*1023, LISTROW$(1)*1023
56790    dim SELECTEDROWS(1)
56800 ! 
56810    def library FNEXPORTLISTVIEWCSV(WINDOW,SPEC$;GENFILENAME,DELIM$,FILENAME$*255,___,WAITWIN,CS,NUMOFCOLS,TURN,INSTANCE,N,M,SORTNEXT,FORMAT$*64,SELNO,SELECTED)
56820       if FN43 then 
56830          library : FNGETFILENUMBER,FNSHOWMESSAGE
56840 ! 
56850          if ~LEN(TRIM$(DELIM$)) then let DELIM$='","'
56860          let WAITWIN=FNSHOWMESSAGE("Exporting... Please Wait.")
56870 ! 
56880 ! .     ! Query the Listview Header
56890          input #WINDOW, fields SPEC$&",HEADERS,,nowait ": (MAT HEADERS$,MAT EXWIDTHS,MAT EXFORMS$)
56900          let MAT2STR(MAT HEADERS$,HEADERS$,'","')
56910 ! 
56920 ! .     ! Read the Listview Filter
56930          input #WINDOW, fields SPEC$&",mask,,nowait" : (MAT MASK)
56940 ! .     ! Read number of columns
56950          input #WINDOW, fields SPEC$&",colcnt,all,nowait" : NUMOFCOLS
56960 ! 
56970 ! .     ! Handle any Sorting that has occurred.
56980          input #WINDOW, fields SPEC$&",rowsub,all,displayed_order,nowait": MAT SORTORDER
56990 ! 
57000          input #WINDOW, fields SPEC$&",rowcnt,sel,nowait ": SELNO
57010          if SELNO>1 AND MSGBOX("Do you ONLY want to include selected items in your report?","List Report","Yn","QST")=2 then 
57020             let SELECTED=1
57030             mat SELECTEDROWS(SELNO)
57040             input #WINDOW, fields SPEC$&",rowsub,sel,nowait": MAT SELECTEDROWS
57050          else 
57060             let SELECTED=0
57070          end if 
57080 ! 
57090 ! .     ! Calculate the mat Start and mat End necessary to read the data
57100 ! .     ! We're using a trick here. Looks like BR Returns displayed_order with all the
57110 ! .     !  filter-showing rows at the end. So we just read the last however many rows
57120 ! .     !  of our mat SortOrder and use it for our Starts and Ends, and they're already in
57130 ! .     !  displayed order for us
57140          mat START(SUM(MASK))=SORTORDER(UDIM(MAT SORTORDER)-SUM(MASK)+1:UDIM(MAT SORTORDER))
57150          mat ENDER(SUM(MASK))=START
57160 ! 
57170 ! .     ! Make enough room for the data we're reading
57180          mat LISTDATA$(NUMOFCOLS*UDIM(MAT START))
57190          mat LISTROW$(NUMOFCOLS)
57200 ! 
57210 ! .     ! Read the data in the order sorted
57220          let M=0
57230          for N=1 to UDIM(MAT START)
57240             if ~SELECTED OR SRCH(MAT SELECTEDROWS,START(N))>0 then ! If not "selection only" or if this is part of the selection
57250                let M+=1
57260                input #WINDOW, fields SPEC$&",row,range,nowait" : START(N), ENDER(N), (MAT LISTROW$)
57270                mat LISTDATA$(((M-1)*NUMOFCOLS)+1:M*NUMOFCOLS)=LISTROW$
57280             end if 
57290          next N
57300 ! 
57310          mat LISTDATA$(NUMOFCOLS*M)
57320 ! 
57330 ! .     ! Find a unique name
57340          if GENFILENAME then 
57350             let FILENAME$=FNGENERATEFILENAME$("@:csvexpt","csv")
57360          end if 
57370 ! 
57380 ! .     ! Open the data file
57390          if (LEN(TRIM$(FILENAME$))) then 
57400             open #(CS:=FNGETFILENUMBER): "NAME="&FILENAME$&",replace,recl=2000",display,output 
57410          else 
57420             open #(CS:=FNGETFILENUMBER): "NAME=SAVE:CSV files (*.csv) |*.csv,replace,RECL=2000", display, output 
57430             let FILENAME$=FILE$(CS)
57440          end if 
57450 ! 
57460 ! .     ! Print Header Line
57470          print #CS: '"'&HEADERS$&'"'
57480 ! 
57490 ! .     ! Loop through data and print the CSV file one line at a time.
57500          let TURN=0
57510          do 
57520             mat LISTROW$(NUMOFCOLS)
57530             for N=1 to NUMOFCOLS
57540                let LISTROW$(N)=TRIM$(LISTDATA$(N+TURN))
57550 ! .           ! Apply Conversion if needed
57560                if LWRC$(TRIM$(EXFORMS$(N)(1:5)))="date(" OR LWRC$(TRIM$(EXFORMS$(N)(1:4)))="fmt(" OR LWRC$(TRIM$(EXFORMS$(N)(1:4)))="pic(" then 
57570                   let FORMAT$=EXFORMS$(N)
57580                   if POS(FORMAT$,",") then 
57590                      let FORMAT$=FORMAT$(1:POS(FORMAT$,",")-1)
57600                   end if 
57610                   let LISTROW$(N)=CNVRT$(FORMAT$,VAL(LISTROW$(N))) error IGNORE
57620                end if 
57630             next N
57640             let M=0
57650             for N=1 to NUMOFCOLS
57660                let M+=1
57670                if N<=UDIM(MAT EXWIDTHS) AND EXWIDTHS(N)=0 then 
57680                   let FNREMOVECOLUMN(M,MAT LISTROW$)
57690                   let M-=1
57700                end if 
57710             next N
57720 ! 
57730             let MAT2STR(MAT LISTROW$,PRINTROW$,DELIM$)
57740             print #CS: '"'&PRINTROW$&'"'
57750 ! 
57760             let PRINTROW$=""
57770             let TURN=TURN+NUMOFCOLS
57780          loop WHILE TURN<UDIM(MAT LISTDATA$)
57790 ! 
57800          close #CS: 
57810 ! 
57820 ! .     ! Launch the file in the default application ..
57830          execute "sy -C -M -@ start "&OS_FILENAME$(FILENAME$)
57840          close #WAITWIN: 
57850       else 
57860          let MSGBOX("Export from Listview requires BR 4.3 or higher.","Export Failed")
57870       end if 
57880    fnend 
57890 ! 
57900    def FNGENERATEFILENAME$*255(BASE$*255,EXTENSION$;___,FILENAME$*255,INSTANCE)
57910       if LEN(EXTENSION$) AND EXTENSION$(1:1)><"." then let EXTENSION$(1:0)="."
57920       let FILENAME$=BASE$&SESSION$&DATE$("mmdddyy")&TIME$(1:2)&TIME$(4:5)&TIME$(7:8)&EXTENSION$
57930       do WHILE EXISTS(FILENAME$)
57940          let INSTANCE+=1
57950          let FILENAME$=BASE$&SESSION$&DATE$("mmdddyy")&TIME$(1:2)&TIME$(4:5)&TIME$(7:8)&STR$(INSTANCE)&EXTENSION$
57960       loop 
57970 ! 
57980       let FNGENERATEFILENAME$=FILENAME$
57990    fnend 
58000 ! 
58010    def FNREMOVECOLUMN(COL,MAT ARRAY$;___,I)
58020       for I=COL to UDIM(MAT ARRAY$)-1
58030          let ARRAY$(I)=ARRAY$(I+1)
58040       next I
58050       mat ARRAY$(UDIM(MAT ARRAY$)-1)
58060    fnend 
58070 ! 
58080 Bademaillibrary: ! Jump here if email can't be sent.
58090    let MSGBOX("The email could not be sent. The custom EmailLibrary$ specified in your fileio.ini file is invalid, or missing the fnSendMail function.","Error")
58100    continue 
58110 ! 
58120    dim EMAILCONF$(1)*1024,EMAILCONF(1),EMAILCONF,FORM$(1)*255
58130    dim CCEMAILSTRING$*10000
58140    dim EMAILADDRESSSTRING$*10256
58150    def library FNSENDEMAIL(EMAILADDRESS$*255,EMAILMESSAGE$*10000;SUBJECT$*255,INVOICEFILE$*255,NOPROMPT,BCCEMAIL$*255,MAT CCEMAILS$,CCASTO,___,RESULTFILE,SUCCESS,OUTPUTSTRING$*1024,INDEX,EMAILLIBRARY$*64)
58160 ! 
58170       let EMAILLIBRARY$=FNSETTINGS$("emaillibrary")
58180 ! 
58190       if LEN(EMAILLIBRARY$) then 
58200          if EXISTS(EMAILLIBRARY$) then 
58210             library EMAILLIBRARY$ : FNSENDMAIL error Bademaillibrary
58220             let FNSENDEMAIL=FNSENDMAIL(EMAILADDRESS$,EMAILMESSAGE$,SUBJECT$,INVOICEFILE$,NOPROMPT,BCCEMAIL$,MAT CCEMAILS$,CCASTO) error Bademaillibrary
58230          else 
58240             let MSGBOX("The Custom EmailLibrary$ specified in fileio.ini could not be found.","Error")
58250          end if 
58260       else 
58270          library : FNOPENFILE, FNGETFILENUMBER, FNDOESLAYOUTEXIST
58280          if FNDOESLAYOUTEXIST("emailcfg") then 
58290             if EXISTS("sendemail.exe") then 
58300                let EMAILCONF=FNOPEN("emailcfg",MAT EMAILCONF$,MAT EMAILCONF,MAT FORM$,1,0,0,"",D$,D,0,0,1)
58310                read #EMAILCONF, using FORM$(EMAILCONF),rec=1 : MAT EMAILCONF$,MAT EMAILCONF norec IGNORE
58320                if FILE(EMAILCONF)=0 then 
58330                   if EXISTS("EmailLog.[WSID]") then execute "*free EmailLog.[WSID]"
58340                   if EMAILMESSAGE$="" then let EMAILMESSAGE$=" "
58350                   let EMAILMESSAGE$=SREP$(EMAILMESSAGE$,HEX$("0D"),HEX$("0A"))
58360                   let EMAILMESSAGE$=SREP$(EMAILMESSAGE$,HEX$("0A0A"),HEX$("0A"))
58370                   let EMAILMESSAGE$=SREP$(EMAILMESSAGE$,HEX$("0A"),"\n")
58380                   if LEN(BCCEMAIL$) then let BCCEMAIL$(1:0)=" -bcc "
58390                   let CCEMAILSTRING$=""
58400                   for INDEX=1 to UDIM(MAT CCEMAILS$)
58410                      if LEN(TRIM$(CCEMAILS$(INDEX))) then 
58420                         if LEN(TRIM$(CCEMAILSTRING$)) then let CCEMAILSTRING$=CCEMAILSTRING$&" "
58430                         let CCEMAILSTRING$=CCEMAILSTRING$&CCEMAILS$(INDEX)
58440                      end if 
58450                   next INDEX
58460 ! 
58470                   let EMAILADDRESSSTRING$=EMAILADDRESS$
58480 ! 
58490                   if CCASTO then 
58500                      if LEN(TRIM$(EMAILADDRESSSTRING$)) then let EMAILADDRESSSTRING$=EMAILADDRESSSTRING$&" "
58510                      let EMAILADDRESSSTRING$=EMAILADDRESSSTRING$&CCEMAILSTRING$
58520                      let CCEMAILSTRING$=""
58530                   end if 
58540 ! 
58550                   if LEN(TRIM$(CCEMAILSTRING$)) then let CCEMAILSTRING$=" -cc "&CCEMAILSTRING$
58560 ! 
58570                   if LEN(TRIM$(INVOICEFILE$)) then 
58580                      execute 'sy -M -s -t120 sendemail -s '&EMAILCONF$(CONF_SERVER)&' -t '&EMAILADDRESSSTRING$&' -f '&EMAILCONF$(CONF_FROMADDR)&' -xu '&EMAILCONF$(CONF_USERACCOUNT)&' -xp '&EMAILCONF$(CONF_PASSWORD)&' -u "'&SUBJECT$&'" -m "'&EMAILMESSAGE$&'" -a "'&OS_FILENAME$(INVOICEFILE$)&'"'&CCEMAILSTRING$&BCCEMAIL$&' -v -q -l EmailLog.'&WSID$
58590                   else 
58600                      execute 'sy -M -s -t120 sendemail -s '&EMAILCONF$(CONF_SERVER)&' -t '&EMAILADDRESSSTRING$&' -f '&EMAILCONF$(CONF_FROMADDR)&' -xu '&EMAILCONF$(CONF_USERACCOUNT)&' -xp '&EMAILCONF$(CONF_PASSWORD)&' -u "'&SUBJECT$&'" -m "'&EMAILMESSAGE$&'"'&CCEMAILSTRING$&BCCEMAIL$&' -v -q -l EmailLog.'&WSID$
58610                   end if 
58620                   execute 'type EmailLog.[WSID] >>EmailLog.txt'
58630                   open #(RESULTFILE:=FNGETFILENUMBER): "name=EmailLog.[WSID],recl=512",display,input 
58640                   do UNTIL FILE(RESULTFILE)
58650                      linput #RESULTFILE: OUTPUTSTRING$ eof IGNORE
58660                      if POS(OUTPUTSTRING$,"Email was sent successfully!") then let SUCCESS=1
58670                   loop 
58680                   close #RESULTFILE: 
58690                   execute '*free EmailLog.[WSID]'
58700                   let FNSENDEMAIL=SUCCESS
58710                   if SUCCESS AND ~NOPROMPT then let MSGBOX("Email was sent successfully!","Email Sent")
58720                else 
58730                   let MSGBOX("Email account not configured. Please enter the appropriate information in the emailcfg file.","Error")
58740                end if 
58750             else 
58760                let MSGBOX("SendEmail.exe program not found. Please include it with your software. This program can be downloaded for free from the internet.","Error")
58770             end if 
58780          else 
58790             let MSGBOX("The Email Configuration File is missing. Please add the emailcfg file layout to your layout folder. It is included in the latest versions of fileio.","Error")
58800          end if 
58810       end if 
58820    fnend 
58830 ! 
58840    def library FNSUBSTITUTESTRINGCODE(&STRING$,CODE$*2048;SUBSTITUTECHAR$,___,SCS$,SCE$,PREFIX$,SUBSTRING$,LASTPLACESEARCHED,VALUE$*255)
58850       execute CODE$
58860 ! 
58870       if SUBSTITUTECHAR$="" then let SUBSTITUTECHAR$="[]"
58880       let SUBSTITUTECHAR$=RPAD$(SUBSTITUTECHAR$,2)
58890       let SCS$=SUBSTITUTECHAR$(1:1) : let SCE$=SUBSTITUTECHAR$(2:2)
58900 ! 
58910       do WHILE (LASTPLACESEARCHED:=POS(STRING$,SCS$,LASTPLACESEARCHED+1))
58920          let SUBSTRING$=FNEXTRACTSUBSTRING$(STRING$,SCS$,SCE$)
58930          execute "Value$="&SUBSTRING$ error Skipthis
58940          let STRING$=SREP$(STRING$,TRIM$(SCS$&SUBSTRING$&SCE$),VALUE$)
58950 ! 
58960 Skipthis: ! Jump here if error executing Substring
58970       loop 
58980    fnend 
58990 ! 
59000    def library FNSTANDARDTIME$(MT$;SECONDS,___,H,M,S,P)
59010       library : FNPARSETIME, FNBUILDTIME$
59020       let FNPARSETIME(MT$,H,M,S,P)
59030       let FNSTANDARDTIME$=FNBUILDTIME$(H,M,S,P,0,SECONDS)
59040    fnend 
59050 ! 
59060    def library FNMILITARYTIME$(ST$;SECONDS,___,H,M,S,P)
59070       library : FNPARSETIME, FNBUILDTIME$
59080       let FNPARSETIME(ST$,H,M,S,P)
59090       let FNMILITARYTIME$=FNBUILDTIME$(H,M,S,P,1,SECONDS)
59100    fnend 
59110 ! 
59120    def library FNCALCULATEHOURS(TIMEIN$,TOUT$,DAYSIN,DAYSOUT;___,HRIN,HROUT,MININ,MINOUT,SECIN,SECOUT,TOTAL,TOTALOUT)
59130 ! .! this function returns the hours between timein and tout, which must be passed in as hhmmss in string form
59140       let HRIN=VAL(TIMEIN$(1:2))
59150       let HROUT=VAL(TOUT$(1:2))
59160       let MININ=VAL(TIMEIN$(3:4))
59170       let MINOUT=VAL(TOUT$(3:4))
59180       let SECIN=VAL(TIMEIN$(5:6))
59190       let SECOUT=VAL(TOUT$(5:6))
59200 ! 
59210       let DAYCOUNT=DAYSOUT-DAYSIN
59220 ! 
59230       if DAYCOUNT>=2 then 
59240 ! .  ! add 24 hours for each full day
59250          let TOTAL+=24*(DAYCOUNT-1)
59260       end if 
59270 ! 
59280       if DAYCOUNT>=1 then 
59290 ! .  ! first day trough midnight calculation
59300          let TOTAL+=(24-HRIN)
59310          if MININ<>0 then 
59320             let TOTAL-=((MININ)/60)
59330          end if 
59340          if SECIN<>0 then 
59350             let TOTAL-=(SECIN/3600)
59360          end if 
59370 ! .  ! last day from midnight calculation
59380          let TOTAL+=HROUT
59390          let TOTAL+=(MINOUT/60)
59400          let TOTAL+=(SECOUT/3600)
59410       else 
59420 ! .  ! in same day
59430          let TOTAL+=HROUT-HRIN
59440          if MININ<>0 then 
59450             let TOTAL-=((MININ)/60)
59460          end if 
59470          if SECIN<>0 then 
59480             let TOTAL-=(SECIN/3600)
59490          end if 
59500          let TOTAL+=(MINOUT/60)
59510          let TOTAL+=(SECOUT/3600)
59520       end if 
59530       let TOTALOUT=ROUND(TOTAL,2)
59540       if TOTALOUT=0 then let TOTALOUT=.01  !set to a few seconds minimum
59550       let FNCALCULATEHOURS=TOTALOUT
59560    fnend 
59570 ! 
59580 ! 
59590    def library FNBUILDTIME$(H,M,S,P;MILITARY,SECONDS,___,P$,H$,M$,S$)
59600       let M$=":"&CNVRT$("PIC(##)",M)
59610       if SECONDS then let S$=":"&CNVRT$("PIC(##)",S)
59620 ! 
59630       if MILITARY then 
59640          if P then let H+=12 : let P=0
59650       else 
59660          if H>12 then let H-=12 : let P=1
59670          if P then let P$="pm" else let P$="am"
59680       end if 
59690 ! 
59700       let H$=STR$(H)
59710 ! 
59720       let FNBUILDTIME$=H$&M$&S$&P$
59730    fnend 
59740 ! 
59750    def library FNPARSETIME(T$,&H,&M,&S,&P;___,COLON)
59760       let T$=LWRC$(T$)
59770 ! 
59780       if POS(T$,"p")>0 then let P=1
59790       let T$=SREP$(T$,"a","")
59800       let T$=SREP$(T$,"p","")
59810       let T$=SREP$(T$,"m","")
59820 ! 
59830       let H=FNPARSENEXTCOLON(T$)
59840       let M=FNPARSENEXTCOLON(T$)
59850       let S=FNPARSENEXTCOLON(T$)
59860    fnend 
59870 ! 
59880    def FNPARSENEXTCOLON(&T$;___,COLON)
59890       let COLON=POS(T$,":")
59900       if COLON>0 then 
59910          let FNPARSENEXTCOLON=VAL(T$(1:COLON-1))
59920          let T$(1:COLON)=""
59930       else 
59940          let FNPARSENEXTCOLON=VAL(T$)
59950          let T$=""
59960       end if 
59970    fnend 
59980 ! 
59990    dim SUBSTRINGSUBS$(1)*255,SUBNUMERICSUBS$(1)*255
60000    def library FNSUBSTITUTESTRING(&STRING$,FILELAYOUT$,MAT F$,MAT F;SUBSTITUTECHAR$,___,SCS$,SCE$,PREFIX$,SUBSTRING$,LASTPLACESEARCHED)
60010       if SUBSTITUTECHAR$="" then let SUBSTITUTECHAR$="[]"
60020       let SUBSTITUTECHAR$=RPAD$(SUBSTITUTECHAR$,2)
60030       let SCS$=SUBSTITUTECHAR$(1:1) : let SCE$=SUBSTITUTECHAR$(2:2)
60040 ! 
60050 ! .  ! Read Layout:
60060       library : FNREADLAYOUTARRAYS
60070       let FNREADLAYOUTARRAYS(FILELAYOUT$,PREFIX$,MAT SUBSTRINGSUBS$,MAT SUBNUMERICSUBS$)
60080 ! 
60090       do WHILE (LASTPLACESEARCHED:=POS(STRING$,SCS$,LASTPLACESEARCHED+1))
60100          let SUBSTRING$=FNEXTRACTSUBSTRING$(STRING$,SCS$,SCE$)
60110          if LWRC$(SUBSTRING$(1:LEN(PREFIX$)))=LWRC$(PREFIX$) then ! If its a match for the given file then
60120             let STRING$=SREP$(STRING$,TRIM$(SCS$&SUBSTRING$&SCE$),FNSUBMATCHVALUE$(SUBSTRING$(LEN(PREFIX$)+1:99),MAT SUBSTRINGSUBS$,MAT SUBNUMERICSUBS$,MAT F$,MAT F))
60130          end if 
60140       loop 
60150    fnend 
60160 ! 
60170    def FNSUBMATCHVALUE$*1023(SUBSTRING$,MAT STRINGSUBS$,MAT NUMSUBS$,MAT F$,MAT F;___,INDEX,CASEUPPER,CASELOWER,CASETITLE)
60180       if POS(SUBSTRING$,"::U") then 
60190          let SUBSTRING$=SREP$(SUBSTRING$,"::U","")
60200          let CASEUPPER=1
60210       else if POS(SUBSTRING$,"::L") then 
60220          let SUBSTRING$=SREP$(SUBSTRING$,"::L","")
60230          let CASELOWER=1
60240       else if POS(SUBSTRING$,"::T") then 
60250          let SUBSTRING$=SREP$(SUBSTRING$,"::T","")
60260          let CASETITLE=1
60270       end if 
60280 ! 
60290       let INDEX=FNFINDMATCH(SUBSTRING$,MAT STRINGSUBS$)
60300       if INDEX>0 then 
60310          if CASEUPPER then 
60320             let FNSUBMATCHVALUE$=UPRC$(TRIM$(F$(INDEX)))
60330          else if CASELOWER then 
60340             let FNSUBMATCHVALUE$=LWRC$(TRIM$(F$(INDEX)))
60350          else if CASETITLE then 
60360             let FNSUBMATCHVALUE$=FNTITLECASE$(TRIM$(F$(INDEX)))
60370          else 
60380             let FNSUBMATCHVALUE$=TRIM$(F$(INDEX))
60390          end if 
60400       else 
60410          let INDEX=FNFINDMATCH(SUBSTRING$,MAT NUMSUBS$)
60420          if INDEX>0 then 
60430             let FNSUBMATCHVALUE$=STR$(F(INDEX))
60440          end if 
60450       end if 
60460    fnend 
60470 ! 
60480    def FNTITLECASE$*1023(STRING$*1023;___,INDEX,AFTERASPACE,STRINGOUT$*1023)
60490       let AFTERASPACE=1
60500       for INDEX=1 to LEN(STRING$)
60510          if AFTERASPACE then 
60520             let STRINGOUT$(9999:0)=UPRC$(STRING$(INDEX:INDEX))
60530             let AFTERASPACE=0
60540          else 
60550             let STRINGOUT$(9999:0)=LWRC$(STRING$(INDEX:INDEX))
60560          end if 
60570          if STRING$(INDEX:INDEX)=" " then let AFTERASPACE=1
60580       next INDEX
60590       let FNTITLECASE$=STRINGOUT$
60600    fnend 
60610 ! 
60620    def FNFINDMATCH(SUB$,MAT SUBS$;___,INDEX)
60630       for INDEX=1 to UDIM(MAT SUBS$)
60640          let SUBS$(INDEX)=LWRC$(SUBS$(INDEX))
60650       next INDEX
60660       let FNFINDMATCH=SRCH(MAT SUBS$,LWRC$(SUB$))
60670    fnend 
60680 ! 
60690    dim TEMPES$*10000
60700    def FNEXTRACTSUBSTRING$(&STRING$,SCS$,SCE$;___,P)
60710       if (P:=POS(STRING$,SCS$)) then 
60720          let TEMPES$=STRING$(P+1:10000+P)
60730          if POS(TEMPES$,SCE$) then let TEMPES$=TEMPES$(1:POS(TEMPES$,SCE$)-1)
60740 ! 
60750          let FNEXTRACTSUBSTRING$=TEMPES$(1:18)
60760       end if 
60770    fnend 
60780 ! 
60790 Readscreensize: ! Return The Screen Size Of Window 0 In Terms Of Rows And Columns
60800    dim SCREENSIZE(4), FONTSIZE(2)
60810    def library FNREADSCREENSIZE(&ROWS,&COLS;PARENTWINDOW)=FNREADSCREENS(ROWS,COLS,PARENTWINDOW)
60820    def FNREADSCREENS(&ROWS,&COLS;PARENTWINDOW)
60830       if ENV$("guimode")><"ON" then 
60840          let ROWS=24
60850          let COLS=80
60860       else if ~FN42E then 
60870          let FNOLDREADSCREENSIZE(ROWS,COLS,PARENTWINDOW)
60880       else 
60890          let FILE(PARENTWINDOW,"USABLE_RECT",MAT SCREENSIZE)
60900          let FILE(PARENTWINDOW,"FONTSIZE",MAT FONTSIZE)
60910          let ROWS=(SCREENSIZE(4)/FONTSIZE(1))
60920          let COLS=(SCREENSIZE(3)/FONTSIZE(2))
60930       end if 
60940    fnend 
60950 ! 
60960    def FNOLDREADSCREENSIZE(&ROWS,&COLS;PARENTWINDOW,___,FFILE,STRING$*2000,SROW,SCOL,EROW,ECOL,POSITION,STAR$)
60970       let STAR$=FNNEEDSTAR$
60980       execute STAR$&"Status Files >[SESSION].tmp"
60990       open #(FFILE:=FNGETFILENUMBER) : "name=[SESSION].tmp",display,input 
61000 ! 
61010       do WHILE FILE(FFILE)=0
61020          linput #FFILE: STRING$ eof IGNORE
61030       loop UNTIL STRING$(1:5)="-----"
61040       do WHILE FILE(FFILE)=0
61050          linput #FFILE: STRING$ eof IGNORE
61060       loop UNTIL (LWRC$(STRING$)(1:4)="open") AND TRIM$(STRING$(POS(STRING$,"#")+1:POS(STRING$,"#")+5))=STR$(PARENTWINDOW)
61070       if FILE(FFILE)=0 then 
61080          linput #FFILE: STRING$ eof IGNORE
61090       end if 
61100 ! 
61110       close #FFILE: 
61120       execute STAR$&"Free [SESSION].tmp"
61130 ! 
61140       if (POSITION:=POS(UPRC$(STRING$),"SROW=")) then 
61150          let SROW=VAL(STRING$(POSITION+5:POS(STRING$,",",POSITION)-1)) conv IGNORE
61160       end if 
61170       if (POSITION:=POS(UPRC$(STRING$),"SCOL=")) then 
61180          let SCOL=VAL(STRING$(POSITION+5:POS(STRING$,",",POSITION)-1)) conv IGNORE
61190       end if 
61200       if (POSITION:=POS(UPRC$(STRING$),"EROW=")) then 
61210          let EROW=VAL(STRING$(POSITION+5:POS(STRING$,",",POSITION)-1)) conv IGNORE
61220       end if 
61230       if (POSITION:=POS(UPRC$(STRING$),"ECOL=")) then 
61240          let ECOL=VAL(STRING$(POSITION+5:POS(STRING$,",",POSITION)-1)) conv IGNORE
61250       end if 
61260       if SROW AND EROW then let ROWS=EROW-SROW+1
61270       if SCOL AND ECOL then let COLS=ECOL-SCOL+1
61280    fnend 
61290 ! 
61300    def FN43=(VAL(WBVERSION$(1:3))>=4.3)
61310    def FN42E=(WBVERSION$>="4.20e")
61320    def FN42=(VAL(WBVERSION$(1:3))>=4.2)
61330    def FN418=((VAL(WBVERSION$(1:4))>=4.18) OR FN42)
61340    def FN42IA=(WBVERSION$>="4.20ia")
61350    def FN42J=(WBVERSION$>="4.20j")
61360 ! 
99000 ! #Autonumber# 99000,10
99010 Open: ! ***** Function To Call Library Openfile And Proc Subs
99020    def FNOPEN(FILENAME$*255, MAT F$, MAT F, MAT FORM$; INPUTONLY, KEYNUM, DONT_SORT_SUBS, PATH$*255, MAT DESCR$, MAT FIELD_WIDTHS,SUPRESS_PROMPT,IGNORE_ERRORS,SUPPRESS_LOG,MAT DATEFMT$,___,INDEX)
99030       dim _FILEIOSUBS$(1)*800, _LOADEDSUBS$(1)*80
99040       let FNOPEN=FNOPENFILE(FILENAME$, MAT F$, MAT F, MAT FORM$, INPUTONLY, KEYNUM, DONT_SORT_SUBS, PATH$, MAT DESCR$, MAT FIELD_WIDTHS, MAT _FILEIOSUBS$, SUPRESS_PROMPT,IGNORE_ERRORS,PROGRAM$,SUPPRESS_LOG,MAT DATEFMT$)
99050       if SRCH(_LOADEDSUBS$,UPRC$(FILENAME$))<=0 then : mat _LOADEDSUBS$(UDIM(_LOADEDSUBS$)+1) : let _LOADEDSUBS$(UDIM(_LOADEDSUBS$))=UPRC$(FILENAME$) : for INDEX=1 to UDIM(MAT _FILEIOSUBS$) : execute (_FILEIOSUBS$(INDEX)) : next INDEX
99060    fnend 
99070 ! 
99900 ! #Autonumber# 99900,5
99905 Ignore: continue 
99910 Retrycount: ! 
99915    if ERRORRETRYCOUNT<5 then 
99920       let ERRORRETRYCOUNT+=1
99925       retry 
99930    else 
99935       let ERRORRETRYCOUNT=0
99940       continue 
99945    end if 
99950 ! 
99955 Sleepretrycount: ! 
99960    let SLEEP(.1)
99965    if SLEEPRETRYCOUNT<5 then 
99970       let SLEEPRETRYCOUNT+=1
99975       retry 
99980    else 
99985       let SLEEPRETRYCOUNT=0
99990       continue 
99995    end if 
