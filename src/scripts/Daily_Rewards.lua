local ck = require("__PKGNAME__")
local Player = ck:get_table("Player")
ck:define_feature("auto_daily", true)
ck:define_constant("auto_daily.last", "000000")
ck:define_constant("auto_daily.check_interval", 1200)
local triggers = {}

local function kill_triggers()
    for _, id in ipairs(triggers) do
        killTrigger(id)
    end
    triggers = {}
end

local function get_now()
    return getTime(true, "yymmdd")
end

local function check_daily()
    local last = ck:constant("auto_daily.last")
    local now = get_now()
    if Player.BasePl > 1000000 then
        if now ~= last then
            send("daily redeem")
        end
    end
end

local function stop()
    deleteNamedTimer("__PKGNAME__", "CK:auto_daily")
    kill_triggers()
end

local function start()
    table.insert(triggers,
        tempExactMatchTrigger(
            "Thank you for playing CKMud, enjoy your daily reward!",
            function()
                ck:set_constant("auto_daily.last", get_now())
            end
        )
    )
    table.insert(triggers,
        tempExactMatchTrigger(
            "You have already collected your daily reward for today.",
            function()
                ck:set_constant("auto_daily.last", get_now())
            end
        )
    )
    registerNamedTimer("__PKGNAME__", "CK:auto_daily", ck:constant("auto_daily.check_interval"), check_daily, true)
end

-- Start this thing
if ck:feature("auto_daily") then
    start()
end

-- We want to watch for changes to constant and featues for disables or timer changes

local function onConstantChange(event, name, value)
    if name == "auto_daily.check_interval" then
        stop()
        start()
    end
end

local function onFeatureChange(event, name, value)
    if name == "auto_daily" then
        if value then
            start()
        else
            stop()
        end
    end
end

registerNamedEventHandler("__PKGNAME__", "auto_daily.check_interval", "CK.Constant", onConstantChange)
registerNamedEventHandler("__PKGNAME__", "auto_daily.feature", "CK.Feature", onFeatureChange)
