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
local PromptCounters = ck:get_table("PromptCounters")


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
    deleteNamedTimer("__PKGNAME__", "CK:Learning")
    -- Kill Triggers
    for _, id in ipairs(learn.triggers) do
        killTrigger(id)
    end
    learn.triggers = {}
end

local function enter()
    -- Change Mode
    Mode:switch(Mode.Learning, exit)
    -- Clear out all state
    learn.state = { }
    -- Install a timer
    registerNamedTimer("__PKGNAME__", "CK:Learning", 0.5, do_learning, true)
end

function learn:toggle(target, path)
    self.target = target
    self.speedwalk = path
    if Mode:is(Mode.Learning) then
        Mode:switch(Mode.Interactive)
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
            enter()
        end
    end
end

