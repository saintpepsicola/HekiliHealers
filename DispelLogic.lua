local addonName, ns = ...

local dispelData = {
    ["PALADIN"] = { hekiliKey = "cleanse", spellName = "Cleanse" },
    ["PRIEST"] = { hekiliKey = "purify", spellName = "Purify" },
    ["SHAMAN"] = { hekiliKey = "purify_spirit", spellName = "Purify Spirit" },
    ["DRUID"] = { hekiliKey = "natures_cure", spellName = "Nature's Cure" },
    ["MONK"] = { hekiliKey = "detox", spellName = "Detox" },
    ["EVOKER"] = { hekiliKey = "naturalize", spellName = "Naturalize" }
}

function ns.InitializeDispelLogic()
    local _, playerClass = UnitClass("player")
    local data = dispelData[playerClass]
    if not data then return end

    C_Timer.After(1.5, function()
        if not (ns.Hekili and ns.Hekili.Class and ns.Hekili.Class.abilities) then
            return
        end

        local abilityToPatch = ns.Hekili.Class.abilities[data.hekiliKey]
        if not abilityToPatch then
            return
        else

            abilityToPatch.funcs = abilityToPatch.funcs or {}

            abilityToPatch.buff = nil
            abilityToPatch.funcs.buff = nil

            abilityToPatch.funcs.usable = function()
                return true
            end

            abilityToPatch.usable = nil
            
        end
    end)
end