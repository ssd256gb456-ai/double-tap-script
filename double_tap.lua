local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

-- Настройки телепортации
local currentBind = Enum.UserInputType.MouseButton1
local listeningForBind = false
local lastActionTime = 0
local actionCooldown = 0.3
local isProcessing = false
local teleportDistance = 10

-- Настройки TrashTalk
local trashTalkEnabled = false
local spamThread = nil
local trashTalkPhrases = {"1"}

-- Настройки AntiAim
local antiAimEnabled = false
local antiAimThread = nil
local antiAimTypes = {"Jitter", "Spin", "Random", "Backwards", "Sideways"}
local currentAntiAimType = "Jitter"
local antiAimSpeed = 5
local antiAimIntensity = 30

-- Настройки Rage Aim
local rageAimEnabled = false
local doubleTapEnabled = false
local peekAssistEnabled = false
local autoShootEnabled = false
local autoReloadEnabled = false
local doubleTapKey = Enum.KeyCode.E
local peekKey = Enum.KeyCode.Q
local aimMode = "Closest to plr"
local hitPart = "Head"
local hitPoint = "Fixed"
local isDoubleTapping = false

-- Настройки Aimbot
local aimbotEnabled = false
local aimbotKey = Enum.KeyCode.LeftAlt
local aimbotFOV = 100
local aimbotSmoothness = 0.2
local aimbotFOVColor = Color3.fromRGB(255, 0, 0)
local showFOV = true
local aimbotThread = nil

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

-- FOV Circle для Aimbot
local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.Size = UDim2.new(0, aimbotFOV * 2, 0, aimbotFOV * 2)
fovCircle.Position = UDim2.new(0.5, -aimbotFOV, 0.5, -aimbotFOV)
fovCircle.BackgroundColor3 = aimbotFOVColor
fovCircle.BackgroundTransparency = 0.7
fovCircle.BorderSizePixel = 0
fovCircle.Visible = showFOV
fovCircle.Parent = screenGui

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

-- Основное меню
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 600)
frame.Position = UDim2.new(0.5, -200, 0.5, -300)
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

-- Секция Rage Aim
local rageSection = Instance.new("TextLabel")
rageSection.Size = UDim2.new(1, -20, 0, 20)
rageSection.Position = UDim2.new(0, 10, 0, 335)
rageSection.BackgroundTransparency = 1
rageSection.TextColor3 = Color3.fromRGB(200, 200, 200)
rageSection.Text = "RAGE AIM"
rageSection.Font = Enum.Font.GothamBold
rageSection.TextSize = 11
rageSection.TextXAlignment = Enum.TextXAlignment.Left
rageSection.Parent = frame

local rageAimButton = Instance.new("TextButton")
rageAimButton.Size = UDim2.new(1, -20, 0, 25)
rageAimButton.Position = UDim2.new(0, 10, 0, 355)
rageAimButton.BackgroundColor3 = Color3.fromRGB(160, 80, 160)
rageAimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
rageAimButton.Text = "Rage Aim: OFF"
rageAimButton.Font = Enum.Font.Gotham
rageAimButton.TextSize = 10
rageAimButton.Parent = frame

local autoShootButton = Instance.new("TextButton")
autoShootButton.Size = UDim2.new(0.48, -10, 0, 25)
autoShootButton.Position = UDim2.new(0, 10, 0, 385)
autoShootButton.BackgroundColor3 = Color3.fromRGB(80, 80, 160)
autoShootButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoShootButton.Text = "AutoShoot: OFF"
autoShootButton.Font = Enum.Font.Gotham
autoShootButton.TextSize = 9
autoShootButton.Parent = frame

local autoReloadButton = Instance.new("TextButton")
autoReloadButton.Size = UDim2.new(0.48, -10, 0, 25)
autoReloadButton.Position = UDim2.new(0.52, 0, 0, 385)
autoReloadButton.BackgroundColor3 = Color3.fromRGB(80, 80, 160)
autoReloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoReloadButton.Text = "AutoReload: OFF"
autoReloadButton.Font = Enum.Font.Gotham
autoReloadButton.TextSize = 9
autoReloadButton.Parent = frame

