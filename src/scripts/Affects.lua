local fried = require("__PKGNAME__.fried")
local Skills = fried:get_table("API.Skills") -- FRIED.API.Skills:mastered
local API = fried:get_table("API") -- FRIED.API more public
local Affects = fried:get_table("API.Affect") -- less public
local State = fried:get_table("API.State")

local list_of_affects = {
  "demonic will", 
  "energy shield", 
  "barrier", 
  "hasshuken", 
  "herculean force", 
  "resonance",
  "zanzoken", 
  "kino tsurugi", 
  "regenerate",
  "forcefield",
  "infravision",
  "celestial shield",
  "celestial drain",
}

function Affects:rebuff(seen)
  for _, affect in ipairs(Skills:filter_unlearned(list_of_affects)) do
    if not seen[affect] and State:check(State.NORMAL, true) then
      cecho(f"\n<cyan>Performing Rebuff: {affect}")
      API:focus(affect)
    end
  end
end

function API:focus(affect)
  send(f"focus '{affect}'")
end
