combo_graph =
  {
    ["punch"] =
      {
        ["punch"] = {["punch"] = "Pummel", ["uppercut"] = {["wolf"] = "W.F. Storm"}},
        ["kick"] = {["punch"] = {["uppercut"] = {["roundhouse"] = "Meteor Rush"}}},
      },
    ["kick"] =
      {
        ["kick"] = {["kick"] = "MG Kick"},
        ["roundhouse"] = {["dynamite kick"] = {["dynamite kick"] = "Dyna Crush"}},
      },
    ["mach punch"] = {["mach kick"] = {["mach punch"] = "Mach Flurry"}},
  }

function next_combo(combo_test)
  local combo_test = combo_test or Player.COMBO
  local head = combo_graph
  if combo_test then
    for i, v in ipairs(combo_test) do
      if head[v] then
        head = head[v]
      else
        echo("Not sure what " .. v .. " is!")
        return nil
      end
    end
  end
  if type(head) == "string" then
    echoc("<red>" .. head)
  else
    -- Return the next key at random
    --echo("Current Head")
    --display(head)
    local next_attack = random_elem(head)
    --display(next_attack)
    return string.gsub(next_attack, " ", "")
  end
end

function combo(who)
  if Player.COMBO then
    if last_combo_id ~= COMBO_ID then
      last_combo_id = COMBO_ID
      send("--")
    end
    local attack = next_combo()
    --echo("Next Attack: ")
    --display(attack)
    if who then
      send(attack .. " " .. who)
    else
      send(attack)
    end
    Times.lastcombo = getEpoch()
  else
    local next_fight = next_combo()
    if who then
      send(next_fight .. " " .. who)
    else
      send(next_fight)
    end
    Times.lastcombo = getEpoch()
  end
end