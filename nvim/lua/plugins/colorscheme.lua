-- Colorschemes.
--
-- <leader>uc opens a picker that previews each one live as you scroll.
-- Whatever you land on is remembered and restored next launch -- see
-- lua/theme.lua. There is nothing to edit here to change your theme.

return {
  -- ── the options ───────────────────────────────────────────────────────
  -- all eager, because a colorscheme has to be on the runtimepath before
  -- the picker can find it. Loading one only defines a `colors/` file;
  -- it costs a few ms total and applies nothing until asked.

  -- zenwritten: the exact palette Ghostty is running (theme = Zenwritten
  -- Dark). Same author, same hex values, so the editor and the terminal
  -- around it are one surface -- bg #191919, fg #bbbbbb.
  {
    "mcchrish/zenbones.nvim",
    dependencies = { "rktjmp/lush.nvim" },
    lazy = false,
    priority = 1000,
    init = function()
      vim.o.background = "dark"
      vim.g.zenwritten_lightness = "dim"
      vim.g.zenwritten_italic_comments = true
      vim.g.zenwritten_transparent_background = false
    end,
  },

  -- VSCode Dark+/Light+, if you want your old colors back verbatim
  { "Mofiqul/vscode.nvim", lazy = false, priority = 100 },

  -- muted ink-wash palette, warm greys, low eye strain
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 100,
    opts = {
      compile = false,
      dimInactive = true,
      theme = "wave",       -- also: "dragon" (darker, greyer), "lotus" (light)
      background = { dark = "wave", light = "lotus" },
    },
  },

  -- warm retro, the highest contrast option here
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 100,
    opts = { contrast = "hard", transparent_mode = false },
  },

  -- soft pastels, four flavours from near-black to cream
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 100,
    opts = {
      flavour = "mocha",    -- mocha | macchiato | frappe | latte
      integrations = {
        blink_cmp = true, gitsigns = true, neotree = true,
        telescope = true, treesitter = true, which_key = true,
      },
    },
  },

  -- desaturated rose and pine, quiet
  { "rose-pine/neovim", name = "rose-pine", lazy = false, priority = 100,
    opts = { styles = { italic = false } } },

  -- green, forest, gentle contrast
  { "sainnhe/everforest", lazy = false, priority = 100,
    init = function() vim.g.everforest_background = "medium" end },

  -- IBM Carbon: near-black with high-saturation accents
  { "nyoom-engineering/oxocarbon.nvim", lazy = false, priority = 100 },

  -- a family: nightfox, duskfox, nordfox, terafox, carbonfox
  { "EdenEast/nightfox.nvim", lazy = false, priority = 100 },

  -- the one you just rejected, kept for its light "day" variant
  { "folke/tokyonight.nvim", lazy = false, priority = 100,
    opts = { style = "night" } },

  -- ── the picker ───────────────────────────────────────────────────────
  -- requiring telescope.builtin loads telescope on demand, so this stays
  -- out of the startup path
  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    keys = {
      {
        "<leader>uc",
        function() require("telescope.builtin").colorscheme({ enable_preview = true }) end,
        desc = "Pick a colorscheme",
      },
    },
  },
}
