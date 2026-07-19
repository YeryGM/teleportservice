local Bomb = require(script.Parent.Parent.projectiles.Bomb)

local StaminaBomb = {
    affectCaster = true,
    explodeOnImpact = false,
    onlyPlayers = true,
    hasEffect = true,
}
StaminaBomb.__index = StaminaBomb
setmetatable(StaminaBomb, {__index = Bomb})

function StaminaBomb.new(config, tool)
    local self = setmetatable(Bomb.new(config, tool), StaminaBomb)
    return self
end

function StaminaBomb:onExplode(_player, _impactData, _hitParts)
    
end
return StaminaBomb