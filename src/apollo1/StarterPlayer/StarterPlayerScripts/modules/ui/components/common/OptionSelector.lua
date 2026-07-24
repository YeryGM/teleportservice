local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local ARROW_COLOR = Color3.fromRGB(60, 60, 60)
local ARROW_HOVER = Color3.fromRGB(80, 80, 80)
local ARROW_SIZE = UDim2.fromOffset(32, 32)
local LABEL_WIDTH = 80

local function OptionSelector(props)
	return React.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		LayoutOrder = props.layoutOrder or 0,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		UIListLayout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
		}),
		Label = React.createElement("TextLabel", {
			Size = UDim2.fromOffset(LABEL_WIDTH, 32),
			LayoutOrder = 1,
			BackgroundTransparency = 1,
			Text = props.label or "",
			TextColor3 = Color3.fromRGB(180, 180, 180),
			TextSize = 14,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		PrevButton = React.createElement("TextButton", {
			Size = ARROW_SIZE,
			LayoutOrder = 2,
			BackgroundColor3 = ARROW_COLOR,
			BorderSizePixel = 0,
			Text = "<",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 18,
			Font = Enum.Font.GothamBold,
			AutoButtonColor = true,
			[React.Event.Activated] = function()
				if props.onPrev then
					props.onPrev()
				end
			end,
		}, {
			UICorner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
		}),
		ValueLabel = React.createElement("TextLabel", {
			Size = UDim2.new(1, -(LABEL_WIDTH + ARROW_SIZE.X.Offset * 2 + 32), 0, 32),
			LayoutOrder = 3,
			BackgroundTransparency = 1,
			Text = props.value or "",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 15,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Center,
		}),
		NextButton = React.createElement("TextButton", {
			Size = ARROW_SIZE,
			LayoutOrder = 4,
			BackgroundColor3 = ARROW_COLOR,
			BorderSizePixel = 0,
			Text = ">",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 18,
			Font = Enum.Font.GothamBold,
			AutoButtonColor = true,
			[React.Event.Activated] = function()
				if props.onNext then
					props.onNext()
				end
			end,
		}, {
			UICorner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
		}),
	})
end

return OptionSelector
