-- PUZAN LUA DT System + AntiAim - Roblox Studio
-- Вставь в LocalScript в StarterPlayerScripts

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Настройки телепортации
local currentBind = Enum.UserInputType.MouseButton1
local listeningForBind = false
local lastActionTime = 0
local actionCooldown = 0.3
local isProcessing = false
local teleportDistance = 10 -- Увеличено до 10 studs

-- Настройки TrashTalk
local trashTalkEnabled = false
local spamThread = nil
local trashTalkPhrases = {
    "1"
}

-- Настройки AntiAim
local antiAimEnabled = false
local antiAimThread = nil
local antiAimTypes = {
    "Jitter",
    "Spin",
    "Random",
    "Backwards",
    "Sideways"
}
local currentAntiAimType = "Jitter"
local antiAimSpeed = 5
local antiAimIntensity = 30

-- Ждем загрузки игрока
local function waitForPlayer()
    while not LocalPlayer do
        wait(1)
        LocalPlayer = Players.LocalPlayer
    end
end

waitForPlayer()

-- Ждем PlayerGui
local function waitForPlayerGui()
    while not LocalPlayer:FindFirstChild("PlayerGui") do
        wait(1)
    end
end

waitForPlayerGui()

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PUZANLUA_DT_System"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer.PlayerGui

local indicator = Instance.new("TextLabel")
indicator.Name = "DTIndicator"
indicator.Size = UDim2.new(0, 60, 0, 30)
indicator.Position = UDim2.new(0, 10, 0.5, -15)
indicator.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
indicator.TextColor3 = Color3.fromRGB(255, 255, 255)
indicator.Text = "DT"
indicator.Font = Enum.Font.GothamBold
indicator.TextSize = 16
indicator.TextStrokeTransparency = 1
indicator.Visible = true
indicator.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = indicator

