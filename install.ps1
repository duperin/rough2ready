param(
  [ValidateSet("auto", "codex", "claude-code", "claude", "opencode", "open-code")]
  [string]$Agent = "auto",
  [string]$Target,
  [string]$Repo = "https://github.com/duperin/rough2ready",
  [switch]$Help
)

$ErrorActionPreference = "Stop"
$SkillName = "rough2ready"

function Show-Usage {
  @"
Rough2Ready installer for Windows PowerShell

Usage:
  irm https://raw.githubusercontent.com/duperin/rough2ready/main/install.ps1 | iex
  iex "& { `$(irm https://raw.githubusercontent.com/duperin/rough2ready/main/install.ps1) } -Agent opencode"
  .\install.ps1
  .\install.ps1 -Agent codex
  .\install.ps1 -Target C:\path\to\skills

Options:
  no arguments         Install to detected agents only
  -Agent codex        Install to %USERPROFILE%\.codex\skills\rough2ready
  -Agent claude-code  Install to %USERPROFILE%\.claude\skills\rough2ready
  -Agent opencode     Install as %USERPROFILE%\.config\opencode\commands\rough2ready.md
  -Target PATH        Install to PATH\rough2ready
  -Repo URL           Repository URL used when downloading the ZIP archive
  -Help               Show help
"@
}

function Get-HomePath {
  if ($HOME) {
    return $HOME
  }
  if ($env:USERPROFILE) {
    return $env:USERPROFILE
  }
  throw "Could not determine the user home directory."
}

function New-BackupName([string]$Path) {
  $stamp = Get-Date -Format "yyyyMMddHHmmss"
  return "$Path.bak.$stamp.$PID"
}

