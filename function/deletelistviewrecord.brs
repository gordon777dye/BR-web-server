00010 ! function\deletelistviewrecord.brs
00020 !
00030 !
00040 !  Created on 01/07/2009
00050 !
00060 !  This function deletes the currently selected record on a lisview screen
00070 !
00080 !  The last read record of a data file always corresponds with the currently
00090 !  highlighted record in the listview
00100 !
00110 !  This function gives a record description of the last read
00120 !  record of the data file
00130 !  It deletes the last read record of the data file
00140 !  It does not, however, leave the current screen
00150 !
00160 !
00170 def fndeletelistviewrecord(&ExitMode,DataFile,mat f$,&RepopulateListviews;Recorddescription$*255)
00180    if RecordDescription$="" then
00190       if udim(f$)>1 then
00200          let RecordDescription$=f$(1)
00210       end if
00220       if udim(f$)>2 then
00230          let RecordDescription$=RecordDescription$&","&f$(2)
00240       end if
00250    end if
00260    if 2=msgbox("Are you sure you wish to delete the current record: "&RecordDescription$,"Delete Record?","yN","QST") then
00270       read #Datafile, using form$(Datafile), rec=CurrentRec : mat f$, mat f
00280       delete #DataFile:
00290       let RepopulateListviews=1
00300    end if
00310 fnend
