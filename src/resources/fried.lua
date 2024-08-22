--[[
Some basic functionality so I don't have to worry about init order or
script load order

local fried = require("__PKGNAME__.fried")
]]
local fried = {}
FRIED = FRIED or {}
-- Saving this just in case
local db = db


function fried:run_init(what, func)
    -- Return an init function that prints out whats going on

    local function init()
        cecho("<green>[ FRIED ] - Calling " .. what .. " Init!\n")
        func()
    end

    return init
end

function fried:get_table(name, default)
    local head = FRIED
    -- Always get a working storage space for tracking things.
    if name then
        for _, t in ipairs(string.split(name, ".")) do
            head[t] = head[t] or (default or {})
            head = head[t]
        end
    end
    return head
end

local Features = get_table("Features")

function fried:define_feature(name, default_value)
    Features[name] = default_value
end

function fried:feature(name)
    local val = fried.db:read_toggle(name)
    if val == nil then
        return Features[name]
    end
    return val
end

function fried:make_enum(name, alist)
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

local mydb = db:create("fried_settings", {
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

fried.db = { settings_db = mydb }

function fried:set_constant(name, value)
    db:add(mydb.Constants, { name = name, value = value })
end

fried.db.set_constant = fried.set_constant

function fried:read_constant(name)
    local rec = db:fetch(mydb.Constants, db:eq(mydb.Constants.name, name))
    if not rec[1] then
        return nil
    end
    return rec[1].value
end

fried.db.read_constant = fried.read_constant

function fried:delete_constant(name)
    db:delete(mydb.Constants, db:eq(mydb.Constants.name, name))
end

fried.db.delete_constant = fried.delete_constant

function fried:toggle(name, value)
    if value == nil then
        value = true
    end
    db:add(mydb.Toggles, { name = name, value = value and 1 or 0 })
end

fried.db.toggle = fried.toggle

function fried:read_toggle(name)
    local rec = db:fetch(mydb.Toggles, db:eq(mydb.Toggles.name, name))
    if not rec[1] then
        return nil
    end
    return rec[1].value == 1
end

fried.db.read_toggle = fried.read_toggle

function fried:delete_toggle(name)
    db:delete(mydb.Toggles, db:eq(mydb.Toggles.name, name))
end

fried.db.delete_toggle = fried.delete_toggle

-- I need Times.create to work in scripts outside of functions
local Times = fried:get_table("API.Times")
local watches = {}

function Times:create(name)
  if not watches[name] then
    watches[name] = createStopWatch(name, true)
  end
end

return fried