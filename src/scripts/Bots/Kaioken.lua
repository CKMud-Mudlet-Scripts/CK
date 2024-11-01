local ck = require("__PKGNAME__")
local Player = ck:get_table("Player")
local kaio = ck:get_table("API.Kaioken", {
    triggers = {},
    max = 120,
})
local API = ck:get_table("API")
local State = ck:get_table("API.State")
local Mode = ck:get_table("API.Mode")
local Toggles = ck:get_table("Toggles")
local Times = ck:get_table("API.Times")

local function exit()
    -- Delete timer
    deleteNamedTimer("__PKGNAME__", "CK:Kaioken")
    -- Kill Triggers
    for _, id in ipairs(kaio.triggers) do
        killTrigger(id)
    end
    kaio.triggers = {}
    print("Kaioken Training Mode Disabled!!!")
end

---@diagnostic disable-next-line: unused-function
local function do_kaioken()
    if not API:is_connected() then
        -- Don't do anything unless we are connected and have a prompt
        return
    end
    if State:is(State.NORMAL) then
        local goal = kaio.max - 8
        local target = math.min(kaio.max, Player.MKaioken + 9)

        -- WE are Done!
        if Player.MKaioken >= goal then
            send(f "kaioken {goal}")
            echo("You have mastered Kaioken completely!\n")
            Mode:switch(Mode.Interactive)
            exit()
        elseif Player.Fatigue / Player.MaxFatigue < 0.20 then
            State:set(State.REST)
            send("kaioken")
            send("sleep")
        elseif Player.Kaioken < target then
            -- Raise the kaioken
            send(f "kaioken {target}")
        elseif Player.Thirst < 40 then
            send("drink fountain")
        end
    elseif State:is(State.REST) then
        if API:is_rested() then
            send("wake")
            State:set(State.NORMAL)
        end
    end
end



local function enter()
    -- one time trigger to catch the max kaioken possible for character
    table.insert(kaio.triggers, tempRegexTrigger("^Syntax: Kaioken 1-([0-9]+)$",
        function()
            kaio.max = tonumber(matches[2])
            -- So nobody sees it
            gagLine()
        end,
        1
    ))
    -- Silently ask for kaioken
    send("kaioken getmax", false)

    if Player.MKaioken == nil then
        Toggles.hide_status = true
        send("status", false)
        Times:reset("status")
    end

    if kaio.max - 8 == (Player.MKaioken or 0) then
        print("Kaioken is already maxed!")
        Mode:switch(Mode.Interactive)
        return
    end

    -- Change Mode
    Mode:switch(Mode.Kaioken, exit)

    print("Kaioken Training Mode Enabled!!!, Try to hang out in an isolation chamber")
    -- Install a timer
    registerNamedTimer("__PKGNAME__", "CK:Kaioken", 4, do_kaioken, true)
end

function kaio:toggle()
    if Mode:is(Mode.Kaioken) then
        Mode:switch(Mode.Interactive)
    else -- Its off
        -- Change Mode
        enter()
    end
end
