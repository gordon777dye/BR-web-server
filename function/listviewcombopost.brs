00010  ! function\listviewcombopost.brs
00020  ! Created on 05/30/2014
00030  !
00040  ! fnListviewComboPost - This function makes sure the correct item
00050  !  has been read and the listview read is run properly when its
00060  !  repopulated
00070  !
00080  ! #Include {listviewcomboread}
00090  !
00100  def fnListviewComboPost
00110     if len(trim$(CurrentKey$)) then
00120        read #DataFile, using form$(DataFile), key=CurrentKey$ : mat F$, mat F
00130     else
00140        read #DataFile, using form$(DataFile), first : mat F$, mat F
00150     end if
00160     let fnListviewComboRead
00170  fnend
