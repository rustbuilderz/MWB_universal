local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

local espBoxes = {}
local settings = {
    espEnabled = true,
    nameEnabled = true,
    tracerEnabled = true,
    distanceEnabled = true
}

local function CreateESP(player)
    if player == Players.LocalPlayer then return end
    if espBoxes[player] then return end

    espBoxes[player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        Distance = Drawing.new("Text")
    }

    local esp = espBoxes[player]

    esp.Box.Color = Color3.fromRGB(255, 0, 0)
    esp.Box.Thickness = 2
    esp.Box.Filled = false
    esp.Box.Visible = false

    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Name.Size = 18
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Visible = false

    esp.Tracer.Color = Color3.fromRGB(0, 255, 0)
    esp.Tracer.Thickness = 1.5
    esp.Tracer.Visible = false

    esp.Distance.Color = Color3.fromRGB(0, 255, 255)
    esp.Distance.Size = 16
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Visible = false
end

local function UpdateESP(player)
    local esp = espBoxes[player]
    if not esp then return end

    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        esp.Box.Visible = false
        esp.Name.Visible = false
        esp.Tracer.Visible = false
        esp.Distance.Visible = false
        return
    end

    local hrp = player.Character.HumanoidRootPart
    local screenPosition, onScreen = Camera:WorldToViewportPoint(hrp.Position)

    if onScreen and settings.espEnabled then
        local distance = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
        local size = math.clamp(3000 / distance, 30, 120)

        esp.Box.Size = Vector2.new(size, size * 2)
        esp.Box.Position = Vector2.new(screenPosition.X - size / 2, screenPosition.Y - size)
        esp.Box.Visible = settings.espEnabled

        esp.Name.Text = player.Name
        esp.Name.Position = Vector2.new(screenPosition.X, screenPosition.Y - size - 15)
        esp.Name.Visible = settings.nameEnabled

        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        esp.Tracer.To = Vector2.new(screenPosition.X, screenPosition.Y)
        esp.Tracer.Visible = settings.tracerEnabled

        esp.Distance.Text = tostring(distance) .. " studs"
        esp.Distance.Position = Vector2.new(screenPosition.X, screenPosition.Y + size / 2 + 5)
        esp.Distance.Visible = settings.distanceEnabled
    else
        esp.Box.Visible = false
        esp.Name.Visible = false
        esp.Tracer.Visible = false
        esp.Distance.Visible = false
    end
end

local function RemoveESP(player)
    if espBoxes[player] then
        for _, element in pairs(espBoxes[player]) do
            element:Remove()
        end
        espBoxes[player] = nil
    end
end

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if not espBoxes[player] then
            CreateESP(player)
        end
        UpdateESP(player)
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)
