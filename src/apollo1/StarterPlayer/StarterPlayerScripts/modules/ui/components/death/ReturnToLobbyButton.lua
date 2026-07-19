local Button = require(script.Parent.Parent.common.Button)

local function ReturnToLobbyButton(props)
    return Button({
        name = "ReturnToLobby",
        text = "Return To Lobby",
        size = props.size or UDim2.fromScale(0.18, 0.06),
        position = props.position or UDim2.fromScale(0.9, 0.9),
        anchorPoint = props.anchorPoint or Vector2.new(0.5, 0.5),
        onActivated = props.onActivated,
        backgroundColor = Color3.fromRGB(100, 70, 70),
        textSize = 14,
        visible = props.visible,
    })
end

return ReturnToLobbyButton
