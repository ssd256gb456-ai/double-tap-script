local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local currentBind = Enum.UserInputType.MouseButton1
local listeningForBind = false
local lastActionTime = 0
local actionCooldown = 0.3
local isProcessing = false
local trashTalkEnabled = false

local trashTalkPhrases = {
    "fuckpuzan",
    "puzan lua",
    "by puzan team", 
    "puzo",
    "puzan 1488",
    "puzan"
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SingleTapSystem"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

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

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 230)
frame.Position = UDim2.new(0.5, -150, 0.5, -115)
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

local bindLabel = Instance.new("TextLabel")
bindLabel.Size = UDim2.new(1, -20, 0, 25)
bindLabel.Position = UDim2.new(0, 10, 0, 40)
bindLabel.BackgroundTransparency = 1
bindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
bindLabel.Text = "Current Bind: LMB"
bindLabel.Font = Enum.Font.Gotham
bindLabel.TextSize = 12
bindLabel.TextXAlignment = Enum.TextXAlignment.Left
bindLabel.Parent = frame

local changeBind = Instance.new("TextButton")
changeBind.Size = UDim2.new(1, -20, 0, 30)
changeBind.Position = UDim2.new(0, 10, 0, 70)
changeBind.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
changeBind.TextColor3 = Color3.fromRGB(255, 255, 255)
changeBind.Text = "Change Bind"
changeBind.Font = Enum.Font.Gotham
changeBind.TextSize = 12
changeBind.Parent = frame

local bindCorner = Instance.new("UICorner")
bindCorner.CornerRadius = UDim.new(0, 4)
bindCorner.Parent = changeBind

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 110)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Text = "Status: Active"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

local distanceLabel = Instance.new("TextLabel")
distanceLabel.Size = UDim2.new(1, -20, 0, 25)
distanceLabel.Position = UDim2.new(0, 10, 0, 135)
distanceLabel.BackgroundTransparency = 1
distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
distanceLabel.Text = "Distance: 6 studs"
distanceLabel.Font = Enum.Font.Gotham
distanceLabel.TextSize = 12
distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
distanceLabel.Parent = frame

local trashTalkButton = Instance.new("TextButton")
trashTalkButton.Size = UDim2.new(1, -20, 0, 30)
trashTalkButton.Position = UDim2.new(0, 10, 0, 165)
trashTalkButton.BackgroundColor3 = Color3.fromRGB(80, 80, 160)
trashTalkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
trashTalkButton.Text = "TrashTalk: OFF"
trashTalkButton.Font = Enum.Font.Gotham
trashTalkButton.TextSize = 12
trashTalkButton.Parent = frame

local trashCorner = Instance.new("UICorner")
trashCorner.CornerRadius = UDim.new(0, 4)
trashCorner.Parent = trashTalkButton

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(1, -20, 0, 30)
closeButton.Position = UDim2.new(0, 10, 0, 200)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "Close Menu"
closeButton.Font = Enum.Font.Gotham
closeButton.TextSize = 12
closeButton.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeButton

local function getRandomTrashTalk()
    return trashTalkPhrases[math.random(1, #trashTalkPhrases)]
end

local function sendTrashTalk()
    if not trashTalkEnabled then return end
    
    local message = getRandomTrashTalk()
    
    -- Пробуем разные способы открыть чат
    local chatOpenSuccess = false
    
    -- Способ 1: Пробуем найти и активировать поле ввода чата
    pcall(function()
        local coreGui = game:GetService("CoreGui")
        local playerGui = LocalPlayer.PlayerGui
        
        -- Ищем TextBox для чата
        for _, gui in pairs({coreGui, playerGui}) do
            local textBox = gui:FindFirstChildWhichIsA("TextBox", true)
            if textBox and textBox:IsA("TextBox") and textBox.Visible then
                textBox:CaptureFocus()
                chatOpenSuccess = true
                break
            end
        end
    end)
    
    -- Способ 2: Если не нашли, используем горячие клавиши
    if not chatOpenSuccess then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Slash, false, game)
        wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Slash, false, game)
        wait(0.1)
    end
    
    -- Вводим сообщение
    for i = 1, #message do
        local char = message:sub(i, i)
        VirtualInputManager:SendKeyEvent(true, char, false, game)
        VirtualInputManager:SendKeyEvent(false, char, false, game)
        wait(0.01)
    end
    
    -- Отправляем сообщение
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    
    print("[TrashTalk]: " .. message)
end

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
    
    indicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    wait(0.1)
    indicator.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    
    sendTrashTalk()
    
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
    local endPos = startPos + direction * 6
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

local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == currentBind then
        performSingleMove()
    end
end

changeBind.MouseButton1Click:Connect(function()
    listeningForBind = true
    bindLabel.Text = "Press any key..."
    statusLabel.Text = "Status: Listening for bind"
end)

trashTalkButton.MouseButton1Click:Connect(function()
    trashTalkEnabled = not trashTalkEnabled
    if trashTalkEnabled then
        trashTalkButton.Text = "TrashTalk: ON"
        trashTalkButton.BackgroundColor3 = Color3.fromRGB(60, 160, 60)
    else
        trashTalkButton.Text = "TrashTalk: OFF"
        trashTalkButton.BackgroundColor3 = Color3.fromRGB(80, 80, 160)
    end
end)

closeButton.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Delete then
        frame.Visible = not frame.Visible
    end
    
    if listeningForBind then
        currentBind = input.UserInputType
        local bindName = tostring(input.KeyCode or input.UserInputType):gsub("Enum.%a+%.", "")
        bindLabel.Text = "Current Bind: " .. bindName
        statusLabel.Text = "Status: Active"
        listeningForBind = false
    end
end)

UserInputService.InputBegan:Connect(onInputBegan)

print("PUZAN LUA System Ready")
print("LMB = Teleport 6 studs + TrashTalk")
print("DEL = Toggle Menu")
print("TrashTalk works with custom chat systems")
