-- The Safe Send Queue
-- Only Save up sends for sending later

local ck = require("__PKGNAME__")
local SendQueue = ck:get_table("API.SendQueue", {first = 1, last = 0})
local State = ck:get_table("API.State")
local Toggles = ck:get_table("Toggles")
local API = ck:get_table("API")


function SendQueue:push(value)
  -- Lets attempt to do unique queues
  for i = self.first, self.last do
    if self[i] == value then
      return
    end
  end

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
    if self.first ~= 1 then
      self.first = 1
      self.last = 0
    end
    return false
  else
    return true
  end
end

function SendQueue:clear()
  if self.first ~= 0 then
    for pos=self.first,self.last do
        self[pos] = nil;
    end
  end
end

function SendQueue:trySendNow()
  local msg
  if API:not_fighting() and State:check(State.NORMAL, true) and self:hasnext() then
    msg = self:pop()
    send(msg)
  end
end

function API:safeSend(msg)
  self.SendQueue:push(msg)
end