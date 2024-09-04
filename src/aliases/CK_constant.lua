local ck = require("__PKGNAME__")
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

local function header(text, max_width, color)
    -- o----{ Header }----o
    local dashl = math.floor((max_width - string.len(text) - 6) / 2)
    local extra_one = (dashl * 2 + string.len(text) + 6 < max_width) and 1 or 0
    color = color or "green"
    local left = string.rep("-", dashl)
    local right = string.rep("-", dashl + extra_one)
    cecho(f("o{left}[ <{color}>{text}<reset> ]{right}o\n"))
    return string.len(left) + string.len(right) + string.len(text) + 6
end

local function footer(max_width)
    --  o------o
    local body = string.rep("-", max_width - 2)
    echo(f("o{body}o\n"))
end

local constant = matches[2] or ""
local s = header(matches[2] and f("CK Constants List \\ prefix: '{constant}'") or "CK Constants List", 80)
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
footer(s)
echo(" * Use `ck constant <name> = value` to set\n")
