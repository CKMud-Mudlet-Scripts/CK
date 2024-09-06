local ck = require("__PKGNAME__")
local Toggles = ck:get_table("Toggles")
local State = ck:get_table("API.State",  ck:make_enum(
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
local _state = ck:get_table("API._State", {CURRENT_STATE=State.NORMAL, PREV_STATE=State.NORMAL})

function State:set(state)
  _state.PREV_STATE = State:get() or State.NORMAL
  _state.CURRENT_STATE = state
end

function State:get()
  return _state.CURRENT_STATE
end

function State:is(state)
  return state == self:get()
end

function State:revert()
  State:set(_state.PREV_STATE)
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