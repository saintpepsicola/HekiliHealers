local _, Private = ...

-- Preservation Evoker Hekili pack
-- Evoker pack (preservation); green beams go brrr
if Private.hekili and Private.class == "EVOKER" then
    -- Preservation Evoker spec ID is 1468
    local spec = Private.hekili:GetSpecialization(1468)
    local name = string.format("%s_preservation", Private.shortName)
    local date = 20250717  -- Current date in YYYYMMDD format

    -- Remove an old pack with same key if user had an older version
    if Private.hekili.DB and Private.hekili.DB.profile and Private.hekili.DB.profile.packs and Private.hekili.DB.profile.packs[name] then
        Private.hekili.DB.profile.packs[name] = nil
    end

    -- TODO: Add actual Preservation Evoker rotation here
    spec:RegisterPack(name, date, [[Hekili:PlaceholderForPreservationEvokerRotation]])

    -- Force Hekili to pick up the new pack immediately
    Private.hekili:LoadScripts()
end
