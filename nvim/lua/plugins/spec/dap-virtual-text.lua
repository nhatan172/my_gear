---@type NvPluginSpec
return {
  "theHamsta/nvim-dap-virtual-text",
  event = "LspAttach",
  setup = function()
    return {
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = true,
      show_stop_reason = true,
      commented = false,
      only_first_definition = false,
      all_references = false,
      max_lines = 100,
      trim_output = true,
      trim_output_on_ws = true,
      virt_text_pos = "eol",
      virt_lines = false,
      virt_text_win_col = nil,
      ignore_ws = false,
      toggle_update_on_ws = true,
      debounce = 100,
      use_console = true,
      console_line = nil,
      -- experimental
      virt_lines_above = true,
      virt_lines_below = true
    }
  end,
}
