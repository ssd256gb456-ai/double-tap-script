local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local WS = game:GetService("Workspace")

local bind = Enum.UserInputType.MouseButton1
local lastTime = 0
local cooldown = 0.3
local busy = false

local gui = Instance.new("ScreenGui")
gui.Name = "DT"
gui.Parent = LP:WaitForChild("PlayerGui")

local dtText = Instance.new("TextLabel")
dtText.Size = UDim2.new(0, 60, 0, 30)
dtText.Position = UDim2.new(0, 10, 0, 10)
dtText.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
dtText.TextColor3 = Color3.new(1, 1, 1)
dtText.Text = "DT"
dtText.Font = Enum.Font.GothamBold
dtText.TextSize = 16
dtText.Parent = gui

local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 300, 0, 200)
menu.Position = UDim2.new(0.5, -150, 0.5, -100)
menu.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
menu.Visible = false
menu.Parent = gui

local function movePlayer()
    if busy then return end
    busy = true
    
    if tick() - lastTime < cooldown then
        busy = false
        return
    end
    
    lastTime = tick()
    
    local char = LP.Character
    if not char then
        busy = false
        return
    end
    
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if not hum or not root then
        busy = false
        return
    end
    
    local dir = hum.MoveDirection
    if dir.Magnitude < 0.1 then
        dir = root.CFrame.LookVector
    end
    dir = dir.Unit
    
    local start = root.Position
    local target = start + dir * 3
    
    root.CFrame = CFrame.new(target, target + dir)
    
    wait(0.1)
    busy = false
end

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == bind then
        movePlayer()
    end
    if input.KeyCode == Enum.KeyCode.Delete then
        menu.Visible = not menu.Visible
    end
end)

print("DT System Loaded")
print("LMB = Teleport")
print("DEL = Toggle Menu")
