local Button = require(script.Parent.Parent.common.Button)

local function PlayAgainButton(props)
    return Button({
        name = "PlayAgain",
        text = "Play Again",
        size = props.size or UDim2.fromScale(0.18, 0.06),
        position = props.position or UDim2.fromScale(0.5, 0.9),
        anchorPoint = props.anchorPoint or Vector2.new(0.5, 0.5),
        onActivated = props.onActivated,
        backgroundColor = Color3.fromRGB(70, 90, 120),
        textSize = 14,
        visible = props.visible,
    })
end

return PlayAgainButton
