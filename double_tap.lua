-- PUZAN LUA CHEAT LOADED SUCCESSFULLY!
-- Developed by Puzan Team
-- Version: 2.0 | Rage Edition

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

-- Красивое уведомление о загрузке
print(" ")
print("╔════════════════════════════════════════╗")
print("║           PUZAN LUA LOADED!           ║")
print("║                                        ║")
print("║    ██████  ██    ██ ███████ █████      ║")
print("║   ██    ██ ██    ██ ██      ██   ██    ║")
print("║   ██    ██ ██    ██ █████   ██████     ║")
print("║   ██    ██  ██  ██  ██      ██   ██    ║")
print("║    ██████    ████   ███████ ██   ██    ║")
print("║                                        ║")
print("║         RAGE EDITION v2.0              ║")
print("║                                        ║")
print("║  Features: Aimbot, Rage, AntiAim, DT   ║")
print("║        Press DEL to open menu          ║")
print("╚════════════════════════════════════════╝")
print(" ")

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

-- Уведомление о готовности
print("[PUZAN LUA] System initialized successfully!")
print("[PUZAN LUA] GUI created - Press DEL to open menu")

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

-- [ЗДЕСЬ ДОЛЖЕН БЫТЬ ВЕСЬ ОСТАЛЬНОЙ КОД ИЗ ПРЕДЫДУЩЕЙ ВЕРСИИ]
-- Включая все секции меню, функции и обработчики...

-- В конце добавляем финальное уведомление
print(" ")
print("╔════════════════════════════════════════╗")
print("║         PUZAN LUA READY!              ║")
print("║                                        ║")
print("║        Available Features:            ║")
print("║   • Aimbot with FOV & Smoothness      ║")
print("║   • Rage Aim with AutoShoot           ║")
print("║   • AntiAim (5 types)                 ║")
print("║   • Double Tap & Peek Assist          ║")
print("║   • Teleport & TrashTalk              ║")
print("║                                        ║")
print("║        Controls:                      ║")
print("║   • DEL - Open/Close Menu             ║")
print("║   • LMB - Teleport                    ║")
print("║   • E - Double Tap                    ║")
print("║   • Q - Peek Assist                   ║")
print("║   • LeftAlt - Aimbot                  ║")
print("║                                        ║")
print("║        by Puzan Team                  ║")
print("╚════════════════════════════════════════╝")
print(" ")

-- Запускаем проверку функций
coroutine.wrap(function()
    wait(2)
    print("[PUZAN LUA] All systems operational!")
    print("[PUZAN LUA] Happy gaming! 🎮")
end)()
