00010  ! function\listviewcombodelete.brs
00020  ! Created on 05/30/2014
00030  !
00040  ! fnListviewComboDelete - This function deletes the currently selected
00050  !  line in the listview, and triggers the redisplay of the listview.
00060  !
00070  ! #Include {listviewcomboread}
00080  !
00090  def fnListviewComboDelete
00100     if LastReadRecord then
00110        if (2==msgbox("Are you sure you want to delete this record from the list?","Are you sure?","yN","QST")) then
00120           mat X$(udim(mat F$))
00130           mat X(udim(mat F))
00140           read #DataFile, using form$(DataFile), rec=LastReadRecord : mat X$, mat X
00150           delete #DataFile:
00160           let RepopulateListviews=1
00170           let CurrentRec=-1
00180        end if
00190     else
00200        ! We're in add. Nothing to delete.
00210  !
00220        ! Instead, cancel the add.
00230  !
00240  !
00250     end if
00260  fnend
