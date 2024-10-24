local ck = require("__PKGNAME__")
local Attacks = ck:get_table("Player.Attacks")
local Extras = ck:get_table("API.Attacks.Extras")
local Player = ck:get_table("Player")
local API = ck:get_table("API")

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
        adj_dmg = phy_dam * (1 + (body / 400))
    else
        adj_dmg = API:ki_dam(Player.Skills.Supreme[name], Player.Skills.Boosted[name], Player.Skills.Ultimate[name]) *
                      data[2]
        -- if is_melee
    end
    local avg_cooldown = data[4]
    local avg_count = (data[5] + 1) / 2
    local extra = data[6]
    if extra[Extras.fast] then
        avg_cooldown = (data[4] + (data[4] - data[4] * 0.2)) / 2
    end
    if extra[Extras.fast30] then
        avg_cooldown = (data[4] + (data[4] - data[4] * 0.3)) / 2
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

function API:can_use_energy_attack(attack)
    local data = Attacks[attack]
    if data == nil then
        cecho(f "<red>can_use_energy_attack: Unknown Attack {attack}!!!")
        return false
    end
    if data[3] ~= nil then
        cecho(f "<red>can_use_energy_attack: Error Attack {attack} is a meleee attack!!!")
        return false
    end
    if API:isBioDroid() then
        return (data[1] / 2) < Player.Ki
    else
        return data[1] < Player.Ki
    end
end

function API:can_use_melee_attack(attack)
    local data = Attacks[attack]
    if data == nil then
        cecho(f "<red>can_use_melee_attack: Unknown Melee {attack}!!!")
        return false
    end
    if data[3] == nil then
        cecho(f "<red>can_use_melee_attack: Error Attack {attack} is a energy attack!!!")
        return false
    end
    local cost = data[1]
    local race = API:getRace()
    if API:has_fatigue(race) then
        return cost < Player.Fatigue
    elseif API:isAndroid() then
        return cost * 2 < Player.Ki
    else
        return cost * 40 < Player.Ki
    end
end

-- { cost, dmg, is_ubs, cooldown or 1, count or 1, extra_dict }

local Extras = ck:get_table("API.Attacks.Extras") 

function API:cmd_fight(target, kws)
    -- options = { cheapest, energy, physical, extras }
    local defaults = {cheapest=false, energy=true, physical=true, extras = {}}
    local options = table.update(defaults, kws)
    
end

function API:cmd_blast(target)
    self:cmd_fight(target, {physical=false})
end

function API:cmd_strike(target)
    self:cmd_fight(rarget, {energy=false})
end