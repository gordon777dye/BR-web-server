---
title: Attribute_(Config)
file: Attribute_(Config).md
category: 00-configuration
subcategory: 00-configuration/config-directives
kind: config-directive
related: [Attribute (disambiguation), config, Attribute (Screen), 0863, BRC, INPUT SELECT]
---
See also:  `Attribute (disambiguation)`

The **Attribute** `config` specification can be used to substitute attribute combinations, such as U/RGB:B, with square-bracketed letters, such as [X], called subattributes ("subatts").

The subattributes can be used in place of attribute combinations wherever they are allowed in programs. This will reduce coding time, repetition and program size. It will also increase portability, decrease processing time and encourage standardization.

{|
|-valign="top"
|width="10%"|**Font types**||FONT=  FONT.TEXT=  FONT.LABELS=  FONT.BUTTONS=
|-valign="top"
|}

====Comments and Examples====
The following BRConfig.sys ATTRIBUTE specification substitutes the attribute combination U/RGB:B with the subattribute [X].

 ATTRIBUTE [X]U/RGB:B

Also, the contents of defined subattributes can be assigned (or copied) to other subattributes, but multiple subattributes cannot be combined by the assignment process. The following BRConfig.sys specification assigns the attribute combination U/RGB:B to the subattribute [X] and the attribute combination R/HRGB:R to the subattribute [A]. Then it assigns the current value of subattribute [X] to subattribute [E] and the current value of subattribute [A] to subattribute [W]:

 ATTRIBUTE [X]U/RGB:B [A]R/HRGB:R [E][X] [W][A]

Wherever attribute processing occurs (such as in PRINT FIELDS and INPUT FIELDS statements), Business Rules will now accept subattributes as long as they have been defined in CONFIG commands or in the BRConfig.sys file. If a subattribute is used but not defined, Business Rules will use the N default attribute setting (which is the same as the current Windows default setting).

The following BRConfig.sys spec assigns the attribute combination U/RGB:B to the subattribute [D]:

 ATTRIBUTE [D]U/RGB:B

When the above attribute spec is active, the following INPUT FIELDS will display a 10-character field in underline (on a monochrome monitor) or in white letters on a blue background (on a color monitor).

 20 INPUT FIELDS "1,1,C 10,[D]:X$"

 CONFIG ATTRIBUTE [J]RH,font=ariel,slant,max

This specifies reverse highlight ariel italics maximum size.

===Syntax===
 ATTRIBUTE [sub-attribute] attributes [defined sub-attribute] [...] 
 *in this syntax description, square brackets are required around the sub-attributes.
`Image:ConfigAttribute1.png|800px`

====Parameters====
In the above diagram, the "subattribute" parameter represents any uppercase or lowercase letter from A to Z. The letter must be specified within square brackets, and the specification is not case sensitive. See the recommended list in the Technical Considerations section below for suggested assignments

The "attributes" parameter represents the set of specifications that identify the visual and control aspects of a screen display. Business Rules will use this attribute combination wherever it finds the preceding subattribute in a program. See `Attribute (Screen)` for the required syntax for the "attributes" parameter.

The "defined subattribute" parameter is a "subattribute" to which an attribute combination has already been assigned. The value of this "defined subattribute" is assigned to the "subattribute" which precedes it. This supports assignment of one subattribute's value to another.

====Technical Considerations====
:1.) The ATTRIBUTE specification can also be used with the CONFIG command. See the "CONFIG" command below for more information.

:2.) If an invalid character is entered as a subattribute, the `0863` Invalid Attribute Substitution Character error will be displayed.

:3.) ATTRIBUTE allows you to set up to 26 combinations of attributes for reference in programs.

:4.) The following subattribute-coding scheme was revised by BRC in early 1995, as follows:

`Image:Attbox.jpg`

Special Settings Used For Selection Operations

:"A" - normal cursor bar (attr)
:"B" - selected item - no cursor
:"C" - cursor on selected item
Note: V is an unselected data item

