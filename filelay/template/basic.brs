00001 ! Fileio Library Basic Addon Template By Gabriel Bakker
00002 ! Copyright 2012 Gabriel Bakker, Sage Ax
00003 ! Created: 2/6/2012
00004 ! 
00005 ! Use This Template Library As An Example Of How
00006 ! To Construct Other Template Libraries.
00007 ! 
00008 ! Every Template Must Have Two Library Functions,
00009 !  Fntemplatelist And Fnruntemplate.
00010 ! 
00011 !  Fntemplatelist(Mat Templatedesc$)
00012 !  Takes An Array Of Descriptions And Returns A List Of
00013 !  The Available Functions In This Template Library.
00014 ! 
00015 !  Fnruntemplate(Template,Filelay$)
00016 !  This Function Takes The Given Template Index And
00017 !  File Layout And Calls Your Template Function.
00018 ! 
00019 !  A Template Function Should Read The File Layout
00020 !  And Then Build A String Of Code And Return It
00021 !  In The Clip Board So That A Programmer Can
00022 !  Paste It Into His Editor Of Choice Later.
00023 ! 
00024 ! 
00025 ! To Add To This Template Library, Add Your
00026 !  Template Description And Template Label
00027 !  To The List And Gosub Statement At The
00028 !  Bottom Of This Library.
00029 ! 
00030 !  Then Write Some Template Code At That Label
00031 !  In A Subroutine That Sets The Code To Return
00032 !  In The "ReturnCode$" Variable, Or Use The
00033 !  Fnreturncode Function.
00034 ! 
00035    dim KEYS$(1)*255,KEYDESCRIPTION$(1)*255,SSUBS$(1),NSUBS$(1),SSPEC$(1),NSPEC$(1)
00036    dim SDESCRIPTION$(1)*255,NDESCRIPTION$(1)*255,SPOS(1),NPOS(1)
00037    dim FILENAME$*255,PREFIX$
00038    dim LONGESTELEMENT
00039 ! 
00040    dim NUMBERLIST$
00041    dim KEYFIELDS$(1)
00042    dim KEYGIVEN
00043    dim KEYLENGTH, LENGTH, SUB
00044 ! 
00045    dim CODELINE$*400
00046 ! 
00047 ! 
00048 ! *******************************************
00049 !                Self Register
00050 ! *******************************************
00051 Selfregister: ! Template That Creates Code To Self Register
00052 ! This Layout If Its Not Found In The Layout Folder Already
00053 ! 
00054 ! .! Dim at next largest multiple of 255
00055    let LONGESTELEMENT=(INT((LONGESTELEMENT-1)/255)+1)*255
00056 ! 
00057 ! .! Get it from FileIO program
00058 ! 
00059 ! 
00060    return 
00061 ! 
00062 ! *******************************************
00063 !                Conversion
00064 ! *******************************************
00065 Conversion: ! Creates Conversion Functions That Can Be Used
00066 ! To Go Between Fileio Vars And Oldskool Vars To Aid In
00067 ! Implementing Fileio In Older Programs.
00068 ! 
00069 ! 
00070 ! .! Dim at next largest multiple of 255
00071    let LONGESTELEMENT=(INT((LONGESTELEMENT-1)/255)+1)*255
00072 ! 
00073 ! 
00074 ! .! Get code from Active Program
00075 ! 
00076 ! 
00077 ! 
00078    return 
00079 ! 
00080 ! *******************************************
00081 !                Read Loop
00082 ! *******************************************
00083 Readloop: ! Template For A Standard Read Loop And Dim Statement
00084 ! 
00085 ! .! Dim at next largest multiple of 255
00086    let LONGESTELEMENT=(INT((LONGESTELEMENT-1)/255)+1)*255
00087 ! 
00088    let FNRETURNCODE(' ')
00089    let FNRETURNCODE(' ! FileIO Dimensions')
00090    let FNRETURNCODE(' dim Form$(1)*255')
00091    let FNRETURNCODE(' dim '&FILELAY$&', '&FILELAY$&'$(1)*'&STR$(LONGESTELEMENT)&','&FILELAY$&'(1)')
00092    let FNRETURNCODE(' ')
00093    let FNRETURNCODE(' ! Open the file')
00094    let FNRETURNCODE(' let '&FILELAY$&'=Fnopen("'&FILELAY$&'",Mat '&FILELAY$&'$,Mat '&FILELAY$&',Mat Form$,1)')
00095    let FNRETURNCODE(' ')
00096    let FNRETURNCODE(' ! Position to start of file')
00097    let FNRETURNCODE(' restore #'&FILELAY$&': error IGNORE')
00098    let FNRETURNCODE(' ')
00099    let FNRETURNCODE(' do until File('&FILELAY$&')')
00100    let FNRETURNCODE('    read #'&FILELAY$&', using Form$('&FILELAY$&') : Mat '&FILELAY$&'$,Mat '&FILELAY$&' eof IGNORE')
00101    let FNRETURNCODE('    if File('&FILELAY$&')=0 then')
00102    let FNRETURNCODE('       ! Found Something')
00103    let FNRETURNCODE(' ')
00104    let FNRETURNCODE(' ')
00105    let FNRETURNCODE(' ')
00106    let FNRETURNCODE('    end if')
00107    let FNRETURNCODE(' loop')
00108    let FNRETURNCODE(' ')
00109    let FNRETURNCODE(' ! Close DataFile')
00110    let FNRETURNCODE(' close #'&FILELAY$&':')
00111    let FNRETURNCODE(' ')
00112 ! 
00113    return 
00114 ! 
00115 ! *******************************************
00116 !                Read Loop Key
00117 ! *******************************************
00118 Readloopkey: ! Template For A Keyed Read Loop And Dim Statement
00119 ! 
00120 ! .! Dim at next largest multiple of 256
00121    let LONGESTELEMENT=(INT((LONGESTELEMENT-1)/256)+1)*256
00122    mat NUMBERLIST$(UDIM(MAT KEYDESCRIPTION$))
00123    for INDEX=1 to UDIM(MAT NUMBERLIST$)
00124       let NUMBERLIST$(INDEX)=STR$(INDEX)
00125    next INDEX
00126 ! 
00127    let KEYGIVEN=0
00128    let KEYGIVEN=VAL(FNASKCOMBO$(MAT NUMBERLIST$,"Select Key")) conv Ignore
00129    if KEYGIVEN AND KEYGIVEN<=UDIM(MAT KEYDESCRIPTION$) then 
00130       let STR2MAT(LWRC$(KEYDESCRIPTION$(KEYGIVEN)),MAT KEYFIELDS$,"/")
00131 ! 
00132       let FNRETURNCODE(' ')
00133       let FNRETURNCODE(' ! FileIO Dimensions')
00134       let FNRETURNCODE(' dim Form$(1)*255')
00135       let FNRETURNCODE(' dim '&FILELAY$&', '&FILELAY$&'$(1)*'&STR$(LONGESTELEMENT)&','&FILELAY$&'(1)')
00136       let FNRETURNCODE(' ')
00137       let FNRETURNCODE(' ! Variables Used')
00138       let FNRETURNCODE(' dim KeyNumber')
00139 ! 
00140       let CODELINE$=" dim "
00141       let KEYLENGTH=0
00142 ! 
00143       for INDEX=1 to UDIM(MAT KEYFIELDS$)
00144          let SUB=SRCH(MAT SSUBS$,TRIM$(KEYFIELDS$(INDEX)))
00145          if SUB>0 then 
00146             let LENGTH=FNLENGTH(SSPEC$(SUB))
00147             let CODELINE$=CODELINE$&TRIM$(KEYFIELDS$(INDEX))&"$*"&STR$(LENGTH)&", "
00148             let KEYLENGTH+=LENGTH
00149          else 
00150             let SUB=SRCH(MAT NSUBS$,TRIM$(KEYFIELDS$(INDEX)))
00151             if SUB>0 then 
00152                let LENGTH=FNLENGTH(NSPEC$(SUB))
00153                let CODELINE$=CODELINE$&TRIM$(KEYFIELDS$(INDEX))&", "
00154                let KEYLENGTH+=LENGTH
00155             end if 
00156          end if 
00157       next INDEX
00158       if LEN(CODELINE$)>6 then 
00159          let CODELINE$=CODELINE$(1:LEN(CODELINE$)-2)
00160          let FNRETURNCODE(CODELINE$)
00161       end if 
00162 ! 
00163       let FNRETURNCODE(' dim '&FILELAY$&'Key$*'&STR$(KEYLENGTH)&', This'&FILELAY$&'$*'&STR$(KEYLENGTH))
00164       let FNRETURNCODE(' ')
00165       let FNRETURNCODE(' ! Initialize Key Information Here')
00166       let FNRETURNCODE(' let KeyNumber='&STR$(KEYGIVEN))
00167       for INDEX=1 to UDIM(MAT KEYFIELDS$)
00168          let SUB=SRCH(MAT SSUBS$,TRIM$(KEYFIELDS$(INDEX)))
00169          if SUB>0 then 
00170             let FNRETURNCODE(' let '&KEYFIELDS$(INDEX)&'$=')
00171          else 
00172             let FNRETURNCODE(' let '&KEYFIELDS$(INDEX)&'=')
00173          end if 
00174       next INDEX
00175       let FNRETURNCODE(' ')
00176       let FNRETURNCODE(' ! Open the file')
00177       let FNRETURNCODE(' let '&FILELAY$&'=Fnopen("'&FILELAY$&'",Mat '&FILELAY$&'$,Mat '&FILELAY$&',Mat Form$,1,KeyNumber)')
00178       let FNRETURNCODE(' ')
00179       let FNRETURNCODE(' ! Calculate the Key')
00180 ! 
00181       for INDEX=1 to UDIM(MAT KEYFIELDS$)
00182          let SUB=SRCH(MAT SSUBS$,TRIM$(KEYFIELDS$(INDEX)))
00183          if SUB>0 then 
00184             let FNRETURNCODE(' let '&FILELAY$&'$('&PREFIX$&KEYFIELDS$(INDEX)&')='&KEYFIELDS$(INDEX)&'$')
00185          else 
00186             let FNRETURNCODE(' let '&FILELAY$&'('&PREFIX$&KEYFIELDS$(INDEX)&')='&KEYFIELDS$(INDEX))
00187          end if 
00188       next INDEX
00189 ! 
00190       let FNRETURNCODE(' let '&FILELAY$&'Key$=fnBuildKey$("'&FILELAY$&'",mat '&FILELAY$&'$,mat '&FILELAY$&',KeyNumber)')
00191       let FNRETURNCODE(' ')
00192       let FNRETURNCODE(' ! Position by key')
00193       let FNRETURNCODE(' restore #'&FILELAY$&', search>=rtrm$('&FILELAY$&'Key$): nokey IGNORE')
00194       let FNRETURNCODE(' ')
00195       let FNRETURNCODE(' do until File('&FILELAY$&')')
00196       let FNRETURNCODE('    read #'&FILELAY$&', using Form$('&FILELAY$&') : Mat '&FILELAY$&'$,Mat '&FILELAY$&' eof IGNORE')
00197       let FNRETURNCODE('    let This'&FILELAY$&'$=fnBuildKey$("'&FILELAY$&'",mat '&FILELAY$&'$,mat '&FILELAY$&',KeyNumber)')
00198       let FNRETURNCODE('    if File('&FILELAY$&')=0 And rtrm$('&FILELAY$&'Key$)=This'&FILELAY$&'$(1:len(rtrm$('&FILELAY$&'Key$))) then')
00199       let FNRETURNCODE('       ! Found Something')
00200       let FNRETURNCODE(' ')
00201       let FNRETURNCODE(' ')
00202       let FNRETURNCODE(' ')
00203       let FNRETURNCODE('    end if')
00204       let FNRETURNCODE(' loop while rtrm$('&FILELAY$&'Key$)=This'&FILELAY$&'$(1:len(rtrm$('&FILELAY$&'Key$)))')
00205       let FNRETURNCODE(' ')
00206       let FNRETURNCODE(' ! Close DataFile')
00207       let FNRETURNCODE(' close #'&FILELAY$&':')
00208       let FNRETURNCODE(' ')
00209    end if 
00210    return 
00211 ! 
00212 ! *******************************************
00213 !              Read Loop Only
00214 ! *******************************************
00215 Readlooponly: ! Template For A Standard Read Loop And Dim Statement
00216 ! 
00217 ! .! Dim at next largest multiple of 255
00218    let LONGESTELEMENT=(INT((LONGESTELEMENT-1)/255)+1)*255
00219 ! 
00220    let FNRETURNCODE(' ')
00221    let FNRETURNCODE(' ! Position to start of file')
00222    let FNRETURNCODE(' restore #'&FILELAY$&': error IGNORE')
00223    let FNRETURNCODE(' ')
00224    let FNRETURNCODE(' do until File('&FILELAY$&')')
00225    let FNRETURNCODE('    read #'&FILELAY$&', using Form$('&FILELAY$&') : Mat '&FILELAY$&'$,Mat '&FILELAY$&' eof IGNORE')
00226    let FNRETURNCODE('    if File('&FILELAY$&')=0 then')
00227    let FNRETURNCODE('       ! Found Something')
00228    let FNRETURNCODE(' ')
00229    let FNRETURNCODE(' ')
00230    let FNRETURNCODE(' ')
00231    let FNRETURNCODE('    end if')
00232    let FNRETURNCODE(' loop')
00233    let FNRETURNCODE(' ')
00234 ! 
00235    return 
00236 ! 
00237 ! *******************************************
00238 !             Read Loop Only Key
00239 ! *******************************************
00240 Readloopkeyonly: ! Template For A Keyed Read Loop And Dim Statement
00241 ! 
00242 ! .! Dim at next largest multiple of 256
00243    mat NUMBERLIST$(UDIM(MAT KEYDESCRIPTION$))
00244    for INDEX=1 to UDIM(MAT NUMBERLIST$)
00245       let NUMBERLIST$(INDEX)=STR$(INDEX)
00246    next INDEX
00247 ! 
00248    let KEYGIVEN=0
00249    let KEYGIVEN=VAL(FNASKCOMBO$(MAT NUMBERLIST$,"Select Key")) conv Ignore
00250    if KEYGIVEN AND KEYGIVEN<=UDIM(MAT KEYDESCRIPTION$) then 
00251       let STR2MAT(LWRC$(KEYDESCRIPTION$(KEYGIVEN)),MAT KEYFIELDS$,"/")
00252 ! 
00253       let FNRETURNCODE(' ')
00254       let FNRETURNCODE(' ! Variables Used')
00255       let FNRETURNCODE(' dim KeyNumber')
00256 ! 
00257       let CODELINE$=" dim "
00258       let KEYLENGTH=0
00259 ! 
00260       for INDEX=1 to UDIM(MAT KEYFIELDS$)
00261          let SUB=SRCH(MAT SSUBS$,TRIM$(KEYFIELDS$(INDEX)))
00262          if SUB>0 then 
00263             let LENGTH=FNLENGTH(SSPEC$(SUB))
00264             let CODELINE$=CODELINE$&TRIM$(KEYFIELDS$(INDEX))&"$*"&STR$(LENGTH)&", "
00265             let KEYLENGTH+=LENGTH
00266          else 
00267             let SUB=SRCH(MAT NSUBS$,TRIM$(KEYFIELDS$(INDEX)))
00268             if SUB>0 then 
00269                let LENGTH=FNLENGTH(NSPEC$(SUB))
00270                let CODELINE$=CODELINE$&TRIM$(KEYFIELDS$(INDEX))&", "
00271                let KEYLENGTH+=LENGTH
00272             end if 
00273          end if 
00274       next INDEX
00275       if LEN(CODELINE$)>6 then 
00276          let CODELINE$=CODELINE$(1:LEN(CODELINE$)-2)
00277          let FNRETURNCODE(CODELINE$)
00278       end if 
00279 ! 
00280       let FNRETURNCODE(' dim '&FILELAY$&'Key$*'&STR$(KEYLENGTH)&', This'&FILELAY$&'$*'&STR$(KEYLENGTH))
00281       let FNRETURNCODE(' ')
00282       let FNRETURNCODE(' ! Initialize Key Information Here')
00283       let FNRETURNCODE(' let KeyNumber='&STR$(KEYGIVEN))
00284       for INDEX=1 to UDIM(MAT KEYFIELDS$)
00285          let SUB=SRCH(MAT SSUBS$,TRIM$(KEYFIELDS$(INDEX)))
00286          if SUB>0 then 
00287             let FNRETURNCODE(' let '&KEYFIELDS$(INDEX)&'$=')
00288          else 
00289             let FNRETURNCODE(' let '&KEYFIELDS$(INDEX)&'=')
00290          end if 
00291       next INDEX
00292       let FNRETURNCODE(' ')
00293       let FNRETURNCODE(' ! Calculate the Key')
00294 ! 
00295       for INDEX=1 to UDIM(MAT KEYFIELDS$)
00296          let SUB=SRCH(MAT SSUBS$,TRIM$(KEYFIELDS$(INDEX)))
00297          if SUB>0 then 
00298             let FNRETURNCODE(' let '&FILELAY$&'$('&PREFIX$&KEYFIELDS$(INDEX)&')='&KEYFIELDS$(INDEX)&'$')
00299          else 
00300             let FNRETURNCODE(' let '&FILELAY$&'('&PREFIX$&KEYFIELDS$(INDEX)&')='&KEYFIELDS$(INDEX))
00301          end if 
00302       next INDEX
00303 ! 
00304       let FNRETURNCODE(' let '&FILELAY$&'Key$=fnBuildKey$("'&FILELAY$&'",mat '&FILELAY$&'$,mat '&FILELAY$&',KeyNumber)')
00305       let FNRETURNCODE(' ')
00306       let FNRETURNCODE(' ! Position by key')
00307       let FNRETURNCODE(' restore #'&FILELAY$&', search>=rtrm$('&FILELAY$&'Key$): nokey IGNORE')
00308       let FNRETURNCODE(' ')
00309       let FNRETURNCODE(' do until File('&FILELAY$&')')
00310       let FNRETURNCODE('    read #'&FILELAY$&', using Form$('&FILELAY$&') : Mat '&FILELAY$&'$,Mat '&FILELAY$&' eof IGNORE')
00311       let FNRETURNCODE('    let This'&FILELAY$&'$=fnBuildKey$("'&FILELAY$&'",mat '&FILELAY$&'$,mat '&FILELAY$&',KeyNumber)')
00312       let FNRETURNCODE('    if File('&FILELAY$&')=0 And rtrm$('&FILELAY$&'Key$)=This'&FILELAY$&'$(1:len(rtrm$('&FILELAY$&'Key$))) then')
00313       let FNRETURNCODE('       ! Found Something')
00314       let FNRETURNCODE(' ')
00315       let FNRETURNCODE(' ')
00316       let FNRETURNCODE(' ')
00317       let FNRETURNCODE('    end if')
00318       let FNRETURNCODE(' loop while rtrm$('&FILELAY$&'Key$)=This'&FILELAY$&'$(1:len(rtrm$('&FILELAY$&'Key$)))')
00319       let FNRETURNCODE(' ')
00320    end if 
00321    return 
00322 ! 
00323 ! 
00324 ! *******************************************
00325 !                Open The File
00326 ! *******************************************
00327 Openfile: ! Template For Opening The File
00328 ! 
00329 ! .! Dim at next largest multiple of 256
00330    let LONGESTELEMENT=(INT((LONGESTELEMENT-1)/256)+1)*256
00331 ! 
00332    let FNRETURNCODE(' ')
00333    let FNRETURNCODE(' ! FileIO Dimensions')
00334    let FNRETURNCODE(' dim Form$(1)*255')
00335    let FNRETURNCODE(' dim '&FILELAY$&', '&FILELAY$&'$(1)*'&STR$(LONGESTELEMENT)&','&FILELAY$&'(1)')
00336    let FNRETURNCODE(' ')
00337    let FNRETURNCODE(' ! Open the file')
00338    let FNRETURNCODE(' let '&FILELAY$&'=Fnopen("'&FILELAY$&'",Mat '&FILELAY$&'$,Mat '&FILELAY$&',Mat Form$)')
00339    let FNRETURNCODE(' ')
00340    return 
00341 ! 
00342 ! 
00343 ! *******************************************
00344 !               Write Code Key
00345 ! *******************************************
00346 Writecodekey: ! Template For A Keyed Writing And Dim Statements
00347 ! 
00348 ! .! Dim at next largest multiple of 256
00349    let LONGESTELEMENT=(INT((LONGESTELEMENT-1)/256)+1)*256
00350    mat NUMBERLIST$(UDIM(MAT KEYDESCRIPTION$))
00351    for INDEX=1 to UDIM(MAT NUMBERLIST$)
00352       let NUMBERLIST$(INDEX)=STR$(INDEX)
00353    next INDEX
00354 ! 
00355    let KEYGIVEN=0
00356    let KEYGIVEN=VAL(FNASKCOMBO$(MAT NUMBERLIST$,"Select Key")) conv Ignore
00357    if KEYGIVEN AND KEYGIVEN<=UDIM(MAT KEYDESCRIPTION$) then 
00358       let STR2MAT(LWRC$(KEYDESCRIPTION$(KEYGIVEN)),MAT KEYFIELDS$,"/")
00359 ! 
00360       let FNRETURNCODE(' ')
00361       let FNRETURNCODE(' ! FileIO Dimensions')
00362       let FNRETURNCODE(' dim Form$(1)*255')
00363       let FNRETURNCODE(' dim '&FILELAY$&', '&FILELAY$&'$(1)*'&STR$(LONGESTELEMENT)&','&FILELAY$&'(1)')
00364       let FNRETURNCODE(' ')
00365       let FNRETURNCODE(' ! Variables Used')
00366       let FNRETURNCODE(' dim KeyNumber')
00367 ! 
00368       let CODELINE$=" dim "
00369       let KEYLENGTH=0
00370       for INDEX=1 to UDIM(MAT KEYFIELDS$)
00371          let SUB=SRCH(MAT SSUBS$,TRIM$(KEYFIELDS$(INDEX)))
00372          if SUB>0 then 
00373             let LENGTH=FNLENGTH(SSPEC$(SUB))
00374             let CODELINE$=CODELINE$&TRIM$(KEYFIELDS$(INDEX))&"$*"&STR$(LENGTH)&", "
00375             let KEYLENGTH+=LENGTH
00376          else 
00377             let SUB=SRCH(MAT NSUBS$,TRIM$(KEYFIELDS$(INDEX)))
00378             if SUB>0 then 
00379                let LENGTH=FNLENGTH(NSPEC$(SUB))
00380                let CODELINE$=CODELINE$&TRIM$(KEYFIELDS$(INDEX))&", "
00381                let KEYLENGTH+=LENGTH
00382             end if 
00383          end if 
00384       next INDEX
00385       if LEN(CODELINE$)>6 then 
00386          let CODELINE$=CODELINE$(1:LEN(CODELINE$)-2)
00387          let FNRETURNCODE(CODELINE$)
00388       end if 
00389 ! 
00390       let FNRETURNCODE(' dim '&FILELAY$&'Key$*'&STR$(KEYLENGTH)&', This'&FILELAY$&'$*'&STR$(KEYLENGTH))
00391       let FNRETURNCODE(' ')
00392       let FNRETURNCODE(' ! Initialize Key Information Here')
00393       let FNRETURNCODE(' let KeyNumber='&STR$(KEYGIVEN))
00394       for INDEX=1 to UDIM(MAT KEYFIELDS$)
00395          let SUB=SRCH(MAT SSUBS$,TRIM$(KEYFIELDS$(INDEX)))
00396          if SUB>0 then 
00397             let FNRETURNCODE(' let '&KEYFIELDS$(INDEX)&'$=')
00398          else 
00399             let FNRETURNCODE(' let '&KEYFIELDS$(INDEX)&'=')
00400          end if 
00401       next INDEX
00402       let FNRETURNCODE(' ')
00403       let FNRETURNCODE(' ! Open the file')
00404       let FNRETURNCODE(' let '&FILELAY$&'=Fnopen("'&FILELAY$&'",Mat '&FILELAY$&'$,Mat '&FILELAY$&',Mat Form$,1,KeyNumber)')
00405       let FNRETURNCODE(' ')
00406       let FNRETURNCODE(' ! Calculate the Key')
00407 ! 
00408       for INDEX=1 to UDIM(MAT KEYFIELDS$)
00409          let SUB=SRCH(MAT SSUBS$,TRIM$(KEYFIELDS$(INDEX)))
00410          if SUB>0 then 
00411             let FNRETURNCODE(' let '&FILELAY$&'$('&PREFIX$&KEYFIELDS$(INDEX)&')='&KEYFIELDS$(INDEX)&'$')
00412          else 
00413             let FNRETURNCODE(' let '&FILELAY$&'('&PREFIX$&KEYFIELDS$(INDEX)&')='&KEYFIELDS$(INDEX))
00414          end if 
00415       next INDEX
00416 ! 
00417       let FNRETURNCODE(' let '&FILELAY$&'Key$=fnBuildKey$("'&FILELAY$&'",mat '&FILELAY$&'$,mat '&FILELAY$&',KeyNumber)')
00418       let FNRETURNCODE(' ')
00419       let FNRETURNCODE(' ')
00420       let FNRETURNCODE(' read #'&FILELAY$&', using Form$('&FILELAY$&'), key='&FILELAY$&'Key$ : Mat '&FILELAY$&'$,Mat '&FILELAY$&' eof Ignore')
00421       let FNRETURNCODE(' if File('&FILELAY$&')=0 And '&FILELAY$&'Key$=fnBuildKey$("'&FILELAY$&'",mat '&FILELAY$&'$,mat '&FILELAY$&') then')
00422       let FNRETURNCODE('    ! Found It: Set Values')
00423 ! 
00424       for INDEX=1 to UDIM(MAT SSUBS$)
00425          let FNRETURNCODE('    let '&FILELAY$&"$("&PREFIX$&SSUBS$(INDEX)&')=')
00426       next INDEX
00427       for INDEX=1 to UDIM(MAT NSUBS$)
00428          let FNRETURNCODE('    let '&FILELAY$&"("&PREFIX$&NSUBS$(INDEX)&')=')
00429       next INDEX
00430 ! 
00431       let FNRETURNCODE(' ')
00432       let FNRETURNCODE('    ! Save The Record')
00433       let FNRETURNCODE('    rewrite #'&FILELAY$&', using Form$('&FILELAY$&') : Mat '&FILELAY$&'$,Mat '&FILELAY$)
00434       let FNRETURNCODE(' end if')
00435       let FNRETURNCODE(' ')
00436       let FNRETURNCODE(' ! Close DataFile')
00437       let FNRETURNCODE(' let fnCloseFile('&FILELAY$&',"'&FILELAY$&'")')
00438       let FNRETURNCODE(' ')
00439    end if 
00440    return 
00441 ! 
00442 ! 
00443 ! *******************************************
00444 !                Write Code
00445 ! *******************************************
00446 Writecode: ! Template For Writing And Dim Statements
00447 ! 
00448 ! .! Dim at next largest multiple of 256
00449    let LONGESTELEMENT=(INT((LONGESTELEMENT-1)/256)+1)*256
00450 ! 
00451    let FNRETURNCODE(' ')
00452    let FNRETURNCODE(' ! FileIO Dimensions')
00453    let FNRETURNCODE(' dim Form$(1)*255')
00454    let FNRETURNCODE(' dim '&FILELAY$&', '&FILELAY$&'$(1)*'&STR$(LONGESTELEMENT)&','&FILELAY$&'(1)')
00455    let FNRETURNCODE(' ')
00456    let FNRETURNCODE(' ! Open the file')
00457    let FNRETURNCODE(' let '&FILELAY$&'=Fnopen("'&FILELAY$&'",Mat '&FILELAY$&'$,Mat '&FILELAY$&',Mat Form$)')
00458    let FNRETURNCODE(' ')
00459    let FNRETURNCODE(' ! Set Values')
00460 ! 
00461    for INDEX=1 to UDIM(MAT SSUBS$)
00462       let FNRETURNCODE(' let '&FILELAY$&"$("&PREFIX$&SSUBS$(INDEX)&')=')
00463    next INDEX
00464    for INDEX=1 to UDIM(MAT NSUBS$)
00465       let FNRETURNCODE(' let '&FILELAY$&"("&PREFIX$&NSUBS$(INDEX)&')=')
00466    next INDEX
00467 ! 
00468    let FNRETURNCODE(' ')
00469    let FNRETURNCODE(' ! Save The Record')
00470    let FNRETURNCODE(' write #'&FILELAY$&', using Form$('&FILELAY$&') : Mat '&FILELAY$&'$,Mat '&FILELAY$)
00471    let FNRETURNCODE(' ')
00472    let FNRETURNCODE(' ! Close DataFile')
00473    let FNRETURNCODE(' let fnCloseFile('&FILELAY$&',"'&FILELAY$&'")')
00474    let FNRETURNCODE(' ')
00475 ! 
00476    return 
00477 ! 
00478 ! 
00479 ! *******************************************
00480 !             Write Code Only Key
00481 ! *******************************************
00482 Writecodekeyonly: ! Template For A Keyed Writing And Dim Statements
00483 ! 
00484 ! .! Dim at next largest multiple of 256
00485    mat NUMBERLIST$(UDIM(MAT KEYDESCRIPTION$))
00486    for INDEX=1 to UDIM(MAT NUMBERLIST$)
00487       let NUMBERLIST$(INDEX)=STR$(INDEX)
00488    next INDEX
00489 ! 
00490    let KEYGIVEN=0
00491    let KEYGIVEN=VAL(FNASKCOMBO$(MAT NUMBERLIST$,"Select Key")) conv Ignore
00492    if KEYGIVEN AND KEYGIVEN<=UDIM(MAT KEYDESCRIPTION$) then 
00493       let STR2MAT(LWRC$(KEYDESCRIPTION$(KEYGIVEN)),MAT KEYFIELDS$,"/")
00494 ! 
00495       let FNRETURNCODE(' ')
00496       let FNRETURNCODE(' ! Variables Used')
00497       let FNRETURNCODE(' dim KeyNumber')
00498 ! 
00499       let CODELINE$=" dim "
00500       let KEYLENGTH=0
00501 ! 
00502       for INDEX=1 to UDIM(MAT KEYFIELDS$)
00503          let SUB=SRCH(MAT SSUBS$,TRIM$(KEYFIELDS$(INDEX)))
00504          if SUB>0 then 
00505             let LENGTH=FNLENGTH(SSPEC$(SUB))
00506             let CODELINE$=CODELINE$&TRIM$(KEYFIELDS$(INDEX))&"$*"&STR$(LENGTH)&", "
00507             let KEYLENGTH+=LENGTH
00508          else 
00509             let SUB=SRCH(MAT NSUBS$,TRIM$(KEYFIELDS$(INDEX)))
00510             if SUB>0 then 
00511                let LENGTH=FNLENGTH(NSPEC$(SUB))
00512                let CODELINE$=CODELINE$&TRIM$(KEYFIELDS$(INDEX))&", "
00513                let KEYLENGTH+=LENGTH
00514             end if 
00515          end if 
00516       next INDEX
00517       if LEN(CODELINE$)>6 then 
00518          let CODELINE$=CODELINE$(1:LEN(CODELINE$)-2)
00519          let FNRETURNCODE(CODELINE$)
00520       end if 
00521 ! 
00522       let FNRETURNCODE(' dim '&FILELAY$&'Key$*'&STR$(KEYLENGTH)&', This'&FILELAY$&'$*'&STR$(KEYLENGTH))
00523       let FNRETURNCODE(' ')
00524       let FNRETURNCODE(' ! Initialize Key Information Here')
00525       let FNRETURNCODE(' let KeyNumber='&STR$(KEYGIVEN))
00526       for INDEX=1 to UDIM(MAT KEYFIELDS$)
00527          let SUB=SRCH(MAT SSUBS$,TRIM$(KEYFIELDS$(INDEX)))
00528          if SUB>0 then 
00529             let FNRETURNCODE(' let '&KEYFIELDS$(INDEX)&'$=')
00530          else 
00531             let FNRETURNCODE(' let '&KEYFIELDS$(INDEX)&'=')
00532          end if 
00533       next INDEX
00534       let FNRETURNCODE(' ')
00535       let FNRETURNCODE(' ! Calculate the Key')
00536 ! 
00537       for INDEX=1 to UDIM(MAT KEYFIELDS$)
00538          let SUB=SRCH(MAT SSUBS$,TRIM$(KEYFIELDS$(INDEX)))
00539          if SUB>0 then 
00540             let FNRETURNCODE(' let '&FILELAY$&'$('&PREFIX$&KEYFIELDS$(INDEX)&')='&KEYFIELDS$(INDEX)&'$')
00541          else 
00542             let FNRETURNCODE(' let '&FILELAY$&'('&PREFIX$&KEYFIELDS$(INDEX)&')='&KEYFIELDS$(INDEX))
00543          end if 
00544       next INDEX
00545 ! 
00546       let FNRETURNCODE(' let '&FILELAY$&'Key$=fnBuildKey$("'&FILELAY$&'",mat '&FILELAY$&'$,mat '&FILELAY$&',KeyNumber)')
00547       let FNRETURNCODE(' ')
00548       let FNRETURNCODE(' ')
00549       let FNRETURNCODE(' read #'&FILELAY$&', using Form$('&FILELAY$&'), key='&FILELAY$&'Key$ : Mat '&FILELAY$&'$,Mat '&FILELAY$&' eof Ignore')
00550       let FNRETURNCODE(' if File('&FILELAY$&')=0 And '&FILELAY$&'Key$=fnBuildKey$("'&FILELAY$&'",mat '&FILELAY$&'$,mat '&FILELAY$&') then')
00551       let FNRETURNCODE('    ! Found It: Set Values')
00552 ! 
00553       for INDEX=1 to UDIM(MAT SSUBS$)
00554          let FNRETURNCODE('    let '&FILELAY$&"$("&PREFIX$&SSUBS$(INDEX)&')=')
00555       next INDEX
00556       for INDEX=1 to UDIM(MAT NSUBS$)
00557          let FNRETURNCODE('    let '&FILELAY$&"("&PREFIX$&NSUBS$(INDEX)&')=')
00558       next INDEX
00559 ! 
00560       let FNRETURNCODE(' ')
00561       let FNRETURNCODE('    ! Save The Record')
00562       let FNRETURNCODE('    rewrite #'&FILELAY$&', using Form$('&FILELAY$&') : Mat '&FILELAY$&'$,Mat '&FILELAY$)
00563       let FNRETURNCODE(' end if')
00564       let FNRETURNCODE(' ')
00565    end if 
00566    return 
00567 ! 
00568 ! 
00569 ! *******************************************
00570 !                Write Code Only
00571 ! *******************************************
00572 Writecodeonly: ! Template For Writing And Dim Statements
00573    let FNRETURNCODE(' ')
00574    let FNRETURNCODE(' ! Set Values')
00575 ! 
00576    for INDEX=1 to UDIM(MAT SSUBS$)
00577       let FNRETURNCODE(' let '&FILELAY$&"$("&PREFIX$&SSUBS$(INDEX)&')=')
00578    next INDEX
00579    for INDEX=1 to UDIM(MAT NSUBS$)
00580       let FNRETURNCODE(' let '&FILELAY$&"("&PREFIX$&NSUBS$(INDEX)&')=')
00581    next INDEX
00582 ! 
00583    let FNRETURNCODE(' ')
00584    let FNRETURNCODE(' ! Save The Record')
00585    let FNRETURNCODE(' write #'&FILELAY$&', using Form$('&FILELAY$&') : Mat '&FILELAY$&'$,Mat '&FILELAY$)
00586    let FNRETURNCODE(' ')
00587    return 
00588 ! 
00589 ! *******************************************
00590 !               Open Function
00591 ! *******************************************
00592 Openfunction: ! Standard Fileio Open Function
00593    let FNRETURNCODE(' dim LinkageEstablished')
00594    let FNRETURNCODE(' def fnEstablishLinkage')
00595    let FNRETURNCODE('    if ~LinkageEstablished then')
00596    let FNRETURNCODE('       library "fileio" : fnOpenFile,Fnclosefile,Fngetfilenumber,Fnkey$,FnBuildKey$,Fnreadlayoutarrays,Fndoeslayoutexist,Fnreadallkeys,fnReadRelativeDescription$,fnReadRelUnopenedDescription$,fnReadRelUnopenedNumber,fnUpdateFile,fnLog,fnLogArray,fnErrLog,fnReadLayouts,Fnmakeuniquekey$,FnDisplayLength,FnLength,FnReadDescription$,FnReadUnopenedDescription$,fnReadRecordWhere$,fnUniqueKey,fnReadNumber,fnReadUnopenedNumber,fnReadRelativeNumber,fnNotInFile,fnDataCrawler,fnDataEdit')
00597    let FNRETURNCODE('       library "fileio" : fnMakeSubProc,fnReadMatchingKeys,fnReadAllNewKeys,fnReadFilterKeys,fnReadEntireLayout,fnReadLayoutHeader,fnReadSubs,fnReadLayoutPath$,fnReadKeyFiles, fnAskCombo$,fnRunProcFile,fnBuildProcFile,fnDataShow')
00598    let FNRETURNCODE('       library "screenio" : fnCallScreen$,fnFindSubscript,fnFm$,fnfm,fnDisplayScreen,fnGetUniqueName$,fnIsInputSpec,fnIsOutputSpec,fnDays,fnBR42')
00599    let FNRETURNCODE('       let linkageEstablished=1')
00600    let FNRETURNCODE('    end if')
00601    let FNRETURNCODE(' fnend')
00602    let FNRETURNCODE(' !')
00603    let FNRETURNCODE(' ! #Auton'&'umber# 99000,10')
00604    let FNRETURNCODE(' OPEN: ! ***** Function To Call Library Openfile And Proc Subs')
00605    let FNRETURNCODE('       def Fnopen(Filename$*255, Mat F$, Mat F, Mat Form$; Inputonly, Keynum, Dont_Sort_Subs, Path$*255, Mat Descr$, Mat Field_Widths,Supress_Prompt,Ignore_Errors,___,Index)')
00606    let FNRETURNCODE('          dim _FileIOSubs$(1)*800, _Loadedsubs$(1)*80')
00607    let FNRETURNCODE('          let Fnopen=Fnopenfile(Filename$, Mat F$, Mat F, Mat Form$, Inputonly, Keynum, Dont_Sort_Subs, Path$, Mat Descr$, Mat Field_Widths, Mat _FileIOSubs$, Supress_Prompt,Ignore_Errors,Program$)')
00608    let FNRETURNCODE('          if Srch(_Loadedsubs$,Uprc$(Filename$))<=0 then : mat _Loadedsubs$(Udim(_Loadedsubs$)+1) : let _Loadedsubs$(Udim(_Loadedsubs$))=Uprc$(Filename$) : for Index=1 to Udim(Mat _Fileiosubs$) : execute (_Fileiosubs$(Index)) : next Index')
00609    let FNRETURNCODE('       fnend')
00610    let FNRETURNCODE('')
00611    let FNRETURNCODE(' Ignore: Continue')
00612    return 
00613 ! 
00614    dim RETURNCODE$*20000
00615    def FNRETURNCODE(STRING$*512)
00616       let RETURNCODE$=RETURNCODE$&STRING$&CHR$(13)&CHR$(10)
00617    fnend 
00618 ! 
00619    def library FNRUNTEMPLATE(TEMPLATE,FILELAY$;___,INDEX)
00620       let FNESTABLISHLINKAGE
00621       let RETURNCODE$=""
00622       let FNREADENTIRELAYOUT(FILELAY$,FILENAME$,PREFIX$,MAT KEYS$,MAT KEYDESCRIPTION$,MAT SSUBS$,MAT NSUBS$,MAT SSPEC$,MAT NSPEC$,MAT SDESCRIPTION$,MAT NDESCRIPTION$,MAT SPOS,MAT NPOS)
00623       let LONGESTELEMENT=0
00624       for INDEX=1 to UDIM(MAT SSPEC$)
00625          let LONGESTELEMENT=MAX(LONGESTELEMENT,FNLENGTH(SSPEC$(INDEX)))
00626       next INDEX
00627       for INDEX=1 to UDIM(MAT NSPEC$)
00628          let LONGESTELEMENT=MAX(LONGESTELEMENT,FNLENGTH(NSPEC$(INDEX)))
00629       next INDEX
00630       for INDEX=1 to UDIM(MAT SSUBS$)
00631          let SSUBS$(INDEX)=LWRC$(SSUBS$(INDEX))
00632       next INDEX
00633       for INDEX=1 to UDIM(MAT NSUBS$)
00634          let NSUBS$(INDEX)=LWRC$(NSUBS$(INDEX))
00635       next INDEX
00636       let PREFIX$=TRIM$(PREFIX$)
00637       gosub Runtemplate
00638 ! 
00639       if LEN(RETURNCODE$) then let SETENV("CLIPBOARD",RETURNCODE$)
00640    fnend 
00641 ! 
00642 Runtemplate: ! Template List Gosub Statement:
00643    on TEMPLATE gosub Readloop, Readloopkey, Readlooponly, Readloopkeyonly, Writecode, Writecodekey, Writecodeonly, Writecodekeyonly, Openfile, Openfunction, Selfregister, Conversion
00644    return 
00645 ! 
00646 Templatelist: ! Dictionary Listing Of Available Functions
00647    data "Read Loop"
00648    data "Read Loop Key"
00649    data "Read Loop Only"
00650    data "Read Loop Only Key"
00651    data "Write Code"
00652    data "Write Code Key"
00653    data "Write Code Only"
00654    data "Write Code Only Key"
00655    data "Open File"
00656    data "Open Function"
00657    data "Self Register"
00658    data "Conversion"
00659 ! 
00660    def library FNTEMPLATELIST(MAT TEMPLATEDESC$)
00661       restore Templatelist
00662       mat TEMPLATEDESC$(11)
00663       read MAT TEMPLATEDESC$
00664    fnend 
00665 ! 
00666    dim LINKAGEESTABLISHED
00667    def FNESTABLISHLINKAGE
00668       if ~LINKAGEESTABLISHED then 
00669          library "fileio" : FNOPENFILE, FNCLOSE, FNREADENTIRELAYOUT, FNGETFILENUMBER, FNGETKEYELEMENTS, FNLENGTH, FNASKCOMBO$
00670          let LINKAGEESTABLISHED=1
00671       end if 
00672    fnend 
00673 ! 
99000 ! #Autonumber# 99000,10
99010 Open: ! ***** Function To Call Library Openfile And Proc Subs
99020    def FNOPEN(FILENAME$*255, MAT F$, MAT F, MAT FORM$; INPUTONLY, KEYNUM, DONT_SORT_SUBS, PATH$*255, MAT DESCR$, MAT FIELD_WIDTHS,SUPRESS_PROMPT,IGNORE_ERRORS,___,INDEX)
99030       dim _FILEIOSUBS$(1)*800, _LOADEDSUBS$(1)*80
99040       let FNOPEN=FNOPENFILE(FILENAME$, MAT F$, MAT F, MAT FORM$, INPUTONLY, KEYNUM, DONT_SORT_SUBS, PATH$, MAT DESCR$, MAT FIELD_WIDTHS, MAT _FILEIOSUBS$, SUPRESS_PROMPT,IGNORE_ERRORS,PROGRAM$)
99050       if SRCH(_LOADEDSUBS$,UPRC$(FILENAME$))<=0 then : mat _LOADEDSUBS$(UDIM(_LOADEDSUBS$)+1) : let _LOADEDSUBS$(UDIM(_LOADEDSUBS$))=UPRC$(FILENAME$) : for INDEX=1 to UDIM(MAT _FILEIOSUBS$) : execute (_FILEIOSUBS$(INDEX)) : next INDEX
99060    fnend 
99070 ! 
99080 Ignore: continue 
