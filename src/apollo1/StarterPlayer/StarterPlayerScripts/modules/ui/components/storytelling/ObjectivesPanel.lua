local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local useObjectives = require(script.Parent.Parent.Parent.hooks.useObjectives)

local Objective = require(script.Parent.objectives.Objective)

local function ObjectivesPanel()
    local visible = useObjectives.useVisible()
    if not visible then
        return nil
    end
    local objectives = useObjectives.useObjectives()

    local listChildren = {}
    for _, objective in ipairs(objectives or {}) do
        listChildren["Objective" .. tostring(objective.id)] = React.createElement(Objective, {
            id = objective.id,
            text = objective.text,
            children = objective.children,
        })
    end

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
            Text = "Objectives",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        List = React.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, listChildren),
    })
end

return ObjectivesPanel
