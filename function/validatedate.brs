00010  ! function\validatedate.brs
00020  !
00030  ! Created on 01/12/2009
00040  !
00050  !
00060  !
00070  def fnvalidatedate(mat f$,&fieldtext$,controlIndex,mat ControlName$,mat Subscripts,prefix$;___,Index,Subscript,DateValue)
00080  !
00090     let DateValue=days("m/d/ccyy",fieldtext$) error ignore
00100     let fieldtext$=date$(DateValue,"m/d/ccyy")
00110     let fnvalidatedate=1 ! Date Save Successful
00120  !
00130     let Subscript=fnFindSubscript(mat Subscripts$,prefix$,controlname$(controlindex))
00140     if Subscript and Subscript<=udim(mat f) then
00150        let f(Subscript)=DateValue
00160     end if
00170  fnend