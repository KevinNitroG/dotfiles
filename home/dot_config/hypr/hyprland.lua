-- Hyprland loads this file when it is started without a config, and it prefers
-- it over hyprland.conf. HyDE loads it too, last, as the override layer below.
-- The block keeps the two apart: hyde.lua sets `hyde` on its first line, so it
-- runs only when this file is the entry point and HyDE has not been loaded.
-- Removing it leaves a session with a cursor and nothing else.
if not hyde then
	local share = os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")
	local entry = share .. "/hypr/hyde.lua"
	local handle = io.open(entry, "r")
	if not handle then
		error("HyDE is not installed at " .. entry .. ". Run install.sh -r, or point Hyprland at your own config.")
	end
	handle:close()
	dofile(entry)
end

hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1.25")
hl.env("GDK_SCALE", "1.25")
hl.env("TERMINAL", "alacritty")

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.25 })
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1.333, mirror = "eDP-1" })

hl.config({
	general = {
		gaps_in = 0,
		gaps_out = 0,
	},
	decoration = {
		blur = { enabled = true },
		shadow = { enabled = false },
	},
	input = {
		touchpad = {
			natural_scroll = true,
			scroll_factor = 0.1,
		},
		force_no_accel = true,
		scroll_factor = 0.6,
		follow_mouse = 1,
		repeat_delay = 250,
		repeat_rate = 30,
	},
	cursor = {
		inactive_timeout = 10,
	},
	xwayland = {
		force_zero_scaling = true,
	},
	ecosystem = {
		no_donation_nag = true,
	},
	misc = {
		key_press_enables_dpms = true,
		mouse_move_enables_dpms = false,
	},
})

hl.permission({ binary = "fcitx5-lotus-server", type = "keyboard", mode = "allow" })

hl.window_rule({
	name = "browser-workspace",
	match = { class = "^(google-chrome|brave-browser)$" },
	workspace = "1 silent",
	opacity = "1 override 1 override 1",
})

hl.window_rule({
	name = "file-manager",
	match = { class = "^(org.kde.dolphin)$" },
	workspace = "2 silent",
	tile = true,
})

hl.window_rule({
	name = "obs-studio",
	match = { class = "^(com.obsproject.Studio)$" },
	workspace = "8 silent",
})

hl.window_rule({
	name = "media-players",
	match = { class = "^(vlc)$" },
	workspace = "9 silent",
})

hl.window_rule({
	name = "spotify-rule",
	match = { title = "^(Spotify)$" },
	workspace = "9 silent",
})

hl.window_rule({
	name = "vlc-tiling",
	match = { initial_title = "^(VLC media player)$" },
	tile = true,
})

hl.window_rule({
	name = "emulator-fix",
	match = { initial_class = "^(Emulator)$" },
	float = true,
	tile = true,
})

hl.window_rule({
	name = "coding-opacity",
	match = { class = "^(code-oss|[Cc]ode)$" },
	opacity = "1 override 1 override 1",
})

hl.window_rule({
	name = "terminal-opacity",
	match = { class = "^(Alacritty|kitty)$" },
	opacity = "1 override 1 override 1",
})

hl.window_rule({
	name = "jetbrains-opacity",
	match = { class = "^(jetbrains-.*)$" },
	opacity = "1 override 1 override 1",
})

hl.window_rule({
	name = "reader-opacity",
	match = { initial_class = "^(org\\.pwmt\\.zathura)" },
	opacity = "1 override 1 override 1",
})

hl.window_rule({
	name = "obsidian",
	match = { initial_class = "^(obsidian)$" },
	opacity = "1 override 1 override 1",
	workspace = "3 silent",
	fullscreen = true,
})

hl.window_rule({
	name = "jetbrains-focus",
	match = { class = "^(jetbrains-.*)$" },
	focus_on_activate = true,
})

hl.window_rule({
	name = "jetbrains-search",
	match = { class = "^(jetbrains-.*)$", float = true, title = "negative:^win" },
	dim_around = true,
	center = true,
})

hl.window_rule({
	name = "jetbrains-menus",
	match = { class = "^(jetbrains-.*)$", title = "^(win.*)$" },
	no_anim = true,
	no_initial_focus = true,
	rounding = 0,
})

hl.bind("SUPER + Return", hl.dsp.exec_cmd("alacritty"))

hl.bind("SUPER + T", hl.dsp.exec_cmd("kitty"))

hl.bind("SUPER + M", hl.dsp.exec_cmd("spotify"))

hl.bind("SUPER + O", hl.dsp.exec_cmd("obsidian"))

hl.bind("SUPER + SHIFT + O", function()
	hl.timer(function()
		hl.dispatch(hl.dsp.dpms({ action = "disable" }))
	end, { timeout = 500, type = "oneshot" })
end)

hl.bind("SUPER + BackSpace", hl.dsp.exec_cmd(hyde.sh.session.logout.launcher()))

hl.bind("ALT + CONTROL_R", hl.dsp.exec_cmd(hyde.sh.waybar("--hide")))

hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(hyde.sh.screenshot.snip()))

hl.on("hyprland.start", function()
	hl.exec_cmd('eval "$(ssh-agent -s)"')
	hl.exec_cmd("fcitx5")
	hl.exec_cmd("[workspace 1 silent] $BROWSER")
	hl.exec_cmd('[workspace special silent; fullscreen] $TERMINAL -e zsh -l -c "tmux new-session -A"')
end)
