-- Hekili Healers Packs
-- An addon to provide custom Hekili profiles for Priest specializations
local ADDON_NAME, Private = ...

Private.name = "Hekili Healers Packs"
Private.shortName = "Bolt's"
Private.class = UnitClassBase("player")
Private.lowerClass = string.lower(Private.class)

Private.hekili = _G.Hekili

if Private.hekili then
    local Hekili = Private.hekili

    local function LoadSpecPacks()
        if Private.class == "PRIEST" then
            -- Load only Holy Priest specialization pack
            local fileName = string.format("%s_holy", Private.lowerClass)
        end
        if Private.class == "DRUID" then
            -- Load only Resto Druid specialization pack
            local fileName = string.format("%s_resto", Private.lowerClass)
        end
        if Private.class == "SHAMAN" then
            -- Load only Resto Shaman specialization pack
            local fileName = string.format("%s_resto", Private.lowerClass)
        end
    end

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_LOGIN")
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_LOGIN" then
            if not _G.Hekili then
                print("|cFFFF0000Hekili Healers:|r Hekili not detected. This addon requires Hekili to function.")
                return
            end
            Private.hekili = _G.Hekili
            LoadSpecPacks()
        end
    end)
end

