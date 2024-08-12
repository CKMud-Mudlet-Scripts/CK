-- This runs when ever we make the transition from fighting to not fighting
local fried = require("__PKGNAME__.fried")
local Times = fried:get_table("API.Times")
local Toggles = fried:get_table("Toggles")


Times:create("lastfight")

function onFinishedFighting()
  Toggles.meleefighting = false
  Times:reset("fightfinished")
  Toggles.NEXTHT = nil
  cecho("\n<red>Fight Finished!")
end