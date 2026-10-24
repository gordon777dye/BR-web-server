---
title: Help_Facility
file: Help_Facility.md
category: 20-io-screen
subcategory: 20-io-screen/windows-cursor
kind: statement
related: [READY, field help windows, Full Screen Processing Statements, Field Help, WBHelp.exe, READY mode, 4273, ERR, LINE, ON HELP]
---
The **help facility** allowed documentation to be accessed either from `READY` mode (for programmers) or by a running application (for operators). This requires the presences of three files: wbcmd.wbh, wbcmd2.wbh, and wbcmd3.wbh. Since the information in these files is relevant to versions 3.4, a better source for Help topics is this wiki, which is constantly being updated. Many programmers also choose to link the Help files to the wiki for easy access.  

The enabling of the help facility causes Business Rules to access a text file, from which it displays a help screen. The particular screen that Business Rules displays is determined by the screen's topic name.

It is important to note that there is a difference between this help facility and `field help windows`. These two features can work together to provide the user with two-level help information, but field help windows are specified in a much different manner than the help facility's help information is. See the `Full Screen Processing Statements` and the `Field Help` sections for more information about field help windows.

The information in this page has been divided into five main sections: terminology, using the help facility, creating help text files, programming to access help, and customizing Business Rules help files.

===Installing Help Files===
Help text files are included with the first purchase of any Business Rules system. To install these files so that Business Rules help facility will access them, see the Installation instructions which accompanied your system.

To install your own text files, see `WBHelp.exe`.

===Initiating the Help Facility===
Business Rules allows the use of two different keys to access the help facility:
:# The <HELP> key accesses help both when Business Rules is in READY mode and when it is in RUN mode. This is the key that end-users must press in order to get help information. Your Business Rules system is configured to make Ctrl-Y operate as the <HELP> key, but you can remap another key to handle this operation if it will better suit your applications.
:# F1 accesses help when Business Rules is in READY mode only. Pressing of this key while Business Rules is running an application will not access help.

===Help Facility===

===Search location order===
The HELP file search now uses the following directory sequence:
:Current Directory
:Base Node of First Drive Statement (where second param points)
:BR Starting Directory<br>

Note that the HELPDFLT statement refers to filename not dirname.

==Help Terminology==

Many of the options and functions that are associated with the help facility are identified with names that include the word "help":

;Help (or Help facility)<br>
This term refers to the portion of Business Rules that handles help processing. Most often identified simply as help (with a capital H), it is the main topic of this chapter.

;HELPDFLT<br>
This is a BRConfig.sys specification that identifies the default keyword and file name that should be accessed by help when the <HELP> key is pressed.

;Help Error Condition<br>
The HELP error condition is a keyword that can be included with the ON statement or at the end of input or output statements. It traps the pressing of the <HELP> key and causes processing to branch to a specific routine.

;HELP$ function<br>
The HELP$ function causes Business Rules to enter HELP mode and to display a specific help topic or menu. It is frequently used in conjunction with the HELP error condition.

;<HELP> key<br>
The <HELP> key is Ctrl-Y in Business Rules, while a program is running, although it can be easily remapped. It is the key that operators must press in order to receive help information. In READY mode, simply press F1.

;HELP mode<br>
When the help facility is being accessed, Business Rules is said to be in HELP mode. The keyword HELP will appear in the left corner of the status line when Business Rules is in HELP mode.

;Help text files<br>
All the information that help accesses comes from one or more help text files. These files can originate from ordinary text files, but they must be processed by the WBHELP compiler before Help can use them.

;BRHELP compiler program<br>
This program is included on the BRC FTP site. It compiles ordinary text files into help text files that can be accessed rapidly by the help facility.

==Using Help==

===Accessing Help from Ready Mode===
When help is called from `READY mode`, Business Rules! assumes that the operator is a programmer needing Business Rules! information. It responds according to the following three context indicators:

