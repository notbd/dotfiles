# 1Password

[This page](https://developer.1password.com/docs/ssh/get-started/#step-3-turn-on-the-1password-ssh-agent) from 1Password Developer's documentation explains how to set up and turn on the 1Password SSH agent.

- In this dotfiles repository, the setup is taken care of and should not require manual intervention.

- The `~/.ssh/config` file and `~/.zshrc` already contain the necessary configurations for `IdentityAgent` and `$SSH_AUTH_SOCK`.

- The additional command needed to create a symbolic link to the 1Password agent socket file is also included in the stow script and should run during the stow setup.

Below is the command for reference, in case anything goes wrong and the symbolic link needs to be created manually.

```shell
mkdir -p ~/.1password && ln -s ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ~/.1password/agent.sock
```
