# # -------------------------------------------------------------------
# System Path Setup (Tells Zsh where to look for tools like oh-my-posh)
# -------------------------------------------------------------------
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -------------------------------------------------------------------
# Oh My Zsh Core Configuration
# -------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"

# Theme: Powerlevel10k (The absolute gold standard for status lines)
#ZSH_THEME="powerlevel10k/powerlevel10k"

# -------------------------------------------------------------------
# Plugins Configuration
# -------------------------------------------------------------------
# Add wisely, as too many plugins slow down shell startup.
# NOTE: zsh-autosuggestions and zsh-syntax-highlighting must be cloned first (see instructions below)
plugins=(
  git
  fzf
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# -------------------------------------------------------------------
# Modern CLI Tool Enhancements (bat, fzf, ripgrep, lazygit)
# -------------------------------------------------------------------

# 1. Bat (Better than 'cat' with syntax highlighting)
export BAT_THEME="ansi"
# Fix for Debian/Ubuntu where 'bat' is installed as 'batcat'
if command -v batcat &> /dev/null; then
    alias bat="batcat"
fi
alias cat="bat --paging=never"

# 2. Ripgrep (The fastest search tool)
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc" # Optional, if you have a config file
alias grep="rg"

# 3. Lazygit (Terminal UI for git)
alias lg="lazygit"

# 4. FZF (Fuzzy Finder) Configuration & Integration
if [ -f ~/.fzf.zsh ]; then source ~/.fzf.zsh; fi # Source default fzf bindings if present

# Tell FZF to use Ripgrep for ultra-fast indexing and Bat for previews
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --style=numbers --color=always --line-range :500 {}'"

# Use FZF to quickly CD into folders
alias fd="cd \$(find . -type d -not -path '*/.*' | fzf)"

# -------------------------------------------------------------------
# Quality of Life Tweaks
# -------------------------------------------------------------------
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS  # Don't record duplicate commands
setopt SHARE_HISTORY          # Share history across all open terminals

# Enable command auto-correction.
ENABLE_CORRECTION="true"

# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#eval "$(oh-my-posh init zsh --config amro)"
#eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/tokyonight.omp.json')"
eval "$(oh-my-posh init zsh --config tokyonight_storm)"
eval "$(oh-my-posh init zsh --config capr4n)"
#eval "$(oh-my-posh init zsh --config agnoster)"
#eval "$(oh-my-posh init zsh --config atomic)"
