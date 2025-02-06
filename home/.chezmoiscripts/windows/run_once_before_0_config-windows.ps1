# Refs: 
# https://github.com/neersighted/dotfiles/blob/3fd327c6d4c263087999ab1c9e0bfd96c806ab5c/home/.chezmoiscripts/run_onchange_after_windows_preferences.ps1

# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
{
  if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000)
  {
    $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
    Start-Process -Wait -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
    Exit
  }
}

# Allow long path
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1

# Show hiddent files and folders
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name Hidden -Value 1
# Unhide file ext
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name HideFileExt -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name ShowSuperHidden -Value 0

# Enable Hyper-V/WSL.
# if (!(Get-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform).State)
# {
#   Write-Host 'Enabling Hyper-V...'
#   # Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
#   Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform
# }

if (!(Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State)
{
  Write-Host 'Enabling Virtual Machine Platform...'
  Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
}

if (!(Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State)
{
  Write-Host 'Enabling WSL...'
  Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
}

# TODO: later

NetFx4-AdvSrvs
