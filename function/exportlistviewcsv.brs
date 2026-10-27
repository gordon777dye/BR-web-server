00010 ! function\exportlistviewcsv.brs
00020 ! Created on 07/03/2014
00030 !
00040 ! fnExportListview - This function exports a Listview in its current
00050 !  form to a CSV file, using a new function in FileIO.
00060 !
00070 ! You must add a control Name for the listview, and then put that listview name in the CSV button's Userdata field.
00080 !
00090 def fnExportListview(;___,ListviewSubscript)
00100    let ListviewSubscript=fnFindSubscript(mat Subscripts$,"ctl_",UserData$(ControlIndex))
00110    if ListviewSubscript then
00120       let fnExportListviewCSV(Window,fnListSpec$(ControlSpec$(ListviewSubscript)),1)
00130    else
00140       let msgbox("Couldn't find the target listview. Please ensure a valid listview is selected for the Print button, or contact the programmer who worked on your system to fix this error.")
00150    end if
00160 fnend
