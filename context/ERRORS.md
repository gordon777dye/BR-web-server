# Kit Errors

Please record any context kit errors here that are found in the course of its use.
---

## 2026-11-09 — ONBOARDING STEP 9 rebuilds ISAM key files as B-tree

**Where:** [`app/ONBOARDING.md`](app/ONBOARDING.md) STEP 9, "Rebuild every key file of the data
file … with BR's `INDEX` command", and the procedure it produced,
`context/scratch/step9/index.prc`.

**What is wrong:** the step gives `INDEX` the positions, lengths and modifiers of the production
key file but not its **type**. `INDEX` builds a B-tree unless it is given `ISAM` (or `OPTION 5` is
on), so every production ISAM key file came out B-tree in the test area. In QSMRP that was 4 of
439: `ard\taxmast.key`, `cnd\terms.key`, `cod\element.key`, `ind\prodclas.key`. The type is byte 8
of the key file's header: 4 is ISAM, 7 is B-tree.

**What it breaks, silently:** a program that opens such a file with `ISAM` in its open string fails
the open. `arp\arinq` opens `TERMS` through its own `FNOPEN_KEYED`, whose open string ends `Isam,
Shr` and whose `error` clause swallows the failure, so `TERMS` stays 0 and the next keyed read of
it is error 702 at line 56506, shown in the house `Trap:` window. Found by a `uitest` of `arinq`;
the same program works against the data `subs.txt` redirects.

**Fixed in the test area** (2026-11-09): the four were rebuilt with `INDEX … REPLACE DUPKEYS ISAM`,
under a configuration without `include subs.txt` and the test area's own paths, as STEP 9 ran.
All 31 ISAM key files now match their originals' type. `index.prc` lines 67, 193, 276 and 277 now
carry `ISAM`.

**Suggested fix to the step:** read each production key file's type along with its positions, and
add `ISAM` to the `INDEX` line when it is 4.

## 2026-11-09 — `brls -check -sema` passes a comparison BR will not load

**Where:** `dev/tools/brls.exe` (`brls -version` for the build).

**What is wrong:** `brls -check -sema` reports no error for

```
00010    let M$="B"
00020    let P=12+(M$="B")
```

and BR 5.0's `LOAD … source` rejects line 20 with **error 1026, "invalid expression"**, reported at
`line 0`, so nothing points at the line. Outside `IF`/`WHILE`/`UNTIL`, `=` is assignment, and a
string assignment inside a numeric expression does not parse; the comparison is `==`
(`12+(M$=="B")`), which is how QSMRP's own code writes it (`glp\fy_calcs`: `(METHOD$=="B")`).
Found while writing `context\app\tests\fy_calcs.test.brs`. A one-line reproduction:
`context\scratch\brtest\mini\m1.brs`. The two neighbouring forms tried at the same time load
in BR and pass in brls, correctly: `if P<>1 or not P then …` and `fnX(B=0)` as an argument.

## 2026-11-10 — `BR_testing.md` describes `brconfig.ai_test` as one line, and its app-test command omits it

**Where:** [`dev/BR_testing.md`](dev/BR_testing.md) §4.2 ("`brconfig.ai_test` … is
`brconfig.ai_user` plus one line") and §4, the command for an application's own test
(`uitest --start context\app\tests\trial_bal.prc context\app\tests\trial_bal.uis`).

**What is wrong:** `context/dev/tools/brconfig.ai_test` is `brconfig.ai_user` plus **four**
directives: the `SUBSTITUTE menu/cnp` stub, and also `PRINTDIR context\scratch\print +CHANNEL RAW`,
`SUBSTITUTE preview: DIRECT:` and `SUBSTITUTE /select /default`. The last three are what let a
report test run at all: without them QSMRP's `Prn:/10`–`/60` classes go to print preview or a
printer-selection dialog, which no script can answer, and `expect print` finds no capture.

**Why it matters:** the §4 command for an app test gives no `--config`, so it runs on
`$BR_AI_USER`. A model writing a report test from §4 and §4.3 adds `CONFIG PRINTDIR` to the
procedure as §4.3 says, and the run still stops at the preview window. `context/app/tests/custlist`
passes only because the suite is run with `--config context\dev\tools\brconfig.ai_test`
(ONBOARDING STEP 10), which `BR_testing.md` never shows for a single test.

**Suggested fix:** list all four lines in §4.2, and put `--config context\dev\tools\brconfig.ai_test`
in every `context\app\tests\` command in `BR_testing.md`.

## 2026-11-16 — Broken link in the `PRINTER` config-directive page

**Where:** [`br_tree/00-configuration/config-directives/PRINTER.md`](br_tree/00-configuration/config-directives/PRINTER.md)
line 134, the "br_tree audit" note.

**What is wrong:** the link is written `(<../br_tree/40-io-printing/statements/PRINTER.md>)`, as
if the page sat one folder below `context/`. From `00-configuration/config-directives/` it
resolves to `00-configuration/br_tree/40-io-printing/…`, which does not exist. The page it means
does exist, at `br_tree/40-io-printing/statements/PRINTER.md`.

**Suggested fix:** `(../../40-io-printing/statements/PRINTER.md)`.

**Found by:** `dev/tools/gen_brtree_html.exe`, whose link check reports it as the only link or
`#anchor` in br_tree that does not resolve.
