local ServerScriptService = game:GetService("ServerScriptService")
local modifyStamina:BindableFunction = ServerScriptService.funcs.general.player.modifyStamina

local Effect = require(script.Parent.Effect)

local StaminaEffect = {
    isReappliable = true,
    isAccumulative = false,
    retryAttempts = 10,
}
StaminaEffect.__index = StaminaEffect
setmetatable(StaminaEffect, {__index = Effect})

function StaminaEffect.new(player: Player, onRemove)
    local self = setmetatable(Effect.new(player, onRemove), StaminaEffect)
    return self
end

function StaminaEffect:apply(data)
    if not self.player.Character or not self.player.Character.Humanoid then return end
    local ok = modifyStamina:Invoke(self.player, data.maxStamina, data.regenRate, data.drainRate)
    if not ok then
        warn("Failed to apply Stamina Effects to " .. self.player.Name)
        local attempts = 0
        while not ok or attempts < self.retryAttempts do
            task.wait(0.1)
            ok = modifyStamina:Invoke(self.player, true, data.maxStamina, data.regenRate, data.drainRate)
            attempts = attempts + 1
        end
    end
    if self.debugOn then
        print("Stamina Effects applied to " .. self.player.Name .. " with maxStamina: " .. tostring(data.maxStamina) .. ", regenRate: " .. tostring(data.regenRate) .. ", drainRate: " .. tostring(data.drainRate) .. ". Success: " .. tostring(ok))
    end
end


function StaminaEffect:remove()
    if not self.player.Character or not self.player.Character.Humanoid then return end
    local ok = modifyStamina:Invoke(self.player, false)
    if not ok then
        warn("Failed to remove Stamina Effects from " .. self.player.Name)
        local attempts = 0
        while not ok or attempts < self.retryAttempts do
            task.wait(0.1)
            ok = modifyStamina:Invoke(self.player, false)
            attempts = attempts + 1
        end
    end
    if self.debugOn then
        print("Stamina multiplier removed from " .. self.player.Name)
    end
    
end

return StaminaEffect