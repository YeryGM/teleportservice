local Bomb = require(script.Parent.Parent.projectiles.Bomb)

local PoisonBomb = {
    affectCaster = true,
    explodeOnImpact = false,
    onlyPlayers = true,
    hasEffect = true,
}
PoisonBomb.__index = PoisonBomb
setmetatable(PoisonBomb, {__index = Bomb})

function PoisonBomb.new(config, tool)
    local self = setmetatable(Bomb.new(config, tool), PoisonBomb)
    return self
end

function PoisonBomb:onExplode(_player, _impactData, _hitParts)
   
end
return PoisonBomb