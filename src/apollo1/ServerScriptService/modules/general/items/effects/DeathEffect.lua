local Effect = require(script.Parent.Effect)

local DeathEffect = {}
DeathEffect.__index = DeathEffect
setmetatable(DeathEffect, Effect)

function DeathEffect.new(player: Player, onRemove)
    local self = setmetatable(Effect.new(player, onRemove), DeathEffect)
    return self
end

function DeathEffect:apply()
    if not self.player.Character or not self.player.Character.Humanoid then return end
    self.player.Character.Humanoid.Health = 0
    if self.debugOn then
        print("Effect killed player " .. self.player.Name )
    end
end

function DeathEffect:remove()
end

return DeathEffect