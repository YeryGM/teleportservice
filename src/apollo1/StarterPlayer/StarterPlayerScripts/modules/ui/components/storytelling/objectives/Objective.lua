local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local useObjectives = require(script.Parent.Parent.Parent.Parent.hooks.useObjectives)

local function Objective(props)
    local visible = useObjectives.useObjectiveVisible(props.id)
    if not visible then
        return nil
    end
    local children = props.children or {}

    local listChildren = {
        Layout = React.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    }
    local subobjectives = {}
    local formatComplete = {
        StrokeColor3 = Color3.fromRGB(255, 255, 255),
    }
    local formatIncomplete = {}
    local layoutOrder = 1
    for _subObjectiveid, data in pairs(children or {}) do
        local format = data.completed and formatComplete or formatIncomplete
        subobjectives["Child" .. tostring(layoutOrder)] = React.createElement("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Text = "- " .. (data.text or "Sub objective"),
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = layoutOrder,
        })
        layoutOrder += 1
    end
    
    listChildren["Objective" .. tostring(layoutOrder)] = React.createElement("Frame", {
        Size = UDim2.fromScale(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = layoutOrder,
    }, subobjectives)

    return React.createElement("Frame", {
        Size = UDim2.fromScale(0.28, 0.2),
        Position = UDim2.fromScale(0.02, 0.7),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
    }, {
        Title = React.createElement("TextLabel", {
            Size = UDim2.new(1, -12, 0, 20),
            Position = UDim2.fromOffset(6, 4),
            BackgroundTransparency = 1,
            Text = props.text or "Objective",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        List = React.createElement("Frame", {
            Size = UDim2.fromScale(1, 0),
            Position = UDim2.fromOffset(0, 28),
            BackgroundTransparency = 1,
        }, listChildren)
    })
end

return Objective
