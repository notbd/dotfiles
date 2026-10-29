#!/bin/zsh
#
# setup-new-mac.sh - one command on a brand-new Mac that uses the old Mac's account name:
#
#   /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/notbd/dotfiles/main/setup-new-mac.sh)" _ <old-mac>.local
#
# First, on the OLD Mac: System Settings > General > Sharing > Remote Login on, with
# "Allow full disk access for remote users" ticked; on power, lid open, same network.
# Do not open the Claude app on this Mac until this script is finished.
#
#   1. questions first: this Mac's password, Documents access, the old Mac's password
#   2. copy the data from the old Mac in the background (migrate.sh, fetched from the old Mac)
#   3. bootstrap.sh: Homebrew, apps, dotfiles, Node, Python
#   4. wait for the copy, tidy, compare
#   5. guided sign-ins
#
# Safe to re-run: every step picks up where it stopped.

emulate -R zsh
setopt pipe_fail no_unset

say()   { printf '\n\033[1;36m==== %s ====\033[0m\n' "$*"; }
ok()    { printf '\033[0;32m✓   %s\033[0m\n' "$*"; }
warn()  { printf '\033[0;33m!   %s\033[0m\n' "$*" >&2; }
die()   { printf '\033[0;31mx   %s\033[0m\n' "$*" >&2; exit 1; }
pause() { printf '    %s  [Return] ' "$*"; read -r </dev/tty; }

OLD="${1:-}"
DOTFILES="$HOME/.dotfiles"
STAGE="$HOME/.local/share/mac-migration"
SSH_SOCK="${TMPDIR:-/tmp}/mac-migration-ssh.sock"
SSH_OPTS=(-o ControlPath="$SSH_SOCK" -o BatchMode=yes -o UserKnownHostsFile="$STAGE/known_hosts")
PULL_PID=""

[[ -n "$OLD" ]] || die 'Usage: /bin/zsh -c "$(curl -fsSL .../setup-new-mac.sh)" _ <old-mac>.local'
[[ "$(uname -m)" == arm64 ]] || die "This script expects an Apple Silicon Mac."
pgrep -qf "/Applications/Claude.app/" && die "Quit the Claude app first (Cmd-Q); its session list is about to be copied."
mkdir -p "$STAGE/logs"
# on any exit: stop a copy still running, close the connection to the old Mac
trap '[[ -n $PULL_PID ]] && kill $PULL_PID 2>/dev/null; ssh "${SSH_OPTS[@]}" -O exit "$USER@$OLD" 2>/dev/null' EXIT
trap 'exit 130' INT TERM

# ---------------------------------------------------------------- 1. questions
say "1/5  Questions (about a minute; afterwards it runs by itself)"
print "This Mac's login password (to install apps):"
sudo -v </dev/tty || die "sudo failed"
( while kill -0 $$ 2>/dev/null; do sudo -n true; sleep 50; done ) 2>/dev/null &
caffeinate -dimsu -w $$ &

print "If macOS asks whether Terminal may access your Documents folder, click Allow."
command ls ~/Documents >/dev/null 2>&1

nc -z -G 5 "$OLD" 22 2>/dev/null || die "Cannot reach $OLD. On the old Mac turn on Remote Login (see the top of this script)."
if ! ssh "${SSH_OPTS[@]}" -O check "$USER@$OLD" 2>/dev/null; then
  print "The OLD Mac's login password (to copy your data):"
  ssh -o ControlMaster=auto -o ControlPersist=2h -o ControlPath="$SSH_SOCK" \
      -o ServerAliveInterval=15 -o ServerAliveCountMax=8 -o IdentityAgent=none \
      -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile="$STAGE/known_hosts" \
      -fN "$USER@$OLD" </dev/tty || die "Could not log in to $OLD as $USER"
fi
ssh "${SSH_OPTS[@]}" "$USER@$OLD" 'cat ~/.dotfiles/migrate/migrate.sh' >"$STAGE/migrate.sh" && [[ -s $STAGE/migrate.sh ]] \
  || die "Could not fetch ~/.dotfiles/migrate/migrate.sh from $OLD"
# hold one session open until this script exits: keeps the connection alive and the old Mac awake
exec {HOLD}> >(ssh "${SSH_OPTS[@]}" "$USER@$OLD" 'exec caffeinate -is cat >/dev/null' 2>/dev/null)

