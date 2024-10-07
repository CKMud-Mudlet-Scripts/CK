local ck = require("__PKGNAME__")

local names = {"LEVEL", "RACE", "POWERLEVEL", "POWERLEVEL_MAX", "KI", "KI_MAX", "FATIGUE", "FATIGUE_MAX", "GODKI",
               "GODKI_MAX", "DARK_ENERGY", "AFFECTS", "ZENNI", "TOKENS", "EPOINTS", "MAX_GRAVITY", "HITROLL", "DAMROLL",
               "ARMOR", "STR", "INT", "WIS", "SPD", "CON", "STR_BASE", "INT_BASE", "WIS_BASE", "SPD_BASE", "CON_BASE",
               "OPPONENT_HEALTH", "OPPONENT_HEALTH_MAX", "OPPONENT_LEVEL", "OPPONENT_NAME", "AREA_NAME", "ROOM_EXITS",
               "ROOM_NAME", "ROOM_VNUM", "WORLD_TIME", "SERVER_TIME", "CHARACTER_NAME"}

local function issue_report()
    sendMSDP("REPORT", unpack(names))
end


registerNamedEventHandler("__PKGNAME__", "MSDP REPORT", "sysConnectionEvent", issue_report)