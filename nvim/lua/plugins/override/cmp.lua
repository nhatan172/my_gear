---@type NvPluginSpec
return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    { "hrsh7th/cmp-cmdline" },
    { "brenoprata10/nvim-highlight-colors" },
  },
  config = function(_, opts)
    local cmp = require "cmp"

    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })

    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "cmdline" },
        { name = "path" },
        {
          name = "lazydev",
          group_index = 0, -- set group index to 0 to skip loading LuaLS completions
        },
      },
    })

    local colors = require "nvim-highlight-colors.color.utils"
    local utils = require "nvim-highlight-colors.utils"

    ---@class cmp.FormattingConfig
    --- This makes chadrc.ui.cmp take no effect
    opts.formatting = {
      fields = { "abbr", "kind", "menu" },

      format = function(entry, item)
        local icons = require "nvchad.icons.lspkind"
        icons.Color = "󱓻"

        local icon = " " .. icons[item.kind] .. " "
        item.kind = string.format("%s%s ", icon, item.kind)

        local entryItem = entry:get_completion_item()
        if entryItem == nil then
          return item
        end

        local entryDoc = entryItem.documentation
        if entryDoc == nil or type(entryDoc) ~= "string" then
          return item
        end

        local color_hex = colors.get_color_value(entryDoc)
        if color_hex == nil then
          return item
        end

        local highlight_group = utils.create_highlight_name("fg-" .. color_hex)
        vim.api.nvim_set_hl(0, highlight_group, { fg = color_hex, default = true })
        item.kind_hl_group = highlight_group

        return item
      end,
    }

    ---@type cmp.ConfigSchema
    local custom_opts = {
      mapping = {
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item() -- Chọn gợi ý kế tiếp
          else
            fallback()         -- Dùng hành vi Tab mặc định nếu không có gợi ý
          end
        end, { 'i', 's' }),    -- Chế độ insert và select
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item() -- Chọn gợi ý trước đó
          else
            fallback()         -- Dùng hành vi Shift-Tab mặc định nếu không có gợi ý
          end
        end, { 'i', 's' }),    -- Chế độ insert và select
      },
      window = {
        completion = {
          border = "rounded",
        },
        documentation = {
          border = "rounded",
        },
      },
    }

    opts = vim.tbl_deep_extend("force", opts, custom_opts)
    cmp.setup(opts)
  end,
}
