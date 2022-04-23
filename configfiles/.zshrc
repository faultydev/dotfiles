# Additional paths
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# ZSH
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="afowler"
plugins=(git docker docker-compose node zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh
source ~/.zsh_scripts

# ALIASES
alias q="exit"
alias open="xdg-open"
alias nobeep="sudo modprobe -r pcspkr"
alias bl="sudo light -S"
alias ssh="kitty +kitten ssh"

# COSMETICS
pfetch

