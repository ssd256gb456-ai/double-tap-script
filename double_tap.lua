-- PUZAN LUA CHEAT - ULTIMATE EDITION
-- Developed by Puzan Team

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera

-- Уведомление о загрузке
print("╔════════════════════════════════════════╗")
print("║           PUZAN LUA LOADED!           ║")
print("║           ULTIMATE EDITION            ║")
print("║        Press INSERT for Menu          ║")
print("╚════════════════════════════════════════╝")

-- Настройки
local currentBind = Enum.UserInputType.MouseButton1
local listeningForBind = false
local lastActionTime = 0
local actionCooldown = 0.3
local isProcessing = false
local teleportDistance = 10

-- ESP Settings
local espEnabled = false
local espBox = false
local espName = false
local espHealth = false
local espMoney = false
local espDistance = 100
local espObjects = {}

-- Aimbot Settings
local aimbotEnabled = false
local aimbotKey = Enum.KeyCode.LeftAlt
local aimbotFOV = 100
local aimbotSmoothness = 0.2
local showFOV = false
local aimbotThread = nil

-- Third Person
local thirdPersonEnabled = false
local thirdPersonDistance = 10

-- Rage Bot
local rageBotEnabled = false
local silentAim = false
local resolver = false
local autoWall = false

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PUZANLUA_SYSTEM"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- FOV Circle
local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.Size = UDim2.new(0, aimbotFOV * 2, 0, aimbotFOV * 2)
fovCircle.Position = UDim2.new(0.5, -aimbotFOV, 0.5, -aimbotFOV)
fovCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderColor3 = Color3.fromRGB(255, 0, 0)
fovCircle.BorderSizePixel = 2
fovCircle.Visible = showFOV
fovCircle.Parent = screenGui

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

-- Main Menu
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 500)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "PUZAN LUA - ULTIMATE EDITION"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

-- Tabs
local tabs = {"AIMBOT", "VISUALS", "RAGE", "MOVEMENT"}
local currentTab = "AIMBOT"

-- Function to create button
local function createButton(name, position, size, callback)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = name
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.Parent = mainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    return button
end

