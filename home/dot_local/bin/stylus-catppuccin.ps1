# Define default values
param(
  [string]$accent_color = "lavender",
  [string]$light_flavor = "latte",
  [string]$dark_flavor = "mocha"
)

$ErrorActionPreference='Stop'

if (!(Get-Command jq -ErrorAction SilentlyContinue))
{
  Write-Error "No jq available!"
  exit 2
}

$URL = "https://github.com/catppuccin/userstyles/releases/download/all-userstyles-export/import.json"
$FILE_DIR = "$HOME/.config/browser-data/stylus"
$FILE_PATH = "$FILE_DIR/catppuccin.json"

# Ensure directory exists
if (!(Test-Path $FILE_DIR))
{
  New-Item -ItemType Directory -Path $FILE_DIR -Force | Out-Null
}

$stylus = (New-Object Net.WebClient).DownloadString($URL)

# Process JSON and save to file
$stylus | jq --arg accent "$accent_color" `
  --arg light "$light_flavor" `
  --arg dark "$dark_flavor" `
  '.[1:].[].usercssData.vars.accentColor.value |= $accent | .[1:].[].usercssData.vars.lightFlavor.value |= $light | .[1:].[].usercssData.vars.darkFlavor.value |= $dark' | Out-File -Encoding utf8 $FILE_PATH
