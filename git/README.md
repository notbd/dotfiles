# Git

Configuration files for Git.

I use separate ssh keys for commit signing and GitHub account authentication purposes.

I also use [1Password](https://developer.1password.com/docs/ssh/) to sync keys across devices, authenticate my git & ssh workflows and handle commit signing.
(This feature makes my life so much easier that I think it should become a standard for all password managers on the market.)

One single key is used to sign all of my git commits since I moved my keys to 1Password, and the corresponding public key is included in the `.gitconfig` file for verifiability.
