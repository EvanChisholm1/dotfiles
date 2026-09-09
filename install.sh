#!/usr/bin/env bash
# Symlink dotfiles into $HOME. Existing files are backed up to *.bak.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$DOTFILES/$1" dest="$HOME/$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    echo "  backing up existing $dest -> $dest.bak"
    rm -rf "$dest.bak"
    mv "$dest" "$dest.bak"
  fi
  ln -s "$src" "$dest"
  echo "  $dest -> $src"
}

echo "Linking dotfiles from $DOTFILES"
link tmux/tmux.conf .tmux.conf
link nvim         .config/nvim

# ── dependency check ──────────────────────────────────────────────────────
# Nothing here is fatal; the configs load without any of it. These are the
# things whose absence fails quietly rather than loudly.
missing=()
need() { command -v "$1" >/dev/null || missing+=("$1 -- $2"); }

need nvim  "the editor itself"
need git   "lazy.nvim clones plugins with it"
need rg    "telescope live_grep (<leader>fg) finds nothing without it"
need fd    "telescope file finding"
need make  "builds telescope-fzf-native"
need node  "the TypeScript language server runs on it"
need lazygit "<leader>gg / tmux git popup"

# system clipboard: nvim's unnamedplus and tmux's copy-mode yank both need a
# provider, and both fail silently when there isn't one
if [ "$(uname)" = "Darwin" ]; then
  need pbcopy "system clipboard"
elif ! command -v wl-copy >/dev/null && ! command -v xclip >/dev/null; then
  missing+=("wl-clipboard or xclip -- system clipboard (yank goes nowhere without it)")
fi

if [ ${#missing[@]} -gt 0 ]; then
  echo
  echo "Missing (optional, but things will quietly not work):"
  for m in "${missing[@]}"; do echo "  - $m"; done
fi

echo
echo "Done."
echo "  tmux: tmux source-file ~/.tmux.conf   (reload a running session)"
echo "  nvim: first launch bootstraps lazy.nvim and installs plugins;"
echo "        language servers come down via :Mason. Then :checkhealth"
