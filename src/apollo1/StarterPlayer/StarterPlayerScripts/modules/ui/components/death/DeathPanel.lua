local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local UISDeath = require(script.Parent.Parent.Parent.services.UISDeath)
local useDeath = require(script.Parent.Parent.Parent.hooks.useDeath)

local ReviveHeader = require(script.Parent.ReviveHeader)
local OverviewContainer = require(script.Parent.OverviewContainer)
local ToggleOverviewButton = require(script.Parent.ToggleOverviewButton)
local SpectateControls = require(script.Parent.SpectateControls)
local ReturnToLobbyButton = require(script.Parent.ReturnToLobbyButton)
local PlayAgainButton = require(script.Parent.PlayAgainButton)

local function DeathPanel()
    local visible = useDeath.useVisible()
    if not visible then
        return nil
    end

    local isSpectating = useDeath.useIsSpectating()

    return React.createElement("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
    }, {
        ReviveHeader = React.createElement(ReviveHeader, {
            visible = not isSpectating,
            onActivated = UISDeath.requestRevive,
        }),
        Overview = React.createElement(OverviewContainer), --we could pass mode so dimensions adjust spectator vs dead
        ToggleOverview = React.createElement(ToggleOverviewButton, {
            name = "ToggleOverviewBottom",
            onActivated = UISDeath.toggleOverview,
            size = UDim2.fromScale(0.18, 0.05),
            position = UDim2.fromScale(0.1, 0.9),
            anchorPoint = Vector2.new(0.5, 0.5),
            textSize = 12,
        }),
        Spectate = React.createElement(SpectateControls),
        
        PlayAgain = React.createElement(PlayAgainButton, {
            onActivated = UISDeath.requestPlayAgain,
            size = UDim2.fromScale(0.18, 0.06),
            position = UDim2.fromScale(0.5, 0.9),
            anchorPoint = Vector2.new(0.5, 0.5),
            visible = not isSpectating,
        }),
        ReturnToLobby = React.createElement(ReturnToLobbyButton, {
            onActivated = UISDeath.requestReturnToLobby,
        }),
    })
end

return DeathPanel
