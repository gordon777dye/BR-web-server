---
title: Regular expressions (ECMAScript)
file: ECMA_REGEX.md
source: BR 5.03 behaviour, verified by running SEARCH against test files
category: 70-commands
subcategory: 70-commands/file-directory
kind: reference
status: 2b
related: [spec, filename-patterns, ../information/HELP, ../../90-reference/error-codes/1009]
keywords: [SEARCH, regex, regular expression, ECMAScript, pattern, 1009]
corrections:
  - "New page (BR 5.03, 2026-11-22): the regular expressions SEARCH takes between slashes. Every construct listed was run through SEARCH; what is listed as refused gives error 1009. Written with the change that lets a /regex/ hold a !, which BR had taken as the start of a remark (error 1003). HELP COMMANDS REGEX and HELP REGEX show this page."
---

# Regular expressions (ECMAScript)

A pattern written between slashes in a [`SEARCH`](spec.md#search) command is a **regular
expression**: `SEARCH /^ *PRINT/ src\*.brs`. BR uses the ECMAScript grammar, the one JavaScript
uses, as the C++ standard library provides it. This page lists what that grammar accepts in BR,
what it does not, and how a regex meets the rest of the `SEARCH` line. `HELP COMMANDS REGEX` (or
`HELP REGEX`) shows this page.

A pattern in quotes, or a single word, is not a regex: `SEARCH "a.b" file` finds the three
characters `a.b` and nothing else. Use a quoted pattern when you mean text exactly as written.

## Contents

1. [Writing a regex in a SEARCH line](#writing)
2. [What a regex is matched against](#subject)
3. [Characters and escapes](#characters)
4. [Character classes](#classes)
5. [Anchors and boundaries](#anchors)
6. [Repetition](#repetition)
7. [Groups, alternatives and look-ahead](#groups)
8. [Not supported](#unsupported)
9. [The attributes -I, -W, -B and -~](#attributes)
10. [Errors and limits](#errors)
11. [Examples](#examples)

<a id="writing"></a>
## Writing a regex in a SEARCH line

- The regex runs from the first `/` to the next `/` that has no `\` before it. Inside, `\/` stands
  for a `/`: `SEARCH /path\/to/ notes.txt`. Every other `\` sequence goes to the regex as written.
- Blanks, commas, quotes and `!` are part of the regex: `/IF X/`, `/a,b/`, `/say "hi"/`, `/it's/`,
  `/(?!x)/`. A `!` outside the regex still starts a remark, as on any command line.
- A regex with no closing `/` is error **1003**, and the cursor goes to the opening `/`.
- Attributes (`-I`, `-~`, `-W`, `-B`, `-R`) come before the regex and options (`-C`, `-L`, `-N`,
  `-P`) after the file names, as for any `SEARCH` pattern.
- **From a program**, the command is a string, so a `"` inside it is written twice and nothing else
  changes. A BR string gives `\` no special meaning, so the regex keeps its backslashes as typed:

  ```
  EXECUTE "SEARCH /^\s*LET\s/ src\*.brs >hits$"
  EXECUTE "SEARCH /say ""hi""/ notes.txt"
  ```

<a id="subject"></a>
## What a regex is matched against

- **One line at a time.** A match never spans two lines, and the line holds no line end, so `\n`
  and `\r` find nothing.
- **The line is cleaned first**: only displayable ASCII (32 to 126) and the tab are kept. Bytes
  above 127 are removed, so an accented letter can never be matched. `\t` and `\x09` find a tab.
- **Anywhere in the line.** A regex matches if it is found anywhere in the line; it does not have
  to match all of it. To match a whole line, use `^` and `$`: `/^END$/`.
- An **internal file** is searched record by record, each record a line with its trailing blanks
  removed (see [SEARCH](spec.md#search)).

<a id="characters"></a>
## Characters and escapes

| Write | Matches |
|---|---|
| `a`, `7`, `=` | That character. |
| `.` | Any one character, a blank or a tab included. |
| `\.` `\*` `\+` `\?` `\(` `\)` `\[` `\]` `\{` `\}` `\|` `\^` `\$` `\\` | The character itself, without its special meaning: `/a\+b/` finds `a+b`. |
| `\/` | A `/` (SEARCH's own rule, see above). |
| `\t` | A tab. `\f`, `\v`, `\n`, `\r` and `\0` are accepted, but those characters never occur in a cleaned line. |
| `\xhh` | The character with hex code *hh*: `\x21` is `!`, `\x50` is `P`. |
| `\uhhhh` | The character with hex code *hhhh*, the same within ASCII: `P` is `P`. |
| `\cX` | The control character Ctrl-*X*: `\cI` is a tab. |

**A `\` before a letter that has no meaning stands for the letter itself.** `\A` is `A` and `\z`
is `z`. They are not the start-of-text and end-of-text anchors of other regex languages, and BR
gives no error for them. Use `^` and `$`.

<a id="classes"></a>
## Character classes

| Write | Matches |
|---|---|
| `[abc]` | One of `a`, `b` or `c`. |
| `[^abc]` | One character that is not `a`, `b` or `c`. |
| `[a-z]`, `[0-9A-F]` | One character in the range. A range written backwards, `[z-a]`, is error 1009. |
| `\d` / `\D` | A digit `0`-`9` / anything else. |
| `\w` / `\W` | A word character, a letter, digit or `_` / anything else. `$` is **not** a word character here; it is one for `-W` (see below). |
| `\s` / `\S` | A blank or a tab / anything else. |
| `[\d.]`, `[\w$]` | The escapes above also work inside brackets. |
| `[[:alpha:]]`, `[[:digit:]]`, `[[:alnum:]]`, `[[:space:]]`, `[[:upper:]]`, `[[:lower:]]`, `[[:punct:]]`, `[[:xdigit:]]` | POSIX class names, inside the brackets of a class: `/[[:alpha:]]+[[:digit:]]/`. |
| `[]` | Never matches. |
| `[^]` | Any character. |

Inside brackets, `]`, `\`, `^` (first) and `-` (between two characters) are special. Write them as
`\]`, `\\`, `\^` and `\-` to mean the character.

<a id="anchors"></a>
## Anchors and boundaries

| Write | Matches |
|---|---|
| `^` | The start of the line: `/^PRINT/` finds lines that begin with `PRINT`. |
| `$` | The end of the line: `/;$/`. To match a `$` character, write `\$`: `/TOTAL\$/`. |
| `\b` | A word boundary, between a `\w` character and a non-`\w` character or the line's end. `/\bEND\b/` finds `END` but not `ENDLESS` or `APPEND`. |
| `\B` | A place that is not a word boundary. |

A BR string variable's name ends in `$`, which `\b` does not count as part of a word: `/\bNAME\b/`
finds the `NAME` in `NAME$`. Write `/\bNAME\$/` to find only `NAME$`, or use `-W` (see below).

<a id="repetition"></a>
## Repetition

Each of these applies to the character, class or group just before it.

| Write | Means |
|---|---|
| `*` | Zero or more times. |
| `+` | One or more times. |
| `?` | Zero times or once. |
| `{n}` | Exactly *n* times: `/a{3}/`. |
| `{n,}` | *n* or more times. |
| `{n,m}` | From *n* to *m* times. |
| `*?` `+?` `??` `{n,m}?` | The same, taking as few as will do (lazy). |

A repeat with nothing before it, such as `/*a/` or `/a|+b/`, is error 1009. So is `{,m}` with no
lower bound, and a range written backwards, `{2,1}`. Possessive repeats (`a++`, `a*+`) are not
supported and are error 1009.

<a id="groups"></a>
## Groups, alternatives and look-ahead

| Write | Means |
|---|---|
| `x\|y` | `x` or `y`. `/^(END\|STOP)\b/`. |
| `(...)` | A group, which a repeat can apply to: `/(ab)+/`. It also captures what it matched. |
| `\1` ... `\9` | What group 1 to 9 matched, again: `/(\w)\1/` finds a doubled letter, `/(foo)\1/` finds `foofoo`. A number with no such group is error 1009. |
| `(?:...)` | A group that does not capture: `/(?:ab)+c/`. |
| `(?=...)` | Look-ahead: followed by `...`, which is not part of the match. `/foo(?=Bar)/`. |
| `(?!...)` | Negative look-ahead: not followed by `...`. `/foo(?!Bar)/`. |

The match itself is not shown. `SEARCH` shows the whole line, so a group only decides whether a
line matches.

<a id="unsupported"></a>
## Not supported

These come from other regex languages (Perl, PCRE, .NET, Python). BR's ECMAScript grammar does not
have them, and each is error **1009**:

| Construct | Example | Instead |
|---|---|---|
| Look-behind | `(?<=a)b`, `(?<!a)b` | Match the text before as well: `/ab/`. |
| Named groups | `(?<name>...)`, `(?P<name>...)` | A plain group and its number, `(...)` and `\1`. |
| Inline flags | `(?i)`, `(?x)` | The `-I` attribute: `SEARCH -I /print/ file`. |
| Atomic groups | `(?>...)` | |
| Possessive repeats | `a++`, `a*+` | |
| Unicode properties | `\p{L}`, `\P{L}` | A class, `[A-Za-z]`; a cleaned line is ASCII only. |
| A repeat with no lower bound | `{,3}` | `{0,3}`. |

Not refused but **not anchors**: `\A`, `\Z` and `\z` match the letters `A`, `Z` and `z` (see
[Characters and escapes](#characters)).

<a id="attributes"></a>
## The attributes -I, -W, -B and -~

The attributes before the pattern apply to a regex as to a quoted pattern:

- **`-I`** ignores the case of ASCII letters throughout the regex: `SEARCH -I /^print/` finds
  `PRINT X` and `print x`, and `[a-z]` also matches capitals.
- **`-W`** is checked after the regex has matched: a match next to a word character is passed over,
  and the search goes on in the same line. For `-W` a word character is a letter, a digit, `_` or
  **`$`**, so `SEARCH -W /PRINT/` does not find `PRINT$`. `\b` inside the regex uses its own,
  narrower rule (no `$`).
- **`-B`** gives the regex the line with each run of blanks and tabs made one blank, and the blanks
  at either end removed. `SEARCH -B /^IF X$/` finds `   IF   X   `. The line shown is the line as it is.
- **`-~`** shows the lines the regex does not match.

<a id="errors"></a>
## Errors and limits

- **Error [1009](../../90-reference/error-codes/1009.md)**: the regex does not compile. At the
  command line the cursor goes back to the fault where it can be found: an unmatched `(` or `)`,
  an unclosed `[`, a `{` that is not a valid repeat, a repeat with nothing to repeat, or a backwards
  range. For anything else, such as a construct from [Not supported](#unsupported), it goes to the
  first character of the regex.
- **Error 1003**: no closing `/`.
- **A line longer than 4,096 characters** is not tried against a regex. A quoted pattern is still
  tried on it.
- **A line too complex for the regex engine** is skipped. A pattern such as `(a*)*b` against a long
  run of `a`s can make the engine give up. The command goes on with the next line and does not end
  with an error.
- For both, the first such line of each file is noted on the screen (`name: line n too long`,
  `name: line n too complex to search`), and nothing is written to a redirected output.
- A regex that can match an empty string, such as `/x*/` or `/$/`, matches every line.

<a id="examples"></a>
## Examples

```
SEARCH /^\s*PRINT\b/ src\*.brs              ! lines that begin with PRINT, after any indent
SEARCH -I /\bLET\s+\w+\$?\s*=/ src\*.brs     ! LET assignments, either case
SEARCH /\bFN[A-Z]\w*\$?\(/ src\*.brs         ! calls of a user function
SEARCH /^\d+\s+REM\b/ old.brs                ! numbered REM lines
SEARCH /"[^"]*\\[^"]*"/ src\*.brs            ! string literals holding a backslash
SEARCH /\d{3}-\d{4}/ customers.txt           ! a phone-number shape
SEARCH /(\w+) \1/ notes.txt                  ! a word typed twice
SEARCH /^(?!\s*!)/ src\*.brs -C              ! count the lines that are not remarks
SEARCH -~ /\S/ notes.txt -C                  ! count the blank lines
```

## See also

- [SEARCH](spec.md#search): the command, its attributes, options and output
- [File name patterns](filename-patterns.md): the glob patterns the file names take, which are not regexes
- [Error 1009](../../90-reference/error-codes/1009.md)
- [HELP](../information/HELP.md)
