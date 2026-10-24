---
title: Library facility
file: spec.md
source: §Libraries (LIBRARY statement, loading, search order, FileIO)
category: 50-libraries
subcategory: 50-libraries/library-facility
kind: spec
status: 2b           # reference base + br_tree fold (NOFILES console, linkage reassignment, loopback/override, maintenance, error CNT); Library_Facility retained; no conflicts
recovered-fold: NoFiles folded+pruned (4.20+, GUI-OFF/mixed-console modes). FileIO/AuditBR relocated to their own leaf 50-libraries/fileio (2026-06-19). 3 redirect-collision pages re-fetched; verbatim retained on the BR wiki
related: [fnsnap, screenio, fileio]
keywords: [LIBRARY, DEF LIBRARY, LOAD, RELEASE, RESIDENT, BRLIBS, NOFILES]
corrections:
  - "NOFILES added to the frontmatter keywords. It is in this page's own `<library-statement>` production and six lines of its semantics, and was not declared. Found in brls phase 13."
---

# Library facility

Linking and loading reusable `FN…` functions across programs. Defining the functions
(`DEF`/`DEF LIBRARY`, parameters, scope) is in
[10-language/flow-control/functions-udf](../../10-language/flow-control/functions-udf/spec.md);
shipped function packs are in [fnsnap](../fnsnap/spec.md).

<a id="syntax"></a>
## Syntax

```bnf
<library-statement> ::= LIBRARY [ 'RELEASE' ',' ] [ 'NOFILES' ',' ]
                                [ <library-program> ] ':' <library-function> [ ',' <library-function> ]*
                      | LIBRARY [ <library-program> ] ':'        -- load-present form (no functions; loads the named library immediately)
<library-program>  ::= '"' <file-pathname> '"' | <string-expression>
<library-function> ::= 'FN' <identifier>
```

<a id="semantics"></a>
## Semantics

- A function must be **linked with `LIBRARY`** before it can be called — even one defined locally
  with `DEF LIBRARY`. **The `<library-program>` file reference is optional**, which selects between two
  linkage methods:
  - **Named linkage** (reference given, `LIBRARY "PRESLIB": FNX`) links each function **directly** to
    that library.
  - **Unnamed linkage** (reference omitted, `LIBRARY : FNX`) leaves BR to determine which loaded
    library each function links to, resolved by the **search order** below (see the "Linkage" and
    "Named/Unnamed" discussion in `Library_Facility.md`). An **unnamed** statement is **required** to
    call back into the main program.If a program names itself in a LIBRARY statement a second copy of 
    itself is loaded and linked. 
- **`RELEASE`** clears a function's workspace variables after it returns; **`NOFILES`**
  keeps the library's channels separate from the caller's. Both require an explicit
  `<library-program>` be specified in the LIBRARY statement. `OPTION RETAIN` in a RESIDENT library 
  preserves its variables across the
  main program's `CHAIN`s. A **`NOFILES`** library also gets its **own console** (window #0, sized
  from the initiator's, shown only when it awaits operator input); a passed-files library shares the
  caller's window hierarchy. A library can't be both passed-files and NOFILES at once; `NOCLOSE` files
  in a NOFILES library are treated as normal files. It works under `GUI OFF`
  too — each independent console hierarchy keeps its own GUI mode, so modes may be mixed — but
  `PARENT=NONE` is illegal with `GUI OFF`. An inactive `RELEASE`d module can be relinked as either FILES
  or NOFILES regardless of how it was previously loaded.
- **Loading strategies**: *Resident* (loaded once, stays — `EXECUTE "LOAD lib,RESIDENT"`; this
  `LOAD ...,RESIDENT` form is allowed under `EXECUTE` because it does not terminate/replace the
  running program),
  *Present* (`LIBRARY "name":` with no functions loads it immediately, or named-with-functions
  loads it on the first call), *As-needed*
  (`LIBRARY RELEASE,…` — loaded per call, not searched by unnamed linkage). A no-functions
  `LIBRARY "name":` is a **load** directive, **not** a detach — the only way to detach a linkage is to
  end the main program.
