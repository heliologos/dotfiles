return {
  "swaits/zellij-nav.nvim",
  event = "VeryLazy",
  cond = function()
    return vim.env.ZELLIJ ~= nil
  end,
  keys = {
    { "<C-h>", "<cmd>ZellijNavigateLeftTab<CR>", silent = true, desc = "Navigate left (pane/tab)" },
    { "<C-j>", "<cmd>ZellijNavigateDown<CR>", silent = true, desc = "Navigate down" },
    { "<C-k>", "<cmd>ZellijNavigateUp<CR>", silent = true, desc = "Navigate up" },
    { "<C-l>", "<cmd>ZellijNavigateRightTab<CR>", silent = true, desc = "Navigate right (pane/tab)" },
  },
  opts = {},
}
