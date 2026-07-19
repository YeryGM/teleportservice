local Button = require(script.Parent.Parent.common.Button)

local function ReviveHeader(props)
    if not props.visible then
        return nil
    end

    return Button({
        name = "ReviveButton",
        text = "Request Revive",
        size = props.size or UDim2.fromScale(0.3, 0.06),
        position = props.position or UDim2.fromScale(0.5, 0.08),
        anchorPoint = props.anchorPoint or Vector2.new(0.5, 0.5),
        onActivated = props.onActivated,
        backgroundColor = Color3.fromRGB(80, 120, 80),
        textSize = 16,
    })
end

return ReviveHeader
