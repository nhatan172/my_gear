-- unused
---@type NvPluginSpec

return {
  "nvim-tree/nvim-tree.lua",
  enabled = true,
  lazy = false,
  init = function()
    vim.keymap.set("n", "<C-a>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
  end,
  config = function()
    dofile(vim.g.base46_cache .. "nvimtree")

    local nvtree = require "nvim-tree"
    local api = require "nvim-tree.api"

    local function edit_or_open()
      local node = api.tree.get_node_under_cursor()

      if node.nodes ~= nil then
        -- expand or collapse folder
        api.node.open.edit()
      else
        -- open file
        api.node.open.edit()
        -- Close the tree if file was opened
        api.tree.close()
      end
    end


    -- open as vsplit on current node
    local function vsplit_preview()
      local node = api.tree.get_node_under_cursor()

      if node.nodes ~= nil then
        -- expand or collapse folder
        api.node.open.edit()
      else
        -- open file as vsplit
        api.node.open.vertical()
      end

      -- Finally refocus on tree if it was lost
      api.tree.focus()
    end

    local function copy_file_to(node)
      local file_src = node['absolute_path']
      -- The args of input are {prompt}, {default}, {completion}
      -- Read in the new file path using the existing file's path as the baseline.
      local file_out = vim.fn.input("COPY TO: ", file_src, "file")
      -- Create any parent dirs as required
      local dir = vim.fn.fnamemodify(file_out, ":h")
      vim.fn.system { 'mkdir', '-p', dir }
      -- Copy the file
      vim.fn.system { 'cp', '-R', file_src, file_out }
    end

    local function find_directory_and_focus()
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      local function open_nvim_tree(prompt_bufnr, _)
        actions.select_default:replace(function()
          local api = require("nvim-tree.api")

          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          api.tree.open()
          api.tree.find_file(selection.cwd .. "/" .. selection.value)
        end)
        return true
      end

      require("telescope.builtin").find_files({
        find_command = { "fd", "--type", "directory", "--hidden", "--exclude", ".git/*" },
        attach_mappings = open_nvim_tree,
      })
    end


    local tree_actions = {
      {
        name = "Create node",
        handler = require("nvim-tree.api").fs.create,
      },
      {
        name = "Remove node",
        handler = require("nvim-tree.api").fs.remove,
      },
      {
        name = "Trash node",
        handler = require("nvim-tree.api").fs.trash,
      },
      {
        name = "Rename node",
        handler = require("nvim-tree.api").fs.rename,
      },
      {
        name = "Fully rename node",
        handler = require("nvim-tree.api").fs.rename_sub,
      },
      {
        name = "Copy",
        handler = require("nvim-tree.api").fs.copy.node,
      },

      -- ... other custom actions you may want to display in the menu
    }

    local function tree_actions_menu(node)
      local entry_maker = function(menu_item)
        return {
          value = menu_item,
          ordinal = menu_item.name,
          display = menu_item.name,
        }
      end

      local finder = require("telescope.finders").new_table({
        results = tree_actions,
        entry_maker = entry_maker,
      })

      local sorter = require("telescope.sorters").get_generic_fuzzy_sorter()

      local default_options = {
        finder = finder,
        sorter = sorter,
        attach_mappings = function(prompt_buffer_number)
          local actions = require("telescope.actions")

          -- On item select
          actions.select_default:replace(function()
            local state = require("telescope.actions.state")
            local selection = state.get_selected_entry()
            -- Closing the picker
            actions.close(prompt_buffer_number)
            -- Executing the callback
            selection.value.handler(node)
          end)

          -- The following actions are disabled in this example
          -- You may want to map them too depending on your needs though
          actions.add_selection:replace(function() end)
          actions.remove_selection:replace(function() end)
          actions.toggle_selection:replace(function() end)
          actions.select_all:replace(function() end)
          actions.drop_all:replace(function() end)
          actions.toggle_all:replace(function() end)

          return true
        end,
      }

      -- Opening the menu
      require("telescope.pickers").new({ prompt_title = "Tree menu" }, default_options):find()
    end

    -- local function toggle_replace()
    --[[ local api = require("nvim-tree.api")
      if api.tree.is_visible() then
        api.tree.close()
      else
        api.node.open.replace_tree_buffer()
      end
    end ]]

    -- Add custom mappings
    local function custom_on_attach(bufnr)
      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      api.config.mappings.default_on_attach(bufnr)
      vim.api.nvim_set_keymap("n", "<C-a>", ":NvimTreeToggle<cr>", { silent = true, noremap = true })

      -- on_attach
      vim.keymap.set("n", "l", edit_or_open, opts("Edit Or Open"))
      vim.keymap.set("n", "L", vsplit_preview, opts("Vsplit Preview"))
      -- vim.keymap.set("n", "h", api.tree.close, opts("Close"))
      vim.keymap.set("n", "H", api.tree.collapse_all, opts("Collapse All"))
      local map = vim.keymap.set
      map("n", "+", api.tree.change_root_to_node, opts "CD")
      map("n", "?", api.tree.toggle_help, opts "Help")
      map("n", "<ESC>", api.tree.close, opts "Close")
      -- custom mappings
      map('n', '<C-t>', api.tree.change_root_to_parent, opts('Up'))

      map('n', '<c>', copy_file_to, opts('Copy File'))
      vim.keymap.set("n", "E", api.tree.expand_all, opts "Expand All")
      -- vim.keymap.set("n", "fd", find_directory_and_focus)
      vim.keymap.set("n", "<leader>am", tree_actions_menu, { buffer = bufnr, noremap = true, silent = true })
    end

    local path_sep = package.config:sub(1, 1)

    local function trim_sep(path)
      return path:gsub(path_sep .. "$", "")
    end

    local function uri_from_path(path)
      return vim.uri_from_fname(trim_sep(path))
    end

    local function is_sub_path(path, folder)
      path = trim_sep(path)
      folder = trim_sep(folder)
      if path == folder then
        return true
      else
        return path:sub(1, #folder + 1) == folder .. path_sep
      end
    end

    local function check_folders_contains(folders, path)
      for _, folder in pairs(folders) do
        if is_sub_path(path, folder.name) then
          return true
        end
      end
      return false
    end

    local function match_file_operation_filter(filter, name, type)
      if filter.scheme and filter.scheme ~= "file" then
        -- we do not support uri scheme other than file
        return false
      end
      local pattern = filter.pattern
      local matches = pattern.matches

      if type ~= matches then
        return false
      end

      local regex_str = vim.fn.glob2regpat(pattern.glob)
      if vim.tbl_get(pattern, "options", "ignoreCase") then
        regex_str = "\\c" .. regex_str
      end
      return vim.regex(regex_str):match_str(name) ~= nil
    end

    -- Automatically open file upon creation
    api.events.subscribe(api.events.Event.FileCreated, function(file)
      vim.cmd("edit " .. file.fname)
    end)

    -- Automatically detect and update renamed paths
    api.events.subscribe(api.events.Event.NodeRenamed, function(data)
      local stat = vim.uv.fs_stat(data.new_name)
      if not stat then
        return
      end
      local type = ({ file = "file", directory = "folder" })[stat.type]
      local clients = vim.lsp.get_clients {}
      for _, client in ipairs(clients) do
        if check_folders_contains(client.workspace_folders, data.old_name) then
          local filters = vim.tbl_get(client.server_capabilities, "workspace", "fileOperations", "didRename", "filters")
              or {}
          for _, filter in pairs(filters) do
            if
                match_file_operation_filter(filter, data.old_name, type)
                and match_file_operation_filter(filter, data.new_name, type)
            then
              client.notify(
                "workspace/didRenameFiles",
                { files = { { oldUri = uri_from_path(data.old_name), newUri = uri_from_path(data.new_name) } } }
              )
            end
          end
        end
      end
    end)

    local SIZES = {
      HEIGHT = 0.8,
      WIDTH = 0.25,
    }

    nvtree.setup {
      update_focused_file = {
        enable = true,
      },
      actions = {
        open_file = {
          quit_on_open = false,
        }
      },
      on_attach = custom_on_attach,
      sync_root_with_cwd = true,
      filters = { custom = { "^.git$" } },
      git = { enable = true },
      renderer = {
        highlight_git = "none",
        icons = {
          glyphs = {
            folder = {
              default = "",
              open = "",
              empty = "",
              empty_open = "",
            },
            git = {
              unstaged = "",
              staged = "",
              unmerged = "",
              renamed = "",
              untracked = "",
              deleted = "",
              ignored = "󰴲",
            },
          },
        },
      },
      --[[ preview = {
        enable = true,
        width = 60,
        height = 30
      }, ]]
      view = {
        -- Allow statuscolumn to be applied on nvim-tree
        preserve_window_proportions = true,
        -- side = "left",
        side = "left",
        signcolumn = "no",
        --[[ float = {
          enable = true,
          open_win_config = function()
            local screen_w = vim.opt.columns:get()
            local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
            local window_w = screen_w * SIZES.WIDTH
            local window_h = screen_h * SIZES.HEIGHT
            local window_w_int = math.floor(window_w)
            local window_h_int = math.floor(window_h)
            local center_x = (screen_w - window_w) / 2
            local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
            return {
              border = "rounded",
              relative = "editor",
              row = center_y,
              col = center_x,
              width = window_w_int,
              height = window_h_int,
            }
          end,
        }, ]]
        width = function()
          return math.floor(vim.opt.columns:get() * SIZES.WIDTH)
        end,
      },
      filesystem_watchers = {
        ignore_dirs = {
          -- "node_modules",
        },
      },
    }
  end,
}
