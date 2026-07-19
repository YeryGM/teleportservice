local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local useCutscene = require(script.Parent.Parent.Parent.Parent.hooks.useCutscene)

local function CutsceneBars()
    local visible = useCutscene.selectVisible()
    if not visible then
        return nil
    end

    local targetHeightScale = useCutscene.selectBars().heightScale or 0.12
    local color = Color3.fromRGB(0, 0, 0)
    targetHeightScale = math.clamp(targetHeightScale, 0, 0.5)

    local heightScale, setHeightScale = React.useState(0)

    React.useEffect(function()
        local duration = 0.25
        local startTime = os.clock()

        local connection
        local function updateHeightScale()
            local alpha = math.clamp((os.clock() - startTime) / duration, 0, 1)
            local easedAlpha = alpha * alpha * (3 - 2 * alpha)
            setHeightScale(targetHeightScale * easedAlpha)

            if alpha >= 1 and connection then
                connection:Disconnect()
                connection = nil
            end
        end

        setHeightScale(0)
        updateHeightScale()
        connection = RunService.Heartbeat:Connect(updateHeightScale)

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
        Top = React.createElement("Frame", {
            Size = UDim2.fromScale(1, heightScale),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
        }),
        Bottom = React.createElement("Frame", {
            Size = UDim2.fromScale(1, heightScale),
            Position = UDim2.fromScale(0, 1),
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
        }),
    })
end

return CutsceneBars
