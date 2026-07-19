local Bomb = require(script.Parent.Parent.projectiles.Bomb)

local DeathBomb = {
    affectCaster = true,
    explodeOnImpact = false,
    onlyPlayers = true,
    hasEffect = true,
}
DeathBomb.__index = DeathBomb
setmetatable(DeathBomb, {__index = Bomb})

function DeathBomb.new(config, tool)
    local self = setmetatable(Bomb.new(config, tool), DeathBomb)
    return self
end

function DeathBomb:onExplode(_player, _impactData, _hitParts)
   
end
return DeathBomb