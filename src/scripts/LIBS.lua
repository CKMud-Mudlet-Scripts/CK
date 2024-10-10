local ck = require("__PKGNAME__")
local Times = ck:get_table("API.Times")
local Toggles = ck:get_table("Toggles")
local API = ck:get_table("API")
local PromptCounters = ck:get_table("PromptCounters")
local PromptFlags = ck:get_table("PromptFlags")
local Player = ck:get_table("Player")
local Skills = ck:get_table("API.Skills")
local State = ck:get_table("API.State")
local Mode = ck:get_table("API.Mode")

ck:define_constant("name", "???")
ck:define_feature("auto_unravel", true)

function Player:get_health()
    return math.floor(Player.Pl / Player.MaxPl * 100)
end

function Player:get_energy()
    return math.floor(Player.Ki / Player.MaxKi * 100)
end

function Player:get_stamina()
    return math.floor(Player.Fatigue / Player.MaxFatigue * 100)
end

function API:RESET_ALL()
    State:set(State.ALLSTOP)
    API.SendQueue:clear()
    Mode:switch()
    State:set()
end

function API:setName(name)
    Player.name = name
    local old_name = ck:constant("name")
    if old_name == "???" then
        ck:set_constant("name", name)
    elseif old_name ~= name then
        cecho(f " <Red>Error: Named Changed from {old_race}, use `lua CK constant name={name}`")
    end
end

function API:auto_unravel(target)
    if ck:feature("auto_unravel") and Skills:learned("unravel") then
        send(f "focus 'unravel' {target}")
    end
end

function API:get_gravity(training)
    local max_gravity = Player.MaxGravity or 2
    local max_pl = Player.MaxPl or Player.Pl
    if training then
        return math.min(math.floor((1 / 5000) * 0.06 * max_pl), max_gravity - 1)
    else
        return max_gravity - 1
    end
end

function API:status_ok()
    return Player:get_health() >= 50 and Player:get_energy() >= 50 and Player:get_stamina() >= 50
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
    PromptCounters.fighting = 4
    Toggles.fighting = true
    PromptFlags.fighting = true
end

function API:not_fighting()
    -- If we haven't been fighting for 3 prompts then we are not fighting
    return PromptCounters.fighting == nil and Toggles.fighting ~= true
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

function API:lowest_stat()
    -- Find the smallest stat
    local stat = nil
    for id, value in pairs(CK.Player.BaseStats) do
        if not stat or Player.BaseStats[stat] > Player.BaseStats[id] then
            stat = id
        end
    end
    return stat
end

function API:get_train()
    local stat = self:lowest_stat()
    if stat == "STR" then
        if Player.UBS < 100 or Player.LBS < 100 then
            -- Try to balance UBS/LBS
            if Player.UBS < Player.LBS then
                return "pushup"
            else
                return "situp"
            end
        elseif math.random() < 0.5 then
            -- pick random if UBS/LBS are balanced
            return "situp"
        else
            return "pushup"
        end
    elseif stat == "WIS" then
        return "meditate"
    elseif stat == "INT" then
        return "study"
    elseif stat == "SPD" then
        return "jog"
    end
end

function API:add_attack(name, cost, dmg, is_ubs, cooldown, count, extra)
    local extra_dict = {}
    for _, k in ipairs(extra or {}) do
        extra_dict[k] = true
    end
    Player.Attacks[name] = { cost, dmg, is_ubs, cooldown or 1, count or 1, extra_dict }
end
