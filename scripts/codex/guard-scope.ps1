<#
.SYNOPSIS
Checks repository changes against an explicit path allowlist.

.DESCRIPTION
Runs read-only Git queries from any directory inside a repository. Paths are
normalized to forward-slash repository-relative form. Exact entries allow one
file; entries ending in / allow descendants. This layered safeguard does not
replace review, sandboxing, or authorization controls.

.PARAMETER Mode
Worktree checks unstaged and untracked paths. Staged checks the index. All
checks both sets. The default is All.

.PARAMETER AllowedPath
One or more exact repository-relative files or directory prefixes ending in /.

.PARAMETER ExpectedBranch
Optional exact branch name. A mismatch fails.

.PARAMETER ExpectedHead
Optional exact 40-character commit hash. A mismatch fails.

.PARAMETER AllowDetachedHead
Allows detached HEAD only when explicitly supplied. Detached HEAD fails by
default.
#>
[CmdletBinding()]
param(
    [ValidateSet('Worktree', 'Staged', 'All')]
    [string]$Mode = 'All',

    [string[]]$AllowedPath = @(),

    [string]$ExpectedBranch,

    [string]$ExpectedHead,

    [switch]$AllowDetachedHead
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-GuardFailure {
    param([string[]]$Detail)

    Write-Output 'GUARD_SCOPE_FAIL'
    foreach ($line in $Detail) {
        Write-Output $line
    }
}

function Invoke-GitText {
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

function ConvertTo-RepositoryPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [switch]$PermitDirectory
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw 'empty-path'
    }

    foreach ($character in $Path.ToCharArray()) {
        if ([char]::IsControl($character)) {
            throw 'control-character-path'
        }
    }

    $directory = $Path.EndsWith('/') -or $Path.EndsWith('\')
    if ($directory -and -not $PermitDirectory) {
        throw 'unexpected-directory-path'
    }

    $value = $Path.Replace('\', '/')
    while ($value.StartsWith('./', [System.StringComparison]::Ordinal)) {
        $value = $value.Substring(2)
    }
    if ($directory) {
        $value = $value.TrimEnd('/')
    }

    if ([string]::IsNullOrWhiteSpace($value) -or
        $value.StartsWith('/', [System.StringComparison]::Ordinal) -or
        [System.IO.Path]::IsPathRooted($value) -or
        $value -match '^[A-Za-z]:') {
        throw 'absolute-or-empty-path'
    }

    $parts = $value.Split('/')
    $normalized = New-Object System.Collections.Generic.List[string]
    foreach ($part in $parts) {
        if ([string]::IsNullOrEmpty($part) -or $part -eq '.') {
            continue
        }
        if ($part -eq '..') {
            throw 'outside-repository-path'
        }
        $normalized.Add($part)
    }

    if ($normalized.Count -eq 0) {
        throw 'empty-normalized-path'
    }

    $result = [string]::Join('/', $normalized.ToArray())
    if ($directory) {
        return $result + '/'
    }
    return $result
}

function Add-GitPaths {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.HashSet[string]]$Destination,
        [Parameter(Mandatory = $true)][string]$Arguments,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $result = Invoke-GitText -Arguments $Arguments -WorkingDirectory $RepositoryRoot
    if ($result.ExitCode -ne 0) {
        throw 'git-path-query-failed'
    }

    $entries = [regex]::Split($result.Output, [string][char]0)
    foreach ($entry in $entries) {
        if ([string]::IsNullOrEmpty($entry)) {
            continue
        }
        $path = ConvertTo-RepositoryPath -Path $entry
        $null = $Destination.Add($path)
    }
}

try {
    if ($null -eq $AllowedPath -or $AllowedPath.Count -eq 0) {
        Write-GuardFailure -Detail @('category=allowlist-required')
        exit 1
    }

    $currentDirectory = (Get-Location).Path
    $rootResult = Invoke-GitText -Arguments 'rev-parse --show-toplevel' -WorkingDirectory $currentDirectory
    if ($rootResult.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($rootResult.Output)) {
        Write-GuardFailure -Detail @('category=not-git-repository')
        exit 1
    }
    $repositoryRoot = [System.IO.Path]::GetFullPath($rootResult.Output.Trim())

    $normalizedAllowlist = New-Object System.Collections.Generic.List[object]
    foreach ($entry in $AllowedPath) {
        $isDirectory = $entry.EndsWith('/') -or $entry.EndsWith('\')
        $normalizedEntry = ConvertTo-RepositoryPath -Path $entry -PermitDirectory
        $normalizedAllowlist.Add([pscustomobject]@{
            Path        = $normalizedEntry
            IsDirectory = $isDirectory
        })
    }

    $hasExpectedBranch = -not [string]::IsNullOrWhiteSpace($ExpectedBranch)
    $hasExpectedHead = -not [string]::IsNullOrWhiteSpace($ExpectedHead)

    if ($hasExpectedBranch) {
        if ($ExpectedBranch -notmatch '^[A-Za-z0-9._/-]+$') {
            Write-GuardFailure -Detail @('category=invalid-expected-branch')
            exit 1
        }
    }

    if ($hasExpectedHead -and $ExpectedHead -notmatch '^[0-9A-Fa-f]{40}$') {
        Write-GuardFailure -Detail @('category=invalid-expected-head')
        exit 1
    }

    $branchResult = Invoke-GitText -Arguments 'symbolic-ref --quiet --short HEAD' -WorkingDirectory $repositoryRoot
    $isDetached = $branchResult.ExitCode -ne 0
    if ($isDetached -and -not $AllowDetachedHead) {
        Write-GuardFailure -Detail @('category=detached-head expected=attached')
        exit 1
    }

    if ($hasExpectedBranch) {
        if ($isDetached) {
            Write-GuardFailure -Detail @('category=branch-mismatch expected_branch=' + $ExpectedBranch + ' actual_branch=detached')
            exit 1
        }
        $actualBranch = $branchResult.Output.Trim()
        if ($actualBranch -cne $ExpectedBranch) {
            Write-GuardFailure -Detail @('category=branch-mismatch expected_branch=' + $ExpectedBranch + ' actual_branch=' + $actualBranch)
            exit 1
        }
    }

    if ($hasExpectedHead) {
        $headResult = Invoke-GitText -Arguments 'rev-parse HEAD' -WorkingDirectory $repositoryRoot
        if ($headResult.ExitCode -ne 0) {
            throw 'git-head-query-failed'
        }
        $actualHead = $headResult.Output.Trim()
        if ($actualHead -cne $ExpectedHead.ToLowerInvariant()) {
            Write-GuardFailure -Detail @('category=head-mismatch expected_head=' + $ExpectedHead.ToLowerInvariant() + ' actual_head=' + $actualHead)
            exit 1
        }
    }

    $changedPaths = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
    if ($Mode -eq 'Worktree' -or $Mode -eq 'All') {
        Add-GitPaths -Destination $changedPaths -Arguments 'diff --name-only -z --no-renames --' -RepositoryRoot $repositoryRoot
        Add-GitPaths -Destination $changedPaths -Arguments 'ls-files --others --exclude-standard -z --' -RepositoryRoot $repositoryRoot
    }
    if ($Mode -eq 'Staged' -or $Mode -eq 'All') {
        Add-GitPaths -Destination $changedPaths -Arguments 'diff --cached --name-only -z --no-renames --' -RepositoryRoot $repositoryRoot
    }

    $violations = New-Object System.Collections.Generic.List[string]
    foreach ($path in $changedPaths) {
        $allowed = $false
        foreach ($entry in $normalizedAllowlist) {
            if ($entry.IsDirectory) {
                if ($path.StartsWith($entry.Path, [System.StringComparison]::Ordinal)) {
                    $allowed = $true
                    break
                }
            }
            elseif ($path -ceq $entry.Path) {
                $allowed = $true
                break
            }
        }
        if (-not $allowed) {
            $violations.Add($path)
        }
    }

    if ($violations.Count -gt 0) {
        $detail = New-Object System.Collections.Generic.List[string]
        foreach ($path in ($violations | Sort-Object)) {
            $detail.Add('path=' + $path + ' category=outside-allowlist')
        }
        Write-GuardFailure -Detail $detail.ToArray()
        exit 1
    }

    Write-Output 'GUARD_SCOPE_PASS'
    Write-Output ('mode=' + $Mode + ' changed=' + $changedPaths.Count)
    exit 0
}
catch {
    Write-GuardFailure -Detail @('category=execution-error')
    exit 2
}
