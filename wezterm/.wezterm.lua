local wezterm = require 'wezterm'

return {
  -- Font Configuration
  font = wezterm.font('MesloLGS NF'), -- Change to your preferred font
  font_size = 14.0,                  -- Adjust font size
  line_height = 1.2,                 -- Line height for better readability

  -- Colors and Appearance
  color_scheme = 'Catppuccin Macchiato', -- Popular color scheme
  enable_tab_bar = true,                 -- Show the tab bar
  hide_tab_bar_if_only_one_tab = true,   -- Hide tab bar if only one tab is open
  window_background_opacity = 0.9,       -- Transparency (set to 1.0 for no transparency)
  text_background_opacity = 1.0,         -- Ensures text is opaque
  window_decorations = "RESIZE",         -- Minimal decorations for a modern look

  -- Add Background Image
  background = {
    -- Path to the image (absolute or relative to the config directory)
    {
      source = {
        File = '/Users/tannn/Downloads/small_memory.jpg', -- Replace with the actual image path
      },
      -- opacity = 0.5,    -- Adjust opacity of the image (0.0 to 1.0)
      hsb = {
        brightness = 0.2, -- Adjust brightness (0.0 to 1.0)
        hue = 1.0,        -- Adjust hue (1.0 keeps the original color)
        saturation = 1.0, -- Adjust saturation (1.0 keeps the original saturation)
      },
    },
  },

  -- Padding around the terminal
  window_padding = {
    left = 8,
    right = 8,
    top = 8,
    bottom = 8,
  },

  -- Scrollback buffer
  scrollback_lines = 5000, -- Increase for more history in the terminal

  -- Keybindings
  keys = {
    { key = 'w', mods = 'CTRL', action = wezterm.action.CloseCurrentPane { confirm = true }},
    { key = 't', mods = 'CTRL', action = wezterm.action.SpawnTab 'CurrentPaneDomain'},
    { key = 'h', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Left'},
    { key = 'l', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Right'},
    { key = 'k', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Up'},
    { key = 'j', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Down'},
  },

  -- Mouse Support
  enable_wayland = true,               -- Enable for better Wayland support
  mouse_bindings = {
    -- Right-click paste
    {
      event = { Up = { streak = 1, button = 'Right' } },
      mods = 'NONE',
      action = wezterm.action.PasteFrom 'Clipboard',
    },
  },

  -- Tab Bar Styling
  tab_bar_at_bottom = true,            -- Place the tab bar at the bottom
  use_fancy_tab_bar = true,
  colors = {
    tab_bar = {
      background = '#1e1e2e',
      active_tab = {
        bg_color = '#575268',
        fg_color = '#ffffff',
        italic = false,
      },
      inactive_tab = {
        bg_color = '#1e1e2e',
        fg_color = '#808080',
      },
      inactive_tab_hover = {
        bg_color = '#313244',
        fg_color = '#c0caf5',
        italic = true,
      },
      new_tab = {
        bg_color = '#1e1e2e',
        fg_color = '#808080',
      },
    },
  },
}
