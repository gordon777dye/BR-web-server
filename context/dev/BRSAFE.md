# brsafe — editing BR source that holds CP437 bytes

`*.br.brs` / `*.wbs` source is stored as **CP437**. A few files carry single‑byte high‑bit
characters (box‑drawing / window‑frame `data` tables). `Edit` / `Write` / `MultiEdit` re‑encode
the whole file as UTF‑8 and corrupt those bytes — **even when your edit is ASCII and nowhere
near them**. `brsafe` (`context/dev/tools/brsafe.exe`) edits such files at the byte level.

## Rule

Before editing any `*.br.brs` / `*.wbs` source file, run `brsafe check <file>`:

- **exit 0** — pure ASCII → use `Edit` / `Write` normally.
- **exit 1** — has CP437 bytes → **do not** use `Edit` / `Write` / `MultiEdit`. Read with
  `brsafe view`, edit with `brsafe replace`.

A `PreToolUse` hook can enforce this automatically by blocking `Edit`/`Write`/`MultiEdit` on such
files before they ever run — see **Installing the enforcement hook** below. Check whether one is
already installed before assuming you need to add it: `Get-Content "$env:USERPROFILE\.claude\settings.json"`
and look for a `hooks.PreToolUse` entry whose `matcher` includes `Edit`.

## Installing the enforcement hook

Two files, both **outside this app tree**, in the user's Claude Code config — install once, and it
protects every BR app tree that carries this same `context/dev/tools/brsafe.exe` layout (path
resolution below walks upward from the edited file, it isn't hardcoded to one app).

**1. `$env:USERPROFILE\.claude\hooks\brsafe-guard.ps1`** (create the `hooks` folder if absent):

```powershell
# PreToolUse hook: block Edit/Write/MultiEdit on *.br.brs / *.wbs source files that still
# carry CP437 high-bit bytes (window-frame `data` tables). Those tools re-encode the whole
# file as UTF-8 and corrupt such bytes, even when the edit itself is plain ASCII nowhere near
# them. Route flagged files through brsafe (view/replace) instead — see context/dev/BRSAFE.md
# in whichever BR app tree the file lives under.
#
# Claude Code PreToolUse contract: exit 0 = allow, exit 2 = block (stderr text is fed back to
# Claude as the reason). Any ambiguous/unresolvable situation below fails OPEN (exit 0) rather
# than blocking unrelated work — this hook exists to catch a specific known corruption risk,
# not to gate all file edits.

try {
    $raw = [Console]::In.ReadToEnd()
    $payload = $raw | ConvertFrom-Json -ErrorAction Stop
} catch {
    exit 0
}

$toolName = $payload.tool_name
if ($toolName -notmatch '^(Edit|Write|MultiEdit)$') { exit 0 }

$filePath = $payload.tool_input.file_path
if (-not $filePath) { exit 0 }

if ($filePath -notmatch '\.(br\.brs|wbs)$') { exit 0 }

if (-not [System.IO.Path]::IsPathRooted($filePath)) {
    $cwd = $payload.cwd
    if ($cwd) { $filePath = Join-Path $cwd $filePath }
}

# A brand-new file can't yet hold corrupted bytes.
if (-not (Test-Path -LiteralPath $filePath)) { exit 0 }

# Walk upward from the file looking for this app tree's own context/dev/tools/brsafe.exe —
# each BR app tree carries its own copy of the context kit.
$dir = Split-Path -Parent $filePath
$brsafe = $null
while ($dir) {
    $candidate = Join-Path $dir 'context\dev\tools\brsafe.exe'
    if (Test-Path -LiteralPath $candidate) { $brsafe = $candidate; break }
    $parent = Split-Path -Parent $dir
    if ($parent -eq $dir) { break }
    $dir = $parent
}

if (-not $brsafe) {
    [Console]::Error.WriteLine("brsafe-guard: no context/dev/tools/brsafe.exe found above $filePath - cannot verify CP437 safety, allowing edit unchecked.")
    exit 0
}

& $brsafe check "$filePath" >$null 2>$null
$brsafeExit = $LASTEXITCODE

if ($brsafeExit -eq 1) {
    [Console]::Error.WriteLine("$filePath contains CP437 high-bit bytes (window-frame data tables). Edit/Write/MultiEdit will corrupt them by re-encoding the file as UTF-8. Use 'brsafe view' to read it and 'brsafe replace' to edit it instead - see context/dev/BRSAFE.md.")
    exit 2
}

exit 0
```

**Critical implementation gotcha — do not "clean up" the native-call line.** `& $brsafe check
"$filePath" >$null 2>$null` looks like it could be simplified to `2>&1 | Out-Null`, or the whole
script could open with `$ErrorActionPreference = 'Stop'` for safety. **Both break it.** Under
PowerShell 5.1, once `$ErrorActionPreference` is `'Stop'`, *any* stderr text from a native
executable — even redirected to `$null`, not just merged with `2>&1` — is promoted to a
terminating `NativeCommandError` that isn't caught (it happens after the only `try/catch` in the
script), so the hook process dies with exit code 1 (a PowerShell crash) instead of the intended
exit code 2 (a deliberate block). This was hit and fixed empirically while building this hook:
keep `$ErrorActionPreference` at its default (`'Continue'`) for the whole script, and scope
`-ErrorAction Stop` to only the one cmdlet call (`ConvertFrom-Json`) that must fail fast into the
`catch`.

