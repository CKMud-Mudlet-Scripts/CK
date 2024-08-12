local fried = require("__PKGNAME__.fried")
local Toggles = fried.get_table("Toggles")

function onDisconnectionEvent(eventname)
Toggles.firstprompt = false
end

