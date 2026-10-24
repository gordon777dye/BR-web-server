# Printer


---

Also see the [[Printing]] section.

The '''Printer''' specification allows you to specify which printer to use. It translates hex character strings for the printer or for display files, allowing you to customize Business Rules! to a particular printer.

:1.) Multiple PRINTER translations are supported by the BRConfig.sys file as of Business Rules! release 3.30. PRINTER translations may additionally be referenced through use of the PRINTER= parameter in the OPEN statement (see "OPEN display" in the Statements section for more information).

You can specify PRINTER specifications for up to nine named printers and one default printer in the same BRConfig.sys file. The full path name used to open the printer/display file must be specified after the word PRINTER and before the "2B...." specifications start. The keyword [[INIT]] can be used to specify the initialization string for each printer. This initialization string is sent to the printer/display file with every OPEN statement for that name. If no translation exists for a string for the named printer, the default translation for that string is used.

The keyword PRINTER= is allowed in the open string for display and printer files. This keyword names a printer translation that is used instead of the NAME= string for performing PRINTER string replacements. For example:

 PRINTER INIT 1B57001B2D00      !default initialization
 PRINTER 2B0045582B,1B5701      !default - expanded
 PRINTER 2B0045582D,1B5700 	    !default - CANCEL EXPANDED
 PRINTER C:\\BR\\PTEST INIT 1B2D00     !initializes the file ptest
 PRINTER C:\\BR\\PTEST 2B00554C2B,1B2D01   !set underline mode for ptest
 PRINTER C:\\BR\\PTEST 2B00554C2D,1B2D00  !cancel underline mode for ptest

:2.) The PRINTER specification now provides a much easier to use and easier to read system of creating printer substitution tables. It allows translation tables to be specified for up to nine named printers and one default printer.

====Comments and Examples====
The PRINTER specification replaces all occurrences of the first hex character string with the second string. Both strings may be of varying lengths. Multiple PRINTER specifications are permitted.

====Syntax====
[[Image:Printer.png|500px]]

The revised syntax (incorporating all enhancements since release 3.2 for the PRINTER spec is as follows. Business Rules! continues to support the old 2B... printer substitution sequence, but ADS recommends that you utilize the new system in all new development projects and update the old system as is convenient.

Diagram defaults
:1.) For default printer.
:2.) Do not reset value of LINESPP.
:3.) Substitute to null (nothing).

====Start-up Default====
Ignore the 2B020500hhvvll sequence.

====Parameters====
"Printer name" is the file name and path of the printer to which this PRINTER specification applies. The PRINTER spec will be activated whenever the specified printer name is opened with the PRINTER= parameter in an OPEN display statement. If PRINTER= is not used in the OPEN display statement but the NAME= string identifies a printer, Business Rules! will attempt to match the NAME= string to the printer name.

NOTE that all of the BRConfig.sys PRINTER specs together may specify no more than nine different printer names. A tenth set of PRINTER specs that lists no printer name may be specified as the default.

When the "printer name" parameter is not used, the PRINTER spec is assumed to apply to the default printer translation table. Business Rules! activates the default printer translation table whenever PRINTER= is not specified in the OPEN display statement and Business Rules! is unable to match the printer named in the OPEN display's NAME= string to a PRINTER specs "printer name."

The "INIT" keyword indicates that the succeeding "output string" should be sent whenever the specified printer is opened. For easiest reading of the BRConfig.sys file, Business Rules Corp recommends that the first PRINTER spec for each printer include the INIT string.

The "LPP ##" parameter sets the value of Business Rules! LINESPP function. ## has to be a number from 1 to 255. For more information about the usefulness of this parameter, see "LINESPP" in the Functions section.

The "substring" parameter is a PRINT string that Business Rules! should watch for and substitute with "output string" wherever it occurs. It must be enclosed within square brackets ([]) and followed by a comma when specified. This "substring" parameter is the key to the PRINTER specs easier-to-read format.

It would typically consist of an English-like term that identifies the printer code being sent. A few possible examples are: _E_G for turn bold on, __P for set characters per inch to 10, and [ITAL-] for turn italics off. The same string would be used in a Business Rules! PRINT statement when the desired printer feature is to be executed.

