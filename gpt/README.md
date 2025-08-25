# Integrations for Open-AI API (GPT)

## `gpt.sh`
> ### Simple OpenAI-API shell integration.

### Env
> `$LLM_API` = 'API-KEY'
> ### Example usage
```bash
# simplest — inline prompt
gpt "Hello there!"

# longer prompt from a file
gpt -i notes/prompt.txt

# prompt from file, save answer into a file (and still see it in terminal)
gpt -i notes/prompt.txt -o reply.txt

# inline prompt, save output to file only
gpt "Write a haiku about Arch Linux" -o haiku.txt

# use stdin (pipe into gpt)
echo "Summarize this text for me" | gpt

# set model explicitly
gpt -m gpt-4.1 "Explain systemd in one sentence"

# add a system prompt to guide style
gpt -s "You are a sarcastic hacker poet." "Say something about firewalls"

# tweak randomness
gpt -T 0.2 "Explain AI in very formal language"
gpt -T 1.5 "Explain AI in a silly, chaotic way"
```
