local Aimbot = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ===== Utility =====

local function IsAlive(character)
	local hum = character:FindFirstChildOfClass("Humanoid")
	return hum and hum.Health > 0
end

local function IsVisible(origin, target)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = { LocalPlayer.Character }

	local result = workspace:Raycast(origin, target - origin, params)
	return result == nil
end

local function WorldToScreen(pos)
	local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
	return Vector2.new(screenPos.X, screenPos.Y), onScreen
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

		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then continue end

		if Config.WallCheck then
			if not IsVisible(Camera.CFrame.Position, root.Position) then
				continue
			end
		end

		local distance
		if Config.LockType == "ClosestToPlayer" then
			distance = (Camera.CFrame.Position - root.Position).Magnitude
		else
			local screenPos, onScreen = WorldToScreen(root.Position)
			if not onScreen then continue end
			distance = (screenPos - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
		end

		if distance < shortest then
			shortest = distance
			closest = root
		end
	end

	return closest
end

-- ===== Main Loop =====

function Aimbot.Start(Config)
	RunService.RenderStepped:Connect(function()
		if not Config.Enabled then return end
		if not LocalPlayer.Character then return end

		local target = GetClosestTarget(Config)
		if not target then return end

		local velocity = target.AssemblyLinearVelocity
		local predictedPosition = target.Position + (velocity * Config.Prediction)

		Camera.CFrame = CFrame.new(
			Camera.CFrame.Position,
			predictedPosition
		)
	end)
end

return Aimbot