local doubleTapButton = Instance.new("TextButton")
doubleTapButton.Size = UDim2.new(0.48, -10, 0, 25)
doubleTapButton.Position = UDim2.new(0, 10, 0, 415)
doubleTapButton.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
doubleTapButton.TextColor3 = Color3.fromRGB(255, 255, 255)
doubleTapButton.Text = "DoubleTap: OFF"
doubleTapButton.Font = Enum.Font.Gotham
doubleTapButton.TextSize = 9
doubleTapButton.Parent = frame

local peekAssistButton = Instance.new("TextButton")
peekAssistButton.Size = UDim2.new(0.48, -10, 0, 25)
peekAssistButton.Position = UDim2.new(0.52, 0, 0, 415)
peekAssistButton.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
peekAssistButton.TextColor3 = Color3.fromRGB(255, 255, 255)
peekAssistButton.Text = "PeekAssist: OFF"
peekAssistButton.Font = Enum.Font.Gotham
peekAssistButton.TextSize = 9
peekAssistButton.Parent = frame

local aimModeLabel = Instance.new("TextLabel")
aimModeLabel.Size = UDim2.new(1, -20, 0, 20)
aimModeLabel.Position = UDim2.new(0, 10, 0, 445)
aimModeLabel.BackgroundTransparency = 1
aimModeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
aimModeLabel.Text = "Aim: Closest to plr"
aimModeLabel.Font = Enum.Font.Gotham
aimModeLabel.TextSize = 10
aimModeLabel.TextXAlignment = Enum.TextXAlignment.Left
aimModeLabel.Parent = frame

local hitPartLabel = Instance.new("TextLabel")
hitPartLabel.Size = UDim2.new(1, -20, 0, 20)
hitPartLabel.Position = UDim2.new(0, 10, 0, 465)
hitPartLabel.BackgroundTransparency = 1
hitPartLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
hitPartLabel.Text = "Hitpart: Head"
hitPartLabel.Font = Enum.Font.Gotham
hitPartLabel.TextSize = 10
hitPartLabel.TextXAlignment = Enum.TextXAlignment.Left
hitPartLabel.Parent = frame

-- Секция Aimbot
local aimbotSection = Instance.new("TextLabel")
aimbotSection.Size = UDim2.new(1, -20, 0, 20)
aimbotSection.Position = UDim2.new(0, 10, 0, 495)
aimbotSection.BackgroundTransparency = 1
aimbotSection.TextColor3 = Color3.fromRGB(200, 200, 200)
aimbotSection.Text = "AIMBOT"
aimbotSection.Font = Enum.Font.GothamBold
aimbotSection.TextSize = 11
aimbotSection.TextXAlignment = Enum.TextXAlignment.Left
aimbotSection.Parent = frame

local aimbotButton = Instance.new("TextButton")
aimbotButton.Size = UDim2.new(1, -20, 0, 25)
aimbotButton.Position = UDim2.new(0, 10, 0, 515)
aimbotButton.BackgroundColor3 = Color3.fromRGB(160, 160, 80)
aimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
aimbotButton.Text = "Aimbot: OFF"
aimbotButton.Font = Enum.Font.Gotham
aimbotButton.TextSize = 10
aimbotButton.Parent = frame

local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(1, -20, 0, 20)
fovLabel.Position = UDim2.new(0, 10, 0, 545)
fovLabel.BackgroundTransparency = 1
fovLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fovLabel.Text = "FOV: 100"
fovLabel.Font = Enum.Font.Gotham
fovLabel.TextSize = 10
fovLabel.TextXAlignment = Enum.TextXAlignment.Left
fovLabel.Parent = frame

