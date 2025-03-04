---@type NvPluginSpec
return {
  "mgastonportillo/yerbreak.nvim",
  dependencies = { "rcarriga/nvim-notify" },
  cmd = "Yerbreak",
  event = "VeryLazy",
  init = function()
    vim.keymap.set("n", "<leader>yb", "<cmd>Yerbreak<CR>", { desc = "Toggle Yerbreak" })
  end,
  opts = {
    ascii_table = "op",
    delay = 2000,
    border = "none",
  },
  config = function (_, opts)
    require("yerbreak").setup(opts)
    
    -- local last_activity = vim.loop.now()
    -- local afk_time = 120000
    -- local timer = vim.loop.new_timer()

    -- local function check_afk()
    --   local now = vim.loop.now()

    --   if now - last_activity >= afk_time then
    --     vim.cmd("Yerbreak")

    --     if timer and not timer:is_closing() then
    --       timer:stop()
    --     end
    --   end
    -- end

    -- vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
    --   callback = function()
    --     if timer and not timer:is_closing() then
    --       timer:stop()
    --     end
    --     timer:start(1000, 1000, vim.schedule_wrap(check_afk))

    --   end
    -- })

    -- vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
    --   callback = function()
    --     last_activity = vim.loop.now()
    --   end
    -- })
  end,
}
