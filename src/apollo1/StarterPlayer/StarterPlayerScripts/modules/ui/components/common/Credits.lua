local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local function Credits(props)
    return React.createElement("Frame", {
        Size = props.size or UDim2.fromOffset(0, 0),
        Position = props.position,
        AnchorPoint = props.anchorPoint,
        LayoutOrder = props.layoutOrder,
        BackgroundColor3 = props.backgroundColor or Color3.fromRGB(40, 40, 40),
        BackgroundTransparency = props.backgroundTransparency or 0,
        Visible = props.visible ~= false,
        ZIndex = props.zIndex,
    }, {
         CreditsIcon = React.createElement("ImageLabel", {
            Size = UDim2.fromOffset(24, 24),
            Position = UDim2.fromScale(0, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://12345678", 
        }),
        CreditsLabel = React.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0, 0),
            BackgroundTransparency = 1,
            TextColor3 = props.textColor or Color3.fromRGB(255, 255, 255),
            TextSize = props.textSize or 16,
            Font = props.font or Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Text = ("Credits: " .. (props.credits or "0")),
        }),
    })
end

return Credits
