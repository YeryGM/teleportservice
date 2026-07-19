local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))
local UISQte = require(script.Parent.Parent.Parent.Parent.services.UISQte)

local function Progress(props)
    local keycode = props.keycode
    local letter = props.letter
    local vertical = props.vertical
    local currentPresses = props.currentPresses[keycode] or 0
    local requiredPresses = props.requiredPresses or 1
    local progress = math.clamp(currentPresses / requiredPresses, 0, 1)

    return React.createElement("TextButton", {
        LayoutOrder =  1,
        Size = UDim2.fromOffset(56, 56),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ClipsDescendants = true,
        Text = letter,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        [React.Event.Activated] = function()
            UISQte.validate(keycode)
        end,
    }, {
        progressBar = React.createElement("Frame", {
            Size = vertical and UDim2.fromScale(1, progress) or UDim2.fromScale(progress, 1),
            Position = vertical and UDim2.fromScale(0, 1) or UDim2.fromScale(0, 0),
            AnchorPoint = vertical and Vector2.new(0, 1) or Vector2.new(0, 0),
            BackgroundColor3 = Color3.fromRGB(165, 172, 165),
            BorderSizePixel = 0,
        }),
        UICorner = React.createElement("UICorner", {
            CornerRadius = UDim.new(0.1, 0),
        }),
        outline = React.createElement("UIStroke", {
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 2,
        }),
       
    })
end

return Progress
