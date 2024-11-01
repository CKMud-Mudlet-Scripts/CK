--[[
Some basic functionality so I don't have to worry about init order or
script load order

local ck = require("__PKGNAME__")
]] 
local ck = {}
-- Global Data Prefix
local PREFIX = "CK"
local WAS_SET = "__ck_defaults_WAS_SET"

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
    local ck_id = ck:get_table_id(ck)
    -- Prefix all names with out PREFIX
    name = table.concat({PREFIX, name}, ".")
    -- Loop over words in name split by .
    for w, d in string.gmatch(name, "([%w_]+)(.?)") do
        head[w] = head[w] or {}
        head = head[w]
    end
    if default and head[WAS_SET] ~= ck_id then
        ck:copy_table_into(default, head)
        -- prevent the defaults from being copied again on script save. 
        head[WAS_SET] = ck_id
    end
    return head
end

function ck:get_table_id(t)
    return (f"{t}"):split(": ")[2]
end

function ck:copy_table_into(t, dst)
    for k, v in pairs(t) do
        dst[k] = v
    end
    local mt = getmetatable(t)
    if mt then
        setmetatable(dst, mt)
    end
end

function ck:clear_table(t)
    ---@diagnostic disable-next-line: undefined-field
    local keys = table.keys(t)
    for _, key in ipairs(keys) do
        t[key] = nil
    end
end

local Features = ck:get_table("Features")
local Constants = ck:get_table("Constants")

function ck:define_feature(name, default_value)
    Features[name] = default_value or false
end

function ck:feature(name)
    if Features[name] == nil then
        error(f"unknown feature name: {name}")
    end
    local val = ck.db:read_toggle(name)
    if val == nil then
        return Features[name]
    end
    return val
end

function ck:feature_names()
    local a = {}
    for feature in pairs(ck:get_table("Features")) do
        table.insert(a, feature)
    end
    table.sort(a)
    return a
end

function ck:constant_names()
    local a = {}
    for const in pairs(ck:get_table("Constants")) do
        table.insert(a, const)
    end
    table.sort(a)
    return a
end

function ck:define_constant(name, default_value)
    Constants[name] = {default_value}
end

function ck:constant(name)
    if Constants[name] == nil then
        error(f"unknown constant name: {name}")
    end
    local val = ck.db:read_constant(name)
    if val == nil then
        return Constants[name] and Constants[name][1] or nil
    end
    return yajl.to_value(val)[1]
end

---@param name string
function ck:set_constant(name, value)
    ck.db:set_constant(name, yajl.to_string({value}))
    raiseEvent("CK.Constant", name, value)
end

--@param name string
--@param vale bool
function ck:set_feature(name, value)
    ck.db:toggle(name, value)
    raiseEvent("CK.Feature", name, value)
end

function ck:make_enum(name, alist)
    -- Create an Enum Table with helpful enum values
    local atable = {}
    for _, v in ipairs(alist) do
        atable[v] = {name .. "." .. v}
    end
    setmetatable(atable, {
        __index = function(self, key)
            if not key == WAS_SET then
                error(string.format("%q is not a valid member of %s", tostring(key), name), 2)
            end
        end
    })
    return atable
end

-- DB stuff

ck.db = {
    schema = db:create("CKMud", {
        Toggles = {
            name = "",
            value = 0,
            _unique = {"name"},
            _violations = "REPLACE"
        },
        Constants = {
            name = "",
            value = "",
            _unique = {"name"},
            _violations = "REPLACE"
        }
    })
}

---@param name string
---@param value string
function ck.db:set_constant(name, value)
    db:add(self.schema.Constants, {
        name = name,
        value = value
    })
end

function ck.db:read_constant(name)
    local rec = db:fetch(self.schema.Constants, db:eq(self.schema.Constants.name, name))
    if not rec or not rec[1] then
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
    db:add(self.schema.Toggles, {
        name = name,
        value = value and 1 or 0
    })
end

function ck.db:read_toggle(name)
    local rec = db:fetch(self.schema.Toggles, db:eq(self.schema.Toggles.name, name))
    if not rec or not rec[1] then
        return nil
    end
    return rec[1].value == 1
end

function ck.db:delete_toggle(name)
    db:delete(self.schema.Toggles, db:eq(self.schema.Toggles.name, name))
end

-- I need Times.create to work in scripts outside of functions
local Times = ck:get_table("API.Times", {
    _watches = {}
})

function Times:create(name)
    if not self._watches[name] then
        tempTimer(0, function()
            self._watches[name] = createStopWatch(PREFIX .. "." .. name, true)
        end)
    end
end

-- Versions 
local versions = {}

function ck:register(what, version, noregister)

    versions[what] = version

    if not noregister then
        registerNamedEventHandler(what, "reregister_package", "CK:Register_Package", function(event)
            require("CK"):register(what, version, true)
        end)
    end

end

function ck:get_version_str()
    -- CKMud-Shared:1.x.x CKMud-Core:2.x
    local modules = {}
    local versions = versions
    for m in pairs(versions) do
        table.insert(modules, m)
    end
    table.sort(modules)
    local output = {}
    for _, m in ipairs(modules) do
        table.insert(output, f "{m}:{versions[m]}")
    end
    return table.concat(output, " ")
end

function ck:get_versions()
    local modules = {}
    for mod, v in pairs(versions) do
        modules[mod] = v
    end
    return modules
end

function ck:installed_module(what)
    return versions[what]
end

-- Sub Package Plugins System

-- When CK is reinstalled tell the other packages to register again
registerNamedEventHandler(PREFIX, "sysInstall", "sysInstall", function(event, name)
    if name:starts(PREFIX) then
        raiseEvent("CK:Register_Package")
    end
end)

-- When a package is uninstalled remove it from our list
registerNamedEventHandler(PREFIX, "sysUninstall", "sysUninstall", function(event, name)
    if name:starts(PREFIX) then
        versions[name] = nil
    end
end)

return ck
