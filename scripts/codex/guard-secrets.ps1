<#
.SYNOPSIS
Scans newly added repository content for high-confidence credential indicators.

.DESCRIPTION
Checks added lines in staged and unstaged textual diffs plus eligible untracked
text files. It never reads environment variables or prints matched content.
Binary files are skipped. Files larger than 1 MiB produce a scanner error so a
clean pass is never reported for unscanned oversized content. This is a layered
safeguard, not a complete secret-detection or security boundary.

.PARAMETER Mode
Worktree checks unstaged additions and untracked files. Staged checks indexed
additions. All checks both sets. The default is All.
#>
[CmdletBinding()]
param(
    [ValidateSet('Worktree', 'Staged', 'All')]
    [string]$Mode = 'All'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:MaximumFileBytes = 1MB
$script:Findings = New-Object System.Collections.Generic.List[object]
$script:ScannerErrors = New-Object System.Collections.Generic.List[object]
$script:FindingKeys = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
$script:ErrorKeys = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
$script:SkippedBinaryCount = 0

$script:Detectors = @(
    [pscustomobject]@{ Name = 'PRIVATE_KEY_HEADER'; Pattern = '-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----' },
    [pscustomobject]@{ Name = 'STRIPE_OR_CLERK_SECRET_KEY'; Pattern = '\b(?:sk|rk)_(?:live|test)_[A-Za-z0-9]{20,}\b' },
    [pscustomobject]@{ Name = 'STRIPE_WEBHOOK_SECRET'; Pattern = '\bwhsec_[A-Za-z0-9]{20,}\b' },
    [pscustomobject]@{ Name = 'GITHUB_TOKEN'; Pattern = '\bgh[pousr]_[A-Za-z0-9]{30,}\b' },
    [pscustomobject]@{ Name = 'GITHUB_FINE_GRAINED_TOKEN'; Pattern = '\bgithub_pat_[A-Za-z0-9_]{40,}\b' },
    [pscustomobject]@{ Name = 'OPENAI_SECRET_KEY'; Pattern = '\bsk-(?:proj-)?[A-Za-z0-9_-]{20,}\b' },
    [pscustomobject]@{ Name = 'AWS_ACCESS_KEY_ID'; Pattern = '\b(?:AKIA|ASIA)[0-9A-Z]{16}\b' },
    [pscustomobject]@{ Name = 'SLACK_TOKEN'; Pattern = '\bxox[baprs]-[A-Za-z0-9-]{20,}\b' },
    [pscustomobject]@{ Name = 'BEARER_JWT'; Pattern = '(?i)\bBearer\s+eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\b' }
)

function Invoke-GitRaw {
    param(
        [Parameter(Mandatory = $true)][string]$Arguments,
        [Parameter(Mandatory = $true)][string]$WorkingDirectory
    )

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = 'git'
    $startInfo.Arguments = $Arguments
    $startInfo.WorkingDirectory = $WorkingDirectory
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.StandardOutputEncoding = New-Object System.Text.UTF8Encoding($false)
    $startInfo.StandardErrorEncoding = New-Object System.Text.UTF8Encoding($false)

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    if (-not $process.Start()) {
        throw 'git-start-failed'
    }
    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    $process.WaitForExit()
    $stdout = $stdoutTask.GetAwaiter().GetResult()
    $null = $stderrTask.GetAwaiter().GetResult()
    $exitCode = $process.ExitCode
    $process.Dispose()

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output   = $stdout
    }
}

function ConvertTo-SafeRepositoryPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw 'empty-path'
    }
    foreach ($character in $Path.ToCharArray()) {
        if ([char]::IsControl($character)) {
            throw 'control-character-path'
        }
    }

    $value = $Path.Replace('\', '/')
    if ($value.StartsWith('/', [System.StringComparison]::Ordinal) -or
        [System.IO.Path]::IsPathRooted($value) -or
        $value -match '^[A-Za-z]:' -or
        @($value.Split('/') | Where-Object { $_ -eq '..' }).Count -gt 0) {
        throw 'unsafe-repository-path'
    }
    return $value
}

