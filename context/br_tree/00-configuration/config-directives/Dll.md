---
title: Dll
file: Dll.md
category: 00-configuration
subcategory: 00-configuration/config-directives
kind: config-directive
related: [SPOOLPATH]
---
BR functions with a Dll structure.

===Structure=== 

As of Release 4.3 Business Rules! is structured with the following modules:

*brserver.exe - The BR Server module accessed by Client-Server configurations. Brserver.exe also operates as what is now viewed as the Standard Model. If it is invoked by brlistener, then it acts as brserver. If it is simply executed, it acts as brcombined. However, when operating as the standard model, it needs to have brclient.dll in the same directory as brserver.
*brclient.exe - The program that the user accesses in Client-Server configurations.
*brclient.dll - The client processing program that correlates with the brserver edition.
*npbrclient.dll - The standard (non-IE) browser plugin dll
*iebrclient.dll - Internet Explorer plugin dll

Client installation is done by placing brclient.exe and brclient.dll on the client system and referencing brclient.exe in an icon. Server installation is done by placing brserver.exe and brclient.dll on the server and referencing brserver.exe in the brlistener.conf file. Exe files may be renamed as desired. The name of the released brclient.dll modules will be lengthy and must not be changed because BR relies on the DLL names for version identification. 

You will need one of the following possible configurations:
*Workstation Standard Model
**Server executable
**Workstation Client dll
*Linux Terminal Support
**Server executable
**Linux Client dll ( .so )
*Client Server Model
**On Client Machine-
***Client executable
***Workstation Client dll
**On Server
***Server executable
***Workstation Client dll
***BR Listener installed
***[ Linux Client dll for Linux terminal access ]

Servers, clients, debug models and release models can be intermixed. However dlls must be the in same bit class (32 or 64) as the modules that call them.  Put your BR bmp files ( drawsunk.bmp, startup.bmp etc. ) in the BR server executable directory.  When client DLLs are transferred from the server to the client they are stored in \users\-name-\AppData\Local\ADS\ and the full pathname to the most recent is stored in the registry at HKEY_CURRENT_USER\ Software\ADS\BusinessRules!\CurrentClient. 

Updates will pertain to Processor DLLs while the user interfaces will remain as installed. Client DLLs will be automatically uploaded when corresponding server DLLs are accessed in the event they are not already present on the client.

The client can be accessed from within a browser by initiating it with HTML which can specify an embedded window or a separate independent window. In all cases opening a window with PARENT=NONE creates a separate window. 

===BR Adjunctive Files===

The BR executable is now considered to be where the BR server actually resides, irrespective of Drive statements and current working directories.

The following files are located in the BR executable directory by default:
*BR server executable
*BRconfig.sys
*BRserial.dat
*BRserver.dat
*WBcmd.wbh - BR help files
*Server Dlls
*Client Dlls for uploading as needed
*System Image files – linedraw, etc. - typically BMPs

===Exceptions====

If WBcmd.wbh doesn't exist in the BR executable directory then BR looks for it in the initial directory specified by the first drive statement. (Deprecated – this will be eliminated at some point).  ONQPATH currently defaults to this initial path as well. (This will remain).

If the BRconfig file is not present in the BR executable directory then BR looks for it in the current working directory at the time of BR invocation. 

The `SPOOLPATH` :OS-fullpath  configuration statement specifies where print spool files are temporarily stored during printing.  SPOOLPATH defaults to a spool directory that runs off of the BR root of the first drive statement. If no such spool directory exists and SPOOLPATH is not specified then BR creates one. For example:

 DRIVE   J:, C:\BR, x, \MYAPP   

would result in spool files being placed in:

 C:\BR\SPOOL\

SPOOLPATH @::client-OS-fullpath specifies where on the client spool files are to be placed. For example:

 SPOOLPATH  @::C:\BR\SPOOL  (or whatever other full path is desired)

The @:  tells BR that this path is on the client. The second colon says the path is independent of drive specifications. In addition to regular spool files, this is where PDF files are created. 

SPOOLPATH can be set concurrently for both client and server by specifying two SPOOLPATH statements. BR creates print files in the server spool directory during printing and forwards them to the client when the print file is closed. 

The client-pathname has some unique characteristics:
Relative paths are assumed to be OS pathnames relative to the CLIENT_CURRENT_DIR folder, or the startup directory if CLIENT_CURRENT_DIR is not specified. 

If a full pathname is specified it must begin with a colon. (For example,   @::X:\path). Otherwise, it will be preceded with the path to the client current working directory.
 
Specifying a relative remote pathname is not compatible with CLIENT_CURRENT_DIR SYNC.

The status of SPOOLPATH and REMOTESPOOLPATH settings are displayed in response to the STATUS SUBSTITUTE command (not the STATUS CONFIG command).  

WORKPATH defaults to the BR root of the first drive statement, for example:
 C:\BR\

BRconfig.sys INCLUDE statements are relative to the location of the file containing the INCLUDE statement (the parent).  CONFIG command INCLUDE statements are relative to the current directory at the time the command is issued.

===Licensing Restrictions===

As of 4.20H, brserial files must be specific to the first decimal position of the release of BR that is being used. (e.g. 4.2x versus 4.3x)

To accommodate more than one brserial level, BR first looks for its own suffix (42 or 43) before looking for a DAT file. From now on it is most useful to name your brserial files either BRSERIAL.42 or BRSERIAL.43, etc.
