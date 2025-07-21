##########################################

# GENERAL, VARIABLES

# VARIABLES
$env:VISUAL = "code"
$env:PAGER = "delta"
$env:PYTHONIOENCODING = "utf-8" # To fix thefuck
#$env:MAKEFLAGS = "-f C:\\Users\\kevinnitro\\.config\\mkfile\\global.mk"
# $env:XDG_CONFIG_HOME = "$($env:USERPROFILE)\.config"
$env:NODE_OPTIONS = "--disable-warning=ExperimentalWarning"

# If is in non-interactive shell, then return
if (!([Environment]::UserInteractive -and -not $([Environment]::GetCommandLineArgs() | Where-Object { $_ -like '-NonI*' })))
{
  return
}

$DEFAULT_NVIM_CONFIG = "nvim"
$NVIM_CONFIGS = @(
  "nvim",
  "LazyVim",
  "NvChad"
)

# App manage
$CHOCO_APPS_TO_UPGRADE = @(
)

$SCOOP_APPS_TO_UPGRADE = @(
  "extras/autohotkey",
  "extras/dockercompletion",
  "extras/komorebi",
  "extras/lazygit",
  "extras/obs-studio",
  "extras/posh-git"
  "extras/powertoys",
  "extras/psfzf",
  "extras/psreadline",
  "extras/scoop-completion",
  "extras/vscode",
  "main/actionlint",
  "main/bat",
  "main/delta",
  "main/eza",
  "main/fastfetch",
  "main/fd",
  "main/fzf",
  "main/grep",
  "main/lazydocker",
  "main/lf",
  "main/neovim",
  "main/rclone",
  "main/ripgrep",
  "main/sd",
  "main/sed",
  "main/starship",
  "main/sudo",
  "main/tldr",
  "main/touch",
  "main/zoxide"
)

$PIP_APPS_TO_UPGRADE = @(
  "thefuck",
  "cpplint",
  "ruff"
)

$NPM_APPS_TO_UPGRADE = @(
  "markdownlint",
  "eslint",
  "prettier"
)

$POWERSHELL_MODULES_TO_UPDATE = @(
  "CompletionPredictor",
  "posh-wakatime"
)


##########################################

# MODULES

# Import-Module DockerCompletion
# Import-Module Terminal-Icons
# Import-Module posh-wakatime
# Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion"
# Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
# Import-Module "$env:USERPROFILE\.config\wakatime\posh-wakatime\posh-wakatime.psm1"
Import-Module CompletionPredictor
Import-Module posh-git
Import-Module Catppuccin
Import-Module PsReadLine


##########################################

# PWSH CONFIG

# Let the script run even on error
# $ErrorActionPreference = "SilentlyContinue"

# For stop cursor from blinking
#Write-Host "`e[?12l"

# Pwsh catppuccin theme
$Flavor = $Catppuccin['Mocha']
# PSStyle Catppuccin
# Ref: https://github.com/catppuccin/powershell#profile-usage
$PSStyle.Formatting.Debug = $Flavor.Sky.Foreground()
$PSStyle.Formatting.Error = $Flavor.Red.Foreground()
$PSStyle.Formatting.ErrorAccent = $Flavor.Blue.Foreground()
$PSStyle.Formatting.FormatAccent = $Flavor.Teal.Foreground()
$PSStyle.Formatting.TableHeader = $Flavor.Rosewater.Foreground()
$PSStyle.Formatting.Verbose = $Flavor.Yellow.Foreground()
$PSStyle.Formatting.Warning = $Flavor.Peach.Foreground()


# PSREADLINE CONFIG

$ScriptBlock = {
  Param([string]$line)
  if ($line -like " *")
  {
    return $false
  }
  $ignore_psreadline = @("user", "pass", "account")
  foreach ($ignore in $ignore_psreadline)
  {
    if ($line -match $ignore)
    {
      return $false
    }
  }
  return $true
}

# Ref: https://github.com/catppuccin/powershell#profile-usage
$Colors = @{
  # Largely based on the Code Editor style guide
  # Emphasis, ListPrediction and ListPredictionSelected are inspired by the Catppuccin fzf theme

  # Powershell colours
  ContinuationPrompt     = $Flavor.Teal.Foreground()
  Emphasis               = $Flavor.Red.Foreground()
  Selection              = $Flavor.Surface0.Background()

  # PSReadLine prediction colours
  InlinePrediction       = $Flavor.Overlay0.Foreground()
  ListPrediction         = $Flavor.Mauve.Foreground()
  ListPredictionSelected = $Flavor.Surface0.Background()

  # Syntax highlighting
  Command                = $Flavor.Blue.Foreground()
  Comment                = $Flavor.Overlay0.Foreground()
  Default                = $Flavor.Text.Foreground()
  Error                  = $Flavor.Red.Foreground()
  Keyword                = $Flavor.Mauve.Foreground()
  Member                 = $Flavor.Rosewater.Foreground()
  Number                 = $Flavor.Peach.Foreground()
  Operator               = $Flavor.Sky.Foreground()
  Parameter              = $Flavor.Pink.Foreground()
  String                 = $Flavor.Green.Foreground()
  Type                   = $Flavor.Yellow.Foreground()
  Variable               = $Flavor.Lavender.Foreground()
}

$PSReadLineOptions = @{
  EditMode             = "emacs"
  AddToHistoryHandler  = $ScriptBlock
  Color                = $Colors
  ExtraPromptLineCount = $true
  HistoryNoDuplicates  = $true
  MaximumHistoryCount  = 5000
  PredictionSource     = "HistoryAndPlugin"
  PredictionViewStyle  = "ListView"
  ShowToolTips         = $true
  BellStyle            = "None"
}

