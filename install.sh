#!/bin/sh

set -e

REPO=${REPO:-M3te0r/dotfiles}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-main}

USER=${USER:-$(id -u -n)}
# $HOME is defined at the time of login, but it could be unset. If it is unset,
# a tilde by itself (~) will not be expanded to the current user's home directory.
# POSIX: https://pubs.opengroup.org/onlinepubs/009696899/basedefs/xbd_chap08.html#tag_08_03
HOME="${HOME:-$(getent passwd $USER 2>/dev/null | cut -d: -f6)}"
# macOS does not have getent, but this works even if $HOME is unset
HOME="${HOME:-$(eval echo ~$USER)}"
DEST_DIR_NAME="${DEST_DIR_NAME:-dotfiles}"
DEST_DIR="${DEST_DIR:-$HOME/$DEST_DIR_NAME}"
ZDOTDIR="${ZDOTDIR:-$DEST_DIR/zsh}"


if [ ! -d "$DEST_DIR" ]; then
  git init --quiet "$DEST_DIR" && cd "$DEST_DIR" \
  && git config core.eol lf \
  && git config core.autocrlf false \
  && git config fsck.zeroPaddedFilemode ignore \
  && git config fetch.fsck.zeroPaddedFilemode ignore \
  && git config receive.fsck.zeroPaddedFilemode ignore \
  && git config dotfile.remote origin \
  && git config dotfiles.branch "$BRANCH" \
  && git remote add origin "$REMOTE" \
  && git fetch --depth=1 origin \
  && git checkout -b "$BRANCH" "origin/$BRANCH" || {
    [ ! -d "$DEST_DIR" ] || {
      cd -
      rm -rf "$DEST_DIR" 2>/dev/null
    }
    echo "git clone of dotfiles repo failed"
    exit 1
  }
  # Exit installation directory
  cd -
else
  cd "$DEST_DIR"
  git pull --quiet --rebase $REMOTE $BRANCH
  cd -
fi


cat <<EOF > $HOME/.zshenv
ZDOTDIR=~/$DEST_DIR_NAME/zsh
#source -- "\$ZDOTDIR"/.zshenv
EOF




#sh -c "$(curl -fsSL https://raw.githubusercontent.com/M3te0r/dotfiles/main/install.sh)"
