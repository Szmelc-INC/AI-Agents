# Integrations for Shell-GPT package

# Shell-GPT Usage Cheat Sheet

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