:# A command or statement is typed in on the 24th line. When F1 or <HELP> is pressed, Business Rules immediately enters help and displays a description of and syntax diagram for the specific command or statement.
:# An error has occurred. If the programmer has arrowed down at least one line (the line must be blank) and then pressed F1 or <HELP>, Business Rules displays information about the particular error that occurred.
:# The 24th line is blank and no error has occurred. Business Rules displays the main help menu.

For instance you could type the following keyword on the command line & press <HELP>:

 GOSUB <HELP>

Business Rules will immediately respond by displaying a screen that describes the GOSUB command.

`image:Gosubhelp.jpg`

Or, you could generate an error by entering the following line:

 DIM <CR>

If you press the down arrow and then press F1 or <HELP>, Business Rules will display a description of error code 1011:

`image:dimhelp.jpg`

If the command line is blank when <HELP> is pressed, Business Rules will branch to a screen that displays the main help menu:

`image:helpmenu.jpg`

Hitting the Escape key at any time will return you to BR in ready or error mode.

===Technical Considerations===
:1.) From READY mode, Business Rules branches only to help command or statement topics -it will not branch to other help topics (such as BRConfig.sys specifications or function descriptions) unless HELP mode has already been accessed or unless the topic is called by a program.
:2.) If F1 or the <HELP> key is pressed while an unrecognized string is on the command line, Business Rules will return help error `4273`. In contrast to other errors, this error will not cause the system to beep, the error code number will not appear in the status line, and the values of `ERR` and `LINE` will not be set. Instead, Business Rules! displays the following message on the 23rd line of the screen:

 Help Error 4273  *UNRECOGNIZED,c:\wbcmd.wbh

:3.) When accessing specific help topics from READY mode, you must type commands and statements exactly as they would normally be typed before Business Rules will branch to them as a help keyword.
:a.) For commands, this means that the command keyword (or its abbreviation) must be the first string on the command line. It does not matter what follows the keyword.
:b.) For statements, this means that the statement (or its abbreviation) must either be the first string on the command line (as in an immediate-mode statement), or it must be preceded by a valid line number of up to five digits in length. It does not matter what follows the statement keyword.
:4.) Business Rules branches to the LET topic from READY mode, even when the LET keyword is not on the command line, when three conditions are true:
:a.)  the command line contains a line number followed by any valid variable name;
:b.)  the valid variable is not also a valid keyword; and
:c.)  the F1 or <HELP> key is pressed to access help.
:5.) In a few special cases, Business Rules will branch to a short menu of possible topics rather than to the topic itself. This occurs primarily in situations where the first word of a two-word statement (such as PRINT FIELDS) is its own statement (PRINT), or where a single statement has numerous applications and more than one syntax diagram (such as OPEN).

===Accessing Help from an Application===

An operator can attempt to access help while an application is running by pressing <HELP>. If the application is programmed to utilize help, execution will pause and Business Rules will display a topic in the following order of precedence:

:1.) If Business Rules is in ERROR mode and the variable ERR has been set, help will display text about the error code that appears on the command line.
:2.) If the HELP error condition has been coded at the end of the keyboard input statement being processed when <HELP> was pressed, Business Rules will branch to the related error-handling routine (which will most likely contain a HELP$ function). help will display whatever topic is specified in the HELP$ function.
:3.) If neither of the two previous conditions exist, Business Rules will display the topic which is specified by the BRConfig.sys file HELPDFLT specification (or, if this specification has been overridden by the CONFIG command, the most recently specified HELPDFLT topic will be displayed).
:4.) When Business Rules is in HELP mode, the message "Page down for more" will now be displayed in the message area of the status line when there is more than one screen for the selected topic.

===Help Keys===
Moving around through help is primarily accomplished through use of the function keys. These keys will have somewhat different functions depending on whether you are accessing a help text screen or a help menu screen. Text screens contain textual information about a particular topic. Menu screens present a list of numbered topics; selection of one of these menu topics allows the user to view the text for that same topic.

The following table shows the actions of each key according to the type of help screen being used:

`Image:helpfacility.jpg`

