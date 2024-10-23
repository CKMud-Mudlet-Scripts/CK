local ck = require("__PKGNAME__")
local Player = ck:get_table("Player")
local Toggles = ck:get_table("Toggles")
local learn = ck:get_table("API.Learning", {
    triggers = {},
    gravity = 0,
    to_learn = {}
})
local Times = ck:get_table("API.Times")
local API = ck:get_table("API")
local State = ck:get_table("API.State")
local Mode = ck:get_table("API.Mode")
local PromptCounters = ck:get_table("PromptCounters")
local Skills = ck:get_table("API.Skills")
local Room = ck:get_table("Room")

local instant_targets = {"gine", "roshi", "teragon", "malak", "bubbles", "cypher"}

local function aoe_ok()
    return API:status_ok()
end

local function heal_ok()
    return API:status_ok()
end

local function buff_ok()
    return API:status_ok()
end

local function ultra_ok()
    return Player.GK >= 25
end

---@diagnostic disable-next-line: unused-function
local function do_learning()
    if not API:is_connected() then
        -- Don't do anything unless we are connected and have a prompt
        return
    end
    local speedwalk_path = learn.speedwalk
    local target = learn.target

    if State:is(State.NORMAL) then
        local sent = false
        local to_learn = learn.to_learn
        local learned = learn:setup_skills()
        learn:maybe_adjust_gravity()
        if learned > 0 then
            -- Handle Primary Skills
            if #(to_learn.energy) > 0 and API:can_use_energy_attack(to_learn.energy[1]) then
                send(f "{to_learn.energy[1]} {target}")
                sent = true
            elseif #(to_learn.melee) > 0 and API:can_use_melee_attack(to_learn.melee[1]) then
                send(f "{to_learn.melee[1]} {target}")
                sent = true
            elseif #(to_learn.aoe) > 0 and aoe_ok() then
                send(f "{to_learn.aoe[1]}")
                sent = true
            elseif #(to_learn.buffs) > 0 and buff_ok() then
                send(f "focus '{to_learn.buffs[1]}'")
                sent = true
            elseif #(to_learn.heals) > 0 and heal_ok() then
                send(f "focus '{to_learn.heals[1]}'")
                sent = true
            elseif #(to_learn.ultras) > 0 and ultra_ok() then
                send(f "focus '{to_learn.ultras[1]}'")
                sent = true
            elseif #(to_learn.learnable) > 0 and API:status_ok() then
                send(f "{to_learn.learnable[1]} {target}")
                sent = true
            end
        elseif learn:need_to_master("powersense") and API:status_ok() then
            send(f "powersense {target}")
            sent = true
        elseif learn:need_to_master("powerdown") or learn:need_to_master("powerup") and API:status_ok() then
            send("powerdown")
            send("powerup")
            sent = true
        elseif learn:need_to_master("scan") and API:status_ok() then
            send("scan")
            sent = true
        elseif learn:need_to_master("portal") and Player.Ki > (Player.MaxKi * .10) then
            local ptarget = table.sample_items(instant_targets)
            send(f "focus 'portal' {ptarget}")
            sent = true
        elseif learn:need_to_master("instant") and Player.Ki > 500 then
            local itarget = table.sample_items(instant_targets)
            send(f "focus 'instant' {itarget}")
            sent = true
        elseif Skills:mastered("machpunch") and Player.UBS < 100 and API:can_use_melee_attack("machpunch") then
            send(f "machpunch {target}")
            sent = true
        elseif Skills:mastered("machkick") and Player.LBS < 100 and API:can_use_melee_attack("machkick") then
            send(f "machkick {target}")
            sent = true
        end

        if sent == false and not API:is_rested() then
            -- Try to Rest
            if API:isAndroid() then
                State:set(State.REST)
                send("vent")
                send("repair")
            else
                State:set(State.SPEEDWALK)
                registerAnonymousEventHandler("sysSpeedwalkFinished", function()
                    State:set(State.REST)
                    send("sleep")
                end, true)
                speedwalk(speedwalk_path, false, 0.5)
            end
            return
        end

        local others = {"powersense", "powerup", "powerdown", "portal", "instant", "scan"}
        if sent == false and learned == 0 and Player.UBS == 100 and Player.LBS == 100 then
            -- check others
            local all_done = true
            for _, v in ipairs(others) do
                if learn:need_to_master(v) then
                    all_done = false
                end
            end
            if all_done then
                -- Lets turn on zeta on the target
            end
        end

        -- If we didn't do anything we are probably done.
    elseif State:is(State.REST) then
        -- WE are resting
        -- If we are a android do nothing, the triggers will take us out of rest
        if not API:isAndroid() and API:is_rested() then
            State:set(State.SPEEDWALK)
            send("wake")
            registerAnonymousEventHandler("sysSpeedwalkFinished", function()
                State:set(State.NORMAL)
            end, true)
            speedwalk(speedwalk_path, true, 0.5)
        end
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
    send("learn")
    -- Change Mode
    Mode:switch(Mode.Learning, exit)
    -- Clear out all state
    learn.state = {}
    learn.to_learn = {
        set = false
    }
    learn.gravity = 0

    -- Install a timer
    registerNamedTimer("__PKGNAME__", "CK:Learning", 4, do_learning, true)
end

function learn:maybe_adjust_gravity()
    local new_grav = API:get_gravity()
    if Room.Gravity < new_grav then
        send(f "adjust {new_grav}")
    end
end

function learn:setup_skills()
    local to_learn = self.to_learn
    -- figure out what we should learn
    to_learn.set = true
    to_learn.energy = Skills:filter_mastered(Skills:energy_attacks())
    to_learn.melee = Skills:filter_mastered(Skills:melee_attacks())
    to_learn.aoe = Skills:filter_mastered(Skills:AoE())
    to_learn.buffs = Skills:filter_mastered(Skills:buffs())
    to_learn.heals = Skills:filter_mastered(Skills:heals())
    to_learn.ultras = Skills:filter_mastered(Skills:ultras())
    to_learn.learnable = Skills:learnable()

    return self:count_to_learn()
end

function learn:need_to_master(name)
    -- If its learned and not mastered
    return Skills:learned(name) and not Skills:mastered(name)
end

function learn:count_to_learn()
    local to_learn = self.to_learn
    if to_learn.set then
        return (#(to_learn.energy) + #(to_learn.melee) + #(to_learn.aoe) + #(to_learn.buffs) + #(to_learn.heals) +
                   #(to_learn.ultras) + #(to_learn.learnable))
    end
    return -1
end

function learn:toggle(target, path)
    self.target = target
    self.speedwalk = path
    if Mode:is(Mode.Learning) then
        Mode:switch(Mode.Interactive)
        print("Learning Mode Disabled!!!")
    else -- Its off
        local is_android = API:isAndroid()
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
