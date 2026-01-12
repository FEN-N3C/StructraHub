local MODE = "DEV"

local BRANCH = (MODE == "DEV") and "dev" or "main"
local VERSION = (MODE == "DEV") and "V1.2.0" or "V1.1.0"

local BASE = ("https://raw.githubusercontent.com/FEN-N3C/StructraHub/%s/"):format(BRANCH)

local function Load(file)
    local url = BASE .. file
    local source = game:HttpGet(url)

    assert(source and #source > 0, "Failed to fetch " .. file)

    local chunk, err = loadstring(source)
    assert(chunk, "Loadstring failed for " .. file .. ": " .. tostring(err))

    return chunk()
end

local Config = Load("config.lua")
local UI = Load("ui.lua")
local Aimbot = Load("aimbot.lua")

UI.Init(Config)
Aimbot.Start(Config, Fluent.Options)

print(
    MODE == "DEV"
        and ("Successfully loaded StructraHub DEV (%s)!"):format(VERSION)
        or  ("Successfully loaded StructraHub (%s)!"):format(VERSION)
)
