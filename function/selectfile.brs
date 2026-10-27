00010  ! function\selectfile.brs
00020  ! Created on 03/28/2009
00030  !
00040  ! fnSelectFile - This Function selects a file or a folder
00050  ! in the ScreenIO system using the BR File Selection Dialog
00060  !
00070  !
00080  def fnSelectFile(controlindex,mat subscripts$,mat controlname$,prefix$,mat s$,mat f$;___,Folder$*255,FileHandle)
00090  !
00100     let FileSubscript=fnFindSubscript(mat Subscripts$,prefix$,controlname$(controlIndex))
00110     let ScreenSubscript=fnFindSubscript(mat Subscripts$,"sio_",controlname$(controlIndex))
00120  !
00130     let Folder$=trim$(f$(FileSubscript))
00140     if Folder$="" then let Folder$=".\"
00150     let Folder$=Folder$(1:pos(Folder$,"\",-1))&"*.*"
00160  !
00170     open #(filehandle:=fnGetFileNumber): "name=open:"&Folder$&", recl=80", external, input error Ignore
00180     if file(filehandle)=0 then
00190        let folder$=trim$(file$(filehandle))
00200        close #filehandle:
00210  !
00220        if pos(lwrc$(ControlName$(ControlIndex)),"folder") then
00230           let Folder$=Folder$(1:pos(Folder$,"\",-1))
00240        end if
00250  !
00260        if FileSubscript then let f$(FileSubscript)=folder$
00270        if ScreenSubscript then let s$(ScreenSubscript)=folder$
00280     end if
00290  fnend