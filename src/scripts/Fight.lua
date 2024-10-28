local ck = require("__PKGNAME__")
local Attacks = ck:get_table("Player.Attacks")
local Skills = ck:get_table("API.Skills")
local Player = ck:get_table("Player")
local API = ck:get_table("API")
local Extras = ck:get_table("API.Attacks.Extras")

function API:get_attack_dpr(name)
    -- Boil down each attack into a single metric so we can sort them
    local data = Attacks[name]
    if data == nil then
        return nil
    end
    local adj_dmg
    local is_melee = data[3] ~= nil
    if is_melee then
        local phy_dam = API:phy_dam(Player.Skills.Supreme[name], Player.Skills.Boosted[name],
            Player.Skills.Ultimate[name]) * data[2]
        local body = Player.LBS
        if data[3] then
            body = Player.UBS
        end
        adj_dmg = phy_dam * (1 + (body / 400)) * (Skills:level(name) / 100)
    else
        adj_dmg = API:ki_dam(Player.Skills.Supreme[name], Player.Skills.Boosted[name], Player.Skills.Ultimate[name]) *
            data[2] * (Skills:level(name) / 100)
        -- if is_melee
    end
    local avg_cooldown = data[4]
    local avg_count = (data[5] + 1) / 2
    local extra = data[6]

    if extra[Extras.fast30] then
        avg_cooldown = (data[4] + (data[4] - data[4] * 0.3)) / 2
    elseif extra[Extras.fast] then
        avg_cooldown = (data[4] + (data[4] - data[4] * 0.2)) / 2
    end

    if extra[Extras.daze] then
        -- Lets say daze is 65% the cooldown and 25% damage
        adj_dmg = adj_dmg * 1.25
        avg_cooldown = avg_cooldown * .65
    end
    if extra[Extras.bleed] then
        -- Bleed is complicated based on the victims PL, so lets just say its a +10%
        adj_dmg = adj_dmg * 1.10
    end
    if extra[Extras.piercing] then
        -- Lets just sat its a 5% boost since it reduces the targets armor, which might not
        -- be a whole lot
        adj_dmg = adj_dmg * 1.05
    end
    if extra[Extras.shock] then
        adj_dmg = adj_dmg * 1.05
    end
    -- This is average DPS per round
    return (adj_dmg * avg_count) / avg_cooldown
end

local function energy_cost(attack, _race)
    local data = Attacks[attack]
    if data == nil then
        cecho(f "<red>can_use_energy_attack: Unknown Attack {attack}!!!")
        return 100000000
    end
    if data[3] ~= nil then
        cecho(f "<red>can_use_energy_attack: Error Attack {attack} is a meleee attack!!!")
        return 100000000
    end

    if API:isBioDroid(_race) then
        return data[1] / 2
    end
    return data[1]
end

local function melee_cost(attack, _race)
    local data = Attacks[attack]
    if data == nil then
        cecho(f "<red>can_use_melee_attack: Unknown Melee {attack}!!!")
        return 10000000000
    end
    if data[3] == nil then
        cecho(f "<red>can_use_melee_attack: Error Attack {attack} is a energy attack!!!")
        return 10000000000
    end
    local cost = data[1]
    if API:has_fatigue(_race) then
        return cost
    elseif API:isAndroid(_race) then
        return cost * 2
    else
        return cost * 40
    end
end

function API:can_use_energy_attack(attack)
    return energy_cost(attack) < Player.Ki
end

function API:can_use_melee_attack(attack)
    local race = API:getRace()
    local cost = melee_cost(attack, race)

    if API:has_fatigue(race) then
        return cost < Player.Fatigue
    else
        return cost < Player.Ki
    end
end

-- { cost, dmg, is_ubs, cooldown or 1, count or 1, extra_dict }

-- Filter by Extras (takes list of attacks and extras list)
local function filter_by_extra(attacks, extras)
    local function has_extras(a_extras)
        for _, extra in ipairs(extras) do
            if not a_extras[extra] then
                return false
            end
        end
        return true
    end

    if #extras == 0 then
        return attacks
    end

    local ntable = {}
    for _, name in ipairs(attacks) do
        local data = Attacks[name]
        if has_extras(data[6]) then
            table.insert(ntable, name)
        end
    end
    return ntable
end

-- Filter by energy/physical
local function filter_by_kind(attacks, energy, physical)
    if energy and physical then
        return attacks
    end

    if not energy and not physical then
        -- maybe raise an error
        return {}
    end

    local ntable = {}
    for _, name in ipairs(attacks) do
        local data = Attacks[name]
        local is_physical = data[3] ~= nil
        local is_energy = data[3] == nil
        if is_energy and energy then
            table.insert(ntable, name)
        end
        if is_physical and physical then
            table.insert(ntable, name)
        end
    end
    return ntable
end

---@param target string
function API:cmd_fight(target, kws)
    -- options = { cheapest, energy, physical, extras }
    local defaults = { free_only = false, energy = true, physical = true, extras = {} }
    ---@diagnostic disable-next-line: undefined-field
    local options = table.update(defaults, kws)
    local race = API:getRace()

    if options.free_only and Player.KiRegen == nil then
        options.free_only = false
    end

    if options.free_only and options.energy and API:has_fatigue(race) then
        options.physical = false
    end
    
    if options.free_only and not options.energy and API:has_fatigue(race) then
        -- Not sure how to make this work for physical attacks for races with fatigue since nobody has fatigue regen. 
        options.free_only = false
    end

    -- Attack Names we can use filtering by the above constraints for energy/physical and extras
    local attacks = filter_by_kind(
        filter_by_extra(
            Skills:filter_unlearned(
            ---@diagnostic disable-next-line: undefined-field
                table.keys(Attacks)
            ),
            options.extras
        ),
        options.energy, options.physical
    )

    -- lets collect dpr for each of the remaining attacks
    local attack_dpr = {}
    for _, name in ipairs(attacks) do
        attack_dpr[name] = API:get_attack_dpr(name)
    end

    -- If free_only, only those that are below KiRegen


    -- Take top 3 or 4 at random
    -- send it
end

function API:cmd_blast(target)
    self:cmd_fight(target, { physical = false })
end

function API:cmd_strike(target)
    self:cmd_fight(target, { energy = false })
end
