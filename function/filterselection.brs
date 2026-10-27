00010  ! function\filterselection.brs
00020  ! Created on 07/13/2009
00030  !
00040  ! fnFilterSelection - This Function displays the current list with the
00050  !  selected items highlighted
00060  !
00070  !
00080  def fnFilterSelection$(mat f$,mat f,mat ScreenIO$;___,CurrentKey$)
00090     let CurrentKey$=fnBuildKey$(Trim$(Screenio$(Si_Filelay)),Mat F$,Mat F)
00100     if srch(mat MarkedRecords$,CurrentKey$)>0 then
00110        let fnFilterSelection$="/#000000:#FFFF00"
00120     else
00130        let fnFilterSelection$="/#FFFFFF:#000000"
00140     end if
00150  fnend
