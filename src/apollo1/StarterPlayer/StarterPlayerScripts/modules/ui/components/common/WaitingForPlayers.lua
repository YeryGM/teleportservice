local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local function WaitingForPlayers(props)
    local waitingPlayers = props.waiting or 0
    local totalPlayers = props.total or 0
    
    return React.createElement("Frame", {
        Size = UDim2.fromScale(0.5, 1),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
        BorderSizePixel = 0,
    }, {
        TextLabel = React.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 0.2),
            Position = UDim2.fromScale(0.5, 0.7),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            Text = "Waiting for other players to finish shopping...",
        }),
        PlayerCount = React.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 0.1),
            Position = UDim2.fromScale(0.5, 0.85),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            Text = string.format("%d / %d", waitingPlayers, totalPlayers),
        }),
    })
end

return WaitingForPlayers