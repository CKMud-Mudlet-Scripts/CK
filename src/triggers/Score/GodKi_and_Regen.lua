local matches = multimatches[2]
local Player = CK.Player

if Player.MaxKi then -- Is it known
    local bm = Player.GK
    local regen = math.floor(Player.MaxGK * matches[3] / 100)
    Player.GKRegen = regen
    gagLine()

    cecho(string.format('\n<dim_gray>GodKi<white>:    %-27s<dim_gray> GODKI REGEN<white>: %s\n', math.format(bm),
        math.format(regen)))
end