return {
  -- Mason: installs language servers / formatters into ~/.local/share/nvim/mason
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    opts = { ui = { border = "rounded" } },
    config = function(_, opts)
      require("mason").setup(opts)

      -- formatters aren't language servers, so mason-lspconfig won't fetch
      -- them; install them on first run and then leave them alone
      local tools = { "stylua", "prettierd" }
      local reg = require("mason-registry")
      reg.refresh(function()
        for _, name in ipairs(tools) do
          local ok, pkg = pcall(reg.get_package, name)
          if ok and not pkg:is_installed() then pkg:install() end
        end
      end)
    end,
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      -- ── diagnostics ────────────────────────────────────────────────────
      vim.diagnostic.config({
        virtual_text = { prefix = "●", spacing = 2 },
        severity_sort = true,
        underline = true,
        update_in_insert = false,
        float = { border = "rounded", source = true },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.INFO]  = " ",
            [vim.diagnostic.severity.HINT]  = " ",
          },
        },
      })

      -- ── keymaps, bound only in buffers with a server attached ──────────
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local function map(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = "LSP: " .. desc })
          end
          -- required lazily inside each callback: requiring telescope.builtin
          -- out here would load all of telescope the moment any server
          -- attaches, defeating its keys/cmd lazy spec
          local function pick(name)
            return function() require("telescope.builtin")[name]() end
          end

          map("gd", pick("lsp_definitions"), "Go to definition")
          map("gr", pick("lsp_references"), "References")
          map("gi", pick("lsp_implementations"), "Implementations")
          map("gy", pick("lsp_type_definitions"), "Type definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>cs", pick("lsp_document_symbols"), "Document symbols")
          map("<leader>cS", pick("lsp_dynamic_workspace_symbols"), "Workspace symbols")
          map("K", vim.lsp.buf.hover, "Hover docs")

          -- highlight other references to whatever is under the cursor
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client:supports_method("textDocument/documentHighlight") then
            local group = vim.api.nvim_create_augroup("lsp-highlight-" .. ev.buf, { clear = true })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = ev.buf, group = group, callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = ev.buf, group = group, callback = vim.lsp.buf.clear_references,
            })
          end

          -- <leader>uh toggles inlay hints (types shown inline)
          if client and client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
            map("<leader>uh", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
            end, "Toggle inlay hints")
          end
        end,
      })

      -- ── per-server settings ────────────────────────────────────────────
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false },
            diagnostics = { globals = { "vim" } },
            hint = { enable = true },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.config("ts_ls", {
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "literals",
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = false,
              includeInlayFunctionLikeReturnTypeHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "literals",
              includeInlayFunctionParameterTypeHints = true,
            },
          },
        },
      })

      vim.lsp.config("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = true,
            check = { command = "clippy" },
            inlayHints = { closingBraceHints = { enable = false } },
          },
        },
      })

      -- ── install + enable ───────────────────────────────────────────────
      -- ensure_installed resolves each name against mason's registry index
      -- synchronously and never fetches it first. On a fresh machine that
      -- index hasn't been downloaded yet, so every lookup misses and you get
      --   Server "eslint" is not a valid entry in ensure_installed.
      --   Make sure to only provide lspconfig server names.
      -- which blames the names. They're fine; the registry just isn't there
      -- yet. Refresh first. On a warm cache mason invokes the callback
      -- immediately (registry/init.lua), so this costs nothing after run one.
      require("mason-registry").refresh(function()
        vim.schedule(function()
          require("mason-lspconfig").setup({
            ensure_installed = {
              "lua_ls",     -- Lua (this config)
              "ts_ls",      -- TypeScript / JavaScript
              "eslint",     -- JS/TS linting
              "jsonls",     -- JSON + schema validation
              "html",
              "cssls",
              "pyright",    -- Python types
              "ruff",       -- Python lint/format
              -- "gopls",   -- uncomment after `brew install go`
            },
            -- stylua/prettierd ship an --lsp mode that mason would happily
            -- enable as a second client; conform already drives them
            automatic_enable = { exclude = { "stylua", "prettierd" } },
          })
        end)
      end)

      -- rust-analyzer comes from your rustup toolchain, not Mason
      vim.lsp.enable("rust_analyzer")
    end,
  },

  -- ── formatting ────────────────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true }) end, desc = "Format buffer" },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        jsonc = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        rust = { "rustfmt" },
        python = { "ruff_format" },
      },
      -- format on save, but never block for more than half a second
      format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
    },
  },
}
