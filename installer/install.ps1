[CmdletBinding()]
param(
 [ValidatePattern('^[A-Za-z]$')][string]$DriveLetter='D',
 [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9_-]*(\\[A-Za-z0-9][A-Za-z0-9_-]*)*[string]$Folder='dsh-superagent',
 [string]$Distribution='Ubuntu-24.04',
 [switch]$VerifyOnly
)
$ErrorActionPreference='Stop'
$DriveLetter=$DriveLetter.ToUpperInvariant()
$root=Join-Path ($DriveLetter+':\') $Folder
$ubuntu=Join-Path $root 'Ubuntu'
function StopSafe($msg){ Write-Warning $msg; exit 2 }
function Approve($msg){ $a=Read-Host ($msg+' Type YES'); if($a -cne 'YES'){StopSafe 'Not approved.'} }
$v=Get-Volume -DriveLetter $DriveLetter -ErrorAction Stop
$d=Get-Partition -DriveLetter $DriveLetter | Get-Disk
Write-Host ('Disk: '+$d.FriendlyName+' serial: '+$d.SerialNumber)
Write-Host ('Target: '+$ubuntu)
if($DriveLetter -eq 'C'){StopSafe 'Refusing installation to Windows system drive.'}
if($v.FileSystem -ne 'NTFS'){StopSafe 'Only NTFS volumes supported.'}
if($v.SizeRemaining -lt 20GB){StopSafe 'Need at least 20 GiB available.'}
if(-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)){StopSafe 'WSL missing. Install separately as Administrator and rerun.'}
& wsl.exe --version | Out-Host
if($LASTEXITCODE -ne 0){StopSafe 'WSL not initialized: run wsl --install --no-distribution as admin, handle reboot manually, then rerun.'}
$distros=((& wsl.exe --list --quiet | Out-String) -replace [char]0,'')
$names=@($distros -split '[\r\n]+' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$exists=($names -contains $Distribution)
if($exists){
  $regRoot='HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss'
  $entries=@(Get-ChildItem $regRoot -ErrorAction SilentlyContinue | ForEach-Object { Get-ItemProperty $_.PSPath } | Where-Object { $_.DistributionName -eq $Distribution })
  if($entries.Count -ne 1){StopSafe 'Cannot verify exact WSL distribution registry location; refusing to modify existing distro.'}
  $registered=([string]$entries[0].BasePath -replace '^\\\\\?\\','').TrimEnd('\')
  $expected=[IO.Path]::GetFullPath($ubuntu).TrimEnd('\')
  if(-not [string]::Equals($registered,$expected,[StringComparison]::OrdinalIgnoreCase)){
    StopSafe ('Registered distro location '+$registered+' differs from requested '+$expected)
  }
}
if($exists){
 if(-not (Test-Path (Join-Path $ubuntu 'ext4.vhdx'))){StopSafe 'Distribution exists elsewhere. Refusing to overwrite.'}
 Write-Host 'Existing Ubuntu VHD verified at selected path.'
}else{
 if(Test-Path $ubuntu){if(@(Get-ChildItem $ubuntu -Force).Count -gt 0){StopSafe 'Target directory is not empty.'}}
 if($VerifyOnly){Write-Host 'Preflight OK; Ubuntu not installed.';exit 0}
 Approve 'Install Ubuntu 24.04 at this SSD path?'
 New-Item -ItemType Directory -Path $ubuntu -Force | Out-Null
 & wsl.exe --install -d $Distribution --location $ubuntu --no-launch
 if($LASTEXITCODE -ne 0){StopSafe 'WSL Ubuntu installation failed. No C: fallback.'}
}
if(-not(Test-Path (Join-Path $ubuntu 'ext4.vhdx'))){StopSafe 'Ubuntu VHD is missing at target path.'}
Write-Host 'Ubuntu location verified.'
if($VerifyOnly){exit 0}
$linuxScript=Join-Path $PSScriptRoot 'setup-linux.sh'
if(-not(Test-Path $linuxScript)){StopSafe 'setup-linux.sh missing. Download the entire installer folder.'}
& wsl.exe -d $Distribution -u root -- /bin/true
if($LASTEXITCODE -ne 0){StopSafe 'Cannot boot distro; stop safely.'}
& wsl.exe -d $Distribution -u root -- mkdir -p /opt/tunnellab-installer
if($LASTEXITCODE -ne 0){StopSafe 'Cannot create Linux staging folder.'}
$unc='\\wsl.localhost\'+$Distribution+'\opt\tunnellab-installer\setup-linux.sh'
Copy-Item -LiteralPath $linuxScript -Destination $unc -Force
Approve 'Install Linux prerequisites, create an unprivileged user, and restrict WSL interoperability?'
& wsl.exe -d $Distribution -u root -- bash /opt/tunnellab-installer/setup-linux.sh --system
if($LASTEXITCODE -ne 0){StopSafe 'Linux setup incomplete; inspect terminal errors and rerun.'}
Write-Host 'Terminating Ubuntu only to apply WSL settings. Windows will NOT restart.'
& wsl.exe --terminate $Distribution
if($LASTEXITCODE -ne 0){StopSafe 'Ubuntu termination failed.'}
& wsl.exe -d $Distribution -u dsh-agent -- bash /opt/tunnellab-installer/setup-linux.sh --app
if($LASTEXITCODE -ne 0){StopSafe 'Application setup incomplete; inspect terminal and rerun.'}
Write-Host 'Profile configured but inactive. No GitHub auth, model, workers or automation configured.'
)][string]$Folder='dsh-superagent',
 [string]$Distribution='Ubuntu-24.04',
 [switch]$VerifyOnly
)
$ErrorActionPreference='Stop'
$DriveLetter=$DriveLetter.ToUpperInvariant()
$root=Join-Path ($DriveLetter+':\') $Folder
$ubuntu=Join-Path $root 'Ubuntu'
function StopSafe($msg){ Write-Warning $msg; exit 2 }
function Approve($msg){ $a=Read-Host ($msg+' Type YES'); if($a -cne 'YES'){StopSafe 'Not approved.'} }
$v=Get-Volume -DriveLetter $DriveLetter -ErrorAction Stop
$d=Get-Partition -DriveLetter $DriveLetter | Get-Disk
Write-Host ('Disk: '+$d.FriendlyName+' serial: '+$d.SerialNumber)
Write-Host ('Target: '+$ubuntu)
if($DriveLetter -eq 'C'){StopSafe 'Refusing installation to Windows system drive.'}
if($v.FileSystem -ne 'NTFS'){StopSafe 'Only NTFS volumes supported.'}
if($v.SizeRemaining -lt 20GB){StopSafe 'Need at least 20 GiB available.'}
if(-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)){StopSafe 'WSL missing. Install separately as Administrator and rerun.'}
& wsl.exe --version | Out-Host
if($LASTEXITCODE -ne 0){StopSafe 'WSL not initialized: run wsl --install --no-distribution as admin, handle reboot manually, then rerun.'}
$distros=(& wsl.exe --list --quiet | Out-String)
$exists= $distros -match [regex]::Escape($Distribution)
if($exists){
 if(-not (Test-Path (Join-Path $ubuntu 'ext4.vhdx'))){StopSafe 'Distribution exists elsewhere. Refusing to overwrite.'}
 Write-Host 'Existing Ubuntu VHD verified at selected path.'
}else{
 if(Test-Path $ubuntu){if(@(Get-ChildItem $ubuntu -Force).Count -gt 0){StopSafe 'Target directory is not empty.'}}
 if($VerifyOnly){Write-Host 'Preflight OK; Ubuntu not installed.';exit 0}
 Approve 'Install Ubuntu 24.04 at this SSD path?'
 New-Item -ItemType Directory -Path $ubuntu -Force | Out-Null
 & wsl.exe --install -d $Distribution --location $ubuntu --no-launch
 if($LASTEXITCODE -ne 0){StopSafe 'WSL Ubuntu installation failed. No C: fallback.'}
}
if(-not(Test-Path (Join-Path $ubuntu 'ext4.vhdx'))){StopSafe 'Ubuntu VHD is missing at target path.'}
Write-Host 'Ubuntu location verified.'
if($VerifyOnly){exit 0}
$linuxScript=Join-Path $PSScriptRoot 'setup-linux.sh'
if(-not(Test-Path $linuxScript)){StopSafe 'setup-linux.sh missing. Download the entire installer folder.'}
& wsl.exe -d $Distribution -u root -- /bin/true
if($LASTEXITCODE -ne 0){StopSafe 'Cannot boot distro; stop safely.'}
& wsl.exe -d $Distribution -u root -- mkdir -p /opt/tunnellab-installer
if($LASTEXITCODE -ne 0){StopSafe 'Cannot create Linux staging folder.'}
$unc='\\wsl.localhost\'+$Distribution+'\opt\tunnellab-installer\setup-linux.sh'
Copy-Item -LiteralPath $linuxScript -Destination $unc -Force
Approve 'Install Linux prerequisites, create an unprivileged user, and restrict WSL interoperability?'
& wsl.exe -d $Distribution -u root -- bash /opt/tunnellab-installer/setup-linux.sh --system
if($LASTEXITCODE -ne 0){StopSafe 'Linux setup incomplete; inspect terminal errors and rerun.'}
Write-Host 'Terminating Ubuntu only to apply WSL settings. Windows will NOT restart.'
& wsl.exe --terminate $Distribution
if($LASTEXITCODE -ne 0){StopSafe 'Ubuntu termination failed.'}
& wsl.exe -d $Distribution -u dsh-agent -- bash /opt/tunnellab-installer/setup-linux.sh --app
if($LASTEXITCODE -ne 0){StopSafe 'Application setup incomplete; inspect terminal and rerun.'}
Write-Host 'Profile configured but inactive. No GitHub auth, model, workers or automation configured.'
