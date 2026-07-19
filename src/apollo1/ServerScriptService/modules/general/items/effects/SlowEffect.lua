local Effect = require(script.Parent.Effect)

local SlowEffect = {
    isReappliable = true,
    isAccumulative = false,
}
SlowEffect.__index = SlowEffect
setmetatable(SlowEffect, {__index = Effect})

function SlowEffect.new(player: Player, onRemove)
    local self = setmetatable(Effect.new(player, onRemove), SlowEffect)
    return self
end

function SlowEffect:apply(data)
    if not self.player.Character then return end
    self.originalData.walkSpeed = self.player.Character.Humanoid.WalkSpeed
    local newWalkSpeed = self.originalData.walkSpeed * (data.slowPercentage or 1)
    self.player.Character.Humanoid.WalkSpeed = newWalkSpeed or 0
    if self.debugOn then
        print("New WalkSpeed: " .. newWalkSpeed)
    end
end

function SlowEffect:remove()
    if not self.player.Character then return end
    self.player.Character.Humanoid.WalkSpeed = self.originalData.walkSpeed or 16
    if self.debugOn then
        print("WalkSpeed restored to: " .. (self.originalData.walkSpeed or 16) .. " for " .. self.player.Name)
    end
end

return SlowEffect