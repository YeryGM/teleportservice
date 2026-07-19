local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))
local UISShop = require(script.Parent.Parent.Parent.services.UISShop)

local hooksFolder = script.Parent.Parent.Parent.hooks
local useShop = require(hooksFolder.useShop)

local commonFolder = script.Parent.Parent.common
local Button = require(commonFolder.Button)
local Credits = require(commonFolder.Credits)
local ShopItem = require(script.Parent.ShopItem)

local function BuyingPanel()
    local items = useShop.useItems()
    local credits = useShop.useCredits()

    local listChildren = {
        Layout = React.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    }
    for itemId, itemData in pairs(items or {}) do
        listChildren[itemData.Name] = React.createElement(ShopItem, {
            itemId = itemId,
    })
    end
    
    return React.createElement("Frame", {
        Size = UDim2.fromScale(0.5, 1),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
        BorderSizePixel = 0,
    }, {
        
        Credits = React.createElement(Credits, {
            credits = credits,
            Position = UDim2.fromScale(1, 0),
            AnchorPoint = Vector2.new(1, 0),
            
        }),
        List = React.createElement("ScrollingFrame", {
            Position = UDim2.fromScale(0.05, 0.2),
            Size = UDim2.new(1, -32, 1, -60),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.fromScale(0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 6,
        }, listChildren),
        ConfirmButton = React.createElement(Button, {
            Text = "Confirm",
            Size = UDim2.fromScale(0.3, 0.08),
            Position = UDim2.fromScale(1, 0),
            AnchorPoint = Vector2.new(1, 0),
            onClick = function()
                UISShop.confirmPurchase()
             end,
        }), 
    })
end

return BuyingPanel