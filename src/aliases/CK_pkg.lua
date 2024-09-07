local ck = require("__PKGNAME__")
local console = require("__PKGNAME__.console")
local mode = matches[2] or "help"
local args = (matches[3] or ""):split(" ")

-- This list might have to grow in time
local submodules = {"Chat", "Map"}

local function get_install_url(fullname)
    local shortname = fullname
    -- Are we talking about the main package or a subpackage
    if shortname:find("-") then
        shortname = fullname:split("-")[2]
    end
    local url = f "https://github.com/CKMud-Mudlet-Scripts/{shortname}/releases/latest/download/{fullname}.mpackage"
    return url
end

local functions = {}

function functions.help()
    print("CK pkg install <chat|map> - install extra like map/chat")
    print("CK pkg upgrade <name> - upgrade a named package")
    print("CK pkg upgrade all - upgrade all packages")
    print("CK pkg versions - list all packages")
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
    fullname = f "CK-{name}"
    if table.contains(submodules, name) then
        if ck:installed_module(fullname) == nil then
            local url = get_install_url(fullname)
            installPackage(url)
        else
            print("Already Installed")
        end
    else
        print(f "No Such Package {name}")
    end
end

function functions.update(name, version)
    local function upgrade(package)
        uninstallPackage(package)
        installPackage(get_install_url(package))
    end
    name = name:title()

    if name == "All" then
        for m, v in pairs(ck:get_versions()) do
            upgrade(m)
        end
    else
        local installed = ck:get_versions()
        if installed[name] then
            upgrade(name)
        elseif installed[f "CK-{name}"] then
            upgrade(f "CK-{name}")
        else
            print(f "{name} is not installed!")
        end
    end
end

functions["check-update"] = function()
    echo("To be complete later...")
end

-- Dispatch
functions[mode](unpack(args))
