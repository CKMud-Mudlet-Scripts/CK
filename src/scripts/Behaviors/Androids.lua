local ck = require("__PKGNAME__")
local Player = ck:get_table("Player")
local API = ck:get_table("API")
local State = ck:get_table("API.State")
local Mode = ck:get_table("API.Mode")
local Times = ck:get_table("API.Times")

Times:create("android_vent")

local function on_prompt()
    if not API:isAndroid() then
        return
    end
    if not API:cmd_stack_empty() then
        -- Don't stack cmds 
        return
    end

    if Mode:is(Mode.Zetabot) then
        if State:is(State.NORMAL) then
            if Times:last("android_vent") > 60 and Player.get_energy() < 50 then
                send("vent")
                Times:reset("android_vent")
            end
        end
    end

    if State:is(State.REST) then
        if Player.get_health() < 100 then
            send("repair")
        end
    end
end

registerNamedEventHandler("__PKGNAME__", "Behavior_Android_NotFighting", "CK.notFighting", on_prompt)
