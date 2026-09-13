#!/usr/bin/env node
// Cross-platform port of statusline-command.sh (no bash/jq/awk/date dependency).

const RESET = "\x1b[0m";
const COLOR = { blue: "\x1b[34m", red: "\x1b[31m", yellow: "\x1b[33m", magenta: "\x1b[35m", cyan: "\x1b[36m" };
const SEGMENTS = 10;
const FILLED = "●";
const EMPTY = "○";

function formatTimeRemaining(resetTimestamp) {
  const now = Math.floor(Date.now() / 1000);
  const secondsLeft = resetTimestamp - now;
  if (secondsLeft <= 0) return "now";
  const hours = Math.floor(secondsLeft / 3600);
  const minutes = Math.floor((secondsLeft % 3600) / 60);
  return hours > 0 ? `${hours}h ${minutes}m` : `${minutes}m`;
}

function buildContextSegment(input) {
  const used = input.context_window?.used_percentage;
  const totalInput = input.context_window?.total_input_tokens;
  const ctxSize = input.context_window?.context_window_size;

  if (used == null) {
    return `${COLOR.blue}${EMPTY.repeat(SEGMENTS)} 0%${RESET}`;
  }

  const ctxInt = Math.round(used);
  const filledCount = Math.min(Math.floor((ctxInt * SEGMENTS) / 100), SEGMENTS);
  const bar = FILLED.repeat(filledCount) + EMPTY.repeat(SEGMENTS - filledCount);

  const tokensK = Math.floor(totalInput / 1000);
  const maxK = Math.floor(ctxSize / 1000);
  const color = ctxInt > 60 ? COLOR.red : COLOR.blue;

  return `${color}${bar} ${tokensK}k/${maxK}k (${ctxInt}% used)${RESET}`;
}

function buildModelSegment(input) {
  const model = input.model?.display_name;
  const effort = input.effort?.level;
  let str = `${COLOR.yellow}${model}${RESET}`;
  if (effort) str += ` ${COLOR.magenta}(${effort})${RESET}`;
  return str;
}

function buildSuffix(input) {
  let suffix = "";
  const fiveHourPct = input.rate_limits?.five_hour?.used_percentage;
  const sevenDayPct = input.rate_limits?.seven_day?.used_percentage;
  const fiveHourReset = input.rate_limits?.five_hour?.resets_at;
  const sevenDayReset = input.rate_limits?.seven_day?.resets_at;

  if (fiveHourPct != null || sevenDayPct != null) {
    suffix += ` • ${COLOR.cyan}[`;
    if (fiveHourPct != null) {
      suffix += `5h: ${Math.round(fiveHourPct)}% (${formatTimeRemaining(fiveHourReset)})`;
    }
    if (sevenDayPct != null) {
      if (fiveHourPct != null) suffix += " | ";
      suffix += `7d: ${Math.round(sevenDayPct)}%`;
    }
    suffix += `]${RESET}`;
  }

  const cwd = input.cwd;
  if (cwd) {
    const parts = cwd.split(/[/\\]/).filter(Boolean);
    const shortCwd = parts.slice(-2).join("/");
    suffix += ` • ${shortCwd}`;
  }

  return suffix;
}

let raw = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => (raw += chunk));
process.stdin.on("end", () => {
  const input = JSON.parse(raw);
  const modelSegment = buildModelSegment(input);
  const ctxSegment = buildContextSegment(input);
  const suffix = buildSuffix(input);
  process.stdout.write(`${modelSegment} | ${ctxSegment}${suffix}\n`);
});
