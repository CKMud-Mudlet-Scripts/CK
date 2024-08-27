-- The Safe Send Queue
-- Only Save up sends for sending later

local ck = require("__PKGNAME__.ck")
local SendQueue = ck:get_table("API.SendQueue", {first = 0, last = -1})
local State = ck:get_table("API.State")
local Toggles = ck:get_table("Toggles")
local API = ck:get_table("API")


function SendQueue:push(value)
  local last = self.last + 1
  self.last = last
  self[last] = value
end

function SendQueue:pop()
  local first = self.first
  if first > self.last then
    error("list is empty")
  end
  local value = self[first]
  self[first] = nil
  self.first = first + 1
  return value
end

function SendQueue:hasnext()
  if self.first > self.last then
    return false
  else
    return true
  end
end

function SendQueue:trySendNow()
  local msg
  if not Toggles.fighting and State:check(State.NORMAL, true) and self:hasnext() then
    msg = self:pop()
    send(msg)
  end
end

function API:safeSend(msg)
  self.SendQueue:push(msg)
end