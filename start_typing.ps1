wezterm-gui --config-file (Join-Path $PSScriptRoot .wezterm_back.lua) start -- hx -w $PSScriptRoot "$(Join-Path $PSScriptRoot test.md):4"
sleep 0.1
wezterm-gui --config-file (Join-Path $PSScriptRoot .wezterm_front.lua) start -- hx -w $PSScriptRoot (Join-Path $PSScriptRoot test1.md)

