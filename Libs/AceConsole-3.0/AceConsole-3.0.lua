--- **AceConsole-3.0** provides registration facilities for slash commands.
-- @class file
-- @name AceConsole-3.0
-- @release $Id: AceConsole-3.0.lua 1202 2019-05-15 23:11:39Z nevcairiel $
local MAJOR, MINOR = "AceConsole-3.0", 7

local AceConsole, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not AceConsole then return end -- No upgrade needed

AceConsole.embeds = AceConsole.embeds or {} -- what objects embed this lib
AceConsole.commands = AceConsole.commands or {} -- registered commands
AceConsole.weakcommands = AceConsole.weakcommands or {} -- weakly-referenced commands (used for plugins)

-- Lua APIs
local tconcat, tostring, select = table.concat, tostring, select
local type, pairs, error = type, pairs, error
local format, strfind, strsub = string.format, string.find, string.sub
local max = math.max

-- WoW APIs
local _G = _G

-- local constants
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME

-----------------------------------------------------------------------
-- AceConsole:Print(...)
-- Print to the default chat frame.

function AceConsole:Print(...)
	local output = "|cff33ff99"..tostring(self.name or self).."|r: "
	for i = 1, select("#", ...) do
		output = output .. tostring(select(i, ...)) .. " "
	end
	DEFAULT_CHAT_FRAME:AddMessage(output)
end

-----------------------------------------------------------------------
-- AceConsole:Printf(...)
-- Print formatted text to the default chat frame.

function AceConsole:Printf(...)
	self:Print(format(...))
end

-----------------------------------------------------------------------
-- AceConsole:RegisterChatCommand(command, func, persist)
-- Register a chat command
-- command  - the command to register ("/command")
-- func     - the function or method to call (function or string)
-- persist  - if true, the command will not be unregistered when the object is disabled

function AceConsole:RegisterChatCommand(command, func, persist)
	if type(command) ~= "string" then error("Usage: RegisterChatCommand(command, func[, persist]): 'command' - string expected.", 2) end
	
	if type(func) == "string" then
		local method = func
		func = function(...)
			self[method](self, ...)
		end
	elseif type(func) ~= "function" then
		error("Usage: RegisterChatCommand(command, func[, persist]): 'func' - function or method name expected.", 2)
	end
	
	if not AceConsole.commands[command] then
		-- register the command with WoW
		_G["SLASH_"..command.."1"] = "/"..command
		SlashCmdList[command] = function(input, editBox)
			AceConsole:ExecuteCommand(input, editBox, command)
		end
	end
	
	AceConsole.commands[command] = AceConsole.commands[command] or {}
	AceConsole.commands[command][self] = func
	
	if persist then
		AceConsole.weakcommands[command] = AceConsole.weakcommands[command] or {}
		AceConsole.weakcommands[command][self] = func
	end
	
	return true
end

-----------------------------------------------------------------------
-- AceConsole:UnregisterChatCommand(command)
-- Unregister a chat command

function AceConsole:UnregisterChatCommand(command)
	if AceConsole.commands[command] then
		AceConsole.commands[command][self] = nil
		if not next(AceConsole.commands[command]) then
			-- no more registered commands, remove the WoW command
			_G["SLASH_"..command.."1"] = nil
			SlashCmdList[command] = nil
			AceConsole.commands[command] = nil
		end
	end
end

-----------------------------------------------------------------------
-- AceConsole:ExecuteCommand(...)
-- Execute a command (for internal use)

function AceConsole:ExecuteCommand(input, editBox, command)
	if not AceConsole.commands[command] then return end
	
	-- execute all registered commands
	for addon, func in pairs(AceConsole.commands[command]) do
		func(input, editBox)
	end
end

-----------------------------------------------------------------------
-- Embed AceConsole into an addon

local mixins = {
	"Print",
	"Printf",
	"RegisterChatCommand",
	"UnregisterChatCommand",
}

-- Embeds AceConsole into the target object making the functions from the mixins list available on target:..
-- @param target target object to embed AceConsole in
function AceConsole:Embed(target)
	for k, v in pairs(mixins) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end

-- AceConsole:OnEmbedDisable(target)
-- target is being disabled, unregister all events
function AceConsole:OnEmbedDisable(target)
	-- We don't unregister commands on disable, as they are persistent
end

for addon in pairs(AceConsole.embeds) do
	AceConsole:Embed(addon)
end
