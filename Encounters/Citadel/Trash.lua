local L,SN,ST = DXE.L,DXE.SN,DXE.ST

do
	local data = {
		version = 2,
		key = "icctrash", 
		zone = L["Icecrown Citadel"], 
		category = L["Citadel"], 
		name = format(L["%s (T)"],L["Deathbound Ward"]), 
		triggers = {
			scan = {
				37007, -- Deathbound Ward
			},
		},
		onactivate = {
			tracing = {37007}, -- Deathbound Ward
			tracerstart = true,
			combatstop = true,
		},
		alerts = {
			disruptshoutwarn = {
				varname = format(L["%s Cast"],SN[71022]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[71022]),
				time = 3,
				flashtime = 3,
				color1 = "ORANGE",
				sound = "ALERT5",
				flashscreen = true,
				icon = ST[71022],
			},
		},
		events = {
			-- Disrupting Shout
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 71022, -- 10/25
				execute = {
					{
						"alert","disruptshoutwarn"
					},
				}
			}
		},
	}

	DXE:RegisterEncounter(data)
end

do
	local data = {
		version = 2,
		key = "icctrashtwo",
		zone = L["Icecrown Citadel"],
		category = L["Citadel"],
		name = format(L["%s (T)"],L["Stinky"]),
		triggers = {
			scan = {
				37025, -- Stinky
			},
		},
		onactivate = {
			tracing = {37025}, -- Stinky
			tracerstart = true,
			combatstop = true,
		},
		userdata = {
			mortaltext = "",
		},
		alerts = {
			decimatewarn = {
				varname = format(L["%s Cast"],SN[71123]),
				type = "centerpopup",
				text = format(L["%s Cast"],SN[71123]),
				time = 3,
				flashtime = 3,
				color1 = "PURPLE",
				sound = "ALERT5",
				flashscreen = true,
				icon = ST[71123],
			},
			mortalwarn = {
				varname = format(L["%s Warning"],SN[71127]),
				type = "simple",
				text = "<mortaltext>",
				time = 3,
				color1 = "RED",
				icon = ST[71127],
			},
		},
		events = {
			-- Decimate
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 71123, -- 10/25
				execute = {
					{
						"alert","decimatewarn"
					},
				}
			},
			-- Mortal Wound
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = 71127,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{mortaltext = format("%s: %s!",SN[71127],L["YOU"])},
						"alert","mortalwarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{mortaltext = format("%s: #5#!",SN[71127])},
						"alert","mortalwarn",
					},
				},
			},
			-- Mortal Wounds applications
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = 71127,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{mortaltext = format("%s: %s! %s!",SN[71127],L["YOU"],format(L["%s Stacks"],"#11#"))},
						"alert","mortalwarn",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{mortaltext = format("%s: #5#! %s!",SN[71127],format(L["%s Stacks"],"#11#")) },
						"alert","mortalwarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
