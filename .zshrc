# ── Login banner ────────────────────────────────────────────────────────────
if [[ -o interactive ]]; then
  clear
  cat <<'EOF'

      ██▓███   ██▀███   ██▓ ███▄ ▄███▓▓█████ 
      ▓██░  ██▒▓██ ▒ ██▒▓██▒▓██▒▀█▀ ██▒▓█   ▀ 
      ▓██░ ██▓▒▓██ ░▄█ ▒▒██▒▓██    ▓██░▒███   
      ▒██▄█▓▒ ▒▒██▀▀█▄  ░██░▒██    ▒██ ▒▓█  ▄ 
      ▒██▒ ░  ░░██▓ ▒██▒░██░▒██▒    ░██▒░▒████▒
      ▒▓▒░ ░  ░░ ▒▓ ░▒▓░░▓  ░ ▒░    ░  ░░░ ▒░ ░
      ░▒ ░        ░▒ ░ ▒░ ▒ ░░  ░      ░ ░ ░  ░
      ░░          ░░   ░  ▒ ░░      ░      ░   
                  ░      ░          ░      ░  ░

      Cyber, art, and risk


EOF
loader_width=45
for pct in 0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100; do
  filled=$(( pct * loader_width / 100 ))
  empty=$(( loader_width - filled ))
  bar="$(printf '%*s' "$filled" '' | tr ' ' '#')"
  gap="$(printf '%*s' "$empty" '' | tr ' ' '.')"
  printf "\r\033[K      [%s%s] %3d%%" "$bar" "$gap" "$pct"
  sleep 0.025
done
printf "\n"
  printf "\n      %s\n" ".╩╬╦.."
  printf "\n      %s\n" "Biometric scan passed"
weather_raw="$(curl -fsSL --max-time 2 'wttr.in/?format=%C+%t+%w' 2>/dev/null || true)"
printf "\n      %s @ \033[38;5;245m%s\033[0m" "${weather_raw:-Weather unavailable}" "$(date '+%Y-%m-%d %H:%M:%S')"

printf "\n\n      %s\n" "Recent local additions"

for dir in "$HOME/bin" "$HOME/.local/bin" "$HOME/scripts" "$HOME/Sites/mikeb.work"; do
  [[ -d "$dir" ]] || continue

  recent="$(find "$dir" -maxdepth 1 -type f -mtime -14 -print 2>/dev/null \
    | sed "s#$HOME#~#" \
    | sort \
    | tail -5)"

  [[ -n "$recent" ]] || continue

  printf "\n      \033[38;5;245m%s\033[0m\n" "${dir/#$HOME/~}"
  printf "%s\n" "$recent" | sed 's/^/        /'
done

printf "\n\n\n"
fi

export COPYFILE_DISABLE=1
export EDITOR='nvim'
export VISUAL='nvim'
export HOMEBREW_NO_ENV_HINTS=1
export PATH="/usr/local/opt/openjdk@17/bin:/usr/local/opt/openjdk/bin:$HOME/.local/bin:/usr/local/sbin:$PATH"
export NVM_DIR="$HOME/.nvm"
export AERC_CONFIG="$HOME/Library/Preferences/aerc"

[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && . "$NVM_DIR/bash_completion"

alias at="$HOME/at.sh"
alias br='brew'
alias c='clear'
alias day="$HOME/day.sh"
alias delete='rm -rv'
alias docs='cd "$HOME/Documents"'
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias edit='nvim'
alias ez='${EDITOR:-nvim} ~/.zshrc'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gd='git diff'
alias gp='git push'
alias gs='git status'
alias h='cd ~'
alias http='python3 -m http.server'
alias ip='ipconfig getifaddr en0'
alias jump='popd'           # The "Jump" button
alias jumps='dirs -v'        # See your recent jump points with numbers
alias ls='ls -G'
alias mb='cd "$HOME/Sites/mikeb.work/"'
alias nuke="rm -rf"
alias nv='${EDITOR:-nvim}'
alias nv='nvim'
alias pip='python3 -m pip'
alias re='source ~/.zshrc'
alias rename='mv'
alias scrap='${EDITOR:-nvim} -c "setlocal buftype=nofile bufhidden=wipe noswapfile"'
alias stream='$HOME/stream.sh'

unalias venv 2>/dev/null

venv() {
  [[ -d venv ]] || python3 -m venv venv
  source venv/bin/activate
}

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
autoload -Uz colors && colors
setopt AUTO_CD
setopt AUTO_PUSHD 
setopt PROMPT_SUBST
setopt PUSHD_IGNORE_DUPS
# PROMPT='%F{81}%n@%m%f %F{189}%~%f %F{226}%%%f '
PROMPT=$'\n%F{81}%n@%m %F{189}%3~ %F{226}[%*] %F{118}$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)%f
%F{226}%%%f '


if [[ -z "$TMUX" && "$TERM_PROGRAM" != "vscode" ]]; then
  if tmux has-session -t main 2>/dev/null; then
    exec tmux attach -t main
  else
    exec tmux new-session -s main -n Zsh
  fi
fi

