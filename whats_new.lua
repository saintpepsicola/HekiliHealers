local addonName, ns = ...

ns.WhatsNew = ns.WhatsNew or {}

ns.WhatsNew.NEWS_VERSION = 2
ns.WhatsNew.DISCORD_URL = "https://discord.gg/U2VsMKrQrn" 

function ns.WhatsNew:getLines()
    return {
        "• You're free of Cell! Use it if you love it, ditch it if you don't. Default Blizzard frames work. World mouseover works. Go wild.",
        "• Holy Paladin and Resto Druid updated for Season 3. Shaman is up next, then the rest of the heal squad.",
        "• Brand new Discord (a few days old) — come hang and drop feedback: " .. self.DISCORD_URL,
    }
end
