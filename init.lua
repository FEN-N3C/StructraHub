local BASE =
	"https://raw.githubusercontent.com/FEN-N3C/Axis-Hub/main/"

local function Load(file)
	return loadstring(game:HttpGet(BASE .. file))()
end

local Config = Load("config.lua")
local UI = Load("ui.lua")
local Aimbot = Load("aimbot.lua")

UI.Init(Config)
Aimbot.Start(Config)

print("loaded fine")
