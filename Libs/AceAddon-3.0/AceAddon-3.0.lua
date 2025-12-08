--- **AceAddon-3.0** provides a framework for creating addons.
-- @class file
-- @name AceAddon-3.0
-- @release $Id: AceAddon-3.0.lua 1202 2019-05-15 23:11:39Z nevcairiel $

local MAJOR, MINOR = "AceAddon-3.0", 13
local AceAddon, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not AceAddon then return end -- No upgrade needed

AceAddon.frame = AceAddon.frame or CreateFrame("Frame", "AceAddon30Frame") -- Our very own frame
AceAddon.addons = AceAddon.addons or {} -- addons in general
AceAddon.statuses = AceAddon.statuses or {} -- statuses of addon.
AceAddon.initializequeue = AceAddon.initializequeue or {} -- addons that are new and not initialized
AceAddon.enablequeue = AceAddon.enablequeue or {} -- addons that are initialized and waiting to be enabled
AceAddon.embeds = AceAddon.embeds or setmetatable({}, {__index = function(tbl, key) tbl[key] = {} return tbl[key] end}) -- contains a list of libraries embedded in an addon

-- Lua APIs
local tinsert, tconcat, tremove = table.insert, table.concat, table.remove
local fmt, tostring = string.format, tostring
local select, pairs, next, type, unpack = select, pairs, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: geterrorhandler, LibStub, CreateFrame

xpcall = xpcall

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function safecall(func, ...)
	if func then
		return xpcall(func, errorhandler, ...)
	end
end

-- local function to enable an addon
local function EnableAddon(self, addon)
	if type(addon) == "string" then addon = AceAddon:GetAddon(addon) end
	if addon.enabledState then return end -- already enabled
	
	addon.enabledState = true
	safecall(addon.OnEnable, addon)
	
	-- Fire OnEnable for all embeded addons
	for i, module in pairs(addon.modules or {}) do
		if module.enabledState == nil then
			EnableAddon(self, module)
		end
	end
	
	return true
end

-- local function to initialize an addon
local function InitializeAddon(self, addon)
	safecall(addon.OnInitialize, addon)

	-- We don't call InitializeAddon on modules, the addon will do that itself
end

-- local function to disable an addon
local function DisableAddon(self, addon)
	if type(addon) == "string" then addon = AceAddon:GetAddon(addon) end
	if not addon.enabledState then return end
	
	addon.enabledState = false
	safecall(addon.OnDisable, addon)
	
	-- Fire OnDisable for all embeded addons
	for i, module in pairs(addon.modules or {}) do
		if module.enabledState then
			DisableAddon(self, module)
		end
	end
	
	return true
end

--- **DEPRECATED**: Use :NewAddon instead, or use :GetAddon to get an existing addon.
-- @name AceAddon:NewAddon
function AceAddon:NewAddon(objectorname, ...)
	local object, name
	if type(objectorname) == "table" then
		object = objectorname
		name = object.name or tostring(object)
	else
		name = objectorname
	end
	
	if self.addons[name] then error(fmt("Addon '%s' already exists.", name), 2) end
	
	object = object or {}
	object.name = name
	
	local addonmeta = {}
	local oldmeta = getmetatable(object)
	if oldmeta then
		for k, v in pairs(oldmeta) do addonmeta[k] = v end
	end
	addonmeta.__tostring = function() return object.name end
	setmetatable( object, addonmeta )
	
	self.addons[name] = object
	
	-- embed dependencies
	for i=1,select('#', ...) do
		self:EmbedLibrary(object, select(i, ...), false, 4)
	end
	tinsert(self.initializequeue, object)
	return object
end

--- Get the addon object by name.
-- @name AceAddon:GetAddon
function AceAddon:GetAddon(name)
	return self.addons[name]
end

--- Embeds AceAddon-3.0 into the target object making the functions from the mixins list available on target:..
-- @param target target object to embed aceaddon in
-- @param ... list of mixins to embed
function AceAddon:EmbedLibrary(target, libname, silent, offset)
	local lib = LibStub:GetLibrary(libname, silent)
	if not lib then return end
	
	local mixin = lib.embeds and lib.embeds[target]
	if not mixin then
		mixin = {}
		
		for name, func in pairs(lib) do
			if type(func) == "function" and not name:match("^[A-Z]") then
				mixin[name] = func
			end
		end
		
		if lib.embeds then
			lib.embeds[target] = mixin
		end
	end
	
	for name, func in pairs(mixin) do
		target[name] = func
	end
	
	return true
end

--- Iterate over all registered addons.
-- @name AceAddon:IterateAddons
function AceAddon:IterateAddons()
	return pairs(self.addons)
end

--- Iterate over all embeds for a particular addon.
-- @name AceAddon:IterateEmbedsOnAddon
function AceAddon:IterateEmbedsOnAddon(addon)
	return pairs(self.embeds[addon])
end

-- Event handling
local function OnEvent(this, event, arg1)
	if event == "PLAYER_LOGIN" then
		for i = 1, #AceAddon.initializequeue do
			InitializeAddon(AceAddon, AceAddon.initializequeue[i])
		end
		for i = 1, #AceAddon.enablequeue do
			EnableAddon(AceAddon, AceAddon.enablequeue[i])
		end
	end
end

AceAddon.frame:RegisterEvent("PLAYER_LOGIN")
AceAddon.frame:SetScript("OnEvent", OnEvent)

-- Addon initialization
function AceAddon:PLAYER_LOGIN()
	-- Initialize all addons
	for i = 1, #self.initializequeue do
		InitializeAddon(self, self.initializequeue[i])
	end
	
	-- Enable all addons
	for i = 1, #self.enablequeue do
		EnableAddon(self, self.enablequeue[i])
	end
end

local mixins = {
	"NewAddon", "GetAddon", "EmbedLibrary", "IterateAddons", "IterateEmbedsOnAddon"
}

-- Embed ourselves
for k, v in pairs(mixins) do
	AceAddon[v] = AceAddon[v]
end
