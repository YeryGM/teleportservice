local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local function FriendsMultiplierRow(props)
    local value = props.value or "x1.0"

    return React.createElement("Frame", {
        Size = props.size or UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        LayoutOrder = props.layoutOrder,
    }, {
        Title = React.createElement("TextLabel", {
            Size = UDim2.fromScale(0.7, 1),
            BackgroundTransparency = 1,
            Text = "Friends Multiplier",
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        Value = React.createElement("TextLabel", {
            Position = UDim2.fromScale(0.7, 0),
            Size = UDim2.fromScale(0.3, 1),
            BackgroundTransparency = 1,
            Text = tostring(value),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Right,
        }),
    })
end

return FriendsMultiplierRow
