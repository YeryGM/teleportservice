local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))
local UISShop = require(script.Parent.Parent.Parent.services.UISShop)

local hooksFolder = script.Parent.Parent.Parent.hooks
local useShop = require(hooksFolder.useShop)

local function Counter()
    local data = useShop.useCountdown()
    local currentCount, setCurrentCount = React.useState(nil)
    local isFinishedRef = React.useRef(false)
    local connectionRef = React.useRef(nil)
    local syncDataRef = React.useRef(nil)
    
    React.useEffect(function()
        isFinishedRef.current = false
        syncDataRef.current = data
        local function updateCountdown()
            local now = workspace:GetServerTimeNow()
            local remaining = data.endTime - now
            if remaining <= 0 then
                if not isFinishedRef.current then
                    isFinishedRef.current = true
                    setCurrentCount(0)
                    if connectionRef.current then
                        connectionRef.current:Disconnect()
                        connectionRef.current = nil
                    end
                    UISShop.confirmPurchase()
                end
            return
            end
            local displayValue = math.max(1, math.ceil(remaining))
            setCurrentCount(displayValue)
        end
        updateCountdown()
        connectionRef.current = RunService.Heartbeat:Connect(updateCountdown)
       
        return function()
            if connectionRef.current then
                connectionRef.current:Disconnect()
            end
        end
    end, {})
    
    if currentCount == nil then
        return React.createElement("TextLabel", {
            Size = UDim2.fromScale(0.3, 0.08),
            Visible = false,
        })
    end
    return React.createElement("TextLabel", {
        Size = UDim2.fromScale(0.3, 0.08),
        Position = UDim2.fromScale(0.35, 0.46),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.3,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 48,
        Font = Enum.Font.GothamBold,
        Text = tostring(currentCount),
        TextScaled = true,
    })
end

return Counter