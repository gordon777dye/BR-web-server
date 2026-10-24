# 50-libraries/screenio

ScreenIO library, Lexi, and the PhpIO web deployment.

**📄 Guide → [spec.md](spec.md)** _(status: 2b)_ — A Rapid-Application-Development library (a Sage AX tool) for building event-driven, screen-based applications;

<!-- keep -->
Deep-reference pages:
- [ScreenIO_Function_Reference.md](ScreenIO_Function_Reference.md) — the 21 `DEF LIBRARY` exports (ScreenIO v2.95) + event contract (source-derived)
- [ScreenIO_Data_Model.md](ScreenIO_Data_Model.md) — `screenio.dat`/`screenfld.dat` screen & control schema (source-derived, from `filelay/`)
- [ScreenIO_Library.md](ScreenIO_Library.md) — full ~206-section Sage AX wiki manual, captured locally

Internals (dev kit):
- [screenio-guide.md](../../../dev/screenio-guide.md) — how screens compile and run: Helper Library pipeline, screen stack, event dispatch, programmatic authoring
<!-- /keep -->

| File | Kind | Summary |
|---|---|---|
| [ScreenIO Data Model (screen & control definitions)](ScreenIO_Data_Model.md) | reference | A ScreenIO "Screen Function" is data, not code: the designer stores each screen as one record in screen/screenio.dat plus one record per… |
| [ScreenIO Function Reference](ScreenIO_Function_Reference.md) | reference | The library's public surface is 21 DEF LIBRARY functions as of ScreenIO v2.95 (FNVERSION=2.95). |
| [ScreenIO Library (full wiki manual capture)](ScreenIO_Library.md) | reference | The ScreenIO Library is "a Rapid Application Design tool that enables anyone to write complex user interfaces or complete custom programs… |
