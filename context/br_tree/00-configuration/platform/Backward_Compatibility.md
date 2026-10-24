---
title: Backward_Compatibility
file: Backward_Compatibility.md
category: 00-configuration
subcategory: 00-configuration/platform
kind: config-directive
related: [Business Rules!, 4.1, 2D controls, NWP, BRC, OPTION, statements, BRConfig.SYS, Option (Config), FKey]
---
`Business Rules!` `4.1` provided many new features, including support for a more modern look and feel, `2D controls`, and `NWP` improvements, as well as many others.  However, it also demands more careful syntax checking then previous versions.  This means that a lot of times programs that ran fine in earlier versions of BR no longer work in later versions.  To address this problem, `BRC` has provided the BR Developer with many `OPTION` `statements` that can be added to your `BRConfig.SYS` file to disable the advanced syntax checking and allow your old programs to continue to work under the latest version of BR.

Here is a list of the `Option (Config)` that are most useful when upgrading and what they do:

  option 14 ! allow multiple locks on same record from duplicate opens, for same file opened twice at same station 
  option 25 ! make file$(0) -> CON: 
  option 27 ! Ignore Invalid Y2K Key Data (err 4120) 
  option 29 ! Save programs as .WB files. (Default is .BR) 
  option 32 ! Suppress notification of error 6245 Which indicates an invalid or unsupported (by BR) escape sequence has been printed
            ! during Native Windows Printing. 
  option 37 ! Cause BR to return old `FKey` value when someone uses the right arrow to exit a field (returns FKey 104 (down arrow)
            ! instead of the new FKey 116 (right arrow)).
  option 38 ! This suppresses an error caused by specification of an N in the trailing attribute position. This Option is provided
            ! only for legacy purposes.
  option 39 ! Suppress colon right alignment for labels.
  option 41 ! Ignore GUI statements when they are encountered in non-GUI mode. 
  option 43 ! Use old style Input Select with respect to setting `CURFLD` to the `NXTFLD` value when a selection is made.
  option 44 ! Make the mouse wheel produce the same result as the arrow keys when control is returned to a program via the 
            ! E, L or X field attributes. Without this Option, the mouse wheel returns Fkey results of 124/125 (up arrow/down 
            ! arrow). With this Option it returns 102/104 during INPUT FIELDS and 105/106 during INPUT SELECT operations (normal 
            ! arrow key responses). Note: Option 44 is NOT needed to use the mouse wheel. It only pertains to Fkey results 
            ! with E, X or L. 
  option 45 ! allows the old method of extended field specification in addition to the new method. 
  option 47 ! Enable the continued use of PRINTER= in OPEN statements.
  option 50 ! Suppress theme usage for text controls. This enables the Windows classical look under XP. 
  option 55 ! BR realigns fields in accordance with its CPIsetting. If the font in use doesn't quite match the CPI and the
            ! print line contains spaces (causing BR to position each column). then diffferent rows may not line up with the
            ! rows above them. This option causes BR to specifically position each character. This slows things down a bit, but
            ! can be necessary in certain circumstances.
  option 56 ! Make SRCH return -1 when a matching index is not found.
  option 58 ! Allow ON FNKEY syntax (in addition to ON FKEY).
  option 60 ! Save in the 4.2/4.3 object format (save level 38) so a pre-5.0 BR can load the
            ! program.  BR no longer writes the 4.18-and-earlier format at all, though programs
            ! already in it still load.  Also sets option 74.
  option 62 ! Use line draw border specification.
  option 65 ! Ignore ON ATTN statements.
  
  `FieldBreak Min_Spaces` 2 ! Automatically separate fields based on spaces
  
  `Config GUI Off|gui off` ! Disables NEW GUI Controls and Syntax.
 
You may not need all of these options depending on your situation, and your usage of no-longer-supported syntax. But this list should be a good starting point for people attempting to make the upgrade from BR 4.0 to BR 4.2
