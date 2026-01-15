-- esp.lua
local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Cache = {}

-- Create or get drawing objects for a player
local function getCache(player)
    if not Cache[player] then
        Cache[player] = {}
        local c = Cache[player]

        c.Box = Drawing.new("Square")
        c.Box.Thickness = 1
        c.Box.Filled = false
        c.Box.Color = Color3.new(1,1,1)
        c.Box.Transparency = 1

        c.Name = Drawing.new("Text")
        c.Name.Center = true
        c.Name.Outline = true
        c.Name.Color = Color3.new(1,1,1)
        c.Name.Transparency = 1

        c.Health = Drawing.new("Line")
        c.Health.Thickness = 2
        c.Health.Transparency = 1

        c.Distance = Drawing.new("Text")
        c.Distance.Center = true
        c.Distance.Outline = true
        c.Distance.Color = Color3.new(1,1,1)
        c.Distance.Transparency = 1

        c.Tracer = Drawing.new("Line")
        c.Tracer.Thickness = 1
        c.Tracer.Transparency = 1

        c.HeadDot = Drawing.new("Circle")
        c.HeadDot.Thickness = 1
        c.HeadDot.Radius = 6
        c.HeadDot.Filled = false
        c.HeadDot.Transparency = 1
    end
    return Cache[player]
end

-- Hide all drawings
local function hideAll(player)
    local c = Cache[player]
    if not c then return end
    for _, obj in pairs(c) do
        obj.Visible = false
    end
end

function ESP.Start(Config)
    RunService.RenderStepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then
                hideAll(player)
                continue
            end

            local char = player.Character
            if not char or not char.Parent or (char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health <= 0) then
                hideAll(player)
                continue
            end

            local root = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            if not root or not head then
                hideAll(player)
                continue
            end

            local rootPos, rootOnScreen = Camera:WorldToViewportPoint(root.Position)
            local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,1,0))

            if not rootOnScreen and not headOnScreen then
                hideAll(player)
                continue
            end

            local draw = getCache(player)

            -- BOX
            if Config.ESPEnabled and Config.ESPBoxes then
                local height = math.clamp((rootPos.Y - headPos.Y) * 2, 0, 300)
                draw.Box.Size = Vector2.new(height/1.5, height)
                draw.Box.Position = Vector2.new(rootPos.X - height/3, headPos.Y)
                draw.Box.Visible = true
            else
                draw.Box.Visible = false
            end

            -- NAME
            if Config.ESPEnabled and Config.ESPNames then
                draw.Name.Text = player.Name
                draw.Name.Position = Vector2.new(rootPos.X, headPos.Y - 14)
                draw.Name.Visible = true
            else
                draw.Name.Visible = false
            end

            -- HEALTH BAR
            if Config.ESPEnabled and Config.ESPHealthbars then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)

                    local barHeight = draw.Box.Size.Y
                    local barX = draw.Box.Position.X - 6
                    local barTop = draw.Box.Position.Y
                    local barBottom = barTop + barHeight

                    draw.Health.From = Vector2.new(barX, barBottom)
                    draw.Health.To = Vector2.new(
                        barX,
                        barBottom - (barHeight * hpPercent)
                    )

                    draw.Health.Color = Color3.new(1 - hpPercent, hpPercent, 0)
                    draw.Health.Visible = true
                else
                    draw.Health.Visible = false
                end
            else
                draw.Health.Visible = false
            end
                
            -- DISTANCE
            if Config.ESPEnabled and Config.ESPDistance then
                local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude)
                draw.Distance.Text = dist .. " studs"
                draw.Distance.Position = Vector2.new(rootPos.X, rootPos.Y + 25)
                draw.Distance.Visible = true
            else
                draw.Distance.Visible = false
            end

            -- TRACERS
            if Config.ESPEnabled and Config.ESPTracers then
                draw.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                draw.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                draw.Tracer.Visible = true
            else
                draw.Tracer.Visible = false
            end

            -- HEADBOX
            if Config.ESPEnabled and Config.ESPHeadbox then
                draw.HeadDot.Position = Vector2.new(headPos.X, headPos.Y)
                draw.HeadDot.Visible = true
            else
                draw.HeadDot.Visible = false
            end
        end
    end)
end

Players.PlayerRemoving:Connect(function(player)
    local c = Cache[player]
    if c then
        for _, obj in pairs(c) do
            obj:Remove()
        end
        Cache[player] = nil
    end
end)

return ESP
