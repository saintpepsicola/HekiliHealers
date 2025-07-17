local _, Private = ...

-- Preservation Evoker Hekili pack
if Private.hekili and Private.class == "EVOKER" then
    -- Preservation Evoker spec ID is 1467
    local spec = Private.hekili:GetSpecialization(1467)
    local name = string.format("%s_preservation", Private.shortName)
    local date = 20250717  -- Current date in YYYYMMDD format

    -- Remove an old pack with same key if user had an older version
    if Hekili.DB and Hekili.DB.profile and Hekili.DB.profile.packs and Hekili.DB.profile.packs[name] then
        Hekili.DB.profile.packs[name] = nil
    end

    -- TODO: Add actual Preservation Evoker rotation here
    spec:RegisterPack(name, date, [[Hekili:PlaceholderForPreservationEvokerRotation]])

    -- Force Hekili to pick up the new pack immediately
    Hekili:LoadScripts()
end