===Selecting a Menu Item===

Selection of a particular menu item causes Business Rules to take one of two actions: it will either display textual information about the selected topic or, if no text exists, it will display a menu of subtopics, which are related to the selected topic. Likewise, the selection of any subtopic item will either lead to a related item display or to another menu of subtopics. There is no limit to the number of menu levels, which may exist beneath a main topic item.

If a menu selection has both text and a related topic menu, the system will display the text first. The related topic menu can then be accessed from that display by pressing the F1 key.

The individual items on a help menu can be selected in three different ways. The following main menu screen, which can be reached from Business Rules READY mode by pressing <HELP> or from within help by typing in CMDMENU and pressing <Enter>, will be used to demonstrate these three methods.

:1.) Use the arrow keys to place the selection bar on the desired item and press <Enter>. To select the "Function descriptions/syntax" option from the above menu using this method, you would press the down arrow key twice so that the selection bar rested on the third topic description. Pressing <Enter> would then cause a submenu for the Functions topic to be displayed.
:2.) Enter the number of the desired item on the command line of the screen and press <Enter>.To select the "BRConfig.sys specifications" option using this method, you would type in the number 7 and press <Enter>. This would cause a submenu for the BRConfig.sys topic to be displayed.
:3.) Use the F9 key to toggle to a screen of topic keywords. Type in the keyword for the topic you would like to see, then press <Enter>.To select the "Help on Help" option using this method, you would first note that this topic is the fourth item on the menu.

Then you would press the F9 key, which would cause the a new help screen to be displayed, the keyword equivalent to the original main menu screen. The keywords you see here are the same keywords that are coded into the help text files for these topics. To get to the menu for the help on help topic, you would type in the keyword HELP and press <Enter>.

The main benefit of typing in a keyword to access a specific help topic is that it allows you to access any topic from any screen. The only requirement is that you must either know or be able to find the correct keyword to type in.

In the help facility files, names of commands, statements, functions, and BRConfig.sys specifications are usually valid keywords. The keywords for error codes consist of the letters ERR followed by the four- digit error code.

===The Related Topics List===

When a help topic has both text and a related topic menu associated with it, the text will be displayed whenever the topic is selected. The 24th line of the text screen will show the prompt "Press F1 for related topics". Pressing the F1 key will cause the submenu screen to be displayed.

===Retracing your steps through help===

The F2 key allows you to retrace the sequence of help screens you have viewed. When F2 is repeatedly pressed, help will recall up to fifteen successive screens before it redisplays the most recently viewed screen.

It is possible to exit the help facility with the F2 key. If five help screens have been viewed and the F2 key is pressed six times, for instance, Business Rules will return to READY mode (or to the executing program).

==Creating a help text file==
Help text files contain all the information Business Rules help facility displays. A single text file is made up of many topic definitions, the elements of which are described in the following sections.

Help text files can be created with any standard word- processor. The final form of the file must be ASCII text characters, which is the same as a Business Rules display file.

Before a text file may be accessed by the help facility, it must be compiled by the WBHELP compiler program. This compiler program, which must be executed from the native operating system, can be downloaded from the BRC FTP site. Instructions and tips for using the compiler are included in the section below.

===Topic Definition===
;Purpose:
The "topic definition" consists of everything that the help facility needs to provide an end-user with information about one topic. The information in the topic definition tells help what to display on text screens and what to display on menu screens.

;Requirements:
A single topic definition typically consists of several elements: a starting topic name, a menu description, one or more related topic references, text about the topic and an ending topic name. (The beginning and ending topic names must be identical.)

;The following is an example of a typical topic definition:
`Image:Help0152.jpg`

====Topic Name====

;Purpose:
Business Rules accesses textual information by its "topic name", a unique keyword which is coded at the beginning and the end of the topic definition and which is preceded by a single colon (:).

;Requirements:
The topic name keyword may be up to 33 characters in length and may contain any standard keyboard characters except commas or spaces; its preceding colon (:) must appear in the first column of the text line.

