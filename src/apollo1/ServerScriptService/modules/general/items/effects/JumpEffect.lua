local Effect = require(script.Parent.Effect)

local JumpEffect = {
    isReappliable = true,
    isAccumulative = false,
}
JumpEffect.__index = JumpEffect
setmetatable(JumpEffect, {__index = Effect})

function JumpEffect.new(player: Player, onRemove)
    local self = setmetatable(Effect.new(player, onRemove), JumpEffect)
    self.originalData = {}
    return self
end

function JumpEffect:apply(data)
    if not self.player.Character or not self.player.Character.Humanoid then return end
    self.originalData.JumpHeight = self.player.Character.Humanoid.JumpHeight
    local newJumpHeight = self.originalData.JumpHeight * (data.jumpHeightPercentage or 1)
    self.player.Character.Humanoid.JumpHeight = newJumpHeight or 0
end

function JumpEffect:remove()
    if not self.player.Character or not self.player.Character.Humanoid then return end
    self.player.Character.Humanoid.JumpHeight = self.originalData.JumpHeight or 7.2
    if self.debugOn then
        print("JumpHeight restored to: " .. (self.originalData.JumpHeight or 7.2) .. " for " .. self.player.Name)
    end
end

return JumpEffect