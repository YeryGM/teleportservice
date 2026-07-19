local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Projectile = require(script.Parent.Projectile)
local Backpack = require(script.Parent.Parent.actions.Backpack)

local bindableEvent = ServerScriptService.events.general.player
local applyEffects: BindableEvent = bindableEvent.applyEffects

export type BombConfig = Projectile.ProjectileConfig & {
	fuseTime: number?,
	OnlyPlayers: boolean?,
	EffectId: string?,
	Data: any?,
}

local Bomb = {}
Bomb.__index = Bomb
setmetatable(Bomb, { __index = Projectile })

function Bomb.new(config: BombConfig, tool: Tool)
	assert(tool, "Tool is required")
	local self = setmetatable(Projectile.new(config), Bomb)
	self.tool = tool
	self.fuseTime = config.fuseTime or 0
	self.onlyPlayers = config.OnlyPlayers or false
	return self
end

function Bomb:getUid(): string
	return self.tool:GetAttribute("uid")
end

function Bomb:canFire(fireContext): boolean
	local owner = fireContext.Owner
	if not owner or not owner:IsA("Player") then
		return true
	end
	return Backpack:hasItem(owner, self.tool.Name, 1)
end

function Bomb:onFire(context)
	local owner = context.Owner
	if owner and owner:IsA("Player") then
		Backpack:removeItem(owner, self.tool.Name, 1)
	end
end

function Bomb:onImpact(context, impactData)
	if self.fuseTime <= 0 then
		self:explode(context, impactData)
		return
	end
	task.delay(self.fuseTime, function()
		self:explode(context, impactData)
	end)
end

function Bomb:explode(context, impactData)
	self:playExplosionEffects(context, impactData)
	local hitParts = self:getPartsInRadius(
		impactData.Position,
		self.config.ImpactRadius or 0
	)
	if self.onlyPlayers then
		hitParts = self:getPlayers(hitParts, context.Owner)
	end
	self:onExplode(context, impactData, hitParts)
	if self.onlyPlayers and #hitParts > 0 then
		self:applyEffects(hitParts)
	end
end

function Bomb:getPlayers(parts: {BasePart}, owner)
	local players = {}
	local unique = {}
	for _, part in ipairs(parts) do
		local character = part:FindFirstAncestorOfClass("Model")
		if not character then
			continue
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			continue
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and player ~= owner and not unique[player] then
			unique[player] = true
			table.insert(players, player)
		end
	end
	return players
end

function Bomb:applyEffects(players)
	applyEffects:Fire(players,self.config.EffectId,self.config.Data)
end

function Bomb:playExplosionEffects(_context, _impactData)
	-- override
end

function Bomb:onExplode(_context, _impactData, _targets)
	-- override
end

return Bomb