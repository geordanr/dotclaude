#!/usr/bin/env bash
# Claude Code status line script

input=$(cat)

# --- Current directory (full path) ---
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')

# --- Git: branch, working-tree counts, ahead/behind, in-progress operation ---
# One `git status` call, cached for a few seconds per directory: git over /mnt/c
# is slow, and the status line redraws often.
git_segment() {
  local dir="$1"
  git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

  local status
  status=$(git -C "$dir" status --porcelain=v2 --branch 2>/dev/null) || return

  # head, staged, modified, untracked, conflicts, ahead, behind
  local head staged modified untracked conflicts ahead behind
  read -r head staged modified untracked conflicts ahead behind < <(
    printf '%s\n' "$status" | awk '
      /^# branch.oid /  { oid = substr($3, 1, 7) }
      /^# branch.head / { head = $3 }
      /^# branch.ab /   { ahead = substr($3, 2); behind = substr($4, 2) }
      /^[12] / {
        xy = $2
        if (substr(xy, 1, 1) != ".") s++
        if (substr(xy, 2, 1) != ".") m++
      }
      /^u / { c++ }
      /^\? / { u++ }
      END {
        if (head == "(detached)") head = oid
        printf "%s %d %d %d %d %d %d\n", head, s, m, u, c, ahead, behind
      }')

  local git_dir op=""
  git_dir=$(git -C "$dir" rev-parse --absolute-git-dir 2>/dev/null)
  if [ -d "$git_dir/rebase-merge" ] || [ -d "$git_dir/rebase-apply" ]; then
    op="REBASE"
  elif [ -f "$git_dir/MERGE_HEAD" ]; then
    op="MERGE"
  elif [ -f "$git_dir/CHERRY_PICK_HEAD" ]; then
    op="CHERRY-PICK"
  elif [ -f "$git_dir/REVERT_HEAD" ]; then
    op="REVERT"
  elif [ -f "$git_dir/BISECT_LOG" ]; then
    op="BISECT"
  fi

  local out
  out=$(printf '\033[1;93m\xe2\x8e\x87 %s\033[0m' "$head")
  [ "$staged" -gt 0 ]    && out+=$(printf ' \033[0;92m+%d\033[0m' "$staged")
  [ "$modified" -gt 0 ]  && out+=$(printf ' \033[38;5;215m~%d\033[0m' "$modified")
  [ "$untracked" -gt 0 ] && out+=$(printf ' \033[38;5;250m?%d\033[0m' "$untracked")
  [ "$conflicts" -gt 0 ] && out+=$(printf ' \033[1;91m!%d\033[0m' "$conflicts")
  [ "$ahead" -gt 0 ]     && out+=$(printf ' \033[0;97m\xe2\x86\x91%d\033[0m' "$ahead")
  [ "$behind" -gt 0 ]    && out+=$(printf ' \033[0;97m\xe2\x86\x93%d\033[0m' "$behind")
  [ -n "$op" ]           && out+=$(printf ' \033[1;91m%s\033[0m' "$op")
  printf '%s' "$out"
}

git_info=""
if [ -n "$cwd" ]; then
  cache_ttl=5
  cache_file="${TMPDIR:-/tmp}/claude-statusline-git-$(printf '%s' "$cwd" | md5sum | cut -c1-16)"
  now=$(date +%s)
  mtime=$(stat -c %Y "$cache_file" 2>/dev/null || echo 0)
  if [ $((now - mtime)) -lt "$cache_ttl" ]; then
    git_info=$(cat "$cache_file")
  else
    git_info=$(git_segment "$cwd")
    tmp=$(mktemp "${cache_file}.XXXXXX" 2>/dev/null) &&
      printf '%s' "$git_info" > "$tmp" && mv -f "$tmp" "$cache_file"
  fi
fi

# --- Current model ---
model=$(echo "$input" | jq -r '.model.display_name // .model.id // empty')

# --- Context used percentage ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# --- Active agent time and tokens per minute ---
# Output tokens per minute of model generation time (tool execution excluded).
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')

active_secs=0
tpm=""

if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  # Use python3 for reliable JSON parsing of the JSONL transcript
  result=$(python3 - "$transcript_path" <<'PYEOF'
import sys, json
from datetime import datetime

# Active time = model generation only. For each API response (grouped by
# message.id), count from the entry that triggered it (user prompt or
# tool_result) to its last streamed block. Tool execution, permission prompts
# and user idle time fall between a tool_use and the next tool_result/prompt,
# so they are excluded. Tokens = output tokens, deduplicated per message.id.
def ts(e):
    t = e.get('timestamp')
    if not t:
        return None
    try:
        return datetime.fromisoformat(t.replace('Z', '+00:00')).timestamp()
    except ValueError:
        return None

spans = {}   # message.id -> [start, end]
tokens = {}  # message.id -> output_tokens
last_trigger = None
try:
    with open(sys.argv[1]) as f:
        for line in f:
            try:
                e = json.loads(line)
            except ValueError:
                continue
            if e.get('isSidechain'):
                continue
            t = ts(e)
            if t is None:
                continue
            if e.get('type') == 'assistant':
                msg = e.get('message') or {}
                mid = msg.get('id')
                if not mid:
                    continue
                if mid not in spans:
                    spans[mid] = [last_trigger if last_trigger is not None else t, t]
                spans[mid][1] = t
                out = (msg.get('usage') or {}).get('output_tokens') or 0
                tokens[mid] = max(tokens.get(mid, 0), out)
            elif e.get('type') == 'user':
                last_trigger = t
except OSError:
    pass

active_secs = sum(max(0.0, b - a) for a, b in spans.values())
total = sum(tokens.values())
tpm = round(total / (active_secs / 60)) if active_secs > 0 else 0
print(f"{active_secs:.0f} {tpm}")
PYEOF
  )
  
  if [ -n "$result" ]; then
    active_secs=$(echo "$result" | awk '{print $1}')
    tpm_val=$(echo "$result" | awk '{print $2}')
  fi
fi

# Format active duration as Xm Ys or just Xs
format_duration() {
  local secs="$1"
  local s=$(echo "$secs" | awk '{printf "%d", $1}')
  if [ "$s" -ge 60 ] 2>/dev/null; then
    local m=$((s / 60))
    local rem=$((s % 60))
    echo "${m}m ${rem}s"
  else
    echo "${s}s"
  fi
}

# --- Assemble status line ---
parts=()
mparts=()

# Directory: the home dir is shown as "~" and the Windows home dir (directly
# or via the ~/winhome symlink) as "🪟~"; the portion below it is in bold.
# Windows home is checked first because ~/winhome lies under $HOME.
dir_base=""
dir_label=""
for entry in "/mnt/c/Users/geord:🪟~" "$HOME/winhome:🪟~" "$HOME:~"; do
  home_dir="${entry%:*}"
  if [[ "$cwd" == "$home_dir" || "$cwd" == "$home_dir"/* ]]; then
    dir_base="$home_dir"
    dir_label="${entry##*:}"
    break
  fi
done
if [ -z "$dir_base" ]; then
  parts+=("$(printf '\033[0;96m%s\033[0m' "$cwd")")
elif [ "$cwd" = "$dir_base" ]; then
  parts+=("$(printf '\033[1;96m%s\033[0m' "$dir_label")")
else
  parts+=("$(printf '\033[0;96m%s/\033[1;96m%s\033[0m' "$dir_label" "${cwd#"$dir_base"/}")")
fi

# Git
if [ -n "$git_info" ]; then
  parts+=("$git_info")
fi

# Model
if [ -n "$model" ]; then
  mparts+=("$(printf '\033[1;95m%s\033[0m' "$model")")
fi

# Context used
if [ -n "$used_pct" ]; then
  used_int=$(echo "$used_pct" | awk '{printf "%d", $1}')
  if [ "$used_int" -ge 80 ] 2>/dev/null; then
    color='\033[1;91m'
  elif [ "$used_int" -ge 50 ] 2>/dev/null; then
    color='\033[0;93m'
  else
    color='\033[0;92m'
  fi
  mparts+=("$(printf "${color}ctx:%d%%\033[0m" "$used_int")")
fi

# Active duration
if [ -n "$active_secs" ] && [ "$active_secs" != "0" ]; then
  dur=$(format_duration "$active_secs")
  mparts+=("$(printf '\033[38;5;117mactive:%s\033[0m' "$dur")")
fi

# Tokens per minute
if [ -n "$tpm_val" ] && [ "$tpm_val" -gt 0 ] 2>/dev/null; then
  # 950, 1.8k, 12.4k, 1.2M
  tpm_fmt=$(awk -v n="$tpm_val" 'BEGIN {
    if (n >= 999950) printf "%.1fM", n / 1e6   # not "1000.0k"
    else if (n >= 1e3) printf "%.1fk", n / 1e3
    else printf "%d", n
  }')
  mparts+=("$(printf '\033[38;5;223mtpm:%s\033[0m' "$tpm_fmt")")
fi

# Model, ctx, active and tpm form one segment, joined by a dim dot
if [ ${#mparts[@]} -gt 0 ]; then
  msep="$(printf '\033[38;5;244m \xc2\xb7 \033[0m')"
  mgroup="${mparts[0]}"
  for p in "${mparts[@]:1}"; do
    mgroup="${mgroup}${msep}${p}"
  done
  parts+=("$mgroup")
fi

# Join with separator
sep="$(printf '\033[38;5;244m \xe2\x94\x82 \033[0m')"
result_line=""
for part in "${parts[@]}"; do
  if [ -z "$result_line" ]; then
    result_line="$part"
  else
    result_line="${result_line}${sep}${part}"
  fi
done

printf "%b\n" "$result_line"
