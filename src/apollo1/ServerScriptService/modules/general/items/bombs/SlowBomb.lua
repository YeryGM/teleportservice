local Bomb = require(script.Parent.Parent.projectiles.Bomb)

local SlowBomb = {
    affectCaster = true,
    explodeOnImpact = false,
    onlyPlayers = true,
    hasEffect = true,
}
SlowBomb.__index = SlowBomb
setmetatable(SlowBomb, {__index = Bomb})

function SlowBomb.new(config, tool)
    local self = setmetatable(Bomb.new(config, tool), SlowBomb)
    return self
end

function SlowBomb:onExplode(_player, _impactData, _hitParts)
   
end
return SlowBomb