00010  ! function\returnselection.brs
00020  ! Created on 07/13/2009
00030  !
00040  ! fnReturnSelection - This Function returns the selected list to the
00050  !  calling program
00060  !
00070  !
00080  def fnReturnSelection(&CurrentKey$,DataFile;___,Index)
00090     let CurrentKey$=""
00100     for Index=1 to udim(mat MarkedRecords$)
00110        let CurrentKey$=CurrentKey$&fnKey$(DataFile,MarkedRecords$(Index))
00120     next Index
00130  fnend
