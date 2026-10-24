01000 ! Rep Login
01020 ! 
01040 ! ***** Client Authentication
01060 ! 
01080 ! ***** Last Modified Xx/Xx/Xx
01100 ! ***** Prev Modified Xx/Xx/Xx
01120 ! 
01140 ! 
01160    dim AUTH$*200,NAME$*100,PASSWORD$*200,STORED_PASSWORD$*200
01180    def library FNLOGIN(MAT KEYS$,MAT VALUES$)
01200 ! Setup Linkage Back To The Web Server
01220       library : FNAUTHENTICATE, FNSEND_PAGE, FNAUTHORIZE
01240       let SUB1 = SRCH(KEYS$,"^User_Name") !:
            if SUB1 < 1 then ! If Not Already Authenticating
01260          if SRCH(KEYS$,"RELOGIN") > 0 then !:
                  let FNAUTHENTICATE("Re-Login to Continue the Session","challenge.relogin.html") !:
               else !:
                  let FNAUTHENTICATE("Login to Activity Log","challenge.bootstrap.html")
01280       else 
01300 ! 
01320 ! Here We Want To Encrypt The Password For Comparison To Storage
01340          let PASSWORD$ = ENCRYPT$(VALUES$(SUB1+1),"","MD5")
01360 ! Lookup The Stored Password Value Associated With Name In Values$(Sub1)
01380 ! 
01400          if 1 OR PASSWORD$ == STORED_PASSWORD$ then 
01420 ! .         1 hour = .041667      1 minute = .00069445
01440 ! .         Provide expiration date and time as "days" value.
01460 ! .         Or specify timeout interval as a negative days value.
01480             let FNAUTHORIZE(-5*.00069445) ! 5 Minute Timeout
01500             if SRCH(KEYS$,"RELOGIN") < 1 then !:
                     let FNSEND_PAGE("home.html") ! Initial Page
01510 ! .         If RELOGIN present then web server will resume the session.
01520          end if 
01540       end if 
01560    fnend 
