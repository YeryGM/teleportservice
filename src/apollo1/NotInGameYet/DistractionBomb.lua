local ReplicatedStorage = game:GetService("ReplicatedStorage")

local distractBreath = ReplicatedStorage.events.server.general.bindable.distractBreath

local Bomb = require(script.Parent.Bomb)

local DistractionBomb = {
    affectCaster = true,
    explodeOnImpact = false,
    onlyPlayers = false,
    hasEffect = false,
}

function DistractionBomb.new(config, tool)
    local self = setmetatable(Bomb.new(config, tool), {__index = DistractionBomb})
    return self
end

function DistractionBomb:onExplode(_player, impactData, _hitPlayers)
   --will fire event to breath so it goes to state distracted at impact pos
    if not impactData.Position then
        if self.debugOn then
            warn("DistractionBomb: No impact position provided")
        end
        return
     end
    distractBreath:Fire(impactData.Position, self.config.data)
end
return DistractionBomb