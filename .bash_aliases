#!/usr/bin/bash

BOLD=$'\033[1m'
CYAN=$'\033[38;5;6m'    # Theme Cyan
GREEN=$'\033[38;5;2m'   # Theme Green
YELLOW=$'\033[38;5;3m'  # Theme Yellow
RED=$'\033[38;5;1m'     # Theme Red
BLUE=$'\033[38;5;4m'    # Theme Blue
GRAY=$'\033[38;5;8m'    # Theme "Bright Black" (usually the Gray in most themes)
NC=$'\033[0m'           # No Color


alias htop='btop'

# Shortcuts
alias findReq="find . -iname 'requirements*.txt' -exec pip install -r {} \;"
alias update='sudo apt update; sudo apt upgrade;'
alias vimdiff='vim -d'

# ast-grep: always use global config for custom languages (e.g. XML)
export AST_GREP_CONFIG=/home/andg/.config/ast-grep/sgconfig.yml
ast-grep() {
  local cfg="$AST_GREP_CONFIG"
  [[ -z "$cfg" || ! -f "$cfg" ]] && { command ast-grep "$@"; return; }
  local subcmd=""
  local args=()
  for arg in "$@"; do
    if [[ -z "$subcmd" && "$arg" =~ ^(run|scan|test|lsp|new)$ ]]; then
      subcmd="$arg"
    fi
    args+=("$arg")
  done
  # If no explicit subcommand, inject 'run' so we can pass -c
  if [[ -z "$subcmd" ]]; then
    command ast-grep run -c "$cfg" "$@"
  else
    command ast-grep "${args[1]}" -c "$cfg" "${args[@]:1}"
  fi
}

if [ -f ~/.bash_aliases_odoo ]; then
    . ~/.bash_aliases_odoo
fi