;Technical Considerations:
:1.) The starting topic name (the topic name that identifies the start of the text) should be followed by a menu description.
:2.) The ending topic name may be followed by the RETURN keyword, which works in conjunction with the HELP$ function to return a keyboard scancode to the program. (See "Passing values to the program with Help" for more information.)
:3.) Topic names are never displayed by help except when F9 is used to toggle between a screen of menu descriptions and its topic names equivalent.
:4.) When Business Rules is in HELP mode, an end-user may type in the topic name and press <CR>; Business Rules will immediately display the text for that topic.
:5.) One help topic may include many other topics or part of another topic; there are no restrictions as to where the beginning or ending topic names must be specified.

====Menu Description====

;Purpose:
The menu description is a short phrase that describes the topic being defined. It is used by help in the construction of related topic menus.

;Comments:
Help constructs menus from the information provided by two elements in the topic definition: the list of related topic references and the menu description. The list of related topic references tells help which topics should be included on the menu. The menu description (which is usually coded with the original topic definition) identifies the exact text that should be used to describe the topic.

Help displays menu descriptions in the following two circumstances:
:1.) When help displays a menu of related topics, the menu description of the current topic is displayed at the top of the screen. In the following example, for instance, the menu description "AUTO command/syntax" appears at the top of the related topics menu for AUTO:
`Image:Help0153.jpg`<br>
The text file line (consisting of both the topic name and the menu description) that identified "AUTO command/syntax" as the menu description for AUTO is as follows:

:AUTO  AUTO command/syntax

:2.) When help displays a related topics menu, it uses the original menu description for each menu item unless a substitute menu description has been specified (see below for information about specifying substitute menu descriptions). The following topic definition, for instance, sets up a submenu for the topic EDIT COMMANDS:

:EDIT COMMANDS  Other editing commands
::AUTO
::DEL
::LIST
::RENUM
::TYPE

This topic definition instructs help to create and display a menu of topic choices whenever the EDIT COMMANDS topic is accessed by a help user.<br>
Each of the related topic references (preceded by two colons in the above example) will be a numbered menu item. Before creating the menu, help actually refers back to the main topic definition and locates the menu description for each of the related topic references. The actual menu would appear as:

`Image:Help0154.jpg`<br>
;Requirements:
The menu description appears on the same line as the topic name, although it must be separated from the topic name by one or more spaces. It can be any combination of words, letters or numbers. The only requirement is that it cannot exceed 60 characters.

;Technical Considerations:
:1.) The menu description, which is included in the main topic definition, is considered the default; Business Rules will use it in all help menus that reference the topic unless a substitute is specified.

If you wish to specify a substitute menu description for a particular topic in a particular menu, you may do so by placing the new description immediately after the related topic reference. A substitute menu description is displayed only in the menu for which it is specified.

The following topic definition instructs help to display the default menu description for each of the related topic references except LIST. The menu description for LIST is to be "LIST editing" instead.

:EDIT COMMANDS  Other editing commands
::AUTO
::DEL
::LIST  LIST editing
::RENUM
::TYPE

:2.) The manner in which Business Rules displays menus with more than 21 topic references is determined by the longest description on the menu. If any one-menu description exceeds 33 characters in length, topics will be displayed in a single column on the screen; PgDn can be used to see additional screens of topics. If all the menu descriptions contain 33 characters or less, up to 42 topics will be displayed (in two columns) on the screen.
:3.) Although the menu description is not a required part of the topic definition, it is strongly recommended. Omitting the menu description, either by accident or on purpose, will cause Business Rules to display help menus with blank options, as in the following example (item 2 is missing because there is no menu description):

`Image:Help0155.jpg`<br>
The only ways to discover the contents of option 2 above are to either press F9 for the topic name (topic names are frequently too cryptic for the end- user to understand), or to select the topic and read its text.

