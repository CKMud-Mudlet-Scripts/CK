local matches = multimatches[2]
local Player = CK.Player

if Player.MaxKi then -- Is it known
    local bm = math.floor(matches[2] / 100 * Player.MaxKi)
    local regen = math.floor(Player.MaxKi * matches[3] / 100)
    Player.KiRegen = regen
    gagLine()

    cecho(string.format('\n<dim_gray>BioMass<white>:    %-22s<dim_gray> BM REGEN<white>: %s\n', math.format(bm),
        math.format(regen)))
end