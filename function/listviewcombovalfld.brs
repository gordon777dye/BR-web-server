00010  ! function\listviewcombovalfld.brs
00020  ! Created on 05/31/2014
00030  !
00040  ! fnListviewComboValFld - This function doesn't allow user changing
00050  !  fields when they also clicked on a new record in the listview
00060  !  indicating that they want to cancel all changes anyway.
00070  !
00080  ! #Include {listviewcomboread}
00090  !
00100  def fnListviewComboValFld
00110     if ~ChangedRead then
00120        let fnListviewComboValFld=1
00130     end if
00140  fnend
