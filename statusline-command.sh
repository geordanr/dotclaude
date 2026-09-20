#!/usr/bin/env bash
# Claude Code status line script

input=$(cat)

# --- Current directory (leaf only) ---
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
dir=$(basename "$cwd")

# --- Git branch (only if in a git repo) ---
branch=""
if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

# --- Context used percentage ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# --- Active agent time and tokens per minute ---
# Parse transcript to compute agent-active duration (time Claude spends generating,
# not waiting on tool calls) and cumulative output tokens.
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')

active_secs=0
tpm=""

if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  # Use python3 for reliable JSON parsing of the JSONL transcript
  result=$(python3 - "$transcript_path" <<'PYEOF'
import sys, json, math

transcript_path = sys.argv[1]
messages = []
try:
    with open(transcript_path, 'r') as f:
        for line in f:
            line = line.strip()
            if line:
                try:
                    messages.append(json.loads(line))
                except json.JSONDecodeError:
                    pass
except Exception:
    pass

# Compute agent-active time:
# For each assistant turn, active time = (timestamp of last message in that turn) - (timestamp of first message in that turn)
# We identify turns by consecutive messages with role=="assistant"
# Between assistant turns there are user/tool messages (waiting time) which we exclude.

active_ms = 0
total_output_tokens = 0

i = 0
while i < len(messages):
    msg = messages[i]
    role = msg.get('role', msg.get('type', ''))
    
    if role == 'assistant':
        # Find the span of this assistant turn
        turn_start_ts = None
        turn_end_ts = None
        j = i
        while j < len(messages):
            m = messages[j]
            r = m.get('role', m.get('type', ''))
            if r != 'assistant':
                break
            ts = m.get('timestamp')
            if ts is not None:
                if turn_start_ts is None:
                    turn_start_ts = ts
                turn_end_ts = ts
            # Count output tokens
            usage = m.get('usage', {}) or {}
            total_output_tokens += usage.get('output_tokens', 0)
            j += 1
        
        if turn_start_ts is not None and turn_end_ts is not None:
            active_ms += (turn_end_ts - turn_start_ts)
        elif turn_start_ts is not None:
            # Single message turn - count as 0 duration for that turn
            pass
        
        i = j
    else:
        i += 1

active_secs = active_ms / 1000.0

if active_secs > 0 and total_output_tokens > 0:
    active_mins = active_secs / 60.0
    tpm = math.ceil(total_output_tokens / active_mins)
else:
    tpm = 0

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

# Directory
parts+=("$(printf '\033[1;34m%s\033[0m' "$dir")")

# Git branch
if [ -n "$branch" ] && [ "$branch" != "HEAD" ]; then
  parts+=("$(printf '\033[0;33m\xef\x9c\xa2 %s\033[0m' "$branch")")
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
