local ck = require("__PKGNAME__.ck")
local Toggles = ck:get_table("Toggles")

function onDisconnectionEvent(eventname)
    Toggles.firstprompt = false
end

