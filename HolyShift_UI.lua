-- Adapted from thetimel3ss/holyshift-enhanced, HolyShift_UI.lua (Timeless).
-- Settings are initialized on VARIABLES_LOADED, never during file loading.
--===========================================
-- UI Frame (Main)
--===========================================
HolyShiftUIFrame = CreateFrame("Frame", "HolyShiftUIFrame", UIParent)
table.insert(UISpecialFrames, "HolyShiftUIFrame")
HolyShiftUIFrame:SetFrameStrata("DIALOG")
HolyShiftUIFrame:SetWidth(460)
HolyShiftUIFrame:SetHeight(540)
HolyShiftUIFrame:SetPoint("CENTER", UIParent, "CENTER")

HolyShiftUIFrame:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true, tileSize = 32, edgeSize = 32,
      insets = { left = 11, right = 12, top = 12, bottom = 11 }
  })
HolyShiftUIFrame:Hide()

-- Main Title
local addonVersion = (GetAddOnMetadata("HolyShift", "Version") or "dev")
local mainTitle = HolyShiftUIFrame:CreateFontString(nil, "OVERLAY")
mainTitle:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
mainTitle:SetPoint("TOP", HolyShiftUIFrame, "TOP", 0, -15)
mainTitle:SetText("|cffd08524HolyShift |cffffffffv" .. addonVersion)

-- MainFrame drag
HolyShiftUIFrame:SetMovable(true)
HolyShiftUIFrame:SetClampedToScreen(true)
HolyShiftUIFrame:EnableMouse(true)
HolyShiftUIFrame:RegisterForDrag("LeftButton")
HolyShiftUIFrame:SetScript("OnDragStart", function() this:StartMoving() end) -- Using 'this' for safety
HolyShiftUIFrame:SetScript("OnDragStop", function()
    this:StopMovingOrSizing()

    -- Save current position to database
    local point, _, relPoint, x, y = this:GetPoint()
    if not HolyShiftSettingsReady then return end
    HolyShiftCharacterDB.position = { point = point, relPoint = relPoint, x = x, y = y }
end)

-- MainFrame close button
local mainClose = CreateFrame("Button", nil, HolyShiftUIFrame, "UIPanelCloseButton")
mainClose:SetPoint("TOPRIGHT", HolyShiftUIFrame, "TOPRIGHT", -5, -5)
mainClose:SetScript("OnClick", function()
    HolyShiftUIFrame:Hide()
end)

--==========================================
-- Log Frame
--==========================================
HolyShiftLogFrame = CreateFrame("Frame", "HolyShiftLogFrame", UIParent)
table.insert(UISpecialFrames, "HolyShiftLogFrame")

HolyShiftLogFrame:SetFrameStrata("FULLSCREEN_DIALOG")
HolyShiftLogFrame:SetWidth(450)
HolyShiftLogFrame:SetHeight(400)
HolyShiftLogFrame:SetPoint("CENTER", UIParent, "CENTER")
HolyShiftLogFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
HolyShiftLogFrame:Hide()

-- LogFrame title
local logTitle = HolyShiftLogFrame:CreateFontString(nil, "OVERLAY")
logTitle:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
logTitle:SetPoint("TOP", HolyShiftLogFrame, "TOP", 0, -15)
logTitle:SetText("|cffd08524HolyShift |cffffffff Debug Log")

-- LogFrame drag
HolyShiftLogFrame:SetMovable(true)
HolyShiftLogFrame:SetClampedToScreen(true)
HolyShiftLogFrame:EnableMouse(true)
HolyShiftLogFrame:RegisterForDrag("LeftButton")
HolyShiftLogFrame:SetScript("OnDragStart", function() this:StartMoving() end)
HolyShiftLogFrame:SetScript("OnDragStop", function()
    this:StopMovingOrSizing()
    local point, _, relPoint, x, y = this:GetPoint()
    if not HolyShiftSettingsReady then return end
    HolyShiftCharacterDB.logposition = { point = point, relPoint = relPoint, x = x, y = y }
end)

-- LogFrame close button
local logClose = CreateFrame("Button", nil, HolyShiftLogFrame, "UIPanelCloseButton")
logClose:SetPoint("TOPRIGHT", HolyShiftLogFrame, "TOPRIGHT", -5, -5)




