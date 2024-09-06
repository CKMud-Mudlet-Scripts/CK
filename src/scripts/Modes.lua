local ck = require("__PKGNAME__")
local Toggles = ck:get_table("Toggles")
local Mode = ck:get_table("API.Mode",  ck:make_enum(
          "Mode",
          {
            'Learning',
            'Training',
            'Zetabot',
            'Interactive'
          }
))
local API = ck:get_table("API")
local _mode = ck:get_table("API._mode", {mode=Mode.Interactive, string=""})

function Mode:switch(new_mode)
    new_mode = new_mode or Mode.Interactive
    API.State:set(API.State.NORMAL)
    -- Remove this shit later
    if new_mode == Mode.Interactive then
        _mode.string = ""
        Toggles.botmode = false
        Toggles.training = false
        Toggles.learning = false
    elseif new_mode == Mode.Learning then
        _mode.string = "Learning"
        Toggles.learning = true
        Toggles.botmode = false
        Toggles.training = false
    elseif new_mode == Mode.Training then
        _mode.string = "Training"
        Toggles.training = true
        Toggles.botmode = false
        Toggles.learning = false
    elseif new_mode == Mode.Zetabot then
        _mode.string = "Zetabot"
        Toggles.training = false
        Toggles.botmode = true
        Toggles.learning = false
    end
    _mode.mode = new_mode
end

function Mode:is(mode)
    return mode == _mode.mode
end

function Mode:get()
    return _mode.mode
end

function Mode:toString()
    return _mode.string
end