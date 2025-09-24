return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        hidden = true,
        ignored = true,
        sources = {
          files = {
            hidden = true,
            ignored = true,
            exclude = {
              "**/.DS_Store",
              "**/node_modules/**",
            },
          },
        },
        win = {
          list = { keys = {
            ["<Tab>"] = "confirm",
          } },
        },
      },
      explorer = {
        hidden = true,
        ignored = true,
        sources = {
          files = {
            hidden = true,
            ignored = true,
            exclude = {
              "**/.DS_Store",
              "**/node_modules/**",
            },
          },
        },
      },
    },
  },
}
