-- The Safe Send Queue
-- Only Save up sends for sending later
SendQueue = SendQueue or {first = 0, last = -1}

function SendQueue.push(value)
  local last = SendQueue.last + 1
  SendQueue.last = last
  SendQueue[last] = value
end

function SendQueue.pop()
  local first = SendQueue.first
  if first > SendQueue.last then
    error("list is empty")
  end
  local value = SendQueue[first]
  SendQueue[first] = nil
  SendQueue.first = first + 1
  return value
end

function SendQueue.hasnext()
  if SendQueue.first > SendQueue.last then
    return false
  else
    return true
  end
end

function SendQueue.trySendNow()
  local msg
  if not Toggles.fighting and is_state(State.NORMAL, true) and SendQueue.hasnext() then
    msg = SendQueue.pop()
    send(msg)
  end
end

function safeSend(msg)
  SendQueue.push(msg)
end

-- END Safe Send Queue