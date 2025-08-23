local addonName, ns = ...

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:RegisterEvent("UNIT_HEALTH")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("UNIT_AURA")
f:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")

local debugFrame = CreateFrame("Frame", "HekiliHealersDebugFrame", UIParent, "BackdropTemplate")
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

local header = debugFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
header:SetPoint("TOPLEFT", debugFrame, "TOPLEFT", 10, -10)
header:SetText("Hekili Healers — Mouseover Info")

local scrollFrame = CreateFrame("ScrollFrame", "HekiliHealersDebugScrollFrame", debugFrame, "UIPanelScrollFrameTemplate")
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

local closeButton = CreateFrame("Button", nil, debugFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", debugFrame, "TOPRIGHT", 0, 0)

debugFrame:Hide()

local initialized = false
local lastMouseoverGUID = nil
local lastMouseoverHealth = 0
local lastMouseoverCheck = 0
local mouseoverActive = false
local lastAuraRefresh = 0

local ClearMouseoverState
local CheckGroupHealth
local IsMouseOverUnitFrame
local ScanMouseoverAuras
local UpdateDebugOverlay

local function getNewsVersion()
    return (ns.WhatsNew and ns.WhatsNew.NEWS_VERSION) or 1
end

local function getDiscordURL()
    return (ns.WhatsNew and ns.WhatsNew.DISCORD_URL) or "https://discord.gg/hekilihealers"
end

HekiliHealersDB = HekiliHealersDB or {}

local function CreateWhatsNewFrame()
    local frame = CreateFrame("Frame", "HekiliHealersWhatsNew", UIParent, "BackdropTemplate")
    frame:SetSize(460, 320)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.85)
    frame:Hide()

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("TOP", 0, -12)
    title:SetText("What's New — Hekili Healers")

    local sub = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    sub:SetPoint("TOP", title, "BOTTOM", 0, -6)
    sub:SetText("Fresh bits, fewer shackles")

    local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 16, -70)
    scroll:SetPoint("BOTTOMRIGHT", -36, 56)
    local child = CreateFrame("Frame", nil, scroll)
    child:SetSize(1, 1)
    scroll:SetScrollChild(child)

    local body = child:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    body:SetPoint("TOPLEFT")
    body:SetJustifyH("LEFT")
    body:SetJustifyV("TOP")
    body:SetWidth(400)

    local getLines = ns.WhatsNew and ns.WhatsNew.getLines
    local lines = (type(getLines) == "function") and getLines(ns.WhatsNew) or {}
    if #lines == 0 then
        lines = { "Welcome back!", "Patch notes were too shy to show up." }
    end
    body:SetText(table.concat(lines, "\n\n"))

    local close = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    close:SetSize(120, 24)
    close:SetPoint("BOTTOMRIGHT", -14, 14)
    close:SetText("Heck yeah!")
    close:SetScript("OnClick", function()
        frame:Hide()
    end)

    local dont = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    dont:SetSize(160, 24)
    dont:SetPoint("RIGHT", close, "LEFT", -8, 0)
    dont:SetText("Don't show again")
    dont:SetScript("OnClick", function()
        HekiliHealersDB.newsShownVersion = getNewsVersion()
        frame:Hide()
    end)

    local copy = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    copy:SetSize(160, 24)
    copy:SetPoint("BOTTOMLEFT", 14, 14)
    copy:SetText("Print Discord Link")
    copy:SetScript("OnClick", function()
        print(string.format("|cFF00FF00Hekili Healers:|r Discord: %s", getDiscordURL()))
    end)

    local x = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    x:SetPoint("TOPRIGHT", 2, 2)
    x:SetScript("OnClick", function()
        frame:Hide()
    end)

    return frame
end

local whatsNew
local function ShowWhatsNewIfNeeded()
    if HekiliHealersDB.newsShownVersion == getNewsVersion() then return end
    if not whatsNew then
        whatsNew = CreateWhatsNewFrame()
    end
    whatsNew:Show()
end

local healThreshold = 76
local healingNeededCount = 3

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
            local v = {
                name = defaultAura.name,
                count = defaultAura.count,
                duration = defaultAura.duration,
                expires = defaultAura.expires,
                applied = defaultAura.applied,
                caster = defaultAura.caster,
                id = 0,
                up = false,
                down = true,
                remains = 0
            }
            rawset(t, k, v)
            return v
        end,
        __newindex = function(t, k, v)
            rawset(t, k, v)
        end
    }
    setmetatable(proxy, mt)
    return proxy
