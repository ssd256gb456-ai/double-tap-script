local UserInputService = game:GetService("UserInputService")
local doubleTapTime = 0.3
local lastTapTime = 0
local tapCount = 0

local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local currentTime = tick()
        if (currentTime - lastTapTime) < doubleTapTime then
            tapCount = tapCount + 1
        else
            tapCount = 1
        end
        lastTapTime = currentTime
        if tapCount == 2 then
            print("Double Tap Activated!")
            -- Твое действие здесь
            tapCount = 0
        end
    end
end
UserInputService.InputBegan:Connect(onInputBegan)
