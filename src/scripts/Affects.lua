local ck = require("__PKGNAME__")
local Skills = ck:get_table("API.Skills") -- CK.API.Skills:mastered
local API = ck:get_table("API") -- CK.API more public
local Affects = ck:get_table("API.Affects") -- less public
local State = ck:get_table("API.State")

ck:define_feature("auto_hakai", false)
ck:define_feature("auto_buff", true)

function Affects:rebuff(seen)
    for _, affect in ipairs(Skills:buffs()) do
        if not seen[affect] and State:is(State.NORMAL) then
            if affect ~= "hakai barrier" or ck:feature("auto_hakai") then
                cecho(f "\n<cyan>Performing Rebuff: {affect}")
                API:focus(affect)
            end
        end
    end
end

function API:auto_rebuff(affect)
    if ck:feature("auto_buff") then
        API:safeSend(f"focus '{affect}'")
    end
end

function API:focus(affect)
    send(f "focus '{affect}'")
end
