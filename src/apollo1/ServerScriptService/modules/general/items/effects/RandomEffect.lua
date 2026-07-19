local Effect = require(script.Parent.Effect)

local RandomEffect = {
    isReappliable = true,
    isAccumulative = false,
    probs = {
		[101] = 25, -- HealthEffect
		[102] = 20, -- JumpEffect
		[103] = 15, -- SpeedEffect
		[104] = 10, -- StaminaEffect
		[120] = 5,  -- PoisonEffect
		[121] = 3,  -- DeathEffect
		[122] = 2,  -- FreezeEffect
		[123] = 1,  -- SlowEffect
	},
	effectModules = {
		[101] = require(script.Parent.HealthEffect),
		[102] = require(script.Parent.JumpEffect),
		[103] = require(script.Parent.SpeedEffect),
		[104] = require(script.Parent.StaminaEffect),
		[150] = require(script.Parent.PoisonEffect),
		[151] = require(script.Parent.DeathEffect),
		[152] = require(script.Parent.FreezeEffect),
		[153] = require(script.Parent.SlowEffect),
	}
}
RandomEffect.__index = RandomEffect
setmetatable(RandomEffect, {__index = Effect})

function RandomEffect.new(player: Player, onRemove)
    local self = setmetatable(Effect.new(player, onRemove), RandomEffect)
    self.effectProbs= {}
    self.effects = {}
    return self
end

function RandomEffect:apply(data)
    if not self.player.Character or not self.player.Character.Humanoid then return end
    for effectId, module in pairs(self.effectModules) do
       self.effectProbs[effectId].probability = self.probs[effectId] or 0
       self.effectProbs[effectId].module = module
    end
	local numEffects = Random.new():NextInteger(1, data.maxEffects)
	for _i = 1, numEffects do
		local effectId = self:selectRandomEffects()
		if effectId then
			--maybe check compatibility here
			local instance = self.effects[effectId] 
			if instance then
				instance:load(data)
			else
				instance = self.effectProbs[effectId].module.new(self.player, self.onRemove)
				instance:load(data)
				self.effects[effectId] = instance
				if self.debugOn then
					print("Applied effect:", effectId)
				end
			end
		end
		continue
	end
end

function RandomEffect:remove()
  
end

function RandomEffect:selectRandomEffects()
	local selected = nil
	local totalWeight = 0
	for _effectId, data in pairs(self.effectProbs) do
		totalWeight += data.probability
	end
	local pick = Random.new():NextNumber(0, totalWeight)
	local cumulative = 0
	for effectId, data in pairs(self.effectProbs) do
		cumulative += data.probability
		if pick <= cumulative then
			selected = effectId
			break
		end
	end
	return selected
end

return RandomEffect