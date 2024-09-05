local ck = require("__PKGNAME__")
local Player = ck:get_table("Player")
-- local tell_rpc = ck:get_table("API.tell_rpc")

function enter_botmode()
    Toggles.timer_ok = true
    enableTimer("BotModeFast")
  end
  
  function exit_botmode()
    disableTimer("BotModeFast")
  end
  
  function toggle_botmode(aoe, target)
    if Toggles.botmode then
      -- disable it
      Toggles.botmode = false
      echo("Autobot Mode Disabled!!!")
      set_state(State.NORMAL)
      exit_botmode()
    else
      Toggles.botmode = true
      Toggles.training = false
      set_state(State.NORMAL)
      echo("Autobot Mode Enabled!!!")
      autobot_target = {aoe, target}
      Toggles.autobot_sense = true
      enter_botmode()
    end
  end
  
  function on_botmode()
    -- This is executed by a timer when botmode is on
    aoe = autobot_target[1]
    target = autobot_target[2]
    local g = math.min(math.floor((1 / 5000) * 0.06 * Player.MAXPL), (max_gravity or 2) - 1)
    ok_to_vent = ok_to_vent or true
    local ran = math.random()
    Times.lastaoe = Times.lastaoe or getEpoch()
    if PromptCounters.timer_ok == nil or (PromptCounters.timer_ok <= 17 and not Toggles.fighting) then
      Toggles.timer_ok = true
    end
    if is_connected() then
      if Toggles.botmode and PromptFlags.timertrainer == nil then
        -- Only one cmd per prompt print so we don't flood the mud
        PromptFlags.timertrainer = true
        if Toggles.timer_ok then
          if is_state(State.NORMAL, true) and Player.HEALTH > 50 and Player.FATIGUE <= 80 then
            if Toggles.autobot_sense then
              Toggles.autobot_sense = true
              Toggles.autobot_found = false
              send(f("sense {target}"))
              TimerCount = 0
            end
            if Toggles.autobot_adjust then
              send(f("adjust {g}"))
              Toggles.autobot_adjust = false
            end
            if Toggles.autobot_found then
              Toggles.timer_ok = false
              PromptCounters.timer_ok = 20
              send(aoe)
            end
            Times.lastaoe = getEpoch()
          end
        end
      end
    end
  end