--==================================
-- Checkbox System
--==================================
function HolyShiftTooltip(control, title, text)
    control:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:SetText(title, 1, 0.82, 0)
        GameTooltip:AddLine(text, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    control:SetScript("OnLeave", function() GameTooltip:Hide() end)
end
HolyShiftTooltip(mainClose, "Close settings", "Closes this window. Saved settings remain active.")
HolyShiftTooltip(logClose, "Close log", "Closes the viewer without clearing the log or disabling logging.")

local checkboxes = {}
local function CreateOptionCheckbox(entry, y)
    local cb = CreateFrame("CheckButton", nil, HolyShiftUIFrame, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", HolyShiftUIFrame, "TOPLEFT", 20, y)
    local label = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", cb, "RIGHT", 5, 0)
    label:SetText(entry.label)
    cb:SetScript("OnClick", function()
        local checked = this:GetChecked()
        HolyShiftSetOption(entry.key, checked == true or checked == 1)
    end)
    -- This upstream setting no longer affects builder selection. Preserve its
    -- saved value and command without presenting a working combat control.
    if entry.legacy then
        cb:Disable()
        label:SetTextColor(0.5, 0.5, 0.5)
    end
    HolyShiftTooltip(cb, entry.label, entry.tooltip)
    -- A disabled checkbutton may not receive OnEnter on 1.12; cover its label.
    local hover = CreateFrame("Frame", nil, HolyShiftUIFrame)
    hover:SetWidth(330)
    hover:SetHeight(22)
    hover:SetPoint("TOPLEFT", HolyShiftUIFrame, "TOPLEFT", 52, y - 2)
    hover:EnableMouse(true)
    HolyShiftTooltip(hover, entry.label, entry.tooltip)
    checkboxes[entry.key] = cb
end
for index, entry in ipairs(HolyShiftOptions) do
    CreateOptionCheckbox(entry, -35 - (index - 1) * 25)
end

HolyShiftEquipmentFields = {}
local equipmentFields = HolyShiftEquipmentFields
local previews = {}
local function EquipmentPreview(key, reference)
    local name, texture = HolyShiftEquipmentDisplay(reference)
    previews[key].icon:SetTexture(texture)
    previews[key].name:SetText(name)
end
local function CreateEquipmentField(key, label, y)
    local title = HolyShiftUIFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", HolyShiftUIFrame, "TOPLEFT", 25, y)
    title:SetText(label)
    local field = CreateFrame("EditBox", "HolyShiftEquipment_"..key, HolyShiftUIFrame, "InputBoxTemplate")
    field:SetWidth(205)
    field:SetHeight(22)
    field:SetPoint("TOPLEFT", HolyShiftUIFrame, "TOPLEFT", 150, y + 5)
    field:SetAutoFocus(false)
    field:SetMaxLetters(512)
    local icon = field:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(22); icon:SetHeight(22)
    icon:SetPoint("RIGHT", field, "LEFT", -12, 0)
    local name = HolyShiftUIFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    name:SetPoint("TOPLEFT", HolyShiftUIFrame, "TOPLEFT", 150, y - 21)
    name:SetWidth(270); name:SetJustifyH("LEFT")
    previews[key] = { icon = icon, name = name }
    field:SetScript("OnTextChanged", function()
        local value = this:GetText()
        if string.find(value, "|Hitem:", 1, true) then
            this:SetText(HolyShiftEquipmentInput(value))
            return
        end
        EquipmentPreview(key, value)
    end)
    local purpose = key == "weapon" and "Replacement main-hand weapon after Manual Crowd Pummeler runs out of charges."
        or "Offhand equipped with the replacement weapon, and restored after Ancient Cornerstone Grimoire use."
    HolyShiftTooltip(field, label, purpose.." Enter a name, positive item ID or Shift-click an item link while this field has focus. None disables it. IDs identify the item type, not a specific enchanted copy.")
    local choose = CreateFrame("Button", nil, HolyShiftUIFrame, "UIPanelButtonTemplate")
    choose:SetWidth(65); choose:SetHeight(22)
    choose:SetPoint("LEFT", field, "RIGHT", 12, 0)
    choose:SetText("Bags")
    choose:SetScript("OnClick", function() HolyShiftOpenEquipmentPicker(key) end)
    HolyShiftTooltip(choose, "Choose "..label, "Lists matching equipment currently in your bags. Selecting an item saves its ID for this character; it does not equip the item immediately.")
    field:SetScript("OnEnterPressed", function()
        HolyShiftSetEquipment(key, this:GetText())
        this:ClearFocus()
    end)
    field:SetScript("OnEscapePressed", function()
        this:ClearFocus()
        this:SetText(HolyShiftEquipmentInput(HolyShiftCharacterDB[key]))
    end)
    equipmentFields[key] = field
end
CreateEquipmentField("weapon", "Weapon", -355)
CreateEquipmentField("offhand", "Offhand", -410)
local saveEquipment = CreateFrame("Button", nil, HolyShiftUIFrame, "UIPanelButtonTemplate")
saveEquipment:SetWidth(110)
saveEquipment:SetHeight(22)
saveEquipment:SetPoint("TOPLEFT", HolyShiftUIFrame, "TOPLEFT", 25, -465)
saveEquipment:SetText("Save equipment")
saveEquipment:SetScript("OnClick", function()
    local weapon = equipmentFields.weapon:GetText()
    local offhand = equipmentFields.offhand:GetText()
    HolyShiftSetEquipment("weapon", weapon)
    HolyShiftSetEquipment("offhand", offhand)
    equipmentFields.weapon:ClearFocus()
    equipmentFields.offhand:ClearFocus()
end)
local hint = HolyShiftUIFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
hint:SetPoint("BOTTOMLEFT", HolyShiftUIFrame, "BOTTOMLEFT", 25, 22)
hint:SetText("Name, ID or Shift-click link; None disables the slot.")

function HolyShiftRefreshUI()
    if not HolyShiftSettingsReady then return end
    for key, cb in pairs(checkboxes) do cb:SetChecked(HolyShiftCharacterDB[key] == 1) end
    for key, field in pairs(equipmentFields) do
        if not field:HasFocus() then
            field:SetText(HolyShiftEquipmentInput(HolyShiftCharacterDB[key]))
            EquipmentPreview(key, HolyShiftCharacterDB[key])
        end
    end
end
HolyShiftUIFrame:SetScript("OnShow", HolyShiftRefreshUI)

-- Clear log button
local clearDebugBtn = CreateFrame("Button", "HolyShiftClearDebugBtn", HolyShiftUIFrame, "UIPanelButtonTemplate")
clearDebugBtn:SetWidth(60)
clearDebugBtn:SetHeight(20)
clearDebugBtn:SetPoint("LEFT", HolyShiftUIFrame, "TOPLEFT", 335, -325)
clearDebugBtn:SetText("Clear")

clearDebugBtn:SetScript("OnClick", function()
    HolyShiftClearLog()
    HSPrint('|cffd08524HolyShift |cffffffffDebug log clear.')
end)

-- Tooltip
clearDebugBtn:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
    GameTooltip:SetText("Clears this character's debug log, including the saved entries. Does not disable logging.")
    GameTooltip:Show()
end)
clearDebugBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

HolyShiftTooltip(saveEquipment, "Save equipment", "Saves both equipment fields for this character. Names and links are converted to IDs when resolvable. None disables a slot. This button does not equip items.")
HolyShiftTooltip(clearDebugBtn, "Clear log", "Deletes this character's debug entries. Logging stays enabled if its checkbox is checked.")

-- Debug viewer. Logging persists via HSDebugLog, like upstream.
local logMessages = CreateFrame("ScrollingMessageFrame", nil, HolyShiftLogFrame)
logMessages:SetPoint("TOPLEFT", HolyShiftLogFrame, "TOPLEFT", 25, -45)
logMessages:SetPoint("BOTTOMRIGHT", HolyShiftLogFrame, "BOTTOMRIGHT", -25, 25)
logMessages:SetFont("Fonts\\FRIZQT__.TTF", 11)
logMessages:SetJustifyH("LEFT")
logMessages:SetMaxLines(500)
logMessages:SetFading(false)
logMessages:EnableMouseWheel(true)
logMessages:SetScript("OnMouseWheel", function()
    if arg1 > 0 then this:ScrollUp() else this:ScrollDown() end
end)
function HolyShiftAppendLog(line)
    if HolyShiftLogFrame:IsVisible() then logMessages:AddMessage(line) end
end
function HolyShiftRefreshLog()
    logMessages:Clear()
    for _, line in ipairs(HSDebugLog or {}) do logMessages:AddMessage(tostring(line)) end
end
HolyShiftLogFrame:SetScript("OnShow", HolyShiftRefreshLog)
logClose:SetScript("OnClick", function() HolyShiftLogFrame:Hide() end)

local logButton = CreateFrame("Button", nil, HolyShiftUIFrame, "UIPanelButtonTemplate")
logButton:SetWidth(75)
logButton:SetHeight(22)
logButton:SetPoint("TOPLEFT", HolyShiftUIFrame, "TOPLEFT", 330, -465)
logButton:SetText("View log")

function HolyShiftToggleLog()
    if not HolyShiftSettingsReady then return end
    if HolyShiftLogFrame:IsVisible() then HolyShiftLogFrame:Hide()
    else HolyShiftLogFrame:Show() end
end
logButton:SetScript("OnClick", HolyShiftToggleLog)
HolyShiftTooltip(logButton, "View log", "Opens the last 500 debug entries for this character. Use the mouse wheel to scroll. Enable Debug to record new entries.")

function HolyShiftRestoreUI()
    for _, entry in ipairs({ { HolyShiftUIFrame, "position" }, { HolyShiftLogFrame, "logposition" } }) do
        local frame, key = entry[1], entry[2]
        local p = HolyShiftCharacterDB[key]
        local anchors = { TOP = true, BOTTOM = true, LEFT = true, RIGHT = true, CENTER = true,
            TOPLEFT = true, TOPRIGHT = true, BOTTOMLEFT = true, BOTTOMRIGHT = true }
        if type(p) == "table" and anchors[p.point] and anchors[p.relPoint]
            and type(p.x) == "number" and type(p.y) == "number" then
            frame:ClearAllPoints()
            frame:SetPoint(p.point, UIParent, p.relPoint, p.x, p.y)
        end
    end
    HolyShiftRefreshUI()
end
function HolyShiftToggleUI()
    if not HolyShiftSettingsReady then return end
    if HolyShiftUIFrame:IsVisible() then HolyShiftUIFrame:Hide()
    else HolyShiftUIFrame:Show() end
end
SLASH_HOLYSHIFT_UI1 = "/holyshift"
SLASH_HOLYSHIFT_UI2 = "/hs"
SlashCmdList["HOLYSHIFT_UI"] = HolyShiftToggleUI

-- Paged bag picker; no items are equipped by selecting a row.
local picker = CreateFrame("Frame", "HolyShiftEquipmentPicker", UIParent)
picker:SetWidth(430); picker:SetHeight(420)
picker:SetPoint("CENTER", UIParent, "CENTER")
picker:SetFrameStrata("DIALOG")
picker:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true,
    tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 } })
