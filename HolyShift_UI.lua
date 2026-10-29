-- Adapted from thetimel3ss/holyshift-enhanced, HolyShift_UI.lua (Timeless).
-- Settings are initialized on VARIABLES_LOADED, never during file loading.
--===========================================
-- UI Frame (Main)
--===========================================
HolyShiftUIFrame = CreateFrame("Frame", "HolyShiftUIFrame", UIParent)
table.insert(UISpecialFrames, "HolyShiftUIFrame")
HolyShiftUIFrame:SetFrameStrata("DIALOG")
HolyShiftUIFrame:SetWidth(360)
HolyShiftUIFrame:SetHeight(490)
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
    HolyShiftDB.position = { point = point, relPoint = relPoint, x = x, y = y }
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
    HolyShiftDB.logposition = { point = point, relPoint = relPoint, x = x, y = y }
end)

-- LogFrame close button
local logClose = CreateFrame("Button", nil, HolyShiftLogFrame, "UIPanelCloseButton")
logClose:SetPoint("TOPRIGHT", HolyShiftLogFrame, "TOPRIGHT", -5, -5)




--==================================
-- Checkbox System
--==================================
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
    checkboxes[entry.key] = cb
end
for index, entry in ipairs(HolyShiftOptions) do
    CreateOptionCheckbox(entry, -35 - (index - 1) * 25)
end

local equipmentFields = {}
local function CreateEquipmentField(key, label, y)
    local title = HolyShiftUIFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", HolyShiftUIFrame, "TOPLEFT", 25, y)
    title:SetText(label)
    local field = CreateFrame("EditBox", nil, HolyShiftUIFrame, "InputBoxTemplate")
    field:SetWidth(205)
    field:SetHeight(22)
    field:SetPoint("TOPLEFT", HolyShiftUIFrame, "TOPLEFT", 110, y + 5)
    field:SetAutoFocus(false)
    field:SetMaxLetters(128)
    field:SetScript("OnEnterPressed", function()
        HolyShiftSetEquipment(key, this:GetText())
        this:ClearFocus()
    end)
    field:SetScript("OnEscapePressed", function()
        this:ClearFocus()
        this:SetText(HolyShiftDB[key])
    end)
    equipmentFields[key] = field
end
CreateEquipmentField("weapon", "Weapon", -355)
CreateEquipmentField("offhand", "Offhand", -385)
local saveEquipment = CreateFrame("Button", nil, HolyShiftUIFrame, "UIPanelButtonTemplate")
saveEquipment:SetWidth(110)
saveEquipment:SetHeight(22)
saveEquipment:SetPoint("TOPLEFT", HolyShiftUIFrame, "TOPLEFT", 25, -415)
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
hint:SetText("Equipment: enter an item name, or None to disable.")

function HolyShiftRefreshUI()
    if not HolyShiftSettingsReady then return end
    for key, cb in pairs(checkboxes) do cb:SetChecked(HolyShiftDB[key] == 1) end
    for key, field in pairs(equipmentFields) do
        if not field:HasFocus() then field:SetText(HolyShiftDB[key]) end
    end
end
HolyShiftUIFrame:SetScript("OnShow", HolyShiftRefreshUI)

-- Clear log button
local clearDebugBtn = CreateFrame("Button", "HolyShiftClearDebugBtn", HolyShiftUIFrame, "UIPanelButtonTemplate")
clearDebugBtn:SetWidth(60)
clearDebugBtn:SetHeight(20)
clearDebugBtn:SetPoint("LEFT", HolyShiftUIFrame, "TOPLEFT", 235, -325)
clearDebugBtn:SetText("Clear")

clearDebugBtn:SetScript("OnClick", function()
    HolyShiftClearLog()
    HSPrint('|cffd08524HolyShift |cffffffffDebug log clear.')
end)

-- Tooltip
clearDebugBtn:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
    GameTooltip:SetText("Clears the log lines stored in memory.")
    GameTooltip:Show()
end)
clearDebugBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

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
logButton:SetPoint("TOPLEFT", HolyShiftUIFrame, "TOPLEFT", 240, -415)
logButton:SetText("View log")

function HolyShiftToggleLog()
    if not HolyShiftSettingsReady then return end
    if HolyShiftLogFrame:IsVisible() then HolyShiftLogFrame:Hide()
    else HolyShiftLogFrame:Show() end
end
logButton:SetScript("OnClick", HolyShiftToggleLog)

function HolyShiftRestoreUI()
    for _, entry in ipairs({ { HolyShiftUIFrame, "position" }, { HolyShiftLogFrame, "logposition" } }) do
        local frame, key = entry[1], entry[2]
        local p = HolyShiftDB[key]
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
