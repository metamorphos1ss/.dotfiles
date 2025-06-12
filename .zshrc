#zinit init
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
  echo "Installing zinit..."
  mkdir -p "$HOME/.local/share/zinit"
  git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

#instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light rupa/z
zinit light Aloxaf/fzf-tab
zinit light djui/alias-tips
zinit light MichaelAquilina/zsh-you-should-use
zinit light romkatv/powerlevel10k

#MUST BE LAST
zinit light zsh-users/zsh-syntax-highlighting 

#powerlevel10k theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#aliases
alias ll='ls -lha'
alias gs='git status'
alias n='nvim'
alias cat='bat'
alias b='bat'
alias p='python3'

#env
export EDITOR="nvim"
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

#completition
autoload -Uz compinit && compinit

#zsh settings
setopt autocd
setopt no_beep
setopt hist_ignore_dups
echo -ne '\e[5 q'
