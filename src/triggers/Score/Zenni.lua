local matches = multimatches[2]
local Player = CK.Player

if not CK.Toggles.hide_score then
cecho(
    string.format(
      '      <dim_gray>Gauntlet Runs:<yellow> %s\n',
      CK.math.format(math.floor(Player.Zenni / 25000000))
    )
  )
end