local ADDON_NAME, addon = ...

if not addon.Retail then return end

local range = addon.range

addon.newMapApi = true
addon.WatchedEvents = {
	"ZONE_CHANGED_NEW_AREA",
	"PLAYER_DIFFICULTY_CHANGED",
	"CHALLENGE_MODE_START",
	"CHALLENGE_MODE_RESET",
	"CHALLENGE_MODE_COMPLETED",
}

addon.ZoneMappings = {
	["The Eye of Eternity"] = { 141 },
	["Ulduar"] = range(147, 152),
	["The Obsidian Sanctum"] = { 155 },
	["Vault of Archavon"] = { 156 },
	["Naxxramas"] = range(162, 167),
	["Trial of the Crusader"] = { 172, 173 },
	["Icecrown Citadel"] = range(186, 193),
	["The Ruby Sanctum"] = { 200 },
	["Onyxia's Lair"] = { 248 },
	["Baradin Hold"] = { 282 },
	["Blackwing Descent"] = { 285, 286 },
	["The Bastion of Twilight"] = { 294, 295, 296 },
	["Throne of the Four Winds"] = { 328 },
	["Firelands"] = { 367, 368, 369 },
	["Dragon Soul"] = range(409, 415),
	["Mogu'shan Vaults"] = { 471, 472, 473 },
	["Heart of Fear"] = { 474, 475 },
	["Terrace of Endless Spring"] = { 456 },
	["Deeprun Tram"] = { 499, 500 },  -- Location of Bizmo's Brawlpub in Stormwind
	["Brawl'gar Arena"] = { 503 },  -- Horde in Orgrimmar
	["Throne of Thunder"] = range(508, 515),
	["Hellfire Citadel"] = { 534 },
	["Siege of Orgrimmar"] = range(556, 570),
	["Blackrock Foundry"] = range(596, 600),
	["Highmaul"] = range(610, 615),
	["Blackrock Foundry"] = { 624 },  -- Also BRF
	["Hellfire Citadel"] = range(661, 670),  -- Now only the one in Tanaan Jungle?
	["Halls of Valor"] = { 703 },
	["Maw of Souls"] = { 706 },
	["Vault of the Wardens"] = { 710 },
	["Eye of Azshara"] = { 713 },
	["Neltharion's Lair"] = { 731 },
	["Assault on Violet Hold"] = { 732 },
	["Darkheart Thicket"] = { 733 },
	["Black Rook Hold"] = { 751 },
	["Arcway"] = { 749 },
	["Court of Stars"] = { 761, 762, 763 },
	["The Nighthold"] = { 764, 765, 766, 767, 768, 769, 770, 771, 772 },
	["The Emerald Nightmare"] = range(777, 789),
	["Trial of Valor"] = { 806, 807, 808 },
	["Return to Karazhan"] = range(809, 822),
	["Cathedral of the Eternal Night"] = { 845, 846, 847, 848, 849 },
	["Tomb of Sargeras"] = { 850, 851, 852, 853, 854, 855, 856 },
	["Antorus, the Burning Throne"] = range(909, 920),
	["Atal'Dazar"] = { 934, 935 },
	["Freehold"] = { 936 },
	["Tol Dagor"] = range(974, 980),
	["King's Rest"] = { 1004 },
	["The MOTHERLODE!!"] = { 1010 },
	["Waycrest Manor"] = { 1015 },
	["Shrine of the Storm"] = { 1039, 1040 },
	["The Underrot"] = { 1041, 1042 },
	["Temple of Sethrallis"] = { 1038, 1043 },
	["Siege of Boralus"] = { 1162 },
	["Uldir"] = range(1148, 1155),
	["Battle of Dazar'alor"] = { 1352, 1353, 1354, 1356, 1357, 1358, 1364 },
	["Crucible of Storms"] = { 1345, 1346 },
	["The Eternal Palace"] = range(1512, 1520),
	["Operation: Mechagon"] = { 1490, 1491, 1493, 1494, 1497 },
	["Ny'alotha, The Waking City"] = { 1580, 1581, 1582, 1590, 1591, 1592, 1593, 1594, 1595, 1596, 1597 },

	-- Shadowlands
	["The Necrotic Wake"] = { 1666, 1667, 1668 },
	["Sanguine Depths"] = { 1675, 1676 },
	["Mists of Tirna Scithe"] = { 1669 },
	["Halls of Atonement"] = { 1663, 1664, 1665 },
	["Plaguefall"] = { 1674, 1697 },
	["De Other Side"] = { 1677, 1678, 1679, 1680 },
	["Spires of Ascension"] = { 1692, 1693, 1694, 1695 },
	["Theater of Pain"] = { 1683, 1684, 1685, 1686, 1687 },
	["Castle Nathria"] = { 1735, 1744, 1745, 1746, 1747, 1748, 1750, 1755 },
	["Tazavesh, the Veiled Market"] = { 1989, 1990, 1991, 1992, 1993, 1995, 1996, 1997 },
	["Sanctum of Domination"] = { 1998, 1999, 2000 },
	["Sepulcher of the First Ones"] = { 2047, 2048, 2049, 2050, 2051, 2052, 2055, 2061 },

	-- Dragonflight
	["Algeth'ar Academy"] = { 2097, 2098, 2099 },
	["The Azure Vault"] = { 2073, 2074, 2075, 2076, 2077 },
	["Brackenhide Hollow"] = { 2096 },
	["Halls of Infusion"] = { 2082, 2083 },
	["Neltharus"] = { 2080, 2081 },
	["The Nokhud Offensive"] = { 2093 },
	["Ruby Life Pools"] = { 2094, 2095 },
	["Uldaman: Legacy of Tyr"] = { 2071, 2072 },
	["Vault of the Incarnates"] = range(2119, 2126),
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
		[26] = {
			["5"] = "Normal",
			["5H"] = "Heroic",
			["5M"] = "Mythic",
			["Challenge Mode"] = "Mythic+",
		},
		[26.1] = {
			["5"] = "Normal",
			["5H"] = "Heroic",
			["5M"] = "Mythic",
			["Challenge Mode"] = "Mythic+",
		},
		[28] = {
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
	["Assault on Violet Hold"] = {
		tier = 19,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Cathedral of the Eternal Night"] = {
		tier = 19,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Court of Stars"] = {
		tier = 19,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Darkheart Thicket"] = {
		tier = 19,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Vault of the Wardens"] = {
		tier = 19,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Maw of Souls"] = {
		tier = 19,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Halls of Valor"] = {
		tier = 19,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Black Rook Hold"] = {
		tier = 19,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Eye of Azshara"] = {
		tier = 19,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Neltharion's Lair"] = {
		tier = 19,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Return to Karazhan"] = {
		tier = 19.1,
		difficulties = {
			["5"] = false,
			["5H"] = false,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Atal'Dazar"] = {
		tier = 22,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["King's Rest"] = {
		tier = 22,
		difficulties = {
			["5"] = false,
			["5H"] = false,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Shrine of the Storm"] = {
		tier = 22,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Waycrest Manor"] = {
		tier = 22,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Freehold"] = {
		tier = 22,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Temple of Sethrallis"] = {
		tier = 22,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Siege of Boralus"] = {
		tier = 22,
		difficulties = {
			["5"] = false,
			["5H"] = false,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["The Underrot"] = {
		tier = 22,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Tol Dagor"] = {
		tier = 22,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["The MOTHERLODE!!"] = {
		tier = 22,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Operation: Mechagon"] = {
		tier = 24,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},

	-- Shadowlands
	["Plaguefall"] = {
		tier = 26,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["The Necrotic Wake"] = {
		tier = 26,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Sanguine Depths"] = {
		tier = 26,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Mists of Tirna Scithe"] = {
		tier = 26,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Spires of Ascension"] = {
		tier = 26,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["De Other Side"] = {
		tier = 26,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Theater of Pain"] = {
		tier = 26,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Halls of Atonement"] = {
		tier = 26,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Tazavesh, the Veiled Market"] = {
		tier = 26.1,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	-- Dragonflight
	["Algeth'ar Academy"] = {
		tier = 28,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["The Azure Vault"] = {
		tier = 28,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Brackenhide Hollow"] = {
		tier = 28,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Halls of Infusion"] = {
		tier = 28,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Neltharus"] = {
		tier = 28,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["The Nokhud Offensive"] = {
		tier = 28,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Ruby Life Pools"] = {
		tier = 28,
		difficulties = {
			["5"] = true,
			["5H"] = true,
			["5M"] = true,
			["Challenge Mode"] = true,
		},
	},
	["Uldaman: Legacy of Tyr"] = {
		tier = 28,
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
	["The Eye of Eternity"] = {
		difficulties = {
			["10"] = true,
			["25"] = true,
		},
	},
	["Naxxramas"] = {
		tier = 7.1,
		difficulties = {
			["10"] = true,
			["25"] = true,
		},
	},
	["The Obsidian Sanctum"] = {
		tier = 7.2,
		difficulties = {
			["10"] = true,
			["25"] = true,
		},
	},
	["Onyxia's Lair"] = {
		difficulties = {
			["10"] = true,
			["25"] = true,
		},
	},
	["The Ruby Sanctum"] = {
		difficulties = {
			["10"] = true,
			["10H"] = true,
			["25"] = true,
			["25H"] = true,
		},
	},
	["Ulduar"] = {
		tier = 8,
		difficulties = {
			["10"] = true,
			["25"] = true,
		},
	},
	["Trial of the Crusader"] = {
		tier = 9,
		difficulties = {
			["10"] = true,
			["10H"] = true,
			["25"] = true,
			["25H"] = true,
		},
	},
	["Vault of Archavon"] = {
		difficulties = {
			["10"] = true,
			["25"] = true,
		},
	},
	["Icecrown Citadel"] = {
		tier = 10,
		difficulties = {
			["10"] = true,
			["10H"] = true,
			["25"] = true,
			["25H"] = true,
		},
	},
	["Blackwing Descent"] = {
		tier = 11.1,
		difficulties = {
			["10"] = true,
			["10H"] = true,
			["25"] = true,
			["25H"] = true,
		},
	},
	["Throne of the Four Winds"] = {
		tier = 11.0,
		difficulties = {
			["10"] = true,
			["10H"] = true,
			["25"] = true,
			["25H"] = true,
		},
	},
	["The Bastion of Twilight"] = {
		tier = 11.2,
		difficulties = {
			["10"] = true,
			["10H"] = true,
			["25"] = true,
			["25H"] = true,
		},
	},
	["Baradin Hold"] = {
		tier = 0,
		difficulties = {
			["10"] = true,
			["25"] = true,
		},
	},
	["Firelands"] = {
		tier = 12,
		difficulties = {
			["10"] = true,
			["10H"] = true,
			["25"] = true,
			["25H"] = true,
		},
	},
	["Dragon Soul"] = {
		tier = 13,
		difficulties = {
			["10"] = true,
			["10H"] = true,
			["25"] = true,
			["25H"] = true,
		},
	},
	["Mogu'shan Vaults"] = {
		tier = 14.1,
		difficulties = {
			["10"] = true,
			["10H"] = true,
			["25"] = true,
			["25H"] = true,
			["LFR30"] = true,
		},
	},
	["Heart of Fear"] = {
		tier = 14.2,
		difficulties = {
			["10"] = true,
			["10H"] = true,
			["25"] = true,
			["25H"] = true,
			["LFR30"] = true,
		},
	},
	["Terrace of Endless Spring"] = {
		tier = 14.3,
		difficulties = {
			["10"] = true,
			["10H"] = true,
			["25"] = true,
			["25H"] = true,
			["LFR30"] = true,
		},
	},
	["Throne of Thunder"] = {
		tier = 15,
		difficulties = {
			["10"] = true,
			["10H"] = true,
			["25"] = true,
			["25H"] = true,
			["LFR30"] = true,
		},
	},
	["Siege of Orgrimmar"] = {
		tier = 16,
		difficulties = {
			["Mythic 20"] = true,
			["Heroic"] = true,
			["Normal"] = true,
			["LFR30"] = true,
		},
	},
	["Highmaul"] = {
		tier = 17.1,
		difficulties = {
			["Mythic 20"] = true,
			["Heroic"] = true,
			["Normal"] = true,
			["LFR30"] = true,
		},
	},
	["Blackrock Foundry"] = {
		tier = 17.2,
		difficulties = {
			["Mythic 20"] = true,
			["Heroic"] = true,
			["Normal"] = true,
			["LFR30"] = true,
		},
	},
	["Hellfire Citadel"] = {
		tier = 18,
		difficulties = {
			["Mythic 20"] = true,
			["Heroic"] = true,
			["Normal"] = true,
			["LFR30"] = true,
		},
	},
	["The Emerald Nightmare"] = {
		tier = 19,
		difficulties = {
			["Mythic 20"] = true,
			["Heroic"] = true,
			["Normal"] = true,
			["LFR30"] = true,
		},
	},
	["Trial of Valor"] = {
		tier = 19.1,
		difficulties = {
			["Mythic 20"] = true,
			["Heroic"] = true,
			["Normal"] = true,
			["LFR30"] = true,
		},
	},
	["The Nighthold"] = {
		tier = 19.2,
		difficulties = {
			["Mythic 20"] = true,
			["Heroic"] = true,
			["Normal"] = true,
			["LFR30"] = true,
		},
	},
	["Tomb of Sargeras"] = {
		tier = 20,
		difficulties = {
			["Mythic 20"] = true,
			["Heroic"] = true,
			["Normal"] = true,
			["LFR30"] = true,
		},
	},
	["Antorus, the Burning Throne"] = {
		tier = 21,
		difficulties = {
			["Mythic 20"] = true,
			["Heroic"] = true,
			["Normal"] = true,
			["LFR30"] = true,
		},
	},
	["Uldir"] = {
		tier = 22,
		difficulties = {
			["Mythic 20"] = true,
			["Heroic"] = true,
			["Normal"] = true,
			["LFR30"] = true,
		},
	},
	["Battle of Dazar'alor"] = {
		tier = 23,
		difficulties = {
			["Mythic 20"] = true,
			["Heroic"] = true,
			["Normal"] = true,
			["LFR30"] = true,
		},
	},
	["Crucible of Storms"] = {
		tier = 23.1,
		difficulties = {
			["Mythic 20"] = true,
			["Heroic"] = true,
			["Normal"] = true,
			["LFR30"] = true,
		},
	},
	["The Eternal Palace"] = {
		tier = 24,
		difficulties = {
			["Mythic 20"] = true,
			["Heroic"] = true,
			["Normal"] = true,
			["LFR30"] = true,
		},
	},
	["Ny'alotha, The Waking City"] = {
		tier = 25,
		difficulties = {
			["Mythic 20"] = true,
			["Heroic"] = true,
			["Normal"] = true,
			["LFR30"] = true,
		},
	},
	["Castle Nathria"] = {
		tier = 26,
		difficulties = {
			["Mythic 20"] = true,
			["Heroic"] = true,
			["Normal"] = true,
			["LFR30"] = true,
		},
	},
	["Sanctum of Domination"] = {
		tier = 26.1,
		difficulties = {
			["Mythic 20"] = true,
			["Heroic"] = true,
			["Normal"] = true,
			["LFR30"] = true,
		},
	},
	["Sepulcher of the First Ones"] = {
		tier = 27,
		difficulties = {
			["Mythic 20"] = true,
			["Heroic"] = true,
			["Normal"] = true,
			["LFR30"] = true,
		},
	},
	["Vault of the Incarnates"] = {
		tier = 28,
		difficulties = {
			["Mythic 20"] = true,
			["Heroic"] = true,
			["Normal"] = true,
			["LFR30"] = true,
		},
	},
}

addon.Battlegrounds = {
	"Alterac Valley", "Arathi Basin", "Eye of the Storm", "Isle of Conquest",
	"Strand of the Ancients", "Warsong Gulch"
}

addon.Arenas = {
	"Dalaran Sewers", "Ruins of Lordaeron", "The Circle of Blood",
	"The Ring of Trials", "The Ring of Valor"
}
