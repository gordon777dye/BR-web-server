01000 ! Execute "con opt 60 off" !:
         ! Rep Web_Server
01020    let VERSION$ = "2.06"
01040 ! Br Standard Web Server
01060 ! Control File Is: Web_Server.Ini
01080 ! Url_Base = Full Br Path To Directory Being Served
01100 ! Port = Port Number To Be Serviced  (Default Is 443)
01120 ! .    This Port is never closed.
01140 ! Logfile = Optional Br Text File For Http Engine Logging
01160 ! .    This Log File Is Never Closed.
01180 ! Debugfile = Optional Br Text File For Web Server Debug Messages
01200 ! .    This log File is replaced each run.
01210 ! Session_Digits = Low-Order Session Digits That Name Its Work File In !:
         ! .    Sessions\ (0-3, default 1).  No session is kept in memory between !:
         ! .    requests, so any number of engines can serve the same site.
01215 ! Proxy = Optional: the reverse proxy's address(es) - BR then serves plain !:
         ! .    HTTP on Bind (default 127.0.0.1), Port may be a range such as !:
         ! .    8081-8084, and Cert is not needed: the proxy serves HTTPS and files.
01220 !
01240    if WBVERSION$ < "4.32g" then !:
            print "BR Version must be 4.32g or greater." !:
            print BELL; !:
            stop 
01260    if ENV$("STATUS.STACKS.WORKSTACK.MAX") < "500000" then !:
            print "Please set the workstack to at least 500000." !:
            print BELL; !:
            stop 
01280    on fkey 93 goto Exit_Br
01300 ! 
01320    dim URL$*4096,URL_BASE$*1000,EXT$*500,FULL_URL$*5500,PAGE$*32000
01340    dim POST$*100000, CONTROL$*2000, LIBRARY$(0)*2000, FUNCT$(0)*500
01360    dim COOKIE$*5000,URL_BASE_SAVE$*1000,EXT_SAVE$*500
01380    dim RUN_DIR$(0)*200,PWD$*200,LIBRARY$*2000
01400    dim LOGFILE$*300,DEBUGFILE$*300,URLCODES$(227)*3,CHARS$(227)*1
01420    dim ALLOW$(20)*30,CERT_BASE$*60,SSL_KEY_PHRASE$*500,WORK2$*5000
01440    dim S_SESSION$*10,S_STATUS$*1,S_USER$*50,SESS_KEY$*13,SESS_GROUP_OPEN$*3
01460    dim SESS_DIR$*300,SET_COOKIE$*200,REQ_SESSION$*10,SESSION_CHARS$*62
01480    dim TEMP1$,TEMP2$*4096,URL_REDIRECT$*4096 ! Use To Redirect
01490    dim SESS_BLOB$*110000,SESS_CHUNK$*4078,SESS_FREE$(0)*10,SWEEP_GROUP$*3
01495    dim WS_TMP$*40,WS_TMP2$*40
01497    dim PROXY$*300,BIND$*60,PORT_FIRST$*20
01500 ! 
01520    let TRUE = 1 : let FALSE = 0 !:
         let CRLF$ = HEX$("0D0A") !:
         let FIFTEEN_MINUTES = 15 * .00069445 !:
         let THIRTY_MINUTES = 30 * .00069445 !:
         let ONE_HOUR = .041667 !:
         let TWO_HOURS = 2 * ONE_HOUR !:
         let AUTH_REQUIRED = TRUE ! Login Required !:
         let HTTP_VERSION$ = "1" ! Http/1.1
01530    let SESSION_DIGITS = 1 ! Session Digits Naming Its File !:
         let SESS_FILE = 990 : let SESX_FILE = 991 !:
         let ONE_MINUTE = .00069445 !:
         let FIVE_MINUTES = 5 * ONE_MINUTE !:
         let SESSION_CHARS$ = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" !:
         let WS_TMP$ = "web_server" & WSID$ & ".tmp" !:
         let WS_TMP2$ = WS_TMP$ & "2" ! Work Files: One Pair Per Engine
01540    let BACKSLASH$ = "\" !:
         if ENV$("SERVER_PLATFORM") = "LINUX" then !:
            let BACKSLASH$ = "/"
01560    let POS1 = POS(PROGRAM$,BACKSLASH$,-1) !:
         let PWD$ = PROGRAM$(1:POS1)
01580 ! 
01600    print #0: NEWPAGE
01620    print #0, fields "5,10,c": "Business Rules WebServer " & VERSION$ !:
         print "Business Rules WebServer " & VERSION$ !:
         print 
01640    let GMT_OFFSET = FNGET_GMT_OFFSET * .00069445 ! Minutes -> Hours !:
         gosub Get_Mime_Types
01660 ! 
01680    open #10: "Name= Web_Server.INI",display,input ioerr Ini_Error
01700 ! 
01720 Readini: ! ***** Read Ini Configuration File
01740    do  !:
            linput #10: CONTROL$ eof Readini_Done
01760       if UPRC$(CONTROL$(1:4))="REM " then !:
               goto Ini_Loop
01780       if POS(UPRC$(CONTROL$),"URL_BASE=") then !:
               let DUMMY = POS(CONTROL$,"=") !:
               let URL_BASE$ = TRIM$(CONTROL$(DUMMY+1:2000)) !:
               goto Ini_Loop
01800       if POS(UPRC$(CONTROL$),"HTTP_VERSION=") then !:
               let DUMMY = POS(CONTROL$,"=") !:
               let HTTP_VERSION$ = TRIM$(CONTROL$(DUMMY+1:2000)) !:
               goto Ini_Loop
01820       if (DUMMY := POS(UPRC$(CONTROL$),"PORT=")) then 
01840          let CONTROL$(DUMMY:DUMMY+4) = NULL$ ! Remiove Keyword
01860          if (DUMMY := POS(CONTROL$,"^HTTP")) > 0 then ! If Alternate Port !:
                  execute "config http " & TRIM$(CONTROL$(1:DUMMY-1)) !:
               else !:
                  let PORT$ = TRIM$(CONTROL$)
01880          goto Ini_Loop
01900       end if 
01905       if POS(UPRC$(CONTROL$),"SESSION_DIGITS=") then 
01910          let DUMMY = POS(CONTROL$,"=") !:
               let WORK$ = TRIM$(CONTROL$(DUMMY+1:2000))
01912          let SESSION_DIGITS = VAL(WORK$) conv Session_Digits_Error
01914          goto Ini_Loop
01916       end if
01917       if POS(UPRC$(CONTROL$),"PROXY=") then !:
               let DUMMY = POS(CONTROL$,"=") !:
               let PROXY$ = TRIM$(CONTROL$(DUMMY+1:2000)) !:
               goto Ini_Loop
01918       if POS(UPRC$(CONTROL$),"BIND=") then !:
               let DUMMY = POS(CONTROL$,"=") !:
               let BIND$ = TRIM$(CONTROL$(DUMMY+1:2000)) !:
               goto Ini_Loop
01920       if POS(UPRC$(CONTROL$),"CERT=") then !:
               let DUMMY = POS(CONTROL$,"=") !:
               let CERT_BASE$ = TRIM$(CONTROL$(DUMMY+1:2000)) !:
               goto Ini_Loop
01940       if POS(UPRC$(CONTROL$),"NOLOGIN") then !:
               let AUTH_REQUIRED = FALSE !:
               goto Ini_Loop
01960       if POS(UPRC$(CONTROL$),"LOGFILE=") then !:
               let DUMMY = POS(CONTROL$,"=") !:
               let LOGFILE$ = TRIM$(CONTROL$(DUMMY+1:2000)) !:
               goto Ini_Loop
01980       if POS(UPRC$(CONTROL$),"DEBUGFILE=") then 
02000          let DUMMY = POS(CONTROL$,"=") !:
               let DEBUGFILE$ = TRIM$(CONTROL$(DUMMY+1:2000))
02020          let DBG_COOKIES = POS(LWRC$(DEBUGFILE$),"cookies") !:
               let DBG_PRINT_ALL = POS(LWRC$(DEBUGFILE$),"print_all")
02040          if (DUMMY := POS(DEBUGFILE$,",")) then !:
                  let DEBUGFILE$(DUMMY:2000)=NULL$
02060          goto Ini_Loop
02080       end if 
02100       if POS1 := POS(UPRC$(CONTROL$),"LIBRARY=") then 
02120          let POS2 = POS(CONTROL$,",",POS1) !:
               mat LIBRARY$(FUNC_SUB+=1) !:
               mat FUNCT$(FUNC_SUB) !:
               mat RUN_DIR$(FUNC_SUB) !:
               let LIBRARY$(FUNC_SUB) = TRIM$(CONTROL$(POS1+8:POS2-1))
02140          if (NOT (POS1 := POS(UPRC$(CONTROL$),"FUNCTIONS=",POS2))) then !:
                  goto Function_Error
02160          if (POS2 := POS(UPRC$(CONTROL$),"RUN_DIR=")) then !:
                  let RUN_DIR$(FUNC_SUB) = CONTROL$(POS2+8:99999) !:
                  let CONTROL$(POS2:99999) = NULL$ ! Remove Run_Dir Parm !:
                  let CONTROL$ = RTRM$(CONTROL$) ! Right Trim Spaces !:
                  let CONTROL$ = RTRM$(CONTROL$,",") ! Remove Preceding Comma
02180          let FUNCT$(FUNC_SUB) = TRIM$(CONTROL$(POS1+10:99999))
02200          goto Ini_Loop
02220       end if 
02240       if POS1 := POS(UPRC$(CONTROL$),"ALLOW=") then 
02260          let POS1 += 5
02280          let POS2 = POS(CONTROL$,",",POS1+1) !:
               let POS2 += 2000 * (~POS2) ! Pos Of Comma Or 2000 !:
               let ALLOW$(ALLOW_SUB+=1) = TRIM$(CONTROL$(POS1+1:POS2-1))
02300          let POS1 = POS2 !:
               if POS2 < 2000 then !:
                  goto 2280 !:
               else !:
                  goto Ini_Loop
02320       end if 
02340       if POS(UPRC$(CONTROL$),"RELOGIN_MINUTES=") then 
02360          let DUMMY = POS(CONTROL$,"=") !:
               let WORK$ = TRIM$(CONTROL$(DUMMY+1:2000))
02380          let RELOGIN_MINUTES = VAL(WORK$) conv 2420
02400          goto Ini_Loop
02420       end if 
02440       print CONTROL$
02460 Ini_Loop: loop 
02480 ! 
02500 Readini_Done: ! ***** Report Ini Findings
02520    close #10: 
02540 ! 
02560    if URL_BASE$ > NULL$ then !:
            print "URL_BASE= ";URL_BASE$ !:
         else print "URL_BASE= Not Specified" !:
            print BELL; !:
            stop 
02580    if CERT_BASE$ > NULL$ then
02582       print "HTTPS CERT= ";CERT_BASE$
02584    else if PROXY$ > NULL$ then
02586       print "PROXY= ";PROXY$;" - the proxy serves HTTPS, no CERT= needed"
02588    else
02590       print "CERT= Not Specified"
02592       print BELL;
02594       stop
02596    end if
02600    if PORT$ = NULL$ AND ENV$("PORT") > NULL$ then !:
            let PORT$ = ENV$("PORT")
02620    if PORT$ = NULL$ AND PROXY$ > NULL$ then !:
            let PORT$ = "8081-8084"
02630    if PORT$ = NULL$ then !:
            let PORT$ = "443"
02635    let PORT_FIRST$ = PORT$ !:
         if POS(PORT$,"-") then !:
            let PORT_FIRST$ = PORT$(1:POS(PORT$,"-")-1)
02640    let PORT = VAL(PORT_FIRST$) !:
         if PORT then !:
            print "PORT= ";PORT$ !:
            print "Note- BR must be restarted to effect port or https changes." !:
         else print "Port Specified Must Be a Number" !:
            print BELL; !:
            stop 
02660    if LOGFILE$ > NULL$ then !:
            print "LOGFILE= ";LOGFILE$
02680 ! 
02700    for FUNC_SUB = 1 to UDIM(FUNCT$)
02720       if NOT EXISTS(SREP$(UPRC$(LIBRARY$(FUNC_SUB)),"RETAIN",NULL$)) then !:
               let LIBRARY$ = LIBRARY$(FUNC_SUB) !:
               goto Library_Exist_Error
02740       print "LIBRARY= ";LIBRARY$(FUNC_SUB) !:
            print "   FUNCTIONS= ";FUNCT$(FUNC_SUB) !:
            if RUN_DIR$(FUNC_SUB) > NULL$ then !:
               print "   RUN_DIR= ";RUN_DIR$(FUNC_SUB)
02760    next FUNC_SUB
02780    if RELOGIN_MINUTES then !:
            print "RELOGIN_MINUTES= ";RELOGIN_MINUTES
02790    if SESSION_DIGITS < 0 OR SESSION_DIGITS > 3 OR SESSION_DIGITS <> INT(SESSION_DIGITS) then !:
            goto Session_Digits_Error
02795    if AUTH_REQUIRED then !:
            print "SESSION_DIGITS= ";SESSION_DIGITS
02800    if NOT AUTH_REQUIRED then !:
            print "NOLOGIN"
02820    mat ALLOW$(ALLOW_SUB) !:
         if ALLOW_SUB then !:
            let MAT2STR(MAT ALLOW$,WORK$,", ") !:
            print "ALLOW= "; WORK$
02840 ! 
02860 ! ***** Establish Library Linkage
02880    library : FNPUT_OBJECT, FNGET_OBJECT, FNDELETE_OBJECT
02900    if UDIM(FUNCT$) > 0 AND NOT LIBRARY_INSTALLED then 
02920       open #30: "name= " & WS_TMP$ & ",replace,recl=3000",display,output  !:
            print #30: "load " & PROGRAM$ !:
            print #30: "10 library_installed = 1" !:
            for SUB1 = 1 to UDIM(FUNCT$) !:
               let WORK = POS(UPRC$(LIBRARY$(SUB1)),"RETAIN") !:
               let LIBRARY$(SUB1)(WORK:(WORK+5)*SGN(WORK)) = NULL$ !:
               print #30: "load ";LIBRARY$(SUB1);" resident" !:
               let WORK = ~SGN(WORK) !:
               let RELEASE$ = "release"(1:10*WORK) !:
               print #30: 3020+SUB1;" library "&RELEASE$&", '";LIBRARY$(SUB1);"': ";SREP$(UPRC$(FUNCT$(SUB1)),",AUTH","") !:
            next SUB1
02940       print #30: "run" !:
            close #30: !:
            execute "proc " & WS_TMP$
02960    end if 
02980    on error goto Library_Error
03000 ! 
03020 ! 
03040 ! 
03060 ! 
03080 ! 
03100 ! 
03120 ! 
03140 ! 
03160 ! 
03180    mat ALLOW$(ALLOW_SUB +2) !:
         read MAT ALLOW$(ALLOW_SUB +1: ALLOW_SUB +2)
03200    data index,login
03220    on error system 
03240    library : FNSEND_PAGE
03260 ! 
03280 ! ***** Open Files
03300    execute "CONFIG CONSOLE ON"
03320    dim QUERYFILE$*255
03340    let QUERYFILE$ = 'Name=query[SESSION].txt'
03360    let WORK$ = "100" !:
         open #(QUERY_FILE:=104): QUERYFILE$, display,input ioerr 3380 !:
         linput #QUERY_FILE: WORK$ ioerr 3370
03370    close #QUERY_FILE: 
03380    open #QUERY_FILE: QUERYFILE$ & ", Replace",display,output  !:
         print #QUERY_FILE: WORK$ !:
         let QUERY_NUMBER = VAL(WORK$)
03390    if AUTH_REQUIRED then !:
            gosub Sess_Setup
03400    if LOGFILE$ > NULL$ then !:
            let LOGFILE$(1:0) = " LOG= " !:
            !
03410    if PROXY$ > NULL$ then goto Config_Proxy
03420    open #(SSL_PHRASE_FILE:=106): "Name= " & CERT_BASE$ & ".phrase", internal, input ioerr 3460
03440    read #SSL_PHRASE_FILE: WORK$ !:
         let SSL_KEY_PHRASE$ = DECRYPT$(WORK$, "keY_phrase_key") !:
         close #SSL_PHRASE_FILE: !:
         goto 3520
03460    open #SSL_PHRASE_FILE: "Name= " & CERT_BASE$ & ".phrase, new, recl=3200", internal, output 
03480    print  !:
         print "Specify SSL Key File Passphrase:" !:
         linput SSL_KEY_PHRASE$ ioerr 3480
03500    let WORK$ = ENCRYPT$(SSL_KEY_PHRASE$,"keY_phrase_key") !:
         write #SSL_PHRASE_FILE: WORK$ !:
         close #SSL_PHRASE_FILE: 
03520    let SSL_KEY_PHRASE$ = '"' & SSL_KEY_PHRASE$ & '"' !:
         ! 
03540    execute "config HTTPS " & PORT$ & LOGFILE$ & " URL_BASE=" & URL_BASE$ & " CERT=" & CERT_BASE$ & " PHRASE=" & SSL_KEY_PHRASE$
03550    goto 3580
03555 Config_Proxy: ! ***** Behind A Reverse Proxy: Plain Http, Loopback Only, No Files
03557    if BIND$ = NULL$ then !:
            let BIND$ = "127.0.0.1"
03559    execute "config HTTP " & PORT$ & LOGFILE$ & " BIND=" & BIND$ & " PROXY=" & PROXY$ & " URL_BASE=NONE"
03560 !
03580    let WORK$ = NULL$ !:
         if AUTH_REQUIRED then !:
            let WORK$ = ",auth"
03600 Open_Http_File: open #(HTTP_FILE:=100): "name=HTTP_file,http=server,recl=32000,eol=none" & WORK$,display,outin ioerr Http_Open_Error !:
         ! Note- Http File Never Closes
03620    if DEBUGFILE$ > NULL$ then !:
            open #(DEBUG:=102): "name= " & DEBUGFILE$ & ", replace, recl=3200",display,output ioerr Open_Debug_Error
03640 ! 
03660 Mainloop: ! ***** Main Loop *********************
03680    if PAGEBUF$ > NULL$ then 
03700       let WORK$ = PAGEBUF$ !:
            let FLUSH = TRUE ! Set To Flush Buffer !:
            if MIME_TYPE$ = NULL$ then !:
               gosub Calc_Mime_Type
