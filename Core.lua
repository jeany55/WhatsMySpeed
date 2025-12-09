local ADDON_NAME = "WhatsMySpeed"
local ADDON_AUTHOR = "Jeany"
local ADDON_VERSION = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")

local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local speedFrame

local addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0")
addon:RegisterChatCommand("wms", "HandleSlashCommand")

-- Delta time accumulator for OnUpdate
local delta = 0

-- Hold player position because GetUnitSpeed does not work for dragonriding
local x = nil
local y = nil

local convertSpeedToPercentage = function(speed)
  return math.floor((speed / BASE_MOVEMENT_SPEED) * 100)
end

-- Does not take account pitch atm. Todo?
local function calculateDragonridingSpeed(newX, newY)
  local dx = newX - x
  local dy = newY - y

  local distance = math.sqrt(dx * dx + dy * dy) -- distance in yards traveled
  local speedYardsPerSecond = distance / addon.db.realm.config.pollingInterval

  return speedYardsPerSecond
end

-- Fires every polling interval
local function updateSpeed()
  local currentSpeed = 0
  local unitSpeed = GetUnitSpeed("player")

  local newX, newY = UnitPosition("player")

  if x and y and newX ~= x and newY ~= y then
    if not unitSpeed or unitSpeed == 0 then
      -- Dragonriding or some other movement method where GetUnitSpeed returns 0
      currentSpeed = calculateDragonridingSpeed(newX, newY)
    else
      currentSpeed = unitSpeed
    end
    local speedAsPercentage = convertSpeedToPercentage(currentSpeed)

    speedFrame.caption:SetText(string.format("%d%%", speedAsPercentage))
  else
    speedFrame.caption:SetText(L["no_speed"])
  end

  x = newX
  y = newY
end

function addon:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New(ADDON_NAME .. "DB")

  if not self.db.realm.config then
    self.db.realm.config = { frameLocked = false, showFrame = true, pollingInterval = 0.5 }
  end

  speedFrame = CreateFrame("Frame", "WhatsMySpeedFrame", UIParent, "BackdropTemplate")
  speedFrame:SetPoint("CENTER")
  speedFrame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
  })
  speedFrame:SetBackdropColor(0, 0, 0, 0.9)
  speedFrame:SetMovable(true)
  speedFrame:EnableMouse(true)
  speedFrame:RegisterForDrag("LeftButton")

  speedFrame.caption = speedFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  speedFrame.caption:SetPoint("CENTER", speedFrame, "CENTER")
  speedFrame.caption:SetText(L["no_speed"])

  speedFrame:SetSize(speedFrame.caption:GetStringWidth() + 30, speedFrame.caption:GetStringHeight() + 20)

  speedFrame:SetScript("OnUpdate", function(self, elapsed)
    delta = delta + elapsed
    if delta >= addon.db.realm.config.pollingInterval then
      delta = 0
      updateSpeed()
    end
  end)

  local isFrameAllowedToMove = function()
    return not addon.db.realm.config.frameLocked and IsShiftKeyDown()
  end

  speedFrame:SetScript("OnDragStart", function(self)
    if isFrameAllowedToMove() then
      self:StartMoving()
    end
  end)
  speedFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
  end)
  self:UpdateFrameVisibility()
end

function addon:UpdateFrameVisibility()
  if self.db.realm.config.showFrame then
    speedFrame:Show()
  else
    speedFrame:Hide()
  end
end

local function splitString(inputstr, delimiter)
  local sep = delimiter or "%s"
  local result = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(result, str)
  end
  return result
end

function addon:HandleSlashCommand(input)
  local splitInput = splitString(input)

  local command = string.lower(splitInput[1] or "")
  local subCommand = string.lower(splitInput[2] or "")

  local addonAuthorFormatted = string.format("|cFF00FFFF%s|r", ADDON_AUTHOR)

  if command == "lock" then
    self.db.realm.config.frameLocked = not self.db.realm.config.frameLocked
  elseif command == "show" then
    self.db.realm.config.showFrame = not self.db.realm.config.showFrame
    self:UpdateFrameVisibility()
  elseif command == "update" then
    local interval = tonumber(subCommand)
    if not interval then
      print(L["invalid_number"])
    elseif interval < 0.5 then
      print(L["min_interval"])
    else
      self.db.realm.config.pollingInterval = interval
    end
  else
    print(string.format(L["welcome"], ADDON_VERSION, addonAuthorFormatted))
    print(string.format(L["slash_command_1"]))
    print(string.format(L["slash_command_2"]))
    print(string.format(L["slash_command_3"], self.db.realm.config.pollingInterval))
  end
end
