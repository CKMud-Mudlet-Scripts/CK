local Data = CK.Player.Skills
local Learned = Data.Learned
local Mastered = Data.Mastered
local Supreme = Data.Supreme
local Boosted = Data.Boosted
local Ultimate = Data.Ultimate
local section = Data.section
-- API
local sapi = CK.API.Skills

-- Loop through matches
for _, o in ipairs({0, 3}) do
  local skill = matches[2 + o]
  local status = matches[3 + o]
  if skill ~= nil then
    local tskill = sapi:translate(skill)
    ---@diagnostic disable-next-line: undefined-field
    if table.contains({"Mastered", "Boosted", "Supreme", "Ultimate"}, status) then
      Mastered[tskill] = true
    end 
    local higher_status = false
    if status == "Ultimate" then
      Ultimate[tskill] = true
      higher_status = true
    end
      
    if status == "Supreme" or higher_status then
      Supreme[tskill] = true
      higher_status = true
    end
    
    if status == "Boosted" or higher_status then
      Boosted[tskill] = true
    end
    Learned[tskill] = true
    table.insert(section, tskill)
  end
end