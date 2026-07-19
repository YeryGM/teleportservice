local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local FastCast2 = require(ReplicatedStorage.packages2.FastCast2)
local FastCastEnums = require(ReplicatedStorage.packages2.FastCast2.FastCastEnums)

export type FireContext = {
	Owner: any,
	Origin: Vector3,
	Direction: Vector3,
	SpeedMultiplier: number?,
	Data: any?,
}
export type CastUserData = {
	Owner: any,
	FireContext: FireContext,
	BounceCount: number,
	SpawnTime: number,
}

export type ProjectileContext = {
	Cast: any,
	Owner: any,
	FireContext: FireContext,
	SpawnTime: number,
	BounceCount: number,
}
export type FireData = {
    direction: Vector3,
    holdTime: number?,
}

export type ProjectileConfig = {
	-- Projectile
	Speed: number,
	Gravity: Vector3,
	Lifetime: number,
	MaxDistance: number,
	ProjectileModel: Instance?,
	ImpactRadius: number?,
	ImpactRaycastParams: RaycastParams?,
	-- Bounce
	CanBounce: boolean?,
	MaxBounces: number?,
	BounceDamping: number?,
	-- Charge
	UseCharge: boolean?,
	MaxChargeTime: number?,
	-- Cosmetic
	UseObjectCache: boolean?,
	ObjectCacheSize: number?,
	CosmeticContainer: Instance?,
	RotateWithVelocity: boolean?,
}

export type ImpactData = {
	Position: Vector3,
	Normal: Vector3,
	Velocity: Vector3,
	Instance: Instance?,
	Material: Enum.Material,
	BounceCount: number,
}

local Projectile = {}
Projectile.__index = Projectile

function Projectile.new(config: ProjectileConfig)
	assert(config.Speed, "Missing Speed")
	assert(config.Gravity, "Missing Gravity")
	assert(config.MaxDistance, "Missing MaxDistance")
	assert(config.Lifetime, "Missing Lifetime")

	local self = setmetatable({}, Projectile)
	self.config = config
	self.caster = FastCast2.new()
	self.behavior = self:createBehavior()
	self:createCaster()
	return self
end

function Projectile:getContext(cast): ProjectileContext
	local data = cast.UserData
	return {
		Cast = cast,
		Owner = data.Owner,
		FireContext = data.FireContext,
		SpawnTime = data.SpawnTime,
		BounceCount = data.BounceCount,
	}
end

function Projectile:createDefaultRaycastParams(): RaycastParams
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {}
	params.IgnoreWater = true
	return params
end

function Projectile:createOverlapParams(): OverlapParams
	local overlap = OverlapParams.new()
	overlap.FilterType = Enum.RaycastFilterType.Exclude
	overlap.FilterDescendantsInstances = {}
	return overlap
end

function Projectile:createBehavior()
	local behavior = FastCast2.newBehavior()
	behavior.RaycastParams = self.config.ImpactRaycastParams or self:createDefaultRaycastParams()
	behavior.Acceleration = self.config.Gravity
	behavior.MaxDistance = self.config.MaxDistance
	behavior.HighFidelityBehavior = FastCastEnums.HighFidelityBehavior.Default
	behavior.HighFidelitySegmentSize = 1
	behavior.CosmeticBulletTemplate = self.config.ProjectileModel
	behavior.CosmeticBulletContainer = self.config.CosmeticContainer or Workspace
	return behavior
end

function Projectile:createCaster()
	local useCache = self.config.UseObjectCache == true
	self.caster:Init(
		"BulkMoveTo",
		useCache,
		self.config.ProjectileModel,
		self.config.ObjectCacheSize or 100,
		self.config.CosmeticContainer or Workspace
	)
	self.caster.Hit = function(cast, result, velocity, cosmetic)
		self:_onHit(
			cast,
			result,
			velocity,
			cosmetic
		)
	end

	self.caster.LengthChanged = function(
		cast,
		lastPoint,
		direction,
		displacement,
		velocity,
		cosmetic
	)
		self:_onLengthChanged(
			cast,
			lastPoint,
			direction,
			displacement,
			velocity,
			cosmetic
		)
	end

	self.caster.CastTerminating = function(cast)
		self:_onTerminate(cast)
	end
