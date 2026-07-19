local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Enums = require(ReplicatedStorage.modules.general.data.Enums)
local StateMachine = require(ReplicatedStorage.modules.general.utils.StateMachine)
--submodules
local submods = script.Parent.submod
local Stamina = require(submods.StaminaC)
local Hide = require(submods.HideC)
local ToolsC = require(submods.ToolsC)
local QteC = require(submods.QteC)
--events/funcs
local remoteEvents = ReplicatedStorage.events.general.player
local ragdoll: RemoteEvent = remoteEvents.ragdoll
local qteEvent: RemoteEvent = remoteEvents.qte
local npcAttack: RemoteEvent = remoteEvents.npcAttack
local toggleShouldCheck: RemoteEvent = remoteEvents.toggleShouldCheck

local _remoteFuncs = ReplicatedStorage.funcs.general.player

local config = {
    [Enums.player.states.Walk] = {velocity = 1},
    [Enums.player.states.Run] = {velocity = 1.5},
    [Enums.player.states.Crouch] = {velocity = 0.5},
    [Enums.player.states.Attacked] = {velocity = 0},
    [Enums.player.states.Hidden] = {velocity = 0},
}

local anims = {
    [0] = { -- 0 for player anims
        [Enums.player.states.Hiding] = {
            id = "rbxassetid://2515090838",
            looped = true,
            priority = Enum.AnimationPriority.Core,
        },
    },
    [Enums.npc.types.Breath] = {
        [Enums.npc.actions.Breath.Qte] = {
            id =  "rbxassetid://2515090838",
            looped = false,
            priority = Enum.AnimationPriority.Action,
        },
       
    },
    
}

local Player = {
    debugOn = false,
}


local function ragdollCharacter(character, delay: number)
    local function motor6DWithBallSocket(joint: Motor6D, parent)
        if joint:IsA("Motor6D") then
            local part0 = joint.Part0
            local part1 = joint.Part1
            local ballSocket = Instance.new("BallSocketConstraint")
            local attachment0 = Instance.new("Attachment")
            local attachment1 = Instance.new("Attachment")
            ballSocket.Attachment0 = attachment0
            ballSocket.Attachment1 = attachment1
            ballSocket.Attachment0.Position = joint.C0
            ballSocket.Attachment0.Orientation = Vector3.new(joint.C0:ToEulerAnglesXYZ())
            ballSocket.Attachment1.Position = joint.C1
            ballSocket.Attachment1.Orientation = Vector3.new(joint.C1:ToEulerAnglesXYZ())
            attachment0.Parent = part0
            attachment1.Parent = part1
            ballSocket.Parent = parent
            joint.Enabled = false
        end
    end
    local function ballSocketToMotor6D(joint)
        if joint:IsA("BallSocketConstraint") then
            joint:Destroy()
        end
        if joint:IsA("Motor6D") then
            joint.Enabled = true
        end
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not humanoidRootPart then return end
	humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
    humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
    humanoid.PlatformStand = true
    humanoid.RequiresNeck = false
    humanoidRootPart.CanCollide = false
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyVelocity.Velocity = Vector3.new(0, -10, -20)
    bodyVelocity.Parent = humanoidRootPart
	Debris:AddItem(bodyVelocity, delay - 0.1)

    for _, joint in pairs(character:GetDescendants()) do
        if joint:IsA("Motor6D") then
            motor6DWithBallSocket(joint, character)
        end
    end
    
	task.delay(delay, function()
        if humanoid.Health <= 0 then
            return
        end
		humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		humanoid.PlatformStand = false
		for _, joint in pairs(character:GetDescendants()) do
            ballSocketToMotor6D(joint)
        end
	end)
end

local function freezeCharacter(player:Player)
    local character = player.Character
    if not character then return end
    local HumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if HumanoidRootPart then
        HumanoidRootPart.Anchored = true
    end
end

local function unfreezeCharacter(player:Player)
    local character = player.Character
    if not character then return end
    local HumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if HumanoidRootPart then
        HumanoidRootPart.Anchored = false
    end
end

local function cleanUpConns(conns)
    for _, conn in ipairs(conns) do
        if conn and conn.Disconnect then
            conn:Disconnect()
        end
    end
    table.clear(conns)
end

