local ck = require("__PKGNAME__")
local Player = ck:get_table("Player")
local Room = ck:get_table("Room")
local Target = ck:get_table("Target")
local API = ck:get_table("API")
local MSDP = ck:get_table("API.MSDP")
local Toggles = ck:get_table("Toggles")

local names = {"LEVEL", "RACE", "POWERLEVEL", "POWERLEVEL_MAX", "KI", "KI_MAX", "FATIGUE", "FATIGUE_MAX", "GODKI",
               "GODKI_MAX", "DARK_ENERGY", "AFFECTS", "ZENNI", "TOKENS", "EPOINTS", "MAX_GRAVITY", "HITROLL", "DAMROLL",
               "ARMOR", "STR", "INT", "WIS", "SPD", "CON", "STR_BASE", "INT_BASE", "WIS_BASE", "SPD_BASE", "CON_BASE",
               "OPPONENT_HEALTH", "OPPONENT_HEALTH_MAX", "OPPONENT_LEVEL", "OPPONENT_NAME", "AREA_NAME", "ROOM_EXITS",
               "ROOM_NAME", "ROOM_VNUM", "CHARACTER_NAME", "THIRST", "HUNGER", "ROOM_GRAVITY", "BASE_PL", "UBS", "LBS",
               "UPDATE_EPOCH", "MAX_DENERGY"}

function MSDP:last_update()
    return getEpoch() - ((msdp or {}).UPDATE_EPOCH or 0)
end

function MSDP:report_names()
    sendMSDP("REPORT", unpack(names))
end

-- Track Updates, fire off a CK.tick event for hud to hook into. 
registerNamedEventHandler("__PKGNAME__", "MSDP UPDATE_EPOCH", "msdp.UPDATE_EPOCH", function()
    if not Toggles.ticked_once then
        cecho(f "<yellow>Received MSDP Update Epoch...\n")
    end
    Toggles.ticked_once = true
    raiseEvent("CK.tick")
end)

-- Report all the names to the server to request updates on them
registerNamedEventHandler("__PKGNAME__", "MSDP REPORT", "sysConnectionEvent", function()
    Toggles.ticked_once = false
    MSDP:report_names()
end)

registerNamedEventHandler("__PKGNAME__", "MSDP Player Reload", "CK.onPlayerReload", function()
    Toggles.ticked_once = false
    MSDP:report_names()
end)

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
    Player.BasePl = tonumber(msdp.BASE_PL)
end)

-- PL and MaxPl
registerNamedEventHandler("__PKGNAME__", "MSDP MAX_PL", "msdp.POWERLEVEL_MAX", function()
    Player.MaxPl = tonumber(msdp.POWERLEVEL_MAX)
end)
registerNamedEventHandler("__PKGNAME__", "MSDP PL", "msdp.POWERLEVEL", function()
    Player.Pl = tonumber(msdp.POWERLEVEL)
end)

-- FATIGUE API:has_fatigue()
registerNamedEventHandler("__PKGNAME__", "MSDP FATIGUE", "msdp.FATIGUE", function()
    Player.Fatigue = tonumber(msdp.FATIGUE)
end)
registerNamedEventHandler("__PKGNAME__", "MSDP MAX FATIGUE", "msdp.FATIGUE_MAX", function()
    Player.MaxFatigue = tonumber(msdp.FATIGUE_MAX)
end)

-- KI/Max KI
registerNamedEventHandler("__PKGNAME__", "MSDP KI", "msdp.KI", function()
    Player.Ki = tonumber(msdp.KI)
end)
registerNamedEventHandler("__PKGNAME__", "MSDP MAX KI", "msdp.KI_MAX", function()
    Player.MaxKi = tonumber(msdp.KI_MAX)
end)

-- God Ki
registerNamedEventHandler("__PKGNAME__", "MSDP GK", "msdp.GODKI", function()
    Player.GK = tonumber(msdp.GODKI)
end)
registerNamedEventHandler("__PKGNAME__", "MSDP MAX GK", "msdp.GODKI_MAX", function()
    Player.MaxGK = tonumber(msdp.GODKI_MAX)
end)

-- Hitroll and Damroll
registerNamedEventHandler("__PKGNAME__", "MSDP Damroll", "msdp.DAMROLL", function()
    Player.Damroll = tonumber(msdp.DAMROLL)
end)
registerNamedEventHandler("__PKGNAME__", "MSDP Hitroll", "msdp.HITROLL", function()
    Player.Hitroll = tonumber(msdp.HITROLL)
end)

