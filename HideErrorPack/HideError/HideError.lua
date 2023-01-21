--[[
Removes Error Messages
Sets Error Speech to Mute
Mutes Fizz Sounds Files
]]

--Print Text in chat on addon load
local function onAddonLoaded(self, event, addonName)
    if addonName == "HideError" then
        DEFAULT_CHAT_FRAME:AddMessage("HideError 10.0.2 loaded type /about for info")
    end
end

local frame = CreateFrame("FRAME")
frame:RegisterEvent("ADDON_LOADED")
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
border:SetPoint("CENTER",myFrame,"CENTER")

-- Title text frame
local title = hideError:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", hideError, 0, -15)
title:SetText("Hide Error Addon Interface")

-- Version Text
local version = hideError:CreateFontString(nil, "OVERLAY", "GameFontNormal")
version:SetPoint("BOTTOM", hideError, 130, 10)
version:SetText("Updated to version 10.0.2 (100002)");

--Hidden on load
hideError:Hide()

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
SlashCmdList["ABOUT"] = ShowHideErrorFrame

--Check Box to Mute All Error Sounds
local myCheckBox = CreateFrame("CheckButton", "MyCheckBox", hideError, "UICheckButtonTemplate")
myCheckBox:SetSize(40, 40)
myCheckBox:SetPoint("TOP", hideError, -200 , -70)
myCheckBox:SetChecked(false)
myCheckBox.text:SetText("Mute all error sounds")

--Check Box to Mute Fizzle Sounds
local myCheckBox2 = CreateFrame("CheckButton", "MyCheckBox2", hideError, "UICheckButtonTemplate")
myCheckBox2:SetSize(40, 40)
myCheckBox2:SetPoint("TOP", hideError, -200 , -140)
myCheckBox2:SetChecked(false)
myCheckBox2.text:SetText("Mute only fizzle sounds")

--On Click Mute All Button on Click and Unmute
myCheckBox:SetScript("OnClick", function()
  if myCheckBox:GetChecked() then
    print("All error sounds are muted.")
    UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE");
    SetCVar("Sound_EnableErrorSpeech", "0");
    myCheckBox2:SetChecked(false)
  else
    print("All error sounds are unmuted.")
    UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE");
    SetCVar("Sound_EnableErrorSpeech", "1");
  end
end)

--Mute Error Sound Button on Click and Unmute
myCheckBox2:SetScript("OnClick", function()
  if myCheckBox2:GetChecked() then
    print("Fizzle sounds are muted.")
    MuteSoundFile(569772)
    MuteSoundFile(569774)
    MuteSoundFile(569775)
    MuteSoundFile(569776)
    myCheckBox:SetChecked(false)
  else
    print("Fizzle sounds are unmuted.")
    PlaySound(569772)
    PlaySound(569774)
    PlaySound(569775)
    PlaySound(569776)
  end
end)

--X Button Created
local crossButton = CreateFrame("Button", nil, hideError, "UIPanelCloseButton")
crossButton:SetSize(20, 20) -- set the size of the button
crossButton:SetPoint("TOPRIGHT", hideError, "TOPRIGHT", -10, -10) -- position the button in the top-right corner of the screen
crossButton:SetNormalTexture("nil")
crossButton:SetPushedTexture("nil")

