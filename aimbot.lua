local Aimbot = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ===== Utility =====

local function IsAlive(character)
    local hum = character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function IsVisible(origin, targetPart, targetCharacter)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {
        LocalPlayer.Character,
        targetCharacter
    }

    local direction = targetPart.Position - origin
    local result = workspace:Raycast(origin, direction, params)

    return result == nil
end

local function WorldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

-- ===== Target Part Selection =====

local function GetTargetPart(character, Config)
    if Config.LockPart == "Head" then
        return character:FindFirstChild("Head")
    end
    return character:FindFirstChild("HumanoidRootPart")
end

-- ===== Target Selection =====

local function GetClosestTarget(Config)
    local closest
    local shortest = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Config.TeamCheck and player.Team == LocalPlayer.Team then continue end

        local char = player.Character
        if not char then continue end
        if Config.DeadCheck and not IsAlive(char) then continue end

        local part = GetTargetPart(char, Config)
        if not part then continue end

        if Config.WallCheck and not IsVisible(Camera.CFrame.Position, part.Position) then
            continue
        end

        local distance
        if Config.LockType == "ClosestToPlayer" then
            distance = (Camera.CFrame.Position - part.Position).Magnitude
        else
            local screenPos, onScreen = WorldToScreen(part.Position)
            if not onScreen then continue end
            distance = (screenPos - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
        end

        if distance < shortest then
            shortest = distance
            closest = part
        end
    end

    return closest
end

-- ===== Main Loop =====

function Aimbot.Start(Config, Options)
    RunService.RenderStepped:Connect(function()
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
