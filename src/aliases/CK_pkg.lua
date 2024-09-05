local ck = require("__PKGNAME__")
local console = require("__PKGNAME__.console")
local mode = matches[2] or "help"
local args = (matches[3] or ""):split(" ")

-- This list might have to grow in time
local submodules = {"Enoch", "Chat", "Core", "Prime", "Map"}


local function get_install_url(fullname)
    local shortname = fullname
    -- Are we talking about the main package or a subpackage
    if shortname:find("-") then
        shortname = fullname:split("-")[2]
    end
    local url = f"https://github.com/CKMud-Mudlet-Scripts/{shortname}/releases/latest/download/{fullname}.mpackage"
    return url
end


local functions = {}

function functions.help()
  print("TODO Help Screen")
end

function functions.versions()
    local s = console:header("CK pkg versions", 25, "cyan")
    local fmt = "|<GhostWhite>%10s <cyan>: <GhostWhite>%-10s<reset>|\n"
    for m, v in pairs(ck:get_versions()) do
        -- Remove the CK- prefix
        if m:find("CK-", 1, true) then
            m = m:split("-")[2]
        end
        cecho(fmt:format(m, v))
    end
    console:footer(s)
  
end

function functions.install(name, version)
    name = name:title()
    fullname = f"CK-{name}"
    if table.contains(submodules, name) then
        if ck:installed_module(fullname) == nil then
            local url = get_install_url(fullname)
            installPackage(url)
        else
            print("Already Installed")
        end
    else
        print(f"No Such Package {name}")
    end
end

function functions.upgrade(name, version)
    -- uninstallPackage("CKMud-Core")
    -- installPackage("https://github.com/CKMud-Mudlet-Scripts/Core/releases/latest/download/CKMud-Core.mpackage")
end

functions["check-updates"] = function()
end

-- Dispatch
functions[mode](unpack(args))