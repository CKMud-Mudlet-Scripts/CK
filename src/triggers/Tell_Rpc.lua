--[[
This is a rpc think irc bot we dispatch to `Tell Rpc` Script
]]
local api = CK.API
local matches = multimatches[2]
local who = matches[2]
local what = matches[3]
if string.starts(what, "!") and api:feature("tell_rpc") then
  api.tell_rpc:handle(who, what)
end  