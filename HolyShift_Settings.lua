-- Equipment references are item IDs whenever a name/link can be resolved.
-- Names remain a compatibility fallback for legacy configurations.
function HolyShiftItemID(reference)
    if type(reference) == "number" then
        if reference > 0 and reference == math.floor(reference) then return reference end
        return nil
    end
    if type(reference) ~= "string" then return nil end
    local _, _, id = string.find(reference, "item:(%d+)")
    if not id then _, _, id = string.find(reference, "^(%d+)$") end
    id = tonumber(id)
    if id and id > 0 then return id end
    return nil
end

local function ItemName(link)
    if not link then return nil end
    local _, _, name = string.find(link, "|h%[(.-)%]|h")
    return name
end

function HolyShiftItemMatches(link, reference)
    if not link or not reference or reference == "None" then return false end
    local wanted = HolyShiftItemID(reference)
    if wanted then return HolyShiftItemID(link) == wanted end
    local name = ItemName(link)
    return name and string.lower(name) == string.lower(tostring(reference)) or false
end

function HolyShiftNormalizeEquipment(value)
    if type(value) == "number" then
        local id = HolyShiftItemID(value)
        if id then return "item:"..id end
        return nil
    end
    if type(value) ~= "string" then return "None" end
    local _, _, trimmed = string.find(value, "^%s*(.-)%s*$")
    if trimmed == "" or string.lower(trimmed) == "none" then return "None" end
    local id = HolyShiftItemID(trimmed)
    if id then return "item:"..id end
    if tonumber(trimmed) or string.find(trimmed, "item:", 1, true) then return nil end
    -- Resolve cached names first, then inspect links in bags/equipment. This
    -- also works when GetItemInfo has not cached a manually typed item yet.
    if type(GetItemInfo) == "function" then
        local _, link = GetItemInfo(trimmed)
        id = HolyShiftItemID(link)
        if id then return "item:"..id end
    end
    if type(GetContainerNumSlots) == "function" then
        for bag = 0, 4 do
            for slot = 1, GetContainerNumSlots(bag) do
                local link = GetContainerItemLink(bag, slot)
                if HolyShiftItemMatches(link, trimmed) then return "item:"..HolyShiftItemID(link) end
            end
        end
    end
    if type(GetInventoryItemLink) == "function" then
        for slot = 0, 19 do
            local link = GetInventoryItemLink("player", slot)
            if HolyShiftItemMatches(link, trimmed) then return "item:"..HolyShiftItemID(link) end
        end
    end
    return trimmed
end

function HolyShiftEquipmentDisplay(reference)
    if not reference or reference == "None" then return "None", "Interface\\Icons\\INV_Misc_QuestionMark" end
    if type(GetItemInfo) == "function" then
        local name, _, _, _, _, _, _, _, _, texture = GetItemInfo(reference)
        if name then return name, texture or "Interface\\Icons\\INV_Misc_QuestionMark" end
    end
    local id = HolyShiftItemID(reference)
    return id and ("ID "..id) or reference, "Interface\\Icons\\INV_Misc_QuestionMark"
end

function HolyShiftEquipmentInput(reference)
    return tostring(HolyShiftItemID(reference) or reference or "None")
end

local locations = {
    weapon = { INVTYPE_WEAPON = true, INVTYPE_WEAPONMAINHAND = true, INVTYPE_2HWEAPON = true },
    offhand = { INVTYPE_WEAPON = true, INVTYPE_WEAPONOFFHAND = true, INVTYPE_SHIELD = true, INVTYPE_HOLDABLE = true },
}
function HolyShiftBagEquipment(key)
    local items, seen = {}, {}
    if not locations[key] then return items end
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            local id = HolyShiftItemID(link)
            if id and not seen[id] then
                local name, _, _, _, _, _, _, _, equipLoc, texture = GetItemInfo(link)
                if locations[key][equipLoc] then
                    seen[id] = true
                    table.insert(items, { reference = "item:"..id, name = name or ItemName(link),
                        texture = texture, link = link })
                end
            end
        end
    end
    table.sort(items, function(a, b) return a.name < b.name end)
    return items
end

function HolyShiftEquipItem(reference, destination)
    if not reference or reference == "None" then return false end
    if HolyShiftItemMatches(GetInventoryItemLink("player", destination), reference) then return true end
    -- Never disturb an item already carried by the player's cursor.
    local cursor = CursorHasItem()
    if cursor == true or cursor == 1 then return false end
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            if HolyShiftItemMatches(GetContainerItemLink(bag, slot), reference) then
                local _, _, locked = GetContainerItemInfo(bag, slot)
                if locked ~= true and locked ~= 1 then
                    PickupContainerItem(bag, slot)
                    EquipCursorItem(destination)
                    -- Put the displaced item (or a refused equip) back in its bag slot.
                    cursor = CursorHasItem()
                    if cursor == true or cursor == 1 then PickupContainerItem(bag, slot) end
                    return true -- attempt sent; the client decides equip restrictions
                end
            end
        end
    end
    return false
end

