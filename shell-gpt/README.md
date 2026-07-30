# Integrations for Shell-GPT package

# Shell-GPT Usage Cheat Sheet

## `$HOME/.config/shell_gpt/.sgptrc` configs:
### Gemini
```
USE_LITELLM=true
DEFAULT_MODEL=gemini/gemini-3.5-flash
OPENAI_API_KEY=placeholder
API_BASE_URL=default
REQUEST_TIMEOUT=90
DEFAULT_COLOR=magenta
DEFAULT_EXECUTE_SHELL_CMD=false
DISABLE_STREAMING=false
OPENAI_USE_FUNCTIONS=true
SHOW_FUNCTIONS_OUTPUT=false
PRETTIFY_MARKDOWN=true
CODE_THEME=dracula
CHAT_CACHE_PATH=/tmp/chat_cache
CACHE_PATH=/tmp/cache
CHAT_CACHE_LENGTH=100
CACHE_LENGTH=100
ROLE_STORAGE_PATH=/home/silverx/.config/shell_gpt/roles
OPENAI_FUNCTIONS_PATH=/home/silverx/.config/shell_gpt/functions
SHELL_INTERACTION=true
OS_NAME=arch
SHELL_NAME=zsh
```

### Local Ollama
```
CHAT_CACHE_PATH=/tmp/chat_cache
CACHE_PATH=/tmp/cache
CHAT_CACHE_LENGTH=100
CACHE_LENGTH=100
REQUEST_TIMEOUT=60
DEFAULT_COLOR=magenta
ROLE_STORAGE_PATH=/home/silverx/.config/shell_gpt/roles
DEFAULT_EXECUTE_SHELL_CMD=false
DISABLE_STREAMING=false
CODE_THEME=dracula
OPENAI_FUNCTIONS_PATH=/home/silverx/.config/shell_gpt/functions
OPENAI_USE_FUNCTIONS=true
SHOW_FUNCTIONS_OUTPUT=true
PRETTIFY_MARKDOWN=true
USE_LITELLM=false
SHELL_INTERACTION=true
OS_NAME=arch
SHELL_NAME=zsh
OPENAI_API_BASE=http://localhost:11434/v1
API_BASE_URL=http://localhost:11434/v1
OPENAI_API_KEY=sk-local
DEFAULT_MODEL=huihui_ai/qwen3.5-abliterated:35b
```

---

## Shell integrations
### `shellgpt.zsh` ~ `GEMINI_API_*` keys rotation
```bash
# === Multi Gemini key rotation for ShellGPT ===
sgpt() {
  # Collect all available keys
  local keys=()
  [[ -n $GEMINI_API_KEY ]] && keys+=("$GEMINI_API_KEY")
  for i in {1..9}; do
    local var="GEMINI_API_$i"
    [[ -n ${(P)var} ]] && keys+=("${(P)var}")   # zsh
    # bash version: [[ -n ${!var} ]] && keys+=("${!var}")
  done

  if (( ${#keys[@]} == 0 )); then
    echo "No GEMINI_API_KEY or GEMINI_API_1..9 found" >&2
    return 1
  fi

  # Pick a random key
  local selected=${keys[$((RANDOM % ${#keys[@]} + 1))]}

  # Temporarily export it and call the real sgpt
  GEMINI_API_KEY="$selected" OPENAI_API_KEY="placeholder" command sgpt "$@"
}
```

---

> Common examples of how to use [`sgpt`](https://github.com/TheR1D/shell-gpt) in your terminal.

---

## 🔹 Basic usage
```bash
sgpt "Explain how DNS works in one sentence"
```

## 🔹 Code generation
```bash
sgpt "Write a bash script to list all .txt files in current directory"
```

## 🔹 Run in shell and execute
```bash
sgpt --shell "find all .log files bigger than 10MB and delete them"
```
*(prints the command, asks for confirmation, then executes)*

## 🔹 Chat / interactive mode
```bash
sgpt --chat dev
```
- Opens a persistent chat session named **dev**  
- Useful for asking multiple related questions without repeating context

## 🔹 Save conversation history
```bash
sgpt --chat linux "How do I restart NetworkManager on Fedora?"
sgpt --chat linux "And how do I enable it on boot?"
```

## 🔹 Generate git commit messages
```bash
git diff | sgpt "Write a concise git commit message"
```

## 🔹 Use as man-like helper
```bash
sgpt "How to resize LVM partition on Linux?"
```

## 🔹 Output as code only
```bash
sgpt --code "Python function to calculate Fibonacci sequence"
```

## 🔹 With input file
```bash
sgpt --file myscript.py "Explain what this script does"
```

## 🔹 Use custom model
```bash
sgpt --model gpt-4 "Summarize the differences between TCP and UDP"
```
