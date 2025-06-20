local _, Private = ...

-- Holy Paladin Hekili pack
if Private.hekili and Private.class == "PALADIN" then
    -- Holy Paladin spec ID is 65
    local spec = Private.hekili:GetSpecialization(65)
    local name = string.format("%s_holy", Private.shortName)
    local date = 20250620

    -- Remove an old pack with same key if user had an older version
    if Hekili.DB and Hekili.DB.profile and Hekili.DB.profile.packs and Hekili.DB.profile.packs[name] then
        Hekili.DB.profile.packs[name] = nil
    end

    -- NOTE: Replace the placeholder text below with the real pack export string once you build it in Hekili.
    spec:RegisterPack(name, date, [[Hekili:1IvtZTTnq0Fl5IsYuxwkQyB5or(qo14dUDgLZKeIesK1GaSaG2rZ4H)27UasuauKYsjTxsKaw82pWUp8SINg)T4L5enn(XOWORdVjkmiCA0TtJIxQ3wtJxwtYEISb(aNub)7xemTQqW2QAQPsLMirt2YeKCekLOrMbMfVCvtjt)vE8QHWFA0mW2AAw8J3CD8YIY8CQ1uQkBNtAt)dWnXlzLkTYGDnLNd(e(8JM4MYjRy084VeVmtwQPYsc631RdOv1BLucpHr3qY2g0u3MoPnTs0OOINPYa63ru7TybLW0fb1z620p3MExy8ssMUuWJx(IqMNiwNSHjKqmbP9gQoEz3zJ1qcoAmH1RKAXluzB69lAtNzC8gPOPobDAcNsZHd15ow5Mcn6VCYlCe7zxi2xwMo)cZ0pD(rZbGvfLuMbADbnrIzifafWtJ37Rjnm9PVAVSKkYjPyKTjcEsbHNRU4BVlZTZcn7NtnnIaA08s(MGCbCr2fpWYkfSmwnQLcnD36dgz))E3F7)z39xMFNF9b)AYdGvj7PrC61NECVKVUrbiHXUz05hBG)gNsXAgrv0H3iH1nJgwNy2oV85sonrlymeJBpFmmrVjHZPplq0sinscKShqhxiPIOam2IWp)cHxtyuUoyfLKzRNpxk1n0G9qCOfUNfOZU78D2bG0BLQKCkRekQeEMbOPHJI0hgG4Sn91x3vzwXeICwJY2c8rNcZZu(gCK7fjrxyCIHPz)(syG9jQRtrtobN(4Sn7UHTeEgyM56j3HFvtvf0l1ZRFAmZjn6MkEFZVEmZFPKRpg9BgnyQLWN6B(TUMxlS)VVjZDnbMpsGIuLQVv97ouAzzgUXHZMrySe7xsW39TV(NyLE09(pYwh66sx(dpFg5DfxqWITPWy6b6zBKRT)Dt(MkysOVrJtgNvGueafdqehz7iZecgs8hCiadK0ksjhm7EOrolpOI8DN8x2OiqoMG1MNmJcrJt4(o0dCfndYg447j9SGf0dlGKmbMVqLCDEZ5Wgx51izi(ujJvi86IiYmIHttkpYu4R1sAMOAf5nEF3maxtye4ftlZM)RMESEN(nB8ipttYfUuzMmYC)eoepMLP)Kp4AyEgMNCnPeOd2DQU7HJIbJzJhdMTnfnOSbeI4RAgPZFk8UW5Wl0ejhMrHzRVvqBtlRQfsiLwlafaVFNiQ33MkP)ttPeJdLOcSd4nevGkCybOnfAcubTpyqyn8mKa4j2GgjjqFjOMawhMIbJl5qMIMzJ02uCCezA17TJlmUVH7zDEoAmO7NSIOO)E7dTP)kCSDIHGV(Wxnro6Jz(OJrg2XiwxY66vvbDTq)YIFZRp4QY1lgUXP9HHoCV7B84J3SSi8TaXCHHGyAnMmCBXKXBfqp05dazxLQxzfDSOtZb6N(sAMmKCMphf6c6QbLB(ta)SWjdjW11NEAjh0vhuVE)IztophFRxEDGw9NixMFTlK(6(ge2rLCEM5WnE5GJCWU2ipTno26kUBqJNmO6qVwHEY2ggMrub6cuFzBVDW7jaZuifk1(k1ho6SV(6rc6(OlEwbBdukT6UmDyNZaHvc2y7AvCn2UwbwJISrpL7Uw5tUR0PwYDX(YGUcfaTyV(NRScNwmD4rbVv9v84U1(3198RVKbSeUtvZIOxF9eQzUhuY4bKJYceL31tNYeRPJQrXJr0xhIxlLNSdhI0G91QZIiAKFYOZCC(UWbDR3pHZX0DJpQCzX(pcj68HJ4r(bAoYlGEf4r98)eeUG)cDTP)L9Lx8p(uxiK2F)oJeM4)9d]])

    -- Force Hekili to pick up the new pack immediately
    Hekili:LoadScripts()
end




