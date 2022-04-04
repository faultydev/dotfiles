# ZSH
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="afowler"
plugins=(git docker docker-compose node zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

ix() {
            local opts
            local OPTIND
            [ -f "$HOME/.netrc" ] && opts='-n'
            while getopts ":hd:i:n:" x; do
                case $x in
                    h) echo "ix [-d ID] [-i ID] [-n N] [opts]"; return;;
                    d) $echo curl $opts -X DELETE ix.io/$OPTARG; return;;
                    i) opts="$opts -X PUT"; local id="$OPTARG";;
                    n) opts="$opts -F read:1=$OPTARG";;
                esac
            done
            shift $(($OPTIND - 1))
            [ -t 0 ] && {
                local filename="$1"
                shift
                [ "$filename" ] && {
                    curl $opts -F f:1=@"$filename" $* ix.io/$id
                    return
                }
                echo "^C to cancel, ^D to send."
            }
            curl $opts -F f:1='<-' $* ix.io/$id
}


# ALIASES
# alias ix="curl -F 'f:1=<-' ix.io"
alias tmpfile="vim /tmp/$(date +%H:%M_%d-%m-%Y)"
alias q="exit"
alias open="xdg-open"
alias nobeep="sudo modprobe -r pcspkr"
alias bl="sudo light -S"
alias ssh="kitty +kitten ssh"

# COSMETICS
pfetch

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
