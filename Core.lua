local _G = getfenv(0)
local ADDON_NAME, addon = ...

local table = _G.table
local pairs = _G.pairs

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

local function range(from, to)
	local result = {}
	for i = from, to do
		table.insert(result, i)
	end
	return result
end
addon.range = range

addon.addonTitle = C_AddOns.GetAddOnMetadata(ADDON_NAME,"Title")
addon.addonVersion = cleanupVersion("@project-version@")

local function versionInRange(version, start, finish)
	if _G.type(version) ~= "number" then return false end
	local start = start or 0
	local finish = finish or 100000000
	if _G.type(start) ~= "number" or _G.type(finish) ~= "number" then return false end
	return version >= start and version < finish
  end
  
addon.CURRENT_BUILD, addon.CURRENT_INTERNAL,
	addon.CURRENT_BUILD_DATE, addon.CURRENT_UI_VERSION = _G.GetBuildInfo()
addon.Classic = versionInRange(addon.CURRENT_UI_VERSION, 0, 20000)
addon.TBC = versionInRange(addon.CURRENT_UI_VERSION, 20000, 30000)
addon.Wrath = versionInRange(addon.CURRENT_UI_VERSION, 30000, 40000)
addon.Cataclysm = versionInRange(addon.CURRENT_UI_VERSION, 40000, 50000)
addon.Retail = versionInRange(addon.CURRENT_UI_VERSION, 90000)

function addon.IsGameOptionsVisible()
	local optionsFrame = _G.SettingsPanel or _G.InterfaceOptionsFrame
    return optionsFrame and optionsFrame:IsVisible() or false
end

function addon.ShowGameOptions()
	local optionsFrame = _G.SettingsPanel or _G.InterfaceOptionsFrame
    optionsFrame:Show()
end

function addon.HideGameOptions()
	local optionsFrame = _G.SettingsPanel or _G.InterfaceOptionsFrame
	if _G.SettingsPanel then
		if not _G.UnitAffectingCombat("player") then
			_G.HideUIPanel(optionsFrame)
		end
	else
		optionsFrame:Hide()
	end
end
