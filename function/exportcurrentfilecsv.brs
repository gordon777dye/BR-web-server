00010  ! function\exportcurrentfilecsv.brs
00020  ! Created on 11/09/2017
00030  !
00040  ! fnExportCurrentFileCSV - This function calls FileIO's CSV Export Dialog
00050  !  with Column Select automatically for the file that is the subject of the
00060  !  current listview. It passes in the currently selected records.
00070  !
00080  ! Specify an alternate layout if you like (with fewer fields (replace fields you don't want with Xs)) in UserData
00090  !
00100  dim SelRecs(1)
00110  !
00120  def fnExportCurrentFileCSV
00130     mat SelRecs(udim(mat SelectedRecords))=SelectedRecords
00140     if udim(mat SelRecs)=1 then mat SelRecs(udim(mat VisibleRecords))=VisibleRecords
00150     if trim$(UserData$(ControlIndex))="" then let UserData$(ControlIndex)=ScreenIO$(si_filelay)
00160     let fnCSVExport(UserData$(ControlIndex),3,"",0,0,"","",0,mat SelRecs,"",1)
00170  fnend