====Related Topic Reference====
;Purpose:
Related topic references identify where the help user may be able to find additional information about the current topic. When Business Rules is in HELP mode, each related topic reference is included on a menu; the menu can be accessed from the current topic by pressing F1.

;Comments:
It is important to note that the related topics menu is a cross-referencing device: any item which is specified, as a related topic (unless it is preceded by an asterisk) must elsewhere be defined as a main topic.

A related topic item which is preceded by an asterisk (*) is actually a string value which may be passed back to the program.

See "Passing values back to a program with Help" for more information.

;Requirements:
Related topic references must be specified on the lines immediately following the topic name/menu description; each related topic reference must be preceded with a pair of colons (::).

Unless an asterisk precedes it, the keyword, which is used as the related topic reference, must be defined elsewhere in the file with a full topic definition.

In the following topic definition example, the topics END, SKIP and STOP are identified as related topic references. When a help user accesses the CODE topic and then presses the F1 key to see the list of related topics, each item displayed will be the menu description from the item's original topic definition. END, SKIP and STOP must be defined elsewhere in the text file (or group of text files, as long as all are compiled by WBHELP into the same output file):

:CODE  CODE function
::END
::SKIP
::STOP
:::Code function
:::(text goes here)

;Technical Considerations:
:1.) An optional menu description may be included after each related topic reference. In such a case, help will display the specified menu description instead of the description that appears in the main topic definition. This substitute menu description is displayed only in the menu for which it is specified.
:2.) Topic definitions can be interleaved and overlapped with one another so that two or more definitions can share some or all of the same text. In such cases, it is important to note that related topic references cannot be shared. The related topic references for a particular topic must start on the first line after the topic name and menu description is identified. As soon as help encounters a line that starts with something other than two colons (::), it assumes that the list of related topic references has ended.
:3.) There is no limit to the number of related topic references that may be specified for a particular menu.
:4.) Business Rules displays either 21 or 42 menu options per screen, depending on the length of the longest menu description on the menu.
:5.) Related topic references appear in the same order on the help menu as you enter them in the help text file. If you wish to alphabetize the options or place them in any certain order, you must do this from the text file.

====Text====

;Purpose:
The text portion of a topic definition provides information about the topic. It is this text that the help user actually sees when the topic is accessed.

;Comments:
It is helpful for the end-user if a title (possibly the same as the menu description) is included at the top of the text description.<br>
Text is not a required element of the topic definition. When a help user selects a topic that does not include text, Business Rules displays the related topics menu for that topic. In the following example, for instance, two topics are defined. In the first, no text is specified. When a user selects the CMDMENU topic, Business Rules will immediately display a menu with its seven related topics choices. In the second, text is specified. When a user selects the SHARE SPEC topic, the text will be immediately displayed; the user will then be able to press F1 to see the related topics menu.

:CMDMENU  Business Rules Help - Main menu
::COMMANDS
::ERROR CODES
::FUNCTIONS
::HELP
::STATEMENTS
::TERMINOLOGY
::BRCONFIG.SYS

:SHARE SPEC  "Share-spec definition"
::NOSHR
::SHR
::SHRI

Share-spec
:Indicates that one of three share parameters (NOSHR, SHR, SHRI) should be specified.
:See the related topics menu for more information about each.

Business Rules help screens support all ASCII characters. Many word-processors have features that are not ASCII-compatible, BRC suggests that you investigate the compatibility of your word-processor's features before writing extensive help text files.<br>
Some hardware types will not support certain graphics characters even though they are ASCII-compatible. See APPENDIX I Terminal Consideration for specific information and recommendations regarding the use of such hardware.

;Requirements:
Text for the help facility may be of any length and may encompass any number of screens. The maximum width of a single text line is 79 characters.<br>
Business Rules accepts the use of attributes to provide special display emphasis to text in help. See the following section for additional information about using display attributes in text files.

;Technical Considerations:
:1.) The carat character (^) and the vertical bar () carry special significance in help text files (see the following section on display attributes for more information). Business Rules suppresses each first occurrence of these special characters from the display. If you wish to actually display one of these characters, you must indicate it twice in the text file, as follows:

