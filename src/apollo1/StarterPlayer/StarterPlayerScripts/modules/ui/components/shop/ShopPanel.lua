local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local hooksFolder = script.Parent.Parent.Parent.hooks
local useShop = require(hooksFolder.useShop)

local Counter = require(script.Parent.Counter)
local BuyingPanel = require(script.Parent.BuyingPanel)
local WaitingPanel = require(script.Parent.WaitingPanel)

local function ShopPanel()
    local visible = useShop.useVisible()
    local transitioned = useShop.useTransitioned()
    if not visible then return nil end

    local Panel
    if transitioned then
        Panel = React.createElement(WaitingPanel)
    else
        Panel = React.createElement(BuyingPanel)
    end

    return React.createElement("Frame", {
        Size = UDim2.fromScale(0.5, 1),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
        BorderSizePixel = 0,
    }, {
        Title = React.createElement("TextLabel", {
            Size = UDim2.new(1, -80, 0, 28),
            Position = UDim2.fromOffset(16, 8),
            BackgroundTransparency = 1,
            Text = "Shop",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        Panel = Panel,
        Counter = React.createElement(Counter)
    })
end

return ShopPanel