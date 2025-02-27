local ck = require("__PKGNAME__")
local Times = ck:get_table("API.Times")
local Toggles = ck:get_table("Toggles")
local API = ck:get_table("API")
local PromptCounters = ck:get_table("PromptCounters")
local PromptFlags = ck:get_table("PromptFlags")
local Player = ck:get_table("Player", { Attacks = {} })
local Skills = ck:get_table("API.Skills")
local State = ck:get_table("API.State")
local Mode = ck:get_table("API.Mode")

ck:define_constant("name", "???")
ck:define_feature("auto_unravel", true)
ck:define_feature("auto_fruit", true)
ck:define_feature("beep", true)

function Player:get_health()
    if Player.Pl and Player.MaxPl then
        return math.floor(Player.Pl / Player.MaxPl * 100)
    end
    return 100 -- Lie So prompt works on first login
end

function Player:get_energy()
    return math.floor(Player.Ki / Player.MaxKi * 100)
end

function Player:get_stamina()
    if not API:has_fatigue() then
        return 100
    end
    return math.floor(Player.Fatigue / Player.MaxFatigue * 100)
end

function API:RESET_ALL()
    State:set(State.ALLSTOP)
    API.SendQueue:clear()
    Mode:switch()
    State:set()
end

function API:BEEP()
    if ck:feature("beep") then
        alert()
        playSoundFile({ name = getMudletHomeDir() .. "/__PKGNAME__/beep.mp3", loops = #matches })
        for i = 1, #matches do
            selectCaptureGroup(i)
            replace("")
        end
    end
end

function API:setName(name)
    Player.name = name
    local old_name = ck:constant("name")
    if old_name == "???" then
        ck:set_constant("name", name)
    elseif old_name ~= name then
        cecho(f " <Red>Error: Named Changed from {old_race}, use `CK constant name=\"{name}\"`")
    end
end

function API:getName()
    return Player.name or ck:constant("name")
end

function API:auto_unravel(target)
    if ck:feature("auto_unravel") and Skills:learned("unravel defense") then
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

function API:cmd_stack_empty()
    -- I might move this in the future
    return CK.cmd_stack == 0
end

function API:cmd_stack()
    return CK.cmd_stack
end

function API:status_ok()
    return Player:get_health() >= 50 and Player:get_energy() >= 50 and Player:get_stamina() >= 50
end

function API:is_rested()
    return (
        Player.GK == Player.MaxGK and
        Player.Ki == Player.MaxKi and
        Player.Fatigue == Player.MaxFatigue and
        Player.Pl == Player.MaxPl
    )
end

function API:auto_rest()
    if State:is(State.NORMAL) and Mode:is(Mode.Interactive) then
        State:set(State.REST)
    end
end

function API:auto_wake()
    if State:is(State.REST) and Mode:is(Mode.Interactive) then
        State:set(State.NORMAL)
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

function API:not_fighting()
    -- If we haven't been fighting for 3 prompts then we are not fighting
    return not PromptCounters.fighting and not Toggles.fighting and not PromptFlags.Target
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
    for id, value in pairs(Player.BaseStats) do
        if not stat or Player.BaseStats[stat] > Player.BaseStats[id] then
            stat = id
        end
    end
    return stat
end

function API:add_attack(name, cost, dmg, is_ubs, cooldown, count, extra)
    local extra_dict = {}
    for _, k in ipairs(extra or {}) do
        extra_dict[k] = true
    end
    Player.Attacks[name] = { cost, dmg, is_ubs, cooldown or 1, count or 1, extra_dict }
end

function API:check_msdp_mudlet_settings()
    local options = getConfig()
    local changes = false
    local wanted = {
        enableGMCP = false,
        enableMNES = true,
        enableMSDP = true,
        enableMSP = false,
        enableMSSP = false,
        enableMTTS = true
    }

    for name, value in pairs(wanted) do
        if options[name] ~= value then
            setConfig(name, value)
            changes = true
        end
    end
    if changes and self:is_connected(true) then
        cecho(
            "<red>!<yellow>!<red>!<yellow>!<white> Reconnecting to fix Mudlet Protocol Settings <yellow>!<red>!<yellow>!<red>!\n")
        reconnect()
    end
    return changes
end

registerNamedEventHandler("__PKGNAME__", "Enforce Protocols", "sysConnectionEvent", function()
    API:check_msdp_mudlet_settings()
end)

registerNamedEventHandler("__PKGNAME__", "Enforce Protocols on Install", "sysInstall", function(event, name)
    if name == "__PKGNAME__" then
        API:check_msdp_mudlet_settings()
    end
end)

function API:send_multi(cmds)
    for _, cmd in ipairs(cmds:split(";")) do
        send(cmd)
    end
end
