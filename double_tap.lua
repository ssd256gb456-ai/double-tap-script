-- NEVERLOSE v1111 - Advanced Anti-Aim Configuration
-- Full Yaw, Jitter, and Fake settings

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Config = {
    -- BunnyHop
    BunnyHop = false,
    BunnyHopSpeed = 1.3,
    
    -- Anti-Aim
    AntiAim = false,
    AntiAimMode = "Yaw",
    
    -- Yaw Settings
    YawEnabled = true,
    YawAngle = 60,
    YawSpeed = 5,
    BodyYaw = "None", -- "None", "Static", "Jitter"
    MoveDirRotation = 1,
    
    -- Jitter Settings
    HeadFakeOffset = 0,
    YawFakeOffset = 0,
    YawJitter = 5,
    HeadJitter = 0,
    FakeRate = 5,
    
    -- ESP
    ESP = false
}

local LocalPlayer = Players.LocalPlayer

-- Advanced GUI with all Anti-Aim settings
local function CreateAdvancedMenu()
    local mainGUI = Instance.new("ScreenGui")
    mainGUI.Name = "Neverlosev1111"
    mainGUI.Parent = CoreGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = mainGUI
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = "NEVERLOSE v1111 - ADVANCED AA"
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = mainFrame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -40)
    scrollFrame.Position = UDim2.new(0, 5, 0, 35)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
    scrollFrame.Parent = mainFrame
    
    -- Toggle function
    local function AddToggle(text, configKey, yPos)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 25)
        button.Position = UDim2.new(0, 0, 0, yPos)
        button.Text = text .. ": " .. (Config[configKey] and "ON" or "OFF")
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(50, 50, 60)
        button.Font = Enum.Font.Gotham
        button.TextSize = 12
        button.Parent = scrollFrame
        
        button.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            button.Text = text .. ": " .. (Config[configKey] and "ON" or "OFF")
            button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(50, 50, 60)
        end)
        
        return yPos + 30
    end

    -- Value selector function
    local function AddValueSelector(text, configKey, values, yPos)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 25)
        button.Position = UDim2.new(0, 0, 0, yPos)
        button.Text = text .. ": " .. tostring(Config[configKey])
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        button.Font = Enum.Font.Gotham
        button.TextSize = 11
        button.Parent = scrollFrame
        
        button.MouseButton1Click:Connect(function()
            local currentIndex = 1
            for i, val in ipairs(values) do
                if tostring(Config[configKey]) == tostring(val) then
                    currentIndex = i
                    break
                end
            end
            
            local nextIndex = (currentIndex % #values) + 1
            Config[configKey] = values[nextIndex]
            button.Text = text .. ": " .. tostring(Config[configKey])
        end)
        
        return yPos + 30
    end

    -- Number selector function
    local function AddNumberSelector(text, configKey, min, max, step, yPos)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 25)
        button.Position = UDim2.new(0, 0, 0, yPos)
        button.Text = text .. ": " .. tostring(Config[configKey])
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
        button.Font = Enum.Font.Gotham
        button.TextSize = 11
        button.Parent = scrollFrame
        
        button.MouseButton1Click:Connect(function()
            local newValue = Config[configKey] + step
            if newValue > max then
                newValue = min
            end
            Config[configKey] = newValue
            button.Text = text .. ": " .. tostring(Config[configKey])
        end)
        
        return yPos + 30
    end

    local yPos = 0
    
    -- BunnyHop Section
    yPos = AddToggle("BunnyHop", "BunnyHop", yPos)
    yPos = AddNumberSelector("BunnyHop Speed", "BunnyHopSpeed", 1.1, 2.0, 0.1, yPos)
    yPos = yPos + 10
    
    -- Anti-Aim Section
    yPos = AddToggle("Anti-Aim", "AntiAim", yPos)
    yPos = AddValueSelector("Anti-Aim Mode", "AntiAimMode", {"Yaw", "Jitter", "HeadDown", "Spin"}, yPos)
    yPos = yPos + 10
    
    -- Yaw Settings Section
    local yawLabel = Instance.new("TextLabel")
    yawLabel.Size = UDim2.new(1, 0, 0, 20)
    yawLabel.Position = UDim2.new(0, 0, 0, yPos)
    yawLabel.Text = "--- Yaw Settings ---"
    yawLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    yawLabel.BackgroundTransparency = 1
    yawLabel.Font = Enum.Font.GothamBold
    yawLabel.TextSize = 12
    yawLabel.Parent = scrollFrame
    yPos = yPos + 25
    
    yPos = AddToggle("Yaw Enabled", "YawEnabled", yPos)
    yPos = AddValueSelector("Body Yaw", "BodyYaw", {"None", "Static", "Jitter"}, yPos)
    yPos = AddNumberSelector("Yaw Angle", "YawAngle", -180, 180, 15, yPos)
    yPos = AddNumberSelector("Yaw Speed", "YawSpeed", 1, 20, 1, yPos)
    yPos = AddNumberSelector("MoveDir Rotation", "MoveDirRotation", 0, 5, 1, yPos)
    yPos = yPos + 10
    
    -- Jitter Settings Section
    local jitterLabel = Instance.new("TextLabel")
    jitterLabel.Size = UDim2.new(1, 0, 0, 20)
    jitterLabel.Position = UDim2.new(0, 0, 0, yPos)
    jitterLabel.Text = "--- Jitter Settings ---"
    jitterLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    jitterLabel.BackgroundTransparency = 1
    jitterLabel.Font = Enum.Font.GothamBold
    jitterLabel.TextSize = 12
    jitterLabel.Parent = scrollFrame
    yPos = yPos + 25
    
    yPos = AddNumberSelector("Head Fake Offset", "HeadFakeOffset", -50, 50, 5, yPos)
    yPos = AddNumberSelector("Yaw Fake Offset", "YawFakeOffset", -50, 50, 5, yPos)
    yPos = AddNumberSelector("Yaw Jitter", "YawJitter", 0, 20, 1, yPos)
    yPos = AddNumberSelector("Head Jitter", "HeadJitter", 0, 20, 1, yPos)
    yPos = AddNumberSelector("Fake Rate", "FakeRate", 1, 10, 1, yPos)
    yPos = yPos + 10
    
    -- ESP Section
    yPos = AddToggle("ESP", "ESP", yPos)
    
    -- Info
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 60)
    info.Position = UDim2.new(0, 0, 0, yPos)
    info.Text = "DEL - Hide/Show Menu\nYaw: Body rotation\nJitter: Rapid angle changes\nFake: Fake head/body positions"
    info.TextColor3 = Color3.fromRGB(150, 150, 200)
    info.BackgroundTransparency = 1
    info.TextSize = 10
    info.Font = Enum.Font.Gotham
    info.Parent = scrollFrame
    
    return mainGUI
