local matches = multimatches[2]
--local metrics = matches.Metrics
local forms = matches.Forms
local Player = CK.Player
local Toggles = CK.Toggles

Player.Pl = tonumber(matches.PL:gsub(",", ""):trim())
Player.Status = {}

-- Handle Metrics
--[[  Obsolete by MSDP
for _, raw_metric in ipairs(metrics:split(" | ")) do
  local parts = raw_metric:split(": ")
  local name = parts[1]
  local value = parts[2]
  if value:ends("%") then -- strip off %
     value = value:sub(1, -2)
  end
  Player[name] = tonumber(value)
end
]]

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
--[[ Obsolete by MSDP
if Player.GK then
Player.MaxGK = 500 + 50 * (Player.RemortLevel or 0)
end


if not sup and Player.MaxPl then
Player.Health = math.floor((Player.Pl / Player.MaxPl) * 100)
end
]]
-- Toggle this
cecho(f"[<green>{CK.API.State:toString()}<white>]")
cecho(f"[<red>{CK.Room.Gravity}<white> / <red>{CK.Player.MaxGravity}x G<white>]")

if not CK.API.Mode:is(CK.API.Mode.Interactive) then
  cecho(f"[<green>{CK.API.Mode:toString()}<white>]")
end

-- Inject Health % after PL 
-- toggle this
selectString("|", 1)
local health = Player:get_health()
  -- 100%     75%       50%       25%
  -- green -> yellow -> orange -> red
  if health > 75 then
    fg("green")
  elseif health > 50 then
    fg("yellow")
  elseif health > 25 then
    fg("orange")
  else
    fg("red")
  end
replace(f"{health}% |")
selectString("|", 1)
fg("ansiLightBlack")
deselect()

-- Toggle this
if Toggles.EnemyLineComboTest then
  Player.COMBO = nil
end
if Player.COMBO then
  cecho("[<red>IN COMBO<white>]")
end

raiseEvent("CK.onPrompt")