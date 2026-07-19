local Effect = require(script.Parent.Effect)

local HealthEffect = {
    isReappliable = true,
    isAccumulative = false,
}
HealthEffect.__index = HealthEffect
setmetatable(HealthEffect, {__index = Effect})

function HealthEffect.new(player: Player, onRemove)
    local self = setmetatable(Effect.new(player, onRemove), HealthEffect)
    return self
end

function HealthEffect:apply(data)
    if not self.player.Character or not self.player.Character.Humanoid then return end
    local maxHealth = self.player.Character.Humanoid.MaxHealth
    local currentHealth = self.player.Character.Humanoid.Health
    local newHealth = math.min(maxHealth, currentHealth + (maxHealth * data.healPercentage))
    self.player.Character.Humanoid.Health = newHealth
    if self.debugOn then
        print("Previous health for " .. self.player.Name .. ": " .. currentHealth)
        print("Actual health for " .. self.player.Name .. ": " .. newHealth)
    end
end

function HealthEffect:remove()
end

return HealthEffect