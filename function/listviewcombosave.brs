00010  ! function\listviewcombosave.brs
00020  ! Created on 05/30/2014
00030  !
00040  ! fnListviewComboSave - This function saves the current edits into the
00050  !  previously recorded last record read, and triggers the redisplaying
00060  !  of the listview.
00070  !
00080  ! #Include {listviewcomboread}
00090  !
00100  dim X$(1)*1023,X(1)
00110  !
00120  def fnListviewComboSave
00130     if LastReadRecord then
00140        mat X$(udim(mat F$))
00150        mat X(udim(mat F))
00160        read #DataFile, using form$(DataFile), rec=LastReadRecord : mat X$, mat X
00170        rewrite #DataFile, using form$(DataFile) : mat F$, mat F
00180        let CurrentRec=LastRecordRead
00190     else
00200        write #DataFile, using form$(DataFile) : mat F$, mat F
00210        let CurrentRec=LastReadRecord=rec(DataFile)
00220     end if
00230  !
00240     let RepopulateListviews=1
00250  fnend
