---
title: Attribute_(Screen)
file: Attribute_(Screen).md
category: 20-io-screen
subcategory: 20-io-screen/fields-attributes
kind: statement
related: [Attribute (disambiguation), Help Facility, HTML color codes, attribute statements]
---
See also:  `Attribute (disambiguation)`

The "attributes" parameter represents a set of specifications that identify the visual and control aspects of a screen display. Attributes are used primarily in full screen processing statements, but they may also be used in help text files (see `Help Facility` for more information about this usage). We begin with examples to put the following syntax in context. This wiki serves as documentation for legacy applications as well as current technology, so some of the syntax (where noted) has been deprecated. 

====Comments and Examples====
In the following example, "r" indicates that the message to be printed is to be reversed (highlighted). (Line 2005 is included because it's best to start a new page before printing new lines and accepting new input).

 02005 PRINT NEWPAGE
 02010 PRINT FIELDS "10,30,c 16,r": "Enter Customer #"

In the next example, "ae" indicates that as soon as the last digit of input is entered or one of the exit keys is used, the program is to perform an automatic Enter:

 02020 INPUT FIELDS "10,48,n 5,ae": CUSTNUM

In the next example, color is added. Line 2030 displays the message "Enter Date" with control attributes that are ignored because they are irrelevant for PRINT FIELDS. Line 2040 displays a field with red letters on a blue background:

 02030 PRINT FIELDS "12,30,c 16,cae": "Enter Date"
 02040 RINPUT FIELDS "12,48,c 8,/r:b": DateSold$

Business Rules is designed to handle the mixing of monochrome and color attributes and selects the appropriate attributes for the current monitor (unless a color system has been specified as COLOR N in the BRConfig.sys file). Your programs may then use color when it is available, but require no code changes when they are moved from one type of monitor to another. However, in newer versions of BR, the majority of monochrome attibutes (such as blinking) are no longer supported. In the following example, line 80 produces a highlighted field when a monochrome monitor is in use. When a color monitor is being used, it produces red letters on a teal background:

 00080 PRINT FIELDS "2,2,C 7,h/r:bg":" HELLO"

====Syntax====
`Image:screenattributes.png|800px`<br>

====Defaults====
# N (normal).
# Grey background.

====Parameters====
The syntax diagram shows four columns of specifications, which are labeled as monochrome, control, foreground color and background color attributes.

=====Monochrome Attributes=====

=====Control Attributes=====

====Color foreground attributes====
Foreground color attributes must follow all the monochrome and control attributes, and must be separated from the preceding attributes by a forward slash (/). They identify the visual characteristics of the field foreground when it is displayed on a color monitor (in a given field, the characters within the field are the foreground and the space behind the characters is the background). When both color and monochrome attributes are specified for a field, Business Rules selects the appropriate attributes according to the monitor used at start-up.

;Foreground color attributes are specified by the following list of single letter codes:
{|
|-valign="top"
|width="10%"|**R**||Red.
|-valign="top"
|width="10%"|**G**||Green.
|-valign="top"
|width="10%"|**B**||Blue.
|-valign="top"
|width="10%"|**H**||Highlight.
|-valign="top"
|width="10%"|**W**||Windows default color
|-valign="top"
|width="10%"|**#RRGGBB**||Beginning with 4.x foreground and background colors can be designated using the 6 digit HTML color codes preceeded with a pound sign #FF0000 causes the text to be RED
|-valign="top"
|}
Note that beginning with BR4.17 a color attribute of "N" is no longer allowed and will create an error condition.

====Color background attributes====
Background color attributes must be separated from foreground attributes by a colon (:). They identify the visual characteristics of the field background when it is displayed on a color monitor (in a given field, the characters within the field are the foreground and the space behind the characters is the background).

Background color attributes are specified by the following list of single letter codes (NOTE that H actually affects the foreground when it is specified with background attributes):
{|
|-valign="top"
|width="10%"|**R**||Red.
|-valign="top"
|width="10%"|**G**||Green.
|-valign="top"
|width="10%"|**B**||Blue.
|-valign="top"
|width="10%"|**H**||Foreground blink.
|-valign="top"
|width="10%"|**T**||Transparent
|-valign="top"
|width="10%"|**W**||Windows default color
|-valign="top"
|width="10%"|**#RRGGBB**||Beginning with 4.x foreground and background colors can be designated using the 6 digit HTML color codes preceeded with a pound sign #FF0000 causes the background to be RED
|-valign="top"
|}

====Technical Considerations====
When multiple foreground color or background color attributes are coded, the following combinations will result:
{|
|-valign="top"
|width="10%"|**BG**||(blue + green)  =  light blue
|-valign="top"
|width="10%"|**RB**||(red + blue)  =  purple
|-valign="top"
|width="10%"|**RG**||(red + green)  =  yellow
|-valign="top"
|width="10%"|**BGR**||(blue + green + red)=  white
|-valign="top"
|}

See also `HTML color codes`

=== Color Specifications ===
When processing field attributes, processing is done left to right. 
Nothing may follow color specifications in FIELDS attributes, whereas color specifications in `attribute statements` may be followed by a colon and further attributes such as fontname. 

As the FIELDS attributes are being processed left to right, if an ATTRIBUTE statement is referenced (e.g. [STRONG]) then all attributes are cleared and the referenced attribute statement is processed. Then the remainder of the FIELDS attributes are processed. 

It may be that both color and font are specified by an ATTRIBUTE statement, but it is desired to override just the color. This can be accomplished by referring to an ATTRIBUTE statement and then following it with a color specification. In that case the FIELDS color attribute will override entirely the ATTRIBUTE color specification. 

Also, within a color specification it is permissible to have multiple seemingly conflicting color specifications such as /HRW:RG#112233.
In these cases the priority given to conflicting specifications is:
# #112233 style values
# W (Windows system)
# HRGB values

There is no point in specifying both W and #112233 values because the #112233 values always take priority. However it can be useful to specify both HRGB and one of the other specifications so that HRGB will be used by terminal emulators but will be ignored by graphical clients.

====Inactive fields====
Inactive fields in 4.X+ versions default to the Windows inactive colors (usually grey on grey) This can be overridden by setting the attribute "[INACTIVE]" to the desired color behavior.

 e.g. ATTRIBUTE [INACTIVE]N/W:#FFFFFF

This will set inactive fields to the windows foreground default (typically black) on a white background (4.16+)
