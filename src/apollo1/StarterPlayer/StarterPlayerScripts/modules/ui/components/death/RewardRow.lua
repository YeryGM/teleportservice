local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local function RewardRow(props)
    local data = props.data or {}
    local title = data.title or "Reward"
    local value = data.value or "0"
    local image = data.image or ""

    return React.createElement("Frame", {
        Size = props.size or UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        LayoutOrder = props.layoutOrder,
    }, {
        Image = React.createElement("ImageLabel", {
            Size = UDim2.fromScale(0.15, 1),
            BackgroundTransparency = 1,
            Image = image,
            ScaleType = Enum.ScaleType.Fit,
        }),
        TextContainer = React.createElement("Frame", {
            Position = UDim2.fromScale(0.18, 0),
            Size = UDim2.fromScale(0.82, 1),
            BackgroundTransparency = 1,
        }, {
            Layout = React.createElement("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            Title = React.createElement("TextLabel", {
                Size = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = Color3.fromRGB(220, 220, 220),
                TextSize = 14,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 1,
            }),
            Value = React.createElement("TextLabel", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = tostring(value),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 18,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 2,
            }),
        }),
    })
end

return RewardRow
