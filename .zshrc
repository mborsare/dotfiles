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
alias day="$HOME/day.sh"
alias delete='rm -rv'
alias docs='cd "$HOME/Documents"'
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias edit='nvim'
alias mp3='$HOME/.local/bin/mp3'
alias ip='ipconfig getifaddr en0'
alias nv='nvim'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gd='git diff'
alias gp='git push'
alias gs='git status'
alias h='cd ~'
alias http='python3 -m http.server'
alias ls='ls -G'
alias mb='cd "$HOME/Sites/mikeb.work/"'
alias nuke="rm -rf"
alias nv='${EDITOR:-nvim}'
alias pip='python3 -m pip'
alias rc='${EDITOR:-nvim} ~/.zshrc'
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
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
autoload -Uz colors && colors
setopt PROMPT_SUBST
PROMPT='%F{81}%n@%m%f %F{189}%~%f %F{226}%%%f '

if [[ -z "$TMUX" && "$TERM_PROGRAM" != "vscode" ]]; then
  if tmux has-session -t main 2>/dev/null; then
    exec tmux attach -t main
  else
    exec tmux new-session -s main -n Zsh
  fi
fi

up() {
  local input="$1"
  local minutes="${2:-}"
  local chunk_seconds="${3:-60}"
  local warmup_limit=180
  local model="realesr-animevideov3-x4"
  local cache_root="$HOME/.cache/up"

  [[ -z "$input" ]] && { echo "✗ usage: up <file> [minutes] [chunk_seconds]"; return 1; }
  [[ ! -f "$input" ]] && { echo "✗ not found: $input"; return 1; }

  local abs_input
  abs_input="$(realpath "$input")"

  local base_name
  base_name="$(basename "$abs_input" | sed 's/\.[^.]*$//')"

  local run_dir="$cache_root/$base_name"
  local chunks_dir="$run_dir/chunks"
  local parts_dir="$run_dir/parts"
  local work_dir="$run_dir/work"
  local log_file="$run_dir/run.log"

  mkdir -p "$chunks_dir" "$parts_dir" "$work_dir"
  touch "$log_file"

  local max_gb="${UP_MAX_SCRATCH_GB:-10}"
  _check_space() {
    local used
    used="$(du -sm "$run_dir" 2>/dev/null | awk '{print $1}')"
    (( used > max_gb * 1024 ))
  }

  _log() {
    printf '%s  %s\n' "$(date '+%H:%M:%S')" "$*" | tee -a "$log_file"
  }

  _cleanup_chunk_dirs() {
    rm -rf "$work_dir/frames" "$work_dir/upscaled"
    mkdir -p "$work_dir/frames" "$work_dir/upscaled"
  }

  caffeinate -dimsu -w $$ &
  local caf_pid=$!
  _log "▶ caffeinated (pid: $caf_pid) - starting: $base_name"

  local deadline=0
  [[ -n "$minutes" ]] && deadline=$(( $(date +%s) + minutes * 60 ))

  # Split source into chunks (skipped on resume).
  if [[ -z "$(find "$chunks_dir" -mindepth 1 -print -quit 2>/dev/null)" ]]; then
    _log "→ splitting into ${chunk_seconds}s chunks..."
    ffmpeg -loglevel error -y -i "$abs_input" \
      -c copy -map 0 \
      -f segment -segment_time "$chunk_seconds" -reset_timestamps 1 \
      "$chunks_dir/chunk_%03d.mkv" || {
        _log "✗ chunk split failed"
        kill "$caf_pid" 2>/dev/null
        return 1
      }
  fi

  local fps
  fps="$(ffprobe -v error -select_streams v:0 -show_entries stream=avg_frame_rate \
    -of default=noprint_wrappers=1:nokey=1 "$abs_input")"
  [[ -z "$fps" ]] && fps="24000/1001"

  local chunk
  local part_idx=0

  for chunk in "$chunks_dir"/chunk_*.*; do
    [[ -e "$chunk" ]] || continue

    if [[ "$deadline" -gt 0 && "$(date +%s)" -ge "$deadline" ]]; then
      _log "→ time limit reached before chunk $(basename "$chunk")"
      break
    fi

    if _check_space; then
      _log "✗ scratch limit ${max_gb}GB reached — stopping before $(basename "$chunk")"
      kill "$caf_pid" 2>/dev/null
      return 1
    fi

    _cleanup_chunk_dirs

    local frames_dir="$work_dir/frames"
    local upscaled_dir="$work_dir/upscaled"
    local part_file
    part_file="$(printf '%s/part_%03d.mp4' "$parts_dir" "$part_idx")"

    _log "→ chunk $(basename "$chunk")"

    ffmpeg -loglevel error -y -i "$chunk" \
      -vf "hqdn3d=1.2:1.2:4:4,unsharp=3:3:0.6:3:3:0.0" \
      -q:v 2 "$frames_dir/frame_%05d.jpg" || {
        _log "✗ extract failed on $(basename "$chunk")"
        kill "$caf_pid" 2>/dev/null
        return 1
      }

    find "$work_dir" -name '._*' -delete
    dot_clean "$work_dir" 2>/dev/null

    local total
    total="$(find "$frames_dir" -name 'frame_*.jpg' | wc -l | tr -d ' ')"
    find "$upscaled_dir" -name '*.png' -size 0 -delete

    if [[ "$total" -eq 0 ]]; then
      _log "✗ no frames extracted for $(basename "$chunk")"
      kill "$caf_pid" 2>/dev/null
      return 1
    fi

    _log "→ upscaling chunk ($total frames)"

    /Applications/Upscayl.app/Contents/Resources/bin/upscayl-bin \
      -i "$frames_dir" \
      -o "$upscaled_dir" \
      -s 2 \
      -n "$model" \
      -m "/Applications/Upscayl.app/Contents/Resources/models" \
      -j 4:4:4 &
    local up_pid=$!

    local warmup_done=0
    local warmup_p=0

    while kill -0 "$up_pid" 2>/dev/null; do
      sleep 5

      local cur
      cur="$(find "$upscaled_dir" -name "*_${model}.png" | wc -l | tr -d ' ')"
      printf "\r\033[K  upscaling chunk %03d: %d/%d" "$part_idx" "$cur" "$total"

      if [[ "$cur" -gt 0 ]]; then
        warmup_done=1
      fi

      if [[ "$warmup_done" -eq 0 ]]; then
        (( warmup_p++ ))
        if [[ "$warmup_p" -ge "$warmup_limit" ]]; then
          kill "$up_pid"; printf "\n"
          _log "✗ warmup timeout on $(basename "$chunk")"
          kill "$caf_pid" 2>/dev/null; return 1
        fi
      fi

      if [[ "$deadline" -gt 0 && "$(date +%s)" -ge "$deadline" ]]; then
        kill "$up_pid"
        printf "\n"
        _log "→ time limit reached during $(basename "$chunk")"
        wait "$up_pid" 2>/dev/null
        kill "$caf_pid" 2>/dev/null
        return 0
      fi
    done

    wait "$up_pid" 2>/dev/null
    printf "\n"

    find "$upscaled_dir" -name "*_${model}.png" | while read -r f; do
      mv "$f" "${f%_${model}.png}.png" 2>/dev/null
    done

    local final_c
    final_c="$(find "$upscaled_dir" -name 'frame_*.png' | wc -l | tr -d ' ')"
    if [[ "$final_c" -eq 0 ]]; then
      _log "✗ no upscaled frames for $(basename "$chunk")"
      kill "$caf_pid" 2>/dev/null
      return 1
    fi

    local concat_file="$work_dir/concat.txt"
    printf "file '%s'\n" "$upscaled_dir"/frame_*.png | sort -V > "$concat_file"

    ffmpeg -loglevel error -y \
      -f concat -safe 0 -r "$fps" -i "$concat_file" \
      -i "$chunk" \
      -map 0:v -map "1:a?" \
      -vf "eq=contrast=1.05:saturation=1.1,unsharp=3:3:0.5" \
      -c:v libx264 -pix_fmt yuv420p -crf 18 -preset fast \
      -c:a copy \
      "$part_file" || {
        _log "✗ assembly failed on $(basename "$chunk")"
        kill "$caf_pid" 2>/dev/null
        return 1
      }

    _log "✓ part done: $(basename "$part_file")"

    rm -f "$chunk"
    _log "✓ chunk removed: $(basename "$chunk")"

    # Free local disk before next chunk.
    rm -rf "$frames_dir" "$upscaled_dir" "$concat_file"

    (( part_idx++ ))
  done

  if [[ -z "$(find "$parts_dir" -name 'part_*.mp4' -print -quit 2>/dev/null)" ]]; then
    _log "✗ no finished parts to combine"
    kill "$caf_pid" 2>/dev/null
    return 1
  fi

  _log "→ concatenating final output"
  local final_concat="$run_dir/final_concat.txt"
  printf "file '%s'\n" "$parts_dir"/part_*.mp4 | sort -V > "$final_concat"

  ffmpeg -loglevel error -y \
    -f concat -safe 0 -i "$final_concat" \
    -c copy "${abs_input%.*}_up.mp4" || {
      _log "✗ final concat failed"
      kill "$caf_pid" 2>/dev/null
      return 1
    }

  _log "✓ done: ${abs_input%.*}_up.mp4"
  kill "$caf_pid" 2>/dev/null
}

