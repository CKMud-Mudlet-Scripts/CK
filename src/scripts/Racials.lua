local ck = require("__PKGNAME__")
local API = ck:get_table("API")
local Racial = ck:get_table("API.Racial")

ck:define_constant("race", "???")
ck:define_constant("race:android.configure", "defense 50")

-- Figure out something better
function API:isAndroid(race)
    return race == "Android"
end

function API:isBioDroid(race)
    return race == "Bio-Android"
end

function API:setRace(race)
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