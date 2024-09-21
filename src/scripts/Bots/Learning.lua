local ck = require("__PKGNAME__")
local Player = ck:get_table("Player")
local Toggles = ck:get_table("Toggles")
local learn = ck:get_table("API.Learning", {
    triggers = {}, gravity = 0
})
local Times = ck:get_table("API.Times")
local API = ck:get_table("API")
local State = ck:get_table("API.State")
local Mode = ck:get_table("API.Mode")
local PromptCounters = ck:get_table("PromptCounters")




---@diagnostic disable-next-line: unused-function
local function do_learning()
    if not API:is_connected() then
        -- Don't do anything unless we are connected and have a prompt
        return
    end
    local speedwalk = learn.speedwalk
    local target = learn.target
    local g = API:get_gravity()

    if State:is(State.NORMAL) then
        -- We should be attacking
        if Times:last("learn.blast") > timeout then
            -- Stuck lets reset
            learn.state.ok_to_blast = true
            Times:reset("learn.blast")
        end
        if learn.state.ok_to_blast and API:status_ok() then
            if learn.state.ok_to_adjust and API:not_fighting() then
                send(f("adjust {g}"))
                learn.state.ok_to_adjust = false
            end

            send(aoe)
            learn.state.ok_to_blast = false
        end
    elseif State:is(State.SENSE) then
        -- We should be looking
        if Times:last("learn.sense") > timeout then
            -- Stuck lets reset
            learn.state.ok_to_sense = true
            Times:reset("learn.sense")
        end
        send(f("sense {target}"))
        learn.state.ok_to_sense = false
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
    learn.state = {}
    learn.gravity = 0
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
