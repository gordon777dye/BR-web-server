00010  ! function\listviewcomboread.brs
00020  ! Created on 05/30/2014
00030  !
00040  ! fnListviewComboRead - This function records the last clicked on
00050  !  item so it can be saved later in a Combo Listview/Add/Edit screen.
00060  !  it is also necessary to have a listview read event for this type
00070  !  of screen in order to make the fields update properly, though the
00080  !  listview read event function doesn't need to do anything for that
00090  !  effect.
00100  !
00110  dim LastReadRecord
00120  dim ChangedRead
00130  !
00140  def fnListviewComboRead
00150     let TTT = LastReadRecord
00160     let TT=ChangedRead
00170     if LastReadRecord><rec(DataFile) then
00180        let LastReadRecord=rec(Datafile)
00190        let ChangedRead=1
00200     end if
00210  fnend