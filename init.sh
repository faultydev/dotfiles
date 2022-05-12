#!/bin/sh

trap 'echo "Interrupted by user"; exit' SIGINT SIGTERM

# dependency check; git 
if [ -z "$(which git 2>&1)" ]; then
  __print "please install \"git\""
  exit 1
fi

ORIGIN="$(pwd)"

GITS="https://git.faulty.nl/faulty/dotfiles https://github.com/faultydev/dotfiles"
for GIT in $GITS; do
  if git ls-remote "$GIT" CHECK_GIT_REMOTE_URL_REACHABILITY > /dev/null 2>&1; then
    GIT_URL="$GIT"
    break
  fi
done

if [ -z "$GIT_URL" ]; then
  __print "no git reachable"
  exit 1
fi

echo "<$0> using git url: $GIT_URL"

echo "<$0> checking for existing dotfiles"
if [ -d "$HOME/.local/dotfiles" ]; then
  echo "<$0> found existing dotfiles"
  echo "<$0> remove existing dotfiles? (Y/n)"
  read -r -n 1 -s answer
  if [ "$answer" = "y" ] || [ "$answer" = "" ]; then
    echo "<$0> removing existing dotfiles"
    rm -rf "$HOME/.local/dotfiles"
  else
    echo "<$0> exiting"
    exit 1
  fi
fi

echo "<$0> cloning dotfiles"
git clone "$GIT_URL" ~/.local/dotfiles

cd ~/.local/dotfiles

echo "<$0> executing sync.sh"
sh sync.sh

echo "<$0> done"
cd "$ORIGIN"
exit 0
