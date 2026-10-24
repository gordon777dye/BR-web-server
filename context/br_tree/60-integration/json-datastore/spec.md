---
title: JSON & data store
file: spec.md
source: §JSON and Data Store
category: 60-integration
subcategory: 60-integration/json-datastore
kind: spec
status: 2b           # synthesized from the reference; new leaf, no backing pages to fold (nothing pending)
related: [web, system-functions]
keywords: [JSON, datastore, object-store]
---

# JSON & data store

In-memory storage of named objects (JSON or other strings) plus functions to build, parse, and
serve JSON — the data layer behind BR web services. Sending content to the browser is in
[web](../web/spec.md); the HTTP client OPEN is in
[30-io-file/statements](../../30-io-file/statements/spec.md#open).

<a id="semantics"></a>
## Semantics

**Data store** (in the WEB_SERVER program) holds named objects across web requests. Limits: object
names ≤200 chars (case-insensitive, bracketed `[n]` subscripts for duplicates), keys ≤50, values
≤5000 bytes, ≤300 KB per JSON object, 100 MB total. Set `BRConfig.sys` stack to 500000+ for JSON
work.

**JSON** uses the usual model: object `{}` (name-value members), array `[]`, values =
string/number/object/array/true/false/null. Functions address values by **fully-qualified name**:
`object.member.submember`, `object[n].member`, `object.member[n]`.

<a id="object-store"></a>
### Object store functions
| Function | Purpose |
|---|---|
| `FNPut_Object(name, s$)` | create/replace a named object |
| `FNInsert_Object(name, s$)` | insert ahead of an existing same-named object |
| `FNGet_Object(name, s$)` | retrieve an object's value (`-10` = not found) |
| `FNSend_Object(name [,suppress_header,suppress_length])` | send object to the HTTP client |
| `FNDelete_Object(name)` | delete the named object |

<a id="json-functions"></a>
### JSON value functions (by path)
| Function | Purpose |
|---|---|
| `FNPut_Json(fqname, v$; must-exist, as-is)` | create/replace a value at a path |
| `FNInsert_Json(fqname, v$; as-is)` | insert (turns duplicate members into an array) |
| `FNAppend_Json(fqname, v$; as-is)` | append after a location |
| `FNDelete_Json(fqname; null-flag)` | remove (or blank) a value |
| `FNGet_Json(fqname, container$; as-is)` | read a value into a variable |
| `FNCompile_Json("{"|"[", member, MAT keys$, MAT values$, out$)` | build JSON from arrays |
| `FNParse_Json(s$, type$, name$, MAT keys$, MAT values$)` | parse JSON into arrays |
| `FNCompile_Object` / `FNParse_Object` | same, operating directly on stored objects |

Non-numeric values are auto-quoted unless the `as-is` flag is set.

<a id="html"></a>
### HTML output helpers
`FNSend_string(s$ [,…])` sends a string (≤30 KB); `FNSend_Page(file; MAT args$, MAT repl$ [,…])`
sends a page file with `{{arg}}`→value substitutions. BR sets the HTTP content type from the first
character: `<`→`text/html`; `{`/`[`/`"`→`application/json`.

<a id="return-codes"></a>
## Return codes (selected)
`1` success · `1++` elements parsed · `-10` object not found · `-21..-29` member not found at
level 1–9 · `-41+` unbalanced quotes/braces · `-50` page not found · `-500` keys/values mismatch ·
`-510` bad value-type · `-520` invalid JSON · `-n` string overflow at segment n.

<a id="examples"></a>
## Examples

```business-rules
! Build and send a REST response
15130 FNPut_Json("api_response", '{"status":"success","data":{}}')
15170 FNPut_Json("api_response.data.user_id", USER_ID$)
15200 FOR I=1 TO N : FNInsert_Json("api_response.data.results", RESULTS$(I)) : NEXT I
15250 FNSend_Object("api_response")

! Parse an inbound JSON request body
16170 LET RC = FNParse_Json(INBOUND$, TYPE$, NAME$, MAT KEYS$, MAT VALUES$)
```

<a id="see-also"></a>
## See also

- [web](../web/spec.md) — BR as a web server that consumes/serves this JSON
- [system-functions](../../10-language/data-manipulation/system-functions/spec.md#array-functions) — `STR2MAT`/`MAT2STR` for non-JSON parsing
- [30-io-file/statements](../../30-io-file/statements/spec.md#open) — `HTTP=CLIENT` channel
- Backing keyword page: [Json](Json.md)
