local ck = require("__PKGNAME__.ck")
local Player = ck:get_table("Player")
local State = ck:get_table("API.State")
local Times = ck:get_table("API.Times")
local Toggles = ck:get_table("Toggles")




function onNotFightingPrompt()
  Toggles.EnemyLineComboTest = true
  Toggles.skip_fight = nil

  if State:check(State.NORMAL, true) and Times:last("status") > 120 then
    send("status")
    Times:reset("status")
  end
  if State:check(State.NORMAL, true) and Times:last("score") > 240 then
    send("score")
    Times:reset("score")
  end
  if State:check(State.NORMAL, true) and Player.KI == 100 and Times:last("scouterself") > 900 then
    send("analyze self")
    Times:reset("scouterself")
  end
  -- Handle Send Queue
  ck:get_table("API.SendQueue"):trySendNow()
end