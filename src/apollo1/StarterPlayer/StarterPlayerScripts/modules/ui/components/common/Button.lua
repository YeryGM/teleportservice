local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local function Button(props)
    return React.createElement("TextButton", {
        Text = props.text or "",
        Size = props.size or UDim2.fromOffset(0, 0),
        Position = props.position,
        AnchorPoint = props.anchorPoint,
        LayoutOrder = props.layoutOrder,
        BackgroundColor3 = props.backgroundColor or Color3.fromRGB(40, 40, 40),
        BackgroundTransparency = props.backgroundTransparency or 0,
        TextColor3 = props.textColor or Color3.fromRGB(255, 255, 255),
        TextSize = props.textSize or 16,
        Font = props.font or Enum.Font.GothamMedium,
        AutoButtonColor = props.autoButtonColor ~= false,
        Visible = props.visible ~= false,
        ZIndex = props.zIndex,
        [React.Event.Activated] = function()
            props.onActivated()
        end,
    })
end

return Button
