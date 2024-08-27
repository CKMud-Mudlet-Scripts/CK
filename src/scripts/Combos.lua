local ck = require("__PKGNAME__.ck")
local ROOT = ck:get_table()
local Player = ck:get_table("Player")
local API = ck:get_table("API")
local Combo = ck:get_table("API.Combo")
local Times = ck:get_table("API.Times")
local Skills = ck:get_table("API.Skills")

Times:create("combo")

local combo_graph =
{
  ["punch"] =
  {
    ["punch"] = { ["punch"] = "Pummel", ["uppercut"] = { ["wolf"] = "W.F. Storm" } },
    ["kick"] = { ["punch"] = { ["uppercut"] = { ["roundhouse"] = "Meteor Rush" } } },
  },
  ["kick"] =
  {
    ["kick"] = { ["kick"] = "MG Kick" },
    ["roundhouse"] = { ["dynamite kick"] = { ["dynamite kick"] = "Dyna Crush" } },
  },
  ["mach punch"] = { ["mach kick"] = { ["mach punch"] = "Mach Flurry" } },
}

function Combo:next(combo_test)
  local combo_test = combo_test or Player.COMBO
  local head = combo_graph
  if combo_test then
    for i, v in ipairs(combo_test) do
      if head[v] then
        head = head[v]
      else
        echo(f "Not sure what {v} is!")
        return nil
      end
    end
  end
  if type(head) == "string" then
    cecho(f "<red>{head}")
  else
    -- Return the next key at random
    --echo("Current Head")
    --display(head)
    local next_attack = table.sample_keys(head)
    --display(next_attack)
    return string.gsub(next_attack, " ", "")
  end
end

function API:cmd_combo(who)
  who = who or ""
  if Player.COMBO then
    if ROOT.last_combo_id ~= ROOT.COMBO_ID then
      ROOT.last_combo_id = ROOT.COMBO_ID
      send("--")
    end
  end
  local attack = Combo:next()
  if Skills:learned(Skills:translate(attack)) then
    send(f "{attack} {who}")
  else
    cecho(f "<red>Combo {attack} is not learned yet!")
  end
  Times:reset("combo")
end
