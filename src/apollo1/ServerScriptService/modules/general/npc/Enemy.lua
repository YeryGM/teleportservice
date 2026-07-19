local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local Npc= require(script.Parent.Npc)

local defaults = {
	fovAngle = 120,
	fanRays = 7,
	noiseThreshold = 2,
	hitboxRadius = 3,
	hitboxDistance = 4,
	hitboxOffset = Vector3.new(0, 2, 0),
}

local Enemy = {
	debugOn = false,
}
Enemy.__index = Enemy
setmetatable(Enemy, {__index = Npc})

function Enemy.new(id:number, model: Model, agent, 
	anims:{[number]: string},
	properties:{maxHealth: number?, walkSpeed: number?, detectionRadius: number?, damage: number?})
    local self = setmetatable(Npc.new(id, model, agent, anims, { 
		health = properties.maxHealth, 
		walkSpeed = properties.walkSpeed }),
		Enemy
	)
    self.radius = properties.detectionRadius or defaults.hitboxDistance
	self.detection = {
		fovAngle = defaults.fovAngle,
		fanRays = defaults.fanRays,
		noiseThreshold = defaults.noiseThreshold,
		hitboxRadius = defaults.hitboxRadius,
		hitboxDistance = defaults.hitboxDistance,
		hitboxOffset = defaults.hitboxOffset,
	}
	self.damage = properties.damage or 10
	self.raycastParams = nil
    return self
end

function Enemy:getRaycastParams()
	if not self.raycastParams then
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.RespectCanCollide = false
		self.raycastParams = params
	end
	self.raycastParams.FilterDescendantsInstances = {self.model}
	return self.raycastParams
end

function Enemy:getPlayerCharacterFromHit(hit: Instance)
	if not hit then
		return nil
	end
	local model = hit:FindFirstAncestorOfClass("Model")
	if not model then
		return nil
	end
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return nil
	end
	if not model:FindFirstChild("HumanoidRootPart") then
		return nil
	end
	if Players:GetPlayerFromCharacter(model) then
		return model
	end
	return nil
end

function Enemy:detectHitboxPlayer(hitboxRadius: number?, hitboxDistance: number?, hitboxOffset: Vector3?)
	if not self.humanoidRootPart then
		return nil
	end
	local radius = hitboxRadius or self.detection.hitboxRadius
	local distance = hitboxDistance or self.detection.hitboxDistance
	local offset = hitboxOffset or self.detection.hitboxOffset
	if not radius or not distance then
		return nil
	end
	local origin = self.humanoidRootPart.Position + offset
	local direction = self.humanoidRootPart.CFrame.LookVector * distance
	local result = Workspace:Spherecast(origin, radius, direction, self:getRaycastParams())
	if not result then
		return nil
	end
	return self:getPlayerCharacterFromHit(result.Instance)
end

function Enemy:callCondition(condition, playerCharacter)
	if not condition then
		return false
	end
	local ok, result = pcall(condition, self, playerCharacter)
	if ok then
		return result
	end
	return condition(playerCharacter)
end

function Enemy:attack(player:Player)
	local character = player.Character
	if not character then return end
	local tHumanoid:Humanoid = character:FindFirstChildOfClass("Humanoid")
	if not tHumanoid then return end
    if self:isAlive() and tHumanoid.Health > 0 then
        tHumanoid:TakeDamage(self.damage)
    end
end

function Enemy:killPlayer(player:Player)
	local character = player.Character
	if not character then return end
	local tHumanoid:Humanoid = character:FindFirstChildOfClass("Humanoid")
	if not tHumanoid then return end
    tHumanoid.Health = 0
end

function Enemy:isPlayerWithinRadius(playerCharacter, radius)
    local hrp = playerCharacter:FindFirstChild("HumanoidRootPart")
    if not hrp or not self.humanoidRootPart then return false end

    local dist = (hrp.Position - self.humanoidRootPart.Position).Magnitude
    return dist <= radius
end

function Enemy:fitsConditions(playerCharacter, detectConditions)
	if not detectConditions then
		return true
	end
	for _, condition in pairs(detectConditions) do
		if condition and not self:callCondition(condition, playerCharacter) then
			return false
		end
	end
    return true
end

function Enemy:fitsOneCondition(playerCharacter, detectConditions)
	if not detectConditions then
		return true
	end
	for _, condition in pairs(detectConditions) do
		if condition and self:callCondition(condition, playerCharacter) then
			return true
		end
	end
	return false
end

