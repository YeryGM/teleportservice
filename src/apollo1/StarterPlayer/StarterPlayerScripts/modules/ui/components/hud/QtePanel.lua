local ReplicatedStorage = game:GetService("ReplicatedStorage")
local QteEnums = require(ReplicatedStorage.modules.general.data.Enums).qte.types
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local useQte = require(script.Parent.Parent.Parent.hooks.useQte)
local Repeated = require(script.Parent.qte.RepeatedP)
local Ordered = require(script.Parent.qte:WaitForChild("OrderedP"))

local map = {
    [QteEnums.Repeated] = Repeated,
    [QteEnums.Sequence] = Ordered,
}

local function QtePanel()
    local visible = useQte.useVisible()
    if not visible then
        return nil
    end

    local qteEnum = useQte.useActiveQte()

    local QteComponent = map[qteEnum]
    if not QteComponent then
        return nil
    end

    return React.createElement("Frame", {
        Size = UDim2.fromScale(0.3, 0.08),
        Position = UDim2.fromScale(0.5, 0.78),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
    }, {
       React.createElement(QteComponent, {})
    })
end

return QtePanel
