# 30-io-file/file-model

File concepts: internal vs external files, file numbers, locking, sharing.

**📄 Guide → [spec.md](spec.md)** _(status: 2b)_ — The concepts behind BR file I/O: file types, usage modes, access methods, file numbers, and multi-user sharing/locking.

_Backing keyword pages below._

| File | Kind | Summary |
|---|---|---|
| [.$$$](.$$$.md) | statement | Procedure files with names that end in a .$$$ extension will automatically delete themselves when they close. |
| [.BAK](.BAK.md) | statement | .bak (wikipedia:.bak|wikipedia) is the wikipedia:file extension|file extension for a Business Rules! program backup file. |
| [.BR](.BR.md) | statement | .br is the default wikipedia:file extension|file extension for a Business Rules! program file. |
| [Anchor_Record](Anchor_Record.md) | statement | In Internal Files, the Anchor Record is the first record in a linked list, and the basis for accessing linked list data from the master… |
| [LINKED](LINKED.md) | statement | Business Rules now supports LINKED files, which are Business Rules internal files that contain one or more sets of linked records. |
| [Multi-User_Considerations_Tutorial](Multi-User_Considerations_Tutorial.md) | tutorial | In most situations, there will be more than one user accessing the BR programs and files. |
| [OPEN_internal](OPEN_internal.md) | statement | The Open (OPE) Internal statement activates a Business Rules! internal file for input/output. |
| [PROTECT](PROTECT.md) | statement | The Protect command enables and disables two types of file protection. |