-- Gravity
registerNamedEventHandler("__PKGNAME__", "MSDP Gravity", "msdp.MAX_GRAVITY", function()
    Player.MaxGravity = tonumber(msdp.MAX_GRAVITY)
end)
registerNamedEventHandler("__PKGNAME__", "MSDP Room Gravity", "msdp.ROOM_GRAVITY", function()
    Room.Gravity = tonumber(msdp.ROOM_GRAVITY)
end)

-- Zenni
registerNamedEventHandler("__PKGNAME__", "MSDP Zenni", "msdp.ZENNI", function()
    Player.Zenni = tonumber(msdp.ZENNI)
end)

-- Stats
---@diagnostic disable-next-line: undefined-field
for _, stat in ipairs(("INT WIS STR SPD"):split(" ")) do
    registerNamedEventHandler("__PKGNAME__", f "MSDP {stat}", f "msdp.{stat}", function()
        Player.Stats[stat] = tonumber(msdp[stat])
    end)
    registerNamedEventHandler("__PKGNAME__", f "MSDP {stat}_BASE", f "msdp.{stat}_BASE", function()
        Player.BaseStats[stat] = tonumber(msdp[f "{stat}_BASE"])
    end)
end

registerNamedEventHandler("__PKGNAME__", "MSDP UBS", "msdp.UBS", function()
    Player.UBS = tonumber(msdp.UBS)
end)
registerNamedEventHandler("__PKGNAME__", "MSDP LBS", "msdp.LBS", function()
    Player.LBS = tonumber(msdp.LBS)
end)

registerNamedEventHandler("__PKGNAME__", "MSDP Dark Energy", "msdp.DARK_ENERGY", function()
    Player.DarkEnergy = tonumber(msdp.DARK_ENERGY)
end)

registerNamedEventHandler("__PKGNAME__", "MSDP Max Dark Energy", "msdp.MAX_DENERGY", function()
    Player.MaxDarkEnergy = tonumber(msdp.MAX_DENERGY)
end)

registerNamedEventHandler("__PKGNAME__", "MSDP Armor", "msdp.ARMOR", function()
    Player.Armor = tonumber(msdp.ARMOR)
end)

registerNamedEventHandler("__PKGNAME__", "MSDP Tokens", "msdp.TOKENS", function()
    Player.Tokens = tonumber(msdp.TOKENS)
end)

registerNamedEventHandler("__PKGNAME__", "MSDP E-Points", "msdp.EPOINTS", function()
    Player.EPoints = tonumber(msdp.EPOINTS)
end)

registerNamedEventHandler("__PKGNAME__", "MSDP Hunger", "msdp.HUNGER", function()
    Player.Hunger = tonumber(msdp.HUNGER)
end)

registerNamedEventHandler("__PKGNAME__", "MSDP Thirst", "msdp.THIRST", function()
    Player.Thirst = tonumber(msdp.THIRST)
end)

-- Room Stuff
registerNamedEventHandler("__PKGNAME__", "MSDP Area Name", "msdp.AREA_NAME", function()
    Room.area = msdp.AREA_NAME
end)
registerNamedEventHandler("__PKGNAME__", "MSDP Room Name", "msdp.ROOM_NAME", function()
    Room.name = msdp.ROOM_NAME
end)
registerNamedEventHandler("__PKGNAME__", "MSDP Room VNUM", "msdp.ROOM_VNUM", function()
    Room.vnum = tonumber(msdp.ROOM_VNUM)
end)

-- OPPONENT STUFF
registerNamedEventHandler("__PKGNAME__", "MSDP Target Health", "msdp.OPPONENT_HEALTH", function()
    Target.Health = tonumber(msdp.OPPONENT_HEALTH)
end)
registerNamedEventHandler("__PKGNAME__", "MSDP Target Max Health", "msdp.OPPONENT_HEALTH_MAX", function()
    Target.MaxHealth = tonumber(msdp.OPPONENT_HEALTH_MAX)
end)
registerNamedEventHandler("__PKGNAME__", "MSDP Target Name", "msdp.OPPONENT_NAME", function()
    local name = msdp.OPPONENT_NAME
    Target.name = name
end)
registerNamedEventHandler("__PKGNAME__", "MSDP Target Level", "msdp.OPPONENT_LEVEL", function()
    Target.level = tonumber(msdp.OPPONENT_LEVEL)
end)

--[[
{
  AFFECTS = "",
  SERVER_ID = "CKMud 1.2",

}
]]
