local ck = require("__PKGNAME__")
local Data = ck:get_table("Player.Skills", {
    Level = {},
    Learned = {},
    Mastered = {},
    Boosted = {},
    Supreme = {},
    Ultimate = {},
    Sections = {
        AoE = {},
        Focus = {},
        Ki = {},
        Other = {},
        Physical = {}
    }
})
local Skills = ck:get_table("API.Skills") -- CK.API.Skills:mastered
local Player = ck:get_table("Player")
local API = ck:get_table("API")

function Skills:clear()
    Data.Level = {}
    Data.Learned = {}
    Data.Mastered = {}
    Data.Boosted = {}
    Data.Supreme = {}
    Data.Ultimate = {}
    Data.Sections = {
        AoE = {},
        Focus = {},
        Ki = {},
        Other = {},
        Physical = {}
    }
end

-- This should be a full list of abilities
local fullname_to_cmd = {
    ["whirlwind"] = "whirl",
    ["scatter shot"] = "scatter",
    ["mach punch"] = "machpunch",
    ["mach kick"] = "machkick",
    ["super big bang"] = "superbb",
    ["super kamehameha"] = "superk",
    ["spirit blast"] = "sblast",
    ["rage saucer"] = "rage",
    ["disruptor beam"] = "disrupt",
    ["braver strike"] = "braver",
    ["big bang"] = "bigbang",
    ["eye beam"] = "eyebeam",
    ["photon wave"] = "photon",
    ["dragon punch"] = "dpunch",
    ["renzokou energy dan"] = "renzo",
    ["final flash"] = "final",
    ["final kamehameha"] = "finalk",
    ["warp kamehameha"] = "warp",
    ["instant trans"] = "instant",
    ["hellsflash"] = "hells",
    ["justice blitz"] = "justice",
    ["cyclone kick"] = "cyclone",
    ["super godfist"] = "supergodfist",
    ["heel stomp"] = "heel",
    ["wolf fang fist"] = "wolf",
    ["chou kamehameha"] = "chou",
    ["spirit bomb"] = "genki",
    ["dynamite kick"] = "dynamite",
    ["suppression"] = "sup",
    ["kamehameha"] = "kame",
    ["makankosappo"] = "makan",
    ["void wave"] = "void",
    ["evil blast"] = "evilblast",
    ["perfect kamehameha"] = "perfect",
    ["galick gun"] = "galick",
    ["destruction sphere"] = "dsphere",
    ["perfect spirit bomb"] = "pgenki",
    ["spirit cannon"] = "spiritcannon",
    ["special beam blast"] = "special",
    ["hellfire blitz"] = "hellfire",
    ["bio impact"] = "bioimp",
    ["nether fist"] = "nether",
    ["vanishing ball"] = "vanish",
    ["cataclysmic orb"] = "cataclysmic",
    ["super vanishing ball"] = "supervb",
    ["hakai blast"] = "hakai",
    ["shadow strike"] = "shadow",
    ["soul reaver"] = "soulreaver",
    ["accel driver"] = "accel",
    ["eclipse bomb"] = "eclipse",
    ["chocolate beam"] = "chocolate",
    ["extinction rain"] = "extinct",
    ["calamity blaster"] = "calamity",
    ["mystic ball"] = "mysticb",
    ["emperor death ball"] = "emperor", -- typo maybe
    ["emperor deathball"] = "emperor",
    ["death saucer"] = "deathsaucer",
    ["shockwave kick"] = "shockwave",
    ["neo tri-beam"] = "neotri",
    ["moonlight pierce"] = "moonlight",
    ["zephyr slice"] = "zephyr",
    ["nova symphony"] = "nova",
    ["death storm"] = "deathstorm",
}

local known_buffs = { "demonic will", "energy shield", "barrier", "hasshuken", "herculean force", "resonance",
    "zanzoken", "kino tsurugi", "regenerate", "forcefield", "infravision", "celestial shield",
    "celestial drain", "invigorate", "swiftness", "gigantification", "wrathful fury",
    "divine judgement", "hakai barrier", "tremor pulse" }

local learnable_aoe = { "final", "scatter", "whirl" }

function Skills:translate(raw)
    -- Get the short_name from long name
    local lraw = string.lower(raw)
    local cmd_name = fullname_to_cmd[lraw]
    if cmd_name ~= nil then
        return cmd_name
    end
    return raw
end

function Skills:mastered(skill)
    return Data.Mastered[skill] == true
end

function Skills:learned(skill)
    return Data.Learned[skill] == true
end

function Skills:boosted(skill)
    return Data.Boosted[skill] == true
end

function Skills:supreme(skill)
    return Data.Supreme[skill] == true
end

function Skills:ultimate(skill)
    return Data.Ultimate[skill] == true
end

function Skills:level(skill)
    return Data.Level[skill]
end

