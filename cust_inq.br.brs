00010 ! Rep Cust_Inq
00020 ! 
00030 !  Created 5/01/2018
00040 ! 
00050 !  Support A Customer Inquiry Operation
00060 ! 
00070    dim CUSTOMER$(1)*80,CUSTOMER(1)
00080    dim FORM$(1)*300
00082    dim SEARCH_KEY$*30, WORK$*2000
00084    dim ROW_ARGS$(5)*20,ROW_VALUES$(5)*30 ! Storage For One Row
00090 ! 
00120    def library FNDISPLAY_CUST(MAT KEYS$,MAT VALUES$)
00130 ! .! Search for matching customer data
00140 ! .! print one row for each matching record
00150 ! 
00160       let FNLIBRARYLINKAGE
00180 ! 
00200       if CUSTOMERFILE=0 then !:
               let CUSTOMERFILE=FNOPEN("customer",MAT CUSTOMER$,MAT CUSTOMER,MAT FORM$,1)
00210       if (CUST_ID_SUB := SRCH(KEYS$,"^cust_ID")) > 0 AND (CUST_DEST_SUB := SRCH(KEYS$,"^cust_dest")) > 0 then 
00220          let FNSEND_PAGE("customer_list1.htm",NULL$,NULL$,0,1) !:
               ! Send Http Header & Html Header - Suppress Length
00230          let SEARCH_KEY$ = RTRM$(RPAD$(VALUES$(CUST_ID_SUB),8) & "ST" & VALUES$(CUST_DEST_SUB)) !:
               if VALUES$(CUST_DEST_SUB) = NULL$ then !:
                  let SEARCH_KEY$ = RTRM$(VALUES$(CUST_ID_SUB))
00240          restore #CUSTOMERFILE, search>=SEARCH_KEY$: nokey Donereadingcustomer
00250 ! 
00260 Readloop: ! Return Up Here For The Read Loop
00270          read #CUSTOMERFILE, using FORM$(CUSTOMERFILE) : MAT CUSTOMER$,MAT CUSTOMER eof Donereadingcustomer
00280          let WORK$ = CUSTOMER$(RCU_CUSTOMER) & "ST" & CUSTOMER$(RCU_DESTINATION)
00290          if WORK$(1:LEN(SEARCH_KEY$)) <> SEARCH_KEY$ then !:
                  goto Donereadingcustomer
00300 ! 
00310          let ROW_VALUES$(1) = CUSTOMER$(RCU_CUSTOMER) !:
               let ROW_VALUES$(2) = CUSTOMER$(RCU_DESTINATION) !:
               let ROW_VALUES$(3) = CUSTOMER$(RCU_CUST_NAME) !:
               let ROW_VALUES$(4) = CUSTOMER$(RCU_CONTACT) !:
               let ROW_VALUES$(5) = CUSTOMER$(RCU_CUST_PHONE)
00320          let FNSEND_PAGE("customer_list2.htm",MAT ROW_ARGS$,MAT ROW_VALUES$,1) !:
               ! Send One Row - Suppress Http Header
00330          goto Readloop
00340       end if 
00350 ! 
00360 Donereadingcustomer: ! ***** Done Reading Customer File
00370       let FNSEND_PAGE("customer_list3.htm",NULL$,NULL$,1) !:
            ! Send Http Footer - Suppress Http Header
00570    fnend 
00840 ! 
00850    dim LINKAGEESTABLISHED
00860    def FNLIBRARYLINKAGE
00870       if ~LINKAGEESTABLISHED then 
00880          library "fileio" : FNOPENFILE, FNCLOSEFILE
00890          library : FNSEND_PAGE
00900 ! 
00910          let LINKAGEESTABLISHED=1
00915          read MAT ROW_ARGS$
00917          data ^cust_id,^dest,^name,^contact,^phone
00920       end if 
00930    fnend 
00940 ! 
01070 ! 
01080 Open: ! ***** Function To Call Library Openfile And Proc Subs
01090    def FNOPEN(FILENAME$*255, MAT F$, MAT F, MAT FORM$; INPUTONLY, KEYNUM, DONT_SORT_SUBS, PATH$*255, MAT DESCR$, MAT FIELD_WIDTHS,SUPRESS_PROMPT,IGNORE_ERRORS,SUPPRESS_LOG,___,INDEX)
01100       dim _FILEIOSUBS$(1)*800, _LOADEDSUBS$(1)*80
01110       let FNOPEN=FNOPENFILE(FILENAME$, MAT F$, MAT F, MAT FORM$, INPUTONLY, KEYNUM, DONT_SORT_SUBS, PATH$, MAT DESCR$, MAT FIELD_WIDTHS, MAT _FILEIOSUBS$, SUPRESS_PROMPT,IGNORE_ERRORS,PROGRAM$,SUPPRESS_LOG)
01120       if SRCH(_LOADEDSUBS$,UPRC$(FILENAME$))<=0 then : mat _LOADEDSUBS$(UDIM(_LOADEDSUBS$)+1) : let _LOADEDSUBS$(UDIM(_LOADEDSUBS$))=UPRC$(FILENAME$) : for INDEX=1 to UDIM(MAT _FILEIOSUBS$) : execute (_FILEIOSUBS$(INDEX)) : next INDEX
01130    fnend 
