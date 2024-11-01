local matches = multimatches[2]
local Player = CK.Player
Player.Kaioken = tonumber(matches.CURR)
Player.MKaioken = tonumber(matches.MAX)
CK.PromptFlags.Kaioken = true