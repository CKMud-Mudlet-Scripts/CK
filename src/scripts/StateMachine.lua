local fried = require("__PKGNAME__.fried")
local Toggles = fried:get_table("Toggles")
local State = fried:get_table("API.State",  fried:make_enum(
          "State",
          {
            'REST',
            'REPAIR',
            'FLEE',
            'SEEK_REST',
            'SENSE',
            'NORMAL',
            'BUFFING',
            'CRAFTING',
          }
))

State._CURRENT_STATE = State._CURRENT_STATE or State.NORMAL
State._PREV_STATE = State._PREV_STATE or State.NORMAL


function State:set(state)
  State._PREV_STATE = State:get() or State.NORMAL
  State._CURRENT_STATE = state
end

function State:get()
  return State._CURRENT_STATE
end

function State:revert()
  State:set(State._PREV_STATE)
end

function State:check(state, botmode)
  return
    State:get() == state and (botmode or Toggles.botmode or Toggles.training or Toggles.learning)
end

function State:toString()
  local state = State:get()
  if state == State.REST then
    return "REST"
  elseif state == State.REPAIR then
    return "REPAIR"
  elseif state == State.FLEE then
    return "<yellow>FLEE"
  elseif state == State.SEEK_REST then
    return "SEEK_REST"
  elseif state == State.NORMAL then
    return "NORMAL"
  elseif state == State.SENSE then
    return "SENSE"
  elseif state == State.BUFFING then
    return "<yellow>BUFFING"
  elseif state == State.CRAFTING then
    return "<yellow>CRAFTING"
  end
  return "UNKNOWN"
end