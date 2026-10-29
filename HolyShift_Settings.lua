-- Configuration shared by the original commands and Timeless's configuration UI.
-- Keep the original globals as SavedVariables for migration and debug export.
HolyShiftOptions = {
    { key = "innervate", variable = "HSInnervateUse", label = "Auto Innervate" },
    { key = "mcp", variable = "HSMCPUse", label = "Auto Manual Crowd Pummeler" },
    { key = "manapot", variable = "HSMPUse", label = "Auto Mana Potion" },
    { key = "demonicrune", variable = "HSDRUse", label = "Auto Demonic Rune" },
    { key = "flurry", variable = "HSFLUse", label = "Auto Juju Flurry" },
    { key = "clawadds", variable = "HSClawAdd", label = "Claw non-bosses (legacy)", legacy = true },
    { key = "tiger", variable = "HSTigerUse", label = "Auto Tiger's Fury" },
    { key = "shift", variable = "HSShiftUse", label = "Auto Powershift" },
    { key = "cower", variable = "HSCowerUse", label = "Auto Cower" },
    { key = "deathrate", variable = "HSDeathrate", label = "Deathrate Report" },
    { key = "ff", variable = "HSAutoFF", label = "Auto Faerie Fire" },
    { key = "debug", variable = "HSDebugEnabled", label = "Enable Debug" },
}
HolyShiftOptionByKey = {}
for _, entry in ipairs(HolyShiftOptions) do
    HolyShiftOptionByKey[entry.key] = entry
end

local function NormalizeToggle(value)
    if value == true or tonumber(value) == 1 then return 1 end
    return 0
end

local function NormalizeEquipment(value)
    if type(value) ~= "string" then return "None" end
    local _, _, trimmed = string.find(value, "^%s*(.-)%s*$")
    if trimmed == "" or string.lower(trimmed) == "none" then return "None" end
    return trimmed
end

function HolyShiftInitializeSettings()
    if type(HolyShiftDB) ~= "table" then HolyShiftDB = {} end
    for _, entry in ipairs(HolyShiftOptions) do
        local value = HolyShiftDB[entry.key]
        if value == nil then value = getglobal(entry.variable) end
        value = NormalizeToggle(value) -- upstream defaults: all optional automation off
        HolyShiftDB[entry.key] = value
        setglobal(entry.variable, value)
    end
    for _, key in ipairs({ "weapon", "offhand" }) do
        local value = HolyShiftDB[key]
        if value == nil then
            if key == "weapon" then value = HSWeapon else value = HSOffhand end
        end
        value = NormalizeEquipment(value)
        HolyShiftDB[key] = value
        if key == "weapon" then HSWeapon = value else HSOffhand = value end
    end
    if type(HSDebugLog) ~= "table" then HSDebugLog = {} end
    while table.getn(HSDebugLog) > 500 do table.remove(HSDebugLog, 1) end
    HolyShiftDB.schemaVersion = 1
    HolyShiftSettingsReady = true
end

function HolyShiftSetOption(key, value)
    local entry = HolyShiftOptionByKey[key]
    if not entry or not HolyShiftSettingsReady then return false end
    value = NormalizeToggle(value)
    HolyShiftDB[key] = value
    setglobal(entry.variable, value)
    if HolyShiftRefreshUI then HolyShiftRefreshUI() end
    return true
end

function HolyShiftSetEquipment(key, value)
    if not HolyShiftSettingsReady or (key ~= "weapon" and key ~= "offhand") then return false end
    value = NormalizeEquipment(value)
    HolyShiftDB[key] = value
    if key == "weapon" then HSWeapon = value else HSOffhand = value end
    if HolyShiftRefreshUI then HolyShiftRefreshUI() end
    return true
end

function HolyShiftClearLog()
    HSDebugLog = {}
    if HolyShiftRefreshLog then HolyShiftRefreshLog() end
end