{|
|-valign="top"
|width="10%"|**Window**||This is the normal screen. By default, text is black and the window background is the same as that of the Windows default configuration. If a user changes his Windows colors, this background color will change accordingly.
|-valign="top"
|width="10%"|**Error**||This color scheme is used for error displays.
|-valign="top"
|width="10%"|**Information**||This type of window is also called a dialog box.
|-valign="top"
|width="10%"|**Menu**||A system menu.
|-valign="top"
|width="10%"|**Selection**||This is used for a point-and-shoot operation. These colors are often the same as the menu colors because they are both used for selection.
|-valign="top"
|}
<br>
Special Selection Settings: These are used to identify the cursor bar in conjunction with a variety of situations.

The ATTRIBUTE specification includes the ability to specify the colors that are to be used in the Business Rules help screens that are accessed with the HELP$ function. Help files need not be edited or modified in any way to take advantage of this feature. In the following syntax diagram, the [HPROMPT], [HTEXT], [HLIGHTBAR] and [HMENU] parameters were previously undocumented:

`Image:Configattribute2.png`

====Parameters====
The documented parameters affect the following aspects of Business Rules help displays:

{|
|-valign="top"
|width="10%"|**[HPROMPT]**||On-line help prompts (i.e., "Press F2 for related topics")
|-valign="top"
|width="10%"|**[HTEXT]  **||On-line help text
|-valign="top"
|width="10%"|**[HLIGHTBAR]**||On-line help's menu selection bar
|-valign="top"
|width="10%"|**[HMENU] **||On-line help menus
|-valign="top"
|}

====Recommended attributes====
`BRC` recommends that you set up your on-line help attributes as shown in the ATTRIBUTE specification that follows. (See item 4 in the technical consideration section above for a list of standard subattribute assignments.)

 ATTRIBUTE [HPROMPT][Z] [HTEXT][X] [HLIGHTBAR][A] [HMENU][M]

====Attribute Substitution Name Extensions====

Attribute substitution names [xxx] may be up to 12 characters long. Fonts can be specified at the field level by assigning them to attribute substitution names.

====Example====

 CONFIG ATTRIBUTE [hilite_text]/#rrggbb:#rrggbb font=arial:slant:max

This specifies that [hilite_text] denotes foreground and background colors specified as #rrggbb with arial, italics, and maximum size font. 

Font names with embedded spaces should NOT be enclosed in quotation marks.
e.g. Font=Free 3 of 9

====Screen and Attribute Statements Working Together====

SCREEN statements can now use attribute substitution names.  The more readable method for specifying screen attributes is to first define each attribute through an attribute substitution name and then reference them in SCREEN statements.  This means that the ATTRIBUTE and SCREEN statements can be used to progressively build upon one another.

Attribute 70 (black on white) is the "normal" default for the Windows model.<br>

Example 1: (this goes into your BRCONFIG.SYS file):

 ATTRIBUTE [lime_black]/#00FF00:#000000
 ATTRIBUTE [orange_white]/#FFA500:#FFFFFF
 ATTRIBUTE [XX]UH/RGB:W font=arial:slant:max
 ! W and font= are ignored by Unix terminal support
 SCREEN N [lime_black], U [orange_white], R [XX]

Example 2:

 ATTRIBUTE [normal]/W:W    ! windows foreground and background
 SCREEN N [normal]

The /#rrggbb:#rrggbb embedded syntax in FIELDS statements still overrides color for the corresponding fields, irrespective of SCREEN settings.  Also supported is W, which may be specified in lieu of R, G, B and H, denoting use of current Windows colors.

Example:

 /RG:W     -  yellow foreground on Windows background color

X attribute suppression

`Option (Config)|Option` 24 suppresses recognition of the X attribute during `INPUT SELECT` operations.  This is how versions prior to 3.8 worked, even though the documentation indicated that X applies to SELECT operations.  Note- this is OPTION 25 in version 3.8.

===Fonts===
