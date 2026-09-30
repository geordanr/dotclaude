#!/usr/bin/env bash
# Claude Code status line script

input=$(cat)

# --- Current directory (full path) ---
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')

# --- Git branch (only if in a git repo) ---
branch=""
if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
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

# Directory: full path, with the portion below the home dir in bold.
# The Windows home dir under WSL counts as a home dir too.
dir_base=""
for home_dir in "$HOME" /mnt/c/Users/geord; do
  if [[ "$cwd" == "$home_dir"/* ]]; then
    dir_base="$home_dir"
    break
  fi
done
if [ -n "$dir_base" ]; then
  parts+=("$(printf '\033[0;96m%s/\033[1;96m%s\033[0m' "$dir_base" "${cwd#"$dir_base"/}")")
else
  parts+=("$(printf '\033[0;96m%s\033[0m' "$cwd")")
fi

# Git branch
if [ -n "$branch" ] && [ "$branch" != "HEAD" ]; then
  parts+=("$(printf '\033[0;33m\xef\x9c\xa2 %s\033[0m' "$branch")")
fi

# Model
if [ -n "$model" ]; then
  parts+=("$(printf '\033[0;94m%s\033[0m' "$model")")
fi

# Context used
if [ -n "$used_pct" ]; then
  used_int=$(echo "$used_pct" | awk '{printf "%d", $1}')
  if [ "$used_int" -ge 80 ] 2>/dev/null; then
    color='\033[1;31m'
  elif [ "$used_int" -ge 50 ] 2>/dev/null; then
    color='\033[0;33m'
  else
    color='\033[0;32m'
  fi
  parts+=("$(printf "${color}ctx:%d%%\033[0m" "$used_int")")
fi

# Active duration
if [ -n "$active_secs" ] && [ "$active_secs" != "0" ]; then
  dur=$(format_duration "$active_secs")
  parts+=("$(printf '\033[0;36mactive:%s\033[0m' "$dur")")
fi

# Tokens per minute
if [ -n "$tpm_val" ] && [ "$tpm_val" -gt 0 ] 2>/dev/null; then
  parts+=("$(printf '\033[0;35mtpm:%s\033[0m' "$tpm_val")")
fi

# Join with separator
sep="$(printf '\033[0;90m \xe2\x94\x82 \033[0m')"
result_line=""
for part in "${parts[@]}"; do
  if [ -z "$result_line" ]; then
    result_line="$part"
  else
    result_line="${result_line}${sep}${part}"
  fi
done

printf "%b\n" "$result_line"
