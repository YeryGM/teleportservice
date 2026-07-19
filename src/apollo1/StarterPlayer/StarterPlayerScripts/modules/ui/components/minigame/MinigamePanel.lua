local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local useMinigame = require(script.Parent.Parent.Parent.hooks.useMinigame)

local function MinigamePanel()
    local visible = useMinigame.useVisible()
    if not visible then
        return nil
    end

   return React.createElement("Frame", {
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
    }) 
end

return MinigamePanel
