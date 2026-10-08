clone

make a dot alias 
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

pull
dot checkout
dot config --local status.showUntrackedFiles no

