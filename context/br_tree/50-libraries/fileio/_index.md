# 50-libraries/fileio

The FileIO library (Sage AX): layout-driven file access, automatic versioning, DataCrawler, and the Audit BR add-on.

**📄 Guide → [spec.md](spec.md)** _(status: 2b)_ — FileIO is the standard file-access abstraction in this codebase: you describe each data file once in an ASCII layout file, and FileIO OPENs…

<!-- keep -->
Deep-reference pages:
- [FileIO_Function_Reference.md](FileIO_Function_Reference.md) — all 80 `DEF LIBRARY` exports, grouped (source-derived, from `fileio.brs`)
- [FileIO_Library.md](FileIO_Library.md) — the full online-doc manual (layout format, `fnSettings`, DataCrawler, CSV, examples)
- [AuditBR.md](AuditBR.md) — the Audit BR add-on (`fnBeginAudit`/`fnCompare`)
<!-- /keep -->

| File | Kind | Summary |
|---|---|---|
| [AuditBR](AuditBR.md) | concept | Audit BR is a powerful new library from Sage AX, created as a part of Sage AX's continuous mission to empower the BR developer with the… |
| [FileIO Function Reference (source-derived)](FileIO_Function_Reference.md) | reference | FileIO's public surface is 80 DEF LIBRARY functions in fileio.brs. Every signature below is taken verbatim from the shipping source (not the… |
| [FileIO_Library](FileIO_Library.md) | concept | The FileIO Library began as a project to find a way to reduce the effort associated with making changes to data file layouts. |
