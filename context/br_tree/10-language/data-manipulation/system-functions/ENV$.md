---
title: ENV$
file: ENV$.md
category: 10-language
subcategory: 10-language/data-manipulation/system-functions
kind: function
related: [environmental variable, SetEnv, UserName, GUIMode, Status]
---
ENV$(<variable>)

The **Env$(var$)** returns the current value of the specified environment variable. To see a list of operating system environmental variables, enter the SET command with no parameters at the operating system prompt.

BR internal environmental values can be set by CONFIG SETENV. For example, use the following command to set the value of env$("librarypath"):

 config setenv librarypath f:\apps\library\

Operating system ENV$ variables cannot be set or altered by CONFIG SETENV. 

The **Env$** function is used to retrieve local *BR only* `environmental variable` values (which were set with `SetEnv`).

Example:

 got1$=env$("`UserName`")
 got2$=env$("`GUIMode`")

====Comments and Examples====

As an example, if LOGNAME contains the login name, the following line in a menu program would require a user to log in as "root" to be able to run program PROG14.

 00040 if env$("LogName")="root" then chain "Prog14" else goto SHOWMENU

For a complete list of possible ENV$ arguments issue the following command:

 `Status` Env [ -P ]

Example:
 ENV$("SERVER_PLATFORM")      
Returns “WINDOWS”

====Technical Considerations====

# Linux and MAC versions of Business Rules require that user-created environment variables be passed by an export command to the operating system before the user enters Business Rules. This is a normal Linux/ MAC OS X requirement. Otherwise, the values of these variables are not accessible to BR.
# There is a BR provided Env$ variable called GUIMODE (case insensitive). It's value is either ON or OFF depending on whether BR is in `GUIMode|GUI mode`.
# The keyword CLIPBOARD retrieves the current contents of the Windows clipboard.
# BR_MODEL returns the model of Business Rules currently operating (COMBINED or CLIENT/SERVER). 
# Also see Monitor Interrogation below.

===BR SETTINGS ENVIRONMENT COMPREHENSIVE INTERROGATION===

The ENV$("STATUS") function can be used to retrieve a broad range of program environment data. It returns the same type of data that the STATUS ENV command returns, except:
# It populates a string array with the data.
# **ENV$("status" ...** returns only the values of environment variables, whereas **ST ENV** shows each whole **ENV$()** expression along with its corresponding value.

 ENV$("STATUS [ .sub-keyword ] ... " [, mat config$ ] [, "search-arg , ... " ] )

ENV$ returns a string, or in the event that a string array (e.g. MAT CONFIG$) is specified, ENV$ redimensions and loads the array with the associated values.

Use STATUS sub-keywords to restrict the output to exact terms. For a list of valid keywords issue a **STATUS ENV "status" -P** command. The subtle aspect of this is that STATUS ENV shows all environment variables accessible via ENV$, whereas only the ENV$("status") values can be sent to an array. 

Note that, while sub-keywords are case insensitive, they must be spelled out in their entirety. 
e.g. '''ENV$('status.attribute')** fails to produce any results, whereas **ENV$('status.attributes')''' produces many results. 
[To see a list of attributes currently in effect enter ST ATTR at the keyboard. Or enter ST ENV 'attr' for ENV$ values of specific attributes.] This complete spelling requirement is meant for programs (as distinguished with command line inquiry), and avoids inadvertent argument matching. However, ad-hoc inquiry is facilitated by optional additional case insensitive string filter arguments.

Like the `Status#Status Env|STATUS ENV` command, ad hoc comma separated search arguments in a single quoted string may be specified to filter the output. Each search argument provided is matched (case insensitive) against each output line and only matching lines are output. Individual comma separated search words may be preceded with a tilde (~) to indicate exclusion of matching lines. Each argument is space trimmed before comparing. 

It is not necessary to provide an array to receive the results. If only one value is needed and no array is provided, the first value produced by the ENV$ call is returned as the string value of the function, and the search argument(s) can conveniently narrow the result to the desired term. 

The following program displays all STATUS information that contains the word “file”:

 00100    dim CONFIG$(1)*100
 00120    let ENV$("STATUS",MAT CONFIG$,"file")
 00140    print MAT CONFIG$

The above program produces the following output:

 CHAINDFLT   - Look for object files with source first.
 EDITOR C:\PROGRAM FILES\MILLS ENTERPRISE\MYEDITBR\MYEDITBR.EXE
 FILENAMES LOWER_CASE
 OPTION 23 is OFF - prevent data conversion errors from moving file position
 OPTION 25 is ON - make FILE$(0) be CON: if in windows
 OPTION 26 is OFF - suppress creation of .BAK files
 OPTION 29 is ON - save programs as .WB files
 OPTION 33 is 64 - locking position for large file support
 OPTION 49 is OFF - use relative path for spool file
 OPTION 51 is OFF - recover deleted records for all files
 SPOOLCMD prt.bat [SPOOLFILE] [COPIES] [PRINTER]
 Server File: :c:\wbserver.dat
 BR Config File: :C:\ADS\SYS\br.d\brconfig.sys
 Executable File: :C:\ADS\SYS\br.d\ 
 brserver-430beta+q-Win32-DebugEfence-2011-03-20.exe
 Serial File: :C:\ADS\SYS\br.d\brserial.dat
 Workfile path: :c:\ads
 Open File #  0  :CON:

If you just want the options with the word file then use:

 00100    dim CONFIG$(1)*100
 00120    let ENV$("STATUS.CONFIG.OPTION",MAT CONFIG$,"file")
 00140    print MAT CONFIG$