end

function Projectile:reflectVelocity(velocity: Vector3, normal: Vector3, damping: number): Vector3
	return (velocity- (2 * velocity:Dot(normal) * normal)) * damping
end

function Projectile:Fire(fireContext: FireContext)
	if not self:canFire(fireContext) then
		return
	end
	local speed = self.config.Speed
	if self.config.UseCharge then
		local maxCharge = self.config.MaxChargeTime or 1
		local holdTime = math.clamp(fireContext.Data and fireContext.Data.holdTime or maxCharge,0,maxCharge)
		speed *= holdTime / maxCharge
	end
	local cast = self.caster:RaycastFire(
		fireContext.Origin,
		fireContext.Direction.Unit,
		speed,
		self.behavior
	)

	cast.UserData = {
		Owner = fireContext.Owner,
		FireContext = fireContext,
		BounceCount = 0,
		SpawnTime = os.clock(),
	}

	local context = self:getContext(cast)
	task.delay(self.config.Lifetime, function()
		if cast then
			FastCast2:TerminateCast(cast)
		end
	end)
	self:onFire(context)
	return cast
end

function Projectile:_onHit(cast, result: RaycastResult, velocity: Vector3, cosmetic: Instance?)
	local data = cast.UserData
	local impactData: ImpactData = {
		Position = result.Position,
		Normal = result.Normal,
		Velocity = velocity,
		Instance = result.Instance,
		Material = result.Material,
		BounceCount = data.BounceCount,
	}

	local canBounce = self.config.CanBounce == true
	local maxBounces = self.config.MaxBounces or 0
	local context = self:getContext(cast)
	if canBounce and data.BounceCount < maxBounces then
		data.BounceCount += 1
		local reflected = self:reflectVelocity(
				velocity,
				result.Normal,
				self.config.BounceDamping or 0.5
			)

		FastCast2:SetVelocityCast(cast,reflected)
		FastCast2:SetPositionCast(cast, result.Position + result.Normal * 0.05)
		
		self:onBounce(context, impactData)
		return
	end
	FastCast2:TerminateCast(cast)
	self:handleImpact(context, impactData, cosmetic)
end

function Projectile:_onLengthChanged(
	_cast,
	lastPoint: Vector3, 
	direction: Vector3, 
	_displacement, 
	_velocity, 
	cosmetic
)

	if not cosmetic then
		return
	end
	if not self.config.RotateWithVelocity then
		return
	end
	local cf = CFrame.lookAt(lastPoint,lastPoint + direction)
	if cosmetic:IsA("BasePart") then
		cosmetic.CFrame = cf
	elseif cosmetic:IsA("Model") then
		cosmetic:PivotTo(cf)
	end
end

function Projectile:_onTerminate(cast)
    self:onTerminate(
        self:getContext(cast)
    )
end

function Projectile:onTerminate(_context)
	-- override
end

function Projectile:handleImpact(context, impactData)
    self:onImpact(context, impactData)
end

function Projectile:getPartsInRadius(position: Vector3, radius: number): {BasePart}
	if not self.overlapParams then
		self.overlapParams = self:createOverlapParams()
	end
	local parts = Workspace:GetPartBoundsInRadius(
		position,
		radius,
		self.overlapParams
	)
	return parts
end

function Projectile:canFire(_fireContext: FireContext): boolean
	return true
end

function Projectile:onFire(context)
	return context
end

function Projectile:onBounce(_cast,_impactData: ImpactData)
	-- override
end

function Projectile:onImpact(_context:ProjectileContext,_impactData: ImpactData,_hitParts: {BasePart})
	-- override
end

function Projectile:Destroy()
	if self.caster then
		self.caster:Destroy()
		self.caster = nil
	end
	self.behavior = nil
	self.overlapParams = nil
end

return Projectile