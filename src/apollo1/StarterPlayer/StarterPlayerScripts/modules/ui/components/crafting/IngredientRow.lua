local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local function IngredientRow(props)
    local ingredient = props.ingredient or {}
    local canCraft = props.canCraft == true
    local totalAmount = (props.amount or 1)
    local forceColor = props.forceColor
    local amountColor = nil
    if forceColor then
        amountColor = forceColor
    else 
        amountColor = canCraft and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 60, 60)
    end
    
    return React.createElement("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        LayoutOrder = props.layoutOrder,
    }, {
        Icon = React.createElement("ImageLabel", {
            Size = UDim2.fromScale(0.15, 1),
            BackgroundTransparency = 1,
            Image = ingredient.assetId or "",
            ScaleType = Enum.ScaleType.Fit,
        }),
        Amount = React.createElement("TextLabel", {
            Position = UDim2.fromScale(0.7, 0),
            Size = UDim2.fromScale(0.3, 1),
            BackgroundTransparency = 1,
            Text = "x" .. tostring(totalAmount),
            TextColor3 = amountColor,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Right,
        }),
    })
end

return IngredientRow
