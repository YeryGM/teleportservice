local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UISDeath = require(script.Parent.Parent.Parent.services.UISDeath)
local useDeath = require(script.Parent.Parent.Parent.hooks.useDeath)

local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))
local Button = require(script.Parent.Parent.common.Button)

local function SpectateControls(props)
    local visible = useDeath.useIsSpectating()
    if not visible then
        return nil
    end
    local spectatorName = useDeath.useSpectator() or "Player"

    return React.createElement("Frame", {
        Size = props.size or UDim2.fromScale(0.3, 0.06),
        Position = props.position or UDim2.fromScale(0.5, 0.9),
        AnchorPoint = props.anchorPoint or Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
    }, {
        Left = Button({
            name = "Left",
            text = "<",
            size = UDim2.fromScale(0.2, 1),
            position = UDim2.fromScale(0, 0),
            anchorPoint = Vector2.new(0, 0),
            onActivated = UISDeath.spectateLeft,
            backgroundColor = Color3.fromRGB(50, 50, 50),
        }),
        NameLabel = React.createElement("TextLabel", {
            Position = UDim2.fromScale(0.2, 0),
            Size = UDim2.fromScale(0.6, 1),
            BackgroundTransparency = 1,
            Text = spectatorName,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Center,
        }),
        Right = Button({
            name = "Right",
            text = ">",
            size = UDim2.fromScale(0.2, 1),
            position = UDim2.fromScale(0.8, 0),
            anchorPoint = Vector2.new(0, 0),
            onActivated = UISDeath.spectateRight,
            backgroundColor = Color3.fromRGB(50, 50, 50),
        }),
    })
end

return SpectateControls
