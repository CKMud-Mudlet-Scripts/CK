local ck = require("__PKGNAME__")
local API = ck:get_table("API")
local Player = ck:get_table("Player")
local Racial = ck:get_table("API.Racial")

ck:define_constant("race", "???")
ck:define_constant("race:android.configure", "defense 50")

-- Figure out something better
function API:isAndroid(race)
    return (race or self:getRace()) == "Android"
end

function API:isBioDroid(race)
    return (race or self:getRace()) == "Bio-Android"
end

function API:setRace(race)
  Player.race = race
  local old_race = ck:constant("race")
  if old_race == "???" then
    ck:set_constant("race", race)
  elseif old_race ~= race then
    cecho(f " <Red>Error: Race Change from {old_race}, use `lua CK constant race={race}`")
  end
end

function Racial:Android_setConfigure(value)
    ck:set_constant("race:android.configure", value)
end

function Racial:Android_getConfigure()
    return ck:constant("race:android.configure")
end

function API:has_fatigue(_race)
  local race = _race or self:getRace()
  return (self:isAndroid(race) or self:isBioDroid(race))
end

function API:getRace()
  return Player.race or ck:constant("race")
end