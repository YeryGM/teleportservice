local Effect = require(script.Parent.Effect)

local PoisonEffect = {
    isReappliable = true,
    isAccumulative = false,
}
PoisonEffect.__index = PoisonEffect
setmetatable(PoisonEffect, {__index = Effect})

function PoisonEffect.new(player: Player, onRemove)
    local self = setmetatable(Effect.new(player, onRemove), PoisonEffect)
    return self
end

function PoisonEffect:apply(data)
    if not self.player.Character or not self.player.Character.Humanoid then return end
    local totalDamage = self.player.Character.Humanoid.MaxHealth * data.damagePercentage
    local damagePerSecond = totalDamage / self.duration
    self.applyThread =task.spawn(function()
        while self.active do
            if not self.player.Character or not self.player.Character.Humanoid then return end
            local newHealth = math.max(0, self.player.Character.Humanoid.Health - (damagePerSecond * 0.1))
            if newHealth >= 0 then
                self.player.Character.Humanoid.Health = 0
            end
            self.player.Character.Humanoid.Health = newHealth
            task.wait(0.1)  
        end
    end)
end


function PoisonEffect:remove()
    if self.applyThread then
        self.applyThread:Cancel()
    end
    if self.debugOn then
        print("Poison duration has ended for " .. self.player.Name)
    end
end

return PoisonEffect