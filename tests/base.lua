-- Run from the addon directory with Lua 5.0.3: lua tests/base.lua
local checks = 0
local function eq(actual, expected, message)
    checks = checks + 1
    assert(actual == expected, message..": expected "..tostring(expected)..", got "..tostring(actual))
end
getglobal = function(name) return _G[name] end
setglobal = function(name, value) _G[name] = value end
SlashCmdList, UISpecialFrames = {}, {}
local frames = {}
local methods = {}
for _, name in ipairs({ "SetFrameStrata", "SetWidth", "SetHeight", "SetBackdrop", "SetFont", "SetJustifyH", "SetMaxLines", "SetFading", "EnableMouseWheel", "SetMovable", "SetClampedToScreen", "EnableMouse", "RegisterForDrag", "StartMoving", "StopMovingOrSizing", "SetAutoFocus", "SetMaxLetters", "SetTextColor" }) do
    methods[name] = function() end
end
function methods:SetScript(name, callback) self.scripts[name] = callback end
function methods:SetPoint(point, relative, relPoint, x, y) self.point = {point, relative, relPoint, x, y} end
function methods:GetPoint() return unpack(self.point) end
function methods:ClearAllPoints() self.point = nil end
function methods:RegisterEvent(name) self.events[name] = true end
function methods:SetText(text) self.text = text end
function methods:GetText() return self.text or "" end
function methods:SetChecked(value) self.checked = value end
function methods:GetChecked() return self.checked end
function methods:HasFocus() return self.focused end
function methods:ClearFocus() self.focused = false end
function methods:Disable() self.disabled = true end
function methods:IsVisible() return self.visible end
function methods:Hide() self.visible = false end
function methods:Show()
    self.visible = true
    if self.scripts.OnShow then self.scripts.OnShow() end
end
function methods:AddMessage(line) table.insert(self.messages, line) end
function methods:Clear() self.messages = {} end
local function frame(kind, name, parent)
    local f = { kind = kind, name = name, parent = parent, scripts = {}, events = {}, messages = {}, visible = false }
    setmetatable(f, { __index = methods })
    table.insert(frames, f)
    if name then _G[name] = f end
    return f
end
CreateFrame = frame
function methods:CreateFontString(name) return frame("FontString", name, self) end
UIParent = frame("Frame", "UIParent")
DEFAULT_CHAT_FRAME = frame("Frame")
UnitName = function(unit) return "Test" end
UnitClass = function() return "Druida", "DRUID" end
GetAddOnMetadata = function() return nil end -- missing metadata must not break loading

-- Match XML order. File loading must not overwrite SavedVariables before the event.
dofile("HolyShift_Settings.lua")
dofile("HolyShiftCore.lua")
dofile("HolyShift_UI.lua")
eq(HolyShiftDB, nil, "no database before saved variables load")
local host = frame("Frame")
this = host
HolyShift_OnLoad()
eq(host.events.VARIABLES_LOADED, true, "register settings event")
eq(host.events.PLAYER_TARGET_CHANGED, true, "localized druid registers combat events")

-- First install: exact upstream opt-in defaults and synchronized checkboxes.
HolyShift_OnEvent("VARIABLES_LOADED")
HolyShiftToggleUI()
local function checkbox(label)
    for _, f in ipairs(frames) do
        if f.kind == "FontString" and f.text == label then return f.parent end
    end
    error("missing checkbox: "..label)
end
for _, option in ipairs(HolyShiftOptions) do
    eq(HolyShiftDB[option.key], 0, "default "..option.key)
    eq(getglobal(option.variable), 0, "runtime "..option.key)
    eq(checkbox(option.label).checked, false, "UI "..option.key)
end
-- Actual 1.12 checkbuttons return 1 or nil; handle 0 from compatibility layers too.
local cb = checkbox("Auto Innervate")
for _, entry in ipairs({ {1,1}, {0,0}, {true,1}, {false,0} }) do
    this = cb; cb.checked = entry[1]; cb.scripts.OnClick()
    eq(HSInnervateUse, entry[2], "checkbox runtime")
    eq(HolyShiftDB.innervate, entry[2], "checkbox persistence")
end
this = cb; cb.checked = nil; cb.scripts.OnClick()
eq(HSInnervateUse, 0, "unchecked nil")
eq(checkbox("Claw non-bosses (legacy)").disabled, true, "inactive legacy option disabled")

