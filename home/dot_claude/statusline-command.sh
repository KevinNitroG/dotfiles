#!/usr/bin/env bash
input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')
five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
five_hour_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_day_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Build circle bar (10 segments)
FILLED="●"
EMPTY="○"
SEGMENTS=10

if [ -n "$used" ]; then
  ctx_int=$(printf "%.0f" "$used")
  filled_count=$((ctx_int * SEGMENTS / 100))
  [ "$filled_count" -gt "$SEGMENTS" ] && filled_count=$SEGMENTS

  bar=""
  for i in $(seq 1 $SEGMENTS); do
    if [ "$i" -le "$filled_count" ]; then
      bar="${bar}${FILLED}"
    else
      bar="${bar}${EMPTY}"
    fi
  done

  # Convert tokens to k
  tokens_k=$((total_input / 1000))
  max_k=$((ctx_size / 1000))

  # Choose color: blue by default, red when > 60%
  if [ "$ctx_int" -gt 60 ]; then
    color="\033[31m"
  else
    color="\033[34m"
  fi

  ctx_segment="${color}${bar} ${tokens_k}k/${max_k}k (${ctx_int}% used)\033[0m"
else
  empty_bar=""
  for i in $(seq 1 $SEGMENTS); do
    empty_bar="${empty_bar}${EMPTY}"
  done
  ctx_segment="\033[34m${empty_bar} 0%\033[0m"
fi

# Build model string with effort
model_str="\033[33m${model}\033[0m"
if [ -n "$effort" ]; then
  model_str="${model_str} \033[35m(${effort})\033[0m"
fi

# Build suffix with cwd and rate limits
suffix=""

# Format time remaining function
format_time_remaining() {
  local reset_timestamp=$1
  local now=$(date +%s)
  local seconds_left=$((reset_timestamp - now))

  if [ "$seconds_left" -le 0 ]; then
    echo "now"
  else
    local hours=$((seconds_left / 3600))
    local minutes=$(((seconds_left % 3600) / 60))
    if [ "$hours" -gt 0 ]; then
      echo "${hours}h ${minutes}m"
    else
      echo "${minutes}m"
    fi
  fi
}

# Add rate limits to suffix with rounded percentages and time remaining
if [ -n "$five_hour_pct" ] || [ -n "$seven_day_pct" ]; then
  suffix="${suffix} • \033[36m["
  if [ -n "$five_hour_pct" ]; then
    five_hour_pct_rounded=$(printf "%.0f" "$five_hour_pct")
    time_remaining=$(format_time_remaining "$five_hour_reset")
    suffix="${suffix}5h: ${five_hour_pct_rounded}% (${time_remaining})"
  fi
  if [ -n "$seven_day_pct" ]; then
    [ -n "$five_hour_pct" ] && suffix="${suffix} | "
    seven_day_pct_rounded=$(printf "%.0f" "$seven_day_pct")
    suffix="${suffix}7d: ${seven_day_pct_rounded}%"
  fi
  suffix="${suffix}]\033[0m"
fi

if [ -n "$cwd" ]; then
  # Shorten path: show last 2 components
  short_cwd=$(echo "$cwd" | awk -F'/' '{print $(NF-1)"/"$NF}')
  suffix="${suffix} • ${short_cwd}"
fi

printf "%b | %b%b\n" "$model_str" "$ctx_segment" "$suffix"
