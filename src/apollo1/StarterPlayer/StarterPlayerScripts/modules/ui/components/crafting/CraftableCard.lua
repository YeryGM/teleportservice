local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local IngredientRow = require(script.Parent.IngredientRow)

local function CraftableCard(props)
    local item = props.item or {}
    local amount = item.amount or 1
    local craftInfo = props.craftInfo or {}

    local ingredients = {}
    ingredients.Layout = React.createElement("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local index = 1
    for ingredientId, ingredientData in pairs(item.recipe or {}) do
        local canCraftIngredient = craftInfo[ingredientId] == true
        ingredients["Ingredient" .. tostring(ingredientId)] = React.createElement(IngredientRow, {
            ingredient = props.ingredientList[ingredientId] or {},
            amount = ingredientData.amount or 1,
            canCraft = canCraftIngredient,
            layoutOrder = index,
        })
        index = index + 1
    end

    return React.createElement("Frame", {
        Size = UDim2.new(1, 0, 0, 140),
        BackgroundColor3 = Color3.fromRGB(32, 32, 32),
        BorderSizePixel = 0,
        LayoutOrder = props.layoutOrder,
        [React.Event.InputBegan] = function(input)
            if not input then return end
            local t = input.UserInputType
            if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
                if props.onSelect then
                    props.onSelect(item.id)
                end
            end
        end,
    }, {
        Padding = React.createElement("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
        }),
        TitleRow = React.createElement("Frame", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
        }, {
            Icon = React.createElement("ImageLabel", {
                Size = UDim2.fromScale(0.12, 1),
                BackgroundTransparency = 1,
                Image = item.assetId or "",
                ScaleType = Enum.ScaleType.Fit,
            }),
            Title = React.createElement("TextLabel", {
                Position = UDim2.fromScale(0.15, 0),
                Size = UDim2.fromScale(0.7, 1),
                BackgroundTransparency = 1,
                Text = item.name or "Craftable",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
            AmountLabel = React.createElement("TextLabel", {
                Position = UDim2.fromScale(0.85, 0),
                Size = UDim2.fromScale(0.15, 1),
                BackgroundTransparency = 1,
                Text = "x" .. tostring(amount),
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextSize = 12,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Right,
            }),
        }),
        Ingredients = React.createElement("Frame", {
            Position = UDim2.fromScale(0.1, 0.9),
            Size = UDim2.new(1, 0, 0, 60),
            BackgroundTransparency = 1,
        }, ingredients),
    })
end

return CraftableCard
