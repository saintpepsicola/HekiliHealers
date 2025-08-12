-- Hekili Healers Packs bootstrap (quick + dirty)
local ADDON_NAME, Private = ...

Private.name = "Hekili Healers Packs"
Private.shortName = "Bolt's"
Private.class = UnitClassBase("player")
Private.lowerClass = string.lower(Private.class)

-- Hekili is a required dependency (see TOC), so it should exist here
Private.hekili = _G.Hekili

-- If their selection is missing, we try to help. We don't stomp choices.
local function EnsurePackSelection()
    local hekili = Private.hekili
    if not hekili or not hekili.DB or not hekili.DB.profile then return end
    local profile = hekili.DB.profile
    local specs = profile.specs
    local packs = profile.packs
    if not specs or not packs then return end

    local _, class = UnitClass("player")
    local specIndex = GetSpecialization()
    if not specIndex then return end
    local specID = GetSpecializationInfo(specIndex)
    if not specID then return end

    local desiredPack
    if class == "PRIEST" and specID == 257 then desiredPack = string.format("%s_holy", Private.shortName) end
    if class == "DRUID" and specID == 105 then desiredPack = string.format("%s_resto", Private.shortName) end
    if class == "SHAMAN" and specID == 264 then desiredPack = string.format("%s_resto", Private.shortName) end
    if class == "PALADIN" and specID == 65 then desiredPack = string.format("%s_holy", Private.shortName) end
    if class == "EVOKER" and specID == 1468 then desiredPack = string.format("%s_preservation", Private.shortName) end

    if not desiredPack then return end

    specs[specID] = specs[specID] or {}
    local current = specs[specID].package

    -- If we ship a built-in pack for this spec, install + select it
    if ns and ns.Packs and ns.Packs[specID] then
        local shipped = ns.Packs[specID]
        local specObj = hekili:GetSpecialization(specID)
        if specObj and shipped and type(shipped.data) == "string" and shipped.data ~= "" then
            specObj:RegisterPack(shipped.name, shipped.date or 20250101, shipped.data)
            specs[specID].package = shipped.name
            hekili:LoadScripts()
            print(string.format("|cFF00FF00Hekili Healers:|r Loaded built-in pack '%s' for spec %d.", shipped.name, specID))
            return
        end
    end

    -- Only set if their current selection is missing or empty, and ours exists.
    local currentExists = current and packs[current]
    if (not currentExists) and packs[desiredPack] then
        specs[specID].package = desiredPack
        hekili:LoadScripts()
        print(string.format("|cFF00FF00Hekili Healers:|r Selected pack '%s' for spec %d.", desiredPack, specID))
    end
end

-- Nudge this at login so everything's loaded first
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    EnsurePackSelection()
end)

