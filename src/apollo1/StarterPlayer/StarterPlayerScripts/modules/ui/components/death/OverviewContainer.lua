local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local UISDeath = require(script.Parent.Parent.Parent.services.UISDeath)
local useDeath = require(script.Parent.Parent.Parent.hooks.useDeath)

local RewardRow = require(script.Parent.RewardRow)
local FriendsMultiplierRow = require(script.Parent.FriendsMultiplierRow)
local TotalRow = require(script.Parent.TotalRow)
local ToggleOverviewButton = require(script.Parent.ToggleOverviewButton)

local function OverviewContainer(props)
    local visible = useDeath.useOverviewOpen()
    if not visible then
        return nil
    end

    local overviewData = useDeath.useOverviewData() or {}
    local creditsFound = overviewData.creditsFound or 0
    local creditsEarned = overviewData.creditsEarned or 0
    local multiplier = overviewData.multiplier or 1
    local creditsTotal = overviewData.creditsTotal or 0
    local phrase = overviewData.phrase or "Over the stars"
    local imageId = overviewData.imageId or ""

    return React.createElement("Frame", {
        Size = props.size or UDim2.fromScale(0.7, 0.5),
        Position = props.position or UDim2.fromScale(0.5, 0.45),
        AnchorPoint = props.anchorPoint or Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
    }, {
        Left = React.createElement("Frame", {
            Size = UDim2.fromScale(0.6, 1),
            BackgroundTransparency = 1,
        }, {
            Padding = React.createElement("UIPadding", {
                PaddingTop = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 12),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
            }),
            Layout = React.createElement("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            Title = React.createElement("TextLabel", {
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Text = "Overview",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 18,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 1,
            }),
            FoundReward = React.createElement(RewardRow, {
                name = "Credits Found",
                data = creditsFound,
                layoutOrder = 2,
            }),
            EarnedReward = React.createElement(RewardRow, {
                name = "Credits Earned",
                data = creditsEarned,
                layoutOrder = 3,
            }),
            FriendsMultiplier = React.createElement(FriendsMultiplierRow, {
                value = multiplier,
                layoutOrder = 4,
            }),
            Total = React.createElement(TotalRow, {
                value = creditsTotal,
                layoutOrder = 5,
            }),
        }),
        Right = React.createElement("Frame", {
            Position = UDim2.fromScale(0.6, 0),
            Size = UDim2.fromScale(0.4, 1),
            BackgroundTransparency = 1,
        }, {
            Padding = React.createElement("UIPadding", {
                PaddingTop = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 12),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
            }),
            Image = React.createElement("ImageLabel", {
                Size = UDim2.fromScale(1, 0.7),
                BackgroundTransparency = 1,
                Image = imageId,
                ScaleType = Enum.ScaleType.Fit,
                LayoutOrder = 1,
            }),
            Message = React.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.3),
                BackgroundTransparency = 1,
                Text = phrase,
                TextColor3 = Color3.fromRGB(220, 220, 220),
                TextSize = 14,
                Font = Enum.Font.Gotham,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                LayoutOrder = 2,
            }),
        }),
        Toggle = React.createElement(ToggleOverviewButton, {
            name = "ToggleOverviewTop",
            onActivated = UISDeath.toggleOverview,
            size = UDim2.fromScale(0.2, 0.1),
            position = UDim2.fromScale(0.98, 0.02),
            anchorPoint = Vector2.new(1, 0),
            textSize = 12,
        }),
    })
end

return OverviewContainer
