local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.modules.general.data.Enums)
local StateMachine = require(ReplicatedStorage.modules.general.utils.StateMachine)

local Enemy = require(script.Parent.Enemy)
local generalFolder = script.Parent.Parent
local Configs = require(generalFolder.data.Configs)
local RepeatedPressVal = require(generalFolder.interaction.qte.RepeatedPress)

local npcAttack: RemoteEvent = ReplicatedStorage.events.general.player.npcAttack

local E = {
	states = {
        Cutscene = 1,
        Patrol = 2,
        Chase = 3,
        Attack = 4,
        Minigame = 5,
		Cooldown = 6,
    },
}

local anims = {
	[Enums.npc.actions.Breath.Qte] = "rbxassetid://2515090838",
	[Enums.npc.actions.Breath.Kill] = "rbxassetid://2515090838",
	[Enums.npc.actions.Breath.Cooldown] = "rbxassetid://2515090838",
	[Enums.npc.actions.Breath.Cutscene] = "rbxassetid://2515090838",
}

local timeout = 2

local Breath = {
	debugOn = false,
}
Breath.__index = Breath
setmetatable(Breath, {__index = Enemy})

function Breath.new(id: number, model: Model, patrolWaypoints: {Vector3})
	local config = Configs.getConfig().npc.Breath
	local properties = config.properties
	local agent = config.agent
    local self = setmetatable(Enemy.new(id, model, agent, anims, {
		detectRadius = properties.detectRadius, 
		maxHealth = properties.maxHealth, 
		walkSpeed = properties.walkSpeed, 
		damage = properties.damage
	}), Breath
	)
	
    self.stateMachine = StateMachine.new()
    self.attackDistance = properties.attackDistance
    self.patrolWaypoints = patrolWaypoints
	self.debugOn = Breath.debugOn
	self.stopRequested = false
    self.currentState = E.states.Cutscene
    self:setUpStateMachine()()
    return self
end
-- HELPER
function Breath:signalStop()
	self.stopRequested = true
end

function Breath:isStopRequested()
	return self.stopRequested
end

function Breath:resetFlags(newState)
	self.stopRequested = false
	self.currentState = newState
end

--DETECTION
function Breath:isPlayerHiding(playerCharacter):boolean
    if not playerCharacter then
        return false
    end
    local playerstate = playerCharacter:GetAttribute("st")
	if playerstate == Enums.player.states.Hidden then
		if self.debugOn then 
			print("Skipped:", playerCharacter.Name, "- MovementState:", playerstate) 
		end
		return true
	end
    return false
end

function Breath:detectTarget()
	local hitboxTarget = self:detectHitboxPlayer()
	if hitboxTarget and not self:isPlayerHiding(hitboxTarget) then
		return hitboxTarget
	end
	return self:detectClosestPlayer(self.isPlayerHiding, {self.isPlayerVisible, self.isPlayerMakingNoise})
end

-- STATE MACHINE 
function Breath:setUpStateMachine()
    self.stateMachine:SetStateChangedCallback(function(prevState: string, newState: string)
        if self.debugOn then 
            print("Breath State change:", prevState, "->", newState)
        end
        self:signalStop() 
        task.wait(0.05)
        self:resetFlags(newState)
    end)
    
	self.stateMachine:AddState(E.states.Cutscene, 
		function() self:cutsceneEnter() end, 
		function() self:cutsceneExit() end
	)
	self.stateMachine:AddState(E.states.Patrol, 
		function() self:patrolEnter() end, 
		function() self:patrolExit() end
	)
	self.stateMachine:AddState(E.states.Chase, 
		function(target:Model) self:chaseEnter(target) end, 
		function() self:chaseExit() end
	)
	self.stateMachine:AddState(E.states.Attack, 
		function(player:Player)self:attackEnter(player) end, 
		function() self:attackExit() end
	)
	self.stateMachine:AddState(E.states.Minigame, 
		function(player:Player)self:minigameEnter(player) end, 
		function() self:minigameExit() end
	)
	self.stateMachine:AddState(E.states.Cooldown, 
		function()self:coolDownEnter() end, 
		function() self:coolDownExit() end
	)
	
    self.stateMachine:SetState(E.states.Cutscene)