end

local function WipeTable(tbl)
    for k in pairs(tbl) do
        tbl[k] = nil
    end
end

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

function IsMouseOverUnitFrame()
    local foci = GetMouseFoci()
    if foci and #foci > 0 then
        local focus = foci[1]
        if focus and focus ~= WorldFrame then
            local unit = focus:GetAttribute("unit") or focus.unit
            if unit and UnitExists(unit) and UnitIsFriend("player", unit) then
                return true, unit
            end
        end
    end
    return false, nil
end

f:SetScript("OnUpdate", function(self, elapsed)
    lastMouseoverCheck = (lastMouseoverCheck or 0) + elapsed
    lastAuraRefresh = (lastAuraRefresh or 0) + elapsed
    if lastMouseoverCheck >= 0.1 then
        lastMouseoverCheck = 0
        if not UnitExists("mouseover") then
            ClearMouseoverState()
        end
    end
    if UnitExists("mouseover") and lastAuraRefresh >= 0.2 then
        lastAuraRefresh = 0
        ScanMouseoverAuras()
        UpdateDebugOverlay()
    end
end)

function ScanMouseoverAuras()
    if not UnitExists("mouseover") then return end
    
    if not C_UnitAuras or not C_UnitAuras.GetBuffDataByIndex or not C_UnitAuras.GetDebuffDataByIndex then
        print("|cFFFF0000Hekili Healers Error|r: C_UnitAuras API is unavailable. Please check for addon conflicts or repair your game.")
        return
    end
    
    if not ns.State.mouseover.buff then ns.State.mouseover.buff = CreateAuraProxy() end
    if not ns.State.mouseover.debuff then ns.State.mouseover.debuff = CreateAuraProxy() end
    WipeTable(ns.State.mouseover.buff)
    WipeTable(ns.State.mouseover.debuff)
    
    ns.State.mouseover.dispel = false
    ns.State.mouseover.dispel_cauterize = false
    ns.State.mouseover.dispel_naturalize = false
    
    local _, playerClass = UnitClass("player")
    local specID = GetSpecializationInfo(GetSpecialization() or 0) or 0
    local dispelTypes = {}
    
    if playerClass == "PRIEST" then
        dispelTypes["Magic"] = true
        dispelTypes["Disease"] = true
    elseif playerClass == "DRUID"  then
        dispelTypes["Magic"] = true
        dispelTypes["Curse"] = true
        dispelTypes["Poison"] = true
    elseif playerClass == "MONK" and specID == 270 then
        dispelTypes["Magic"] = true
        dispelTypes["Poison"] = true
        dispelTypes["Disease"] = true
    elseif playerClass == "PALADIN" then
        dispelTypes["Magic"] = true
        dispelTypes["Poison"] = true
        dispelTypes["Disease"] = true
    elseif playerClass == "SHAMAN" and specID == 264 then
        dispelTypes["Curse"] = true
        dispelTypes["Magic"] = true
    elseif playerClass == "EVOKER" and specID == 1468 then
        dispelTypes["Magic"] = true
        dispelTypes["Poison"] = true
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
            
            local key = string.lower(aura.name and aura.name:gsub("[%s%-]", "_") or "unknown")
            ns.State.mouseover.buff[key] = ns.State.mouseover.buff[tostring(aura.spellId)]
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
            
            local key = string.lower(aura.name and aura.name:gsub("[%s%-]", "_") or "unknown")
            ns.State.mouseover.debuff[key] = ns.State.mouseover.debuff[tostring(aura.spellId)]
            
            local healAbsorbSpellIDs = {
                [49576] = true,
                [12294] = true,
            }
            if healAbsorbSpellIDs[aura.spellId] then
                debuff.is_heal_absorb = true
            end
            
            if UnitExists("mouseover") then
                if dispelTypes[aura.dispelName] then
                    ns.State.mouseover.dispel = true
                end
            end
        end
        i = i + 1
    end
end