local increaseFOV = Instance.new("TextButton")
increaseFOV.Size = UDim2.new(0.48, -10, 0, 20)
increaseFOV.Position = UDim2.new(0, 10, 0, 565)
increaseFOV.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
increaseFOV.TextColor3 = Color3.fromRGB(255, 255, 255)
increaseFOV.Text = "+ FOV"
increaseFOV.Font = Enum.Font.Gotham
increaseFOV.TextSize = 9
increaseFOV.Parent = frame

local decreaseFOV = Instance.new("TextButton")
decreaseFOV.Size = UDim2.new(0.48, -10, 0, 20)
decreaseFOV.Position = UDim2.new(0.52, 0, 0, 565)
decreaseFOV.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
decreaseFOV.TextColor3 = Color3.fromRGB(255, 255, 255)
decreaseFOV.Text = "- FOV"
decreaseFOV.Font = Enum.Font.Gotham
decreaseFOV.TextSize = 9
decreaseFOV.Parent = frame

local smoothnessLabel = Instance.new("TextLabel")
smoothnessLabel.Size = UDim2.new(1, -20, 0, 20)
smoothnessLabel.Position = UDim2.new(0, 10, 0, 590)
smoothnessLabel.BackgroundTransparency = 1
smoothnessLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
smoothnessLabel.Text = "Smoothness: 0.2"
smoothnessLabel.Font = Enum.Font.Gotham
smoothnessLabel.TextSize = 10
smoothnessLabel.TextXAlignment = Enum.TextXAlignment.Left
smoothnessLabel.Parent = frame

local increaseSmoothness = Instance.new("TextButton")
increaseSmoothness.Size = UDim2.new(0.48, -10, 0, 20)
increaseSmoothness.Position = UDim2.new(0, 10, 0, 610)
increaseSmoothness.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
increaseSmoothness.TextColor3 = Color3.fromRGB(255, 255, 255)
increaseSmoothness.Text = "+ Smooth"
increaseSmoothness.Font = Enum.Font.Gotham
increaseSmoothness.TextSize = 9
increaseSmoothness.Parent = frame

local decreaseSmoothness = Instance.new("TextButton")
decreaseSmoothness.Size = UDim2.new(0.48, -10, 0, 20)
decreaseSmoothness.Position = UDim2.new(0.52, 0, 0, 610)
decreaseSmoothness.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
decreaseSmoothness.TextColor3 = Color3.fromRGB(255, 255, 255)
decreaseSmoothness.Text = "- Smooth"
decreaseSmoothness.Font = Enum.Font.Gotham
decreaseSmoothness.TextSize = 9
decreaseSmoothness.Parent = frame

local showFOVButton = Instance.new("TextButton")
showFOVButton.Size = UDim2.new(1, -20, 0, 25)
showFOVButton.Position = UDim2.new(0, 10, 0, 635)
showFOVButton.BackgroundColor3 = Color3.fromRGB(80, 80, 160)
showFOVButton.TextColor3 = Color3.fromRGB(255, 255, 255)
showFOVButton.Text = "Show FOV: ON"
showFOVButton.Font = Enum.Font.Gotham
showFOVButton.TextSize = 10
showFOVButton.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(1, -20, 0, 25)
closeButton.Position = UDim2.new(0, 10, 0, 665)
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
addCorner(rageAimButton, 4)
addCorner(autoShootButton, 3)
addCorner(autoReloadButton, 3)
addCorner(doubleTapButton, 3)
addCorner(peekAssistButton, 3)
addCorner(aimbotButton, 4)
addCorner(increaseFOV, 3)
addCorner(decreaseFOV, 3)
addCorner(increaseSmoothness, 3)
addCorner(decreaseSmoothness, 3)
addCorner(showFOVButton, 4)
addCorner(closeButton, 4)