This uses both the sub-keywords and the search string to filter the output which produces:
 OPTION 23 is OFF - prevent data conversion errors from moving file position
 OPTION 25 is ON - make FILE$(0) be CON: if in windows
 OPTION 26 is OFF - suppress creation of .BAK files
 OPTION 29 is ON - save programs as .WB files
 OPTION 33 is 64 - locking position for large file support
 OPTION 49 is OFF - use relative path for spool file
 OPTION 51 is OFF - recover deleted records for all files 

Note that while sub-keywords are case insensitive, they must be completely specified, whereas search strings are more “friendly”. For a complete list of valid keywords, issue the command:

 STATUS ENV -p

Some of the keywords supported are:
 ENV$("CLIENT_PLATFORM") is "WINDOWS"
 ENV$("CLIENT_PLATFORM.BR_BUILD_TYPE") is "DebugEfence"
 ENV$("CLIENT_PLATFORM.BR_BUILD_DATE") is "2011-05-12"
 ENV$("CLIENT_PLATFORM.BR_BITS") is "32"
 ENV$("CLIENT_PLATFORM.OS_BITS") is "64"
 ENV$("CLIENT_PLATFORM.OS_VERSION_NAME") is "Windows 7"
 ENV$("CLIENT_PLATFORM.OS_VERSION_NUMBER") is "6.1"
 ENV$("SERVER_PLATFORM") is "LINUX"
 ENV$("SERVER_PLATFORM.BR_BUILD_TYPE") is "DebugEfence"
 ENV$("SERVER_PLATFORM.BR_BUILD_DATE") is "2011-05-13"
 ENV$("SERVER_PLATFORM.BR_BITS") is "64"
 ENV$("SERVER_PLATFORM.OS_BITS") is ""
 ENV$("SERVER_PLATFORM.OS_VERSION_NAME") is "#36-Ubuntu SMP Thu Jun 3 20:38:33 UTC 2010"
 ENV$("SERVER_PLATFORM.OS_VERSION_NUMBER") is "2.6.32-22-server"	
 BR_MODEL		  “CLIENT/SERVER” or “COMBINED”

===Monitor Configuration Interrogation===

 ENV$("MONITOR1 | MONITOR2", MAT <num-arrayname>)

Either MONITOR1 or MONITOR2 redimensions num-arrayname to 4 elements and returns X (horizontal) and Y (vertical), of the upper left corner, and Width and Height in pixels ofthe current setting for either monitor 1 or monitor 2. Monitor 2 can be regarded as an extension of monitor 1 concerning the total video space.

Example Program (cut and paste into a text editor – then LOAD file SOURCE):
 00010    let MONITORS$ = ENV$("monitor_count")
 00020    let MONITORS = VAL(MONITORS$)
 00030    print MONITORS
 00040    for I = 1 to MONITORS
 00050       let ENV$("monitor"&STR$(I), MAT TEST)
 00060       for J = 1 to 4
 00070          print TEST(J);
 00080       next J
 00090       print 
 00100    next I

Results for 2 monitors of differing sizes:
 2
 0 0 1280 1024 
 1280 0 1024 768

====Accessing the Client's Environment when in Client Server ====

EXECUTE '*sys -M set >Workfile-[session].txt

This is really a workaround as BR does not grant direct access to the CLIENT environment variables.

A Recomendation is to add a "Prefix" to each of the clients environment, as an example "CS_".

A Few examples that might be of interest

* CS_USERNAME       = The actual user logged on to the workstation
* CS_COMPUTERNAME   = The actual computername of the workstaiton.
* CS_TEMP           = The actual %TEMP% folder for the workstation.

The following is a "Snipet" of code that reads the client environment.
** NOTE:  The following code won't work on it's own **

  39032   DIM Cs_Worked$*512,Tempenv$*2048,Addstr$*3, Leftstr$*2048, Rightstr$*2048
  39035   LET Cs_Worked$='Failed Execute of: *sys -M set > "'&Cs_Textfile_Make$&'"'
  39040   EXECUTE '*sys -M set > "'&Cs_Textfile_Make$&'"' ERROR XIT_FNCS_ENV
  39045   LET Cs_Worked$='Failed to Open: '&Cs_Textfile_Open$
  39050   OPEN #1: 'NAME='&Cs_Textfile_Open$,DISPLAY,INPUT ERROR XIT_FNCS_ENV
  39055   LET Cs_Worked$=""
  39060 STARTLOOP: ! 
  39070   LET Addstr$="CS_"
  39080   DO 
  39090     LINPUT #1: Tempenv$ ERROR XIT_LOOP
  39100     LET Gw_Wholeline=Len(Rtrm$(Tempenv$)) !:
            LET Gw_Addlen=1 !:
            LET Gw_Posfnwp=Pos(Uprc$(Tempenv$),"=")
  39110     IF Gw_Posfnwp>0 THEN 
  39120       LET Gw_Equal =Pos(Tempenv$,'=')
  39130       LET Gw_Nextequal =Pos(Tempenv$,'=',Gw_Posfnwp+Gw_Addlen)
  39140       IF Gw_Equal > 0 THEN 
  39150         LET Leftstr$ = Addstr$&Tempenv$(1:Gw_Posfnwp-1)
  39160         LET Rightstr$ = Tempenv$(Gw_Posfnwp+1:Gw_Wholeline)
  39170         LET Setenv(Leftstr$,Rightstr$) ERROR 39180
  39180 ! Should SETENV FAIL, Ignore it
  39190       END IF 
  39200     END IF 
  39210   LOOP 
  39220 XIT_LOOP: ! End of Startloop
  39230   CLOSE #1: ERROR 39240
  39240 ! 
  39260 XIT_FNCS_ENV: !
