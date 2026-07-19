local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local useStamina = require(script.Parent.Parent.Parent.hooks.useStamina)

local function StaminaBar()
    local visible = useStamina.useVisible()
    if not visible then
        return nil
    end
    local shownAtFull = useStamina.useShownAtFull()
    local isFull = useStamina.useIsFull()
    if isFull and not shownAtFull then
        return nil
    end
    local isInfinite = useStamina.useIsInfinite()
    local percent = 1
    if isInfinite then
        percent = 1
    else
        percent = useStamina.usePercent()
    end
    --local current = useStamina.useCurrent()
    --local max = useStamina.useMax()

    return React.createElement("Frame", {
        Size = UDim2.fromScale(0.25, 0.025),
        Position = UDim2.fromScale(0.02, 0.15),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0,
    }, {
        CanvasGroup = React.createElement("CanvasGroup", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
        },{
            Fill = React.createElement("Frame", {
                Size = UDim2.fromScale(percent, 1),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
            }),
        }),
        UICorner = React.createElement("UICorner", {
            CornerRadius = UDim.new(0.5, 0),
        }),
    })
end

return StaminaBar
