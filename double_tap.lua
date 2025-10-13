local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local currentBind = Enum.UserInputType.MouseButton1
local listeningForBind = false
local lastActionTime = 0
local actionCooldown = 0.3
local isProcessing = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SingleTapSystem"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local indicator = Instance.new("TextLabel")
indicator.Name = "DTIndicator"
indicator.Size = UDim2.new(0, 60, 0, 30)
indicator.Position = UDim2.new(0, 10, 0, 10)
indicator.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
indicator.TextColor3 = Color3.fromRGB(255, 255, 255)
indicator.Text = "DT"
indicator.Font = Enum.Font.GothamBold
indicator.TextSize = 16
indicator.Visible = true
indicator.Parent = screenGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Single Tap DT"
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
distanceLabel.Text = "Distance: 3 studs"
distanceLabel.Font = Enum.Font.Gotham
distanceLabel.TextSize = 12
distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
distanceLabel.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(1, -20, 0, 30)
closeButton.Position = UDim2.new(0, 10, 0, 165)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "Close Menu"
closeButton.Font = Enum.Font.Gotham
closeButton.TextSize = 12
closeButton.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeButton

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
    local endPos = startPos + direction * 3
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

print("DT System Ready")
print("LMB = Teleport 3 studs")
print("DEL = Toggle Menu")
print("Menu contains: Bind settings, Status, Distance info")
