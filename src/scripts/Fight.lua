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
    local phy_dam = API:phy_dam(Player.Skills.Supreme[name], Player.Skills.Boosted[name], Player.Skills.Ultimate[name]) * data[2]
    local body = Player.LBS
    if data[3] then
      body = Player.UBS
    end
    adj_dmg = phy_dam * (1 + (body / 400))
  else
    adj_dmg = API:ki_dam(Player.Skills.Supreme[name], Player.Skills.Boosted[name], Player.Skills.Ultimate[name]) * data[2]
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
