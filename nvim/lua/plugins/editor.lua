return {
  -- ── fuzzy finding: the cmd+P / cmd+shift+F replacement ────────────────
  {
    "nvim-telescope/telescope.nvim",
    -- master, not 0.1.x. 0.1.x was last touched May 2024 and still calls
    -- nvim-treesitter's master-branch module API -- parsers.ft_to_lang() and
    -- configs.is_enabled(). This config pins nvim-treesitter to `main`, where
    -- `parsers` is a plain data table and `configs` no longer exists at all, so
    -- previewing a file and <leader>/ both died with
    --   attempt to call field 'ft_to_lang' (a nil value)
    -- Upstream fixed it in #3566 (treesitter: standalone implementation);
    -- master needs nvim >= 0.11 and touches no nvim-treesitter Lua API.
    branch = "master",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      { "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep in project" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Open buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help pages" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Grep word under cursor" },
      { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search in file" },
    },
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
          -- selection_caret and entry_prefix MUST have the same display width,
          -- and neither may be a byte-prefix of the other. Picker:update_prefix
          -- identifies the caret to replace by testing selection_caret first
          -- (pickers.lua), so a 1-space caret matches an unselected row's
          -- 2-space prefix, replaces only its first byte, and leaves the row one
          -- space wider every time the selection moves off it -- the whole list
          -- creeps right as you scroll.
          prompt_prefix = "  ",
          selection_caret = "❯ ",
          entry_prefix = "  ",
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          layout_config = { horizontal = { prompt_position = "top", preview_width = 0.55 } },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<Esc>"] = actions.close, -- one Esc closes, no normal-mode detour
              ["<C-u>"] = false,         -- let C-u clear the prompt instead
            },
          },
          file_ignore_patterns = { "node_modules", "%.git/", "target/", "dist/", "%.lock" },
        },
        pickers = {
          find_files = { hidden = true },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- ── syntax: real parsing, not regex ───────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").setup()

      local parsers = {
        "bash", "css", "diff", "dockerfile", "gitcommit", "gitignore", "html",
        "javascript", "jsdoc", "json", "lua", "luadoc", "markdown",
        "markdown_inline", "python", "query", "regex", "rust", "toml", "tsx",
        "typescript", "vim", "vimdoc", "yaml",
      }

      local installed = require("nvim-treesitter.config").get_installed("parsers")
      local missing = vim.tbl_filter(function(p)
        return not vim.tbl_contains(installed, p)
      end, parsers)
      if #missing > 0 then
        require("nvim-treesitter").install(missing)
      end

      -- turn on highlighting + treesitter-aware indent for any buffer
      -- that has a parser available
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          local lang = vim.treesitter.language.get_lang(ft)
          if lang and pcall(vim.treesitter.start, args.buf, lang) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  -- ── file tree sidebar ─────────────────────────────────────────────────
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle reveal<cr>", desc = "Toggle file tree" },
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        follow_current_file = { enabled = true }, -- tree tracks the open buffer
        use_libuv_file_watcher = true,            -- pick up external file changes
        filtered_items = { visible = false, hide_dotfiles = false, hide_gitignored = true },
      },
      window = {
        width = 32,
        mappings = { ["<space>"] = "none" }, -- don't steal the leader key
      },
    },
  },

  -- ── git ───────────────────────────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" }, change = { text = "▎" },
        delete = { text = "" }, topdelete = { text = "" }, changedelete = { text = "▎" },
      },
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buf, desc = desc })
        end
        map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
        map("n", "[h", function() gs.nav_hunk("prev") end, "Previous hunk")
        map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>gd", gs.diffthis, "Diff this file")
      end,
    },
  },

  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Lazygit" },
    },
  },

  -- ── small quality-of-life ─────────────────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>u", group = "ui/toggle" },
        { "<leader>x", group = "diagnostics" },
      },
    },
  },

  -- auto-close brackets and quotes
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- auto-close/rename HTML & JSX tags
  { "windwp/nvim-ts-autotag", event = "InsertEnter", opts = {} },

  -- gcc / gc{motion} comments that understand JSX and embedded languages
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    init = function()
      vim.g.skip_ts_context_commentstring_module = true
      -- teach the built-in `gc` operator to ask treesitter what the comment
      -- syntax is at the cursor, so JSX inside a .tsx file comments correctly
      local get_option = vim.filetype.get_option
      vim.filetype.get_option = function(filetype, option)
        if option ~= "commentstring" then
          return get_option(filetype, option)
        end
        local ok, cs = pcall(function()
          return require("ts_context_commentstring.internal").calculate_commentstring()
        end)
        return (ok and cs) or get_option(filetype, option)
      end
    end,
    opts = { enable_autocmd = false },
  },

  -- sa/sd/sr to add, delete, replace surrounding quotes & brackets
  { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },

  -- shows the enclosing function/class at the top of the window
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPre",
    opts = { max_lines = 3 },
  },
}