function Get-SourceDir {
  param([string]$RepoUrl)

  if ($PSScriptRoot -and
      (Test-Path -LiteralPath (Join-Path $PSScriptRoot "SKILL.md")) -and
      (Test-Path -LiteralPath (Join-Path $PSScriptRoot "agents"))) {
    return $PSScriptRoot
  }

  $normalizedRepoUrl = $RepoUrl.TrimEnd("/")
  if ($normalizedRepoUrl.EndsWith(".git")) {
    $normalizedRepoUrl = $normalizedRepoUrl.Substring(0, $normalizedRepoUrl.Length - 4)
  }
  $zipUrl = $normalizedRepoUrl + "/archive/refs/heads/main.zip"
  $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("rough2ready-" + [System.Guid]::NewGuid().ToString("N"))
  $zipPath = Join-Path $tempRoot "rough2ready.zip"
  New-Item -ItemType Directory -Path $tempRoot | Out-Null

  try {
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
    Expand-Archive -Path $zipPath -DestinationPath $tempRoot -Force
    $candidate = Join-Path $tempRoot "rough2ready-main"
    if (-not (Test-Path -LiteralPath (Join-Path $candidate "SKILL.md"))) {
      throw "SKILL.md not found in downloaded archive."
    }
    $script:Rough2ReadyCleanupPaths += $tempRoot
    return $candidate
  }
  catch {
    if (Test-Path -LiteralPath $tempRoot) {
      Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
    throw
  }
}

function Install-SkillFolder {
  param(
    [string]$SourceDir,
    [string]$TargetRoot
  )

  $targetDir = Join-Path $TargetRoot $SkillName
  $stagingRoot = Join-Path $TargetRoot (".$SkillName.install." + [System.Guid]::NewGuid().ToString("N"))
  $stagingDir = Join-Path $stagingRoot $SkillName

  New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null
  Copy-Item -LiteralPath (Join-Path $SourceDir "SKILL.md") -Destination (Join-Path $stagingDir "SKILL.md") -Force
  Copy-Item -LiteralPath (Join-Path $SourceDir "agents") -Destination (Join-Path $stagingDir "agents") -Recurse -Force

  if (Test-Path -LiteralPath $targetDir) {
    $backupDir = New-BackupName $targetDir
    Move-Item -LiteralPath $targetDir -Destination $backupDir
    Write-Host "Backed up existing install to $backupDir"
  }

  Move-Item -LiteralPath $stagingDir -Destination $targetDir
  Remove-Item -LiteralPath $stagingRoot -Force
  Write-Host "Installed $SkillName to $targetDir"
  Write-Host "Try: `$$SkillName compare product A with product B"
}

function Install-OpenCodeCommand {
  param(
    [string]$SourceDir,
    [string]$CommandRoot
  )

  New-Item -ItemType Directory -Path $CommandRoot -Force | Out-Null
  $commandFile = Join-Path $CommandRoot "$SkillName.md"
  $skillContent = Get-Content -LiteralPath (Join-Path $SourceDir "SKILL.md") -Raw
  $commandContent = @"
---
description: Improve a rough prompt and answer it with Rough2Ready
---

Use the Rough2Ready instructions below to improve and execute this request.

User request:
`$ARGUMENTS

<rough2ready>
$skillContent
</rough2ready>
"@

  $stagingFile = Join-Path $CommandRoot (".$SkillName.command." + [System.Guid]::NewGuid().ToString("N") + ".md")
  Set-Content -LiteralPath $stagingFile -Value $commandContent -Encoding UTF8

  if (Test-Path -LiteralPath $commandFile) {
    $backupFile = New-BackupName $commandFile
    Move-Item -LiteralPath $commandFile -Destination $backupFile
    Write-Host "Backed up existing command to $backupFile"
  }

  Move-Item -LiteralPath $stagingFile -Destination $commandFile
  Write-Host "Installed OpenCode command to $commandFile"
  Write-Host "Try: /$SkillName compare product A with product B"
}

function Test-AgentAvailable {
  param([string]$AgentName)

  switch ($AgentName) {
    "codex" {
      return [bool]((Get-Command codex -ErrorAction SilentlyContinue) -or
        (Test-Path -LiteralPath (Join-Path (Get-HomePath) ".codex")))
    }
    "claude-code" {
      return [bool]((Get-Command claude -ErrorAction SilentlyContinue) -or
        (Get-Command claude-code -ErrorAction SilentlyContinue) -or
        (Test-Path -LiteralPath (Join-Path (Get-HomePath) ".claude")))
    }
    "opencode" {
      return [bool]((Get-Command opencode -ErrorAction SilentlyContinue) -or
        (Test-Path -LiteralPath (Join-Path (Get-HomePath) ".config\opencode")))
    }
    default {
      return $false
    }
  }
}

function Install-Agent {
  param(
    [string]$AgentName,
    [string]$SourceDir,
    [string]$HomePath
  )

  switch ($AgentName) {
    "codex" {
      Install-SkillFolder -SourceDir $SourceDir -TargetRoot (Join-Path $HomePath ".codex\skills")
    }
    { $_ -in @("claude-code", "claude") } {
      Install-SkillFolder -SourceDir $SourceDir -TargetRoot (Join-Path $HomePath ".claude\skills")
    }
    { $_ -in @("opencode", "open-code") } {
      Install-OpenCodeCommand -SourceDir $SourceDir -CommandRoot (Join-Path $HomePath ".config\opencode\commands")
    }
    default {
      throw "Unsupported agent '$AgentName'. Use -Target for custom agents."
    }
  }
}

if ($Help) {
  Show-Usage
  exit 0
}

$script:Rough2ReadyCleanupPaths = @()

try {
  $homePath = Get-HomePath
  $sourceDir = Get-SourceDir -RepoUrl $Repo

  if (-not (Test-Path -LiteralPath (Join-Path $sourceDir "SKILL.md"))) {
    throw "SKILL.md not found in source."
  }
  if (-not (Test-Path -LiteralPath (Join-Path $sourceDir "agents"))) {
    throw "agents directory not found in source."
  }

  if ($Target) {
    New-Item -ItemType Directory -Path $Target -Force | Out-Null
    Install-SkillFolder -SourceDir $sourceDir -TargetRoot $Target
    return
  }

  if ($Agent -ne "auto") {
    Install-Agent -AgentName $Agent -SourceDir $sourceDir -HomePath $homePath
    return
  }

  $installedAny = $false
  foreach ($detectedAgent in @("codex", "claude-code", "opencode")) {
    if (Test-AgentAvailable -AgentName $detectedAgent) {
      Install-Agent -AgentName $detectedAgent -SourceDir $sourceDir -HomePath $homePath
      $installedAny = $true
    }
  }

  if (-not $installedAny) {
    Write-Host "No supported agent install was detected. Nothing was installed."
    Write-Host "Use -Agent codex, -Agent claude-code, -Agent opencode, or -Target PATH to install explicitly."
  }
}
finally {
  foreach ($path in $script:Rough2ReadyCleanupPaths) {
    if (Test-Path -LiteralPath $path) {
      Remove-Item -LiteralPath $path -Recurse -Force
    }
  }
}
