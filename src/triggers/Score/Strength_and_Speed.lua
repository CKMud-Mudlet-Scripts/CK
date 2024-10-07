local matches = multimatches[2]
local Player = CK.Player

Player.BaseStats.STR = tonumber(matches[2]:trim())
Player.Stats.STR = tonumber(matches[3]:trim())
Player.BaseStats.SPD = tonumber(matches[4]:trim())
Player.Stats.SPD = tonumber(matches[5]:trim())