---
title: MyEdit_(BR_Edition)
file: MyEdit_(BR_Edition).md
category: 00-configuration
subcategory: 00-configuration/installation-tooling
kind: config-directive
related: [editor, Business Rules!, 4.18, Mills Enterprise, Western Canadian Software, Ryan J. Mills, Lookup project, refactoring, variables, labels]
---
**MyEdit - BR Edition** (**MyEditBR**) is the first third-party `editor` to be specifically written to support the `Business Rules!` language.

It is the most popular editor for Business Rules! `4.18`+ editing

With it's high level of integration with BR! and the built-in capabilities MyEditBR will become a valued tool for all BR! developers.  MyEditBR is based on SynEdit[http://synedit.sourceforge.net/].

==Extrenal Link(s)==
*[http://www.mills-enterprise.ca/ Mills Enterprise Website]
*[http://support.mills-enterprise.ca/ Mills Enterprise - Support Forums]

==Support==
MyEditBR is the product of `Mills Enterprise` with the support of `Western Canadian Software`.  

The support is handled by `Ryan J. Mills` and he can typically be reached on the BR Forums, the Mills Enterprise Website or via his private email address.

There are two versions of MyEditBR: **Free** and **Supported**.

While MyEditBR is free to download and use, the free version has certain features and capabilities turned off.  You will still be able to use MyEditBR for your average day to day BR! programming responsibilities.

The supported version of MyEditBR gives the user a license to more advanced features found in the program.

Please note that there is only one program.  The supported features are turned on with a valid support license.  It is easier to describe the differences as if they were from two separate programs.

Here is a list of current features showing the differences between the two versions:

* **Number of open files**<br>- Free version is limited to 5 open files at any one time.<br>- Supported version is unlimited.
* **Color and Language Support**<br>- Free version doesn't support importing/exporting color and language customizations from within the editor.<br>- Supported version has built-in importing/exporting capabilities.
* **Automated Bug Reporting**<br>- Free version doesn't provide this.<br>- Supported version will offer to submit bug report directly to Mills Enterprise via the web.
* **Advanced Editor Options**<br>- Free version doesn't provide this.<br>- Supported version can show modified line statuses and supports editing in either editor while in Split View mode.
* **BR Support**<br>- Free version doesn't provide this.<br>- Supported version integrates directly with BR to provide direct editing of .WB/.BR files and compiling back to .BR/.WB files.  As well as providing on the fly native BR syntax checking while editing (appears as additional HWEs)
* **Advanced Debugging Features**<br>- Free version has the standard debugger support<br>- Supported version provides advanced capabilities like Conditional Breakpoints.
* **Program Support**<br>- Free version doesn't provide this.<br>- Supported version provides additional features such as Checking for Updates.

This list is not complete and will be updated as completed features get added to the program.

The licensing terms have not been finalized to date as such all copies of MyEditBR available from the ADS FTP site and directly from Mills Enterprise (Ryan Mills) have a temporary license provided that will expire after a given date.

To see the details of the currently installed license, open the Help|About program menu item.  (Doing so on a Remote Desktop Connection is very very slow and may take a long time for the about dialog to fade away)

==Installation==
*To move the keyboard shortcut assignments from one installation to another copy the [Program Installation Directory]\MyEditBR.actbindings file.

*To move your color setup for any or all languages use the Help>Export and Help>Import options.

*To implement the BR Wiki as context sensitive help, see the `Lookup project`.

==Portable Installation==

/forceportable is the command line option needed to make MyEditBR behave properly on a USB install.

You need the following setup (Manually configured):

# Make a folder on your USB key.
# Copy all files and folders where you have MyEditBR installed on your main machine to the folder created in Step 1. (This will typically be "c:\program files\mills enterprise\myeditbr".)
# Copy all files and folders from your MyEditBR data directory into the folder created in Step 1. (This data folder will be found in one of two different places depending on the operating system you have. WinXP: "c:\documents and settings\(your username)\Application Data\Mills Enterprise\MyEditBR") (Please replace (your username) with the appropriate value. Smile)

You need to edit your brconfig.sys file and add the command line option /forceportable) it to the EDITOR option there as well as point it to your new USB install of MyEditBR.

Once that is done, you should be good to go.

==Features==
* **Hints Warnings and Errors (HWE)**
**Built in checking for the most commonly encountered problems when moving from the standard BR editor to MyEditBR.
* **Syntax Highlighting**
**Color coded syntax highlighting provides easy visual ques to program code.
* **Code Completion**
**Providing quick shortcuts to long function names as well as showing the parameters of current function
* **Refactoring**
**The latest versions of the application support `refactoring` of `variables`, `labels` and `named forms`.
* **Line Renumbering**
**As powerful as BR but with additional capabilities.
* **BR Debugger** (requires BR! `4.18`+)
**Visual Debugger, Watches, Breakpoints, Conditional Breakpoints (Supported version only), Hover over tool tip variable evaluation and more.
* **Re-mappable Keyboard Shortcuts**
**Don't like a given keyboard short cut, then change it!
* **Highly Customizable**
**Persistent configuration changes between runs of the application.  Includes window and tool window size and position storage and configuration persistence.
* **Full Multi-Monitor Support**
**If you work on a laptop with an additional monitor at work but not at home, MyEditBR will always start up on the correct monitor.
* **Live Development**
**New features can be added/considered on request
* **Alt+Mouse Scrolling Changes Font Size**
**This is also implemented as keyboard shortcuts (Ctrl+Shift+< and Ctrl+Shift+>)

==Settings Files==
To copy settings between multiple installations you may need to copy one or more of the following files.

*MyEditBR.actbindings - Primarily Menu / Tool bar shortcuts (action bindings)
*MyEditBR.ardetails - Auto-Recovery details in case of a crash during editing
*MyEditBR.broptions - BR specific options (HWE for example)
*MyEditBR.desktop - Screen docking layout (Includes dockable tool windows)
*MyEditBR.exclusions - BR HWE Global Exclusions
*MyEditBR.fileextensions - Additional file extension handling (.cfg -> text file)
*MyEditBR.filesmru - MRU file list
*MyEditBR.genops - Editor General options (spell checker, AutoNewFileType, etc)
*MyEditBR.highlighters - Additional custom highlighters (??)
*MyEditBR.options - SynEdit specific options
*MyEditBR.pagesetup - SynEdit print page setup options (??)
*MyEditBR.searchhistory - Search/Replace history
*MyEditBR.sessionmru - MRU session file list
*MyEditBR.usertools - User Tools
*MyEditBR.visparm - Editor Visual parameters (Editor State and Position, Tool bar states, positions and customizations)

===Additional Tools===

Lexi is an additional tool that can be installed and used with MyEditBR to enhance the BR programmer's efficiency. 
 

==See Also==
*Errors `1154` and `1156`
