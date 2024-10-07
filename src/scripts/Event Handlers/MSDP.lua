local ck = require("__PKGNAME__")
local Player = ck:get_table("Player")
local API = ck:get_table("API")

local names = {"LEVEL", "RACE", "POWERLEVEL", "POWERLEVEL_MAX", "KI", "KI_MAX", "FATIGUE", "FATIGUE_MAX", "GODKI",
               "GODKI_MAX", "DARK_ENERGY", "AFFECTS", "ZENNI", "TOKENS", "EPOINTS", "MAX_GRAVITY", "HITROLL", "DAMROLL",
               "ARMOR", "STR", "INT", "WIS", "SPD", "CON", "STR_BASE", "INT_BASE", "WIS_BASE", "SPD_BASE", "CON_BASE",
               "OPPONENT_HEALTH", "OPPONENT_HEALTH_MAX", "OPPONENT_LEVEL", "OPPONENT_NAME", "AREA_NAME", "ROOM_EXITS",
               "ROOM_NAME", "ROOM_VNUM", "CHARACTER_NAME", "THIRST", "HUNGER", "ROOM_GRAVITY", "BASE_PL" }


local function issue_report()
    sendMSDP("REPORT", unpack(names))
end


registerNamedEventHandler("__PKGNAME__", "MSDP REPORT", "sysConnectionEvent", issue_report)


-- Track Name 
registerNamedEventHandler("__PKGNAME__", "MSDP CHARACTER_NAME", "msdp.CHARACTER_NAME", function() 
    local name = msdp.CHARACTER_NAME
    if name ~= Player.name then
        API:setName(name)
    end
end)

-- Track race
registerNamedEventHandler("__PKGNAME__", "MSDP RACE", "msdp.RACE", function() 
    local race = msdp.RACE
    if race ~= Player.race then
        API:setRace(race)
    end
end)

-- BASE_PL
registerNamedEventHandler("__PKGNAME__", "MSDP BasePL", "msdp.BASE_PL", function() 
    Player.BasePl = msdp.BASE_PL
end)

-- PL and MaxPl
registerNamedEventHandler("__PKGNAME__", "MSDP MAX_PL", "msdp.POWERLEVEL_MAX", function() 
    Player.MaxPl = msdp.POWERLEVEL_MAX
end)
registerNamedEventHandler("__PKGNAME__", "MSDP PL", "msdp.POWERLEVEL", function() 
    Player.Pl = msdp.POWERLEVEL
end)

-- FATIGUE API:has_fatigue()
registerNamedEventHandler("__PKGNAME__", "MSDP FATIGUE", "msdp.FATIGUE", function()
    if API:has_fatigue() then
        Player.Fatigue = msdp.FATIGUE
    end
end)
registerNamedEventHandler("__PKGNAME__", "MSDP MAX FATIGUE", "msdp.FATIGUE_MAX", function() 
    if API:has_fatigue() then
        Player.MaxFatigue = msdp.FATIGUE_MAX
    end
end)

-- KI/Max KI
registerNamedEventHandler("__PKGNAME__", "MSDP KI", "msdp.KI", function()
    local race = API:getRace()
    local ki = msdp.KI
    if API:has_fatigue(race) then
        Player.Ki = ki
    elseif API:isAndroid(race) then
        Player.Heat = ki
    elseif API:isBioDroid(race) then
        Player.Biomass = ki
    end
end)
registerNamedEventHandler("__PKGNAME__", "MSDP MAX KI", "msdp.KI_MAX", function() 
    local race = API:getRace()
    local max_ki = msdp.KI_MAX
    if API:has_fatigue() then
        Player.MaxKi = max_ki
    elseif API:isAndroid(race) then
        Player.MaxHeat = max_ki
    elseif API:isBioDroid(race) then
        Player.MaxBiomass = max_ki
    end
end)


--[[
{
  AFFECTS = "",
  AREA_NAME = "Guru's Compound",
  ARMOR = "98",
  BASE_PL = "12637125",
  CHARACTER_NAME = "Nip",
  COMMANDS = { "LIST", "REPORT", "RESET", "SEND", "UNREPORT" },
  CON = "0",
  CON_BASE = "0",
  DAMROLL = "210",
  DARK_ENERGY = "0",
  EPOINTS = "0",
  FATIGUE = "91",
  FATIGUE_MAX = "100",
  GODKI = "0",
  GODKI_MAX = "0",
  HITROLL = "249",
  HUNGER = "0",
  INT = "80",
  INT_BASE = "58",
  KI = "2032",
  KI_MAX = "2032",
  LEVEL = "1",
  MAX_GRAVITY = "358",
  OPPONENT_HEALTH = "0",
  OPPONENT_HEALTH_MAX = "0",
  OPPONENT_LEVEL = "0",
  OPPONENT_NAME = "",
  POWERLEVEL = "12843963",
  POWERLEVEL_MAX = "12843963",
  RACE = "Majin",
  ROOM_GRAVITY = "1",
  ROOM_NAME = "A gravel path",
  ROOM_VNUM = "319",
  SERVER_ID = "CKMud 1.2",
  SPD = "90",
  SPD_BASE = "58",
  STR = "85",
  STR_BASE = "57",
  THIRST = "-1",
  TOKENS = "1",
  WIS = "78",
  WIS_BASE = "59",
  ZENNI = "3777671"
}
]]