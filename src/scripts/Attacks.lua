local ck = require("__PKGNAME__")
local API = ck:get_table("API")
local UBS = true
local LBS = false

local function add_melee(name, cost, dmg, is_ubs, cooldown, count, extra)
  API:add_attack(name, cost, dmg, is_ubs, cooldown, count, extra)
end
local function add_energy(name, cost, dmg, cooldown, count, extra)
  API:add_attack(name, cost, dmg, nil, cooldown, count, extra)
end

--[[
  fast - 20% no cooldown chance
  piercing - ignore 20% armor

  Use daze for stun
]]
local Extras = ck:get_table("API.Attacks.Extras",
  ck:make_enum("Extras",
    { "knockdown", "burn", "bleed", "daze", "fast", "piercing", "piercing_major", "piercing_minor", "deep_penetration",
      "fast30", "shock", "heal", "poison", "rest" }))
-- % damage  * (1+([UBS or LBS] / 100) / 4)

-- Piercing = 15/20/25
-- Piercing_major +5%
-- Piercing_minor -5%
-- deep_penetration +10%

-- rest and heal, for things that can reduce fatigue or heal the caster

--
-- Melee Attacks - add_melee(name, cost, dmg, is_ubs, cooldown, count, extra)
--

-- Starting Melee Attacks
add_melee("punch", 3, 0.125, UBS)
add_melee("kick", 3, 0.125, LBS)
add_melee("roundhouse", 4, 0.25, LBS, 2)
add_melee("sweep", 5, 0.25, LBS, 1, 1, { Extras.knockdown })
add_melee("uppercut", 4, 0.25, UBS, 2)

-- discoverable
add_melee('machpunch', 4, 0.30, UBS, 1, 1, { Extras.fast })
add_melee('machkick', 4, 0.30, LBS, 1, 1, { Extras.fast })
add_melee("justice", 12, 0.80, LBS, 2, 4, { Extras.piercing })
add_melee("supergodfist", 12, 2.25, UBS, 2, 1, { Extras.piercing, Extras.piercing_major })

-- Mob taught
add_melee("dynamite", 5, 0.60, LBS, 2)
add_melee("wolf", 6, 0.10, UBS, 2, 8)

-- Mentor taught
add_melee("heel", 6, 0.80, LBS, 2, 1, { Extras.daze })
add_melee("braver", 6, 0.80, UBS, 2, 1, { Extras.bleed })
add_melee("cyclone", 6, 0.40, LBS, 2, 3, { Extras.daze })
add_melee("rage", 8, 0.50, UBS, 2, 4, { Extras.bleed })
add_melee("dpunch", 8, 0.90, UBS, 2, 1, { Extras.daze })
add_melee("godfist", 12, 1.25, UBS, 2, 1, { Extras.piercing, Extras.piercing_minor })

-- Android Melee
add_melee("accel", 8, 0.60, LBS, 2, 3, { Extras.piercing, Extras.piercing_major })

-- BioDroid Racial
add_melee("bioimp", 8, 0.85, UBS, 1, 1, { Extras.daze })

-- Demon Racial
add_melee("nether", 6, 1.00, UBS, 2, 1, { Extras.heal })
add_melee("shadow", 5, 0.75, UBS, 1, 1, { Extras.piercing, Extras.deep_penetration })

-- Majin Racial
add_melee("mysticb", 8, 0.45, UBS, 2, 6, { Extras.piercing, Extras.piercing_major })

-- Human Racial
add_melee("shockwave", 8, 1.25, LBS, 2, 1, {Extras.shock})

-- Konatsu Racial
add_melee("moonlight", 4, 0.6, UBS, 1, 1, {Extras.piercing})
add_melee("zephyr", 4, 0.35, UBS, 2, 5, {Extras.bleed})

--
-- KI Attacks - add_energy(name, cost, dmg, cooldown, count, extra)
--

-- Starting Ki
add_energy("kishot", 2, 0.2, 1, 1, { Extras.fast })

-- Mentor Ki Attacks
add_energy("eyebeam", 3, 0.2, 1, 1, { Extras.fast30, Extras.fast })
add_energy("kame", 20, 0.35)
add_energy("kienzan", 30, 0.5, 1, 1, { Extras.bleed })
add_energy("bigbang", 60, 0.65, 2, 4)
add_energy("makan", 60, 0.85, 2, 3)
add_energy("chou", 60, 0.60, 2, 4)
add_energy("sblast", 100, 0.75, 1, 1, { Extras.burn })


-- Discoverable
add_energy("superk", 50, 0.65)
add_energy("superbb", 160, 0.8, 2, 4)
add_energy("warp", 240, 0.75, 2, 3, { Extras.daze })
add_energy("genki", 300, 1.25, 3, 4, { Extras.piercing, Extras.piercing_major, Extras.deep_penetration })
add_energy("finalk", 1000, 3.0, 2)
add_energy("hakai", 500, 1.35, 2, 1, { Extras.piercing, Extras.piercing_major })

-- Mob Taught
add_energy("galick", 30, 0.50)
add_energy("noxious", 100, 0.75, 1, 1, { Extras.poison })

-- Majin Racial Ki
add_energy("vanish", 60, 0.70)
add_energy("supervb", 160, 0.85, 2, 3)
add_energy("chocolate", 20, 0.35, 1)
add_energy("calamity", 250, 1.0, 2, 1, { Extras.burn })

-- Sphinxian Racial Ki
add_energy("cataclysmic", 25, 0.5, 1, 1, { Extras.piercing, Extras.piercing_major })

-- Icer Racial Ki
add_energy("deathsaucer", 200, 0.9, 2, 4, { Extras.bleed })
add_energy("deathball", 60, 0.6, 2, 5)
add_energy("emperor", 400, 1.0, 2, 5, { Extras.piercing, Extras.piercing_major, Extras.deep_penetration })


-- Namekian Racial Ki
add_energy("special", 250, 1.25, 2, 3, { Extras.piercing, Extras.piercing_major, Extras.deep_penetration })

-- Demon Racial Ki
add_energy("stonespit", 40, 0.35, 1, 1, { Extras.daze })
add_energy("evilblast", 50, 0.5, 1, 1, { Extras.burn })
add_energy("soulreaver", 300, 1.30, 2, 1, { Extras.rest })
add_energy("hellfire", 300, 1.15, 2, 4, { Extras.burn, Extras.piercing })

-- Android Racial Ki
add_energy("photon", 40, 0.55)
add_energy("disrupt", 100, 0.75, 1, 1, { Extras.daze })
add_energy("eclipse", 250, 1.5, 2, 1, { Extras.shock })

-- BioDroid Racial KI
add_energy("deathbeam", 4, 0.3, 1, 1, { Extras.fast, Extras.piercing, Extras.piercing_minor })
add_energy("perfect", 60, 0.7, 1)
add_energy("pgenki", 500, 0.8, 2, 5, { Extras.piercing, Extras.piercing_major, Extras.deep_penetration })

-- BioDroid Absorb
add_energy("spiritcannon", 100, 0.4, 1, 1, { Extras.heal })
add_energy("dsphere", 100, 0.90)
add_energy("doublesunday", 30, 0.6, 1, 1, { Extras.daze })

-- Human Racial
add_energy("neotri", 250, 1.5, 2, 1, {Extras.burn})