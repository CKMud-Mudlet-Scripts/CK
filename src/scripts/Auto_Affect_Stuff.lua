local fried = require("__PKGNAME__.fried")
local Skills = fried.get_table("API.Skills") -- FRIED.API.Skills:mastered

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

function handleBuffs(seen)
  for _, affect in ipairs(Skills:filter_unlearned(list_of_affects)) do
    if not seen[affect] and is_state(State.NORMAL, true) then
      cecho(f"\n<cyan>Performing Rebuff: {affect}")
      focus_buff(affect)
    end
  end
end

function focus_buff(affect)
  send(f"focus '{affect}'")
end
