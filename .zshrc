
# ── Locale & Environment ─────────────────────────────────────────────────────
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export COPYFILE_DISABLE=1
export EDITOR='nvim'
export VISUAL='nvim'
export HOMEBREW_NO_ENV_HINTS=1
export NVM_DIR="$HOME/.nvm"

# Shared paths first.
export PATH="$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:$PATH"

# macOS-only paths.
if [[ "$OSTYPE" == darwin* ]]; then
  export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
  export PATH="/usr/local/opt/openjdk@17/bin:/usr/local/opt/openjdk/bin:$PATH"
  export AERC_CONFIG="$HOME/Library/Preferences/aerc"
fi

# ── Zsh Behavior ─────────────────────────────────────────────────────────────
setopt INTERACTIVE_COMMENTS
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PROMPT_SUBST
setopt PUSHD_IGNORE_DUPS

# ── File Colors ──────────────────────────────────────────────────────────────
export CLICOLOR=1

if [[ "$OSTYPE" == darwin* ]]; then
  lsc_pool=(C D E F G H)
  LS_DIR_COL=${lsc_pool[$(( 1 + RANDOM % $#lsc_pool ))]}
  LS_LINK_COL=${lsc_pool[$(( 1 + RANDOM % $#lsc_pool ))]}
  LS_EXE_COL=${lsc_pool[$(( 1 + RANDOM % $#lsc_pool ))]}

  export LSCOLORS="${LS_DIR_COL}x${LS_LINK_COL}xFxDx${LS_EXE_COL}xEgEdxbxgxcxd"

elif [[ "$OSTYPE" == linux* ]]; then
  file_pool=(31 32 33 34 35 36 37 91 92 93 94 95 96)
  LS_DIR_COL=${file_pool[$(( 1 + RANDOM % $#file_pool ))]}
  LS_LINK_COL=${file_pool[$(( 1 + RANDOM % $#file_pool ))]}
  LS_EXE_COL=${file_pool[$(( 1 + RANDOM % $#file_pool ))]}
  LS_FILE_COL=${file_pool[$(( 1 + RANDOM % $#file_pool ))]}

  export LS_COLORS="di=1;${LS_DIR_COL}:ln=1;${LS_LINK_COL}:ex=1;${LS_EXE_COL}:*.txt=${LS_FILE_COL}:*.md=${LS_FILE_COL}:*.sh=1;${LS_EXE_COL}:*.db=${LS_FILE_COL}:*.toml=${LS_FILE_COL}:*.json=${LS_FILE_COL}:*.html=${LS_FILE_COL}"
fi

# ── Tmux Auto-Attach ─────────────────────────────────────────────────────────
# Attach to main if present; otherwise create it.
# Never start nested sessions, and don't fail when tmux is absent.

if [[ -o interactive && -z "$TMUX" && "$TERM_PROGRAM" != "vscode" ]] &&
   command -v tmux >/dev/null 2>&1; then
  if tmux has-session -t main 2>/dev/null; then
    exec tmux attach-session -t main
  else
    exec tmux new-session -s main -n Zsh
  fi
fi

# ── Login Banner ─────────────────────────────────────────────────────────────
if [[ -o interactive ]]; then
  if [[ -x "$HOME/.config/alacritty/random-palette.zsh" ]]; then
    "$HOME/.config/alacritty/random-palette.zsh"
  fi

  clear

  prime_colors=(39 45 51 81 87 118 121 159 214 208 141)
  RANDOM_COL=${prime_colors[$(( 1 + RANDOM % $#prime_colors ))]}

  # Glitch the PRIME logo, then settle on the original artwork.
  () {
    local logo_text
    local -a logo_rows glitch_chars
    local frame row col span tint line noise
    logo_text=$(cat <<'EOF'
██▓███   ██▀███   ██▓ ███▄ ▄███▓▓█████ 
▓██░  ██▒▓██ ▒ ██▒▓██▒▓██▒▀█▀ ██▒▓█   ▀ 
▓██░ ██▓▒▓██ ░▄█ ▒▒██▒▓██    ▓██░▒███   
▒██▄█▓▒ ▒▒██▀▀█▄  ░██░▒██    ▒██ ▒▓█  ▄ 
▒██▒ ░  ░░██▓ ▒██▒░██░▒██▒   ░██▒░▒████▒
▒▓▒░ ░  ░░ ▒▓ ░▒▓░░▓  ░ ▒░   ░  ░░░ ▒░ ░
░▒ ░       ░▒ ░ ▒░ ▒ ░░  ░      ░ ░ ░  ░
░░         ░░   ░  ▒ ░░      ░      ░   
            ░      ░         ░      ░  ░
EOF
)
    logo_rows=("${(@f)logo_text}")
    glitch_chars=('░' '▒' '▓' '█' '/' '_' '+')
    printf '\n\n'

    # Redraw only when the terminal has enough room for the whole logo.
    if [[ -t 1 && "$TERM" != dumb ]] && (( COLUMNS >= 48 && LINES >= 16 )); then
      for frame in {1..12}; do
        for row in {1..9}; do
          line=${logo_rows[$row]}
          tint=$RANDOM_COL
          if (( RANDOM % 3 == 0 )); then
            if (( RANDOM % 3 == 0 )); then
              noise='mjb'
              span=3
            else
              span=$(( 1 + RANDOM % 4 ))
              noise=${glitch_chars[$(( 1 + RANDOM % $#glitch_chars ))]}
              noise=${(l:$span::$noise:)}
            fi
            col=$(( 1 + RANDOM % (${#line} - span + 1) ))
            line[$col,$(( col + span - 1 ))]=$noise
            tint=${prime_colors[$(( 1 + RANDOM % $#prime_colors ))]}
          fi
          printf '\r\033[2K\033[38;5;%sm%s\033[0m\n' "$tint" "$line"
        done
        sleep 0.04
        printf '\033[9A'
      done
    fi

    for line in "${logo_rows[@]}"; do
      printf '\r\033[2K\033[38;5;%sm%s\033[0m\n' "$RANDOM_COL" "$line"
    done
    printf '      Cyber, art, and risk\n\n'
  }

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

  printf "\n      \033[38;5;${RANDOM_COL}m%s\033[0m @ \033[38;5;245m%s\033[0m" \
    "${weather_raw:-Weather unavailable}" \
    "$(date '+%Y-%m-%d %H:%M:%S')"

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

# ── NVM ──────────────────────────────────────────────────────────────────────
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && . "$NVM_DIR/bash_completion"

# ── Aliases ──────────────────────────────────────────────────────────────────
alias at="$HOME/at.sh"
alias c='clear'
alias bins='cd "$HOME/.local/bin"'
alias day="$HOME/day.sh"
alias delete='rm -rv'
alias docs='cd "$HOME/Documents"'
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias ds='dot status -uno'
alias drives='lsblk -f'
alias edit='nvim'
alias exe='$HOME/.local/bin/'
alias ez='${EDITOR:-nvim} ~/.zshrc'
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gd='git diff'
alias gp='git push'
alias gs='git status'
alias h='cd ~'
alias httpsnake='python3 -m http.server'
alias httpgolf='caddy file-server --listen :8080 --browse'
alias ip='dig +short myip.opendns.com @resolver1.opendns.com'
alias jump='popd'
alias jumps='dirs -v'
alias mb='cd "$HOME/Sites/mikeb.work/"'
alias mute='sonos mute'
alias nuke='rm -rf'
alias nv='nvim'
alias oil="$HOME/oil.sh"
alias pip='python3 -m pip'
alias primedrive='/Volumes/PRIME/'
alias re='source ~/.zshrc'
alias rename='mv'
alias rithmic='wine "$HOME/.wine/drive_c/Program Files (x86)/Rithmic/Rithmic Trader Pro/Rithmic Trader Pro.exe"'
alias scrap='${EDITOR:-nvim} -c "setlocal buftype=nofile bufhidden=wipe noswapfile"'
alias stream='$HOME/stream.sh'
unalias torrent 2>/dev/null
function torrent {
  command /opt/local/bin/aria2c "$@"
}
alias x='exit'

# OS-specific aliases.
if [[ "$OSTYPE" == darwin* ]]; then
  alias br='brew'
  alias ls='ls -G'
  alias ll='ls -lahG'
  alias la='ls -laG'
  alias iplocal='ipconfig getifaddr en0'

elif [[ "$OSTYPE" == linux* ]]; then
  alias ls='ls --color=auto'
  alias ll='ls -lah --color=auto'
  alias la='ls -la --color=auto'
  alias iplocal="hostname -I | awk '{print \$1}'"
fi

# Eza overrides native ls aliases when installed.
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -lah --icons=auto --group-directories-first --git'
  alias la='eza -a --icons=auto --group-directories-first'
  alias lt='eza --tree --level=2 --icons=auto'
fi

unalias venv 2>/dev/null

venv() {
  [[ -d venv ]] || python3 -m venv venv
  source venv/bin/activate
}

# ── Zsh Settings & Completion ────────────────────────────────────────────────
autoload -Uz colors && colors
autoload -Uz compinit
autoload -Uz vcs_info
autoload -Uz add-zsh-hook

zmodload zsh/complist 2>/dev/null

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' %F{118} %b%f'
zstyle ':vcs_info:git:*' actionformats ' %F{214} %b|%a%f'

_prime_vcs_precmd() {
  vcs_info
}

add-zsh-hook precmd _prime_vcs_precmd

compinit -u
bindkey '^I' expand-or-complete

# ── Prompt Helpers ───────────────────────────────────────────────────────────
battery_pct() {
  if [[ "$OSTYPE" == darwin* ]]; then
    pmset -g batt 2>/dev/null | grep -Eo "[0-9]+%" | head -1 | cut -d% -f1
  elif [[ "$OSTYPE" == linux* ]]; then
    for bat in /sys/class/power_supply/BAT*/capacity; do
      [[ -f "$bat" ]] && cat "$bat" && return
    done
  fi
}

# ── PRIME Prompt ─────────────────────────────────────────────────────────────
PROMPT=$'\n%F{$RANDOM_COL}%n@%m%f %F{189}%~${vcs_info_msg_0_} %F{242}[%*]%f %F{242}$(battery_pct)%f\n%F{242}%%%f '
