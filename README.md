# Dotfiles

My home directory is the working tree. Git lives in `~/.local/share/dotfiles.git`.

## Setup

```sh
git clone --bare git@github.com:mborsare/dotfiles.git ~/.local/share/dotfiles.git
alias dot='git --git-dir="$HOME/.local/share/dotfiles.git" --work-tree="$HOME"'
dot config status.showUntrackedFiles no
dot checkout
```

If checkout complains about existing files, back them up and retry. Don't force it.

The `dot` alias is already in `.zshrc`.

## Daily use

```sh
dot status
dot diff
dot add ~/.zshrc
dot commit -m "Update config"
dot push
```

To update another machine:

```sh
dot pull --ff-only
```

Only stage files you intend to track. Never `dot add .` from home.
