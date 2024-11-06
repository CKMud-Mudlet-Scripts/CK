local matches = multimatches[2]
local Player = CK.Player

if Player.MaxKi then -- Is it known
    local bm = Player.Ki
    local regen = math.floor(Player.MaxKi * matches[3] / 100)
    Player.KiRegen = regen
    gagLine()

    cecho(string.format('\n<dim_gray>Ki<white>:    %-27s<dim_gray> KI REGEN<white>: %s\n', CK.math.format(bm),
        CK.math.format(regen)))
end