function Skills:learnable()
    local race = API:getRace()
    -- Dict [ Learnable Skill name ] = {How to Learn, Prereq skills}
    local adict = {
        scatter = { "kishot" },
        warp = { "superk", "instant" },
        superbb = { "bigbang" },
        superk = { "kame" },
        machpunch = { "punch" },
        machkick = { "kick" },
        supervb = { "vanish" },
        shadow = { "nether", "soulreaver", "portal" },
        hellfire = { "finalk", "justice", "shadow" },
        eclipse = { "finalk", "disrupt" },
        accel = { "justice", "instant", "whirl" },
        calamity = { "finalk", "supervb" },
        emperor = { "deathball", "deathbeam", "deathsaucer" },
        deathstorm = {"tailwhip", "emperor"},
    }
    if Player.BasePl > 125000000 then
        adict["finalk"] = { "warp", "final" }
        adict["justice"] = { "cyclone", "dynamite", "rage" }
        adict["supergodfist"] = { "godfist", "wolf", "dpunch" }
    end

    if API:isBioDroid(race) then
        adict["pgenki"] = { "genki", "finalk", "perfect" }
        adict["bioimp"] = { "supergodfist", "nether" }
    end

    if race == "Majin" then
        adict["mysticb"] = { "supergodfist", "justice" }
    end

    if race == "Human" then
        adict["shockwave"] = { "justice", "roundhouse" }
        adict["neotri"] = { 'finalk', 'kikoho' }
    end

    if API:isGodRace(race) then
        adict["hakai"] = { "finalk", "hakai barrier" }
    end

    local Mastered = Data.Mastered
    local Learned = Data.Learned
    local nlist = {}
    -- k = skill to learn,  v is table each element must be mastered but first item is learn command
    for k, v in pairs(adict) do
        if Learned[k] ~= true then
            local all_reqs = true
            for _, v1 in ipairs(v) do
                if Mastered[v1] ~= true then
                    all_reqs = false
                    break
                end
            end
            if all_reqs then
                table.insert(nlist, v[1])
            end
        end
    end
    return nlist
end

function Skills:filter(alist, must_be_learned)
    local Mastered = Data.Mastered
    local Learned = Data.Learned
    if must_be_learned == nil then
        must_be_learned = false
    end
    local nlist = {}
    for i, v in ipairs(alist) do
        if Mastered[v] ~= true and (not must_be_learned or Learned[v] == true) then
            table.insert(nlist, v)
        end
    end
    return nlist
end

function Skills:filter_unlearned(alist)
    local Learned = Data.Learned
    local nlist = {}
    for i, v in ipairs(alist) do
        if Learned[v] then
            table.insert(nlist, v)
        end
    end
    return nlist
end

function Skills:filter_mastered(alist)
    local Mastered = Data.Mastered
    local nlist = {}
    for i, v in ipairs(alist) do
        if not Mastered[v] then
            table.insert(nlist, v)
        end
    end
    return nlist
end

registerNamedEventHandler("__PKGNAME__", "CK:SkillsReLoad", "CK.onPlayerReload", function(event)
    send("learn")
end)

function Skills:heals()
    local alist = {}
    local words = { "revitalize", "restoration" }
    for _, v in ipairs(Data.Sections.Focus) do
        ---@diagnostic disable-next-line: undefined-field
        if table.contains(words, v) or v:find("heal", 1, true) then
            table.insert(alist, v)
        end
    end
    return alist
end

function Skills:buffs()
    local alist = {}
    for _, v in ipairs(known_buffs) do
        if self:learned(v) then
            table.insert(alist, v)
        end
    end
    return alist
end

function Skills:AoE()
    local ret = {}
    for _, v in ipairs(learnable_aoe) do
        if self:learned(v) then
            table.insert(ret, v)
        end
    end
    ---@diagnostic disable-next-line: undefined-field
    return table.n_union(ret, Data.Sections.AoE)
end

function Skills:energy_attacks()
    local ret = {}
    for k, v in pairs(Player.Attacks) do
        if self:learned(k) and v[3] == nil then
            table.insert(ret, k)
        end
    end
    ---@diagnostic disable-next-line: undefined-field
    return table.n_union(ret, Data.Sections.Ki)
end

function Skills:melee_attacks()
    local ret = {}
    for k, v in pairs(Player.Attacks) do
        if self:learned(k) and v[3] ~= nil then
            table.insert(ret, k)
        end
    end
    ---@diagnostic disable-next-line: undefined-field
    return table.n_union(ret, Data.Sections.Physical)
end

function Skills:ultras()
    local ultra1 = 'ultra instinct'
    local ultra2 = 'ultra ego'
    local alist = {} -- Even tho mortals can only have 1
    if self:learned(ultra1) then
        table.insert(alist, ultra1)
    end
    if self:learned(ultra2) then
        table.insert(alist, ultra2)
    end
    return alist
end
