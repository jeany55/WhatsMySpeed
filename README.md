# WhatsMySpeed

A simple World of Warcraft addon built with the Ace3 framework. This addon provides a basic framework for WoW addon development.

## Features

- Built with the Ace3 framework (AceAddon-3.0, AceConsole-3.0)
- Prints a message to chat when the addon loads
- Includes chat commands for interaction

## Installation

1. Download or clone this repository
2. Copy the `WhatsMySpeed` folder to your World of Warcraft `Interface\AddOns\` directory
3. Restart WoW or reload your UI with `/reload`

## Usage

### Chat Commands

The addon provides the following chat commands:

- `/wms` - Display help message and addon status
- `/whatsmyspeed` - Display help message and addon status

Both commands can accept optional arguments which will be echoed back to demonstrate command handling.

### Examples

```
/wms
/whatsmyspeed
/wms hello world
```

## Development

This addon uses the Ace3 library framework, which provides:

- **AceAddon-3.0**: Core addon management and lifecycle
- **AceConsole-3.0**: Chat command registration and handling
- **LibStub**: Library versioning and management
- **CallbackHandler-1.0**: Event callback management

### File Structure

```
WhatsMySpeed/
├── WhatsMySpeed.toc     # Addon table of contents
├── WhatsMySpeed.lua     # Main addon code
└── Libs/                # Ace3 libraries
    ├── LibStub/
    ├── CallbackHandler-1.0/
    ├── AceAddon-3.0/
    └── AceConsole-3.0/
```

### Addon Lifecycle

The addon follows the standard Ace3 lifecycle:

1. **OnInitialize()**: Called when the addon is first loaded
2. **OnEnable()**: Called when the addon is enabled (after PLAYER_LOGIN)
3. **OnDisable()**: Called when the addon is disabled

## License

See LICENSE file for details.
