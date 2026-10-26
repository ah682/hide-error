-- Run the real add-on in a fresh Lua environment with explicit WoW API fakes.
-- This proves transitions of our API requests, not actual client audio/UI behavior.
local addonPath = os.getenv("HIDEERROR_SOURCE") or "HideErrorPack/HideError/HideError.lua"
local testCount, failures = 0, 0

local function equal(actual, expected, label)
    if actual ~= expected then
        error((label or "value") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual), 2)
    end
end

local function client(speech, errorEvent)
    local state = {
        cvars = { Sound_EnableErrorSpeech = speech or "1", Sound_EnableSFX = "1" },
        muted = {}, played = {}, messages = {}, frames = {},
    }
    local env = setmetatable({}, { __index = _G })
    env._G, env.SlashCmdList = env, {}
    local widget = {}
    function widget:SetSize(w, h) self.width, self.height = w, h end
    function widget:GetWidth() return self.width end
    function widget:GetHeight() return self.height end
    function widget:SetPoint(...) end
    function widget:SetAllPoints(...) end
    function widget:SetColorTexture(...) end
    function widget:SetText(text) self.label = text end
    function widget:SetMovable(...) end
    function widget:SetClampedToScreen(...) end
    function widget:EnableMouse(...) end
    function widget:RegisterForDrag(...) end
    function widget:StartMoving() end
    function widget:StopMovingOrSizing() end
    function widget:SetNormalTexture(...) end
    function widget:SetPushedTexture(...) end
    function widget:Show() self.shown = true end
    function widget:Hide() self.shown = false end
    function widget:IsShown() return self.shown end
    function widget:SetChecked(value) self.checked = value end
    function widget:GetChecked() return self.checked end
    function widget:SetScript(event, callback) self.scripts[event] = callback end
    function widget:RegisterEvent(event) self.events[event] = true end
    function widget:UnregisterEvent(event) self.events[event] = nil end
    function widget:IsEventRegistered(event) return self.events[event] == true end
    local function newWidget()
        return setmetatable({ shown = true, scripts = {}, events = {} }, { __index = widget })
    end
    function widget:CreateTexture(...) return newWidget() end
    function widget:CreateFontString(...) return newWidget() end
    env.CreateFrame = function(kind, name, parent, template)
        local frame = newWidget()
        frame.text = newWidget()
        if name then env[name] = frame end
        table.insert(state.frames, frame)
        return frame
    end
    env.UIParent = newWidget()
    env.UIErrorsFrame = newWidget()
    if errorEvent ~= false then env.UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE") end
    env.GetCVar = function(name) return state.cvars[name] end
    env.SetCVar = function(name, value)
        assert(state.cvars[name] ~= nil, "unexpected CVar " .. name)
        state.cvars[name] = tostring(value)
    end
    env.MuteSoundFile = function(id) state.muted[id] = true end
    env.UnmuteSoundFile = function(id) state.muted[id] = nil end
    env.PlaySound = function(id) table.insert(state.played, id) end
    env.print = function(message) table.insert(state.messages, message) end
    env.DEFAULT_CHAT_FRAME = { AddMessage = function(_, message) table.insert(state.messages, message) end }
    local chunk, message
    if setfenv then
        chunk, message = loadfile(addonPath)
        if chunk then setfenv(chunk, env) end
    else
        chunk, message = loadfile(addonPath, "t", env)
    end
    assert(chunk, message)
    chunk("HideError")
    state.env = env
    function state:click(which, checked)
        local box = self.env[which == "all" and "MyCheckBox" or "MyCheckBox2"]
        box:SetChecked(checked)
        box.scripts.OnClick(box, "LeftButton")
    end
    function state:event(event, ...)
        for _, frame in ipairs(self.frames) do
            if frame:IsEventRegistered(event) and frame.scripts.OnEvent then
                frame.scripts.OnEvent(frame, event, ...)
            end
        end
    end
    return state
end