-- Основное меню
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 400)
frame.Position = UDim2.new(0.5, -175, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "PUZAN LUA"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

-- Секция телепортации
local teleportSection = Instance.new("TextLabel")
teleportSection.Size = UDim2.new(1, -20, 0, 20)
teleportSection.Position = UDim2.new(0, 10, 0, 35)
teleportSection.BackgroundTransparency = 1
teleportSection.TextColor3 = Color3.fromRGB(200, 200, 200)
teleportSection.Text = "TELEPORT"
teleportSection.Font = Enum.Font.GothamBold
teleportSection.TextSize = 11
teleportSection.TextXAlignment = Enum.TextXAlignment.Left
teleportSection.Parent = frame

local bindLabel = Instance.new("TextLabel")
bindLabel.Size = UDim2.new(1, -20, 0, 20)
bindLabel.Position = UDim2.new(0, 10, 0, 55)
bindLabel.BackgroundTransparency = 1
bindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
bindLabel.Text = "Bind: LMB"
bindLabel.Font = Enum.Font.Gotham
bindLabel.TextSize = 10
bindLabel.TextXAlignment = Enum.TextXAlignment.Left
bindLabel.Parent = frame

local changeBind = Instance.new("TextButton")
changeBind.Size = UDim2.new(1, -20, 0, 25)
changeBind.Position = UDim2.new(0, 10, 0, 75)
changeBind.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
changeBind.TextColor3 = Color3.fromRGB(255, 255, 255)
changeBind.Text = "Change Bind"
changeBind.Font = Enum.Font.Gotham
changeBind.TextSize = 10
changeBind.Parent = frame

local distanceLabel = Instance.new("TextLabel")
distanceLabel.Size = UDim2.new(1, -20, 0, 20)
distanceLabel.Position = UDim2.new(0, 10, 0, 105)
distanceLabel.BackgroundTransparency = 1
distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
distanceLabel.Text = "Distance: 10 studs"
distanceLabel.Font = Enum.Font.Gotham
distanceLabel.TextSize = 10
distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
distanceLabel.Parent = frame

-- Секция TrashTalk
local trashSection = Instance.new("TextLabel")
trashSection.Size = UDim2.new(1, -20, 0, 20)
trashSection.Position = UDim2.new(0, 10, 0, 130)
trashSection.BackgroundTransparency = 1
trashSection.TextColor3 = Color3.fromRGB(200, 200, 200)
trashSection.Text = "TRASHTALK"
trashSection.Font = Enum.Font.GothamBold
trashSection.TextSize = 11
trashSection.TextXAlignment = Enum.TextXAlignment.Left
trashSection.Parent = frame

local trashTalkButton = Instance.new("TextButton")
trashTalkButton.Size = UDim2.new(1, -20, 0, 25)
trashTalkButton.Position = UDim2.new(0, 10, 0, 150)
trashTalkButton.BackgroundColor3 = Color3.fromRGB(80, 80, 160)
trashTalkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
trashTalkButton.Text = "TrashTalk: OFF"
trashTalkButton.Font = Enum.Font.Gotham
trashTalkButton.TextSize = 10
trashTalkButton.Parent = frame

-- Секция AntiAim
local antiAimSection = Instance.new("TextLabel")
antiAimSection.Size = UDim2.new(1, -20, 0, 20)
antiAimSection.Position = UDim2.new(0, 10, 0, 185)
antiAimSection.BackgroundTransparency = 1
antiAimSection.TextColor3 = Color3.fromRGB(200, 200, 200)
antiAimSection.Text = "ANTIAIM"
antiAimSection.Font = Enum.Font.GothamBold
antiAimSection.TextSize = 11
antiAimSection.TextXAlignment = Enum.TextXAlignment.Left
antiAimSection.Parent = frame

local antiAimButton = Instance.new("TextButton")
antiAimButton.Size = UDim2.new(1, -20, 0, 25)
antiAimButton.Position = UDim2.new(0, 10, 0, 205)
antiAimButton.BackgroundColor3 = Color3.fromRGB(160, 80, 80)
antiAimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
antiAimButton.Text = "AntiAim: OFF"
antiAimButton.Font = Enum.Font.Gotham
antiAimButton.TextSize = 10
antiAimButton.Parent = frame

local antiAimTypeLabel = Instance.new("TextLabel")
antiAimTypeLabel.Size = UDim2.new(1, -20, 0, 20)
antiAimTypeLabel.Position = UDim2.new(0, 10, 0, 235)
antiAimTypeLabel.BackgroundTransparency = 1
antiAimTypeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
antiAimTypeLabel.Text = "Type: Jitter"
antiAimTypeLabel.Font = Enum.Font.Gotham
antiAimTypeLabel.TextSize = 10
antiAimTypeLabel.TextXAlignment = Enum.TextXAlignment.Left
antiAimTypeLabel.Parent = frame

local changeAntiAimType = Instance.new("TextButton")
changeAntiAimType.Size = UDim2.new(1, -20, 0, 25)
changeAntiAimType.Position = UDim2.new(0, 10, 0, 255)
changeAntiAimType.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
changeAntiAimType.TextColor3 = Color3.fromRGB(255, 255, 255)
changeAntiAimType.Text = "Change Type"
changeAntiAimType.Font = Enum.Font.Gotham
changeAntiAimType.TextSize = 10
changeAntiAimType.Parent = frame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -20, 0, 20)
speedLabel.Position = UDim2.new(0, 10, 0, 285)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Text = "Speed: 5"
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 10
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = frame

local increaseSpeed = Instance.new("TextButton")
increaseSpeed.Size = UDim2.new(0.48, -10, 0, 20)
increaseSpeed.Position = UDim2.new(0, 10, 0, 305)
increaseSpeed.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
increaseSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
increaseSpeed.Text = "+ Speed"
increaseSpeed.Font = Enum.Font.Gotham
increaseSpeed.TextSize = 9
increaseSpeed.Parent = frame

local decreaseSpeed = Instance.new("TextButton")
decreaseSpeed.Size = UDim2.new(0.48, -10, 0, 20)
decreaseSpeed.Position = UDim2.new(0.52, 0, 0, 305)
decreaseSpeed.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
decreaseSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
decreaseSpeed.Text = "- Speed"
decreaseSpeed.Font = Enum.Font.Gotham
decreaseSpeed.TextSize = 9
decreaseSpeed.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(1, -20, 0, 25)
closeButton.Position = UDim2.new(0, 10, 0, 335)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "Close Menu"
closeButton.Font = Enum.Font.Gotham
closeButton.TextSize = 10
closeButton.Parent = frame

