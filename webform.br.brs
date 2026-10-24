00001 ! Webform.Br ! Copyright 2013 By Sage Ax
00002 ! 
00003 !  Created 4/26/2013
00004 ! 
00005 !  This Is The Webform Library, A Collection Of Tools To Use With The Br
00006 !  Web Server To Aid In The Creation Of Html And Web Forms That Interact
00007 !  With A Br Back End.
00008 ! 
00009 !  Library "webform" : Fnheading,Fnformstart,Fnfield,Fnformend,Fnfooter,Fnsend,Fnhtml,Fnsubmit
00010 ! 
00011    def library FNHEADING(;TITLE$*255,&CSS$)
00012       let FNLIBRARYLINKAGE
00013 ! 
00014       let FNHTML("<!DOCTYPE html>")
00015       let FNHTML("<html>")
00016       let FNHTML("<head>")
00017       if LEN(TITLE$) then let FNHTML("<title>"&TITLE$&"</title>")
00018       if LEN(CSS$) then let FNHTML("<style>"&CSS$&"</style>")
00019       let FNHTML("</head>")
00020       let FNHTML("<body>")
00021    fnend 
00022 ! 
00023    def library FNFORMSTART(FUNCTION$*64;METHOD$,LIBRARY$*64,___,ACTION$*128)
00024       let FNLIBRARYLINKAGE
00025 ! 
00026       let ACTION$="?"
00027       if LIBRARY$<>"" then let ACTION$=ACTION$&"BR_LIB="&LIBRARY$&"&"
00028       let ACTION$=ACTION$&"BR_FUNC="&FUNCTION$
00029 ! 
00030       if METHOD$="" then let METHOD$="get"
00031 ! 
00032       let FNHTML("<form method="""&METHOD$&""" action="""&ACTION$&""">")
00033 ! 
00034       if LWRC$(METHOD$)="get" then ! If Its Get Then We Send The Target This Way
00035          if LIBRARY$<>"" then 
00036             let FNHTML("<input type=""hidden"" name=""BR_LIB"" value="""&LIBRARY$&""">")
00037          end if 
00038          let FNHTML("<input type=""hidden"" name=""BR_FUNC"" value="""&FUNCTION$&""">")
00039       end if 
00040 ! 
00041    fnend 
00042 ! 
00043    def library FNFIELD(CAPTION$*80,FIELD$*64;TYPE$,ROWS,COLS,___,ROWS$,COLS$,CONTROL$,ENDTAG$)
00044       let FNLIBRARYLINKAGE
00045       if TYPE$="" then let TYPE$="text"
00046       if ROWS>1 then 
00047          let CONTROL$="textarea"
00048          let ENDTAG$="</textarea>"
00049          let ROWS$=" rows="&STR$(ROWS)&" "
00050       else 
00051          let CONTROL$="input"
00052       end if 
00053       if COLS then 
00054          let COLS$=" cols="&STR$(COLS)&" "
00055       end if 
00056 ! 
00057       let FNHTML(CAPTION$&" <"&CONTROL$&ROWS$&COLS$&" type="""&TYPE$&""" name="""&TRIM$(FIELD$)&""">"&ENDTAG$&"<br>")
00058 ! 
00059 ! .! First name: <input type="text" name="firstname"><br>
00060    fnend 
00061 ! 
00062    def library FNSUBMIT
00063       let FNLIBRARYLINKAGE
00064 ! 
00065       let FNHTML("<input type=""submit"" value=""Submit"">")
00066    fnend 
00067 ! 
00068    def library FNFORMEND
00069       let FNLIBRARYLINKAGE
00070 ! 
00071       let FNHTML("</form>")
00072    fnend 
00073 ! 
00074    def library FNFOOTER
00075       let FNLIBRARYLINKAGE
00076 ! 
00077       let FNHTML("</body>")
00078       let FNHTML("</html>")
00079    fnend 
00080 ! 
00081    dim DOCUMENT$*100000
00082    dim LASTDOCUMENT$*100000
00083    def library FNHTML(HTML$*10000)
00084       let DOCUMENT$=DOCUMENT$&HTML$
00085    fnend 
00086 ! 
00087    def library FNSEND
00088       let FNLIBRARYLINKAGE
00089       let FNPUT_JSON("HTML_Document",DOCUMENT$)
00090       let FNSEND_OBJECT("HTML_Document")
00091       let LASTDOCUMENT$=DOCUMENT$
00092       let DOCUMENT$=""
00093    fnend 
00094 ! 
00095    def library FNINDEX(MAT KEYS$,KEY$)
00096       let FNINDEX=SRCH(MAT KEYS$,KEY$)
00097    fnend 
00098 ! 
00099    def library FNBUILDSUBSLIST(MAT SUBS$,MAT TEMPSETSUBSCRIPTS$;PREFIX$,INDEX)
00100       mat TEMPSETSUBSCRIPTS$(0)
00101       for INDEX=1 to UDIM(MAT SUBS$)
00102          if LEN(TRIM$(SUBS$(INDEX))) then 
00103             let FNADDTOSUBSARRAY("let "&PREFIX$&TRIM$(SUBS$(INDEX))(1:30-LEN(PREFIX$))&"="&STR$(INDEX),MAT TEMPSETSUBSCRIPTS$)
00104          end if 
00105       next INDEX
00106    fnend 
00107 ! 
00108    dim ADDTOSUBSCOUNT
00109 Addtosubsarray: ! Adds Subscripts To A Processing Effecient Array
00110    def FNADDTOSUBSARRAY(STRING$*50,MAT SUBS$;___,INDEX)
00111 ! 
00112       let ADDTOSUBSCOUNT+=1
00113       let INDEX=UDIM(MAT SUBS$)
00114 ! 
00115       if INDEX=0 OR ADDTOSUBSCOUNT>31 then 
00116          gosub Addnewone
00117       else 
00118          let SUBS$(INDEX)=SUBS$(INDEX)&": "&STRING$ soflow Erroraddnewone
00119       end if 
00120    fnend 
00121 ! 
00122 Erroraddnewone: gosub Addnewone : continue 
00123 Addnewone: ! Add A New Sub Line
00124    let ADDTOSUBSCOUNT=1
00125    let INDEX+=1
00126    mat SUBS$(INDEX)
00127    let SUBS$(INDEX)="*"&STRING$
00128    return 
00129 ! 
00130 ! 
00131    dim LINKAGEESTABLISHED
00132    def FNLIBRARYLINKAGE
00133       if ~LINKAGEESTABLISHED then 
00134          library : FNHTML
00135          library : FNPUT_JSON, FNSEND_OBJECT
00136          let LINKAGEESTABLISHED=1
00137       end if 
00138    fnend 