-- Migrating old globals normalizes strings and booleans without enabling defaults.
HolyShiftDB = nil
HSInnervateUse, HSMPUse, HSShiftUse, HSWeapon = "1", true, "0", "  Test Weapon  "
HolyShiftInitializeSettings()
eq(HolyShiftDB.innervate, 1, "migrate numeric string")
eq(HolyShiftDB.manapot, 1, "migrate boolean")
eq(HolyShiftDB.shift, 0, "preserve explicit off")
eq(HSWeapon, "Test Weapon", "migrate equipment")
-- The earlier private UI's table takes precedence over stale mirrored globals.
HolyShiftDB = { innervate = 0, shift = true, offhand = "Shield", position = { point = "TOPLEFT", relPoint = "TOPLEFT", x = 10, y = -20 }, logposition = { point = "BOTTOM", relPoint = "BOTTOM", x = 0, y = 30 } }
HolyShiftInitializeSettings(); HolyShiftRestoreUI()
eq(HSInnervateUse, 0, "DB explicit off wins")
eq(HSShiftUse, 1, "private UI migration")
eq(HSOffhand, "Shield", "private equipment migration")
eq(HolyShiftUIFrame.point[1], "TOPLEFT", "main position restored")
eq(HolyShiftLogFrame.point[5], 30, "log position restored")
HolyShiftDB.position = { point = "bad", relPoint = "CENTER", x = 1, y = 1 }
HolyShiftRestoreUI() -- invalid saved position is ignored

-- All legacy slash toggles remain synchronized with the UI.
for _, option in ipairs(HolyShiftOptions) do
    HolyShift_SlashCommand(option.key.." on")
    eq(HolyShiftDB[option.key], 1, "slash on "..option.key)
    HolyShift_SlashCommand(option.key.." off")
    eq(getglobal(option.variable), 0, "slash off "..option.key)
end
HolyShift_SlashCommand("  weapon   My Weapon  ")
eq(HSWeapon, "My Weapon", "weapon slash")
HolyShift_SlashCommand("offhand none")
eq(HSOffhand, "None", "offhand none")
-- Save BOTH draft fields before refresh can overwrite the other input.
local fields = {}
for _, f in ipairs(frames) do if f.kind == "EditBox" then table.insert(fields, f) end end
fields[1]:SetText("Weapon A"); fields[2]:SetText("Offhand B")
for _, f in ipairs(frames) do if f.text == "Save equipment" then f.scripts.OnClick() end end
eq(HSWeapon, "Weapon A", "equipment UI weapon")
eq(HSOffhand, "Offhand B", "equipment UI offhand")

HSDebugLog = { "persisted line" }
HolyShiftInitializeSettings()
eq(HSDebugLog[1], "persisted line", "keep saved log")
HolyShiftToggleLog()
local viewer
for _, f in ipairs(frames) do if f.kind == "ScrollingMessageFrame" then viewer = f end end
eq(viewer.messages[1], "persisted line", "log viewer populated")
HolyShiftAppendLog("live line")
eq(viewer.messages[2], "live line", "live debug append")
HolyShift_SlashCommand("debug clear")
eq(table.getn(viewer.messages), 0, "clear viewer")
eq(table.getn(HSDebugLog), 0, "clear persisted log")
for i = 1, 520 do table.insert(HSDebugLog, tostring(i)) end
HolyShiftInitializeSettings()
eq(table.getn(HSDebugLog), 500, "bound migrated debug log")
-- Exercise the real logger with its unit dependencies stubbed.
UnitMana = function() return 50 end
GetComboPoints = function() return 2 end
UnitExists = function() return 1 end
CheckInteractDistance = function() return 1 end
GetTime = function() return 10 end
UnitDebuff = function() return nil end
strfind = string.find
date = function() return "12:00:00" end
HolyShift_SlashCommand("debug on")
HSDebugTrace("TEST", "log is working")
eq(table.getn(HSDebugLog), 500, "logger bound")
assert(string.find(HSDebugLog[500], "TEST"))
-- /hsdps dps keeps dispatching exactly once without configuration side effects.
local calls = 0
HolyShiftAddon = function() calls = calls + 1 end
HolyShift_SlashCommand("dps")
eq(calls, 1, "combat macro preserved")
HolyShiftSettingsReady = nil
HolyShiftToggleUI() -- early command must not access an unloaded DB
print("PASS: "..checks.." base/settings/UI checks (Lua ".._VERSION..")")
