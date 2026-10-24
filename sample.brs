00010 ! Sample.Br ! Copyright 2013 By Sage Ax
00020 ! 
00030 !  Created 4/26/2013
00040 ! 
00050 !  This Is A Sample Program Demonstrating How To Use The Webform Library
00060 ! 
00070    dim COMMENTS$(1)*255,COMMENTS(1)
00080    dim FORM$(1)*255
00090 ! 
00100    dim C$*255
00110 ! 
00120    def library FNSAVECOMMENT(MAT KEYS$,MAT VALUES$)
00130 ! .! This function needs to save the comment in a data file and return
00140 ! .!  a page thanking the user for their input
00150 ! 
00160       let FNLIBRARYLINKAGE
00170       let FNREQUESTSUBS(MAT KEYS$)
00180 ! 
00190 ! .! Save the data in the file
00200       let COMMENTSFILE=FNOPEN("comments",MAT COMMENTS$,MAT COMMENTS,MAT FORM$)
00210       let COMMENTS$(C_NAME)=VALUES$(R_FIELD_NAME)
00220       let COMMENTS$(C_COMMENT)=VALUES$(R_FIELD_COMMENTS)
00230       let COMMENTS(C_DATE)=DAYS(DATE$)
00240       let COMMENTS$(C_TIME)=TIME$
00250       write #COMMENTSFILE, using FORM$(COMMENTSFILE) : MAT COMMENTS$,MAT COMMENTS
00260       let FNCLOSEFILE(COMMENTSFILE,"comments")
00270       library : FNSEND_PAGE
00280 ! 
00284       if XKEYS$(1) = NULL$ then read MAT XKEYS$ ! ,Mat Xvalues$
00290       let FNSEND_PAGE("thank_you.html",MAT XKEYS$,MAT XVALUES$)
00300 ! 
00310    fnend 
00320 ! 
00330    dim CSS$*10000
00335    dim XKEYS$(2),XVALUES$(2)*50
00337    data ^now_testing,^tag2,value 1,now going to the store
00340 ! 
00350    def library FNADDCOMMENT(MAT KEYS$,MAT VALUES$)
00360 ! .! Here we need to return the HTML to show a form for Add Comments and it needs a button to Save the value that calls fnSaveComment
00370       let FNLIBRARYLINKAGE
00380 ! 
00390 ! .! The heading and the top of the page
00400       let CSS$="body {background:url('bg.jpg') no-repeat;}"
00410 ! 
00420       let FNHEADING("Add Comment",CSS$)
00430       let FNHTML("<h1>Suggestion Box</h1>")
00440       let FNHTML("<p>Please enter your suggestions in the suggestion box</p>")
00450 ! 
00460 ! .! The form
00470       let FNFORMSTART("fnSaveComment","post")
00480       let FNFIELD("Name: ","field_name")
00490       let FNFIELD("Comments: ","field_comments","",6,40)
00500       let FNSUBMIT
00510       let FNFORMEND
00520 ! 
00530 ! .! footer closes out the html
00540       let FNFOOTER
00550 ! 
00560       let FNSEND
00570    fnend 
00580    def library FNVIEWCOMMENTS(MAT KEYS$,MAT VALUES$)
00590 ! .! Here we need to return the HTML to show a list of all the saved comments in the file
00600       let FNLIBRARYLINKAGE
00610 ! 
00620       let CSS$="body {background-color: #A5E8D2;}"
00630 ! 
00640       let FNHEADING("Comments and Suggestions",CSS$)
00650       let FNHTML("<h1>Suggestion Box</h1>")
00660 ! 
00670       let FNHTML("<p>Here's a list of all of the comments we have received so far.</b>")
00680       let FNHTML("<ul>")
00690 ! 
00700       let COMMENTSFILE=FNOPEN("comments",MAT COMMENTS$,MAT COMMENTS,MAT FORM$,1)
00710 ! 
00720 Readloop: ! Return Up Here For The Read Loop
00730       read #COMMENTSFILE, using FORM$(COMMENTSFILE) : MAT COMMENTS$,MAT COMMENTS eof Donereadingcomments
00740       let FNHTML("<li>"&COMMENTS$(C_NAME)&" wrote <em>"""&COMMENTS$(C_COMMENT)&"""</em> - <em><strong>"&DATE$(COMMENTS(C_DATE),"Day, Month DD, CCYY")&" at "&TIME$&"</em></strong></li>")
00750       goto Readloop
00760 ! 
00770 Donereadingcomments: ! We're done reading here
00780       let FNHTML("</ul>")
00790       let FNFOOTER
00800 ! 
00810       let FNSEND
00820       close #COMMENTSFILE: 
00830    fnend 
00840 ! 
00850    dim LINKAGEESTABLISHED
00860    def FNLIBRARYLINKAGE
00870       if ~LINKAGEESTABLISHED then 
00880          library "fileio" : FNOPENFILE, FNCLOSEFILE
00890          library "webform" : FNHEADING,FNFORMSTART,FNFIELD,FNFORMEND,FNFOOTER,FNSEND,FNHTML,FNSUBMIT,FNINDEX
00900 ! 
00910          let LINKAGEESTABLISHED=1
00920       end if 
00930    fnend 
00940 ! 
00950 ! 
00960 ! #Autonumber# 99000,10
00970    dim REQUESTSUBSCRIPTS$(1)*800
00980 Requestsubs: ! This Function Sets The Subscripts For The Request String
00990    def FNREQUESTSUBS(MAT SUBS$;___,INDEX)
01000       library "webform" : FNBUILDSUBSLIST
01010       let FNBUILDSUBSLIST(MAT SUBS$,MAT REQUESTSUBSCRIPTS$,"R_")
01020       for INDEX=1 to UDIM(MAT REQUESTSUBSCRIPTS$)
01030          execute REQUESTSUBSCRIPTS$(INDEX)
01040       next INDEX
01050    fnend 
01060 ! 
01070 ! 
01080 Open: ! ***** Function To Call Library Openfile And Proc Subs
01090    def FNOPEN(FILENAME$*255, MAT F$, MAT F, MAT FORM$; INPUTONLY, KEYNUM, DONT_SORT_SUBS, PATH$*255, MAT DESCR$, MAT FIELD_WIDTHS,SUPRESS_PROMPT,IGNORE_ERRORS,SUPPRESS_LOG,___,INDEX)
01100       dim _FILEIOSUBS$(1)*800, _LOADEDSUBS$(1)*80
01110       let FNOPEN=FNOPENFILE(FILENAME$, MAT F$, MAT F, MAT FORM$, INPUTONLY, KEYNUM, DONT_SORT_SUBS, PATH$, MAT DESCR$, MAT FIELD_WIDTHS, MAT _FILEIOSUBS$, SUPRESS_PROMPT,IGNORE_ERRORS,PROGRAM$,SUPPRESS_LOG)
01120       if SRCH(_LOADEDSUBS$,UPRC$(FILENAME$))<=0 then : mat _LOADEDSUBS$(UDIM(_LOADEDSUBS$)+1) : let _LOADEDSUBS$(UDIM(_LOADEDSUBS$))=UPRC$(FILENAME$) : for INDEX=1 to UDIM(MAT _FILEIOSUBS$) : execute (_FILEIOSUBS$(INDEX)) : next INDEX
01130    fnend 