end
--cutscene
function Breath:cutsceneEnter()
    if self.debugOn then
        print("Entering cutscene State")
    end
	local track = self:playAnim(Enums.npc.actions.Breath.Cutscene)
	track.Stopped:Wait()
	if self.stateMachine:GetState() == E.states.Cutscene and not self:isStopRequested() then
		self.stateMachine:SetState(E.states.Patrol)
	end
end

function Breath:cutsceneExit()
end
--PATROL
function Breath:patrolEnter()
    if self.debugOn then
        print("Entering Patrol State")
    end
    self:resetFlags(E.states.Patrol)
	
	while self.stateMachine:GetState() == E.states.Patrol and not self:isStopRequested() do
		-- Check for targets before moving
		local playerTarget = self:detectTarget()
		if playerTarget then
			self.stateMachine:SetState(E.states.Chase, nil, playerTarget)
			return
		end
		local destination = self.patrolWaypoints[math.random(1, #self.patrolWaypoints)]
		local destinationPos = nil
		if destination then
			if typeof(destination) == "Vector3" then
				destinationPos = destination
			elseif typeof(destination) == "Instance" and destination:IsA("BasePart") then
				destinationPos = destination.Position
			end
		end
		if not destinationPos then
			task.wait(0.25)
		end
		local ok = destinationPos and self:followPathTo(destinationPos, 2,
			function()
				return self.stateMachine:GetState() ~= E.states.Patrol or self:isStopRequested()
			end,
			function(target)
			    -- Target detection callback - return true to interrupt pathfinding
			    if target then
					self.stateMachine:SetState(E.states.Chase, nil, target)
					return true
				end
				return false
			end,
            self.isPlayerHiding, 
			{self.isPlayerVisible, self.isPlayerMakingNoise}
			) or false
		-- If we were interrupted by state change, exit
		if self:isStopRequested() or self.stateMachine:GetState() ~= E.states.Patrol then
			return
		end
		-- If pathfinding failed, wait a bit before trying again
		if not ok then
			task.wait(0.25)
		end
	end
end

function Breath:patrolExit()
	
end

function Breath:chaseEnter(targetPlayerCharacter)
    if self.debugOn then
        print("Entering Chasing State")
    end
    self:resetFlags(E.states.Chase)

	local chaseTarget = targetPlayerCharacter or self:detectTarget()
	if not chaseTarget or not chaseTarget:FindFirstChild("HumanoidRootPart") then
		self.stateMachine:SetState(E.states.Patrol)
		return
	end
	local lastSeenTime = os.clock()
	local maxChaseTime = 1
	local lastPosition = chaseTarget.HumanoidRootPart.Position

	while self.stateMachine:GetState() == E.states.Chase and not self:isStopRequested() do
		local currentTarget = self:detectTarget()
		if currentTarget then
			chaseTarget = currentTarget
			lastSeenTime = os.clock()
			local hrp = chaseTarget:FindFirstChild("HumanoidRootPart")
			if hrp then
				lastPosition = hrp.Position
			end
		end
			-- Check if we lost target for too long
		if not chaseTarget or not chaseTarget:FindFirstChild("HumanoidRootPart") or (os.clock() - lastSeenTime) > maxChaseTime then
			if self.debugOn then 
				print("Lost target, returning to patrol") 
			end
			self.stateMachine:SetState(E.states.Patrol)
			return
		end
			
		if self:isPlayerWithinRadius(chaseTarget, self.attackDistance) then
			local plr = Players:GetPlayerFromCharacter(chaseTarget)
			if plr then
                local playerState = chaseTarget:GetAttribute("st")
                if playerState == Enums.player.states.Hiding then
                    self.stateMachine:SetState(E.states.Minigame, nil, plr)
                else
					self.stateMachine:SetState(E.states.Attack, nil, plr)
                end
			    return
			end
		end
		-- Follow the target 
		local chaseHrp = chaseTarget:FindFirstChild("HumanoidRootPart")
		local destination = chaseHrp and chaseHrp.Position or lastPosition
		if destination then
			self:followPathTo(destination, timeout,
			    function(): boolean
					return self.stateMachine:GetState() ~= E.states.Chase or self:isStopRequested()
				end,
				function(detectedTarget)
					-- Update chase target if we spot someone else closer
					if detectedTarget then
						local newDist = (self.humanoidRootPart.Position - detectedTarget.HumanoidRootPart.Position).Magnitude
						local currentDist = (self.humanoidRootPart.Position - chaseTarget.HumanoidRootPart.Position).Magnitude
						if newDist < currentDist then
							chaseTarget = detectedTarget
							lastSeenTime = os.clock()
							lastPosition = detectedTarget.HumanoidRootPart.Position
							if self.debugOn then 
								print("Switched chase target") 
							end
							return true 
						end
					end
					return false
				end,
                self.isPlayerHiding, 
                {self.isPlayerVisible, self.isPlayerMakingNoise}
				)
		end
		-- Small delay to prevent excessive processing
		task.wait(0.5)
	end
end

function Breath:attackEnter(player:Player)
    if self.debugOn then 
		print("Attacking player:", player.Name) 
	end
    self:resetFlags(E.states.Attack)
	if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		self.stateMachine:SetState(E.states.Patrol)
		return
	end
	local track = self:playAnim(Enums.npc.actions.Breath.Qte)
	npcAttack:FireClient(player, Enums.npc.types.Breath, Enums.npc.actions.Breath.Qte, {duration = track.Length})
	track.Stopped:Wait()
	
	self:killPlayer(player)
	if self.stateMachine:GetState() == E.states.Attack and not self:isStopRequested() then
		if self.debugOn then 
			print(" Attack finished, returning to patrol") 
		end
		self.stateMachine:SetState(E.states.Patrol)
	end
end

function Breath:attackExit()
	
end

function Breath:minigameEnter(player:Player)
    if self.debugOn then
        print("Entering Minigame State with player:", player.Name)
    end
    self:resetFlags(E.states.Minigame)
	if not player or not player.Character then
		self.stateMachine:SetState(E.states.Patrol)
	    return
	end
	local qte = RepeatedPressVal.new(player,
		function() 
			self:attack(player)
			if self.stateMachine:GetState() == E.states.Minigame and not self:isStopRequested() then
				self.stateMachine:SetState(E.states.Cooldown)
			end
		end,
		function() 
			self:killPlayer(player) 
		end, 
		Enums.npc.types.Breath
	)

	local animDuration = qte.duration
	local track = self:playAnim(Enums.npc.actions.Breath.Qte, animDuration)
	npcAttack:FireClient(player, Enums.npc.types.Breath, Enums.npc.actions.Breath.Qte, {duration = animDuration})
	track.Stopped:Connect(function()
		if self.stateMachine:GetState() == E.states.Minigame and not self:isStopRequested() then
			self.stateMachine:SetState(E.states.Cooldown)
		end
	end)
end

function Breath:coolDownEnter()
	if self.debugOn then
		print("Entering Cooldown State")
	end
	self:resetFlags(E.states.Cooldown)
	local track = self:playAnim(Enums.npc.actions.Breath.Cooldown)
	track.Stopped:Wait()
	if self.stateMachine:GetState() == E.states.Cooldown and not self:isStopRequested() then
		self.stateMachine:SetState(E.states.Patrol)
	end
end

function Breath:coolDownExit()
end

return Breath