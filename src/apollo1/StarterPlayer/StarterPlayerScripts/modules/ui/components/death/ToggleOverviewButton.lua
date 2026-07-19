local Button = require(script.Parent.Parent.common.Button)

local function ToggleOverviewButton(props)
    local isOpen = props.isOpen == true
    local text = isOpen and "Hide Overview" or "Show Overview"

    return Button({
        name = props.name or "ToggleOverview",
        text = text,
        size = props.size,
        position = props.position,
        anchorPoint = props.anchorPoint,
        layoutOrder = props.layoutOrder,
        onActivated = props.onActivated,
        backgroundColor = props.backgroundColor or Color3.fromRGB(55, 55, 55),
        textSize = props.textSize or 14,
    })
end

return ToggleOverviewButton
