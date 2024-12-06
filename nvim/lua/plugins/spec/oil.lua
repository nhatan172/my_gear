---@type NvPluginSpec
return {
  "stevearc/oil.nvim",
  event = "VeryLazy",
  enabled = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function(_, opts)
    local autocmd = vim.api.nvim_create_autocmd
    local augroup = vim.api.nvim_create_augroup
    local oil = require "oil"
    local util = require "oil.util"
    local utils = require "gale.utils"
    local map = utils.glb_map
    local buf_map = utils.buf_map

    _G.oil_details_expanded = false
    _G.get_oil_winbar = function()
      local dir = oil.get_current_dir()
      if dir then
        return "%#OilWinbar#" .. vim.fn.fnamemodify(dir, ":~")
      else
        return "%#OilWinbar#" .. vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
      end
    end

    -- Workaround to issue with oil-vcs-status when toggling too quickly
    local debounced_close = utils.debounce(function()
      vim.g.oil_is_open = false
      oil.close()
    end, 100)

    _G.oil_is_open = false
    local toggle_oil = function()
      if util.is_oil_bufnr(vim.api.nvim_get_current_buf()) and vim.g.oil_is_open then
        debounced_close()
      else
        vim.g.oil_is_open = true
        oil.open()
      end
    end

    -- helper function to parse output
    local function parse_output(proc)
      local result = proc:wait()
      local ret = {}
      if result.code == 0 then
        for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
          -- Remove trailing slash
          line = line:gsub("/$", "")
          ret[line] = true
        end
      end
      return ret
    end

    -- build git status cache
    local function new_git_status()
      return setmetatable({}, {
        __index = function(self, key)
          local ignore_proc = vim.system(
            { "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
            {
              cwd = key,
              text = true,
            }
          )
          local tracked_proc = vim.system({ "git", "ls-tree", "HEAD", "--name-only" }, {
            cwd = key,
            text = true,
          })
          local ret = {
            ignored = parse_output(ignore_proc),
            tracked = parse_output(tracked_proc),
          }

          rawset(self, key, ret)
          return ret
        end,
      })
    end

    local git_status = new_git_status()

    -- Clear git status cache on refresh
    local refresh = require("oil.actions").refresh
    local orig_refresh = refresh.callback
    refresh.callback = function(...)
      git_status = new_git_status()
      orig_refresh(...)
    end

    autocmd("FileType", {
      desc = "Disable Oil toggler in telescope buffers.",
      pattern = "Telescope*",
      group = augroup("OilTelescope", { clear = true }),
      callback = function(event)
        buf_map(event.buf, "n", "<C-n>", "<nop>")
      end,
    })

    ---@type oil.SetupOpts
    local new_opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      watch_for_changes = true,
      cleanup_delay_ms = 0,
      win_options = {
        winbar = "%!v:lua.get_oil_winbar()",
        signcolumn = "yes:1",
      },
      view_options = {
        is_hidden_file = function(name, bufnr)
          local dir = oil.get_current_dir(bufnr)
          local is_dotfile = vim.startswith(name, ".") and name ~= ".."
          -- if no local directory (e.g. for ssh connections), just hide dotfiles
          if not dir then
            return is_dotfile
          end
          -- dotfiles are considered hidden unless tracked
          if is_dotfile then
            return not git_status[dir].tracked[name]
          else
            -- Check if file is gitignored
            return git_status[dir].ignored[name]
          end
        end,
        show_hidden = true,
        is_always_hidden = function(name, bufnr)
          return false
        end,
      },
      -- Configuration for the floating window in oil.open_float
      float = {
        -- Padding around the floating window
        padding = 2,
        max_width = 0,
        max_height = 0,
        border = "rounded",
        win_options = {
          winblend = 0,
        },
        -- optionally override the oil buffers window title with custom function: fun(winid: integer): string
        get_win_title = nil,
        -- preview_split: Split direction: "auto", "left", "right", "above", "below".
        preview_split = "auto",
        -- This is the config that will be passed to nvim_open_win.
        -- Change values here to customize the layout
        override = function(conf)
          return conf
        end,
      },
      -- Configuration for the actions floating preview window
      preview = {
        -- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        -- min_width and max_width can be a single value or a list of mixed integer/float types.
        -- max_width = {100, 0.8} means "the lesser of 100 columns or 80% of total"
        max_width = 0.9,
        -- min_width = {40, 0.4} means "the greater of 40 columns or 40% of total"
        min_width = { 40, 0.4 },
        -- optionally define an integer/float for the exact width of the preview window
        width = nil,
        -- Height dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        -- min_height and max_height can be a single value or a list of mixed integer/float types.
        -- max_height = {80, 0.9} means "the lesser of 80 columns or 90% of total"
        max_height = 0.9,
        -- min_height = {5, 0.1} means "the greater of 5 columns or 10% of total"
        min_height = { 5, 0.1 },
        -- optionally define an integer/float for the exact height of the preview window
        height = nil,
        border = "rounded",
        win_options = {
          winblend = 0,
        },
        -- Whether the preview window is automatically updated when the cursor is moved
        update_on_cursor_moved = true,
      },
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<Tab>"] = "actions.select",
        ["<C-s>"] = false,
        ["<C-v>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" },
        ["<C-h>"] = { "actions.select", opts = { horizontal = true }, desc = "Open the entry in a horizontal split" },
        ["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open the entry in new tab" },
        ["<C-p>"] = "actions.preview",
        ["<C-l>"] = "actions.refresh",
        ["<C-c>"] = false,
        ["q"] = "actions.close",
        ["-"] = "actions.parent",
        ["<S-Tab>"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to the current oil directory" },
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["I"] = "actions.toggle_hidden",
        ["g\\"] = "actions.toggle_trash",
        ["<leader>de"] = {
          callback = function()
            vim.g.oil_details_expanded = not vim.g.oil_details_expanded
            if vim.g.oil_details_expanded then
              oil.set_columns { "icon", "permissions", "size", "mtime" }
            else
              oil.set_columns { "icon" }
            end
          end,
          desc = "Toggle file detail view",
        },
      },
    }

    -- map("n", "<C-n>", function()
    --   toggle_oil()
    -- end, { desc = "Open Oil" })

    opts = vim.tbl_deep_extend("force", opts, new_opts)
    return opts
  end,
}
