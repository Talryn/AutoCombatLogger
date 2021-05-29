local ADDON_NAME, addon = ...

if not addon.Classic then return end

local range = addon.range

addon.newMapApi = false
addon.WatchedEvents = {
	"ZONE_CHANGED_NEW_AREA",
	"PLAYER_ENTERING_WORLD"
}

addon.ZoneMappings = {
	-- Classic Raids
	["Molten Core"] = { 409 },
	["Onyxia's Lair"] = { 249 },
	["Blackwing Lair"] = { 469 },
	["Zul'Gurub"] = { 309 },
	["Ahn'Qiraj"] = { 531 },
	["Ruins of Ahn'Qiraj"] = { 509 },
	["Naxxramas"] = { 533 },

	-- Classic Dungeons
	["Blackfathom Deeps"] = { 48 },
	["Blackrock Depths"] = { 230 },
	["Blackrock Spire"] = { 229 },
	["Dire Maul"] = { 429 },
	["Gnomeregan"] = { 90 },
	["Maraudon"] = { 349 },
	["Ragefire Chasm"] = { 389 },
	["Razorfen Downs"] = { 129 },
	["Razorfen Kraul"] = { 47 },
	["Scarlet Halls"] = { 1001 },
	["Scarlet Monastery"] = { 1004 },
	["Scholomance"] = { 329 },
	["Shadowfang Keep"] = { 33 },
	["Stratholme"] = { 329 },
	["The Deadmines"] = { 36 },
	["The Stockade"] = { 34 },
	["The Temple of Atal'Hakkar"] = { 109 },
	["Uldaman"] = { 70 },
	["Wailing Caverns"] = { 43 },
	["Zul'Farrak"] = { 209 },

	-- Classic Battlegrounds
	["Alterac Valley"] = { 30 },
	["Arathi Basin"] = { 529 },
	["Warsong Gulch"] = { 489 },
}

addon.InstanceDifficulties = {
	[0] = "None",
	[1] = "5",
	[2] = "5H",
	[3] = "10",
	[4] = "25",
	[5] = "10H",
	[6] = "25H",
	[7] = "LFR25",
	[8] = "Challenge Mode",
	[9] = "40",
	--[10] = "Not used",
	[11] = "Heroic Scenario",
	[12] = "Scenario",
	--[13] = "Not used",
	[14] = "Normal", -- Normal 10-30 Raid
	[15] = "Heroic", -- Heroic 10-30 Raid
	[16] = "Mythic 20",
	[17] = "LFR30",
	[23] = "5M", -- Mythic 5 player
	[24] = "5T", -- Timewalker 5 player
	[148] = "20", -- Classic 20 player raid
}

addon.DifficultyOrder = {
	["LFR30"] = 1,
	["10"] = 2,
	["10H"] = 3,
	["25"] = 4,
	["25H"] = 5,
	["Normal"] = 6,
	["Heroic"] = 7,
	["Mythic 20"] = 8,
	["40"] = 9,
}

addon.InstanceMappings = {
	tiers = {
		[1] = {
			["5"] = "Normal",
		},
		-- [19] = {
		-- 	["5"] = "Normal",
		-- 	["5H"] = "Heroic",
		-- 	["5M"] = "Mythic",
		-- 	["Challenge Mode"] = "Mythic+",
		-- },
	}
}

addon.InstanceDifficultyOrder = {
	["5"] = 1,
	["5H"] = 2,
	["5M"] = 3,
	["Challenge Mode"] = 4,
}

addon.Instances = {
	-- Classic Dungeons
	["Blackfathom Deeps"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
	["Blackrock Depths"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
	["Blackrock Spire"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
	["Dire Maul"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
	["Gnomeregan"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
	["Maraudon"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
	["Ragefire Chasm"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
	["Razorfen Downs"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
	["Razorfen Kraul"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
	["Scaret Halls"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
	["Scarlet Monastery"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
	["Scholomance"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
	["Shadowfang Keep"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
	["Stratholme"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
	["The Deadmines"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
	["The Stockade"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
	["The Temple of Atal'Hakkar"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
	["Uldaman"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
	["Wailing Caverns"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
	["Zul'Farrak"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
}

-- Raids to track and the possible raid sizes.
addon.Raids = {
	-- Classic Raids
	["Molten Core"] = {
		tier = 1,
		difficulties = {
			["40"] = true,
		},
	},
	["Onyxia's Lair"] = {
		difficulties = {
			["40"] = true,
		},
	},
	["Blackwing Lair"] = {
		tier = 2,
		difficulties = {
			["40"] = true,
		},
	},
	["Zul'Gurub"] = {
		tier = 2.1,
		difficulties = {
			["20"] = true,
		},
	},
	["Ahn'Qiraj"] = {
		tier = 2.5,
		difficulties = {
			["40"] = true,
		},
	},
	["Ruins of Ahn'Qiraj"] = {
		tier = 2.5,
		difficulties = {
			["20"] = true,
		},
	},
	["Naxxramas"] = {
		tier = 3,
		difficulties = {
			["40"] = true,
		},
	},
}

addon.Battlegrounds = {
	"Alterac Valley", "Arathi Basin", "Warsong Gulch"
}

addon.Arenas = {

}
