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

addon.addonTitle = _G.GetAddOnMetadata(ADDON_NAME,"Title")
addon.addonVersion = cleanupVersion("@project-version@")

addon.CURRENT_BUILD, addon.CURRENT_INTERNAL,
    addon.CURRENT_BUILD_DATE, addon.CURRENT_UI_VERSION = _G.GetBuildInfo()
addon.Classic = addon.CURRENT_UI_VERSION < 20000
addon.BfA = addon.CURRENT_UI_VERSION >= 80000
