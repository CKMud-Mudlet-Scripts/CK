local ck = require("__PKGNAME__.ck")
local Times = ck:get_table("API.Times")
local API = ck:get_table("API")
local PromptCounters = ck:get_table("PromptCounters")

function API:constant(name)
  return ck.constant(name)
end

function API:feature(name)
  return ck:feature(name)
end

ck:define_feature("tell_rpc", false)
ck:define_constant("alts", {})

local function compact_featuredb()
  local names = ck:feature_names()
  db:delete(ck.db.schema.Toggles, db:not_in(ck.db.schema.Toggles.name, names))
  echo("[ CK ] - Feature DB Compaction Complete.\n")
end

registerAnonymousEventHandler("sysExitEvent", compact_featuredb)

local function compact_constdb()
  local names = ck:constant_names()
  db:delete(ck.db.schema.Constants, db:not_in(ck.db.schemna.Constants.name, names))
  echo("[ CK ] - Constants DB Compaction Complete.\n")
end

registerAnonymousEventHandler("sysExitEvent", compact_constdb)


function API:iThinkWeFighting()
  -- If we have two prompts with not fight messages its safe to say fighting is over
  PromptCounters.fighting = 2
end

function API:is_connected()
  return Toggles.firstprompt == true
end

function Times:last(name)
  return getStopWatchTime(name)
end

function Times:reset(name)
  resetStopWatch(name)
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