function Get-GitPathSet {
    param(
        [Parameter(Mandatory = $true)][string[]]$Queries,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $paths = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
    foreach ($query in $Queries) {
        $result = Invoke-GitRaw -Arguments $query -WorkingDirectory $RepositoryRoot
        if ($result.ExitCode -ne 0) {
            throw 'git-path-query-failed'
        }
        foreach ($entry in [regex]::Split($result.Output, [string][char]0)) {
            if ([string]::IsNullOrEmpty($entry)) {
                continue
            }
            $path = ConvertTo-SafeRepositoryPath -Path $entry
            $null = $paths.Add($path)
        }
    }
    return $paths
}

function Add-Finding {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [int]$Line,
        [Parameter(Mandatory = $true)][string]$Detector,
        [string]$Classification = 'content'
    )

    $key = $Path + [char]0 + $Line + [char]0 + $Detector + [char]0 + $Classification
    if ($script:FindingKeys.Add($key)) {
        $script:Findings.Add([pscustomobject]@{
            Path           = $Path
            Line           = $Line
            Detector       = $Detector
            Classification = $Classification
        })
    }
}

function Add-ScannerError {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Detector
    )

    $key = $Path + [char]0 + $Detector
    if ($script:ErrorKeys.Add($key)) {
        $script:ScannerErrors.Add([pscustomobject]@{
            Path     = $Path
            Detector = $Detector
        })
    }
}

function Get-SensitivePathDetector {
    param([Parameter(Mandatory = $true)][string]$Path)

    $leaf = [System.IO.Path]::GetFileName($Path)
    $lowerLeaf = $leaf.ToLowerInvariant()

    if ($lowerLeaf -eq '.env.example' -or $lowerLeaf -eq '.env.sample') {
        return $null
    }
    if ($lowerLeaf -eq '.env' -or $lowerLeaf.StartsWith('.env.')) {
        return 'SENSITIVE_ENV_FILE'
    }
    if ($lowerLeaf -match '\.(pem|key|p12|pfx|jks|keystore)$') {
        return 'SENSITIVE_KEYSTORE_FILE'
    }
    if ($lowerLeaf -eq 'google-services.json') {
        return 'GOOGLE_SERVICES_FILE'
    }
    if ($lowerLeaf -eq 'googleservice-info.plist') {
        return 'GOOGLE_SERVICE_INFO_FILE'
    }
    if ($lowerLeaf -match '\.(mobileprovision|provisionprofile)$') {
        return 'MOBILE_PROVISIONING_FILE'
    }
    if ($lowerLeaf -match 'service[-_]?account.*\.json$') {
        return 'SERVICE_ACCOUNT_FILE'
    }
    return $null
}

function Test-CredentialLikeValue {
    param([Parameter(Mandatory = $true)][string]$Value)

    if ($Value.Length -lt 16) {
        return $false
    }
    if ($Value -match '(?i)(placeholder|example|sample|changeme|replace|your[_-]|dummy|fake|test[_-]?only|not[_-]?a[_-]?secret)' -or
        $Value.StartsWith('${') -or $Value.StartsWith('<')) {
        return $false
    }

    $classes = 0
    if ($Value -cmatch '[a-z]') { $classes++ }
    if ($Value -cmatch '[A-Z]') { $classes++ }
    if ($Value -match '[0-9]') { $classes++ }
    if ($Value -match '[_./+=:@-]') { $classes++ }
    return $classes -ge 3
}

function Test-AddedLine {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][int]$LineNumber,
        [AllowEmptyString()][string]$Text
    )

    foreach ($detector in $script:Detectors) {
        if ($Text -match $detector.Pattern) {
            Add-Finding -Path $Path -Line $LineNumber -Detector $detector.Name
        }
    }

    $assignment = [regex]::Match(
        $Text,
        '(?i)(?:^|[\s,{])["'']?(?:password|passwd|pwd|token|api[_-]?key|secret|client[_-]?secret)["'']?\s*[:=]\s*["'']?([A-Za-z0-9_./+=:@-]{16,})'
    )
    if ($assignment.Success -and (Test-CredentialLikeValue -Value $assignment.Groups[1].Value)) {
        Add-Finding -Path $Path -Line $LineNumber -Detector 'GENERIC_CREDENTIAL_ASSIGNMENT'
    }
}

