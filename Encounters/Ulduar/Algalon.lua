do
	local data = {
		version = "$Rev$",
		key = "algalon", 
		zone = "Ulduar", 
		name = "Algalon the Observer", 
		title = "Algalon the Observer", 
		tracing = {"Algalon the Observer",},
		triggers = {
			scan = "Algalon the Observer", 
		},
		onactivate = {
			autostart = true,
			autostop = true,
			leavecombat = true,
		},
		userdata = {},
		onstart = {},
		alerts = {},
	}
	-- Big Bang
		-- 8 second cast that does 100k damage
	-- Phase Punch
	-- Quantum Strike
	-- Black Hole Explosion
	-- Cosmic Smash
	DXE:RegisterEncounter(data)
end
