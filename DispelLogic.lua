-- Hekili Healers - Dispel Logic Module
local addonName, ns = ...

local dispelData = {
    ["PALADIN"] = {
        hekiliKey = "cleanse",
        spellName = "Cleanse",
        -- Removes: Magic, Poison, Disease (with talent)
    },
    ["PRIEST"] = {
        hekiliKey = "purify", 
        spellName = "Purify",
        -- Removes: Magic, Disease
    },
    ["SHAMAN"] = {
        hekiliKey = "purify_spirit",
        spellName = "Purify Spirit",
        -- Removes: Magic, Curse
    },
    ["DRUID"] = {
        hekiliKey = "natures_cure",
        spellName = "Nature's Cure",
        -- Removes: Magic, Curse, Poison
    },
    ["MONK"] = {
        hekiliKey = "detox",
        spellName = "Detox",
        -- Removes: Magic, Poison, Disease
    },
    ["EVOKER"] = {
            hekiliKey = "naturalize", 
            spellName = "Naturalize",
            -- Removes: Magic, Poison
        }
}

function ns.InitializeDispelLogic()
    local _, playerClass = UnitClass("player")
    local data = dispelData[playerClass]

    -- Exit if the player is not one of the healer classes defined above.
    if not data then return end

    C_Timer.After(1.0, function()
        if not (ns.Hekili and ns.Hekili.Class and ns.Hekili.Class.abilities) then
            return
        end

        -- Handle single dispel ability for all classes
        local abilityToPatch = ns.Hekili.Class.abilities[data.hekiliKey]
        if not abilityToPatch then
            -- print(("|cFFFF0000Hekili Healers Error:|r Could not find '%s' ability in Hekili to modify."):format(data.spellName))
        else
            -- 1. Overwrite the original 'usable' function with our mouseover logic.
            abilityToPatch.funcs = abilityToPatch.funcs or {}
            
            
                abilityToPatch.funcs.usable = function()
                    return (ns.State and ns.State.mouseover and ns.State.mouseover.dispel) or false
                end
            
            
            abilityToPatch.usable = nil

            -- print(("|cFF00FF00Hekili Healers:|r Hekili's '%s' ability has been modified for mouseover logic."):format(data.spellName))
        end
    end)
end
