local ck = require("__PKGNAME__")
local console = require("__PKGNAME__.console")
local features = ck:feature_names()
local max_length = -1

-- Get the max length
for _, v in ipairs(features) do
    local l = string.len(v)
    if l > max_length then
        max_length = l
    end
end

local max_width = 80
if max_length == -1 then
    max_length = 15
end
-- : and on/off is 6 characters
local num_column = math.min(#features + 2, math.floor(max_width / (max_length + 6)), 4)
local total_width = num_column * (max_length + 6) + (3 * (num_column - 1))

local fmt = f "%{max_length}s : %3s<reset>"

local function print_feature(feature)
    cecho(string.format(fmt, feature, ck:feature(feature) and "<green>on" or "<red>off"))
end

local function ncolumn(t, n)
    print_feature(t[1])

    local c = 1
    for i = 2, #t, 1 do
        if c == n then
            c = 0
            echo("\n")
        end
        if c ~= 0 then
            echo("   ")
        end
        print_feature(t[i])
        c = c + 1
    end
    echo("\n")
end

local s = console:header("CK Features List", total_width)
if #features > 0 then
    ncolumn(features, num_column)
else
    echo("NO FEATURES FOUND\n")
end
console:footer(s)
echo(" * Use `CK feature <name> on/off` to toggle\n")