function Player:load()
    local player = Players.LocalPlayer
    self.lastState = nil
    self.conns = {}
    self.globalConns = {}
    self.characterConns = {}
    self.characterLoaded = false
    self.playerLoaded = false
    self.player = player
    self.stateMachine = StateMachine.new()
    self.handlers = {
        stamina = Stamina.new(function() self.stateMachine:SetState(Enums.player.states.Walk) end),
        hide = Hide.new(player),
        tools = ToolsC.new(player),
        qtes = QteC:load(player)
    }
    self:setUp()
end

function Player:setUp()
    if self.playerLoaded then
        if self.debugOn then
            print("Player already loaded for", self.player.Name)
        end
        return
    end
    self.playerLoaded = true
    self:setupStateMachine()

    local characterAddedConn = self.player.CharacterAdded:Connect(function(character)
        self:loadCharacter(character)
    end)
    table.insert(self.characterConns, characterAddedConn)
    local characterRemovingConn = self.player.CharacterRemoving:Connect(function()
        self:unloadCharacter()
    end)
    table.insert(self.characterConns, characterRemovingConn)

    local conn = ragdoll.OnClientEvent:Connect(function(delay: number)
        ragdollCharacter(self.player.Character, delay)
    end)
    table.insert(self.globalConns, conn)

    local conn2 = qteEvent.OnClientEvent:Connect(function(qteEnum:number, data)
        self.handlers.qtes:create(qteEnum, data)
    end)
    table.insert(self.globalConns, conn2)

    local conn3 = toggleShouldCheck.OnClientEvent:Connect(function(shouldCheck: boolean)
        self.handlers.stamina:setShouldCheck(shouldCheck)
    end)
    table.insert(self.globalConns, conn3)

    local conn4 = npcAttack.OnClientEvent:Connect(function(npcEnum: number, actionEnum: number, data: any?)
        self.stateMachine:SetState(Enums.player.states.Attacked, false, npcEnum, actionEnum, data)
    end)
    table.insert(self.globalConns, conn4)

    self:loadCharacter(self.player.Character)
end

-- STATE MACHINE
function Player:setupStateMachine()
    local function updateState(newState:number)
        if self.lastState ~= newState then
            self.lastState = newState
            local humanoid = self.player.Character:WaitForChild("Humanoid")
            humanoid.WalkSpeed = humanoid.WalkSpeed * config[newState].velocity
        end
    end

    self.stateMachine:SetStateChangedCallback(function(prevState, newState)
        if self.debugOn then 
            print("State change:", prevState, "->", newState)
        end
        cleanUpConns(self.conns)
        self.conns = {}
        self:playAnim(newState)
        updateState(newState)
        task.wait(0.05)
    end)

    self.stateMachine:AddState(Enums.player.states.Walk,
        function() self:walkEnter() end, 
        function() self:walkExit() end
    )
    self.stateMachine:AddState(Enums.player.states.Run, 
        function() self:runEnter() end, 
        function() self:runExit() end
    )
    self.stateMachine:AddState(Enums.player.states.Crouch, 
        function() self:crouchEnter() end, 
        function() self:crouchExit() end
    )
    self.stateMachine:AddState(Enums.player.states.Minigame, 
        function(minigameEnum: number, data:any?) 
            self:minigameEnter(minigameEnum, data) 
        end, 
        function() self:minigameExit() end
    )
    self.stateMachine:AddState(Enums.player.states.Attacked, 
        function(npcEnum: number, actionEnum: number, data:any?) 
            self:attackedEnter(npcEnum, actionEnum, data) 
        end, 
        function() self:attackedExit() end
    )
end

--WALK
function Player:walkEnter()
	local InputHandlers = {
		began = {
			[Enum.KeyCode.C] = function()
                self.stateMachine:SetState(Enums.player.states.Crouch)
			end,
			[Enum.KeyCode.LeftShift] = function()
				self.stateMachine:SetState(Enums.player.states.Run)
			end
		},
    }

    local inputBeganConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and InputHandlers.began[input.KeyCode] then
			InputHandlers.began[input.KeyCode]()
		end
	end)
    table.insert(self.conns, inputBeganConn)
end

function Player:walkExit()
end
--RUN
function Player:runEnter()	
	local InputHandlers = {
		began = {
			[Enum.KeyCode.C] = function()
                self.stateMachine:SetState(Enums.player.states.Crouch)
			end,
		},
        ended = {
            [Enum.KeyCode.LeftShift] = function()
                self.stateMachine:SetState(Enums.player.states.Walk)
            end
        }
    }
    local inputBeganConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and InputHandlers.began[input.KeyCode] then
			InputHandlers.began[input.KeyCode]()
		end
	end)
    local inputEndedConn = UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if not gameProcessed and InputHandlers.ended[input.KeyCode] then
            InputHandlers.ended[input.KeyCode]()
        end
    end)	
    table.insert(self.conns, inputBeganConn)
    table.insert(self.conns, inputEndedConn)    
    self.handlers.stamina:setOnUse(true)
