-- # DAP
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      "rcarriga/nvim-dap-ui",
      dependencies = {
        "nvim-neotest/nvim-nio",
      },
    },
    "theHamsta/nvim-dap-virtual-text",
    "mxsdev/nvim-dap-vscode-js",
    {
      "microsoft/vscode-js-debug",
      lazy = false,
      build = function()
        local cwd = vim.fn.getcwd()
        local plugin_path = vim.fn.stdpath("data") .. "/lazy/" .. "vscode-js-debug"
        vim.fn.chdir(plugin_path)
        vim.fn.system({
          "npm",
          "install",
          "--legacy-peer-deps",
        })
        vim.fn.system({
          "npx",
          "gulp",
          "vsDebugServerBundle",
        })
        vim.fn.system({
          "mv",
          "dist",
          "out",
        })
        vim.fn.chdir(cwd)
      end,
    },
  },
  event = "VeryLazy",
  lazy = false,
  config = function()
    local dap = require("dap")
    local dap_utils = require("dap.utils")
    -- # DAP UI
    -- # Sign
    vim.fn.sign_define("DapBreakpoint", { text = "🟥", texthl = "", linehl = "", numhl = "" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "🟧", texthl = "", linehl = "", numhl = "" })
    vim.fn.sign_define("DapLogPoint", { text = "🟩", texthl = "", linehl = "", numhl = "" })
    vim.fn.sign_define("DapStopped", { text = "🈁", texthl = "", linehl = "", numhl = "" })
    vim.fn.sign_define("DapBreakpointRejected", { text = "⬜", texthl = "", linehl = "", numhl = "" })


    -- dap-vscode-js config
    local dap_vscode_js = require("dap-vscode-js")
    dap_vscode_js.setup({
      node_path = "node",
      debugger_path = vim.fn.stdpath("data") .. "/lazy/" .. "vscode-js-debug",
      adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
      continue = function()
        if vim.fn.filereadable('.vscode/launch.json') then
          require('dap.ext.vscode').load_launchjs()
        end
        dap.continue()
      end
    })

    local exts = {
      "go",
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      -- using pwa-chrome
      "vue",
      "svelte",
    }

    for i, ext in ipairs(exts) do
      dap.configurations[ext] = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch Current File (pwa-node)",
          -- cwd = vim.fn.getcwd(),
          cwd = "${workspaceFolder}",
          args = { "${file}" },
          sourceMaps = true,
          protocol = "inspector",
        },
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch Current File (pwa-node with ts-node)",
          -- cwd = vim.fn.getcwd(),
          cwd = "${workspaceFolder}",
          runtimeArgs = { "--loader", "ts-node/esm" },
          runtimeExecutable = "node",
          args = { "${file}" },
          sourceMaps = true,
          runtimeArgs = { "--nolazy", "--inspect", "-r", "ts-node/register", "-r", "tsconfig-paths/register", "--unhandled-rejections=strict" },
          protocol = "inspector",
          skipFiles = { "<node_internals>/**", "node_modules/**" },
          resolveSourceMapLocations = {
            "${workspaceFolder}/**",
            "!**/node_modules/**",
          },
        },
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch Current File (pwa-node with deno)",
          -- cwd = vim.fn.getcwd(),
          cwd = "${workspaceFolder}",
          runtimeArgs = { "run", "--inspect", "--allow-all", "${file}" },
          runtimeExecutable = "deno",
          attachSimplePort = 9229,
        },
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch Test Current File (pwa-node with jest)",
          -- cwd = vim.fn.getcwd(),
          cwd = "${workspaceFolder}",
          runtimeArgs = { "${workspaceFolder}/node_modules/.bin/jest" },
          runtimeExecutable = "node",
          args = { "${file}", "--coverage", "false" },
          rootPath = "${workspaceFolder}",
          sourceMaps = true,
          console = "integratedTerminal",
          internalConsoleOptions = "neverOpen",
          skipFiles = { "<node_internals>/**", "node_modules/**" },
        },
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch Test Current File (pwa-node with vitest)",
          -- cwd = vim.fn.getcwd(),
          cwd = "${workspaceFolder}",
          program = "${workspaceFolder}/node_modules/vitest/vitest.mjs",
          args = { "--inspect", "--threads", "false", "run", "${file}" },
          autoAttachChildProcesses = true,
          smartStep = true,
          console = "integratedTerminal",
          skipFiles = { "<node_internals>/**", "node_modules/**" },
        },
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch Test Current File (pwa-node with deno)",
          cwd = vim.fn.getcwd(),
          runtimeArgs = { "test", "--inspect", "--allow-all", "${file}" },
          runtimeExecutable = "deno",
          smartStep = true,
          console = "integratedTerminal",
          attachSimplePort = 9229,
        },
        {
          type = "pwa-chrome",
          request = "attach",
          name = "Attach Program (pwa-chrome, select port)",
          program = "${file}",
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          port = function()
            return vim.fn.input("Select port: ", 9222)
          end,
          webRoot = "${workspaceFolder}",
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach Program (pwa-node, select pid)",
          cwd = vim.fn.getcwd(),
          processId = dap_utils.pick_process,
          skipFiles = { "<node_internals>/**" },
        },
      }
    end
  end
}