03710       if SUPPRESS_HEADER AND SET_COOKIE$ > NULL$ then !:
               gosub Cookie_Into_Pagebuf
03720       if NOT SUPPRESS_HEADER then !:
               let FNSEND_HEADER(MIME_TYPE$, LEN(PAGEBUF$))
03740       do WHILE LEN(PAGEBUF$) > 0 !:
               print #HTTP_FILE: PAGEBUF$(1:30000) !:
               let PAGEBUF$(1:30000) = NULL$ !:
            loop 
03750       if FLUSH then ! If First Pass
03760          if DEBUG then !:
                  print #DEBUG: "========= send pagebuf ==========" !:
                  print #DEBUG: FULL_URL$ !:
                  print #DEBUG: "SEND PAGE$ "; LEN(WORK$);" bytes: "
03780          if DEBUG AND MIME_TYPE$ = "text/html" then 
03785             if DBG_PRINT_ALL then !:
                     print #DEBUG: WORK$ !:
                  else !:
                     print #DEBUG: WORK$(1:300)
03790          else !:
               print #DEBUG: "Mime Type= ";MIME_TYPE$
03795       end if  ! End If Flush
03800       let PAGEBUF$ = MIME_TYPE$ = NULL$ !:
            let SUPPRESS_HEADER = 0
03810       if FLUSH then !:
               let FLUSH = FALSE !:
               goto 3720
03815       if DEBUG then !:
               print #DEBUG: "================================="
03820    end if  ! Send Pagebuf$
03840    on fkey 93 goto Exit_Br
03850    let SET_COOKIE$ = NULL$ !:
         if AUTH_REQUIRED AND FNNOW >= NEXT_SWEEP then !:
            gosub Sweep_Sessions
03860    let POST_RECEIVED = FALSE !:
         let URL$ = POST$ = NULL$ !:
         linput #HTTP_FILE,wait=60: POST$ error Printdebug !:
         let FNURLDECODE(POST$,1)
03880    let POST_RECEIVED = TRUE !:
         if DEBUG then !:
            print #DEBUG: !:
            print #DEBUG: "POST Received: ";POST$ !:
            print "POST Received: ";POST$
03900    goto Processurl
03920 ! 
03940 Printdebug: ! !:
         if ERR <> 4270 then 
03945       if DEBUG AND ERR <> 4145 then !:
               print #DEBUG: TIME$;"  ";ERR;"  ";BRERR$ !:
               print TIME$;"  ";ERR;"  ";BRERR$ !:
            else !:
               print "*";
03950    else if DEBUG then ! Err 4270 (Eof) Reading Post Data !:
            print #DEBUG: !:
            print #DEBUG: "GET received." !:
            print "GET received."
03960 ! 
03980 Processurl: ! ***** Process Url *****
04000    let URL$=FILE$(HTTP_FILE,"PAGE-URL") error Mainloop
04020    let REDIRECT = (AUTH_REQUIRED AND FILE$(HTTP_FILE,"PROTOCOL") == "http") !:
         ! Print Redirect; File$(Http_File,"PROTOCOL") !:
         if REDIRECT AND DEBUG then !:
            print #DEBUG: "Redirecting to HTTPS"
04040    if REDIRECT then !:
            goto Redirect_To_Https
04060 Get_Cookie: ! Relogin Comes Here After Authentication
04080    let COOKIE$=FILE$(HTTP_FILE,"PAGE-COOKIE") !:
         if (DBG_COOKIES) AND LEN(COOKIE$) > 0 then !:
            print #DEBUG: "COOKIE Received: ";COOKIE$
04090    if AUTH_REQUIRED then !:
            gosub Establish_Session
04100    let FNURLDECODE(URL$) !:
         let URL$=SREP$(URL$,"/",BACKSLASH$) !:
         if URL$(1:1) <> BACKSLASH$ AND URL$(1:1) <> "." then !:
            let URL$(1:0) = BACKSLASH$
04120    if DEBUG then !:
            print #DEBUG: "URL= ";URL$ !:
            print URL$
04140    if POST_RECEIVED AND POST$ == NULL$ then !:
            let POST_RECEIVED = FALSE
04160    if ( (URLQPOS := POS(URL$,"?")) AND LEN(URL$) > URLQPOS) OR POST_RECEIVED then !:
            goto Process_Parms
04180 ! 
04200 ! ***** Serve Web Page *****
04220    if URLQPOS = LEN(URL$) then !:
            let URL$(URLQPOS:URLQPOS) = NULL$
04240 Serve_Page: let URL_EXISTS = EXISTS(URL_BASE$ & EXT$ & URL$) !:
         if URL_EXISTS then ! 1=Dir,  2=File
04260 ! Extension Is Subdir Path Below Url_Base
04280       let URL$ = EXT$ & URL$ ! Use Extension
04300    else if ( URL_EXISTS := EXISTS(URL_BASE$ & URL$) ) then 
04320       let EXT$ = NULL$ ! Clear Extension
04340    else goto Not_Found ! Fatal
04360    if URL_EXISTS == 1 then ! Directory
04380       let EXT$ = URL$ ! Set Extension !:
            gosub Get_Index !:
            let URL$(2000:0) = INDEX_FILE$ ! Append Index Filename To Url !:
            if EXT$ = BACKSLASH$ then !:
               let EXT$ = NULL$
04400       if URL$ == BACKSLASH$ then !:
               let URL$(99:1) = "index.????" !:
               goto Not_Found ! Error 404 - Page Not Found
04420    else ! Must Be A File - Check For Index
04440       let POS1 = POS(URL$, BACKSLASH$, -1) ! Last Backslash !:
            if POS(LWRC$(URL$(POS1:9999)),"index") then !:
               let EXT$ = URL$(1:POS1-1)
04460    end if  ! End Of Extention Reset By Index
04480 ! 
04500    if AUTH_REQUIRED then 
04520       if SKIP_AUTH then !:
               let SKIP_AUTH = FALSE !:
               goto Page_Authorized
04540       for ALLOW_SUB = 1 to UDIM(ALLOW$)
04560          if POS(URL$,"^"&ALLOW$(ALLOW_SUB)) then !:
                  goto Page_Authorized
04580       next ALLOW_SUB
04600       let SUB1 = 1 !:
            on FNCK_AUTH goto Page_Authorized, Mainloop none Unauthorized !:
            ! If Relogin Initiated By Ck_Auth Then Await Response
04620    end if  ! Auth_Required
04640 ! 
04660 Page_Authorized: ! 
04680    let FNSEND_PAGE(URL$) !:
         goto Mainloop
04700 ! 
04720 Urldecode: ! ***** Replace All % Codes With Their Hex Equivalents
04740    def FNURLDECODE(&URL$;START)
04760       let URL$(START:LEN(URL$))=SREP$(URL$(START:LEN(URL$)),"+"," ") !:
            let START = 0 ! Now Do The Whole String
04780 ! 
04800       do WHILE (START:=POS(URL$,"%",START+1))
04820          let URL$(START:START+2) = HEX$(URL$(START+1:START+2)) error 4840
04840       loop 
04860    fnend 
04880 ! 
04900 Get_Index: ! ***** Get Index File Name
04920    let INDEX_FILE$ = NULL$ !:
         execute "dir " & URL_BASE$ & URL$ & " >" & WS_TMP2$ error Not_Found_Subr !:
         let INDEX_FILE = 300 !:
         do  !:
            open #(INDEX_FILE+=1): "Name= " & WS_TMP2$,display,input ioerr Ignore !:
         loop UNTIL FILE(INDEX_FILE) == 0
04940    do  !:
            linput #INDEX_FILE: CONTROL$ eof Eof_Index
04960       if (INDEX_POS := POS(LWRC$(CONTROL$)," index.")) then !:
               let INDEX_FILE$ = CONTROL$(INDEX_POS+1:2000) !:
               goto Eof_Index ! The Name's column differs between BR versions
04980    loop 
05000 ! 
05020 Eof_Index: close #INDEX_FILE: !:
         if URL$(LEN(URL$):LEN(URL$)) <> BACKSLASH$ then !:
            let INDEX_FILE$(1:0) = BACKSLASH$
05040    return 
05060 ! 
05080 Ck_Auth: ! ***** Check Auth - 0 Not Auth | 1 Auth | 2 Relogin Initiated
05100    def FNCK_AUTH
05120       if DEBUG then : print : print "URL$ = "; URL$
05140       let FNCK_AUTH = 0 ! Default !:
            let SESSION_$ = NULL$ !:
            if UDIM(KEYS$) < 200 then !:
               mat KEYS$(200)=(NULL$) !:
               mat VALUES$(200)=(NULL$)
05160       if POS(URL$,'^~?BR_FUNC=FNLOGIN') then 
05180          let FNCK_AUTH = 3 ! Always Allow Naviagtion To Login Page
05200       else if (POS5 := POS(COOKIE$,"Session=")) then 
05220          let POS6 = POS(COOKIE$,'"',POS5+9) ! Ending Quote !:
               let SESSION_$ = COOKIE$(POS5+9:POS6-1) ! Get Session Number
05240          let POS3 = LEN(URL$) !:
               if URL$(POS3-8:POS3) = "&RELOGIN=" then ! Relogging In
05260             if FNSESS_READ(SESSION_$) AND S_IGNORE_EXPIRE > FNNOW then !:
                     let URL$(POS3-8:INF) = NULL$
05280          end if 
05300          let VALUES$(SUB1+=1) = SESSION_$ !:
               let KEYS$(SUB1) = "Session"
05320          if FNSESS_READ(SESSION_$) AND S_STATUS$ = "A" then 
05340             let CURRENT_TIME = DAYS(DATE)+FP(DAYS(TIME$,"h:m:s")) !:
                  if CURRENT_TIME < S_EXPIRATION then 
05360                let FNCK_AUTH = 1 !:
                     let NOT_AUTH = 0 !:
                     if S_INCREMENT then 
05380                   let S_EXPIRATION = CURRENT_TIME + S_INCREMENT !:
                        let FNSESS_WRITE !:
                        if DEBUG then !:
                           print #DEBUG: !:
                           print #DEBUG: "Current Time:   ";DATE$(CURRENT_TIME,"ccyy/mm/dd hh:mm:ss") !:
                           print #DEBUG: "New Expiration: ";DATE$(S_EXPIRATION,"ccyy/mm/dd hh:mm:ss") !:
                           print #DEBUG: !:
                           print  !:
                           print "Current Time:   ";DATE$(CURRENT_TIME,"ccyy/mm/dd hh:mm:ss") !:
                           print "New Expiration: ";DATE$(S_EXPIRATION,"ccyy/mm/dd hh:mm:ss") !:
                           print 
05400                end if  ! Time Increment
05420             else ! Expired
05440                let POS3 = LEN(URL$) !:
                     if URL$(POS3-7:POS3) <> "RELOGIN=" then ! Not Relogging In
05460                   let S_STATUS$ = "X" !:
                        let FNCK_AUTH = 0 !:
                        if DEBUG then !:
                           print #DEBUG: "Current Time:  ";DATE$(CURRENT_TIME,"ccyy/mm/dd hh:mm:ss") !:
                           print #DEBUG: "Expired #####: ";DATE$(S_EXPIRATION,"ccyy/mm/dd hh:mm:ss") !:
                           print "Current Time:  ";DATE$(CURRENT_TIME,"ccyy/mm/dd hh:mm:ss") !:
                           print "Expired #####: ";DATE$(S_EXPIRATION,"ccyy/mm/dd hh:mm:ss")
05480 ! .            Auth Expired - Process Relogin (The User Name Stays In The Session)
05500                   if CURRENT_TIME < (S_EXPIRATION + RELOGIN_MINUTES * .00069445) then ! Relogin Window Open - First Compile Checkpoint
05520                      let S_RELOGIN_POST = POST_RECEIVED !:
                           let S_RELOGIN_EXPIRE = CURRENT_TIME + ONE_HOUR !:
                           let S_IGNORE_EXPIRE = 0 !:
                           let SESS_BLOB$ = LPAD$(STR$(LEN(URL$)),4,"0") & URL$
05540                      if POST_RECEIVED then !:
                              let SESS_BLOB$(INF:0) = POST$
05560                      let FNSESS_PUT_BLOB(SESSION_$) ! Url And Post, For The Resume
05820                      if DEBUG then !:
                              print "Re-Login Initiated" !:
                              print #DEBUG: "Re-Login Initiated"
05840                      let FNSEND_LOCAL_PAGE(".\relogin.html") !:
                           let FNCK_AUTH = 2 ! Relogin Initiated !:
                           ! 
05860                   end if  ! Relogin Window Open
05870                   let FNSESS_WRITE ! Authorization Ended !:
                     end if  ! Relogin Not In Progress !:
                  end if  ! Session Expired
05880          end if  ! Session Authorized !:
            end if  ! Session Found In Cookie
05900    fnend 
05920 ! 
05940 Unauthorized: ! ***** Unauthorized
05960    if DEBUG then !:
            print #DEBUG: "================ Unauthorized =============="
05980    print #HTTP_FILE: "HTTP/1." & HTTP_VERSION$ & " 401 Unauthorized" & CRLF$
05990    if SET_COOKIE$ > NULL$ then !:
            print #HTTP_FILE: SET_COOKIE$ & CRLF$
05995    print #HTTP_FILE: "Content-Type: text/html"; CRLF$ ; CRLF$
06000    if DEBUG then !:
            print #DEBUG: "HTTP/1." & HTTP_VERSION$ & " 401 Unauthorized" !:
            print #DEBUG: "Content-Type: "; "text/html"; TAB(1)
06020    dim NULL$(0)
06040    let FNSEND_LOCAL_PAGE(".\unauthorized.html",MAT NULL$,MAT NULL$,TRUE)
06060    goto Mainloop
06080 ! 
06100 Not_Found: ! ***** Report File Not Found - Application Error
06120    if DEBUG then !:
            print #DEBUG: "Application error-" !:
            print #DEBUG: "404 Not Found: ";URL_BASE$ & URL$ !:
            print "Application Error-" !:
            print "404 Not Found: ";URL_BASE$ & URL$
06140    print #HTTP_FILE: "Application error-  " !:
         print #HTTP_FILE: "404 Not Found: ";URL_BASE$ & URL$ & CRLF$ !:
         goto Mainloop !:
         ! ** If Page Doesn't exist, just notify client
06160 ! 
06180 Not_Found_Subr: ! ***** Report File Not Found - Application Error
06200    if DEBUG then !:
            print #DEBUG: "Application error-" !:
            print #DEBUG: "404 Not Found: ";URL_BASE$ & URL$ !:
            print "Application Error-" !:
            print "404 Not Found: ";URL_BASE$ & URL$
06220    print #HTTP_FILE: "Application error-" !:
         print #HTTP_FILE: "404 Not Found: ";URL_BASE$ & URL$ & CRLF$ !:
         return  !:
         ! ** If Page Doesn't exist, just notify client
