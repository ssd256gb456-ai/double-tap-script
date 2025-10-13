-- Double Tap Script - Hold to Activate with Wall Check
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Переменные системы
local currentBind = Enum.UserInputType.MouseButton1
local listeningForBind = false
local scriptActive = true
local guiVisible = false
local isKeyPressed = false
local activeConnection = nil

-- Создание GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DoubleTapGUI_" .. tostring(math.random(1, 10000))
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

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
    title.Text = "Hold System"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = frame

    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(0, 8)
    UICorner2.Parent = title

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

    local UICorner3 = Instance.new("UICorner")
    UICorner3.CornerRadius = UDim.new(0, 4)
    UICorner3.Parent = changeBind

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

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(1, -20, 0, 30)
    closeButton.Position = UDim2.new(0, 10, 0, 140)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Text = "Close"
    closeButton.Font = Enum.Font.Gotham
    closeButton.TextSize = 12
    closeButton.Parent = frame

    local UICorner4 = Instance.new("UICorner")
    UICorner4.CornerRadius = UDim.new(0, 4)
    UICorner4.Parent = closeButton

    return screenGui, frame, bindLabel, changeBind, statusLabel, closeButton
end

-- Функция проверки на стены
local function checkWallCollision(startPos, endPos)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local raycastResult = Workspace:Raycast(startPos, (endPos - startPos), raycastParams)
    
    if raycastResult then
        return true, raycastResult.Position
    end
    
    return false, endPos
end

-- Функция активации способности
local function activateAbility()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    -- Получаем направление взгляда
    local direction = rootPart.CFrame.LookVector
    
    -- Начальная позиция
    local startPos = rootPart.Position
    
    -- Конечная позиция (10 studs вперед)
    local endPos = startPos + direction * 10
    
    -- Проверяем столкновение со стенами
    local hitWall, hitPosition = checkWallCollision(startPos, endPos)
    
    if hitWall then
        -- Если есть стена, двигаемся до стены минус небольшой отступ
        local safeDistance = 2
        local moveVector = (hitPosition - startPos)
        local moveDistance = math.max(0, moveVector.Magnitude - safeDistance)
        local safePosition = startPos + direction * moveDistance
        rootPart.CFrame = CFrame.new(safePosition, safePosition + direction)
        print("Moved to wall: " .. tostring(moveDistance))
    else
        -- Если стены нет, двигаемся полностью
        rootPart.CFrame = CFrame.new(endPos, endPos + direction)
        print("Moved full distance")
    end
end

-- Создаем GUI
local screenGui, frame, bindLabel, changeBind, statusLabel, closeButton = createGUI()

-- Обработчик нажатия кнопки
local function onInputBegan(input, gameProcessed)
    if gameProcessed or not scriptActive then return end
    
    if input.UserInputType == currentBind and not isKeyPressed then
        isKeyPressed = true
        print("Key pressed - Ability active")
        
        -- Запускаем цикл пока кнопка нажата
        activeConnection = RunService.Heartbeat:Connect(function()
            if isKeyPressed then
                activateAbility()
            else
                activeConnection:Disconnect()
            end
        end)
    end
end

-- Обработчик отпускания кнопки
local function onInputEnded(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == currentBind then
        isKeyPressed = false
        print("Key released - Ability deactivated")
        
        if activeConnection then
            activeConnection:Disconnect()
            activeConnection = nil
        end
    end
end

-- Обработчик смены бинда
changeBind.MouseButton1Click:Connect(function()
    listeningForBind = true
    bindLabel.Text = "Press new key..."
end)

-- Обработчик закрытия
closeButton.MouseButton1Click:Connect(function()
    frame.Visible = false
    guiVisible = false
end)

-- Обработчик ввода для биндов и меню
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Открытие/закрытие меню по DEL
    if input.KeyCode == Enum.KeyCode.Delete then
        guiVisible = not guiVisible
        frame.Visible = guiVisible
    end
    
    -- Обработка смены бинда
    if listeningForBind then
        currentBind = input.UserInputType
        local bindName = tostring(input.KeyCode or input.UserInputType):gsub("Enum.%a+%.", "")
        bindLabel.Text = "Current Bind: " .. bindName
        listeningForBind = false
        wait(0.5)
        bindLabel.Text = "Bind changed to: " .. bindName
    end
end)

-- Подключаем обработчики ввода
UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)

-- Защита от удаления GUI
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    if not screenGui or not screenGui.Parent then
        screenGui, frame, bindLabel, changeBind, statusLabel, closeButton = createGUI()
    end
end)

print("Hold System loaded! Press DEL to open menu.")
print("Hold the bind key to activate, release to deactivate.")
