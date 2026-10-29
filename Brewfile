# Brewfile - what a fresh Mac needs on day one: shell, development, AI tools, work.
# Everything else lives in Brewfile.extra:  brew bundle --file=~/.dotfiles/Brewfile.extra
# Record a new install here with:  brew bundle add <name>  (HOMEBREW_BUNDLE_FILE is set in .zshrc)

# -------- used by the dotfiles --------
brew "bat"
brew "eza"
brew "fd"
brew "fzf"
brew "gh"            # git credential helper
brew "git"
brew "git-delta"     # git pager
brew "starship"
brew "stow"          # link.sh
brew "trash"         # `rm` alias; macOS's own trash rejects rm's flags
brew "zellij"
brew "zoxide"

# -------- development --------
brew "ffmpeg"
brew "fnm"           # Node versions (reads .nvmrc)
brew "imagemagick"
brew "pnpm"
brew "poppler"       # pdftotext, pdftoppm
brew "python"        # /opt/homebrew/bin/python3: Homebrew's current default (3.15), stdlib only
brew "python@3.14"   # ~/.local/bin/python3 with python/python3.txt, and the venvs

# -------- apps --------
cask "1password"
cask "1password-cli"
cask "aside"
cask "chatgpt"       # also hosts a local MCP server and Codex's desktop runtime
cask "claude"
cask "claude-code"
cask "codex"
cask "ghostty"
cask "typeless"
cask "visual-studio-code"
cask "zed"

# -------- work --------
cask "libreoffice"   # soffice: spreadsheet checks
cask "microsoft-excel"
cask "microsoft-powerpoint"
cask "microsoft-word"
cask "onedrive"
cask "wechat"
cask "wechatwork"    # 企业微信

# -------- fonts used by the configs --------
cask "font-geist-mono"                # vscode editor fallback
cask "font-input"                     # vscode editor fallback
cask "font-jetbrains-mono"            # vscode editor fallback
cask "font-jetbrains-mono-nerd-font"  # ghostty, zed terminal
cask "font-mononoki-nerd-font"        # vscode terminal

# -------- by hand (no Homebrew package) --------
# Berkeley Mono: the font zed and vscode use first; download link in 1Password
