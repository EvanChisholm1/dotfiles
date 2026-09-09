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
# Split by consequence. HARD deps make nvim throw visible errors; SOFT deps
# fail quietly, which is worse to debug.
hard=() soft=()
have() { command -v "$1" >/dev/null 2>&1; }

# tree-sitter CLI: nvim-treesitter is pinned to its `main` branch, which shells
# out to `tree-sitter generate` / `tree-sitter build` for every parser. Without
# it, parser installs fail outright with
#   Error during "tree-sitter build": ENOENT ... 'tree-sitter'
# and :checkhealth reports "tree-sitter-cli not found". Needs >= 0.26.1.
TS_MIN="0.26.1"
if ! have tree-sitter; then
  hard+=("tree-sitter (>= $TS_MIN) -- REQUIRED to install treesitter parsers")
else
  ts_ver="$(tree-sitter --version 2>/dev/null | awk '{print $2}')"
  if [ -n "$ts_ver" ] && [ "$(printf '%s\n%s\n' "$TS_MIN" "$ts_ver" | sort -V | head -1)" != "$TS_MIN" ]; then
    hard+=("tree-sitter $ts_ver is too old -- need >= $TS_MIN")
  fi
fi

have cc   || hard+=("a C compiler (cc) -- treesitter parsers are compiled from C")
have git  || hard+=("git -- lazy.nvim clones plugins with it")
have make || hard+=("make -- builds telescope-fzf-native")

# Mason downloads and unpacks language servers with these
have curl  || soft+=("curl -- Mason downloads language servers with it")
have unzip || soft+=("unzip -- Mason unpacks some servers with it")

# node/npm gate most of the language servers. Mason shells out to `npm` for
# ts_ls, pyright, and eslint/jsonls/html/cssls -- those last four are all one
# npm package (vscode-langservers-extracted), so they fail as a group. Only
# lua_ls and ruff come from GitHub releases and survive without node.
# Note nvm installs node into your shell rc, so a GUI-launched nvim can have
# node on PATH in a terminal and not see it at all. Check inside nvim with
#   :lua print(vim.fn.exepath("npm"))
if ! have node || ! have npm; then
  soft+=("node + npm -- REQUIRED for 6 of the 8 language servers:")
  soft+=("    ts_ls, pyright, eslint, jsonls, html, cssls")
  soft+=("    (only lua_ls and ruff work without it)")
fi

have rg   || soft+=("ripgrep (rg) -- <leader>fg live_grep silently finds nothing")
have fd   || soft+=("fd -- telescope file finding falls back to a slower walk")
have lazygit || soft+=("lazygit -- <leader>gg")

# rust-analyzer is enabled unconditionally but comes from rustup, not Mason,
# so on a box without a Rust toolchain it just never attaches, with no error.
have rust-analyzer || soft+=("rust-analyzer -- 'rustup component add rust-analyzer'")
have rustfmt       || soft+=("rustfmt -- format-on-save for .rs files")

# system clipboard: nvim's unnamedplus and tmux's copy-mode yank both need a
# provider, and both fail silently when there isn't one
if [ "$(uname)" = "Darwin" ]; then
  have pbcopy || soft+=("pbcopy -- system clipboard")
elif ! have wl-copy && ! have xclip; then
  soft+=("wl-clipboard or xclip -- system clipboard (yank goes nowhere without it)")
fi

if [ ${#hard[@]} -gt 0 ]; then
  echo
  echo "MISSING REQUIRED:"
  for m in "${hard[@]}"; do echo "  ! $m"; done
  echo
  if [ "$(uname)" = "Darwin" ]; then
    echo "  brew install tree-sitter"
    echo "  xcode-select --install     # for cc, if missing"
  else
    echo "  cargo install tree-sitter-cli     # or: npm i -g tree-sitter-cli,"
    echo "                                    # or your distro's tree-sitter-cli"
    echo "  sudo apt install build-essential  # for cc, if missing"
  fi
fi

if [ ${#soft[@]} -gt 0 ]; then
  echo
  echo "Missing (optional -- these fail quietly rather than loudly):"
  # entries starting with spaces are continuation lines, not new bullets
  for m in "${soft[@]}"; do
    case "$m" in
      "  "*) echo "  $m" ;;
      *)     echo "  - $m" ;;
    esac
  done
fi

echo
echo "Done."
echo "  tmux: tmux source-file ~/.tmux.conf   (reload a running session)"
echo "  nvim: first launch bootstraps lazy.nvim and installs plugins;"
echo "        language servers come down via :Mason. Then :checkhealth"
