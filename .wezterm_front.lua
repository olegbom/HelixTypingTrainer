local wezterm = require("wezterm")
local config = wezterm.config_builder()


local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

wezterm.on('format-window-title', function ()
	return 'TypingWeztermHelixFront'
end)

config.window_decorations = "RESIZE"
local opacity = 0.6

config.window_background_opacity = opacity
config.hide_tab_bar_if_only_one_tab = true

config.color_scheme = 'Breeze (Gogh)'
config.font =
  wezterm.font('JetBrainsMono NF', {
    weight = 'DemiBold'
  })
-- config.font = wezterm.font('Fixedsys Excelsior')
-- config.colors = { cursor_fg = 'black' };
-- config.cell_width = 9.0/8.0
config.font_size = 12
config.window_padding = {left = 0, right = 0, top = 0, bottom = 0}

config.debug_key_events = true

return config
