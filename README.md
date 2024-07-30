# Dotfiles

My dotfiles.

This repo has one folder for each application that needs to be configured. I am currently using [GNU Stow](https://www.gnu.org/software/stow/) to symlink the files in the folder to the appropriate location in the home directory.

## Setup

```shell
git clone git@github.com:notbd/dotfiles.git
# or clone without git history using `degit notbd/dotfiles dotfiles`
cd dotfiles
. dotfiles-setup.sh
```

## Future plans

- [x] Add a script to stow all the applications.
- [x] Add a script to run additional setup commands for each application.
- [ ] Add a script to setup homebrew and install all the applications.

## License

[WTFPL](http://www.wtfpl.net/about/)
