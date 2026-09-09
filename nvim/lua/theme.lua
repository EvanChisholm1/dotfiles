-- Colorscheme persistence.
--
-- The active colorscheme is stored outside the config, in stdpath("data"),
-- so switching themes never means editing a file. <leader>uc picks one.

local M = {}

local state_file = vim.fn.stdpath("data") .. "/colorscheme"

-- matches Ghostty's `theme = Zenwritten Dark`
M.fallback = "zenwritten"

function M.remember(name)
  pcall(vim.fn.writefile, { name }, state_file)
end

function M.recall()
  if vim.fn.filereadable(state_file) == 1 then
    local lines = vim.fn.readfile(state_file)
    if lines[1] and lines[1] ~= "" then return lines[1] end
  end
end

-- zenwritten's bright-black sits a shade darker than the value Ghostty
-- ships for the same theme. Pinning it means :terminal programs -- lazygit
-- especially -- render identically inside nvim and outside it.
local terminal_fixups = {
  zenwritten = { terminal_color_8 = "#4a4546" },
}

local function align_terminal_colors(name)
  local fixes = terminal_fixups[name]
  if not fixes then return end
  for k, v in pairs(fixes) do vim.g[k] = v end
end

function M.apply()
  -- persist every colorscheme change from here on. Telescope's picker
  -- restores the previous scheme when you cancel, which fires this again,
  -- so backing out of the picker correctly leaves things as they were.
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function(ev)
      M.remember(ev.match)
      align_terminal_colors(ev.match)
    end,
  })

  local want = M.recall() or M.fallback
  if not pcall(vim.cmd.colorscheme, want) then
    pcall(vim.cmd.colorscheme, M.fallback)
  end
end

return M