-- Добавляем закругления
local function addCorner(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = obj
end

addCorner(changeBind, 4)
addCorner(trashTalkButton, 4)
addCorner(antiAimButton, 4)
addCorner(changeAntiAimType, 4)
addCorner(increaseSpeed, 3)
addCorner(decreaseSpeed, 3)
addCorner(closeButton, 4)

-- Функции TrashTalk
local function getRandomTrashTalk()
    return "1"
end

local function sendToChat(message)
    pcall(function()
        local TextChatService = game:GetService("TextChatService")
        if TextChatService then
            local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if channel then
                channel:SendAsync(message)
                return
            end
        end
        
        local events = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if events then
            local sayMessage = events:FindFirstChild("SayMessageRequest")
            if sayMessage then
                sayMessage:FireServer(message, "All")
            end
        end
    end)
end

local function startSpam()
    while trashTalkEnabled do
        local message = getRandomTrashTalk()
        sendToChat(message)
        wait(0.5)
    end
end

-- Функции AntiAim
local function jitterAntiAim()
    while antiAimEnabled and currentAntiAimType == "Jitter" do
        local character = LocalPlayer.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local randomAngle = math.random(-antiAimIntensity, antiAimIntensity)
                rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(randomAngle), 0)
            end
        end
        wait(1/antiAimSpeed)
    end
end

local function spinAntiAim()
    local angle = 0
    while antiAimEnabled and currentAntiAimType == "Spin" do
        local character = LocalPlayer.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                angle = angle + antiAimSpeed
                rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(angle), 0)
            end
        end
        wait(1/60)
    end
end

local function randomAntiAim()
    while antiAimEnabled and currentAntiAimType == "Random" do
        local character = LocalPlayer.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local randomAngle = math.random(0, 360)
                rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, math.rad(randomAngle), 0)
            end
        end
        wait(1/antiAimSpeed)
    end
end

local function backwardsAntiAim()
    while antiAimEnabled and currentAntiAimType == "Backwards" do
        local character = LocalPlayer.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(180), 0)
            end
        end
        wait(1/antiAimSpeed)
    end
end

local function sidewaysAntiAim()
    while antiAimEnabled and currentAntiAimType == "Sideways" do
        local character = LocalPlayer.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(90), 0)
            end
        end
        wait(1/antiAimSpeed)
    end
end

local function startAntiAim()
    if currentAntiAimType == "Jitter" then
        antiAimThread = coroutine.create(jitterAntiAim)
    elseif currentAntiAimType == "Spin" then
        antiAimThread = coroutine.create(spinAntiAim)
    elseif currentAntiAimType == "Random" then
        antiAimThread = coroutine.create(randomAntiAim)
    elseif currentAntiAimType == "Backwards" then
        antiAimThread = coroutine.create(backwardsAntiAim)
    elseif currentAntiAimType == "Sideways" then
        antiAimThread = coroutine.create(sidewaysAntiAim)
    end
    if antiAimThread then
        coroutine.resume(antiAimThread)
    end
end

-- Функции телепортации
local function checkWallCollision(startPos, endPos)
    local character = LocalPlayer.Character
    if not character then return false, endPos end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character}
    local raycastResult = Workspace:Raycast(startPos, (endPos - startPos), raycastParams)
    if raycastResult then
        return true, raycastResult.Position
    end
    return false, endPos
end

local function getMoveDirection()
    local character = LocalPlayer.Character
    if not character then return Vector3.new(0, 0, 0) end
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return Vector3.new(0, 0, 0) end
    local moveDirection = humanoid.MoveDirection
    if moveDirection.Magnitude < 0.1 then
        moveDirection = rootPart.CFrame.LookVector
    end
    return moveDirection.Unit
end

