#!/bin/zsh

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'
BOLD_MAGENTA='\033[1;35m'
BOLD_CYAN='\033[1;36m'
RESET='\033[0m'

# Utility functions
print_header() {
  echo "\n${BOLD_CYAN}==== $1 ====${RESET}"
}

print_subheader() {
  echo "\n${BOLD_MAGENTA}>>> $1 ${RESET}"
}

print_success() {
  echo "${GREEN}✓ $1${RESET}"
}

print_error() {
  echo "${RED}✗ $1${RESET}"
}

print_warning() {
  echo "${YELLOW}! $1${RESET}"
}

print_info() {
  echo "${BLUE}ℹ $1${RESET}"
}

# Start
print_header "STARTING DOTFILES SETUP"

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
    print_info "Stowing $1..."
    # Redirect both stdout and stderr to /dev/null to silence output
    if stow -v -R "$1" > /dev/null 2>&1; then
      print_success "$1 stowed successfully"
    else
      print_error "Failed to stow $1 (exit code: $?)"
    fi
  else
    print_error "Directory $1 not found. Skipping."
  fi
}

# Stow all
print_subheader "Stowing dotfiles"
for dir in "${stow_dirs[@]}"; do
  stow_dir "$dir"
done

# Run scripts within `./scripts` directory and its subdirectories
print_subheader "Running setup scripts"
find_and_run_scripts() {
  local script_dir="$1"
  find "$script_dir" -type f | while read -r script; do
    if [ -f "$script" ]; then
      if [ -x "$script" ]; then
        print_info "Running $script..."
        if . "$script"; then
          print_success "Script $script completed successfully"
        else
          print_error "Script $script failed (exit code: $?)"
        fi
      else
        print_warning "Script $script is not executable. Skipping."
        print_warning "To make it executable, run: chmod +x \"$script\""
      fi
    else
      print_error "File $script is not a regular file. Skipping."
    fi
  done
}

if [ -d "scripts" ]; then
  find_and_run_scripts "scripts"
else
  print_error "'scripts' directory not found."
fi

# Finish
print_header "FINISHED DOTFILES SETUP"
