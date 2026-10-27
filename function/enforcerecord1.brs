00010  ! function\enforcerecord1.brs
00020  ! Created on 08/07/2014
00030  !
00040  ! fnEnforceRecord1 - This Function enforces Record 1 for the current
00050  !  data file. If the file doesn't have a record 1, then a blank record
00060  !  1 is created
00070  !
00080  !  It should be used as the Enter event.
00090  !
00100  !
00110  def fnEnforceRecord1
00120     ! Set it to read Record 1
00130     let Record=1
00140  !
00150     ! Make sure Record 1 Exists
00160     restore #Datafile, rec=Record : norec Ignore
00170  !
00180     ! If it doesn't, create it.
00190     if file(DataFile) then
00200        mat f$=("") : mat f=(0)
00210        write #DataFile, using form$(DataFile), rec=Record : mat F$, mat F
00220     end if
00230  fnend
