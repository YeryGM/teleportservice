-- ServerScriptService.Modules.Door
local TweenService = game:GetService("TweenService")

local DoorModule = {}

-- Función que inicializa la puerta
function DoorModule.Init(doorModel)
    local hinge = doorModel:WaitForChild("Hinge")
    local base = doorModel:WaitForChild("Base")
    local prompt = base:WaitForChild("ProximityPrompt")

    
    hinge.Anchored = false

    -- Estado
    local isOpen = false

    -- Tweens
    local tweenInfo = TweenInfo.new(1)
    local closedCFrame = hinge.CFrame
    local openCFrame = hinge.CFrame * CFrame.Angles(0, math.rad(90), 0)

    local tweenOpen = TweenService:Create(hinge, tweenInfo, {CFrame = openCFrame})
    local tweenClose = TweenService:Create(hinge, tweenInfo, {CFrame = closedCFrame})

    -- Evento del ProximityPrompt
    prompt.Triggered:Connect(function()
        prompt.Enabled = false

        if isOpen then
            tweenClose:Play()
            prompt.ActionText = "Open"
        else
            tweenOpen:Play()
            prompt.ActionText = "Close"
        end

        isOpen = not isOpen
        wait(1)
        prompt.Enabled = true
    end)
end

return DoorModule
