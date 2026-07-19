local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local hooksFolder = script.Parent.Parent.Parent.hooks
local useShop = require(hooksFolder.useShop)

local commonFolder = script.Parent.Parent.common
local WaitingForPlayers = require(commonFolder.WaitingForPlayers)

local function WaitingPanel()
    local counts = useShop.useWaitingCounts()
    local waitingPlayers = counts.waiting or 0
    local totalPlayers = counts.total or 0
    return React.createElement("Frame", {
        Size = UDim2.fromScale(0.5, 1),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
        BorderSizePixel = 0,
    }, {
        Image = React.createElement("ImageLabel", {
            Size = UDim2.fromScale(0.4, 0.4),
            Position = UDim2.fromScale(0.5, 0.3),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Image = "rbxassetid://13776333609",
        }),
        WaitingForPlayers = React.createElement(WaitingForPlayers, {
                waiting = waitingPlayers,
                total = totalPlayers,
        }),
    })
end

return WaitingPanel