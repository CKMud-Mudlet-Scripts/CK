local ck = require("__PKGNAME__")
local Times = ck:get_table("API.Times")
local Toggles = ck:get_table("Toggles")
local API = ck:get_table("API")
local PromptCounters = ck:get_table("PromptCounters")
local PromptFlags = ck:get_table("PromptFlags")
local Player = ck:get_table("Player")

ck:define_constant("name", "???")
ck:define_constant("race", "???")

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
    cecho(f" <Red>Error: Race Change from {old_race}, use `lua CK constant race={race}`")
  end
end

function API:setName(name)
  Player.name = name
  local old_name = ck:constant("name")
  if old_name == "???" then
    ck:set_constant("name", name)
  elseif old_name ~= name then
    cecho(f" <Red>Error: Named Changed from {old_race}, use `lua CK constant name={name}`")
  end
end


function API:status_ok()
  -- Maybe a better system is needed, but this check means you are OK, not great but not bad state
  -- Good for AOE and scouter prechecks
  local race = self:constant("race")
  local health = (Player.Health or 100) >= 50
  if self:isBioDroid(race) then
     return health and Player.Biomass >= 50
  elseif self:isAndroid(race) then
     return health and Player.Heat <= 60
  else 
    -- Everyone else
     return health and Player.Ki > 50 and Player.Fatigue <= 60
  end
end

function API:constant(name)
  return ck:constant(name)
end

function API:feature(name)
  return ck:feature(name)
end

local function compact_featuredb()
  local names = ck:feature_names()
  db:delete(ck.db.schema.Toggles, db:not_in(ck.db.schema.Toggles.name, names))
  echo("[ CK ] - Feature DB Compaction Complete.\n")
end

local function compact_constdb()
  local names = ck:constant_names()
  db:delete(ck.db.schema.Constants, db:not_in(ck.db.schemna.Constants.name, names))
  echo("[ CK ] - Constants DB Compaction Complete.\n")
end

registerNamedEventHandler("__PKGNAME__", "CK:CompactDB", "sysExitEvent", function(event)
  compact_constdb()
  compact_featuredb()
end)

function API:iThinkWeFighting()
  -- If we have two prompts with not fight messages its safe to say fighting is over
  PromptCounters.fighting = 3
  Toggles.fighting = true
  PromptFlags.fighting = true
end

function API:not_fighting()
  -- If we haven't been fighting for 3 prompts then we are not fighting
  return PromptCounters.fighting == nil and Toggles.fighting == false
end

function API:is_connected(ignore_prompt)
  local _, _, connected = getConnectionInfo()
  return (ignore_prompt or Toggles.firstprompt == true) and connected == true
end

function Times:last(name)
  return getStopWatchTime("CK." .. name)
end

function Times:reset(name)
  resetStopWatch("CK." .. name)
end

function PromptCounters:active(name)
  return PromptCounters[name] ~= nil
end

-- Quality Of Life functions
function math.round(x, n)
  return tonumber(string.format("%." .. n .. "f", x))
end

function math.format(i)
  return tostring(i):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

function table.sample_keys(tb)
  local keys = {}
  for k, v in pairs(tb) do
    table.insert(keys, k)
  end
  return keys[math.random(#keys)]
end

function table.sample_items(tl)
  local pos = math.floor(math.random() * #tl) + 1
  return tl[pos]
end

function table.extend(list, items)
  for _, item in ipairs(items) do
    list[#list + 1] = item
  end
end

function API:item_tier()
  -- Thanks Vorrac
  local base_pl = Player.BasePl
  local tier = 0
  if base_pl >= 3000000000 then
    tier = 8
  elseif base_pl >= 1500000000 then
    tier = 7
  elseif base_pl >= 500000000 then
    tier = 6
  elseif base_pl >= 250000000 then
    tier = 5
  elseif base_pl >= 125000000 then
    tier = 4
  elseif base_pl >= 75000000 then
    tier = 3
  elseif base_pl >= 25000000 then
    tier = 2
  elseif base_pl >= 1000000 then
    tier = 1
  end
  return tier
end