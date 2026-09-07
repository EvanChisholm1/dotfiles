#!/usr/bin/env bash
# Symlink dotfiles into $HOME. Existing files are backed up to *.bak.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$DOTFILES/$1" dest="$HOME/$2"
  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    echo "  backing up existing $dest -> $dest.bak"
    mv "$dest" "$dest.bak"
  fi
  ln -s "$src" "$dest"
  echo "  $dest -> $src"
}

echo "Linking dotfiles from $DOTFILES"
link tmux/tmux.conf .tmux.conf

echo
echo "Done. Reload a running tmux with: tmux source-file ~/.tmux.conf"
