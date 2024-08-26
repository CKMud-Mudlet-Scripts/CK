--[[
Some basic functionality so I don't have to worry about init order or
script load order

local ck = require("__PKGNAME__.ck")
]]
local ck = {}
-- Global Data Prefix
local PREFIX = "CK"
-- Saving this just in case
local db = db


function ck:run_init(what, func)
    -- Return an init function that prints out whats going on

    local function init()
        cecho("<green>[ CK ] - Calling " .. what .. " Init!\n")
        func()
    end

    return init
end

function ck:get_table(name, default)
    -- get a data table, with possible "default"
    local head = _G
    -- Prefix all names with out PREFIX
    name = table.concat({PREFIX, name}, ".")
    -- Loop over words in name split by .
    for w, d in string.gmatch(name, "([%w_]+)(.?)") do
        if d == "." then    -- There is a word after
            head[w] = head[w] or {}
        else   
            head[w] = default or {} -- If there is a default do the assignment
        end
        head = head[w]
    end
    return head
end

local Features = ck:get_table("Features")

function ck:define_feature(name, default_value)
    Features[name] = default_value
end

function ck:feature(name)
    local val = ck.db:read_toggle(name)
    if val == nil then
        return Features[name]
    end
    return val
end

function ck:make_enum(name, alist)
    -- Create an Enum Table with helpful enum values
    local atable = {}
    for _, v in ipairs(alist) do
        atable[v] = { name .. "." .. v }
    end
    setmetatable(
        atable,
        {
            __index =
                function(self, key)
                    error(string.format("%q is not a valid member of %s", tostring(key), name), 2)
                end,
        }
    )
    return atable
end

-- DB stuff

ck.db = { schema = db:create("CKMud", {
    Toggles = {
        name = "",
        value = 0,
        _unique = { "name" },
        _violations = "REPLACE",
    },
    Constants = {
        name = "",
        value = "",
        _unique = { "name" },
        _violations = "REPLACE",
    }
}) 
}

function ck.db:set_constant(name, value)
    db:add(self.schema.Constants, { name = name, value = value })
end

function ck.db:read_constant(name)
    local rec = db:fetch(self.schema.Constants, db:eq(self.schema.Constants.name, name))
    if not rec[1] then
        return nil
    end
    return rec[1].value
end

function ck.db:delete_constant(name)
    db:delete(self.schema.Constants, db:eq(self.schema.Constants.name, name))
end

function ck.db:toggle(name, value)
    if value == nil then
        value = true
    end
    db:add(self.schema.Toggles, { name = name, value = value and 1 or 0 })
end

function ck.db:read_toggle(name)
    local rec = db:fetch(self.schema.Toggles, db:eq(self.schema.Toggles.name, name))
    if not rec[1] then
        return nil
    end
    return rec[1].value == 1
end

function ck.db:delete_toggle(name)
    db:delete(self.schema.Toggles, db:eq(self.schema.Toggles.name, name))
end

-- I need Times.create to work in scripts outside of functions
local Times = ck:get_table("API.Times")
local watches = ck:get_table("API.Times._watches")

function Times:create(name)
    if not watches[name] then
        watches[name] = createStopWatch(name, true)
    end
end

return ck