:Press ^^Y to quit

Business Rules would display the above text file line as follows:

:Press ^Y to quit

The carat and vertical bar characters are suppressed from the text portion of a topic definition only; they do not apply to the menu description.

===Display Attributes===

;Requirements:

Display attributes (highlight, reverse, underline, etc.) may be included in any help text file. The beginning of the text to be emphasized must be marked with a starting vertical bar (|) and one or more uppercase display attributes (H, B, U, R, N or I); the end of the text to be emphasized should be marked with an ending vertical bar.

When no ending vertical bar is included, help assumes that the display attributes are to remain active for the remainder of the text line. Help automatically turns off all display attributes at the end of each text line. Display attributes must be respecified for each line of text they are to effect.

A space between display attributes and the text they are to emphasize is required when the first letter of the text is also a display attribute (H, B, U, R, N or I).

The following is an example of the use of the U attribute in a text file:

 | U This text will be underlined |

;Technical Considerations:
:1.) The vertical bar/attribute combination will take up a space on the screen when help displays the topic text.
:2.) Attribute combinations will operate the same in help text files as they do in Business Rules programs, with one exception: the I attribute (for invisible) must be specified by itself when it is used in a help text file.
:3.) The vertical bar character is automatically suppressed by help, even when it is not immediately followed by a display attribute. If you wish to have a single vertical bar displayed on a text screen, two vertical bars (||) must be specified in the text file.

===Interleaving and Overlapping Topics===

One help topic may include many other topics or part of another topic; there are no restrictions as to where the beginning or ending markers must be specified. The only requirement is that subtopic items must be listed immediately after their main topic descriptions (and prior to any other main topic description). 

===The BR Help Compiler===

==Programming to Access Help==

By utilizing various programming techniques, a Business Rules program can perform several help operations: it can call a help topic directly; it can trap a user request for help (pressing of the <HELP> key) and call a help topic according to the context of the situation; or it can pass a menu selection or other values back to the application.

The programming elements that go into accomplishing these actions include the following:

:1.) Using the HELP$ function to call a help topic.
:2.) Using the HELP "error" trap keyword and/or `ON HELP` to trap the pressing of <HELP>.
:3.) Using the CURFLD function and the help text file's "mark" to make context-sensitive help calls with the HELP$ function.
:4.) Creating help menus with special related topic references (keyword is preceded by an asterisk) to pass a menu value back to the program.
:5.) Using the RETURN keyword (with the "ending topic name" in a help text file) to return a keyboard scancode value to the program.

===The Help$ Function===
;Purpose:
The HELP$ function causes Business Rules to enter HELP mode and to display a specific help topic or menu.

;Comments:
The use of HELP$ is the main way in which a Business Rules application can access the help facility. "Error" processing, which traps the pressing of <HELP>, always branches to another program line which may then utilize the HELP$ function to call a help topic.

`Image:Help1.png|800px`<br>

;Defaults:
:1.) Restore screen upon returning to application.
:2.) Use the file name specified by the HELPDFLT specification in the BRConfig.sys file.
:3.) Append .wbh.
:4.) Display from the first line of the first screen of topic text.

;Parameters:
An asterisk (*) may precede the keyword when the screen should not be restored upon returning to the application from help. This option is especially useful for Unix and Linux systems. (This asterisk should not be confused with the related topic name option that returns a keyword value to the program.)

"Keyword" is the name of the topic that is to be displayed as soon as Business Rules enters HELP mode.

"Filename" is the help file within which the keyword topic definition can be found.

"Mark" is a numeric value (either variable or constant) which corresponds to a chronologically placed carat symbol (^) in the help text. The mark parameter allows you to specify the portion of the help text which is to be displayed first. If mark equals 3, then the text located after the 3rd carat in the help text will be the first text displayed on the screen (all other text for the topic will be accessible by use of the arrow keys).

