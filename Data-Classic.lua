local ADDON_NAME, addon = ...

if not addon.Classic then return end

local range = addon.range

addon.ZoneMappings = {
	["Molten Core"] = { 409 },
	["Onyxia's Lair"] = { 249 },
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
		[19] = {
			["5"] = "Normal",
			["5H"] = "Heroic",
			["5M"] = "Mythic",
			["Challenge Mode"] = "Mythic+",
		},
		[19.1] = {
			["5"] = "Normal",
			["5H"] = "Heroic",
			["5M"] = "Mythic",
			["Challenge Mode"] = "Mythic+",
		},
		[22] = {
			["5"] = "Normal",
			["5H"] = "Heroic",
			["5M"] = "Mythic",
			["Challenge Mode"] = "Mythic+",
		},
		[24] = {
			["5"] = "Normal",
			["5H"] = "Heroic",
			["5M"] = "Mythic",
			["Challenge Mode"] = "Mythic+",
		},
	}
}

addon.InstanceDifficultyOrder = {
	["5"] = 1,
	["5H"] = 2,
	["5M"] = 3,
	["Challenge Mode"] = 4,
}

addon.Instances = {
	["Arcway"] = {
		tier = 19,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
}

-- Raids to track and the possible raid sizes.
addon.Raids = {
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

}

addon.Battlegrounds = {
	"Alterac Valley", "Arathi Basin", "Warsong Gulch"
}

addon.Arenas = {

}
