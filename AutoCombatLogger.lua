local _G = getfenv(0)

local table = _G.table
local pairs = _G.pairs
local ipairs = _G.ipairs

local AutoCombatLogger = _G.LibStub("AceAddon-3.0"):NewAddon("AutoCombatLogger", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")

local L = _G.LibStub("AceLocale-3.0"):GetLocale("AutoCombatLogger", true)
local LDB = _G.LibStub("LibDataBroker-1.1")
local icon = _G.LibStub("LibDBIcon-1.0")

local DEBUG = false

local GREEN = "|cff00ff00"
local YELLOW = "|cffffff00"
local BLUE = "|cff0198e1"
local ORANGE = "|cffff9933"
local WHITE = "|cffffffff"

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
	[930] = "Throne of Thunder",
}

local ReverseZones = {}
for k,v in pairs(Zones) do
	ReverseZones[v] = k
end

local RaidDifficulties = {
    [3] = "10",
    [4] = "25",
    [5] = "10H",
    [6] = "25H",
    [7] = "LFR25"
}

local interestingRaids = {
    "The Eye of Eternity", "Icecrown Citadel", "Naxxramas", "The Obsidian Sanctum",
    "Onyxia's Lair", "The Ruby Sanctum", "Trial of the Crusader", "Ulduar",
    "Vault of Archavon", "Blackwing Descent", "Throne of the Four Winds",
    "The Bastion of Twilight", "Baradin Hold", "Firelands", "Dragon Soul",
	"Mogu'shan Vaults", "Heart of Fear", "Terrace of Endless Spring",
	"Throne of Thunder"
}

-- Define which raids should have heroic modes
local heroicRaids = {
    ["Icecrown Citadel"] = true,
    ["The Ruby Sanctum"] = true,
    ["Trial of the Crusader"] = true,
    ["Blackwing Descent"] = true,
    ["Throne of the Four Winds"] = true,
    ["The Bastion of Twilight"] = true,
    ["Firelands"] = true,
    ["Dragon Soul"] = true,
	["Mogu'shan Vaults"] = true,
	["Heart of Fear"] = true,
	["Terrace of Endless Spring"] = true,
	["Throne of Thunder"] = true,
}

-- Define which raids should have Raid Finder versions
local raidFinder = {
    ["Dragon Soul"] = true,
	["Mogu'shan Vaults"] = true,    
	["Heart of Fear"] = true,
	["Terrace of Endless Spring"] = true,
	["Throne of Thunder"] = true,
}

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
        logBG = "No",
        selectedBGs = {},
        logArena = "No",
        selectedArenas = {},
        logWorld = "No"
    }
}

-- Dynamically add the default raid settings
for j, raid in ipairs(interestingRaids) do
    defaults.profile.selectedRaids[raid] = {}
    for key, difficulty in pairs(RaidDifficulties) do
        -- Don't create a value for a heroic raid if it isn't an option
        local heroic = (difficulty == "10H" or difficulty == "25H")
        if (heroic == false and difficulty ~= "LFR25") or 
            (heroicRaids[raid] and heroic == true) or
            (difficulty == "LFR25" and raidFinder[raid] == true) then
            defaults.profile.selectedRaids[raid][difficulty] = false
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
                    }
                }
            }
        }
    }
        
    -- Dynamically add the raid options
    local startOrder = 40
    for i, raid in ipairs(interestingRaids) do
        options.args.raids.args[raid] = {
            name = self:GetLocalName(raid),
            type = "header",
            order = startOrder + i*10
        }

        for key, difficulty in pairs(RaidDifficulties) do
            local heroic = (difficulty == "10H" or difficulty == "25H")
            if (heroic == false and difficulty ~= "LFR25") or 
                (heroicRaids[raid] and heroic == true) or
                (difficulty == "LFR25" and raidFinder[raid] == true) then
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
        			order = startOrder + i*10 + key,
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
	elseif input == "debug" then
		DEBUG = true
		self.db.profile.debug = true
	elseif input == "nodebug" then
		DEBUG = false
		self.db.profile.debug = false
    else
        _G.LibStub("AceConfigCmd-3.0").HandleCommand(AutoCombatLogger, "acl", "AutoCombatLogger", input)
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
				tooltip:AddLine(GREEN .. L["Auto Combat Logger"])
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
				if _G.LoggingCombat() then
					aclLDB.icon = "Interface\\RAIDFRAME\\ReadyCheck-Ready.blp"
				else
					aclLDB.icon = "Interface\\RAIDFRAME\\ReadyCheck-NotReady.blp"
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

function AutoCombatLogger:ProcessZoneChange()
	local areaid = _G.GetCurrentMapAreaID()
    if not areaid or areaid == 0 then
		if not self.zoneTimer then
			self.zoneTimer = self:ScheduleTimer("ProcessZoneChange", 5)
		end
        return
    end

	self.zoneTimer = nil
    local name, type, difficulty, maxPlayers = self:GetCurrentInstanceInfo()
	local nonlocalZone = Zones[areaid]

    if DEBUG == true then
        self:Print("Zone: "..name..", Area ID: ".. areaid ..", Non-Local: "..(nonlocalZone or ""))
        self:Print("Type: "..type..", Difficulty: "..difficulty..", Max Players: "..maxPlayers)
    end
    
    if (type == "raid" and self.db.profile.logRaid == "Yes") then
        self:EnableCombatLogging()
    elseif (type == "raid" and self.db.profile.logRaid == "Custom" and 
            difficulty and nonlocalZone and 
            self.db.profile.selectedRaids[nonlocalZone] and
            self.db.profile.selectedRaids[nonlocalZone][difficulty]== true) then
        self:EnableCombatLogging()
    elseif (type == "party" and self.db.profile.logInstance == "Yes") then
        self:EnableCombatLogging()
    elseif (type == "arena" and self.db.profile.logArena == "Yes") then
        self:EnableCombatLogging()
    elseif (type == "pvp" and self.db.profile.logBG == "Yes") then
        self:EnableCombatLogging()
    elseif (type == "none" and self.db.profile.logWorld == "Yes") then
        self:EnableCombatLogging()
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
    local InstanceDifficulties = {
        [1] = "5",
        [2] = "5H"
    }

    local name, type, instanceDifficulty, difficultyName, maxPlayers, 
        dynamicDifficulty, isDynamic, mapId = _G.GetInstanceInfo()

    local difficulty = ""
    if (type == "party") then
        difficulty = InstanceDifficulties[instanceDifficulty] or ""
    elseif (type == "raid") then
        difficulty = RaidDifficulties[instanceDifficulty] or ""
    end

    return name, type, difficulty, maxPlayers
end

function AutoCombatLogger:EnableCombatLogging()
	if _G.LoggingCombat() then return end

    if self.db.profile.verbose then
        self:Print(L["Enabling combat logging"])
    end
	_G.LoggingCombat(1)
end

function AutoCombatLogger:DisableCombatLogging()
	if not _G.LoggingCombat() then return end

    if self.db.profile.verbose then
        self:Print(L["Disabling combat logging"])
    end
	_G.LoggingCombat(0)
end

function AutoCombatLogger:EnableChatLogging()
	if _G.LoggingChat() then return end

    if self.db.profile.verbose then
        self:Print(L["Enabling chat logging"])
    end
	_G.LoggingChat(1)
end

function AutoCombatLogger:DisableChatLogging()
	if not _G.LoggingChat() then return end

    if self.db.profile.verbose then
        self:Print(L["Disabling chat logging"])
    end
	_G.LoggingChat(0)
end
