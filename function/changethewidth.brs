00010  ! function\changethewidth.brs
00020  ! Created on 02/02/2002
00030  !
00040  ! fnChangeTheWidth - This Function changes the width of the sample field
00050  !
00060  !
00070  def fnChangeTheWidth
00080     let width(ctl_field_addr1)+=5
00090     let invisible(ctl_changebutton)=1
00100  !
00110  fnend
