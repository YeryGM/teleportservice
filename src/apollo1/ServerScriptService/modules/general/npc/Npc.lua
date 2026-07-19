local PathfindingService = game:GetService("PathfindingService")

local default = {
    agent = {
		AgentRadius = 2,
		AgentHeight = 11,
		AgentCanJump = true,
		AgentJumpHeight = 10,
		AgentMaxSlope = 45,
	},
	properties = {
		health = 100,
		walkSpeed = 16,
	},
}

local Npc = {
    debugOn = false,
}
Npc.__index = Npc

function Npc.new(id:number, model: Model, agent, 
	anims: {[number]: string},
	properties:{maxHealth: number?, walkSpeed: number?})
	local hrt = model:FindFirstChild("HumanoidRootPart")
	local humanoid: Humanoid? = model:FindFirstChildOfClass("Humanoid")
	if not hrt or not humanoid then
		if Npc.debugOn then
			error("Model must contain a Humanoid and HumanoidRootPart to create an NPC.")
		end
		return nil
	end
    local self = setmetatable({}, Npc)
    self.id = id 

    self.maxHealth = properties.maxHealth or default.properties.health
    self.walkSpeed = properties.walkSpeed or default.properties.walkSpeed
	self.agent = agent or default.agent
    self.model = model
    self.conns = {}
	self.animTracks = {}
	self:load(humanoid, hrt, anims)
    return self
end

function Npc:load(humanoid:Humanoid, humanoidRootPart: Part, anims: {[number]: string})
	if not humanoid or not humanoidRootPart then
		return
	end
	self.humanoid = humanoid
	self.humanoidRootPart = humanoidRootPart
	
	self.humanoid.WalkSpeed = self.walkSpeed
	self.humanoid.MaxHealth = self.maxHealth
	self.humanoid.Health = self.maxHealth
	
	for action, animId in pairs(anims) do
		local anim = Instance.new("Animation")
		anim.AnimationId = animId
		self.animTracks[action] = self.humanoid:LoadAnimation(anim)
	end
end

function Npc:unload()
	for _, conn in pairs(self.conns) do
        if conn and conn.Connected then
			conn:Disconnect()
		end
    end
    self.conns = {}
	self.humanoid = nil
	self.humanoidRootPart = nil
end

function Npc:takeDamage(amount:number)
	self.humanoid.TakeDamage(self.humanoid, amount)
end

function Npc:isAlive(): boolean
    return self.humanoid.Health > 0
end

function Npc:computePathTo(destination: Vector3)
    local path = PathfindingService:CreatePath({
		AgentRadius = self.agent.AgentRadius or default.agent.AgentRadius,
		AgentHeight = self.agent.AgentHeight or default.agent.AgentHeight,
		AgentCanJump = self.agent.AgentCanJump or default.agent.AgentCanJump,
		AgentJumpHeight = self.agent.AgentJumpHeight or default.agent.AgentJumpHeight,
		AgentMaxSlope = self.agent.AgentMaxSlope or default.agent.AgentMaxSlope,
	})
	local ok = pcall(function()
		path:ComputeAsync(self.humanoidRootPart.Position, destination)
	end)
	if ok and path.Status == Enum.PathStatus.Success then
		return path
	end
	return nil
end

function Npc:moveTo(destination: Vector3, checkInterrupt: (() -> boolean)?, timeout: number)
    local reached, cancelled = false, false
	timeout = timeout or 3
	local start = os.clock()

	local conn = self.humanoid.MoveToFinished:Connect(function(success)
		reached = success
	end)
    table.insert(self.conns, conn)
	self.humanoid:MoveTo(destination)
	while not reached and not cancelled and (os.clock() - start) < timeout do
		if checkInterrupt and checkInterrupt() then
			cancelled = true
			break
		end
		task.wait(0.1)
	end
	if conn then 
		conn:Disconnect()
		local idx = table.find(self.conns, conn)
		if idx then
			table.remove(self.conns, idx)
		end
	end
	if not reached and not cancelled then
		self.humanoid:MoveTo(self.humanoidRootPart.Position)
	end
	return not cancelled and reached
end

function Npc:playAnim(id:number, duration:number?)
    local animTrack:AnimationTrack = self.animTracks[id]
    if animTrack then
        if duration then
            local speed = animTrack.Length / duration
            animTrack:AdjustSpeed(speed)
        end
        animTrack:Play()
    end
    return animTrack
end

return Npc