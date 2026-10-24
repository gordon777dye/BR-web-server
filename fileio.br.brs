00010 ! Fileio - Copyright February 2006 By Gabriel Bakker #Autonumber# 10,10
00020 !    Distributed Open Source As A Christmas Gift To Brag Members
00030 ! This Library Houses All File Maintenance Operations
00040 ! 
00050 ! Created: 03/28/06
00060 ! Modified: 01/29/12
00070 ! 
00080 ! 
00500 ! #Autonumber# 500,1
00501 ! If You Run This Library As A Program, It Will Function As A Data
00502 ! Crawler That Will Allow You To View The Raw Data In Your Datafiles
00503 ! 
00504 ! To Update A Datafile, Just Simply Increase The Version Number
00505 ! Then Make Any Change You Like - Add Fields, Remove Fields, Rearrange
00506 ! Fields, Change Keys...
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
00518 ! By Creating A Simple Procfile Called Fileio.Ini, A Procfile That
00519 ! Resides In The Current Path And Setting The Appropriate Values.
00520 ! 
00521    goto Dims
00522 ! 
01000 ! #Autonumber# 1000,5
01005 Settings: ! ***** Set Global Defaults For The Library Here
01010    def FNDEFAULTSETTINGS(&DEFAULTFILELAYOUTPATH$;&PROMPTONFILECREATE,&CREATELOGFILE,&ENFORCEDUPKEYS,&STARTFILENUMBER,&CHECKINDEX,&COMPRESSCOLUMNS,&MAXCOLWIDTH,&NEWLINE$,&LOGLIBRARY$,&LOGLAYOUT$,&ANIMATEDATACRAWLER,&TEMPLATEPATH$,&IGNORELAYOUTS$,&CLOSEFILESIMPLE)
01015       let ENFORCEDUPKEYS=1 ! Enforce That Key Number 1 Is Unique Key
01020       let DEFAULTFILELAYOUTPATH$="filelay\" ! Path To Your File Layouts
01025       let PROMPTONFILECREATE=1 ! Ask User Before Creating New Files
01030       let CREATELOGFILE=0
01035       let STARTFILENUMBER=1 ! Set Above 255 To Avoid Conflicts With Legacy Programs.
01040       let CHECKINDEX=0 ! Automatically Update Indexes (Use For Partial Fileio Implementations, Disable For Full Fileio Installations.)
01045       let COMPRESSCOLUMNS=0 ! Shrink Or Expand Columns In Data Crawler By Default
01050       let MAXCOLWIDTH=20 ! Max Default Column Width In Data Crawler
01055       let NEWLINE$=CHR$(13)&CHR$(10) ! Default Crlf
01060       let LOGLIBRARY$="" ! Defaut Log Library, Defaults To None
01065       let LOGLAYOUT$="" ! Log File Layout, Defaults To Internal File
01070       let ANIMATEDATACRAWLER=1 ! Use Screenio Animation For Datacrawler (If Available, Will Not Cause Error If Not Available)
01075       let TEMPLATEPATH$="filelay\template\" ! Default Template Path
01080       let IGNORELAYOUTS$="" ! List Any Ignore Layouts Here.
01085       let CLOSEFILESIMPLE=0 ! Use Simple Comparison For Fnclosefile
01090    fnend 
01095 ! 
01100    def FNREADSETTINGS(MAT SSETTINGNAMES$,MAT SSETTINGS$,MAT NSETTINGNAMES$,MAT NSETTINGS$,&READSETTINGS;___,DEFAULTFILELAYOUTPATH$*255,NEWLINE$*255,LOGLIBRARY$*255,PROMPTONFILECREATE,CREATELOGFILE,ENFORCEDUPKEYS,STARTFILENUMBER,CHECKINDEX,COMPRESSCOLUMNS,MAXCOLWIDTH,LOGLIBRARY$*255,LOGLAYOUT$,ANIMATEDATACRAWLER,TEMPLATEPATH$*255,IGNORELAYOUTS$*255,CLOSEFILESIMPLE,STAR$)
01105       let STAR$=FNNEEDSTAR$
01110       let FNDEFAULTSETTINGS(DEFAULTFILELAYOUTPATH$,PROMPTONFILECREATE,CREATELOGFILE,ENFORCEDUPKEYS,STARTFILENUMBER,CHECKINDEX,COMPRESSCOLUMNS,MAXCOLWIDTH,NEWLINE$,LOGLIBRARY$,LOGLAYOUT$,ANIMATEDATACRAWLER,TEMPLATEPATH$,IGNORELAYOUTS$,CLOSEFILESIMPLE)
01115       if EXISTS("fileio.ini") then 
01120          execute STAR$&"subproc fileio.ini"
01125       else if EXISTS("fileio\fileio.ini") then 
01130          execute STAR$&"subproc fileio\fileio.ini"
01135       else if EXISTS("\fileio.ini") then 
01140          execute STAR$&"subproc \fileio.ini"
01145       end if 
01150 ! 
01155       if ANIMATEDATACRAWLER AND EXISTS("screenio.br") then 
01160          library "screenio" : FNANIMATE, FNPREPAREANIMATION, FNCLOSEANIMATION
01165       else 
01170          let ANIMATEDATACRAWLER=0
01175       end if 
01180       if LOGLAYOUT$="" AND EXISTS(DEFAULTFILELAYOUTPATH$&"logfile") then let LOGLAYOUT$="logfile"
01185       if LOGLAYOUT$<>"" then let IGNORELAYOUTS$=IGNORELAYOUTS$&","&LOGLAYOUT$
01190       let IGNORELAYOUTS$=LWRC$(IGNORELAYOUTS$)
01195 ! 
01200       let SSETTINGNAMES$(1)="layoutpath"
01205       let SSETTINGNAMES$(2)="newline"
01210       let SSETTINGNAMES$(3)="loglibrary"
01215       let SSETTINGNAMES$(4)="loglayout"
01220       let SSETTINGNAMES$(5)="templatepath"
01225       let SSETTINGNAMES$(6)="ignorelayouts"
01230 ! 
01235       let NSETTINGNAMES$(1)="promptonfilecreate"
01240       let NSETTINGNAMES$(2)="createlogfile"
01245       let NSETTINGNAMES$(3)="enforcedupkeys"
01250       let NSETTINGNAMES$(4)="startfilenumber"
01255       let NSETTINGNAMES$(5)="checkindex"
01260       let NSETTINGNAMES$(6)="compresscolumns"
01265       let NSETTINGNAMES$(7)="maxcolwidth"
01270       let NSETTINGNAMES$(8)="animatedatacrawler"
01275       let NSETTINGNAMES$(9)="closefilesimple"
01280 ! 
01285       let SSETTINGS$(1)=DEFAULTFILELAYOUTPATH$
01290       let SSETTINGS$(2)=NEWLINE$
01295       let SSETTINGS$(3)=LOGLIBRARY$
01300       let SSETTINGS$(4)=LOGLAYOUT$
01305       let SSETTINGS$(5)=TEMPLATEPATH$
01310       let SSETTINGS$(6)=IGNORELAYOUTS$
01315 ! 
01320       let NSETTINGS(1)=PROMPTONFILECREATE
01325       let NSETTINGS(2)=CREATELOGFILE
01330       let NSETTINGS(3)=ENFORCEDUPKEYS
01335       let NSETTINGS(4)=STARTFILENUMBER
01340       let NSETTINGS(5)=CHECKINDEX
01345       let NSETTINGS(6)=COMPRESSCOLUMNS
01350       let NSETTINGS(7)=MAXCOLWIDTH
01355       let NSETTINGS(8)=ANIMATEDATACRAWLER
01360       let NSETTINGS(9)=CLOSEFILESIMPLE
01365 ! 
01370       let READSETTINGS=1
01375    fnend 
01380 ! 
01385    dim READSETTINGS
01390    dim SSETTINGNAMES$(6),SSETTINGS$(6)*255
01395    dim NSETTINGNAMES$(9),NSETTINGS(9)
01400 ! 
01405    def FNSETTINGS$*255(SETTINGNAME$;___,SETTINGSUB)
01410       if ~READSETTINGS then let FNREADSETTINGS(MAT SSETTINGNAMES$,MAT SSETTINGS$,MAT NSETTINGNAMES$,MAT NSETTINGS$,READSETTINGS)
01415       let SETTINGSUB=SRCH(MAT SSETTINGNAMES$,LWRC$(SETTINGNAME$))
01420       if SETTINGSUB>0 then let FNSETTINGS$=SSETTINGS$(SETTINGSUB)
01425    fnend 
01430    def FNSETTINGS(SETTINGNAME$;___,SETTINGSUB)
01435       if ~READSETTINGS then let FNREADSETTINGS(MAT SSETTINGNAMES$,MAT SSETTINGS$,MAT NSETTINGNAMES$,MAT NSETTINGS$,READSETTINGS)
01440       let SETTINGSUB=SRCH(MAT NSETTINGNAMES$,LWRC$(SETTINGNAME$))
01445       if SETTINGSUB>0 then let FNSETTINGS=NSETTINGS(SETTINGSUB)
01450    fnend 
01455 ! 
01460    dim STARSCHECKED
01465    def FNNEEDSTAR$
01470       if STARSCHECKED then 
01475          if STARSCHECKED=-1 then let FNNEEDSTAR$="*"
01480       else 
01485          if ENV$("guimode")="ON" then 
01490             let STARSCHECKED=1
01495          else 
01500             let STARSCHECKED=-1
01505             let FNNEEDSTAR$="*"
01510          end if 
01515       end if 
01520    fnend 
01525 ! 
02000 ! #Autonumber# 2000,10
02010 Dims: ! Dimension Statements For Data Crawler
02020    dim LVDIR_HEADINGS$(1)*30,LVDIR_WIDTHS(1),LVDIR_FIELDFORMS$(1)
02030    dim DC_DATA$(1)*1024,DC_DATA(1),DC_FORMS$(1)*2000,DC_DFDESCR$(1)*80,DC_DFLABEL$(1)*80,DC_DFSHOW(1)
02040    dim CSV_DATA$(1)*4000,CSV_DATA(1),CSV_FORMS$(1)*2000
02050    dim DC_WIDTHS(1),FIELDFORMS$(1),DC_OUTPUTROW$(1)*1024,DC_RECORDS(1)
02060    dim DC_SAVEDATA$(1)*1024, DC_SAVESUBS(1)
02070    dim DC_DELETEROW(1),DC_COLORSTART(1),DC_COLOREND(1),DC_COLOR$(1)
02080    dim DC_CHANGEDDATA$(1)*1024, DC_CHANGEDSUBS(1)
02090    dim _DUMMY$*255,_DUMMY,_LOGGING
02100    dim INCLUDECOLS$(1), UIOPTIONS$(13), SELECTEDRECORDS(1),RECORDS(1)
02110    dim SEARCH$*80
02120 ! 
02130    if TRIM$(ENV$("guimode"))="" then 
02140       print "DataCrawler Mode only works with New Gui version of BR"
02150       stop 
02160    end if 
02170    let TURNGUIBACKOFF=(ENV$("guimode")=="OFF")
02180    if TURNGUIBACKOFF then execute "config gui on"
02190 ! 
02200    let LVDIR_HEADINGS$(1)="File Layouts" !:
         let LVDIR_WIDTHS(1)=38 !:
         let LVDIR_FIELDFORMS$(1)="CC 30"
