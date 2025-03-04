return {
  "zbirenbaum/copilot.lua", -- Use the correct plugin name
  cmd = "Copilot",          -- Load only when :Copilot is called
  event = "InsertEnter",    -- Lazy-load when entering insert mode
  config = function()
    require("copilot").setup({
      suggestion = { enabled = true }, -- Enable inline suggestions
      panel = { enabled = true },      -- Enable the Copilot panel
    })
  end,
}