function UpdateDebugOverlay()
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
        for spellKey, buff in pairs(ns.State.mouseover.buff) do
            local spellIdNumeric = tonumber(spellKey)
            if spellIdNumeric and type(buff) == "table" and buff.up then
                local remains = buff.remains or 0
                table.insert(lines, string.format("- %s (ID: %d, %d stacks, %.1f sec left)", 
                    buff.name or "Unknown", spellIdNumeric, buff.count or 0, remains))
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
        for spellKey, debuff in pairs(ns.State.mouseover.debuff) do
            local spellIdNumeric = tonumber(spellKey)
            if spellIdNumeric and type(debuff) == "table" and debuff.up then
                local remains = debuff.remains or 0
                table.insert(lines, string.format("- %s (ID: %d, %d stacks, %.1f sec left)", 
                    debuff.name or "Unknown", spellIdNumeric, debuff.count or 0, remains))
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
        local healthPct = maxHealth > 0 and (health / maxHealth * 100) or 0
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
    ns.State.mouseover.dispel_cauterize = false
    ns.State.mouseover.dispel_naturalize = false
    
    ns.State.mouseover.buff = CreateAuraProxy()
    ns.State.mouseover.debuff = CreateAuraProxy()
    
    ns.State.mo = ns.State.mouseover
    
    lastMouseoverGUID = nil
    lastMouseoverHealth = 0
    mouseoverActive = false
    
    UpdateDebugOverlay()
end

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

function f:ADDON_LOADED(loadedAddon)
    if loadedAddon == "HekiliHealers" then
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

        ShowWhatsNewIfNeeded()
    end
end

function f:PLAYER_LOGIN()
    print("|cFF00FF00Hekili Healers:|r PLAYER_LOGIN event fired.")
    if not _G.Hekili then
        print("|cFFFF0000Hekili Healers Error:|r _G.Hekili not found on PLAYER_LOGIN.")
        return
    end

    ns.Hekili = _G.Hekili
    ns.State = _G.Hekili.State

    ns.State.mouseover = ns.State.mouseover or {}
    ns.State.mouseover.health = ns.State.mouseover.health or {}
    ns.State.mouseover.buff = CreateAuraProxy()
    ns.State.mouseover.debuff = CreateAuraProxy()
    ns.State.mo = ns.State.mouseover

    initialized = true
    print("|cFF00FF00Hekili Healers:|r Addon initialized.")

    C_Timer.After(2, function()
        if type(ns.InitializeDispelLogic) == "function" then
            ns.InitializeDispelLogic() 
            print("|cFF00FF00Hekili Healers:|r Dispel Logic Initialized.")
        end
    end)

    C_Timer.After(1, function()
        if CheckGroupHealth then
            CheckGroupHealth()
            print("|cFF00FF00Hekili Healers:|r Group Health Checked.")
        end
    end)

    if ns.RecommendationUI and type(ns.RecommendationUI.Initialize) == "function" then
        print("|cFF00FF00Hekili Healers:|r Calling RecommendationUI.Initialize().")
        ns.RecommendationUI.Initialize()
    else
        print("|cFFFF0000Hekili Healers Error:|r ns.RecommendationUI or its Initialize function not found.")
    end
end

function f:UPDATE_MOUSEOVER_UNIT()
    CheckMouseover()
end

function f:UNIT_AURA(unit)
    if not UnitExists("mouseover") then return end
    if IsMouseOverUnitFrame() and (unit == "mouseover" or UnitGUID(unit) == ns.State.mouseover.unit) then
        UpdateHekiliMouseoverState()
    end
end

function f:PLAYER_TARGET_CHANGED()
    ClearMouseoverState()
end

function f:UNIT_HEALTH(unit)
    if unit == "mouseover" and UnitExists("mouseover") and IsMouseOverUnitFrame() then
        UpdateHekiliMouseoverState()
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

SLASH_HHDEBUG1 = '/hh'

SlashCmdList["HHDEBUG"] = function(msg)
    if debugFrame:IsShown() then
        debugFrame:Hide()
    else
        debugFrame:Show()
    end
end

SLASH_HHNEWS1 = '/hhnews'
SlashCmdList["HHNEWS"] = function(msg)
    msg = tostring(msg or ""):
    lower()
    if msg:find("reset") then
        HekiliHealersDB.newsShownVersion = nil
        return
    end
    if not whatsNew then
        whatsNew = CreateWhatsNewFrame()
    end
    whatsNew:Show()
end
