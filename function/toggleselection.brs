00010  ! function\toggleselection.brs
00020  ! Created on 04/13/2009
00030  !
00040  ! fnToggleSelection - This Function toggles the current selection
00050  !
00060  !
00070  def fnToggleSelection(CurrentKey$,&RepopulateListviews;___,Index,I)
00080     let Index=srch(mat MarkedRecords$,CurrentKey$)
00090     if Index>0 then
00100        for I = Index to udim(MarkedRecords$)-1
00110           let MarkedRecords$(I)=MarkedRecords$(I+1)
00120        next I
00130        mat MarkedRecords$(udim(MarkedRecords$)-1)
00140     else
00150        mat MarkedRecords$(udim(MarkedRecords$)+1)
00160        let MarkedRecords$(udim(MarkedRecords$))=CurrentKey$
00170     end if
00180     let RepopulateListviews=1
00190  fnend