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
| `ssh` | `.ssh/config`, `.ssh/known_hosts.github`, `.ssh/allowed_signers` | Keys live in 1Password, except the agent signing key (see [Coding agents](#coding-agents)); `link.sh` links its agent socket to `~/.1password/agent.sock`. New hosts go to an untracked `~/.ssh/known_hosts` |
| `ghostty` | `.config/ghostty/config` | Main terminal. Key bindings pair with the `bindkey` lines in `.zshrc` |
| `starship` | `.config/starship/starship.toml` | Prompt |
| `zellij` | `.config/zellij/` | Starts in locked mode: `Ctrl-L` unlocks, `Ctrl-A` enters tmux mode, so neither reaches the shell inside zellij |
| `zed`, `vscode` | editor settings and key bindings | Extensions are not tracked here |

Not packages: `Brewfile` and `Brewfile.extra`; `python/`, frozen requirements for plain `python3` (pinned to 3.14 through `~/.local/bin`) and for each venv `bootstrap.sh` builds; and `migrate/`, kept out of git because it names private folders: `setup-new-mac.sh` copies it from the old Mac.

## Coding agents

Three Git identities, picked by who runs the command. Claude Code and Codex sign, push and run `gh` with their own key and token, no Touch ID. Everything else (the Claude app and T3 Code in the background, my own `git pull`) reads my repos with a read-only token, no Touch ID. My pushes, signatures and `gh` commands still go through 1Password. The agents are told apart by environment variables that only they set. The agent rules live in `~/.claude/docs/code-repo.md`.

| Piece | Where | Notes |
|---|---|---|
| Signing key | `~/.ssh/agent_signing`, `.pub` | A plain key file, not in 1Password. The public key is in `allowed_signers` and on GitHub as the signing key "Agent Signing Key - Joan" |
| GitHub token | `~/.config/gh-agent/hosts.yml` | Fine-grained token "agent - Joan": all repositories; Actions, Contents, Issues, Pull requests, Variables and Workflows read and write; Code quality, Code scanning alerts, Commit statuses, Dependabot alerts, Deployments and Metadata read-only |
| Variables | `env` in `~/.claude/settings.json`, `[shell_environment_policy.set]` in `~/.codex/config.toml` | `GIT_CONFIG_*` switch the signing key and program and send fetches and pushes to `git@github.com:` and `ssh://git@github.com/` over HTTPS; `GH_CONFIG_DIR` points `gh` and the HTTPS credential helper at the token, and the `Match exec` block at the top of `.ssh/config` keeps the agents' ssh away from 1Password |
| Read-only token | `~/.config/gh/hosts.yml` | Fine-grained token "read-only - Joan": all repositories; Actions, Code quality, Code scanning alerts, Commit statuses, Contents, Dependabot alerts, Deployments, Issues, Metadata and Pull requests read-only. `.gitconfig` sends fetches from `git@github.com:notbd/` over HTTPS, where `gh auth git-credential` hands out this token; its `pushInsteadOf = git@github.com` keeps my pushes on SSH and is shorter than the agents' rule on purpose, so theirs wins. Other owners' repos stay on SSH: GitHub has no token that reads them read-only |
| My `gh` | 1Password item "GitHub CLI Token" | Classic token "gh CLI via 1Password - Joan", loaded by the 1Password shell plugin (`~/.config/op/`). `.zshrc` skips the plugin in agent shells. Keep the macOS keychain free of a gh token: with an old token left there (tested 2026-11-01), the agents' `gh` used it instead of the one in `gh-agent` |
| Check | `~/.claude/hooks/agent-git-check.py` | Runs at session start, runs real `git` and `ssh -G` commands for each identity, and speaks up only when something drifted or a token expires within 30 days |

All three tokens expire on 2027-11-01. To renew, press Regenerate on each token's GitHub page, then:

- classic: paste it into the 1Password item
- agent: `pbpaste | GH_CONFIG_DIR=~/.config/gh-agent command gh auth login -h github.com --with-token --insecure-storage`
- read-only: `pbpaste | command gh auth login -h github.com --with-token --insecure-storage`

The last two differ only in `GH_CONFIG_DIR`; the check warns if both directories end up with the same token. `command` skips the 1Password plugin, whose `GH_TOKEN` makes `gh` refuse to log in, and `--insecure-storage` keeps the token out of the keychain entry every config directory shares. `migrate.sh` copies the key, both tokens and the plugin config to a new Mac; `~/.claude` and `~/.codex` come along with the variables.

## License

[WTFPL](http://www.wtfpl.net/about/)
