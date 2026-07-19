local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local useQte = require(script.Parent.Parent.Parent.Parent.hooks.useQte)

local Progress = require(script.Parent.Parent.elements.Progress)

local function Repeated()
    local data = useQte.useQteData()
    if not data then
        return nil
    end

    local keys = data.keys 
    if not keys or next(keys) == nil then
        return nil
    end

    local children = {}
    for keycode, letter in pairs(keys) do
        local progressElement = React.createElement(Progress, {
            keycode = keycode,
            letter = letter,
            vertical = true,
            currentPresses = data.currentPresses,
            requiredPresses = data.requiredPresses,
        })
        children[letter] = progressElement
    end

    return React.createElement("Frame", {
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromOffset(0, 72),
        Position = UDim2.fromScale(0.5, 0.78),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
    }, children)
end

return Repeated
