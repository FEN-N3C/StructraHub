-- ui.lua
local UI = {}

-- Load Fluent and Addons
local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()
local SaveManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"
))()
local InterfaceManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
))()

function UI.Init(Config)
    -- Create Window
    local Window = Fluent:CreateWindow({
        Title = "AxisHub",
        SubTitle = "internal",
        Size = UDim2.fromOffset(580, 460), -- REQUIRED
        Theme = "Dark",
        Acrylic = true,
        TabWidth = 160,
        MinimizeKey = Enum.KeyCode.LeftControl
    })

    -- Create Tabs
    local Tabs = {
        Main = Window:AddTab({ Title = "Aimbot", Icon = "crosshair" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    local Options = Fluent.Options

    local AimKeybind = Tabs.Main:AddKeybind("AimKey", {
        Title = "Aim Key",
        Mode = "Hold",
        Default = "MouseRight",
    })
    
    local Toggle = Tabs.Main:AddToggle("Enabled", {
        Title = "Aimbot",
        Default = Config.Enabled
    })
    Toggle:OnChanged(function(v)
        Config.Enabled = v
    end)
    Options.Enabled:SetValue(Config.Enabled)

    -- TeamCheck Toggle
    local TeamToggle = Tabs.Main:AddToggle("TeamCheck", {
        Title = "Team Check",
        Default = Config.TeamCheck
    })
    TeamToggle:OnChanged(function(v)
        Config.TeamCheck = v
    end)
    Options.TeamCheck:SetValue(Config.TeamCheck)

    -- DeadCheck Toggle
    local DeadToggle = Tabs.Main:AddToggle("DeadCheck", {
        Title = "Dead Check",
        Default = Config.DeadCheck
    })
    DeadToggle:OnChanged(function(v)
        Config.DeadCheck = v
    end)
    Options.DeadCheck:SetValue(Config.DeadCheck)

    -- WallCheck Toggle
    local WallToggle = Tabs.Main:AddToggle("WallCheck", {
        Title = "Wall Check",
        Default = Config.WallCheck
    })
    WallToggle:OnChanged(function(v)
        Config.WallCheck = v
    end)
    Options.WallCheck:SetValue(Config.WallCheck)

    -- Prediction Slider
    local PredictionSlider = Tabs.Main:AddSlider("Prediction", {
        Title = "Prediction",
        Description = "How far ahead to predict",
        Min = 0,
        Max = 1,
        Rounding = 2,
        Default = Config.Prediction
    })
    PredictionSlider:OnChanged(function(v)
        Config.Prediction = tonumber(v)
    end)
    PredictionSlider:SetValue(Config.Prediction)

    -- LockType Dropdown
    local LockDropdown = Tabs.Main:AddDropdown("LockType", {
        Title = "Lock Type",
        Values = { "ClosestToCursor", "ClosestToPlayer" },
        Multi = false,
        Default = Config.LockType == "ClosestToCursor" and 1 or 2
    })
    LockDropdown:OnChanged(function(v)
        Config.LockType = v
    end)
    LockDropdown:SetValue(Config.LockType)

    -- Lock Part Dropdown
    local PartDropdown = Tabs.Main:AddDropdown("LockPart", {
        Title = "Lock Part",
        Values = { "HumanoidRootPart", "Head" },
        Multi = false,
        Default = Config.LockPart == "HumanoidRootPart" and 1 or 2
    })
    PartDropdown:OnChanged(function(v)
        Config.LockPart = v
    end)
    PartDropdown:SetValue(Config.LockPart)

    local RandomToggle = Tabs.Main:AddToggle("RandomizePart", {
        Title = "Randomize Part",
        Default = Config.RandomizePart
    })
    RandomToggle:OnChanged(function(v)
        Config.RandomizePart = v
    end)
    Options.RandomizePart:SetValue(Config.RandomizePart)

    local RandomInterval = Tabs.Main:AddSlider("RandomizeInterval", {
        Title = "Randomize Interval",
        Description = "Seconds between random part switches",
        Min = 0.1,
        Max = 5,
        Rounding = 1,
        Default = Config.RandomizeInterval
    })
    RandomInterval:OnChanged(function(v)
        Config.RandomizeInterval = tonumber(v)
    end)
    RandomInterval:SetValue(Config.RandomizeInterval)
    
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)

    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})

    InterfaceManager:SetFolder("AxisHub")
    SaveManager:SetFolder("AxisHub/GameConfig")

    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)

    -- Select first tab by default
    Window:SelectTab(1)

    -- Notify user
    Fluent:Notify({
        Title = "AxisHub",
        Content = "UI loaded successfully!",
        Duration = 5
    })
end

return UI
