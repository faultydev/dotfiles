#### SYNC ####

# packages to install
# generally the package names are universal
PACKAGES="zsh awesome neovim kitty alsa-utils"

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
