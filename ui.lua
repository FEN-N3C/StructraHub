local UserInputService = game:GetService("UserInputService")

local UI = {}

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
    local Window = Fluent:CreateWindow({
        Title = "StructraHub",
        SubTitle = "V1.1.0",
        Size = UDim2.fromOffset(580, 460),
        Theme = "Dark",
        Acrylic = true,
        TabWidth = 160,
        MinimizeKey = Enum.KeyCode.LeftControl
    })

    local Tabs = {
        Main = Window:AddTab({ Title = "Aimbot", Icon = "crosshair" }),
        FOV = Window:AddTab({ Title = "FOV", Icon = "circle-dot" }),
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

    -- i gonna kill myself bro
    --local AimbotKeybind = Tabs.Main:AddKeybind("AimbotToggleKey", {
        --Title = "Toggle Aimbot",
        --Mode = "Press",  -- triggers callback on each key press
        --Default = "None",
    --})

    --AimbotKeybind:OnChanged(function()
        --local newState = not Config.Enabled
        --Toggle:SetValue(newState) -- updates UI + Config

        --Fluent:Notify({
            --Title = "Aimbot",
            --Content = newState and "Enabled" or "Disabled",
            --Duration = 1.5
        --})
    --end)

    local TeamToggle = Tabs.Main:AddToggle("TeamCheck", {
        Title = "Team Check",
        Description = "Don't toggle if teams are not present",
        Default = Config.TeamCheck
    })
    TeamToggle:OnChanged(function(v)
        Config.TeamCheck = v
    end)

    local DeadToggle = Tabs.Main:AddToggle("DeadCheck", {
        Title = "Dead Check",
        Default = Config.DeadCheck
    })
    DeadToggle:OnChanged(function(v)
        Config.DeadCheck = v
    end)

    local WallToggle = Tabs.Main:AddToggle("WallCheck", {
        Title = "Wall Check",
        Default = Config.WallCheck
    })
    WallToggle:OnChanged(function(v)
        Config.WallCheck = v
    end)

    local FriendToggle = Tabs.Main:AddToggle("FriendCheck", {
        Title = "Friend Check",
        Default = Config.FriendCheck
    })

    FriendToggle:OnChanged(function(v)
        Config.FriendCheck = v
    end)

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

    local FOVToggle = Tabs.FOV:AddToggle("FOVEnabled", {
        Title = "Enable FOV",
        Description = "Only lock onto players inside FOV",
        Default = Config.FOVEnabled
    })
    FOVToggle:OnChanged(function(v)
        Config.FOVEnabled = v
    end)

    local FOVVisualToggle = Tabs.FOV:AddToggle("FOVVisible", {
        Title = "Visual FOV",
        Default = Config.FOVVisible
    })
    FOVVisualToggle:OnChanged(function(v)
        Config.FOVVisible = v
    end)

    local FOVRadiusSlider = Tabs.FOV:AddSlider("FOVRadius", {
        Title = "Radius",
        Min = 25,
        Max = 500,
        Rounding = 0,
        Default = Config.FOVRadius
    })
    FOVRadiusSlider:OnChanged(function(v)
        Config.FOVRadius = tonumber(v)
    end)

    local FOVThicknessSlider = Tabs.FOV:AddSlider("FOVThickness", {
        Title = "Thickness",
        Min = 1,
        Max = 10,
        Rounding = 0,
        Default = Config.FOVThickness
    })
    FOVThicknessSlider:OnChanged(function(v)
        Config.FOVThickness = tonumber(v)
    end)

    local FOVOpacitySlider = Tabs.FOV:AddSlider("FOVOpacity", {
        Title = "Opacity",
        Min = 0,
        Max = 1,
        Rounding = 2,
        Default = Config.FOVOpacity
    })
    FOVOpacitySlider:OnChanged(function(v)
        Config.FOVOpacity = tonumber(v) or 1
    end)

    local FOVColorPicker = Tabs.FOV:AddColorpicker("FOVColor", {
        Title = "Color",
        Default = Config.FOVColor
    })
    FOVColorPicker:OnChanged(function(v)
        Config.FOVColor = v
    end)
    
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)

    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})

    InterfaceManager:SetFolder("StructraHub")
    SaveManager:SetFolder("StructraHub/GameConfig")

    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)

    Window:SelectTab(1)

    Fluent:Notify({
        Title = "StructraHub",
        Content = "UI loaded successfully!",
        Duration = 5
    })
end

return UI
