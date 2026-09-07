# dotfiles

Personal config, set up to clone-and-go on a new machine.

## Install

```sh
git clone git@github.com:EvanChisholm1/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` symlinks configs into `$HOME`, backing up anything already there
to `<file>.bak`. Edits made afterwards go straight into the repo.

## What's here

| Path             | Links to       | Notes                                |
| ---------------- | -------------- | ------------------------------------ |
| `tmux/tmux.conf` | `~/.tmux.conf` | Prefix `C-a`, vim keys, no plugins   |

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