end

function Player:runExit()
    self.handlers.stamina:setOnUse(false)
end
--CROUCH
function Player:crouchEnter()
	local InputHandlers = {
		began = {
			[Enum.KeyCode.LeftShift] = function()
                self.stateMachine:SetState(Enums.player.states.Run)
			end
			},
        ended = {
            [Enum.KeyCode.C] = function()
                self.stateMachine:SetState(Enums.player.states.Walk)
            end
        }
    }

    local inputBeganConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and InputHandlers.began[input.KeyCode] then
			InputHandlers.began[input.KeyCode]()
		end
	end)
    local inputEndedConn = UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if not gameProcessed and InputHandlers.ended[input.KeyCode] then
            InputHandlers.ended[input.KeyCode]()
        end
    end)	
    table.insert(self.conns, inputBeganConn)
    table.insert(self.conns, inputEndedConn)   
end

function Player:crouchExit()
    
end
--MINIGAME minigames so player stays frozen
function Player:minigameEnter(minigameEnum:number, _data:any?)
    freezeCharacter(self.player)
    local handler = {
        [1] = function()
               
        end,
    }
    if handler[minigameEnum] then
        handler[minigameEnum]()
    end 
end

function Player:minigameExit()
    unfreezeCharacter(self.player)
end
--ATTACKED: for npcs that dont insta kill like the ones that play anim 
function Player:attackedEnter(npcEnum:number, actionEnum:number, data:any?)
    if data.shouldFreeze and not self.frozen then
        self.frozen = true
        freezeCharacter(self.player)
    end
    local duration = data and data.duration
    local handler = {
        [Enums.npc.types.Breath] = function()
            local character = self.player.Character
            if not character then return end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            local animID = npcEnum * 100 + actionEnum
            self:playAnim(animID, duration)

        end,
    }
    if handler[npcEnum] then
        handler[npcEnum]()
    end
end

function Player:attackedExit()
    if self.frozen then
        self.frozen = false
        unfreezeCharacter(self.player)
    end
end
--HIDDEN
function Player:hiddenEnter()
    
end

function Player:hiddenExit()
    
end

--CHARACTER
function Player:loadCharacter(character)
    if self.characterLoaded then
		if self.debugOn then
			print("Character already loaded for", self.player.Name)
		end
		return
	end
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		if self.debugOn then
			print("Humanoid missing for", self.player.Name)
		end
		return
	end
	self.characterLoaded = true
	local diedConn = humanoid.Died:Connect(function()
		
	end)
	table.insert(self.characterConns, diedConn)
    self:loadAnims(humanoid)
    self.stateMachine:SetState(Enums.player.states.Walk)
end

function Player:unloadCharacter()
   if not self.characterLoaded then
		if self.debugOn then
			print("Character not loaded for", self.player.Name)
		end
		return
	end
	cleanUpConns(self.characterConns)
	self.characterConns = {}
	self.characterLoaded = false
    self.animsTracks = {}
end

--ANIMS
local function loadAnim(animator: Animator, animId: string)
    local anim = Instance.new("Animation")
    anim.AnimationId = animId
    return animator:LoadAnimation(anim)
end

function Player:loadAnims(humanoid: Humanoid)
    local animator = humanoid:WaitForChild("Animator")
    local animTracks = {}
    for charId, actionData in pairs(anims) do
        for actionId, animData in pairs(actionData) do
            local id = charId * 100 + actionId
            local track = loadAnim(animator, animData.id)
            animTracks[id] = track
        end
    end
    self.animsTracks = animTracks
end

function Player:playAnim(id:number, duration:number?)
    local animTrack:AnimationTrack = self.animsTracks[id]
    if animTrack then
        if duration then
            local speed = animTrack.Length / duration
            animTrack:AdjustSpeed(speed)
        end
        animTrack:Play()
    end
    return animTrack
end

function Player:stopAnim(id:number)
    local animTrack = self.animsTracks[id]
    if animTrack and animTrack.IsPlaying then
        animTrack:Stop()
    end
end

   

return Player