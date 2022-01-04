-- Sets game configuration settings
function love.conf(t)
	t.version = "11.3"
	t.title = "YASC - Yet Another Snake Clone" -- Sets window title.
	t.author = "kdude63" -- Sets author name for use in debug screen.
	t.window.width = 840 -- Sets window width.
	t.window.height = 456 -- Sets window height.
	t.window.msaa = 4 -- Sets FSAA level. (Anti-aliasing.)
	t.window.vsync = 1 -- Sets vsync, caps game at 60(?) fps.
	t.release = false -- Use %appdata%/LOVE/(identity) or %appdata%/(identity) as savegame directory.
end
