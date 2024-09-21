local ck = require("__PKGNAME__")
local Player = ck:get_table("Player")
local Toggles = ck:get_table("Toggles")
local learn = ck:get_table("API.Learning", {
    triggers = {}, gravity = 0, to_learn = {}
})
local Times = ck:get_table("API.Times")
local API = ck:get_table("API")
local State = ck:get_table("API.State")
local Mode = ck:get_table("API.Mode")
local PromptCounters = ck:get_table("PromptCounters")
local Skills = ck:get_table("API.Skills")

local instant_targets = { "gine", "roshi", "teragon", "malak", "bubbles", "cypher" }

---@diagnostic disable-next-line: unused-function
local function do_learning()
    if not API:is_connected() then
        -- Don't do anything unless we are connected and have a prompt
        return
    end
    local speedwalk = learn.speedwalk
    local target = learn.target

    if State:is(State.NORMAL) then
        local to_learn = learn.to_learn
        local learned = learn:setup_skills()
        if learned then
            -- Handle Primary Skills
            if #(to_learn.energy) and has_energy(to_learn.energy[1]) then
                send(f "{to_learn.energy[1]} {target}")
            elseif #(to_learn.melee) and has_fatigue(to_learn.melee[1]) then
                send(f "{to_learn.melee[1]} {target}")
            elseif #(to_learn.aoe) and aoe_ok() then
                send(f "{to_learn.aoe[1]}")
            elseif #(to_learn.buffs) and buff_ok() then
                send(f "focus '{to_learn.buffs[1]}'")
            elseif #(to_learn.heals) and heal_ok() then
                send(f "focus '{to_learn.heals[1]}'")
            elseif #(to_learn.ultras) and ultra_ok() then
                send(f "focus '{to_learn.ultras[1]}'")
            end
        else
            -- check learnables
            -- check powersense/suppress/etc
            -- check portal/instant 
        end
        -- We should be training a skill
    elseif State:is(State.Rest) then
        -- WE are resting
        -- If we are a android do nothing, the triggers will take us out of rest
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
    learn.to_learn = { set = false }
    learn.gravity = 0

    -- Install a timer
    registerNamedTimer("__PKGNAME__", "CK:Learning", 0.5, do_learning, true)
end

function learn:maybe_adjust_gravity()
    local new_grav = API:get_gravity()
    if self.gravity < new_grav then
        send(f "adjust {new_grav}")
        self.gravity = new_grav
    end
end

function learn:setup_skills()
    local to_learn = self.to_learn
    -- figure out what we should learn
    to_learn.set = true
    to_learn.energy = Skills:filter_mastered(Skills:energy_attacks())
    to_learn.melee = Skills:filter_mastered(Skills:melee_attacks())
    to_learn.aoe = Skills:filter_mastered(Skills:Aoe())
    to_learn.buffs = Skills:filter_mastered(Skills:buffs())
    to_learn.heals = Skills:filter_mastered(Skills:heals())
    to_learn.ultras = Skills:filter_mastered(Skills:ultras())

    return self:count_to_learn()
end

function learn:count_to_learn()
    local to_learn = self.to_learn
    if to_learn.set then
        return (
            #(to_learn.energy)
            + #(to_learn.melee)
            + #(to_learn.aoe)
            + #(to_learn.buffs)
            + #(to_learn.heals)
            + #(to_learn.ultras)
        )
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
