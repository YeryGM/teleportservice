local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local useCrafting = require(script.Parent.Parent.Parent.hooks.useCrafting)
local UISCrafting = require(script.Parent.Parent.Parent.services.UISCrafting)

local Button = require(script.Parent.Parent.common.Button)
local CraftableCard = require(script.Parent.CraftableCard)
local CraftableDetails = require(script.Parent.CraftableDetails)
local IngredientsOwned = require(script.Parent.IngredientsOwned)

local function CraftingPanel()
    local visible = useCrafting.useVisible()
    if not visible then
        return nil
    end
    local craftables = useCrafting.useCraftables()
    local craftInfo = useCrafting.useCraftInfo()
    local ingredientsOwned = useCrafting.useIngredientsOwned()
    local ingredientList = useCrafting.useIngredientList()
    
    local listChildren = {
        Layout = React.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    }

    local itemIds = {}
    for itemId in pairs(craftables or {}) do
        table.insert(itemIds, itemId)
    end
    table.sort(itemIds, function(a, b)
        return a < b
    end)

    for index, itemId in ipairs(itemIds) do
        local itemData = craftables[itemId]
        listChildren["Item" .. tostring(itemId)] = React.createElement(CraftableCard, {
            item = itemData, --contains amount that will be crafted
            recipe = itemData.recipe or {},
            craftInfo = craftInfo,
            layoutOrder = index,
            onCraft = UISCrafting.craft,
            onSelect = UISCrafting.selectCraftable,
            ingredientList = ingredientList,
        })
    end

    return React.createElement("Frame", {
        Size = UDim2.fromScale(0.75, 0.75),
        Position = UDim2.fromScale(0.25, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
    }, {
        Title = React.createElement("TextLabel", {
            Size = UDim2.new(1, -80, 0, 28),
            Position = UDim2.fromOffset(16, 8),
            BackgroundTransparency = 1,
            Text = "Crafting",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        Close = Button({
            text = "Close",
            size = UDim2.fromOffset(72, 24),
            position = UDim2.new(1, -80, 0, 8),
            anchorPoint = Vector2.new(0, 0),
            onActivated = UISCrafting.close(),
            backgroundColor = Color3.fromRGB(60, 60, 60),
            textSize = 12,
        }),
        List = React.createElement("ScrollingFrame", {
            Position = UDim2.fromScale(0.25, 0.25),
            Size = UDim2.new(1, -32, 1, -60),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.fromScale(0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 6,
        }, listChildren),

        IngredientsOwned = React.createElement(IngredientsOwned, {
            ownedIngredients = ingredientsOwned,
            ingredientList = ingredientList,
        }),

        Details = React.createElement(CraftableDetails),
        
        CraftButton = React.createElement(Button, {
            text = "Craft",
            size = UDim2.fromOffset(120, 32),
            position = UDim2.new(0.5, -60, 1, -40),
            anchorPoint = Vector2.new(0.5, 1),
            onActivated = function()
                UISCrafting.craft(useCrafting.useSelectedItemId())
            end,
            backgroundColor = Color3.fromRGB(80, 80, 80),
            textSize = 14,
        }),
    })
end

return CraftingPanel
