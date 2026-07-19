local TweenService = game:GetService("TweenService")

local HidingSpot = require(script.Parent.HidingSpot)

local Closet = {}
Closet.__index = Closet

function Closet.new(model)
    local self = setmetatable(HidingSpot.new(model), Closet)
    self:load()
    return self
end

function Closet:load()
    local hinge1 = self.model.hinge1
    local hinge2 = self.model.hinge2
    if not (hinge1 and hinge2) then
        warn("Closet model is missing hinges")
        return
    end
    self.hinge1 = hinge1
    self.hinge2 = hinge2
end

function Closet:animateOpen()
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	TweenService:Create(self.hinge1, tweenInfo, {CFrame = self.hinge1.CFrame * CFrame.Angles(0, math.rad(100), 0)}):Play()
	TweenService:Create(self.hinge2, tweenInfo, {CFrame = self.hinge2.CFrame * CFrame.Angles(0, math.rad(-100), 0)}):Play()
	task.wait(tweenInfo.Time)
	TweenService:Create(self.hinge1, tweenInfo, {CFrame = self.hinge1.CFrame * CFrame.Angles(0, math.rad(-80), 0)}):Play()
	TweenService:Create(self.hinge2, tweenInfo, {CFrame = self.hinge2.CFrame * CFrame.Angles(0, math.rad(80), 0)}):Play()
end

function Closet:animateClose()
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	TweenService:Create(self.hinge1, tweenInfo, {CFrame = self.hinge1.CFrame * CFrame.Angles(0, math.rad(80), 0)}):Play()
	TweenService:Create(self.hinge2, tweenInfo, {CFrame = self.hinge2.CFrame * CFrame.Angles(0, math.rad(-80), 0)}):Play()
	task.wait(tweenInfo.Time)
	TweenService:Create(self.hinge1, tweenInfo, {CFrame = self.hinge1.CFrame * CFrame.Angles(0, math.rad(-100), 0)}):Play()
	TweenService:Create(self.hinge2, tweenInfo, {CFrame = self.hinge2.CFrame * CFrame.Angles(0, math.rad(100), 0)}):Play()
end

return Closet