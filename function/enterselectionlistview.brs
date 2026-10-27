00010  ! function\enterselectionlistview.brs
00020  ! Created on 07/13/2009
00030  !
00040  ! fnEnterSelectionListview - This Function Primes the Selection Listview
00050  !
00060  !
00070  dim MarkedRecords$(1)
00080  !
00090  def fnEnterSelectionListview(ParentKey$,DataFile;___,Index,KeyLen)
00100  !
00110     let KeyLen=kln(DataFile)
00120     mat MarkedRecords$(int(len(ParentKey$)/KeyLen))
00130  !
00140     for Index=1 to udim(mat MarkedRecords$)
00150        let MarkedRecords$(Index)=ParentKey$(((Index-1)*KeyLen)+1:(Index*KeyLen))
00160     next Index
00170  fnend
