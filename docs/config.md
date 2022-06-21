> work in progress

# Introduction
This is a collection of config args for my dotfiles.

## Variables
If the variable is changeable by env it won't be prefixed with a `$`.

### cfg.sh

---

#### `$PACKAGES`

This is a list of packages that are installed by default.

---

#### `$FALLBACK_INSTALL_STRING`
This is a string that is used to install packages if the package manager is not detected.

#### `$BACKUP_DIRECTORIES`
This is a list of directories that are backed up by the backup script.

#### `$TAR_NAME`
This is the name of the tar file that is created by the backup script.

---

#### `DO_AS_SU`
This is automatically set to `doas` or, if not available, to `sudo`.

---

### `GRAPHICAL`
Install graphical components?  
this flag can also be modified by the `-g` argument when running the script.

#### `USE_SUDO`
Use sudo?  
This flag, when changed, changes the default behaviour of the script; some modules aren't run because they require root privileges.

#### `DO_GIT_SYNC`
Sync with git?  
Check for updates with git, this can take a couple of seconds and can be disabled by setting this to `0`.

---

#### `GIT_USER_NAME`
This is the name of the user that is used for git.

#### `GIT_USER_EMAIL`
This is the email of the user that is used for git.

#### `GIT_SIGNING_KEY`
This is the signing key that is used for git.

### lib.sh

#### `LOG_FILE`
This is used to pipe the output to from any ran command.

#### `$VERBOSE`
This is used to enable verbose output.
This is automatically set to `1` when the `-v` argument is used.

#### `$SILENCE`
This is used to disable all output (with few exceptions).
This is automatically set to `1` when the `-s` argument is used.

#### `$DEBUG`
This is used to enable debug output.
This is automatically set to `1` when the `-d` argument is used.

#### `$VERSION`
This is the version of the script.