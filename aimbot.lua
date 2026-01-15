local Aimbot = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local lastPartSwitch = 0
local currentRandomPart = "HumanoidRootPart"

local PARTS = { "HumanoidRootPart", "Head" }
local Drawing = Drawing or nil

local function GetMousePosition()
    return UserInputService:GetMouseLocation()
end

local FOVCircle = Drawing and Drawing.new("Circle")
if FOVCircle then
    FOVCircle.Filled = false
    FOVCircle.NumSides = 64
end

local function UpdateFOV(Config)
    if not FOVCircle then return end

    local mousePos = GetMousePosition()

    FOVCircle.Visible = Config.FOVEnabled and Config.FOVVisible
    FOVCircle.Position = mousePos
    FOVCircle.Radius = Config.FOVRadius
    FOVCircle.Thickness = Config.FOVThickness
    FOVCircle.Transparency = math.clamp(Config.FOVOpacity or 1, 0, 1)
    FOVCircle.Color = Config.FOVColor
end

local function IsInsideFOV(screenPos, radius)
    local mousePos = GetMousePosition()
    return (screenPos - mousePos).Magnitude <= radius
end

local function IsAlive(character)
    local hum = character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function HasForceField(character)
    return character:FindFirstChildOfClass("ForceField") ~= nil
end

local function IsFriend(player)
    return LocalPlayer:IsFriendsWith(player.UserId)
end

local function GetRayOrigin()
    return Camera.CFrame.Position + (Camera.CFrame.LookVector * 0.1)
end

local function IsVisible(targetPart, targetCharacter)
    local origin = Camera.CFrame.Position + (Camera.CFrame.LookVector * 0.1)
    local direction = targetPart.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {
        LocalPlayer.Character,
        targetCharacter
    }
    params.IgnoreWater = true

    local result = workspace:Raycast(origin, direction, params)

    if not result then
        return true
    end

    return result.Instance:IsDescendantOf(targetCharacter)
end

local function WorldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

local function GetTargetPart(character, Config)
    local partName = Config.LockPart

    if Config.RandomizePart then
        local now = os.clock()

        if now - lastPartSwitch >= Config.RandomizeInterval then
            lastPartSwitch = now
            partName = PARTS[math.random(#PARTS)]
            currentRandomPart = partName
        else
            partName = currentRandomPart
        end
    end

    return character:FindFirstChild(partName)
end

local function GetClosestTarget(Config)
    local closest
    local shortest = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Config.TeamCheck and player.Team == LocalPlayer.Team then continue end
        if Config.FriendCheck and IsFriend(player) then continue end

        local char = player.Character
        if not char then continue end
        if Config.DeadCheck and not IsAlive(char) then continue end

        local part = GetTargetPart(char, Config)
        if not part then continue end

        if Config.WallCheck and not IsVisible(part, char) then
            continue
        end

        if Config.ForceFieldCheck and HasForceField(char) then
            continue
        end

        local distance
        if Config.LockType == "ClosestToPlayer" then
            distance = (Camera.CFrame.Position - part.Position).Magnitude
        else
            local screenPos, onScreen = WorldToScreen(part.Position)
            if not onScreen then continue end

            if Config.FOVEnabled and not IsInsideFOV(screenPos, Config.FOVRadius) then
                continue
            end

            distance = (screenPos - GetMousePosition()).Magnitude
        end

        if distance < shortest then
            shortest = distance
            closest = part
        end
    end

    return closest
end

function Aimbot.Start(Config, Options)
    RunService.RenderStepped:Connect(function()
        UpdateFOV(Config)

        if not Config.Enabled then return end
        if not Options.AimKey:GetState() then return end
        if not LocalPlayer.Character then return end

        local target = GetClosestTarget(Config)
        if not target then return end

        local velocity = target.AssemblyLinearVelocity
        local predictedPosition = target.Position + (velocity * Config.Prediction)

        Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPosition)
    end)
end

return Aimbot
