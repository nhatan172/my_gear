---@type NvPluginSpec
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose" },
  init = function()
    local map = vim.keymap.set
    -- map("n", "<leader>dV", "<cmd>DiffviewOpen<CR>", { desc = "Diffview open" })
    -- map("n", "<leader>dC", "<cmd>DiffviewClose<CR>", { desc = "Diffview close" })
  end,
  config = true,
}
