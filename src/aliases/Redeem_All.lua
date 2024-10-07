local id = tempTrigger(
    "The opened loot box disintegrates in your hands...",
    function()
        send("redeem")
    end
)

tempTrigger(
    "You don't have any loot boxes to redeem.", function()
        killTrigger(id)
    end,
    1
)

tempTrigger(
    "The Namekian Dragonballs lift up into the sky and shoot off out of sight.",
    function()
        send("redeem")
    end,
    1
)

send("redeem")
