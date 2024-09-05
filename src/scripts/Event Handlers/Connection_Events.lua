local ck = require("__PKGNAME__")
local Toggles = ck:get_table("Toggles")

local function onDisconnectionEvent(eventname)
    Toggles.firstprompt = false
end

registerNamedEventHandler("__PKGNAME__", "onDisconnectionEvent", "sysDisconnectionEvent", onDisconnectionEvent)
registerNamedEventHandler("__PKGNAME__", "onDisconnectionEvent", "sysConnectionEvent", onDisconnectionEvent)