local matches = multimatches[2]
local Player = CK.Player

if Player.MaxBiomass then -- Is it known
    local bm = math.floor(matches[2] / 100 * Player.MaxBiomass)
    local regen = math.floor(Player.MaxBiomass * matches[3] / 100)
    deleteLine()

    cecho(string.format('\n<dim_gray>BioMass<white>:    %-22s<dim_gray> BM REGEN<white>: %s\n', math.format(bm),
        math.format(regen)))
end
