local matches = multimatches[2]
local affect = string.trim(matches.affect)
local timeleft = (tonumber(string.trim(matches.time)) or 1) * 60
cecho("<green> " .. timeleft .. " seconds")
CK.PromptFlags.affects[affect] = true
