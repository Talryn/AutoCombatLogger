local ADDON_NAME, addon = ...

if not addon.Cataclysm then return end

local range = addon.range

addon.newMapApi = false
addon.WatchedEvents = {
	"ZONE_CHANGED_NEW_AREA",
	"PLAYER_ENTERING_WORLD"
}

addon.ZoneMappings = {
	-- Cataclysm Dungeons
	["Blackrock Caverns"] = { 645 }, -- newApi 283
	["End Time"] = { 938 },
	["Grim Batol"] = { 670 },  --newApi 293
	["Halls of Origination"] = { 644 },  -- newApi 297
	["Hour of Twilight"] = { 940 },
	["Lost City of the Tol'vir"] = { 755 },  -- newApi 277
--	["The Deadmines"] = { 36 }, --newApi 291
	["The Stonecore"] = { 725 },  -- newApi 324
	["The Vortex Pinnacle"] = { 657 },  -- newApi 325
	["Throne of the Tides"] = { 643 },  -- newApi 322
	["Well of Eternity"] = { 939 },
	["Zul'Aman"] = { 568 },
	["Zul'Gurub"] = { 859 },

	-- Cataclysm Raids
	["Baradin Hold"] = { 757 },
	["Blackwing Descent"] = { 669 },
	["Dragon Soul"] = { 967 },
	["Firelands"] = { 720 },
	["The Bastion of Twilight"] = { 671 },
	["Throne of the Four Winds"] = { 754 },

	-- Wrath Dungeons
	["Ahn'kahet: The Old Kingdom"] = { 619 },
	["Azjol-Nerub"] = { 601 },
	["Drak'Tharon Keep"] = { 600 },
	["Gundrak"] = { 604 },
	["Halls of Lightning"] = { 602 },
	["Halls of Reflection"] = { 668 },
	["Halls of Stone"] = { 599 },
	["Pit of Saron"] = { 658 },
	["The Culling of Stratholme"] = { 595 },
	["The Forge of Souls"] = { 632 },
	["The Nexus"] = { 576 },
	["The Oculus"] = { 578 },
	["The Violet Hold"] = { 608 },
	["Utgarde Keep"] = { 574 },
	["Utgarde Pinnacle"] = { 575 },

	-- Wrath Raids
	["Naxxramas"] = { 533 },
	["The Eye of Eternity"] = { 616 },
	["The Obsidian Sanctum"] = { 615 },
	["Vault of Archavon"] = { 624 },
	["Ulduar"] = { 603 },
	["Trial of the Crusader"] = { 649 },
	["Icecrown Citadel"] = { 631 },

	-- BC Dungeons
	["The Blood Furnace"] = { 542 },
	["Sethekk Halls"] = { 556 },
	["Auchenai Crypts"] = { 558 },
	["Mana-Tombs"] = { 557 },
	["The Slave Pens"] = { 547 },
	["The Steamvault"] = { 545 },
	["The Underbog"] = { 546 },
	["Hellfire Ramparts"] = { 543 },
	["The Mechanar"] = { 554 },
	["The Botanica"] = { 553 },
	["Arcatraz"] = { 552 },
	["The Shattered Halls"] = { 540 },
	["The Shadow Labyrinth"] = { 555 },
	["Old Hillsbrad Foothills"] = { 560 },
	["The Black Morass"] = { 269 },

	-- BC Raids
	["Gruul's Lair"] = { 565 },
	["Magtheridon's Lair"] = { 544 },
	["Serpentshrine Cavern"] = { 548 },
	["Tempest Keep"] = { 550 },
	["Black Temple"] = { 564 },
	["Karazhan"] = { 532 },
	["The Battle for Mount Hyjal"] = { 534 },
	["Zul'Aman"] = { 568 },
	["The Sunwell"] = { 580 },

	-- Classic Raids
	["Molten Core"] = { 409 },
	["Onyxia's Lair"] = { 249 },
	["Blackwing Lair"] = { 469 },
	["Zul'Gurub"] = { 309 },
	["Ahn'Qiraj"] = { 531 },
	["Ruins of Ahn'Qiraj"] = { 509 },
--	["Naxxramas"] = { 533 },

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
	[173] = "5", -- BC 5 Normal dungeon
	[174] = "5H", -- BC 5 Heroic dungeon
	[175] = "10", -- BC 10 player raid
	[176] = "25", -- BC 25 player raid
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
		[4] = {
			["5"] = "Normal",
			["5H"] = "Heroic",
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
	-- Cataclysm Dungeons
	["Blackrock Caverns"] = {
		tier = 11,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["Grim Batol"] = {
		tier = 11,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["Halls of Origination"] = {
		tier = 11,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["Lost City of the Tol'vir"] = {
		tier = 11,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["The Stonecore"] = {
		tier = 11,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["The Vortex Pinnacle"] = {
		tier = 11,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["Throne of the Tides"] = {
		tier = 11,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},

	-- Wrath Dungeons
	["Ahn'kahet: The Old Kingdom"] = {
		tier = 5,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["Azjol-Nerub"] = {
		tier = 5,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["Drak'Tharon Keep"] = {
		tier = 5,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["Gundrak"] = {
		tier = 5,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["Halls of Lightning"] = {
		tier = 5,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["Halls of Reflection"] = {
		tier = 5,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["Halls of Stone"] = {
		tier = 5,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["Pit of Saron"] = {
		tier = 5,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["The Culling of Stratholme"] = {
		tier = 5,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["The Forge of Souls"] = {
		tier = 5,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["The Nexus"] = {
		tier = 5,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["The Oculus"] = {
		tier = 5,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["The Violet Hold"] = {
		tier = 5,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["Utgarde Keep"] = {
		tier = 5,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["Utgarde Pinnacle"] = {
		tier = 5,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},

	-- TBC Dungeons
	["The Blood Furnace"] = {
		tier = 4,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["Sethekk Halls"] = {
		tier = 4,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["Auchenai Crypts"] = {
		tier = 4,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["Mana-Tombs"] = {
		tier = 4,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["The Slave Pens"] = {
		tier = 4,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["The Steamvault"] = {
		tier = 4,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["The Underbog"] = {
		tier = 4,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["Hellfire Ramparts"] = {
		tier = 4,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["The Mechanar"] = {
		tier = 4,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["The Botanica"] = {
		tier = 4,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["Arcatraz"] = {
		tier = 4,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["The Shattered Halls"] = {
		tier = 4,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["The Shadow Labyrinth"] = {
		tier = 4,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["The Black Morass"] = {
		tier = 4,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},

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
		tier = 11,
		difficulties = {
			["5"] = true,
			["5H"] = true,
		},
	},
	["Stratholme"] = {
		tier = 1,
		difficulties = {
			["5"] = true,
		},
	},
	["The Deadmines"] = {
		tier = 11,
		difficulties = {
			["5"] = true,
			["5H"] = true,
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
	-- Cataclysm Raids
	["Baradin Hold"] = {
		tier = 11,
		difficulties = {
			["10"] = true,
			["10H"] = true,
			["25"] = true,
			["25H"] = true,
		},
	},
	["Blackwing Descent"] = {
		tier = 11,
		difficulties = {
			["10"] = true,
			["10H"] = true,
			["25"] = true,
			["25H"] = true,
		},
	},
	["The Bastion of Twilight"] = {
		tier = 11,
		difficulties = {
			["10"] = true,
			["10H"] = true,
			["25"] = true,
			["25H"] = true,
		},
	},
	["Throne of the Four Winds"] = {
		tier = 11,
		difficulties = {
			["10"] = true,
			["10H"] = true,
			["25"] = true,
			["25H"] = true,
		},
	},


	-- Wrath Raids
	["Icecrown Citadel"] = {
		tier = 9,
		difficulties = {
			["10"] = true,
			["10H"] = true,
			["25"] = true,
			["25H"] = true,
		},
	},
	["Trial of the Crusader"] = {
		tier = 8.5,
		difficulties = {
			["10"] = true,
			["10H"] = true,
			["25"] = true,
			["25H"] = true,
		},
	},
	["Onyxia's Lair"] = {
		tier = 8.5,
		difficulties = {
			["10"] = true,
			["10H"] = true,
			["25"] = true,
			["25H"] = true,
			["40"] = true,
		},
	},
	["Ulduar"] = {
		tier = 8,
		difficulties = {
			["10"] = true,
			["25"] = true,
		},
	},
	["Naxxramas"] = {
		tier = 7,
		difficulties = {
			["10"] = true,
			["25"] = true,
		},
	},
	["The Obsidian Sanctum"] = {
		tier = 7,
		difficulties = {
			["10"] = true,
			["25"] = true,
		},
	},
	["The Eye of Eternity"] = {
		tier = 7,
		difficulties = {
			["10"] = true,
			["25"] = true,
		},
	},
	["Vault of Archavon"] = {
		tier = 7,
		difficulties = {
			["10"] = true,
			["25"] = true,
		},
	},

	-- BC Raids
	["Karazhan"] = {
		tier = 4,
		difficulties = {
			["10"] = true,
		},
	},
	["Gruul's Lair"] = {
		tier = 4,
		difficulties = {
			["25"] = true,
		},
	},
	["Magtheridon's Lair"] = {
		tier = 4,
		difficulties = {
			["25"] = true,
		},
	},
	["Serpentshrine Cavern"] = {
		tier = 5,
		difficulties = {
			["25"] = true,
		},
	},
	["Tempest Keep"] = {
		tier = 5,
		difficulties = {
			["25"] = true,
		},
	},
	["Black Temple"] = {
		tier = 6,
		difficulties = {
			["25"] = true,
		},
	},
	["The Battle for Mount Hyjal"] = {
		tier = 6,
		difficulties = {
			["25"] = true,
		},
	},
	["Zul'Aman"] = {
		tier = 6.5,
		difficulties = {
			["10"] = true,
		},
	},
	["The Sunwell"] = {
		tier = 6.5,
		difficulties = {
			["25"] = true,
		},
	},

	-- Classic Raids
	["Molten Core"] = {
		tier = 1,
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
	-- ["Naxxramas"] = {
	-- 	tier = 3,
	-- 	difficulties = {
	-- 		["40"] = true,
	-- 	},
	-- },
}

addon.Battlegrounds = {
	"Alterac Valley", "Arathi Basin", "Warsong Gulch"
}

addon.Arenas = {

}