- **Search order** (unnamed): the **main program first**, then each loaded library in **reverse load
  order** (last-loaded, first-searched); BR links to the **first** library where the function is
  defined, and that linkage persists until reassigned. As-needed (`RELEASE`) libraries are **not**
  searched (they aren't resident in memory).
 - **Communication**: a library can't see the main program's globals — pass **parameters**, use the 
  **return value**, or call **init functions**. An untrapped error in a library function is reported to
  the caller with `LINE` = the erroneous statement line, `ERR` = the error number, and `CNT` set
  based on the number of values successfully processed (typically via a FORM statement). `STATUS LIBRARY` lists active linkages.

  <a id="clearing"></a>
### Variable clearing by library type
| Library type | Variables cleared |
|---|---|
| Main-program functions | when the main program ends |
| Resident (default) | when the main program ends |
| Resident + `OPTION RETAIN` | only when the library is cleared/reloaded |
| Resident + `RELEASE`, or As-needed | after each function call |

<a id="linkage-loopback"></a>
### Linkage, loopback & maintenance
- **Reassignment**: re-executing a `LIBRARY` statement that names the same function but a different
  library relinks it; when all of a *present* library's linked functions are reassigned it is removed
  from memory (a *resident* one stays until `CLEAR`). All linkages detach when the main program ends.
- **Loopback / override**: a library function can call back into the **main program** — link it with an
  **unnamed** `LIBRARY` statement (the main program is always treated as "loaded last", so it will 
  find the function quickly). A loopback call uses  **fresh stack space** (the caller's 
  original pending loops aren't seen until the library returns).  CAUTION: If you name the main (current) 
  program  in a LIBRARY statement a second copy of the main program will be initiated with all variables 
  cleared  and it's variables will remain separate from the calling instance. This could be very confusing.
- **Maintenance**: when interrupted mid-call, `LIST` shows the *active* (library) program — use **F9**
  for inspection of another loaded module. Saving changes to a running library requires listing it to a
  file and reloading; `REPLACE` has no effect until the main program is ended and the library is reloaded; 
  `CLEAR` a resident library before loading a replacement, and load resident libraries **before** 
  application programs to avoid memory fragmentation.
- **Constraints**: referencing one library both with and without `RELEASE` (same or different functions) 
  errors; `RELEASE` is incompatible with `OPTION RETAIN`; naming a *local non-library* function on a 
  `LIBRARY` statement raises a duplicate-function-definition error.

<a id="fileio"></a>
### FileIO library
The shipped `FILEIO` library is the standard file-access abstraction: it OPENs a file, loads its
`FORM$` layout, sizes the data arrays, and `EXECUTE`s subscript-constant definitions
(`FNOPENFILE`/`FNCLOSEFILE`/`FNGETFILENUMBER`). It has its own leaf —
**[50-libraries/fileio](../fileio/spec.md)** — covering the layout-file model, automatic versioning, the
87-export [Function Reference](../fileio/FileIO_Function_Reference.md), and the full online-doc manual.

<a id="examples"></a>
## Examples

```business-rules
00100 LIBRARY "PRESLIB": FNPRESLIB1, FNPRESLIB2
00200 LIBRARY "ENV$(BRLIBS)mylib.br": fnprocess, fnvalidate
01000 EXECUTE "LOAD RESLIB,RESIDENT"
01400 LIBRARY : FNALIBI                    ! unnamed linkage (search queue)
50000 LIBRARY RELEASE,NOFILES,"MNTCUST": FNMNTCUST   ! run a program as a function
```

<a id="see-also"></a>
## See also

- [10-language/flow-control/functions-udf](../../10-language/flow-control/functions-udf/spec.md) — `DEF`/`DEF LIBRARY`, parameters (`&`), scope
- [fnsnap](../fnsnap/spec.md) — the shipped FnSnap function packs
- [screenio](../screenio/spec.md) — the ScreenIO RAD library
- [fileio](../fileio/spec.md) — the FileIO file-access library (relocated from here to its own leaf, with FileIO_Function_Reference / FileIO_Library / AuditBR)
- [70-commands/program-management](../../70-commands/program-management/spec.md) — `CHAIN` vs library calls, `CLEAR`/`LOAD RESIDENT`
- Backing keyword page retained (deep reference): [Library_Facility](Library_Facility.md) (sample
  program + "turn a program into a callable library function" recipe).

*(Backing pages `Library_(statement)`, `Library_Functions`, `Library_function`, `Libraries_Tutorial`,
`Release_(library)` were folded into this spec and pruned. The 2b
redirect-collision page `NoFiles` was folded here and pruned; verbatim wikitext remains on the BR wiki.)*
