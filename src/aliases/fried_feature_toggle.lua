local fried = require("CKMud-Shared.fried")
local api = FRIED.API
local feature_list = api:feature_names()

local feature = matches[2]
local switch = matches[3]

if feature == nil then
    return
end

if not table.contains(feature_list, feature) then
    echo(f"No Such Feature: {feature}\n") 
    return
end

local value = switch == "on" and true or false
fried.db:toggle(feature, value)
echoc(f"Setting Feature({feature}) to {switch}!\n")