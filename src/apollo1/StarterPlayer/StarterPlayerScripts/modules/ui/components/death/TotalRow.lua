local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local function TotalRow(props)
    local value = props.value or "0"

    return React.createElement("Frame", {
        Size = props.size or UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        LayoutOrder = props.layoutOrder,
    }, {
        Title = React.createElement("TextLabel", {
            Size = UDim2.fromScale(0.7, 1),
            BackgroundTransparency = 1,
            Text = "Total",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        Value = React.createElement("TextLabel", {
            Position = UDim2.fromScale(0.7, 0),
            Size = UDim2.fromScale(0.3, 1),
            BackgroundTransparency = 1,
            Text = tostring(value),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Right,
        }),
    })
end

return TotalRow
