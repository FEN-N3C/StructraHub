local ESP = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- Drawing cache
local Objects = {}

-- ===== UTIL =====

local function NewDrawing(type, props)
    local obj = Drawing.new(type)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

local function Clear(player)
    if Objects[player] then
        for _, obj in pairs(Objects[player]) do
            obj:Remove()
        end
        Objects[player] = nil
    end
end

local function CharacterAlive(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

-- ===== CREATE ESP =====

local function Create(player)
    Objects[player] = {
        Box = NewDrawing("Square", {
            Thickness = 1,
            Filled = false,
            Color = Color3.fromRGB(255, 255, 255),
            Visible = false
        }),

        Name = NewDrawing("Text", {
            Size = 13,
            Center = true,
            Outline = true,
            Color = Color3.fromRGB(255, 255, 255),
            Visible = false
        }),

        HealthBar = NewDrawing("Line", {
            Thickness = 2,
            Color = Color3.fromRGB(0, 255, 0),
            Visible = false
        }),

        Distance = NewDrawing("Text", {
            Size = 13,
            Center = true,
            Outline = true,
            Color = Color3.fromRGB(255, 255, 255),
            Visible = false
        }),

        Tracer = NewDrawing("Line", {
            Thickness = 1,
            Color = Color3.fromRGB(255, 255, 255),
            Visible = false
        }),

        Head = NewDrawing("Circle", {
            Radius = 6,
            Thickness = 1,
            Filled = false,
            Color = Color3.fromRGB(255, 255, 255),
            Visible = false
        })
    }
end

-- ===== UPDATE LOOP =====

function ESP.Start(Config)
    RunService.RenderStepped:Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then
                Clear(player)
                continue
            end

            local char = player.Character
            if not Config.ESPEnabled or not char or not CharacterAlive(char) then
                Clear(player)
                continue
            end

            if not Objects[player] then
                Create(player)
            end

            local root = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not root or not head or not hum then
                Clear(player)
                continue
            end

            local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position)

            if not onScreen then
                for _, obj in pairs(Objects[player]) do
                    obj.Visible = false
                end
                continue
            end

            local height = math.clamp((rootPos.Y - headPos.Y) * 2, 2, 300)
            local width = height / 1.5
            local x = rootPos.X - width / 2
            local y = headPos.Y

            -- BOX
            local box = Objects[player].Box
            box.Visible = Config.ESPBoxes
            box.Position = Vector2.new(x, y)
            box.Size = Vector2.new(width, height)

            -- NAME
            local name = Objects[player].Name
            name.Visible = Config.ESPNames
            name.Text = player.Name
            name.Position = Vector2.new(rootPos.X, y - 14)

            -- HEALTHBAR
            local hb = Objects[player].HealthBar
            hb.Visible = Config.ESPHealthbars
            local hp = hum.Health / hum.MaxHealth
            hb.From = Vector2.new(x - 4, y + height)
            hb.To = Vector2.new(x - 4, y + height - (height * hp))
            hb.Color = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)

            -- DISTANCE
            local dist = Objects[player].Distance
            dist.Visible = Config.ESPDistance
            local studs = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
            dist.Text = studs .. " studs"
            dist.Position = Vector2.new(rootPos.X, y + height + 2)

            -- TRACER
            local tracer = Objects[player].Tracer
            tracer.Visible = Config.ESPTracers
            tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            tracer.To = Vector2.new(rootPos.X, rootPos.Y)

            -- HEADBOX
            local headbox = Objects[player].Head
            headbox.Visible = Config.ESPHeadbox
            headbox.Position = Vector2.new(headPos.X, headPos.Y)
        end
    end)
end

return ESP
