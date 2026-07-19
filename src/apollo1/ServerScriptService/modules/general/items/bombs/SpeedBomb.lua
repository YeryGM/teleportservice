local Bomb = require(script.Parent.Parent.projectiles.Bomb)

local SpeedBomb = {
    affectCaster = true,
    explodeOnImpact = false,
    onlyPlayers = true,
    hasEffect = true,
}
SpeedBomb.__index = SpeedBomb
setmetatable(SpeedBomb, {__index = Bomb})

function SpeedBomb.new(config, tool)
    local self = setmetatable(Bomb.new(config, tool), SpeedBomb)
    return self
end

function SpeedBomb:onExplode(_player, _impactData, _hitParts)
   
end
return SpeedBomb