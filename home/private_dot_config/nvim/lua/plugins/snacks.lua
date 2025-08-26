return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      hidden = true, -- for hidden files
      ignored = true, -- for .gitignore files
      win = {
        list = {
          keys = {
            ["<Tab>"] = "confirm",
          },
        },
      },
    },
    explorer = {
      files = {
        hidden = true,
      },
    },
  },
}
