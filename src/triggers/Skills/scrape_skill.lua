local Data = FRIED.Player.Skills
local Learned = Data.Learned
local Mastered = Data.Mastered
local Supreme = Data.Supreme
local Boosted = Data.Boosted
local section = Data.section
-- API
local sapi = FRIED.API.Skills

-- Loop through matches
for _, o in ipairs({0, 3}) do
  local skill = matches[2 + o]
  local status = matches[3 + o]
  if skill ~= nil then
    local tskill = sapi:translate(skill)
    if status == "Mastered" or status == "Boosted" or status == "Supreme" then
      Mastered[tskill] = true
    end
    if status == "Supreme" then
      Supreme[tskill] = true
      Boosted[tskill] = true
    elseif status == "Boosted" then
      Boosted[tskill] = true
    end
    Learned[tskill] = true
    table.insert(section, tskill)
  end
end