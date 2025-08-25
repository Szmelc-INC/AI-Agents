#!/usr/bin/env bash
# gemini.sh - Simple Gemini API CLI integration

set -euo pipefail

API_URL="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
API_KEY="${GEMINI:-}"

usage() {
  echo "Usage: $0 [options] [prompt]"
  echo
  echo "Options:"
  echo "  -i FILE    Read prompt from FILE"
  echo "  -o FILE    Write output to FILE"
  echo "  -m MODEL   Set model (default: gemini-2.0-flash)"
  echo "  -h         Show this help"
  echo
  echo "Examples:"
  echo "  $0 \"Explain AI in a few words\""
  echo "  $0 -i input.txt -o output.txt"
  exit 1
}

# defaults
MODEL="gemini-2.0-flash"
infile=""
outfile=""
prompt=""

# parse args
while getopts "i:o:m:h" opt; do
  case $opt in
    i) infile="$OPTARG" ;;
    o) outfile="$OPTARG" ;;
    m) MODEL="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done
shift $((OPTIND -1))

if [[ -n "$infile" ]]; then
  if [[ -f "$infile" ]]; then
    prompt=$(<"$infile")
  else
    echo "Error: input file not found: $infile" >&2
    exit 1
  fi
elif [[ $# -gt 0 ]]; then
  prompt="$*"
else
  usage
fi

if [[ -z "$API_KEY" ]]; then
  echo "Error: GEMINI API key not set. Export GEMINI in your shell rc." >&2
  exit 1
fi

# perform request
response=$(curl -s \
  -H "Content-Type: application/json" \
  -H "X-goog-api-key: $API_KEY" \
  -X POST \
  -d "{
    \"contents\": [
      {
        \"parts\": [
          { \"text\": \"${prompt}\" }
        ]
      }
    ]
  }" \
  "$API_URL?key=$API_KEY")

# parse response (jq required)
output=$(echo "$response" | jq -r '.candidates[0].content.parts[0].text // "Error: no output"')

if [[ -n "$outfile" ]]; then
  echo "$output" > "$outfile"
  echo "[*] Saved response to $outfile"
else
  echo "$output"
fi
