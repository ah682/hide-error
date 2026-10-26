--[[
Removes Error Messages
Sets Error Speech to Mute
Mutes Fizz Sounds Files
]]

-- One mode owns the temporary client changes. See README for the legacy target.
local setMode

--Print Text in chat on addon load
local function onAddonLoaded(self, event, addonName)
    if addonName == "HideError" then
        DEFAULT_CHAT_FRAME:AddMessage("HideError 1.5.1 loaded: /hideerror for settings, /about for info")
    elseif event == "PLAYER_LOGOUT" and setMode then
        -- CVars and sound-file muting can outlive this Lua environment.
        setMode("off")
    end
end

local frame = CreateFrame("FRAME")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", onAddonLoaded)

-- Create main frame hold addon interface
local hideError = CreateFrame("Frame", "hideError", UIParent)

-- Set the frame's size and position
hideError:SetSize(500, 350)
hideError:SetPoint("CENTER")

-- Add a texture to the frame
local texture = hideError:CreateTexture()
texture:SetAllPoints(hideError)
texture:SetColorTexture(0, 0, 0, 0.8)

-- Border
local border = hideError:CreateTexture("FrameBorder", "BACKGROUND")
border:SetColorTexture(1,1,1,0.8)
border:SetSize(hideError:GetWidth()+2,hideError:GetHeight()+2)
border:SetPoint("CENTER",hideError,"CENTER")

-- Title text frame
local title = hideError:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", hideError, 0, -15)
title:SetText("Hide Error Addon Interface")

-- Version Text
local version = hideError:CreateFontString(nil, "OVERLAY", "GameFontNormal")
version:SetPoint("BOTTOM", hideError, 130, 10)
version:SetText("HideError 1.5.1 - legacy Interface 100005");

--Hidden on load
hideError:Hide()

--Makes Frame Movable
hideError:SetMovable(true)
hideError:SetClampedToScreen(true)
hideError:EnableMouse(true)
hideError:RegisterForDrag("LeftButton")
hideError:SetScript("OnDragStart", hideError.StartMoving)
hideError:SetScript("OnDragStop", hideError.StopMovingOrSizing)

--Show and hide parent frame on command
local function ShowHideErrorFrame()
  if hideError:IsShown() then
    hideError:Hide()
    print("Hide Error frame hidden")
  else
    hideError:Show()
    print("Hide Error frame shown")
  end
end
SLASH_HIDEERROR1 = "/hideerror"
SlashCmdList["HIDEERROR"] = ShowHideErrorFrame

--about
local function AboutText()
    print("Addon to Disable Error Sounds and Text type /hideerror to access interface")
end
SLASH_ABOUT1 = "/about"
SlashCmdList["ABOUT"] = AboutText

--Check Box to Mute All Error Sounds
local myCheckBox = CreateFrame("CheckButton", "MyCheckBox", hideError, "UICheckButtonTemplate")
myCheckBox:SetSize(40, 40)
myCheckBox:SetPoint("TOP", hideError, -200 , -70)
myCheckBox:SetChecked(false)
myCheckBox.text:SetText("Mute error text, speech and fizzle")

--Check Box to Mute Fizzle Sounds
local myCheckBox2 = CreateFrame("CheckButton", "MyCheckBox2", hideError, "UICheckButtonTemplate")
myCheckBox2:SetSize(40, 40)
myCheckBox2:SetPoint("TOP", hideError, -200 , -140)
myCheckBox2:SetChecked(false)
myCheckBox2.text:SetText("Mute only fizzle sounds")

-- Muting sound files is global to the client. We only undo the four files
-- this add-on muted; another add-on using the same files can still conflict.
local fizzleFiles = {569772, 569774, 569775, 569776}
local mode = "off"
local savedSpeech, savedErrorEvent

setMode = function(nextMode)
  if nextMode == mode then return end

  if mode == "all" then
    -- Restore the preference/registration observed immediately before suppression.
    SetCVar("Sound_EnableErrorSpeech", savedSpeech)
    if savedErrorEvent then
      UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
    end
    savedSpeech, savedErrorEvent = nil, nil
  end

  if nextMode == "all" then
    savedSpeech = GetCVar("Sound_EnableErrorSpeech")
    savedErrorEvent = UIErrorsFrame:IsEventRegistered("UI_ERROR_MESSAGE")
    UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
    SetCVar("Sound_EnableErrorSpeech", "0")
  end

  -- All and fizzle both suppress these files. Switching between them must
  -- preserve the mute; exiting either must unmute, never play a sound.
  if mode == "off" and nextMode ~= "off" then
    for _, fileID in ipairs(fizzleFiles) do MuteSoundFile(fileID) end
  elseif mode ~= "off" and nextMode == "off" then
    for _, fileID in ipairs(fizzleFiles) do UnmuteSoundFile(fileID) end
  end

  mode = nextMode
  myCheckBox:SetChecked(mode == "all")
  myCheckBox2:SetChecked(mode == "fizzle")
end

myCheckBox:SetScript("OnClick", function(self)
  setMode(self:GetChecked() and "all" or "off")
end)

myCheckBox2:SetScript("OnClick", function(self)
  setMode(self:GetChecked() and "fizzle" or "off")
end)

--X Button Created
local crossButton = CreateFrame("Button", nil, hideError, "UIPanelCloseButton")
crossButton:SetSize(20, 20) -- set the size of the button
crossButton:SetPoint("TOPRIGHT", hideError, "TOPRIGHT", -10, -10) -- position the button in the top-right corner of the screen
crossButton:SetNormalTexture("nil")
crossButton:SetPushedTexture("nil")

