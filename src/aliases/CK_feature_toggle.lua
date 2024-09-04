local ck = require("__PKGNAME__")
local feature_list = ck:feature_names()

local feature = matches[2]
local switch = matches[3]

if feature == nil then
    return
end

if not table.contains(feature_list, feature) then
    cecho(f"<red>No Such Feature: {feature}\n")
    return
end

local value = switch == "on" and true or false
ck.db:toggle(feature, value)
echoc(f "Setting Feature({feature}) to {switch}!\n")
