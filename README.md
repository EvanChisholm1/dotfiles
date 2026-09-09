# dotfiles

Personal config, set up to clone-and-go on a new machine.

## Install

```sh
git clone git@github.com:EvanChisholm1/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` symlinks configs into place, backing up anything already there to
`<name>.bak`. Because they're symlinks, edits you make afterwards land in the
repo — `git diff` in `~/dotfiles` shows what you've changed. It also reports any
missing dependency whose absence fails *quietly* (ripgrep, a clipboard
provider) rather than loudly.

## What's here

| Path             | Links to        | Notes                                     |
| ---------------- | --------------- | ----------------------------------------- |
| `tmux/tmux.conf` | `~/.tmux.conf`  | Prefix `C-a`, vim keys, no plugins        |
| `nvim/`          | `~/.config/nvim`| lazy.nvim, LSP for TS/JS + Rust + Python  |

Each has its own README: [`nvim/README.md`](nvim/README.md) is the full
keymap reference and VSCode translation table.

## First run on a new machine

1. `./install.sh`
2. Launch `nvim` — lazy.nvim bootstraps itself, then installs the 36 plugins
   pinned in `nvim/lazy-lock.json`. Treesitter parsers compile on first use.
3. Language servers install via Mason on first file open. `:Mason` to watch,
   `:checkhealth` when it settles.
4. `tmux` picks up its config on next launch.

Expect a couple of minutes of downloading on step 2–3. Everything after that
is local.

`lazy-lock.json` is committed deliberately: a fresh clone installs the exact
plugin commits running on the machine this was captured from, not whatever is
on `main` today. After a deliberate `:Lazy update`, commit the changed lockfile.

## tmux cheatsheet

Prefix is **`C-a`** (not the default `C-b`).

| Key                | Action                            |
| ------------------ | --------------------------------- |
| `prefix r`         | Reload config                     |
| `prefix \|` / `-`  | Split vertical / horizontal       |
| `prefix h/j/k/l`   | Move between panes                |
| `prefix H/J/K/L`   | Resize pane (repeatable)          |
| `prefix c`         | New window in current directory   |
| `prefix C-h/C-l`   | Previous / next window            |
| `prefix v`         | Enter copy mode (`v` select, `y` yank) |

Copy mode yanks to the system clipboard using whichever of `pbcopy`,
`wl-copy`, or `xclip` exists on the machine; with none of them it falls back
to tmux's internal buffer.

Requires tmux 3.0+ for `tmux-256color` and the `if-shell` clipboard detection.

## Requirements

`install.sh` checks all of this and tells you what's missing. The one that is
**not optional**:

- **`tree-sitter` CLI >= 0.26.1.** nvim-treesitter is pinned to its `main`
  branch, which shells out to `tree-sitter generate` / `tree-sitter build` for
  every parser. Without it, parser installs fail with
  `Error during "tree-sitter build": ENOENT ... 'tree-sitter'` and
  `:checkhealth` reports `tree-sitter-cli not found`.
  `brew install tree-sitter`, or `cargo install tree-sitter-cli`.
- A C compiler (`cc`) — parsers compile from C.
- `git`, `make`.

Quiet ones — everything loads fine, features just don't work: `rg`
(`<leader>fg`), `fd`, `node` (TypeScript server), `curl`/`unzip` (Mason),
`lazygit`, a clipboard provider, and `rust-analyzer`/`rustfmt` from rustup
(`rust_analyzer` is enabled unconditionally but never attaches without it).

## Notes / known rough edges

- **Theme sync.** nvim's colorscheme is remembered in
  `~/.local/share/nvim/colorscheme` (not in this repo — it's per-machine), and
  Ghostty's lives in `~/.config/ghostty/config.ghostty`. They're meant to
  match; nothing enforces it. `<Space>uc` in nvim to change.
- **`gr` / `gi`.** These are bound to LSP references/implementations, and are
  also prefixes of Neovim 0.11+'s built-in `grn`/`gra`/`grr`/`gri`/`grt`/`grx`.
  A complete mapping that's also a prefix makes Vim wait `timeoutlen` (400ms)
  before firing. If `gr` feels sluggish, deleting those six defaults in
  `nvim/lua/plugins/lsp.lua` clears the ambiguity.
- **Go** isn't set up. `brew install go`, then uncomment `"gopls"` in
  `nvim/lua/plugins/lsp.lua`.
