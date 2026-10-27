00010  ! function\deleterecord.brs
00020  !
00030  !
00040  ! Created on 01/07/2009
00050  !
00060  !  This function deletes the currently edited record on an add/edit screen
00070  !
00080  !  The last read record of a data file always corresponds with the current
00090  !  record on the screen in an add/edit screen
00100  !
00110  !  This function asks the user for confirmation
00120  !  This function deletes the last read record of the data file
00130  !  Finally, this function instructs screenio to leave the current screen
00140  !   on an Edit Screen, if we delete a record, we also want to stop editing it.
00150  !
00160  !
00170  def fndeleterecord(&ExitMode,DataFile,Key$)
00180     if 2=msgbox("Are you sure you wish to delete the current record?","Delete Record?","yN","EXCL") then
00190        if len(trim$(key$)) then
00200           delete #DataFile:
00210        end if
00220        let ExitMode=QuitOnly
00230     end if
00240  fnend