# ZSH
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="afowler"
plugins=(git docker docker-compose node zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# ALIASES
alias ix="curl -F 'f:1=<-' ix.io"
alias chis="cat ~/.zsh_history | less +G"
alias tmpfile="nvim /tmp/$(date +%H:%M_%d-%m-%Y)"
alias q="exit"

# COSMETICS
pfetch
