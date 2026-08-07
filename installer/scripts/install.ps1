#requires -Version 5
<#
  install.ps1 -- installs the latest (or a pinned) `kite` release on Windows.

    irm https://kite-lang.pages.dev/install.ps1 | iex
    $env:KITE_VERSION="0.2.0"; irm https://kite-lang.pages.dev/install.ps1 | iex
    irm https://kite-lang.pages.dev/install.ps1 -OutFile install.ps1; ./install.ps1 -Uninstall

  Env / param overrides:
    KITE_REPO / -Repo               GitHub "owner/repo"   (default: yo-le-zz/Kite)
    KITE_VERSION / -Version          release tag to install (default: latest)
    KITE_INSTALL_DIR / -InstallDir    where to put kite.exe   (default: %LOCALAPPDATA%\Kite\bin)
#>
param(
  [string]$Repo = $(if ($env:KITE_REPO) { $env:KITE_REPO } else { "yo-le-zz/Kite" }),
  [string]$Version = $(if ($env:KITE_VERSION) { $env:KITE_VERSION } else { "" }),
  [string]$InstallDir = $(if ($env:KITE_INSTALL_DIR) { $env:KITE_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA "Kite\bin" }),
  [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

function Write-Info($msg) { Write-Host $msg -ForegroundColor DarkGray }
function Write-Ok($msg)   { Write-Host "OK  $msg" -ForegroundColor Green }
function Write-Die($msg)  { Write-Host "ERR $msg" -ForegroundColor Red; exit 1 }

if ($Uninstall) {
  $exe = Join-Path $InstallDir "kite.exe"
  if (Test-Path $exe) { Remove-Item $exe -Force }
  Write-Ok "removed $exe"
  exit 0
}

# --- arch detection -> kite's build.sh short target name ---
$archRaw = [System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture
switch ($archRaw) {
  "X64"   { $ArchLabel = "x64" }
  "Arm64" { $ArchLabel = "arm64" }
  "X86"   { $ArchLabel = "x86" }
  default { Write-Die "unsupported architecture: $archRaw" }
}
$Short = "windows-$ArchLabel"

# --- resolve version + asset URL ---
if ([string]::IsNullOrEmpty($Version)) {
  Write-Info "resolving latest release of $Repo..."
  try {
    $release = Invoke-RestMethod -UseBasicParsing `
      -Headers @{ "Accept" = "application/vnd.github+json"; "User-Agent" = "kite-install-ps1" } `
      -Uri "https://api.github.com/repos/$Repo/releases/latest"
  } catch {
    Write-Die "could not resolve the latest release from GitHub: $_"
  }
  $Version = $release.tag_name.TrimStart("v")
}

$FileName = "kite-$Version-$Short.zip"
$DownloadUrl = "https://github.com/$Repo/releases/download/v$Version/$FileName"

Write-Info "installing kite $Version ($Short) into $InstallDir"

$TmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("kite-install-" + [System.Guid]::NewGuid())
New-Item -ItemType Directory -Path $TmpDir | Out-Null
try {
  $ZipPath = Join-Path $TmpDir $FileName
  try {
    Invoke-WebRequest -UseBasicParsing -Uri $DownloadUrl -OutFile $ZipPath
  } catch {
    Write-Die "download failed: $DownloadUrl (does this release cover $Short?)"
  }

  $ExtractDir = Join-Path $TmpDir "extracted"
  Expand-Archive -Path $ZipPath -DestinationPath $ExtractDir -Force

  $BinPath = Get-ChildItem -Path $ExtractDir -Recurse -Filter "kite.exe" | Select-Object -First 1
  if (-not $BinPath) { Write-Die "no 'kite.exe' found inside $FileName" }

  New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
  Copy-Item $BinPath.FullName (Join-Path $InstallDir "kite.exe") -Force

  Write-Ok "kite $Version installed to $InstallDir\kite.exe"

  # Add to the *user* PATH (no admin rights needed) if not already present.
  $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
  if ($userPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$InstallDir", "User")
    Write-Info "added $InstallDir to your user PATH -- open a new terminal for it to take effect"
  }

  Write-Info "run 'kite --version' in a new terminal to confirm the install."
} finally {
  Remove-Item -Recurse -Force $TmpDir -ErrorAction SilentlyContinue
}
