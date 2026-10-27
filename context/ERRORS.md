# Kit Errors

Please record any context kit errors here that are found in the course of its use.
---

## 2026-10-24 — found while building brweb's web_server 2.11

1. **Multiplying by `INF` raises error 0006 ("Division by zero"). The kit doesn't say so.**
   `br_tree/10-language/.../spec.md` defines `INF` only as the "largest representable number
   (`1.0E+307`)", and `essentials.md` shows it only as a string-slice bound (`X$(INF:0)`). On BR
   5.01 (Debug build, `WBVERSION$` = 5.01), every multiplication involving `INF` stopped with
   error 0006: `INF*1`, `INF*0`, `0*INF` and `300+INF*0`. Addition worked: `300+INF` gave
   `E+307`. The message names division, so it misleads. Found in a real program, where
   `POST$(1:300+INF*SGN(FLAG))` stopped an unattended server. The probe is
   `context/scratch/mini_inf0.brs`, with its output in `mini_inf0.txt`. Suggest an `essentials.md`
   §4 entry: use `INF` only as a bound or in comparisons, never in multiplication.

## 2026-10-25 — found while building brweb's web_server 2.13

1. **`brls -check -sema` passes a string comparison with `=` inside an assignment, and real BR
   refuses it (error 1026, "invalid expression").** `essentials.md` §1 says bare `=` is the
   is-equal operator everywhere except as the assignment itself, and gives
   `LET X = A OR B AND C` as assigning a whole condition. That holds for numbers but not for
   strings. On BR 5.01 (Debug build), `LOAD … source` gave:

   | Line | BR | brls 0.1.0-dev |
   |---|---|---|
   | `let B = (A$ = "x")` | error 1026 | clean |
   | `let B = (A$(1:1) = "x")` | error 1026 | clean |
   | `let B = (N = 1)` | loads | clean |
   | `let B = (A$ == "x")` | loads | clean |

   Found in a real program, where `let URL_PREPARED = (URL$(1:1) = BACKSLASH$)` passed brls and
   stopped the compile. (VS Code's separate br-lsp did flag it.) The probes are
   `context/scratch/mini_streq_a.brs` to `_d.brs`. Suggest a brls error for a bare `=` string
   comparison in an expression that is not a condition, and an `essentials.md` §1 note to use
   `==` there.

## 2026-10-25 — found while building brweb's web_server 2.15

1. **An optional (local) string parameter declared longer than about 32,000 characters makes
   every call to the function fail, with a meaningless error number.** `essentials.md` §2 and §4
   document the 32,767 limit only for a string *passed* by value (error 0004 at the call). They
   also present unpassed optional parameters as the way to get scratch locals, with no size
   caveat. On BR 5.01 (Debug build, `workstack 500000`), `DEF FNINNER(&V$;P,S$*n)`, called from
   another function, gave:

   | `n` | Result |
   |---|---|
   | 10,000 | works |
   | 32,000 | works |
   | 40,000 | error 25436 |
   | 100,000 | error 30972; in web_server, 30969 |

   None of those numbers is in `br_tree/90-reference/error-codes/` or `error-reference.md`, and
   the log calls them "Unknown BR error code". Found when a `STACK$*100000` local stopped
   web_server's new `FNJSON_UNBALANCED`. A global `DIM` of the same size works. The probes are
   `context/scratch/mini_bigloc_a.brs` to `_d.brs`. Suggest an `essentials.md` §2 note: keep
   optional string locals at 32,000 or less, and use a global for anything larger.

## 2026-10-26 — found while bringing brweb's kit up to the qsmrp kit's level

1. **ONBOARDING STEP 1 says to fill in a README line that the README doesn't have.** STEP 1 step 4
   and the closing checklist both say to fill in the "BR environment variables are" line at the
   end of the AI Model Rules in `context/README.md`. The kit's `README.md` has no such line; the
   two fill-in lines it does have are the source-masters line and the "BR starts in" line. brweb's
   README now has the line, added by hand. Suggest adding a
   `- BR environment variables are ___________. (completed in ONBOARDING STEP 1)` line to the
   kit's README.
2. **`env.cmd` and `setx.cmd` in ONBOARDING STEP 1 are written with LF line endings in the qsmrp
   kit's own copies.** cmd can mis-handle `goto` labels in LF-only batch files, and `setx.cmd`
   depends on `goto failed`. brweb's copies are CRLF. Suggest the step say to write them with CRLF.
3. **`BR_launch.md` gives one install's paths as if they were the kit's.** "The procedure has to
   sit in BR's start folder" says "For this application the first `DRIVE` is
   `DRIVE m:,c:\ads,xxx,\qsmrp`, so that folder is `C:\ADS\qsmrp`". In any other app (brweb starts
   in `C:\ADS_test\gabriel\brweb`) that sentence is wrong. Suggest pointing to the "BR starts in"
   line in `context/README.md` instead.
