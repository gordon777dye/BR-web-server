<#
.SYNOPSIS
  Headlessly run a .brs file through Lexi (translate Lexi-only syntax to plain, numbered BR),
  and optionally compile the translated result to a .br object -without opening VS Code.

.DESCRIPTION
  Lexi (context/dev/BR_launch.md's "The Lexi preprocessor" section) is normally invoked by the
  "BR Language Server" VS Code extension (crs-dev.vslang-br) on save. This script reproduces that
  same mechanism directly: it loads the extension's bundled lexionly.brs/linenum.brs driver
  program, injects Infile$/Outfile$ by typing extra numbered lines into it (exactly as the
  extension itself does), runs it through the bundled brnative.exe with unattended logging so a
  bad input can't hang the shell, and reports the result.

  Only use this for an app confirmed to use Lexi (check app/conventions.md, or grep its source
  for `/* `, `&=`, `#Select#` -see essentials.md for the syntax list). Feeding this a plain BR
  file that doesn't need Lexi is harmless (Lexi passes plain BR through unchanged other than
  adding line numbers), but pointless.

.PARAMETER Source
  Path to the .brs file to translate. Required.

.PARAMETER OutFile
  Path for the translated, plain-BR output. Defaults to "<Source>.lexiout.brs" next to the
  source.

.PARAMETER Compile
  Also compile the translated output to a .br object via LOAD .../SAVE or REPLACE (whichever
  applies), using the same bundled runtime. Off by default -this script's primary job is
  translation; compiling is a convenience for a full headless round-trip.

.PARAMETER OutObject
  Path for the compiled .br when -Compile is given. Defaults to Source with its extension
  replaced by .br.

.PARAMETER LexiPath
  Path to the extension's Lexi/ folder (containing lexi.brs, lexionly.brs, linenum.brs,
  brnative.exe, wbconfig.sys). Auto-detected under
  "$env:USERPROFILE\.vscode\extensions\crs-dev.vslang-br-*\Lexi" if not given -pass this
  explicitly if Lexi lives somewhere else (e.g. this app's own root lexi.brs/lexi.br, which is
  the copy ScreenIO itself uses -see conventions.md section 7). That app-root copy has no bundled
  brnative.exe/wbconfig.sys of its own, so -LexiPath in that case should still point at a folder
  that has (or -BrExe/-WbConfig should be given explicitly).

.PARAMETER BrExe
  Path to the BR executable to run Lexi with. Defaults to "<LexiPath>\brnative.exe".