The "output string" parameter identifies the printer escape sequence that should be sent whenever the specified "substring" is included in a PRINT statement. Business Rules! allows any combination of hex codes, octal codes and literal strings (in quotes) for the "output string" parameter. The requirements for specifying the "output string" are:

:1.) Hexadecimal codes are specified without quotation marks. The letters A through F may be in uppercase or lowercase. Any combination of tabs, new lines, spaces and commas may be used to increase readability and will be ignored, unless they appear inside quotation marks (in which case they will be assumed to be literals). See Appendix H for a complete list of hex codes.

:2.) Octal codes must be specified as part of a literal string. See "Literal strings" below for more information.

:3.) Literal strings must appear within quotation marks, and may include octal codes when specified in the format shown below. See Appendix H for a complete list of octal codes.

The following formats or characters, when used in a literal string, have the specified meanings:

{|
|-valign="top"
|width="10%"|'''\\###'''||Octal value (backslash followed by three digits)
|-valign="top"
|width="10%"|'''\\b'''||Backspace
|-valign="top"
|width="10%"|'''\\E or \\e'''||Escape; same as CHR$(27) or octal \\033
|-valign="top"
|width="10%"|'''\\f'''||Form feed
|-valign="top"
|width="10%"|'''\\l'''||Line feed
|-valign="top"
|width="10%"|'''\\n'''||Newline
|-valign="top"
|width="10%"|'''\\r'''||Return
|-valign="top"
|width="10%"|'''\\t'''||Tab
|-valign="top"
|width="10%"|'''^x'''||Control-x (x may be any character)
|-valign="top"
|width="10%"|'''\\^'''||Caret (^)
|-valign="top"
|width="10%"|'''\\~'''||Tilde (~)
|-valign="top"
|width="10%"|'''\\:'''||Colon (:)
|-valign="top"
|width="10%"|'''\\'''||Backslash (\\); same as CHR$(92)
|-valign="top"
|width="10%"|'''\\"'''||Double quote mark ("); same as CHR$(34)
|-valign="top"
|}

====Examples====
"LPP 48" in the following PRINTER spec causes Business Rules! LINESPP function to be set to 48. "[LPP 48]" is a PRINT string that should be substituted with the "\\Ep48" escape sequence whenever it is used. "\\Ep48" is the escape sequence that causes the specified printer (in this case the default printer) to set lines per page to 48.

 PRINTER LPP 48 [LPP 48],"\\Ep48"

A Business Rules! statement that would activate the above PRINTER spec is as follows:

 PRINT #255:"[LPP 48]" ! set page length to 48 lines

The following example uses an output string that includes both a hex code and a literal string:

 PRINTER EPSONDOT LPP 66 [COLS=132],12"\\EP"  ! 10 CPI

The first character in the "from hex string" must be 2Bh, which is the ASCII code for the "+" character; the second character must be less than 20h or greater than D0h.<br>
All occurrences of the "from hex string" will be replaced with the "to hex string."<br>
The "EPSON" parameter supports the System/23 2B020500hhvvll translation for Epson printers. You may want to try this specification before any other, as it handles the translation for any printer with an Epson-compatible prom.

The "IBM23" parameter supports the System/23 2B020500hhvvll translation for the IBM System/23 Datamaster printer. Use of this printer with a PC requires the use of a separate hardware/software product, PC23-Print.

The "IBMCOLOR," "OKIDATA," and "OKIDATA84" parameters support the System/23 2B020500hhvvll translation for IBM Color, OKIDATA and OKIDATA 84 printers.

====Technical Considerations====
:1.) PRINTER may be specified only in the BRConfig.sys file; it is not valid with CONFIG.
:2.) A useful general definition of the PRINTER specification is as follows:

 PRINTER 2B1B, 1B

This specification, by instructing the system to ignore the "+" in all sequences beginning with "+ Esc", allows your program to support different printers without code changes.

:3.) If you write a program that specifies custom printer escape sequences, you can later change those escape sequences with the PRINTER specification -as long as the "+" character begins the program sequence and as long as the second character is less than 20h or greater than D0h.

<noinclude>
[[Category:Printing]]
[[Category:Config]]
</noinclude>

<!-- br_tree-audit -->
> **br_tree audit:** Represented in br_tree → [40-io-printing/statements/PRINTER.md](<../br_tree/40-io-printing/statements/PRINTER.md>).