local function performSingleMove()
    if isProcessing then return end
    isProcessing = true
    local currentTime = tick()
    if currentTime - lastActionTime < actionCooldown then
        isProcessing = false
        return
    end
    lastActionTime = currentTime
    
    -- Анимация индикатора
    local originalColor = indicator.BackgroundColor3
    indicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    wait(0.1)
    indicator.BackgroundColor3 = originalColor
    
    local character = LocalPlayer.Character
    if not character then
        isProcessing = false
        return
    end
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then
        isProcessing = false
        return
    end
    local direction = getMoveDirection()
    if direction.Magnitude < 0.1 then
        isProcessing = false
        return
    end
    local startPos = rootPart.Position
    local endPos = startPos + direction * teleportDistance
    local hitWall, hitPosition = checkWallCollision(startPos, endPos)
    if hitWall then
        local safeDistance = 1.0
        local moveVector = (hitPosition - startPos)
        local moveDistance = math.max(0, moveVector.Magnitude - safeDistance)
        if moveDistance > 0.5 then
            local safePosition = startPos + direction * moveDistance
            rootPart.CFrame = CFrame.new(safePosition, safePosition + direction)
        end
    else
        rootPart.CFrame = CFrame.new(endPos, endPos + direction)
    end
    wait(0.1)
    isProcessing = false
end

-- Обработчики кнопок
changeBind.MouseButton1Click:Connect(function()
    listeningForBind = true
    bindLabel.Text = "Press any key..."
end)

trashTalkButton.MouseButton1Click:Connect(function()
    trashTalkEnabled = not trashTalkEnabled
    if trashTalkEnabled then
        trashTalkButton.Text = "TrashTalk: ON"
        trashTalkButton.BackgroundColor3 = Color3.fromRGB(60, 160, 60)
        spamThread = coroutine.create(startSpam)
        coroutine.resume(spamThread)
    else
        trashTalkButton.Text = "TrashTalk: OFF"
        trashTalkButton.BackgroundColor3 = Color3.fromRGB(80, 80, 160)
    end
end)

antiAimButton.MouseButton1Click:Connect(function()
    antiAimEnabled = not antiAimEnabled
    if antiAimEnabled then
        antiAimButton.Text = "AntiAim: ON"
        antiAimButton.BackgroundColor3 = Color3.fromRGB(60, 160, 60)
        startAntiAim()
    else
        antiAimButton.Text = "AntiAim: OFF"
        antiAimButton.BackgroundColor3 = Color3.fromRGB(160, 80, 80)
    end
end)

changeAntiAimType.MouseButton1Click:Connect(function()
    local currentIndex = 1
    for i, type in ipairs(antiAimTypes) do
        if type == currentAntiAimType then
            currentIndex = i
            break
        end
    end
    currentIndex = currentIndex + 1
    if currentIndex > #antiAimTypes then
        currentIndex = 1
    end
    currentAntiAimType = antiAimTypes[currentIndex]
    antiAimTypeLabel.Text = "Type: " .. currentAntiAimType
end)

increaseSpeed.MouseButton1Click:Connect(function()
    antiAimSpeed = math.min(20, antiAimSpeed + 1)
    speedLabel.Text = "Speed: " .. antiAimSpeed
end)

decreaseSpeed.MouseButton1Click:Connect(function()
    antiAimSpeed = math.max(1, antiAimSpeed - 1)
    speedLabel.Text = "Speed: " .. antiAimSpeed
end)

closeButton.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

-- Обработчики ввода
local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == currentBind then
        performSingleMove()
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Delete then
        frame.Visible = not frame.Visible
    end
    
    if listeningForBind then
        currentBind = input.UserInputType
        local bindName = tostring(input.KeyCode or input.UserInputType):gsub("Enum.%a+%.", "")
        bindLabel.Text = "Bind: " .. bindName
        listeningForBind = false
    end
end)

UserInputService.InputBegan:Connect(onInputBegan)

-- Защита от респавна
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    if not screenGui or not screenGui.Parent then
        screenGui.Parent = LocalPlayer.PlayerGui
    end
end)

print("PUZAN LUA DT + AntiAim System Loaded!")
print("Controls:")
print("- LMB: Teleport 10 studs")
print("- DEL: Toggle Menu")
print("- AntiAim: 5 types with speed control")
print("- TrashTalk: Spams '1' in chat")
