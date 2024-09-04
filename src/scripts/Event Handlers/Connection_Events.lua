local ck = require("__PKGNAME__")
local Toggles = ck:get_table("Toggles")

local function onDisconnectionEvent(eventname)
    Toggles.firstprompt = false
end

registerNamedEventHandler("CKMud-Shared", "onDisconnectionEvent", "sysDisconnectionEvent", onDisconnectionEvent)
registerNamedEventHandler("CKMud-Shared", "onDisconnectionEvent", "sysConnectionEvent", onDisconnectionEvent)