.PARAMETER WbConfig
  Path to the wbconfig to run Lexi with. Defaults to "<LexiPath>\wbconfig.sys" (Lexi's own
  config -separate from any app's brconfig.sys).

.PARAMETER KeepTemp
  Don't delete the generated proc/config/log temp files afterward. Useful for debugging a
  failure.

.PARAMETER TimeoutSec
  Kill the BR process if it hasn't exited after this many seconds (default 30). Should never
  actually be hit in unattended mode -BR aborts fast on its own when it can't proceed -but this
  is a hard safety net against a genuinely hung process.

.EXAMPLE
  .\lexi-compile.ps1 -Source C:\Everything\Work\SageLive\panel.brs -OutFile C:\scratch\panel.plain.brs

.EXAMPLE
  .\lexi-compile.ps1 -Source .\myedit.brs -Compile
  # produces .\myedit.lexiout.brs (translated) and .\myedit.br (compiled)

.NOTES
  Verified 2026-09-11 against the crs-dev.vslang-br 0.1.22 bundled Lexi: both the translate-only
  path and -Compile (confirmed the resulting .br LOADs as an object and RUNs cleanly, no errors)
  were run end-to-end, not just read from the extension's code. The Infile$/Outfile$ injection
  mechanism (typing numbered lines into the loaded lexionly.brs/linenum.brs program) is
  reverse-engineered from that extension's dist/extension.js and confirmed to match its real
  behavior. If a compile/run attempt reports a stray error with no obvious cause, check for a
  leftover log file from a previous run first (see BR_launch.md's "operational hazards" -a
  locked/stale log file produced a spurious exit 99 during this script's own testing that a
  fresh run didn't reproduce).
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$Source,
  [string]$OutFile,
  [switch]$Compile,
  [string]$OutObject,
  [string]$LexiPath,
  [string]$BrExe,
  [string]$WbConfig,
  [switch]$KeepTemp,
  [int]$TimeoutSec = 30
)

$ErrorActionPreference = 'Stop'

function Resolve-LexiPath {
  param([string]$Explicit)
  if ($Explicit) {
    if (-not (Test-Path $Explicit)) { throw "LexiPath '$Explicit' does not exist." }
    return (Resolve-Path $Explicit).Path
  }
  $candidates = Get-ChildItem "$env:USERPROFILE\.vscode\extensions" -Directory -Filter 'crs-dev.vslang-br-*' -ErrorAction SilentlyContinue |
    Sort-Object Name -Descending
  foreach ($c in $candidates) {
    $p = Join-Path $c.FullName 'Lexi'
    if (Test-Path (Join-Path $p 'lexi.brs')) { return $p }
  }
  throw "Could not auto-detect the Lexi folder under $env:USERPROFILE\.vscode\extensions\crs-dev.vslang-br-*\Lexi. Pass -LexiPath explicitly."
}

function Test-HasLineNumbers {
  param([string]$Path)
  $firstLine = Get-Content -Path $Path -TotalCount 50 | Where-Object { $_.Trim().Length -gt 0 } | Select-Object -First 1
  if (-not $firstLine) { return $false }
  return [regex]::IsMatch($firstLine, '^\s*\d{1,5}\s')
}

$Source = (Resolve-Path $Source).Path
if (-not $OutFile) { $OutFile = "$Source.lexiout.brs" }
if ($Compile -and -not $OutObject) { $OutObject = [System.IO.Path]::ChangeExtension($Source, '.br') }

$LexiPath = Resolve-LexiPath -Explicit $LexiPath
if (-not $BrExe) { $BrExe = Join-Path $LexiPath 'brnative.exe' }
if (-not $WbConfig) { $WbConfig = Join-Path $LexiPath 'wbconfig.sys' }
if (-not (Test-Path $BrExe)) { throw "BR executable not found: $BrExe" }
if (-not (Test-Path $WbConfig)) { throw "wbconfig not found: $WbConfig" }

$driver = if (Test-HasLineNumbers $Source) { 'lexionly.brs' } else { 'linenum.brs' }

$work = Join-Path $env:TEMP ("lexi-compile-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work | Out-Null
$logFile = Join-Path $work 'startlog.txt'
$unattendedConfig = Join-Path $work 'wbconfig.ai_util'
$translateProc = Join-Path $work 'translate.prc'

# Unattended config = Lexi's own wbconfig.sys with an UNATTENDED LOGGING line prepended, so a
# bad input aborts fast instead of hanging at an interactive prompt (see BR_launch.md's
# "operational hazards" section).
$wbconfigBody = Get-Content -Path $WbConfig -Raw
Set-Content -Path $unattendedConfig -Value ("LOGGING 10, :$logFile, unattended`r`n" + $wbconfigBody) -NoNewline

$outFileFull = if ([System.IO.Path]::IsPathRooted($OutFile)) { $OutFile } else { Join-Path (Get-Location) $OutFile }

$procBody = @"
proc noecho
subproc $driver
00025 Infile$=":$Source"
00026 Outfile$=":$outFileFull"
run
clear
system
"@
Set-Content -Path $translateProc -Value $procBody -NoNewline

function Invoke-BrProc {
  param([string]$ProcPath, [string]$Cwd, [string]$Exe, [string]$Config, [int]$Timeout)
  # Windows PowerShell 5.1's ProcessStartInfo has no ArgumentList (that's .NET Core+ only) -
  # build a single Arguments string instead, quoting each token so paths with spaces survive.
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = $Exe
  $psi.WorkingDirectory = $Cwd
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError = $true
  $psi.UseShellExecute = $false
  $psi.Arguments = "`"proc :$ProcPath`" `"-$Config`""
  $p = [System.Diagnostics.Process]::Start($psi)
  $stdout = $p.StandardOutput.ReadToEndAsync()
  $stderr = $p.StandardError.ReadToEndAsync()
  if (-not $p.WaitForExit($Timeout * 1000)) {
    $p.Kill()
    throw "BR process timed out after ${Timeout}s and was killed -check for a leaked WSID slot on the next run (see BR_launch.md's operational hazards)."
  }
  [PSCustomObject]@{
    ExitCode = $p.ExitCode
    StdOut   = $stdout.Result
    StdErr   = $stderr.Result
  }
}

Write-Verbose "Running $driver against $Source (cwd=$LexiPath)"
$result = Invoke-BrProc -ProcPath $translateProc -Cwd $LexiPath -Exe $BrExe -Config $unattendedConfig -Timeout $TimeoutSec

$failed = ($result.ExitCode -ne 0) -or ($result.StdOut -match 'Input attempted in unattended mode') -or ($result.StdOut -match 'Unattended processing terminated by error')
if ($failed -or -not (Test-Path $outFileFull)) {
  if (-not $KeepTemp) { } else { Write-Host "Temp files kept at: $work" }
  throw "Lexi translation failed (exit=$($result.ExitCode)). BR output:`n$($result.StdOut)`n$($result.StdErr)"
}

Write-Host "Translated: $Source -> $outFileFull"

if ($Compile) {
  $compileProc = Join-Path $work 'compile.prc'
  $existsCheck = "exists("":$OutObject"")"
  $compileBody = @"
proc noecho
load ":$outFileFull" source
skip PROGRAM_REPLACE if $existsCheck
save ":$OutObject"
skip XIT
:PROGRAM_REPLACE
replace ":$OutObject"
:XIT
system
"@
  Set-Content -Path $compileProc -Value $compileBody -NoNewline
  Write-Verbose "Compiling $outFileFull -> $OutObject"
  $compileResult = Invoke-BrProc -ProcPath $compileProc -Cwd $LexiPath -Exe $BrExe -Config $unattendedConfig -Timeout $TimeoutSec
  $compileFailed = ($compileResult.ExitCode -ne 0) -or ($compileResult.StdOut -match 'Input attempted in unattended mode') -or ($compileResult.StdOut -match 'Unattended processing terminated by error')
  if ($compileFailed -or -not (Test-Path $OutObject)) {
    throw "Compile step failed (exit=$($compileResult.ExitCode)). BR output:`n$($compileResult.StdOut)`n$($compileResult.StdErr)"
  }
  Write-Host "Compiled: $outFileFull -> $OutObject"
}

if (-not $KeepTemp) {
  Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue
} else {
  Write-Host "Temp files kept at: $work"
}

[PSCustomObject]@{
  Translated = $outFileFull
  Object     = if ($Compile) { $OutObject } else { $null }
}
