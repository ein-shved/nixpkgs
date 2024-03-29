local M = {}

local separator = "#808080"

M.tabufline = {
  enabled = false,
}

M.theme = "chocolate"

M.changed_themes = {
  chocolate = {
    base30 = {
      statusline_bg = separator,
    },
    base_16 = {
      base0E = "#8080f0",
      base02 = "#584838",
    },
  },
}

M.hl_override = {
  WinSeparator = { bg = separator },
  Comment = {
    fg = "#909090",
    italic = true,
  },
  Keyword = { fg = "#8080f0" },
}

M.hl_add = {
  GitBlame = { fg = "#404050" },
  DapBreakpoint = { fg = '#993939', },
  DapLogPoint = { fg = '#61afef',  },
  DapStopped = { fg = '#98c379',  },
}

M.statusline = require("custom.statusline")

return M
