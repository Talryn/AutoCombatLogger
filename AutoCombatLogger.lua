AutoCombatLogger = LibStub("AceAddon-3.0"):NewAddon("AutoCombatLogger", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("AutoCombatLogger", true)

local LDB = LibStub("LibDataBroker-1.1")
local icon = LibStub("LibDBIcon-1.0")
local Zone = LibStub("LibBabble-Zone-3.0"):GetLookupTable()
local ReverseZone = LibStub("LibBabble-Zone-3.0"):GetReverseLookupTable()

local GREEN = "|cff00ff00"
local YELLOW = "|cffffff00"
local BLUE = "|cff0198e1"
local ORANGE = "|cffff9933"
local WHITE = "|cffffffff"

local RaidDifficulties = {
    [1] = "10",
    [2] = "25",
    [3] = "10H",
    [4] = "25H"
}

local interestingRaids = {
    "The Eye of Eternity", "Icecrown Citadel", "Naxxramas", "The Obsidian Sanctum",
    "Onyxia's Lair", "The Ruby Sanctum", "Trial of the Crusader", "Ulduar",
    "Vault of Archavon"
}

-- Define which raids should have heroic modes
local heroicRaids = {
    ["Icecrown Citadel"] = true,
    ["The Ruby Sanctum"] = true,
    ["Trial of the Crusader"] = true
}

local defaults = {
    profile = {
		minimap = {
			hide = true,
		},
        verbose = false,
        logRaid = "Always",
        selectedRaids = {}
    }
}

-- Dynamically add the default raid settings
for j, raid in ipairs(interestingRaids) do
    defaults.profile.selectedRaids[raid] = {}
    for key, difficulty in pairs(RaidDifficulties) do
        -- Don't create a value for a heroic raid if it isn't an option
        local heroic = (difficulty == "10H" or difficulty == "25H")
        if heroic == false or (heroicRaids[raid] and heroic == true) then
            defaults.profile.selectedRaids[raid][difficulty] = true
        end
    end
end

local function invertTable(table)
    if type(table) ~= "table" then return end

    local newTable = {}
    for key, value in pairs(table) do
        newTable[value] = key 
    end
    
    return newTable
end

local logOptions = {
    [1] = "Never",
    [2] = "Always",
    [3] = "Custom"
}

local invertedOptions = invertTable(logOptions)

local aclLDB = nil
local update = nil

local options

function AutoCombatLogger:GetOptions()
    if options then return options end

    options = {
        name = "AutoCombatLogger",
        handler = AutoCombatLogger,
        type = 'group',
        args = {
    		displayheader = {
    			order = 0,
    		    type = "header",
    		    name = "General Options",
    		},
    	    minimap = {
                name = L["Minimap Button"],
                desc = L["Toggle the minimap button"],
                type = "toggle",
                set = "SetMinimapButton",
                get = "GetMinimapButton",
    			order = 10
            },
            verbose = {
                name = L["Verbose"],
                desc = L["Toggles the display of informational messages"],
                type = "toggle",
                set = "SetVerbose",
                get = "GetVerbose",
    			order = 20
            },
    		displayheader2 = {
    			order = 30,
    		    type = "header",
    		    name = "Raid Options",
    		},
    		logRaid = {
                name = L["Log Raids"],
                desc = L["When to log combat within raids"],
                type = "select",
                width = "double",
                set = "SetLogRaid",
                get = "GetLogRaid",
    			order = 40,
    			values = {
    			    [1] = L["Never"],
    			    [2] = L["Always"],
    			    [3] = L["Custom"],
    			}		    
    		},
        }
    }

    -- Dynamically add the raid options
    local startOrder = 40
    for i, raid in ipairs(interestingRaids) do
        options.args[raid] = {
            name = Zone[raid],
            type = "header",
            order = startOrder + i*10
        }

        for key, difficulty in pairs(RaidDifficulties) do
            local heroic = (difficulty == "10H" or difficulty == "25H")
            if heroic == false or (heroicRaids[raid] and heroic == true) then
                options.args[raid.."-"..difficulty] = {
                    name = difficulty,
                    desc = Zone[raid].." ("..difficulty..")",
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
    
    return options
end

function AutoCombatLogger:ChatCommand(input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    else
        LibStub("AceConfigCmd-3.0").HandleCommand(AutoCombatLogger, "acl", "AutoCombatLogger", input)
    end
end

function AutoCombatLogger:OnInitialize()
    -- Called when the addon is loaded

    -- Load the settings
    self.db = LibStub("AceDB-3.0"):New("AutoCombatLoggerDB", defaults, "Default")
    --options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

    -- Register the options table
    LibStub("AceConfig-3.0"):RegisterOptionsTable("AutoCombatLogger", self:GetOptions())
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(
	    "AutoCombatLogger", "Auto Combat Logger")

    self:RegisterChatCommand("AutoCombatLogger", "ChatCommand")
    self:RegisterChatCommand("acl", "ChatCommand")

	-- Create the LDB launcher
	aclLDB = LDB:NewDataObject("AutoCombatLogger",{
		type = "launcher",
		icon = "Interface\\RAIDFRAME\\ReadyCheck-NotReady.blp",
		OnClick = function(clickedframe, button)
			if button == "RightButton" then
				local optionsFrame = InterfaceOptionsFrame

				if optionsFrame:IsVisible() then
					optionsFrame:Hide()
				else
					InterfaceOptionsFrame_OpenToCategory(AutoCombatLogger.optionsFrame)
				end
			elseif button == "LeftButton" then
				-- Toggle whether the game is logging combat
				if LoggingCombat() then
					LoggingCombat(false)
				else
					LoggingCombat(true)
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
    -- Called when the addon is enabled

    -- Register to receive the ZONE_CHANGED_NEW_AREA event.  This event fires
    -- on a new zone (i.e., chat channels change).
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    -- PLAYER_DIFFICULTY_CHANGED is needed to watch for normal/heroic changes 
    -- while inside a dynamic instance.
    self:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")

	-- Setup the OnUpdate to update the LDB icon
	update = CreateFrame("Frame", nil, UIParent)
	update:SetScript("OnUpdate",
			function(self, elapsed)
				if LoggingCombat() then
					aclLDB.icon = "Interface\\RAIDFRAME\\ReadyCheck-Ready.blp"
				else
					aclLDB.icon = "Interface\\RAIDFRAME\\ReadyCheck-NotReady.blp"
				end
			end)
	
	self:ProcessZoneChange()
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
    -- Check that the zone has been set.  If not, schedule and event to retry.
    local zone = GetRealZoneText()
    if not zone or zone == "" then
        -- Keep trying to find the zone information every 5 seconds.
        self:ScheduleTimer("ProcessZoneChange", 5)
        return
    end

    local name, type, difficulty, maxPlayers = self:GetCurrentInstanceInfo()
    local nonlocalZone = ReverseZone[zone]

    print("Zone: "..name..", Real Zone: ".. zone..", Reverse Zone: "..(nonlocalZone or ""))
    print("Type: "..type..", Difficulty: "..difficulty..", Max Players: "..maxPlayers)

    local alwaysRaid = (self.db.profile.logRaid == "Always")
    local customRaid = (self.db.profile.logRaid == "Custom")

    if (type == "raid" and alwaysRaid == true) then
        self:EnableCombatLogging()
    elseif (type == "raid" and customRaid == true and difficulty and nonlocalZone and 
            self.db.profile.selectedRaids[nonlocalZone][difficulty]== true) then
        self:EnableCombatLogging()
    else
        self:DisableCombatLogging()
    end
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
        dynamicDifficulty, isDynamic = GetInstanceInfo()

    local difficulty = ""
    if (type == "party") then
        difficulty = InstanceDifficulties[instanceDifficulty] or ""
    elseif (type == "raid") then
        difficulty = RaidDifficulties[instanceDifficulty] or ""

        -- If we're in a dynamic instance we have determine if it's heroic 
        -- in a different manner.  For a dynamic instance, the difficulty 
        -- only shows the raid size and not if it is heroic.  Need to check
        -- the last return values to determine heroic.
        if isDynamic and isDynamic == true and dynamicDifficulty == 1 then
            difficulty = difficulty.."H"
        end
    end

    return name, type, difficulty, maxPlayers
end

function AutoCombatLogger:EnableCombatLogging()
    if (self.db.profile.verbose) then
        self:Print(L["Enabling combat logging"])
    end
	LoggingCombat(1)
end

function AutoCombatLogger:DisableCombatLogging()
    if (self.db.profile.verbose) then
        self:Print(L["Disabling combat logging"])
    end
	LoggingCombat(0)
end

function AutoCombatLogger:SetMinimapButton(info, value)
	-- Reverse the value since the stored value is to hide it and not show it
    self.db.profile.minimap.hide = not value
	if self.db.profile.minimap.hide then
		icon:Hide("AutoCombatLogger")
	else
		icon:Show("AutoCombatLogger")
	end
end

function AutoCombatLogger:GetMinimapButton(info)
	-- Reverse the value since the stored value is to hide it and not show it
    return not self.db.profile.minimap.hide
end

function AutoCombatLogger:SetVerbose(info, value)
    self.db.profile.verbose = value
end

function AutoCombatLogger:GetVerbose(info)
    return self.db.profile.verbose
end

function AutoCombatLogger:SetLogRaid(info, value)
    self.db.profile.logRaid = logOptions[value]
end

function AutoCombatLogger:GetLogRaid(info)
    return invertedOptions[self.db.profile.logRaid]
end