end

-- Advanced Anti-Aim with all features
local function StartAdvancedAntiAim()
    local jitterTime = 0
    
    while true do
        if Config.AntiAim and LocalPlayer.Character then
            local character = LocalPlayer.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local root = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            
            if humanoid and root then
                humanoid.AutoRotate = false
                jitterTime = jitterTime + RunService.Heartbeat:Wait()
                
                if Config.AntiAimMode == "Yaw" and Config.YawEnabled then
                    -- Yaw Anti-Aim
                    local baseAngle = Config.YawAngle
                    
                    -- Body Yaw modifications
                    if Config.BodyYaw == "Jitter" then
                        baseAngle = baseAngle + math.sin(jitterTime * Config.YawSpeed) * Config.YawJitter
                    elseif Config.BodyYaw == "Static" then
                        baseAngle = Config.YawAngle
                    end
                    
                    -- Apply Yaw rotation
                    local yawCFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(baseAngle), 0)
                    character:SetPrimaryPartCFrame(yawCFrame)
                    
                elseif Config.AntiAimMode == "Jitter" then
                    -- Jitter Anti-Aim
                    local jitterAngle = math.sin(jitterTime * Config.FakeRate) * Config.YawJitter
                    local headJitter = math.cos(jitterTime * Config.FakeRate) * Config.HeadJitter
                    
                    -- Apply jitter to body
                    character:SetPrimaryPartCFrame(CFrame.new(root.Position) * CFrame.Angles(0, math.rad(jitterAngle), 0))
                    
                    -- Apply jitter to head
                    if head then
                        local headOffset = Config.HeadFakeOffset + headJitter
                        head.CFrame = root.CFrame * CFrame.new(0, 1.5, 0) * CFrame.Angles(math.rad(headOffset), 0, 0)
                    end
                    
                elseif Config.AntiAimMode == "HeadDown" then
                    -- Head Down only
                    character:SetPrimaryPartCFrame(CFrame.new(root.Position))
                    if head then
                        head.CFrame = root.CFrame * CFrame.new(0, 1.5, 0) * CFrame.Angles(math.rad(75), 0, 0)
                    end
                    
                elseif Config.AntiAimMode == "Spin" then
                    -- Spinbot
                    local spin = tick() * Config.YawSpeed
                    character:SetPrimaryPartCFrame(CFrame.new(root.Position) * CFrame.Angles(0, spin, 0))
                end
                
                -- Apply Fake Offsets
                if Config.YawFakeOffset ~= 0 then
                    local currentCFrame = root.CFrame
                    root.CFrame = currentCFrame * CFrame.Angles(0, math.rad(Config.YawFakeOffset), 0)
                end
            end
        end
    end
end

-- BunnyHop with speed boost
local function StartBunnyHop()
    while true do
        if Config.BunnyHop and LocalPlayer.Character then
            local character = LocalPlayer.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            
            if humanoid then
                humanoid.WalkSpeed = 16 * Config.BunnyHopSpeed
                
                if humanoid.MoveDirection.Magnitude > 0 then
                    humanoid.Jump = true
                end
            end
        else
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16
                end
            end
        end
        wait(0.1)
    end
end

-- ESP System
local function StartESP()
    local highlights = {}
    
    while true do
        if Config.ESP then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if not highlights[player] then
                        local highlight = Instance.new("Highlight")
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.8
                        highlight.Parent = player.Character
                        highlights[player] = highlight
                    end
                    highlights[player].Adornee = player.Character
                end
            end
        else
            for player, highlight in pairs(highlights) do
                highlight:Destroy()
            end
            highlights = {}
        end
        wait(0.5)
    end
end

-- Menu toggle
local function SetupToggle(menu)
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Delete then
            menu.Enabled = not menu.Enabled
        end
    end)
end

-- Main injection
local function InjectNeverlose()
    print("NEVERLOSE v1111 Advanced AA Injecting...")
    
    local menu = CreateAdvancedMenu()
    SetupToggle(menu)
    
    coroutine.wrap(StartBunnyHop)()
    coroutine.wrap(StartAdvancedAntiAim)()
    coroutine.wrap(StartESP)()
    
    print("NEVERLOSE v1111 Advanced AA Ready!")
    print("Features: Yaw, Jitter, Fake Offsets, Body Yaw")
    print("Use menu to configure all Anti-Aim settings")
    
    return true
end

-- Safe execute
pcall(InjectNeverlose)
