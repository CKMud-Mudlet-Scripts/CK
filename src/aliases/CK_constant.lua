local ck = require("__PKGNAME__")
local console = require("__PKGNAME__.console")
local constants = ck:constant_names()
local max_length = -1
-- Get the max length
for _, v in ipairs(constants) do
    local l = string.len(v)
    if l > max_length then
        max_length = l
    end
end
local fmt = f("%{max_length}s = ")

local function print_constant(constant)
    cecho(string.format(fmt, constant))
    display(ck:constant(constant))
end

local constant = matches[2] or ""
local s = console:header(matches[2] and f("CK Constants List \\ prefix: '{constant}'") or "CK Constants List", 80)
local found = 0

for _, v in ipairs(constants) do
    if v:starts(constant) then
        found = found + 1
        print_constant(v)
    end
end

if #constants == 0 then
    echo("NO CONSTANTS DEFINED!\n")
elseif found == 0 then
    cecho(f("<red>NO CONSTANTS FOUND STARTING WITH '{constant}'\n"))
end
console:footer(s)
echo(" * Use `CK constant <name> = value` to set\n")
