# Dotfiles

My macOS setup. The folders under [Packages](#packages) are [GNU Stow](https://www.gnu.org/software/stow/) packages linked into `$HOME`. `.stowrc` makes stow link files, never whole folders, so files an app creates stay out of this repo; edits an app makes to a linked file land here and show up in `git diff`.

## New Mac

Needs an Apple Silicon Mac with the same account name as the old one, both on the same network. On the old Mac: System Settings > General > Sharing > Remote Login on, with "Allow full disk access for remote users" ticked; on power, lid open. On the new Mac, before opening any app:

```shell
/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/notbd/dotfiles/main/setup-new-mac.sh)" _ <old-mac>.local
```

It asks for both Macs' passwords up front, copies the data from the old Mac in the background while it installs everything, compares the copy, then walks through the sign-ins. The Berkeley Mono font is installed by hand (see the end of `Brewfile`).

Other entry points, all safe to re-run:

| Command | Does |
|---|---|
| `zsh ~/.dotfiles/bootstrap.sh` | Homebrew, `Brewfile`, `link.sh`, Node (fnm), pnpm globals, python3 packages and venvs |
| `zsh ~/.dotfiles/link.sh` | Links only, plus `~/.local/bin` tools. Real files in the way go to `~/.dotfiles-backup/<time>/` |
| `brew bundle --file=~/.dotfiles/Brewfile.extra` | Optional apps |

## Packages

| Package | Links | Notes |
|---|---|---|
| `zsh` | `.zshrc`, `.zprofile`, `.config/zsh/aliases.zsh` | zinit plugins, fzf, zoxide, fnm, starship. No alias shadows a standard command except `rm`, which moves to the Trash |
| `git` | `.gitconfig`, `.config/git/ignore` | Commits are signed with an SSH key kept in 1Password; signing and GitHub sign-in use separate keys |
| `ssh` | `.ssh/config`, `.ssh/known_hosts.github`, `.ssh/allowed_signers` | Keys live in 1Password; `link.sh` links its agent socket to `~/.1password/agent.sock`. New hosts go to an untracked `~/.ssh/known_hosts` |
| `ghostty` | `.config/ghostty/config` | Main terminal. Key bindings pair with the `bindkey` lines in `.zshrc` |
| `starship` | `.config/starship/starship.toml` | Prompt |
| `zellij` | `.config/zellij/` | Starts in locked mode: `Ctrl-L` unlocks, `Ctrl-A` enters tmux mode, so neither reaches the shell inside zellij |
| `zed`, `vscode` | editor settings and key bindings | Extensions are not tracked here |

Not packages: `Brewfile` and `Brewfile.extra`; `python/`, frozen requirements for plain `python3` (pinned to 3.14 through `~/.local/bin`) and for each venv `bootstrap.sh` builds; and `migrate/`, kept out of git because it names private folders: `setup-new-mac.sh` copies it from the old Mac.

## License

[WTFPL](http://www.wtfpl.net/about/)