local function fizzle(state, muted)
    for _, id in ipairs({569772, 569774, 569775, 569776}) do
        equal(state.muted[id] == true, muted, "sound file " .. id)
    end
    equal(#state.played, 0, "mode changes must not play sounds")
end

local function test(name, run)
    testCount = testCount + 1
    local ok, message = pcall(run)
    if ok then
        print("PASS " .. name)
    else
        failures = failures + 1
        print("FAIL " .. name .. "\n  " .. tostring(message))
    end
end

test("initial load preserves settings and leaves both modes off", function()
    local s = client("0", false)
    equal(s.cvars.Sound_EnableErrorSpeech, "0")
    equal(s.env.UIErrorsFrame:IsEventRegistered("UI_ERROR_MESSAGE"), false)
    equal(s.env.MyCheckBox:GetChecked(), false)
    equal(s.env.MyCheckBox2:GetChecked(), false)
    equal(s.env.hideError:IsShown(), false)
    fizzle(s, false)
end)

test("all mode suppresses error event, speech and four fizzle files", function()
    local s = client()
    s:click("all", true)
    equal(s.env.UIErrorsFrame:IsEventRegistered("UI_ERROR_MESSAGE"), false)
    equal(s.cvars.Sound_EnableErrorSpeech, "0")
    equal(s.cvars.Sound_EnableSFX, "1", "unrelated sound preference")
    equal(s.env.MyCheckBox:GetChecked(), true)
    equal(s.env.MyCheckBox2:GetChecked(), false)
    fizzle(s, true)
end)

test("all to fizzle restores other error text and saved speech", function()
    local s = client()
    s:click("all", true)
    s:click("fizzle", true)
    equal(s.env.UIErrorsFrame:IsEventRegistered("UI_ERROR_MESSAGE"), true)
    equal(s.cvars.Sound_EnableErrorSpeech, "1")
    equal(s.env.MyCheckBox:GetChecked(), false)
    equal(s.env.MyCheckBox2:GetChecked(), true)
    fizzle(s, true)
end)

test("leaving all preserves an already disabled speech preference", function()
    local s = client("0")
    s:click("all", true)
    s:click("all", false)
    equal(s.cvars.Sound_EnableErrorSpeech, "0")
    fizzle(s, false)
end)

test("leaving all preserves an already unregistered error event", function()
    local s = client("1", false)
    s:click("all", true)
    s:click("fizzle", true)
    equal(s.env.UIErrorsFrame:IsEventRegistered("UI_ERROR_MESSAGE"), false)
    equal(s.cvars.Sound_EnableErrorSpeech, "1")
end)

test("speech snapshot is captured on entry and refreshed on later entries", function()
    local s = client("1")
    s.cvars.Sound_EnableErrorSpeech = "0"
    s:click("all", true)
    s:click("all", false)
    equal(s.cvars.Sound_EnableErrorSpeech, "0", "pre-entry preference")
    s.cvars.Sound_EnableErrorSpeech = "1"
    s:click("all", true)
    s:click("all", false)
    equal(s.cvars.Sound_EnableErrorSpeech, "1", "next entry preference")
end)

test("fizzle off unmutes sound files without playing them", function()
    local s = client()
    s:click("fizzle", true)
    s:click("fizzle", false)
    fizzle(s, false)
    equal(s.cvars.Sound_EnableErrorSpeech, "1")
    equal(s.env.UIErrorsFrame:IsEventRegistered("UI_ERROR_MESSAGE"), true)
end)

test("fizzle to all to off restores the complete state", function()
    local s = client()
    s:click("fizzle", true)
    s:click("all", true)
    equal(s.env.MyCheckBox2:GetChecked(), false)
    fizzle(s, true)
    s:click("all", false)
    equal(s.env.MyCheckBox:GetChecked(), false)
    equal(s.env.MyCheckBox2:GetChecked(), false)
    equal(s.cvars.Sound_EnableErrorSpeech, "1")
    equal(s.env.UIErrorsFrame:IsEventRegistered("UI_ERROR_MESSAGE"), true)
    fizzle(s, false)
end)

test("repeated selection of all does not overwrite the original preference", function()
    local s = client()
    s:click("all", true)
    s:click("all", true)
    s:click("all", false)
    equal(s.cvars.Sound_EnableErrorSpeech, "1")
    equal(s.env.UIErrorsFrame:IsEventRegistered("UI_ERROR_MESSAGE"), true)
    fizzle(s, false)
end)

test("logout restores settings and unmutes owned fizzle files", function()
    local s = client()
    s:click("all", true)
    s:event("PLAYER_LOGOUT")
    equal(s.cvars.Sound_EnableErrorSpeech, "1")
    equal(s.env.UIErrorsFrame:IsEventRegistered("UI_ERROR_MESSAGE"), true)
    fizzle(s, false)
end)

test("about prints information without toggling the window", function()
    local s = client()
    s.env.SlashCmdList.ABOUT()
    equal(s.env.hideError:IsShown(), false)
    assert(s.messages[#s.messages]:find("/hideerror", 1, true), "about must describe the command")
    s.env.SlashCmdList.HIDEERROR()
    equal(s.env.hideError:IsShown(), true)
    s.env.SlashCmdList.ABOUT()
    equal(s.env.hideError:IsShown(), true)
    s.env.SlashCmdList.HIDEERROR()
    equal(s.env.hideError:IsShown(), false)
end)

test("addon-loaded message only responds to this addon", function()
    local s = client()
    s:event("ADDON_LOADED", "OtherAddon")
    equal(#s.messages, 0)
    s:event("ADDON_LOADED", "HideError")
    equal(#s.messages, 1)
    assert(s.messages[1]:find("/hideerror", 1, true), "load message should name the settings command")
end)

print(string.format("%d tests, %d failures (%s; explicit WoW API fakes)", testCount, failures, _VERSION))
if failures > 0 then error("HideError regressions failed") end
