local matches = multimatches[2]
local Player = CK.Player

Player.BaseStats.INT = tonumber(matches[2]:trim())
Player.Stats.INT = tonumber(matches[3]:trim())
Player.LBS = tonumber(matches[4]:trim())
