local maxSlots = 8
local sequence = {}

-- MAIN FRAME (TRANSPARENT OVERLAY)
local f = CreateFrame("Frame", "SimonCompassFrame", UIParent)
f:SetSize(260, 320)
f:SetPoint("CENTER")

f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetClampedToScreen(true)
f:EnableKeyboard(true)
f:SetPropagateKeyboardInput(false)
f:Hide()

f:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

-- REMOVE ANY DEFAULT BACKGROUND TEXTURES
for _, region in pairs({f:GetRegions()}) do
    if region.SetTexture then
        region:SetTexture(nil)
    end
end

-- GHOST BACKGROUND (subtle)
local bg = f:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(0, 0, 0, 0.15)

-- TITLE
local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
title:SetPoint("TOP", 0, -10)
title:SetText("Simon Compass Helper")

-- CLOSE BUTTON (X)
local closeBtn = CreateFrame("Button", nil, f)
closeBtn:SetSize(24, 24)
closeBtn:SetPoint("TOPRIGHT", -5, -5)

closeBtn:SetNormalFontObject("GameFontHighlight")
closeBtn:SetText("|cffff5555X|r")

closeBtn:SetScript("OnClick", function()
    f:Hide()
end)

-- SLOT DISPLAY
local slots = {}

for i = 1, maxSlots do
    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetSize(24, 24)
    tex:SetColorTexture(0.2, 0.2, 0.2)
    tex:SetPoint("BOTTOMLEFT", 10 + (i - 1) * 28, 20)
    slots[i] = tex
end

local function render()
    for i = 1, maxSlots do
        local c = sequence[i]

        if c == "yellow" then
            slots[i]:SetColorTexture(1, 0.9, 0.2)
        elseif c == "blue" then
            slots[i]:SetColorTexture(0.2, 0.6, 1)
        elseif c == "green" then
            slots[i]:SetColorTexture(0.2, 1, 0.4)
        elseif c == "red" then
            slots[i]:SetColorTexture(1, 0.2, 0.2)
        else
            slots[i]:SetColorTexture(0.2, 0.2, 0.2)
        end
    end
end

local function add(color)
    if #sequence >= maxSlots then return end
    table.insert(sequence, color)
    render()
end

local function undo()
    table.remove(sequence)
    render()
end

local function reset()
    sequence = {}
    render()
end

-- BUTTON CREATION (WASD COMPASS)
local function makeButton(text, color, x, y, r, g, b)
    local btn = CreateFrame("Button", nil, f)
    btn:SetSize(50, 50)
    btn:SetPoint("CENTER", x, y)

    local bgTex = btn:CreateTexture(nil, "BACKGROUND")
    bgTex:SetAllPoints()
    bgTex:SetColorTexture(r, g, b, 0.9)

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    label:SetPoint("CENTER")
    label:SetText(text)

    btn:SetScript("OnClick", function()
        add(color)
    end)

    return btn
end

-- WASD LAYOUT
makeButton("W", "yellow", 0, 80, 1, 0.9, 0.2)
makeButton("D", "blue",   80, 0, 0.2, 0.6, 1)
makeButton("A", "green", -80, 0, 0.2, 1, 0.4)
makeButton("S", "red",    0, -80, 1, 0.2, 0.2)

-- INSTRUCTIONS
local helpText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
helpText:SetPoint("BOTTOM", 0, 5)
helpText:SetText("W A S D = Input | R = Reset | Backspace = Undo")
helpText:SetTextColor(0.8, 0.8, 0.8)

-- KEY INPUT
f:SetScript("OnKeyDown", function(_, key)
    key = key:lower()

    if key == "w" then add("yellow") return end
    if key == "d" then add("blue") return end
    if key == "a" then add("green") return end
    if key == "s" then add("red") return end

    if key == "backspace" then undo() return end
    if key == "r" then reset() return end
end)

-- SLASH COMMAND
SLASH_SIMON1 = "/simon"

SlashCmdList["SIMON"] = function(msg)
    msg = msg and msg:lower() or ""

    if msg == "reset" then
        reset()
        return
    end

    if f:IsShown() then
        f:Hide()
    else
        f:Show()
    end
end

-- INIT
render()