function Enemy:detectClosestPlayer(skipCondition, detectConditions)
    local closest, closestDist = nil, self.radius
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not self:isPlayerWithinRadius(player.Character, self.radius) then
                continue
            end
			if skipCondition and self:callCondition(skipCondition, player.Character) then
                if Enemy.debugOn then
                    print("Skipping target:", player.Name)
                end
                continue
            end
			local dist = (player.Character.HumanoidRootPart.Position - self.humanoidRootPart.Position).Magnitude
			if dist < closestDist then
                if not detectConditions then
                    closest, closestDist = player.Character, dist
                end
				if self:fitsOneCondition(player.Character, detectConditions) then
					closest, closestDist = player.Character, dist
				end
			end
		end
	end
	return closest
end


function Enemy:isPlayerVisible(playerCharacter, fovAngle: number?, fanRays: number?)
    local hrp = playerCharacter:FindFirstChild("HumanoidRootPart")
	if not hrp or not self.humanoidRootPart then return false end

	local origin = self.humanoidRootPart.Position
	local direction = (hrp.Position - origin)
	local distance = direction.Magnitude
	if distance <= 0 then
		return true
	end
	local forward = self.humanoidRootPart.CFrame.LookVector
	local dot = forward:Dot(direction.Unit)
	dot = math.clamp(dot, -1, 1)
	local angle = math.deg(math.acos(dot))
	local maxFov = fovAngle or self.detection.fovAngle
	if not maxFov or angle > maxFov / 2 then
		return false
	end
	local rays = fanRays or self.detection.fanRays
	local params = self:getRaycastParams()
	if not rays or rays <= 1 then
		local ray = Workspace:Raycast(origin, direction, params)
		if not ray then
			return true
		end
		return ray.Instance and ray.Instance:IsDescendantOf(playerCharacter) or false
	end
	local halfFov = math.rad(maxFov / 2)
	local step = (halfFov * 2) / (rays - 1)
	local base = self.humanoidRootPart.CFrame
	for i = 0, rays - 1 do
		local yaw = -halfFov + step * i
		local dir = (base * CFrame.Angles(0, yaw, 0)).LookVector * distance
		local ray = Workspace:Raycast(origin, dir, params)
		if ray and ray.Instance and ray.Instance:IsDescendantOf(playerCharacter) then
			return true
		end
	end
	return false
end

function Enemy:isPlayerMakingNoise(playerCharacter, noiseThreshold: number?)
    local humanoid = playerCharacter:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end

	local threshold = noiseThreshold or self.detection.noiseThreshold
    local speed = humanoid.MoveDirection.Magnitude * humanoid.WalkSpeed
	return threshold and speed >= threshold or false
end

function Enemy:followPathTo(destination: Vector3, timeout:number, interruptCondition,
    detectedTargetCallback,skipCondition,detectionConditions)

    local path = self:computePathTo(destination)
	if not path then return false end

	local waypoints = path:GetWaypoints()
	if Enemy.debugOn then
		self:showWaypoints(waypoints)
	end
	local blockedAt = nil
	local blockedConn = path.Blocked:Connect(function(blockedIndex)
		blockedAt = blockedIndex
	end)
    table.insert(self.conns, blockedConn)
    
	local function cleanup()
		if blockedConn then
			blockedConn:Disconnect()
			local idx = table.find(self.conns, blockedConn)
			if idx then
				table.remove(self.conns, idx)
			end
			blockedConn = nil
		end
	end
	local i = 1
	while i <= #waypoints do
		if interruptCondition and interruptCondition() then
			cleanup()
			return false
		end

		if blockedAt and blockedAt >= i then
			path = self:computePathTo(destination)
			if not path then
				 cleanup(); 
				 return false 
			end
			waypoints = path:GetWaypoints()
			if Enemy.debugOn then
				self:showWaypoints(waypoints)
			end
			blockedAt = nil
			i = 1
			continue
		end
        --move to next waypoint
		local wp = waypoints[i]
		local ok = self:moveTo(wp.Position, interruptCondition, timeout)
		if not ok then
			 cleanup(); 
			 return false
	    end
		-- Check for target after reaching each waypoint
		if detectedTargetCallback then
			local target = self:detectHitboxPlayer()
			if target and skipCondition and self:callCondition(skipCondition, target) then
				target = nil
			end
			if not target then
				target = self:detectClosestPlayer(skipCondition, detectionConditions)
			end
			if target then
				if detectedTargetCallback(target) then
					cleanup()
					return true
				end
			end
		end
		i += 1
	end

	cleanup()
	return true
end

function Enemy:showWaypoints(waypoints)
	for _, wp in ipairs(waypoints) do
		local p = Instance.new("Part")
		p.Position = wp.Position
		p.Anchored = true
		p.CanCollide = false
		p.Size = Vector3.new(1,1,1)
		p.Color = Color3.new(0,1,0)
		p.Parent = workspace
		Debris:AddItem(p, 2)
	end
end
return Enemy