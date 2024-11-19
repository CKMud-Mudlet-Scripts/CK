-- This even Fires every single Prompt
local ck = require("__PKGNAME__")
local API = ck:get_table("API")
local Player = ck:get_table("Player")
local PromptFlags = ck:get_table("PromptFlags")
local PromptCounters = ck:get_table("PromptCounters")
local State = ck:get_table("API.State")
local Affects = ck:get_table("API.Affects")
local Toggles = ck:get_table("Toggles")
local Times = ck:get_table("API.Times")
local Status = ck:get_table("Player.Status")
local Mode = ck:get_table("API.Mode")
local MSDP = ck:get_table("API.MSDP")
local Target = ck:get_table("Target")


Times:create("fight")
Times:create("fightfinished")
Times:create("status")
Times:create("prompt")
ck:define_feature("auto_fight", false)
ck:define_constant("auto_fight.delay", 6)

local function PlayerLoad()
    if API:is_connected(true) then
        raiseEvent("CK.onPlayerReload")
    end
end

local function decPromptCounters()
    for k, v in pairs(PromptCounters) do
        if k ~= "active" then
            if v ~= nil then
                if v <= 1 then
                    PromptCounters[k] = nil
                elseif v ~= nil then
                    PromptCounters[k] = v - 1
                end
            end
        end
    end
end

local function isPromptCounterActive(name)
    return PromptCounters[name] ~= nil
end

local function LastPrompt()
    local last = Times:last("prompt")
    local force = false
    if API:is_connected() then
        if API.Times:last("prompt") > 3600 then
            cecho("<red>!!!!!Prompt is not parsing file a bug!!!!!")
        end
    end
end

-- setup a timer so we always get a prompt in a reasonable time
registerNamedTimer("__PKGNAME__", "CK:LastPrompt", 8, LastPrompt, true)

local function onPrompt()
    Times:reset("prompt")

    -- Lets check if MSDP is up2date 
    if Toggles.ticked_once then
        local last_update = MSDP:last_update()
        if last_update > 60 then
            cecho("<red>!<yellow>!<red>!<yellow>!<white> Reconnecting to fix CKMud MSDP feed <yellow>!<red>!<yellow>!<red>!\n")
            reconnect()
            Toggles.ticked_once = false
        elseif last_update > 5 then
            cecho("<red>!<yellow>!<red>!<yellow>!<white> Re-Subscribing to MSDP events<yellow>!<red>!<yellow>!<red>!\n")
            MSDP:report_names()
            Toggles.ticked_once = false
        end
    end

    Toggles.firstprompt = true

    if not PromptFlags.Kaioken then
        Player.Kaioken = 0
    end

    if not PromptFlags.Target then
        Player.Target = nil
        Player.Target_Full = nil
    end

    if not Status.HT then
        Toggles.NEXTHT = nil
    end

    if PromptFlags.Target or Target.name ~= "" then
        -- How long to wait until we start doing notfighting events
        PromptCounters.fighting = 3
        raiseEvent("CK.onFightingPrompt")
    end

    if Toggles.fighting and not (PromptFlags.Target or Target.name ~= "") then
        -- We just stopped a fight
        Toggles.fighting = false
        raiseEvent("CK.onFinishedFighting")
    end
    -- We haven't been in combat for quite a while
    if API:not_fighting() then
        -- Only when we are damn sure we are not fighting
        raiseEvent("CK.onNotFightingPrompt")
    end
    -- Handle Buffs before we clear flags
    if PromptFlags.affects and State:check(State.NORMAL, true) and ck:feature("auto_buff") then
        Affects:rebuff(PromptFlags.affects)
    end
    -- All flags since last prompt should be cleared so next prompt we can take action
    ck:clear_table(PromptFlags)
    decPromptCounters()
end

registerNamedEventHandler("__PKGNAME__", "onPrompt", "CK.onPrompt", onPrompt)

local function onNotFightingPrompt()
    Toggles.EnemyLineComboTest = true
    Toggles.skip_fight = nil

    if State:check(State.NORMAL, true) and Times:last("status") > 120 then
        Toggles.hide_status = true
        send("status", false)
        Times:reset("status") -- Prevent immediate re-entry next prompt
    end
    -- Handle Send Queue
    ck:get_table("API.SendQueue"):trySendNow()
    raiseEvent("CK.notFighting")
end

registerNamedEventHandler("__PKGNAME__", "onNotFightingPrompt", "CK.onNotFightingPrompt", onNotFightingPrompt)

local function onFightingPrompt(val)
    if ck:feature("auto_fight") and Mode:is(Mode.Interactive) and State:is(State.NORMAL) then
        if Times:last("fight") > ck:constant("auto_fight.delay") then
            if not Toggles.no_fight then
                API:cmd_fight(nil, {free_only=true})
            end
        end
    end
    if State:check(State.CRAFTING, true) or State:check(State.BUFFING, true) or State:check(State.SENSE, true) then
        State:check(State.NORMAL)
    end
    raiseEvent("CK.fighting")
end

registerNamedEventHandler("__PKGNAME__", "onFightingPrompt", "CK.onFightingPrompt", onFightingPrompt)

local function onFinishedFighting(event)
    Toggles.meleefighting = false
    Times:reset("fightfinished")
    Toggles.NEXTHT = nil
    cecho("\n<red>Fight Finished!")
    raiseEvent("CK.finishedFighting")
end

registerNamedEventHandler("__PKGNAME__", "onFinishedFighting", "CK.onFinishedFighting", onFinishedFighting)

registerNamedEventHandler("__PKGNAME__", "CK:PlayerReload", "sysLoadEvent", function(event)
    PlayerLoad()
end)