function Get-WorktreeFile {
    param(
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $nativePath = $Path.Replace('/', [System.IO.Path]::DirectorySeparatorChar)
    $fullPath = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $nativePath))
    $rootPrefix = $RepositoryRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    if (-not $fullPath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw 'path-outside-repository'
    }
    return $fullPath
}

function Test-WorktreeFileSize {
    param(
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $fullPath = Get-WorktreeFile -RepositoryRoot $RepositoryRoot -Path $Path
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        return $false
    }
    $item = Get-Item -LiteralPath $fullPath -Force
    if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        Add-ScannerError -Path $Path -Detector 'REPARSE_POINT_UNSCANNED'
        return $false
    }
    if ($item.Length -gt $script:MaximumFileBytes) {
        Add-ScannerError -Path $Path -Detector 'OVERSIZED_FILE_SKIPPED'
        return $false
    }
    return $true
}

function Test-StagedFileSize {
    param([Parameter(Mandatory = $true)][string]$Path)

    $sizeOutput = @(& git cat-file -s (':' + $Path) 2>$null)
    if ($LASTEXITCODE -ne 0 -or $sizeOutput.Count -ne 1) {
        Add-ScannerError -Path $Path -Detector 'STAGED_FILE_UNREADABLE'
        return $false
    }
    [long]$size = 0
    if (-not [long]::TryParse([string]$sizeOutput[0], [ref]$size)) {
        Add-ScannerError -Path $Path -Detector 'STAGED_SIZE_UNKNOWN'
        return $false
    }
    if ($size -gt $script:MaximumFileBytes) {
        Add-ScannerError -Path $Path -Detector 'OVERSIZED_FILE_SKIPPED'
        return $false
    }
    return $true
}

function Scan-Diff {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [switch]$Staged
    )

    $arguments = @('diff')
    if ($Staged) {
        $arguments += '--cached'
    }
    $arguments += @('--no-ext-diff', '--no-textconv', '--no-color', '--unified=0', '--no-renames', '--', $Path)
    $previousErrorAction = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $diffLines = @(& git @arguments 2>$null)
        $diffExitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorAction
    }
    if ($diffExitCode -ne 0) {
        throw 'git-diff-failed'
    }

    $inHunk = $false
    $newLineNumber = 0
    foreach ($lineValue in $diffLines) {
        $line = [string]$lineValue
        $hunk = [regex]::Match($line, '^@@ -[0-9]+(?:,[0-9]+)? \+([0-9]+)(?:,[0-9]+)? @@')
        if ($hunk.Success) {
            $inHunk = $true
            $newLineNumber = [int]$hunk.Groups[1].Value
            continue
        }
        if (-not $inHunk) {
            continue
        }
        if ($line.StartsWith('+', [System.StringComparison]::Ordinal)) {
            Test-AddedLine -Path $Path -LineNumber $newLineNumber -Text $line.Substring(1)
            $newLineNumber++
        }
        elseif ($line.StartsWith('-', [System.StringComparison]::Ordinal)) {
            continue
        }
        elseif ($line.StartsWith('\', [System.StringComparison]::Ordinal)) {
            continue
        }
        else {
            $newLineNumber++
        }
    }
}

function Scan-UntrackedFile {
    param(
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Path
    )

    if (-not (Test-WorktreeFileSize -RepositoryRoot $RepositoryRoot -Path $Path)) {
        return
    }
    $fullPath = Get-WorktreeFile -RepositoryRoot $RepositoryRoot -Path $Path
    $bytes = [System.IO.File]::ReadAllBytes($fullPath)
    if ($bytes -contains 0) {
        $script:SkippedBinaryCount++
        return
    }

    try {
        $encoding = New-Object System.Text.UTF8Encoding($false, $true)
        $text = $encoding.GetString($bytes)
    }
    catch {
        $script:SkippedBinaryCount++
        return
    }

    $lines = [regex]::Split($text, "\r\n|\n|\r")
    for ($index = 0; $index -lt $lines.Count; $index++) {
        Test-AddedLine -Path $Path -LineNumber ($index + 1) -Text $lines[$index]
    }
}

