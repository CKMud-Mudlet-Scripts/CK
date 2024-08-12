local fried = require("__PKGNAME__.fried")
local PromptFlags = fried:get_table("PromptFlags")
local State = fried:get_table("API.State")
local Times = fried:get_table("API.Times")
local Toggles = fried:get_table("Toggles")
local API = fried:get_table("API")

function onFightingPrompt(val)
  if Times:last("fight") > 2 and PromptFlags.fighting then
    if not Toggles.no_fight then
        API:cmd_fight(nil)
    end
  end
  if
    State:check(State.CRAFTING, true) or State:check(State.BUFFING, true) or State:check(State.SENSE, true)
  then
    State:check(State.NORMAL)
  end
end