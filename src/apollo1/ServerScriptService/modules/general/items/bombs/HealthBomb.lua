local Bomb = require(script.Parent.Parent.projectiles.Bomb)

local HealthBomb = {
    affectCaster = true,
    explodeOnImpact = false,
    onlyPlayers = true,
    hasEffect = true,
}
HealthBomb.__index = HealthBomb
setmetatable(HealthBomb, {__index = Bomb})

function HealthBomb.new(config, tool)
    local self = setmetatable(Bomb.new(config, tool), HealthBomb)
    return self
end

function HealthBomb:onExplode(_player, _impactData, _hitParts)
   
end
return HealthBomb