picker:EnableMouse(true)
picker:Hide()
table.insert(UISpecialFrames, "HolyShiftEquipmentPicker")
local title = picker:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", picker, "TOP", 0, -20)
local close = CreateFrame("Button", nil, picker, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", picker, "TOPRIGHT", -5, -5)
close:SetScript("OnClick", function() picker:Hide() end)
HolyShiftTooltip(close, "Close item picker", "Returns to settings without changing equipment.")
local rows, items, selectedKey, page = {}, {}, nil, 1
local status = picker:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
status:SetPoint("BOTTOM", picker, "BOTTOM", 0, 50)
local function Refresh()
    local pages = math.max(1, math.ceil(table.getn(items) / 10))
    page = math.max(1, math.min(page, pages))
    for index, row in ipairs(rows) do
        local item = items[(page - 1) * 10 + index]
        row.item = item
        if item then
            row.label:SetText(item.name.." ("..HolyShiftItemID(item.reference)..")")
            row.icon:SetTexture(item.texture or "Interface\\Icons\\INV_Misc_QuestionMark")
            row:Show()
        else row:Hide() end
    end
    if table.getn(items) == 0 then status:SetText("No matching equipment in bags. You can still enter an ID.")
    else status:SetText("Page "..page.." / "..pages.." - click an item to save its ID") end
end
for index = 1, 10 do
    local row = CreateFrame("Button", nil, picker)
    row:SetWidth(375); row:SetHeight(28)
    row:SetPoint("TOPLEFT", picker, "TOPLEFT", 25, -45 - (index - 1) * 29)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetWidth(24); row.icon:SetHeight(24)
    row.icon:SetPoint("LEFT", row, "LEFT", 0, 0)
    row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.label:SetPoint("LEFT", row, "LEFT", 32, 0)
    row.label:SetWidth(335); row.label:SetJustifyH("LEFT")
    row:SetScript("OnClick", function()
        if this.item then
            HolyShiftSetEquipment(selectedKey, this.item.reference)
            local field = HolyShiftEquipmentFields[selectedKey]
            field:ClearFocus()
            HolyShiftRefreshUI()
            picker:Hide()
        end
    end)
    row:SetScript("OnEnter", function()
        if this.item then
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(this.item.link)
            GameTooltip:AddLine("Click to save this item ID. Does not equip it.", 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)
    rows[index] = row
end
local function PageButton(label, x, step)
    local button = CreateFrame("Button", nil, picker, "UIPanelButtonTemplate")
    button:SetWidth(85); button:SetHeight(22)
    button:SetPoint("BOTTOM", picker, "BOTTOM", x, 20)
    button:SetText(label)
    button:SetScript("OnClick", function() page = page + step; Refresh() end)
    HolyShiftTooltip(button, label, "Shows another page of matching equipment in your bags.")
end
PageButton("Previous", -95, -1)
PageButton("Next", 95, 1)
function HolyShiftOpenEquipmentPicker(key)
    if not HolyShiftSettingsReady then return end
    selectedKey, page = key, 1
    items = HolyShiftBagEquipment(key)
    title:SetText(key == "weapon" and "Choose main-hand weapon" or "Choose offhand")
    Refresh(); picker:Show()
end
-- Consume item links only when one of our visible inputs is focused. Otherwise
-- delegate to the previous chat handler (including other addons' hooks).
local function InsertEquipmentLink(link)
    if not HolyShiftUIFrame:IsVisible() or not HolyShiftItemID(link) then return false end
    for _, field in pairs(HolyShiftEquipmentFields) do
        if field:HasFocus() then
            field:SetText(HolyShiftEquipmentInput(link))
            return true
        end
    end
    return false
end
if type(ChatEdit_InsertLink) == "function" then
    local previous = ChatEdit_InsertLink
    ChatEdit_InsertLink = function(link)
        if InsertEquipmentLink(link) then return true end
        return previous(link)
    end
end
if ChatFrameEditBox and type(ChatFrameEditBox.Insert) == "function" then
    local previous = ChatFrameEditBox.Insert
    ChatFrameEditBox.Insert = function(self, text)
        if InsertEquipmentLink(text) then return end
        return previous(self, text)
    end
end
HolyShiftUIFrame:SetScript("OnHide", function() picker:Hide() end)
-- Native 1.12 bag/equipment clicks may not call chat insertion while chat is
-- hidden. Route only Shift-left-clicks with one of our fields focused.
if type(ContainerFrameItemButton_OnClick) == "function" then
    local previous = ContainerFrameItemButton_OnClick
    ContainerFrameItemButton_OnClick = function(button, ignoreShift)
        if button == "LeftButton" and not ignoreShift and IsShiftKeyDown() then
            local link = GetContainerItemLink(this:GetParent():GetID(), this:GetID())
            if InsertEquipmentLink(link) then return end
        end
        return previous(button, ignoreShift)
    end
end
if type(PaperDollItemSlotButton_OnClick) == "function" then
    local previous = PaperDollItemSlotButton_OnClick
    PaperDollItemSlotButton_OnClick = function(button, ignoreShift)
        if button == "LeftButton" and not ignoreShift and IsShiftKeyDown() then
            if InsertEquipmentLink(GetInventoryItemLink("player", this:GetID())) then return end
        end
        return previous(button, ignoreShift)
    end
end
if type(SetItemRef) == "function" then
    local previous = SetItemRef
    SetItemRef = function(link, text, button)
        if button == "LeftButton" and IsShiftKeyDown() and InsertEquipmentLink(link) then return end
        return previous(link, text, button)
    end
end
