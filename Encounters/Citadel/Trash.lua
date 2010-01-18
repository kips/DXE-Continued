local L,SN,ST = DXE.L,DXE.SN,DXE.ST

do
	local data = {
		version = 2,
		key = "icctrash", 
		zone = L.zone["Icecrown Citadel"], 
		category = L.zone["Citadel"], 
		name = format(L.alert["%s (T)"],L.npc_citadel["Deathbound Ward"]), 
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
				varname = format(L.alert["%s Casting"],SN[71022]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[71022]),
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
	local decimate_event = {
		type = "combatevent",
		eventtype = "SPELL_CAST_START",
		spellid = 71123, -- 10/25
		execute = {
			{
				"alert","decimatewarn"
			},
		}
	}
	
	local mortal_wound_event = {
		type = "combatevent",
		eventtype = "SPELL_AURA_APPLIED",
		spellid = 71127,
		execute = {
			{
				"expect",{"#4#","==","&playerguid&"},
				"set",{mortaltext = format("%s: %s!",SN[71127],L.alert["YOU"])},
				"alert","mortalwarn",
			},
			{
				"expect",{"#4#","~=","&playerguid&"},
				"set",{mortaltext = format("%s: #5#!",SN[71127])},
				"alert","mortalwarn",
			},
		},
	}

	local mortal_wound_dose_event = {
		type = "combatevent",
		eventtype = "SPELL_AURA_APPLIED_DOSE",
		spellid = 71127,
		execute = {
			{
				"expect",{"#4#","==","&playerguid&"},
				"set",{mortaltext = format("%s: %s! %s!",SN[71127],L.alert["YOU"],format(L.alert["%s Stacks"],"#11#"))},
				"alert","mortalwarn",
			},
			{
				"expect",{"#4#","~=","&playerguid&"},
				"set",{mortaltext = format("%s: #5#! %s!",SN[71127],format(L.alert["%s Stacks"],"#11#")) },
				"alert","mortalwarn",
			},
		},
	}

	local decimatewarn = {
		varname = format(L.alert["%s Casting"],SN[71123]),
		type = "centerpopup",
		text = format(L.alert["%s Casting"],SN[71123]),
		time = 3,
		flashtime = 3,
		color1 = "PURPLE",
		sound = "ALERT5",
		flashscreen = true,
		icon = ST[71123],
	}
	local mortalwarn = {
		varname = format(L.alert["%s Warning"],SN[71127]),
		type = "simple",
		text = "<mortaltext>",
		time = 3,
		color1 = "RED",
		icon = ST[71127],
	}

	do
		local data = {
			version = 3,
			key = "icctrashtwo",
			zone = L.zone["Icecrown Citadel"],
			category = L.zone["Citadel"],
			name = format(L.alert["%s (T)"],L.npc_citadel["Stinky"]),
			triggers = {
				scan = {
					37025, -- Stinky
				},
			},
			onactivate = {
				tracing = {
					37025, -- Stinky
				}, 
				tracerstart = true,
				combatstop = true,
			},
			userdata = {
				mortaltext = "",
			},
			alerts = {
				decimatewarn = decimatewarn,
				mortalwarn = mortalwarn,
			},
			events = {
				-- Decimate
				decimate_event,
				-- Mortal Wound
				mortal_wound_event,
				-- Mortal Wounds applications
				mortal_wound_dose_event,
			},
		}

		DXE:RegisterEncounter(data)
	end

	do
		local data = {
			version = 1,
			key = "icctrashthree",
			zone = L.zone["Icecrown Citadel"],
			category = L.zone["Citadel"],
			name = format(L.alert["%s (T)"],L.npc_citadel["Precious"]),
			triggers = {
				scan = {
					37217, -- Precious
				},
			},
			onactivate = {
				tracing = {
					37217, -- Precious
				}, 
				tracerstart = true,
				combatstop = true,
			},
			userdata = {
				mortaltext = "",
				awakentime = {28,20,loop = false},
			},
			alerts = {
				decimatewarn = decimatewarn,
				mortalwarn = mortalwarn,
				awakencd = {
					varname = format(L.alert["%s Cooldown"],SN[71159]),
					type = "dropdown",
					text = format(L.alert["%s Cooldown"],SN[71159]),
					time = "<awakentime>",
					flashtime = 10,
					color1 = "GREY",
					icon = ST[71159],
				}
			},
			events = {
				-- Decimate
				decimate_event,
				-- Mortal Wound
				mortal_wound_event,
				-- Mortal Wounds applications
				mortal_wound_dose_event,
				-- Awaken Plagued Zombie
				{
					type = "event",
					event = "EMOTE",
					execute = {
						{
							"expect",{"#2#","==",L.npc_citadel["Precious"]},
							"alert","awakencd",
						},
					},
				},
			},
		}

		DXE:RegisterEncounter(data)
	end
end
