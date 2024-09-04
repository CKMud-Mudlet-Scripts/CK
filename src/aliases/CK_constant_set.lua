local ck = require("__PKGNAME__")
local constant_list = ck:constant_names()
local constant = matches[2]
local raw_value = matches[3]
if constant == nil then
  return
end
if not table.contains(constant_list, constant) then
  echo(f("No Such Constant: {constant}\n"))
  return
end
local value_func, error = loadstring(" return " .. raw_value)
if value_func then
  local value = value_func()
  ck:set_constant(constant, value)
  echo(f("Setting Constant({constant}) to "))
  display(value)
else
  echo(f("Error parsing entered lua constant value: {error}!"))
end