;Technical Considerations:
:1.) The NOKEY error condition can be used with HELP$ function calls to trap situations where a keyword or topic cannot be found. The error code is 4273. When this error occurs, the system does not set ERR or LINE. This prevents 4273 errors from conflicting with prior errors that may be used with RETRY or CONTINUE.

===Passing Values to a Program with Help===
Business Rules provides three different methods for passing values back to a program from help:

:1.) A keyboard scancode can be passed when HELP$ is used in conjunction with the help text file RETURN keyword (this operates the same way that the KSTAT$ function does).
:2.) A keyword can be passed when HELP$ is used in conjunction with the help file asterisk (preceding a related topic name) option.
:3.) The operator may pass a string back to the program by entering text on the help command line and pressing ESC or F2.

Passing Keyboard Scancodes:
The RETURN keyword, when placed after a topic's ending marker in a help text file, will work in conjunction with the HELP$ function to return a keyboard scan code.

The RETURN keyword may be coded into the help text file (after the ending topic name marker), as in the following example:

 :ERROR  File sharing error
 
 The customer file is in use right now.
 
 Press F9 to return to the menu or any other key to retry the operation.
 :ERROR RETURN

The Business Rules routine to test the value of the key pressed would be:

 01100 SHARETRAP: X$=HELP$("ERROR")
 01200 IF X$=HEX$("0900") THEN GOTO MENU ELSE RETRY

In line 1200, the 0900 is the scancode for the F9 key.<br>
Passing keyword values to the program

When related topic references in a help text file are preceded with an asterisk, they may be used as menu items which HELP$ will access. These subtopics are not actually subtopics with associated text and menus; rather, they are keywords that are returned to the program.

The following is an example of a help menu that passes the selected program's name back to the calling program:

 :MENU
 ::*ORDERENT.BR  Order Entry
 ::*ORDERPRT.BR  Order Print
 ::*ORDERUPD.BR  Order Update
 :MENU

The Business Rules program to display the above menu is:

 00100 X$=HELP$("*MENU,filename")
 00110 IF X$<>"" THEN CHAIN X$
 00120 STOP

NOTE that the keyword MENU is preceded by an asterisk (*) in line 100. This asterisk is not to be confused with the related topic name asterisk; it prevents Business Rules from restoring the screen when leaving help, which is especially desirable on Unix and Linux systems.

===Passing text back to the program===

The operator may pass a string back to the program by entering text on the help command line and pressing ESC or F2.

===Passing Keyboard Scancodes===

The RETURN keyword, when placed after a topic's ending marker in a help text file, will work in conjunction with the HELP$ function to return a keyboard scancode.

The RETURN keyword may be coded into the help text file (after the ending topic name marker), as in the following example:
:
 :ERROR File sharing error
The customer file is in use right now.

Press F9 to return to the menu or any other key to retry the operation.
 :ERROR RETURN

The Business Rules routine to test the value of the key pressed would be:

 01100	SHARETRAP:X$=HELP$("ERROR")
 01200	IF X$=HEX$("0900") THEN GOTO MENU ELSE RETRY

In line 1200, the 0900 is the scan code for the F9 key.

===Trapping Help Calls with an Error Condition===

Business Rules error processing capabilities allow you to specify HELP as an error condition both for the ON statement and at the end of a statement. In both cases, error processing is initiated when the <HELP> key is pressed.

The following example shows the HELP error condition as it may be coded at the end of a line. This type of coding causes a branch to another program line -but it does not automatically initiate help. As in this example, however, the branched-to line may call help with the HELP$ function:

 00010 INPUT FIELDS A$:X$ HELP 100
 ....
 00100 HELP$(KEYWORD$) : RETRY

ON HELP may be used to invoke help processing directly. It will take action when the HELP keyword has not been coded at the end of a program line.

When ON HELP SYSTEM (the default condition) is active and the <HELP> key is pressed, the "keyword,filename" specified in the BRConfig.sys's `HELPDFLT` specification is processed by help. If HELPDFLT is not specified, ON HELP SYSTEM operates as ON HELP IGNORE. Program interruptions which occur due to ON HELP SYSTEM always take place between lines rather than during the processing of a line.

