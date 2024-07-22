#!/bin/zsh

stow_dirs=(
  "alacritty"
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
    echo "Stowing $1..."
    stow -v -R "$1"
  else
    echo "Directory $1 not found. Skipping."
  fi
}

# Main script
echo "Starting to stow dotfiles..."

for dir in "${stow_dirs[@]}"; do
  stow_dir "$dir"
done

echo "Finished stowing dotfiles."
