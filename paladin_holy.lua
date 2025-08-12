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
    spec:RegisterPack(name, date, [[Hekili:LIvBVTTnq4FlbdWBfRXt2okPDRjaRTFOjylRaU7tdvs0s0wCHIuGKkogiq)23rsBlQ3DYqbcSKo(CVX7UNRbZc(wWYeKchC)CV5(EVB28PZ8w47FrWs1UCCWYCu8dOnWpyOm4VFKtv)OmmLt3vg9tZFJwGDuokrdKKxiIbHcwUQGqv3Ycw1b6ZwS4DGS544G7V0pyzkjjbBfflJTQqwg9fqfblPePsAWgtxhMGxJzsm889glhZqRO4KGpgSefRiCgGb5rcdhMl4k8HxbWki52ho)8ZlJwcGvg9zlALr)UrWYO)auwzeirWs4akSGGaZdJOQ0P5XWN(qz0fEbk4FaORrfuvxMsB99NicRPA(PpXzkbNsXI3SxPh8bbEvXdyql3pVhVmgrPH2hc1HiBGk0MJQfQaqw8AajMZPj8TmPgHlEniOdCe2g959FnNpjxAd15cCmpBf6yW28hv3PF8JCdCOcbYnnUQy96P5ikkHy)4uT3numEfgfdaXxdM2MuLlyArEehMWvtBivz01LrEDDh4Rc85FY4g2SDhjMkfSrWlYlJMug1PQwJiQ0dQQT9A(Sn2vLghOMrhocZqsq576Y0)0bqgPuXy1H68EidJtaL0r4DiXRSOhXSnWLNWTcKXv69s8(6Dfui11n1gxaQJ7uDm(5NlJgWsaGKs9jG4QSildloEHUlrqfQImMRjasFzFslZf6kK6sFvFsVLWaFPH0V71eERUQ8irOkmDjEFVaLXNIFs3h2CHeEQrlXfEDBVo9Gb8N55QGvVef47z(G7BVPm6QEuRebiVMeB8QznVZF6ADUd(u0UqiGLIyj7BkDO72aLvXums3cUJkQVyp9i1tTSWecm2KoCvLE0CyoFlwarjOdXcZHpRms3cbdcXGleRPql2Pks8dgRWIEFrJp8ENirneAvy(IsRxSpT20GRu2wUirNs3q5qNPblVhtzxzvMPlaHTUqsC6AdncQuk4zY0Q2(Dm(6fOv)kCn(PmLh)WXEcNuc03G9avZg7uBWji7eTR6nL0n2Nni8Tsc93YzSWHV3qH53724ZjAvVHNTpYbX(3IKnzyMQPq9x2FyI40knmvGZagAstBLnXjtZqpz8GJYEqnDjPtbVOqIsWIqPsqme4uwAmd0KqMsWut8vLIdf6ybMxi7QPXN)6YX4QE6P3b7HOqInyv7gI2PLDpj1j1H0JjntSgB6nmfsIJbP2h)AyaBbEme2LDv5x7EcmgvMzc3qa)rSqxCVFNJl1TX3IemWwHO63sjqYdMmTMqbM)6hYiMrhLrYI8CUa811Ci(TbZaBjUmcYLShWk50YOYOBv2dzOKc3iGqjirQMuhgu8on2eo4hWViSyAbKgHpb(bw8RL3bzSYO)5V1lDCRcNj)(BlJ2MsItDLgX2vP1Yigxd(t5usmrrRWnr)lTYXvk93kJaBFVA(MfIYOzFxdAI7RM7O5Tek1XJ2dP6GOMOH5vSISvyHwXskmmP8UBZ0bm9lU0YuvFZ0SYg8rnVsvkxy3OdMrJK4K)IvBhsn5EtQiy5pyUn3INC5DwCLtpUgWpF9V0K19iczie)wY6RfisceEU7GYoPfZoIoGPD1m330ChM3Q3E5A3DWgx6JS0hx098ogxqOVJRNo2kVvHqxthqV1c164Od5aykUJAgAvHkvC0Fb8Dx(qdDRwv9CSA9FEbh0zHHxWPAVgG(WD3j85NFfGAxCyC5SRmmUC2Lf6rUg0)1UYz6sJjNOHR2jKWvekSzQaXIXhkTAF(jgCdZ4pI1Zpdjzzq0NPg3bQFH7iZIj1PMUWBCKoUqWqa57nP6PBUQhyD3dyi0M57wu0pB)kTSVUwxoBxBOf8wY)DDIAm0gYSUaCYJueU56fDbwDEzdH2vEt6LoDxixr4Aqu9))zv(EDD(ACKnDWCId(dDVFGWCDmo7KazqdzXPzi12bRngN1)MEdMv66Rhi(25f160D1gYaKRVbOlpPxc16V6wY0nx3kRaMUbwqpKNFz5gluniTQHOfl4pm375N75)hPgW5sSTLQosz104TlU5QGG)7]])

    -- Force Hekili to pick up the new pack immediately
    Private.hekili:LoadScripts()
end




