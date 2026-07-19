local Text = {
	[1] = {
		properties = {
			font = Font.fromEnum(Enum.Font.Garamond),
			textSize = 36,
			textColor = Color3.fromRGB(255, 255, 255),
			strokeColor = Color3.fromRGB(0, 0, 0),
			strokeTransparency = 0.25,
			textXAlignment = Enum.TextXAlignment.Center,
			textYAlignment = Enum.TextYAlignment.Center,
		},
		motion = {
			offset = Vector2.new(0, -10),
			duration = 0.25,
		},
	},
	[2] = {
		properties = {
			font = Font.fromEnum(Enum.Font.GothamBold),
			textSize = 28,
			textColor = Color3.fromRGB(255, 239, 186),
			strokeColor = Color3.fromRGB(25, 18, 8),
			strokeTransparency = 0.15,
			textXAlignment = Enum.TextXAlignment.Center,
			textYAlignment = Enum.TextYAlignment.Center,
		},
		
		motion = {
			offset = Vector2.new(0, -4),
			duration = 0.2,
		},
	},
	[3] = {
		properties = {
			font = Font.fromEnum(Enum.Font.Garamond),
			textSize = 22,
			textColor = Color3.fromRGB(225, 225, 235),
			strokeColor = Color3.fromRGB(15, 15, 25),
			strokeTransparency = 0.4,
			textXAlignment = Enum.TextXAlignment.Left,
			textYAlignment = Enum.TextYAlignment.Top,
		},
		motion = {
			offset = Vector2.new(5, 0),
			duration = 0.28,
		},
	},
}

return Text