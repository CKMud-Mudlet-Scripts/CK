local matches = multimatches[2]
local name = CK.Player.name or CK.API:constant("name")

if matches[3] == name or matches[4] == name then
    CK.API:iThinkWeFighting()
end
