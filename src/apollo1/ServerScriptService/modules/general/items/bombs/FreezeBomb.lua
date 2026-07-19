local Bomb = require(script.Parent.Parent.projectiles.Bomb)

local FreezeBomb = {
    affectCaster = true,
    explodeOnImpact = false,
    onlyPlayers = true,
    hasEffect = true,
}
FreezeBomb.__index = FreezeBomb
setmetatable(FreezeBomb, {__index = Bomb})

function FreezeBomb.new(config, tool)
    local self = setmetatable(Bomb.new(config, tool), FreezeBomb)
    return self
end

function FreezeBomb:onExplode(_player, _impactData, _hitParts)
   
end
return FreezeBomb