local addonName, ns = ...

ns.WhatsNew = ns.WhatsNew or {}

ns.WhatsNew.NEWS_VERSION = 3
ns.WhatsNew.DISCORD_URL = "https://discord.gg/U2VsMKrQrn" 

function ns.WhatsNew:getLines()
    return {

        "EVOKER - the new kid on the block! Give feedback on it as you're trying it out.",

        "• Holy Paladin, Resto Druid and Shaman updated for Season 3. Is anyone even playing Holy Priest?",

        "• You're free of Cell! You can mouseover WHATEVER, don't even need frames as long as they're your allies.",

        "• Brand new Discord (a few days old) — come hang and drop feedback: " .. self.DISCORD_URL,
    }
end
