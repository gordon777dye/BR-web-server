# Kit Errors

Please record any context kit errors here that are found in the course of its use.
---

## 2026-10-23 — found during onboarding of brweb (kit version 1.00)

1. **`dev/tools/fileio.brs` is missing.** `dev/APP-DEV-GUIDE.md` §4 ("Inspecting actual data
   values") cites "[`tools/fileio.brs`](tools/fileio.brs) line 1753" and further line numbers in it,
   but the kit ships no such file. FileIO source exists only as documentation under
   `br_tree/50-libraries/fileio/`.
2. **ONBOARDING STEP 1, sub-step 7 is ambiguous when `brconfig.sys` already has `OPTION 60`.**
   Sub-step 6 only says to stop "under BR 4.3". This app's `brconfig.sys` has an active `option 60`,
   but production runs BR 5.00 (`brlog.txt` shows "Release 5.00"), so the stop condition doesn't
   apply. Sub-step 7 then adds a second `option 60` line, and the procedure doesn't say whether the
   original should be kept. Both were kept; the duplicate is harmless.
3. **The STEP 2 "clearly smaller" staleness sign can't be applied when masters are source.**
   A `.br` is tokenized object, so its byte size isn't comparable with the `.brs`. The only way to
   compare content is to decompile, and that is prohibited when masters are source. The procedure
   doesn't say how to resolve a "suspect" file in that case.
4. **`extract-schema.exe` takes `Pos` from the positions comment column, not from the FORMs.**
   ONBOARDING Appendix A says column 5 (positions) is "documentation only" and the parser ignores
   it, while FileIO computes positions from the FORM specs. But `data-model.md`'s `Pos` comes from
   that column. Where it is stale (brweb's `filelay/customer`, after an `UNUSED$ C 5` row with no
   positions was inserted), `data-model.md` disagrees with what FileIO reads at runtime, with no
   warning. A row with no positions shows `—`. Suggest computing `Pos` from the FORMs, and warning
   when the column disagrees.
