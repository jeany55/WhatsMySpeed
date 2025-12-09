# Getting Started with WhatsMySpeed

This guide will help you understand and start using the WhatsMySpeed WoW addon.

## What This Addon Does

WhatsMySpeed is a minimal World of Warcraft addon built with the Ace3 framework. It demonstrates:

1. **Startup Message**: When you log into WoW, the addon prints a message to your chat window
2. **Chat Commands**: You can type `/wms` or `/whatsmyspeed` to interact with the addon

## Quick Start

### Installation

1. **Download the addon files**
2. **Copy to WoW directory**:
   - Navigate to your WoW installation folder
   - Go to `Interface\AddOns\`
   - Copy the entire `WhatsMySpeed` folder here
3. **Restart WoW** or type `/reload` in-game

### Verify Installation

1. Log into WoW
2. At the character select screen or when you log in, you should see:
   ```
   WhatsMySpeed: WhatsMySpeed addon loaded! Type /wms or /whatsmyspeed for help.
   ```

### Using the Addon

Try these commands in the chat window:

```
/wms
```
This will display:
```
WhatsMySpeed: WhatsMySpeed - Commands:
WhatsMySpeed: /wms or /whatsmyspeed - Display this help message
WhatsMySpeed: Addon is running and ready!
```

You can also pass arguments:
```
/wms hello world
```
This will display:
```
WhatsMySpeed: You typed: hello world
```

## Understanding the Code

### Main Files

- **WhatsMySpeed.toc**: Tells WoW how to load the addon
- **WhatsMySpeed.lua**: Contains the addon logic

### Key Concepts

#### Ace3 Framework

The addon uses Ace3, which is a popular WoW addon framework providing:
- **AceAddon-3.0**: Manages addon lifecycle (initialization, enabling, disabling)
- **AceConsole-3.0**: Handles chat commands

#### Addon Lifecycle

```lua
function WhatsMySpeed:OnInitialize()
    -- Called when addon first loads
    -- Register commands here
end

function WhatsMySpeed:OnEnable()
    -- Called when addon is enabled
    -- Set up event handlers here
end

function WhatsMySpeed:OnDisable()
    -- Called when addon is disabled
end
```

#### Chat Commands

```lua
-- Register a command
self:RegisterChatCommand("wms", "ChatCommand")

-- Handle the command
function WhatsMySpeed:ChatCommand(input)
    self:Print("Hello!")
end
```

## Next Steps

This addon provides a framework for building more complex addons. You could:

1. **Track player speed**: Use `GetUnitSpeed("player")` to monitor movement speed
2. **Add UI elements**: Create frames to display information
3. **Handle events**: Register for game events to react to changes
4. **Save data**: Use `SavedVariables` to persist settings between sessions
5. **Add configuration**: Use AceConfig-3.0 for in-game settings

## Resources

- [Ace3 Documentation](https://www.wowace.com/projects/ace3)
- [WoW API Documentation](https://wowpedia.fandom.com/wiki/World_of_Warcraft_API)
- [WoW AddOn Tutorial](https://wowpedia.fandom.com/wiki/UI_beginner%27s_guide)

## Troubleshooting

### Addon doesn't load
- Make sure the folder is named exactly `WhatsMySpeed`
- Check that `WhatsMySpeed.toc` exists in the folder
- Try `/reload` or restart WoW

### Commands don't work
- Make sure you're typing the commands in the chat box
- Commands are case-sensitive: use lowercase
- Try `/wms` first to see if the addon is responding

### No startup message
- Check if addons are enabled in the character select screen
- Look in the AddOns list to verify WhatsMySpeed is loaded
- Check for Lua errors with an error addon like BugSack
