-- This runs when ever we make the transition from fighting to not fighting
local ck = require("__PKGNAME__.ck")
local Times = ck:get_table("API.Times")
local Toggles = ck:get_table("Toggles")


Times:create("lastfight")

function onFinishedFighting()
  Toggles.meleefighting = false
  Times:reset("fightfinished")
  Toggles.NEXTHT = nil
  cecho("\n<red>Fight Finished!")
end