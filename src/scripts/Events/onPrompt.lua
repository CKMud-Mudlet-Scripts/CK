--This even Fires every single Prompt
local fried = require("__PKGNAME__.fried")
local Player = fried:get_table("Player")
local PromptFlags = fried:get_table("PromptFlags")
local PromptCounters = fried:get_table("PromptCounters")
local State = fried:get_table("API.State")
local Affects = fried:get_table("API.Affects")
local Toggles = fried:get_table("Toggles")
local Timers = fried:get_table("Timers")

local function decPromptCounters()
  for k, v in pairs(PromptCounters) do
    if v ~= nil then
      if v <= 1 then
        PromptCounters[k] = nil
      elseif v ~= nil then
        PromptCounters[k] = v - 1
      end
    end
  end
end

local function isPromptCounterActive(name)
  return PromptCounters[name] ~= nil
end

local function clearFlags()
  -- get_table means everyone has a ref to the table in their local
  -- so we set all the keys to null
  local klist = {}
  for key, _ in pairs(PromptFlags) do
    table.insert(klist, key)
  end
  for _, key in ipairs(PromptFlags) do
    PromptFlags[key] = nil
  end
end

function onPrompt()
  -- Lets make sure we get a prompt on a regular cadence
  if Timers.forceprompt ~= nil then
    killTimer(Timers.forceprompt)
    Timers.forceprompt = nil
  end
  Timers.forceprompt =
      tempTimer(
        30,
        function()
          send("score")
        end
      )
  if not Player.HT then
    Toggles.NEXTHT = nil
  end
  -- Things that had not been set since last prompt maybe we can clear
  if Toggles.fighting and not isPromptCounterActive('fighting') then
    Toggles.fighting = false
    raiseEvent("onFinishedFighting")
  end
  -- Lets handle fighting and non fighting stuff
  if Toggles.fighting then
    raiseEvent("onFightingPrompt")
  else
    raiseEvent("onNotFightingPrompt")
  end
  -- Handle Buffs before we clear flags
  if PromptFlags.affections and State:check(State.NORMAL, true) then
    Affects:rebuff(PromptFlags.affects)
  end
  -- All flags since last prompt should be cleared so next prompt we can take action
  clearFlags()
  decPromptCounters()
end
