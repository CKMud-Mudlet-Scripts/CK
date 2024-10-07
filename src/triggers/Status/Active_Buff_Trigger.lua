local matches = multimatches[2]
local affect = string.trim(matches.affect)
local timeleft = (tonumber(string.trim(matches.time)) or 1) * 60
if not CK.Toggles.hide_status then
    cecho("<green> " .. timeleft .. " seconds")
end
CK.PromptFlags.affects[affect] = true