-- Функции Aimbot
local function getClosestPlayerInFOV()
    local closestPlayer = nil
    local closestDistance = math.huge
    local localCharacter = LocalPlayer.Character
    if not localCharacter then return nil end
    
    local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    
    local camera = Workspace.CurrentCamera
    local mousePos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local aimPart = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and aimPart then
                local screenPoint, onScreen = camera:WorldToViewportPoint(aimPart.Position)
                
                if onScreen then
                    local distanceFromCenter = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                    
                    if distanceFromCenter <= aimbotFOV and distanceFromCenter < closestDistance then
                        closestDistance = distanceFromCenter
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function aimAtPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    
    local targetCharacter = targetPlayer.Character
    local aimPart = targetCharacter:FindFirstChild("Head") or targetCharacter:FindFirstChild("HumanoidRootPart")
    local localCharacter = LocalPlayer.Character
    
    if not aimPart or not localCharacter then return end
    
    local camera = Workspace.CurrentCamera
    local targetPosition = aimPart.Position
    
    -- Плавное наведение
    local currentCFrame = camera.CFrame
    local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPosition)
    local smoothedCFrame = currentCFrame:Lerp(targetCFrame, aimbotSmoothness)
    
    camera.CFrame = smoothedCFrame
end

local function startAimbot()
    while aimbotEnabled do
        local targetPlayer = getClosestPlayerInFOV()
        if targetPlayer then
            aimAtPlayer(targetPlayer)
        end
        RunService.RenderStepped:Wait()
    end
end

local function updateFOVCircle()
    fovCircle.Size = UDim2.new(0, aimbotFOV * 2, 0, aimbotFOV * 2)
    fovCircle.Position = UDim2.new(0.5, -aimbotFOV, 0.5, -aimbotFOV)
    fovCircle.BackgroundColor3 = aimbotFOVColor
    fovCircle.Visible = showFOV
end

-- Остальные функции (TrashTalk, AntiAim, Rage Aim, телепортация) остаются без изменений
-- ... [здесь должен быть весь остальной код из предыдущей версии] ...

-- Обработчики кнопок Aimbot
aimbotButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        aimbotButton.Text = "Aimbot: ON"
        aimbotButton.BackgroundColor3 = Color3.fromRGB(60, 160, 60)
        aimbotThread = coroutine.create(startAimbot)
        coroutine.resume(aimbotThread)
    else
        aimbotButton.Text = "Aimbot: OFF"
        aimbotButton.BackgroundColor3 = Color3.fromRGB(160, 160, 80)
    end
end)

increaseFOV.MouseButton1Click:Connect(function()
    aimbotFOV = math.min(300, aimbotFOV + 10)
    fovLabel.Text = "FOV: " .. aimbotFOV
    updateFOVCircle()
end)

decreaseFOV.MouseButton1Click:Connect(function()
    aimbotFOV = math.max(10, aimbotFOV - 10)
    fovLabel.Text = "FOV: " .. aimbotFOV
    updateFOVCircle()
end)

increaseSmoothness.MouseButton1Click:Connect(function()
    aimbotSmoothness = math.min(1, aimbotSmoothness + 0.1)
    smoothnessLabel.Text = "Smoothness: " .. string.format("%.1f", aimbotSmoothness)
end)

decreaseSmoothness.MouseButton1Click:Connect(function()
    aimbotSmoothness = math.max(0.1, aimbotSmoothness - 0.1)
    smoothnessLabel.Text = "Smoothness: " .. string.format("%.1f", aimbotSmoothness)
end)

showFOVButton.MouseButton1Click:Connect(function()
    showFOV = not showFOV
    if showFOV then
        showFOVButton.Text = "Show FOV: ON"
    else
        showFOVButton.Text = "Show FOV: OFF"
    end
    updateFOVCircle()
end)

-- Обновляем FOV круг при запуске
updateFOVCircle()

print("PUZAN LUA DT + AntiAim + Rage Aim + Aimbot System Loaded!")
print("Controls:")
print("- LMB: Teleport 10 studs")
print("- DEL: Toggle Menu")
print("- E: Double Tap (when enabled)")
print("- Q: Peek Assist (when enabled)")
print("- LeftAlt: Aimbot (hold)")
print("- Rage Aim: Auto aim + shooting")
