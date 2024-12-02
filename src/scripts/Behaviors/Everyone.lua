local ck = require("__PKGNAME__")
local Player = ck:get_table("Player")
local API = ck:get_table("API")
local Skills = ck:get_table("API.Skills")
local Times = ck:get_table("API.Times")

ck:define_feature("auto_heal_self", false)
ck:define_constant("auto_heal_self_at", 40)

Times:create("auto_heal_backoff")

local function fighting(race)
    if not ck:feature("auto_heal_self") then
      return
    end
    if Times:last("auto_heal_backoff") < 10 then
      return
    end
    local heal_at = ck:constant("auto_heal_self_at")
    local our_health = Player.get_health()
    local heal = Skills:get_heal()
    local stack = API:cmd_stack()
    if heal == nil then
        return
    end
    if our_health < heal_at then
        if stack > 1 and our_health < (heal_at / 2) then
            send("--")
            stack = 0
        end
        
        if stack > 1 then
            -- Don't flood them out 
            return
        end

        Times:reset("auto_heal_backoff")
        if not API:isAndroid(race) then
            send(f "focus '{heal}'")
        else
            send("repair")
        end
    end
end

API:register_behavior(nil, "*", nil, fighting)