06240 ! 
06260 Redirect_To_Https: ! ***** Redirect Client To Https At The Same Url
06280    let FNSEND_LOCAL_PAGE(".\br_redirect.html",TEMP1$:="^new_location",TEMP2$:="https://" & FILE$(HTTP_FILE,'HOST') & SREP$(URL$,"\","/"),TRUE) !:
         goto Mainloop
06300 ! 
06320 Ignore: continue 
06340 ! 
06360 Ini_Error: ! ***** Ini File Open Error
06380    print "Cannot Open Web_Server.INI" !:
         print "ERR = ";ERR;"  ";BRERR$(ERR) !:
         print "Required Statements:" !:
         print "  URL_BASE= site-full-BR-directory-path ( can be \. )" !:
         print "  CERT= cert-file-base-name" !:
         print "Optional Statements (each on a separate line):" !:
         print "  NOLOGIN" !:
         print "  PORT= https-port  |  PORT= http-port HTTP  (either may be a range: first-last)" !:
         print "  PROXY= proxy-address, ...  (behind a reverse proxy: plain HTTP, no CERT=)" !:
         print "  BIND= listen-address  (with PROXY=, default 127.0.0.1)" !:
         print "  LOGFILE= relative-pathname  |  DEBUGFILE= ...  [, COOKIES]" !:
         print "  LIBRARY= full-BR-pathname [RETAIN], FUNCTIONS= function1, fn2, ... [,AUTH]" !:
         print "       [,RUN_DIR= full-BR-path]" !:
         print "  RELOGIN_MINUTES= Number of minutes to allow a relogin" !:
         print "  SESSION_DIGITS= 0 to 3 low-order session digits naming its file (default 1)" !:
         print "  ALLOW= url-segment, ... (public pages - case insensitive)" !:
         print  !:
         print "In Browser Specify:" !:
         print "  URL[:port][/path-relative-to-site]?BR_FUNC=function-name" !:
         print "       [&MY_PARAM1=data1&ANY_KW=any-data& ...]" !:
         print "Paths stated in URLs are relative to the URL_BASE path." !:
         stop 
06390 Session_Digits_Error: print "SESSION_DIGITS= must be 0, 1, 2 or 3" !:
         print BELL; !:
         stop 
06400 ! 
06420 Http_Open_Error: ! 
06440    print "Cannot Open HTTP Port" !:
         print "ERR = ";ERR;"  ";BRERR$(ERR) !:
         print BELL; !:
         stop 
06460 ! 
06480 Open_Debug_Error: ! 
06500    print "Cannot Open DEBUGFILE "; DEBUGFILE$ !:
         print "ERR = ";ERR;"  ";BRERR$(ERR) !:
         print BELL; !:
         stop 
06520 ! 
06540 Library_Exist_Error: ! 
06560    print  !:
         print "Library Does Not Exist: "; LIBRARY$ !:
         print "Full name must be specified.. e.g. mylib.br" !:
         print BELL; !:
         stop 
06580 ! 
06600 Library_Error: ! 
06620    print  !:
         print "Library statement error at line ";LINE !:
         print "ERR = ";ERR;"  ";BRERR$(ERR) !:
         print BELL; !:
         stop 
06640 ! 
06660 Function_Error: ! 
06680    print "Function Not Defined: "; CONTROL$ !:
         print "          Note- FUNCTIONS=  keyword is plural." !:
         print BELL; !:
         stop 
06700 ! 
06720 Relogin_Resume: ! ***** Resume Session
06740    if (NOT FNSESS_READ(RELOGIN_SESSION$)) OR (S_RELOGIN_EXPIRE = 0) then !:
            let RELOGIN_SESSION$ = NULL$ !:
            print #HTTP_FILE: "Server Error - Re-Login data not found." !:
            let URL$ = "/" !:
            goto Get_Cookie ! Process Index.Html
06750    let FNSESS_GET_BLOB(RELOGIN_SESSION$) !:
         if LEN(SESS_BLOB$) < 4 then !:
            let SESS_BLOB$ = "0001/"
06760    let POS2 = VAL(SESS_BLOB$(1:4)) conv Relogin_Bad_Blob !:
         let URL$ = SESS_BLOB$(5:4+POS2) !:
         if S_RELOGIN_POST then !:
            let POST$ = SESS_BLOB$(5+POS2:INF) !:
            let POST_RECEIVED = TRUE !:
         else !:
            let POST$ = "" !:
            let POST_RECEIVED = FALSE
06780    let SUB3 = SRCH(KEYS$,"RELOGIN") !:
         if SUB3 > 0 then !:
            let KEYS$(SUB3) = NULL$
06800    let CURRENT_TIME = DAYS(DATE)+FP(DAYS(TIME$,"h:m:s")) !:
         let S_IGNORE_EXPIRE = CURRENT_TIME + TWO_HOURS !:
         let S_RELOGIN_EXPIRE = S_RELOGIN_POST = 0 !:
         let FNSESS_WRITE !:
         let FNSESS_DROP_BLOB(RELOGIN_SESSION$)
06920    let RELOGIN_SESSION$ = NULL$ !:
         goto Get_Cookie
06930 Relogin_Bad_Blob: let SESS_BLOB$ = "0001/" !:
         goto 6760 ! Saved Url Unreadable: Resume At The Top
06940 ! 
06960    dim PARM$*5050, VALUES$(0)*30000, KEYS$(0)*100
06980 ! 
07000 ! ######################################################
07020 Process_Parms: ! ***** Process Url Parameters *********
07040    mat KEYS$(200)=(NULL$) !:
         mat VALUES$(200)=(NULL$) !:
         let NOT_AUTH = AUTH_REQUIRED !:
         let SUB1 = 1 !:
         let SUB5 = POS5 = 0 ! Clear Active Cookie Indicators
07060    let KEYS$(SUB1) = "QueryNumber" !:
         let VALUES$(SUB1) = STR$(QUERY_NUMBER+=1) !:
         restore #QUERY_FILE: !:
         print #QUERY_FILE: QUERY_NUMBER
07080 ! ***** Process Session Permissions
07100    if AUTH_REQUIRED then 
07120       if (RET_CODE:=FNCK_AUTH) == 2 then !:
               goto Mainloop ! Relogin Initiated - Await Response
07140       if RET_CODE = 0 then ! Not Authorized
07160          if SESSION_$ > NULL$ AND FNSESS_PENDING(SESSION_$) then 
07180             let WORK2$ = FILE$(HTTP_FILE,"page-auth") !:
                  if WORK2$ > NULL$ then 
07200                let POS5 = POS(WORK2$,":") !:
                     let VALUES$(SUB1+=1) = WORK2$(1:POS5-1) !:
                     let KEYS$(SUB1) = "User_Name" !:
                     let VALUES$(SUB1+=1) = WORK2$(POS5+1:99) !:
                     let KEYS$(SUB1) = "Password"
07220             end if  ! Page-Auth !:
               end if  ! Auth_Pending
07240       else ! Authorized
07260          if (NOT POS(URL$,"^index")) AND (POS(URL$,"^FNLogin")) then !:
                  let SKIP_AUTH = TRUE !:
                  let POST_RECEIVED = FALSE !:
                  let URL$(URLQPOS:INF) = NULL$ !:
                  ! Linput Z$ !:
                  goto Serve_Page ! Ignore Redundant Login Requests
07280       end if  ! Not Auth !:
         end if  ! Auth_Required
07300 !  Let The Subsequent Code Decide Whether To Allow Access To This Fn
07320    for ALLOW_SUB = 1 to UDIM(ALLOW$)
07340       if POS(URL$,"^"&ALLOW$(ALLOW_SUB)) then !:
               let NOT_AUTH = FALSE !:
               goto Process_Url_Parms
07360    next ALLOW_SUB
07380 Process_Url_Parms: ! ***** Process Url$
07400    if URLQPOS then 
07420       let POS1 = URLQPOS+1 ! Skip "?" Char
07440       do WHILE URL$(POS1:POS1) > NULL$
07460          let POS2 = POS(URL$,"&",POS1) !:
               if POS2 < 1 then !:
                  let POS2 = LEN(URL$)+1
07480          let PARM$ = URL$(POS1:POS2-1) !:
               let POS3 = POS(PARM$,"=") !:
               if NOT POS3 then !:
                  print #HTTP_FILE: "Parameter missing '=' char ";PARM$ & CRLF$ !:
               else !:
                  let KEYS$(SUB1 +=1) = PARM$(1:POS3-1)(1:100) !:
                  let VALUES$(SUB1) = PARM$(POS3+1:99999) soflow Ignore
07500          let POS1 = POS2+1
07520       loop 
07540    end if 
07560 ! ***** Process Post$
07580    let POS1 = 1 !:
         do WHILE POST$(POS1:POS1) > NULL$
07600       let POS2 = POS(POST$,"&",POS1) !:
            if POS2 < 1 then !:
               let POS2 = LEN(POST$)+1
07620       let PARM$ = POST$(POS1:POS2-1) !:
            let POS3 = POS(PARM$,"=") !:
            if NOT POS3 then !:
               print #HTTP_FILE: "Parameter missing '=' char ";PARM$ & CRLF$ !:
            else !:
               let KEYS$(SUB1 +=1) = PARM$(1:POS3-1) !:
               let VALUES$(SUB1) = PARM$(POS3+1:99999) soflow Ignore
07640       let POS1 = POS2+1
07660    loop 
07680 ! ***** Process Arrays
07700    mat VALUES$(SUB1) !:
         mat KEYS$(SUB1)
07720    if DEBUG then !:
            print #DEBUG: "========================" !:
            print #DEBUG: MAT KEYS$ !:
            print #DEBUG: "========================" !:
            print #DEBUG: MAT VALUES$ !:
            print #DEBUG: "========================"
07740    let FUNC_KW_SUB = SRCH(MAT KEYS$,"BR_FUNC") !:
         if FUNC_KW_SUB < 1 then !:
            print #HTTP_FILE: "Keyword BR_FUNC= Not Found." & CRLF$ !:
            goto Url_Parm_Not_Found
07760    let FUNC_SUB = SRCH(MAT FUNCT$,"^"&VALUES$(FUNC_KW_SUB)) !:
         if FUNC_SUB < 1 then !:
            print #HTTP_FILE: "Function ";VALUES$(FUNC_KW_SUB);" Not Found." & CRLF$ !:
            goto Url_Parm_Not_Found
07780    let LIB_SUB = FUNC_SUB
07800    if NOT_AUTH then !:
            goto Unauthorized
07820    if RUN_DIR$(LIB_SUB) > NULL$ then !:
            execute "CD " & RUN_DIR$(LIB_SUB) & " -N"
07840    if DEBUG then !:
            print  !:
            print "let " & VALUES$(FUNC_KW_SUB)&"(mat keys$,mat values$)" !:
            print #DEBUG: "let " & VALUES$(FUNC_KW_SUB)&"(mat keys$,mat values$)" !:
            print MAT KEYS$ !:
            print  !:
            print MAT VALUES$
07860    execute "let " & VALUES$(FUNC_KW_SUB)&"(mat keys$,mat values$)" error Exec_Error ! ######## Exec ######## !:
         execute "CD " & PWD$ & " -N" !:
         if RELOGIN_SESSION$ = NULL$ then !:
            goto Mainloop !:
         else !:
            goto Relogin_Resume
07880 Url_Parm_Not_Found: ! 
07900    if (URLQPOS > 2) AND NOT POST_RECEIVED then ! If A Page Requested !:
            let URL$(URLQPOS:99999) = NULL$ ! Trim Url !:
            goto Serve_Page ! And Serve It !:
         else !:
            goto Mainloop
07920 Exec_Error: print #HTTP_FILE: "Error ";ERR;" occured attempting execution of ";VALUES$(FUNC_KW_SUB)&"(mat keys$,mat values$)" & CRLF$ !:
         execute "CD " & PWD$ & " -N" !:
         goto Mainloop
07940 ! 
07960 ! ######################################################
08000    dim AUTH_ARGS$(4)*50,AUTH_VALUES$(4)*200
08020 ! 
08040 Authenticate: ! ***** Authenticate The User Of The Current Page
08060    def library FNAUTHENTICATE(REALM$*500;FILENAME$*200,WORK1$)
08080 ! 
08100       if NOT AUTH_REQUIRED then !:
               print "Authentication attempted with NOLOGIN specified." !:
               print BELL; !:
               stop 
08120       if DEBUG then !:
               print #DEBUG: "FNAuthenticate called" !:
               print "FNAuthenticate called"
08140       if FILENAME$ = NULL$ then !:
               let FILENAME$ = ".\challenge.html"
08160       if FILENAME$(1:2) <> ".\" then !:
               let FILENAME$(1:0) = ".\" ! Needed For Local Pages
08180       let AUTH_ARGS$(1) = "^realm" !:
            let AUTH_VALUES$(1) = REALM$ !:
            let AUTH_ARGS$(2) = "^date" !:
            let CURRENT_TIME = DAYS(DATE)+FP(DAYS(TIME$,"h:m:s")) !:
            let AUTH_VALUES$(2) = DATE$(CURRENT_TIME+GMT_OFFSET,"D3, DD M3 CCYY HH:MM:SS") & " GMT;" !:
            let AUTH_ARGS$(3) = "^session"
08200       rem if (NOT POS(FULL_URL$,"^index")) AND ((SUB5 := SRCH(AUTHORIZED$,SESSION_$)) > 0) AND CURRENT_TIME < EXPIRATION(SUB5) then !:                                       goto End_Authenticate ! Ignore Redundant Login Requests
08220 ! If Relogging In - Keep Old Session Number
08240       if SRCH(KEYS$,"RELOGIN") > 0 then 
08260          let AUTH_VALUES$(3) = VALUES$(2) ! Current Session !:
               if FNSESS_READ(VALUES$(2)) AND S_RELOGIN_EXPIRE > 0 then !:
                  let AUTH_ARGS$(4) = "^user_name" !:
                  let AUTH_VALUES$(4) = S_USER$
08280       else ! Normal Path - The Session This Browser Already Has !:
            let AUTH_VALUES$(3) = REQ_SESSION$ !:
            let AUTH_ARGS$(4) = AUTH_VALUES$(4) = ""
08290       if AUTH_VALUES$(3) = NULL$ then !:
               let AUTH_VALUES$(3) = FNSESS_CREATE$
08300       let FNSEND_LOCAL_PAGE(FILENAME$,MAT AUTH_ARGS$,MAT AUTH_VALUES$,TRUE) ! Issue Challenge
08320 ! The Session Now Awaits The Browser's Credentials
08340       let SESSION_$ = AUTH_VALUES$(3)
08360       if FNSESS_READ(SESSION_$) then !:
               let S_PENDING = CURRENT_TIME !:
               let FNSESS_WRITE
08400 End_Authenticate: fnend 
08420 ! 
08480 ! 
08500 Authorize: ! ***** Mark This Session Authorized
08520    def library FNAUTHORIZE(INCREMENT;EXPIRATION_WORK,WORK1$,POS5,POS6,SESSION_$)
08540       let POST$ = NULL$ ! All Done With This Data !:
            let CURRENT_TIME = DAYS(TIME$,"h:m:s") !:
            if INCREMENT < 0 then ! If Time Increment !:
               let EXPIRATION_WORK = CURRENT_TIME - INCREMENT !:
            else if DATE(INCREMENT) then !:
               let EXPIRATION_WORK = INCREMENT ! Local Expiration Time !:
            else !:
               let MSGBOX("ERROR- Expiration date & time not specified","Application Error","OK","ERR") !:
               goto End_Authorize
08560    let POS5 := POS(COOKIE$,"Session=") !:
         let POS6 = POS(COOKIE$,'"',POS5+9) ! Ending Quote !:
         let SESSION_$ = COOKIE$(POS5+9:POS6-1) ! Get Session Number !:
         if POS5 = 0 then !:
            print #HTTP_FILE: "ERROR- Session not found in Cookie" !:
            goto End_Authorize
08580    if SESSION_$ <> VALUES$(2) then pause  ! ######################
08600    if INCREMENT < 0 then !:
            let INCREMENT = -INCREMENT !:
         else !:
            let INCREMENT = 0
08620    if DEBUG then !:
            print #DEBUG: "  ";TAB(1);"Session ";SESSION_$;" now Authorized and Active" !:
            print #DEBUG: "Expiration time is ";DATE$(EXPIRATION_WORK,"ccyy/mm/dd hh:mm:ss") !:
            print #DEBUG: " "
08640    if DEBUG then !:
            print "  ";TAB(1);"Session ";SESSION_$;" now Authorized and Active" !:
            print "Expiration time is ";DATE$(EXPIRATION_WORK,"ccyy/mm/dd hh:mm:ss") !:
            print " "
08660    let SUB1 = SRCH(KEYS$,"^User_Name") !:
         ! Now Trigger Resumption !:
         if SRCH(KEYS$,"RELOGIN") > 0 then !:
            let RELOGIN_SESSION$ = SESSION_$ ! Flag Checkpoint Restart
08680    if NOT FNSESS_READ(SESSION_$) then !:
            let FNSESS_ADD(SESSION_$)
08700    let S_STATUS$ = "A" !:
         let S_EXPIRATION = EXPIRATION_WORK !:
         let S_INCREMENT = INCREMENT !:
         let S_PENDING = 0
08710    if SUB1 > 0 then !:
            let S_USER$ = VALUES$(SUB1)(1:50) ! User Name
08720    let FNSESS_WRITE
08740 End_Authorize: ! 
08760 fnend 
08780 ! 
08800 ! ######################################################
08820 ! . ***** ####### JSON Service Routines ########
08840 ! 
08860 dim STORAGE$(0)*10000, START(0),END(0),OBJECTS$(0)*200
08880 dim NAMES$(0)*200
08900 dim WORK$*4194304,PAGEBUF$*4194304
08920 ! 
08940 ! ######################################################
08960 Append: ! ***** Append - Wrap Around Insert Function With Append_Flag
08980 Append_Json: ! ***** Append Json
09000 def library FNAPPEND_JSON(NAME$*2000, &VALUE$; AS_IS_FLAG)
09020    library : FNINSERT_JSON
09040    let FNAPPEND_JSON = FNINSERT_JSON(NAME$, VALUE$, AS_IS_FLAG, 1)
09060 fnend 
09080 ! 
09100 Insert: ! ***** Top Level Insert Function
09120 Insert_Object: ! ***** Insert Object
09140 def library FNINSERT_OBJECT(NAME$*200, &VALUE$; MUST_EXIST_FLAG, AS_IS_FLAG)
09160    let MUST_EXIST_FLAG = AS_IS_FLAG = 0
09180    if POS(NAME$,".") then !:
            let FNINSERT_OBJECT = -60 ! Object Name Contins Period !:
            goto End_Insert_Object
09200    if (SUCCESS := FNINIT(NAME$, MAT NAMES$)) < 0 then !:
            let FNINSERT_OBJECT = SUCCESS !:
            goto End_Insert_Object
09220    let FNINSERT_OBJECT = FNINS_OBJECT
09240 End_Insert_Object: fnend 
09260 ! 
09280 Insert_Json: ! ***** Insert Json
09300 def library FNINSERT_JSON(NAME$*2000, &VALUE$; AS_IS_FLAG,APPEND_FLAG,DONT_SAVE_WORK)
09320 !     Parse Names And Get Object Subscript -> Obj_Ref
09340    if NOT DONT_SAVE_WORK then ! If Not Working Locally
09360       if (SUCCESS := FNINIT(NAME$, MAT NAMES$)) < 0 then !:
               let FNINSERT_JSON = SUCCESS !:
               goto End_Insert_Json
09380    end if 
09400    if UDIM(NAMES$) == 1 then let SUCESS = FNINS_OBJECT !:
         else let SUCCESS = FNINSERT_MEMBER
09420    let FNINSERT_JSON = SUCCESS !:
         if SUCCESS >= 0 AND CHANGED AND NOT DONT_SAVE_WORK then !:
            let FNSTORE_OBJECT
09440 End_Insert_Json: fnend 
09460 ! 
09480 Ins_Object: ! ***** Insert Object - Find Insertion Point
09500 def FNINS_OBJECT
09520    if ( OBJ_SUB := SRCH(MAT OBJECTS$,NAMES$(1)) ) > 0 then !:
            goto Existing_Object_Name
09540 ! 
09560 ! ***** New Object Name -  Append To Storage
09580    if OBJ_REF > 1 then !:
            let FNINS_OBJECT = -80 ! Invalid Subscript !:
            goto End_Ins_Object
09600    let CUR_START = UDIM(STORAGE$)+1 ! Next Storage Array Entry !:
         let OBJ_SUB = UDIM(OBJECTS$)+1 ! Next Object Name Entry !:
         goto Actually_Ins_Object
09620 ! 
09640 Existing_Object_Name: ! 
09660    if OBJ_REF then ! If Object Name Is Subscripted
09680       if OBJ_REF == 1 then !:
               let OBJ_SUB += APPEND_FLAG !:
               let CUR_START = START(OBJ_SUB) !:
               goto Actually_Ins_Object
09700       let SUB1 = OBJ_SUB + OBJ_REF -2 ! Prior To Target Slot !:
            if (UDIM(OBJECTS$) => SUB1) AND (NAMES$(1) == OBJECTS$(SUB1)) then ! Found
09720          if APPEND_FLAG AND (UDIM(OBJECTS$) => (SUB1+1)) AND (NAMES$(1) == OBJECTS$(SUB1+1)) then !:
                  let SUB1 +=1 ! Insert After
09740          let OBJ_SUB = SUB1 +1 ! Insert Here !:
               let CUR_START = END(SUB1)+1
09760       else !:
            let FNINS_OBJECT = -80 ! Invalid Subscript!:
            goto End_Ins_Object
09780    else ! Append To List Of Objects With This Name
09800       rem ######## fails ######### do WHILE (UDIM(OBJECTS$) > OBJ_SUB) AND ((OBJECTS$(OBJ_SUB+1)) == NAMES$(1)) !:                                                                                      let OBJ_SUB+=1                  !Find last instance of name !:               loop
09820       do WHILE (UDIM(OBJECTS$) > OBJ_SUB) AND ((OBJECTS$(OBJ_SUB+1))==NAMES$(1)) !:
               let OBJ_SUB+=1 ! Find Last Instance Of Name !:
            loop 
09840       let CUR_START = END(OBJ_SUB)+1 ! Next Storage Array Entry !:
            let OBJ_SUB += 1 ! Next Object Name Entry
09860    end if 
09880 ! 
09900 Actually_Ins_Object: ! ***** At Long Last
09920    mat OBJECTS$(UDIM(OBJECTS$)+1) ! Expand Object Names List !:
         mat START(UDIM(OBJECTS$)) ! Expand Storage Pointer Arrays !:
         mat END(UDIM(OBJECTS$))
09940    for SUB1 = UDIM(OBJECTS$) to OBJ_SUB+1 step -1 ! Shift Names Up !:
            let OBJECTS$(SUB1) = OBJECTS$(SUB1-1) !:
            let START(SUB1) = START(SUB1-1) !:
            let END(SUB1) = END(SUB1-1) !:
         next SUB1
09960    let WORK$ = VALUE$ !:
         let OBJ_SIZE = CEIL(LEN(WORK$)/10000) ! Size Of Object !:
         let START(OBJ_SUB) = CUR_START ! Target Area Start & End !:
         let END(OBJ_SUB) = CUR_START + OBJ_SIZE -1 !:
         let OBJECTS$(OBJ_SUB) = NAMES$(1) ! Store Object Name #####
09980    mat STORAGE$(UDIM(STORAGE$) + OBJ_SIZE) ! Expand Storage!:
         for SUB1 = (UDIM(STORAGE$)-OBJ_SIZE) to START(OBJ_SUB) step -1 !:
            let STORAGE$(SUB1+OBJ_SIZE) = STORAGE$(SUB1) ! Shift Storage Up!:
         next SUB1 !:
         for SUB1 = OBJ_SUB+1 to UDIM(OBJECTS$) !:
            let START(SUB1) += OBJ_SIZE !:
            let END(SUB1) += OBJ_SIZE !:
         next SUB1
10000    let POS1 = 1 !:
         let POS2 = 10000 !:
         for STOR_SUB = CUR_START to END(OBJ_SUB) ! Store Object ##### !:
            let STORAGE$(STOR_SUB) = WORK$(POS1:POS2) !:
            let POS1 += 10000 !:
            let POS2 += 10000 !:
         next STOR_SUB
10020    if WORK$(POS1:POS1) <> NULL$ then !:
            print "assertion failure - left over work$ is ";LEN(WORK$(POS1:INF));" bytes" !:
            pause 
10040    let WORK_CONTENT = OBJ_SUB ! Current Work$ Object Pointer !:
         let FNINS_OBJECT = TRUE
10060 End_Ins_Object: fnend 
10080 ! 
10100 Insert_Member: ! ***** Insert Member
10120 def FNINSERT_MEMBER
10140    if NOT DONT_SAVE_WORK then ! If We're not working locally
10160       let RETURN_CODE = FNGET_CURRENT_OBJECT ! Load Work$ !:
            if RETURN_CODE < 0 then !:
               let FNINSERT_MEMBER = RETURN_CODE !:
               goto End_Insert_Member
10180    end if 
10200    let LAST_COLON = 0 ! Start Here !:
         for NAME_SUB = 2 to UDIM(NAMES$)
10220       let ADD_MEMBER = NEGATIVE_FIND = FALSE !:
            let RETURN_CODE = FNFIND_MEMBER ! Find Member ####### !:
            ! Print Name$;" ## ";Work$(Last_Colon:Punct) !:
            ! Print Found;Return_Code;Element;Last_Colon;Punct;Append_Flag !:
            if RETURN_CODE < 0 then 
10240          let NEGATIVE_FIND = TRUE !:
               if ARRAY_REF OR (RETURN_CODE < -30) OR (ELEMENT AND NOT FOUND) OR (NAME_SUB < UDIM(NAMES$)) then !:
                  let FNINSERT_MEMBER = RETURN_CODE !:
                  goto End_Insert_Member
10260 ! .   If Low Level Not Found And name Not Subscripted - Insert Member
10280          let RETURN_CODE = FNADVANCE_TO_COMMA(WORK$,LAST_COLON,PUNCT) ! Find Outer Area !:
               if RETURN_CODE < 0 then !:
                  let FNINSERT_MEMBER = -(40+NAME_SUB-1) ! Unbalanced Punctuation!:
                  goto End_Insert_Member !:
               else let ADD_MEMBER = TRUE
10300       end if 
10310       rem if NAME_SUB = 3 AND POS(NAMES$(3),"^notes") then print "found=";FOUND;'   ';NAMES$(3) : execute 'go step'
10320       if APPEND_FLAG AND ELEMENT AND NOT FOUND then ! Append Pair
10340          let POS1 = ELEMENT !:
               do WHILE WORK$(POS1 +=1: POS1) == " " !:
               loop  ! Skip White Space
10360          if WORK$(POS1:POS1) == "{" then !:
                  let LAST_COLON = ELEMENT !:
                  let ELEMENT = 0
10380       end if 
10400 Insert_Loop: ! ***** Insert Member Or Add Value
10420       if (LOW_LEVEL := (NAME_SUB == UDIM(NAMES$))) OR NOT FOUND then 
10440          if FOUND OR ELEMENT then ! Add Value #########
10460             let POS1 = PUNCT !:
                  if ELEMENT then 
10480                let RETURN_CODE = FNADVANCE_TO_COMMA(WORK$,LAST_COLON,POS1) ! Find Outer Area !:
                     if RETURN_CODE < 0 then !:
                        let FNINSERT_MEMBER = -(40+NAME_SUB-1) ! Unbalanced Punctuation!:
                        goto End_Insert_Member
10500             end if 
10520             let POS2 = POS1 !:
                  do WHILE WORK$((POS1-=1):POS1) == " " !:
                  loop  ! Skip White Space
10540             if WORK$(POS1:POS1) <> "]" then ! If No Brackets !:
                     let WORK$(POS2:0) = "]" ! Insert Them !:
                     let WORK$(LAST_COLON+1:0) = "[" !:
                     let PUNCT += 2 !:
                     let ELEMENT += SGN(ELEMENT) ! Accomodate Bracket!:
                     goto 10460 ! And Loop
10560 ! 
10580             if LOW_LEVEL AND ((NOT FOUND) OR (ELEMENT AND NEGATIVE_FIND)) AND WORK$(ELEMENT:ELEMENT) <> "]" then 
10600 ! .               If we are inserting a member at a specific point
10620                if ELEMENT then !:
                        let LAST_COLON = ELEMENT !:
                        let ELEMENT = 0
10640                let WORK$(LAST_COLON+1:LAST_COLON) = "{}," !:
                     let PUNCT = LAST_COLON+3 !:
                     let FOUND = FALSE !:
                     goto Insert_Loop
10660             end if 
10680             if ADD_MEMBER then !:
                     let WORK$(POS1:0) = ",{}" !:
                     let PUNCT = POS1 +4 !:
                     let ELEMENT = FOUND = 0 !:
                     goto Insert_Loop
10700             if ELEMENT then !:
                     let POS1 = ELEMENT ! Subscripted Value #######
10720 ! 
10740             let FIRST_ELEMENT = FALSE !:
                  if WORK$(POS1:POS1) == "[" then ! If New First Element !:
                     let POS1 += 1 ! Insert After Bracket !:
                     let WORK$(POS1:0) = "," ! Insert Trailing Comma !:
                     let FIRST_ELEMENT = TRUE
10760             if WORK$(POS1-1:POS1) = "[]" then ! Empty List !:
                     let WORK$(POS1-1:POS1) = NULL$ ! Remove Brackets !:
                     let POS1 -= 1 ! Character Following ] !:
                     let FIRST_ELEMENT = TRUE
10780             let WORK4$ = VALUE$(1:1) !:
                  let ADD_QUOTES = FALSE !:
                  if (NOT POS('"{[',WORK4$)) AND NOT AS_IS_FLAG then ! Value Not Quoted !:
                     let ADD_QUOTES = ( ( (WORK4$ == NULL$) OR POS(VALUE$,",")) ) !:
                     let DUMMY = VAL(VALUE$) conv Add_Quotes !:
                     let DUMMY = ((WORK4$ == "0" AND VALUE$(2:2) <> ".") OR (NOT POS("123456789",WORK4$))) !:
                     let ADD_QUOTES = MAX(ADD_QUOTES, QUOTE_NUMERICS,DUMMY)
10800             if ADD_QUOTES then !:
                     let WORK$(POS1:0) = '"'
10820             let WORK$(POS1:0) = VALUE$ !:
                  if ADD_QUOTES then !:
                     let WORK$(POS1:0) = '"'
10840             if NOT FIRST_ELEMENT then !:
                     let WORK$(POS1:0) = ","
10860          else ! Insert New Member #######
10880             let POS1 = POS(WORK$(LAST_COLON:PUNCT-1),"}",-1) !:
                  ! Ending Brace In Parent Value Area
10900             if NOT POS1 then ! Single Value Exists !:
                     let FNINSERT_MEMBER = -(50+NAME_SUB-1) !:
                     ! Cannot Add Member To Value List !:
                     goto End_Insert_Member
10920             let POS1 = (POS1+LAST_COLON-1) ! Relative To Work$
10940             if LOW_LEVEL then 
10960                let WORK4$ = VALUE$(1:1) !:
                     let ADD_QUOTES = FALSE !:
                     if (NOT POS('"{[',WORK4$)) AND NOT AS_IS_FLAG then ! Value Not Quoted !:
                        let ADD_QUOTES = ( ( (WORK4$ == NULL$) OR POS(VALUE$,",")) ) !:
                        let DUMMY = VAL(VALUE$) conv Add_Quotes !:
                        let DUMMY = ((WORK4$ == "0" AND VALUE$(2:2) <> ".") OR (NOT POS("123456789",WORK4$))) !:
                        let ADD_QUOTES = MAX(ADD_QUOTES, QUOTE_NUMERICS,DUMMY)
10980                if ADD_QUOTES then !:
                        let WORK$(POS1:0) = '"'
11000                let WORK$(POS1:0) = VALUE$ !:
                     if ADD_QUOTES then !:
                        let WORK$(POS1:0) = '"'
11020             else ! Insert Middle Level Member!:
                  let WORK$(POS1:0) = "{}"
11040             let COMMA$ = "," !:
                  if WORK$(POS1-1:POS1-1) == "{" then !:
                     let COMMA$ = NULL$
11060             let WORK$(POS1:0) = COMMA$&FNQUOTE$(NAMES$(NAME_SUB))&":" !:
                  let LAST_COLON = POS(WORK$,":",POS1)
11080          end if 
11100          let CHANGED = TRUE ! Flag Work$ Changed
11120 ! 
11140       end if  ! End If Insert Member Or Add Value
11160    next NAME_SUB
11180    let FNINSERT_MEMBER = TRUE
11200 End_Insert_Member: fnend 
11220 ! 
11240 Quote: ! ***** Enclose String In Quotes
11260 def FNQUOTE$*10000(&STRING$) = '"'&STRING$&'"'
11280 Add_Quotes: if NOT AS_IS_FLAG then !:
         let ADD_QUOTES = TRUE
11300 continue 
11320 ! 
11340 Init: ! ***** Initialization
11360 def FNINIT(NAME$*2000,MAT NAMES$)
11380    if WBVERSION$ < "4.3" then !:
            print "BR Version must be 4.3 or greater." !:
            print BELL; !:
            stop 
11400    let TRUE = 1 !:
         let FNINIT = TRUE
11420    let STR2MAT(NAME$,MAT NAMES$,".","Q") ! Parse Names !:
         let NAMES$(1)=UPRC$(NAMES$(1)) ! Uppercase Object Name !:
         let OBJ_REF = 0 ! Array Ref Value !:
         if (POS1 := POS(NAMES$(1),"[")) AND (POS2 := POS(NAMES$(1),"]",POS1)) then 
11440       let OBJ_REF = VAL(NAMES$(1)(POS1+1:POS2-1)) conv Ignore !:
            let NAMES$(1)(POS1:200) = NULL$ !:
            if OBJ_REF < 1 then !:
               let FNINIT = -80 ! Invalid Object Subscript !:
               goto End_Init
11460    end if 
11480 End_Init: fnend 
11500 ! 
11520 ! 
11540 ! . ##################  GET  ########################
11560 Get: ! ***** Top Level Get Function
11580 Get_Object: ! ***** Get Object Into Work$ And Container$
11600 def library FNGET_OBJECT(NAME$*200, &CONTAINER$)
11620    if (SUCCESS := FNINIT(NAME$, MAT NAMES$)) < 0 then !:
            let FNGET_OBJECT = SUCCESS !:
            goto End_Get
11640    if UDIM(NAMES$) == 1 then let FNGET_OBJECT = FNGET_CURRENT_OBJECT(COPY:=TRUE) !:
         else let FNGET_OBJECT = -60 ! Object Name Contains A Period
11660 End_Get_Object: fnend 
11680 ! 
11700 Get_Json: ! ***** Get Json Into Work$ And Container$
11720 def library FNGET_JSON(NAME$*2000, &CONTAINER$; AS_IS_FLAG)
11740    if (SUCCESS := FNINIT(NAME$, MAT NAMES$)) < 0 then !:
            let FNGET_JSON = SUCCESS !:
            goto End_Get
11760    if UDIM(NAMES$) == 1 then let FNGET_JSON = FNGET_CURRENT_OBJECT(COPY:=TRUE) !:
         else let FNGET_JSON = FNGET_MEMBER
11780 End_Get: fnend 
11800 ! 
11820 Get_Current_Object: ! ***** Get Object Into Work$ [ And Container$ ]
11840 def FNGET_CURRENT_OBJECT(;COPY_FLAG)
11860    if ( OBJ_SUB := SRCH(MAT OBJECTS$,NAMES$(1)) ) < 1 then !:
            let FNGET_CURRENT_OBJECT = -10 ! Object Not Found !:
            goto End_Get_Object
11880    let SUB1 = OBJ_SUB + MAX(1,OBJ_REF) -1 ! Target Object !:
         if (UDIM(OBJECTS$) => SUB1) AND (NAMES$(1) == OBJECTS$(SUB1)) then !:
            let OBJ_SUB = SUB1 ! Object Exists !:
            let CUR_START = START(SUB1) !:
         else !:
            let FNGET_CURRENT_OBJECT = -80 ! Invalid Subscript!:
            goto End_Get_Object
11900    if WORK_CONTENT <> OBJ_SUB then !:
            let POS1 = 1 !:
            for STOR_SUB = START(OBJ_SUB) to END(OBJ_SUB) ! Get Object ##### !:
               let WORK$(POS1:INF) = STORAGE$(STOR_SUB) !:
               let POS1 += 10000 !:
            next STOR_SUB !:
            let WORK_CONTENT = OBJ_SUB !:
            let CHANGED = FALSE
11920    let FNGET_CURRENT_OBJECT = TRUE !:
         if COPY_FLAG then !:
            let CONTAINER$ = WORK$
11940 End_Get_Current_Object: fnend 
11960 ! 
11980 Get_Member: ! ***** Get Json Member Value
12000 def FNGET_MEMBER
12020    let SUCCESS = FNGET_CURRENT_OBJECT ! Load Work$ !:
         if SUCCESS < 1 then !:
            let FNGET_MEMBER = SUCCESS !:
            goto End_Get_Member
12040    let SUCCESS = FNFIND_MEMBER ! Find Member ####### !:
         if SUCCESS < 0 then !:
            let FNGET_MEMBER = SUCCESS !:
            goto End_Get_Member
12060    let LAST_COLON = MAX(LAST_COLON,ELEMENT) !:
         if SUCCESS == 0 OR LAST_COLON == PUNCT then !:
            let FNGET_MEMBER = -(20+NAME_SUB-1) ! Member Not Found !:
            goto End_Get_Member
12080    if AS_IS_FLAG then ! Trim Spaces Only!:
            let CONTAINER$ = TRIM$(WORK$(LAST_COLON+1:PUNCT-1)) !:
         else ! Also Trim Quotes !:
            let CONTAINER$ = TRIM$(TRIM$(WORK$(LAST_COLON+1:PUNCT-1)),'"')
12100    let FNGET_MEMBER = TRUE
12120 End_Get_Member: fnend 
12140 ! 
12160 ! 
12180 ! . ##################  PUT  ########################
12200 Put_Object: ! ***** Put Object
12220 def library FNPUT_OBJECT(NAME$*200, &VALUE$; MUST_EXIST_FLAG, AS_IS_FLAG)
12240    let MUST_EXIST_FLAG = AS_IS_FLAG = 0
12260    if POS(NAME$,".") then !:
            let FNPUT_OBJECT = -60 ! Object Name Contins Period !:
            goto End_Put_Object
12280    if (SUCCESS := FNINIT(NAME$, MAT NAMES$)) < 0 then !:
            let FNPUT_OBJECT = SUCCESS !:
            goto End_Put_Object
12300    let FNPUT_OBJECT = FNSET_OBJECT
12320 End_Put_Object: fnend 
12340 ! 
12360 Put_Json: ! ***** Put Json
12380 def library FNPUT_JSON(NAME$*2000, &VALUE$; MUST_EXIST_FLAG, AS_IS_FLAG)
12400    if (SUCCESS := FNINIT(NAME$, MAT NAMES$)) < 0 then !:
            let FNPUT_JSON = SUCCESS !:
            goto End_Put_Json
12420    if UDIM(NAMES$) == 1 then let FNPUT_JSON = FNSET_OBJECT !:
         else let FNPUT_JSON = FNSET_MEMBER
12440    if CHANGED then !:
            let FNSTORE_OBJECT
12460 End_Put_Json: fnend 
12480 ! 
12500 Set_Object: ! ***** Replace Or Store An Object
12520 def FNSET_OBJECT
12540    let SUCCESS = FNDEL_OBJECT !:
         if MUST_EXIST_FLAG AND (SUCCESS < 0) then !:
            let FNSET_OBJECT = SUCCESS !:
            goto End_Set_Object
12560    let FNSET_OBJECT = FNINS_OBJECT
12580 End_Set_Object: fnend 
12600 ! 
12620 Set_Member: ! ***** Replace Or Store A Json Value
12640 def FNSET_MEMBER
12660    let FNSET_MEMBER = SUCCESS=FNDELETE_MEMBER(REPLACE_FLAG := TRUE) !:
         if MUST_EXIST_FLAG AND (SUCCESS < 0) then !:
            goto End_Set_Member
12680    if SUCCESS < 1 then !:
            let FNINIT(NAME$, MAT NAMES$) ! Recover Subscripts !:
            let FNSET_MEMBER = FNINSERT_MEMBER
12700 End_Set_Member: fnend 
12720 ! 
12740 ! . ##################  DELETE  ########################
12760 Delete: ! ***** Top Level Delete Function
12780 Delete_Object: ! ***** Delete Object
12800 def library FNDELETE_OBJECT(NAME$*200)
12820    if (SUCCESS := FNINIT(NAME$, MAT NAMES$)) < 0 then !:
            let FNDELETE_OBJECT = SUCCESS !:
            goto End_Delete_Object
12840    if UDIM(NAMES$) > 1 then !:
            let FNDELETE_OBJECT = -60 ! Not An Object !:
            goto End_Delete_Object
12860    library : FNDELETE_JSON
12880    let FNDELETE_OBJECT = FNDELETE_JSON(NAME$)
12900 End_Delete_Object: fnend 
12920 ! 
12940 Delete_Json: ! ***** Delete Json
12960 def library FNDELETE_JSON(NAME$*2000; NULL_VALUE_FLAG)
12980    if (SUCCESS := FNINIT(NAME$, MAT NAMES$)) < 0 then !:
            let FNDELETE_JSON = SUCCESS !:
            goto End_Delete_Json
13000    if UDIM(NAMES$) == 1 then let FNDELETE_JSON = FNDEL_OBJECT !:
         else let FNDELETE_JSON = FNDELETE_MEMBER
13020    if CHANGED then !:
            let FNSTORE_OBJECT
13040 End_Delete_Json: fnend 
13060 ! 
13080 Del_Object: ! ***** Delete Object
13100 def FNDEL_OBJECT
13120    if ( OBJ_SUB := SRCH(MAT OBJECTS$,NAMES$(1)) ) < 1 then !:
            let FNDEL_OBJECT = -10 ! Object Not Found !:
            goto End_Del_Object
13140    let SUB1 = OBJ_SUB + MAX(1,OBJ_REF) -1 ! Target Object !:
         if (UDIM(OBJECTS$) => SUB1) AND (NAMES$(1) == OBJECTS$(SUB1)) then !:
            let OBJ_SUB = SUB1 ! Object Exists !:
         else !:
            let FNDEL_OBJECT = -80 ! Invalid Subscript!:
            goto End_Del_Object
13160    let OBJ_SIZE = (END(OBJ_SUB) - START(OBJ_SUB) +1) !:
         for SUB1 = START(OBJ_SUB) to UDIM(STORAGE$)-OBJ_SIZE !:
            let STORAGE$(SUB1) = STORAGE$(SUB1+OBJ_SIZE) ! Shift Down!:
         next SUB1 !:
         mat STORAGE$(UDIM(STORAGE$) - OBJ_SIZE) ! Reduce Storage
13180    for SUB1 = OBJ_SUB to UDIM(OBJECTS$)-1 !:
            let OBJECTS$(SUB1) = OBJECTS$(SUB1+1) !:
            let START(SUB1) = START(SUB1+1) -OBJ_SIZE !:
            let END(SUB1) = END(SUB1+1) -OBJ_SIZE !:
         next SUB1 !:
         mat OBJECTS$(UDIM(OBJECTS$)-1) !:
         mat START(UDIM(OBJECTS$)) !:
         mat END(UDIM(OBJECTS$))
13200    let FNDEL_OBJECT = TRUE
13220 End_Del_Object: fnend 
13240 ! 
13260 Delete_Member: ! ***** Delete Json Member Value
13280 def FNDELETE_MEMBER(; REPLACE_FLAG)
13300    let FNDELETE_MEMBER = FALSE
13320    let SUCCESS = FNGET_CURRENT_OBJECT ! Load Work$ !:
         if SUCCESS < 1 then !:
            let FNDELETE_MEMBER = SUCCESS !:
            goto End_Delete_Member
13340 Delete_Child_Loop: ! 
13360    let SUCCESS = FNFIND_MEMBER ! Find Member ####### !:
         if SUCCESS < 0 then !:
            let FNDELETE_MEMBER = SUCCESS !:
            goto End_Delete_Member
13380    let LAST_COLON2 = LAST_COLON !:
         let LAST_COLON = MAX(LAST_COLON,ELEMENT) !:
         if ELEMENT AND SUCCESS > 0 then 
13400       let SUCCESS2 = FNADVANCE_TO_COMMA(WORK$,ELEMENT,PUNCT) ! Find Next!:
            if SUCCESS2 < 0 then !:
               let FNDELETE_MEMBER = -(40+NAME_SUB-1) ! Unbalanced Punctuation!:
               goto End_Delete_Member
13420    end if 
13440    if SUCCESS == 0 OR LAST_COLON == PUNCT then !:
            let FNDELETE_MEMBER = -(20+NAME_SUB-1) ! Member Not Found !:
            goto End_Delete_Member
13460    if REPLACE_FLAG then ! ####### Insert Value #######
13480       let WORK4$ = VALUE$(1:1) !:
            let ADD_QUOTES = FALSE !:
            if (NOT POS('"{[',WORK4$)) AND NOT AS_IS_FLAG then ! Value Not Quoted !:
               let ADD_QUOTES = ( ( (WORK4$ == NULL$) OR POS(VALUE$,",")) ) !:
               let DUMMY = VAL(VALUE$) conv Add_Quotes !:
               let DUMMY = ((WORK4$ == "0" AND VALUE$(2:2) <> ".") OR (NOT POS("123456789",WORK4$))) !:
               let ADD_QUOTES = MAX(ADD_QUOTES, QUOTE_NUMERICS,DUMMY)
13500       if ADD_QUOTES then !:
               let WORK$(PUNCT:0) = '"' !:
               let WORK$(LAST_COLON +1:0) ='"' !:
               let PUNCT += 2
13520       let WORK$(LAST_COLON+(1+ADD_QUOTES):PUNCT-(1+ADD_QUOTES)) = VALUE$ !:
            goto Check_Brackets
13540    end if 
13560    if NULL_VALUE_FLAG then ! ####### Insert Null Value ####### !:
            let WORK$(LAST_COLON+1:PUNCT-1) = '""' !:
            goto Check_Brackets
13580 Delete_Bracket_Loop: ! 
13600    let QUOTES_ACTIVE = 0 !:
         let POS1 = LAST_COLON +1 ! Prep Backward Search
13620    do  ! Find Leading Boundary !:
            let POS1 -= 1 !:
            if WORK$(POS1:POS1) == '"' then !:
               let QUOTES_ACTIVE = ~QUOTES_ACTIVE
13640    loop UNTIL ((NOT QUOTES_ACTIVE) AND (LEFT_BOUND := POS(",{[",WORK$(POS1:POS1)))) OR POS1 == 0
13660    on LEFT_BOUND goto Left_Comma, Left_Brace, Left_Bracket none End_Delete_Member
13680 Left_Comma: ! Left Boundary Is A Comma
13700    let WORK$(POS1:PUNCT-1) = NULL$ !:
         goto Check_Brackets
13720 Right_Comma: let WORK$(POS1+1:PUNCT) = NULL$ !:
         goto Check_Brackets
13740 ! 
13760 Left_Brace: ! Left Boundary Is A Brace
13780    if WORK$(PUNCT:PUNCT) == "," then !:
            goto Right_Comma !:
         else goto Delete_Child
13800 Left_Bracket: ! Left Boundary Is A Bracket
13820    if WORK$(PUNCT:PUNCT) == "," then !:
            goto Right_Comma
13840    if WORK$(PUNCT:PUNCT) <> "]" then !:
            let FNDELETE_MEMBER = -(40+NAME_SUB-1) ! Unbalanced Punctuation!:
            goto End_Delete_Member
13860    let SUCCESS = FNADVANCE_TO_COMMA(WORK$,POS1-1,PUNCT) ! Find Outer Area !:
         if SUCCESS < 0 then !:
            let FNDELETE_MEMBER = -(40+NAME_SUB-1) ! Unbalanced Punctuation!:
            goto End_Delete_Member !:
         else let LAST_COLON = POS1-1 !:
            let ELEMENT = 0 !:
            goto Delete_Bracket_Loop
13880 ! 
13900 Delete_Child: ! Empty Member - Delete Or Null Value
13920    if NAME_SUB == 2 then ! First Level - Leave Braces !:
            let WORK$(POS1+1:PUNCT-1) = NULL$ !:
            goto Delete_Done
13940    let NAME_SUB -= 1 ! Drop Back One Level!:
         let FNINIT(NAME$, MAT NAMES$) ! Recover Subscripts !:
         mat NAMES$(NAME_SUB) ! Trim Names Array !:
         goto Delete_Child_Loop
13960 ! 
13980 Check_Brackets: ! Check For Single Value List
14000    let POS1 = LAST_COLON2 !:
         do WHILE WORK$((POS1+=1):POS1) == " " !:
         loop  ! Skip White Space
14020    if WORK$(POS1:POS1) == "[" then 
14040       let SUCCESS = FNADVANCE_TO_COMMA(WORK$,POS1,PUNCT) ! Find Next!:
            if SUCCESS < 0 then !:
               let FNDELETE_MEMBER = -(40+NAME_SUB-1) ! Unbalanced Punctuation!:
               goto End_Delete_Member
14060       if WORK$(PUNCT:PUNCT) == "]" then !:
               let WORK$(PUNCT:PUNCT) = NULL$ !:
               let WORK$(POS1:POS1) = NULL$
14080    end if 
14100 Delete_Done: let FNDELETE_MEMBER = TRUE
14120    let CHANGED = TRUE
14140 End_Delete_Member: fnend 
14160 ! 
14180 Store_Object: ! ***** Copy Work$ Into Storage$ & Adjust Sizes
14200 def FNSTORE_OBJECT
14220    let OBJ_SIZE = CEIL(LEN(WORK$)/10000) ! Size Of Object !:
         let OBJ_DIFF = OBJ_SIZE - (END(OBJ_SUB) - START(OBJ_SUB) +1) !:
         let END(OBJ_SUB) += OBJ_DIFF ! Adjust Saved Size
14240    if OBJ_DIFF > 0 then !:
            mat STORAGE$(UDIM(STORAGE$) + OBJ_DIFF) ! Expand Storage!:
            for SUB1 = (UDIM(STORAGE$)-OBJ_DIFF) to START(OBJ_SUB) step -1 !:
               let STORAGE$(SUB1+OBJ_DIFF) = STORAGE$(SUB1) ! Shift Storage Up!:
            next SUB1
14260    let POS1 = 1 !:
         let POS2 = 10000 !:
         for STOR_SUB = START(OBJ_SUB) to END(OBJ_SUB) ! Store Object ##### !:
            let STORAGE$(STOR_SUB) = WORK$(POS1:POS2) !:
            let POS1 += 10000 !:
            let POS2 += 10000 !:
         next STOR_SUB
14280    if WORK$(POS1:POS1) <> NULL$ then !:
            print "assertion failure - left over work$ is ";LEN(WORK$(POS1:INF));" bytes" !:
            pause 
14300    if OBJ_DIFF < 0 then !:
            for SUB1 = END(OBJ_SUB)+1 to UDIM(STORAGE$)+OBJ_DIFF !:
               let STORAGE$(SUB1) = STORAGE$(SUB1-OBJ_DIFF) ! Shift Down!:
            next SUB1 !:
            mat STORAGE$(UDIM(STORAGE$) + OBJ_DIFF) ! Reduce Storage
14320    let WORK_CONTENT = OBJ_SUB ! Current Work$ Object Pointer !:
         let FNSTORE_OBJECT = TRUE !:
         let CHANGED = FALSE
14340 End_Store_Object: fnend 
14360 ! 
14380 Find_Member: ! ***** Find Json Object Member
14400 ! Function Sets 'LAST_COLON' To Colon Following The Name And !:
      ! 'PUNCT' To The Punctuation That Terminates "The Last found \ !:
      ! Named Value Area" (this is the parent value term when not found) !:
      ! Name_Sub Points To The Last Name Searched !:
      ! 'FOUND' Is Set To True Or False !:
      ! If Low Level 'ARRAY_REF', 'ELEMENT' Is Set To Punct Left Of Element
14420 def FNFIND_MEMBER
14440    let FNFIND_MEMBER = FALSE !:
         let LAST_COLON = ELEMENT = 0 ! Start Here !:
         for NAME_SUB = 2 to UDIM(NAMES$) ! Search For Member
14460       let ARRAY_REF = 0 ! Array Ref Value !:
            if (POS1 := POS(NAMES$(NAME_SUB),"[")) AND (POS2 := POS(NAMES$(NAME_SUB),"]",POS1)) then 
14480          let ARRAY_REF = VAL(NAMES$(NAME_SUB)(POS1+1:POS2-1)) conv Ignore !:
               let NAMES$(NAME_SUB)(POS1:200) = NULL$ !:
               if ARRAY_REF < 1 then !:
                  let FNFIND_MEMBER = -(30+NAME_SUB-1) ! Invalid Subscript !:
                  goto End_Find_Member
14500       end if 
14520       let PUNCT = MAX(ELEMENT,LAST_COLON) ! Search From Here !:
            do WHILE WORK$((PUNCT+=1):PUNCT) == " " ! Skip White Space!:
            loop 
14540       if WORK$(PUNCT:PUNCT) <> "{" then !:
               let FNFIND_MEMBER = -(20+NAME_SUB-1) ! Member Not Found !:
               goto End_Find_Member
14550       rem if NAME_SUB = 3 AND POS(NAMES$(3),"^notes") then print "found=";FOUND;'   ';NAMES$(3) : execute 'go step'
14560       let FOUND = FNFIND_NAME(WORK$,PUNCT,FNQUOTE$(NAMES$(NAME_SUB))) !:
            ! Find_Name() Returns Posn Of Colon Following The Name In Punct
14580       if FOUND < 0 then 
14600          if FOUND == -40 then !:
                  let FNFIND_MEMBER = -(40+NAME_SUB-1) ! Unbalanced Quotes !:
                  goto End_Find_Member
14620          let FNFIND_MEMBER = FOUND ! Forward Error Code !:
               goto End_Find_Member
14640       else if FOUND then ! Name Found !:
               let LAST_COLON = PUNCT
14660 ! 
14680 Find_Ending: ! Find Ending Brace For Either Found Member Or Its Parent
14700       let SUCCESS := FNADVANCE_TO_COMMA(WORK$,LAST_COLON,PUNCT)
14720       if SUCCESS == -40 then !:
               let FNFIND_MEMBER = -(40+NAME_SUB-1) ! Unbalanced Quotes !:
               goto End_Find_Member
14740 ! 
14760 !         Print "name$=";Names$(Name_Sub);"   found=";Found;"   last_colon=";Last_Colon;"   punct=";Punct
14780 ! 
14800       if NOT FOUND then !:
               goto End_Find_Member
14820       if ARRAY_REF then ! Find Element #######
14840          let POS2 = LAST_COLON ! Skip White Space !:
               do WHILE WORK$((POS2+=1):POS2) == " " !:
               loop 
14860          if WORK$(POS2:POS2) <> "[" then ! If No Bracket
14880             if ARRAY_REF > 2 then !:
                     let FNFIND_MEMBER = -(30+NAME_SUB-1) ! Invalid Subscript !:
                     goto End_Find_Member
14900             let ELEMENT = LAST_COLON
14920             if ARRAY_REF == 2 then 
14940                let SUCCESS := FNADVANCE_TO_COMMA(WORK$,LAST_COLON,PUNCT) !:
                     if SUCCESS == -40 then !:
                        let FNFIND_MEMBER = -(40+NAME_SUB-1) ! Unbalanced Quotes !:
                        goto End_Find_Member
14960                let ELEMENT = PUNCT
14980             end if 
15000          else ! Bracket Found
15020             let COUNT = 0 !:
                  do WHILE (SUCCESS := FNADVANCE_TO_COMMA(WORK$,POS2,POS3)) => 0 !:
                     let COUNT += 1 !:
                     let POS2A = POS2 ! Save Pos2 !:
                     let POS2 = POS3 ! Advance To Ending Punctuation !:
                     let CHAIN_BRACKETS = TRUE !:
                  loop UNTIL COUNT == ARRAY_REF OR SUCCESS == 0
15040             let CHAIN_BRACKETS = FALSE
15060             if SUCCESS == -40 then !:
                     let FNFIND_MEMBER = -(40+NAME_SUB-1) !:
                     ! Unbalanced Quotes !:
                     goto End_Find_Member
15080             if ARRAY_REF > COUNT+1 then !:
                     let FNFIND_MEMBER = -(30+NAME_SUB-1) !:
                     ! Invalid Member Subscript !:
                     goto End_Find_Member !:
                  else if ARRAY_REF == COUNT then !:
                     let ELEMENT = POS2A ! Element Found !:
                  else let ELEMENT = POS2 ! Position At The End Of List !:
                     if WORK$(POS2:POS2) <> "]" then pause 
15100          let PUNCT = POS3
15120       end if  ! Bracket Found !:
         end if  ! Array_Ref
15140 ! If Element Doesn't exist and were not going to insert the !:
         ! Low Order Member
15160    let DUMMY = UDIM(NAMES$) !:
         if (ELEMENT == PUNCT) AND ((NAME_SUB < (DUMMY-1)) OR ((NAME_SUB == (DUMMY-1)) AND POS(NAMES$(DUMMY),"["))) then 
15180       let FNFIND_MEMBER = -(30+NAME_SUB-1) ! Invalid Subscript !:
            goto End_Find_Member
15200    end if 
15220    if ARRAY_REF == 0 then !:
            let ELEMENT = 0
15240 next NAME_SUB
15260 let NAME_SUB -= 1 ! Point At Member Name Found !:
      let FNFIND_MEMBER = TRUE
15280 End_Find_Member: fnend 
15300 ! 
15320 Find_Name: !  ***** Find Member Name
15340 def FNFIND_NAME(&WORK$,&BRACE_POS,NAME$*200;PUNCT,BRACE,COLON)
15360 ! Brace_Pos Gives The Opening Brace Of The Area To Be Searched
15380    let FNFIND_NAME = FALSE !:
         let PUNCT = BRACE_POS !:
         let NAME$ = UPRC$(NAME$)
15400 ! 
15420    do  ! Examine Each Named Pair In Braced Area
15440       let COLON = POS(WORK$,":",PUNCT) !:
            if UPRC$(TRIM$(WORK$(PUNCT+1:COLON-1))) == NAME$ then !:
               let BRACE_POS = COLON ! Return Colon Posn After Name !:
               let FNFIND_NAME = TRUE !:
               goto End_Find_Name
15460    loop UNTIL (FNADVANCE_TO_COMMA(WORK$,MAX(COLON,PUNCT),PUNCT)) < 1
15480 End_Find_Name: fnend 
15500 ! 
15520 Advance_To_Comma: ! ***** Advance Work Area Pointer
15540 def FNADVANCE_TO_COMMA(&WORK$,COLON,&PUNCT;POS1,POS2,POS3,BRACE_DEPTH,BRACKET_DEPTH)
15560 ! Return True If Comma Found, Else Return False Or Error
15580    let FNADVANCE_TO_COMMA = FALSE !:
         let POS1 = COLON+1 !:
         let FIRST_PASS = QUOTE_POS = INF
15600 ! 
15620 Quote_Loop: ! Loop Here After Skipping Quoted Area
15640    if OPEN_BRACE_POS <= QUOTE_POS then !:
            let OPEN_BRACE_POS = POS(WORK$,"{",POS1)
15660    if NOT OPEN_BRACE_POS then let OPEN_BRACE_POS = INF
15680    if CLOSE_BRACE_POS <= QUOTE_POS then !:
            let CLOSE_BRACE_POS = POS(WORK$,"}",POS1)
15700    if NOT CLOSE_BRACE_POS then let CLOSE_BRACE_POS = INF
15720    if COMMA_POS <= QUOTE_POS then !:
            let COMMA_POS = POS(WORK$,",",POS1)
15740    if NOT COMMA_POS then let COMMA_POS = INF
15760 ! 
15780    if NOT (FIRST_PASS AND CHAIN_BRACKETS) then 
15800       if OPEN_BRACKET_POS <= QUOTE_POS then !:
               let OPEN_BRACKET_POS = POS(WORK$,"[",POS1)
15820       if NOT OPEN_BRACKET_POS then let OPEN_BRACKET_POS = INF
15840       if CLOSE_BRACKET_POS <= QUOTE_POS then !:
               let CLOSE_BRACKET_POS = POS(WORK$,"]",POS1)
15860       if NOT CLOSE_BRACKET_POS then let CLOSE_BRACKET_POS = INF
15880    end if 
15900 ! 
15920    let FIRST_PASS = FALSE !:
         goto Quote_ ! Now Go Find Next Quote
15940 ! 
15960 Advance_Loop: ! ***** Main Advance Loop
15980    on POS('{}[]",',WORK$(POS3:POS3)) goto Open_Brace_, Close_Brace_, Open_Bracket_, Close_Bracket_, Quote_, Comma_
16000 Open_Brace_: let OPEN_BRACE_POS = POS(WORK$,"{",POS1) !:
         if NOT OPEN_BRACE_POS then let OPEN_BRACE_POS = INF
16020    goto Advance_Min
16040 Close_Brace_: let CLOSE_BRACE_POS = POS(WORK$,"}",POS1) !:
         if NOT CLOSE_BRACE_POS then let CLOSE_BRACE_POS = INF
16060    goto Advance_Min
16080 Open_Bracket_: let OPEN_BRACKET_POS = POS(WORK$,"[",POS1) !:
         if NOT OPEN_BRACKET_POS then let OPEN_BRACKET_POS = INF
16100    goto Advance_Min
16120 Close_Bracket_: let CLOSE_BRACKET_POS = POS(WORK$,"]",POS1) !:
         if NOT CLOSE_BRACKET_POS then let CLOSE_BRACKET_POS = INF
16140    goto Advance_Min
16160 Quote_: let QUOTE_POS = POS(WORK$,'"',POS1) !:
         if NOT QUOTE_POS then let QUOTE_POS = INF
16180    goto Advance_Min
16200 Comma_: let COMMA_POS = POS(WORK$,",",POS1) !:
         if NOT COMMA_POS then let COMMA_POS = INF
16220 !   Goto Advance_Min
16240 Advance_Min: ! Find Minimum
16260    let POS3 = POS2 = MIN(OPEN_BRACE_POS, CLOSE_BRACE_POS, OPEN_BRACKET_POS, CLOSE_BRACKET_POS, QUOTE_POS, COMMA_POS)
16280    on POS('{}[]",',WORK$(POS2:POS2)) goto _Open_Brace, _Close_Brace, _Open_Bracket, _Close_Bracket, _Quote, _Comma
16300 ! 
16320 Unbalanced: ! !:
         let FNADVANCE_TO_COMMA = -40 ! Unbalanced Braces Or Quotes !:
         goto End_Advance_To_Comma
16340 ! 
16360 _Open_Brace: ! ** Process Open Brace
16380    if NOT BRACKET_DEPTH then let BRACE_DEPTH += 1 !:
            let POS1 = POS2+1 !:
            goto Advance_Loop
16400 _Close_Brace: ! ** Process Close Brace
16420    if NOT BRACKET_DEPTH then 
16440       let BRACE_DEPTH -= 1
16460       if BRACE_DEPTH < 0 then !:
               let PUNCT = POS2 !:
               goto End_Advance_To_Comma
16480    end if 
16500    let POS1 = POS2+1 !:
         goto Advance_Loop
16520 ! 
16540 _Open_Bracket: ! ** Process Open Bracket
16560    if NOT BRACE_DEPTH then let BRACKET_DEPTH += 1 !:
            let POS1 = POS2+1 !:
            goto Advance_Loop
16580 _Close_Bracket: ! ** Process Close Bracket
16600    if NOT BRACE_DEPTH then 
16620       let BRACKET_DEPTH -= 1
16640       if BRACKET_DEPTH < 0 then !:
               let PUNCT = POS2 !:
               goto End_Advance_To_Comma
16660    end if 
16680    let POS1 = POS2+1 !:
         goto Advance_Loop
16700 ! 
16720 _Quote: ! ** Process Quote
16740    let POS1 = POS(WORK$,'"',POS2+1)+1 ! Byte After Next Quote
16760    if POS1 == 1 then !:
            goto Unbalanced !:
         else !:
            goto Quote_Loop
16780 _Comma: ! ** Process Comma
16800    if BRACE_DEPTH OR BRACKET_DEPTH then !:
            let POS1 = POS2+1 !:
            goto Advance_Loop
16820    let PUNCT = POS2 !:
         let FNADVANCE_TO_COMMA = TRUE
16840 End_Advance_To_Comma: fnend 
16860 ! 
16880 Compile_Object: ! ***** Compile And Store A Json Member
16900 def library FNCOMPILE_OBJECT(TYPE$, MEMBER_NAME$*200, MAT KEYS$, MAT VALUES$, OBJECT_NAME$*200;WORK2$*30000)
16920    if POS(OBJECT_NAME$,".") then !:
            let FNCOMPILE_OBJECT = -60 !:
            goto End_Compile_Object
16940    library : FNCOMPILE_JSON, FNPUT_JSON
16960    let SUCCESS = FNCOMPILE_JSON(TYPE$, MEMBER_NAME$, MAT KEYS$, MAT VALUES$, WORK2$) !:
         if SUCCESS < 0 then !:
            let FNCOMPILE_OBJECT = SUCCESS !:
            goto End_Compile_Object
16980    let FNCOMPILE_OBJECT = FNPUT_JSON(OBJECT_NAME$,WORK2$)
17000 End_Compile_Object: fnend 
17020 ! 
17040 Compile_Json: ! ***** Compile A Json Member Or Value Set
17060 def library FNCOMPILE_JSON(TYPE$, MEMBER_NAME$*200, MAT KEYS$, MAT VALUES$, &CONTAINER$; QUOTE_NUMERICS)
17080    let QUOTE_NUMERICS = SGN(QUOTE_NUMERICS) !:
         if UDIM(KEYS$) <> UDIM(VALUES$) then !:
            let FNCOMPILE_JSON = -500 !:
            goto End_Compile_Json
17100    if NOT POS("{[",TYPE$) then !:
            let FNCOMPILE_JSON = -510 !:
            goto End_Compile_Json
17120    if MEMBER_NAME$ == NULL$ then !:
            let MEMBER_NAME$ = "@#$"
17140    if UDIM(KEYS$) == 0 then !:
            let FNCOMPILE_JSON = -540 !:
            goto End_Compile_Json
17160    library : FNINSERT_JSON
17180    let TRUE = 1 !:
         let WORK_CONTENT = 0 ! Work$ Contents Destroyed !:
         on soflow goto Soflow_Compile_Error !:
         let COMPILE_LIST = COMPILE_MEMBER = FALSE !:
         if TYPE$ == "{" then !:
            let COMPILE_MEMBER = TRUE !:
            let WORK$ = '{"'&MEMBER_NAME$&'":{}}' !:
            mat NAMES$(3) = ("XXX") !:
         else !:
            let COMPILE_LIST = TRUE !:
            let WORK$ = '{"'&MEMBER_NAME$&'":[""]}' !:
            mat NAMES$(2) = ("XXX")
17200    let NAMES$(2) = MEMBER_NAME$ !:
         for SUB1 = 1 to UDIM(KEYS$) !:
            if COMPILE_MEMBER then 
17220          if KEYS$(SUB1) == NULL$ then !:
                  let FNCOMPILE_JSON = -530 !:
                  goto End_Compile_Json
17240          let NAMES$(3) = KEYS$(SUB1) !:
               let SUCCESS = FNINSERT_JSON("YYY",VALUES$(SUB1),0,0,1) !:
               if SUCCESS < 0 then !:
                  let FNCOMPILE_JSON = SUCCESS !:
                  goto End_Compile_Json
17260       else ! Compile List
17280          if KEYS$(SUB1) > NULL$ then ! Key Specified In List
17300             let ADD_QUOTES = (VALUES$(SUB1) == NULL$) !:
                  if NOT POS('"{[',VALUES$(SUB1)(1:1)) then ! Value Not Quoted !:
                     let DUMMY = VAL(VALUES$(SUB1)) conv Add_Quotes !:
                     let ADD_QUOTES = MAX(ADD_QUOTES, QUOTE_NUMERICS)
17320             let QUOTE$ = '"'(1:ADD_QUOTES) ! Set Quote Value !:
                  let CONTAINER$ = '{"'& KEYS$(SUB1) &'":'&QUOTE$ !:
                  let CONTAINER$(300:0) = VALUES$(SUB1) !:
                  let CONTAINER$(INF:0) = QUOTE$&"}"
17340             let SUCCESS = FNINSERT_JSON("YYY",CONTAINER$,0,0,1) !:
                  if SUCCESS < 0 then !:
                     let FNCOMPILE_JSON = SUCCESS !:
                     goto End_Compile_Json
17360          else ! Normal List Value !:
               let SUCCESS = FNINSERT_JSON("YYY",VALUES$(SUB1),0,0,1) !:
               if SUCCESS < 0 then !:
                  let FNCOMPILE_JSON = SUCCESS !:
                  goto End_Compile_Json
17380       end if  ! End If Compile List
17400    next SUB1
17420    if COMPILE_LIST then ! Remove Initial Place Holder
17440       if UDIM(KEYS$) > 1 then !:
               let POS1 = POS(WORK$,":") !:
               let WORK$(POS1+2:POS1+4) = NULL$ !:
            else ! Same But Include Removal Of Brackets !:
               let POS1 = POS(WORK$,":") !:
               let WORK$(POS1+1:POS1+4) = NULL$ !:
               let WORK$(WORK:=LEN(WORK$)-1:WORK) = NULL$ ! Trailing Bracket
17460    end if 
17480    if MEMBER_NAME$ == "@#$" then !:
            let WORK$(1:7) = NULL$ ! Remove Name !:
            let WORK$(LEN(WORK$):LEN(WORK$)) = NULL$
17500    let CONTAINER$ = WORK$ !:
         let FNCOMPILE_JSON = SUB1 -1 !:
         goto End_Compile_Json
17520 Soflow_Compile_Error: let FNCOMPILE_JSON = -SUB1
17540 End_Compile_Json: on soflow system  !:
      fnend 
17560 ! 
17580 Parse_Object: ! ***** Parse And Store A Json Member
17600 def library FNPARSE_OBJECT(OBJECT_NAME$*200, &TYPE$, &MEMBER_NAME$, MAT KEYS$, MAT VALUES$ ;WORK3$*30000)
17620    if POS(OBJECT_NAME$,".") then !:
            let FNPARSE_OBJECT = -60 !:
            goto End_Parse_Object
17640    library : FNPARSE_JSON, FNGET_JSON
17660    let SUCCESS = FNGET_JSON(OBJECT_NAME$,WORK3$) !:
         if SUCCESS < 0 then !:
            let FNPARSE_OBJECT = SUCCESS !:
            goto End_Parse_Object
17680    let FNPARSE_OBJECT = FNPARSE_JSON(WORK3$, TYPE$, MEMBER_NAME$, MAT KEYS$, MAT VALUES$)
17700 End_Parse_Object: fnend 
17720 ! 
17740 Parse_Json: ! ***** Parse A Json Member Or Value Set
17760 def library FNPARSE_JSON(STRING$*30000, &TYPE$, &MEMBER_NAME$, MAT KEYS$, MAT VALUES$;WORK2$*30000)
17761 ! ########### Fixme After Fixing Br Change To 50000 ################
17780    let STRING_LEN = LEN(STRING$) !:
         on soflow goto Soflow_Parse_Error !:
         let POS1 = TRUE = 1 !:
         let COUNT = VALUE_SET = 0 !:
         let TYPE$ = MEMBER_NAME$ = NULL$ !:
         mat KEYS$(300) = (NULL$) !:
         mat VALUES$(300) = (NULL$)
17800    if NOT POS("{[",STRING$(1:1)) then 
17820       if ((STRING$(1:1) <>'"' OR STRING$(STRING_LEN:STRING_LEN) <>'"') AND STRING_LEN > 15) OR STRING_LEN == 0 then !:
               goto Invalid_Json
17840       let WORK = VAL(STRING$) conv 17860 !:
            goto Valid_Json ! Good Stuff
17860       if NOT ( (STRING$(1:1) == '"' AND STRING$(STRING_LEN:STRING_LEN) == '"') OR UPRC$(STRING$) == "TRUE" OR UPRC$(STRING$) == "FALSE" OR UPRC$(STRING$) == "NULL") then goto Invalid_Json
17880 Valid_Json: ! 
17900       let COUNT = 1 !:
            let VALUES$(1) = STRING$ !:
            let TYPE$ = "[" ! Single Element List!:
            goto Finish_Parse
17920 Invalid_Json: ! 
17940       let FNPARSE_JSON = -520 !:
            goto End_Parse
17960    end if 
17980    let SUCCESS = FNADVANCE_TO_COMMA(STRING$,POS1,PUNCT) ! Find Punct !:
         if SUCCESS < 0 then !:
            let FNPARSE_JSON = SUCCESS ! Unbalanced Punctuation!:
            goto End_Parse
18000    if STRING$(PUNCT:PUNCT) == "," OR STRING$(1:1) == "[" then !:
            let VALUE_SET = TRUE !:
            let TYPE$ = STRING$(1:1)
18020    if VALUE_SET then 
18040       do  !:
               let COUNT +=1 !:
               if COUNT > UDIM(KEYS$) then !:
                  mat KEYS$(300+UDIM(KEYS$)) !:
                  mat VALUES$(UDIM(KEYS$))
18060 ! 
18080          if TYPE$ = "[" then ! Array !:
                  let VALUES$(COUNT) = STRING$(POS1+1:PUNCT-1) !:
               else ! Member List
18100             let WORK2$ = STRING$(POS1+1:PUNCT-1) !:
                  let POS1 = POS(WORK2$,'"') !:
                  let POS2 = POS(WORK2$,'"',POS1+1) !:
                  let POS3 = POS(WORK2$,":",POS2) !:
                  if NOT MIN(POS1,POS2,POS3) then let FNPARSE_JSON = -COUNT !:
                     goto End_Parse
18120             let KEYS$(COUNT) = WORK2$(POS1+1:POS2-1) !:
                  let VALUES$(COUNT) = TRIM$(WORK2$(POS3+1:30000))
18140          end if 
18160 ! 
18180          let POS1 = PUNCT !:
               if STRING$(POS1:POS1) == "," then 
18200             let SUCCESS = FNADVANCE_TO_COMMA(STRING$,POS1,PUNCT) ! Find Punct !:
                  if SUCCESS < 0 then !:
                     let FNPARSE_JSON = SUCCESS ! Unbalanced Punctuation!:
                     goto End_Parse
18220          end if 
18240       loop WHILE STRING$(POS1:POS1) == ","
18260    else ! Single Member
18280       library : FNPARSE_JSON
18300       let POS1 = POS(STRING$,'"') !:
            let POS2 = POS(STRING$,'"',POS1+1) !:
            let POS3 = POS(STRING$,":",POS2) !:
            if NOT (MIN(POS1,POS2,POS3) AND STRING$(STRING_LEN:STRING_LEN) == "}") then goto Invalid_Json
18320       let MEMBER_NAME$ = STRING$(POS1+1:POS2-1) !:
            let TYPE$ = "{" !:
            let WORK2$ = TRIM$(STRING$(POS3+1:STRING_LEN-1)) !:
            let PUNCT = 0 !:
            if WORK2$(1:1) == "{" then ! Check For Value Set
18340          let SUCCESS = FNADVANCE_TO_COMMA(WORK2$,1,PUNCT) ! Find Punct !:
               if SUCCESS < 0 then !:
                  let FNPARSE_JSON = SUCCESS ! Unbalanced Punctuation!:
                  goto End_Parse
18360       end if 
18380       if POS("{[",WORK2$(1:1)) OR WORK2$(PUNCT:PUNCT) == "," then ! If List Or Member Parse Value Set !:
               let FNPARSE_JSON(WORK2$,TYPE$,DUMMY$,MAT KEYS$,MAT VALUES$) !:
            else !:
               let COUNT = 1 !:
               let VALUES$(1) = WORK2$ !:
               let KEYS$(1) = MEMBER_NAME$ !:
               let MEMBER_NAME$ = NULL$
18400    end if  ! End If Value Set
18420 Finish_Parse: ! 
18440    let FNPARSE_JSON = COUNT !:
         goto End_Parse
18460 Soflow_Parse_Error: ! 
18480    let FNPARSE_JSON = -(MAX(1,COUNT))
18500 End_Parse: ! Trim Arrays
18520    mat KEYS$(COUNT) !:
         mat VALUES$(COUNT) !:
         for SUB1 = 1 to COUNT ! Strip Quotes !:
            let POS1 = LEN(VALUES$(SUB1)) !:
            if (VALUES$(SUB1)(1:1) == '"') AND (VALUES$(SUB1)(POS1:POS1) == '"') then !:
               let VALUES$(SUB1)(POS1:POS1) = NULL$ !:
               let VALUES$(SUB1)(1:1) = NULL$
18540    next SUB1 !:
         on soflow system 
18560 fnend 
18580 ! 
18600 Send_Object: ! ***** Send An Object Or Json Member
18620 def library FNSEND_OBJECT(OBJECT_NAME$*200)
18640    if POS(OBJECT_NAME$,".") then !:
            let FNSEND_OBJECT = -60 !:
            goto End_Send_Object
18660    if (SUCCESS := FNINIT(OBJECT_NAME$, MAT NAMES$)) < 0 then !:
            let FNSEND_OBJECT = SUCCESS !:
            goto End_Send_Object
18680    if (SUCCESS := FNGET_CURRENT_OBJECT) < 0 then !:
            let FNSEND_OBJECT = SUCCESS !:
            goto End_Send_Object
18700    if DEBUG then !:
            print #DEBUG: "======== send object ============" !:
            print #DEBUG: "PRINT WORK$ "; LEN(WORK$);" bytes: " !:
            print #DEBUG: WORK$(1:300) !:
            print #DEBUG: WORK$(LEN(WORK$)-299:99999)
18720    let PAGEBUF$(INF:0) = WORK$ ! Append To Output
18740    let FNSEND_OBJECT = 1 !:
         let WORK_CONTENT = 0
18760 End_Send_Object: fnend 
18780 ! 
18800 Send_String: ! ***** Send A String Value
18820 def library FNSEND_STRING(VALUE$*30000)
18821 ! ########### Fixme After Fixing Br Change To 50000 ################
18840    let WORK$ = VALUE$ !:
         let WORK_CONTENT = 0
18860    if DEBUG then !:
            print #DEBUG: "========== send string ==========" !:
            print #DEBUG: "PRINT WORK$ "; LEN(WORK$);" bytes: " !:
            print #DEBUG: WORK$(1:300)
18880    let PAGEBUF$(INF:0) = WORK$ ! Append To Output
18900    let FNSEND_STRING = 1
18920 End_Send_String: fnend 
18940 ! 
18960 ! ******************** Serve Web Page *********************
18980 ! Data Printed To Http Is Not Actually Sent Until The Linput
19000 Send_Local_Page: ! ***** Send Direct Local Page
19020 def FNSEND_LOCAL_PAGE(URL$*4096;MAT ARGS$,MAT REPL$,SUPPRESS_HDR)
19040    let URL_BASE_SAVE$ = URL_BASE$ !:
         let EXT_SAVE$ = EXT$ !:
         let EXT$ = URL_BASE$ = NULL$ !:
         let SUPPRESS_HEADER = SUPPRESS_HDR ! Set Global
19060    let FNSEND_PAGE(URL$,MAT ARGS$,MAT REPL$)
19080    let URL_BASE$ = URL_BASE_SAVE$ !:
         let EXT$ = EXT_SAVE$
19100 End_Send_Local_Page: fnend 
19120 ! 
19140 Send_Page: ! ***** Send An Html Page With String Replacements
19160 def library FNSEND_PAGE(URL$*4096;MAT ARGS$,MAT REPL$,SUB1,FILE_NAME$*500)
19180    let URL$=SREP$(URL$,"/",BACKSLASH$) !:
         if URL$(1:1) == ":" then 
19200       let FULL_URL$ = URL_REDIRECT$ = URL$(2:2000) !:
            if NOT ( URL_EXISTS := EXISTS(FULL_URL$) ) then !:
               gosub Not_Found_Subr ! Report Not Found To Browser !:
               let FNSEND_PAGE = -50 ! Page Not Found !:
               goto End_Send_Page
19220    else 
19240       let URL_REDIRECT$ = URL$
19260       if URL$(1:1) <> BACKSLASH$ AND URL$(1:1) <> "." then !:
               let URL$(1:0) = BACKSLASH$ ! For Path Continuation
19280       let URL_EXISTS = EXISTS(URL_BASE$ & EXT$ & URL$) !:
            if URL_EXISTS then !:
               let URL$ = EXT$ & URL$ ! Use Extension !:
            else if NOT ( URL_EXISTS := EXISTS(URL_BASE$ & URL$) ) then !:
               gosub Not_Found_Subr ! Report Not Found To Browser !:
               let FNSEND_PAGE = -50 ! Page Not Found !:
               goto End_Send_Page
19300    let FULL_URL$=URL_BASE$ & URL$
19320 end if 
19340 ! 
19360 if URL_EXISTS == 1 then ! Directory !:
         let FNSEND_PAGE = -52 ! Not A File !:
         goto End_Send_Page
19380 if UDIM(ARGS$) <> UDIM(REPL$) then !:
         let FNSEND_PAGE = -500 ! Arrays Not Equal !:
         goto End_Send_Page
19400 ! 
19420 ! Caution- You Must Use Temp2$ Here-
19440 if (POST$ > NULL$) AND (URL_BASE$ > NULL$) then !:
         ! Redirect Instead Of Send To Clear Post Data In Client !:
         let FNSEND_LOCAL_PAGE(".\br_redirect.html",TEMP1$:="^new_location",TEMP2$:=SREP$(URL_REDIRECT$,"\","/"),TRUE) !:
         ! Url_Base$ Will Be Null On Redirect (See Send_Local_Page) !:
         goto End_Send_Page
19460 ! 
19480 let END_INPUT = WORK_CONTENT = 0 !:
      let WORK$ = NULL$
19500 open #125: "name="&TRIM$(FULL_URL$)&",recl=32000",external,input,relative ioerr Send_Page_Open_Err ! Note- Recl And Form Statement Have To Agree On Length
19520 ! 
19540 let SUB1 = POS(FULL_URL$,".",-1) !:
      let FILE_NAME$ = LWRC$(FULL_URL$(SUB1:999))
19560 let SUB1 = SRCH(MIME_KEYS$,FILE_NAME$)
19580 if SUB1 > 0 then !:
         let MIME_TYPE$ = MIME_VALUES$(SUB1) !:
      else !:
         let MIME_TYPE$ = NULL$ ! Unknown - Don't guess
19600 ! 
19620 Form25: form C 32000
19640 let SUB1 = 1 ! First Time Switch !:
      do  !:
         read #125,using Form25: PAGE$ ioerr Short_Rec eof Send_Page_Eof
19660    if 1 OR MIME_TYPE$(1:4) = "text" then !:
            let WORK$(INF:0) = PAGE$ ! Append Page Data !:
         else !:
            let WORK$(INF:0) = XLATE$(PAGE$,"STR2UTF")
19670    if DEBUG AND MIME_TYPE$(1:4) = "text" AND SUB1 then !:
            print #DEBUG: "========== send page ==========" !:
            print #DEBUG: "PRINT WORK$ "; LEN(WORK$);" bytes: " !:
            print #DEBUG: WORK$(1:300) !:
            let SUB1 = 0
19680 loop UNTIL END_INPUT
19700 Send_Page_Eof: ! 
19720 if UDIM(REPL$) > 0 AND POS(REPL$(1),"^redirect") then pause  !:
         ! Redirecting To Redirect.. Should Never Happen.. Will Loop
19740 for SUB1 = 1 to UDIM(ARGS$) ! Search And Replace !:
         let WORK$ = SREP$(WORK$,ARGS$(SUB1),REPL$(SUB1)) !:
      next SUB1
19760 ! 
19780 let PAGEBUF$(INF:0) = WORK$ ! Append To Output
19800 close #125: !:
      let FNSEND_PAGE = 1 ! Success !:
      goto End_Send_Page
19820 Send_Page_Open_Err: ! 
19840 dim _ERR$*255
19860 let _ERR$ = BRERR$ !:
      let _ERR = ERR
19880 let FNSEND_PAGE = -54 ! Cannot Open !:
      goto End_Send_Page
19900 Short_Rec: ! ***** Handle Short Record
19920 reread #125,using Form25: PAGE$ !:
      let PAGE$=RTRM$(PAGE$,CHR$(0)) !:
      let END_INPUT = 1 !:
      continue 
19940 End_Send_Page: fnend 
19960 ! 
19980 Send_Header: ! ***** Send Http Header
20000 def FNSEND_HEADER(MIME_TYPE$*50,CONTENT_LENGTH;POSN,WORK$*5500)
20020 ! 
20040    print #HTTP_FILE: "HTTP/1."&HTTP_VERSION$&" 200 OK" & CRLF$ !:
         if MIME_TYPE$ > NULL$ then !:
            print #HTTP_FILE: "Content-Type: "; MIME_TYPE$; CRLF$
20060    print #HTTP_FILE: "Content-Length:";CONTENT_LENGTH; CRLF$
20070    if SET_COOKIE$ > NULL$ then !:
            print #HTTP_FILE: SET_COOKIE$; CRLF$
20080    let WORK$=FULL_URL$ !:
         let POSN=POS(WORK$,BACKSLASH$,-1) !:
         if POSN then !:
            let WORK$(POSN:INF)=NULL$ !:
         else !:
            let WORK$=BACKSLASH$
20100    print #HTTP_FILE: 'Content-Location: ';WORK$ ; CRLF$
20120    if AUTH_REQUIRED AND (MIME_TYPE$ = "text/html") then !:
            print #HTTP_FILE: "Cache-Control: no-cache, no-store, must-revalidate"; CRLF$ !:
            print #HTTP_FILE: "Pragma: no-cache" ; CRLF$ !:
            print #HTTP_FILE: "Expires: 0" ; CRLF$
20140    let WORK2$ = "Date: " & DATE$(DAYS(DATE)+FP(DAYS(TIME$,"h:m:s"))+GMT_OFFSET,"D3, DD M3 CCYY HH:MM:SS") & " GMT" !:
         print #HTTP_FILE: WORK2$ & CRLF$ !:
         print #HTTP_FILE: "Server: BR Web_Server ";VERSION$; CRLF$
20160    if DEBUG then !:
            print #DEBUG: "========= send HTTP header =========" !:
            print #DEBUG: "HTTP/1."&HTTP_VERSION$&" 200 OK"
20180    if DEBUG AND MIME_TYPE$ > NULL$ then !:
            print #DEBUG: "Content-Type: " & MIME_TYPE$
20200    if DEBUG then !:
            print #DEBUG: "Content-Length: ";CONTENT_LENGTH
20220    if DEBUG then !:
            print #DEBUG: 'Content-Location: ';WORK$
20240    if DEBUG AND AUTH_REQUIRED AND (MIME_TYPE$ = "text/html") then !:
            print #DEBUG: "Cache-Control: no-cache, no-store, must-revalidate" !:
            print #DEBUG: "Pragma: no-cache" !:
            print #DEBUG: "Expires: 0"
20260    if DEBUG then !:
            print #DEBUG: WORK2$ !:
            print #DEBUG: "Server: BR Web_Server ";VERSION$
20280    print #HTTP_FILE: CRLF$
20300 End_Send_Header: fnend 
20320 ! 
20340 Get_Gmt_Offset: ! ***** Get Gmt Time Offset In Minutes
20360 def FNGET_GMT_OFFSET(;POSN,ACCUM,WORK,FACTOR)
20380    execute "sy -e -M reg query HKLM\System\CurrentControlSet\Control\TimeZoneInformation >" & WS_TMP2$
20400    let REG_FILE = 300 !:
         do  !:
            open #(REG_FILE+=1): "Name= " & WS_TMP2$,display,input ioerr Gmt_Error !:
         loop UNTIL FILE(REG_FILE) == 0
20420    do  !:
            linput #REG_FILE: CONTROL$ eof Gmt_Eof
20440       if CONTROL$(5:11) == "ActiveT" then 
20460          let POSN = POS(CONTROL$,"0x") !:
               let CONTROL$ = UPRC$(RTRM$(CONTROL$(POSN+2:99)))
20480          let NEGATIVE_GMT = 0 !:
               let HEX_STRING$ = "0123456789ABCDEF" !:
               if CONTROL$(1:1) = "F" then ! Negative Number !:
                  let NEGATIVE_GMT = 1 !:
                  let CONTROL$ = LTRM$(CONTROL$,"F") !:
                  let HEX_STRING$ = "FEDCBA9876543210"
20500          for WORK = 1 to LEN(CONTROL$) !:
                  let POSN = LEN(CONTROL$) !:
                  let FACTOR = 2**((WORK-1) * 4) ! Shift Multiplier !:
                  let ACCUM += ( (POS(HEX_STRING$,CONTROL$(POSN:POSN))-1) * FACTOR ) !:
                  let CONTROL$(POSN:POSN) = NULL$ !:
               next WORK
20520          if NEGATIVE_GMT then !:
                  let ACCUM += 1 !:
                  let ACCUM *= -1
20540          exit do 
20560       end if 
20580    loop 
20600 Gmt_Eof: close #REG_FILE: !:
         let FNGET_GMT_OFFSET = ACCUM
20620    let CURRENT_TIME = DAYS(DATE)+FP(DAYS(TIME$,"h:m:s")) !:
         print DATE$(CURRENT_TIME+(ACCUM * .00069445),"D3, DD M3 CCYY HH:MM:SS") & " GMT;"
20640 fnend 
20660 Gmt_Error: ! 
20680 print "Cannot Obtain GMT Offset: " !:
      print "reg query HKLM\System\CurrentControlSet\Control\TimeZoneInformation failed" !:
      print BELL; !:
      stop 
20700 ! 
20720 Get_Mime_Types: ! ***** Load Http Mime Types Per File Types
20740 dim MIME_KEYS$(350),MIME_VALUES$(350)*40,MIME_TYPE$*40
20760 open #300: "Name= filetypes.txt, Shri",display,input ioerr Mime_Error
20780 do  !:
         let SUB1 +=1
20800    input #300: MIME_VALUES$(SUB1),MIME_KEYS$(SUB1) eof Mime_Eof !:
      loop 
20820 Mime_Eof: ! 
20840 let SUB1 -= 1 !:
      mat MIME_KEYS$(SUB1) !:
      mat MIME_VALUES$(SUB1)
20860 let SUB1 = 0 !:
      return 
20880 Mime_Error: ! 
20900 print "Cannot Obtain File Types" !:
      print "Is filetypes.txt missing?" !:
      print BELL; !:
      stop 
20920 ! 
20940 Calc_Mime_Type: ! ***** Calcualte The Mime Type Of Work$ Contents
20960 let MIME_TYPE$ = LTRM$(PAGEBUF$(1:100))(1:4) !:
      if (MIME_TYPE$(1:1) == "<") OR UPRC$(MIME_TYPE$) == "HTTP" then !:
         let MIME_TYPE$ = "text/html" !:
      else if POS('{["',MIME_TYPE$) then !:
         let MIME_TYPE$ = "application/json" !:
      else let MIME_TYPE$ = NULL$
20980 return 
21000 ! 
21020 Random_Session_Numer: ! ***** Create A Random Session Number
21040 def FNRANDOM_SESSION_NUMER$*255(SIZE;___,SECTION,RESULT$*255)
21060    randomize  ! Seed The Random Number Generatorwith
21080    for INDEX_=1 to SIZE
21100       let SECTION = INT(RND*3+1)
21120       if SECTION=1 then ! Numbers 0-9
21140          let RESULT$(INF:INF) = CHR$(INT(RND*10+48)) ! Ascii  48-57
21160       else if SECTION=2 then ! Uppercase Letters
21180          let RESULT$(INF:INF) = CHR$(INT(RND*26+65)) ! Ascii  65-90, 97-122
21200       else if SECTION=3 then ! Lowercase Letters
21220          let RESULT$(INF:INF) = CHR$(INT(RND*26+97)) ! Ascii  97-122
21240       end if 
21260    next INDEX_
21280    let FNRANDOM_SESSION_NUMER$ = RESULT$
21300 fnend 
21320 ! 
21340 Exit_Br: execute "system"
21400 ! 
21420 ! ######################################################
21440 ! ***** Session Store - Nothing About A Session Stays In Memory Between !:
      ! Requests.  Each Session Is A Record In Sessions\Sess<G>.Dat, Keyed By !:
      ! The Full Session Number, <G> Being Its Low-Order Session_Digits Digits; !:
      ! Its Relogin Data (Url And Post) Is In Sessions\Sesx<G>.Dat.  So Any !:
      ! Engine Can Answer Any Request.  Status: N New (Not Logged In), !:
      ! A Authorized, X Authorization Ended, F A Free Record Awaiting Reuse.
21460 Sess_Form: form C 10,C 1,V 50,8*PD 8.6,N 1
21480 Sesx_Form: form C 13,N 4,C 4078
21500 ! 
21520 Now: ! ***** The Time As A Day Number With Its Fraction
21540 def FNNOW = DAYS(DATE)+FP(DAYS(TIME$,"h:m:s"))
21560 ! 
21580 Sess_Setup: ! ***** The Session Store, In Sessions\ Beside This Program
21600 let SESS_DIR$ = PWD$ & "sessions" & BACKSLASH$
21620 if NOT EXISTS(PWD$ & "sessions") then execute "mkdir " & PWD$ & "sessions" error Sess_Dir_Error
21640 randomize 
21660 let NEXT_SWEEP = 0 ! Sweep Before The First Request
21680 return 
21700 Sess_Dir_Error: print "Cannot create the session folder ";SESS_DIR$ !:
      print BELL; !:
      stop 
21720 ! 
21740 Establish_Session: ! ***** Every Browser Gets A Session Before It Logs In
21760 let REQ_SESSION$ = FNCOOKIE_SESSION$
21780 if (REQ_SESSION$ > NULL$) AND (NOT FNSESS_READ(REQ_SESSION$)) then let REQ_SESSION$ = NULL$
21800 if REQ_SESSION$ = NULL$ then goto New_Session
21820 if FNNOW - S_TOUCHED > ONE_MINUTE then let FNSESS_WRITE ! Keeps It From The Sweep
21840 return 
21860 New_Session: let REQ_SESSION$ = FNSESS_CREATE$
21880 if REQ_SESSION$ = NULL$ then return  ! Session Store Unavailable
21900 let SET_COOKIE$ = 'Set-Cookie: Session="' & REQ_SESSION$ & '"; Secure; HttpOnly; SameSite=strict; Max-Age=64800; Path=/'
21920 let COOKIE$(1:0) = 'Session="' & REQ_SESSION$ & '"; ' ! This Request Carries It Already
21940 if DEBUG then print #DEBUG: "New session ";REQ_SESSION$
21960 return 
21980 ! 
22000 Cookie_Into_Pagebuf: ! ***** A Page With Its Own Headers Gets The New Session Cookie Too
22020 if (UPRC$(PAGEBUF$(1:5)) <> "HTTP/") OR (POS(PAGEBUF$(1:3000),"Set-Cookie: Session=") > 0) then return 
22040 let POSN = POS(PAGEBUF$,CHR$(10))
22060 if POSN then let PAGEBUF$(POSN+1:0) = SET_COOKIE$ & CRLF$
22080 return 
22100 ! 
22120 Sweep_Sessions: ! ***** Free The Sessions Past Their Purge Time - Every Five Minutes
22140 let NEXT_SWEEP = FNNOW + FIVE_MINUTES
22160 for SWEEP_GROUP = 0 to 10**SESSION_DIGITS - 1
22180    let SWEEP_GROUP$ = NULL$
22200    if SESSION_DIGITS then let SWEEP_GROUP$ = LPAD$(STR$(SWEEP_GROUP),SESSION_DIGITS,"0")
22220    if EXISTS(SESS_DIR$ & "sess" & SWEEP_GROUP$ & ".dat") then gosub Sweep_Group
22240 next SWEEP_GROUP
22260 return 
22280 Sweep_Group: if NOT FNSESS_OPEN(SWEEP_GROUP$) then return 
22300 let SWEEP_COUNT = 0
22320 let SWEEP_NOW = FNNOW
22340 restore #SESS_FILE: ioerr Sweep_Free
22360 Sweep_Read: read #SESS_FILE,using Sess_Form,release: SESS_KEY$,S_STATUS$,S_USER$,S_CREATED,S_TOUCHED,S_EXPIRATION,S_INCREMENT,S_PENDING,S_RELOGIN_EXPIRE,S_IGNORE_EXPIRE,S_PURGE eof Sweep_Free ioerr Sweep_Free
22380 if (SESS_KEY$(1:1) = "#") OR (SWEEP_NOW <= S_PURGE) then goto Sweep_Read
22400 let SWEEP_COUNT += 1
22420 mat SESS_FREE$(SWEEP_COUNT)
22440 let SESS_FREE$(SWEEP_COUNT) = SESS_KEY$(1:10)
22460 goto Sweep_Read
22480 Sweep_Free: for SWEEP_SUB = 1 to SWEEP_COUNT ! Each One Again: Another Engine May Have Used It
22500    if FNSESS_READ(SESS_FREE$(SWEEP_SUB)) AND FNNOW > S_PURGE then let FNSESS_FREE
22520 next SWEEP_SUB
22540 if DEBUG AND SWEEP_COUNT then print #DEBUG: "Session sweep freed ";SWEEP_COUNT;" in group ";SWEEP_GROUP$
22560 return 
22580 ! 
22600 Cookie_Session: ! ***** The Session Number In The Cookie, If It Is Well Formed
22620 def FNCOOKIE_SESSION$*10(;POS5,POS6,WORK2$*20,CHAR_SUB,BAD)
22640    let POS5 = POS(COOKIE$,"Session=")
22660    if POS5 = 0 then goto End_Cookie_Session
22680    let POS6 = POS(COOKIE$,'"',POS5+9)
22700    if POS6 <> POS5+19 then goto End_Cookie_Session ! Not Ten Characters
22720    let WORK2$ = COOKIE$(POS5+9:POS6-1)
22740    for CHAR_SUB = 1 to 7
22760       if POS(SESSION_CHARS$,WORK2$(CHAR_SUB:CHAR_SUB)) = 0 then let BAD = 1
22780    next CHAR_SUB
22800    for CHAR_SUB = 8 to 10
22820       if POS("0123456789",WORK2$(CHAR_SUB:CHAR_SUB)) = 0 then let BAD = 1
22840    next CHAR_SUB
22860    if NOT BAD then let FNCOOKIE_SESSION$ = WORK2$
22880 End_Cookie_Session: fnend 
22900 ! 
22920 New_Session_Id: ! ***** Seven Letters Or Digits, Then Three Digits, From A Sha-1
22940 def FNNEW_SESSION_ID$*10(;DIGEST$*20,RESULT$*10,CHAR_SUB,CHAR_CODE)
22960    let SESSION_COUNTER += 1
22980    let DIGEST$ = ENCRYPT$(STR$(RND) & STR$(RND) & WSID$ & DATE$ & TIME$ & STR$(SESSION_COUNTER),"","SHA-1")
23000    for CHAR_SUB = 1 to 7
23020       let CHAR_CODE = MOD(ORD(DIGEST$(CHAR_SUB:CHAR_SUB)),62) + 1
23040       let RESULT$(INF:0) = SESSION_CHARS$(CHAR_CODE:CHAR_CODE)
23060    next CHAR_SUB
23080    for CHAR_SUB = 8 to 10
23100       let RESULT$(INF:0) = STR$(MOD(ORD(DIGEST$(CHAR_SUB:CHAR_SUB)),10))
23120    next CHAR_SUB
23140    let FNNEW_SESSION_ID$ = RESULT$
23160 fnend 
23180 ! 
23200 Sess_Group: ! ***** The File Group Of A Session: Its Low-Order Digits
23220 def FNSESS_GROUP$*3(SESS$*10)
23240    if SESSION_DIGITS then let FNSESS_GROUP$ = SESS$(11-SESSION_DIGITS:10)
23260 fnend 
23280 ! 
23300 Sess_Open: ! ***** Have The Group's Two Files Open On Sess_file And Sesx_file
23320 def FNSESS_OPEN(GROUP$*3;TRIES,NAME$*300)
23340    if FILE(SESS_FILE) <> -1 AND FILE(SESX_FILE) <> -1 AND GROUP$ = SESS_GROUP_OPEN$ then goto Sess_Is_Open
23360 Sess_Open_Try: if FILE(SESS_FILE) <> -1 then close #SESS_FILE: 
23380    if FILE(SESX_FILE) <> -1 then close #SESX_FILE: 
23400    let SESS_GROUP_OPEN$ = NULL$
23420    let TRIES += 1
23440    if TRIES > 5 then goto End_Sess_Open
23460    let NAME$ = SESS_DIR$ & "sess" & GROUP$
23480    open #SESS_FILE: "name=" & NAME$ & ".dat,kfname=" & NAME$ & ".idx,use,recl=127,kps=1,kln=10,shr,wait=5",internal,outin,keyed ioerr Sess_Open_Retry
23500    let NAME$ = SESS_DIR$ & "sesx" & GROUP$
23520    open #SESX_FILE: "name=" & NAME$ & ".dat,kfname=" & NAME$ & ".idx,use,recl=4095,kps=1,kln=13,shr,wait=5",internal,outin,keyed ioerr Sess_Open_Retry
23540    let SESS_GROUP_OPEN$ = GROUP$
23560 Sess_Is_Open: let FNSESS_OPEN = 1
23580    goto End_Sess_Open
23600 Sess_Open_Retry: let SLEEP(1) ! Another Engine May Be Creating The Files
23620    goto Sess_Open_Try
23640 End_Sess_Open: fnend 
23660 ! 
23680 Sess_Read: ! ***** Read A Session Into The S_ Fields - 1 If It Exists
23700 def FNSESS_READ(SESS$*10)
23720    if LEN(SESS$) <> 10 then goto End_Sess_Read
23740    if NOT FNSESS_OPEN(FNSESS_GROUP$(SESS$)) then goto End_Sess_Read
23760    read #SESS_FILE,using Sess_Form,key=SESS$,release: S_SESSION$,S_STATUS$,S_USER$,S_CREATED,S_TOUCHED,S_EXPIRATION,S_INCREMENT,S_PENDING,S_RELOGIN_EXPIRE,S_IGNORE_EXPIRE,S_PURGE,S_RELOGIN_POST nokey End_Sess_Read ioerr End_Sess_Read
23780    if S_STATUS$ <> "F" then let FNSESS_READ = 1
23800 End_Sess_Read: fnend 
23820 ! 
23840 Sess_Write: ! ***** Write The S_ Fields Back To The Session's Record
23860 def FNSESS_WRITE
23880    let S_TOUCHED = FNNOW
23900    let S_PURGE = FNSESS_PURGE_TIME
23920    if NOT FNSESS_OPEN(FNSESS_GROUP$(S_SESSION$)) then goto End_Sess_Write
23940    rewrite #SESS_FILE,using Sess_Form,key=S_SESSION$: S_SESSION$,S_STATUS$,S_USER$,S_CREATED,S_TOUCHED,S_EXPIRATION,S_INCREMENT,S_PENDING,S_RELOGIN_EXPIRE,S_IGNORE_EXPIRE,S_PURGE,S_RELOGIN_POST nokey End_Sess_Write ioerr End_Sess_Write
23960    let FNSESS_WRITE = 1
23980 End_Sess_Write: fnend 
24000 ! 
24020 Sess_Purge_Time: ! ***** When The Sweep May Free This Session
24040 def FNSESS_PURGE_TIME(;PURGE_AT)
24060    let PURGE_AT = S_TOUCHED + THIRTY_MINUTES ! Idle, Never Logged In
24080    if S_STATUS$ = "A" OR S_STATUS$ = "X" then let PURGE_AT = MAX(PURGE_AT,S_EXPIRATION + RELOGIN_MINUTES * ONE_MINUTE + TWO_HOURS)
24100    let FNSESS_PURGE_TIME = MAX(PURGE_AT,S_RELOGIN_EXPIRE,S_IGNORE_EXPIRE)
24120 fnend 
24140 ! 
24160 Sess_Pending: ! ***** 1 If The Session Was Issued A Challenge, Which Is Then Used Up
24180 def FNSESS_PENDING(SESS$*10)
24200    if FNSESS_READ(SESS$) AND S_PENDING > 0 then 
24220       let S_PENDING = 0
24240       let FNSESS_WRITE
24260       let FNSESS_PENDING = 1
24280    end if 
24300 fnend 
24320 ! 
24340 Sess_Create: ! ***** A New Session Number And Its Record - Null If The Store Is Unavailable
24360 def FNSESS_CREATE$*10(;TRIES,NEW_ID$*10)
24380 Sess_Create_Try: let TRIES += 1
24400    if TRIES > 5 then goto End_Sess_Create
24420    let NEW_ID$ = FNNEW_SESSION_ID$
24440    if NOT FNSESS_OPEN(FNSESS_GROUP$(NEW_ID$)) then goto End_Sess_Create
24460    read #SESS_FILE,using Sess_Form,key=NEW_ID$,release: SESS_KEY$ nokey Sess_Create_New ioerr End_Sess_Create
24480    goto Sess_Create_Try ! That Number Is Taken
24500 Sess_Create_New: if FNSESS_ADD(NEW_ID$) then let FNSESS_CREATE$ = NEW_ID$
24520 End_Sess_Create: fnend 
24540 ! 
24560 Sess_Add: ! ***** Add A Session Record - In A Free Record When There Is One
24580 def FNSESS_ADD(NEW_ID$*10;TRIES,FREE_KEY$*13)
24600    let S_SESSION$ = NEW_ID$
24620    let S_STATUS$ = "N"
24640    let S_USER$ = NULL$
24660    let S_CREATED = S_TOUCHED = FNNOW
24680    let S_EXPIRATION = S_INCREMENT = S_PENDING = S_RELOGIN_EXPIRE = S_IGNORE_EXPIRE = S_RELOGIN_POST = 0
24700    let S_PURGE = FNSESS_PURGE_TIME
24720    if NOT FNSESS_OPEN(FNSESS_GROUP$(NEW_ID$)) then goto End_Sess_Add
24740 Sess_Add_Free: let TRIES += 1
24760    if TRIES > 5 then goto Sess_Add_Append
24780    read #SESS_FILE,using Sess_Form,search>="#",release: FREE_KEY$ eof Sess_Add_Append nokey Sess_Add_Append ioerr Sess_Add_Append
24800    if FREE_KEY$(1:1) <> "#" then goto Sess_Add_Append
24820    rewrite #SESS_FILE,using Sess_Form,key=FREE_KEY$(1:10): S_SESSION$,S_STATUS$,S_USER$,S_CREATED,S_TOUCHED,S_EXPIRATION,S_INCREMENT,S_PENDING,S_RELOGIN_EXPIRE,S_IGNORE_EXPIRE,S_PURGE,S_RELOGIN_POST nokey Sess_Add_Free ioerr Sess_Add_Free
24840    let FNSESS_ADD = 1
24860    goto End_Sess_Add
24880 Sess_Add_Append: write #SESS_FILE,using Sess_Form: S_SESSION$,S_STATUS$,S_USER$,S_CREATED,S_TOUCHED,S_EXPIRATION,S_INCREMENT,S_PENDING,S_RELOGIN_EXPIRE,S_IGNORE_EXPIRE,S_PURGE,S_RELOGIN_POST ioerr End_Sess_Add
24900    let FNSESS_ADD = 1
24920 End_Sess_Add: fnend 
24940 ! 
24960 Sess_Free: ! ***** Turn The Session Just Read Into A Free Record, With Its Relogin Data
24980 def FNSESS_FREE(;FREE_KEY$*10)
25000    let FREE_KEY$ = "#" & LPAD$(STR$(REC(SESS_FILE)),9,"0")
25020    rewrite #SESS_FILE,using Sess_Form,key=S_SESSION$: FREE_KEY$,"F","",0,0,0,0,0,0,0,0,0 nokey End_Sess_Free ioerr End_Sess_Free
25040    let FNSESS_DROP_BLOB(S_SESSION$)
25060 End_Sess_Free: fnend 
25080 ! 
25100 Sess_Put_Blob: ! ***** Keep Sess_Blob$ (Relogin Url And Post) For A Session
25120 def FNSESS_PUT_BLOB(SESS$*10;SEQ,POSN)
25140    let FNSESS_DROP_BLOB(SESS$)
25160    if NOT FNSESS_OPEN(FNSESS_GROUP$(SESS$)) then goto End_Put_Blob
25180    let POSN = 1
25200 Put_Blob_Next: if (POSN > LEN(SESS_BLOB$)) OR (SEQ >= 999) then goto End_Put_Blob
25220    let SEQ += 1
25240    let SESS_CHUNK$ = SESS_BLOB$(POSN:POSN+4077)
25260    let FNSESX_STORE(SESS$ & LPAD$(STR$(SEQ),3,"0"),SESS_CHUNK$)
25280    let POSN += 4078
25300    goto Put_Blob_Next
25320 End_Put_Blob: fnend 
25340 ! 
25360 Sess_Get_Blob: ! ***** Sess_Blob$ As Kept For A Session, Or Null
25380 def FNSESS_GET_BLOB(SESS$*10;SEQ,SX_KEY$*13,PIECE_LEN)
25400    let SESS_BLOB$ = NULL$
25420    if NOT FNSESS_OPEN(FNSESS_GROUP$(SESS$)) then goto End_Get_Blob
25440 Get_Blob_Next: let SEQ += 1
25460    if SEQ > 999 then goto End_Get_Blob
25480    read #SESX_FILE,using Sesx_Form,key=SESS$ & LPAD$(STR$(SEQ),3,"0"),release: SX_KEY$,PIECE_LEN,SESS_CHUNK$ nokey End_Get_Blob ioerr End_Get_Blob
25500    let SESS_BLOB$(INF:0) = SESS_CHUNK$(1:PIECE_LEN)
25520    goto Get_Blob_Next
25540 End_Get_Blob: fnend 
25560 ! 
25580 Sess_Drop_Blob: ! ***** Free The Records Holding A Session's Sess_blob$
25600 def FNSESS_DROP_BLOB(SESS$*10;SEQ,SX_KEY$*13,FREE_KEY$*13)
25620    if NOT FNSESS_OPEN(FNSESS_GROUP$(SESS$)) then goto End_Drop_Blob
25640 Drop_Blob_Next: let SEQ += 1
25660    if SEQ > 999 then goto End_Drop_Blob
25680    let SX_KEY$ = SESS$ & LPAD$(STR$(SEQ),3,"0")
25700    read #SESX_FILE,using Sesx_Form,key=SX_KEY$,release: FREE_KEY$ nokey End_Drop_Blob ioerr End_Drop_Blob
25720    let FREE_KEY$ = "#" & LPAD$(STR$(REC(SESX_FILE)),12,"0")
25740    rewrite #SESX_FILE,using Sesx_Form,key=SX_KEY$: FREE_KEY$,0,"" nokey End_Drop_Blob ioerr End_Drop_Blob
25760    goto Drop_Blob_Next
25780 End_Drop_Blob: fnend 
25800 ! 
25820 Sesx_Store: ! ***** Store One Piece Of Relogin Data - In A Free Record When There Is One
25840 def FNSESX_STORE(SX_KEY$*13,&PIECE$;TRIES,FREE_KEY$*13)
25860 Sesx_Store_Free: let TRIES += 1
25880    if TRIES > 5 then goto Sesx_Store_Append
25900    read #SESX_FILE,using Sesx_Form,search>="#",release: FREE_KEY$ eof Sesx_Store_Append nokey Sesx_Store_Append ioerr Sesx_Store_Append
25920    if FREE_KEY$(1:1) <> "#" then goto Sesx_Store_Append
25940    rewrite #SESX_FILE,using Sesx_Form,key=FREE_KEY$: SX_KEY$,LEN(PIECE$),PIECE$ nokey Sesx_Store_Free ioerr Sesx_Store_Free
25960    goto End_Sesx_Store
25980 Sesx_Store_Append: write #SESX_FILE,using Sesx_Form: SX_KEY$,LEN(PIECE$),PIECE$ ioerr End_Sesx_Store
26000 End_Sesx_Store: fnend 
