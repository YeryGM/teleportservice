local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local function CutsceneSkip()
    local visible, setVisible = React.useState(true)
    if not visible then
        return nil
    end
    React.useEffect(function()
        local duration = 1 
        local startTime = os.clock()
        local connection
        local function updateShown()
            local alpha = math.clamp((os.clock() - startTime) / duration, 0, 1)
            local easedAlpha = alpha * alpha * (3 - 2 * alpha)
            setVisible(easedAlpha < 1)

            if alpha >= 1 and connection then
                connection:Disconnect()
                connection = nil
            end
        end
        setVisible(false)
        updateShown()
        connection = RunService.Heartbeat:Connect(updateShown)

        return function()
            if connection then
                connection:Disconnect()
            end
        end
    end, {})

    return React.createElement("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    }, {
        Init = React.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "Press [F] to skip",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextScaled = true,
            Visible = visible,
        })
    })
end

return CutsceneSkip
