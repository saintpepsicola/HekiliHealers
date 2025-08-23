local addonName, ns = ...

ns.WhatsNew = ns.WhatsNew or {}

ns.WhatsNew.NEWS_VERSION = 4
ns.WhatsNew.DISCORD_URL = "https://discord.gg/mueqeqUE" 

function ns.WhatsNew:getLines()
    return {

        "• Holy Paladin, Resto Druid and Holy Priest AUTO DISPEL ",

        "• Localization",

        "• EVOKER - the new kid on the block! Give feedback on it as you're trying it out.",


        "• Discord: " .. self.DISCORD_URL,
    }
end