-- Configuration shared by the original commands and Timeless's configuration UI.
-- HolyShiftDB is a read-only legacy import; active settings belong to this character.
HolyShiftOptions = {
    { key = "innervate", tooltip = "Uses Innervate on yourself when mana is low in the boss-mana recovery routine. Does not grant the spell if unlearned.", variable = "HSInnervateUse", label = "Auto Innervate" },
    { key = "mcp", tooltip = "Uses Manual Crowd Pummeler on boss targets. When charges run out, Weapon and Offhand define replacement equipment in your bags.", variable = "HSMCPUse", label = "Auto Manual Crowd Pummeler" },
    { key = "manapot", tooltip = "Allows Major or Superior Mana Potions in the low-mana boss recovery routine. Shares potion cooldowns and consumes your items.", variable = "HSMPUse", label = "Auto Mana Potion" },
    { key = "demonicrune", tooltip = "Allows Demonic Rune in the low-mana boss recovery routine when health is above 1000. Consumes a rune and costs health.", variable = "HSDRUse", label = "Auto Demonic Rune" },
    { key = "flurry", tooltip = "Allows Juju Flurry in the upstream out-of-cat boss/raid routine. Consumes the item; it is not a general on-cooldown trigger in Cat Form.", variable = "HSFLUse", label = "Auto Juju Flurry" },
    { key = "clawadds", tooltip = "Legacy setting retained for compatibility. It currently has no effect: the upstream rotation chooses its builder automatically.", variable = "HSClawAdd", label = "Claw non-bosses (legacy)", legacy = true },
    { key = "tiger", tooltip = "Maintains Tiger's Fury during normal combat when energy, range and combo-point conditions allow. The existing stealth opener can also use it independently.", variable = "HSTigerUse", label = "Auto Tiger's Fury" },
    { key = "shift", tooltip = "Allows low-energy powershifting. Tries Reshift if learned and ready, then the existing Cat Form fallback. Costs mana and may remove buffs.", variable = "HSShiftUse", label = "Auto Powershift" },
    { key = "cower", tooltip = "Allows the optional Cower branch when a non-boss attacks you in a party with more than two other members. The upstream boss emergency routine can use Cower independently.", variable = "HSCowerUse", label = "Auto Cower" },
    { key = "deathrate", tooltip = "Reports estimated remaining fight time from target health changes. Estimates can be inaccurate when targets switch, heal or take burst damage.", variable = "HSDeathrate", label = "Deathrate Report" },
    { key = "ff", tooltip = "Maintains missing Faerie Fire (Feral) when range, cooldown and combo-point conditions allow. Another player's armor debuff can satisfy upkeep.", variable = "HSAutoFF", label = "Auto Faerie Fire" },
    { key = "debug", tooltip = "Records combat decisions and errors in a per-character log of up to 500 lines. View log opens the viewer; Clear removes saved entries.", variable = "HSDebugEnabled", label = "Enable Debug" },
}
HolyShiftOptionByKey = {}
for _, entry in ipairs(HolyShiftOptions) do
    HolyShiftOptionByKey[entry.key] = entry
end

local function NormalizeToggle(value)
    if value == true or tonumber(value) == 1 then return 1 end
    return 0
end

function HolyShiftInitializeSettings()
    if type(HolyShiftCharacterDB) ~= "table" then
        HolyShiftCharacterDB = {}
        -- Import the former account-wide settings once per character, by value.
        -- Never alias the legacy table: another character must not see our edits.
        if type(HolyShiftDB) == "table" then
            for key, value in pairs(HolyShiftDB) do
                if type(value) ~= "table" then HolyShiftCharacterDB[key] = value end
            end
            for _, key in ipairs({ "position", "logposition" }) do
                if type(HolyShiftDB[key]) == "table" then
                    HolyShiftCharacterDB[key] = {}
                    for k, v in pairs(HolyShiftDB[key]) do HolyShiftCharacterDB[key][k] = v end
                end
            end
        end
    end
    for _, entry in ipairs(HolyShiftOptions) do
        local value = HolyShiftCharacterDB[entry.key]
        if value == nil then value = getglobal(entry.variable) end
        value = NormalizeToggle(value) -- upstream defaults: all optional automation off
        HolyShiftCharacterDB[entry.key] = value
        setglobal(entry.variable, value)
    end
    for _, key in ipairs({ "weapon", "offhand" }) do
        local value = HolyShiftCharacterDB[key]
        if value == nil then
            if key == "weapon" then value = HSWeapon else value = HSOffhand end
        end
        value = HolyShiftNormalizeEquipment(value) or "None"
        HolyShiftCharacterDB[key] = value
        if key == "weapon" then HSWeapon = value else HSOffhand = value end
    end
    if type(HSDebugLog) ~= "table" then HSDebugLog = {} end
    while table.getn(HSDebugLog) > 500 do table.remove(HSDebugLog, 1) end
    HolyShiftCharacterDB.schemaVersion = 2
    HolyShiftSettingsReady = true
end

function HolyShiftSetOption(key, value)
    local entry = HolyShiftOptionByKey[key]
    if not entry or not HolyShiftSettingsReady then return false end
    value = NormalizeToggle(value)
    HolyShiftCharacterDB[key] = value
    setglobal(entry.variable, value)
    if HolyShiftRefreshUI then HolyShiftRefreshUI() end
    return true
end

function HolyShiftSetEquipment(key, value)
    if not HolyShiftSettingsReady or (key ~= "weapon" and key ~= "offhand") then return false end
    value = HolyShiftNormalizeEquipment(value)
    if not value then
        HSPrint("HolyShift: enter an item name, positive item ID, item link, or None.")
        return false
    end
    HolyShiftCharacterDB[key] = value
    if key == "weapon" then HSWeapon = value else HSOffhand = value end
    if HolyShiftRefreshUI then HolyShiftRefreshUI() end
    return true
end

function HolyShiftClearLog()
    HSDebugLog = {}
    if HolyShiftRefreshLog then HolyShiftRefreshLog() end
end
