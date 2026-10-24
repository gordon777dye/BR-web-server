---
title: Keyword_Abbreviation
file: Keyword_Abbreviation.md
category: 10-language
subcategory: 10-language/syntax
kind: concept
related: [Alert, Auto, Break, ChDir, Clear, Config, Copy, Date, Del, Dir]
provenance: recovered-2b (redirect-collision casualty re-fetched from wiki)
corrections: "All 15 stale abbreviations corrected against BR's own matcher (tokensub over the keyword tables). Values here are computed, not transcribed; see spec.md#abbreviations for the rule and brls abbreviations.json for the full comparison."
---
'''These abbreviations have been corrected against Business Rules' own keyword matcher.'''
The list as originally published is stale in fifteen places: it gave abbreviations that later
releases made ambiguous (`DE` against `DEBUG`, `DI` against `DISPLAY`, `FR` against `FRE`,
`REN` against `RENUM`, `LI` against `LIBRARY`), one the interpreter has no way to match at all
(`CD` for `ChDir` — not a prefix of the word), and nine that are more cautious than BR requires.
Each corrected line carries an HTML comment saying why. The rule the values are computed from is
in [syntax](spec.md#abbreviations).

Primary and secondary keywords can be abbreviated on input, thereby increasing programmer productivity. Primary keywords are the names of statements and commands. Secondary keywords are other keywords used in statements (they are always capitalized in syntax diagrams, meaning they must be typed in exactly as is or with an acceptable abbreviation). Lists of the shortest acceptable abbreviations for each of these keywords are included in this APPENDIX.

An abbreviation, which is longer than what is listed is also, accepted. DELETE could be entered as DEL, DELE, or DELET, for instance.

For primary keywords, each abbreviation is unique; the rule for determining the abbreviation is explained below. Secondary keyword abbreviations are not unique; instead, Business Rules uses the context and placement of the keyword to determine its meaning.

==**Command Abbreviations**==

A list of the shortest acceptable abbreviations for command names follows. The full keyword appears with its shortest acceptable abbreviation, if any, directly afterwards.

**Caution**

Business Rules automatically expands abbreviated keywords only when the abbreviations appear in program statements (not commands or procedures) and only when they are not part of a literal expression. Some future additions to Business Rules may make a few abbreviations invalid, it is strongly recommended that you spell out all keywords which Business Rules won't expand for you when they are to remain a permanent part of your application. This includes all keywords which appear in procedure files, BRConfig.sys file or in the literal expressions of EXECUTE statements.


`Alert` (AL)

`Auto` (AU)

`Break` (B)  <!-- corrected: no other command begins with B -->

`ChDir` (CH)  <!-- corrected: CD is not a prefix of CHDIR and appears nowhere in BR -->

`Clear` (CL)

`Config` (CON)

`Copy` (COP)

`Date` (DA)

`Del` (DEL)  <!-- corrected: DE now also matches DEBUG -->

`Dir` (DIR)  <!-- corrected: DI now also matches DISPLAY -->

`Display` (DIS)

`Drop` (DR)

`Edit` (E)  <!-- corrected: no other command begins with E -->

`Free` (FREE)  <!-- corrected: FR now also matches the FRE command -->

`Go` (G)  <!-- corrected: GO is an exact match, taken before GO END -->

`Go End`

`Index` (I)  <!-- corrected: no other command begins with I -->

`List` (LIS)

`Load` (LO)

`Merge` (ME)

`MkDir` (MK)

`Proc`

`ProcErr` (PROCE)  <!-- corrected: PROC is an exact match and wins first -->

`Protect` (PROT)

`Rename` (RENA)  <!-- corrected: REN now also matches RENUM -->

`Renum` (RENU)

`Replace` (REP)

`RmDir` (RM)

`Run` (RU)

`Save` (SA)

`Skip` (SK)

`Sort` (SO)

`Status` (ST)

`SubProc` (SU)

`System` (SY)

`Time` (TI)

`Type` (TY)

`Verify` (V)

==**Statement Abbreviations**==

A list of the shortest acceptable abbreviations for statement names follows. The full keyword is followed by its shortest acceptable abbreviation (if any) in parentheses.

There are two special situations where it will seem as if the same abbreviation applies to different statements: with the five OPEN statements, and with the two READ statements. Although this manual describes the OPEN communications, OPEN display, OPEN external, OPEN internal and OPEN display statements separately, they are actually all variations of the same statement. Business Rules recognizes the OPE abbreviation for each. The same is true for the READ file and READ data statements.
`chain` (ch)

`close` (cl)

`continue` (co)

`data` (da)

`def`

`delete` (del)

`dim`

`end` (en)

`end if` (en if)

`execute` (exe)

`exit` (exi)

`fnend` (fn)

`for`

`form`

`gosub`(gos)

`goto` (got)

`if`

`input` (in)

`input fields` (in f)

`input select` (in s)

`let` (le)

`linput` (lin)  <!-- corrected: li now also matches LIBRARY -->

`mat` (m)

`next` (n)

`on error`

`on gosub` (on gos)

`on goto` (on got)

`open communications` (ope)

`open display` (ope)

`open external` (ope)

`open internal` (ope)

`open window` (ope)

`option` (opt)

`pause` (pa)

`print` (pr)

`print border` (pr b)

`print fields` (pr f)

`print using` (pr u)

`randomize` (ra)

`read` (rea)

`rem`

`reread` (rer)

`restore` (rest)

`retry` (retr)

`return` (retu)

`rewrite` (rew)

`rinput` (ri)

`rinput fields` (ri f)

`rinput select` (ri s)

`stop` (st)

`trace` (t)

`use` (u)

`write` (w)  <!-- corrected: no other statement begins with W -->


<noinclude>
</noinclude>
