# shortcuts — a customizable keyboard-shortcut reference
# https://github.com/Suhaas-code/Shortcuts-cmd
[CmdletBinding()]
param(
    [Parameter(Position = 0)] [string] $Command = '',
    [Parameter(Position = 1, ValueFromRemainingArguments = $true)] [string[]] $Rest
)

$ErrorActionPreference = 'Stop'
$VERSION  = '1.0.0'
$REPO     = 'Suhaas-code/Shortcuts-cmd'
$BASE_URL = "https://github.com/$REPO/releases/latest/download"

function Get-ConfigDir { Join-Path $env:APPDATA 'shortcuts' }
function Get-DataFile  { Join-Path (Get-ConfigDir) 'shortcuts.txt' }

# --- colors ----------------------------------------------------------------
$script:UseColor = (-not $env:NO_COLOR) -and (-not [Console]::IsOutputRedirected)
$e = [char]27
if ($script:UseColor) {
    $C_HDR = "$e[1;36m"; $C_KEY = "$e[0;33m"; $C_RST = "$e[0m"
} else {
    $C_HDR = ''; $C_KEY = ''; $C_RST = ''
}

function Die($msg) { Write-Error "shortcuts: $msg"; exit 1 }

function Get-File($url, $dest) {
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
    } catch { Die "download failed: $url" }
}

function Confirm-Data {
    $df = Get-DataFile
    if (-not (Test-Path $df)) {
        New-Item -ItemType Directory -Force -Path (Get-ConfigDir) | Out-Null
        try { Get-File "$BASE_URL/shortcuts.default.txt" $df }
        catch { Die "no shortcuts file at $df and default download failed. Run: shortcuts reset" }
    }
}

# --- rendering -------------------------------------------------------------
# Parses the data file into sections and prints aligned/colored output.
function Show-Shortcuts([string] $Filter) {
    $lines = Get-Content -LiteralPath (Get-DataFile)
    $sections = New-Object System.Collections.ArrayList
    $cur = $null
    $maxk = 0

    foreach ($line in $lines) {
        if ($line -match '^\s*$') { continue }
        if ($line -match '^#') {
            $cur = [ordered]@{ Name = ($line.Substring(1)).Trim(); Rows = (New-Object System.Collections.ArrayList) }
            [void]$sections.Add($cur)
            continue
        }
        $k = ''; $d = ''
        $tab = $line.IndexOf("`t")
        if ($tab -ge 0) {
            $k = $line.Substring(0, $tab); $d = $line.Substring($tab + 1)
        } elseif ($line -match '  +') {
            $idx = $line.IndexOf($Matches[0])
            $k = $line.Substring(0, $idx); $d = $line.Substring($idx + $Matches[0].Length)
        } else { $k = $line; $d = '' }
        $k = $k.Trim(); $d = $d.Trim()
        if ($null -eq $cur) {
            $cur = [ordered]@{ Name = 'General'; Rows = (New-Object System.Collections.ArrayList) }
            [void]$sections.Add($cur)
        }
        [void]$cur.Rows.Add(@{ Key = $k; Desc = $d })
        if ($k.Length -gt $maxk) { $maxk = $k.Length }
    }

    $pad = $maxk + 2
    $first = $true
    foreach ($s in $sections) {
        $rows = $s.Rows
        if ($Filter) {
            $f = $Filter.ToLower()
            $rows = @($s.Rows | Where-Object { $_.Key.ToLower().Contains($f) -or $_.Desc.ToLower().Contains($f) })
        }
        if ($rows.Count -eq 0) { continue }
        if (-not $first) { Write-Host '' }
        $first = $false
        Write-Host "$C_HDR=== $($s.Name) ===$C_RST"
        foreach ($r in $rows) {
            if ($r.Desc -eq '') {
                Write-Host "$C_KEY$($r.Key)$C_RST"
            } else {
                Write-Host ("$C_KEY{0}$C_RST{1}" -f $r.Key.PadRight($pad), $r.Desc)
            }
        }
    }
}

# --- commands --------------------------------------------------------------
function Invoke-Edit {
    Confirm-Data
    $df = Get-DataFile
    $ed = $env:EDITOR
    if (-not $ed) { $ed = 'notepad' }
    Write-Host 'Opening shortcuts in the default editor...'
    & $ed $df
}

function Invoke-Reset([string[]] $args) {
    $df = Get-DataFile
    $yes = ($args -contains '-y') -or ($args -contains '--yes')
    if ((Test-Path $df) -and (-not $yes)) {
        $ans = Read-Host "Overwrite $df with defaults? [y/N]"
        if ($ans -notmatch '^(y|yes)$') { Die 'cancelled' }
    }
    New-Item -ItemType Directory -Force -Path (Get-ConfigDir) | Out-Null
    Get-File "$BASE_URL/shortcuts.default.txt" $df
    Write-Host "Restored defaults to $df"
}

function Invoke-Update {
    $dest = $PSCommandPath
    if (-not $dest) { $dest = Join-Path $env:LOCALAPPDATA 'Programs\shortcuts\shortcuts.ps1' }
    Get-File "$BASE_URL/shortcuts.ps1" $dest
    Write-Host "Updated shortcuts at $dest"
}

function Show-Help {
    @"
shortcuts — customizable keyboard-shortcut reference (v$VERSION)

Usage:
  shortcuts                 Print your shortcuts
  shortcuts search <term>   Filter shortcuts by keyword
  shortcuts edit            Open your shortcuts in `$env:EDITOR (else notepad)
  shortcuts path            Print the data file path
  shortcuts reset [-y]      Restore the default shortcuts
  shortcuts update          Update the shortcuts script itself
  shortcuts version         Print version
  shortcuts help            Show this help

Data file: $(Get-DataFile)
"@ | Write-Host
}

switch ($Command.ToLower()) {
    ''          { Confirm-Data; Show-Shortcuts '' }
    'list'      { Confirm-Data; Show-Shortcuts '' }
    'edit'      { Invoke-Edit }
    { $_ -in 'search','find' } {
        if (-not $Rest -or -not $Rest[0]) { Die 'usage: shortcuts search <term>' }
        Confirm-Data; Show-Shortcuts $Rest[0]
    }
    { $_ -in 'path','where' } { Write-Host (Get-DataFile) }
    'reset'     { Invoke-Reset $Rest }
    { $_ -in 'update','upgrade' } { Invoke-Update }
    { $_ -in 'version','-v','--version' } { Write-Host "shortcuts $VERSION" }
    { $_ -in 'help','-h','--help' } { Show-Help }
    default     { Write-Host "shortcuts: unknown command `"$Command`"`n"; Show-Help; exit 1 }
}