function Write-FindingOutput {
    param([Parameter(Mandatory = $true)]$Finding)

    $linePart = ''
    if ($Finding.Line -gt 0) {
        $linePart = ' line=' + $Finding.Line
    }
    Write-Output ('path=' + $Finding.Path + $linePart + ' detector=' + $Finding.Detector + ' classification=' + $Finding.Classification)
}

try {
    $currentDirectory = (Get-Location).Path
    $rootResult = Invoke-GitRaw -Arguments 'rev-parse --show-toplevel' -WorkingDirectory $currentDirectory
    if ($rootResult.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($rootResult.Output)) {
        Write-Output 'GUARD_SECRETS_ERROR'
        Write-Output 'detector=NOT_GIT_REPOSITORY'
        exit 2
    }
    $repositoryRoot = [System.IO.Path]::GetFullPath($rootResult.Output.Trim())

    Push-Location -LiteralPath $repositoryRoot
    try {
        $worktreePaths = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
        $stagedPaths = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
        $untrackedPaths = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)

        if ($Mode -eq 'Worktree' -or $Mode -eq 'All') {
            $worktreePaths = Get-GitPathSet -Queries @('diff --name-only -z --no-renames --diff-filter=ACMRTUXB --') -RepositoryRoot $repositoryRoot
            $untrackedPaths = Get-GitPathSet -Queries @('ls-files --others --exclude-standard -z --') -RepositoryRoot $repositoryRoot
        }
        if ($Mode -eq 'Staged' -or $Mode -eq 'All') {
            $stagedPaths = Get-GitPathSet -Queries @('diff --cached --name-only -z --no-renames --diff-filter=ACMRTUXB --') -RepositoryRoot $repositoryRoot
        }

        foreach ($path in $worktreePaths) {
            $pathDetector = Get-SensitivePathDetector -Path $path
            if ($null -ne $pathDetector) {
                Add-Finding -Path $path -Line 0 -Detector $pathDetector -Classification 'sensitive-path'
            }
            if (Test-WorktreeFileSize -RepositoryRoot $repositoryRoot -Path $path) {
                Scan-Diff -Path $path
            }
        }

        foreach ($path in $stagedPaths) {
            $pathDetector = Get-SensitivePathDetector -Path $path
            if ($null -ne $pathDetector) {
                Add-Finding -Path $path -Line 0 -Detector $pathDetector -Classification 'sensitive-path'
            }
            if (Test-StagedFileSize -Path $path) {
                Scan-Diff -Path $path -Staged
            }
        }

        foreach ($path in $untrackedPaths) {
            $pathDetector = Get-SensitivePathDetector -Path $path
            if ($null -ne $pathDetector) {
                Add-Finding -Path $path -Line 0 -Detector $pathDetector -Classification 'sensitive-path'
            }
            Scan-UntrackedFile -RepositoryRoot $repositoryRoot -Path $path
        }
    }
    finally {
        Pop-Location
    }

    if ($script:ScannerErrors.Count -gt 0) {
        Write-Output 'GUARD_SECRETS_ERROR'
        foreach ($errorItem in ($script:ScannerErrors | Sort-Object Path, Detector)) {
            Write-Output ('path=' + $errorItem.Path + ' detector=' + $errorItem.Detector)
        }
        exit 2
    }

    if ($script:Findings.Count -gt 0) {
        Write-Output 'GUARD_SECRETS_FAIL'
        foreach ($finding in ($script:Findings | Sort-Object Path, Line, Detector)) {
            Write-FindingOutput -Finding $finding
        }
        exit 1
    }

    Write-Output 'GUARD_SECRETS_PASS'
    Write-Output ('mode=' + $Mode + ' findings=0 skipped_binary=' + $script:SkippedBinaryCount)
    exit 0
}
catch {
    Write-Output 'GUARD_SECRETS_ERROR'
    Write-Output 'detector=SCANNER_EXECUTION_ERROR'
    exit 2
}
