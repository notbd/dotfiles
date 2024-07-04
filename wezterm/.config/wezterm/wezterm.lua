-- wezterm.lua
-- Configuration file for wezterm
-- by TWZ


-- Pull in the wezterm API
local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = 'Poimandres'

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 20

config.enable_tab_bar = true

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.75
config.macos_window_background_blur = 32

config.keys = {
  -- CMD + Delete to delete line left of cursor
  {
    key = 'Backspace',
    mods = 'SUPER',
    action = wezterm.action.SendString '\x18\x7f',
  },
  -- CMD + Fn + Delete to delete line right of cursor
  {
    key = 'Delete',
    mods = 'SUPER',
    action = wezterm.action.SendString '\x0b',
  },
  -- OPT + Delete to delete word left of cursor
  {
    key = 'Backspace',
    mods = 'OPT',
    action = wezterm.action.SendString '\x1b\x08',
  },
  -- OPT + Fn + Delete to delete word right of cursor
  {
    key = 'Delete',
    mods = 'OPT',
    action = wezterm.action.SendString '\x1b\x64',
  },
  -- Undo
  {
    key = 'z',
    mods = 'SUPER',
    action = wezterm.action.SendString '\x1f',
  },
  -- Redo
  {
    key = 'z',
    mods = 'SUPER|SHIFT',
    action = wezterm.action.SendString '\x18\x1f',
  },
}

-- return the configuration to wezterm
return config
