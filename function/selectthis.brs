00010  ! function\selectthis.brs
00020  !
00030  ! Created on 01/12/2009
00040  !
00050  ! This function selects a thing from the target (current fields name) file
00060  ! and returns it to the current field, while setting it in the matching file
00070  ! position in whatever the current file is
00080  !
00090  def fnSelectThis(controlindex,mat subscripts$,mat controlname$,prefix$,mat s$,mat f$;___,FileSubscript,Return$*255,ScreenSubscript)
00100     let FileSubscript=fnFindSubscript(mat Subscripts$,prefix$,controlname$(controlIndex))
00110     let ScreenSubscript=fnFindSubscript(mat Subscripts$,"sio_",controlname$(controlIndex))
00120  !
00130     let Return$=fnCallScreen$("["&trim$(controlname$(controlindex))&"]")
00140     if len(trim$(Return$)) then
00150        let f$(FileSubscript)=Return$
00160        let s$(ScreenSubscript)=fnReadUnopenedDescription$(trim$(controlname$(controlindex)),Return$)
00170     end if
00180  fnend