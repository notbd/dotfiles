# .zshenv - read by every zsh, including the non-interactive ones coding agents run commands in

# -------- coding agents --------
# The one place that gives coding agents their own Git identity (README "Coding agents").
# It keys on the marker each harness puts in the shells it starts, whatever config folder it
# runs from: Claude Code sets CLAUDECODE, Codex sets CODEX_THREAD_ID. A new harness only needs
# its marker added here. Never key on anything my own terminal could have.
if [[ -n $CLAUDECODE || -n $CODEX_THREAD_ID ]]; then
  # gh and git's HTTPS credential helper use the agent token; ~/.ssh/config and .zshrc see this
  # variable and keep the agent's ssh and gh away from 1Password
  export GH_CONFIG_DIR=$HOME/.config/gh-agent
  export GIT_CONFIG_COUNT=6
  # Sign with the plain agent key, no Touch ID
  export GIT_CONFIG_KEY_0=user.signingkey               GIT_CONFIG_VALUE_0=$HOME/.ssh/agent_signing
  export GIT_CONFIG_KEY_1=gpg.ssh.program               GIT_CONFIG_VALUE_1=/usr/bin/ssh-keygen
  # Fetch and push every GitHub SSH URL over HTTPS with the agent token. The push rules are
  # longer than .gitconfig's pushInsteadOf = git@github.com, so they win
  export GIT_CONFIG_KEY_2=url.https://github.com/.insteadOf     GIT_CONFIG_VALUE_2=git@github.com:
  export GIT_CONFIG_KEY_3=url.https://github.com/.insteadOf     GIT_CONFIG_VALUE_3=ssh://git@github.com/
  export GIT_CONFIG_KEY_4=url.https://github.com/.pushInsteadOf GIT_CONFIG_VALUE_4=git@github.com:
  export GIT_CONFIG_KEY_5=url.https://github.com/.pushInsteadOf GIT_CONFIG_VALUE_5=ssh://git@github.com/
fi
