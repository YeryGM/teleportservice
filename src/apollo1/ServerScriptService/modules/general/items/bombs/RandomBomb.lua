local Bomb = require(script.Parent.Parent.projectiles.Bomb)

local RandomBomb = {
    affectCaster = true,
    explodeOnImpact = false,
    onlyPlayers = true,
    hasEffect = true,
}
RandomBomb.__index = RandomBomb
setmetatable(RandomBomb, {__index = Bomb})

function RandomBomb.new(config, tool)
    local self = setmetatable(Bomb.new(config, tool), RandomBomb)
    return self
end

function RandomBomb:onExplode(_player, _impactData, _hitPlayers)
   
end
return RandomBomb