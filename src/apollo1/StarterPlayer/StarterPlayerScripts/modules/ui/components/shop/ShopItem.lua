local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))
local UISShop = require(script.Parent.Parent.Parent.services.UISShop)

local hooksFolder = script.Parent.Parent.Parent.hooks
local useShop = require(hooksFolder.useShop)

local function ShopItem(props)
    local state = useShop.useShopItem(props.itemId)
    local itemData = state.item
    local available = state.available
    local selectedAmount = state.selectedAmount

    return React.createElement("Frame", {
        Size = UDim2.fromScale(0.75, 0.75),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
        BorderSizePixel = 0,
        [React.Event.InputBegan] = function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                UISShop.selectItem(props.itemId)
            end
        end,
    }, {
        ItemName = React.createElement("TextLabel", {
            Size = UDim2.new(1, -80, 0, 28),
            Position = UDim2.fromOffset(16, 8),
            BackgroundTransparency = 1,
            Text = itemData.Name or "Item",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        AvailableAmount = React.createElement("TextLabel", {
            Size = UDim2.new(1, -80, 0, 28),
            Position = UDim2.fromOffset(16, 36),
            BackgroundTransparency = 1,
            Text = tostring(available or "Unlimited"),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        Image = React.createElement("ImageLabel", {
            Size = UDim2.fromScale(0.3, 0.8),
            Position = UDim2.fromScale(0.7, 0.1),
            BackgroundTransparency = 1,
            Image = itemData.ImageId or "",
            ScaleType = Enum.ScaleType.Fit,
        }),
        Description = React.createElement("TextLabel", {
            Size = UDim2.new(1, -80, 0, 28),
            Position = UDim2.fromOffset(16, 64),
            BackgroundTransparency = 1,
            Text = itemData.Description or "No description",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        Price = React.createElement("TextLabel", {
            Size = UDim2.new(1, -80, 0, 28),
            Position = UDim2.fromOffset(16, 92),
            BackgroundTransparency = 1,
            Text = tostring(itemData.Price or 0),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        Selection = React.createElement("TextLabel", {
            Size = UDim2.new(1, -80, 0, 28),
            Position = UDim2.fromOffset(16, 120),
            BackgroundTransparency = 1,
            Text = "x" .. tostring(selectedAmount or 0),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
    })
end

return ShopItem
