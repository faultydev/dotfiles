source ~/.zsh_preferences

# paths
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

if [ $_ZSH_PREF_NO_NONSENSE != 1 ]; then 
# ZSH
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="afowler"
plugins=(git docker docker-compose node zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

source ~/.zsh_scripts

# ALIASES
alias open="xdg-open"
alias nobeep="sudo modprobe -r pcspkr"
alias bl="sudo light -S"
alias ssh="kitty +kitten ssh"

# COSMETICS
if [ $_ZSH_PREF_NO_PFETCH != 1 ]; then pfetch; fi

else 
PS1="$(whoami)@$(cat /etc/hostname) $ "
fi

alias q="exit"
