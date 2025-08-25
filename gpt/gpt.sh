#!/usr/bin/env bash
# gpt — minimal CLI for OpenAI Responses API
# Usage:
#   gpt "prompt text"
#   gpt -i in.txt
#   gpt -i in.txt -o out.txt
#   echo "hi" | gpt
#   gpt -m gpt-4.1 "Summarize this:"
set -euo pipefail

url="https://api.openai.com/v1/responses"
m="gpt-4.1-mini"    # default model
i=""                # -i input file
o=""                # -o output file
s=""                # -s system prompt (optional)
T=""                # -T temperature (optional, e.g., 0.2)

usage() {
  echo "gpt: Simple GPT CLI via OpenAI Responses API
Usage:
  gpt \"prompt\"
  gpt -i in.txt [-o out.txt]
  echo \"hi\" | gpt
Options:
  -i FILE   read prompt from file
  -o FILE   write output to file (also prints to stdout)
  -m MODEL  model id (default: ${m})
  -s TEXT   system prompt
  -T NUM    temperature (0..2)
  -h        help
ENV:
  LLM_API   OpenAI API key" >&2
}

# deps: jq? python3?
has_jq() { command -v jq >/dev/null 2>&1; }
has_py() { command -v python3 >/dev/null 2>&1; }

# json-escape stdin -> stdout
jesc() {
  if has_jq; then jq -Rs .; elif has_py; then python3 - <<'PY'
import sys, json; print(json.dumps(sys.stdin.read()))
PY
  else
    echo "error: need jq or python3 for JSON escaping" >&2; exit 1
  fi
}

# extract text from API response -> stdout
extract_text() {
  if command -v jq >/dev/null 2>&1; then
    jq -r '
      # 1) Responses API (current)
      (.output[0].content[]? | select(.type=="output_text") | .text) //
      # 2) Convenience or legacy shapes (fallbacks)
      .output_text //
      .choices[0].message.content //
      .data[0].text //
      empty
    '
  elif command -v python3 >/dev/null 2>&1; then
    python3 - <<'PY'
import sys, json
j=json.load(sys.stdin)
# Try Responses API v2 shape
try:
    for c in (j.get("output") or []):
        for part in (c.get("content") or []):
            if part.get("type")=="output_text":
                t = part.get("text")
                if t:
                    print(t)
                    sys.exit(0)
except Exception:
    pass
# Fallbacks
t = j.get("output_text")
if not t:
    ch = (j.get("choices") or [{}])[0]
    t = (ch.get("message") or {}).get("content") or ""
if not t:
    d = (j.get("data") or [{}])[0]
    t = d.get("text") or ""
print(t)
PY
  else
    cat   # last resort: dump raw JSON
  fi
}

# flags
while getopts ":i:o:m:s:T:h" opt; do
  case "$opt" in
    i) i="$OPTARG" ;;
    o) o="$OPTARG" ;;
    m) m="$OPTARG" ;;
    s) s="$OPTARG" ;;
    T) T="$OPTARG" ;;
    h) usage; exit 0 ;;
    \?) echo "error: invalid option -$OPTARG" >&2; usage; exit 1 ;;
    :) echo "error: -$OPTARG requires an argument" >&2; usage; exit 1 ;;
  esac
done
shift $((OPTIND-1))

# API key
: "${LLM_API:?error: LLM_API env var is required}"

# prompt source
p=""
if [ $# -gt 0 ]; then
  p="$*"
elif [ -n "${i}" ]; then
  p="$(cat -- "$i")"
elif [ ! -t 0 ]; then
  p="$(cat)"
else
  echo "error: provide a prompt, -i FILE, or pipe stdin" >&2
  usage; exit 1
fi

# build JSON body
usr=$(printf "%s" "$p" | jesc)
sys=""
if [ -n "$s" ]; then sys=$(printf "%s" "$s" | jesc); fi

# Assemble payload (Responses API)
# Minimal: {"model": "...", "input": "..." }
# Optional system: we can pass a message array via input items.
if [ -n "$sys" ]; then
  data=$(cat <<EOF
{
  "model": "${m}",
  "input": [
    {"role":"system","content": ${sys}},
    {"role":"user","content": ${usr}}
  ]$( [ -n "$T" ] && printf ', "temperature": %s' "$T")
}
EOF
)
else
  data=$(cat <<EOF
{
  "model": "${m}",
  "input": ${usr}$( [ -n "$T" ] && printf ', "temperature": %s' "$T")
}
EOF
)
fi

# call API
r=$(curl -sS "$url" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LLM_API" \
  -d "$data")

# try to extract plain text
t=$(printf "%s" "$r" | extract_text)

# if empty, show raw response as a hint
if [ -z "$t" ]; then
  echo "warning: could not parse model output; raw JSON below:" >&2
  echo "$r"
  [ -n "$o" ] && printf "%s" "$r" >"$o"
  exit 0
fi

# print + optional save
printf "%s\n" "$t"
[ -n "$o" ] && printf "%s\n" "$t" >"$o"
