# shortcuts — a customizable keyboard-shortcut reference
# https://github.com/Suhaas-code/shortcuts-cmd
[CmdletBinding()]
param(
    [Parameter(Position = 0)] [string] $Command = '',
    [Parameter(Position = 1, ValueFromRemainingArguments = $true)] [string[]] $Rest
)

$ErrorActionPreference = 'Stop'
$VERSION  = '1.4.0'
$REPO     = 'Suhaas-code/shortcuts-cmd'
$BASE_URL = "https://github.com/$REPO/releases/latest/download"

function Get-ConfigDir { Join-Path $env:APPDATA 'shortcuts' }
function Get-DataFile  { Join-Path (Get-ConfigDir) 'shortcuts.txt' }

# --- colors ----------------------------------------------------------------
$script:UseColor = (-not $env:NO_COLOR) -and (-not [Console]::IsOutputRedirected)
$e = [char]27
$script:Rst = if ($script:UseColor) { "$e[0m" } else { '' }

# Default color specs — overridable via `// color <target> = <spec>` in the data file.
$script:SpecHeader = 'bold cyan'
$script:SpecKey    = 'green'
$script:SpecDesc   = 'default'
$script:SpecCode   = 'bold yellow'

$script:AnsiMap = @{
    'bold' = 1; 'dim' = 2; 'italic' = 3; 'underline' = 4
    'black' = 30; 'red' = 31; 'green' = 32; 'yellow' = 33
    'blue' = 34; 'magenta' = 35; 'cyan' = 36; 'white' = 37
    'gray' = 90; 'grey' = 90; 'bright-black' = 90; 'bright-red' = 91
    'bright-green' = 92; 'bright-yellow' = 93; 'bright-blue' = 94
    'bright-magenta' = 95; 'bright-cyan' = 96; 'bright-white' = 97
}

function ConvertTo-Ansi([string] $spec) {
    if (-not $script:UseColor) { return '' }
    $codes = @()
    foreach ($t in ($spec -split '\s+')) {
        if (-not $t -or $t -in 'default', 'none') { continue }
        if ($script:AnsiMap.ContainsKey($t)) { $codes += $script:AnsiMap[$t] }
    }
    if ($codes.Count -eq 0) { return '' }
    "$e[" + ($codes -join ';') + 'm'
}

function Read-ColorDirectives([string[]] $lines) {
    foreach ($line in $lines) {
        if ($line -notmatch '^\s*//') { continue }
        # `// ansi = off` disables all color/styling (avoids ANSI leaking over SSH/WSL).
        if ($line -match '^\s*//\s*ansi\s*=?\s*(\w+)') {
            if ($Matches[1].ToLower() -in 'off','false','no','0','disable') {
                $script:UseColor = $false; $script:Rst = ''
            }
            continue
        }
        if ($line -match '^\s*//\s*color\s+(\w+)\s*=?\s*(.*)$') {
            $val = $Matches[2].Trim()
            switch ($Matches[1].ToLower()) {
                'header'      { $script:SpecHeader = $val }
                'key'         { $script:SpecKey = $val }
                'desc'        { $script:SpecDesc = $val }
                'description' { $script:SpecDesc = $val }
                'code'        { $script:SpecCode = $val }
            }
        }
    }
}

function Format-Colored([string] $code, [string] $text) {
    if ($code) { "$code$text$($script:Rst)" } else { $text }
}

# Converts one Markdown emphasis marker (e.g. `**`) into ANSI on/off codes.
# Codes accumulate over the surrounding color, so <off> (22/23) restores it
# without dropping the base color. Markers are always stripped, even with color off.
function Convert-Emphasis([string] $s, [string] $marker, [int] $on, [int] $off) {
    $out = ''
    $mlen = $marker.Length
    while (($p = $s.IndexOf($marker)) -ge 0) {
        $out += $s.Substring(0, $p)
        $s = $s.Substring($p + $mlen)
        $q = $s.IndexOf($marker)
        if ($q -lt 0) { return $out + $marker + $s }   # unmatched — keep literal
        $inner = $s.Substring(0, $q)
        $s = $s.Substring($q + $mlen)
        if ($inner -eq '') { $out += ($marker + $marker); continue }
        if ($script:UseColor) { $out += "$e[${on}m$inner$e[${off}m" } else { $out += $inner }
    }
    $out + $s
}

