-- HekiliHelper.lua
local addonName, ns = ...

-- Create our addon frame and register for events
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:RegisterEvent("UNIT_HEALTH")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("UNIT_AURA")
f:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")

-- Create a debug overlay frame
local debugFrame = CreateFrame("Frame", "HekiliHelperDebugFrame", UIParent, "BackdropTemplate")
debugFrame:SetSize(400, 300)
debugFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
debugFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
debugFrame:SetBackdropColor(0, 0, 0, 0.7)
debugFrame:SetMovable(true)
debugFrame:EnableMouse(true)
debugFrame:RegisterForDrag("LeftButton")
debugFrame:SetScript("OnDragStart", debugFrame.StartMoving)
debugFrame:SetScript("OnDragStop", debugFrame.StopMovingOrSizing)

-- Add header
local header = debugFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
header:SetPoint("TOPLEFT", debugFrame, "TOPLEFT", 10, -10)
header:SetText("HekiliHelper Mouseover Info")

-- Create scrolling text frame for target details
local scrollFrame = CreateFrame("ScrollFrame", "HekiliHelperDebugScrollFrame", debugFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -5)
scrollFrame:SetPoint("BOTTOMRIGHT", debugFrame, "BOTTOMRIGHT", -30, 10)

local scrollChild = CreateFrame("Frame")
scrollFrame:SetScrollChild(scrollChild)
scrollChild:SetSize(scrollFrame:GetWidth(), 600)

local debugText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
debugText:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, -5)
debugText:SetWidth(scrollChild:GetWidth() - 10)
debugText:SetJustifyH("LEFT")
debugText:SetJustifyV("TOP")
debugText:SetText("No mouseover target selected.\n")

