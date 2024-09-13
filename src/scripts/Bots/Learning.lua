local ck = require("__PKGNAME__")
local Player = ck:get_table("Player")
local Toggles = ck:get_table("Toggles")
local learn = ck:get_table("API.Learning", {
    triggers = {}
})
local Times = ck:get_table("API.Times")
local API = ck:get_table("API")
local State = ck:get_table("API.State")
local Mode = ck:get_table("API.Mode")

--[[
Times:create("zeta.sense")
Times:create("zeta.blast")
ck:define_constant("learning.timeout", 120)
ck:define_constant("zetabot.delay", 0.5)
]]

---@diagnostic disable-next-line: unused-function
local function do_learning()
    if not API:is_connected() then
        -- Don't do anything unless we are connected and have a prompt
        return
    end
    local aoe = zeta.aoe
    local target = zeta.target
    local g = math.min(math.floor((1 / 5000) * 0.06 * Player.MaxPl), (Player.MaxGravity or 2) - 1)
    local timeout = ck:constant("zetabot.timeout")

    if State:is(State.NORMAL) then
        -- We should be attacking
        if Times:last("zeta.blast") > timeout then
            -- Stuck lets reset
            zeta.state.ok_to_blast = true
            Times:reset("zeta.blast")
        end
        if zeta.state.ok_to_blast and API:status_ok() then
            if zeta.state.ok_to_adjust and API:not_fighting() then
                send(f("adjust {g}"))
                zeta.state.ok_to_adjust = false
            end

            send(aoe)
            zeta.state.ok_to_blast = false
        end
    elseif State:is(State.SENSE) then
        -- We should be looking
        if Times:last("zeta.sense") > timeout then
            -- Stuck lets reset
            zeta.state.ok_to_sense = true
            Times:reset("zeta.sense")
        end
        send(f("sense {target}"))
        zeta.state.ok_to_sense = false
    end
end

local function exit()
    -- Delete timer
    deleteNamedTimer("__PKGNAME__", "CK:Zetabot")
    -- Kill Triggers
    for _, id in ipairs(zeta.triggers) do
        killTrigger(id)
    end
    zeta.triggers = {}
end

local function enter()
    -- Change Mode
    Mode:switch(Mode.Zetabot, exit)
    -- Clear out all state
    zeta.state = {
        ok_to_blast = true,
        ok_to_sense = true,
        ok_to_adjust = true
    }
    -- Setup Temp Triggers

    -- Look for a signal that the AOE executed
    table.insert(zeta.triggers, tempTrigger("You have gained", function()
        -- Its okay to blast again
        zeta.state.ok_to_blast = true
    end))

    -- Look for a single nobody is around to aoe
    table.insert(zeta.triggers, tempTrigger("There is no one around to use", function()
        -- Move to SENSE state
        State:set(State.SENSE)
        -- Its okay to send a sense
        zeta.state.ok_to_sense = true
    end))
    -- Look for Sense target found
    table.insert(zeta.triggers, tempTrigger("You're already in the same room!!", function()
        -- Move to NORMAL state
        State:set(State.NORMAL)
        -- Its okay to blast again
        zeta.state.ok_to_blast = true
        -- Its okay to adjust gravity
        zeta.state.ok_to_adjust = true
    end))
    -- Look for Sense Execute
    table.insert(zeta.triggers, tempTrigger("You concentrate and sense", function()
        zeta.state.ok_to_sense = true
    end))

    -- Install a timer
    registerNamedTimer("__PKGNAME__", "CK:Zetabot", ck:constant("zetabot.delay"), do_zetabot, true)
end

function learn:toggle(target, path)
    self.target = target
    self.speedwalk = path
    if Mode:is(Mode.Learning) then
        exit()
        print("Learning Mode Disabled!!!")
    else -- Its off
        local is_android = API:isAndroid(ck:constant("race"))
        if target == nil or (path == nil and not is_android) then
            if is_android then
                print("Learning mode requires a target argument!")
            else
                print("Learning mode requires target and speedwalk to rest")
            end
        else
            print("Learning Mode Enabled!!!")
            -- Change Mode
            Mode:switch(Mode.Interactive)
        end
    end
end

