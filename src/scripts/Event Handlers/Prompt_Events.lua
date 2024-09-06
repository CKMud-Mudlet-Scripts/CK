-- This even Fires every single Prompt
local ck = require("__PKGNAME__")
local API = ck:get_table("API")
local Player = ck:get_table("Player")
local PromptFlags = ck:get_table("PromptFlags")
local PromptCounters = ck:get_table("PromptCounters")
local State = ck:get_table("API.State")
local Affects = ck:get_table("API.Affects")
local Toggles = ck:get_table("Toggles")
local Timers = ck:get_table("Timers")
local Times = ck:get_table("API.Times")
local Status = ck:get_table("Player.Status")

Times:create("fight")
Times:create("fightfinished")
Times:create("scouterself")
Times:create("score")
Times:create("status")
Times:create("prompt")

local function decPromptCounters()
    for k, v in pairs(PromptCounters) do
        if v ~= nil then
            if v <= 1 then
                PromptCounters[k] = nil
            elseif v ~= nil then
                PromptCounters[k] = v - 1
            end
        end
    end
end

local function isPromptCounterActive(name)
    return PromptCounters[name] ~= nil
end

local function clearFlags()
    -- get_table means everyone has a ref to the table in their local
    -- so we set all the keys to null
    local klist = {}
    for key, _ in pairs(PromptFlags) do
        table.insert(klist, key)
    end
    for _, key in ipairs(klist) do
        PromptFlags[key] = nil
    end
end

local function LastPrompt()
    local last = Times:last("prompt")
    local force = false
    if API:is_connected() then
        if API.Mode:check(API.Mode.Interactive) then
            force = last > 30
        else
            force = last > 8
        end

        if force then
            send("\n")
        end
    
        if  API.Times:last("prompt") > 3600 then
            cecho("<red>!!!!!Prompt is not parsing file a bug!!!!!")
        end
    end
end

local function onPrompt()
    Times:reset("prompt")
    Toggles.firstprompt = true

    if not PromptFlags.Kaioken then
        Player.Kaioken = 0
    end

    -- setup a timer so we always get a prompt in a reasonable time
    registerNamedTimer("__PKGNAME__", "CK:LastPrompt", 30, LastPrompt, true)

    if not Status.HT then
        Toggles.NEXTHT = nil
    end
    -- Things that had not been set since last prompt maybe we can clear
    if Toggles.fighting and not isPromptCounterActive('fighting') then
        Toggles.fighting = false
        raiseEvent("CK.onFinishedFighting")
    end
    -- Lets handle fighting and non fighting stuff
    if Toggles.fighting then
        raiseEvent("CK.onFightingPrompt")
    else
        raiseEvent("CK.onNotFightingPrompt")
    end
    -- Handle Buffs before we clear flags
    if PromptFlags.affects and State:check(State.NORMAL, true) then
        Affects:rebuff(PromptFlags.affects)

    end
    -- All flags since last prompt should be cleared so next prompt we can take action
    clearFlags()
    decPromptCounters()
end

registerNamedEventHandler("__PKGNAME__", "onPrompt", "CK.onPrompt", onPrompt)

local function onNotFightingPrompt()
    Toggles.EnemyLineComboTest = true
    Toggles.skip_fight = nil

    if State:check(State.NORMAL, true) and Times:last("status") > 120 then
        send("status")
        Times:reset("status")
    end
    if State:check(State.NORMAL, true) and Times:last("score") > 240 then
        send("score")
        Times:reset("score")
    end
    if State:check(State.NORMAL, true) and API:status_ok() and Times:last("scouterself") > 900 then
        -- status_green depends on the race 
        send("analyze self")
        Times:reset("scouterself")
    end
    -- Handle Send Queue
    ck:get_table("API.SendQueue"):trySendNow()
end

registerNamedEventHandler("__PKGNAME__", "onNotFightingPrompt", "CK.onNotFightingPrompt", onNotFightingPrompt)

local function onFightingPrompt(val)
    if Times:last("fight") > 2 and PromptFlags.fighting then
        if not Toggles.no_fight then
            API:cmd_fight(nil)
        end
    end
    if State:check(State.CRAFTING, true) or State:check(State.BUFFING, true) or State:check(State.SENSE, true) then
        State:check(State.NORMAL)
    end
end

registerNamedEventHandler("__PKGNAME__", "onFightingPrompt", "CK.onFightingPrompt", onFightingPrompt)

local function onFinishedFighting()
    Toggles.meleefighting = false
    Times:reset("fightfinished")
    Toggles.NEXTHT = nil
    cecho("\n<red>Fight Finished!")
end

registerNamedEventHandler("__PKGNAME__", "onFinishedFighting", "CK.onFinishedFighting", onFinishedFighting)
