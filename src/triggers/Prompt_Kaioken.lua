local matches = multimatches[2]
local Player = CK.Player
Player.Kaioken = tonumber(matches.CURR)
local cur = Player.Kaioken
local max = tonumber(matches.MAX)
CK.PromptFlags.Kaioken = true

-- Toggle This also handler KAIO and King Kai buffs
if max < 120 and cur < max + 9 then
  if cur < 128 then
    send(f("kaioken {max+9}"))
  end
end