===Context Sensitive Help Calls===

Use of the `CURFLD` function for the value of the HELP$ "mark" parameter allows a program to call help topics according to the user's current field. This option is valuable when a single help topic describes all the fields on a screen.

The operator can be directed to the exact text that explains the valid entries for the field. In the following example, OT will be interpreted as the second CURFLD. If the cursor is positioned on the OT field and the operator pushes the help key, the help text at the second mark (^) will immediately be displayed.

 00100 INPUT FIELDS MAT FLD$: HRS,OT,DT,SICK HELP 900
 ...
 00900 HELP$("HOURS.ENTRY", CURFLD) : RETRY

If the cursor is positioned on the OT field and the operator pushes <HELP>, help text related to the OT field will immediately be displayed. When the operator returns to the program, the screen will be restored and the cursor will be repositioned at the OT field (or whatever field the cursor was at when the error occurred). This type of cursor repositioning happens when either an `INPUT FIELDS` or a `RINPUT FIELDS` statement is to be executed immediately after the `RETRY`.

==Customizing Help Files==

The first purchase of `Business Rules!` comes with a set of help programs (downloadable from `BRC`) containing an extensive set of ASCII text files related to the operation of Business Rules!.

If you wish to utilize the text files as they have been sent to you, all you need to do is compile them with the `WBHELP` program. (See your Installation instructions or the section on WBHELP for information about this process.)

If you wish to customize the HELP text (for in-house use or for your own customers), you must edit or supplement the files before using the WBHELP program. Read on for more information about this process.

If you wish to access the edited files from READY mode, it is important to remember that the only help file name Business Rules will access from READY mode is `WBCMD.WBH`. Likewise, the default topic name (the topic that Business Rules accesses when no other string appears on the command line and when <HELP> or F1 is pressed) is always CMDMENU.

Customizing the above files for your own or your end- users' use will involve some or all of the following steps:

:1.) Unsqueeze the files.
:2.) Draw the files you wish to edit into a standard word processor or ASCII text editor.
:3.) Edit or isolate the desired text.

Two editing situations that you will likely encounter include the following cases:

:o  Incorporate a single entire file (such as ERRCODES) for use with your end-users' help facility. Before accomplishing this, you will need to review the file and take steps to ensure that all subtopic references continue to correlate to main topics references. The following topic definition, for instance, references CONV as a subtopic.

       :ERR####  Error code ####
       ::CONV
       ::ERRORCODES
       text.....
       :ERR####

Since the main topic definition for CONV is not included in the ERRCODES file, you can do one of three things:

:1.)  Delete the CONV subtopic from the text;
:2.)   Add a topic by the name of CONV to the text;
:3.)   Add the file within which the CONV topic exists to your list of help files to be run by WBHELP (this last option will almost always be highly impractical and time consuming).The second subtopic reference (ERRORCODES) in the above example will not cause the same problems as the first; its main topic definition is included in the ERRCODES file.

:  o  Delete one or more topics from a file.
The important item to consider when you delete a topic from a file is that you must also delete any subtopic references to that topic.

In the following example, F1 is a subtopic reference beneath the topic KEYS. If you decide to remove the F1 definition, then you must also remove the F1 subtopic reference wherever it exists in the file:

`Image:Help0159.jpg`

:4.) Update the INDEX file with any topic definitions or subtopic definitions that you have added to or deleted from the text. It is important to remember that all topic names must be unique and that a subtopic definition must always correlate to an existing main topic definition.

Forgetting to record these changes in the INDEX file will not lead to an execution error, since the file is only a bookkeeping aid. However, it is important that you use some method of keeping track of the keywords you have used; neglecting to do so increases the likelihood of making errors, and it could also cause a great deal of frustration and extra work.

If you keep track of the topic names that you add to a file as you define them, it will be much easier for you to avoid topic name duplication.
