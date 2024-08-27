local ck = require("__PKGNAME__.ck")
local Skills = ck:get_table("API.Skills") -- CK.API.Skills:mastered
local API = ck:get_table("API") -- CK.API more public
local Affects = ck:get_table("API.Affect") -- less public
local State = ck:get_table("API.State")

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
  "invigorate",
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
