$SCOOP_FONTS = @(
  "nerd-fonts/JetBrainsMono-NF",
  "nerd-fonts/Noto-NF"
)

$SCOOP_COMPLETIONS = @(
  "extras/dockercompletion",
  "extras/scoop-completion"
)

$SCOOP_NECESSARYS = @(
  "extras/winrar",
  "main/7zip",
  "main/openssh",
  "main/unrar",
  "main/wget"
  # "main/winget"
  #"extras/windows-terminal",
  #"neorocks-scoop/luarocks" # For nvim lazy, rest.nvim
)

$SCOOP_CODE_EDITORS = @(
  "extras/vscode",
  "extras/windows-terminal",
  "extras/alacritty",
  "main/neovim"
  # "extra/sublime-text"
)

$SCOOP_OFTEN_USE_APPS = @(
  "extras/anydesk",
  "extras/obs-studio",
  "extras/powertoys",
  "extras/vlc",
  "extras/winaero-tweaker",
  "nonportable/parsec-np"
  # "extra/spotify",
  # "extras/everything",
  # "extras/spicetify-themes", 
  # "main/spicetify-cli",
)

$SCOOP_CODING_TOOLS = @(
  "extra/jqp",
  "extras/autohotkey",
  "extras/keyviz",
  "extras/komorebi",
  "extras/lazygit",
  "extras/posh-git"
  "extras/psfzf",
  "extras/psreadline",
  "extras/terminal-icons",
  "main/adb",
  "main/bat",
  "main/bottom",
  "main/delta",
  "main/eza",
  "main/fastfetch",
  "main/fd",
  "main/ffmpeg",
  "main/fzf",
  "main/gh",
  "main/glow",
  "main/goodbyedpi"
  "main/gzip",
  "main/jq",
  "main/lazydocker",
  "main/poppler",
  "main/rclone",
  "main/ripgrep",
  "main/sd",
  "main/starship",
  "main/sudo",
  "main/tldr",
  "main/unar",
  "main/vivetool",
  "main/wakatime-cli",
  "main/xh",
  "main/yazi",
  "main/yq",
  "main/yt-dlp",
  "main/zoxide",
  "sysinternals/whois"
  # "main/actionlint",
  # "main/file", # for yazi, but use in git instead
  # "main/lf",
  # "main/oh-my-posh"
  #"main/gnupg",
  #"main/gpg", # Use default builtin gpg of git
  #"main/grep",
  #"main/sed",
  #"main/touch",
)

$SCOOP_OTHER_APPS = @(
  "extras/winscp",
  "main/openssl",
  "nonportable/k-lite-codec-pack-standard-np",
  "nonportable/winfsp-np" # For rclone
  #"extras/putty",
  #"extras/qbittorrent-enhanced",
  #"extras/v2rayn"
  #"main/uutils-coreutils",
)
$MICROSOFT_STORE_APPS = @(
 "XP8C9QZMS2PC1T" # Brave
)
# $PIP_APPS = @(
#   "thefuck"
#   "yewtube"
# )

Install-Module -Name CompletionPredictor -Repository PSGallery -Force

scoop install $SCOOP_FONTS $SCOOP_COMPLETIONS $SCOOP_NECESSARYS $SCOOP_CODE_EDITORS $SCOOP_OFTEN_USE_APPS $SCOOP_CODING_TOOLS $SCOOP_OTHER_APPS

# Post install script for scoop
#reg import "$env:USERPROFILE\scoop\apps\windows-terminal\current\install-context.reg"
reg import "$env:USERPROFILE\scoop\apps\pwsh\current\install-explorer-context.reg"
reg import "$env:USERPROFILE\scoop\apps\pwsh\current\install-file-context.reg"
reg import "$env:USERPROFILE\scoop\apps\7zip\current\install-context.reg"

# pip install $PIP_APPS

winget install $MICROSOFT_STORE_APPS --accept-source-agreements --accept-package-agreements