# ---------------------------------------------------------------- 2. copy in the background
say "2/5  Copying data from $OLD in the background"
PULL_OUT="$STAGE/logs/$(date +%Y%m%d-%H%M%S)-setup-pull.out"
print "    progress: tail -f $PULL_OUT"
zsh "$STAGE/migrate.sh" pull "$OLD" >"$PULL_OUT" 2>&1 &
PULL_PID=$!

# ---------------------------------------------------------------- 3. apps and settings
say "3/5  Homebrew, dotfiles, apps"
if [[ ! -x /opt/homebrew/bin/brew ]]; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null \
    || die "Homebrew install failed"   # </dev/null: fail instead of waiting at a "press any key" fallback
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
xcode-select -p >/dev/null 2>&1 || die "Command Line Tools missing: run xcode-select --install, then this script again"
if [[ -d $DOTFILES/.git ]]; then
  git -C "$DOTFILES" pull --ff-only -q || warn "git pull failed; using ~/.dotfiles as it is"
else
  git clone -q https://github.com/notbd/dotfiles.git "$DOTFILES" || die "git clone failed"
fi
mkdir -p "$DOTFILES/migrate" && cp "$STAGE/migrate.sh" "$DOTFILES/migrate/"
zsh "$DOTFILES/bootstrap.sh" </dev/tty; BOOT_RC=$?

# ---------------------------------------------------------------- 4. wait for the copy
say "4/5  Waiting for the data copy"
wait $PULL_PID; PULL_RC=$?; PULL_PID=""
grep -v '^    [^ ]' "$PULL_OUT"                         # all but the per-item progress lines
cp -pn ~/.zsh_history "$STAGE/zsh_history.from-old-mac" 2>/dev/null   # first run only; see the last step
zsh "$DOTFILES/migrate/migrate.sh" finish
zsh "$DOTFILES/migrate/migrate.sh" verify "$OLD"; VERIFY_RC=$?

# ---------------------------------------------------------------- 5. sign-ins
say "5/5  Sign-ins (each app opens; sign in, then press Return here)"
open -a 1Password; pause "1Password: sign in, then Settings > Developer > turn on 'Use the SSH Agent'."
[[ "$(ssh -T -o BatchMode=yes git@github.com 2>&1)" == *successfully* ]] && ok "GitHub over SSH works" \
  || warn "GitHub over SSH does not work yet: check 1Password's SSH agent"
open -a Claude;   pause "Claude: sign in. Your old sessions should be in the sidebar."
open -a ChatGPT;  pause "ChatGPT: sign in (a local MCP server runs inside it)."
open -a Aside;    pause "Aside: sign in to your browser profile."
zsh "$DOTFILES/link.sh" >/dev/null                        # links the aside CLI, now that Aside has run
gh auth status >/dev/null 2>&1 || gh auth login -h github.com -p ssh --skip-ssh-key --web </dev/tty
codex login status >/dev/null 2>&1 || codex login </dev/tty


say "Done"
(( BOOT_RC ))   && warn "bootstrap.sh reported problems: run  zsh ~/.dotfiles/bootstrap.sh  again"
(( PULL_RC ))   && warn "The copy is not complete: run  zsh ~/.dotfiles/migrate/migrate.sh pull $OLD  again"
(( VERIFY_RC )) && warn "Some files still differ (see the comparison above)"
cat <<EOF
Sign in when you first use them: WeChat, 企业微信, Typeless, Office, OneDrive.
By hand: Berkeley Mono font (download link in 1Password).
Optional apps: brew bundle --file=~/.dotfiles/Brewfile.extra

When you stop using the old Mac:
  old Mac:   zsh ~/.dotfiles/migrate/migrate.sh retire
  this Mac:  zsh ~/.dotfiles/migrate/migrate.sh pull $OLD     (the last changes)
             zsh ~/.dotfiles/migrate/migrate.sh activate

Last step: type  exec zsh -l  in this window before closing it. This window started before your
zsh settings existed; closing it the normal way would trim ~/.zsh_history to 1000 lines.
(A copy is kept at ${STAGE/#$HOME/~}/zsh_history.from-old-mac.)
EOF
exit $(( BOOT_RC || PULL_RC || VERIFY_RC ))
