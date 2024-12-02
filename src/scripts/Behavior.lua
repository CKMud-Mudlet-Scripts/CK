local ck = require("__PKGNAME__")
local API = ck:get_table("API")

function API:register_behavior(name, race, not_fighting, fighting, finished_fighting)
    -- If you are outside the CK package you should pass something other than nil for name. 
    if name == nil then
        name = "CK"
    end

    if not_fighting ~= nil then
        registerNamedEventHandler("__PKGNAME__", f "Behavior_{name}_{race}_NotFighting", "CK.notFighting", function()
            local _race = API:getRace()
            if race:lower() == _race:lower() or race == "*" then
                not_fighting(_race)
            end
        end)
    end

    if fighting ~= nil then
        registerNamedEventHandler("__PKGNAME__", f "Behavior_{name}_{race}_Fighting", "CK.fighting", function()
            local _race = API:getRace()
            if race:lower() == _race:lower() or race == "*" then
                fighting(_race)
            end
        end)
    end

    if finished_fighting ~= nil then
        registerNamedEventHandler("__PKGNAME__", f "Behavior_{name}_{race}_FinishedFighting", "CK.finishedFighting",
            function()
                local _race = API:getRace()
                if race:lower() == _race:lower() or race == "*" then
                    finished_fighting(_race)
                end
            end)
    end
end