# Renders inline Markdown emphasis: **bold**, *italic*, _italic_ (bold first so
# ** is consumed before single *). Applied only to text outside `backticks`.
function Expand-Inline([string] $s) {
    if (-not $s) { return $s }
    $s = Convert-Emphasis $s '**' 1 22
    $s = Convert-Emphasis $s '*'  3 23
    $s = Convert-Emphasis $s '_'  3 23
    $s
}

# Splits text on `backticks`; even-index segments use $baseColor (with inline
# emphasis expanded), odd-index (inside backticks) use $codeColor verbatim.
# Backticks themselves are stripped from the output.
function Format-Field([string] $text, [string] $baseColor, [string] $codeColor) {
    $parts = $text -split '`'
    $sb = New-Object System.Text.StringBuilder
    for ($i = 0; $i -lt $parts.Count; $i++) {
        if ($parts[$i] -eq '') { continue }
        if ($i % 2 -eq 0) { [void]$sb.Append((Format-Colored $baseColor (Expand-Inline $parts[$i]))) }
        else              { [void]$sb.Append((Format-Colored $codeColor $parts[$i])) }
    }
    $sb.ToString()
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
        try { Get-File "$BASE_URL/windows.txt" $df }
        catch { Die "no shortcuts file at $df and default download failed. Run: shortcuts reset" }
    }
}

