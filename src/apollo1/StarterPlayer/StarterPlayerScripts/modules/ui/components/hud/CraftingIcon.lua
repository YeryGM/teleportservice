local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local useHud = require(script.Parent.Parent.Parent.hooks.useHud)
local UISCrafting = require(script.Parent.Parent.Parent.services.UISCrafting)

local function CraftingIcon()
    local visible = useHud.useCraftingVisible()
    if not visible then
        return nil
    end

    return React.createElement("ImageLabel", {
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://123456789", 
        [React.Event.InputBegan] = function(InputObject)
            if InputObject.UserInputType == Enum.UserInputType.MouseButton1 or InputObject.UserInputType == Enum.UserInputType.Touch then
                UISCrafting.open()
            end
        end,
    })
end

return CraftingIcon
