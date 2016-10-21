local _G = getfenv(0)
local ADDON_NAME, addon = ...

local table = _G.table
local pairs = _G.pairs
local ipairs = _G.ipairs

local AutoCombatLogger = _G.LibStub("AceAddon-3.0"):NewAddon("AutoCombatLogger", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")

local L = _G.LibStub("AceLocale-3.0"):GetLocale("AutoCombatLogger", true)
local LDB = _G.LibStub("LibDataBroker-1.1")
local icon = _G.LibStub("LibDBIcon-1.0")

-- Try to remove the Git hash at the end, otherwise return the passed in value.
local function cleanupVersion(version)
	local iter = _G.string.gmatch(version, "(.*)-[a-z0-9]+$")
	if iter then
		local ver = iter()
		if ver and #ver >= 3 then
			return ver
		end
	end
	return version
end

addon.addonTitle = _G.GetAddOnMetadata(ADDON_NAME,"Title")
addon.addonVersion = cleanupVersion("@project-version@")

addon.CURRENT_BUILD, addon.CURRENT_INTERNAL, 
    addon.CURRENT_BUILD_DATE, addon.CURRENT_UI_VERSION = _G.GetBuildInfo()
addon.WoD = addon.CURRENT_UI_VERSION >= 60000

local DEBUG = false

local GREEN = "|cff00ff00"
local YELLOW = "|cffffff00"
local BLUE = "|cff0198e1"
local ORANGE = "|cffff9933"
local WHITE = "|cffffffff"
local addonHdr = GREEN.."%s %s"

-- GetInstanceInfo() data
-- 10th Anniversary Molten Core
-- [1]="Molten Core", [2]="raid", [3]=18, [4]="Event",  [5]=40,  [6]=0,  [7]=false,
-- Horde Brawler's Guild
-- [1]="Brawl'gar Arena", [2]="none", [3]=0, [4]="", [5]=5, [6]=0,
-- Alliance Brawler's Guild (GetCurrentMapDungeonLevel() also returns [1]=2)
-- [1]="Deeprun Tram",[2]="none",[3]=0,[4]="",[5]=5,[6]=0,[7]=false,[8]=369,[9]=0

AutoCombatLogger.zoneTimer = nil

local Zones = {
	[527] = "The Eye of Eternity",
	[604] = "Icecrown Citadel",
	[535] = "Naxxramas",
	[531] = "The Obsidian Sanctum",
	[718] = "Onyxia's Lair",
	[609] = "The Ruby Sanctum",
	[543] = "Trial of the Crusader",
	[529] = "Ulduar",
	[532] = "Vault of Archavon",
	[754] = "Blackwing Descent",
	[773] = "Throne of the Four Winds",
	[758] = "The Bastion of Twilight",
	[752] = "Baradin Hold",
	[800] = "Firelands",
	[824] = "Dragon Soul",
	[896] = "Mogu'shan Vaults",
	[897] = "Heart of Fear",
	[886] = "Terrace of Endless Spring",
	[922] = "Deeprun Tram", -- Location of Bizmo's Brawlpub in Stormwind
	[925] = "Brawl'gar Arena", -- Horde in Orgrimmar
	[930] = "Throne of Thunder",
	[945] = "Hellfire Citadel",
	[953] = "Siege of Orgrimmar",
	[994] = "Highmaul",
	[988] = "Blackrock Foundry",
	[1011] = "Blackrock Foundry", -- Also BRF
	[1026] = "Hellfire Citadel",  -- Now only the one in Tanaan Jungle?
	[1066] = "Assault on Violet Hold",
	[1067] = "Darkheart Thicket",
	[1045] = "Vault of the Wardens",
	[1042] = "Maw of Souls",
	[1041] = "Halls of Valor",
	[1081] = "Black Rook Hold",
	[1046] = "Eye of Azshara",
	[1065] = "Neltharion's Lair",
	[1094] = "The Emerald Nightmare", 
}

local ReverseZones = {}
for k,v in pairs(Zones) do
	ReverseZones[v] = k
end

local InstanceDifficulties = {
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

local DifficultyOrder = {
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

local InstanceMappings = {
	tiers = {
		[19] = {
			["5"] = "Normal",
			["5H"] = "Heroic",
			["5M"] = "Mythic",
			["Challenge Mode"] = "Mythic+",
		},
	}
}

local InstanceDifficultyOrder = {
	["5"] = 1,
	["5H"] = 2,
	["5M"] = 3,
	["Challenge Mode"] = 4,
}

local Instances = {
	["Assault on Violet Hold"] = {
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
}

local OrderedInstances = {}
for instance, data in pairs(Instances) do
	table.insert(OrderedInstances, instance)
end
table.sort(OrderedInstances, 
	function(a,b)
		return (Instances[a]["tier"] or 0) > (Instances[b]["tier"] or 0)
	end)

-- Raids to track and the possible raid sizes.
local Raids = {
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
}

local OrderedRaids = {}
for raid, data in pairs(Raids) do
	table.insert(OrderedRaids, raid)
end
table.sort(OrderedRaids, 
	function(a,b)
		return (Raids[a]["tier"] or 0) > (Raids[b]["tier"] or 0)
	end)

local Battlegrounds = {
	"Alterac Valley", "Arathi Basin", "Eye of the Storm", "Isle of Conquest", 
	"Strand of the Ancients", "Warsong Gulch"
}

local Arenas = {
	"Dalaran Sewers", "Ruins of Lordaeron", "The Circle of Blood", 
	"The Ring of Trials", "The Ring of Valor"
}

local defaults = {
	profile = {
		minimap = {
			hide = true,
		},
		chat = {
			enabled = false,
		},
		verbose = false,
		debug = false,
		logRaid = "Yes",
		selectedRaids = {},
		logInstance = "No",
		selectedInstances = {},
		logBG = "No",
		selectedBGs = {},
		logArena = "No",
		selectedArenas = {},
		logWorld = "No",
		log = {
			Garrison = false,
			Brawlers = false,
			Taxi = false,
		},
	}
}

-- Dynamically add the default raid settings
for raid, data in pairs(Raids) do
	defaults.profile.selectedRaids[raid] = {}
	for difficulty, enabled in pairs(Raids[raid]["difficulties"] or {}) do
		if enabled then
			defaults.profile.selectedRaids[raid][difficulty] = false
		end
	end
end

-- Dynamically add the default instances settings
for instance, data in pairs(Instances) do
	defaults.profile.selectedInstances[instance] = {}
	for difficulty, enabled in pairs(Instances[instance]["difficulties"] or {}) do
		if enabled then
			defaults.profile.selectedInstances[instance][difficulty] = false
		end
	end
end

-- Dynamically add the battleground options
for i, bg in ipairs(Battlegrounds) do
    defaults.profile.selectedBGs[bg] = false
end

-- Dynamically add the arena options
for i, arena in ipairs(Arenas) do
    defaults.profile.selectedArenas[arena] = false
end

local function invertTable(table)
	if _G.type(table) ~= "table" then return end
	local newTable = {}
	for key, value in pairs(table) do
		newTable[value] = key 
	end
	return newTable
end

local logOptions = {
    [1] = "No",
    [2] = "Yes",
    [3] = "Custom"
}

local localizedLogOptions = {
    [1] = L["No"],
    [2] = L["Yes"],
    [3] = L["Custom"]    
}

local invertedOptions = invertTable(logOptions)

local aclLDB = nil
local update = nil

local options

function AutoCombatLogger:GetLocalName(raid)
	local id = ReverseZones[raid]
	if id then
		return _G.GetMapNameByID(id) or raid
	else
		return raid
	end
end

function AutoCombatLogger:GetOptions()
	if options then return options end

	options = {
		name = "AutoCombatLogger",
		type = "group",
		args = {
			general = {
				name = "General Options",
				type = "group",
				args = {
					minimap = {
						name = L["Minimap Button"],
						desc = L["Toggle the minimap button"],
						type = "toggle",
						set = function(info,val)
							-- Reverse the value since the stored value is to hide 
							-- it and not show it
							self.db.profile.minimap.hide = not val
							if self.db.profile.minimap.hide then
								icon:Hide("AutoCombatLogger")
							else
								icon:Show("AutoCombatLogger")
							end
						end,
						get = function(info)
							-- Reverse the logic since the option is to hide
							return not self.db.profile.minimap.hide
						end,
						order = 10
					},
					verbose = {
						name = L["Verbose"],
						desc = L["Toggles the display of informational messages"],
						type = "toggle",
						set = function(info,val) self.db.profile.verbose = val end,
						get = function(info) return self.db.profile.verbose end,
						order = 20
					}
				}
			},
			chat = {
				type = "group",
				name = L["Chat"],
				args = {
					enabled = {
						name = L["Enable"],
						desc = L["ChatEnable_Desc"],
						type = "toggle",
						set = function(info,val)
							self.db.profile.chat.enabled = val
							if val then
								self:EnableChatLogging()
							else
								self:DisableChatLogging()
							end
						end,
						get = function(info)
							return self.db.profile.chat.enabled
						end,
						order = 1
					},
				},
			},
			raids = {
				type = "group",
				name = "Raids",
				args = {
					logRaid = {
						name = L["Log Raids"],
						desc = L["When to log combat within raids"],
						type = "select",
						width = "double",
						set = function(info,val) self.db.profile.logRaid = logOptions[val] end,
						get = function(info) return invertedOptions[self.db.profile.logRaid] end,
						order = 10,
						values = localizedLogOptions
					},
					header = {
						name = L["Custom Settings"],
						type = "header",
						order = 20
					},
					desc = {
						name = L["For Custom, choose the individual raids to log below."],
						type = "description",
						order = 30
					}
				}
			},
			instances = {
				type = "group",
				name = "Instances",
				args = {
					logInstance = {
						name = L["Log Instances"],
						desc = L["When to log combat within instances"],
						type = "select",
						width = "double",
						set = function(info,val) self.db.profile.logInstance = logOptions[val] end,
						get = function(info) return invertedOptions[self.db.profile.logInstance] end,
						order = 10,
						values = localizedLogOptions
					}
				}
			},
			arenas = {
				type = "group",
				name = "Arenas",
				args = {
					logArena = {
						name = L["Log Arena"],
						desc = L["When to log combat within arenas"],
						type = "select",
						width = "double",
						set = function(info,val) self.db.profile.logArena = logOptions[val] end,
						get = function(info) return invertedOptions[self.db.profile.logArena] end,
						order = 10,
						values = localizedLogOptions
					},
					header = {
						name = L["Custom Settings"],
						type = "header",
						order = 20
					},
					desc = {
						name = L["For Custom, choose the individual arenas to log below."],
						type = "description",
						order = 30
					}            		
				}                
			},
			bgs = {
				type = "group",
				name = "Battlegrounds",
				args = {
					logBG = {
						name = L["Log Battlegrounds"],
						desc = L["When to log combat within battlegrounds"],
						type = "select",
						width = "double",
						set = function(info,val) self.db.profile.logBG = logOptions[val] end,
						get = function(info) return invertedOptions[self.db.profile.logBG] end,
						order = 10,
						values = localizedLogOptions
					},
					header = {
						name = L["Custom Settings"],
						type = "header",
						order = 20
					},
					desc = {
						name = L["For Custom, choose the individual battlegrounds to log below."],
						type = "description",
						order = 30
					}
				}
			},
			world = {
				type = "group",
				name = "World",
				args = {
					logWorld = {
						name = L["Log World Zones"],
						desc = L["When to log combat within world zones"],
						type = "select",
						width = "double",
						set = function(info,val) self.db.profile.logWorld = logOptions[val] end,
						get = function(info) return invertedOptions[self.db.profile.logWorld] end,
						order = 10,
						values = localizedLogOptions
					},
					specialHdr = {
						order = 20,
						name = "Special Areas",
						type = "header",
					},
					logBrawlers = {
						order = 100,
						name = _G.GetCategoryInfo(15202) or "Brawler's Guild",
						desc = _G.GetCategoryInfo(15202) or "Brawler's Guild",
						type = "toggle",
						width = "double",
						set = function(info,val)
							self.db.profile.log.Brawlers = val
						end,
						get = function(info)
							return self.db.profile.log.Brawlers
						end,
					},
					logGarrison = {
						order = 110,
						name = _G.GetCategoryInfo(15237) or "Garrison",
						desc = _G.GetCategoryInfo(15237) or "Garrison",
						type = "toggle",
						width = "double",
						set = function(info,val)
							self.db.profile.log.Garrison = val
						end,
						get = function(info)
							return self.db.profile.log.Garrison
						end,
					},
				}
			}
		}
	}

	-- Dynamically add the raid options
	local startOrder = 40
	for i, raid in ipairs(OrderedRaids) do
		options.args.raids.args[raid] = {
			name = self:GetLocalName(raid),
			type = "header",
			order = startOrder + i*20
		}
		for difficulty, enabled in pairs(Raids[raid]["difficulties"] or {}) do
			if enabled then
				options.args.raids.args[raid.."-"..difficulty] = {
					name = difficulty,
					desc = self:GetLocalName(raid) .. " ("..difficulty..")",
					type = "toggle",
					width = "half",
					get = function() 
						return self.db.profile.selectedRaids[raid][difficulty] 
					end,
					set = function(info, value)
						self.db.profile.selectedRaids[raid][difficulty] = value
					end,
					order = startOrder + i*20 + (DifficultyOrder[difficulty] or 1),
				}
			end
		end
	end

	-- Dynamically add the instance options
	local startOrder = 30
	for i, instance in ipairs(OrderedInstances) do
		options.args.instances.args[instance] = {
			name = self:GetLocalName(instance),
			type = "header",
			order = startOrder + i*20
		}
		for difficulty, enabled in pairs(Instances[instance]["difficulties"] or {}) do
			if enabled then
				local tier = Instances[instance].tier or 0
				local mappings = InstanceMappings.tiers[tier] or {}
				options.args.instances.args[instance.."-"..difficulty] = {
					name =  mappings[difficulty] or difficulty,
					desc = self:GetLocalName(instance) .. " ("..difficulty..")",
					type = "toggle",
					width = "half",
					get = function() 
						return self.db.profile.selectedInstances[instance][difficulty] 
					end,
					set = function(info, value)
						self.db.profile.selectedInstances[instance][difficulty] = value
					end,
					order = startOrder + i*20 + (InstanceDifficultyOrder[difficulty] or 1),
				}
			end
		end
	end

	-- Dynamically add the battleground options
	for i, bg in ipairs(Battlegrounds) do
		options.args.bgs.args[bg] = {
			name = self:GetLocalName(bg),
			type = "toggle",
			width = "normal",
			get = function() 
				return self.db.profile.selectedBGs[bg]
			end,
			set = function(info, val)
				self.db.profile.selectedBGs[bg] = val
			end,
			order = startOrder + i*10
		}
	end


	-- Dynamically add the arena options
	for i, arena in ipairs(Arenas) do
		options.args.arenas.args[arena] = {
			name = arena,
			type = "toggle",
			width = "normal",
			get = function() 
				return self.db.profile.selectedArenas[arena]
			end,
			set = function(info, val)
				self.db.profile.selectedArenas[arena] = val
			end,
			order = startOrder + i*10
		}
	end
    
	return options
end

function AutoCombatLogger:ChatCommand(input)
	if not input or input:trim() == "" then
		_G.InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
		_G.InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
	elseif input == "debug" then
		DEBUG = true
		self.db.profile.debug = true
	elseif input == "nodebug" then
		DEBUG = false
		self.db.profile.debug = false
	elseif input == "raids" then
		self:Print("Raids:")
		for i, raid in ipairs(OrderedRaids) do
			self:Print(raid)
		end
	else
		_G.LibStub("AceConfigCmd-3.0").HandleCommand(AutoCombatLogger, 
			"acl", "AutoCombatLogger", input)
	end
end

function AutoCombatLogger:OnInitialize()
	-- Load the settings
	self.db = _G.LibStub("AceDB-3.0"):New("AutoCombatLoggerDB", defaults, "Default")

	DEBUG = self.db.profile.debug

	-- Register the options table
	local config = _G.LibStub("AceConfig-3.0")
	local dialog = _G.LibStub("AceConfigDialog-3.0")
	local options = self:GetOptions()

	config:RegisterOptionsTable("AutoCombatLogger", options)
	self.optionsFrame = dialog:AddToBlizOptions(
		"AutoCombatLogger", "AutoCombatLogger", nil, "general")
	config:RegisterOptionsTable("AutoCombatLogger-Chat", options.args.chat)
	dialog:AddToBlizOptions(
		"AutoCombatLogger-Chat", options.args.chat.name, "AutoCombatLogger")
	config:RegisterOptionsTable("AutoCombatLogger-Raids", options.args.raids)
	dialog:AddToBlizOptions(
		"AutoCombatLogger-Raids", options.args.raids.name, "AutoCombatLogger")
	config:RegisterOptionsTable("AutoCombatLogger-Instances", options.args.instances)
	dialog:AddToBlizOptions(
		"AutoCombatLogger-Instances", options.args.instances.name, "AutoCombatLogger")
	config:RegisterOptionsTable("AutoCombatLogger-Arenas", options.args.arenas)
	dialog:AddToBlizOptions(
		"AutoCombatLogger-Arenas", options.args.arenas.name, "AutoCombatLogger")
	config:RegisterOptionsTable("AutoCombatLogger-BGs", options.args.bgs)
	dialog:AddToBlizOptions(
		"AutoCombatLogger-BGs", options.args.bgs.name, "AutoCombatLogger")
	config:RegisterOptionsTable("AutoCombatLogger-World", options.args.world)
	dialog:AddToBlizOptions(
		"AutoCombatLogger-World", options.args.world.name, "AutoCombatLogger")

	self:RegisterChatCommand("AutoCombatLogger", "ChatCommand")
	self:RegisterChatCommand("acl", "ChatCommand")

	-- Create the LDB launcher
	aclLDB = LDB:NewDataObject("AutoCombatLogger",{
		type = "launcher",
		icon = "Interface\\RAIDFRAME\\ReadyCheck-NotReady.blp",
		OnClick = function(clickedframe, button)
			if button == "RightButton" then
				local optionsFrame = _G.InterfaceOptionsFrame

				if optionsFrame:IsVisible() then
					optionsFrame:Hide()
				else
					_G.InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
				end
			elseif button == "LeftButton" then
				-- Toggle whether the game is logging combat
				if _G.LoggingCombat() then
					_G.LoggingCombat(false)
				else
					_G.LoggingCombat(true)
				end
			end
		end,
		OnTooltipShow = function(tooltip)
			if tooltip and tooltip.AddLine then
			    tooltip:AddLine(addonHdr:format(
					_G.GetAddOnMetadata(ADDON_NAME,"Title"), addon.addonVersion))
				tooltip:AddLine(YELLOW .. L["Left click"] .. " " .. WHITE
					.. L["to toggle combat logging."])
				tooltip:AddLine(YELLOW .. L["Right click"] .. " " .. WHITE
					.. L["to open/close the configuration."])
			end
		end
	})
	icon:Register("AutoCombatLogger", aclLDB, self.db.profile.minimap)
end

function AutoCombatLogger:OnEnable()
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")

	update = _G.CreateFrame("Frame", nil, _G.UIParent)
	update:SetScript("OnUpdate",
		function(self, elapsed)
			self.lastUpdate = (self.lastUpdate or 0) + elapsed
			if self.lastUpdate >= 5.0 then
				self.lastUpdate = 0
				if _G.LoggingCombat() then
					aclLDB.icon = "Interface\\RAIDFRAME\\ReadyCheck-Ready.blp"
				else
					aclLDB.icon = "Interface\\RAIDFRAME\\ReadyCheck-NotReady.blp"
				end
			end
		end)
	
	self:ProcessZoneChange()

	if self.db.profile.chat.enabled then
		self:EnableChatLogging()
	else
		self:DisableChatLogging()
	end
end

function AutoCombatLogger:OnDisable()
	-- Unregister events
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
	self:UnregisterEvent("PLAYER_DIFFICULTY_CHANGED")
end

function AutoCombatLogger:PLAYER_DIFFICULTY_CHANGED()
	-- Just to be safe, wait a few seconds and then check the status
	self:ScheduleTimer("ProcessZoneChange", 3)
end

function AutoCombatLogger:ZONE_CHANGED_NEW_AREA()
	self:ProcessZoneChange()
end

local LogChecks = {
	-- Garrison
	[1] = function(data)
		if _G.IsMapGarrisonMap(data.areaid) and data.profile.log.Garrison then
			return true, "Garrison"
		else
			return false
		end
	end,
	-- Logging Raids
	[2] = function(data)
		if data.type == "raid" and data.profile.logRaid == "Yes" then
			return true, "Raid"
		else
			return false
		end
	end,
	-- Logging Specific Raids
	[3] = function(data)
		if data.type == "raid" and data.profile.logRaid == "Custom" and 
			data.difficulty and data.nonlocalZone and 
			data.profile.selectedRaids[data.nonlocalZone] and
			data.profile.selectedRaids[data.nonlocalZone][data.difficulty]== true then
			return true, "Raid"
		else
			return false
		end
	end,
	-- Logging Instances
	[4] = function(data)
		local diffCheck = data.difficulty and data.difficulty ~= "None" and
			data.difficulty ~= ""
		if data.type == "party" and diffCheck and 
			not _G.IsMapGarrisonMap(data.areaid) and 
			data.profile.logInstance == "Yes" then
			return true, "Instance"
		else
			return false
		end
	end,
		
}

local data = {}
function AutoCombatLogger:ProcessZoneChange()
	local areaid = _G.GetCurrentMapAreaID()
	if not areaid or areaid == 0 or areaid == -1 then
		if not self.zoneTimer then
			self.zoneTimer = self:ScheduleTimer("ProcessZoneChange", 5)
		end
		return
	end

	self.zoneTimer = nil
	local name, type, difficulty, maxPlayers, mapId = self:GetCurrentInstanceInfo()
	local nonlocalZone = Zones[areaid]

	local isGarrison = _G.IsMapGarrisonMap(areaid)
	local isBrawlers = (nonlocalZone == "Brawl'gar Arena" or mapId == 369)

	if DEBUG == true then
		local fmt1 = "Zone: %s, Area ID: %s, Non-Local: %s"
		local fmt2 = "Type: %s, Difficulty: %s, MaxPlayers: %s, Garrison: %s, Brawl: %s"
		self:Print(fmt1:format(name, _G.tostring(areaid), _G.tostring(nonlocalZone)))
		self:Print(fmt2:format(type, difficulty, _G.tostring(maxPlayers), 
			_G.tostring(isGarrison), _G.tostring(isBrawlers)))
	end

	local profile = self.db.profile
	local diffCheck = difficulty and difficulty ~= "None" and difficulty ~= ""

	if _G.UnitOnTaxi("player") then
		if profile.log.Taxi then
			self:EnableCombatLogging("Taxi")
		else
			self:DisableCombatLogging("Taxi")
		end
	elseif isGarrison then
		if profile.log.Garrison then
			self:EnableCombatLogging("Garrison")
		else
			self:DisableCombatLogging()
		end
	elseif (type == "raid" and profile.logRaid == "Yes") then
		self:EnableCombatLogging("Raid")
	elseif (type == "raid" and profile.logRaid == "Custom" and 
		difficulty and nonlocalZone and profile.selectedRaids[nonlocalZone] and
		profile.selectedRaids[nonlocalZone][difficulty]== true) then
			self:EnableCombatLogging("Custom Raid: ".._G.tostring(nonlocalZone))
	elseif (type == "party" and diffCheck and not isGarrison and 
		profile.logInstance == "Yes") then
		self:EnableCombatLogging("Instance")
	elseif (type == "party" and diffCheck and not isGarrison and 
		profile.logInstance == "Custom" and nonlocalZone and profile.selectedInstances[nonlocalZone] and
		profile.selectedInstances[nonlocalZone][difficulty]== true) then
		self:EnableCombatLogging("Custom Instance")
	elseif (type == "arena" and profile.logArena == "Yes") then
		self:EnableCombatLogging("Arena")
	elseif (type == "pvp" and profile.logBG == "Yes") then
		self:EnableCombatLogging("BG")
	elseif (type == "none" and profile.logWorld == "Yes") then
		self:EnableCombatLogging("World")
	elseif (type == "none" and isBrawlers and profile.log.Brawlers) then
		self:EnableCombatLogging("Brawlers")
	else
		self:DisableCombatLogging()
	end

	--if self.db.profile.chat.enabled then
	--	self:EnableChatLogging()
	--else
	--	self:DisableChatLogging()
	--end
end

--- Returns information on the current instance.
-- @return name The name of the current instance or zone.
-- @return type The type of the current instance. (i.e., arena,none,party,pvp,raid)
-- @return difficulty The difficult of the current instance (i.e., 5,5H,10,10H,25,25H)
-- @return maxPlayers The maximum number of players allowed in the instance.
function AutoCombatLogger:GetCurrentInstanceInfo()
	local name, type, instanceDifficulty, difficultyName, maxPlayers, 
		dynamicDifficulty, isDynamic, mapId, new1 = _G.GetInstanceInfo()

	local difficulty = ""
	if (type == "party") then
		difficulty = InstanceDifficulties[instanceDifficulty] or ""
	elseif (type == "raid") then
		difficulty = InstanceDifficulties[instanceDifficulty] or ""
	elseif (type == "scenario") then
		difficulty = InstanceDifficulties[instanceDifficulty] or ""
	end

	return name, type, difficulty, maxPlayers, mapId
end

function AutoCombatLogger:EnableCombatLogging(reason)
	--if DEBUG then
	--	self:Print("Attempt to Enable Combat Logging(".._G.tostring(reason)..")")
	--end

	if _G.LoggingCombat() then return end

	if self.db.profile.verbose then
		self:Print(L["Enabling combat logging"])
	end
	_G.LoggingCombat(true)
end

function AutoCombatLogger:DisableCombatLogging()
	if not _G.LoggingCombat() then return end

	if self.db.profile.verbose then
		self:Print(L["Disabling combat logging"])
	end
	_G.LoggingCombat(false)
end

function AutoCombatLogger:EnableChatLogging()
	if _G.LoggingChat() then return end

	if self.db.profile.verbose then
		self:Print(L["Enabling chat logging"])
	end
	_G.LoggingChat(true)
end

function AutoCombatLogger:DisableChatLogging()
	if not _G.LoggingChat() then return end

	if self.db.profile.verbose then
		self:Print(L["Disabling chat logging"])
	end
	_G.LoggingChat(false)
end