-- Close button
local closeButton = CreateFrame("Button", nil, debugFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", debugFrame, "TOPRIGHT", 0, 0)

-- Hide by default
debugFrame:Hide()

local initialized = false
local lastMouseoverGUID = nil
local lastMouseoverHealth = 0
local lastMouseoverCheck = 0
local mouseoverActive = false

-- Group healing variables
local lastGroupHealthCheck = 0
local healThreshold = 76  -- Health percentage threshold below which a player is considered to need healing
local healingNeededCount = 3  -- Number of group members that need to be injured before group_heal_needed is true

-- Proxy baby
local function CreateAuraProxy()
    local proxy = {}
    local defaultAura = {
        name = "unknown",
        count = 0,
        duration = 0,
        expires = 0,
        applied = 0,
        caster = "nobody",
        id = 0,
        up = false,
        down = true,
        remains = 0
    }
    local mt = {
        __index = function(t, k)
            return defaultAura
        end,
        __newindex = function(t, k, v)
            rawset(t, k, v)
        end
    }
    setmetatable(proxy, mt)
    return proxy
end

-- Function to check group health status
CheckGroupHealth = function()
    if not (initialized and ns.Hekili and ns.State) then
        return
    end
    
    local numGroupMembers = GetNumGroupMembers()
    local inRaid = IsInRaid()
    local inGroup = IsInGroup()
    local lowHealthCount = 0
    
    ns.State.group_heal_needed = false
    ns.State.low_health_members = 0
    
    if not inGroup then
        return
    end
    
    local playerHealth = UnitHealth("player") or 0
    local playerMaxHealth = UnitHealthMax("player") or 1
    local playerHealAbsorb = UnitGetTotalHealAbsorbs("player") or 0
    local playerEffectiveHealth = math.max(0, playerHealth - playerHealAbsorb)
    local playerEffectiveHealthPct = (playerEffectiveHealth / playerMaxHealth) * 100
    
    if playerEffectiveHealthPct <= healThreshold or playerHealAbsorb > (playerMaxHealth * 0.1) then
        lowHealthCount = lowHealthCount + 1
    end
    
    if inRaid then
        for i = 1, numGroupMembers do
            local unit = "raid" .. i
            if unit ~= "player" and UnitExists(unit) and UnitInRange(unit) and not UnitIsUnit(unit, "player") then
                local health = UnitHealth(unit) or 0
                local maxHealth = UnitHealthMax(unit) or 1
                local healAbsorb = UnitGetTotalHealAbsorbs(unit) or 0
                local effectiveHealth = math.max(0, health - healAbsorb)
                local effectiveHealthPct = (effectiveHealth / maxHealth) * 100
                
                if effectiveHealthPct <= healThreshold or healAbsorb > (maxHealth * 0.1) then
                    lowHealthCount = lowHealthCount + 1
                end
            end
        end
    else
        for i = 1, numGroupMembers - 1 do
            local unit = "party" .. i
            if UnitExists(unit) and UnitInRange(unit) and not UnitIsUnit(unit, "player") then
                local health = UnitHealth(unit) or 0
                local maxHealth = UnitHealthMax(unit) or 1
                local healAbsorb = UnitGetTotalHealAbsorbs(unit) or 0
                local effectiveHealth = math.max(0, health - healAbsorb)
                local effectiveHealthPct = (effectiveHealth / maxHealth) * 100
                
                if effectiveHealthPct <= healThreshold or healAbsorb > (maxHealth * 0.1) then
                    lowHealthCount = lowHealthCount + 1
                end
            end
        end
    end
    
    ns.State.low_health_members = lowHealthCount
    ns.State.group_heal_needed = (lowHealthCount >= healingNeededCount)
    
    return lowHealthCount >= healingNeededCount
end

-- Function to check if the mouse is over a Cell unit frame
IsMouseOverUnitFrame = function()
    local numGroupMembers = GetNumGroupMembers()
    local inRaid = IsInRaid()
    local inGroup = IsInGroup()

    local soloFrame = _G["CellSoloFramePlayer"]
    if soloFrame and soloFrame:IsVisible() and (soloFrame:IsMouseOver() or (soloFrame.widgets and soloFrame.widgets.healthBar and soloFrame.widgets.healthBar:IsMouseOver())) then
        if soloFrame.states and soloFrame.states.unit and UnitExists(soloFrame.states.unit) then
            local frameUnitGUID = UnitGUID(soloFrame.states.unit)
            local mouseoverGUID = UnitExists("mouseover") and UnitGUID("mouseover") or nil
            if frameUnitGUID and mouseoverGUID and frameUnitGUID == mouseoverGUID then
                return true
            end
        end
    end

    for i = 1, numGroupMembers do
        local unitFrame = _G["CellPartyFrameHeaderUnitButton"..i]
        if unitFrame and unitFrame:IsVisible() and (unitFrame:IsMouseOver() or (unitFrame.healthBar and unitFrame.healthBar:IsMouseOver())) then
            if unitFrame.unit and UnitExists(unitFrame.unit) then
                local frameUnitGUID = UnitGUID(unitFrame.unit)
                local mouseoverGUID = UnitExists("mouseover") and UnitGUID("mouseover") or nil
                if frameUnitGUID and mouseoverGUID and frameUnitGUID == mouseoverGUID and (UnitInParty("mouseover") or UnitInRaid("mouseover")) then
                    return true
                end
            end
        end
    end

    if inRaid then
        for i = 1, numGroupMembers do
            for headerNum = 0, 7 do
                local unitFrame = _G["CellRaidFrameHeader"..headerNum.."UnitButton"..i]
                if unitFrame and unitFrame:IsVisible() and (unitFrame:IsMouseOver() or (unitFrame.healthBar and unitFrame.healthBar:IsMouseOver())) then
                    if unitFrame.unit and UnitExists(unitFrame.unit) then
                        local frameUnitGUID = UnitGUID(unitFrame.unit)
                        local mouseoverGUID = UnitExists("mouseover") and UnitGUID("mouseover") or nil
                        if frameUnitGUID and mouseoverGUID and frameUnitGUID == mouseoverGUID and (UnitInParty("mouseover") or UnitInRaid("mouseover")) then
                            return true
                        end
                    end
                end
            end
        end
    end

    if PlayerFrame and PlayerFrame:IsVisible() and (PlayerFrame:IsMouseOver() or (PlayerFrame.healthBar and PlayerFrame.healthBar:IsMouseOver())) then
        if PlayerFrame.unit and UnitExists(PlayerFrame.unit) then
            local frameUnitGUID = UnitGUID(PlayerFrame.unit)
            local mouseoverGUID = UnitExists("mouseover") and UnitGUID("mouseover") or nil
            if frameUnitGUID and mouseoverGUID and frameUnitGUID == mouseoverGUID and (UnitInParty("mouseover") or UnitInRaid("mouseover")) then
                return true
            end
        end
    end

    return false
end

-- OnUpdate script to check for mouse leaving frames and group health
f:SetScript("OnUpdate", function(self, elapsed)
    lastMouseoverCheck = (lastMouseoverCheck or 0) + elapsed
    lastGroupHealthCheck = (lastGroupHealthCheck or 0) + elapsed
    
    if lastMouseoverCheck >= 0.1 then
        lastMouseoverCheck = 0
        
        if UnitExists("mouseover") then
            if not IsMouseOverUnitFrame() then
                ClearMouseoverState()
            end
        elseif mouseoverActive then
            ClearMouseoverState()
        end
    end
    
    if lastGroupHealthCheck >= 0.5 then
        lastGroupHealthCheck = 0
        CheckGroupHealth()
    end
end)

-- Function to scan mouseover unit auras
local function ScanMouseoverAuras()
    if not UnitExists("mouseover") then return end
    
    if not C_UnitAuras or not C_UnitAuras.GetBuffDataByIndex or not C_UnitAuras.GetDebuffDataByIndex then
        print("|cFFFF0000HekiliHelper Error|r: C_UnitAuras API is unavailable. Please check for addon conflicts or repair your game.")
        return
    end
    
    for k, _ in pairs(ns.State.mouseover.buff) do
        ns.State.mouseover.buff[k] = nil
    end
    
    for k, _ in pairs(ns.State.mouseover.debuff) do
        ns.State.mouseover.debuff[k] = nil
    end
    
    ns.State.mouseover.dispel = false
    
    local _, playerClass = UnitClass("player")
    local specID = GetSpecializationInfo(GetSpecialization() or 0) or 0
    local dispelTypes = {}
    
    if playerClass == "PRIEST" and (specID == 256 or specID == 257) then
        dispelTypes["Magic"] = true
        dispelTypes["Disease"] = true
    elseif playerClass == "DRUID" and specID == 105 then
        dispelTypes["Curse"] = true
        dispelTypes["Poison"] = true
    elseif playerClass == "MONK" and specID == 270 then
        dispelTypes["Magic"] = true
        dispelTypes["Poison"] = true
        dispelTypes["Disease"] = true
    elseif playerClass == "PALADIN" and specID == 65 then
        dispelTypes["Magic"] = true
        dispelTypes["Poison"] = true
        dispelTypes["Disease"] = true
    elseif playerClass == "SHAMAN" and specID == 264 then
        dispelTypes["Curse"] = true
        dispelTypes["Magic"] = true
    end
    
    local i = 1
    while true do
        local aura = C_UnitAuras.GetBuffDataByIndex("mouseover", i)
        if not aura then break end
        
        if aura.spellId then
            ns.State.mouseover.buff[tostring(aura.spellId)] = ns.State.mouseover.buff[tostring(aura.spellId)] or {}
            local buff = ns.State.mouseover.buff[tostring(aura.spellId)]
            buff.name = aura.name or "Unknown"
            buff.count = aura.applications or 0
            buff.duration = aura.duration or 0
            buff.expires = aura.expirationTime or 0
            buff.applied = aura.expirationTime and aura.duration and (aura.expirationTime - aura.duration) or GetTime()
            buff.caster = aura.sourceUnit or "unknown"
            buff.id = aura.spellId
            buff.up = true
            buff.down = false
            buff.remains = aura.expirationTime and (aura.expirationTime - GetTime()) or 0
            
            local key = string.lower(aura.name and aura.name:gsub("[%s%-]+", "_") or "unknown")
            ns.State.mouseover.buff[key] = ns.State.mouseover.buff[tostring(aura.spellId)]
            
            if aura.spellId == 1459 then
                ns.State.mouseover.buff.arcane_intellect = ns.State.mouseover.buff[tostring(aura.spellId)]
            end
        end
        i = i + 1
    end
    
    i = 1
    while true do
        local aura = C_UnitAuras.GetDebuffDataByIndex("mouseover", i)
        if not aura then break end
        
        if aura.spellId then
            ns.State.mouseover.debuff[tostring(aura.spellId)] = ns.State.mouseover.debuff[tostring(aura.spellId)] or {}
            local debuff = ns.State.mouseover.debuff[tostring(aura.spellId)]
            debuff.name = aura.name or "Unknown"
            debuff.count = aura.applications or 0
            debuff.duration = aura.duration or 0
            debuff.expires = aura.expirationTime or 0
            debuff.applied = aura.expirationTime and aura.duration and (aura.expirationTime - aura.duration) or GetTime()
            debuff.caster = aura.sourceUnit or "unknown"
            debuff.id = aura.spellId
            debuff.up = true
            debuff.down = false
            debuff.remains = aura.expirationTime and (aura.expirationTime - GetTime()) or 0
            debuff.is_heal_absorb = false
            
            local key = string.lower(aura.name and aura.name:gsub("[%s%-]+", "_") or "unknown")
            ns.State.mouseover.debuff[key] = ns.State.mouseover.debuff[tostring(aura.spellId)]
            
            local healAbsorbSpellIDs = {
                [49576] = true, -- Necrotic Strike
                [12294] = true, -- Mortal Strike
            }
            if healAbsorbSpellIDs[aura.spellId] then
                debuff.is_heal_absorb = true
            end
            
            if UnitIsFriend("player", "mouseover") and (UnitInParty("mouseover") or UnitIsUnit("player", "mouseover")) then
                if dispelTypes[aura.dispelName] then
                    ns.State.mouseover.dispel = true
                end
            end
        end
        i = i + 1
    end
    
    setmetatable(ns.State.mouseover.buff, {
        __index = function(t, k)
            t[k] = {
                name = "unknown",
                count = 0,
                duration = 0,
                expires = 0,
                applied = 0,
                caster = "nobody",
                id = 0,
                up = false,
                down = true,
                remains = 0
            }
            return t[k]
        end
    })
    
    setmetatable(ns.State.mouseover.debuff, {
        __index = function(t, k)
            t[k] = {
                name = "unknown",
                count = 0,
                duration = 0,
                expires = 0,
                applied = 0,
                caster = "nobody",
                id = 0,
                up = false,
                down = true,
                remains = 0,
                is_heal_absorb = false
            }
            return t[k]
        end
    })
end

-- Function to update the overlay with mouseover target details
local function UpdateDebugOverlay()
    local lines = {}
    
    if not ns.State or not ns.State.mouseover or not ns.State.mouseover.exists then
        table.insert(lines, "No mouseover target selected.\n")
        debugText:SetText(table.concat(lines, "\n"))
        scrollFrame:UpdateScrollChildRect()
        return
    end

    local unitName = ns.State.mouseover.name or "Unknown"
    local health = ns.State.mouseover.health.current or 0
    local maxHealth = ns.State.mouseover.health.max or 1
    local healthPct = ns.State.mouseover.health.pct or 0
    local isPlayer = ns.State.mouseover.is_player and "Yes" or "No"
    local isFriendly = UnitIsFriend("player", "mouseover") and "Yes" or "No"
    local role = ns.State.mouseover.role or "Unknown"
    local isTank = ns.State.mouseover.isTank and "Yes" or "No"
    local hasDispel = ns.State.mouseover.dispel and "Yes" or "No"

    table.insert(lines, string.format("|cFFFFFFFF%s|r", unitName))
    table.insert(lines, string.format("Health: %d / %d (%.1f%%)", health, maxHealth, healthPct))
    table.insert(lines, string.format("Is Player: %s", isPlayer))
    table.insert(lines, string.format("Is Friendly: %s", isFriendly))
    table.insert(lines, string.format("Role: %s", role))
    table.insert(lines, string.format("Is Tank: %s", isTank))
    table.insert(lines, string.format("Has Dispellable Debuff: %s", hasDispel))
    table.insert(lines, "")

    table.insert(lines, "|cFF00FF00Buffs:|r")
    local buffCount = 0
    if ns.State.mouseover.buff then
        for spellID, buff in pairs(ns.State.mouseover.buff) do
            if type(buff) == "table" and buff.up then
                local remains = buff.remains or 0
                table.insert(lines, string.format("- %s (ID: %s, %d stacks, %.1f sec left)", 
                    buff.name or "Unknown", tostring(spellID), buff.count or 0, remains))
                buffCount = buffCount + 1
            end
        end
    end
    if buffCount == 0 then
        table.insert(lines, "- None")
    end
    table.insert(lines, "")

    table.insert(lines, "|cFFFF0000Debuffs:|r")
    local debuffCount = 0
    if ns.State.mouseover.debuff then
        for spellID, debuff in pairs(ns.State.mouseover.debuff) do
            if type(debuff) == "table" and debuff.up then
                local remains = debuff.remains or 0
                table.insert(lines, string.format("- %s (ID: %s, %d stacks, %.1f sec left)", 
                    debuff.name or "Unknown", tostring(spellID), debuff.count or 0, remains))
                debuffCount = debuffCount + 1
            end
        end
    end
    if debuffCount == 0 then
        table.insert(lines, "- None")
    end

    debugText:SetText(table.concat(lines, "\n"))
    scrollFrame:UpdateScrollChildRect()
    scrollFrame:SetVerticalScroll(0)
end

-- Function to inject data into Hekili state
local function UpdateHekiliMouseoverState()
    if not (initialized and ns.Hekili and ns.State) then return end
    
    ns.State.mouseover = ns.State.mouseover or {}
    ns.State.mouseover.buff = ns.State.mouseover.buff or {}
    ns.State.mouseover.debuff = ns.State.mouseover.debuff or {}
    ns.State.mouseover.health = ns.State.mouseover.health or {}
    ns.State.mo = ns.State.mouseover
    
    if UnitExists("mouseover") and IsMouseOverUnitFrame() then
        local health = UnitHealth("mouseover") or 0
        local maxHealth = UnitHealthMax("mouseover") or 1
        local healAbsorb = UnitGetTotalHealAbsorbs("mouseover") or 0
        local healthPct = health / maxHealth * 100
        local effectiveHealth = math.max(0, health - healAbsorb)
        local effectiveHealthPct = maxHealth > 0 and (effectiveHealth / maxHealth * 100) or 0

        ns.State.mouseover.exists = true
        ns.State.mouseover.health.current = health
        ns.State.mouseover.health.max = maxHealth
        ns.State.mouseover.health.pct = effectiveHealthPct
        ns.State.mouseover.health.percent = effectiveHealthPct
        ns.State.mouseover.health.raw_pct = healthPct
        ns.State.mouseover.health.heal_absorb = healAbsorb
        ns.State.mouseover.unit = UnitGUID("mouseover")
        ns.State.mouseover.name = UnitName("mouseover") or "Unknown"
        ns.State.mouseover.is_player = UnitIsPlayer("mouseover")
        ns.State.mouseover.is_self = UnitIsUnit("player", "mouseover")
        local role = UnitGroupRolesAssigned("mouseover")
        ns.State.mouseover.role = role ~= "NONE" and role or "Unknown"
        ns.State.mouseover.isTank = role == "TANK"

        ScanMouseoverAuras()
        mouseoverActive = true
    else
        ClearMouseoverState()
        mouseoverActive = false
    end
    UpdateDebugOverlay()
end

-- Function to clear mouseover data (make it accessible to other functions)
ClearMouseoverState = function()
    if not (initialized and ns.Hekili and ns.State) then 
        return 
    end
    
    if not ns.State.mouseover then
        ns.State.mouseover = {}
    end
    
    ns.State.mouseover.exists = false
    if not ns.State.mouseover.health then
        ns.State.mouseover.health = {}
    end
    
    ns.State.mouseover.health.current = 0
    ns.State.mouseover.health.max = 0
    ns.State.mouseover.health.pct = 0
    ns.State.mouseover.health.percent = 0
    ns.State.mouseover.health.raw_pct = 0
    ns.State.mouseover.health.heal_absorb = 0
    
    ns.State.mouseover.unit = nil
    ns.State.mouseover.name = nil
    ns.State.mouseover.is_player = false
    ns.State.mouseover.is_self = false
    ns.State.mouseover.role = nil
    ns.State.mouseover.isTank = false
    ns.State.mouseover.dispel = false
    
    ns.State.mouseover.buff = {}
    ns.State.mouseover.debuff = {}
    
    ns.State.mo = ns.State.mouseover
    
    setmetatable(ns.State.mouseover.buff, {
        __index = function(t, k)
            t[k] = {
                name = "unknown",
                count = 0,
                duration = 0,
                expires = 0,
                applied = 0,
                caster = "nobody",
                id = 0,
                up = false,
                down = true,
                remains = 0
            }
            return t[k]
        end
    })
    
    setmetatable(ns.State.mouseover.debuff, {
        __index = function(t, k)
            t[k] = {
                name = "unknown",
                count = 0,
                duration = 0,
                expires = 0,
                applied = 0,
                caster = "nobody",
                id = 0,
                up = false,
                down = true,
                remains = 0,
                is_heal_absorb = false
            }
            return t[k]
        end
    })
    
    lastMouseoverGUID = nil
    lastMouseoverHealth = 0
    mouseoverActive = false
    
    UpdateDebugOverlay()
end

-- Function to check mouseover unit changes
local function CheckMouseover()
    if IsMouseOverUnitFrame() then
        local guid = UnitGUID("mouseover") or "None"
        local health = UnitHealth("mouseover") or 0
        local unitName = UnitName("mouseover") or "Unknown"

        if guid ~= lastMouseoverGUID or health ~= lastMouseoverHealth then
            lastMouseoverGUID = guid
            lastMouseoverHealth = health
            UpdateHekiliMouseoverState()
        end
    else
        ClearMouseoverState()
    end
end

-- Main initialization
function f:ADDON_LOADED(loadedAddon)
    if loadedAddon == "HekiliHelper" then
        print("|cFF00FF00Hekili Healers:|r Initializing mouseover state in ADDON_LOADED")
        _G.Hekili = _G.Hekili or {}
        _G.Hekili.State = _G.Hekili.State or {}
        ns.State = _G.Hekili.State

        ns.State.mouseover = ns.State.mouseover or {}
        ns.State.mouseover.health = ns.State.mouseover.health or {}
        ns.State.mouseover.buff = CreateAuraProxy()
        ns.State.mouseover.debuff = CreateAuraProxy()
        ns.State.mo = ns.State.mouseover

        ns.State.mouseover.health.current = 0
        ns.State.mouseover.health.max = 0
        ns.State.mouseover.health.pct = 0
        ns.State.mouseover.health.percent = 0

        ns.State.mouseover.exists = false
        ns.State.mouseover.unit = nil
        ns.State.mouseover.name = nil
        ns.State.mouseover.is_player = false
        ns.State.mouseover.is_self = false
        ns.State.mouseover.role = nil
        ns.State.mouseover.isTank = false
        ns.State.mouseover.dispel = false

        ns.State.group_heal_needed = false
        ns.State.low_health_members = 0
    end
end

function f:PLAYER_LOGIN()
    if not _G.Hekili then
        print("|cFFFF0000Hekili Healers:|r Hekili not detected. This addon requires Hekili to function.")
        return
    end

    ns.Hekili = _G.Hekili
    ns.State = _G.Hekili.State

    ns.State.mouseover = ns.State.mouseover or {}
    ns.State.mouseover.health = ns.State.mouseover.health or {}
    ns.State.mouseover.buff = CreateAuraProxy()
    ns.State.mouseover.debuff = CreateAuraProxy()
    ns.State.mo = ns.State.mouseover

    print("|cFF00FF00Hekili Healers:|r Successfully initialized.")

    initialized = true

    C_Timer.After(1, function()
        if CheckGroupHealth then
            CheckGroupHealth()
        end
    end)
end

function f:UPDATE_MOUSEOVER_UNIT()
    CheckMouseover()
end

function f:UNIT_AURA(unit)
    if IsMouseOverUnitFrame() then
        UpdateHekiliMouseoverState()
    end
end

function f:PLAYER_TARGET_CHANGED()
    ClearMouseoverState()
end

function f:UNIT_HEALTH(unit)
    if unit == "mouseover" and UnitExists("mouseover") and IsMouseOverUnitFrame() then
        CheckMouseover()
    elseif not UnitExists("mouseover") then
        ClearMouseoverState()
    end
    
    if UnitInParty(unit) or UnitInRaid(unit) or unit == "player" then
        CheckGroupHealth()
    end
end

function f:UNIT_HEAL_ABSORB_AMOUNT_CHANGED(unit)
    if unit == "mouseover" and UnitExists("mouseover") and IsMouseOverUnitFrame() then
        CheckMouseover()
    end
end

function f:GROUP_ROSTER_UPDATE()
    CheckGroupHealth()
end

f:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        self[event](self, ...)
    end
end)

-- Register slash command
SLASH_HHDEBUG1 = '/hhdebug'

SlashCmdList["HHDEBUG"] = function(msg)
    if debugFrame:IsShown() then
        debugFrame:Hide()
    else
        debugFrame:Show()
    end
end