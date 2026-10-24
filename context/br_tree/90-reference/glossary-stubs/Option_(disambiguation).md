---
title: Option_(disambiguation)
file: Option_(disambiguation).md
category: 90-reference
subcategory: 90-reference/glossary-stubs
kind: concept
related: [Option (Config), startup, br32.exe, Option (statement), Execute, Config, statement]
---
There are two methods of implementing **Options** in BR!.  `Option (Config)` is used primarily at `startup` (see `br32.exe`) and has more options while `Option (statement)` occurs in running BR programs and are found on program lines.  However an `Execute` `Config` `statement` enables all Option (Config) options to be used as statements.  Do note that there is a difference in syntax.  In the following code snippet line 10 utilizes an Option (statement) whilst 20 uses Option (Config).

 00010  Option Base 1
 00020  Execute "Config Option 1 Off"

In the above code snippet, line 10 utilizes the Option `Statement` and line 20 utilizes Option `Config`.

*`Option (Config)`
*`Option (statement)`
