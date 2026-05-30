# ── Locale & Environment ────────────────────────────────────────────────────
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export COPYFILE_DISABLE=1
export EDITOR='nvim'
export VISUAL='nvim'
export HOMEBREW_NO_ENV_HINTS=1
export NVM_DIR="$HOME/.nvm"

# Shared paths first.
export PATH="$HOME/.local/bin:/usr/local/sbin:$PATH"

# macOS-only paths.
if [[ "$OSTYPE" == darwin* ]]; then
  export PATH="/usr/local/opt/openjdk@17/bin:/usr/local/opt/openjdk/bin:$PATH"
  export AERC_CONFIG="$HOME/Library/Preferences/aerc"
fi

# Linux-only paths/config.
if [[ "$OSTYPE" == linux* ]]; then
  export AERC_CONFIG="$HOME/.config/aerc"
fi

# ── Login banner ────────────────────────────────────────────────────────────
if [[ -o interactive ]]; then
  clear

  # 1. Curated "Safe" Palette
  # Excludes vibrating reds and deep blues for better legibility on black.
  prime_colors=(39 45 51 81 87 118 121 159 214 208 141)
  RANDOM_COL=$prime_colors[$(( 1 + RANDOM % $#prime_colors ))]

  # Start the random theme color.
  printf "\033[38;5;${RANDOM_COL}m"

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

  # Progress bar.
  loader_width=45
  for pct in 0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100; do
    filled=$(( pct * loader_width / 100 ))
    empty=$(( loader_width - filled ))
    bar="$(printf '\033[38;5;%sm%*s\033[0m' "$RANDOM_COL" "$filled" '' | tr ' ' '#')"
    gap="$(printf '%*s' "$empty" '' | tr ' ' '.')"
    printf "\r\033[K      [%s%s] %3d%%" "$bar" "$gap" "$pct"
    sleep 0.02
  done

  printf "\n\n"

  bio_msg="Access granted. Have a nice day"
  yellow="\033[38;5;226m"
  reset="\033[0m"

  for i in {0..6}; do
    indent=$(printf '%*s' "$i" '')
    printf "\r\033[K%s%b%s%b" "$indent" "$yellow" "$bio_msg" "$reset"
    sleep 0.015
  done

  sleep 0.1
  printf "\r\033[K      %b%s%b" "$reset" "$bio_msg" "$reset"
  sleep 0.1
  printf "\r\033[K      %b%s%b\n" "$yellow" "$bio_msg" "$reset"

  weather_raw="$(curl -fsSL --max-time 2 'wttr.in/?format=%C+%t+%w' 2>/dev/null || true)"
  printf "\n      \033[38;5;${RANDOM_COL}m%s\033[0m @ \033[38;5;245m%s\033[0m" "${weather_raw:-Weather unavailable}" "$(date '+%Y-%m-%d %H:%M:%S')"
  printf "\n\n      \033[38;5;${RANDOM_COL}m%s\033[0m\n" "Hot files"

  for dir in "$HOME" "$HOME/bin" "$HOME/.local/bin" "$HOME/scripts" "$HOME/Sites/mikeb.work"; do
    [[ -d "$dir" ]] || continue
    recent="$(find "$dir" -maxdepth 1 -type f -mtime -14 -print 2>/dev/null | sed "s#$HOME#~#" | sort | tail -5)"
    [[ -n "$recent" ]] || continue

    printf "\n      \033[38;5;${RANDOM_COL}m%s\033[0m\n" "${dir/#$HOME/~}"
    printf "%s\n" "$recent" | sed 's/^/        /'
  done

  printf "\n\n\n"
  printf "\033[0m"
fi

# ── Aliases ──────────────────────────────────────────────────────────────────
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && . "$NVM_DIR/bash_completion"

alias at="$HOME/at.sh"
alias c='clear'
alias day="$HOME/day.sh"
alias delete='rm -rv'
alias docs='cd "$HOME/Documents"'
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias edit='nvim'
alias exe='$HOME/.local/bin/'
alias ez='${EDITOR:-nvim} ~/.zshrc'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gd='git diff'
alias gp='git push'
alias gs='git status'
alias h='cd ~'
alias http='python3 -m http.server'
alias ip='dig +short myip.opendns.com @resolver1.opendns.com'
alias jump='popd'
alias jumps='dirs -v'
alias mb='cd "$HOME/Sites/mikeb.work/"'
alias mute='sonos mute'
alias nuke='rm -rf'
alias nv='nvim'
alias oil="$HOME/oil.sh"
alias pip='python3 -m pip'
alias re='source ~/.zshrc'
alias rename='mv'
alias rithmic='wine "$HOME/.wine/drive_c/Program Files (x86)/Rithmic/Rithmic Trader Pro/Rithmic Trader Pro.exe"'
alias scrap='${EDITOR:-nvim} -c "setlocal buftype=nofile bufhidden=wipe noswapfile"'
alias stream='$HOME/stream.sh'

# OS-specific aliases.
if [[ "$OSTYPE" == darwin* ]]; then
  alias br='brew'
  alias ls='ls -G'
  alias iplocal='ipconfig getifaddr en0'
elif [[ "$OSTYPE" == linux* ]]; then
  alias ls='ls --color=auto'
  alias iplocal="hostname -I | awk '{print \$1}'"
fi

unalias venv 2>/dev/null
venv() {
  [[ -d venv ]] || python3 -m venv venv
  source venv/bin/activate
}

# ── Zsh Settings & Completion ────────────────────────────────────────────────
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# Linux color support for completions.
if [[ "$OSTYPE" == linux* ]] && command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b)"
fi

autoload -Uz colors && colors
autoload -Uz compinit

# Needed for menu-select tab completion.
zmodload zsh/complist 2>/dev/null

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# -u ignores insecure completion dir warnings on your own box.
compinit -u

# Make Tab complete.
bindkey '^I' expand-or-complete

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PROMPT_SUBST
setopt PUSHD_IGNORE_DUPS

# ── Prompt helpers ───────────────────────────────────────────────────────────
battery_pct() {
  if [[ "$OSTYPE" == darwin* ]]; then
    pmset -g batt 2>/dev/null | grep -Eo "[0-9]+%" | head -1 | cut -d% -f1
  elif [[ "$OSTYPE" == linux* ]]; then
    for bat in /sys/class/power_supply/BAT*/capacity; do
      [[ -f "$bat" ]] && cat "$bat" && return
    done
  fi
}

PROMPT=$'\n%F{$RANDOM_COL}%n@%m%f %F{189}%~ %F{242}[%*]%f %F{242}$(battery_pct)%f\n%F{242}%%%f '

# ── Tmux Auto-Attach ─────────────────────────────────────────────────────────
if [[ -z "$TMUX" && "$TERM_PROGRAM" != "vscode" ]]; then
  if tmux has-session -t main 2>/dev/null; then
    exec tmux attach -t main
  else
    exec tmux new-session -s main -n Zsh
  fi
fi
