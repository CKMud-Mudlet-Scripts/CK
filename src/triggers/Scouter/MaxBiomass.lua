local matches = multimatches[2]
local value = tonumber(string.trim(string.gsub(matches[2], ",", "")))
if CK.Player.Biomass > 0 then
    -- Lets reverse engineer our max
    CK.Player.MaxBiomass = value / (CK.Player.Biomass/100)
end