Set-PSReadLineOption @PSReadLineOptions

# VIM MODE

# function OnViModeChange
# {
#   if ($args[0] -eq 'Command')
#   {
#     # Set the cursor to a blinking block.
#     Write-Host -NoNewLine "`e[1 q"
#   } else
#   {
#     # Set the cursor to a blinking line.
#     Write-Host -NoNewLine "`e[5 q"
#   }
# }

# Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $Function:OnViModeChange

# Set jk to exit vi
# Ref: https://github.com/PowerShell/PSReadLine/issues/1701#issuecomment-1445137723
# Set-PSReadLineKeyHandler -Key j -ViMode Insert -ScriptBlock {
#   if (!$j_timer.IsRunning -or $j_timer.ElapsedMilliseconds -gt 1000)
#   {
#     [Microsoft.PowerShell.PSConsoleReadLine]::Insert("k")
#     $j_timer.Restart()
#     return
#   }

#   [Microsoft.PowerShell.PSConsoleReadLine]::Insert("k")
#   [Microsoft.PowerShell.PSConsoleReadLine]::ViCommandMode()
#   $line = $null
#   $cursor = $null
#   [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
#   [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor-1, 2)
#   [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor-2)
# }

# ref: https://github.com/PowerShell/PSReadLine/issues/759#issuecomment-518363364
# $j_timer = New-Object System.Diagnostics.Stopwatch
# Set-PSReadLineKeyHandler -Chord 'j' -ScriptBlock {
#   if ([Microsoft.PowerShell.PSConsoleReadLine]::InViInsertMode())
#   {
#     $j_timer.ReStart()
#     $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
#     # $key = [System.Console]::ReadKey()
#     if (($j_timer.ElapsedMilliseconds -lt 500) -and $key.Character -eq 'k')
#     {
#       [Microsoft.PowerShell.PSConsoleReadLine]::ViCommandMode()
#     } else
#     {
#       [Microsoft.Powershell.PSConsoleReadLine]::Insert('j')
#       [Microsoft.Powershell.PSConsoleReadLine]::Insert($key.Character)
#     }
#     $j_timer.Stop()
#   }
# }

Set-PSReadLineKeyHandler -Key "Ctrl+p" -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key "Ctrl+n" -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key "Ctrl+w" -Function BackwardDeleteWord
Set-PSReadLineKeyHandler -Key "Ctrl+RightArrow" -Function ForwardWord
Set-PSReadLineKeyHandler -Key "Ctrl+LeftArrow" -Function BackwardWord

