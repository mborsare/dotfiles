# Dotfiles
# Written by ai

Stored relative to the home directory. Git metadata lives in `~/.dotfiles`; 
the working tree is `~/`. There is no separate checkout directory and 
no symlink installation step.

## Set up a new machine

Clone the repository as a bare repository:

```sh
git clone --bare git@github.com:mborsare/dotfiles.git "$HOME/.dotfiles"
alias dot='git --git-dir="$HOME/.dotfiles" --work-tree="$HOME"'
dot config --local status.showUntrackedFiles no
dot ls-tree -r --name-only HEAD
```

Review the file list before applying it. Existing configurations can differ
between machines, especially macOS and Omarchy Linux. Back up any existing
files that would be replaced, keeping their paths relative to `~/`, then run:

```sh
dot checkout
dot status
```

If checkout reports that untracked files would be overwritten, move those
specific files into your backup and retry. Avoid a forced checkout: it can
discard local configuration. Preserve machine-specific settings and merge
them into the checked-out files as needed.

Add the `dot` alias above to your shell configuration if it is not already
present. This setup already defines it in `.zshrc`; Bash users can add it to
`.bashrc`. Open a new shell to load it.

## Everyday use

Use `dot` for this repository, from any directory:

```sh
dot status
dot diff
dot add -- "$HOME/.zshrc"
dot commit -m "Update shell configuration"
```

Stage specific files. Avoid `dot add .` or `dot add -A` from the home
directory: they can accidentally include private files or unrelated data.
Hiding untracked files in status does not prevent Git from adding them.

Inspect incoming changes before updating:

```sh
dot fetch origin
dot diff HEAD..@{upstream}
dot pull --ff-only
```

Commit or back up local edits first. A fast-forward-only pull stops if the
branches have diverged instead of creating an unexpected merge.

Push only when you intend to publish local commits:

```sh
dot push
```

## Omarchy

Keep personal overrides in `~/.config/`; packaged files under
`/usr/share/omarchy/` are managed by Omarchy. After changing Hyprland config,
validate it from the desktop session:

```sh
hyprctl reload
hyprctl configerrors
```

## Recovery

If `dot` is unavailable in a new shell, define the alias again or invoke Git
directly:

```sh
git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status
```

If `~/.dotfiles` is missing, clone it again. Existing files in `~/` remain
in place until checkout; inspect and back them up before applying the repo.
