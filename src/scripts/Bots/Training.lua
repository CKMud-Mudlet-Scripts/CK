local ck = require("__PKGNAME__")
local Player = ck:get_table("Player")
local train = ck:get_table("API.Training", {
    triggers = {},
})
local API = ck:get_table("API")
local State = ck:get_table("API.State")
local Mode = ck:get_table("API.Mode")
local Skills = ck:get_table("API.Skills")
local Room = ck:get_table("Room")
local Target = ck:get_table("Target")

ck:define_feature("training.UBS_LBS", true)

---@diagnostic disable-next-line: unused-function
local function do_training()
    if not API:is_connected() then
        -- Don't do anything unless we are connected and have a prompt
        return
    end
    local speedwalk_path = train.speedwalk
    local target = train.target or train:get_exercise()

    if State:is(State.NORMAL) then
        if train.state.go_rest then
            -- Handle Rest
            State:set(State.SPEEDWALK)
            train.state.go_rest = false
            registerAnonymousEventHandler("sysSpeedwalkFinished", function()
                State:set(State.REST)
                send("drink fountain")
                send("sleep")
            end, true)
            speedwalk(speedwalk_path, false, 0.5)
        elseif train.state.go_train then
            train.state.go_train = false
            train:adjust_gravity()
            send(target)
            if target == "jog" then
                train.state.go_jog = true
                send("down")
            end
        end
    elseif State:is(State.REST) then
        -- WE are resting
        if API:is_rested() then
            State:set(State.SPEEDWALK)
            send("wake")
            registerAnonymousEventHandler("sysSpeedwalkFinished", function()
                State:set(State.NORMAL)
                train.state.go_train = true
            end, true)
            speedwalk(speedwalk_path, true, 0.5)
        end
    end
end

local function exit()
    -- Delete timer
    deleteNamedTimer("__PKGNAME__", "CK:Training")
    -- Kill Triggers
    for _, id in ipairs(train.triggers) do
        killTrigger(id)
    end
    train.triggers = {}
end

local function go_rest()
    train.state.go_jog = false
    train.state.go_rest = true
end

local function enter()
    -- Change Mode
    Mode:switch(Mode.Training, exit)
    -- Clear out all state
    train.state = {
        go_rest = false,
        go_train = true,
        go_jog = false,
    }
    -- Install Triggers
    -- Rest Triggers
    table.insert(train.triggers, tempExactMatchTrigger("You stop doing pushups because you are too tired.", go_rest))
    table.insert(train.triggers, tempExactMatchTrigger("You stop doing situps because you are too tired.", go_rest))
    table.insert(train.triggers, tempExactMatchTrigger("You stop doing exercises because you are too tired.", go_rest))
    table.insert(train.triggers, tempExactMatchTrigger("You stop studying because you are too tired.", go_rest))
    table.insert(train.triggers, tempExactMatchTrigger("You stop meditating because you are too tired.", go_rest))

    -- Jog Trigger
    table.insert(train.triggers, tempExactMatchTrigger("You jog around a bit.",
        function()
            if train.state.go_jog and State:is(State.NORMAL) then
                -- We might need to param this in the future, but down is the common pattern
                send("down")
            end
        end
    ))
    table.insert(train.triggers, tempExactMatchTrigger("You stop jogging.", go_rest))

    -- Install a timer
    registerNamedTimer("__PKGNAME__", "CK:Training", 2, do_training, true)
end

function train:adjust_gravity()
    local new_grav = API:get_gravity(true)
    send(f "adjust {new_grav}")
end

function train:get_exercise()
    if ck:feature("training.UBS_LBS") and Player.UBS < 75 or Player.LBS < 75 then
        if Player.UBS < Player.LBS then
            return table.sample_items({ "pushup", "situp" })
        end
        return "jog"
    end
    local stat = API:lowest_stat()
    if stat == "STR" then
        return table.sample_items({ "pushup", "situp" })
    elseif stat == "WIS" then
        return "meditate"
    elseif stat == "INT" then
        return "study"
    elseif stat == "SPD" then
        return "jog"
    end
end

function train:toggle(path, target)
    self.target = target
    self.speedwalk = path
    if Mode:is(Mode.Training) then
        Mode:switch(Mode.Interactive)
        print("Training Mode Disabled!!!")
    else -- Its off
        if path == nil then
            error("A speed walk is required argument, for finding the isolation chamber")
            return
        end
        ---@diagnostic disable-next-line: undefined-field
        if target and not table.contains({ "study", "exercise", "jog", "meditate", "pushup", "situp" }, target) then
            error(f"Unknown exercise {target}. Not enabling training mode")
            return
        end
        if Player.Status.FLY then
            send("land")
        end
        print("Training Mode Enabled!!!")
        -- Change Mode
        enter()
    end
end
