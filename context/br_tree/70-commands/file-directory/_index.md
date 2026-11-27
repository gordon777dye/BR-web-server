# 70-commands/file-directory

File and directory commands: CHDIR, DIR, COPY, MOVE, FREE, drop options.

**📄 Guide → [spec.md](spec.md)** _(status: 2b)_ — OS-level file and directory operations, runnable interactively or from a procedure / EXECUTE. For opening files inside a program see

<!-- keep -->
**📄 Patterns and completion → [filename-patterns.md](filename-patterns.md)** — glob patterns for `DIR`, `COPY`, `MOVE`, `RENAME`, `FREE`, `DROP` and `TYPE`; `/` as a folder separator (`OPTION 84`); Tab completion of file names at the `READY` prompt.

**📄 Regular expressions → [ECMA_REGEX.md](ECMA_REGEX.md)** — the ECMAScript regex syntax of a `SEARCH /.../` pattern: what is supported, what is error 1009, and how `-I`, `-W`, `-B` and `-~` apply. `HELP COMMANDS REGEX` shows it.

_Backing keyword pages pruned; `spec.md`, `filename-patterns.md` and `ECMA_REGEX.md` are the content._
<!-- /keep -->

| File | Kind | Summary |
|---|---|---|
| [Regular expressions (ECMAScript)](ECMA_REGEX.md) | reference | The regular expressions a SEARCH /.../ pattern takes: supported syntax, what is error 1009, and the attributes. HELP COMMANDS REGEX. |
| [File name patterns and Tab completion](filename-patterns.md) | concept | The file and directory commands share three BR 5.0 behaviours, stated in full here: glob patterns in file names, / as a folder separator… |
