<#
.SYNOPSIS
Builds the next commit of the dist branch (the public BR Web Server package) from main.

.DESCRIPTION
Takes the files listed in package\manifest.txt from main's last commit (not from the working
folder), adds every file in package\overlay\ on top of them (brconfig.sys, README.md, .gitignore),
and commits the result to the dist branch, with the previous dist commit as its parent. dist never
shares history with main, so nothing outside the manifest can reach the public repo.

If the dist worktree exists (for example C:\ads_test\gabriel\dist\brweb), it must have no
uncommitted changes, and it is updated to the new commit afterwards so it can be test-run.

Nothing is pushed. The script prints the push commands at the end.

.PARAMETER Message
The commit message. Default: "BR Web Server <version> package", with the version read from
VERSION$ in main's web_server.br.brs.

.PARAMETER Tag
Optional tag for the new commit, for example v2.17.

.PARAMETER Source
The commit or branch to build from. Default: main.

.PARAMETER DryRun
Builds the package and lists how it differs from the current dist, without committing anything.

.EXAMPLE
package\make_dist.ps1 -DryRun

.EXAMPLE
package\make_dist.ps1 -Tag v2.18
#>
param(
   [string]$Message,
   [string]$Tag,
   [string]$Source = 'main',
   [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

function Invoke-Git {
   $out = & git -c core.quotepath=off @args
   if ($LASTEXITCODE -ne 0) { throw "git $($args -join ' ') failed (exit $LASTEXITCODE)" }
   $out
}

$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root
$Manifest = Join-Path $PSScriptRoot 'manifest.txt'
$Overlay = Join-Path $PSScriptRoot 'overlay'

# ***** Checks
$sourceCommit = Invoke-Git rev-parse --verify "$Source^{commit}"
$oldDist = & git rev-parse --verify -q 'refs/heads/dist'
if ($LASTEXITCODE -ne 0) { $oldDist = $null }

if (-not $DryRun) {
   $pending = Invoke-Git status --porcelain -- package
   if ($pending) {
      throw "package\ has uncommitted changes. Commit them to main first, so the master copy matches what is published:`n$($pending -join "`n")"
   }
}

$worktree = $null
$wtPath = $null
foreach ($line in (Invoke-Git worktree list --porcelain)) {
   if ($line -like 'worktree *') { $wtPath = $line.Substring(9) }
   elseif ($line -eq 'branch refs/heads/dist') { $worktree = $wtPath }
}
if ($worktree -and -not $DryRun) {
   $dirty = Invoke-Git -C $worktree status --porcelain
   if ($dirty) {
      throw "The dist worktree $worktree has uncommitted changes. Commit or discard them first:`n$($dirty -join "`n")"
   }
}

# ***** Read the manifest
$entries = Get-Content $Manifest | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') }

# ***** Select main's files
$files = [ordered]@{}   # path -> "mode,sha"
$matched = @{}
foreach ($line in (Invoke-Git ls-tree -r --full-tree $sourceCommit)) {
   $meta, $path = $line -split "`t", 2
   $mode, $type, $sha = $meta -split ' '
   foreach ($e in $entries) {
      if ($path -eq $e -or ($e.EndsWith('/') -and $path.StartsWith($e))) {
         $files[$path] = "$mode,$sha"
         $matched[$e] = $true
         break
      }
   }
}
$unmatched = $entries | Where-Object { -not $matched.ContainsKey($_) }
if ($unmatched) {
   throw "These manifest lines match nothing in ${Source}:`n$($unmatched -join "`n")"
}

# ***** Add the overlay files
foreach ($f in (Get-ChildItem $Overlay -Recurse -File -Force)) {
   $rel = $f.FullName.Substring($Overlay.Length + 1).Replace('\', '/')
   $sha = Invoke-Git hash-object -w --path $rel $f.FullName
   $files[$rel] = "100644,$sha"
}

# ***** Build the tree in a temporary index (main's own index is not touched)
$index = [IO.Path]::GetTempFileName()
Remove-Item $index
$env:GIT_INDEX_FILE = $index
try {
   foreach ($path in $files.Keys) {
      Invoke-Git update-index --add --cacheinfo "$($files[$path]),$path" | Out-Null
   }
   $tree = Invoke-Git write-tree
}
finally {
   Remove-Item Env:GIT_INDEX_FILE
   Remove-Item $index -ErrorAction SilentlyContinue
}

Write-Host "Package: $($files.Count) files from $Source ($($sourceCommit.Substring(0,7))) plus overlay\"

if ($oldDist) {
   $oldTree = Invoke-Git rev-parse "$oldDist^{tree}"
   if ($tree -eq $oldTree) {
      Write-Host "No changes: the package is the same as dist ($($oldDist.Substring(0,7)))."
      return
   }
   Write-Host "Changes from dist ($($oldDist.Substring(0,7))):"
   Invoke-Git diff-tree -r --name-status $oldTree $tree | ForEach-Object { Write-Host "   $_" }
}

if ($DryRun) {
   Write-Host 'Dry run: nothing committed.'
   return
}

# ***** Commit, move dist, tag
if (-not $Message) {
   $version = (Invoke-Git show "${sourceCommit}:web_server.br.brs" |
      Select-String -Pattern 'VERSION\$ *= *"([^"]+)"' | Select-Object -First 1).Matches[0].Groups[1].Value
   $Message = "BR Web Server $version package"
}
if ($oldDist) {
   $commit = Invoke-Git commit-tree $tree -p $oldDist -m $Message
   Invoke-Git update-ref refs/heads/dist $commit $oldDist
}
else {
   $commit = Invoke-Git commit-tree $tree -m $Message
   Invoke-Git update-ref refs/heads/dist $commit
}
Write-Host "dist is now $($commit.Substring(0,7)): $Message"

if ($Tag) {
   Invoke-Git tag $Tag $commit
   Write-Host "Tagged $Tag"
}

# The worktree had no changes (checked above), so this only brings its files up to the new commit.
if ($worktree) {
   Invoke-Git -C $worktree reset --hard --quiet
   Write-Host "Updated the worktree $worktree"
}

# Push only this tag by name: --tags would send every tag, and a tag on main would publish main.
$tags = if ($Tag) { " refs/tags/$Tag" } else { '' }
Write-Host ''
Write-Host 'To publish and back up:'
Write-Host "   git push public dist:main$tags"
Write-Host "   git push origin dist$tags"
