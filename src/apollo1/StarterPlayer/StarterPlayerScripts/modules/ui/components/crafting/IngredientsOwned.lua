local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local IngredientRow = require(script.Parent.IngredientRow)

local function IngredientsOwned(props)
    local ingredients = props.ownedIngredients or {}
    local ingredientList = props.ingredientList or {}

    local ownedIngredients = {
        Layout = React.createElement("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    }

    local index = 1
    for ingredientId, amount in pairs(ingredients) do
        local ingredientData = ingredientList[ingredientId]
        if not ingredientData or ingredientData.id == nil then
            continue
        end
        ownedIngredients["Ingredient" .. tostring(ingredientId)] = React.createElement(IngredientRow, {
            ingredient = ingredientData,
            amount = amount or 1,
            layoutOrder = index,
            forceColor = Color3.fromRGB(171, 165, 165),
        })
        index = index + 1
    end

    return React.createElement("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0,
    }, ownedIngredients)
end

return IngredientsOwned