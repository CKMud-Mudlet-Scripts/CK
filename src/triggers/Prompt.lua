local matches = multimatches[2]
local metrics = matches.Metrics
local forms = matches.Forms
local Player = CK.Player
local Toggles = CK.Toggles

Player.Pl = tonumber(matches.PL:gsub(",", ""):trim())
Player.Status = {}

-- Handle Metrics
for _, raw_metric in ipairs(metrics:split(" | ")) do
  local parts = raw_metric:split(": ")
  local name = parts[1]
  local value = parts[2]
  if value:ends("%") then -- strip off %
     value = value:sub(1, -2)
  end
  Player[name] = tonumber(value)
end

-- Handle States [HT] [FLY] [UI]
for _, form in ipairs(forms:split(" ")) do
  if form:starts("[") and form:ends("]") then
    form = form:sub(2, -2)  -- Strip off [ and ]
    Player.Status[form] = true
  end
end

-- Determine Suppression
-- Get the color of PL, if its green is zero we are suppressing PL
selectString(matches.PL, 1)
local r, g, b = getFgColor()
deselect()
if g == 0 then
  Player.Status.SUPPRESSED = true
end
local sup = Player.Status.SUPPRESSED == true

-- Handle Max GK
if Player.GK then
Player.MaxGK = 500 + 50 * (Player.RemortLevel or 0)
end

if not Player.SUPPRESSED and Player.MaxPl then
Player.Health = math.floor((Player.Pl / Player.MaxPl) * 100)
end

-- Toggle this
cecho(f"[<green>{CK.API.State:toString()}<white>]")
cecho(f"[<red>{(CK.Player.MaxGravity or '???')}x G<white>]")

if not CK.API.Mode:is(CK.API.Mode.Interactive) then
  cecho(f"[<green>{CK.API.Mode:toString()}<white>]")
end

-- Toggle this
cecho(f"\n[Health: <green>{Player.Health or '???'}<white>%]")
if Toggles.EnemyLineComboTest then
  Player.COMBO = nil
else
  cecho("[<red>IN COMBO<white>]")
end

raiseEvent("CK.onPrompt")