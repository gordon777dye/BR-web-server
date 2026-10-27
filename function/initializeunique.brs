00010  ! function\initializeunique.brs
00020  !
00030  ! Created on 01/11/2009
00040  !
00050  ! This function will initialize any key to unique
00060  !
00070  def fnInitializeUnique(mat Subscripts$,mat f$,prefix$,DataFile;___,Subscript)
00080     let Subscript=fnFindSubscript(mat Subscripts$,prefix$,"id")
00090     if Subscript then
00100        let f$(Subscript)=fnMakeUniqueKey$(DataFile)
00110     end if
00120  fnend