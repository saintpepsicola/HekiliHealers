local _, Private = ...

-- Holy Paladin Hekili pack
-- Paladin pack (holy); big hammer, bigger heals
if Private.hekili and Private.class == "PALADIN" then
    -- Holy Paladin spec ID is 65
    local spec = Private.hekili:GetSpecialization(65)
    local name = string.format("%s_holy", Private.shortName)
    local date = 20250620

    -- Remove an old pack with same key if user had an older version
    if Private.hekili.DB and Private.hekili.DB.profile and Private.hekili.DB.profile.packs and Private.hekili.DB.profile.packs[name] then
        Private.hekili.DB.profile.packs[name] = nil
    end

    -- NOTE: Replace the placeholder text below with the real pack export string once you build it in Hekili.
    spec:RegisterPack(name, date, [[Hekili:DEvuVTTnq4FlTpS1cSi4yhhNSLnG10hwk2YkGZEQisKw8SfNPifiPSJbk4V9EKYYwYrYjXVyyjE677UVJ8UJXNh)q8ug1cX3pCWWXdUA4OOH4)gnoEQDtbepTGMUKUa)JKMJ)(jLW(ZMKmLyJJ8HHF0BWgHIY8azuL6u0O4PZk5c7DY4zTq)YHdqJkG047VejiJZyqLnGjTcBJJ8xi2XtfCJ1eafeZtyWCqAa857dUmiPZeal(tXtt1ClO5uepGkSzrfPwh5gh5cKmAQLRKib8vCjKuOvwO(viNAEr1dND2zoYuKjh5Zvu5i)zWqh5VrpXrqlITyCu7c2woXb8yY4GG1TVDdkcw)NJXeTuyRb8iOMkaQp6NMUb)BILQxaO4CpgG50NsA)2PJAYBUkIXrjxu78nX)5sW)q5YdJ8pCRsA1kHa0FSsh25yAyw5sWd9OdGENRtfIKQhs8P0QeBs1MPwPweKlofqsvkbtTwA8im(uqWNB4Yf(V)Yt57zfMQmAHgsv5ZOVMCkdwPcWrl10MzSzLZNhvqfugVAXiF096sFFvdNDBWdoirndOPixQ5O3ViZ2KpVjRGeMYgDGvoYV7id6k7U)RxOvLfoYp5iDIZCk3MTfNoCMWYvA3(04rpJh4lXNXsKaWWL3bRxRsYPg0YnDjo3wZWroA)2jDfixGBEswRPHqP3tcBlnyXdsDTx)GnaTXnYRXF)7oYr8eeiJX)fOUAkZZb9UdeDzcT0wMlB6c1B)7eWcT)esBRN0N1R5smwoW6Rof5D)wLvCTTmuL46Ebcl2bp57Be2qIpDqhHrdcl8oCfU5bQC5UhzGx1)27hoEYKZF)JOE3DK1Obc6jNpOPRm7T4kJRCLMV9pCKjd6r(PiYZ5PH4)8(pD8sSoCWRkIf0njOQNrLSTv2QlrE8(VyJ7Kc1AqJbdEKFufzoIVMaGgjXm8CbwZmYYtxI4v7M9503CDdbPfcp7a7Bs9VyR6FOdVNS1knZR8lekSAYrlb(sKnPISWXAUCEPH3OgBlDhJmt2(I0hTkXlY6494gIttMkDzx9i7pbooG9roEg8tVdZOvTOUS3us3y)UJc)Zsctoz5y8GJjZx1Sswd1QDfSRBA1)xYwKds7b20UKqlxSUdx0EcI0qooXLjC4FrklchNlea7STMMUSSX4j6sdLb6eJvZddKzRgl5LNdP0ajOhMBoElWtj9vnfSxOTzqI2l2GQ00vV5p)1P90vU)ZDvd82vjoFNYU7I2ilt9TidDRQ7C374NkC(0u0QTA9boWACggU8YUoA1Alf2c1KhsnyMyfO91bAEXO1uTe9vuFEiJJjASxZCUaViI)HCEOzGJyklkuAmwNRWuXcqI(sQJG5D5sC8)ihXrUZw9rHXrXDpywbTiZpviGeVXJnxHXb(pUmvuIjeCjmoa9V6(cQ9oY3(p)DGUZVZ4XFXrwNXtZAAnvUzpRoIu5b)PcbpLBf7XL5)NNCypP)MJG((wAEOcch58h9GYA(QHnyEnxiAerBH0wBAqncVswMpd0EIncSVJ7l3L7fm)lUSAkv)ESW1lXf9JnAZu6QBFIDDPgG9VYwx01pyFivG3S1N8I)Xp]])

    -- Force Hekili to pick up the new pack immediately
    Private.hekili:LoadScripts()
end




