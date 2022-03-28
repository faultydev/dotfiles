# ZSH
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="afowler"
plugins=(git docker docker-compose node zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# ALIASES
alias ix="curl -F 'f:1=<-' ix.io"
alias tmpfile="$EDITOR /tmp/$(date +%H:%M_%d-%m-%Y)"
alias q="exit"
alias open="xdg-open"

# COSMETICS
pfetch

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
