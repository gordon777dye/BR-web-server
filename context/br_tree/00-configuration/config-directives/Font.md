---
title: Font
file: Font.md
category: 00-configuration
subcategory: 00-configuration/config-directives
kind: config-directive
related: [SCREEN OPENDFLT, FONT.TEXT, FONT.LABELS, FONT.BUTTONS, STATUS FONTS, FONTSIZE, Attribute (Config)]
provenance: placed-2b (the FONT page from the BR wiki added to config-directives per request; summarized in spec.md)
---

The **Font** `config` specification is supported. See also `Font (Config)`.

 FONT fontname 3DFONT=fontname

This supports two fonts simultaneously, one for background and captions and one font for input fields.

Version `3.9`+ supports the command `STATUS` FONTS. This will report all currently installed Windows
fonts that are acceptable in a FONT statement. Also fonts can be changed dynamically via the CONFIG
command.

Version `4.1`+ allows specific proportional or non-proportional fonts for text, labels and buttons.

Multiple fonts are now supported under Windows. The default is still `SYSTEMPC`. Any installed
non-proportional font is permitted that is named in the following BRCONFIG.SYS statement:

 SCREEN OPENDFLT   FONT=, FONT.TEXT=, FONT.LABELS=, FONT.BUTTONS=

Where the options are  arial: modern: slant: width+   (etc.)

The above settings are used initially and as OPEN #0 font defaults. When a child window is opened it
inherits the parent window's font settings. Window #0 inherits the OPENDFLT font settings each time it
is opened. When typeface or family is specified in an Open statement, boldness, style and underline
revert to these defaults unless they are also specified in the Open statement.

Size specifications do **not** revert to default values as a result of opening a window. They must be
explicitly specified in order to change them. This is to allow for users resizing their displays and
retaining those settings.

Individual controls inherit the font settings of the window the same way windows inherit settings.

The default font is the user's Windows default font. Separate fonts may be invoked for Labels, Buttons,
and Text (data entry fields):

 OPEN #0: "Srow=5,Scol=5,Rows=25,Cols=80,FONT=Arial", Display, Outin
 (specifies a base font)

 OPEN #0: "Rows=30,Cols=100,FONT.LABELS=Terminal,FONT.TEXT=Arial,FONT.BUTTONS=Lucida Console", Display, Outin

====Font Qualifiers====

| Qualifier | Values | Notes |
|---|---|---|
| **Family** | Decor, Roman, Script, Swiss, Modern (fixed) | useful in addition to the font name for systems that don't have the specified font |
| **Boldness** | Light, Bold | |
| **Style** | Ital, Slant | |
| **Underline** | Under | |
| **Size** | Small, Medium, Large, Max | size is based entirely on font height |

**Font Size Adjustment** — adjusts the size of displayed text down to accommodate the horizontal space
allocated for the text:
- **Width** — determine the average caps + digits character width, then reduce the font size until the
  number of characters times this average fits the BR field capacity.
- **Width+** — determine the average letter size considering both upper and lower case letters, then
  apply the width limitation.
- **Width-** — make the font small enough to accommodate a string of capital W's.
- **NoWidth** — clear the Width adjustment setting.

 OPEN #0: "Rows=30,Cols=100,FONT.LABELS=Terminal:bold:slant,FONT.TEXT=Arial,FONT.BUTTONS=Lucida Console", Display, Outin

The former `FONTSIZE=99x99` parameter is only supported when GUI is OFF.
