00010  ! function\returnrecord.brs
00020  ! Created on 12/18/2014
00030  !
00040  ! fnReturnRecord - This function returns the record number of the selected record.
00050  !
00060  !
00070  def fnReturnRecord
00080     if ExitMode=SelectAndQuit then let CurrentKey$=str$(Rec(Datafile))
00090  fnend
