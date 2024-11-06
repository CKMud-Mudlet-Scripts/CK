-- Instead of patching math and table we have a CK.math and CK.table
local ck = require("__PKGNAME__")
local t = ck:get_table("table")
local m = ck:get_table("math")


-- Quality Of Life functions
function m.round(x, n)
    return tonumber(string.format("%." .. n .. "f", x))
end

function m.format(i)
    return tostring(i):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

if table.unpack == nil then
    -- At some point table.unpack is included in lua
    ---@diagnostic disable-next-line: duplicate-set-field
    function t.unpack(t, i, j)
        return unpack(t, i, j)
    end
else
    function t.unpack(t, i, j)
        return table.unpack(t, i, j)
    end
end

function t.sub(t, i, j)
    return {t.unpack(t, i, j)}
end

function t.sample_keys(tb)
    local keys = {}
    for k, v in pairs(tb) do
        table.insert(keys, k)
    end
    return keys[math.random(#keys)]
end

function t.sample_items(tl)
    local pos = math.floor(math.random() * #tl) + 1
    return tl[pos]
end

function t.extend(list, items)
    for _, item in ipairs(items) do
        list[#list + 1] = item
    end
end