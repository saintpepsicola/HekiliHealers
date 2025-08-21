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
    spec:RegisterPack(name, date, [[Hekili:LIvBVTTnq4FlbdWBdRrZ2jkzDRjaRTFOjylRao7tdvs0s0wCHIuGKYogiq)23rsBlQ3DYqbcSnp(ChFoY7EUgml4XGfjifo4H5tN7p9xMpZB2Lx6p1pyHAxooyrok(j0A4dmug83pYPQVxgMYP70RTJYrjAmK8crmSEWILfeQ6owWYAaF18PGr544GhUcWoLKKGT2GLXwyLLrFXalLivsdOy6QWe8kmtIHV)GjAXm0skoj4J29ki5kcNfS48ZpVmAbSJYOpB3sz0VhRxRm6paelJalcwaBqHfeeedyevL6Lhdl9HYOlHaefBXkHSHWWH5cUcB)jf8pWFRqfu1Pfk)jIWAgb)WN4mLGtPyXpUpEo4sbEzXtyWlpmVb0hSigrPH2VeQPilrfAZl1OkaKlElGeZ50e(wMuJWLVfe0CkHTwVF)3Y(tYLwQoxGJ5zlrhjBZFuDIycEd3ahQqGCZWllwTYlhrrje7IE6txxCC1E0GUbhMWvElXOyav(kioxNcPVBkJM2vQ(Rc85FYeTnsQnqORetLNxl4f5LrtkJ6mgwHiQ0dXqBhyw2YDvPXt6I6Noy(iVxmXxOodhYW4eaUJHHMBdZqsWYDdtVdbYgmBnC5jCRazok9EjE)Ztf8qQRBQnUauhxpnh)YlLrdejaqsPEhaVklYYWIJxO7YeuHQiJ5gcG1x1N1YCH(fsDRVUpR3syWzPH1)YBHERUQSHiufMQeVVxGY4E4N11HnxiHV1OA5ftnlCgSIHKxXfGdeiwm2B)Ty9Ae5Ji2tDF0QvD9HztDJLLVMyX3glU)6TLrxpTh(hbiVIeBiGznFEC6ED(GmqLVPODHaVNIyj7RTDOi5j968lwJh5TzRGnHanBPovDPy0(wd9)4u3vpmNVflagek0CH9ewgPReHbJyW9QvuOsTNIe)KjSSURpM6dV3jludHwVVFvP8l3NYBgWvoBlxKOt3RPCBnP(RsmMZU26mtwMWwvijo10RLRHtMmTw5(MDbFfE1VcxZ5uMYJF6yPLtkb6BWEGIcM4uhWjiBJXR7nL0n2Nni8Tsc9x5Am6WF6q087DRF6Ww1RBARXCWS)TizDgMPAAu)Leo0y1RYdEcCgi0tAk5SooXld9S5eC02dUPllDEFkkKOeSiuQeeJoqLvn0jvK4ZFDXyIDFdzpzkbtn5pvkouO5AmVqoCnefsSgR6QyPUPB3nKDsDiD3wtJVXebanZK4yWQ98xJaylihIWUQRx(1UNaDJLzg6gi8nyH(XT7mlBrcgeRYGfpMsGKh01AfHcZwO)sgX0wPmswKNZfWzf6caCkMbXsCzeKlzpHvsVYOYO7u2nzu2c3iaUgSivlAedoENgBchohWNiSyAbKNHLGZbw8RL3dP0YO)5V1J1CNcNj)27kJ2MsItDTgX2v51Yigxd(Z5usmrrRWnr)jTZXvo93kJGyFVBE0crz0SVPbnX9NM745Tek15eThs1btnSH5NyfzlXcTJLuOzs593LPjm9pCLvWR(QRzYpyrTIsvkxyhme6FJK4K)I1C8tBQiyX3zUU3shE59wCLEhNM4NU5NBQQFeJm6QFhz1ncejbON7p4StA(UJOdyANWZ9xAok070dbDJ7OCJB9rX(JB6EDhJBiu3X9Ko2q1vuOBOdO3AmAnp6ioa6I74MHMdPYfhpVa(UJDOHUvTSE2wT6pVIn6m3XRyxTNMqV5URe(YlVbqTZFmUD2jpg3o7mh9yxJPi0hLZ0pnMCIbUANqcxrOWaUgTYhEA1E)tm4gMX3G19pdjzza7ZuJFaQFH7OYIj1LMcJWmkshhwyiG8NoP6B3EDpW6ohWqOnZ39rr)Y)R8Y(316NZwv(TG3onqx7OMcTHcRlHd5rne3EZfDbwDDzdH21tN0RC6UqUsW1GO6))lQ8N21(RPr2ubZHh8h6E)a0CDmo7KazWa5ItlqQndwBmoR)j9gmR01Qhe(25f16YD1bYaIRVfKlpPxb16vDFY0Ty4QOa6UbrqpIBFD5gluneTQHOLk4pmF6lV0Z)DunGZvyBlxDuYQPWBBX7AzSb)3]])

    -- Force Hekili to pick up the new pack immediately
    Private.hekili:LoadScripts()
end