# --- rendering -------------------------------------------------------------
# Parses the data file into sections and prints aligned/colored output.
# Markdown-lite supported: #/##/### headings, --- horizontal rule, **bold**,
# *italic* / _italic_. // comment lines and `key`<TAB>desc rows are unchanged.
function Show-Shortcuts([string] $Filter) {
    $lines = Get-Content -LiteralPath (Get-DataFile)
    Read-ColorDirectives $lines
    $cHdr = ConvertTo-Ansi $script:SpecHeader
    $cKey = ConvertTo-Ansi $script:SpecKey
    $cDesc = ConvertTo-Ansi $script:SpecDesc
    $cCode = ConvertTo-Ansi $script:SpecCode
    $cRule = if ($script:UseColor) { "$e[2m" } else { '' }
    $sections = New-Object System.Collections.ArrayList
    $cur = $null
    $maxk = 0

    function New-Section($name, $level) {
        $s = [ordered]@{ Name = $name; Level = $level; Rows = (New-Object System.Collections.ArrayList) }
        [void]$sections.Add($s)
        $s
    }

    foreach ($line in $lines) {
        if ($line -match '^\s*$') { continue }
        if ($line -match '^\s*//') { continue }                    # comment / color directive
        if ($line -match '^\s*(-{3,}|\*{3,}|_{3,})\s*$') {         # horizontal rule
            if ($null -eq $cur) { $cur = New-Section 'General' 1 }
            [void]$cur.Rows.Add(@{ Type = 'rule' })
            continue
        }
        if ($line -match '^\s*#') {                                # heading (any level)
            $m = [regex]::Match($line, '^\s*(#+)\s*(.*?)\s*#*\s*$')
            $cur = New-Section ($m.Groups[2].Value.Trim()) ($m.Groups[1].Value.Length)
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
        if ($null -eq $cur) { $cur = New-Section 'General' 1 }
        [void]$cur.Rows.Add(@{ Type = 'row'; Key = $k; Desc = $d })
        $kVisLen = ($k -replace '`', '').Length
        if ($kVisLen -gt $maxk) { $maxk = $kVisLen }
    }

    $pad = $maxk + 2
    $first = $true
    foreach ($s in $sections) {
        $rows = $s.Rows
        if ($Filter) {
            $f = $Filter.ToLower()
            $rows = @($s.Rows | Where-Object { $_.Type -eq 'row' -and ($_.Key.ToLower().Contains($f) -or $_.Desc.ToLower().Contains($f)) })
        }
        if ($rows.Count -eq 0) { continue }
        if (-not $first) { Write-Host '' }
        $first = $false
        $deco = if ($s.Level -ge 2) { '---' } else { '===' }
        Write-Host (Format-Colored $cHdr "$deco $(Expand-Inline $s.Name) $deco")
        foreach ($r in $rows) {
            if ($r.Type -eq 'rule') {
                Write-Host (Format-Colored $cRule ('-' * 32))
            } elseif ($r.Desc -eq '') {
                Write-Host (Format-Field $r.Key $cKey $cCode)
            } else {
                $kVisLen = ($r.Key -replace '`', '').Length
                $padSpaces = ' ' * [Math]::Max(0, $pad - $kVisLen)
                Write-Host ((Format-Field $r.Key $cKey $cCode) + $padSpaces + (Format-Field $r.Desc $cDesc $cCode))
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

function Invoke-Reset([string[]] $Argv) {
    $df = Get-DataFile
    $yes = ($Argv -contains '-y') -or ($Argv -contains '--yes')
    if ((Test-Path $df) -and (-not $yes)) {
        $ans = Read-Host "Overwrite $df with defaults? [y/N]"
        if ($ans -notmatch '^(y|yes)$') { Die 'cancelled' }
    }
    New-Item -ItemType Directory -Force -Path (Get-ConfigDir) | Out-Null
    Get-File "$BASE_URL/windows.txt" $df
    Write-Host "Restored defaults to $df"
}

function Invoke-Update {
    $dest = $PSCommandPath
    if (-not $dest) { $dest = Join-Path $env:LOCALAPPDATA 'Programs\shortcuts\shortcuts.ps1' }
    Get-File "$BASE_URL/shortcuts.ps1" $dest
    Write-Host "Updated shortcuts at $dest"
}

# neofetch-style banner for `shortcuts version`.
function Show-Version {
    $df = Get-DataFile
    $nsec = 0; $nrow = 0
    if (Test-Path $df) {
        $lines = Get-Content -LiteralPath $df
        Read-ColorDirectives $lines
        foreach ($ln in $lines) {
            if ($ln -match '^\s*$' -or $ln -match '^\s*//') { continue }
            if ($ln -match '^\s*(-{3,}|\*{3,}|_{3,})\s*$') { continue }   # horizontal rule
            if ($ln -match '^\s*#') { $nsec++ } else { $nrow++ }
        }
    }
    $cH = ConvertTo-Ansi $script:SpecHeader
    $rst = $script:Rst

    $edition = $PSVersionTable.PSEdition
    $envName = if ($edition -eq 'Core') { 'PowerShell' } else { 'Windows PowerShell' }
    $osName = if ($PSVersionTable.PSVersion.Major -ge 6) {
        if ($IsLinux) { 'Linux' } elseif ($IsMacOS) { 'macOS' } else { 'Windows' }
    } else { 'Windows' }
    $shellName = "$envName $($PSVersionTable.PSVersion)"
    $host_ = $env:COMPUTERNAME; if (-not $host_) { $host_ = 'localhost' }
    $editor = if ($env:EDITOR) { $env:EDITOR } else { 'notepad' }
    $palette = (Format-Colored (ConvertTo-Ansi $script:SpecHeader) 'header') + ' ' +
               (Format-Colored (ConvertTo-Ansi $script:SpecKey) 'key') + ' ' +
               (Format-Colored (ConvertTo-Ansi $script:SpecDesc) 'desc') + ' ' +
               (Format-Colored (ConvertTo-Ansi $script:SpecCode) 'code')

    $logo = @(
        '   ___________________________'
        '  |  _______________________  |'
        '  | |                       | |'
        '  | |   >_ shortcuts        | |'
        '  | |_______________________| |'
        '  |   ___   ___   ___   ___   |'
        '  |  |Ctl| |Alt| |Sft| |Tab|  |'
        '  |  |___| |___| |___| |___|  |'
        '  |___________________________|'
        '      |_______________________|'
    )
    $info = @(
        (Format-Colored $cH 'shortcuts') + '@' + (Format-Colored $cH $host_)
        '-----------------------------'
        "Version      $VERSION"
        "Environment  $envName"
        "OS           $osName"
        "Shell        $shellName"
        "Shortcuts    $nrow in $nsec sections"
        "Editor       $editor"
        "Data         $df"
        "Palette      $palette"
        "GitHub       https://github.com/$REPO"
        '             ^ star & contribute to support!'
    )
    $w = ($logo | Measure-Object -Property Length -Maximum).Maximum
    $max = [Math]::Max($logo.Count, $info.Count)
    Write-Host ''
    for ($i = 0; $i -lt $max; $i++) {
        $l = if ($i -lt $logo.Count) { $logo[$i] } else { '' }
        $r = if ($i -lt $info.Count) { $info[$i] } else { '' }
        $padded = $l.PadRight($w)
        if ($l) { Write-Host ((Format-Colored $cH $padded) + '   ' + $r) }
        else    { Write-Host ($padded + '   ' + $r) }
    }
    Write-Host ''
}

# Removes every trace of shortcuts: program dir, config dir, and the User PATH entry.
# Touches ONLY shortcuts' own files.
function Invoke-Uninstall([string[]] $Argv) {
    $progDir = Join-Path $env:LOCALAPPDATA 'Programs\shortcuts'
    $cfgDir  = Get-ConfigDir
    $yes = ($Argv -contains '-y') -or ($Argv -contains '--yes')

    Write-Host 'This will remove shortcuts completely:'
    Write-Host "  program:  $progDir"
    Write-Host "  config:   $cfgDir (including your customized shortcuts)"
    Write-Host '  PATH:     the shortcuts entry in your User PATH'
    if (-not $yes) {
        $ans = Read-Host 'Proceed? [y/N]'
        if ($ans -notmatch '^(y|yes)$') { Die 'cancelled' }
    }

    # 1) User PATH — drop only the shortcuts program dir
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if ($userPath) {
        $kept = @($userPath -split ';' | Where-Object { $_ -and $_ -ne $progDir })
        $new = ($kept -join ';')
        if ($new -ne $userPath) {
            [Environment]::SetEnvironmentVariable('Path', $new, 'User')
            Write-Host 'Removed shortcuts from your User PATH'
        }
    }

    # 2) config dir (namespaced to shortcuts)
    if ((Test-Path $cfgDir) -and ($cfgDir -match '[\\/]shortcuts$')) {
        Remove-Item -Recurse -Force $cfgDir
        Write-Host "Removed $cfgDir"
    }

    # 3) program dir — this holds the shortcuts.cmd/shortcuts.ps1 that is running
    #    right now. Deleting it inline would yank the file out from under the shell.
    #    Hand off to a detached cmd that waits for this process to exit, then removes it.
    if ((Test-Path $progDir) -and ($progDir -match '[\\/]shortcuts$')) {
        Start-Process cmd.exe -WindowStyle Hidden `
            -ArgumentList "/c ping 127.0.0.1 -n 3 >nul & rmdir /s /q `"$progDir`"" | Out-Null
        Write-Host "Removed $progDir"
    }

    Write-Host ''
    Write-Host 'shortcuts uninstalled. Open a new terminal to drop the PATH change.'
}

function Show-Help {
    @"
shortcuts v$VERSION — keyboard-shortcut cheat sheet

Usage: shortcuts [command]
  (none)           Print shortcuts
  search <term>    Filter by keyword
  edit             Edit in `$env:EDITOR (else notepad)
  path             Print data file path
  reset [-y]       Restore defaults
  update           Update the script
  version          Version + environment
  uninstall [-y]   Remove everything
  help             This help

Data: $(Get-DataFile)
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
    { $_ -in 'version','-v','--version' } { Show-Version }
    { $_ -in 'uninstall','remove' } { Invoke-Uninstall $Rest }
    { $_ -in 'help','-h','--help' } { Show-Help }
    default     { Write-Host "shortcuts: unknown command `"$Command`"`n"; Show-Help; exit 1 }
}
