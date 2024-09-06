local matches = multimatches[2]
local Player = CK.Player

Player.BaseStats.WIS = tonumber(matches[2]:trim())
Player.Stats.WIS = tonumber(matches[3]:trim())
Player.UBS = tonumber(matches[4]:trim())