**2. Add to `$env:USERPROFILE\.claude\settings.json`** — merge this into the existing `hooks` key
if one is already present, don't overwrite the file:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"C:\\Users\\<user>\\.claude\\hooks\\brsafe-guard.ps1\"",
            "timeout": 15
          }
        ]
      }
    ]
  }
}
```

Substitute the real profile path for `<user>` (`$env:USERPROFILE` at install time) — the `command`
value is a literal string, not expanded at runtime.

**Design notes** (why it's shaped this way, so a future edit doesn't regress it):
- **Installed user-level, not project-level.** `~/.claude/settings.json` applies across every app
  tree, so one install protects `qsmrp`, `qsmrp2`, and any future BR app that carries this kit —
  the alternative (a project-local `.claude/settings.json`) would need reinstalling per app tree.
- **`brsafe.exe` is located by walking upward from the edited file**, never hardcoded to one app
  root, so the same installed hook works no matter which app tree's file is being edited or what
  the process's current directory happens to be.
- **Fails open, not closed**, on every ambiguous case: unparseable hook JSON, a missing
  `file_path`, a non-existent file (new file — nothing to corrupt yet), or no `brsafe.exe` found
  above the file. The hook exists to catch one specific, known corruption mechanism — it must never
  become a reason unrelated file edits stop working.
- **Registers on `Edit`, `Write`, and `MultiEdit`** — all three tools do the same whole-file
  UTF-8 re-encode that corrupts CP437 bytes.

**Verify the install** (a hook only takes effect for *new* Claude Code sessions — restart before
testing). From the app root, simulate the three cases a real tool call would trigger:

```powershell
$hook = "$env:USERPROFILE\.claude\hooks\brsafe-guard.ps1"
# A file brsafe flags -> must print a message and exit 2
'{"tool_name":"Edit","tool_input":{"file_path":"cop\\loadb860.br.brs"},"cwd":"C:\\ADS\\qsmrp2"}' | powershell -NoProfile -File $hook; $LASTEXITCODE
# A non-BR file -> must exit 0, no output
'{"tool_name":"Edit","tool_input":{"file_path":"README.md"},"cwd":"C:\\ADS\\qsmrp2"}' | powershell -NoProfile -File $hook; $LASTEXITCODE
```

Then confirm live in a fresh session: ask Claude to `Edit` a file that `brsafe check` flags —
the tool call should be refused with the hook's message, without Claude needing to remember to
check first.

## Commands

### `brsafe view <file> [a:b]`
Prints the file (or a line range) to **stdout** as UTF‑8, so frame characters are legible
(`Read` shows `<?>` for them). Use it to get line numbers for `replace`.
`a:b` is **physical, 1‑based, inclusive**: `a` = one line, `a:` = a→EOF, `:b` = start→b.

### `brsafe replace <file> <a:b> [--old <prefix>] --new <text>|@file|- [--dry-run]`
Replaces physical lines `a`–`b` with `--new` (any resulting line count, including 0).

| element | rule |
|---|---|
| `<a:b>` | physical, 1‑based, inclusive — the numbers `brsafe view` prints |
| `--old <prefix>` | must be a **prefix of line `a`**. Mismatch → abort, nothing written. **Pass it on every call** as an ASCII anchor, e.g. the BR line number: `--old '07080'`. |
| `--new` | **required.** `-` = stdin (heredoc), `@file`, or an inline string. **Empty value deletes `a:b`.** Read as UTF‑8, written as CP437; a character with no CP437 mapping is a hard error and nothing is written. |
| `--dry-run` | print the old/new blocks to **stderr**; write nothing |

Lines outside `a:b` are byte‑copied untouched. CRLF and the file's trailing‑newline state are
preserved. Success prints one line to stdout:
`replaced 147:147 (1 line) -> 1 line; encoding still CP437`.

### `brsafe check <file>` — exit 0 = ASCII, exit 1 = has CP437 bytes.
### `brsafe scan [dir]` — list `*.brs` / `*.wbs` under `dir` that carry CP437 bytes.

## Do / don't

- **Do** take line numbers from `brsafe view`, not `Read`.
- **Do** pass `--old` on every `replace`.
- **Do** verify after an edit: `file <path>` must still report `ISO-8859`, not `UTF-8`.
- **Don't** copy box‑drawing characters out of `view` output into `--old` / `--new`. Edit ASCII
  code regions only — the static frame `data` tables never need editing.
- **Don't** `brsafe view f > f`.

## Exit codes

`0` ok · `1` `check` "has bytes" **or** `replace` semantic failure (`--old` mismatch,
unmappable character, bad range) · `2` usage / I/O error · `3` internal invariant (file left
untouched).

Full CLI: `brsafe -h`. Source: `context/dev/tools/brsafe.go`.

## Example

```bash
brsafe check  glp/accountp.br.brs            # exit 1 → route through brsafe
brsafe view   glp/accountp.br.brs 260:300    # read the frame tables; note line numbers

brsafe replace oap/shipperx.br.brs 147 \
      --old '07080' \
      --new '07080             let _ASN_OK= FNCOMM(SHIP$(2),SHIP$(4))  !xmit'
# → replaced 147:147 (1 line) -> 1 line; encoding still CP437

brsafe replace oap/shipperx.br.brs 200:204 --old '07540' --new - <<'EOF'
07540             print #PRINTER: "done" !:
                  let DONE = 1
EOF

brsafe replace oap/shipperx.br.brs 200:204 --old '07540' --new ''   # delete the range
```
