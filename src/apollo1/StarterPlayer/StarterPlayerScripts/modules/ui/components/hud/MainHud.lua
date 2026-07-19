local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local useHud = require(script.Parent.Parent.Parent.hooks.useHud)

local CraftingIcon = require(script.Parent.CraftingIcon)

local function MainHud()
    local visible = useHud.useVisible()
    if not visible then
        return nil
    end

    local title = useHud.useTitle()
    local hint = useHud.useHint()

    return React.createElement("Frame", {
        Size = UDim2.fromScale(0.3, 0.12),
        Position = UDim2.fromScale(0.02, 0.02),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
    }, {
        Title = React.createElement("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = title or "HUD",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1,
        }),
        Hint = React.createElement("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Text = hint or "",
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 2,
        }),
        CraftingIcon = React.createElement(CraftingIcon, {
            LayoutOrder = 3,
        }),
    })
end

return MainHud