02210 ! 
02220    let UIOPTIONS$(1)="quitbutton"
02230    let UIOPTIONS$(2)="exportbutton"
02240    let UIOPTIONS$(3)="importbutton"
02250    let UIOPTIONS$(4)="columnsbutton"
02260    let UIOPTIONS$(5)="keybutton"
02270    let UIOPTIONS$(6)="deletebutton"
02280    let UIOPTIONS$(7)="savebutton"
02290    let UIOPTIONS$(8)="addbutton"
02300    let UIOPTIONS$(9)="search"
02310    let UIOPTIONS$(10)="border"
02320    let UIOPTIONS$(11)="caption"
02330    let UIOPTIONS$(12)="recl"
02340    let UIOPTIONS$(13)="position"
02350    mat INCLUDECOLS$(0) ! We're including all cols
02360    mat RECORDS(0) ! We're including all records
02370 ! 
02380    library : FNREADLAYOUTS,FNSHOWDATA,FNGETFILENUMBER, FNLOG, FNLOGARRAY
02390 ! 
07000 Selectdatafile: ! ***** Datafile Selection Routine #Autonumber# 7000,10
07010 ! 
07020    if EXISTS("audit.br") then let AUDITFOUND=1
07030 ! 
07040    open #(DC_WINDOW:=FNGETFILENUMBER): "srow=2,scol=22,rows=21,cols=39,Caption= Select File ... ENTER - View / F5 - Edit ,Border=S",display,outin 
07050    let FNREADLAYOUTS(MAT LVDIR_LISTING$)
07060    if UDIM(MAT LVDIR_LISTING$)>15 then let LVDIR_WIDTHS(1)-=2 ! Make Room For Scrollbar
07070 ! 
07080    let _LOGGING=FNSETTINGS("createlogfile")
07090 ! 
07100 ! .! Ignore layouts we're supposed to ignore.
07110    let _IGNORELAYOUTS$=FNSETTINGS$("ignorelayouts")
07120    for DC_INDEX=1 to UDIM(MAT LVDIR_LISTING$)
07130       if ~POS(LWRC$(_IGNORELAYOUTS$),LWRC$(TRIM$(LVDIR_LISTING$(DC_INDEX)))) then 
07140          let DC_JNDEX+=1
07150          let LVDIR_LISTING$(DC_JNDEX)=LVDIR_LISTING$(DC_INDEX)
07160       end if 
07170    next DC_INDEX
07180    mat LVDIR_LISTING$(DC_JNDEX)
07190 ! 
07200    print #DC_WINDOW, fields "18,3,CC 10,,B43;18,27,CC 10,,B44" : "Quit","View"
07210    if AUDITFOUND then print #DC_WINDOW, fields "18,15,CC 10,,B47" : "Audit"
07220    print #DC_WINDOW, fields "21,10,CC 20,,B45" : "Generate Code"
07230    print #DC_WINDOW, fields "20,10,CC 20,,B46" : "New Layout Wizard"
07240    print #DC_WINDOW, fields "1,2,LIST 15/37,HEADERS" : (MAT LVDIR_HEADINGS$, MAT LVDIR_WIDTHS, MAT LVDIR_FIELDFORMS$)
07250    print #DC_WINDOW, fields "1,2,LIST 15/37,=" : (MAT LVDIR_LISTING$)
07260    print #DC_WINDOW, fields "1,2,LIST 15/37,SORT" : 1
07270    do 
07280       input #DC_WINDOW, fields "16,2,SEARCH 37,,1,2;1,2,LIST 15/37,ROWCNT,SEL,44" : SEARCH$,COUNT
07290       mat SELECTEDRECORDS(COUNT)
07300       input #DC_WINDOW, fields "1,2,LIST 15/37,ROWSUB,SEL,NOWAIT" : MAT SELECTEDRECORDS
07310       input #DC_WINDOW, fields "1,2,LIST 15/37,ROWSUB,CUR,NOWAIT" : CHOSEN
07320 ! 
07330       let DC_KEY=FKEY
07340       if DC_KEY=0 OR DC_KEY=201 then let DC_KEY=44 ! Ok Button
07350       if DC_KEY=99 then let DC_KEY=43 ! Esc Button
07360       if DC_KEY=93 then let DC_KEY=43
07370       if DC_KEY=44 then ! Ok Selected
07380          let FNSHOWDATA(LVDIR_LISTING$(CHOSEN),0,0,0,0,0,1,"","","","","Data Crawler",MAT RECORDS,MAT INCLUDECOLS$,MAT UIOPTIONS$,D$,D,D$,"rec")
07390          if FKEY=93 then let DC_KEY=43 ! Pass Windows X Click Back To Parent
07400       end if 
07410       if DC_KEY=5 then 
07420          let FNSHOWDATA(LVDIR_LISTING$(CHOSEN),1,0,0,0,0,1,"","","","","Data Editor",MAT RECORDS,MAT INCLUDECOLS$,MAT UIOPTIONS$,D$,D,D$,"rec")
07430       end if 
07440       if DC_KEY=45 then 
07450          let FNGENERATECODE(LVDIR_LISTING$(CHOSEN))
07460       end if 
07470       if DC_KEY=46 then 
07480          let FNLAYOUTWIZARD
07490       end if 
07500       if DC_KEY=47 then 
07510          let FNCALLAUDIT(MAT SELECTEDRECORDS)
07520       end if 
07530       if FKEY=93 then let DC_KEY=43 ! Pass Windows X Click Back To Parent
07540    loop UNTIL DC_KEY=43
07550    close #DC_WINDOW: 
07560 ! 
08000 Enddatacrawler: ! #Autonumber# 8000,10
08010    if TURNGUIBACKOFF then execute "config gui off"
08020    if FKEY=93 then 
08030       execute "system"
08040    end if 
08050    stop 
08060 ! 
10000 ! #Autonumber# 10000,1
10001 ! *****************
10002 ! ** Datacrawler **
10003 ! *****************
10004 ! 
10005    dim SEARCHNOW$*999
10006    dim DCSPEC$(2)*60
10007    dim FILTERF$(1)*1023,FILTERF(1)
10008 ! 
10009    def library FNDATAEDIT(FILELAY$;SROW$,SCOL$,ROWS$,COLS$,___,SROW,SCOL,ROWS,COLS)
10010       let SROW=VAL(SROW$) conv Ignore
10011       let SCOL=VAL(SCOL$) conv Ignore
10012       let ROWS=VAL(ROWS$) conv Ignore
10013       let COLS=VAL(COLS$) conv Ignore
10014 ! 
10015       library : FNSHOWDATA
10016       let FNDATAEDIT=FNSHOWDATA(FILELAY$,1,SROW,SCOL,ROWS,COLS)
10017    fnend 
10018 ! 
10019    def library FNDATACRAWLER(FILELAY$;SROW$,SCOL$,ROWS$,COLS$,___,SROW,SCOL,ROWS,COLS)
10020       let SROW=VAL(SROW$) conv Ignore
10021       let SCOL=VAL(SCOL$) conv Ignore
10022       let ROWS=VAL(ROWS$) conv Ignore
10023       let COLS=VAL(COLS$) conv Ignore
10024 ! 
10025       library : FNSHOWDATA
10026       let FNDATACRAWLER=FNSHOWDATA(FILELAY$,0,SROW,SCOL,ROWS,COLS)
10027    fnend 
10028 ! 
10029    def FNCALCULATESIZE(&SROW,&SCOL,&ROWS,&COLS,EDIT,MAT ELEMENT$,MAT FILTER$;___,SCREENROWS,SCREENCOLS,MINROWS,MINCOLS,MAXROWS,MAXCOLS,MINSROW,MINSCOL,ADJROWS,ADJCOLS)
10030       let FNREADSCREENS(SCREENROWS,SCREENCOLS)
10031       let FNCALCULATESIZELIMITS(MAT ELEMENT$,EDIT,SCREENROWS,SCREENCOLS,ROWS,COLS,MINROWS,MINCOLS,MAXROWS,MAXCOLS,MINSROW,MINSCOL,MAT FILTER$)
10032 ! 
10033 ! .   ! Size it within limits
10034       let ROWS=MAX(MIN(ROWS,MAXROWS),MINROWS)
10035       let COLS=MAX(MIN(COLS,MAXCOLS),MINCOLS)
10036 ! 
10037 ! .   ! Center it if position isn't given
10038       if ~SROW then let SROW=INT((SCREENROWS-ROWS)/2)+1
10039       if ~SCOL then let SCOL=INT((SCREENCOLS-COLS)/2)+1
10040 ! 
10041       let ADJROWS=INT((SCREENROWS+MAXROWS)/2)
10042       let ADJCOLS=INT((SCREENCOLS+MAXCOLS)/2)
10043 ! 
10044 ! .   ! Adjust it to fit it on screen
10045       let SROW=MAX(MIN(SROW,ADJROWS-ROWS),MINSROW)
10046       let SCOL=MAX(MIN(SCOL,ADJCOLS-COLS),MINSCOL)
10047    fnend 
10048 ! 
10049 ! .! If Include is blank (not given), then include everything.
10050    def FNPREPINCLUDEUI$(MAT INCLUDEUI$;___,INDEX,EMPTY)
10051       if FNISEMPTYS(MAT INCLUDEUI$) then 
10052 ! .      ! Default UI Options
10053          mat INCLUDEUI$(10)
10054          let INCLUDEUI$(1)="quitbutton"
10055          let INCLUDEUI$(2)="exportbutton"
10056          let INCLUDEUI$(3)="importbutton"
10057          let INCLUDEUI$(4)="columnsbutton"
10058          let INCLUDEUI$(5)="deletebutton"
10059          let INCLUDEUI$(6)="savebutton"
10060          let INCLUDEUI$(7)="addbutton"
10061          let INCLUDEUI$(8)="search"
10062          let INCLUDEUI$(9)="border"
10063          let INCLUDEUI$(10)="caption"
10064       end if 
10065 ! 
10066    fnend 
10067 ! 
10068    def FNISEMPTYS(MAT A$;___,INDEX,EMPTY)
10069       let EMPTY=1
10070       for INDEX=1 to UDIM(MAT A$)
10071          if A$(INDEX)<>"" then let EMPTY=0
10072       next INDEX
10073       let FNISEMPTYS=EMPTY
10074    fnend 
10075    def FNISEMPTY(MAT A;___,INDEX,EMPTY)
10076       let EMPTY=1
10077       for INDEX=1 to UDIM(MAT A)
10078          if A(INDEX) then let EMPTY=0
10079       next INDEX
10080       let FNISEMPTY=EMPTY
10081    fnend 
10082    def library FNEMPTY(MAT A)=FNISEMPTY(MAT A)
10083    def library FNEMPTYS(MAT A$)=FNISEMPTYS(MAT A$)
10084 ! 
10085    def FNCLEARUI(MAT OUTPUTSPEC$,MAT INPUTSPEC$,MAT OUTPUTDATA$,MAT INPUTDATA$)
10086       mat OUTPUTSPEC$(0)
10087       mat OUTPUTDATA$(0)
10088       mat INPUTSPEC$(0)
10089       mat INPUTDATA$(0)
10090       let BUTTONCOUNT=0
10091    fnend 
10092 ! 
10093    dim BUTTONCOUNT,MAXBUTTONCOLUMNS
10094    def FNBUTTONROWS
10095       if BUTTONCOUNT then 
10096          let FNBUTTONROWS=INT((BUTTONCOUNT-1)/MAXBUTTONCOLUMNS)+1
10097       end if 
10098    fnend 
10099 ! 
10100    def FNBUTTONSPEC$*36(BUTTONFKEY,ROW,COLS;___,BUTTONCOL,BUTTONROW)
10101       let BUTTONCOUNT+=1
10102       let BUTTONROW=INT((BUTTONCOUNT-1)/MAXBUTTONCOLUMNS)
10103       let BUTTONCOL=MOD(BUTTONCOUNT-1,MAXBUTTONCOLUMNS)+1
10104       let FNBUTTONSPEC$=STR$(ROW-BUTTONROW)&","&STR$(COLS-((8*(BUTTONCOL))-1))&","&"7/CC 10,,B"&STR$(BUTTONFKEY)
10105    fnend 
10106 ! 
10107    def FNADDBUTTON(MAT OUTPUTSPEC$,MAT OUTPUTDATA$,ROWS,COLS,BUTTONFKEY,DATA$)
10108       let FNADDOBJECT(MAT OUTPUTSPEC$,MAT OUTPUTDATA$,FNBUTTONSPEC$(BUTTONFKEY,ROWS,COLS),DATA$)
10109    fnend 
10110 ! 
10111    def FNADDOBJECT(MAT OUTPUTSPEC$,MAT OUTPUTDATA$,SPEC$*40,DATA$;___,INDEX)
10112       let INDEX=UDIM(MAT OUTPUTSPEC$)+1
10113       mat OUTPUTSPEC$(INDEX)
10114       mat OUTPUTDATA$(INDEX)
10115       let OUTPUTSPEC$(INDEX)=SPEC$
10116       let OUTPUTDATA$(INDEX)=DATA$
10117       let FNADDOBJECT=INDEX
10118    fnend 
10119 ! 
10120    def FNCALCULATESIZELIMITS(MAT ELEMENT$,EDIT,SCREENROWS,SCREENCOLS,&ROWS,&COLS,&MINROWS,&MINCOLS,&MAXROWS,&MAXCOLS,&MINSROW,&MINSCOL,MAT FILTER$;___,INDEX,BCOUNT,BCOLS,O_BORDER,BUTTONROWS)
10121 ! 
10122 ! .   ! Set Defaults
10123       let MAXROWS=SCREENROWS
10124       let MAXCOLS=SCREENCOLS
10125       let MINSROW=1
10126       let MINSCOL=1
10127       let MINROWS=3
10128       let MINCOLS=10
10129 ! 
10130       for INDEX=1 to UDIM(MAT ELEMENT$)
10131          if LWRC$(TRIM$(ELEMENT$(INDEX))) = "importbutton" OR LWRC$(TRIM$(ELEMENT$(INDEX))) = "addbutton" OR LWRC$(TRIM$(ELEMENT$(INDEX))) = "deletebutton" OR LWRC$(TRIM$(ELEMENT$(INDEX))) = "savebutton" then ! #Select# Lwrc$(Trim$(Element$(Index))) #Case# "importbutton" # "addbutton" # "deletebutton" # "savebutton"
10132             if EDIT then let BCOUNT+=1
10133          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "columnsbutton" OR LWRC$(TRIM$(ELEMENT$(INDEX))) = "exportbutton" OR LWRC$(TRIM$(ELEMENT$(INDEX))) = "keybutton" OR LWRC$(TRIM$(ELEMENT$(INDEX))) = "quitbutton" then ! #Case# "columnsbutton" # "exportbutton" # "keybutton" # "quitbutton"
10134             let BCOUNT+=1
10135          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "search" then ! #Case# "search"
10136             let MINROWS+=1
10137             let MINCOLS=MAX(MINCOLS,20)
10138          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "grid" then ! #Case# "grid"
10139          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "border" OR LWRC$(TRIM$(ELEMENT$(INDEX))) = "caption" OR LWRC$(TRIM$(ELEMENT$(INDEX))) = "recl" then ! #Case# "border" # "caption" # "recl"
10140             let O_BORDER=1
10141          end if  ! #End Select#
10142       next INDEX
10143 ! 
10144       if O_BORDER then ! Expand To Include Border
10145          let MAXROWS-=2 : let MAXCOLS-=2
10146          let MINSROW+=1 : let MINSCOL+=1
10147       end if 
10148 ! 
10149 ! .   ! Default Size if not given
10150       if ~ROWS then let ROWS=MAXROWS
10151       if ~COLS then let COLS=MAXCOLS
10152 ! 
10153 ! .   ! calculate how many columns we need
10154       if BCOUNT<5 OR BCOUNT<=(COLS-2)/8 then 
10155          let MAXBUTTONCOLUMNS=BCOUNT
10156       else 
10157          let MAXBUTTONCOLUMNS=INT((BCOUNT-1)/2)+1
10158       end if 
10159 ! 
10160 ! .   ! Expand to include buttons
10161       if BCOUNT then 
10162          let BUTTONROWS=INT((BCOUNT-1)/MAXBUTTONCOLUMNS)+1
10163          let MINROWS+=BUTTONROWS
10164          if BUTTONROWS>1 then 
10165             let BCOLS=MAXBUTTONCOLUMNS
10166          else 
10167             let BCOLS=MOD((BCOUNT-1),MAXBUTTONCOLUMNS)+1
10168          end if 
10169          let MINCOLS=MAX(MINCOLS,(8*(BCOLS-1))+10)
10170       end if 
10171 ! 
10172 ! .   ! Add a row for filters
10173       if ~FNISEMPTYS(MAT FILTER$) then 
10174          let MINROWS+=1
10175       end if 
10176    fnend 
10177 ! 
10178    def FNBUILDUI(MAT ELEMENT$,MAT OS$,MAT IS$,MAT OD$,MAT ID$,MAT FILTERFIELDS$,MAT FILTERFORM$,MAT FILTERCOMPARE$,MAT FILTERCAPTION$,MAT FILTERDEFAULTS$,MAT FILTERSUBS,MAT FILTERVALSUBS,MAT COLUMNNAMES$,MAT FILTERKEY,&GRIDSPEC$,EDIT,ROWS,COLS;&O_CAPTION,&O_BORDER,&O_RECL,&O_POSITION,&SEARCHSUB,___,O_SEARCH,INDEX,GRID$,FIRSTROW,FILTERPOSITION,SUB)
10179       let FIRSTROW=1
10180       if ~FNISEMPTYS(MAT FILTERFIELDS$) then 
10181          let FIRSTROW+=1
10182          let FILTERPOSITION=1
10183          mat FILTERFORM$(UDIM(MAT FILTERFIELDS$))
10184          mat FILTERCOMPARE$(UDIM(MAT FILTERFIELDS$))
10185          mat FILTERCAPTION$(UDIM(MAT FILTERFIELDS$))
10186          mat FILTERDEFAULTS$(UDIM(MAT FILTERFIELDS$))
10187          mat FILTERSUBS(UDIM(MAT FILTERFIELDS$))
10188          mat FILTERVALSUBS(UDIM(MAT FILTERFIELDS$))
10189          mat FILTERKEY(UDIM(MAT FILTERFIELDS$))
10190 ! 
10191          for INDEX=1 to UDIM(MAT FILTERFIELDS$)
10192             if LEN(TRIM$(FILTERFIELDS$(INDEX))) then 
10193                let SUB=SRCH(MAT COLUMNNAMES$,LWRC$(TRIM$(FILTERFIELDS$(INDEX))))
10194                if SUB>0 then 
10195                   let FNADDOBJECT(MAT OS$,MAT OD$,"1,"&STR$(FILTERPOSITION)&",CR "&STR$(LEN(FILTERCAPTION$(INDEX))),FILTERCAPTION$(INDEX))
10196                   let FILTERPOSITION+=LEN(FILTERCAPTION$(INDEX))+1
10197                   let FILTERVALSUBS(INDEX)=FNADDOBJECT(MAT IS$,MAT ID$,"1,"&STR$(FILTERPOSITION)&","&FILTERFORM$(INDEX),FILTERDEFAULTS$(INDEX))
10198                   let FILTERPOSITION+=FNLENGTHOF(FILTERFORM$(INDEX))+2
10199                   let FILTERSUBS(INDEX)=SUB
10200                end if 
10201             end if 
10202          next INDEX
10203       end if 
10204       for INDEX=1 to UDIM(MAT ELEMENT$)
10205          if LWRC$(TRIM$(ELEMENT$(INDEX))) = "columnsbutton" then ! #Select# Lwrc$(Trim$(Element$(Index))) #Case# "columnsbutton"
10206             let FNADDBUTTON(MAT OS$,MAT OD$,ROWS,COLS,55,"Columns")
10207          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "exportbutton" then ! #Case# "exportbutton"
10208             let FNADDBUTTON(MAT OS$,MAT OD$,ROWS,COLS,56,"Export")
10209          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "importbutton" then ! #Case# "importbutton"
10210             if EDIT then let FNADDBUTTON(MAT OS$,MAT OD$,ROWS,COLS,57,"Import")
10211          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "addbutton" then ! #Case# "addbutton"
10212             if EDIT then let FNADDBUTTON(MAT OS$,MAT OD$,ROWS,COLS,15,"Add")
10213          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "savebutton" then ! #Case# "savebutton"
10214             if EDIT then let FNADDBUTTON(MAT OS$,MAT OD$,ROWS,COLS,5,"Save (F5)")
10215          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "deletebutton" then ! #Case# "deletebutton"
10216             if EDIT then let FNADDBUTTON(MAT OS$,MAT OD$,ROWS,COLS,16,"Delete")
10217          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "keybutton" then ! #Case# "keybutton"
10218             let FNADDBUTTON(MAT OS$,MAT OD$,ROWS,COLS,4,"Jump (F4)")
10219          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "quitbutton" then ! #Case# "quitbutton"
10220             let FNADDBUTTON(MAT OS$,MAT OD$,ROWS,COLS,54,"Quit")
10221          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "search" then ! #Case# "search"
10222             if EXISTS("images\search.png") then 
10223                let SEARCHSUB=FNADDOBJECT(MAT IS$,MAT ID$,STR$(FIRSTROW)&",3,SEARCH "&STR$(COLS-12)&",,2,1","")
10224                let FNADDOBJECT(MAT OS$,MAT OD$,STR$(FIRSTROW)&",1,P 1/2","images\search.png")
10225             else 
10226                let SEARCHSUB=FNADDOBJECT(MAT IS$,MAT ID$,STR$(FIRSTROW)&",1,SEARCH "&STR$(COLS-10)&",,2,1","")
10227             end if 
10228             let FNADDOBJECT(MAT OS$,MAT OD$,STR$(FIRSTROW)&","&STR$(COLS-8)&",CC 8,,B70","Refresh")
10229             let O_SEARCH=1
10230          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "border" then ! #Case# "border"
10231             let O_BORDER=1
10232          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "caption" then ! #Case# "caption"
10233             let O_CAPTION=1
10234             let O_BORDER=1
10235          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "recl" then ! #Case# "recl"
10236             let O_RECL=1
10237             let O_CAPTION=1
10238             let O_BORDER=1
10239          else if LWRC$(TRIM$(ELEMENT$(INDEX))) = "position" then ! #Case# "position"
10240             let O_POSITION=1
10241          end if  ! #End Select#
10242       next INDEX
10243 ! 
10244       if EDIT then 
10245          let FNADDOBJECT(MAT IS$,MAT ID$,STR$(FIRSTROW+O_SEARCH)&",1,GRID "&STR$(ROWS-((FIRSTROW-1)+O_SEARCH+FNBUTTONROWS))&"/"&STR$(COLS)&",ROWCNT,CHG","")
10246          let GRIDSPEC$=STR$(FIRSTROW+O_SEARCH)&",1,GRID "&STR$(ROWS-((FIRSTROW-1)+O_SEARCH+FNBUTTONROWS))&"/"&STR$(COLS)
10247       else 
10248          let FNADDOBJECT(MAT IS$,MAT ID$,STR$(FIRSTROW+O_SEARCH)&",1,LIST "&STR$(ROWS-((FIRSTROW-1)+O_SEARCH+FNBUTTONROWS))&"/"&STR$(COLS)&",ROWSUB,SELONE","")
10249          let GRIDSPEC$=STR$(FIRSTROW+O_SEARCH)&",1,LIST "&STR$(ROWS-((FIRSTROW-1)+O_SEARCH+FNBUTTONROWS))&"/"&STR$(COLS)
10250       end if 
10251       mat ID$(UDIM(MAT ID$)-1) ! Remove Data Element For List; It Has To Be Given As A Scalar
10252    fnend 
10253 ! 
10254    def FNPREPAREWINDOW(&SROW,&SCOL,&ROWS,&COLS,EDIT,MAT INCLUDEBUTTONS$,&CAPTION$,&GRIDSPEC$,MAT INPUTSPEC$,MAT OUTPUTSPEC$,MAT INPUTDATA$,MAT OUTPUTDATA$,&O_POSITION,MAT FILTERFIELDS$,MAT FILTERFORM$,MAT FILTERCOMPARE$,MAT FILTERCAPTION$,MAT FILTERDEFAULTS$,MAT FILTERSUBS,MAT FILTERVALSUBS,MAT COLUMNNAMES$,MAT FILTERKEY,&SEARCHSUB;___,O_CAPTION,O_BORDER,O_RECL)
10255       let FNPREPINCLUDEUI$(MAT INCLUDEBUTTONS$)
10256 ! 
10257       let FNCALCULATESIZE(SROW,SCOL,ROWS,COLS,EDIT,MAT INCLUDEBUTTONS$,MAT FILTERFIELDS$)
10258       let FNCLEARUI(MAT OUTPUTSPEC$,MAT INPUTSPEC$,MAT OUTPUTDATA$,MAT INPUTDATA$)
10259       let FNBUILDUI(MAT INCLUDEBUTTONS$,MAT OUTPUTSPEC$,MAT INPUTSPEC$,MAT OUTPUTDATA$,MAT INPUTDATA$,MAT FILTERFIELDS$,MAT FILTERFORM$,MAT FILTERCOMPARE$,MAT FILTERCAPTION$,MAT FILTERDEFAULTS$,MAT FILTERSUBS,MAT FILTERVALSUBS,MAT COLUMNNAMES$,MAT FILTERKEY,GRIDSPEC$,EDIT,ROWS,COLS,O_CAPTION,O_BORDER,O_RECL,O_POSITION,SEARCHSUB)
10260 ! 
10261 ! .   ! if setting recl or
10262       if CAPTION$="" AND O_CAPTION then let CAPTION$="View '"&FILELAY$&"' File"
10263       if O_RECL then let CAPTION$=CAPTION$&" ... Recl="&STR$(RLN(DATAFILE))
10264       if O_BORDER then 
10265          if LEN(CAPTION$) then let CAPTION$=CAPTION$&","
10266          let CAPTION$=CAPTION$&"Border=S"
10267       end if 
10268    fnend 
10269 ! 
10270    dim TEXTDISPLAY$*255
10271 ! 
10272    def FNPOPULATEGRID(WINDOW,GRIDSPEC$,LAYOUT$,KEYMATCH$*255,SEARCHMATCH$*255,MAT RECORDS,MAT INCLUDECOLUMNS$,MAT COLUMNNAMES$,RECORDSIZE,DATAFILE,MAT DC_DATA$,MAT DC_DATA,MAT DC_FORMS$,&SEARCHNOW$,MAT DC_RECORDS,MAT DC_DELETEROW,KEYNUMBER,&LASTREC$,DISPLAYSUB,&DISPLAYCONVERT$,MAT FILTERCOMPARE$,MAT FILTERSUBS,MAT FILTERVALSUBS,MAT FILTERKEY,MAT INPUTDATA$;___,SOMETHINGFOUND,OR_RECORDLOCATION,CLEARFLAG$*1,INDEX,ANIMATE,BINCLUDECOLUMNS,SUB,BRECORDS,RECPOINTER,STOPREADING,ACTION,TEMPKEY$*255,ROWCOUNT,LASTTIME)
10273       let ANIMATE=FNSETTINGS("animatedatacrawler")
10274       mat DC_OUTPUTROW$(0) : mat DC_RECORDS(0) : mat DC_DELETEROW(0)
10275       let CLEARFLAG$="="
10276       if ANIMATE then let FNPREPAREANIMATION
10277 ! 
10278       let RECORDSIZE=UDIM(MAT WIDTHS)
10279 ! 
10280       let BINCLUDECOLUMNS=(~FNISEMPTYS(MAT INCLUDECOLUMNS$))
10281       let BRECORDS=(~FNISEMPTY(MAT RECORDS))
10282 ! 
10283       if LEN(KEYMATCH$) AND KLN(DATAFILE)>0 then 
10284          let KEYMATCH$=RTRM$(KEYMATCH$(1:KLN(DATAFILE)))
10285          restore #DATAFILE, search>=KEYMATCH$: 
10286       end if 
10287 ! 
10288       do  ! Read Data
10289          let LASTTIME=TIMER
10290          do WHILE FILE(DATAFILE)<>10
10291             if BRECORDS then 
10292                let RECPOINTER+=1
10293                if RECPOINTER<=UDIM(MAT RECORDS) then 
10294                   read #DATAFILE, using DC_FORMS$(DATAFILE), rec=RECORDS(RECPOINTER), release: MAT DC_DATA$,MAT DC_DATA error Ignore
10295                else 
10296                   let STOPREADING=1
10297                end if 
10298             else 
10299                read #DATAFILE, using DC_FORMS$(DATAFILE),release: MAT DC_DATA$,MAT DC_DATA error Ignore
10300             end if 
10301 ! 
10302             if ~FILE(DATAFILE) AND ~STOPREADING then 
10303                let ACTION=FNPASSESFILTER(MAT DC_DATA$,MAT DC_DATA,MAT FILTERCOMPARE$,MAT FILTERVALSUBS,MAT FILTERSUBS,MAT INPUTDATA$,MAT FILTERKEY)
10304                if ACTION=1 then 
10305                   if ~LEN(KEYMATCH$) OR KEYMATCH$=FNBUILDKEY$(LAYOUT$,MAT DC_DATA$,MAT DC_DATA,KEYNUMBER)(1:LEN(KEYMATCH$)) then 
10306                      if ~LEN(SEARCHMATCH$) OR FNSEARCHIN(SEARCHMATCH$,MAT DC_DATA$,MAT DC_DATA) then 
10307                         if ~LEN(SEARCHNOW$) OR FNSEARCHIN(SEARCHNOW$,MAT DC_DATA$,MAT DC_DATA) then 
10308                            let ROWCOUNT+=1
10309                            let SOMETHINGFOUND=1
10310                            let OR_RECORDLOCATION=UDIM(MAT DC_OUTPUTROW$)
10311                            mat DC_OUTPUTROW$(UDIM(DC_OUTPUTROW$)+RECORDSIZE) ! Add Room
10312                            mat DC_DELETEROW(UDIM(MAT DC_RECORDS) + 1) ! Add Row To Delete From
10313                            mat DC_RECORDS(UDIM(MAT DC_RECORDS) + 1)
10314                            let DC_RECORDS(UDIM(MAT DC_RECORDS))=REC(DATAFILE) ! Save Record Number For Later
10315 ! 
10316                            if BINCLUDECOLUMNS then 
10317                               for INDEX=1 to UDIM(MAT INCLUDECOLUMNS$)
10318                                  let SUB=SRCH(MAT COLUMNNAMES$,INCLUDECOLUMNS$(INDEX))
10319                                  if SUB>UDIM(MAT DC_DATA$) then 
10320                                     let DC_OUTPUTROW$(OR_RECORDLOCATION+INDEX)=STR$(DC_DATA(SUB-UDIM(MAT DC_DATA$)))
10321                                  else if SUB>0 then 
10322                                     let DC_OUTPUTROW$(OR_RECORDLOCATION+INDEX)=DC_DATA$(SUB)
10323                                  end if 
10324                               next INDEX
10325                            else 
10326                               if UDIM(MAT DC_DATA$) then ! Copy Strings
10327                                  mat DC_OUTPUTROW$(OR_RECORDLOCATION+1:OR_RECORDLOCATION+UDIM(MAT DC_DATA$))=DC_DATA$
10328                               end if 
10329                               for INDEX=1 to UDIM(MAT DC_DATA) ! Copy Numerics
10330                                  let DC_OUTPUTROW$(OR_RECORDLOCATION+INDEX+UDIM(MAT DC_DATA$))=STR$(DC_DATA(INDEX))
10331                               next INDEX
10332                            end if 
10333                         end if 
10334                      end if 
10335                   else 
10336                      let STOPREADING=1
10337                   end if 
10338                else if ACTION<0 then 
10339                   let ACTION=ACTION*-1
10340 ! 
10341                   mat FILTERF$(UDIM(MAT DC_DATA$))=("")
10342                   mat FILTERF(UDIM(MAT DC_DATA))=(0)
10343 ! 
10344 ! .               ! take the filter that failed
10345                   if FILTERSUBS(ACTION)>UDIM(MAT FILTERF$) then ! Use Filter To Find The Subscript
10346                      let FILTERF(FILTERSUBS(ACTION)-UDIM(MAT FILTERF$))=VAL(INPUTDATA$(FILTERVALSUBS(ACTION))) conv Ignore
10347                   else 
10348                      let FILTERF$(FILTERSUBS(ACTION))=INPUTDATA$(FILTERVALSUBS(ACTION))
10349                   end if 
10350 ! 
10351 ! .               ! use subscript to build an empty f$ and f with the data
10352 ! .               ! use fnBuildKey$ and Keynum
10353                   if KLN(DATAFILE)>0 AND ~FNISEMPTY(MAT FILTERF) OR ~FNISEMPTYS(MAT FILTERF$) then 
10354                      let TEMPKEY$=FNBUILDKEY$(LAYOUT$,MAT FILTERF$,MAT FILTERF,KEYNUMBER)
10355                      restore #DATAFILE, search>=TRIM$(TEMPKEY$): nokey Stopreading
10356                   end if 
10357                else if ACTION=2 then 
10358 Stopreading:      let STOPREADING=1 ! Dont Like It But Its The Simplest Way To Do It In This Language.
10359                end if 
10360                if ANIMATE then 
10361                   let TEXTDISPLAY$=""
10362                   if DISPLAYSUB then 
10363                      if DISPLAYSUB<0 then 
10364                         let TEXTDISPLAY$=STR$(REC(DATAFILE))
10365                      else if DISPLAYSUB<=UDIM(MAT DC_DATA$) then 
10366                         let TEXTDISPLAY$=TRIM$(DC_DATA$(DISPLAYSUB))
10367                      else 
10368                         if ~LEN(DISPLAYCONVERT$) then 
10369                            let TEXTDISPLAY$=STR$(DC_DATA(DISPLAYSUB-UDIM(MAT DC_DATA$)))
10370                         else 
10371                            let TEXTDISPLAY$=CNVRT$(DISPLAYCONVERT$,DC_DATA(DISPLAYSUB-UDIM(MAT DC_DATA$))) conv Ignore
10372                         end if 
10373                      end if 
10374                   end if 
10375                   if LEN(TRIM$(LASTREC$)) then 
10376                      if LEN(TEXTDISPLAY$) then let TEXTDISPLAY$=TEXTDISPLAY$&" of "
10377                      let TEXTDISPLAY$=TEXTDISPLAY$&LASTREC$
10378                   end if 
10379 ! 
10380                   let FNANIMATE(TEXTDISPLAY$)
10381                end if 
10382             end if 
10383          loop UNTIL STOPREADING OR ((X$:=UNHEX$(KSTAT$))="6300") OR UDIM(MAT DC_OUTPUTROW$)+RECORDSIZE>1000 OR (UDIM(MAT DC_OUTPUTROW$) AND ROWCOUNT<=20 AND (TIMER-LASTTIME>2))
10384 ! 
10385          print #WINDOW, fields GRIDSPEC$&","&CLEARFLAG$ : MAT DC_OUTPUTROW$
10386          mat DC_OUTPUTROW$(0) ! Clear Already Used Data To Go Back For More
10387          let CLEARFLAG$="+"
10388       loop UNTIL STOPREADING OR FILE(DATAFILE)=10 OR X$="6300" ! Until Eof Or Abort
10389 ! 
10390       if ANIMATE then let FNCLOSEANIMATION
10391       let FNPOPULATEGRID=SOMETHINGFOUND
10392    fnend 
10393 ! 
10394    def FNPASSESFILTER(MAT DC_DATA$,MAT DC_DATA,MAT FILTERCOMPARE$,MAT FILTERVALSUBS,MAT FILTERSUBS,MAT INPUTDATA$,MAT FILTERKEY;___,INDEX,PASSING)
10395       let PASSING=1 ! Give It A Fighting Chance (In Case There Are No Filters)
10396       do WHILE (INDEX:=INDEX+1)<=UDIM(MAT FILTERSUBS)
10397          if FILTERSUBS(INDEX)>0 then 
10398             if LEN(FILTERCOMPARE$(INDEX)) then 
10399                let PASSING=0
10400                if POS(FILTERCOMPARE$(INDEX),"*") then ! Fuzzy Search
10401                   if FILTERSUBS(INDEX)>UDIM(MAT DC_DATA$) then 
10402                      if LEN(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) AND FNISNUMBER(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) then 
10403                         if POS(STR$(DC_DATA(FILTERSUBS(INDEX)-UDIM(MAT DC_DATA$))),TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) then 
10404 ! .                        ! It passes this filter
10405                            let PASSING=1
10406                         else 
10407 ! .                        ! Failed numeric filter test
10408                         end if 
10409                      else 
10410                         let PASSING=1
10411                      end if 
10412                   else 
10413                      if LEN(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) then 
10414                         if POS(DC_DATA$(FILTERSUBS(INDEX)),TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) then 
10415 ! .                        ! It passes this filter
10416                            let PASSING=1
10417                         else 
10418 ! .                        ! Failed numeric filter test
10419                         end if 
10420                      else 
10421                         let PASSING=1
10422                      end if 
10423                   end if 
10424                end if 
10425                if POS(FILTERCOMPARE$(INDEX),">") then 
10426                   if FILTERSUBS(INDEX)>UDIM(MAT DC_DATA$) then 
10427                      if LEN(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) AND FNISNUMBER(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) then 
10428                         if DC_DATA(FILTERSUBS(INDEX)-UDIM(MAT DC_DATA$))>VAL(INPUTDATA$(FILTERVALSUBS(INDEX))) then 
10429 ! .                        ! It passes this filter
10430                            let PASSING=1
10431                         else 
10432 ! .                        ! Failed numeric filter test
10433                         end if 
10434                      else 
10435                         let PASSING=1
10436                      end if 
10437                   else 
10438                      if LEN(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) then 
10439                         if DC_DATA$(FILTERSUBS(INDEX))>INPUTDATA$(FILTERVALSUBS(INDEX)) then 
10440 ! .                        ! It passes this filter
10441                            let PASSING=1
10442                         else 
10443 ! .                        ! Failed numeric filter test
10444                         end if 
10445                      else 
10446                         let PASSING=1
10447                      end if 
10448                   end if 
10449                end if 
10450                if POS(FILTERCOMPARE$(INDEX),"<") then 
10451                   if FILTERSUBS(INDEX)>UDIM(MAT DC_DATA$) then 
10452                      if LEN(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) AND FNISNUMBER(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) then 
10453                         if DC_DATA(FILTERSUBS(INDEX)-UDIM(MAT DC_DATA$))<VAL(INPUTDATA$(FILTERVALSUBS(INDEX))) then 
10454 ! .                        ! It passes this filter
10455                            let PASSING=1
10456                         else 
10457 ! .                        ! Failed numeric filter test
10458                         end if 
10459                      else 
10460                         let PASSING=1
10461                      end if 
10462                   else 
10463                      if LEN(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) then 
10464                         if DC_DATA$(FILTERSUBS(INDEX))<INPUTDATA$(FILTERVALSUBS(INDEX)) then 
10465 ! .                        ! It passes this filter
10466                            let PASSING=1
10467                         else 
10468 ! .                        ! Failed numeric filter test
10469                         end if 
10470                      else 
10471                         let PASSING=1
10472                      end if 
10473                   end if 
10474                end if 
10475                if POS(FILTERCOMPARE$(INDEX),"=") then 
10476                   if FILTERSUBS(INDEX)>UDIM(MAT DC_DATA$) then 
10477                      if LEN(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) AND FNISNUMBER(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) then 
10478                         if DC_DATA(FILTERSUBS(INDEX)-UDIM(MAT DC_DATA$))=VAL(INPUTDATA$(FILTERVALSUBS(INDEX))) then 
10479 ! .                        ! It passes this filter
10480                            let PASSING=1
10481                         else 
10482 ! .                        ! Failed numeric filter test
10483                         end if 
10484                      else 
10485                         let PASSING=1
10486                      end if 
10487                   else 
10488                      if LEN(TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX)))) then 
10489                         if TRIM$(DC_DATA$(FILTERSUBS(INDEX)))=TRIM$(INPUTDATA$(FILTERVALSUBS(INDEX))) then 
10490 ! .                        ! It passes this filter
10491                            let PASSING=1
10492                         else 
10493 ! .                        ! Failed numeric filter test
10494                         end if 
10495                      else 
10496                         let PASSING=1
10497                      end if 
10498                   end if 
10499                end if 
10500             end if 
10501          end if 
10502       loop WHILE PASSING
10503 ! 
10504 ! .   ! Index will be the one it failed on if it failed
10505       if ~PASSING then ! Check Filter Key And Return Action
10506          if FILTERKEY(INDEX)=1 then 
10507             let PASSING=INDEX*-1
10508          else if FILTERKEY(INDEX)=-1 then 
10509             let PASSING=2
10510          end if 
10511       end if 
10512 ! 
10513       let FNPASSESFILTER=PASSING
10514    fnend 
10515 ! 
10516    dim GRIDSPEC$*60
10517    dim OUTPUTSPEC$(1)*60
10518    dim OUTPUTDATA$(1)
10519    dim INPUTSPEC$(1)*60
10520    dim INPUTDATA$(1)*255
10521    dim WIDTHS(1)
10522    dim DESCRIPTION$(1)*255
10523    dim COLUMNNAMES$(1)*255
10524 ! 
10525    dim FILTERSUBS(1)
10526    dim FILTERVALSUBS(1)
10527 ! 
10528    dim INCLUDECOLUMNS$(1)
10529    dim INCLUDEBUTTONS$(1)
10530    dim FIELDPOSITIONS(1)
10531 ! 
10532    dim LASTREC$*255
10533    dim DISPLAYFIELDCONVERT$*255
10534 ! 
10535    def library FNSHOWDATA(FILELAY$;EDIT,SROW,SCOL,ROWS,COLS,KEYNUMBER,CAPTION$*127,PATH$*255,KEYMATCH$*255,SEARCHMATCH$*255,CALLINGPROGRAM$*255,MAT RECORDS,MAT INCLUDECOLS$,MAT INCLUDEUI$,MAT COLUMNDESCRIPTION$,MAT COLUMNWIDTHS,MAT COLUMNFORMS$,DISPLAYFIELD$*80,MAT FILTERFIELDS$,MAT FILTERFORM$,MAT FILTERCOMPARE$,MAT FILTERCAPTION$,MAT FILTERDEFAULTS$,MAT FILTERKEY,___,WINDOW,INDEX,X$,KEY,KEY$,ROWCOUNT,SHOULDSAVE,SAVEINDEX,SAVELOOP,SAVERECORDSUB,RECORDSIZE,DELETEINDEX,REBUILDCOLOR,CHANGEDROWCOUNT,OLDCHANGEDDATASIZE,OLDCHANGEDSUBSSIZE,SOMETHINGFOUND,LOGGING,ANIMATE,INPUTFLAG,SUB,INCLUDECOL,TESTCONVERT,RECORDNUM,O_POSITION,DISPLAYSUB,SEARCHSUB,ALREADYWARNED)
10536       library : FNGETFILENUMBER, FNOPENFILE, FNCLOSEFILE, FNREADLAYOUTARRAYS, FNBUILDKEY$, FNSETLOGCHANGES, FNLOGCHANGES, FNLOG, FNLOGARRAY
10537 ! 
10538       mat FILTERSUBS(0)
10539       mat FILTERVALSUBS(0)
10540 ! 
10541       if CALLINGPROGRAM$="" then let CALLINGPROGRAM$="FileIO's fnShowData"
10542       let LOGGING=FNSETTINGS("createlogfile")
10543 ! 
10544       if LOGGING then 
10545          if EDIT then 
10546             let FNLOG("Edit "&TRIM$(FILELAY$)&" file.",CALLINGPROGRAM$)
10547          else 
10548             let FNLOG("View "&TRIM$(FILELAY$)&" file.",CALLINGPROGRAM$)
10549          end if 
10550       end if 
10551 ! 
10552 ! .   ! Make copies of any optional arrays we need to change
10553 ! .   ! in case they aren't given and we can't change the original
10554       mat INCLUDECOLUMNS$(UDIM(MAT INCLUDECOLS$))=INCLUDECOLS$
10555       mat INCLUDEBUTTONS$(UDIM(MAT INCLUDEUI$))=INCLUDEUI$
10556       let SEARCHNOW$=""
10557 ! 
10558       if ~KEYNUMBER then let KEYNUMBER=-1 ! Default To Relative For Preformance
10559       if EDIT AND ~FN42 then let KEYNUMBER=1 ! Must Open Keyed Due To Bug In 4.1 And Earlier
10560 ! 
10561       let DATAFILE=FNOPEN(FILELAY$,MAT DC_DATA$,MAT DC_DATA,MAT DC_FORMS$,(~EDIT),KEYNUMBER,0,PATH$,MAT DC_DFDESCR$,MAT DC_WIDTHS)
10562 ! 
10563       if DATAFILE then 
10564 ! 
10565 ! .      ! Return field names to be used later when populating grid
10566          let FNGETFIELDNAMES(FILELAY$,MAT COLUMNNAMES$,MAT FIELDPOSITIONS)
10567 ! 
10568          let FNLWRCTHIS(MAT INCLUDECOLUMNS$)
10569          let FNLWRCTHIS(MAT INCLUDECOLS$)
10570          let FNLWRCTHIS(MAT COLUMNNAMES$)
10571 ! 
10572          let FNPREPAREWINDOW(SROW,SCOL,ROWS,COLS,EDIT,MAT INCLUDEBUTTONS$,CAPTION$,GRIDSPEC$,MAT INPUTSPEC$,MAT OUTPUTSPEC$,MAT INPUTDATA$,MAT OUTPUTDATA$,O_POSITION,MAT FILTERFIELDS$,MAT FILTERFORM$,MAT FILTERCOMPARE$,MAT FILTERCAPTION$,MAT FILTERDEFAULTS$,MAT FILTERSUBS,MAT FILTERVALSUBS,MAT COLUMNNAMES$,MAT FILTERKEY,SEARCHSUB)
10573 ! 
10574          open #(WINDOW:=FNGETFILENUMBER) : "sRow="&STR$(SROW)&",sCol="&STR$(SCOL)&",Rows="&STR$(ROWS)&",Cols="&STR$(COLS)&",Caption="&CAPTION$,display,outin 
10575 ! 
10576          print #WINDOW, fields MAT OUTPUTSPEC$ : MAT OUTPUTDATA$
10577 ! 
10578          do  ! Whole Thing
10579 ! 
10580             let LASTREC$=DISPLAYFIELD$
10581             if LEN(DISPLAYFIELD$) then 
10582                if LWRC$(DISPLAYFIELD$)="rec" then 
10583                   let LASTREC$=STR$(LREC(DATAFILE))
10584                   let DISPLAYSUB=-1
10585                else 
10586                   if (SUB:=SRCH(MAT COLUMNNAMES$,LWRC$(TRIM$(DISPLAYFIELD$))))>0 then 
10587                      let DISPLAYSUB=SUB
10588                   end if 
10589                end if 
10590             end if 
10591 ! 
10592             let FNCALCULATEFIELDFORMS(FILELAY$,MAT COLUMNNAMES$,MAT FIELDFORMS$,MAT WIDTHS,MAT DESCRIPTION$,MAT DC_WIDTHS,MAT DC_DFDESCR$,MAT INCLUDECOLUMNS$,MAT INCLUDECOLS$,MAT COLUMNDESCRIPTION$,MAT COLUMNWIDTHS,MAT COLUMNFORMS$,MAT FIELDPOSITIONS,O_POSITION,DISPLAYSUB,DISPLAYFIELDCONVERT$)
10593 ! 
10594             if DISPLAYSUB>0 then 
10595 ! 
10596                read #DATAFILE, using DC_FORMS$(DATAFILE), LAST : MAT DC_DATA$, MAT DC_DATA error Ignore
10597 ! 
10598                if FILE(DATAFILE)=0 then 
10599 ! 
10600                   if DISPLAYSUB>UDIM(MAT DC_DATA$) then 
10601                      if DISPLAYSUB<=UDIM(MAT DC_DATA$)+UDIM(MAT DC_DATA) then 
10602                         if ~LEN(DISPLAYFIELDCONVERT$) then 
10603                            let LASTREC$=STR$(DC_DATA(DISPLAYSUB-UDIM(MAT DC_DATA$)))
10604                         else 
10605                            let LASTREC$=CNVRT$(DISPLAYFIELDCONVERT$,DC_DATA(DISPLAYSUB-UDIM(MAT DC_DATA$))) conv Ignore
10606                         end if 
10607                      end if 
10608                   else 
10609                      let LASTREC$=DC_DATA$(DISPLAYSUB)
10610                   end if 
10611                end if 
10612             end if 
10613 ! 
10614             let RECORDSIZE=UDIM(MAT WIDTHS)
10615             let COLSCHANGED=0
10616             mat DC_BLANK$(RECORDSIZE)
10617             print #WINDOW, fields GRIDSPEC$&",HEADERS" : (MAT DESCRIPTION$,MAT WIDTHS,MAT FIELDFORMS$)
10618 ! 
10619             let CHANGEDROWCOUNT=0 : mat DC_CHANGEDDATA$(0) : mat DC_CHANGEDSUBS(0)
10620 ! 
10621             restore #DATAFILE: 
10622             if KLN(DATAFILE)>0 AND TRIM$(KEY$)<>"" then 
10623                restore #DATAFILE, search>=TRIM$(KEY$): nokey Clearkey
10624             end if 
10625             if RECORDNUM then 
10626                restore #DATAFILE, rec=RECORDNUM: norec Clearrec
10627             end if 
10628 ! 
10629             let SOMETHINGFOUND=FNPOPULATEGRID(WINDOW,GRIDSPEC$,FILELAY$,KEYMATCH$,SEARCHMATCH$,MAT RECORDS,MAT INCLUDECOLUMNS$,MAT COLUMNNAMES$,RECORDSIZE,DATAFILE,MAT DC_DATA$,MAT DC_DATA,MAT DC_FORMS$,SEARCHNOW$,MAT DC_RECORDS,MAT DC_DELETEROW,KEYNUMBER,LASTREC$,DISPLAYSUB,DISPLAYFIELDCONVERT$,MAT FILTERCOMPARE$,MAT FILTERSUBS,MAT FILTERVALSUBS,MAT FILTERKEY,MAT INPUTDATA$)
10630             let ALREADYWARNED=0
10631 ! 
10632             print #WINDOW, fields MAT INPUTSPEC$(1:UDIM(MAT INPUTSPEC$)-1) : MAT INPUTDATA$
10633 ! 
10634             do  ! Input Data
10635                if REBUILDCOLOR then gosub Updatecolors
10636                if SOMETHINGFOUND then 
10637                   if UDIM(MAT INPUTDATA$) then 
10638                      input #WINDOW, fields MAT INPUTSPEC$ : MAT INPUTDATA$, ROWCOUNT
10639                   else 
10640                      input #WINDOW, fields MAT INPUTSPEC$ : ROWCOUNT
10641                   end if 
10642                   let KEY=FKEY
10643                   if KEY=54 then let KEY=99
10644                else 
10645                   if EDIT AND (2==MSGBOX("There is no data in the file, or no records match the current search criteria. Would you like to add a row?","File Empty","YN","EXCL")) then 
10646                      let KEY=15 ! Add A Row
10647                      let SOMETHINGFOUND=1
10648                   else 
10649                      if ~ALREADYWARNED then let MSGBOX("Data File is Empty or no records match the current search criteria.","File Empty") : let ALREADYWARNED=1
10650                      if UDIM(MAT INPUTDATA$) then 
10651                         input #WINDOW, fields MAT INPUTSPEC$(1:UDIM(MAT INPUTSPEC$)-1) : MAT INPUTDATA$
10652                         let KEY=FKEY
10653                         if KEY=54 then let KEY=99
10654                      else 
10655                         let KEY=99
10656                      end if 
10657                   end if 
10658                end if 
10659                let SHOULDSAVE=0
10660 ! 
10661                if KEY = 15 AND EDIT then ! #Select# Key #Case# 15 And Edit
10662                   if ROWCOUNT then ! If There Are Already Changes Made, Save Them To Backup Arrays
10663                      mat DC_SAVEDATA$(RECORDSIZE*ROWCOUNT) ! Make Room
10664                      mat DC_SAVESUBS(ROWCOUNT) ! Make Room
10665                      mat DC_CHANGEDDATA$((OLDCHANGEDDATASIZE:=UDIM(DC_CHANGEDDATA$)) + UDIM(DC_SAVEDATA$))
10666                      mat DC_CHANGEDSUBS((OLDCHANGEDSUBSSIZE:=UDIM(DC_CHANGEDSUBS)) + UDIM(DC_SAVESUBS))
10667                      input #WINDOW, fields GRIDSPEC$&",ROWSUB,CHG,NOWAIT" : MAT DC_SAVESUBS
10668                      input #WINDOW, fields GRIDSPEC$&",ROW,CHG,NOWAIT" : MAT DC_SAVEDATA$
10669                      mat DC_CHANGEDDATA$(OLDCHANGEDDATASIZE+1:UDIM(DC_CHANGEDDATA$)) = DC_SAVEDATA$
10670                      mat DC_CHANGEDSUBS(OLDCHANGEDSUBSSIZE+1:UDIM(DC_CHANGEDSUBS)) = DC_SAVESUBS
10671                      let CHANGEDROWCOUNT=UDIM(MAT DC_CHANGEDSUBS)
10672                   end if 
10673                   print #WINDOW, fields GRIDSPEC$&",+" : MAT DC_BLANK$ ! Add A Blank Row
10674                   mat DC_RECORDS(UDIM(MAT DC_RECORDS)+1)
10675                   mat DC_DELETEROW(UDIM(MAT DC_RECORDS))
10676                   let CURFLD(1,((UDIM(MAT DC_RECORDS)-1)*RECORDSIZE) + 1)
10677 ! 
10678                else if KEY = 16 AND EDIT then ! #Case# 16 And Edit
10679                   let DC_DELETEROW(CURROW)=DC_DELETEROW(CURROW)+1 ! Toggle Deleted
10680                   let REBUILDCOLOR = 1
10681 ! 
10682                else if KEY = 55 then ! #Case# 55
10683                   if CHANGEDROWCOUNT OR (EDIT AND ROWCOUNT) OR SUM(MAT DC_DELETEROW) then let NEEDSSAVE=1 else let NEEDSSAVE=0
10684                   let COLSCHANGED=FNSELECTDATACRAWLERCOLS(MAT DC_DFDESCR$,MAT INCLUDECOLUMNS$,MAT COLUMNNAMES$,ROWS,COLS,NEEDSSAVE)
10685                   if COLSCHANGED = 2 then let SHOULDSAVE = 2
10686 ! 
10687                else if KEY = 56 then ! #Case# 56
10688                   let FNCSVEXPORTDLG(FILELAY$,MAT COLUMNNAMES$,ROWS,COLS,KEYNUMBER,KEY$,RECORDNUM,MAT RECORDS,SEARCHMATCH$,KEYMATCH$,SEARCHNOW$)
10689                else if KEY = 57 AND EDIT then ! #Case# 57 And Edit
10690                   let FNCSVIMPORTDLG(FILELAY$,MAT COLUMNNAMES$,ROWS,COLS)
10691 ! 
10692                else if KEY = 4 OR KEY = 99 OR KEY = 93 OR KEY = 70 then ! #Case# 4 # 99 # 93 # 70
10693                   if EDIT AND (CHANGEDROWCOUNT OR ROWCOUNT OR SUM(MAT DC_DELETEROW)) then 
10694                      let SHOULDSAVE=MSGBOX("All unsaved changes will be lost. Do you want to Save first?","Search Warning","YNC","EXCL")
10695                   end if 
10696                end if  ! #End Select#
10697             loop UNTIL ((KEY=99 OR KEY=93 OR KEY=4 OR KEY=70) AND SHOULDSAVE<>4) OR KEY=5 OR KEY=57 OR (KEY=55 AND COLSCHANGED) ! F4 Changes Settings, F5 Saves Settings, 70 Is Search, Needs To Redraw
10698 ! 
10699             if EDIT AND (KEY=5 OR SHOULDSAVE=2) then gosub Savechangeddata
10700 ! 
10701             if KEY=4 then let FNINPUTKEY(KEY$,RECORDNUM,DATAFILE,ROWS,COLS,WINDOW)
10702 ! 
10703             if KEY=70 then 
10704                let SEARCHNOW$=TRIM$(INPUTDATA$(SEARCHSUB)) ! If There's a search box, its always first cause the grids always last so this should work but it would be better to use a subscript.
10705 ! .            ! let InputData$(SearchSub)=""
10706             end if 
10707 ! 
10708          loop UNTIL KEY=99 OR KEY=93 OR FKEY=93
10709 ! 
10710          if EDIT then let INPUTFLAG=1 else let INPUTFLAG=-1
10711          let FNCLOSEFILE(DATAFILE,FILELAY$,PATH$,INPUTFLAG)
10712          if LOGGING then let FNLOG("Close "&TRIM$(FILELAY$)&" file.",CALLINGPROGRAM$)
10713       end if 
10714       close #WINDOW: 
10715    fnend 
10716 ! 
10717 Clearkey: ! Invalid Key Entered
10718    let MSGBOX("Key Not Found")
10719    let KEY$=""
10720    continue 
10721 ! 
10722 Clearrec: ! Invalid Record Entered
10723    let MSGBOX("Record not found")
10724    let RECORDNUM=0
10725    continue 
10726 ! 
10727 Tryagain: ! Try Again
10728    if FKEY=99 OR FKEY=93 then 
10729       continue 
10730    else 
10731       retry 
10732    end if 
10733 ! 
10734 Deconversionfailed: ! Conversion Failed Saving Numeric Field
10735    let TESTCONVERT=DC_DATA(SUB-UDIM(MAT DC_DATA$)) ! Keep Existing Value, New Value Failed
10736    continue 
10737 ! 
10738 Savechangeddata: ! Save All The Changed Records In The Data Crawler
10739 ! 
10740    if (~FNISEMPTYS(MAT INCLUDECOLUMNS$)) then let INCLUDECOL=1
10741 ! .! Save Prerecorded Changes
10742    for SAVELOOP = 1 to CHANGEDROWCOUNT
10743       let SAVERECORDSUB=((SAVELOOP-1)*RECORDSIZE)
10744       if DC_DELETEROW(DC_CHANGEDSUBS(SAVELOOP))=0 then ! Skip It If Its Deleted
10745          mat DC_DATA$=("") : mat DC_DATA=(0)
10746          if DC_RECORDS(DC_CHANGEDSUBS(SAVELOOP)) then 
10747             read #DATAFILE, using DC_FORMS$(DATAFILE), rec=DC_RECORDS(DC_CHANGEDSUBS(SAVELOOP)) : MAT DC_DATA$, MAT DC_DATA
10748             if LOGGING then let FNSETLOGCHANGES(MAT DC_DATA$,MAT DC_DATA)
10749          end if 
10750 ! 
10751 !        Convert Strings Back To Numbers And Assign Back To File Arrays
10752          for SAVEINDEX=1 to RECORDSIZE
10753             if INCLUDECOL then 
10754                let SUB=SRCH(MAT COLUMNNAMES$,INCLUDECOLUMNS$(SAVEINDEX))
10755             else 
10756                let SUB=SAVEINDEX
10757             end if 
10758 ! 
10759             if SUB>UDIM(MAT DC_DATA$) then 
10760                let TESTCONVERT=VAL(DC_CHANGEDDATA$(SAVERECORDSUB+SAVEINDEX)) conv Deconversionfailed
10761                let DC_DATA(SUB-UDIM(MAT DC_DATA$))=TESTCONVERT
10762             else if SUB>0 then 
10763                let DC_DATA$(SUB)=DC_CHANGEDDATA$(SAVERECORDSUB+SAVEINDEX)
10764             end if 
10765          next SAVEINDEX
10766 ! 
10767 !        Save The Data
10768          if DC_RECORDS(DC_CHANGEDSUBS(SAVELOOP)) then 
10769             rewrite #DATAFILE, using DC_FORMS$(DATAFILE) : MAT DC_DATA$, MAT DC_DATA
10770             if LOGGING then let FNLOGCHANGES(MAT DC_DATA$,MAT DC_DATA,"Update """&FILELAY$&""" Record: "&STR$(REC(DATAFILE)),CALLINGPROGRAM$,FILELAY$)
10771          else 
10772             write #DATAFILE, using DC_FORMS$(DATAFILE) : MAT DC_DATA$, MAT DC_DATA
10773             if LOGGING then let FNLOGARRAY(MAT DC_DATA$,MAT DC_DATA,"Write """&FILELAY$&""" Record: "&STR$(REC(DATAFILE))&" Data: ",CALLINGPROGRAM$)
10774          end if 
10775       end if 
10776    next SAVELOOP
10777 ! 
10778 !  Save New Changes
10779    mat DC_SAVEDATA$(RECORDSIZE*ROWCOUNT) ! Make Room
10780    mat DC_SAVESUBS(ROWCOUNT) ! Make Room
10781    input #WINDOW, fields GRIDSPEC$&",ROWSUB,CHG,NOWAIT" : MAT DC_SAVESUBS
10782    input #WINDOW, fields GRIDSPEC$&",ROW,CHG,NOWAIT" : MAT DC_SAVEDATA$
10783 ! 
10784 !  One Record At A Time
10785    for SAVELOOP = 1 to ROWCOUNT
10786       let SAVERECORDSUB=((SAVELOOP-1)*RECORDSIZE)
10787       if DC_DELETEROW(DC_SAVESUBS(SAVELOOP))=0 then ! Skip It If Its Deleted
10788          mat DC_DATA$=("") : mat DC_DATA=(0)
10789          if DC_RECORDS(DC_SAVESUBS(SAVELOOP)) then 
10790             read #DATAFILE, using DC_FORMS$(DATAFILE), rec=DC_RECORDS(DC_SAVESUBS(SAVELOOP)) : MAT DC_DATA$, MAT DC_DATA
10791             if LOGGING then let FNSETLOGCHANGES(MAT DC_DATA$,MAT DC_DATA)
10792          end if 
10793 ! 
10794          for SAVEINDEX=1 to RECORDSIZE
10795             if INCLUDECOL then 
10796                let SUB=SRCH(MAT COLUMNNAMES$,INCLUDECOLUMNS$(SAVEINDEX))
10797             else 
10798                let SUB=SAVEINDEX
10799             end if 
10800 ! 
10801             if SUB>UDIM(MAT DC_DATA$) then 
10802                let TESTCONVERT=VAL(DC_SAVEDATA$(SAVERECORDSUB+SAVEINDEX)) conv Deconversionfailed
10803                let DC_DATA(SUB-UDIM(MAT DC_DATA$))=TESTCONVERT
10804             else if SUB>0 then 
10805                let DC_DATA$(SUB)=DC_SAVEDATA$(SAVERECORDSUB+SAVEINDEX)
10806             end if 
10807          next SAVEINDEX
10808 ! 
10809 !        Save The Data
10810          if DC_RECORDS(DC_SAVESUBS(SAVELOOP)) then 
10811             rewrite #DATAFILE, using DC_FORMS$(DATAFILE) : MAT DC_DATA$, MAT DC_DATA
10812             if LOGGING then let FNLOGCHANGES(MAT DC_DATA$,MAT DC_DATA,"Update """&FILELAY$&""" Record: "&STR$(REC(DATAFILE)),CALLINGPROGRAM$,FILELAY$)
10813          else 
10814             write #DATAFILE, using DC_FORMS$(DATAFILE) : MAT DC_DATA$, MAT DC_DATA
10815             if LOGGING then let FNLOGARRAY(MAT DC_DATA$,MAT DC_DATA,"Write """&FILELAY$&""" Record: "&STR$(REC(DATAFILE))&" Data: ",CALLINGPROGRAM$)
10816          end if 
10817       end if 
10818    next SAVELOOP
10819 ! 
10820 ! .! Delete the records that need to be deleted
10821    for DELETEINDEX=1 to UDIM(MAT DC_DELETEROW)
10822       if DC_DELETEROW(DELETEINDEX) then 
10823          if DC_RECORDS(DELETEINDEX) then 
10824             delete #DATAFILE, rec=DC_RECORDS(DELETEINDEX): 
10825             if LOGGING then let FNLOG("Delete """&FILELAY$&""" Record: "&STR$(DC_RECORDS(DELETEINDEX)),CALLINGPROGRAM$)
10826          end if 
10827          let DC_DELETEROW(DELETEINDEX)=2 ! Clear Them To White Next Round
10828       end if 
10829    next DELETEINDEX
10830    if EDIT then gosub Updatecolors
10831    let MSGBOX("Update Complete!","Update")
10832    return 
10833 ! 
10834 Selectdatacrawlercols: ! **** Open Window To Select Display Columns For Data Crawler ****
10835    def FNSELECTDATACRAWLERCOLS(MAT FIELD_DESC$,MAT INCLUDECOLUMNS$,MAT COLUMNNAMES$,ROWS,COLS;NEEDSSAVE,___,SROW,SCOL,SCREENROWS,SCREENCOLS,ROW,COL,FK,CLOSEWINDOW,SHOULDSAVE,ITEMSPERPAGE,INDEX,JNDEX)
10836       dim INPUT_SPEC$(1)*255,INPUT_DATA$(1)*1000
10837 ! 
10838       let FNREADSCREENS(SCREENROWS,SCREENCOLS)
10839 ! 
10840 ! .   ! Grow to minimum reasonable size
10841       let ROWS=MAX(ROWS,8)
10842       let COLS=MAX(COLS,48)
10843 ! 
10844       let ROWS=MIN(SCREENROWS,ROWS)
10845       let COLS=MIN(SCREENCOLS,COLS)
10846 ! 
10847       mat INPUT_SPEC$(UDIM(MAT FIELD_DESC$))
10848       mat INPUT_DATA$(UDIM(MAT FIELD_DESC$))
10849 ! 
10850 ! .   ! Open main window
10851       let SROW=INT((SCREENROWS-ROWS) / 2) + 1
10852       let SCOL=INT((SCREENCOLS-COLS) / 2) + 1
10853 ! 
10854       open #(COLSEL_WINDOW:=FNGETFILENUMBER): "SROW="&STR$(SROW)&", SCOL="&STR$(SCOL)&", ROWS="&STR$(ROWS)&", COLS="&STR$(COLS),display,outin 
10855       print #COLSEL_WINDOW, fields STR$(ROWS)&","&STR$(COLS-22)&",CC 10,,B55" : "OK"
10856       print #COLSEL_WINDOW, fields STR$(ROWS)&","&STR$(COLS-10)&",CC 10,,B54" : "Cancel"
10857       print #COLSEL_WINDOW, fields STR$(ROWS)&","&STR$(COLS-34)&",CC 10,,B56" : "Select All"
10858       print #COLSEL_WINDOW, fields STR$(ROWS)&","&STR$(COLS-46)&",10/CC 11,,B57" : "Select None"
10859       if COLS>60 then 
10860          print #COLSEL_WINDOW, fields STR$(ROWS)&",2,"&STR$(COLS-49)&"/C 55" : "Choose data columns to display"
10861       end if 
10862 ! 
10863       dim COLSEL_TABS(1)
10864       dim TABATTR$*50
10865 ! 
10866       let ITEMSPERPAGE=(ROWS-4)*INT(COLS/19)
10867 ! 
10868       let ROW = 2
10869       let COL = 2
10870       let THISTAB = 0
10871       for INDEX = 1 to UDIM(MAT INPUT_SPEC$)
10872          if ROW = 2 AND COL = 2 then ! Open A Child Window
10873             let THISTAB+=1
10874             mat COLSEL_TABS(THISTAB)
10875             if UDIM(MAT INPUT_SPEC$) > ITEMSPERPAGE then let TABATTR$=", TAB=Page "&STR$(THISTAB) else let TABATTR$=", BORDER=S, CAPTION=Column List"
10876             open #(COLSEL_TABS(THISTAB):=FNGETFILENUMBER): "SROW=2, SCOL=2, ROWS="&STR$(ROWS-3)&", COLS="&STR$(COLS-2)&TABATTR$&", PARENT="&STR$(COLSEL_WINDOW),display,outin 
10877          end if 
10878 ! 
10879          let INPUT_SPEC$(INDEX)=STR$(ROW)&","&STR$(COL)&",18/check 1000,,"&STR$(1500+INDEX)
10880          let INPUT_DATA$(INDEX)=FIELD_DESC$(MOD(INDEX-1,UDIM(MAT FIELD_DESC$))+1)
10881 ! 
10882          if FNISEMPTYS(MAT INCLUDECOLUMNS$) OR SRCH(MAT INCLUDECOLUMNS$,COLUMNNAMES$(INDEX))>0 then 
10883             let INPUT_DATA$(INDEX) = "^"&INPUT_DATA$(INDEX)
10884          end if 
10885 ! 
10886          let ROW+=1
10887          if ROW > ROWS-3 AND COL+18+19 > COLS then 
10888             let ROW = 2
10889             let COL = 2
10890          else if ROW > ROWS-3 then 
10891             let COL +=19
10892             let ROW = 2
10893          end if 
10894       next INDEX
10895 ! 
10896       do 
10897          do 
10898             let THISTAB = CURTAB(COLSEL_TABS(1))
10899             for TABINDEX = 1 to UDIM(COLSEL_TABS)
10900                if COLSEL_TABS(TABINDEX) = THISTAB then let CURRENTTABINDEX=TABINDEX
10901             next TABINDEX
10902             let STARTCOL = 1 + (CURRENTTABINDEX - 1) * ITEMSPERPAGE
10903             let ENDCOL = MIN(CURRENTTABINDEX * ITEMSPERPAGE, UDIM(INPUT_SPEC$))
10904             rinput #THISTAB, fields MAT INPUT_SPEC$(STARTCOL:ENDCOL) : MAT INPUT_DATA$(STARTCOL:ENDCOL)
10905             let FK=FKEY
10906 ! 
10907             if FK=56 then ! Select All
10908                for INDEX=1 to UDIM(MAT INPUT_DATA$)
10909                   let INPUT_DATA$(INDEX)=TRIM$(INPUT_DATA$(INDEX))
10910                   if INPUT_DATA$(INDEX)(1:1)<>"^" then 
10911                      let INPUT_DATA$(INDEX)(999:1000)=""
10912                      let INPUT_DATA$(INDEX)(1:0)="^"
10913                   end if 
10914                next INDEX
10915             else if FK=57 then ! Select None
10916                for INDEX=1 to UDIM(MAT INPUT_DATA$)
10917                   if INPUT_DATA$(INDEX)(1:1)="^" then 
10918                      let INPUT_DATA$(INDEX)(1:1)=""
10919                   end if 
10920                next INDEX
10921             end if 
10922          loop UNTIL FK=0 OR FK=99 OR FK=93 OR FK=54 OR FK=55 ! 0,55: Ok; 99,93,54: Cancel
10923 ! 
10924          let CLOSEWINDOW=1
10925          if FK=0 OR FK=55 then 
10926             if NEEDSSAVE then 
10927                let SHOULDSAVE=MSGBOX("All unsaved changes will be lost. Do you want to Save first?","Search Warning","YNC","EXCL")
10928                if SHOULDSAVE=2 then let FNSELECTDATACRAWLERCOLS=2
10929                if SHOULDSAVE=3 then let FNSELECTDATACRAWLERCOLS=1
10930                if SHOULDSAVE=4 then let CLOSEWINDOW=0
10931             else 
10932                let FNSELECTDATACRAWLERCOLS=1
10933             end if 
10934             if CLOSEWINDOW then 
10935                mat INCLUDECOLUMNS$(0)
10936                for INDEX = 1 to UDIM(INPUT_DATA$)
10937                   if INPUT_DATA$(INDEX)(1:1)="^" then 
10938                      let JNDEX=UDIM(MAT INCLUDECOLUMNS$)+1
10939                      mat INCLUDECOLUMNS$(JNDEX)
10940                      let INCLUDECOLUMNS$(JNDEX)=COLUMNNAMES$(INDEX)
10941                   end if 
10942                next INDEX
10943                if UDIM(MAT INCLUDECOLUMNS$)=UDIM(MAT INPUT_DATA$) then 
10944                   mat INCLUDECOLUMNS$(0)
10945                end if 
10946             end if 
10947          else 
10948             let FNSELECTDATACRAWLERCOLS=0
10949          end if 
10950       loop UNTIL CLOSEWINDOW
10951 ! 
10952       for THISTAB = 1 to UDIM(COLSEL_TABS)
10953          close #(COLSEL_TABS(THISTAB)): 
10954       next THISTAB
10955 ! 
10956       close #COLSEL_WINDOW: 
10957    fnend 
10958 ! 
10959 Exporttocsv: ! **** Export A Data File To Csv Format
10960    def FNEXPORTTOCSV(LAYOUT$*2000,MAT CSVFIELDNAMES$,CSVFILE$*2000,USERECNUMS;KEYNUMBER,&KEY$,&RECORDNUM,MAT RECORDS,&SEARCHMATCH$,&KEYMATCH$,&SEARCHNOW$,___,CSVFILE,DATAFILE,BRECNUM)
10961       library : FNREADLAYOUTHEADER
10962 ! 
10963       open #(CSVFILE=FNGETFILENUMBER): "name="&CSVFILE$&",recl=32000,replace",display,output ioerr Ignore
10964 ! 
10965       if FILE(CSVFILE) = 0 then 
10966 ! .      ! Print field names in first line
10967          if USERECNUMS then print #CSVFILE: "&RECNUM,";
10968          for FIND = 1 to UDIM(CSVFIELDNAMES$)
10969             if FIND < UDIM(CSVFIELDNAMES$) then print #CSVFILE: CSVFIELDNAMES$(FIND);","; else print #CSVFILE: CSVFIELDNAMES$(FIND)
10970          next FIND
10971 ! 
10972          let DATAFILE=FNOPEN(LAYOUT$,MAT CSV_DATA$,MAT CSV_DATA,MAT CSV_FORMS$,1,KEYNUMBER)
10973 ! 
10974          if KLN(DATAFILE)>0 AND TRIM$(KEY$)<>"" then 
10975             restore #DATAFILE, search>=TRIM$(KEY$): nokey Clearkey
10976          end if 
10977          if RECORDNUM then 
10978             restore #DATAFILE, rec=RECORDNUM: norec Clearrec
10979          end if 
10980 ! 
10981          let BRECNUM=(~FNISEMPTY(MAT RECORDS))
10982 ! 
10983          do 
10984             read #DATAFILE, using CSV_FORMS$(DATAFILE), release: MAT CSV_DATA$,MAT CSV_DATA error Ignore
10985             if FILE(DATAFILE)=0 then 
10986                if ~BRECNUM OR SRCH(MAT RECORDS,REC(DATAFILE))>0 then 
10987                   if ~LEN(KEYMATCH$) OR KEYMATCH$=FNBUILDKEY$(LAYOUT$,MAT CSV_DATA$,MAT CSV_DATA,KEYNUMBER)(1:LEN(KEYMATCH$)) then 
10988                      if ~LEN(SEARCHMATCH$) OR FNSEARCHIN(SEARCHMATCH$,MAT CSV_DATA$,MAT CSV_DATA) then 
10989                         if ~LEN(SEARCHNOW$) OR FNSEARCHIN(SEARCHNOW$,MAT CSV_DATA$,MAT CSV_DATA) then 
10990                            if USERECNUMS then print #CSVFILE: STR$(REC(DATAFILE))&",";
10991                            for FIND = 1 to UDIM(CSVFIELDNAMES$)
10992                               if FIND <= UDIM(CSV_DATA$) then 
10993                                  print #CSVFILE: """"&SREP$(CSV_DATA$(FIND),"""","""""")&"""";
10994                               else 
10995                                  print #CSVFILE: CSV_DATA(FIND - UDIM(CSV_DATA$));
10996                               end if 
10997                               if FIND < UDIM(CSVFIELDNAMES$) then print #CSVFILE: ","; else print #CSVFILE: 
10998                            next FIND
10999                         end if 
11000                      end if 
11001                   end if 
11002                end if 
11003             end if 
11004          loop UNTIL FILE(DATAFILE)<>0
11005 ! 
11006          close #DATAFILE: 
11007          close #CSVFILE: 
11008 ! 
11009          let MSGBOX("Export complete!")
11010       else 
11011          let MSGBOX("Error: could not open file!")
11012       end if 
11013    fnend 
11014 ! 
11015    def FNCSVEXPORTDLG(LAYOUT$,MAT COLUMNNAMES$,ROWS,COLS;KEYNUMBER,&KEY$,&RECORDNUM,MAT RECORDS,&SEARCHMATCH$,&KEYMATCH$,&SEARCHNOW$,___,DIALOG,KEY,CSVPATH$*2000,CSVFILE,USERECNUMS$*50,USERECNUMS)
11016       library : FNREADLAYOUTHEADER
11017 ! 
11018       dim KEYS$(1)*80,KEYDESC$(1)*80,SRCFIELDNAMES$(1)*80
11019 ! 
11020       open #(DIALOG:=FNGETFILENUMBER) : "SROW="&STR$(INT((ROWS - 7) / 2))&",SCOL="&STR$(INT((COLS - 30) / 2))&",ROWS=7,COLS=30,CAPTION=Export to CSV,BORDER=S",display,outin 
11021       print #DIALOG, fields "1,1,C 20;2,22,CC 8,,B62" : "CSV Data File","Browse"
11022       print #DIALOG, fields "7,12,CC 8,,B61" : "Export!"
11023       print #DIALOG, fields "7,22,CC 8,,B60" : "Cancel"
11024 ! 
11025       open #(CSVFILE=FNGETFILENUMBER): "name=SAVE:CSV files (*.csv) |*.csv,recl=32000,replace",display,output ioerr Ignore
11026 ! 
11027       if FILE(CSVFILE) = 0 then 
11028          let CSVPATH$=FILE$(CSVFILE)
11029          close #CSVFILE: 
11030          let USERECNUMS$ = "^Include Record Numbers"
11031          do 
11032             rinput #DIALOG, fields "2,1,20/C 2000,P;4,1,CHECK 50" : CSVPATH$,USERECNUMS$
11033 ! 
11034             let KEY=FKEY
11035 ! 
11036             if KEY=62 then 
11037 ! .             ! browse for a new file
11038                open #(CSVFILE=FNGETFILENUMBER): "name=SAVE:CSV files (*.csv) |*.csv,recl=32000,replace",display,output ioerr Ignore
11039                if FILE(CSVFILE) = 0 then 
11040                   let CSVPATH$=FILE$(CSVFILE)
11041                   close #CSVFILE: 
11042                end if 
11043             end if 
11044          loop UNTIL KEY = 60 OR KEY = 61 OR KEY = 99 OR KEY=93
11045 ! 
11046          if USERECNUMS$(1:1)="^" then let USERECNUMS=1 else let USERECNUMS=0
11047 ! 
11048          if KEY = 61 then 
11049 ! .         ! do export
11050             let FNEXPORTTOCSV(LAYOUT$,MAT COLUMNNAMES$,CSVPATH$,USERECNUMS,KEYNUMBER,KEY$,RECORDNUM,MAT RECORDS,SEARCHMATCH$,KEYMATCH$,SEARCHNOW$)
11051          end if 
11052       end if 
11053 ! 
11054       close #DIALOG: 
11055    fnend 
11056 ! 
11057 Importfromcsv: ! **** Import Data From An External Csv File
11058    def FNIMPORTFROMCSV(LAYOUT$,MAT CSV_FIELDS$,CSVFILE,KEYNUM;___,DATAFILE,RECNUM$,CHARIND,NUMQ)
11059       library : FNBUILDKEY$,FNCLOSEFILE
11060 ! 
11061       dim CSVLINE$*32000,CSVLINEBUF$*32000
11062       dim SRCFIELDNAMES$(1)*80
11063 ! 
11064       if FILE(CSVFILE) = 0 then 
11065          restore #CSVFILE: 
11066          linput #CSVFILE: CSVLINE$
11067 ! 
11068          let FIELDCNT=FNEXTRACTCSVHEADER(CSVLINE$,MAT SRCFIELDNAMES$)
11069          let FNLWRCTHIS(MAT SRCFIELDNAMES$)
11070 ! 
11071          if KEYNUM > 0 then 
11072             let DATAFILE=FNOPEN(LAYOUT$,MAT CSV_DATA$,MAT CSV_DATA,MAT CSV_FORMS$,0,KEYNUM)
11073          else 
11074             let DATAFILE=FNOPEN(LAYOUT$,MAT CSV_DATA$,MAT CSV_DATA,MAT CSV_FORMS$)
11075          end if 
11076 ! 
11077          let FNCLEARCSVAPPLYMESSAGES
11078 ! 
11079          do 
11080             let CSVLINE$=""
11081             do 
11082                linput #CSVFILE: CSVLINEBUF$ error Ignore
11083                let CSVLINE$=CSVLINE$&CSVLINEBUF$
11084 ! 
11085 ! .             ! Special case: starting from the end of the line, if there are an odd number of double quotes before the last comma,
11086 ! .             ! the line is ending with a newline inside string data.  Therefore, grab an additional line
11087                let NUMQ=0
11088                for CHARIND = LEN(CSVLINE$) to 1 step -1
11089                   if CSVLINE$(CHARIND:CHARIND)="""" then let NUMQ+=1
11090                   if CSVLINE$(CHARIND:CHARIND)="," then let CHARIND=0
11091                next CHARIND
11092             loop UNTIL MOD(NUMQ,2)=0
11093             if FILE(CSVFILE) = 0 then 
11094                let FNEXTRACTCSVLINE(CSVLINE$,MAT CSV_DATA$,MAT CSV_DATA,MAT CSV_FIELDS$,MAT SRCFIELDNAMES$)
11095 ! 
11096                if FNDISPLAYCSVAPPLYMESSAGES then 
11097 ! .                 ! There were no errors, or they chose Ignore
11098                   if KEYNUM > 0 then 
11099 ! .                     ! attempt to rewrite
11100                      rewrite #DATAFILE, using CSV_FORMS$(DATAFILE), key=FNBUILDKEY$(LAYOUT$, MAT CSV_DATA$, MAT CSV_DATA, KEYNUM) : MAT CSV_DATA$, MAT CSV_DATA error Ignore
11101                      if FILE(DATAFILE) = 21 then 
11102                         write #DATAFILE, using CSV_FORMS$(DATAFILE) : MAT CSV_DATA$, MAT CSV_DATA
11103                      end if 
11104                   else if KEYNUM = 0 then 
11105                      let RECNUM$=CSVLINE$(1:POS(CSVLINE$,",")-1)
11106                      rewrite #DATAFILE, using CSV_FORMS$(DATAFILE), rec=VAL(RECNUM$) : MAT CSV_DATA$, MAT CSV_DATA error Ignore
11107                      if FILE(DATAFILE) = 21 then 
11108                         write #DATAFILE, using CSV_FORMS$(DATAFILE) : MAT CSV_DATA$, MAT CSV_DATA
11109                      end if 
11110                   else 
11111                      write #DATAFILE, using CSV_FORMS$(DATAFILE) : MAT CSV_DATA$, MAT CSV_DATA
11112                   end if 
11113                else 
11114 ! .                 ! They chose abort
11115                   exit do 
11116                end if 
11117             end if 
11118          loop UNTIL FILE(CSVFILE) <> 0
11119 ! 
11120          let FNCLOSEFILE(DATAFILE,LAYOUT$)
11121 ! 
11122       end if 
11123 ! 
11124    fnend 
11125 ! 
11126    def FNCSVIMPORTDLG(LAYOUT$,MAT COLUMNNAMES$,ROWS,COLS;___,DIALOG,KEY,FILENAME$*255,CSVPATH$*2000,CSVPATH2$*2000,KEY$*160,INDEX,SEL$,CSVFILE,CSVLINE$*32000,FILECHANGED,KEYNUM)
11127       library : FNREADLAYOUTHEADER
11128 ! 
11129       dim KEYS$(1)*80,KEYDESC$(1)*80,KEYOPTIONS$(1)*160,SRCFIELDNAMES$(1)*80
11130 ! 
11131       open #(DIALOG:=FNGETFILENUMBER) : "SROW="&STR$(INT((ROWS - 7) / 2))&",SCOL="&STR$(INT((COLS - 30) / 2))&",ROWS=7,COLS=30,CAPTION=Import from CSV,BORDER=S",display,outin 
11132       print #DIALOG, fields "1,1,C 20;2,22,CC 8,,B62" : "CSV Data File","Browse"
11133       print #DIALOG, fields "7,22,CC 8,,B60" : "Cancel"
11134 ! 
11135       let FNREADLAYOUTHEADER(LAYOUT$,FILENAME$,MAT KEYS$,MAT KEYDESC$,0)
11136 ! 
11137       if FN42 then let SEL$=",SELECT" else let SEL$=""
11138       if POS(FILENAME$,".") > 0 then let CSVPATH$=FILENAME$(1:POS(FILENAME$,"."))&"csv" else let CSVPATH$=FILENAME$&".csv"
11139       let FILECHANGED = 1
11140       do 
11141 ! .     ! Check whether selected file exists and if so, look for &RECNUM field
11142          let CSVPATH2$=CSVPATH$
11143          if FILECHANGED then 
11144             let FILECHANGED = 0
11145             if FILE(CSVFILE) = 0 then close #CSVFILE: 
11146             open #(CSVFILE=FNGETFILENUMBER): "name="&CSVPATH$&",recl=32000",display,input ioerr Ignore
11147          end if 
11148          if FILE(CSVFILE) = 0 then ! File Exists And Is Open
11149             print #DIALOG, fields "4,1,C 26" : "Update Records Using Key"
11150 ! 
11151             restore #CSVFILE: 
11152             linput #CSVFILE: CSVLINE$
11153             let FNEXTRACTCSVHEADER(CSVLINE$,MAT SRCFIELDNAMES$)
11154             if SRCFIELDNAMES$(1) = "&RECNUM" then 
11155                mat KEYOPTIONS$(UDIM(KEYDESC$) + 2)
11156                let KEYOPTIONS$(2)="Record Number"
11157             else 
11158                mat KEYOPTIONS$(UDIM(KEYDESC$) + 1)
11159             end if 
11160             let KEYOPTIONS$(1)="None (append all records)"
11161             for INDEX = 1+UDIM(KEYOPTIONS$)-UDIM(KEYDESC$) to UDIM(KEYOPTIONS$)
11162                let KEYOPTIONS$(INDEX) = STR$(INDEX+UDIM(KEYDESC$)-UDIM(KEYOPTIONS$))&" - "&KEYS$(INDEX+UDIM(KEYDESC$)-UDIM(KEYOPTIONS$))&" ("&KEYDESC$(INDEX+UDIM(KEYDESC$)-UDIM(KEYOPTIONS$))&")"
11163             next INDEX
11164             print #DIALOG, fields "5,1,26/COMBO 160,= "&SEL$ : MAT KEYOPTIONS$
11165 ! 
11166             rinput #DIALOG, fields "2,1,20/C 2000,AEX;5,1,26/COMBO 160"&SEL$ : CSVPATH$,KEY$
11167          else ! File Doesn't exist; don'T Show Any Other Input Fields
11168             let KEY$=""
11169             print #DIALOG, fields "7,11,CC 8" : ""
11170             print #DIALOG, fields "4,1,C 26;5,1,C 26" : "",""
11171             rinput #DIALOG, fields "2,1,20/C 2000,AEX" : CSVPATH$
11172          end if 
11173          let KEY=FKEY
11174 ! 
11175          if KEY = 62 then 
11176 ! .         ! try to open file by browsing
11177             let FILECHANGED = 0
11178             if FILE(CSVFILE) = 0 then close #CSVFILE: 
11179             open #(CSVFILE=FNGETFILENUMBER): "name=OPEN:CSV files (*.csv) |*.csv,recl=32000",display,input ioerr Ignore
11180             if FILE(CSVFILE) = 0 then let CSVPATH$=FILE$(CSVFILE) else let FILECHANGED = 1
11181          end if 
11182          if CSVPATH2$<>CSVPATH$ then 
11183 ! .         ! retry file using contents of text box
11184             let FILECHANGED = 1
11185          end if 
11186          if KEY$="" then 
11187             print #DIALOG, fields "7,12,CC 8" : ""
11188          else 
11189             print #DIALOG, fields "7,12,CC 8,,B61" : "Import!"
11190          end if 
11191 ! 
11192       loop UNTIL KEY = 60 OR KEY = 61 OR KEY = 99 OR KEY=93
11193 ! 
11194       if KEY = 61 then 
11195 ! .     ! get data key number; -1 = append all, 0 = use recnum
11196          if KEY$="Record Number" then 
11197             let KEYNUM=0
11198          else if KEY$(1:4)="None" then 
11199             let KEYNUM=-1
11200          else 
11201             let KEYNUM=VAL(KEY$(1:POS(KEY$," ")-1))
11202          end if 
11203 ! 
11204 ! .     ! do the import
11205          let FNIMPORTFROMCSV(LAYOUT$,MAT COLUMNNAMES$,CSVFILE, KEYNUM)
11206 ! 
11207          close #CSVFILE: 
11208       end if 
11209 ! 
11210       close #DIALOG: 
11211 ! 
11212    fnend 
11213 ! 
11214 Extractcsvheader: ! Extract Field Names From A Csv Header Line Into An Array
11215    def FNEXTRACTCSVHEADER(&LINE$,MAT FIELDNAMES$)
11216       let LINE$=TRIM$(LINE$)
11217       let CHUNKSTART=1 : let FIELDCNT=0
11218       for CHARIND = 1 to LEN(LINE$)
11219          if LINE$(CHARIND:CHARIND)="," then 
11220             let FIELDCNT = FIELDCNT + 1
11221             mat FIELDNAMES$(FIELDCNT)
11222             if CHARIND=CHUNKSTART then let FIELDNAMES$(FIELDCNT)="" else let FIELDNAMES$(FIELDCNT)=LINE$(CHUNKSTART:CHARIND-1)
11223             let CHUNKSTART=CHARIND+1
11224          else if CHARIND=LEN(LINE$) then 
11225             let FIELDCNT = FIELDCNT + 1
11226             mat FIELDNAMES$(FIELDCNT)
11227             let FIELDNAMES$(FIELDCNT)=LINE$(CHUNKSTART:CHARIND)
11228          end if 
11229       next CHARIND
11230       let FNEXTRACTCSVHEADER=FIELDCNT
11231    fnend 
11232 ! 
11233    def FNEXTRACTCSVLINE(&LINE$,MAT SVALUES$,MAT NVALUES,MAT DESTFIELDNAMES$,MAT SRCFIELDNAMES$;___,CHUNKSTART,CURFIELD,CHARIND,CHUNK$*4000,NUMIND,STRIND)
11234       let LINE$=TRIM$(LINE$)
11235       let CHUNKSTART=1 : let CURFIELD=1
11236       mat SVALUES$=("")
11237       mat NVALUES=(0)
11238 ! 
11239       for CHARIND = 0 to LEN(LINE$)
11240          if LINE$(CHARIND+1:CHARIND+1)="," OR CHARIND=LEN(LINE$) then 
11241 ! .          ! grab chunk to parse
11242             let CHUNK$=RTRM$(LINE$(CHUNKSTART:CHARIND)) ! Rtrm, Br Doesn't store trailing spaces anyway.
11243             let NEXTFIELD = 0
11244 ! 
11245 ! .          ! print line$ : print chunk$ : pause ! Debug line
11246 ! 
11247             if CHUNK$(1:1)<>"""" OR MOD(FNNUMENDINGQUOTES(CHUNK$),2)=1 then 
11248 ! .             ! Either has no beg qoute (not quoted) or has both
11249 ! .             ! beginning and ending qoute, process it. Otherwise, go
11250 ! .             ! back for more.
11251 ! 
11252                if CHUNK$(1:1)="""" AND MOD(FNNUMENDINGQUOTES(CHUNK$),2)=1 then 
11253                   let CHUNK$=SREP$(CHUNK$(2:LEN(CHUNK$)-1),"""""","""") ! Substitute Out Inner Qoutes, And Strip Out Qoutes
11254                end if 
11255 ! .             ! if len(Trim$(Chunk$)) then ! If there's something left ! Commented out by GSB .. if a field is empty, we want to clear the value, not ignore it.
11256                let FNAPPLYCSVFIELD(CHUNK$,MAT SVALUES$,MAT NVALUES,MAT DESTFIELDNAMES$,SRCFIELDNAMES$(CURFIELD))
11257 ! .             ! end if
11258                let NEXTFIELD = 1
11259             end if 
11260 ! 
11261             if NEXTFIELD then 
11262 ! .              ! CharInd=CharInd+2
11263                let CHUNKSTART=CHARIND +2
11264                let CURFIELD = CURFIELD + 1
11265             end if 
11266          end if 
11267       next CHARIND
11268    fnend 
11269 ! 
11270 ! .! Old Logic here replaced by the above code.
11271 ! .! Old Logic for Numbers (Without beginning quote):
11272 ! .!  for NumInd=UDim(SValues$)+1 to UDim(SValues$)+Udim(NValues)
11273 ! .!     if DestFieldNames$(NumInd)=SrcFieldNames$(CurField) then NValues(NumInd - UDim(SValues$))=Val(Chunk$)
11274 ! .!  next NumInd
11275 ! 
11276 ! .! Old Logic for Strings (With Beginning Qoute):
11277 ! .!  for StrInd=1 to UDim(SValues$)
11278 ! .!     if DestFieldNames$(StrInd)=SrcFieldNames$(CurField) then SValues$(StrInd)=Chunk$
11279 ! .!  next StrInd
11280 ! 
11281    def FNAPPLYCSVFIELD(&SOURCEDATA$,MAT SVALUES$,MAT NVALUES, MAT DESTFIELDNAMES$,&SOURCEFIELDNAME$;___,INDEX)
11282       let INDEX=SRCH(MAT DESTFIELDNAMES$,SOURCEFIELDNAME$)
11283       if INDEX>=1 AND INDEX<=UDIM(SVALUES$)+UDIM(NVALUES) then 
11284          if INDEX>UDIM(SVALUES$) then 
11285             if FNISNUMBER(CHUNK$) then 
11286                let NVALUES(INDEX-UDIM(SVALUES$))=VAL(CHUNK$)
11287             else 
11288                if ~ERRORIMPORTMESSAGE then ! If Not Asked Yet, Then Ask.
11289 ! .               ! Conversion Error, Field was not a number when it should have been
11290                   mat FIELDSCONV$(UDIM(MAT FIELDSCONV$)+1)
11291                   let FIELDSCONV$(UDIM(MAT FIELDSCONV$))=SOURCEFIELDNAME$
11292                end if 
11293             end if 
11294          else 
11295             let SVALUES$(INDEX)=CHUNK$
11296          end if 
11297       else 
11298 ! .      ! Field could not be found, report it later
11299          if SOURCEFIELDNAME$<>"&recnum" then 
11300             mat FIELDSMISSING$(UDIM(FIELDSMISSING$)+1)
11301             let FIELDSMISSING$(UDIM(FIELDSMISSING$))=SOURCEFIELDNAME$
11302          end if 
11303       end if 
11304    fnend 
11305 ! 
11306    dim FIELDSMISSING$(1)*127
11307    dim FIELDSCONV$(1)*127
11308 ! 
11309    def FNCLEARCSVAPPLYMESSAGES
11310       mat FIELDSMISSING$(0)
11311       mat FIELDSCONV$(0)
11312    fnend 
11313 ! 
11314    dim MESSAGETEXT$*4000
11315    def FNDISPLAYCSVAPPLYMESSAGES
11316       if UDIM(MAT FIELDSMISSING$)+UDIM(MAT FIELDSCONV$) then ! If There Were Errors,
11317          let FNBUILDMESSAGETEXT(MESSAGETEXT$,MAT FIELDSMISSING$,MAT FIELDSCONV$)
11318          if (2==MSGBOX(MESSAGETEXT$,"Import Error","Yn","ERR")) then 
11319             let FNDISPLAYCSVAPPLYMESSAGES=0
11320          else 
11321             let FNDISPLAYCSVAPPLYMESSAGES=1
11322          end if 
11323       else 
11324          let FNDISPLAYCSVAPPLYMESSAGES=1
11325       end if 
11326    fnend 
11327 ! 
11328    def FNBUILDMESSAGETEXT(&MESSAGETEXT$,MAT MISSING$,MAT CONV$;___,INDEX,NP$,NL$)
11329       let NP$=HEX$("0D0A0D0A")
11330       let NL$=HEX$("0D0A")
11331 ! 
11332       let MESSAGETEXT$="Errors were encountered during the import process."
11333       if UDIM(MAT MISSING$) then 
11334          let MESSAGETEXT$=MESSAGETEXT$&NP$&"The following fields could not be found in the data file and will be ignored if you continue:"&NL$
11335          for INDEX=1 to UDIM(MAT MISSING$)
11336             let MESSAGETEXT$=MESSAGETEXT$&MISSING$(INDEX)&", "
11337          next INDEX
11338          let MESSAGETEXT$=MESSAGETEXT$(1:LEN(MESSAGETEXT$)-2) ! Chop Off Final ","
11339       end if 
11340       if UDIM(MAT CONV$) then 
11341          let MESSAGETEXT$=MESSAGETEXT$&NP$
11342          if UDIM(MAT MISSING$) then 
11343             let MESSAGETEXT$=MESSAGETEXT$&"Additionally, t"
11344          else 
11345             let MESSAGETEXT$=MESSAGETEXT$&"T"
11346          end if 
11347          let MESSAGETEXT$=MESSAGETEXT$&"he following fields were numeric fields that contained string data, and will be ignored if you continue:"&NL$
11348          for INDEX=1 to UDIM(MAT CONV$)
11349             let MESSAGETEXT$=MESSAGETEXT$&CONV$(INDEX)&", "
11350          next INDEX
11351          let MESSAGETEXT$=MESSAGETEXT$(1:LEN(MESSAGETEXT$)-2) ! Chop Off Final ","
11352       end if 
11353       let MESSAGETEXT$=MESSAGETEXT$&NP$&"Do you wish to Stop the Import process?"
11354       let FNCLEARCSVAPPLYMESSAGES
11355    fnend 
11356 ! 
11357 ! .! that delicate nervous shake
11358 ! .! upon discovering a pause
11359 ! .! left behind by mistake
11360 ! .! like a sock in the kaverns of kroz
11361 ! 
11362    def FNNUMENDINGQUOTES(CHUNK$*4000;___,CHARIND,QUOTECNT)
11363       let QUOTECNT = 0
11364       for CHARIND = LEN(CHUNK$) to 2 step -1
11365          if CHUNK$(CHARIND:CHARIND)="""" then let QUOTECNT += 1
11366       next CHARIND
11367       let FNNUMENDINGQUOTES = QUOTECNT
11368    fnend 
11369 ! 
11370 ! .! discovered in some dusty function
11371 ! .! that you thought was always working
11372 ! .! abandoned like a lost conjunction
11373 ! .! a dangerous pause, secretly lurking
11374 ! 
11375    def FNLWRCTHIS(MAT A$;___,INDEX)
11376       for INDEX=1 to UDIM(MAT A$)
11377          let A$(INDEX)=LWRC$(A$(INDEX))
11378       next INDEX
11379    fnend 
11380 ! 
11381 ! .! what is this pause
11382 ! .! and why is it there?
11383 ! .! why is it forgotten,
11384 ! .! abandoned somewhere?
11385 ! 
11386 ! 
11387    dim OUTCOLUMNNAMES$(1)
11388 Calculatefieldforms: ! ***** Calculate Field Forms From Widths And Num Of Strings/Numerics
11389    def FNCALCULATEFIELDFORMS(LAYOUT$,MAT COLUMNNAMES$,MAT FIELDFORMS$,MAT OUTWIDTHS,MAT OUTDESCRIPTION$,MAT WIDTHS,MAT DESCRIPTION$,MAT INCLUDECOLUMNS$,MAT ORIGINALINCLUDECOLUMN$,MAT COLUMNDESCRIPTION$,MAT COLUMNWIDTHS,MAT COLUMNFORMS$,MAT FIELDPOSITIONS;BSHOWPOSITIONS,DISPLAYSUB,&DISPLAYFIELDCONVERT$,___,INDEX,COMPRESSCOLUMNS,MAXCOLWIDTH,SUB,BCOLUMNDESCRIPTION,BCOLUMNWIDTH,BORIGINALINCLUDE,BCOLUMNFORMS)
11390 ! 
11391 ! .   ! Prepare width calculation
11392       let COMPRESSCOLUMNS=FNSETTINGS("compresscolumns")
11393       let MAXCOLWIDTH=FNSETTINGS("maxcolwidth")
11394 ! 
11395 ! .   ! Prepare Column Descriptions and Widths
11396       let BCOLUMNWIDTH=~FNISEMPTY(MAT COLUMNWIDTHS)
11397       let BCOLUMNFORMS=~FNISEMPTYS(MAT COLUMNFORMS$)
11398       let BCOLUMNDESCRIPTION=~FNISEMPTYS(MAT COLUMNDESCRIPTION$)
11399       let BORIGINALINCLUDE=~FNISEMPTYS(MAT ORIGINALINCLUDECOLUMN$)
11400 ! 
11401       if ~FNISEMPTYS(MAT INCLUDECOLUMNS$) then 
11402 ! .      ! Size temp arrays
11403          mat OUTWIDTHS(UDIM(MAT INCLUDECOLUMNS$))
11404          mat OUTDESCRIPTION$(UDIM(MAT INCLUDECOLUMNS$))
11405          mat OUTCOLUMNNAMES$(UDIM(MAT INCLUDECOLUMNS$))
11406 ! 
11407 ! .      ! Sort through IncludeColumns and place columns in the grid in order.
11408          for INDEX=1 to UDIM(MAT INCLUDECOLUMNS$)
11409             let SUB=SRCH(MAT COLUMNNAMES$,INCLUDECOLUMNS$(INDEX))
11410             if SUB>0 then ! Found It
11411                let OUTWIDTHS(INDEX)=WIDTHS(SUB)
11412                let OUTDESCRIPTION$(INDEX)=DESCRIPTION$(SUB)
11413                if BSHOWPOSITIONS then let OUTDESCRIPTION$(INDEX)(1:0)=STR$(FIELDPOSITIONS(SUB))&" - "
11414                let OUTCOLUMNNAMES$(INDEX)=INCLUDECOLUMNS$(INDEX)
11415             end if 
11416          next INDEX
11417       else 
11418          mat OUTWIDTHS(UDIM(MAT WIDTHS))=WIDTHS
11419          mat OUTDESCRIPTION$(UDIM(MAT DESCRIPTION$))
11420          mat OUTCOLUMNNAMES$(UDIM(MAT COLUMNNAMES$))=COLUMNNAMES$
11421          for INDEX=1 to UDIM(MAT DESCRIPTION$)
11422             let OUTDESCRIPTION$(INDEX)=DESCRIPTION$(INDEX)
11423             if BSHOWPOSITIONS then let OUTDESCRIPTION$(INDEX)(1:0)=STR$(FIELDPOSITIONS(INDEX))&" - "
11424          next INDEX
11425       end if 
11426 ! 
11427       mat FIELDFORMS$(UDIM(MAT OUTWIDTHS))
11428       for INDEX=1 to UDIM(MAT FIELDFORMS$)
11429          let FIELDFORMS$(INDEX)="C "&STR$(OUTWIDTHS(INDEX))
11430          if BCOLUMNDESCRIPTION then 
11431             if BORIGINALINCLUDE then 
11432 ! .            ! interpret ColumnDescription and ColumnWidth as matching original include
11433                let SUB=SRCH(MAT ORIGINALINCLUDECOLUMN$,OUTCOLUMNNAMES$(INDEX))
11434                if SUB>0 AND SUB<=UDIM(MAT COLUMNDESCRIPTION$) then let OUTDESCRIPTION$(INDEX)=COLUMNDESCRIPTION$(SUB)
11435             else 
11436 ! .            ! interpret columndescription and Columnwidth as matching file record
11437                if INDEX<UDIM(MAT COLUMNDESCRIPTION$) then 
11438                   let OUTDESCRIPTION$(INDEX)=COLUMNDESCRIPTION$(INDEX)
11439                end if 
11440             end if 
11441          end if 
11442 ! 
11443          if ~COMPRESSCOLUMNS then 
11444             let OUTWIDTHS(INDEX)=MAX(OUTWIDTHS(INDEX),LEN(OUTDESCRIPTION$(INDEX)))
11445          end if 
11446          let OUTWIDTHS(INDEX)=MIN(OUTWIDTHS(INDEX),MAXCOLWIDTH)
11447 ! 
11448          if BCOLUMNFORMS then 
11449             if BORIGINALINCLUDE then 
11450 ! .            ! interpret ColumnForms as matching original include
11451                let SUB=SRCH(MAT ORIGINALINCLUDECOLUMN$,OUTCOLUMNNAMES$(INDEX))
11452                if SUB>0 AND SUB<=UDIM(MAT COLUMNFORMS$) AND LEN(TRIM$(COLUMNFORMS$(SUB))) then let FIELDFORMS$(INDEX)=COLUMNFORMS$(SUB)
11453             else 
11454 ! .            ! interpret ColumnForms as matching file record
11455                if INDEX<UDIM(MAT COLUMNFORMS$) AND LEN(TRIM$(COLUMNFORMS$(INDEX))) then 
11456                   let FIELDFORMS$(INDEX)=COLUMNFORMS$(INDEX)
11457                end if 
11458             end if 
11459          end if 
11460 ! 
11461          if BCOLUMNWIDTH then 
11462             if BORIGINALINCLUDE then 
11463 ! .            ! interpret ColumnDescription and ColumnWidth as matching original include
11464                let SUB=SRCH(MAT ORIGINALINCLUDECOLUMN$,OUTCOLUMNNAMES$(INDEX))
11465                if SUB>0 AND SUB<=UDIM(MAT COLUMNWIDTHS) then let OUTWIDTHS(INDEX)=COLUMNWIDTHS(SUB)
11466             else 
11467 ! .            ! interpret columndescription and Columnwidth as matching file record
11468                if INDEX<=UDIM(MAT COLUMNWIDTHS) then 
11469                   let OUTWIDTHS(INDEX)=COLUMNWIDTHS(INDEX)
11470                end if 
11471             end if 
11472          end if 
11473 ! 
11474       next INDEX
11475 ! 
11476       if DISPLAYSUB>0 AND DISPLAYSUB<=UDIM(MAT COLUMNNAMES$) then 
11477          let SUB=SRCH(MAT OUTCOLUMNNAMES$,COLUMNNAMES$(DISPLAYSUB))
11478          if SUB>0 then 
11479             let DISPLAYFIELDCONVERT$=FIELDFORMS$(SUB)
11480          end if 
11481       end if 
11482    fnend 
11483 ! 
11484 Getfieldnames: ! Get The Field Names From The Layout File In Strings First, Numerics Last Order
11485    def FNGETFIELDNAMES(LAYOUT$*255,MAT FIELDNAMES$,MAT POSITIONS)
11486       dim STRINGSUBS$(1)*80,NUMSUBS$(1)*80,STRINGSPECS$(1)*80,NUMSPECS$(1)*80,STRINGDESC$(1)*80,NUMDESC$(1)*80,STRINGPOS(1),NUMPOS(1)
11487       let FNREADLAYOUTARRAYS(LAYOUT$,PREFIX$,MAT STRINGSUBS$,MAT NUMSUBS$,MAT STRINGSPECS$,MAT NUMSPECS$,MAT STRINGDESC$,MAT NUMDESC$,MAT STRINGPOS,MAT NUMPOS,0)
11488       let SUBCNT=UDIM(STRINGSUBS$)+UDIM(NUMSUBS$)
11489       mat FIELDNAMES$(SUBCNT)
11490       mat FIELDNAMES$(1:UDIM(STRINGSUBS$))=STRINGSUBS$
11491       if UDIM(MAT NUMSUBS$) then mat FIELDNAMES$(UDIM(STRINGSUBS$)+1:UDIM(MAT FIELDNAMES$))=NUMSUBS$
11492       mat POSITIONS(SUBCNT)
11493       mat POSITIONS(1:UDIM(MAT STRINGPOS))=STRINGPOS
11494       if UDIM(MAT NUMPOS) then mat POSITIONS(UDIM(MAT STRINGPOS)+1:UDIM(MAT POSITIONS))=NUMPOS
11495    fnend 
11496 ! 
11497 ! 
11498    dim INPUTKEYFIELD$(2)
13000 ! #Autonumber# 13000,10
13010 Inputkey: ! ***** Prompts The User For The Key To Look Up In The Datafile
13020    def FNINPUTKEY(&KEY$,&RECORDNUM,DATAFILE,ROWS,COLS;PARENTWINDOW,___,WINDOW,FIELD$,SROW,SCOL,VIEWLENGTH,LENGTH,HEIGHT,RECORDLEN)
13030       let HEIGHT=1
13040       let RECORDLEN=LEN(STR$(LREC(DATAFILE)))+1
13050       if KLN(DATAFILE)>0 then 
13060 ! .      ! let Height+=1
13070          let LENGTH=KLN(DATAFILE)
13080       end if 
13090 ! 
13100 ! .   ! Uncomment the Hight code above and the Record num code below to
13110 ! .   !  enable both at the same time here. They also need to be enabled
13120 ! .   !  both at the same time in fnShowData by opening file twice,
13130 ! .   !  and using the correct file channel to search by key or by
13140 ! .   !  record number
13150 ! 
13160       let SROW=INT((ROWS-HEIGHT)/2)+1
13170       let VIEWLENGTH=MIN(COLS-2,MAX(LENGTH,RECORDLEN)+4)
13180       let VIEWLENGTH=MAX(VIEWLENGTH,15)
13190       let SCOL=INT((COLS-VIEWLENGTH)/2)+1
13200       open #(WINDOW:=FNGETFILENUMBER) : "srow="&STR$(SROW)&",scol="&STR$(SCOL)&",rows="&STR$(HEIGHT)&",cols="&STR$(VIEWLENGTH)&",Caption= Jump to ... ,Border=S,Parent="&STR$(PARENTWINDOW),display,output 
13210 ! 
13220       mat INPUTKEYFIELD$(HEIGHT)
13230       if KLN(DATAFILE)>0 then 
13240 ! .      ! print #Window, fields "1,1,CR 4;2,1,CR 4" : "Key:","Rec:"
13250          print #WINDOW, fields "1,1,CR 4" : "Key:"
13260          let INPUTKEYFIELD$(1)="1,6,"&STR$(MIN(VIEWLENGTH-6,LENGTH))&"/C "&STR$(LENGTH)
13270 ! .      ! let InputKeyField$(2)="2,6,"&str$(min(ViewLength-6,RecordLen))&"/N "&Str$(RecordLen)
13280          input #WINDOW, fields MAT INPUTKEYFIELD$ : KEY$ ! ,Recordnum Conv Tryagain
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
         mat DC_COLOR$(0) ! Clear Color Markings
13410    for DELETEINDEX=1 to UDIM(MAT DC_DELETEROW)
13420       if DC_DELETEROW(DELETEINDEX) then ! If Row Is Marked For Deletion, Show It In Red
13430          mat DC_COLORSTART(UDIM(MAT DC_COLORSTART)+1) !:
               mat DC_COLOREND(UDIM(MAT DC_COLORSTART)) !:
               mat DC_COLOR$(UDIM(MAT DC_COLORSTART)) ! Make Room !:
               let DC_COLORSTART(UDIM(MAT DC_COLORSTART)) = (((DELETEINDEX-1) * RECORDSIZE)+1) !:
               let DC_COLOREND(UDIM(MAT DC_COLORSTART)) = (DELETEINDEX * RECORDSIZE)
13440          if DC_DELETEROW(DELETEINDEX)=1 then !:
                  let DC_COLOR$(UDIM(MAT DC_COLORSTART)) = "/#FF0000:#FFFF00" ! Red With Yellow Background !:
               else !:
                  let DC_COLOR$(UDIM(MAT DC_COLORSTART)) = "/#000000:#FFFFFF" ! Black With White Background !:
                  let DC_DELETEROW(DELETEINDEX)=0
13450       end if 
13460    next DELETEINDEX
13470    if (UDIM(MAT DC_COLORSTART)) then !:
            print #WINDOW, fields GRIDSPEC$&",ATTR" : (MAT DC_COLORSTART, MAT DC_COLOREND, MAT DC_COLOR$)
13480    return 
13490 ! 
13500 ! 
13510    dim SEARCHFOR$*999
13520    def FNSEARCHIN(&SEARCH$,MAT F$,MAT F;___,SEARCHCHUNK$*64,INDEX,FOUND,NUMBER,PASSING)
13530       let SEARCHFOR$=SEARCH$
13540 ! 
13550       do WHILE LEN(SEARCHFOR$)
13560          if POS(SEARCHFOR$," ") then 
13570             let SEARCHCHUNK$=LWRC$(TRIM$(SEARCHFOR$(1:POS(SEARCHFOR$," "))))
13580             let SEARCHFOR$(1:POS(SEARCHFOR$," "))=""
13590             let SEARCHFOR$=TRIM$(SEARCHFOR$)
13600          else 
13610             let SEARCHCHUNK$=LWRC$(TRIM$(SEARCHFOR$))
13620             let SEARCHFOR$=""
13630          end if 
13640 ! 
13650          let FOUND=0
13660          do 
13670             for INDEX=1 to UDIM(MAT F$)
13680                if POS(LWRC$(F$(INDEX)),SEARCHCHUNK$) then 
13690                   let FOUND=1
13700                   exit do  ! We're done searching as soon as we found it anywhere
13710                end if 
13720             next INDEX
13730             if FNISNUMBER(SEARCHCHUNK$(1:120)) then 
13740                for INDEX=1 to UDIM(MAT F)
13750                   if POS(STR$(F(INDEX)),SEARCHCHUNK$) then 
13760                      let FOUND=1
13770                      exit do  ! We're done searching as soon as we found it anywhere
13780                   end if 
13790                next INDEX
13800             end if 
13810          loop UNTIL 1
13820       loop WHILE FOUND ! Every Chunk Has To Be Found For It To Be Legit.
13830       let FNSEARCHIN=FOUND
13840    fnend 
13850 ! 
13860    def FNISNUMBER(STRING$*120;___,TESTNUMBER)
13870       let TESTNUMBER=VAL(STRING$) conv Notnumber
13880       let FNISNUMBER=1
13890 Notnumber: ! Not A Number
13900    fnend 
13910 ! 
15000 ! #Autonumber# 15000,2
15002    dim TEMPLATEPROG$(1)*255,TEMPLATEDESC$(1)*255,TEMPLATENUM(1),TEMPLATECHOICE$*255
15004 Generatecode: ! This Function Generates Code If Code Templates Are Available
15006    def FNGENERATECODE(FILELAY$;___,TEMPLATECHOICE)
15008       library : FNASKCOMBO$
15010       mat TEMPLATEPROG$(0)
15012       mat TEMPLATEDESC$(0)
15014 ! 
15016 ! .   ! Read the Templates Directory
15018       let FNREADTEMPLATES(MAT TEMPLATEPROG$,MAT TEMPLATEDESC$,MAT TEMPLATENUM)
15020 ! 
15022       if UDIM(MAT TEMPLATEDESC$) then 
15024          let TEMPLATECHOICE$=FNASKCOMBO$(MAT TEMPLATEDESC$,"Select Template")
15026 ! 
15028 ! .      ! code templates are library functions. They can do their own input/output.
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
15052    def library FNASKCOMBO$*255(MAT DESCRIPTION$;CAPTION$*60,___,WINDOW,CHOICE$*255,SCREENROWS,SCREENCOLS,SROW,SCOL)
15054       library : FNGETFILENUMBER
15056       if CAPTION$="" then let CAPTION$="Select"
15058 ! 
15060       let FNREADSCREENS(SCREENROWS,SCREENCOLS)
15062 ! 
15064       let SROW=INT((SCREENROWS-3)/2)+1
15066       let SCOL=INT((SCREENCOLS-20)/2)+1
15068 ! 
15070 ! .   ! Open child window
15072       open #(WINDOW:=FNGETFILENUMBER): "SROW="&STR$(SROW)&", SCOL="&STR$(SCOL)&", ROWS=3, COLS=20, Border=S, Caption="&CAPTION$,display,outin 
15074 ! 
15076 ! .   ! allow user to select code template
15078       print #WINDOW, fields "3,7,CC 7,,B0" : "Ok"
15080       print #WINDOW, fields "1,2,17/COMBO 255,=,SELECT" : MAT DESCRIPTION$
15082       input #WINDOW, fields "1,2,17/COMBO 255,,SELECT" : CHOICE$
15084 ! 
15086       close #WINDOW: 
15088       let FNASKCOMBO$=CHOICE$
15090    fnend 
15092 ! 
15094 ! .! Define Listviews
15096    dim LAYOUTWIZARD_LV1_CAPTIONS$(1), LAYOUTWIZARD_LV1_WIDTHS(1), LAYOUTWIZARD_LV1_SPECS$(1)
15098    dim LAYOUTWIZARD_LV1_SPEC$*40, LAYOUTWIZARD_LV1_POPSPEC$*40
15100 ! 
15102 ! .! Declare Variables
15104    dim LW_OUTPUT_SPEC$(17)*60,LW_OUTPUT_DATA$(17)*60
15106    dim LW_INPUT_SPEC$(5)*255,LW_INPUT_DATA$(5)*1000
15108    dim OPENSTRING$(1)*999
15110 Layoutwizard: ! This Function Gives A Dialog From Which Programmers Can Quickly Generate File Layouts
15112    def FNLAYOUTWIZARD(;___,WINDOW,SCREENROWS,SCREENCOLS,SROW,SCOL,EXITMODE,GENERATE,FUNCTION,FILEBROWSER,INDEX,JNDEX,CURFIELD)
15114 ! 
15116       let FNREADSCREENS(SCREENROWS,SCREENCOLS)
15118 ! 
15120       let SROW=INT((SCREENROWS-22)/2)+1
15122       let SCOL=INT((SCREENCOLS-60)/2)+1
15124 ! 
15126 ! .   ! Read Specs for Output Controls
15128 Layoutwizarddata: restore Layoutwizarddata ! Restore Data Statements
15130       read MAT LW_OUTPUT_SPEC$
15132       data "22,44,14/CC 15,/W:W,B1504","2,1,11/C 12"
15134       data "7,1,13/C 15","12,1,13/C 15"
15136       data "22,27,14/CC 6,/W:W,B1508","17,1,13/C 15"
15138       data "1,1,8/CR 9","1,41,8/CC 6,/W:W,B1513"
15140 ! 
15142       data "1,51,8/CC 8,/W:W,B1514","2,16,8/CC 4,/W:W,B1515"
15144       data "7,16,8/CC 4,/W:W,B1516","12,16,8/CC 4,/W:W,B1517"
15146       data "17,16,8/CC 4,/W:W,B1518","2,27,8/CC 5,/W:W,B1520"
15148       data "2,41,8/CC 9,/W:W,B1521","2,51,8/CC 8,/W:W,B1522"
15150       data "22,4,17/CC 16,/W:W,B1523"
15152 ! 
15154       read MAT LW_OUTPUT_DATA$
15156       data "Generate Layout","Open String:","Read Statement:","Form Statement:"
15158       data "Done","Dim Statements:","Program:","Browse"
15160       data "Search","Scan","Scan","Scan","Scan"
15162       data "Paste","Clear All","Scan All"
15164       data "Open Scratch Pad"
15166 ! 
15168 ! .   ! Read Specs for Input Controls
15170       read MAT LW_INPUT_SPEC$
15172       data "1,10,28/V 999,S/W:W"
15174       data "3,1,GRID 4/60,ROW,ALL"
15176       data "8,1,240/V 999,^ENTER_CRLFS/W:W","13,1,240/V 999,^ENTER_CRLFS/W:W"
15178       data "18,1,240/V 999,^ENTER_CRLFS/W:W"
15180 ! 
15182       read LAYOUTWIZARD_LV1_SPEC$
15184       data "3,1,GRID 4/60,HEADERS"
15186       read LAYOUTWIZARD_LV1_POP$
15188       data "3,1,GRID 4/60,="
15190 ! 
15192 ! .   ! Fix for earlier versions of BR that don't support ENTER_CRLFS
15194       if ~FN42IA then 
15196          for INDEX=1 to UDIM(MAT LW_INPUT_SPEC$)
15198             let LW_INPUT_SPEC$(INDEX)=SREP$(LW_INPUT_SPEC$(INDEX),"^ENTER_CRLFS","")
15200          next INDEX
15202       else if ~FN42J then 
15204          for INDEX=1 to UDIM(MAT LW_INPUT_SPEC$)
15206             let LW_INPUT_SPEC$(INDEX)=SREP$(LW_INPUT_SPEC$(INDEX),"^ENTER_CRLFS","^ENTER-CRLFS")
15208          next INDEX
15210       end if 
15212 ! 
15214       read MAT LAYOUTWIZARD_LV1_CAPTIONS$
15216       data "Open String"
15218       read MAT LAYOUTWIZARD_LV1_WIDTHS
15220       data 40
15222       read MAT LAYOUTWIZARD_LV1_SPECS$
15224       data "V 999,E"
15226 ! 
15228       read LW_GENERATE,LW_DONE,LW_BROWSE,LW_SCANPROGRAM,LW_SCANOPEN,LW_SCANREAD,LW_SCANFORM,LW_SCANDIM,LW_PASTEOPEN,LW_CLEARALL,LW_SCANALL,LW_OPENSCRATCHPAD
15230       data 1504,1508,1513,1514,1515,1516,1517,1518,1520,1521,1522,1523
15232 ! 
15234       read LW_PROGRAMNAME,LW_READSTRING,LW_FORMSTRING,LW_DIMSTRING
15236       data 1,2,3,4
15238 ! 
15240       let FNBUILDSRCHHELP(1)
15242 ! 
15244 ! .   ! Open Screen
15246       open #(WINDOW:=FNGETFILENUMBER): "SROW="&STR$(SROW)&", SCOL="&STR$(SCOL)&", ROWS=22, COLS=60, Border=S, Caption=File Layout Wizard",display,outin 
15248 ! 
15250       print #WINDOW, fields MAT LW_OUTPUT_SPEC$ : MAT LW_OUTPUT_DATA$
15252       print #WINDOW, fields LAYOUTWIZARD_LV1_SPEC$ : (MAT LAYOUTWIZARD_LV1_CAPTIONS$, MAT LAYOUTWIZARD_LV1_WIDTHS, MAT LAYOUTWIZARD_LV1_SPECS$)
15254 ! 
15256 ! .   ! Main input loop here
15258       do 
15260 ! .      ! Trim spaces in mat open string
15262          let JNDEX=0
15264          for INDEX=1 to UDIM(MAT OPENSTRING$)
15266             if LEN(TRIM$(OPENSTRING$(INDEX))) then 
15268                let JNDEX+=1
15270                let OPENSTRING$(JNDEX)=TRIM$(OPENSTRING$(INDEX))
15272             end if 
15274          next INDEX
15276          mat OPENSTRING$(JNDEX+1) : let OPENSTRING$(JNDEX+1)="" ! Add 1
15278 ! 
15280          let CURFLD(CURFIELD,FUNCTION)
15282 ! .      ! populate it
15284          print #WINDOW, fields LAYOUTWIZARD_LV1_POP$ : MAT OPENSTRING$
15286          rinput #WINDOW, fields MAT LW_INPUT_SPEC$ : MAT LW_INPUT_DATA$(1:1),MAT OPENSTRING$,MAT LW_INPUT_DATA$(2:4)
15288          let FUNCTION=FKEY
15290          let CURFIELD=CURFLD
15292 ! 
15294          if FUNCTION = 99 OR FUNCTION = 93 OR FUNCTION = LW_DONE then ! #Select# Function #Case# 99 # 93 # Lw_Done
15296             let EXITMODE=1
15298          else if FUNCTION = LW_BROWSE then ! #Case# Lw_Browse
15300 ! .         ! Browse for a data file
15302             open #(FILEBROWSER:=FNGETFILENUMBER): "name=OPEN:.|*.wb;*.br,recl=1000",external,input ioerr Ignore
15304             if FILE(FILEBROWSER)>-1 then 
15306                let LW_INPUT_DATA$(LW_PROGRAMNAME)=FILE$(FILEBROWSER)
15308                close #FILEBROWSER: 
15310                if LWRC$(LW_INPUT_DATA$(LW_PROGRAMNAME))(1:2)="c:" then 
15312                   let LW_INPUT_DATA$(LW_PROGRAMNAME)=LW_INPUT_DATA$(LW_PROGRAMNAME)(3:999)
15314                   let FNSCANALL(MAT LW_INPUT_DATA$,MAT OPENSTRING$)
15316                end if 
15318             end if 
15320          else if FUNCTION = LW_SCANPROGRAM then ! #Case# Lw_Scanprogram
15322             let FNSEARCHPROGRAMS(MAT OPENSTRING$,LW_INPUT_DATA$(LW_PROGRAMNAME),1)
15324          else if FUNCTION = LW_SCANOPEN then ! #Case# Lw_Scanopen
15326             let FNSEARCHOPENSTRING(MAT LW_INPUT_DATA$,MAT OPENSTRING$,1)
15328          else if FUNCTION = LW_SCANREAD then ! #Case# Lw_Scanread
15330             let FNSEARCHREAD(MAT LW_INPUT_DATA$,MAT OPENSTRING$,1)
15332          else if FUNCTION = LW_SCANFORM then ! #Case# Lw_Scanform
15334             let FNSEARCHFORM(MAT LW_INPUT_DATA$,1)
15336          else if FUNCTION = LW_SCANDIM then ! #Case# Lw_Scandim
15338             let FNSEARCHDIM(MAT LW_INPUT_DATA$,1)
15340          else if FUNCTION = LW_SCANALL then ! #Case# Lw_Scanall
15342             let FNSCANALL(MAT LW_INPUT_DATA$,MAT OPENSTRING$)
15344          else if FUNCTION = LW_CLEARALL then ! #Case# Lw_Clearall
15346             mat OPENSTRING$(1)=("")
15348             let LW_INPUT_DATA$(LW_READSTRING)=""
15350             let LW_INPUT_DATA$(LW_FORMSTRING)=""
15352             let LW_INPUT_DATA$(LW_DIMSTRING)=""
15354          else if FUNCTION = LW_PASTEOPEN then ! #Case# Lw_Pasteopen
15356             mat OPENSTRING$(0)
15358             let SD_DIM$=ENV$("clipboard")
15360             let SD_DIM$=SREP$(SD_DIM$,CHR$(13),CHR$(10))
15362             let SD_DIM$=SREP$(SD_DIM$,CHR$(10)&CHR$(10),CHR$(10))
15364             do WHILE POS(SD_DIM$,CHR$(10))
15366                mat OPENSTRING$(UDIM(MAT OPENSTRING$)+1)
15368                let OPENSTRING$(UDIM(MAT OPENSTRING$))=TRIM$(SD_DIM$(1:POS(SD_DIM$,CHR$(10))-1))
15370                let SD_DIM$(1:POS(SD_DIM$,CHR$(10)))=""
15372             loop 
15374             if LEN(TRIM$(SD_DIM$)) then 
15376                mat OPENSTRING$(UDIM(MAT OPENSTRING$)+1)
15378                let OPENSTRING$(UDIM(MAT OPENSTRING$))=TRIM$(SD_DIM$)
15380                let SD_DIM$=""
15382             end if 
15384          else if FUNCTION = LW_OPENSCRATCHPAD then ! #Case# Lw_Openscratchpad
15386             let FNOPENSCRATCHFILE
15388          else if FUNCTION = LW_GENERATE then ! #Case# Lw_Generate
15390             let EXITMODE=FNGENERATELAY(MAT OPENSTRING$,LW_INPUT_DATA$(LW_READSTRING),LW_INPUT_DATA$(LW_FORMSTRING),LW_INPUT_DATA$(LW_DIMSTRING),1)
15392          end if  ! #End Select#
15394 ! 
15396       loop UNTIL EXITMODE
15398 ! 
15400       close #WINDOW: 
15402    fnend 
15404 ! 
15406    def FNSCANALL(MAT LW_INPUT_DATA$,MAT OPENSTRING$)
15408       if FNISEMPTYS(MAT OPENSTRING$) then let FNSEARCHOPENSTRING(MAT LW_INPUT_DATA$,MAT OPENSTRING$,1)
15410       let FNSEARCHREAD(MAT LW_INPUT_DATA$,MAT OPENSTRING$,1)
15412       let FNSEARCHFORM(MAT LW_INPUT_DATA$,1)
15414       let FNSEARCHDIM(MAT LW_INPUT_DATA$,1)
15416    fnend 
15418 ! 
15420 ! .! 1) Program Name - Search all programs for open statements for the given file name
15422 ! .! if found, return program name and open statements
15424    dim FILELIST$(1)*255, SP_FILENAME$(1)*255
15426    def FNSEARCHPROGRAMS(MAT OPENSTRING$,FOLDER$*255;___,INDEX,OPENINDEX,FILENAME$*255,FILEINDEX,G$)
15428       if POS(FOLDER$,"\") then let FOLDER$=FOLDER$(1:POS(FOLDER$,"\",-1)-1)
15430       mat SP_FILENAME$(0)
15432       for OPENINDEX=1 to UDIM(MAT OPENSTRING$)
15434          let FILENAME$=LWRC$(TRIM$(FNEXTRACTFILENAME$(OPENSTRING$(OPENINDEX))))
15436          if LEN(FILENAME$) AND SRCH(MAT SP_FILENAME$,FILENAME$)<=0 then 
15438             let FILEINDEX=UDIM(MAT SP_FILENAME$)+1
15440             mat SP_FILENAME$(FILEINDEX)
15442             let SP_FILENAME$(FILEINDEX)=FILENAME$
15444          end if 
15446       next OPENINDEX
15448 ! 
15450       if UDIM(MAT SP_FILENAME$) then 
15452 ! 
15454          mat FILELIST$(0)
15456          let FNREADFILES(MAT FILELIST$,TRIM$(FOLDER$),"br ",1,0,1)
15458          let FNREADFILES(MAT FILELIST$,TRIM$(FOLDER$),"wb ",0,0,1)
15460 ! 
15462          for INDEX=1 to UDIM(MAT FILELIST$)
15464             if LWRC$(TRIM$(FILELIST$(INDEX)))<>"screenio.br" then 
15466                let FNBUILDPROC("load """&TRIM$(FOLDER$)&"\"&TRIM$(FILELIST$(INDEX))&"""")
15468                let G$=">"
15470                for FILEINDEX=1 to UDIM(MAT SP_FILENAME$)
15472                   let FNBUILDPROC("list 'open' '"&SP_FILENAME$(FILEINDEX)&"' "&G$&"temp.[wsid]")
15474                   let G$=">>"
15476                next FILEINDEX
15478                let FNBUILDPROC("run srchhelp")
15480                let FNBUILDPROC("skip "&STR$(UDIM(MAT SP_FILENAME$)*2+4)&" if code")
15482                let FNPROCPRINTTOFILE(TRIM$(FOLDER$)&"\"&TRIM$(FILELIST$(INDEX)))
15484                let FNBUILDPROC("load """&TRIM$(FOLDER$)&"\"&TRIM$(FILELIST$(INDEX))&"""")
15486                for FILEINDEX=1 to UDIM(MAT SP_FILENAME$)
15488                   let FNPROCLISTTOFILE("'open' '"&SP_FILENAME$(FILEINDEX)&"'")
15490                next FILEINDEX
15492             end if 
15494          next INDEX
15496          let FNPROCSHOWFILE
15498          let FNRUNPROC
15500       end if 
15502    fnend 
15504 ! 
15506    dim RESULTSTRING$*800,SO_FILENAME$*127,SO_RESULTS$(1)*800,SO_FILES$(1)*127,SO_COUNT(1)
15508 ! 
15510 ! .! 2) Open String - list all "open" and "internal" statements
15512    def FNSEARCHOPENSTRING(MAT LW_INPUT_DATA$,MAT OPENSTRING$;DONTSHOWFILE,___,RESULTSFILE,INDEX,LARGEST,LARGEINDEX,JNDEX)
15514       if LEN(TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))) then 
15516          let FNBUILDPROC("load """&TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))&"""")
15518          let FNPROCLISTTOFILE("'open' 'internal'")
15520          if ~DONTSHOWFILE then let FNPROCSHOWFILE
15522          let FNCLEARTEMPFILE
15524          let FNRUNPROC
15526 ! 
15528          if EXISTS("work.[wsid]") then 
15530             open #(RESULTSFILE:=FNGETFILENUMBER): "name=work.[wsid],recl=800",display,input 
15532             mat SO_RESULTS$(0) : mat SO_FILES$(0) : mat SO_COUNT(0)
15534             do UNTIL FILE(RESULTSFILE)
15536                linput #RESULTSFILE: RESULTSTRING$ error Ignore
15538                if FILE(RESULTSFILE)=0 then 
15540                   let SO_FILENAME$=LWRC$(TRIM$(FNEXTRACTFILENAME$(RESULTSTRING$)))
15542                   if LEN(SO_FILENAME$) then 
15544                      let INDEX=UDIM(MAT SO_RESULTS$)+1
15546                      mat SO_RESULTS$(INDEX)
15548                      let SO_RESULTS$(INDEX)=TRIM$(RESULTSTRING$)
15550                      let INDEX=SRCH(MAT SO_FILES$,SO_FILENAME$)
15552                      if INDEX>0 then 
15554                         let SO_COUNT(INDEX)+=1
15556                      else 
15558                         let INDEX=UDIM(MAT SO_FILES$)+1
15560                         mat SO_FILES$(INDEX) : mat SO_COUNT(INDEX)
15562                         let SO_FILES$(INDEX)=SO_FILENAME$
15564                         let SO_COUNT(INDEX)+=1
15566                      end if 
15568                   end if 
15570                end if 
15572             loop 
15574             close #RESULTSFILE: 
15576 ! 
15578             for INDEX=1 to UDIM(MAT SO_COUNT)
15580                if SO_COUNT(INDEX)>LARGEST then 
15582                   let LARGEST=SO_COUNT(INDEX)
15584                   let LARGEINDEX=INDEX
15586                end if 
15588             next INDEX
15590 ! 
15592             let JNDEX=0
15594             for INDEX=1 to UDIM(MAT SO_RESULTS$)
15596                if SO_FILES$(LARGEINDEX)=LWRC$(TRIM$(FNEXTRACTFILENAME$(SO_RESULTS$(INDEX)))) then 
15598                   let JNDEX+=1
15600                   let SO_RESULTS$(JNDEX)=SO_RESULTS$(INDEX)
15602                end if 
15604             next INDEX
15606             mat SO_RESULTS$(JNDEX)
15608             if JNDEX then 
15610                mat OPENSTRING$(JNDEX)=SO_RESULTS$
15612             end if 
15614          end if 
15616       end if 
15618    fnend 
15620 ! 
15622 ! 
15624 ! .! 3) Read Statement - Parse Open String, look for file number
15626 ! .! or variable name. list all read statements with that file
15628 ! .! number or variable name
15630    dim VAR$*255
15632    def FNSEARCHREAD(MAT LW_INPUT_DATA$,MAT OPENSTRING$;DONTSHOWFILE,___,KEYINDEX,ANYTHING,RESULTSFILE,LARGEST,LARGEINDEX)
15634       if LEN(TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))) then 
15636 ! 
15638          for KEYINDEX=1 to UDIM(MAT OPENSTRING$)
15640 ! .         ! parse the open statements
15642             if LEN(TRIM$(OPENSTRING$(KEYINDEX))) then 
15644                let VAR$=FNEXTRACTOPENVAR$(OPENSTRING$(KEYINDEX)) ! Attempt To Find Open Variable
15646                let FNBUILDPROC("load """&TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))&"""")
15648                let FNPROCLISTTOFILE("'read' '#"&VAR$&"'")
15650                let ANYTHING=1
15652             end if 
15654          next KEYINDEX
15656 ! 
15658          if ~ANYTHING then 
15660 ! .         ! Scan the given file for all read statements if Open string didn't work
15662             let FNBUILDPROC("load """&TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))&"""")
15664             let FNPROCLISTTOFILE("'read'")
15666          end if 
15668 ! 
15670          if ~DONTSHOWFILE then let FNPROCSHOWFILE
15672          let FNCLEARTEMPFILE
15674          let FNRUNPROC
15676 ! 
15678          if EXISTS("work.[wsid]") then 
15680             open #(RESULTSFILE:=FNGETFILENUMBER): "name=work.[wsid],recl=800",display,input 
15682             mat SO_RESULTS$(0)
15684             do UNTIL FILE(RESULTSFILE)
15686                linput #RESULTSFILE: RESULTSTRING$ error Ignore
15688                if FILE(RESULTSFILE)=0 then 
15690                   let INDEX=UDIM(MAT SO_RESULTS$)+1
15692                   mat SO_RESULTS$(INDEX)
15694                   let SO_RESULTS$(INDEX)=TRIM$(RESULTSTRING$)
15696                   if LEN(SO_RESULTS$(INDEX))>LARGEST then 
15698                      let LARGEST=LEN(SO_RESULTS$(INDEX))
15700                      let LARGEINDEX=INDEX
15702                   end if 
15704                end if 
15706             loop 
15708             close #RESULTSFILE: 
15710             if LARGEINDEX then let LW_INPUT_DATA$(LW_READSTRING)=SO_RESULTS$(LARGEINDEX)
15712          end if 
15714       end if 
15716    fnend 
15718 ! 
15720 ! 
15722 ! .! 4) Form Statement - Parse Read Statement, look for "Using lineref". If lineref is not a variable,
15724 ! .! (doesn't contain a "$"), then list that line. If it does contain a dollar sign, then list that
15726 ! .! variable to see where it gets set.
15728    dim LINEREF$*512
15730    def FNSEARCHFORM(MAT LW_INPUT_DATA$;DONTSHOWFILE,___,NOPROC,INDEX,LARGEINDEX,LARGEST,RESULTSFILE)
15732       if LEN(TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))) then 
15734          if LEN(TRIM$(LW_INPUT_DATA$(LW_READSTRING))) then 
15736             let LINEREF$=FNEXTRACTLINEREF$(LW_INPUT_DATA$(LW_READSTRING)) ! Attempt To Find Read String
15738             if LWRC$(LINEREF$(1:5))="""form" then 
15740                let LW_INPUT_DATA$(LW_FORMSTRING)=TRIM$(LINEREF$,"""")
15742                let NOPROC=1
15744             else if POS(LINEREF$,"$") then 
15746                let FNBUILDPROC("load """&TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))&"""")
15748                let FNBUILDPROC("list '"&LINEREF$&"' >temp.[wsid]") ! Attempt To Use Line Ref
15750                let FNBUILDPROC("run srchhelp") ! Check If It Worked
15752                let FNBUILDPROC("skip printregular if code") ! If It Failed, Jump To Regular Print
15754                let FNBUILDPROC("load """&TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))&"""") ! If It Worked, Then Use It
15756                let FNPROCLISTTOFILE(LINEREF$)
15758                let FNBUILDPROC("skip finished") ! Skip Regular Print If It Worked
15760             else 
15762                let FNBUILDPROC("load """&TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))&"""")
15764                let FNBUILDPROC("list "&LINEREF$&" >temp.[wsid]") ! Attempt To Use Line Ref
15766                let FNBUILDPROC("run srchhelp") ! Check If It Worked
15768                let FNBUILDPROC("skip printregular if code") ! If It Failed, Jump To Regular Print
15770                let FNBUILDPROC("load """&TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))&"""") ! If It Worked, Then Use It
15772                let FNPROCLISTTOFILE(LINEREF$,1)
15774                let FNBUILDPROC("skip finished") ! Skip Regular Print If It Worked
15776             end if 
15778          end if 
15780          if ~NOPROC then 
15782             let FNBUILDPROC(":printregular")
15784             let FNBUILDPROC("load """&TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))&"""")
15786             let FNPROCLISTTOFILE("form")
15788             let FNBUILDPROC(":finished")
15790             if ~DONTSHOWFILE then let FNPROCSHOWFILE
15792             let FNCLEARTEMPFILE
15794             let FNRUNPROC
15796 ! 
15798             if EXISTS("work.[wsid]") then 
15800                open #(RESULTSFILE:=FNGETFILENUMBER): "name=work.[wsid],recl=800",display,input 
15802                mat SO_RESULTS$(0)
15804                do UNTIL FILE(RESULTSFILE)
15806                   linput #RESULTSFILE: RESULTSTRING$ error Ignore
15808                   if FILE(RESULTSFILE)=0 then 
15810                      let INDEX=UDIM(MAT SO_RESULTS$)+1
15812                      mat SO_RESULTS$(INDEX)
15814                      let SO_RESULTS$(INDEX)=TRIM$(RESULTSTRING$)
15816                      if LEN(SO_RESULTS$(INDEX))>LARGEST then 
15818                         let LARGEST=LEN(SO_RESULTS$(INDEX))
15820                         let LARGEINDEX=INDEX
15822                      end if 
15824                   end if 
15826                loop 
15828                close #RESULTSFILE: 
15830                if LARGEINDEX then let LW_INPUT_DATA$(LW_FORMSTRING)=SO_RESULTS$(LARGEINDEX)
15832             end if 
15834 ! 
15836          end if 
15838       end if 
15840    fnend 
15842 ! 
15844    dim SD_ARRAYS$(1)*127
15846    dim SD_DIM$*20000
15848 ! 
15850 ! .! 5) Dim Statement - Parse Read Statement, look for any "Mat" variables. for each one thats found, load
15852 ! .! the program, list 'dim' 'arrayname'. If no read statement, list all dims
15854    def FNSEARCHDIM(MAT LW_INPUT_DATA$;DONTSHOWFILE,___,TPOS,STRING$*999,SPOS,CPOS,XPOS,INDEX,RESULTSFILE)
15856       if LEN(TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))) then 
15858          let FNBUILDPROC("load """&TRIM$(LW_INPUT_DATA$(LW_PROGRAMNAME))&"""")
15860          if LEN(TRIM$(LW_INPUT_DATA$(LW_READSTRING))) then 
15862             mat SD_ARRAYS$(0)
15864             let TPOS=0
15866             let STRING$=LWRC$(TRIM$(LW_INPUT_DATA$(LW_READSTRING)))
15868             do WHILE (TPOS:=POS(STRING$,"mat"))
15870                let CPOS=POS(STRING$,",",TPOS+4)
15872                let SPOS=POS(STRING$," ",TPOS+4)
15874                if CPOS AND SPOS then 
15876                   let XPOS=MIN(CPOS,SPOS) ! Whichever Comes First
15878                else 
15880                   let XPOS=MAX(CPOS,SPOS) ! Whichever One There Is
15882                end if 
15884                if ~XPOS then let XPOS=LEN(STRING$)+1 ! The Rest Of The String
15886 ! 
15888                let VAR$=TRIM$(STRING$(TPOS+3:XPOS-1))
15890                let STRING$=STRING$(XPOS-1:LEN(STRING$))
15892                let FNPROCLISTTOFILE("'dim' '"&VAR$&"('")
15894                let INDEX=UDIM(MAT SD_ARRAYS$)+1
15896                mat SD_ARRAYS$(INDEX)
15898                let SD_ARRAYS$(INDEX)=VAR$
15900             loop 
15902          else 
15904             let FNPROCLISTTOFILE("dim")
15906          end if 
15908          if ~DONTSHOWFILE then let FNPROCSHOWFILE
15910          let FNCLEARTEMPFILE
15912          let FNRUNPROC
15914 ! 
15916          if EXISTS("work.[wsid]") then 
15918             open #(RESULTSFILE:=FNGETFILENUMBER): "name=work.[wsid],recl=800",display,input 
15920             let SD_DIM$=""
15922             do UNTIL FILE(RESULTSFILE)
15924                linput #RESULTSFILE: RESULTSTRING$ error Ignore
15926                if FILE(RESULTSFILE)=0 then 
15928                   let SD_DIM$=SD_DIM$&LWRC$(TRIM$(RESULTSTRING$))
15930                end if 
15932             loop 
15934             let LW_INPUT_DATA$(LW_DIMSTRING)="dim "
15936             for INDEX=1 to UDIM(MAT SD_ARRAYS$)
15938                let LW_INPUT_DATA$(LW_DIMSTRING)=LW_INPUT_DATA$(LW_DIMSTRING)&SD_ARRAYS$(INDEX)&"("&STR$(FNREADARRAYSIZE(SD_DIM$,SD_ARRAYS$(INDEX)))&"), "
15940             next INDEX
15942             close #RESULTSFILE: 
15944          end if 
15946       end if 
15948    fnend 
15950 ! 
15952 ! 
15954    def FNREADFILES(MAT FILES$,FOLDER$*255;EXTENSION$,CLEARARRAY,CREATEFOLDER,INCLUDEEXTENSIONS,___,DIRFILE,DUMMY$*255,DIRMASK$*400,STAR$)
15956       let STAR$=FNNEEDSTAR$
15958       if CLEARARRAY then mat FILES$(0)
15960 ! 
15962       if CREATEFOLDER then 
15964          if ~EXISTS(FOLDER$) then execute STAR$&"mkdir "&FOLDER$
15966       end if 
15968 ! 
15970       if ~LEN(TRIM$(EXTENSION$)) then let EXTENSION$="*"
15972 ! 
15974       let DIRMASK$=FOLDER$&"\*."&LWRC$(EXTENSION$)
15976 ! 
15978       execute STAR$&"dir "&DIRMASK$&" >dirlist.[SESSION]" error Ignore
15980       open #(DIRFILE:=FNGETFILENUMBER) : "Name=dirlist.[SESSION]", display,input 
15982       do 
15984          linput #DIRFILE: DUMMY$ eof Ignore
15986          if FILE(DIRFILE)=0 AND ~POS(DUMMY$,"<DIR>") then 
15988             if EXTENSION$="*" OR UPRC$(DUMMY$(11:13))=UPRC$(EXTENSION$) then 
15990                mat FILES$(UDIM(FILES$)+1) !:
                     let FILES$(UDIM(FILES$))=LWRC$(TRIM$(DUMMY$(44:99))(1:32))
15992                if POS(LWRC$(FILES$(UDIM(FILES$))),".")>0 then 
15994                   let FILES$(UDIM(FILES$))=FILES$(UDIM(FILES$))(1:POS(LWRC$(FILES$(UDIM(FILES$))),".")-1)
15996                   if INCLUDEEXTENSIONS then 
15998                      let FILES$(UDIM(FILES$))=FILES$(UDIM(FILES$))&"."&EXTENSION$
16000                   end if 
16002                end if 
16004             end if 
16006          end if 
16008       loop WHILE FILE(DIRFILE)=0
16010       close #DIRFILE: 
16012       execute STAR$&"free dirlist.[SESSION]"
16014    fnend 
16016 ! 
16018    def FNEXTRACTFILENAME$*255(&OPENSTRING$;___,TPOS)
16020       let TPOS=POS(LWRC$(OPENSTRING$),"name=")
16022       if TPOS then 
16024          let FNEXTRACTFILENAME$=OPENSTRING$(TPOS+5:POS(LWRC$(OPENSTRING$),",",TPOS+5)-1)
16026       end if 
16028    fnend 
16030 ! 
16032    def FNEXTRACTKEYFILENAME$*255(&OPENSTRING$;___,TPOS)
16034       let TPOS=POS(LWRC$(OPENSTRING$),"kfname=")
16036       if TPOS then 
16038          let FNEXTRACTKEYFILENAME$=OPENSTRING$(TPOS+7:POS(LWRC$(OPENSTRING$),",",TPOS+7)-1)
16040       end if 
16042    fnend 
16044 ! 
16046    def FNEXTRACTOPENVAR$*512(&OPENSTRING$;___,VAR$*512,INDEX,TPOS,RETURN$*512)
16048       let TPOS=POS(OPENSTRING$,"#")
16050       let VAR$=OPENSTRING$(TPOS:POS(OPENSTRING$,":",TPOS+1))
16052 ! 
16054 ! .   ! Skip past any junk characters such as ( and " "
16056       do UNTIL (INDEX:=INDEX+1)>LEN(VAR$)
16058       loop UNTIL POS("0123456789abcdefghijklmnopqrstuvwxyz",LWRC$(VAR$(INDEX:INDEX)))
16060 ! 
16062 ! .   ! read the first contiguous string of characters thats either a number or a variable
16064       do WHILE INDEX<=LEN(VAR$) AND POS("0123456789abcdefghijklmnopqrstuvwxyz",LWRC$(VAR$(INDEX:INDEX)))
16066          let RETURN$=RETURN$&VAR$(INDEX:INDEX)
16068          let INDEX+=1
16070       loop 
16072       let FNEXTRACTOPENVAR$=RETURN$
16074    fnend 
16076 ! 
16078    def FNEXTRACTLINEREF$*512(&READSTRING$;___,VAR$*512,INDEX,TPOS,RETURN$*512,BQUOTESON)
16080       let TPOS=POS(LWRC$(READSTRING$),"using")
16082       let VAR$=TRIM$(READSTRING$(TPOS+5:LEN(READSTRING$)))
16084 ! 
16086       do WHILE (INDEX:=INDEX+1)<=LEN(VAR$)
16088          if VAR$(INDEX:INDEX)="""" then let BQUOTESON=~BQUOTESON
16090          let RETURN$=RETURN$&VAR$(INDEX:INDEX)
16092       loop UNTIL (~BQUOTESON AND (VAR$(INDEX:INDEX)=="," OR VAR$(INDEX:INDEX)==":"))
16094       if RETURN$(LEN(RETURN$):LEN(RETURN$))="," then let RETURN$=RETURN$(1:LEN(RETURN$)-1)
16096       if RETURN$(LEN(RETURN$):LEN(RETURN$))=":" then let RETURN$=RETURN$(1:LEN(RETURN$)-1)
16098       let FNEXTRACTLINEREF$=TRIM$(RETURN$)
16100    fnend 
16102 ! 
16104 ! .! Proc File Engine
16106 ! .! **********************
16108    dim PROCFILENUMBER, PROCCOMPILENUMBER
16110 ! 
16112 Trynextnumber: ! Try A New Number
16114    let COMPILENUMBER+=1
16116    retry 
16118 ! 
16120    def FNOPENPROC
16122       open #(PROCFILENUMBER:=FNGETFILENUMBER): "name=compile"&STR$(COMPILENUMBER)&".$$$, replace", display, output error Trynextnumber
16124       print #PROCFILENUMBER: "proc noecho"
16126    fnend 
16128 ! 
16130    def FNBUILDSRCHHELP(;NOWAIT)
16132       if ~EXISTS("srchhelp.br") then 
16134          let FNBUILDPROC("00010 DIM RECORD$*800")
16136          let FNBUILDPROC("00020 OPEN #1: ""Name= temp.[wsid]"", DISPLAY, INPUT")
16138          let FNBUILDPROC("00030 LINPUT #1: RECORD$ EOF STOP1")
16140          let FNBUILDPROC("00040 STOP")
16142          let FNBUILDPROC("00050 STOP1: STOP 1")
16144          let FNBUILDPROC("save srchhelp.br")
16146          let FNRUNPROC(NOWAIT)
16148       end if 
16150    fnend 
16152 ! 
16154    def library FNBUILDPROCFILE(STRING$*255)=FNBUILDPROC(STRING$)
16156    def FNBUILDPROC(STRING$*255)
16158       if ~PROCFILENUMBER then let FNOPENPROC
16160       print #PROCFILENUMBER: STRING$
16162    fnend 
16164 ! 
16166    def library FNRUNPROCFILE(;NOWAIT)=FNRUNPROC(NOWAIT)
16168    def FNRUNPROC(;NOWAIT,___,C$,STAR$)
16170       let STAR$=FNNEEDSTAR$
16172       if PROCFILENUMBER then 
16174          print #PROCFILENUMBER: "system"
16176          close #PROCFILENUMBER: 
16178          let PROCFILENUMBER=0
16180          if NOWAIT then let C$=" -C"
16182 ! .      ! execute "type compile"&str$(CompileNumber)&".$$$"
16184 ! .      ! pause
16186          execute STAR$&"system"&C$&" -M "&FNGETBREXE$&" -"&FNGETWBCFG$&" proc compile"&STR$(COMPILENUMBER)&".$$$"
16188       end if 
16190    fnend 
16192 ! 
16194    def FNPROCPRINTTOFILE(STRING$*255)
16196       let FNBUILDPROC("open #1: ""name=filelay\scratchpaper.brs"",display,output")
16198       let FNBUILDPROC("print #1: """&STRING$&"""")
16200       let FNBUILDPROC("close #1: ")
16202    fnend 
16204    def FNPROCLISTTOFILE(STRING$*255;DONTADDQUOTES)
16206       if ~DONTADDQUOTES then 
16208          if STRING$(1:1)<>"'" then let STRING$(1:0)="'"
16210          if STRING$(LEN(STRING$):LEN(STRING$))<>"'" then let STRING$=STRING$&"'"
16212       end if 
16214       let FNBUILDPROC("list "&STRING$&" >>filelay\scratchpaper.brs")
16216       let FNBUILDPROC("list "&STRING$&" >>work."&WSID$) ! Use This Wsid, Not The Procs Wsid
16218    fnend 
16220    def FNCLEARTEMPFILE
16222       if EXISTS ("work.[WSID]") then execute FNNEEDSTAR$&"free work.[WSID]"
16224    fnend 
16226    def FNPROCSHOWFILE
16228       let FNBUILDPROC(FNNEEDSTAR$&"system -C -M start filelay\scratchpaper.brs")
16230    fnend 
16232    def FNOPENSCRATCHFILE
16234       execute FNNEEDSTAR$&"system -C -M start filelay\scratchpaper.brs"
16236    fnend 
16238 ! 
16240 ! **********************************************************************
16242 ! Functions To Get Info From Config.Sys Files. By Susan Smith.
16244 !  Updated By Gabriel Bakker, To Save Time By Running Only Once.
16246 ! 
16248    dim CONFIGFILE$*300
16250    dim EXECUTABLEFILE$*300
16252 ! 
16254    def FNGETWBCFG$*255
16256       if CONFIGFILE$="" then 
16258          let FNREADCONFIGANDEXE
16260       end if 
16262       let FNGETWBCFG$=CONFIGFILE$
16264    fnend 
16266 ! 
16268    def FNGETBREXE$*255
16270       if EXECUTABLEFILE$="" then 
16272          let FNREADCONFIGANDEXE
16274       end if 
16276       let FNGETBREXE$=EXECUTABLEFILE$
16278    fnend 
16280 ! 
16282    dim CONFIGSTAT$*30000
16284    def FNREADCONFIGANDEXE(;___,CR$,FILENUMBER,QSTART,QEND,STAR$)
16286       let STAR$=FNNEEDSTAR$
16288       let CR$=HEX$("0D0A")
16290       execute STAR$&"status files >TEMPFILE.[session]"
16292       if EXISTS("TEMPFILE.[session]") then 
16294          open #(FILENUMBER:=FNGETFILENUMBER): "name=TEMPFILE.[session],eol=none",display,input error Ignore
16296          if ~FILE(FILENUMBER) then 
16298             linput #FILENUMBER: CONFIGSTAT$
16300             close #FILENUMBER: 
16302 ! 
16304             let QSTART=POS(UPRC$(CONFIGSTAT$),"CONFIG FILE")
16306             if QSTART>0 then 
16308                let CONFIGFILE$=CONFIGSTAT$(QSTART+13:QSTART+300)
16310                let QEND=POS(CONFIGFILE$,CR$)
16312                let CONFIGFILE$=CONFIGFILE$(1:QEND-1)
16314                if CONFIGFILE$(1:1)=":" then let CONFIGFILE$=OS_FILENAME$(CONFIGFILE$)
16316             end if 
16318 ! 
16320             let QSTART=POS(UPRC$(CONFIGSTAT$),"EXECUTABLE FILE")
16322             if QSTART>0 then 
16324                let EXECUTABLEFILE$=CONFIGSTAT$(QSTART+17:QSTART+300)
16326                let QEND=POS(EXECUTABLEFILE$,CR$)
16328                let EXECUTABLEFILE$=EXECUTABLEFILE$(1:QEND-1)
16330                if EXECUTABLEFILE$(1:1)=":" then let EXECUTABLEFILE$=OS_FILENAME$(EXECUTABLEFILE$)
16332             end if 
16334          end if 
16336       end if 
16338       if EXISTS("c:\TEMPFILE.[session]") then execute STAR$&"free TEMPFILE.[session] -N"
16340    fnend 
16342 ! 
16344 ! 
16346    dim GL_FILENAME$*127,GL_VER,GL_PRE$, GL_RECL, GL_NAME$*127
16348    dim GL_KFNAME$(1)*127,GL_KPOS$(1)*50,GL_KLEN$(1)*50,GL_KDESCRIPTION$(1)*255
16350    dim GL_SUBS$(1)*127,GL_DESCR$(1)*127,GL_FORM$(1)*50,GL_EXTRA$(1)*255
16352    dim GL_TEMPSUBS$(1)*127,GL_TEMPDESCR$(1)*127,GL_TEMPFORM$(1)*50,GL_MAPPING(1)
16354 ! 
16356    dim GL_KFNAME$*127
16358    dim GL_ERRORMESSAGE$*512
16360    dim GL_TEMPFILENAME$*127
16362 ! 
16364    def library FNGENERATELAYOUT(MAT OPENSTRING$,READSTRING$*999,FORMSTRING$*2000,DIMSTRING$*999;DISPLAYFILE)=FNGENERATELAY(MAT OPENSTRING$,READSTRING$,FORMSTRING$,DIMSTRING$,DISPLAYFILE)
16366    def FNGENERATELAY(MAT OPENSTRING$,READSTRING$*999,FORMSTRING$*2000,DIMSTRING$*999;DISPLAYFILE,___,INDEX,TFILE,TPOS,KEYINDEX,SIZE,JNDEX,FAILEDREAD,FAILEDFORM,FAILEDMATCH,FAILEDHEADER,FAILEDKEY,FPOS,WIDTH,KPPOS,KLPOS,KPOS,KLEN)
16368 ! 
16370 ! .   ! Attempt to parse data, or at least get as far as we can
16372 ! .   !  Give error message when we get stuck
16374 ! .   !  Generate the layout with success message when it works
16376 ! .   !  Return ExitMode when success
16378 ! 
16380 ! .   ! Eventually we can call this code from a function that
16382 ! .   !  searches someones software suite.
16384 ! 
16386 ! .   ! Clear values
16388       mat GL_KFNAME$(0) : mat GL_KPOS$(0)
16390       mat GL_KLEN$(0) : mat GL_KDESCRIPTION$(0)
16392       let GL_FILENAME$=GL_PRE$=GL_NAME$=""
16394       let GL_KFNAME$=GL_ERRORMESSAGE$=GL_TEMPFILENAME$=""
16396       let GL_VER=GL_RECL=0
16398 ! 
16400       let KEYINDEX=0
16402 ! 
16404       for OPENINDEX=1 to UDIM(MAT OPENSTRING$)
16406 ! .      ! Parse Open String
16408          if LEN(OPENSTRING$(OPENINDEX)) then 
16410             let GL_TEMPFILENAME$=FNEXTRACTFILENAME$(OPENSTRING$(OPENINDEX))
16412             if ~LEN(GL_FILENAME$) then let GL_FILENAME$=GL_TEMPFILENAME$
16414 ! 
16416             if LEN(GL_FILENAME$) AND GL_FILENAME$=GL_TEMPFILENAME$ then 
16418                let GL_KFNAME$=FNEXTRACTKEYFILENAME$(OPENSTRING$(OPENINDEX))
16420 ! 
16422                if LEN(GL_KFNAME$) then 
16424                   open #(TFILE:=FNGETFILENUMBER): "name="&GL_FILENAME$&", kfname="&GL_KFNAME$, internal, input, keyed error Ignore
16426                   let KEYINDEX=UDIM(MAT GL_KFNAME$)+1
16428                   mat GL_KFNAME$(KEYINDEX) : mat GL_KPOS$(KEYINDEX)
16430                   mat GL_KLEN$(KEYINDEX) : mat GL_KDESCRIPTION$(KEYINDEX)
16432                   let GL_KFNAME$(KEYINDEX)=GL_KFNAME$
16434                else 
16436                   open #(TFILE:=FNGETFILENUMBER): "name="&GL_FILENAME$, internal, input, relative error Ignore
16438                end if 
16440 ! 
16442                if FILE(TFILE)=0 then 
16444                   let GL_VER=VERSION(TFILE)
16446                   let GL_NAME$=GL_FILENAME$(POS(GL_FILENAME$,"\",-1):LEN(GL_FILENAME$))
16448                   if POS(GL_NAME$,".") then 
16450                      let GL_NAME$=GL_NAME$(1:POS(GL_NAME$,".")-1)
16452                   end if 
16454                   let GL_NAME$=GL_NAME$(1:18)
16456                   let GL_PRE$=TRIM$(GL_NAME$)(1:17)&"_"
16458                   let GL_RECL=RLN(TFILE)
16460                   if KPS(TFILE)>-1 then 
16462                      let GL_KPOS$(KEYINDEX)=""
16464                      let GL_KLEN$(KEYINDEX)=""
16466                      let INDEX=0
16468                      do WHILE KPS(TFILE,(INDEX:=INDEX+1))>-1
16470                         let GL_KPOS$(KEYINDEX)=GL_KPOS$(KEYINDEX)&STR$(KPS(TFILE,INDEX))&"/"
16472                         let GL_KLEN$(KEYINDEX)=GL_KLEN$(KEYINDEX)&STR$(KLN(TFILE,INDEX))&"/"
16474                      loop 
16476                      let GL_KPOS$(KEYINDEX)=GL_KPOS$(KEYINDEX)(1:LEN(GL_KPOS$(KEYINDEX))-1)
16478                      let GL_KLEN$(KEYINDEX)=GL_KLEN$(KEYINDEX)(1:LEN(GL_KLEN$(KEYINDEX))-1)
16480                   end if 
16482                   close #TFILE: 
16484                end if 
16486             end if 
16488          end if 
16490       next OPENINDEX
16492 ! 
16494       if ~LEN(GL_FILENAME$) then let FAILEDHEADER=1
16496 ! 
16498       mat GL_TEMPSUBS$(0) : mat GL_TEMPDESCR$(0) : mat GL_TEMPFORM$(0) : mat GL_MAPPING(0)
16500       mat GL_SUBS$(0) : mat GL_DESCR$(0) : mat GL_FORM$(0) : mat GL_EXTRA$(0)
16502       if LEN(READSTRING$) AND LEN(FORMSTRING$) then 
16504 ! 
16506 ! .      ! Parse Read String
16508 ! .      ! unpack read string
16510 ! .      ! search in form string for each array
16512 ! .      ! use array size from form string to expand each array into one giant list of subscripts
16514          let TPOS=POS(READSTRING$,":")
16516          do WHILE LEN(VAR$:=FNEXTRACTCHUNK$(READSTRING$,TPOS))
16518             if LWRC$(VAR$(1:3))="mat" then 
16520                let SIZE=FNREADARRAYSIZE(DIMSTRING$,VAR$(5:LEN(VAR$)))
16522                if SIZE then 
16524                   let INDEX=UDIM(MAT GL_TEMPSUBS$)
16526                   mat GL_TEMPSUBS$(INDEX+SIZE) : mat GL_TEMPDESCR$(INDEX+SIZE)
16528                   for JNDEX=INDEX+1 to INDEX+SIZE
16530                      if POS(VAR$,"$") then 
16532                         let GL_TEMPSUBS$(JNDEX)=SREP$(VAR$(5:LEN(VAR$)),"$","")&STR$(JNDEX-INDEX)&"$"
16534                      else 
16536                         let GL_TEMPSUBS$(JNDEX)=VAR$(5:LEN(VAR$))&STR$(JNDEX-INDEX)
16538                      end if 
16540                      let GL_TEMPDESCR$(JNDEX)=SREP$(VAR$(5:LEN(VAR$)),"$","")&STR$(JNDEX-INDEX)
16542                   next JNDEX
16544                   if POS(VAR$,"$") then 
16546                      let GL_TEMPSUBS$(INDEX+SIZE)=SREP$(VAR$(5:LEN(VAR$)),"$","")&"L$"
16548                   else 
16550                      let GL_TEMPSUBS$(INDEX+SIZE)=VAR$(5:LEN(VAR$))&"L"
16552                   end if 
16554 ! 
16556                else 
16558                   let FAILEDREAD=1
16560                end if 
16562             else 
16564                let INDEX=UDIM(MAT GL_TEMPSUBS$)+1
16566                mat GL_TEMPSUBS$(INDEX) : mat GL_TEMPDESCR$(INDEX)
16568                let GL_TEMPSUBS$(INDEX)=VAR$
16570                let GL_TEMPDESCR$(INDEX)=SREP$(VAR$,"$","")
16572             end if 
16574          loop UNTIL FAILEDREAD
16576 ! 
16578 ! .      ! Parse Form String
16580 ! .      ! 1) Unpack form string
16582          let FNUNPACKFORMSTRING(FORMSTRING$)
16584 ! 
16586          let TPOS=POS(LWRC$(FORMSTRING$),"form ")
16588          if TPOS then let TPOS+=4 else let FAILEDFORM=1
16590 ! 
16592          let FPOS=0
16594 ! 
16596          do WHILE LEN(VAR$:=FNEXTRACTFORM$(FORMSTRING$,TPOS))
16598             if LWRC$(VAR$(1:4))="pos " then 
16600                let FPOS=VAL(VAR$(5:LEN(VAR$)))-1 conv Ignore
16602             else if LWRC$(VAR$(1:2))="x " then 
16604                let FPOS+=VAL(VAR$(3:LEN(VAR$))) conv Ignore
16606             else 
16608                let INDEX=UDIM(MAT GL_TEMPFORM$)+1
16610                mat GL_TEMPFORM$(INDEX)
16612                let GL_TEMPFORM$(INDEX)=VAR$
16614 ! 
16616 ! .            ! Find width
16618                let WIDTH=FNLENGTHOF(VAR$)
16620 ! 
16622                if WIDTH then 
16624 ! .               ! expand Mapping
16626                   mat GL_MAPPING(MAX(UDIM(MAT GL_MAPPING),FPOS+WIDTH))
16628                   mat GL_MAPPING(FPOS+1:FPOS+WIDTH)=(INDEX)
16630                else 
16632                   let FAILEDFORM=1
16634                end if 
16636                let FPOS+=WIDTH
16638             end if 
16640          loop UNTIL FAILEDFORM
16642 ! 
16644          let INDEX=0
16646          let LASTNUM=-1
16648          let STARTPOS=0
16650 ! 
16652 ! .      ! Read Map, find length of consequetive vars
16654          do WHILE (INDEX:=INDEX+1)<=UDIM(MAT GL_MAPPING)+1
16656             if INDEX>UDIM(MAT GL_MAPPING) OR LASTNUM<>GL_MAPPING(INDEX) then 
16658                if LASTNUM<>-1 then 
16660 ! 
16662 ! .               ! Found one, Process it
16664                   let JNDEX=UDIM(MAT GL_SUBS$)+1
16666                   mat GL_SUBS$(JNDEX)
16668                   mat GL_DESCR$(JNDEX)
16670                   mat GL_FORM$(JNDEX)
16672                   mat GL_EXTRA$(JNDEX)
16674 ! 
16676                   if LASTNUM then 
16678                      if INDEX-STARTPOS=FNLENGTHOF(GL_TEMPFORM$(LASTNUM)) then 
16680 ! .                     ! Its good, use it
16682                         if UDIM(MAT GL_TEMPSUBS$)>=LASTNUM then 
16684                            let GL_SUBS$(JNDEX)=GL_TEMPSUBS$(LASTNUM)
16686                            let GL_DESCR$(JNDEX)=GL_TEMPDESCR$(LASTNUM)
16688                         else 
16690                            let GL_SUBS$(JNDEX)="_"
16692                            let GL_DESCR$(JNDEX)=""
16694                         end if 
16696                         let GL_FORM$(JNDEX)=GL_TEMPFORM$(LASTNUM)
16698                      else 
16700 ! .                     ! Error. Set it and return error.
16702                         if UDIM(MAT GL_TEMPSUBS$)>=LASTNUM then 
16704                            let GL_SUBS$(JNDEX)=GL_TEMPSUBS$(LASTNUM)
16706                            let GL_DESCR$(JNDEX)=GL_TEMPDESCR$(LASTNUM)
16708                         else 
16710                            let GL_SUBS$(JNDEX)="_"
16712                            let GL_DESCR$(JNDEX)=""
16714                         end if 
16716                         let GL_FORM$(JNDEX)="C "&STR$(INDEX-STARTPOS)
16718                         let GL_EXTRA$(JNDEX)="Error. Width: "&STR$(INDEX-STARTPOS)&" but Form: "&GL_TEMPFORM$(LASTNUM)
16720                         let FAILEDMATCH=1
16722                      end if 
16724                   else 
16726 ! .                  ! unknown make it an X
16728                      let GL_SUBS$(JNDEX)="_"
16730                      let GL_FORM$(JNDEX)="X "&STR$(INDEX-STARTPOS)
16732                      let GL_DESCR$(JNDEX)="Unknown / Unused"
16734                   end if 
16736                end if 
16738                if INDEX<=UDIM(MAT GL_MAPPING) then let LASTNUM=GL_MAPPING(INDEX)
16740                let STARTPOS=INDEX
16742             end if 
16744          loop 
16746       else 
16748          if ~LEN(READSTRING$) then let FAILEDREAD=1
16750          if ~LEN(FORMSTRING$) then let FAILEDFORM=1
16752       end if 
16754 ! 
16756 ! .   ! Figure out Keys, mat gl_kpos$,mat gl_klen$,mat gl_kDescription$
16758       for KEYINDEX=1 to UDIM(MAT GL_KDESCRIPTION$)
16760 ! .      ! Read each chunk of gl_kPos$ and gl_kLen$
16762          let KPPOS=KLPOS=0
16764          do WHILE (KPOS:=FNEXTRACTKPS(GL_KPOS$(KEYINDEX),KPPOS))
16766             let KLEN=FNEXTRACTKLN(GL_KLEN$(KEYINDEX),KLPOS)
16768             if KLEN then 
16770 ! .            ! must do a reverse lookup against mat gl_Mapping
16772 ! .            ! to calculate mat gl_kDescription$
16774 ! 
16776                let INDEX=KPOS-1
16778                let LASTNUM=-1
16780 ! 
16782 ! .            ! Read Map, find consequetive nums
16784                do WHILE (INDEX:=INDEX+1)<KLEN+KPOS
16786                   if INDEX<=UDIM(MAT GL_MAPPING) then 
16788                      if LASTNUM<>GL_MAPPING(INDEX) then 
16790 ! .                     ! Found one, Process it
16792                         if LEN(GL_KDESCRIPTION$(KEYINDEX)) then let GL_KDESCRIPTION$(KEYINDEX)=GL_KDESCRIPTION$(KEYINDEX)&"/"
16794                         if GL_MAPPING(INDEX)<=UDIM(MAT GL_TEMPSUBS$) AND GL_MAPPING(INDEX)>0 then 
16796                            let GL_KDESCRIPTION$(KEYINDEX)=GL_KDESCRIPTION$(KEYINDEX)&SREP$(GL_TEMPSUBS$(GL_MAPPING(INDEX)),"$","")
16798                         else 
16800                            let GL_KDESCRIPTION$(KEYINDEX)=GL_KDESCRIPTION$(KEYINDEX)&"Unknown"
16802                            let FAILEDKEY=1
16804                         end if 
16806 ! 
16808                         let LASTNUM=GL_MAPPING(INDEX)
16810                      end if 
16812                   end if 
16814                loop 
16816             else 
16818                if LEN(GL_KDESCRIPTION$(KEYINDEX)) then let GL_KDESCRIPTION$(KEYINDEX)=GL_KDESCRIPTION$(KEYINDEX)&"/"
16820                let GL_KDESCRIPTION$(KEYINDEX)=GL_KDESCRIPTION$(KEYINDEX)&"Unknown"
16822                let FAILEDKEY=1
16824             end if 
16826          loop 
16828       next KEYINDEX
16830 ! 
16832 ! .   ! if name is blank then generate a work filename
16834       if ~LEN(GL_NAME$) then let GL_NAME$="templayout"&SESSION$
16836 ! .   ! if Recl matches gl_Mapping then autogenerate recl
16838       if GL_RECL=UDIM(GL_MAPPING) then let GL_RECL=0
16840 ! 
16842 ! .   ! Burn Layout
16844       let FNWRITELAY(GL_NAME$,GL_FILENAME$,GL_VER,GL_PRE$,MAT GL_KFNAME$,MAT GL_KDESCRIPTION$,MAT GL_SUBS$,MAT GL_DESCR$,MAT GL_FORM$,GL_RECL,MAT GL_EXTRA$,DISPLAYFILE)
16846 ! 
16848 ! .   ! if errors in Header or Detail, print message box
16850       let GL_ERRORMESSAGE$=""
16852       if FAILEDHEADER then let GL_ERRORMESSAGE$=GL_ERRORMESSAGE$&"We were unable to properly build the Header. Check your open statements."&CHR$(13)&CHR$(10)
16854       if FAILEDKEY then let GL_ERRORMESSAGE$=GL_ERRORMESSAGE$&"We were unable to figure out the keys. Check your open and read statements."&CHR$(13)&CHR$(10)
16856       if FAILEDREAD then let GL_ERRORMESSAGE$=GL_ERRORMESSAGE$&"We were unable to figure out the variable names. Check your read statement and dim statement."&CHR$(13)&CHR$(10)
16858       if FAILEDFORM then let GL_ERRORMESSAGE$=GL_ERRORMESSAGE$&"We were unable to figure out the form specs. Check your form statement."&CHR$(13)&CHR$(10)
16860       if FAILEDMATCH then let GL_ERRORMESSAGE$=GL_ERRORMESSAGE$&"There was a problem matching your layout specs. Check your Read, Dim and Form statements."&CHR$(13)&CHR$(10)
16862 ! 
16864 ! .   ! Return error
16866       if FAILEDREAD OR FAILEDFORM OR FAILEDMATCH OR FAILEDHEADER OR FAILEDKEY then 
16868          let MSGBOX(GL_ERRORMESSAGE$,"I need more information.","Ok")
16870       else 
16872          let FNGENERATELAY=1
16874       end if 
16876    fnend 
16878 ! 
16880    def library FNWRITELAYOUT(NAME$,FILENAME$*127,VER,PRE$,MAT KFNAME$,MAT KDESCRIPTION$,MAT SUBS$,MAT DESCR$,MAT FORM$;RECL,MAT EXTRA$,DISPLAYFILE)=FNWRITELAY(NAME$,FILENAME$,VER,PRE$,MAT KFNAME$,MAT KDESCRIPTION$,MAT SUBS$,MAT DESCR$,MAT FORM$,RECL,MAT EXTRA$)
16882    def FNWRITELAY(NAME$,FILENAME$*127,VER,PRE$,MAT KFNAME$,MAT KDESCRIPTION$,MAT SUBS$,MAT DESCR$,MAT FORM$;RECL,MAT EXTRA$,___,FILENUMBER,INDEX,WIDESTSUB,WIDESTDESCR,WIDESTFORM,FILELAYFOLDER$*255)
16884 ! 
16886       let NAME$=NAME$
16888       let FILELAYOUTPATH$=FNSETTINGS$("layoutpath")
16890       library : FNGETFILENUMBER
16892 ! 
16894       open #(FILENUMBER:=FNGETFILENUMBER): "name="&FILELAYOUTPATH$&NAME$&", recl=1000,replace",display,output 
16896       print #FILENUMBER: FILENAME$&", "&PRE$&", "&STR$(VER)
16898       for INDEX=1 to UDIM(MAT KFNAME$)
16900          print #FILENUMBER: KFNAME$(INDEX)&", "&KDESCRIPTION$(INDEX)
16902       next INDEX
16904       if RECL then 
16906          print #FILENUMBER: "recl="&STR$(RECL)
16908       end if 
16910 ! 
16912 ! .   ! Minimums
16914       let WIDESTSUB=10
16916       let WIDESTDESCR=30
16918       let WIDESTFORM=6
16920 ! .   ! Calculate width of output
16922       for INDEX=1 to UDIM(MAT SUBS$)
16924          let WIDESTSUB=MAX(WIDESTSUB,LEN(SUBS$(INDEX)))
16926          let WIDESTDESCR=MAX(WIDESTDESCR,LEN(DESCR$(INDEX)))
16928          let WIDESTFORM=MAX(WIDESTFORM,LEN(FORM$(INDEX)))
16930       next INDEX
16932       print #FILENUMBER: RPT$("=",WIDESTSUB+2+WIDESTDESCR+2+WIDESTFORM)
16934       for INDEX=1 to UDIM(MAT SUBS$)
16936          if INDEX<=UDIM(MAT EXTRA$) AND LEN(EXTRA$(INDEX)) then 
16938             print #FILENUMBER: RPAD$(SUBS$(INDEX)&", ",WIDESTSUB+2)&RPAD$(DESCR$(INDEX)&", ",WIDESTDESCR+2)&LPAD$(FORM$(INDEX),WIDESTFORM)&", "&EXTRA$(INDEX)
16940          else 
16942             print #FILENUMBER: RPAD$(SUBS$(INDEX)&", ",WIDESTSUB+2)&RPAD$(DESCR$(INDEX)&", ",WIDESTDESCR+2)&LPAD$(FORM$(INDEX),WIDESTFORM)
16944          end if 
16946       next INDEX
16948       close #FILENUMBER: 
16950 ! 
16952       if DISPLAYFILE then execute FNNEEDSTAR$&"sy -C -M start notepad "&FILELAYOUTPATH$&NAME$
16954    fnend 
16956 ! 
16958    dim FS_CHUNK$*800
16960    dim FS_REPLACE$*2000
16962    def FNUNPACKFORMSTRING(&FORMSTRING$;___,PLEVEL,SPOS,EPOS,NPOS,INDEX,NUM)
16964 ! .   ! unpack the form string
16966 ! .   !  needs to handle:
16968 ! .   !   form C 10,DATE(mm/dd/ccyy),2*(C 10),2*(C 15,C 10),4*(C 15,FMT(##),3*FMT(###))
16970 ! .   !   form C 10,DATE(mm/dd/ccyy),C 10,C 10,C 15,C 10,C 15,C 10,C 15,FMT(##),FMT(###),FMT(###),FMT(###),C 15,FMT(##),FMT(###),FMT(###),FMT(###),C 15,FMT(##),FMT(###),FMT(###),FMT(###),C 15,FMT(##),FMT(###),FMT(###),FMT(###)
16972 ! 
16974       do WHILE (SPOS:=POS(FORMSTRING$,"*")) ! Find First *
16976 ! .      ! Find Chunk
16978          if FORMSTRING$(SPOS:SPOS+1)="*(" then ! If Next Char Is "("
16980             let EPOS=SPOS ! Find Matching ")"
16982             do  ! Go Through String Counting
16984                let EPOS+=1 ! Parens Until We're at match
16986                if FORMSTRING$(EPOS:EPOS)="(" then let PLEVEL+=1
16988                if FORMSTRING$(EPOS:EPOS)=")" then let PLEVEL-=1
16990             loop WHILE PLEVEL
16992             let FS_CHUNK$=FORMSTRING$(SPOS+2:EPOS-1)&","
16994          else ! If Its Not A "*(" Then
16996             let EPOS=POS(FORMSTRING$,",",SPOS) ! Look For The Next ","
16998             if ~EPOS then let EPOS=LEN(FORMSTRING$)+1
17000             let FS_CHUNK$=FORMSTRING$(SPOS+1:EPOS-1)&","
17002             let EPOS-=1
17004          end if 
17006 ! 
17008 ! .      ! Find Number
17010          let NPOS=SPOS
17012          do WHILE (NPOS:=NPOS-1)
17014          loop WHILE POS("0123456789",FORMSTRING$(NPOS:NPOS))
17016          let NUM=VAL(FORMSTRING$(NPOS+1:SPOS-1))
17018 ! 
17020 ! .      ! Then Substitute
17022          let FS_REPLACE$=RPT$(FS_CHUNK$,NUM)
17024          let FS_REPLACE$=FS_REPLACE$(1:LEN(FS_REPLACE$)-1)
17026          let FORMSTRING$(NPOS+1:EPOS)=FS_REPLACE$
17028       loop  !     Go Until There's no *
17030    fnend 
17032 ! 
17034 ! .!  needs to handle:
17036 ! .!   form C 10,DATE(mm/dd/ccyy),2*(C 10),2*(C 15,C 10),4*(C 15,FMT(##),3*FMT(###))
17038 ! .!   form C 10,DATE(mm/dd/ccyy),C 10,C 10,2*(C 15,C 10),4*(C 15,FMT(##),3*FMT(###))
17040 ! .!   form C 10,DATE(mm/dd/ccyy),C 10,C 10,C 15,C 10,C 15,C 10,4*(C 15,FMT(##),3*FMT(###))
17042 ! .!   form C 10,DATE(mm/dd/ccyy),C 10,C 10,C 15,C 10,C 15,C 10,C 15,FMT(##),3*FMT(###),C 15,FMT(##),3*FMT(###),C 15,FMT(##),3*FMT(###),C 15,FMT(##),3*FMT(###)
17044 ! .!   form C 10,DATE(mm/dd/ccyy),C 10,C 10,C 15,C 10,C 15,C 10,C 15,FMT(##),FMT(###),FMT(###),FMT(###),C 15,FMT(##),FMT(###),FMT(###),FMT(###),C 15,FMT(##),FMT(###),FMT(###),FMT(###),C 15,FMT(##),FMT(###),FMT(###),FMT(###)
17046 ! 
17048    def FNEXTRACTCHUNK$*255(&READSTRING$,&TPOS;___,CPOS,SPOS,XPOS)
17050       do WHILE (READSTRING$(TPOS+1:TPOS+1)=" ")
17052          let TPOS+=1
17054       loop 
17056       let CPOS=POS(READSTRING$,",",TPOS+1)
17058       let SPOS=POS(READSTRING$," ",TPOS+1)
17060       if LWRC$(READSTRING$(TPOS+1:SPOS-1))="mat" then 
17062          let SPOS=POS(READSTRING$," ",SPOS+1)
17064       end if 
17066       if CPOS AND SPOS then 
17068          let XPOS=MIN(CPOS,SPOS)
17070       else 
17072          let XPOS=MAX(CPOS,SPOS)
17074       end if 
17076       if ~XPOS then let XPOS=LEN(READSTRING$)+1
17078       let FNEXTRACTCHUNK$=TRIM$(READSTRING$(TPOS+1:XPOS-1))
17080       if ~CPOS then let CPOS=LEN(READSTRING$)+1
17082       let TPOS=CPOS
17084    fnend 
17086 ! 
17088    def FNEXTRACTFORM$*255(&FORMSTRING$,&TPOS;___,XPOS)
17090       let XPOS=POS(FORMSTRING$,",",TPOS+1)
17092       if ~XPOS then let XPOS=LEN(FORMSTRING$)+1
17094       let FNEXTRACTFORM$=TRIM$(FORMSTRING$(TPOS+1:XPOS-1))
17096       let TPOS=XPOS
17098    fnend 
17100 ! 
17102    def FNEXTRACTKPS(&KPSSTRING$,&TPOS;___,XPOS,KPOS)
17104       let XPOS=POS(KPSSTRING$,"/",TPOS+1)
17106       if ~XPOS then let XPOS=LEN(KPSSTRING$)+1
17108       let KPOS=VAL(KPSSTRING$(TPOS+1:XPOS-1)) conv Ignore
17110       let FNEXTRACTKPS=KPOS
17112       let TPOS=XPOS
17114    fnend 
17116 ! 
17118    def FNEXTRACTKLN(&KLNSTRING$,&TPOS;___,XPOS,KLEN)
17120       let XPOS=POS(KLNSTRING$,"/",TPOS+1)
17122       if ~XPOS then let XPOS=LEN(KLNSTRING$)+1
17124       let KLEN=VAL(KLNSTRING$(TPOS+1:XPOS-1)) conv Ignore
17126       let FNEXTRACTKLN=KLEN
17128       let TPOS=XPOS
17130    fnend 
17132 ! 
17134    def FNREADARRAYSIZE(&DIMSTRING$,VARNAME$*255;___,TPOS,SIZE$,PPOS)
17136       let TPOS=POS(LWRC$(DIMSTRING$),LWRC$(VARNAME$))
17138       if TPOS then let TPOS+=LEN(VARNAME$)
17140       if DIMSTRING$(TPOS:TPOS)="(" then 
17142          let PPOS=POS(DIMSTRING$,")",TPOS+1)
17144          if PPOS then 
17146             let SIZE$=DIMSTRING$(TPOS+1:PPOS-1)
17148             let FNREADARRAYSIZE=0
17150             let FNREADARRAYSIZE=VAL(SIZE$) conv Ignore
17152          end if 
17154       end if 
17156    fnend 
17158 ! 
17160    def FNCALLAUDIT(MAT SEL)
17162       library "audit" : FNRUNAUDIT
17164       let FNRUNAUDIT("",MAT SEL)
17166    fnend 
17168 ! 
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
19120          if START>=199 AND START<300 then let START=300 : let I=0 ! Skip Over The Invalid 200s
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
19260          on error system  ! Turn Error Checking Back Off
19270       end if 
19280    fnend 
19290 ! 
20000 ! #Autonumber# 20000,5
20005 Openfile: ! This Function Opens The Requested File And Returns Filenum
20010    def library FNOPENFILE(&FILENAME$, MAT F$, MAT F, MAT FORM$;INPUTONLY,KEYNUM,DONT_SORT_SUBS,&PATH$,MAT DESCRIPTION$,MAT FIELDWIDTHS,MAT FILEIOSUBS$,SUPRESSPROMPT,IGNOREERRORS,CALLINGPROGRAM$*255,SUPPRESSLOG,___,FILENUMBER,STRINGSIZE,NUMBERSIZE,DUMMY,INDEX,VER,PROMPTONCREATE,OKTOCREATE,CREATELOGFILE,FORM$*2000,STARTFILENUMBER,COUNTFILENUMBER,FILELAY$*255,CHECKINDEX,LOGLAYOUT$)
20015       dim KEYNAME$(1)*255,KPOS$(1)*80,KLEN$(1)*80
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
20070       let CHECKINDEX=FNSETTINGS("checkindex")
20075       if SUPPRESSLOG then 
20080          let CREATELOGFILE=0
20085       else 
20090          let CREATELOGFILE=FNSETTINGS("createlogfile")
20095       end if 
20100 ! 
20105       if NOT (KEYNUM) then let KEYNUM=1
20110       if TRIM$(PATH$)<>"" AND PATH$(LEN(PATH$):LEN(PATH$))<>"\" then let PATH$=PATH$&"\"
20115       let FILELAY$=FILENAME$ ! Make Backup So That We Can Use This Later For Versioning Logic
20120       if FNREADFILELAYOUT(FILENAME$,RECL$,MAT KEYNAME$,MAT KPOS$,MAT KLEN$,FM$, STRINGSIZE, NUMBERSIZE,DONT_SORT_SUBS,VER,MAT DESCRIPTION$,MAT FIELDWIDTHS,MAT FILEIOSUBS$) then ! Reads Layout And Applies Subscripts
20125          if FN42 then 
20130             let FORM$=FM$(1:2000)
20135          else 
20140             let FORM$=TRIM$(FM$(1:255))
20145          end if 
20150          if NOT EXISTS(PATH$&FILENAME$) then 
20155             if SUPRESSPROMPT then 
20160                let OKTOCREATE=SUPRESSPROMPT-1
20165             else if PROMPTONCREATE then 
20170                let MESSAGE$=PATH$&FILENAME$
20175                if LEN(TRIM$(MESSAGE$))>41 then let MESSAGE$=MESSAGE$(1:38)&"..."
20180                let MESSAGE$='Should I create "'&MESSAGE$&'"?'
20185                let OKTOCREATE=FNMESSAGEBOX(MESSAGE$,"File Not Found")
20190             else 
20195                let OKTOCREATE=1
20200             end if 
20205             if OKTOCREATE then 
20210                let FNCREATE(FILENAME$,RECL$,MAT KEYNAME$,MAT KPOS$,MAT KLEN$,VER,FILELAY$,PATH$)
20215             end if 
20220          end if 
20225          if EXISTS(PATH$&FILENAME$) then 
20230             if INPUTONLY then 
20235                do 
20240                   if UDIM(MAT KEYNAME$)>0 AND KEYNUM>0 then 
20245                      let FNCHECKINDEX(PATH$&FILENAME$,PATH$&KEYNAME$(KEYNUM),KPOS$(KEYNUM),KLEN$(KEYNUM),CHECKINDEX,CREATELOGFILE,KEYNUM,ENFORCEDUPKEYS,CALLINGPROGRAM$)
20250                      open #(FILENUMBER:=FNGETFILENUMBER(STARTFILENUMBER)): "name="&PATH$&FILENAME$&", kfname="&PATH$&KEYNAME$(KEYNUM)&",shr",internal, input, keyed ioerr Error_Openfile
20255                   else 
20260                      open #(FILENUMBER:=FNGETFILENUMBER(STARTFILENUMBER)): "name="&PATH$&FILENAME$&",shr",internal, input, relative ioerr Error_Openfile
20265                   end if 
20270                loop WHILE FNWRONGVERSION(FILENUMBER,FILELAY$,VER,PATH$)
20275             else 
20280                do 
20285                   if UDIM(MAT KEYNAME$)>0 AND KEYNUM>0 then 
20290                      let FNCHECKINDEX(PATH$&FILENAME$,PATH$&KEYNAME$(KEYNUM),KPOS$(KEYNUM),KLEN$(KEYNUM),CHECKINDEX,CREATELOGFILE,KEYNUM,ENFORCEDUPKEYS,CALLINGPROGRAM$)
20295                      open #(FILENUMBER:=FNGETFILENUMBER(STARTFILENUMBER,UDIM(KEYNAME$))): "name="&PATH$&FILENAME$&", kfname="&PATH$&KEYNAME$(KEYNUM)&",shr",internal, outin, keyed ioerr Error_Openfile
20300                   else 
20305                      if KEYNUM>=-1 then 
20310                         open #(FILENUMBER:=FNGETFILENUMBER(STARTFILENUMBER,UDIM(KEYNAME$)+1)): "name="&PATH$&FILENAME$&",shr",internal, outin, relative ioerr Error_Openfile
20315                      else 
20320                         open #(FILENUMBER:=FNGETFILENUMBER(STARTFILENUMBER)): "name="&PATH$&FILENAME$&",shr",internal, outin, relative ioerr Error_Openfile
20325                      end if 
20330                   end if 
20335                loop WHILE FNWRONGVERSION(FILENUMBER,FILELAY$,VER,PATH$)
20340                let COUNTFILENUMBER=FILENUMBER
20345                if KEYNUM>=-1 then 
20350                   for INDEX=1 to UDIM(KEYNAME$) ! Outin Requires All Keys To Be Opened
20355                      if INDEX<>KEYNUM then 
20360                         let FNCHECKINDEX(PATH$&FILENAME$,PATH$&KEYNAME$(INDEX),KPOS$(INDEX),KLEN$(INDEX),CHECKINDEX,CREATELOGFILE,INDEX,ENFORCEDUPKEYS,CALLINGPROGRAM$)
20365                         let COUNTFILENUMBER+=1
20370                         open #(COUNTFILENUMBER): "name="&PATH$&FILENAME$&", kfname="&PATH$&KEYNAME$(INDEX)&",shr",internal, outin, keyed 
20375                         mat FORM$(MAX(UDIM(MAT FORM$),COUNTFILENUMBER))
20380                         let FORM$(COUNTFILENUMBER)=FORM$
20385                      end if 
20390                   next INDEX
20395                end if 
20400             end if 
20405             mat FORM$(MAX(UDIM(MAT FORM$),FILENUMBER))
20410             let FORM$(FILENUMBER)=FORM$
20415             mat F$(STRINGSIZE)
20420             mat F(NUMBERSIZE)
20425             let FNOPENFILE=FILENUMBER
20430             let LOGLAYOUT$=FNSETTINGS$("loglayout")
20435             if CREATELOGFILE AND LWRC$(FILELAY$)<>LWRC$(LOGLAYOUT$) then let FNLOG("Open "&FILENAME$&" file.",CALLINGPROGRAM$)
20440          else 
20445             if CREATELOGFILE then let FNLOG("Error: Failed to open "&FILENAME$&" file - File Not Found",CALLINGPROGRAM$,1)
20450          end if 
20455       else 
20460          print "Unable to open file layout: "&FILENAME$
20465          print "Make sure it exists, and its not currently in use."
20470          pause 
20475          stop 
20480       end if 
20485 Exitfnopen: ! Exit Fn Open
20490    fnend 
20495 Error_Openfile: ! An Error Was Found Opening The File
20500    if IGNOREERRORS then goto Returnfailed
20505    print "Error parsing file layout or opening file "&FILENAME$&": "&STR$(ERR)&" on line: "&STR$(LINE)
20510    print "A key specified in your file layout could not be found."
20515    print "Check your file layout header for errors."
20520    pause  ! Give User A Chance To Check Variables
20525    execute "system"
20530 ! 
20535 Returnfailed: ! Open Failed But Keep Going
20540    if CREATELOGFILE then let FNLOG("Error: Failed to open file "&FILENAME$&" or its keys: "&STR$(ERR)&" on fileio line: "&STR$(LINE),CALLINGPROGRAM$,1)
20545    goto Exitfnopen
20550 ! 
20555 ! 
21000 ! #Autonumber# 21000,10
21010 Create: ! This Should Create The Given File If It Does Not Exist
21020    def FNCREATE(FILENAME$*255,RECL$,MAT KEYS$,MAT KPOS$,MAT KLEN$,VER,FILELAY$*255;PATH$*255,___,INDEX,FILENUMBER)
21030       if UDIM(MAT KEYS$)>0 then 
21040          open #(FILENUMBER:=FNGETFILENUMBER): "Name="&PATH$&FILENAME$&", "&RECL$&", kfname="&PATH$&KEYS$(1)&", kps="&KPOS$(1)&", kln="&KLEN$(1)&",new",internal,output,keyed 
21050       else 
21060          open #(FILENUMBER:=FNGETFILENUMBER): "Name="&PATH$&FILENAME$&", "&RECL$&",new", internal, output, relative 
21070       end if 
21080       let VERSION(FILENUMBER,VER)
21090       close #FILENUMBER: 
21100       for INDEX=2 to UDIM(MAT KEYS$)
21110          execute FNNEEDSTAR$&"index "&PATH$&FILENAME$&" "&PATH$&KEYS$(INDEX)&" "&KPOS$(INDEX)&" "&KLEN$(INDEX)&" dupkeys -N"
21120       next INDEX
21130       let FNCREATEVERSIONSAVEINFO(FILELAY$)
21140    fnend 
21150 ! 
21160 Createversionsaveinfo: ! Backs Up The File Layout And Saves Version Information
21170    def FNCREATEVERSIONSAVEINFO(FILELAY$*255;SAVELAY,NEWLAY,FILENAME$*255,PREFIX$,DUMMY$*255,KEYNAME$,VERS$,FILELAYOUTPATH$*255,OLDFILELAYOUT$)
21180       let FILELAYOUTPATH$=FNSETTINGS$("layoutpath") ! Retrieve Settings
21190 ! 
21200       if ~EXISTS(FILELAYOUTPATH$&"version") then 
21210          execute FNNEEDSTAR$&"mkdir "&FILELAYOUTPATH$&"version"
21220       end if 
21230       open #(NEWLAY:=FNGETFILENUMBER): "Name="&FILELAYOUTPATH$&FILELAY$, display,input 
21240       input #NEWLAY: FILENAME$,PREFIX$,VERS$
21250       open #(SAVELAY:=FNGETFILENUMBER): "Name="&FILELAYOUTPATH$&"version\"&FILELAY$&"."&TRIM$(STR$(VAL((VERS$))))&", replace", display, output 
21260       print #SAVELAY: FNCALCULATEBACKUPFILENAME$(TRIM$(FILENAME$))&", o"&TRIM$(PREFIX$)&", "&TRIM$(VERS$)
21270       linput #NEWLAY: DUMMY$
21280       do WHILE UPRC$(DUMMY$(1:5))<>"RECL=" AND DUMMY$(1:4)<>"===="
21290          print #SAVELAY: FNCALCULATEBACKUPFILENAME$(DUMMY$(1:POS(DUMMY$,",")-1)) & TRIM$(DUMMY$(POS(DUMMY$,","):LEN(DUMMY$)))
21300          linput #NEWLAY: DUMMY$
21310       loop 
21320 Copynextline: ! Copy The Rest Of The File
21330       print #SAVELAY: TRIM$(DUMMY$)
21340       linput #NEWLAY: DUMMY$ eof Donecopylines
21350       goto Copynextline
21360 Donecopylines: ! File Is Finished
21370       close #NEWLAY: 
21380       close #SAVELAY: 
21390    fnend 
21400 ! 
21410 Checkversionsaveinfo: ! Ensures Version Save Information Exists
21420    def FNCHECKVERSIONSAVEINFO(FILELAY$*255,VER;___,FILELAYOUTPATH$*255)
21430       let FILELAYOUTPATH$=FNSETTINGS$("layoutpath")
21440       if ~(TRIM$(FILELAY$(POS(TRIM$(FILELAY$),".",-1):LEN(TRIM$(FILELAY$))))="."&TRIM$(STR$(VER))) then 
21450          if (~EXISTS(FILELAYOUTPATH$&"version")) OR (~EXISTS(FILELAYOUTPATH$&"version\"&FILELAY$&"."&TRIM$(STR$(VER)))) then 
21460             let FNCREATEVERSIONSAVEINFO(FILELAY$)
21470          end if 
21480       end if 
21490    fnend 
21500 ! 
21510 Calculatebackupfilename: !  Returns The Backup File Name Of The Given File Name
21520    def FNCALCULATEBACKUPFILENAME$*255(NEWFILENAME$*255;___,LASTSLASH)
21530       let LASTSLASH=POS(NEWFILENAME$,"\",-1)
21540       let NEWFILENAME$(LASTSLASH+1:LASTSLASH)="o"
21550       let FNCALCULATEBACKUPFILENAME$=NEWFILENAME$
21560    fnend 
21570 ! 
21580 Calculatenewfilename: ! Returns The New File Name Of The Given Backup File Name
21590    def FNCALCULATENEWFILENAME$*255(BACKUPFILENAME$*255;___,LASTSLASH)
21600       let LASTSLASH=POS(BACKUPFILENAME$,"\",-1)
21610       if BACKUPFILENAME$(LASTSLASH+1:LASTSLASH+1)="o" then 
21620          let BACKUPFILENAME$(LASTSLASH+1:LASTSLASH+1)=""
21630       end if 
21640       let FNCALCULATENEWFILENAME$=BACKUPFILENAME$
21650    fnend 
21660 ! 
22000 ! #Autonumber# 22000,10
22010 Checkindex: ! Checks To Ensure Indexes Are Up To Date
22020    def FNCHECKINDEX(MAINFILE$*255,KEYFILE$*255,KPOS$*50,KLEN$*50,CHECKINDEX;LOGGING,INDEX,ENFORCEDUPKEYS,&CALLINGPROGRAM$,___,DUPKEYS)
22030       if ENFORCEDUPKEYS AND INDEX=1 then let DUPKEYS=0 else let DUPKEYS=1
22040       if EXISTS(KEYFILE$) then 
22050          if CHECKINDEX then 
22060             if FNGETFILEDT$(KEYFILE$)<>FNGETFILEDT$(MAINFILE$) then 
22070                let FNREBUILDINDEX(MAINFILE$,KEYFILE$,KPOS$,KLEN$,1,LOGGING,DUPKEYS,CALLINGPROGRAM$)
22080             end if 
22090          end if 
22100       else 
22110          let FNREBUILDINDEX(MAINFILE$,KEYFILE$,KPOS$,KLEN$,0,LOGGING,DUPKEYS,CALLINGPROGRAM$)
22120       end if 
22130    fnend 
22140 ! 
22150 ! 
22160 Reindexallfiles: ! Rebuilds Every Index In The System
22170    def library FNREINDEXALLFILES(;___,INDEX)
22180       library : FNREINDEX, FNREADLAYOUTS
22190       let FNREADLAYOUTS(MAT REINDEX$)
22200       for INDEX=1 to UDIM(MAT REINDEX$)
22210          let FNREINDEX(REINDEX$(INDEX))
22220       next INDEX
22230    fnend 
22240 ! 
22250    dim REINDEX$(1)*255
22260    dim REBUILDFILE$*255
22270    dim REBUILDINDEXES$(1)*255
22280    dim REBUILDKPOS$(1)*255
22290    dim REBUILDKLEN$(1)*255
22300    dim DUMMY$(1)*255
22310    dim DUMMY(1)
22320 ! 
22330 ! .   ! Included for backwards compatibility .. there was a typeo in an earlier version.
22340    def library FNRENDIX(DATAFILE$*255;CALLINGPROGRAM$*255)
22350       library : FNREINDEX
22360       let FNRENDIX=FNREINDEX(DATAFILE$,CALLINGPROGRAM$)
22370    fnend 
22380 Reindex: ! Rebuilds All Indexes For A Given Data File
22390    def library FNREINDEX(DATAFILE$*255;CALLINGPROGRAM$*255,___,INDEX,DUMMY,DUMMY2,DUMMY3,DUMMY$*255)
22400       if CALLINGPROGRAM$="" then let CALLINGPROGRAM$="Unknown"
22410       let FNREADFILELAYOUT(DATAFILE$,REBUILDFILE$,MAT REBUILDINDEXES$,MAT REBUILDKPOS$,MAT REBUILDKLEN$,DUMMY$,DUMMY,DUMMY2,0,DUMMY3,MAT DUMMY$,MAT DUMMY)
22420       for INDEX=1 to UDIM(MAT REBUILDINDEXES$)
22430          if EXISTS(REBUILDINDEXES$(INDEX)) then 
22440             let FNREBUILDINDEX(DATAFILE$,REBUILDINDEXES$(INDEX),REBUILDKPOS$(INDEX),REBUILDKLEN$(INDEX),1,0,0,CALLINGPROGRAM$)
22450          else 
22460             let FNREBUILDINDEX(DATAFILE$,REBUILDINDEXES$(INDEX),REBUILDKPOS$(INDEX),REBUILDKLEN$(INDEX),0,0,0,CALLINGPROGRAM$)
22470          end if 
22480       next INDEX
22490    fnend 
22500 ! 
22510 Rebuildindex: ! Rebuilds An Index That Was Missing Or Incomplete
22520    def FNREBUILDINDEX(MAINFILE$*255,KEYFILE$*255,KPOS$*50,KLEN$*50;UPDATE,LOGGING,DUPKEYS,&CALLINGPROGRAM$)
22530       if UPDATE then 
22540          if DUPKEYS then 
22550             execute FNNEEDSTAR$&"index "&MAINFILE$&" "&KEYFILE$&" "&KPOS$&" "&KLEN$&" dupkeys replace shr -N" error Ignore
22560          else 
22570             execute FNNEEDSTAR$&"index "&MAINFILE$&" "&KEYFILE$&" "&KPOS$&" "&KLEN$&" replace shr -N" error Ignore
22580          end if 
22590       else 
22600          if DUPKEYS then 
22610             execute FNNEEDSTAR$&"index "&MAINFILE$&" "&KEYFILE$&" "&KPOS$&" "&KLEN$&" dupkeys shr -N" error Ignore
22620          else 
22630             execute FNNEEDSTAR$&"index "&MAINFILE$&" "&KEYFILE$&" "&KPOS$&" "&KLEN$&" shr -N" error Ignore
22640          end if 
22650       end if 
22660       if LOGGING then let FNLOG("FileIO Autocreate Index "&MAINFILE$&" "&KEYFILE$&" "&KPOS$&" "&KLEN$,CALLINGPROGRAM$,1)
22670    fnend 
22680 ! 
22690 Wrongversion: ! Checks Version, Closes And Updates Files If Wrong Version
22700    def FNWRONGVERSION(FILENUMBER,FILELAY$*255,VER;PATH$*255,___,OLD)
22710       if (OLD:=VERSION(FILENUMBER))>=VER then 
22720          let FNWRONGVERSION=0 ! Success
22730          let FNCHECKVERSIONSAVEINFO(FILELAY$,VER)
22740       else 
22750          close #FILENUMBER: 
22760          let FNUPDATE(FILELAY$,OLD,PATH$)
22770          let FNWRONGVERSION=1 ! Failure, But Version Was Fixed, So Go Back And Reopen It
22780       end if 
22790    fnend 
22800 ! 
22810    dim UPDATEMESSAGES$(1)*80, PRINTEDYET
22820 ! 
22830 ! 
22840    dim DUMMY$
23000 ! #Autonumber# 23000,5
23005 Update: ! Updates File To Latest Version
23010    def FNUPDATE(FILELAY$*255,OLDVER;&PATH$,__,INDEX,OLDFILE,NEWFILE,OPRE$,NPRE$,NNDEX,OLDFILENAME$*255,LASTUPDATEDKEY,ERRINDEX,LASTPERCENT,RECCOUNT,USERABORTED,WINDOW,INTERVAL,NUMRECS,OLDFILELAY$*255,STAR$)
23015       let STAR$=FNNEEDSTAR$
23020       mat UPDATEMESSAGES$(0) : let PRINTEDYET=0
23025       let LAYOUTPATH$=FNSETTINGS$("layoutpath")
23030       on error goto Fileinuse ! Call Rollback Processing For No Changes Made
23035       open #(WINDOW:=FNGETFILENUMBER): "SRow=11,SCol=2,Rows=2,Cols=78,Caption= Updating '"&FILELAY$&"' File - Please Wait ,Border=S",display,outin 
23040 ! 
23045       for INDEX=1 to 78 !:
               print #WINDOW, fields "2,"&STR$(INDEX)&",C 1" : "." !:
            next INDEX
23050 ! 
23055       dim FM$(1)*1000,NF$(1)*800,NF(1),OF$(1)*800,OF(1),NSSUBS$(1)*80,OSSUBS$(1)*80,NNSUBS$(1)*80,ONSUBS$(1)*80,OKEYS$(1)*80
23060 ! 
23065       library : FNOPENFILE, FNCLOSEFILE, FNREADSUBS
23070 ! 
23075       let OLDFILELAY$="version\"&FILELAY$&"."&STR$(OLDVER)
23080 ! 
23085       if EXISTS(LAYOUTPATH$&OLDFILELAY$) then 
23090          let FNFINDINDEXES(OLDFILELAY$,OLDFILENAME$,MAT OKEYS$)
23095          let FNPRINT(WINDOW,MAT UPDATEMESSAGES$,"Making Backup Copy of "&PATH$&FNCALCULATENEWFILENAME$(OLDFILENAME$))
23100          execute STAR$&"copy "&PATH$&FNCALCULATENEWFILENAME$(OLDFILENAME$)&" "&PATH$&OLDFILENAME$&" -N -D"
23105          execute STAR$&"copy "&PATH$&FNCALCULATENEWFILENAME$(OLDFILENAME$)&" "&PATH$&FNCALCULATENEWFILENAME$(OLDFILENAME$)&".bak -N"
23110          execute STAR$&"free "&PATH$&FNCALCULATENEWFILENAME$(OLDFILENAME$)&" -N"
23115          on error goto Fileinusekey ! Call Rollback Processing For File Changed And Some Keys
23120          for INDEX=1 to UDIM(OKEYS$)
23125             let FNPRINT(WINDOW,MAT UPDATEMESSAGES$,"Making Backup Copy of "&PATH$&FNCALCULATENEWFILENAME$(OKEYS$(INDEX)))
23130             execute STAR$&"copy "&PATH$&FNCALCULATENEWFILENAME$(OKEYS$(INDEX))&" "&FNCALCULATENEWFILENAME$(OKEYS$(INDEX))&".bak -N"
23135             execute STAR$&"free "&PATH$&FNCALCULATENEWFILENAME$(OKEYS$(INDEX))&" -N"
23140          next INDEX
23145          on error goto Rollbackinfull ! Call Rollback Processing For File / All Keys Changed
23150          let G_UPDATING=1
23155          let FNPRINT(WINDOW,MAT UPDATEMESSAGES$,"Opening old version of file.")
23160          let OLDFILE=FNOPEN(OLDFILELAY$,MAT OF$,MAT OF, MAT FM$,0,-1,0,PATH$,DUMMY$,DUMMY,0,0,1)
23165          let FNREADSUBS(OLDFILELAY$,MAT OSSUBS$,MAT ONSUBS$,OPRE$)
23170          let FNPRINT(WINDOW,MAT UPDATEMESSAGES$,"Creating new version of file.")
23175          let NEWFILE=FNOPEN(FILELAY$,MAT NF$,MAT NF,MAT FM$,0,0,0,PATH$,DUMMY$,DUMMY,0,0,1) ! Will Automatically Create
23180          let FNREADSUBS(FILELAY$,MAT NSSUBS$,MAT NNSUBS$,NPRE$)
23185          let FNPRINT(WINDOW,MAT UPDATEMESSAGES$,"Preforming File Update. SHIFT-A to abort.")
23190          let NUMRECS=LREC(OLDFILE)
23195 Readoldrecord: ! Read The Old Record Here
23200          read #OLDFILE, using FM$(OLDFILE), release: MAT OF$, MAT OF eof Doneupdating
23205          mat NF$=("")
23210          mat NF=(0)
23215          if INT(((RECCOUNT+=1)/LREC(OLDFILE))*78)>LASTPERCENT then 
23220             for INDEX=MAX(LASTPERCENT,1) to INT((RECCOUNT/NUMRECS)*78)
23225                print #WINDOW, fields "2,"&STR$(INDEX)&",C 1" : "o"
23230             next INDEX
23235             let LASTPERCENT=INT((RECCOUNT/NUMRECS)*78)
23240          end if 
23245          if ~MOD(RECCOUNT,3) then print #WINDOW, fields "1,42,CR 37" : "Completed: "&STR$(RECCOUNT)&" / "&STR$(NUMRECS)
23250          for INDEX=1 to UDIM(OSSUBS$) ! Copy String Values
23255             if (NNDEX:=SRCH(MAT NSSUBS$,OSSUBS$(INDEX)))>0 then 
23260                let NF$(NNDEX)=TRIM$(OF$(INDEX))
23265             end if 
23270          next INDEX
23275          for INDEX=1 to UDIM(ONSUBS$) ! Copy Number Values
23280             if (NNDEX:=SRCH(MAT NNSUBS$,ONSUBS$(INDEX)))>0 then 
23285                let NF(NNDEX)=OF(INDEX)
23290             end if 
23295          next INDEX
23300          write #NEWFILE, using FM$(NEWFILE) : MAT NF$, MAT NF
23305          if KSTAT$="A" then let USERABORTED=1 : goto Rollbackinfull
23310          goto Readoldrecord
23315 Doneupdating: ! We Are Finished
23320          let FNCLOSEFILE(OLDFILE,OLDFILELAY$)
23325          let FNCLOSEFILE(NEWFILE,FILELAY$)
23330          close #WINDOW: 
23335          let G_UPDATING=0 ! We Are Done Updating
23340       else 
23345          print "Error: Unable to locate old version file layout: "&LAYOUTPATH$&OLDFILELAY$
23350          pause 
23355          execute "system"
23360       end if 
23365       let FNRESETERRORHANDLING
23370    fnend 
23375 ! 
23600 ! Error Checking Rollback Update Routine.       #Autonumber# 23600,5
23605 Rollbackinfull: ! Close All Files And Roll Back
23610    on error system 
23615    let UPDATEERRORRECIEVED=ERR
23620    let UPDATEERRORLINE=LINE
23625    if OLDFILE then let FNCLOSEFILE(OLDFILE,OLDFILELAY$)
23630    if NEWFILE then let FNCLOSEFILE(NEWFILE,FILELAY$)
23635    let LASTUPDATEDKEY=UDIM(OKEYS$) ! Set Value To Roll Back All Indexes
23640 ! 
23645 Fileinusekey: ! Error In Second Part. Partially Roll Back
23650    on error system 
23655    if UPDATEERRORRECIEVED=0 then let UPDATEERRORRECIEVED=ERR
23660    if UPDATEERRORLINE=0 then let UPDATEERRORLINE=LINE
23665    print MAT UPDATEMESSAGES$
23670    print "Error encountered or User abort: Rolling back to previous version. Type GO[ENTER] to Quit."
23675    let PRINTEDYET=1
23680    if ~LASTUPDATEDKEY then let LASTUPDATEDKEY=INDEX-1
23685    for ERRINDEX=1 to LASTUPDATEDKEY ! Roll Back All Successful Indexes
23690       if EXISTS(PATH$&OKEYS$(ERRINDEX)) then !:
               execute STAR$&"copy "&PATH$&FNCALCULATENEWFILENAME$(OKEYS$(ERRINDEX))&".bak "&PATH$&FNCALCULATENEWFILENAME$(OKEYS$(ERRINDEX)) ! Copy Backup File To Origional File
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
23905    def FNPRINT(WINDOW,MAT UPDATEMESSAGES$,MESSAGE$*80;___,INDEX)
23910       print #WINDOW, fields "1,1,C 78" : MESSAGE$
23915       let INDEX=UDIM(MAT UPDATEMESSAGES$)+1
23920       mat UPDATEMESSAGES$(INDEX)
23925       let UPDATEMESSAGES$(INDEX)=MESSAGE$
23930    fnend 
23935 ! 
24000 ! #Autonumber# 24000,2
24002 Findindexes: ! ***** Reads A File Layout And Finds All Indexes
24004    def FNFINDINDEXES(LAYOUTNAME$*255;&FILENAME$,MAT KEYS$)
24006 ! .      ! Included for Backwards Compatability
24008       library : FNREADLAYOUTHEADER
24010       let FNFINDINDEXES=FNREADLAYOUTHEADER(LAYOUTNAME$,FILENAME$,MAT KEYS$)
24012    fnend 
24014 ! 
24016 Readentirelayout: ! Reads The Entire Layout Into Arrays
24018    def library FNREADENTIRELAYOUT(LAYOUTNAME$*255;&FILENAME$,&PREFIX$,MAT KEYS$,MAT KEYDESCRIPTION$,MAT SSUBS$,MAT NSUBS$,MAT SSPEC$,MAT NSPEC$,MAT SDESCRIPTION$,MAT NDESCRIPTION$,MAT SPOS,MAT NPOS,___,FILENUMBER)
24020       library : FNREADLAYOUTHEADER, FNREADLAYOUTARRAYS
24022       let FILENUMBER=FNREADLAYOUTHEADER(LAYOUTNAME$,FILENAME$,MAT KEYS$,MAT KEYDESCRIPTION$,1,PREFIX$)
24024       let FNREADENTIRELAYOUT=FNREADLAYOUTARRAYS(LAYOUTNAME$,PREFIX$,MAT SSUBS$,MAT NSUBS$,MAT SSPEC$,MAT NSPEC$,MAT SDESCRIPTION$,MAT NDESCRIPTION$,MAT SPOS,MAT NPOS,FILENUMBER)
24026    fnend 
24028 ! 
24030 Readlayoutheader: ! Reads The Layout Header And Returns Arrays
24032    def library FNREADLAYOUTHEADER(LAYOUTNAME$*255;&FILENAME$,MAT KEYS$,MAT KEYDESCRIPTION$,LEAVEOPEN,&PREFIX$,___,COUNT,KEYNAME$*80,DESCRIPTION$*80,VERS$*80,BKEYS,BKEYDESCRIPTION,LINE$*512)
24034       library : FNGETFILENUMBER
24036 ! 
24038       let LAYOUTPATH$=FNSETTINGS$("layoutpath")
24040 ! 
24042       if TRIM$(LAYOUTNAME$)<>"" AND EXISTS(LAYOUTPATH$&LAYOUTNAME$) then 
24044          if FNSMATRIXPRESENT(MAT KEYS$) then let BKEYS=1
24046          if FNSMATRIXPRESENT(MAT KEYDESCRIPTION$) then let BKEYDESCRIPTION=1
24048 ! 
24050          if BKEYS then mat KEYS$(0)
24052          if BKEYDESCRIPTION then mat KEYDESCRIPTION$(0)
24054 ! 
24056          if ~FNOPENLAYOUT(LAYOUTPATH$&LAYOUTNAME$) then goto Errorreadfilelayout
24058 ! 
24060          let LINE$=FNLAYOUTLINPUT$
24062          if UPRC$(LINE$)<>"#EOF#" then 
24064             let FNREADHEADING(LINE$,FILENAME$,PREFIX$,VERS$)
24066          else 
24068             print "Incomplete Layout."
24070             goto Errorreadfilelayout
24072          end if 
24074 ! 
24076          let LINE$=FNLAYOUTLINPUT$
24078          if UPRC$(LINE$)<>"#EOF#" then 
24080             let FNREADKEYS(LINE$,KEYNAME$,DESCRIPTION$)
24082          else 
24084             print "Incomplete Layout."
24086             goto Errorreadfilelayout
24088          end if 
24090 ! 
24092          do WHILE UPRC$(KEYNAME$(1:4))<>"RECL" AND KEYNAME$(1:4)<>"===="
24094             let COUNT+=1
24096             if BKEYS then 
24098                mat KEYS$(COUNT)
24100                let KEYS$(COUNT)=TRIM$(KEYNAME$)
24102             end if 
24104             if BKEYDESCRIPTION then 
24106                mat KEYDESCRIPTION$(COUNT)
24108                let KEYDESCRIPTION$(COUNT)=TRIM$(DESCRIPTION$)
24110             end if 
24112 ! 
24114             let LINE$=FNLAYOUTLINPUT$
24116             if UPRC$(LINE$)<>"#EOF#" then 
24118                let FNREADKEYS(LINE$,KEYNAME$,DESCRIPTION$)
24120             else 
24122                print "Incomplete Layout."
24124                goto Errorreadfilelayout
24126             end if 
24128          loop 
24130          if UPRC$(KEYNAME$(1:4))="RECL" then 
24132             let LINE$=FNLAYOUTLINPUT$
24134             if UPRC$(LINE$)="#EOF#" then 
24136                print "Incomplete Layout."
24138                goto Errorreadfilelayout
24140             end if 
24142          end if 
24144       end if 
24146       if LEAVEOPEN then 
24148          let FNREADLAYOUTHEADER=1
24150       else 
24152          let FNREADLAYOUTHEADER=COUNT
24154       end if 
24156    fnend 
24158 ! 
24160 Readsubs: ! Read File Layout, Returning All Subscripts As An Array
24162    def library FNREADSUBS(FILENAME$*255,MAT SSUBS$,MAT NSUBS$,&PREFIX$)
24164 ! .      ! Included for Backwards Compatability Only
24166       library : FNREADLAYOUTARRAYS
24168       let FNREADLAYOUTARRAYS(FILENAME$,PREFIX$,MAT SSUBS$,MAT NSUBS$)
24170    fnend 
24172 ! 
24174 Readlayoutarrays: ! Read File Layout, Returning Everything As Some Arrays
24176    def library FNREADLAYOUTARRAYS(LAYOUTNAME$*255,&PREFIX$;MAT SSUBS$,MAT NSUBS$,MAT SSPEC$,MAT NSPEC$,MAT SDESCRIPTION$,MAT NDESCRIPTION$,MAT SPOS,MAT NPOS,ALREADYOPENFILENUMBER,___,INDEX,DUMMY$*512,DUMMY2$*255,SUBNAME$*255,LAYOUT,DESCRIPTION$*255,SPEC$*255,BSSUBS,BNSUBS,BSDESCRIPTION,BNDESCRIPTION,BSSPEC,BNSPEC,BSPOS,BNPOS,POSITION,COUNT,LINE$*512)
24178       library : FNGETFILENUMBER
24180 ! 
24182       let POSITION=1
24184       let LAYOUTPATH$=FNSETTINGS$("layoutpath") ! Read File Layout Path
24186 ! 
24188       if TRIM$(LAYOUTNAME$)<>"" AND EXISTS(LAYOUTPATH$&LAYOUTNAME$) then 
24190          if FNSMATRIXPRESENT(MAT SSUBS$) then let BSSUBS=1
24192          if FNSMATRIXPRESENT(MAT NSUBS$) then let BNSUBS=1
24194          if FNSMATRIXPRESENT(MAT SSPEC$) then let BSSPEC=1
24196          if FNSMATRIXPRESENT(MAT NSPEC$) then let BNSPEC=1
24198          if FNSMATRIXPRESENT(MAT SDESCRIPTION$) then let BSDESCRIPTION=1
24200          if FNSMATRIXPRESENT(MAT NDESCRIPTION$) then let BNDESCRIPTION=1
24202          if FNNMATRIXPRESENT(MAT SPOS) then let BSPOS=1
24204          if FNNMATRIXPRESENT(MAT NPOS) then let BNPOS=1
24206 ! 
24208          if BSSUBS then mat SSUBS$(0)
24210          if BNSUBS then mat NSUBS$(0)
24212          if BSSPEC then mat SSPEC$(0)
24214          if BNSPEC then mat NSPEC$(0)
24216          if BSDESCRIPTION then mat SDESCRIPTION$(0)
24218          if BNDESCRIPTION then mat NDESCRIPTION$(0)
24220          if BSPOS then mat SPOS(0)
24222          if BNPOS then mat NPOS(0)
24224 ! 
24226          if ALREADYOPENFILENUMBER then 
24228 ! .            ! Then we're already there.
24230 ! .            ! Otherwise, (below) we get the prefix and skip to the details
24232          else 
24234             if ~FNOPENLAYOUT(LAYOUTPATH$&LAYOUTNAME$) then goto Errorreadfilelayout
24236             let LINE$=FNLAYOUTLINPUT$
24238             if UPRC$(LINE$)<>"#EOF#" then 
24240                let FNREADHEADING(LINE$,DUMMY$,PREFIX$,DUMMY2$)
24242                let PREFIX$=TRIM$(PREFIX$)
24244             else 
24246                print "Incomplete Layout."
24248                goto Errorreadfilelayout
24250             end if 
24252             do 
24254                let LINE$=FNLAYOUTLINPUT$
24256                if UPRC$(LINE$)="#EOF#" then 
24258                   print "Incomplete Layout."
24260                   goto Errorreadfilelayout
24262                end if 
24264             loop WHILE UPRC$(LINE$(1:4))<>"RECL" AND LINE$(1:4)<>"===="
24266             if UPRC$(LINE$(1:4))="RECL" then 
24268                let LINE$=FNLAYOUTLINPUT$
24270                if UPRC$(LINE$)="#EOF#" then 
24272                   print "Incomplete Layout."
24274                   goto Errorreadfilelayout
24276                end if 
24278             end if 
24280          end if 
24282 Readnextlayoutline: ! Read The Next Line For Processing
24284          let LINE$=FNLAYOUTLINPUT$
24286          if UPRC$(LINE$)="#EOF#" then goto Donereadlayoutarrays
24288          let SUBNAME$=TRIM$(SREP$(LINE$(1:POS(LINE$,",")-1),CHR$(9)," "))
24290          let LINE$=LINE$(POS(LINE$,",")+1:LEN(LINE$))
24292          let DESCRIPTION$=TRIM$(SREP$(LINE$(1:POS(LINE$,",")-1),CHR$(9)," "))
24294          let LINE$=LINE$(POS(LINE$,",")+1:LEN(LINE$))
24296          if POS(LINE$,",") then 
24298             let SPEC$=TRIM$(SREP$(LINE$(1:POS(LINE$,",")-1),CHR$(9)," "))
24300          else 
24302             let SPEC$=TRIM$(SREP$(LINE$,CHR$(9)," "))
24304          end if 
24306 ! 
24308          if TRIM$(UPRC$(SPEC$))(1:2)<>"X " then 
24310             if TRIM$(SUBNAME$)<>"" then 
24312                if POS(SUBNAME$,"$") then 
24314                   let COUNT+=1
24316                   if BSSUBS then 
24318                      mat SSUBS$(UDIM(SSUBS$)+1)
24320                      let SSUBS$(UDIM(SSUBS$))=TRIM$(SREP$(SUBNAME$,"$",""))
24322                   end if 
24324                   if BSSPEC then 
24326                      mat SSPEC$(UDIM(SSPEC$)+1)
24328                      let SSPEC$(UDIM(SSPEC$))=TRIM$(SPEC$)
24330                   end if 
24332                   if BSDESCRIPTION then 
24334                      mat SDESCRIPTION$(UDIM(SDESCRIPTION$)+1)
24336                      let SDESCRIPTION$(UDIM(SDESCRIPTION$))=TRIM$(DESCRIPTION$)
24338                   end if 
24340                   if BSPOS then 
24342                      mat SPOS(UDIM(SPOS)+1)
24344                      let SPOS(UDIM(SPOS))=POSITION
24346                   end if 
24348                else 
24350                   if BNSUBS then 
24352                      mat NSUBS$(UDIM(NSUBS$)+1)
24354                      let NSUBS$(UDIM(NSUBS$))=TRIM$(SUBNAME$)
24356                   end if 
24358                   if BNSPEC then 
24360                      mat NSPEC$(UDIM(NSPEC$)+1)
24362                      let NSPEC$(UDIM(NSPEC$))=TRIM$(SPEC$)
24364                   end if 
24366                   if BNDESCRIPTION then 
24368                      mat NDESCRIPTION$(UDIM(NDESCRIPTION$)+1)
24370                      let NDESCRIPTION$(UDIM(NDESCRIPTION$))=TRIM$(DESCRIPTION$)
24372                   end if 
24374                   if BNPOS then 
24376                      mat NPOS(UDIM(NPOS)+1)
24378                      let NPOS(UDIM(NPOS))=POSITION
24380                   end if 
24382                end if 
24384             end if 
24386          end if 
24388          let POSITION+=FNLENGTHOF(TRIM$(SPEC$))
24390          goto Readnextlayoutline
24392 Donereadlayoutarrays: ! We Finished With All The File Layout
24394          let FNREADLAYOUTARRAYS=COUNT
24396       end if 
24398    fnend 
24400 ! 
24402 Readkeyfiles: ! This Function Reads The Key File List Of A File Layout
24404    def library FNREADKEYFILES(LAYOUT$,MAT KEYS$;___,FILENAME$*255)
24406 ! .      ! Included for Backwards Compatability
24408       let FNFINDINDEXES(LAYOUT$,FILENAME$,MAT KEYS$)
24410    fnend 
24412 ! 
24414 Buildkey: ! This Function Builds A Key Off Of Mat F$ And Mat F
24416    def library FNBUILDKEY$*255(LAYOUT$*30,MAT F$,MAT F;KEYNUM,___,FILENAME$*80,PREFIX$,INDEX,KEYPART$*30,KEYFIELDS$*80,KEY$*255)
24418 ! 
24420       dim BK_KEYS$(1)*80
24422       dim BK_KEYFIELDS$(1)*80
24424       dim BK_SSUBS$(1)*80
24426       dim BK_NSUBS$(1)*80
24428       dim BK_SSPEC$(1)*80
24430       dim BK_NSPEC$(1)*80
24432       dim BK_LASTLAYOUT$*30
24434 ! 
24436       if (TRIM$(LAYOUT$)<>"") AND (UDIM(MAT F$)+UDIM(MAT F)) then 
24438          if LAYOUT$<>BK_LASTLAYOUT$ then 
24440 ! 
24442             library : FNREADENTIRELAYOUT, FNKEY$
24444 ! 
24446             mat BK_KEYS$(0)
24448             mat BK_KEYFIELDS$(0)
24450 ! 
24452             let FNREADENTIRELAYOUT(LAYOUT$,FILENAME$,PREFIX$,MAT BK_KEYS$,MAT BK_KEYFIELDS$,MAT BK_SSUBS$,MAT BK_NSUBS$,MAT BK_SSPEC$,MAT BK_NSPEC$)
24454 ! 
24456             for INDEX=1 to UDIM(MAT BK_SSUBS$)
24458                let BK_SSUBS$(INDEX)=LWRC$(BK_SSUBS$(INDEX))
24460             next INDEX
24462             for INDEX=1 to UDIM(MAT BK_NSUBS$)
24464                let BK_NSUBS$(INDEX)=LWRC$(BK_NSUBS$(INDEX))
24466             next INDEX
24468 ! 
24470             let BK_LASTLAYOUT$=LAYOUT$
24472 ! 
24474          end if 
24476 ! 
24478          if UDIM(MAT BK_KEYS$) then 
24480 ! 
24482             if KEYNUM=0 then let KEYNUM=1
24484             let KEYFIELDS$=LWRC$(TRIM$(BK_KEYFIELDS$(KEYNUM)))
24486 ! 
24488             do 
24490                if POS(KEYFIELDS$,"/") then 
24492                   let KEYPART$=KEYFIELDS$(1:POS(KEYFIELDS$,"/")-1)
24494                   let KEYFIELDS$(1:POS(KEYFIELDS$,"/"))=""
24496                else 
24498                   let KEYPART$=KEYFIELDS$
24500                   let KEYFIELDS$=""
24502                end if 
24504 ! 
24506                if (INDEX:=SRCH(MAT BK_SSUBS$,KEYPART$))>0 then 
24508                   let KEY$=KEY$&RPAD$(RTRM$(F$(INDEX))(1:FNLENGTHOF(BK_SSPEC$(INDEX))),FNLENGTHOF(BK_SSPEC$(INDEX)))
24510                else if (INDEX:=SRCH(MAT BK_NSUBS$,KEYPART$))>0 then 
24512                   let KEY$=KEY$&CNVRT$(BK_NSPEC$(INDEX),F(INDEX))
24514                end if 
24516             loop WHILE LEN(KEYFIELDS$)
24518 ! 
24520             let FNBUILDKEY$=KEY$
24522          end if 
24524       end if 
24526    fnend 
24528 ! 
25000 ! #Autonumber# 25000,5
25005 Closefile: ! ***** Close A File, Closing All Indexes == Use Only With Files Opened I/O With This Library
25010    def library FNCLOSEFILE(FILENUMBER, FILELAY$*255;PATH$*255,OUT,___,REMAINING,FILENAME$*255,CLOSEFILESIMPLE)
25015 ! .      ! Out forces not checking if its input or outin - use to increase speed
25020 ! .      !  when you know for a fact the file is opened outin
25025 ! .      !  -1 will force input, 1 will force output, 0 or not specified will check.
25030 ! 
25035       let CLOSEFILESIMPLE=FNSETTINGS("closefilesimple")
25040 ! 
25045       if OUT=-1 OR (~OUT AND FNINPUT(FILENUMBER)) then 
25050          close #FILENUMBER: 
25055       else 
25060          let REMAINING=FNFINDINDEXES(FILELAY$,FILENAME$)
25065 ! 
25070          if CLOSEFILESIMPLE OR ~FN418 then 
25075             let FILENAME$=SREP$(UPRC$(FILENAME$),"[WSID]",WSID$)
25080             let FILENAME$=SREP$(UPRC$(FILENAME$),"[SESSION]",SESSION$)
25085          end if 
25090 ! 
25095          if KLN(FILENUMBER)=-1 then let REMAINING+=1
25100          do WHILE FILENUMBER<=999
25105             if ~CLOSEFILESIMPLE AND FN418 then 
25110                if UPRC$(OS_FILENAME$(FILE$(FILENUMBER)))=UPRC$(OS_FILENAME$(PATH$&FILENAME$)) then 
25115                   close #(FILENUMBER): ! Close Only If Its This File
25120                   let REMAINING-=1
25125                end if 
25130             else 
25135                if POS(UPRC$(FILE$(FILENUMBER)),"\"&UPRC$(FILENAME$)) OR UPRC$(FILE$(FILENUMBER))=UPRC$(FILENAME$) then 
25140                   close #(FILENUMBER): ! Close Only If Its This File
25145                   let REMAINING-=1
25150                end if 
25155             end if 
25160             let FILENUMBER+=1
25165          loop WHILE REMAINING>0
25170       end if 
25175    fnend 
25180 ! 
25185    def FNINPUT(FILENUMBER;___,DISPLAYFILE,LINE$*255,STAR$)
25190       let STAR$=FNNEEDSTAR$
25195       library : FNGETFILENUMBER
25200       if EXISTS("fileinfo."&SESSION$) then execute STAR$&"free fileinfo."&SESSION$
25205       execute STAR$&"status files >fileinfo."&SESSION$
25210       open #(DISPLAYFILE:=FNGETFILENUMBER): "name=fileinfo."&SESSION$, display, input 
25215 Readnextinfoline: ! Check The Next Input Line
25220       linput #DISPLAYFILE: LINE$ eof Doneinput
25225       if POS(LWRC$(LINE$),"open file #"&LPAD$(STR$(FILENUMBER),3)) then 
25230          linput #DISPLAYFILE: LINE$
25235          if POS(LWRC$(LINE$),"input") then 
25240             let FNINPUT=1
25245          end if 
25250          goto Doneinput
25255       end if 
25260       goto Readnextinfoline
25265 Doneinput: ! Done Fninput Here
25270       close #DISPLAYFILE: 
25275       execute STAR$&"free fileinfo."&SESSION$
25280    fnend 
25285 ! 
25500 ! #Autonumber# 25500,2
25502 Makesubproc: ! Read File Layout, Returning All Subscripts As A Procfile
25504    def library FNMAKESUBPROC(FILENAME$*255;MAT SUBS$,___,INDEX,DUMMY$*512,DUMMY2$*255,SUBNAME$*255,LAYOUT,SUBS,PREFIX$*255,LAYOUTPATH$*255,STRINGSIZE,NUMBERSIZE,LINE$*512,STAR$)
25506       let STAR$=FNNEEDSTAR$
25508       let LAYOUTPATH$=FNSETTINGS$("layoutpath")
25510 ! 
25512       if ~FNOPENLAYOUT(LAYOUTPATH$&FILENAME$) then goto Errorreadfilelayout
25514 ! 
25516       if FNSMATRIXPRESENT(MAT SUBS$) then 
25518          mat SUBS$(0)
25520       else 
25522          open #(SUBS:=FNGETFILENUMBER): "Name=subs.$$$, replace", display, output 
25524       end if 
25526 ! 
25528       let LINE$=FNLAYOUTLINPUT$
25530       if UPRC$(LINE$)<>"#EOF#" then 
25532          let FNREADHEADING(LINE$,DUMMY$,PREFIX$,DUMMY2$)
25534          let PREFIX$=TRIM$(PREFIX$)
25536       else 
25538          print "Incomplete Layout."
25540          goto Errorreadfilelayout
25542       end if 
25544 ! 
25546       do 
25548          let LINE$=FNLAYOUTLINPUT$
25550          if UPRC$(LINE$)="#EOF#" then 
25552             print "Incomplete Layout."
25554             goto Errorreadfilelayout
25556          end if 
25558       loop WHILE UPRC$(LINE$(1:4))<>"RECL" AND LINE$(1:4)<>"===="
25560       if UPRC$(LINE$(1:4))="RECL" then 
25562          let LINE$=FNLAYOUTLINPUT$
25564          if UPRC$(LINE$)="#EOF#" then 
25566             print "Incomplete Layout."
25568             goto Errorreadfilelayout
25570          end if 
25572       end if 
25574 ! 
25576 Readnextsubprocline: ! Read The Next Line For Processing
25578       let LINE$=FNLAYOUTLINPUT$
25580       if UPRC$(LINE$)="#EOF#" then goto Donemakesubproc
25582       if POS(LINE$,",") then 
25584          let SUBNAME$=TRIM$(SREP$(LINE$(1:POS(LINE$,",")-1),CHR$(9)," "))
25586       else 
25588          let SUBNAME$=TRIM$(SREP$(LINE$,CHR$(9)," "))
25590       end if 
25592 ! 
25594       if TRIM$(UPRC$(DUMMY2$))(1:2)<>"X " then 
25596          if TRIM$(SUBNAME$)<>"" then 
25598             if POS(SUBNAME$,"$") then 
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
25638    fnend 
25640 ! 
25642 ! 
25644    dim ADDTOSUBSCOUNT
25646 Addtosubsarray: ! Adds Subscripts To A Processing Effecient Array
25648    def FNADDTOSUBSARRAY(STRING$*70,MAT SUBS$,STAR$;___,INDEX)
25650 ! 
25652       let ADDTOSUBSCOUNT+=1
25654       let INDEX=UDIM(MAT SUBS$)
25656 ! 
25658       if INDEX=0 OR ADDTOSUBSCOUNT>31 OR (~FN418 AND LEN(SUBS$(INDEX))>127) then 
25660          gosub Addnewone
25662       else 
25664          let SUBS$(INDEX)=SUBS$(INDEX)&":"&STRING$ soflow Erroraddnewone
25666       end if 
25668    fnend 
25670 ! 
25672 Erroraddnewone: gosub Addnewone : continue 
25674 Addnewone: ! Add A New Sub Line
25676    let ADDTOSUBSCOUNT=1
25678    let INDEX+=1
25680    mat SUBS$(INDEX)
25682    let SUBS$(INDEX)=STAR$&STRING$
25684    return 
25686 ! 
25688    dim DUMMY2$(1)*255
25690    dim DUMMY3$(1)*255
25692    dim DUMMY4$(1)*255
25694    dim DUMMY5$(1)*255
25696    dim READFORM$*10000
25698    def library FNREADFORM$*10000(FILENAME$*255;___,DUMMY$*255,DUMMY,DUMMY2,DUMMY3)
25700       let FNREADFILELAYOUT(FILENAME$,DUMMY$,MAT DUMMY$,MAT DUMMY2$,MAT DUMMY3$,READFORM$,DUMMY,DUMMY2,0,DUMMY3,MAT DUMMY4$,MAT DUMMY,MAT DUMMY5$,1)
25702       let FNREADFORM$=READFORM$
25704    fnend 
25706    def library FNREADFORMANDSUBS(FILENAME$,MAT SUBS$,&READFORM$,&STRINGSIZE,&NUMBERSIZE)
25708       let FNREADFILELAYOUT(FILENAME$,DUMMY$,MAT DUMMY$,MAT DUMMY2$,MAT DUMMY3$,READFORM$,STRINGSIZE,NUMBERSIZE,0,DUMMY3,MAT DUMMY4$,MAT DUMMY,MAT SUBS$)
25710    fnend 
25712 ! 
25714 ! 
25716    dim LAYOUTNAMES$(1)*255
25718    dim LAYOUTSTART(1)
25720 ! 
25722    dim LAYOUTDATA$(1)*511
25724    dim LAYOUTLINE$*511
25726 ! 
25728    dim CURRENTLAYOUT, LAYOUTPOSITION
25730 ! 
25732    def FNOPENLAYOUT(LAYOUTNAME$*255;___,LAYOUT)
25734       let LAYOUTNAME$=LWRC$(TRIM$(LAYOUTNAME$))
25736       let CURRENTLAYOUT=SRCH(MAT LAYOUTNAMES$,LAYOUTNAME$)
25738       if CURRENTLAYOUT>0 then 
25740 ! .      ! Found, read it from memory
25742          let FNOPENLAYOUT=1
25744       else 
25746          let CURRENTLAYOUT=UDIM(MAT LAYOUTNAMES$)+1
25748          mat LAYOUTNAMES$(CURRENTLAYOUT)
25750          mat LAYOUTSTART(CURRENTLAYOUT)
25752 ! 
25754          let LAYOUTPOSITION=UDIM(MAT LAYOUTDATA$)+1
25756 ! 
25758          let LAYOUTSTART(CURRENTLAYOUT)=LAYOUTPOSITION
25760          let LAYOUTNAMES$(CURRENTLAYOUT)=LAYOUTNAME$
25762 ! 
25764 ! .      ! Read it from the disk and place it in Memory
25766          open #(LAYOUT:=FNGETFILENUMBER): "Name="&LAYOUTNAME$&",shr", display, input error Ignore
25768 ! 
25770          do WHILE FILE(LAYOUT)=0
25772             linput #LAYOUT: LAYOUTLINE$ eof Ignore
25774             if FILE(LAYOUT)=0 then 
25776                if LEN(TRIM$(LAYOUTLINE$)) AND TRIM$(LAYOUTLINE$)(1:1)<>"!" then 
25778                   mat LAYOUTDATA$(LAYOUTPOSITION)
25780                   let LAYOUTDATA$(LAYOUTPOSITION)=LAYOUTLINE$
25782                   let LAYOUTPOSITION+=1
25784                   let FNOPENLAYOUT=1
25786                end if 
25788             end if 
25790          loop 
25792 ! 
25794          mat LAYOUTDATA$(LAYOUTPOSITION)
25796          let LAYOUTDATA$(LAYOUTPOSITION)="#EOF#"
25798          close #LAYOUT: 
25800       end if 
25802       let LAYOUTPOSITION=LAYOUTSTART(CURRENTLAYOUT)
25804    fnend 
25806 ! 
25808    def FNLAYOUTLINPUT$*512
25810       if CURRENTLAYOUT AND LAYOUTPOSITION then 
25812          if LAYOUTPOSITION<=UDIM(MAT LAYOUTDATA$) then 
25814             let FNLAYOUTLINPUT$=LAYOUTDATA$(LAYOUTPOSITION)
25816             let LAYOUTPOSITION+=1
25818          end if 
25820       end if 
25822    fnend 
25824 ! 
25826 ! 
26000 ! #Autonumber# 26000,5
26005 Readfilelayout: ! Read Filelayout, Modify All Parameters, Apply Subscripts
26010    def FNREADFILELAYOUT(&FILENAME$,&RECL$,MAT KEYNAME$,MAT KPOS$,MAT KLEN$,&FORM$,&STRINGSIZE,&NUMBERSIZE,DONT_SORT_SUBS,&VER,MAT DESCRIPTION$,MAT FIELDWIDTHS;MAT SUBS$,DONTCFORM,___,POSITION,PREFIX$,LASTSTRING,LASTNUMBER,SUBS,LINE$*512,CALCRECL,STAR$)
26015       let STAR$=FNNEEDSTAR$
26020       dim RFL_SDESCR$(1)*80,RFL_NDESCR$(1)*80,RFL_DESCR$(1)*80,RFL_SWIDTH(1),RFL_NWIDTH(1),RFL_WIDTH(1)
26025       dim STRINGFORM$*4000, NUMBERFORM$*4000
26030       dim KEYNAME$*255,DESCRIPTION$*80,TEMPFORM$*80,SUBNAME$*80,VER$*80
26035       let STRINGFORM$=NUMBERFORM$=""
26040       let KEYNAME$=DESCRIPTION$=TEMPFORM$=SUBNAME$=VER$=""
26045       mat KEYNAME$(0) : mat KPOS$(0) : mat KLEN$(0) : mat RFL_SDESCR$(0) : mat RFL_NDESCR$(0) : mat RFL_DESCR$(0) : mat RFL_SWIDTH(0) : mat RFL_NWIDTH(0) : mat RFL_WIDTH(0)
26050       let LAYOUTPATH$=FNSETTINGS$("layoutpath")
26055       let STRINGSIZE=0 : let NUMBERSIZE=0 : let FORM$=""
26060 ! 
26065       if ~FNOPENLAYOUT(LAYOUTPATH$&FILENAME$) then goto Errorreadfilelayout
26070 ! 
26075       if FNSMATRIXPRESENT(MAT SUBS$) then 
26080          mat SUBS$(0)
26085       else 
26090          open #(SUBS:=FNGETFILENUMBER): "Name=subs.$$$, replace", display, output 
26095       end if 
26100 ! 
26105       let LINE$=FNLAYOUTLINPUT$
26110       if UPRC$(LINE$)<>"#EOF#" then 
26115          let FNREADHEADING(LINE$,FILENAME$,PREFIX$,VER$)
26120          let VER=VAL(VER$) error Errorreadfilelayout
26125          let PREFIX$=TRIM$(PREFIX$) : let FILENAME$=TRIM$(FILENAME$)
26130       else 
26135          print "Incomplete Layout."
26140          goto Errorreadfilelayout
26145       end if 
26150 ! 
26155       let LINE$=FNLAYOUTLINPUT$
26160       if UPRC$(LINE$)<>"#EOF#" then 
26165          let FNREADKEYS(LINE$,KEYNAME$,DESCRIPTION$)
26170       else 
26175          print "Incomplete Layout."
26180          goto Errorreadfilelayout
26185       end if 
26190 ! 
26195       do WHILE UPRC$(KEYNAME$(1:4))<>"RECL" AND KEYNAME$(1:4)<>"===="
26200          mat KEYNAME$(UDIM(KEYNAME$)+1) !:
               mat KPOS$(UDIM(KEYNAME$)) !:
               mat KLEN$(UDIM(KEYNAME$))
26205          let KEYNAME$(UDIM(KEYNAME$))=TRIM$(KEYNAME$) !:
               let KPOS$(UDIM(KPOS$))=TRIM$(DESCRIPTION$) !:
               let KLEN$(UDIM(KLEN$))=TRIM$(DESCRIPTION$)
26210 ! 
26215          let LINE$=FNLAYOUTLINPUT$
26220          if UPRC$(LINE$)<>"#EOF#" then 
26225             let FNREADKEYS(LINE$,KEYNAME$,DESCRIPTION$)
26230          else 
26235             print "Incomplete Layout."
26240             goto Errorreadfilelayout
26245          end if 
26250       loop 
26255 ! 
26260       if KEYNAME$(1:4)="====" then 
26265          let CALCRECL=1
26270       else 
26275          let RECL$=TRIM$(KEYNAME$)
26280          let LINE$=FNLAYOUTLINPUT$
26285          if UPRC$(LINE$)="#EOF#" then 
26290             print "Incomplete Layout."
26295             goto Errorreadfilelayout
26300          end if 
26305       end if 
26310 ! 
26315       let POSITION=1
26320 Readnextline: ! Read The Next Line For Processing
26325       let LINE$=FNLAYOUTLINPUT$
26330       if UPRC$(LINE$)="#EOF#" then goto Donereadlayout
26335 ! 
26340       let SUBNAME$=TRIM$(SREP$(LINE$(1:POS(LINE$,",")-1),CHR$(9)," "))
26345       let LINE$=LINE$(POS(LINE$,",")+1:LEN(LINE$))
26350       let DESCRIPTION$=TRIM$(SREP$(LINE$(1:POS(LINE$,",")-1),CHR$(9)," "))
26355       let LINE$=LINE$(POS(LINE$,",")+1:LEN(LINE$))
26360       if POS(LINE$,",") then 
26365          let TEMPFORM$=TRIM$(SREP$(LINE$(1:POS(LINE$,",")-1),CHR$(9)," "))
26370       else 
26375          let TEMPFORM$=TRIM$(SREP$(LINE$,CHR$(9)," "))
26380       end if 
26385 ! 
26390       let FNCHECKKEYS(MAT KPOS$,MAT KLEN$,TRIM$(SUBNAME$),POSITION,TRIM$(TEMPFORM$)) error Errorreadfilelayout
26395       if TRIM$(TEMPFORM$)<>"" then 
26400          if TRIM$(UPRC$(TEMPFORM$))(1:2)<>"X " then 
26405             mat RFL_DESCR$(UDIM(MAT RFL_DESCR$)+1)
26410             let RFL_DESCR$(UDIM(MAT RFL_DESCR$))=TRIM$(DESCRIPTION$)
26415             mat RFL_WIDTH(UDIM(MAT RFL_WIDTH)+1)
26420             let RFL_WIDTH(UDIM(MAT RFL_WIDTH))=FNDISPLAYLENGTHOF(TRIM$(TEMPFORM$))
26425             if POS(SUBNAME$,"$") then 
26430                let STRINGSIZE+=1
26435                if SUBS then 
26440                   print #SUBS: "let "&TRIM$(PREFIX$)&TRIM$(SREP$(SUBNAME$,"$",""))&"="&STR$(STRINGSIZE)
26445                else 
26450                   let FNADDTOSUBSARRAY("let "&TRIM$(PREFIX$)&TRIM$(SREP$(SUBNAME$,"$",""))&"="&STR$(STRINGSIZE),MAT SUBS$,STAR$)
26455                end if 
26460                if LASTSTRING<>POSITION AND POSITION<>1 then let STRINGFORM$=STRINGFORM$&"POS "&STR$(POSITION)&","
26465                let FNADDTOFORM(STRINGFORM$,TRIM$(TEMPFORM$))
26470                let LASTSTRING=POSITION+FNLENGTHOF(TRIM$(TEMPFORM$))
26475                mat RFL_SDESCR$(STRINGSIZE)
26480                let RFL_SDESCR$(STRINGSIZE)=TRIM$(DESCRIPTION$)
26485                mat RFL_SWIDTH(STRINGSIZE)
26490                let RFL_SWIDTH(STRINGSIZE)=FNDISPLAYLENGTHOF(TRIM$(TEMPFORM$))
26495             else 
26500                let NUMBERSIZE+=1
26505                if SUBS then 
26510                   print #SUBS: "let "&TRIM$(PREFIX$)&TRIM$(SUBNAME$)&"="&STR$(NUMBERSIZE)
26515                else 
26520                   let FNADDTOSUBSARRAY("let "&TRIM$(PREFIX$)&TRIM$(SUBNAME$)&"="&STR$(NUMBERSIZE),MAT SUBS$,STAR$)
26525                end if 
26530                if LASTNUMBER<>POSITION then let NUMBERFORM$=NUMBERFORM$&"POS "&STR$(POSITION)&","
26535                let FNADDTOFORM(NUMBERFORM$,TRIM$(TEMPFORM$))
26540                let LASTNUMBER=POSITION+FNLENGTHOF(TRIM$(TEMPFORM$))
26545                mat RFL_NDESCR$(NUMBERSIZE)
26550                let RFL_NDESCR$(NUMBERSIZE)=TRIM$(DESCRIPTION$)
26555                mat RFL_NWIDTH(NUMBERSIZE)
26560                let RFL_NWIDTH(NUMBERSIZE)=FNDISPLAYLENGTHOF(TRIM$(TEMPFORM$))
26565             end if 
26570          end if 
26575          let FNADDTOFORM(FORM$,TRIM$(TEMPFORM$))
26580          let POSITION+=FNLENGTHOF(TRIM$(TEMPFORM$))
26585       end if 
26590       goto Readnextline
26595 Donereadlayout: ! We Finished With All The File Layout
26600       if CALCRECL then let RECL$="recl="&STR$(POSITION-1)
26605       let FNCHECKUPRC(MAT KPOS$,MAT KLEN$)
26610       if ~DONT_SORT_SUBS then let FORM$=STRINGFORM$&NUMBERFORM$
26615       let FNFINDANDFIXRPT(FORM$)
26620       let FORM$="form "&FORM$(1:(LEN(FORM$)-1))
26625       let FORM$=CFORM$(FORM$) error IGNORE
26630       if FNSMATRIXPRESENT(MAT DESCRIPTION$) then 
26635          if DONT_SORT_SUBS then ! Resize And Copy Unsorted
26640             mat DESCRIPTION$(UDIM(MAT RFL_DESCR$))=RFL_DESCR$
26645          else ! Resize And Sort And Copy Seperately
26650             mat DESCRIPTION$(STRINGSIZE+NUMBERSIZE) ! Resize
26655             if STRINGSIZE>0 then mat DESCRIPTION$(1:STRINGSIZE)=RFL_SDESCR$ ! Copy Strings
26660             if NUMBERSIZE>0 then mat DESCRIPTION$(STRINGSIZE+1:STRINGSIZE+NUMBERSIZE)=RFL_NDESCR$ ! Copy Numbers
26665          end if 
26670       end if 
26675       if FNNMATRIXPRESENT(MAT FIELDWIDTHS) then 
26680          if DONT_SORT_SUBS then ! Resize And Copy Unsorted
26685             mat FIELDWIDTHS(UDIM(MAT RFL_WIDTH))=RFL_WIDTH
26690          else ! Resize And Sort And Copy Seperately
26695             mat FIELDWIDTHS(STRINGSIZE+NUMBERSIZE) ! Resize
26700             if STRINGSIZE>0 then mat FIELDWIDTHS(1:STRINGSIZE)=RFL_SWIDTH ! Copy Strings
26705             if NUMBERSIZE>0 then mat FIELDWIDTHS(STRINGSIZE+1:STRINGSIZE+NUMBERSIZE)=RFL_NWIDTH ! Copy Numbers
26710          end if 
26715       end if 
26720       if SUBS then close #SUBS: 
26725       let FNREADFILELAYOUT=1 ! Success!
26730 Exitfnreadfilelayout: ! Exit Fnreadfilelayout
26735    fnend 
26740 Errorreadfilelayout: ! Error Encountered Parsing File Layout
26745    if IGNOREERRORS then goto Exitfnreadfilelayout
26750    print "Error parsing file layout: "&STR$(ERR)&" on line: "&STR$(LINE)
26755    if LINE=27060 then print "Look for a missing comma in your detail lines."
26760    if LINE=25110 then print "Check for proper definition of your keyfiles, terminated by a 'recl=' line."
26765    if LINE=25525 then print "Subscript too long. Look for a missing comma in your detail lines."
26770    if LINE=56825 then print "Invalid Form statement: form "&FORM$(1:(LEN(FORM$)-1))
26775    if LINE=25062 then print "Problem Parsing Version Parameter: "&VER$
26780    pause  ! Give User A Chance To Parse Variables
26785    execute "system"
26790 ! 
27000 ! #Autonumber# 27000,5
27005 Checkkeys: ! Routine To Check If A Given Subname Matches Part Of A Key Spec
27010    def FNCHECKKEYS(MAT KPOS$,MAT KLEN$,SUBNAME$*50,POSITION,SPEC$*30;___,INDEX)
27015       let SUBNAME$=SREP$(SUBNAME$,"$","")
27020       for INDEX=1 to UDIM(MAT KPOS$)
27025          let KPOS$(INDEX)=SREP$(UPRC$(KPOS$(INDEX)),UPRC$(SUBNAME$),STR$(POSITION))
27030          let KLEN$(INDEX)=SREP$(UPRC$(KLEN$(INDEX)),UPRC$(SUBNAME$),STR$(FNLENGTHOF(SPEC$)))
27035       next INDEX
27040    fnend 
27045    def FNCHECKUPRC(MAT KPOS$,MAT KLEN$;___,INDEX)
27050       for INDEX=1 to UDIM(MAT KPOS$)
27055          let KPOS$(INDEX)=SREP$(UPRC$(KPOS$(INDEX)),"-U","")
27060          let KLEN$(INDEX)=SREP$(UPRC$(KLEN$(INDEX)),"-U","U")
27065       next INDEX
27070    fnend 
27075 ! 
27080    def FNREADHEADING(LINE$*512,&FILENAME$,&PREFIX$,&VER$)
27085       let FNTAKETHING$(LINE$,FILENAME$)
27090       let FNTAKETHING$(LINE$,PREFIX$)
27095       let FNTAKETHING$(LINE$,VER$)
27100    fnend 
27105 ! 
27110    def FNREADKEYS(LINE$*512,&KEYNAME$,&DESCRIPTION$)
27115       let FNTAKETHING$(LINE$,KEYNAME$)
27120       let FNTAKETHING$(LINE$,DESCRIPTION$)
27125    fnend 
27130 ! 
27135    def FNTAKETHING$(&LINE$,&THING$)
27140       if POS(LINE$,",") then 
27145          let THING$=TRIM$(SREP$(LINE$(1:POS(LINE$,",")-1),CHR$(9)," "))
27150          let LINE$=LINE$(POS(LINE$,",")+1:LEN(LINE$))
27155       else 
27160          let THING$=TRIM$(SREP$(LINE$,CHR$(9)," "))
27165          let LINE$=""
27170       end if 
27175    fnend 
27180 ! 
27300 ! #Autonumber# 27300,10
27310 Lengthof: ! ***** Returns The Length Of A Given Spec
27320    def library FNLENGTH(SPEC$)
27330       let FNLENGTH=FNLENGTHOF(SPEC$)
27340    fnend 
27350    def FNLENGTHOF(SPEC$*40;_SPECLEN)
27360       let SPEC$=SPEC$&" " ! This Will Make Sure We At Least Have 1 Space
27370       if UPRC$(SPEC$(1:3))="PIC" then 
27380          let _SPECLEN=LEN(TRIM$(SPEC$))-5 ! Pic(##) Returns 2
27390       else if UPRC$(SPEC$(1:3))="FMT" then 
27400          let _SPECLEN=LEN(TRIM$(SPEC$))-5 ! Pic(##) Returns 2
27410       else if UPRC$(SPEC$(1:5))="DATE(" then 
27420          let _SPECLEN=LEN(TRIM$(SPEC$))-6 ! Date(Mm/Dd/Ccyy) Returns 10
27430       else if UPRC$(SPEC$(1:2))="S " then 
27440          let _SPECLEN=4
27450       else if UPRC$(SPEC$(1:2))="D " then 
27460          let _SPECLEN=8
27470       else if UPRC$(SPEC$(1:2))="L " then 
27480          let _SPECLEN=9
27490       else 
27500          let _SPECLEN=INT(VAL(SPEC$(POS(SPEC$," "):LEN(SPEC$)))) error Errorreadfilelayout
27510       end if 
27520       let FNLENGTHOF=_SPECLEN
27530    fnend 
27540 ! 
27600 ! #Autonumber# 27600,10
27610 Displaylengthof: ! ***** Returns The Display Length Of A Given Spec
27620    def library FNDISPLAYLENGTH(SPEC$)
27630       let FNDISPLAYLENGTH=FNDISPLAYLENGTHOF(SPEC$)
27640    fnend 
27650    def FNDISPLAYLENGTHOF(SPEC$;_SPECLEN)
27660       let SPEC$=UPRC$(SPEC$)
27670       let _SPECLEN=FNLENGTHOF(SPEC$)
27680       let SPEC$=SPEC$&" "
27690       if POS("S PDL D DLDHDTBLBHB ",SPEC$(1:2)) then ! If Numeric Spec
27700          if SPEC$(1:2)="PD" then ! Pd Is Different
27710             let _SPECLEN=(2*_SPECLEN)-1+2
27720          else ! All The Others Are About The Same
27730             let _SPECLEN=LEN(STR$(256**_SPECLEN))+2
27740          end if 
27750       end if 
27760       let FNDISPLAYLENGTHOF=_SPECLEN
27770    fnend 
27780 ! 
28000 ! #Autonumber# 28000,10
28010 Smatrixpresent: ! ***** Returns True If Optional String Array Is Given
28020    def FNSMATRIXPRESENT(;MAT X$)
28030       if ENV$("GUIMODE")="" then ! Non Gui Versions Of Br
28040          let FNSMATRIXPRESENT=UDIM(X$) ! Don't support regular test
28050       else 
28060          on error goto Smatrixnotpresent
28070          let FNSMATRIXPRESENT=1 ! Assume True
28080          mat X$(UDIM(X$)) ! Redimension Array To Test If Its Real
28090          goto Endsmatrixpresent
28100 Smatrixnotpresent: ! Error Means Optional Matrix Not Given
28110          let FNSMATRIXPRESENT=0 ! It Wasn't there
28120 Endsmatrixpresent: ! We Are Finished
28130          if G_UPDATING then !:
                  on error goto Rollbackinfull !:
               else !:
                  let FNRESETERRORHANDLING ! Turn Off Error Checking
28140       end if 
28150    fnend 
28160 ! 
28500 ! #Autonumber# 28500,10
28510 Nmatrixpresent: ! ***** Returns True If Optional Numeric Array Is Given
28520    def FNNMATRIXPRESENT(;MAT X)
28530       if ENV$("GUIMODE")="" then ! Non Gui Versions Of Br
28540          let FNNMATRIXPRESENT=UDIM(X) ! Don't support regular test
28550       else 
28560          on error goto Nmatrixnotpresent
28570          let FNNMATRIXPRESENT=1 ! Assume True
28580          mat X(UDIM(X)) ! Redimension Array To Test If Its Real
28590          goto Endnmatrixpresent
28600 Nmatrixnotpresent: ! Error Means Optional Matrix Not Given
28610          let FNNMATRIXPRESENT=0 ! It Wasn't there
28620 Endnmatrixpresent: ! We Are Finished
28630          if G_UPDATING then !:
                  on error goto Rollbackinfull !:
               else !:
                  let FNRESETERRORHANDLING ! Turn Off Error Checking
28640       end if 
28650    fnend 
28660 ! 
29000 ! #Autonumber# 29000,10
29010 Addtoform: ! ***** This Function Adds Spec$ To Form$ Checking For Repetition. Thanks To Mikhail Zheleznov For The Formula.
29020    def FNADDTOFORM(&FORM$,SPEC$*40;_LASTSPEC$*40,_REPETITION,_LASTCHUNK$*40)
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
29820    def FNLASTCHUNK$*40(&FORM$) ! Pass By Ref To Save On Workstack
29830       let FNLASTCHUNK$=FORM$(POS(FORM$,",",-2)+1:LEN(FORM$)-1)
29840    fnend 
29850 ! 
29860 Findandfixrpt: ! Searches Your Form Statement For All Subsets Of It That May Be Shortened
29870    def FNFINDANDFIXRPT(&FORM$;___,SIZE,POSITION) ! Pass And Return Byref To Save On Workstack
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
30100    def FNSTRINGTOGETHER$(MAT CHUNK$,&STRING$) ! Pass Byref To Save Workstack
30110       let STRING$=""
30120       for INDEX=1 to UDIM(MAT CHUNK$)
30130          let STRING$(4096:0)=CHUNK$(INDEX)
30140       next INDEX
30150    fnend 
30160 ! 
30170 Fixrpt: ! Function To Fix Repeating Paterns In Form Statements, Thanks To Luis Gomez And Cls
30180    def FNFIXRPT(&TF$,&STRIP$;___,RPT_TIME) ! Pass Byref To Save Workstack
30190       let RPT_TIME=INT(LEN(TF$)/LEN(STRIP$))
30200       do WHILE POS(TF$,","&STRIP$)>0
30210          let TF$=SREP$(TF$,","&RPT$(STRIP$,RPT_TIME),","&STR$(RPT_TIME)&"*("&STRIP$(1:LEN(STRIP$)-1)&"),")
30220       loop WHILE (RPT_TIME-=1)>1
30230    fnend 
30240 ! 
34000 ! #Autonumber# 34000,10
34010 Updatefile: ! Library Call To Ensure A File Is Up To Date
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
34220       read #FL, using FM$(FL), key=KEY$, release: MAT F$, MAT F nokey Ignore
34230       let FNREADDES$=TRIM$(F$(SUBSCRIPT)(1:255))
34240    fnend 
34250 Readunopeneddescription: ! ***** This Function Returns A String Field From A Given Key And File
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
34450       read #FL, using FM$(FL), key=KEY$ : MAT F$, MAT F nokey Ignore
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
34570 Readrelative: ! These Functions Read A Relative File By Record Number And Return A Single Field
34580 ! .   ! ***** This Function Returns A String Field From A File Given A record
34590    def library FNREADRELATIVEDESCRIPTION$*255(FL,SUBSCRIPT,RECORDNUMBER,MAT F$,MAT F,MAT FM$)
34600       let FNREADRELATIVEDESCRIPTION$=FNREADRELATIVEDES$(FL,SUBSCRIPT,RECORDNUMBER,MAT F$,MAT F,MAT FM$)
34610    fnend 
34620    def FNREADRELATIVEDES$*255(FL,SUBSCRIPT,RECORDNUMBER,MAT F$,MAT F,MAT FM$)
34630       mat F$=("") !:
            mat F=(0)
34640       read #FL, using FM$(FL), rec=RECORDNUMBER, release: MAT F$, MAT F norec Ignore
34650       let FNREADRELATIVEDES$=F$(SUBSCRIPT)
34660    fnend 
34670 ! .   ! ***** This function returns a string field from a record and file
34680    def library FNREADRELUNOPENEDDESCRIPTION$*255(LAYOUTNAME$,RECORDNUMBER;FIELD,___,FILENUMBER)
34690       library : FNOPENFILE
34700       if ~FIELD then let FIELD=2
34710       let FILENUMBER=FNOPEN(LAYOUTNAME$,MAT READUNOPENED$,MAT READUNOPENED,MAT READUNOPENEDFORM$,1)
34720       let FNREADRELUNOPENEDDESCRIPTION$=FNREADRELATIVEDES$(FILENUMBER,FIELD,RECORDNUMBER,MAT READUNOPENED$,MAT READUNOPENED,MAT READUNOPENEDFORM$)
34730       close #FILENUMBER: 
34740    fnend 
34750 ! 
34760 ! .   ! ***** This Function Returns A Numeric Field From A File Given A record
34770    def library FNREADRELATIVENUMBER(FL,SUBSCRIPT,RECORDNUMBER,MAT F$,MAT F,MAT FM$)
34780       let FNREADRELATIVENUMBER=FNREADRELATIVENUM(FL,SUBSCRIPT,RECORDNUMBER,MAT F$,MAT F,MAT FM$)
34790    fnend 
34800 ! 
34810    def FNREADRELATIVENUM(FL,SUBSCRIPT,RECORDNUMBER,MAT F$,MAT F,MAT FM$)
34820       mat F$=("") !:
            mat F=(0)
34830       read #FL, using FM$(FL), rec=RECORDNUMBER : MAT F$, MAT F norec Ignore
34840       let FNREADRELATIVENUM=F(SUBSCRIPT)
34850    fnend 
34860 ! 
34870    def library FNREADRELUNOPENEDNUMBER(LAYOUTNAME$,RECORDNUMBER;FIELD,___,FILENUMBER)
34880       library : FNOPENFILE
34890       if ~FIELD then let FIELD=1
34900       let FILENUMBER=FNOPEN(LAYOUTNAME$,MAT READUNOPENED$,MAT READUNOPENED,MAT READUNOPENEDFORM$,1)
34910       let FNREADRELUNOPENEDNUMBER=FNREADRELATIVENUM(FILENUMBER,FIELD,RECORDNUMBER,MAT READUNOPENED$,MAT READUNOPENED,MAT READUNOPENEDFORM$)
34920       close #FILENUMBER: 
34930    fnend 
34940 ! 
34950 Readrecordwhere: ! Search A File For A Record Based On A Filter
34960    def library FNREADRECORDWHERE$*255(LAYOUTNAME$,SEARCHSUB,SEARCHKEY$*255,RETURNSUB;___,FILENUMBER,RETURNVALUE$*255)
34970       library : FNOPENFILE
34980       let FILENUMBER=FNOPEN(LAYOUTNAME$,MAT READUNOPENED$,MAT READUNOPENED,MAT READUNOPENEDFORM$,1)
34990       if FILENUMBER then 
35000          do WHILE FILE(FILENUMBER)=0
35010             read #FILENUMBER, using READUNOPENEDFORM$(FILENUMBER), release: MAT READUNOPENED$,MAT READUNOPENED error Ignore
35020             if FILE(FILENUMBER)=0 then 
35030                if LWRC$(TRIM$(READUNOPENED$(SEARCHSUB)))=LWRC$(TRIM$(SEARCHKEY$)) then 
35040                   let RETURNVALUE$=READUNOPENED$(RETURNSUB)(1:255)
35050                end if 
35060             end if 
35070          loop UNTIL LEN(TRIM$(RETURNVALUE$))
35080          close #FILENUMBER: 
35090       end if 
35100       let FNREADRECORDWHERE$=RETURNVALUE$
35110    fnend 
35120 ! 
35130 ! 
35140 Uniquekey: ! ***** This Function Searches A File To See If A Key Is Unique
35150    def library FNUNIQUEKEY(FL,KEY$*255)
35160       restore #FL, key=KEY$: nokey Uniquekeynotfound
35170       let FNUNIQUEKEY=0 ! False - Key Is Found So Its Not Unique
35180       goto Enduniquekey
35190 Uniquekeynotfound: ! Key Not Found
35200       let FNUNIQUEKEY=1 ! True - Key Not Found So It Must Be Unique
35210 Enduniquekey: fnend 
35220 ! 
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
36370       read #FL, using FM$(FL),release: MAT F$, MAT F eof Ignore
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
36660 Nextreadallnewkeys: ! Read Next Record
36670       read #FL, using FM$(FL),release: MAT F$, MAT F eof Donereadallnewkeys
36680       if SRCH(MAT OUT1$,F$(SUB1))<1 then ! If Not Found Then
36690          mat OUT1$(INDEX:=UDIM(MAT OUT1$)+1) !:
               let OUT1$(INDEX)=F$(SUB1)
36700          if SUB2 then !:
                  mat OUT2$(INDEX) !:
                  let OUT2$(INDEX)=F$(SUB2)
36710       end if 
36720       goto Nextreadallnewkeys
36730 Donereadallnewkeys: ! We Finished Reading Here
36740    fnend 
36750 ! 
37000 ! #Autonumber# 37000,10
37010 Readfilterkeys: ! ***** Read Matching Keys, But It Also Supports Optional Filters And Up To Four Arrays May Be Populated At Once. If Readlarger=True Then Read All Larger Keys. Function By Mikhail Zheleznov
37020    def library FNREADFILTERKEYS(FL,MAT F$,MAT F,MAT FM$,KEY$,KEYFLD,SUB1,MAT OUT1$;FILTER$,FILTER_SUB,READLARGER,SUB2,MAT OUT2$, SUB3, MAT OUT3$, SUB4,MAT OUT4$, INDEX)
37030       mat OUT1$(0)
37040       if SUB2 then mat OUT2$(0)
37050       if SUB3 then mat OUT3$(0)
37060       if SUB4 then mat OUT4$(0)
37070       restore #FL, key=KEY$: nokey Donereadfilterkeys
37080 Nextreadfilterkeys: ! Read Next Record
37090       read #FL, using FM$(FL),release: MAT F$, MAT F eof Ignore
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
38020    def library FNMAKEUNIQUEKEY$*255(FL;INDEX,RANDOM)
38030       library : FNUNIQUEKEY
38040       dim MUKINDEXS(1)
38050       mat MUKINDEXS(KLN(FL))=(0)
38060       if RANDOM then 
38070          randomize 
38080          for INDEX=1 to UDIM(MUKINDEXS)
38090             let MUKINDEXS(INDEX)=INT(RND*35)
38100          next INDEX
38110       end if 
38120       do WHILE NOT FNUNIQUEKEY(FL,FNBUILDKEYFORUNIQUE$(MAT MUKINDEXS))
38130          if RANDOM then 
38140             for INDEX=1 to UDIM(MUKINDEXS)
38150                let MUKINDEXS(INDEX)=INT(RND*35)
38160             next INDEX
38170          else 
38180             let MUKINDEXS(1)+=1
38190             for INDEX=1 to UDIM(MUKINDEXS)-1
38200                if MUKINDEXS(INDEX)>35 then let MUKINDEXS(INDEX)=0 : let MUKINDEXS(INDEX+1)+=1
38210             next INDEX
38220             if MUKINDEXS(UDIM(MUKINDEXS))>35 then let MSGBOX("The system cannot sustain more then "&STR$(35**UDIM(MUKINDEXS))&" of these. Please delete old ones and try again.")
38230          end if 
38240       loop UNTIL MUKINDEXS(UDIM(MUKINDEXS))>35
38250       let FNMAKEUNIQUEKEY$=FNBUILDKEYFORUNIQUE$(MAT MUKINDEXS)
38260    fnend 
38270 ! 
38500 ! #Autonumber# 38500,10
38510 Buildkeyforuniques: ! Builds A Key Out Of The Byte Matrix Given
38520    def FNBUILDKEYFORUNIQUE$*255(MAT BKFUINDEXS;INDEX,KEY$*255)
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
39020    def FNSEARCHCLOSELY(MAT A$,B$;INDEX,FOUND)
39030       for INDEX=1 to UDIM(MAT A$)
39040          if POS(A$(INDEX),B$) then let FOUND=INDEX
39050       next INDEX
39060       let FNSEARCHCLOSELY=FOUND
39070    fnend 
39080 ! 
39090 ! 
40000 ! #Autonumber# 40000,10
40010 ! ****************
40020 ! **  Log File  **
40030 ! ****************
40040 ! 
40050    def library FNVIEWLOGFILE(;SHOWQUIT,SHOWCOLUMNS,SHOWEXPORT,___,LOGLAYOUT$*255,LAYOUTPATH$*255,INDEX)
40060 ! 
40070       if ENV$("guimode")="OFF" then execute "config gui on"
40080       let LOGLAYOUT$=FNSETTINGS$("loglayout")
40090       let LAYOUTPATH$=FNSETTINGS$("layoutpath")
40100 ! 
40110       if LEN(TRIM$(LOGLAYOUT$)) AND EXISTS(LAYOUTPATH$&LOGLAYOUT$) then 
40120          if LWRC$(TRIM$(LOGLAYOUT$))="logfile" then 
40130 ! .         ! Build list of columns to show
40140             dim COLUMNS$(6),W(6),DESCR$(6),FORMS$(6)
40150             let COLUMNS$(1)="username" : let W(1)=10 : let DESCR$(1)="Username" : let FORMS$(1)=""
40160             let COLUMNS$(2)="program" : let W(2)=12 : let DESCR$(2)="Program" : let FORMS$(2)=""
40170             let COLUMNS$(3)="session" : let W(3)=4 : let DESCR$(3)="#" : let FORMS$(3)=""
40180             let COLUMNS$(4)="date" : let W(4)=8 : let DESCR$(4)="Date" : let FORMS$(4)="DATE(mm/dd/ccyy)"
40190             let COLUMNS$(5)="time" : let W(5)=7 : let DESCR$(5)="Time" : let FORMS$(5)="CC 8"
40200             let COLUMNS$(6)="message" : let W(6)=200 : let DESCR$(6)="Message" : let FORMS$(6)=""
40210 ! 
40220 ! .         ! Configure filters for fnShowData for the LogFile
40230             dim FILTERFIELDS$(2), FILTERFORM$(2), FILTERDEFAULTS$(2), FILTERCOMPARE$(2), FILTERCAPTION$(2), FILTERKEY(2)
40240             let FILTERFIELDS$(1)="date" : let FILTERFORM$(1)="DATE(mm/dd/ccyy)" : let FILTERDEFAULTS$(1)=STR$(DAYS(DATE$)) : let FILTERCOMPARE$(1)=">=" : let FILTERCAPTION$(1)="From Date" : let FILTERKEY(1)=1
40250             let FILTERFIELDS$(2)="date" : let FILTERFORM$(2)="DATE(mm/dd/ccyy)" : let FILTERDEFAULTS$(2)=STR$(DAYS(DATE$)) : let FILTERCOMPARE$(2)="<=" : let FILTERCAPTION$(2)="To Date" : let FILTERKEY(2)=-1
40260 ! 
40270 ! .         ! Configure the UI for the LogFile
40280             dim SHOWLOGUI$(1)
40290             mat SHOWLOGUI$(3+SHOWQUIT+SHOWCOLUMNS+SHOWEXPORT)
40300 ! 
40310             let INDEX=0
40320             if SHOWQUIT then let SHOWLOGUI$(INDEX+=1)="quitbutton"
40330             if SHOWEXPORT then let SHOWLOGUI$(INDEX+=1)="exportbutton"
40340             if SHOWCOLUMNS then let SHOWLOGUI$(INDEX+=1)="columnsbutton"
40350             let SHOWLOGUI$(INDEX+=1)="search"
40360             let SHOWLOGUI$(INDEX+=1)="border"
40370             let SHOWLOGUI$(INDEX+=1)="caption"
40380 ! 
40390 ! .         ! Show the log file using fnShowData
40400             library : FNSHOWDATA
40410             let FNSHOWDATA("logfile",0,0,0,20,74,1,"Review Log File","","","",PROGRAM$,DUMMY,MAT COLUMNS$,MAT SHOWLOGUI$,MAT DESCR$,MAT W,MAT FORMS$,"date",MAT FILTERFIELDS$,MAT FILTERFORM$,MAT FILTERCOMPARE$,MAT FILTERCAPTION$,MAT FILTERDEFAULTS$,MAT FILTERKEY)
40420          else 
40430             let FNSHOWDATA(LOGLAYOUT$,0,0,0,20,74,0,"Review Log File","","","",PROGRAM$)
40440          end if 
40450       else if EXISTS("fileio.log") then 
40460          execute "system -C -M start notepad fileio.log"
40470       end if 
40480    fnend 
40490 ! 
40500 Errlog: ! ***** Log An Error Entry
40510    def library FNERRLOG(STRING$*255;CALLINGPROGRAM$*255,___,FILEHANDLE)
40520       library : FNLOG
40530       let FNLOG("Error("&STR$(ERR)&":"&STR$(LINE)&") "&STRING$,CALLINGPROGRAM$)
40540    fnend 
40550 ! 
40560    dim LOGCHANGES$(1)*1024, LOGCHANGES(1)
40570    dim LOGSSUBS$(1)*255,LOGNSUBS$(1)*255
40580    def library FNSETLOGCHANGES(MAT F$,MAT F)
40590       mat LOGCHANGES$(UDIM(MAT F$))=F$
40600       mat LOGCHANGES(UDIM(MAT F))=F
40610    fnend 
40620    def library FNLOGCHANGES(MAT F$,MAT F;STRING$*1024,CALLINGPROGRAM$*255,LAYOUT$,___,INDEX,D$)
40630       library : FNLOG, FNREADSUBS
40640       if LEN(LAYOUT$) then 
40650          let FNREADSUBS(LAYOUT$,MAT LOGSSUBS$,MAT LOGNSUBS$,D$)
40660       else 
40670          mat LOGSSUBS$(UDIM(MAT F$)) : mat LOGNSUBS$(UDIM(MAT F))
40680          for INDEX=1 to UDIM(MAT F$)
40690             let LOGSSUBS$(INDEX)="String "&STR$(INDEX)
40700          next INDEX
40710          for INDEX=1 to UDIM(MAT F)
40720             let LOGNSUBS$(INDEX)="Number "&STR$(INDEX)
40730          next INDEX
40740       end if 
40750 ! 
40760       let STRING$=STRING$&" Changed: "
40770       for INDEX=1 to MIN(UDIM(MAT F$),UDIM(MAT LOGCHANGES$))
40780          if TRIM$(F$(INDEX))<>TRIM$(LOGCHANGES$(INDEX)) then let STRING$=STRING$&" "&LOGSSUBS$(INDEX)&":"""&TRIM$(LOGCHANGES$(INDEX))&""" to """&TRIM$(F$(INDEX))&"""."
40790       next INDEX
40800       for INDEX=1 to MIN(UDIM(MAT F),UDIM(MAT LOGCHANGES))
40810          if F(INDEX)<>LOGCHANGES(INDEX) then let STRING$=STRING$&" "&LOGNSUBS$(INDEX)&":"""&STR$(LOGCHANGES(INDEX))&""" to """&STR$(F(INDEX))&"""."
40820       next INDEX
40830 ! 
40840       let FNLOG(STRING$(1:512),CALLINGPROGRAM$)
40850    fnend 
40860 ! 
40870 Logarray: ! ***** Log An Array And A Message
40880    def library FNLOGARRAY(MAT F$,MAT F;STRING$*512,CALLINGPROGRAM$*255,___,LENGTH,INDEX,FILENUMBER)
40890       library : FNLOG
40900 ! 
40910       for INDEX=1 to UDIM(MAT F$)
40920          if LEN(STRING$)+LEN(F$(INDEX))+2>512 then 
40930             let FNLOG(STRING$,CALLINGPROGRAM$)
40940             let STRING$=""
40950          end if 
40960          let STRING$=STRING$&TRIM$(F$(INDEX))&", "
40970       next INDEX
40980       for INDEX=1 to UDIM(MAT F)
40990          if LEN(STRING$)+LEN(STR$(F(INDEX)))+2>512 then 
41000             let FNLOG(STRING$,CALLINGPROGRAM$)
41010             let STRING$=""
41020          end if 
41030          let STRING$=STRING$&STR$(F(INDEX))&", "
41040       next INDEX
41050       let FNLOG(STRING$,CALLINGPROGRAM$)
41060    fnend 
41070 ! 
41080    dim LOGDATA$(1)*512
41090    dim LOGDATA(1)
41100    dim LOGFORM$(1)*256
41110 ! 
41120 Log: ! ***** Log An Entry
41130    def library FNLOG(STRING$*512;CALLINGPROGRAM$*40,FORCETEXTFILE,___,FILEHANDLE,LOGLIBRARY$*255,LOGLAYOUT$)
41140       let LOGLIBRARY$=FNSETTINGS$("loglibrary")
41150       let LOGLAYOUT$=FNSETTINGS$("loglayout")
41160 ! 
41170       if ~FORCETEXTFILE AND LEN(TRIM$(LOGLIBRARY$)) then 
41180          library LOGLIBRARY$ : FNFILEIOLOG
41190          if LEN(TRIM$(LOGLAYOUT$)) then 
41200             let FNLOG=FNFILEIOLOG(STRING$,LOGIN_NAME$,SESSION$,DAYS(DATE$("mm/dd/ccyy"),"mm/dd/ccyy"),TIME$("hh:mm:ss"),CALLINGPROGRAM$)
41210          else 
41220             if LEN(CALLINGPROGRAM$) then let CALLINGPROGRAM$=CALLINGPROGRAM$&" - "
41230             let FNLOG=FNFILEIOLOG(CALLINGPROGRAM$&STRING$)
41240          end if 
41250       else if ~FORCETEXTFILE AND LEN(TRIM$(LOGLAYOUT$)) then 
41260          library : FNOPENFILE,FNCLOSEFILE
41270          let FILEHANDLE=FNOPEN(LOGLAYOUT$,MAT LOGDATA$,MAT LOGDATA,MAT LOGFORM$,0,0,0,"",MAT DUMMY$,MAT DUMMY,0,1)
41280          if FILEHANDLE then 
41290             let LOGDATA$(LOG_PROGRAM)=CALLINGPROGRAM$
41300             let LOGDATA$(LOG_USERNAME)=LOGIN_NAME$
41310             let LOGDATA$(LOG_SESSION)=SESSION$
41320             let LOGDATA$(LOG_TIME)=TIME$("hh:mm:ss")
41330             let LOGDATA$(LOG_MESSAGE)=STRING$(1:255)
41340             let LOGDATA(LOG_DATE)=DAYS(DATE$("mm/dd/ccyy"),"mm/dd/ccyy")
41350 ! 
41360             write #FILEHANDLE, using LOGFORM$(FILEHANDLE) : MAT LOGDATA$,MAT LOGDATA error Errorusetextfile
41370             let FNCLOSEFILE(FILEHANDLE,LOGLAYOUT$,"",1)
41380          else 
41390             goto Errorusetextfile
41400          end if 
41410       else 
41420 Usetextfile: ! Use A Text Logfile.
41430          let LOGGINGRETRYCOUNT=0
41440          library : FNGETFILENUMBER
41450          open #(FILEHANDLE:=FNGETFILENUMBER) : "Name=FileIO.log, use, recl=658",display,output locked Retrylogging
41460          if FILE(FILEHANDLE)<>-1 then 
41470             print #FILEHANDLE: "User: "&LOGIN_NAME$&" - Session ID: "&SESSION$&" - Date: "&DATE$("mm/dd/ccyy")&" - "&TIME$("hh:mm:ss")&" - Program: "&CALLINGPROGRAM$&": "&STRING$
41480             close #FILEHANDLE: 
41490          end if 
41500       end if 
41510    fnend 
41520 ! 
41530 Errorusetextfile: ! Couldn't write to log file, msg user and use text
41540    let MSGBOX("A file is locked on the server. Please restart the server if the problem continues.")
41550    goto Usetextfile
41560 ! 
41570    dim LOGGINGRETRYCOUNT
41580 ! 
41590 Retrylogging: ! 
41600    if LOGGINGRETRYCOUNT<20 then 
41610       let LOGGINGRETRYCOUNT+=1
41620       let SLEEP(.1)
41630       retry 
41640    else 
41650       let LOGGINGRETRYCOUNT=0
41660       continue 
41670    end if 
41680 ! 
41690 ! 
42000 ! #Autonumber# 42000,10
42010 Notinfile: ! ***** Search A Given Spot In A File For A Given String, Return True If Not Found
42020    def library FNNOTINFILE(STRING$*100,FILENAME$,SUB;PATH$,FILENUMBER)
42030       library : FNOPENFILE,FNREADALLKEYS
42040       dim F$(1)*255,F(1),FMMM$(1)*2000,FILELIST$(1)*255
42050       let FILENUMBER=FNOPEN(FILENAME$,MAT F$,MAT F,MAT FMMM$,1,0,0,PATH$)
42060       let FNREADALLKEYS(FILENUMBER,MAT F$,MAT F,MAT FMMM$,SUB,MAT FILELIST$)
42070       if FNSEARCHCLOSELY(MAT FILELIST$,STRING$)=0 then let FNNOTINFILE=1
42080       close #FILENUMBER: !:
         fnend 
42090 ! 
42100 Getfiledatetime: ! Performs A Directory Listing To Get The Date Of A File
42110    def library FNGETFILEDATETIME$(FILENAME$*255)=FNGETFILEDT$(FILENAME$)
42120    def FNGETFILEDT$(FILENAME$*255;___,DIRFILE,DUMMY$*255,STAR$)
42130       let STAR$=FNNEEDSTAR$
42140       library : FNGETFILENUMBER
42150       execute STAR$&"dir "&FILENAME$&" >xxx[SESSION]"
42160       open #(DIRFILE:=FNGETFILENUMBER) : "Name=xxx[SESSION]", display,input 
42170       do 
42180          linput #DIRFILE: DUMMY$ eof Ignore
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
43020    def library FNREADLAYOUTS(MAT DIRLIST$;___,DUMMY$*255,DIRFILE,LAYOUTPATH$*255,STAR$)
43030       let STAR$=FNNEEDSTAR$
43040       library : FNGETFILENUMBER
43050       let LAYOUTPATH$=FNSETTINGS$("layoutpath")
43060       mat DIRLIST$(0)
43070       execute STAR$&"dir "&LAYOUTPATH$&" >xxx"
43080       open #(DIRFILE:=FNGETFILENUMBER) : "Name=xxx", display,input 
43090 Readfilename: ! Read The Next File Name
43100       linput #DIRFILE: DUMMY$ eof Donereadingfilenames
43110       if DUMMY$(11:13)="   " AND ~POS(DUMMY$,"<DIR>") then 
43120          mat DIRLIST$(UDIM(DIRLIST$)+1) !:
               let DIRLIST$(UDIM(DIRLIST$))=TRIM$(DUMMY$(44:99))(1:30)
43130       end if 
43140       goto Readfilename
43150 Donereadingfilenames: ! Finished
43160       close #DIRFILE: 
43170       execute STAR$&"free xxx"
43180    fnend 
43190 ! 
43200 Doeslayoutexist: ! Return True If Layout Exists In The Layouts Folder
43210    def library FNDOESLAYOUTEXIST(LAYOUT$;LAYOUTPATH$*255)
43220       let LAYOUTPATH$=FNSETTINGS$("layoutpath")
43230       if TRIM$(LAYOUT$)<>"" then 
43240          let FNDOESLAYOUTEXIST = EXISTS(LAYOUTPATH$&LAYOUT$)
43250       end if 
43260    fnend 
43270 ! 
43280 Layoutpath: ! This Funtion Reads The Layout Path
43290    def library FNREADLAYOUTPATH$*255(;___,LAYOUTPATH$*255)
43300       let LAYOUTPATH$=FNSETTINGS$("layoutpath")
43310       let FNREADLAYOUTPATH$=LAYOUTPATH$
43320    fnend 
43330 ! 
43340    dim TEMPLATELIST$(1)
43350    dim TEMPLATEDESCRIPTION$(1)*255
43360 Readtemplates: ! ***** Reads Into A Given Array The List Of File Layouts
43370    def FNREADTEMPLATES(MAT DIRLIST$,MAT TEMPLATEDESC$,MAT TEMPLATENUM;___,DUMMY$*255,DIRFILE,TEMPLATEPATH$*255,INDEX,SPOT,JNDEX,STAR$)
43380       let STAR$=FNNEEDSTAR$
43390       library : FNGETFILENUMBER
43400       let TEMPLATEPATH$=FNSETTINGS$("templatepath")
43410       mat TEMPLATELIST$(0)
43420       execute STAR$&"dir "&TEMPLATEPATH$&" >xxx" error Ignore
43430       if EXISTS("xxx") then 
43440          open #(DIRFILE:=FNGETFILENUMBER) : "Name=xxx", display,input 
43450 Readtemplatename: ! Read The Next File Name
43460          linput #DIRFILE: DUMMY$ eof Donereadingtemplatenames
43470          if (TRIM$(LWRC$(DUMMY$(11:13)))="wb" OR TRIM$(LWRC$(DUMMY$(11:13)))="br") AND ~POS(DUMMY$,"<DIR>") then 
43480             mat TEMPLATELIST$(UDIM(TEMPLATELIST$)+1) !:
                  let TEMPLATELIST$(UDIM(TEMPLATELIST$))=TRIM$(DUMMY$(44:99))(1:30)
43490          end if 
43500          goto Readtemplatename
43510 Donereadingtemplatenames: ! Finished
43520          close #DIRFILE: 
43530          execute STAR$&"free xxx"
43540       end if 
43550 ! 
43560       mat DIRLIST$(0) : mat TEMPLATEDESC$(0) : mat TEMPLATENUM(0)
43570       for INDEX=1 to UDIM(MAT TEMPLATELIST$)
43580 ! .         ! attempt library linkage
43590 ! 
43600          library TEMPLATEPATH$&TEMPLATELIST$(INDEX) : FNTEMPLATELIST, FNRUNTEMPLATE error Skipthistemplate
43610          let FNTEMPLATELIST(MAT TEMPLATEDESCRIPTION$) error Skipthistemplate
43620 ! 
43630          let SPOT=UDIM(MAT DIRLIST$)
43640          mat DIRLIST$(UDIM(MAT TEMPLATEDESCRIPTION$)+SPOT)
43650          mat DIRLIST$(SPOT+1:SPOT+UDIM(MAT TEMPLATEDESCRIPTION$))=(TEMPLATEPATH$&TEMPLATELIST$(INDEX))
43660          mat TEMPLATEDESC$(UDIM(MAT TEMPLATEDESCRIPTION$)+SPOT)
43670          mat TEMPLATEDESC$(SPOT+1:SPOT+UDIM(MAT TEMPLATEDESCRIPTION$))=TEMPLATEDESCRIPTION$
43680          mat TEMPLATENUM(UDIM(MAT TEMPLATEDESCRIPTION$)+SPOT)
43690          for JNDEX=1 to UDIM(MAT TEMPLATEDESCRIPTION$)
43700             let TEMPLATENUM(SPOT+JNDEX)=JNDEX
43710          next JNDEX
43720 Skipthistemplate: ! Skip To Here If A File Isn't a template.
43730       next INDEX
43740    fnend 
43750 ! 
44000 ! #Autonumber# 44000,10
44010 Messagebox: ! ***** Displays A Message Box In New Or Old Gui
44020    def FNMESSAGEBOX(MESSAGE$*60;TITLE$*20,_WINDOW,_CHOICE,_KP$)
44030       library : FNGETFILENUMBER
44040       if TRIM$(ENV$("guimode"))="" then ! Old Gui Version
44050          open #(_WINDOW:=FNGETFILENUMBER): "SROW=10,SCOL=10,EROW=14,ECOL=69,Border=S,Caption="&TITLE$,display,outin 
44060          print #_WINDOW: NEWPAGE
44070          print #_WINDOW, fields "2,1,CC 60" : MESSAGE$
44080          print #_WINDOW, fields "4,1,CR 29" : "Answer (Y/N):"
44090          do 
44100             rinput #_WINDOW, fields "4,31,C 1" : _KP$
44110          loop UNTIL (FKEY=0 AND (UPRC$(_KP$)="Y" OR UPRC$(_KP$)="N")) OR FKEY=99
44120          if FKEY=0 AND UPRC$(_KP$)="Y" then let FNMESSAGEBOX=1 else let FNMESSAGEBOX=0
44130          close #_WINDOW: 
44140       else ! New Gui Version
44150          let _CHOICE=MSGBOX(MESSAGE$,TITLE$,"okC")
44160          if _CHOICE=1 then let FNMESSAGEBOX=1 else let FNMESSAGEBOX=0
44170       end if 
44180    fnend 
44190 ! 
44200 Key: ! ***** This Function Calculates The Key For A File
44210    def library FNKEY$*255(FILENUMBER, KEY$*255)
44220       let FNKEY$=RPAD$(KEY$,KLN(FILENUMBER))
44230    fnend 
44240 ! 
44250 Sortkeys: ! This Function Will Sort The Records Given In The Mat Keys$
44260 ! .! array into the order specified by a given key file.
44270 ! 
44280    dim SORTKEY$(1)*255
44290    dim SORTED(1)
44300 ! 
44310    def library FNSORTKEYS(MAT KEYS$,LAYOUT$,DATAFILE,MAT F$,MAT F,MAT FORM$;KEYNUM,___,INDEX)
44320       library : FNBUILDKEY$
44330       mat SORTKEY$(UDIM(MAT KEYS$))
44340       mat SORTED(UDIM(MAT KEYS$))
44350 ! 
44360       for INDEX=1 to UDIM(MAT KEYS$)
44370          read #DATAFILE, using FORM$(DATAFILE), key=KEYS$(INDEX), release: MAT F$, MAT F
44380          if FILE(DATAFILE)=0 then 
44390             let SORTKEY$(INDEX)=FNBUILDKEY$(LAYOUT$,MAT F$,MAT F,KEYNUM)
44400          end if 
44410       next INDEX
44420 ! 
44430       mat SORTED=AIDX(SORTKEY$)
44440       mat SORTKEY$=KEYS$
44450 ! 
44460       for INDEX=1 to UDIM(MAT KEYS$)
44470          let KEYS$=SORTKEY$(SORTED(INDEX))
44480       next INDEX
44490    fnend 
44500 ! 
44510 Readscreensize: ! Return The Screen Size Of Window 0 In Terms Of Rows And Columns
44520    dim SCREENSIZE(4), FONTSIZE(2)
44530    def library FNREADSCREENSIZE(&ROWS,&COLS;PARENTWINDOW)=FNREADSCREENS(ROWS,COLS,PARENTWINDOW)
44540    def FNREADSCREENS(&ROWS,&COLS;PARENTWINDOW)
44550       if ~FN42E then 
44560          let FNOLDREADSCREENSIZE(ROWS,COLS,PARENTWINDOW)
44570       else 
44580          let FILE(PARENTWINDOW,"USABLE_RECT",MAT SCREENSIZE)
44590          let FILE(PARENTWINDOW,"FONTSIZE",MAT FONTSIZE)
44600          let ROWS=(SCREENSIZE(4)/FONTSIZE(1))
44610          let COLS=(SCREENSIZE(3)/FONTSIZE(2))
44620       end if 
44630    fnend 
44640 ! 
44650    def FNOLDREADSCREENSIZE(&ROWS,&COLS;PARENTWINDOW,___,FFILE,STRING$*2000,SROW,SCOL,EROW,ECOL,POSITION,STAR$)
44660       let STAR$=FNNEEDSTAR$
44670       execute STAR$&"Status Files >[SESSION].tmp"
44680       open #(FFILE:=FNGETFILENUMBER) : "name=[SESSION].tmp",display,input 
44690 ! 
44700       do WHILE FILE(FFILE)=0
44710          linput #FFILE: STRING$ eof Ignore
44720       loop UNTIL STRING$(1:5)="-----"
44730       do WHILE FILE(FFILE)=0
44740          linput #FFILE: STRING$ eof Ignore
44750       loop UNTIL (LWRC$(STRING$)(1:4)="open") AND TRIM$(STRING$(POS(STRING$,"#")+1:POS(STRING$,"#")+5))=STR$(PARENTWINDOW)
44760       if FILE(FFILE)=0 then 
44770          linput #FFILE: STRING$ eof Ignore
44780       end if 
44790 ! 
44800       close #FFILE: 
44810       execute STAR$&"Free [SESSION].tmp"
44820 ! 
44830       if (POSITION:=POS(UPRC$(STRING$),"SROW=")) then 
44840          let SROW=VAL(STRING$(POSITION+5:POS(STRING$,",",POSITION)-1)) conv Ignore
44850       end if 
44860       if (POSITION:=POS(UPRC$(STRING$),"SCOL=")) then 
44870          let SCOL=VAL(STRING$(POSITION+5:POS(STRING$,",",POSITION)-1)) conv Ignore
44880       end if 
44890       if (POSITION:=POS(UPRC$(STRING$),"EROW=")) then 
44900          let EROW=VAL(STRING$(POSITION+5:POS(STRING$,",",POSITION)-1)) conv Ignore
44910       end if 
44920       if (POSITION:=POS(UPRC$(STRING$),"ECOL=")) then 
44930          let ECOL=VAL(STRING$(POSITION+5:POS(STRING$,",",POSITION)-1)) conv Ignore
44940       end if 
44950       if SROW AND EROW then let ROWS=EROW-SROW+1
44960       if SCOL AND ECOL then let COLS=ECOL-SCOL+1
44970    fnend 
44980 ! 
44990    def FN42E=(WBVERSION$>="4.20e")
45000    def FN42=(VAL(WBVERSION$(1:3))>=4.2)
45010    def FN418=((VAL(WBVERSION$(1:4))>=4.18) OR FN42)
45020    def FN42IA=(WBVERSION$>="4.20ia")
45030    def FN42J=(WBVERSION$>="4.20j")
45040 ! 
99000 ! #Autonumber# 99000,10
99010 Open: ! ***** Function To Call Library Openfile And Proc Subs
99020    def FNOPEN(FILENAME$*255, MAT F$, MAT F, MAT FORM$; INPUTONLY, KEYNUM, DONT_SORT_SUBS, PATH$*255, MAT DESCR$, MAT FIELD_WIDTHS,SUPRESS_PROMPT,IGNORE_ERRORS,SUPPRESS_LOG,___,INDEX)
99030       dim _FILEIOSUBS$(1)*800, _LOADEDSUBS$(1)*80
99040       let FNOPEN=FNOPENFILE(FILENAME$, MAT F$, MAT F, MAT FORM$, INPUTONLY, KEYNUM, DONT_SORT_SUBS, PATH$, MAT DESCR$, MAT FIELD_WIDTHS, MAT _FILEIOSUBS$, SUPRESS_PROMPT,IGNORE_ERRORS,PROGRAM$,SUPPRESS_LOG)
99050       if SRCH(_LOADEDSUBS$,UPRC$(FILENAME$))<=0 then : mat _LOADEDSUBS$(UDIM(_LOADEDSUBS$)+1) : let _LOADEDSUBS$(UDIM(_LOADEDSUBS$))=UPRC$(FILENAME$) : for INDEX=1 to UDIM(MAT _FILEIOSUBS$) : execute (_FILEIOSUBS$(INDEX)) : next INDEX
99060    fnend 
99070 ! 
99900 ! #Autonumber# 99900,10
99910 Ignore: continue 
99920 Retrycount: ! 
99930    if ERRORRETRYCOUNT<5 then 
99940       let ERRORRETRYCOUNT+=1
99950       retry 
99960    else 
99970       let ERRORRETRYCOUNT=0
99980       continue 
99990    end if 
