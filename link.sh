#!/bin/zsh
#
# link.sh - link every package into $HOME with GNU Stow (settings in .stowrc), then the
# 1Password SSH agent socket and the tools in ~/.local/bin. Safe to re-run. A real file
# sitting where a link should go (say a ~/.zshrc written by an installer) is first moved
# to ~/.dotfiles-backup/<time>/.

emulate -R zsh
setopt pipe_fail no_unset

say()  { printf '\n\033[1;36m==== %s ====\033[0m\n' "$*"; }
ok()   { printf '\033[0;32m✓   %s\033[0m\n' "$*"; }
warn() { printf '\033[0;33m!   %s\033[0m\n' "$*" >&2; }
fail() { warn "$*"; FAILED+=("$*"); }

DOTFILES="${ZSH_SCRIPT:A:h}"
PACKAGES=(ghostty git ssh starship vscode zed zellij zsh)
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
FAILED=()
cd "$DOTFILES" || exit 1

move_aside() {      # files and foreign links in the way of $1's links (not those already resolving into the repo)
  local file rel target
  for file in $1/**/*(.DN); do
    rel="${file#$1/}"; target="$HOME/$rel"
    [[ "${rel:t}" == .DS_Store || ( ! -e "$target" && ! -L "$target" ) || "${target:A}" == "${file:A}" ]] && continue
    mkdir -p "$BACKUP/${rel:h}" && mv "$target" "$BACKUP/$rel" && warn "moved ~/$rel to $BACKUP/"
  done
}

say "Linking dotfiles"
for pkg in $PACKAGES; do
  move_aside "$pkg"
  if stow --restow "$pkg"; then ok "$pkg"; else fail "stow $pkg"; fi
done

# ~/.ssh/config and SSH_AUTH_SOCK point here; the socket exists once 1Password's SSH agent is on
mkdir -p ~/.1password
ln -sfn ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ~/.1password/agent.sock \
  && ok "1Password SSH agent" || fail "1Password SSH agent link"

# ~/.local/bin, ahead of Homebrew on PATH: tools from outside Homebrew, linked once they exist,
# and python3 / pip3 pinned to 3.14 (Homebrew's own python3 moves on with new releases)
mkdir -p ~/.local/bin
for tool in ~/.agent-reach-venv/bin/{agent-reach,yt-dlp}(N) ~/".aside/cli/Aside CLI.app/Contents/MacOS/aside"(N); do
  ln -sf "$tool" ~/.local/bin/ || fail "~/.local/bin/${tool:t}"
done
for py in python3 pip3; do
  [[ -x /opt/homebrew/bin/$py.14 ]] && { ln -sf /opt/homebrew/bin/$py.14 ~/.local/bin/$py || fail "~/.local/bin/$py" }
done

(( ${#FAILED} == 0 ))
