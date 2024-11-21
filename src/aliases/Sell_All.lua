local thing = matches[2]


local id = tempTrigger(
    "tells you, 'I'll give you",
    function()
        local thing = thing
        send(f"sell {thing}", false)
    end
)

tempTrigger(
    "tells you, 'You don't seem to have that.'", function()
        killTrigger(id)
    end,
    1
)

send(f"sell {thing}")