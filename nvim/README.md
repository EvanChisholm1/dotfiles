# nvim config

Leader is `<Space>`. Press it and wait — which-key shows what's available.

## Layout
```
init.lua              leader, bootstrap, lazy.nvim options
lua/options.lua       editor defaults
lua/keymaps.lua       non-plugin keymaps
lua/plugins/lsp.lua   mason, lspconfig, per-server settings, conform (format)
lua/plugins/cmp.lua   blink.cmp autocomplete
lua/plugins/editor.lua telescope, treesitter, neo-tree, git, small QoL
lua/plugins/ui.lua    lualine, bufferline, indent guides
lua/plugins/colorscheme.lua  the 30 themes
lua/theme.lua         remembers which theme you picked
```

## Coming from VSCode
| VSCode | here |
|---|---|
| Cmd+P | `<Space><Space>` |
| Cmd+Shift+F | `<Space>fg` |
| Cmd+F | `<Space>/` |
| Cmd+B (sidebar) | `<Space>e` |
| F12 (go to def) | `gd` |
| Shift+F12 (refs) | `gr` |
| F2 (rename) | `<Space>cr` |
| Cmd+. (quick fix) | `<Space>ca` |
| Cmd+S | `<C-s>` |
| Ctrl+` | `<Space>gg` (lazygit) |
| Tab (accept suggestion) | `Tab` |

## Keymaps
**Find** `<Space>ff` files · `fg` grep · `fb` buffers · `fr` recent · `fw` word under cursor
· `fk` keymaps · `fh` help · `fd` diagnostics · `/` search in file

**Code** `gd` def · `gr` refs · `gi` impl · `gy` type · `K` hover · `<Space>cr` rename
· `<Space>ca` action · `<Space>cf` format · `<Space>cs` symbols · `<Space>uh` toggle inlay hints

**Diagnostics** `]d` / `[d` next/prev · `<Space>xd` show on this line

**Git** `<Space>gg` lazygit · `gp` preview hunk · `gs` stage · `gr` reset · `gb` blame · `gd` diff
· `]h` / `[h` next/prev hunk

**Buffers** `Shift+h` / `Shift+l` prev/next · `<Space>bd` close

**Windows** `<C-h/j/k/l>` move · `<C-arrows>` resize

**Theme** `<Space>uc` pick a colorscheme — previews live as you scroll, and sticks

**Edit** `gcc` comment line · `gc{motion}` comment · `sa`/`sd`/`sr` add/delete/replace surround
· `J`/`K` in visual moves lines

## Themes
Default is `zenwritten`, which is the exact palette your Ghostty config asks for
(`theme = Zenwritten Dark` in `~/.config/ghostty/config.ghostty`) — same author,
`#191919` background, `#bbbbbb` foreground, all 16 ANSI colors identical. nvim and
the terminal around it are one surface.

`<Space>uc` to change it. 32 variants installed; the one you land on is written to
`~/.local/share/nvim/colorscheme` and restored next launch. Nothing to edit.
Cancel the picker and it puts back what you had.

If you retheme Ghostty, retheme nvim to match with the same key — or, for a palette
zenbones doesn't cover, the terminal-color alignment table lives in `lua/theme.lua`.

Others: `kanagawa-dragon`, `gruvbox`, `oxocarbon`, `carbonfox`, `catppuccin-macchiato`,
`rose-pine-moon`. `vscode` is Dark+ verbatim. Light: `zenbones`, `kanagawa-lotus`,
`rose-pine-dawn`, `dayfox`.

## Adding things
- Plugin: drop a file in `lua/plugins/`, restart, `:Lazy sync`
- Language server: add to `ensure_installed` in `lua/plugins/lsp.lua`, restart
- Formatter: add to `formatters_by_ft` in `lua/plugins/lsp.lua`; if it needs
  installing, add it to the `tools` list in the mason spec

## Go
Not installed. When you want it:
```
brew install go
```
then uncomment `"gopls"` in `ensure_installed` (lua/plugins/lsp.lua).

## Health
`:checkhealth` · `:Lazy` plugins · `:Mason` servers · `:LspInfo` what's attached
· `:ConformInfo` formatters

Format-on-save is on (500ms budget, falls back to the LSP formatter).
Prettier resolves from the project's node_modules first, so per-project config wins.
