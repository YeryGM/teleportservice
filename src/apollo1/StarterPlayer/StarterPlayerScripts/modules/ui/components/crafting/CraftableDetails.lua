local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))


local useCrafting = require(script.Parent.Parent.Parent.hooks.useCrafting)

local function CraftingDetails()
    local selectedItemId = useCrafting.useSelectedItemId()
    local bombList = useCrafting.useBombList()

    local itemData = selectedItemId and bombList[selectedItemId] or nil
    if not itemData or not itemData.id then
        return nil
    end

    local assetId = itemData.assetId or ""
    local name = itemData.name or "Craftable"
    local description = itemData.description or "No description available."

    return React.createElement("Frame", {
        Size = UDim2.fromScale(0.75, 0.75),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
    }, {
        Image = React.createElement("ImageLabel", {
            Size = UDim2.fromScale(0.5, 0.5),
            Position = UDim2.fromScale(0.25, 0.25),
            BackgroundTransparency = 1,
            Image = assetId,
            ScaleType = Enum.ScaleType.Fit,
        }),
        
        Name = React.createElement("TextLabel", {
            Position = UDim2.fromScale(0.1, 0.75),
            Size = UDim2.fromScale(0.8, 0.1),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Center,
        }),

        Description = React.createElement("TextLabel", {
            Position = UDim2.fromScale(0.1, 0.85),
            Size = UDim2.fromScale(0.8, 0.15),
            BackgroundTransparency = 1,
            Text = description,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Center,
        }),
    })
end

return CraftingDetails
