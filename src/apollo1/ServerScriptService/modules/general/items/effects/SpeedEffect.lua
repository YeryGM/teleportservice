local Effect = require(script.Parent.Effect)

local SpeedEffect = {
    isReappliable = true,
    isAccumulative = false,
}
SpeedEffect.__index = SpeedEffect
setmetatable(SpeedEffect, {__index = Effect})

function SpeedEffect.new(player: Player, onRemove)
    local self = setmetatable(Effect.new(player, onRemove), SpeedEffect)
    self.originalData = {}
    return self
end

function SpeedEffect:apply(data)
    if not self.player.Character or not self.player.Character.Humanoid then return end
    self.originalData.walkSpeed = self.player.Character.Humanoid.WalkSpeed
    local newWalkSpeed = self.originalData.walkSpeed * (data.speedPercentage or 1)
    self.player.Character.Humanoid.WalkSpeed = newWalkSpeed or 0
end

function SpeedEffect:remove()
    if not self.player.Character or not self.player.Character.Humanoid then return end
    self.player.Character.Humanoid.WalkSpeed = self.originalData.walkSpeed or 16
    if self.debugOn then
        print("WalkSpeed restored to: " .. (self.originalData.walkSpeed or 16) .. " for " .. self.player.Name)
    end
end

return SpeedEffect