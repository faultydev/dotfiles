# ZSH
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="afowler"
plugins=(git docker docker-compose alias-finder aliases node zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# ALIASES
alias ix="curl -F 'f:1=<-' ix.io"

# COSMETICS
pfetch