# https://ianmorozoff.com/2023/01/10/predictive-intellisense-on-by-default-in-powershell-7-3/#keybinding
$parameters = @{
  Key              = 'F4'
  BriefDescription = 'Toggle PSReadLineOption PredictionSource'
  LongDescription  = 'Toggles the PSReadLineOption PredictionSource option between "None" and "HistoryAndPlugin".'
  ScriptBlock      = {

    # Get current state of PredictionSource
    $state = (Get-PSReadLineOption).PredictionSource

    # Toggle between None and HistoryAndPlugin
    switch ($state)
    {
      "None"
      {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
      }
      "History"
      {
        Set-PSReadLineOption -PredictionSource None
      }
      "Plugin"
      {
        Set-PSReadLineOption -PredictionSource None
      }
      "HistoryAndPlugin"
      {
        Set-PSReadLineOption -PredictionSource None
      }
      Default
      {
        Write-Host "Current PSReadLineOption PredictionSource is Unknown"
      }
    }

    # Trigger autocomplete to appear without changing the line
    # InvokePrompt() does not cause ListView style suggestions to disappear when toggling off
    #[Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()

    # Trigger autocomplete to appear or disappear while preserving the current input
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert(' ')
    [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar()

  }
}
Set-PSReadLineKeyHandler @parameters

# Clear PSReadLine history
function Clear-PSReadLineHistory
{
  Get-PSReadLineOption | Select-Object -expand HistorySavePath | Remove-Item
}

##########################################

Function Test-CommandExists
{
  Param ($command)
  $oldPreference = $ErrorActionPreference
  $ErrorActionPreference = 'SilentlyContinue'
  try
  {
    if (Get-Command $command)
    {
      RETURN $true
    }
  } Catch
  {
    Write-Host "$command does not exist"; RETURN $false
  } Finally
  {
    $ErrorActionPreference = $oldPreference
  }
}


##########################################

# ALIAS

Set-Alias -Name ss -Value Select-String
Set-Alias -Name e -Value explorer.exe
Set-Alias -Name c -Value cls
Set-Alias -Name csl -Value cls
Set-Alias -Name shutdownnow -Value Stop-Computer
Set-Alias -Name rebootnow -Value Restart-Computer

# if (Test-Path -Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -PathType Leaf)
# {
#   Set-Alias -Name msbuild -Value "$(&"${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -prerelease -products * -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe)"
# }

Set-Alias -Name lg -Value lazygit


if (Get-Command scoop)
{
  Set-Alias -Name gitbash -Value "$env:USERPROFILE\scoop\apps\git\current\usr\bin\bash"
  Set-Alias -Name curl -Value "$env:USERPROFILE\scoop\apps\curl\current\bin\curl"
}


##########################################

# UTILS

function Check-WiFiPassword
{
  param(
    [string]$name = $null
  )
  if (-not $name)
  {
    if (Get-Command fzf)
    {
      $name = netsh wlan show profiles |
        Select-String -Pattern "All User Profile\s+:\s+(.*)" |
        ForEach-Object { $_.Matches.Groups[1].Value } |
        fzf --prompt="Select Wi-Fi  " --height=~80% --layout=reverse --border --exit-0 --cycle --margin="2,40" --padding=1
    } else
    {
      "LIST OF SAVED WI-FI"
      "`n---`n"
      # Get the list of saved Wi-Fi networks with position numbers
      $wifiList = netsh wlan show profiles |
        Select-String -Pattern "All User Profile\s+:\s+(.*)" |
        ForEach-Object { $_.Matches.Groups[1].Value }
      # Output the list with position numbers
      for ($i = 0; $i -lt $wifiList.Count; $i++)
      {
        # "$($i+1): $($wifiList[$i])"
        "{0,5}: {1}" -f ($i + 1), $wifiList[$i]
      }
      "`n---`n"
      $inputPosition = Read-Host "Enter the position number of the Wi-Fi network to check the password (Enter for current network)"
      if ([string]::IsNullOrEmpty($inputPosition))
      {
        $name = ((netsh wlan show interfaces | Select-String -Pattern "Profile" -Context 0, 1) -split ":")[1].Trim()
      } else
      {
        # Convert the input position to zero-based index
        $index = [int]$inputPosition - 1
        if ($index -ge 0 -and $index -lt $wifiList.Count)
        {
          $name = $wifiList[$index]
        } else
        {
          "Invalid position number."
          return
        }
      }
    }
  }
  if (-not $name)
  {
    "No input Wi-Fi name"
    return
  }
  $wlan_profile = netsh wlan show profile name="$name" key=clear
  $password = $wlan_profile | Select-String -Pattern "Key Content\s+:\s+(.+)" | ForEach-Object { $_.Matches.Groups[1].Value }
  "Wi-Fi: $name"
  if ($password)
  {
    "Password: $password"
  } else
  {
    "No password available"
  }
}

function Check-Battery
{
  Set-Location
  powercfg /batteryreport
  & "$env:USERPROFILE\battery-report.html"
  Start-Sleep -Seconds 1
  Remove-Item -Path "$env:USERPROFILE\battery-report.html" -Force
}

# Cheat sheet from The Primeagen
# https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-cht.sh
function chtsh
{
  $languages = @(
    "python",
    "cpp",
    "js",
    "ts",
    "bash",
    "powershell",
    "nodejs",
    "lua",
    "css",
    "html"
  )
  $command = @(

  )
  $selected = $languages + $command | fzf --prompt "cht.sh  "  --height=~80% --layout=reverse --border --exit-0 --cycle --margin="2,3" --padding=1
  if (-not $selected)
  {
    exit 0
  }

  $query = Read-Host "Enter Query"

  if ($languages -contains $selected)
  {
    $query = $query -replace ' ', '+'
    curl "cht.sh/$selected/$query"
  } else
  {
    curl "cht.sh/$selected~$query"
  }
}


##########################################

# FZF CONFIG

# Ref: https://github.com/catppuccin/powershell#profile-usage
# https://github.com/catppuccin/fzf - not use background for transparent
$env:FZF_DEFAULT_OPTS = @"
--color=hl:$($Flavor.Red),fg:$($Flavor.Text),header:$($Flavor.Red)
--color=info:$($Flavor.Mauve),pointer:$($Flavor.Rosewater),marker:$($Flavor.Rosewater)
--color=fg+:$($Flavor.Text),prompt:$($Flavor.Mauve),hl+:$($Flavor.Red)
--color=border:$($Flavor.Surface2)
--layout=reverse
--cycle
--scroll-off=5
--border
--preview-window=right,60%,border-left
--bind ctrl-u:preview-half-page-up
--bind ctrl-d:preview-half-page-down
--bind ctrl-f:preview-page-down
--bind ctrl-b:preview-page-up
--bind ctrl-g:preview-top
--bind ctrl-h:preview-bottom
--bind alt-w:toggle-preview-wrap
--bind ctrl-e:toggle-preview
"@

$commandOverride = [ScriptBlock] { param($Location) Write-Host $Location }

Set-PsFzfOption -AltCCommand $commandOverride

Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

Set-PsFzfOption -PSReadlineChordProvider "Ctrl+e" -PSReadlineChordReverseHistory "Ctrl+r" -GitKeyBindings -TabExpansion -EnableAliasFuzzyGitStatus -EnableAliasFuzzyEdit -EnableAliasFuzzyFasd -EnableAliasFuzzyKillProcess -EnableAliasFuzzyScoop

function _fzf_open_path
{
  param (
    [Parameter(Mandatory = $false)]
    [string]$input_path
  )
  if (-not (Test-Path $input_path))
  {
    return
  }
  $cmds = @{
    'bat'    = { bat $input_path }
    'cat'    = { Get-Content $input_path }
    'cd'     = {
      if (Test-Path $input_path -PathType Leaf)
      {
        $input_path = Split-Path $input_path -Parent
      }
      Set-Location $input_path
    }
    'nvim'   = { nvim $input_path }
    'remove' = { Remove-Item -Recurse -Force $input_path }
    'echo'   = { Write-Output $input_path }
  }
  $cmd = $cmds.Keys | fzf --prompt 'Select command> '
  & $cmds[$cmd]
}

function _fzf_get_path_using_fd
{
  try
  {
    $input_path = fd --type file --follow --hidden --exclude .git |
      fzf --prompt 'Files> ' `
        --header-first `
        --header 'CTRL-S: Switch between Files/Directories' `
        --bind 'ctrl-s:transform:if not "%FZF_PROMPT%"=="Files> " (echo ^change-prompt^(Files^> ^)^+^reload^(fd --type file^)) else (echo ^change-prompt^(Directory^> ^)^+^reload^(fd --type directory^))' `
        --preview 'if "%FZF_PROMPT%"=="Files> " (bat --color=always {} --style=plain) else (eza -T --colour=always --icons=always {})'
    return $input_path
  } catch
  {
    return ""
  }
}

function _fzf_get_path_using_rg
{
  try
  {
    $INITIAL_QUERY = "${*:-}"
    $RG_PREFIX = "rg --column --line-number --no-heading --color=always --smart-case"
    $input_path = "" |
      fzf --ansi --disabled --query "$INITIAL_QUERY" `
        --bind "start:reload:$RG_PREFIX {q}" `
        --bind "change:reload:sleep 0.1 & $RG_PREFIX {q} || rem" `
        --bind 'ctrl-s:transform:if not "%FZF_PROMPT%" == "1. ripgrep> " (echo ^rebind^(change^)^+^change-prompt^(1. ripgrep^> ^)^+^disable-search^+^transform-query:echo ^{q^} ^> %TEMP%\rg-fzf-f ^& type %TEMP%\rg-fzf-r) else (echo ^unbind^(change^)^+^change-prompt^(2. fzf^> ^)^+^enable-search^+^transform-query:echo ^{q^} ^> %TEMP%\rg-fzf-r ^& type %TEMP%\rg-fzf-f)' `
        --color 'hl:-1:underline,hl+:-1:underline:reverse' `
        --delimiter ':' `
        --prompt '1. ripgrep> ' `
        --preview-label 'Preview' `
        --header 'CTRL-S: Switch between ripgrep/fzf' `
        --header-first `
        --preview 'bat --color=always {1} --highlight-line {2} --style=plain' `
        --preview-window 'up,60%,border-bottom,+{2}+3/3'
    $input_path = ($input_path -split ":")[0]
    return $input_path
  } catch
  {
    return ""
  }
}

function fdg
{
  _fzf_open_path $(_fzf_get_path_using_fd)
}

function rgg
{
  _fzf_open_path $(_fzf_get_path_using_rg)
}

Set-PSReadLineKeyHandler -Key "Ctrl+f" -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert("fdg")
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadLineKeyHandler -Key "Ctrl+g" -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert("rgg")
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}


##########################################

# BAT CONFIG
function List-BatThemes
{
  $file = fzf --prompt="Select a file to preview  " --preview  "bat --color=always {1} --style=numbers --line-range=:500 {}" --header "Bat preview themes" --header-first
  bat --list-themes | fzf --preview "bat theme={} --color=always $file"
}


##########################################

# YAZI CONFIG
Set-Alias -Name yz -Value yazi

function yzcd
{
  $tmp = [System.IO.Path]::GetTempFileName()
  yazi $args --cwd-file="$tmp"
  $cwd = Get-Content -Path $tmp
  if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path)
  {
    Set-Location -LiteralPath $cwd
  }
  Remove-Item -Path $tmp
}

Set-PSReadLineKeyHandler -Key "Ctrl+d" -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert("yzcd")
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}


##########################################

# EZA CONFIG

if ((Get-Command -Name "eza" -ErrorAction SilentlyContinue))
{
  $DEFAULT_EZA_ARGS = @(
    "--colour=always",
    "--git",
    "--group-directories-first",
    "--icons=always",
    "--ignore-glob=.DS_Store",
    "--no-quotes",
    "--sort=type"
  )

  function _ls
  {
    eza -1 @DEFAULT_EZA_ARGS @args
  }

  function l
  {
    eza -l @DEFAULT_EZA_ARGS @args
  }

  function ll
  {
    eza -lag @DEFAULT_EZA_ARGS @args
  }

  function ld
  {
    eza -lD @DEFAULT_EZA_ARGS @args
  }

  function lt
  {
    eza --tree @DEFAULT_EZA_ARGS @args
  }

  function llt
  {
    eza --tree -lag @DEFAULT_EZA_ARGS @args
  }

  Set-Alias -Name ls -Value _ls -Force
}

##########################################

# CHEZMOI CONFIG

if (Test-CommandExists chezmoi)
{

  Set-Alias -Name cm -Value chezmoi -Option AllScope

  function cmc
  {
    param (
      [string] $msg
    )
    if ($msg)
    {
      chezmoi git commit -m "$msg"
    } else
    {
      chezmoi git commit
    }
    if ($LASTEXITCODE -eq 0)
    {
      chezmoi git push
    }
  }

  function cma
  {
    param (
      [string[]] $files
    )
    $current_dir = Get-Location
    for ($i = 0; $i -lt $files.Length; $i++)
    {
      $files[$i] = "$($current_dir)\$($files[$i])"
    }
    Set-Location
    chezmoi add $files $args
    Set-Location $current_dir
  }

  function cmp
  {
    chezmoi git -- push
  }

  function cms
  {
    chezmoi re-add
    chezmoi git -- f
  }


  function cme
  {
    chezmoi edit --watch $args
  }

  function cdcm
  {
    Set-Location $env:USERPROFILE/.local/share/chezmoi
  }
}



##########################################

# APP MANAGE

function List-ChocoApps
{
  $apps = $(choco list --id-only --no-color).Split("\n")
  $apps = $apps[1..($apps.Length - 2)]
  return $apps
}

function List-ScoopApps
{
  $apps = $(scoop list | Select-Object -ExpandProperty "Name").Split("\n")
  $apps = $apps[1..($apps.Length - 1)]
  return $apps
}

function List-UpdatableScoopApps
{
  $apps = $(scoop status | Select-Object -ExpandProperty "Name").Split("\n")
  return $apps
}

function Select-Apps
{
  param (
    [string[]] $apps
  )
  $apps = $apps | fzf --prompt="Select Apps  " --height=~80% --layout=reverse --border --cycle --margin="2,20" --padding=1 --multi
  return $apps
}

function Update-ChocoApps
{
  $apps_set = New-Object System.Collections.Generic.HashSet[[String]]
  $installed_apps = List-ChocoApps
  foreach ($app in Select-Apps $installed_apps)
  {
    $apps_set.Add($app) >$null
  }
  $include = $(Read-Host "Include predefine apps to update [Y/n]").ToUpper()
  if ($include -eq "Y" -or $include -eq "")
  {
    foreach ($app in $CHOCO_APPS_TO_UPGRADE)
    {
      if ($installed_apps -contains $app)
      {
        $apps_set.Add($app) >$null
      }
    }
  }
  if ($apps_set.Length)
  {
    $apps_string = ($apps_set -split ",")
    if (Check-IsAdmin)
    {
      choco upgrade $apps_string -y
    } else
    {
      Start-Process -FilePath "powershell" -ArgumentList "choco upgrade $($apps_string) -y" -Verb runas
    }
  }
}

function Update-ScoopApps
{
  scoop update
  $apps_set = New-Object System.Collections.Generic.HashSet[[String]]
  $installed_apps = List-UpdatableScoopApps
  foreach ($app in Select-Apps $installed_apps)
  {
    $apps_set.Add($app) >$null
  }
  $include = $(Read-Host "Include predefine apps to update [Y/n]").ToUpper()
  if ($include -eq "Y" -or $include -eq "")
  {
    foreach ($app in $SCOOP_APPS_TO_UPGRADE)
    {
      if ($installed_apps -contains $app)
      {
        $apps_set.Add($app) >$null
      }
    }
  }
  if ($apps_set.Length)
  {
    $apps_string = ($apps_set -split ",")
    scoop update $apps_string
  } else
  {
    Write-Host "No app was selected to update"
  }
}
function Update-NpmApps
{
  $apps_string = $NPM_APPS_TO_UPGRADE -join " "
  npm upgrade $apps_string
}

function Update-PipApps
{
  $apps_string = $PIP_APPS_TO_UPGRADE -join " "
  pip install --upgrade $apps_string
}

function Update-PowershellModules
{
  # Update-Module -Name $POWERSHELL_MODULES_TO_UPDATE -AcceptLicense -Force
  Update-Module -AcceptLicense -Force
}

function Uninstall-ChocoApps
{
  $apps = Select-Apps $(List-ChocoApps)
  if ($apps.Length -eq 0)
  {
    Write-Host "No app was selected"!
    return
  }
  if (Check-IsAdmin)
  {
    choco uninstall $apps -y
  } else
  {
    Start-Process -FilePath "powershell" -ArgumentList "choco uninstall $($apps) -y" -Verb runas
  }
}

function Uninstall-ScoopApps
{
  $apps = Select-Apps $(List-ScoopApps)
  if ($apps.Length -eq 0)
  {
    Write-Host "No app was selected"!
    return
  }
  scoop uninstall $apps
}


##########################################

# NEOVIM CONFIG

function vs
{
  $items = @( "default" ) + $NVIM_CONFIGS
  # $config = $items | Out-GridView -Title "Neovim Config" -OutputMode Single
  $config = $items | fzf --prompt="  Neovim Config  " --height=~80% --layout=reverse --border --exit-0 --cycle --margin="2,40" --padding=1
  if (-not $config)
  {
    Write-Host "No Neovim config was selected"
    return
  } elseif ($config -eq "default")
  {
    $env:NVIM_APPNAME = $DEAFAULT_NVIM_CONFIG
  } else
  {
    $env:NVIM_APPNAME = $config
  }
  nvim @args
}

function Delete-NeovimData
{
  $available_data = @("shada", "swap", "undo", "sessions")
  $available_config_and_all = $NVIM_CONFIGS + "all"
  $available_data_and_all = $available_data + "all"
  $user_select_data = $available_data_and_all | fzf --prompt="Delete Neovim Data  " --height=~80% --layout=reverse --border --exit-0 --cycle --margin="2,40" --padding=1
  $user_select_config = $available_config_and_all | fzf --prompt="Choose Neovim Config  " --height=~80% --layout=reverse --border --exit-0 --cycle --margin="2,40" --padding=1
  if ($user_select_data -eq "all")
  {
    $data = $available_data
  } else
  {
    $data = @($user_select_data)
  }
  if ($user_select_config -eq "all")
  {
    $configs = $NVIM_CONFIGS
  } else
  {
    $configs = @($user_select_config)
  }
  foreach ($config in $configs)
  {
    foreach ($data in $user_select_data)
    {
      if (Test-Path "$env:LOCALAPPDATA/$config-data/$data" -PathType Container)
      {
        Write-Output "Deleting `"$env:LOCALAPPDATA/$config-data/$data`""
        Remove-Item -Path "$env:LOCALAPPDATA/$config-data/$data" -Recurse -Force -ErrorAction Continue
      } else
      {
        Write-Output "`"$env:LOCALAPPDATA/$config-data/$data`" doesn't exist"
      }
    }
  }
}


##########################################

# START - STOP PROGRAMS, SERVICES

function Stop-Unikey
{
  if (Get-Process -Name "UniKeyNT" -ErrorAction SilentlyContinue)
  {
    Start-Process -FilePath "powershell" -ArgumentList "Stop-Process -Name UniKeyNT" -Verb runas
  } else
  {
    Write-Host "UniKeyNT isn't running! No need to stop!"
  }
}

function Start-Unikey
{
  Start-Process "$($env:LOCALAPPDATA)\UniKey\UniKeyNT.exe" -Verb runas
}

function Restart-Unikey
{
  Stop-Unikey
  Start-Unikey
}

function Stop-EVKey
{
  if (Get-Process -Name "EVKey64" -ErrorAction SilentlyContinue)
  {
    Start-Process -FilePath "powershell" -ArgumentList "Stop-Process -Name EVKey64" -Verb runas
  } else
  {
    Write-Host "EVKey64 isn't running! No need to stop!"
  }
}

function Start-EVKey
{
  Start-Process "$($env:LOCALAPPDATA)\EVKey\EVKey64.exe" -Verb runas
}

function Restart-EVKey
{
  Stop-EVKey
  Start-EVKey
}


##########################################

# Komorebi config

function Restart-Komorebi
{
  Stop-Process -Name komorebi -ErrorAction SilentlyContinue
  Stop-Process -Name komorebi-bar -ErrorAction SilentlyContinue
  Stop-Process -Name AutoHotkeyUX -ErrorAction SilentlyContinue
  komorebic-no-console.exe start --bar
  AutoHotkey.exe "$env:USERPROFILE\.config\autohotkey\main.ahk"
}

# Update applications.yml

function Update-KomorebiApplications
{
  komorebic fetch-asc
}


##########################################

# Function to set service to Manual and start it
function Set-ServiceToManualAndStart
{
  param (
    [string]$serviceName
  )
  try
  {
    Set-Service -Name $serviceName -StartupType Manual
    Start-Service -Name $serviceName
  } catch
  {
    Write-Host "Error managing service '$serviceName': $_" -ForegroundColor Red
  }
}

# Function to stop service and disable it
function Stop-ServiceAndDisable
{
  param (
    [string]$serviceName
  )
  try
  {
    Stop-Service -Name $serviceName -Force 
    Set-Service -Name $serviceName -StartupType Disabled
  } catch
  {
    Write-Host "Error managing service '$serviceName': $_" -ForegroundColor Red
  }
}


$DELL_SERVICES = @(
  'DellClientManagementService',
  'DDVDataCollector'
  'DDVRulesProcessor'
  'DDVCollectorSvcApi'
  'SupportAssistAgent'
  'DellTechHub'
)


function Start-DellServices
{
  foreach ($service in $DELL_SERVICES)
  {
    Set-ServiceToManualAndStart -serviceName $service
  }
}

function Stop-DellServices
{
  foreach ($service in $DELL_SERVICES)
  {
    Stop-ServiceAndDisable -serviceName $service
  }
}


##########################################

# GPG

function Start-GPG
{
  gpg-connect-agent reloadagent /bye
}

function Stop-GPG
{
  Stop-Process -Name "gpg-agent" -ErrorAction SilentlyContinue
}

function Restart-GPG
{
  Start-GPG
}


##########################################

# Cloudflare WARP
$CLOUDFLAREWARP_SERVICE_NAME = "CloudflareWARP"

function Start-CloudFlareWarp
{
  $sv = Get-Service -Name $CLOUDFLAREWARP_SERVICE_NAME -ErrorAction SilentlyContinue
  if ($sv)
  {
    Start-Process -FilePath "powershell" -ArgumentList "Set-Service -Name $($CLOUDFLAREWARP_SERVICE_NAME) -StartupType Manual; Set-Service -Name $($CLOUDFLAREWARP_SERVICE_NAME) -Status Running -PassThru" -Verb runas
    Start-Sleep 5
    Start-Process "Cloudflare WARP.exe"
    Write-Host "Started CloudflareWARP"
  } else
  {
    Write-Error "No CloudflareWARP service found!"
  }
}

function Stop-CloudFlareWarp
{
  $sv = Get-Service -Name $CLOUDFLAREWARP_SERVICE_NAME -ErrorAction SilentlyContinue
  if ($sv)
  {
    Stop-Process -Name "Cloudflare WARP" -Force -ErrorAction SilentlyContinue
    Start-Process -FilePath "powershell" -ArgumentList "Set-Service -Name $($CLOUDFLAREWARP_SERVICE_NAME) -Status Stopped -PassThru; Set-Service -Name $($CLOUDFLAREWARP_SERVICE_NAME) -StartupType Disabled" -Verb runas
    Write-Host "Stopped CloudflareWARP"
  } else
  {
    Write-Error "No CloudflareWARP service found!"
  }
}


##########################################

# Clean (Delete recycle bin, temp, cache, disk cleanup)
function Delete-RecyleBin
{
  Clear-RecycleBin -Force
  Write-Host "All the necessary data removed from recycle bin successfully" -ForegroundColor Green
}

function Clean-Scoop
{
  scoop cleanup -a
  scoop cache rm *
}

function Run-DiskCleanUp
{
  Write-Host "Using Disk cleanup Tool" -ForegroundColor Yellow  
  cleanmgr /tuneup:1 /d $env:SYSTEMDRIVE /verylowdisk /autoclean
  Write-Host "Disk Cleanup Successfully done" -ForegroundColor Green  
}

function Clean-All
{
  Delete-RecyleBin
  Run-DiskCleanUp
  Clean-Scoop
}


##########################################

# Update Stylus
function Update-CatppuccinStylus
{
  $url = "https://github.com/catppuccin/userstyles/releases/download/all-userstyles-export/import.json"
  $file = "$env:USERPROFILE\.config\stylus\catppuccin.json"

  Invoke-WebRequest -Uri $url -OutFile $file

  $content = Get-Content -Path $file -Raw
  $updatedContent = $content -replace '"name":"accentColor","value":null', '"name":"accentColor","value":"lavender"'

  Set-Content -Path $file -Value $updatedContent
}


##########################################


# Linux like comma"for Windows
# FROM https://github.com/ChrisTitusTech/powershell-profile/
# If so and the current host is a command line, then change to red color
# as warning to user that they are operating in an elevated context
# Useful shortcuts for traversing directories
# Compute file hashes - useful for checking successful downloads

function md5
{
  Get-FileHash -Algorithm MD5 $args
}
function sha1
{
  Get-FileHash -Algorithm SHA1 $args
}
function sha256
{
  Get-FileHash -Algorithm SHA256 $args
}

# Quick shortcut to start notepad
function n
{
  notepad $args
}

# Drive shortcuts
function HKLM:
{
  Set-Location HKLM:
}
function HKCU:
{
  Set-Location HKCU:
}
function Env:
{
  Set-Location Env:
}

# Does the the rough equivalent of dir /s /b. For example, dirs *.png is dir /s /b *.png
function dirs
{
  if ($args.Count -gt 0)
  {
    Get-ChildItem -Recurse -Include "$args" | ForEach-Object FullName
  } else
  {
    Get-ChildItem -Recurse | ForEach-Object FullName
  }
}



##########################################

# Utils
# ref: https://github.com/ChrisTitusTech/powershell-profile/blob/main/Microsoft.PowerShell_profile.ps1

function ..
{
  Set-Location .\..
}

function ...
{
  Set-Location .\..\..
}

function .3
{
  Set-Location .\..\..\..
}

function .4
{
  Set-Location .\..\..\..\..
}

function .5
{
  Set-Location .\..\..\..\..\..
}

function List-AvailableModules
{
  Get-Module -ListAvailable
}

function Update-PowerShell
{
  if (-not $global:canConnectToGitHub)
  {
    Write-Host "Skipping PowerShell update check due to GitHub.com not responding within 1 second." -ForegroundColor Yellow
    return
  }

  try
  {
    Write-Host "Checking for PowerShell updates..." -ForegroundColor Cyan
    $updateNeeded = $false
    $currentVersion = $PSVersionTable.PSVersion.ToString()
    $gitHubApiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
    $latestReleaseInfo = Invoke-RestMethod -Uri $gitHubApiUrl
    $latestVersion = $latestReleaseInfo.tag_name.Trim('v')
    if ($currentVersion -lt $latestVersion)
    {
      $updateNeeded = $true
    }

    if ($updateNeeded)
    {
      Write-Host "Updating PowerShell..." -ForegroundColor Yellow
      winget upgrade "Microsoft.PowerShell" --accept-source-agreements --accept-package-agreements
      Write-Host "PowerShell has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
    } else
    {
      Write-Host "Your PowerShell is up to date." -ForegroundColor Green
    }
  } catch
  {
    Write-Error "Failed to update PowerShell. Error: $_"
  }
}

if (Test-CommandExists nvim)
{
  if (Test-Path "$env:LOCALAPPDATA/$env:DEFAULT_NVIM_CONFIG" -PathType Container)
  {
    $env:NVIM_APPNAME = $env:DEFAULT_NVIM_CONFIG
  }
  $EDITOR = 'nvim'
} elseif (Test-CommandExists code)
{
  $EDITOR = 'code'
} elseif (Test-CommandExists notepad)
{
  $EDITOR = 'notepad'
} elseif (Test-CommandExists pvim)
{
  $EDITOR = 'pvim'
} elseif (Test-CommandExists vim)
{
  $EDITOR = 'vim'
} elseif (Test-CommandExists vi)
{
  $EDITOR = 'vi'
} elseif (Test-CommandExists notepad++)
{
  $EDITOR = 'notepad++'
} elseif (Test-CommandExists sublime_text)
{
  $EDITOR = 'sublime_text'
}
Set-Alias -Name v -Value $EDITOR
$env:EDITOR = $EDITOR

function Edit-Profile
{
  if ($host.Name -match "ise")
  {
    # $psISE.CurrentPowerShellTab.Files.Add($profile.CurrentUserAllHosts)
    $psISE.CurrentPowerShellTab.Files.Add($profile)
  } else
  {
    # notepad $profile.CurrentUserAllHosts
    v $profile
  }
}

# function ll
# {
#   Get-ChildItem -Path $pwd -File
# }

function Get-PubIP
{
  (Invoke-WebRequest http://ifconfig.me/ip ).Content
}

function _Get-Uptime
{
  $bootuptime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
  $CurrentDate = Get-Date
  $uptime = $CurrentDate - $bootuptime
  Write-Output "Uptime: $($uptime.Days) Days, $($uptime.Hours) Hours, $($uptime.Minutes) Minutes"
}

function uptime
{
  #Windows Powershell only
  If ($PSVersionTable.PSVersion.Major -eq 5 )
  {
    Get-WmiObject win32_operatingsystem |
      Select-Object @{EXPRESSION = { $_.ConverttoDateTime($_.lastbootuptime) } } | Format-Table -HideTableHeaders
  } Else
  {
    _Get-Uptime
    net statistics workstation | Select-String "since" | ForEach-Object { $_.ToString().Replace('Statistics since ', 'Since: ') }
  }
}

function Reload-Profile
{
  . $PROFILE
}

Set-Alias -Name rl -Value Reload-Profile

function find-file($name)
{
  Get-ChildItem -Recurse -Filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
    $place_path = $_.directory
    Write-Output "${place_path}\${_}"
  }
}

function unzip ($file)
{
  Write-Output("Extracting", $file, "to", $pwd)
  $fullFile = Get-ChildItem -Path $pwd -Filter .\cove.zip | ForEach-Object { $_.FullName }
  Expand-Archive -Path $fullFile -DestinationPath $pwd
}

function hb
{
  if ($args.Length -eq 0)
  {
    Write-Error "No file path specified."
    return
  }

  $FilePath = $args[0]

  if (Test-Path $FilePath)
  {
    $Content = Get-Content $FilePath -Raw
  } else
  {
    Write-Error "File path does not exist."
    return
  }

  $uri = "http://bin.christitus.com/documents"
  try
  {
    $response = Invoke-RestMethod -Uri $uri -Method Post -Body $Content -ErrorAction Stop
    $hasteKey = $response.key
    $url = "http://bin.christitus.com/$hasteKey"
    Write-Output $url
  } catch
  {
    Write-Error "Failed to upload the document. Error: $_"
  }
}

function head
{
  param($Path, $n = 10)
  Get-Content $Path -Head $n
}

function tail
{
  param($Path, $n = 10)
  Get-Content $Path -Tail $n
}

function mkcd
{
  param($dir) mkdir $dir -Force; Set-Location $dir
}

# Quick Access to System Information
function sysinfo
{
  Get-ComputerInfo
}

# Networking Utilities
function flushdns
{
  Clear-DnsClientCache
}

# Clipboard Utilities
function cpy
{
  Set-Clipboard $args[0]
}

function pst
{
  Get-Clipboard
}

function ix ($file)
{
  curl.exe -F "f:1=@$file" ix.io
}

# function grep($regex, $dir)
# {
#     if ( $dir )
#     {
#         Get-ChildItem $dir | select-string $regex
#         return
#     }
#     $input | select-string $regex
# }

# function touch($file)
# {
#   "" | Out-File $file -Encoding ASCII
# }

function df
{
  Get-Volume
}

# function sed($file, $find, $replace)
# {
#     (Get-Content $file).replace("$find", $replace) | Set-Content $file
# }

# function which($name) {
#     Get-Command $name | Select-Object -ExpandProperty Definition
# }

function export($name, $value)
{
  Set-Item -Force -Path "env:$name" -Value $value;
}

function pkill($name)
{
  Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

function pgrep($name)
{
  Get-Process $name
}

# Powwershell profile from https://github.com/craftzdog/dotfiles-public/blob/master/.config/powershell/user_profile.ps1

[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

#function which ($command)
#{
#  Get-Command -Name $command -ErrorAction SilentlyContinue |
#    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
#}

function Check-IsAdmin
{
  return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# function Reboot-BIOS
# {
#   if (Check-IsAdmin)
#   {
#     shutdown /r /fw /f /t 0
#   } else
#   {
#     if (Test-CommandExists sudo)
#     {
#       sudo shutdown /r /fw /f /t 0
#     } else
#     Write-Host "Please run with administrator privilege"
#   }
# }
#
function Reboot-BIOS
{
  Start-Process -FilePath "shutdown" -ArgumentList "/r /fw /f /t 0" -Verb runas
}

# Ref: https://gist.github.com/mikepruett3/7ca6518051383ee14f9cf8ae63ba18a7
function extract
{
  param (
    [string]$File,
    [string]$Folder
  )

  if (-not $Folder)
  {
    $FileName = [System.IO.Path]::GetFileNameWithoutExtension($File)
    $Folder = Join-Path -Path (Split-Path -Path $File -Parent) -ChildPath "$FileName"
  }

  if (-not (Test-Path -Path $Folder -PathType Container))
  {
    New-Item -Path $Folder -ItemType Directory | Out-Null
  }

  if (Test-Path -Path "$File" -PathType Leaf)
  {
    switch ($File.Split(".") | Select-Object -Last 1)
    {
      "rar"
      {
        Start-Process -FilePath "UnRar.exe" -ArgumentList "x", "-op'$Folder'", "-y", "$File" -WorkingDirectory "$Env:ProgramFiles\WinRAR\" -Wait | Out-Null
      }
      "zip"
      {
        7z x -o"$Folder" -y "$File" | Out-Null
      }
      "7z"
      {
        7z x -o"$Folder" -y "$File" | Out-Null
      }
      "exe"
      {
        7z x -o"$Folder" -y "$File" | Out-Null
      }
      Default
      {
        Write-Error "No way to Extract $File !!!"; return;
      }
    }
    Write-Host "Extracted "$FILE" to "$($Folder)""
  }
}

function extract_multi
{
  $CurrentDate = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
  $Folder = "extracted_$($CurrentDate)"
  New-Item -Path $Folder -ItemType Directory | Out-Null
  foreach ($File in $args)
  {
    extract -File $File -Folder "$($Folder)\$([System.IO.Path]::GetFileNameWithoutExtension($File))"
  }
}

function Get-Fonts
{
  param (
    $regex
  )
  $AllFonts = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
  if ($null -ne $regex)
  {
    $FilteredFonts = $($AllFonts | Select-String -Pattern ".*${regex}.*")
    return $FilteredFonts
  }
  return $AllFonts
}


##########################################

# EVALX

$_EVALX_COMMANDS = @{
  source_chezmoi_completion = 'Invoke-Expression (& { (chezmoi completion powershell | Out-String) })'
  source_docker_completion  = 'Import-Module DockerCompletion'
  source_gh_autocompletion  = 'Invoke-Expression (& { (gh completion -s powershell | Out-String) })'
  source_posh_wakatime      = 'Import-Module posh-wakatime'
  source_rclone_completion  = 'Invoke-Expression (& { (rclone completion powershell | Out-String) })'
  source_scoop_completion   = 'Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion"'
  source_terminal_icon      = 'Import-Module Terminal-Icons'
}

function evalx
{
  $commands = $_EVALX_COMMANDS.Keys | fzf --multi
  foreach ($key in $commands)
  {
    Invoke-Expression $_EVALX_COMMANDS[$key]
  }
}


##########################################


# Thefuck
# Invoke-Expression "$(thefuck --alias)"

# Zoxide
Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })

# Fastfetch
fastfetch

Invoke-Expression (&starship init powershell)
  
mise activate pwsh | Out-String | Invoke-Expression
