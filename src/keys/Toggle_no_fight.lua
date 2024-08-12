local Toggles = FRIED.Toggles

if Toggles.no_fight then
  Toggles.no_fight = false
  echo("Auto fight() enabled")
else
  Toggles.no_fight = true
  echo("Auto fight() disabled")
end