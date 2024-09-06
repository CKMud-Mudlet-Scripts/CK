local ck = require("__PKGNAME__")
local Skills = ck:get_table("API.Skills") -- CK.API.Skills:mastered
local API = ck:get_table("API") -- CK.API more public
local Affects = ck:get_table("API.Affects") -- less public
local State = ck:get_table("API.State")

ck:define_feature("auto_hakai", false)

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

if API:feature("auto_hakai") then
   list_of_affects:insert("hakai barrier")
end

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
