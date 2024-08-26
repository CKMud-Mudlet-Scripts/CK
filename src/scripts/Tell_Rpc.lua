--[[
This parses !cmd from tell messages and handles replies
]] local ck = require("__PKGNAME__.ck")
local Player = ck:get_table("Player")
local tell_rpc = ck:get_table("API.tell_rpc")

ck:define_feature("tell_rpc", false)
ck:define_feature("tell_rpc_auction_senzu", false)
ck:define_constant("alts", {})

tell_rpc.methods = {
    ["!help"] = function(who, args, reply)
        reply("CKBot Commands: !version, !maxpl, !zenni, !stats")
    end,
    ["!disconnect"] = function(who, args, reply)
        if table.contains(ck:constant("alts"), who) then
            reply("Sure Thing Buddy!")
            send("quit")
            registerAnonymousEventHandler("sysDisconnectionEvent", disconnect, true)
        else
            reply(f "Nice Try {who}")
        end
    end,
    ["!version"] = function(who, args, reply)
        reply(ck:get_version_str())
    end,
    ["!maxpl"] = function(who, args, reply)
        reply("Current Max PL is {reformatInt(Player.MAXPL)}")
    end,
    ["!zenni"] = function(who, args, reply)
        reply("Current Zenni: {reformatInt(Player.MONEY)}")
    end,
    ["!stats"] = function(who, args, reply)
        reply(string.format(
            "Hitroll: %d  Damroll: %d; UBS/LBS: %d/%d; Strength: %d (%d)  Speed: %d (%d)  Wisdom: %d (%d)  Intellect: %d (%d)",
            Player.HITROLL, Player.DAMROLL, Player.UBS, Player.LBS, Player.Stats.BaseSTR, Player.Stats.STR,
            Player.Stats.BaseSPD, Player.Stats.SPD, Player.Stats.BaseWIS, Player.Stats.WIS, Player.Stats.BaseINT,
            Player.Stats.INT))
    end,
    ["!auction"] = function(who, args, reply)
        if ck:feature("tell_rpc_auction_senzu") then
            if args == "senzu" then
                send("get bean bag", false)
                send("auction bean 125000", false)
            elseif args == "senzu token" then
                send("get bean bag", false)
                send("auction bean token 1", false)
            end
        end
    end
}

function tell_rpc:handle(who, what)
    local expanded_args = what:split(" ")
    local cmd = expanded_args[1]
    local rpc = self.methods[cmd]

    if rpc then

        reply = function(msg)
            local w = who
            send(f "tell {w} {msg}")
        end

        rpc(who, table.concat(expanded_args, " ", 2), reply)
    end
end
