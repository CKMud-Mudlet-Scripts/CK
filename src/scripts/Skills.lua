local ck = require("__PKGNAME__")
local Data = ck:get_table("Player.Skills", {
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
local Attacks = ck:get_table("Player.Attacks")
local Skills = ck:get_table("API.Skills") -- CK.API.Skills:mastered
local Player = ck:get_table("Player")

function Skills:clear()
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
    ["perfect spirit bomb"] = "pgenki"
}

local known_buffs = {"demonic will", "energy shield", "barrier", "hasshuken", "herculean force", "resonance",
                     "zanzoken", "kino tsurugi", "regenerate", "forcefield", "infravision", "celestial shield",
                     "celestial drain", "invigorate", "swiftness", "gigantification", "wrathful fury",
                     "divine judgement", "hakai barrier", "tremor pulse"}

local learnable_aoe = {"final", "scatter", "whirl"}

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

function Skills:learnable()
    race = API:getRace()
    local adict = {
        ["scatter"] = {"kishot"},
        ["warp"] = {"superk", "instant"},
        ["superbb"] = {"bigbang"},
        ["superk"] = {"kame"},
        ["machpunch"] = {"punch"},
        ["machkick"] = {"kick"}
    }
    if Player.BasePl > 125000000 then
        adict["finalk"] = {"warp", "final"}
        adict["justice"] = {"cyclone", "dynamite", "rage"}
        adict["supergodfist"] = {"godfist", "wolf", "dpunch"}
        adict["accel"] = {"justice", "instant", "whirl"}
        adict["eclipse"] = {"finalk", "disrupt"}
    end

    if API:isBioDroid(race) then
        adict["pgenki"] = {"genki", "finalk", "perfect"}
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
    local words = {"revitalize", "restoration"}
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
    return table.n_union(ret, Data.Sections.AoE)
end

function Skills:energy_attacks()
    local ret = {}
    for k, v in pairs(Player.Attacks) do
        if self:learned(k) and v[3] == nil then
            table.insert(ret, k)
        end
    end
    return table.n_union(ret, Data.Sections.Ki)
end

function Skills:melee_attacks()
    local ret = {}
    for k, v in pairs(Player.Attacks) do
        if self:learned(k) and v[3] ~= nil then
            table.insert(ret, k)
        end
    end
    return table.n_union(ret, Data.Sections.Physical)
end

function Skills:ultras()
    local ultra1 = 'ultra instinct'
    local ultra2 = 'ultra ego'
    local alist = {} -- Even tho mortals can only have 1
    if self.learned(ultra1) then
        table.insert(alist, ultra1)
    end
    if self.learned(ultra2) then
        table.insert(alist, ultra2)
    end
    return alist
end
