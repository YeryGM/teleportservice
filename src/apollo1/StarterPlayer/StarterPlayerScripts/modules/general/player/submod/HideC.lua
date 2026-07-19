local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local hideEvent:RemoteEvent = ReplicatedStorage.events.general.player.hide

local HideC = {
    conns = {},
    keysToDetect = {
        [Enum.KeyCode.W] = true,
        [Enum.KeyCode.A] = true,
        [Enum.KeyCode.S] = true,
        [Enum.KeyCode.D] = true,
    },
    animDelay = 1,
}
HideC.__index = HideC

local function setCharacterVisibility(playerCharacter, isVisible: boolean)
	for _, v in ipairs(playerCharacter:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("Decal") then
			if v.Name ~= "HumanoidRootPart" then
				v.Transparency = isVisible and 0 or 1
			end
		end
	end
end

function HideC.new(player:Player)
    local self = setmetatable({}, HideC)
    self.player = player
    self.camera = Workspace.CurrentCamera
    self.isHidden = false
    self.actualHidingSpot = nil
    self.debugOn = false
    self:load()
    return self
end

function HideC:load()
    local conn = hideEvent.OnClientEvent:Connect(function(data)
        if typeof(data) ~= "table" then return end
        if data.shouldHide ~= true then return end
        self:hide(data)
    end)
    table.insert(self.conns, conn)

    local conn2 = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end 
        if self.isHidden and self.keysToDetect[input.KeyCode] then
            hideEvent:FireServer({shouldHide = false})
            self:unhidePlayer()
            self.isHidden = false
        end
    end)
    table.insert(self.conns, conn2)
end

function HideC:unload()
    for _, conn in ipairs(self.conns) do
        conn:Disconnect()
    end
    self.conns = {}
end


function HideC:hidePlayer(data)
    if not data or not data.hidingSpot then return end
    local insidePart = data.hidingSpot.insidePart
    if not insidePart then return end
    if self.isHidden then 
        if self.debugOn then 
            print("Player is hidden, cannot hide again") 
        end
        return 
    end
    local character = self.player.Character
    if not character then return end
    self.isHidden = true
    local ht = data.hideTime
    if ht and assert(typeof(ht) == "number", "Invalid hideTime type") then
        HideC.animDelay = ht
    else
        ht = HideC.animDelay
    end
	self.camera.CameraType = Enum.CameraType.Scriptable
	self.camera.CameraSubject = insidePart.CFrame
	setCharacterVisibility(character, false)

	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	TweenService:Create(self.camera, tweenInfo, {CFrame = insidePart.CFrame}):Play()
	task.wait(ht)
    return true
end

function HideC:unhidePlayer()
    if not self.actualHidingSpot then return end
    local outside = self.actualHidingSpot.outsidePart
    if not outside then return end
    if not self.isHidden then 
        if self.debugOn then 
            print("Player is not hidden, cannot unhide") 
        end
        return 
    end
    local character = self.player.Character
    if not character then return end
    self.isHidden = false
    local tweenOut = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    TweenService:Create(self.camera, tweenOut, {CFrame = outside.CFrame}):Play()
    task.wait(tweenOut.Time)
    self.camera.CameraType = Enum.CameraType.Custom
    self.camera.CameraSubject = character
    self:setCharacterVisibility(character, true)
end

return HideC