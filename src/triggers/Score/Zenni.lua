local matches = multimatches[2]
local Player = CK.Player

Player.Zenni = tonumber(matches[2]:gsub(",", ""):trim())

cecho(
    string.format(
      '      <dim_gray>Gauntlet Runs:<yellow> %s\n',
      math.format(math.floor(Player.Zenni / 25000000))
    )
  )