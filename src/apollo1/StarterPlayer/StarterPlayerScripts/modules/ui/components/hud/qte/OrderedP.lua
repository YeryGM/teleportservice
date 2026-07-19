local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local UISQte = require(script.Parent.Parent.Parent.Parent.services.UISQte)
local useQte = require(script.Parent.Parent.Parent.Parent.hooks.useQte)

local function Ordered()
    local data = useQte.useQteData()
    if not data then
        return nil
    end

    local sequence = data.sequence
    if not sequence or #sequence == 0 then
        return nil
    end

    local colorMap = data.colorMap
    
    local buttons = {}
    for keycode, color in pairs(colorMap) do
       local button = React.createElement("TextButton", {
            Size = UDim2.fromOffset(64, 64),
            BackgroundColor3 = color,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextScaled = true,
            Text = keycode.Name,
            [React.Event.Activated] = function()
                UISQte.validate(keycode)
            end,
        })
        buttons[keycode] = button
    end

    local currentIndex = data.currentIndex or 1
    local currentKey = sequence[currentIndex]
    

    React.useEffect(function()
		local UserInputService = game:GetService("UserInputService")
		local signal: RBXScriptConnection = UserInputService.InputEnded:Connect(function(input: InputObject, gp: boolean)
            if gp then return end
			if input.UserInputType == Enum.UserInputType.Keyboard then
                UISQte.validate(input.KeyCode)
			end
		end)
		return function()
			signal:Disconnect()
		end
	end, {})

    return React.createElement("Frame", {
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromOffset(0, 72),
        Position = UDim2.fromScale(0.5, 0.78),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
    },
    {
        key = React.createElement("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
        }, {
            currentKey = React.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamBold,
                TextScaled = true,
                Text = currentKey and currentKey.Name or "",
            }),
            uiCorner = React.createElement("UICorner", {
                CornerRadius = UDim.new(0, 8),
            }),
        }),

        buttonContainer = React.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
        }, {
            buttons = React.createElement("Frame", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
            }, buttons)
        }),
    })
end

return Ordered
