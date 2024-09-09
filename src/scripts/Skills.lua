local ck = require("__PKGNAME__")
local Data = ck:get_table("Player.Skills", {Learned = {}, Mastered = {}, Boosted = {}, Supreme={}, Sections = {}})
local Skills = ck:get_table("API.Skills") -- CK.API.Skills:mastered

function Skills:clear()
  Data.Learned = {}
  Data.Mastered = {}
  Data.Boosted = {}
  Data.Supreme = {}
  Data.Sections = {}
end

-- This should be a full list of abilities
local fullname_to_cmd =
  {
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
    ["taiyoken"] = "solarflare",
    ["suppression"] = "sup",
    ["kamehameha"] = "kame",
    ["makankosappo"] = "makan",
    ["unravel defense"] = "unravel",
    ["void wave"] = "void",
    ["evil blast"] = "evilblast",
    ["ethereal blade"] = "ethereal",
    ["perfect kamehameha"] = "perfect",
  }


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

function Skills:filter_learnable(adict)
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

registerNamedEventHandler("__PKGNAME__", "CK:SkillsReLoad", "CK.onPlayerReload", function (event)
  send("learn")
end)