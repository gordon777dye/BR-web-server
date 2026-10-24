---
alwaysApply: true
---

# BR context kit

To properly view markdown files such as this one, open it with the mdreader provided herein.

This is a model- and developer- facing context for working in **Business Rules! (BR)** — 
reading, writing, and designing BR application code. It is application-agnostic: point the 
tooling at whatever BR codebase you're on. There are three published parts:

- **`dev/`** — the task-oriented coding kit: a router (`topics.json`), distilled statement
  semantics, the system-function and standard-library catalogs, an error reference,
  schema-extraction tooling, and `brls.exe` — a fast BR syntax/sema checker
  (`tools/brls.exe -check -sema <file>`) that needs no BR license or runtime. `-check` reads
  one line at a time, but takes whole files — or several, or stdin. `-sema` adds a whole-file
  pass on top of it (it does nothing on its own): block pairing, which catches a `FOR`, `DO`,
  block `IF` or `DEF` that never closes — real BR rejects those at LOAD — plus the name
  checks: undefined names, argument counts, unresolved `LIBRARY` links.
- **`br_tree/`** — the authoritative BR language reference tree (syntax, data types, file
  and screen I/O, printing, libraries, error codes), the ultimate backstop that `dev/` links into
  for depth.
- **`app/`** — where your toolset information and application programming style will reside.

## AI Model Rules

- Do not invent, guess, or infer commands, file paths, syntax, or facts. 
  Do not or fill gaps with plausible-sounding guesses. If you don't know something: 
  (a) search thIS context first, (b) flag it as unknown, (c) ask the user. **NEVER GUESS** 

- The following documents are required reading and are therefore @ included below:
- **`dev/APP-DEV-GUIDE.md`** — this will save you many headaches and much time.
- **`dev/BR_launch.md`** — this is needed to compile and test.
- **`dev/essentials.md`** — this is exactly what it is named.
- **`app/conventions.md`** — this identifies the program style of this app.
- Note- `app/conventions.md` is created during onboarding, so it won't exist initially.

- Get familiar with the tools in context, especially `brls.exe` (decribed in 
  `APP-DEV-GUIDE.md`) before attempting to code. Use this tool to check your work 
  as you go. 

- Don't be in a hurry to deliver. Look at the context documentation before you code. 

- The master copies of programs are stored in **source (`.brs`)** form. 
  If the program masters are stored in source format decompiling (REPLACE SOURCE) 
  is prohibited. (A one-time exception was authorized and used on 2026-10-23 to create or
  refresh all sources; see `app/STALE_SOURCE.md`. It does not carry forward.)

- BR starts in **`C:\ADS_test\gabriel\brweb` (the app root)**, so kit paths handed to BR take 
  the prefix **(none)** (none when BR starts in the app root). (completed in ONBOARDING STEP 1; see
  `dev/BR_launch.md#start-folder`)

## Installation

Note: This context kit itegrates with any BR app. 

**Copy this folder with it's sub-folders into the main folder of your application**. 
Rename it to "context/". Then copy your brconfig.sys fileto dev/tools.
The rest is done by AI. 

## Update Procedure

- Download a fresh zipped copy of this repo
- Unzip it to it's own folder
- Save your config and "config include" files to a work folder (e.g. app/onboarding/)
- delete br_tree/ and dev/ from your context/ folder
- **move the br_tree/ and dev/ folders from the update into context/**
- restore your config files into dev/tools/


## Start here

**Onboarding has been completed through STEP 8 (2026-10-23).** STEP 9 (test data environment)
and STEP 10 (brls vs real BR survey) are still to do. Until STEP 9 is done, **no `subs.txt`
redirect exists, so every BR run uses the live `data\` files.**

**→ [`app/ONBOARDING.md`](app/ONBOARDING.md)** - Onboarding instructions - do this first. 
All of this should be done by AI at your direction. Just tell your AI agent (one step at a time)
 to execute the instructions. 

**→ [`dev/BR_harness.md`](dev/BR_harness.md)** — How to run **BR 5.0 with an assistant attached**
and watch a program while it runs: its screen, its fields, its listviews, a picture of its
window. This is the only way to see an interactive program or a ScreenIO screen.

**→ [`dev/APP-DEV-GUIDE.md`](dev/APP-DEV-GUIDE.md)** — After completing the onboarding, this
becomes your AI task entry point. Its *"Start here — by task type"* preamble routes your 
agent by what you desire to accomplish (interpret/debug · code · design · test).

## Errors

If you encounter any context kit errors, please log them in ERRORS.md

---

Now including **`dev/APP-DEV-GUIDE.md`**
@dev/APP-DEV-GUIDE.md

Now including **`dev/BR_launch.md`**
@dev/BR_launch.md

Now including **`dev/essentials.md`**
@dev/essentials.md

Now including **`app/conventions.md`**
@app/conventions.md

---