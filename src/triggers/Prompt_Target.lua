local matches = multimatches[2]
local target = matches[2]
local Player = CK.Player
Player.Target_Full = target
-- Get last word
Player.Target = table.remove(target:split(" "))
CK.PromptFlags.Target = true
CK.API:iThinkWeFighting()