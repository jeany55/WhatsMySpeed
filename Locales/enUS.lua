-- WhatsMySpeed Locale File
-- English
local L = LibStub("AceLocale-3.0"):NewLocale("WhatsMySpeed", "enUS", true, true)

L["welcome"] = "|cFFFF7F00WhatsMySpeed|r v.|cFF00FF00%s|r by %s."
L["slash_command_1"] = "|cFFFFFF00/wms show|r - Toggle frame visibility"
L["slash_command_2"] = "|cFFFFFF00/wms lock|r - Lock frame"
L["slash_command_3"] =
    "|cFFFFFF00/wms update <x>|r - Set polling interval (how often in seconds the frame updates). Currently set to %f second(s)."

L["no_speed"] = "------"

L["invalid_number"] = "Invalid number provided. Please enter a valid number for the update interval."
L["min_interval"] = "Polling interval cannot be less than 0.5 seconds."
