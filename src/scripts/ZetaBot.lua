local ck = require("__PKGNAME__")
local Player = ck:get_table("Player")
local Toggles = ck:get_table("Toggles")
local zeta = ck:get_table("API.Zetabot", { triggers = {} })
local Times = ck:get_table("API.Times")

Times:create("zeta.sense")
Times:create("zeta.blast")

local function enter()
    -- Change Mode
    API.Mode.switch(API.Mode.Zetabot)
    -- Clear out all state
    zeta.state = { ok_to_blast = true, ok_to_sense = true, ok_to_adjust = true }
    -- Setup Temp Triggers

    -- Look for a signal that the AOE executed
    zeta.triggers:insert(
        tempTrigger("You have gained", function()
            -- Its okay to blast again
            zeta.state.ok_to_blast = true
        end)
    )

    -- Look for a single nobody is around to aoe
    zeta.triggers:insert(
        tempTrigger("There is no one around to use", function()
            -- Move to SENSE state
            API.State.set(API.State.SENSE)
            -- Its okay to send a sense
            zeta.state.ok_to_sense = true
        end)
    )
    -- Look for Sense target found
    zeta.triggers:insert(
        tempTrigger("You're already in the same room!!", function()
            -- Move to NORMAL state
            API.State.set(API.State.NORMAL)
            -- Its okay to blast again
            zeta.state.ok_to_blast = true
            -- Its okay to adjust gravity
            zeta.state.ok_to_adjust = true
        end)
    )
    -- Look for Sense Execute
    zeta.triggers:insert(
        tempTrigger("You concentrate and sense", function()
            zeta.state.ok_to_sense = true
        end)
    )

    -- Install a timer
    registerNamedTimer("__PKGNAME__", "CK:Zetabot", 0.5, do_zetabot, true)
end

local function exit()
    -- Delete timer
    deleteNamedTimer("__PKGNAME__", "CK:Zetabot")
    -- Kill Triggers
    for _, id in ipairs(zeta.triggers) do
        killTrigger(id)
    end
    zeta.triggers = {}
    -- Change Mode
    API.Mode.switch(API.Mode.Interactive)
end

function zeta:toggle(aoe, target)
    self.target = target
    self.aoe = aoe
    if API.Mode:is(API.Mode.Zetabot) then
        -- Its on, but we want to change target or attack
        if aoe and target then
            print(f "Zetabot Mode Swap: {aoe} {target}!")
        else
            exit()
            print("Zetabot Mode Disabled!!!")
        end
    else -- Its off
        if aoe == nil or target == nil then
            print("Zetabot Error no attack and/or target")
        else
            -- We have aoe and target lets roll
            print("Zetabot Mode Enabled!!!")
            enter()
        end
    end
end

---@diagnostic disable-next-line: unused-function
local function do_zetabot()
    if not API:is_connected() then
        -- Don't do anything unless we are connected and have a prompt
        return
    end
    local aoe = zeta.aoe
    local target = zeta.target
    local g = math.min(math.floor((1 / 5000) * 0.06 * Player.MaxPl), (Player.MaxGravity or 2) - 1)

    if API.State:is(API.State.NORMAL) then
        -- We should be attacking
        if Times:last("zeta.blast") > 120 then
            -- Stuck lets reset
            zeta.state.ok_to_blast = true
            Times:reset("zeta.blast")
        end
        if zeta.state.ok_to_blast and not Toggles.fighting and API:status_ok() then
            if zeta.state.ok_to_adjust then
                send(f("adjust {g}"))
                zeta.state.ok_to_adjust = false
            end

            send(aoe)
            zeta.state.ok_to_blast = false
        end
    elseif API.State:is(API.State.SENSE) then
        -- We should be looking
        if Times:last("zeta.sense") > 120 then
            -- Stuck lets reset
            zeta.state.ok_to_sense = true
            Times:reset("zeta.sense")
        end
        send(f("sense {target}"))
        zeta.state.ok_to_sense = false
    end
end
