#!/bin/zsh

# Start
echo "Starting stow setup..."

stow_dirs=(
  "alacritty"
  "cSpell"
  "git"
  "oh-my-posh"
  "ssh"
  "starship"
  "stow"
  "tmux"
  "vscode"
  "wezterm"
  "zed"
  "zellij"
  "zsh"
)

stow_dir() {
  if [ -d "$1" ]; then
    echo "  - Stowing $1..."
    stow -v -R "$1"
  else
    echo "  * Directory $1 not found. Skipping."
  fi
}

# Stow all
echo "- Starting to stow dotfiles..."
for dir in "${stow_dirs[@]}"; do
  stow_dir "$dir"
done
echo "  Finished stowing dotfiles."

# Run scripts within `./scripts` directory
echo "- Running setup scripts..."
for script in scripts/*; do
  if [ -f "$script" ] && [ -x "$script" ]; then
    echo "  - Running $script..."
    . "$script"
  fi
done
echo "  Finished running setup scripts."

# Finish
echo "Finished stow setup."
