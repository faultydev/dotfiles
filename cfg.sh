#### SYNC ####

# packages to install
# generally the package names are universal
PACKAGES="zsh neovim kitty"

# this string is used when the operating system couldn't be determined
FALLBACK_INSTALL_STRING="pacman -S --noconfirm"

#### BACKUP ####

# relative to home directory
BACKUP_DIRECTORIES="Documents Pictures Music Videos code"
TAR_NAME="backup_$(date +%Y-%m-%d_%H:%M).tar"

#### GENERIC ###

if [ -x "$(command -v doas)" ]; then
  DO_AS_SU="${DO_AS_SU:-doas}"
else
  DO_AS_SU="${DO_AS_SU:-sudo}"
fi

# script options
GRAPHICAL=${GRAPHICAL:-0}
USE_SUDO=${USE_SUDO:-1}
DO_GIT_SYNC=${DO_GIT_SYNC:-1}

GIT_USER_NAME="${GIT_USER_NAME:-faulty}"
GIT_USER_EMAIL="${GIT_USER_EMAIL:-didier@faulty.nl}"
GPG_SIGNING_KEY="${GPG_SIGNING_KEY:-01E71F18AA4398E5}"