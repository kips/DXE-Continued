do
	local L,SN,ST = DXE.L,DXE.SN,DXE.ST
	local data = {
		version = 299,
		key = "razorscale", 
		zone = L.zone["Ulduar"], 
		name = L.npc_ulduar["Razorscale"], 
		triggers = {
			scan = {
				33186, -- Razorscale
				33388, -- Dark Rune Guardian
				33846, -- Dark Rune Sentinel
				33453, -- Dark Rune Watcher
			}, 
			yell = L.chat_ulduar["^Be on the lookout! Mole machines"],
		},
		onactivate = {
			tracing = {33186}, -- Razorscale
			combatstop = true,
			defeat = 33186,
		},
		onstart = {
			{
				"alert","enragecd",
			},
		},
		userdata = {},
		alerts = {
			enragecd = {
				varname = L.alert["Enrage"],
				type = "dropdown",
				text = L.alert["Enrage"],
				time = 900,
				flashtime = 5,
				color1 = "RED",
				color2 = "RED",
				sound = "ALERT6",
				icon = ST[12317],
			},
			devourwarnself = {
				varname = format(L.alert["%s on self"],SN[63236]),
				type = "simple",
				text = format("%s: %s! %s!",SN[63236],L.alert["YOU"],L.alert["MOVE"]),
				time = 1.5,
				color1 = "RED",
				sound = "ALERT1",
				flashscreen = true,
				throttle = 3,
				icon = ST[63236],
			},
			breathwarn = {
				varname = format(L.alert["%s Casting"],SN[63317]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[63317]),
				time = 2.5,
				flashtime = 2.5,
				color1 = "BLUE",
				color2 = "WHITE",
				sound = "ALERT2",
				icon = ST[63317],
			},
			chaindur = {
				varname = format(L.alert["%s Duration"],L.alert["Chain"]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],L.alert["Chain"]),
				time = 38,
				color1 = "BROWN",
				sound = "ALERT3",
				icon = ST[60540],
			},
			permlandwarn = {
				varname = format(L.alert["%s Warning"],L.alert["Permanent Landing"]),
				type = "simple",
				text = format(L.alert["%s Permanently Landed"],L.npc_ulduar["Razorscale"]).."!",
				time = 1.5,
				sound = "ALERT4",
				icon = ST[45753],
			},
			harpoonwarn = {
				varname = format(L.alert["%s Warning"],SN[43993]),
				type = "simple",
				text = format(L.alert["%s Ready"],SN[43993]).."!",
				time = 3,
				sound = "ALERT5",
				color1 = "ORANGE",
				icon = ST[56570],
			},
		},
		events = {
			-- Devouring Flame
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = {63236,64704,64733},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","devourwarnself",
					},
				},
			},
			{
				type = "event",
				event = "YELL",
				execute = {
					-- Razorscale gets chained
					{
						"expect",{"#1#","find",L.chat_ulduar["^Move quickly"]},
						"alert","chaindur",
					},
					-- Razorscale lifts off
					{
						"expect",{"#1#","find",L.chat_ulduar["^Give us a moment to"]},
						"quash","chaindur",
					},
				},
			},
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L.chat_ulduar["deep breath...$"]},
						"alert","breathwarn",
					},
					{
						"expect",{"#1#","find",L.chat_ulduar["grounded permanently!$"]},
						"quash","chaindur",
						"alert","permlandwarn",
					},
					{
						"expect",{"#1#","find",L.chat_ulduar["^Harpoon Turret is ready"]},
						"alert","harpoonwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