-- Function to create checkbox
local function createCheckbox(name, position, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 25)
    frame.Position = position
    frame.BackgroundTransparency = 1
    frame.Parent = mainFrame
    
    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 20, 0, 20)
    checkbox.Position = UDim2.new(0, 0, 0, 0)
    checkbox.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    checkbox.Text = ""
    checkbox.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = checkbox
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 170, 0, 20)
    label.Position = UDim2.new(0, 25, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = name
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    checkbox.MouseButton1Click:Connect(function()
        local newState = not (checkbox.BackgroundColor3 == Color3.fromRGB(0, 255, 0))
        checkbox.BackgroundColor3 = newState and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        callback(newState)
    end)
    
    return checkbox
end

-- Function to create slider
local function createSlider(name, position, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 40)
    frame.Position = position
    frame.BackgroundTransparency = 1
    frame.Parent = mainFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 15)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = name .. ": " .. default
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 10)
    slider.Position = UDim2.new(0, 0, 0, 20)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    slider.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 5)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    fill.Parent = slider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 5)
    fillCorner.Parent = fill
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = slider
    
    button.MouseButton1Down:Connect(function()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local mouse = UserInputService:GetMouseLocation()
            local relativeX = math.clamp((mouse.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * relativeX
            value = math.floor(value)
            fill.Size = UDim2.new(relativeX, 0, 1, 0)
            label.Text = name .. ": " .. value
            callback(value)
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end)
    end)
    
    return slider
end

-- Create UI Elements
local yOffset = 50

-- Aimbot Tab
createCheckbox("Enable Aimbot", UDim2.new(0, 20, 0, yOffset), aimbotEnabled, function(state)
    aimbotEnabled = state
    print("Aimbot:", state)
end)

createCheckbox("Show FOV", UDim2.new(0, 20, 0, yOffset + 30), showFOV, function(state)
    showFOV = state
    fovCircle.Visible = state
end)

createSlider("Aimbot FOV", UDim2.new(0, 20, 0, yOffset + 60), 10, 300, aimbotFOV, function(value)
    aimbotFOV = value
    fovCircle.Size = UDim2.new(0, value * 2, 0, value * 2)
    fovCircle.Position = UDim2.new(0.5, -value, 0.5, -value)
end)

createSlider("Smoothness", UDim2.new(0, 20, 0, yOffset + 110), 1, 100, aimbotSmoothness * 100, function(value)
    aimbotSmoothness = value / 100
end)

-- Visuals Tab
createCheckbox("Enable ESP", UDim2.new(0, 20, 0, yOffset + 160), espEnabled, function(state)
    espEnabled = state
    print("ESP:", state)
end)

createCheckbox("ESP Box", UDim2.new(0, 20, 0, yOffset + 190), espBox, function(state)
    espBox = state
end)

createCheckbox("ESP Name", UDim2.new(0, 20, 0, yOffset + 220), espName, function(state)
    espName = state
end)

createCheckbox("ESP Health", UDim2.new(0, 20, 0, yOffset + 250), espHealth, function(state)
    espHealth = state
end)

createSlider("ESP Distance", UDim2.new(0, 20, 0, yOffset + 280), 10, 500, espDistance, function(value)
    espDistance = value
end)

createCheckbox("Third Person", UDim2.new(0, 20, 0, yOffset + 330), thirdPersonEnabled, function(state)
    thirdPersonEnabled = state
    updateThirdPerson()
end)

createSlider("Third Person Distance", UDim2.new(0, 20, 0, yOffset + 360), 5, 50, thirdPersonDistance, function(value)
    thirdPersonDistance = value
    updateThirdPerson()
end)

-- Rage Tab
createCheckbox("Rage Bot", UDim2.new(0, 20, 0, yOffset + 410), rageBotEnabled, function(state)
    rageBotEnabled = state
    print("Rage Bot:", state)
end)

createCheckbox("Silent Aim", UDim2.new(0, 20, 0, yOffset + 440), silentAim, function(state)
    silentAim = state
end)

createCheckbox("Resolver", UDim2.new(0, 20, 0, yOffset + 470), resolver, function(state)
    resolver = state
end)

createCheckbox("Auto Wall", UDim2.new(0, 20, 0, yOffset + 500), autoWall, function(state)
    autoWall = state
end)

-- Movement Tab
createCheckbox("Enable Teleport", UDim2.new(0, 240, 0, yOffset), true, function(state)
    print("Teleport:", state)
end)

createSlider("Teleport Distance", UDim2.new(0, 240, 0, yOffset + 30), 5, 50, teleportDistance, function(value)
    teleportDistance = value
end)

-- Close Button
local closeButton = createButton("CLOSE", UDim2.new(0, 350, 0, 450), UDim2.new(0, 80, 0, 30), function()
    mainFrame.Visible = false
end)

-- Third Person Function
local function updateThirdPerson()
    if thirdPersonEnabled then
        Camera.CameraType = Enum.CameraType.Scriptable
        local character = LocalPlayer.Character
        if character then
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                Camera.CFrame = root.CFrame * CFrame.new(0, 0, thirdPersonDistance)
            end
        end
    else
        Camera.CameraType = Enum.CameraType.Custom
    end
end

-- ESP Function
local function updateESP()
    for _, obj in pairs(espObjects) do
        if obj then obj:Remove() end
    end
    espObjects = {}
    
    if not espEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                if distance <= espDistance then
                    -- Create ESP Box
                    if espBox then
                        local box = Instance.new("BoxHandleAdornment")
                        box.Name = "ESPBox"
                        box.Adornee = rootPart
                        box.AlwaysOnTop = true
                        box.ZIndex = 10
                        box.Size = Vector3.new(4, 6, 4)
                        box.Color3 = Color3.fromRGB(255, 255, 255)
                        box.Transparency = 0.7
                        box.Parent = rootPart
                        table.insert(espObjects, box)
                    end
                    
                    -- Create ESP Name
                    if espName then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "ESPName"
                        billboard.Adornee = rootPart
                        billboard.Size = UDim2.new(0, 100, 0, 50)
                        billboard.StudsOffset = Vector3.new(0, 3, 0)
                        billboard.AlwaysOnTop = true
                        
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.Text = player.Name
                        label.TextColor3 = Color3.fromRGB(255, 255, 255)
                        label.TextStrokeTransparency = 0
                        label.Font = Enum.Font.GothamBold
                        label.TextSize = 14
                        label.Parent = billboard
                        
                        billboard.Parent = rootPart
                        table.insert(espObjects, billboard)
                    end
                    
                    -- Create ESP Health
                    if espHealth then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "ESPHealth"
                        billboard.Adornee = rootPart
                        billboard.Size = UDim2.new(0, 100, 0, 50)
                        billboard.StudsOffset = Vector3.new(0, 2, 0)
                        billboard.AlwaysOnTop = true
                        
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.Text = "HP: " .. math.floor(humanoid.Health)
                        label.TextColor3 = Color3.fromRGB(0, 255, 0)
                        label.TextStrokeTransparency = 0
                        label.Font = Enum.Font.GothamBold
                        label.TextSize = 12
                        label.Parent = billboard
                        
                        billboard.Parent = rootPart
                        table.insert(espObjects, billboard)
                    end
                end
            end
        end
    end
end

-- Aimbot Function
local function aimbotLoop()
    while aimbotEnabled do
        if UserInputService:IsKeyDown(aimbotKey) then
            local closestPlayer = nil
            local closestDistance = aimbotFOV
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local character = player.Character
                    local humanoid = character:FindFirstChild("Humanoid")
                    local head = character:FindFirstChild("Head")
                    
                    if humanoid and humanoid.Health > 0 and head then
                        local screenPoint = Camera:WorldToViewportPoint(head.Position)
                        local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
            
            if closestPlayer then
                local targetHead = closestPlayer.Character.Head
                local currentCFrame = Camera.CFrame
                local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetHead.Position)
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, aimbotSmoothness)
            end
        end
        wait()
    end
end

-- Teleport Function
local function teleportForward()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            local direction = rootPart.CFrame.LookVector
            rootPart.CFrame = rootPart.CFrame + direction * teleportDistance
        end
    end
end

-- Input Handlers
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Menu Toggle
    if input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
        print("Menu:", mainFrame.Visible and "OPENED" or "CLOSED")
    end
    
    -- Teleport
    if input.UserInputType == currentBind then
        teleportForward()
    end
end)

-- Start Loops
coroutine.wrap(function()
    while true do
        updateESP()
        wait(0.1)
    end
end)()

coroutine.wrap(function()
    while true do
        if aimbotEnabled then
            aimbotLoop()
        end
        wait()
    end
end)()

print("╔════════════════════════════════════════╗")
print("║          SYSTEM READY!                ║")
print("║        INSERT - Open Menu             ║")
print("║        LMB - Teleport                 ║")
print("║        LeftAlt - Aimbot               ║")
print("╚════════════════════════════════════════╝")
