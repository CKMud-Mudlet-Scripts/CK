local ck = require("__PKGNAME__")
local Player = ck:get_table("Player")
local API = ck:get_table("API")

ck:get_table("Player.Stats")
ck:get_table("Player.BaseStats")


local function dam(stat1, stat2, supreme, boosted)
    local supreme_multi = supreme and 7500 or 5000
    local boost_multi = (boosted or supreme) and 750 or 500
    return
        math.floor(
            ((stat1 * 1.8) * supreme_multi) +
            ((stat2 / 5) * supreme_multi) +
            (Player.Damroll * boost_multi) +
            (Player.Hitroll * boost_multi) +
            (math.min((Player.MaxPl / 200), 2000000))
        )
end

function API:heal_factor()
    return Player.Stats.INT * 5000 + Player.Stats.WIS * 25000 + Player.MaxPl / 100
end

function API:ki_dam(supreme, boosted)
    return dam(Player.Stats.INT, Player.Stats.WIS, supreme, boosted)
end

function API:phy_dam(supreme, boosted)
    return dam(Player.Stats.STR, Player.Stats.SPD, supreme, boosted)
end
