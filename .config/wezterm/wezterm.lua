local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-- General
config.enable_wayland = true
config.check_for_updates = false
config.scrollback_lines = 10000
config.audible_bell = 'Disabled'
config.window_close_confirmation = 'NeverPrompt'
config.adjust_window_size_when_changing_font_size = false

-- Mouse ergonomics
config.hide_mouse_cursor_when_typing = true

-- Fonts and Style
config.font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Regular' })
config.font_size = 11.5
config.line_height = 1.15
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

config.color_scheme = 'tokyonight'
config.window_padding = {
    left = 12,
    right = 12,
    top = 10,
    bottom = 10,
}

config.initial_cols = 130
config.initial_rows = 40

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

config.window_background_opacity = 0.98

-- Cross-platform Defaults
if wezterm.target_triple:find("windows") then
    config.default_prog = { 'powershell.exe', '-NoLogo' }
elseif wezterm.target_triple:find("linux") then
    config.default_prog = { '/usr/bin/zsh' }
end

-- Keybindings
config.keys = {
    { key = 'c', mods = 'CTRL|SHIFT', action = wezterm.action.CopyTo 'Clipboard' },
    { key = 'v', mods = 'CTRL|SHIFT', action = wezterm.action.PasteFrom 'Clipboard' },
}

return config
