# Installs kite.exe for the current user and adds it to PATH.
$dest = Join-Path $env:LOCALAPPDATA "Kite\bin"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Copy-Item -Force "$PSScriptRoot\kite.exe" $dest
$path = [Environment]::GetEnvironmentVariable("Path", "User")
if ($path -notlike "*$dest*") { [Environment]::SetEnvironmentVariable("Path", "$path;$dest", "User") }
Write-Host "Kite installed to $dest. Install clang too:  winget install LLVM.LLVM"
