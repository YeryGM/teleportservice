local Bomb = require(script.Parent.Parent.projectiles.Bomb)

local JumpBomb = {
    affectCaster = true,
    explodeOnImpact = false,
    onlyPlayers = true,
    hasEffect = true,
}
JumpBomb.__index = JumpBomb
setmetatable(JumpBomb, {__index = Bomb})

function JumpBomb.new(config, tool)
    local self = setmetatable(Bomb.new(config, tool), JumpBomb)
    return self
end

function JumpBomb:onExplode(_player, _impactData, _hitParts)
   
end
return JumpBomb