-- WhatsMySpeed - A simple WoW addon using Ace3 framework
-- This addon demonstrates basic Ace3 usage with chat commands

-- Create the addon using Ace3
local addonName = "WhatsMySpeed"
local WhatsMySpeed = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0")

-- Called when the addon is initialized
function WhatsMySpeed:OnInitialize()
    -- Print a message to chat when the addon loads
    self:Print("WhatsMySpeed addon loaded! Type /wms or /whatsmyspeed for help.")
    
    -- Register chat commands
    self:RegisterChatCommand("wms", "ChatCommand")
    self:RegisterChatCommand("whatsmyspeed", "ChatCommand")
end

-- Called when the addon is enabled
function WhatsMySpeed:OnEnable()
    -- Called when the addon is enabled
end

-- Called when the addon is disabled
function WhatsMySpeed:OnDisable()
    -- Called when the addon is being disabled
end

-- Handle chat commands
function WhatsMySpeed:ChatCommand(input)
    if not input or input:trim() == "" then
        -- Print help message
        self:Print("WhatsMySpeed - Commands:")
        self:Print("/wms or /whatsmyspeed - Display this help message")
        self:Print("Addon is running and ready!")
    else
        -- Echo back what the user typed
        self:Print("You typed: " .. input)
    end
end
