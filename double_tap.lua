-- Double Tap Script with Protected GUI
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Переменные системы
local doubleTapTime = 0.3
local lastTapTime = 0
local tapCount = 0
local currentBind = Enum.UserInputType.MouseButton1
local listeningForBind = false
local scriptActive = true
local guiVisible = false

-- Создание защищенного GUI
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
    title.Text = "Double Tap System"
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
    bindLabel.Text = "Текущий бинд: ЛКМ"
    bindLabel.Font = Enum.Font.Gotham
    bindLabel.TextSize = 12
    bindLabel.TextXAlignment = Enum.TextXAlignment.Left
    bindLabel.Parent = frame

    local changeBind = Instance.new("TextButton")
    changeBind.Size = UDim2.new(1, -20, 0, 30)
    changeBind.Position = UDim2.new(0, 10, 0, 70)
    changeBind.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    changeBind.TextColor3 = Color3.fromRGB(255, 255, 255)
    changeBind.Text = "Сменить бинд"
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
    statusLabel.Text = "Статус: Активно"
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = frame

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(1, -20, 0, 30)
    closeButton.Position = UDim2.new(0, 10, 0, 140)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Text = "Закрыть"
    closeButton.Font = Enum.Font.Gotham
    closeButton.TextSize = 12
    closeButton.Parent = frame

    local UICorner4 = Instance.new("UICorner")
    UICorner4.CornerRadius = UDim.new(0, 4)
    UICorner4.Parent = closeButton

    return screenGui, frame, bindLabel, changeBind, statusLabel, closeButton
end

-- Создаем GUI
local screenGui, frame, bindLabel, changeBind, statusLabel, closeButton = createGUI()

-- Функция двойного нажатия
local function onInputBegan(input, gameProcessed)
    if gameProcessed or not scriptActive then return end
    
    if input.UserInputType == currentBind then
        local currentTime = tick()
        
        if (currentTime - lastTapTime) < doubleTapTime then
            tapCount = tapCount + 1
        else
            tapCount = 1
        end
        
        lastTapTime = currentTime
        
        if tapCount == 2 then
            -- ТВОЕ ДЕЙСТВИЕ ПРИ АКТИВАЦИИ
            print("Double Tap Activated!")
            
            -- Пример: телепортация вперед
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoid and rootPart then
                    local direction = rootPart.CFrame.LookVector
                    rootPart.CFrame = rootPart.CFrame + direction * 10
                end
            end
            
            tapCount = 0
        end
    end
end

-- Обработчик смены бинда
changeBind.MouseButton1Click:Connect(function()
    listeningForBind = true
    bindLabel.Text = "Нажмите новую клавишу..."
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
        bindLabel.Text = "Текущий бинд: " .. bindName
        listeningForBind = false
        wait(0.5)
        bindLabel.Text = "Бинд изменен на: " .. bindName
    end
end)

-- Подключение основной функции
UserInputService.InputBegan:Connect(onInputBegan)

-- Защита от удаления GUI
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    if not screenGui or not screenGui.Parent then
        screenGui, frame, bindLabel, changeBind, statusLabel, closeButton = createGUI()
    end
end)

print("Double Tap System loaded! Press DEL to open menu.")
warn("GUI created successfully. Use DELETE key to toggle menu.")
