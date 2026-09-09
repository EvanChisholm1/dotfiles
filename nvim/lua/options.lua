local o = vim.opt

-- line numbers
o.number = true
o.relativenumber = true
o.signcolumn = "yes"        -- no layout jitter when diagnostics appear
o.cursorline = true

-- indentation: 2 spaces, follow the file when it disagrees
o.expandtab = true
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.smartindent = true
o.breakindent = true

-- search
o.ignorecase = true
o.smartcase = true          -- capital letter in query => case sensitive
o.hlsearch = true
o.incsearch = true

-- splits open where you expect
o.splitright = true
o.splitbelow = true

-- files: no swap/backup, keep real undo history instead
o.swapfile = false
o.backup = false
o.undofile = true
o.undolevels = 10000

-- ux
o.mouse = "a"
-- share the system clipboard. Works out of the box on macOS (pbcopy); on
-- Linux nvim needs wl-clipboard or xclip present or this silently no-ops.
o.clipboard = "unnamedplus"
o.termguicolors = true
o.scrolloff = 8             -- keep context around the cursor
o.sidescrolloff = 8
o.wrap = false
o.confirm = true            -- prompt instead of failing on unsaved quit
o.updatetime = 200          -- faster CursorHold / gitsigns
o.timeoutlen = 400
o.splitkeep = "screen"
o.completeopt = "menu,menuone,noselect"
o.pumheight = 10
o.inccommand = "split"      -- live preview of :%s
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
o.fillchars = { eob = " " }
o.laststatus = 3            -- one global statusline
o.winborder = "rounded"     -- rounded floats everywhere (nvim 0.11+)

-- treat these as words we can jump around sensibly
vim.opt.iskeyword:append("-")

-- flash the yanked text so you can see what you grabbed
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

-- create missing parent directories on save, so `:e src/new/thing.ts`
-- followed by `:w` just works instead of failing with E212
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    if args.match:match("^%w%w+://") then return end -- leave scp:// and friends alone
    local dir = vim.fn.fnamemodify(args.match, ":p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- return to the last cursor position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
