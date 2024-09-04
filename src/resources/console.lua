--[[

This file is for helpers for creating Aliases output

]]

local console = {}

function console:header(text, max_width, color)
    -- o----{ Header }----o
    local dashl = math.floor((max_width - string.len(text) - 6) / 2)
    local extra_one = (dashl * 2 + string.len(text) + 6 < max_width) and 1 or 0
    color = color or "green"
    local left = string.rep("-", dashl)
    local right = string.rep("-", dashl + extra_one)
    cecho(f "o{left}[ <{color}>{text}<reset> ]{right}o\n")
    return string.len(left) + string.len(right) + string.len(text) + 6
end

function console:footer(max_width)
    --  o------o
    local body = string.rep("-", max_width - 2)
    echo(f "o{body}o\n")
end

return console