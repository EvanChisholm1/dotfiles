return {
  -- blink.cmp: completion engine. Tab-driven, like the editor you came from.
  {
    "saghen/blink.cmp",
    version = "1.*", -- pulls a prebuilt fuzzy-matcher binary, no build step
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      -- Tab accepts the selected item, C-n/C-p move through the menu,
      -- C-space opens it manually, C-e dismisses.
      keymap = { preset = "super-tab" },

      appearance = { nerd_font_variant = "mono" },

      completion = {
        -- show the popup as you type, no keystroke needed
        trigger = { show_on_trigger_character = true },
        -- preselect the top match so Tab is always meaningful
        list = { selection = { preselect = true, auto_insert = false } },
        -- docs panel opens automatically after a short pause
        documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "rounded" } },
        -- greyed-out inline preview of the completion
        ghost_text = { enabled = true },
        menu = {
          border = "rounded",
          draw = {
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "source_name" },
            },
          },
        },
      },

      -- function signature hints while typing arguments
      signature = { enabled = true, window = { border = "rounded" } },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
