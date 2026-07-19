local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts")
local UISDeath = require(PlayerScripts.modules.ui.services.UISDeath)

local remoteEvents = ReplicatedStorage.events.general.player
local returnToLobbyEvent: RemoteEvent = remoteEvents.returnToLobby
local spectateTargetEvent: RemoteEvent = remoteEvents.spectateTarget
local spectateStepEvent: RemoteEvent = remoteEvents.spectateStep

local remoteFuncs = ReplicatedStorage.funcs.general.player
local requestReviveFunc: RemoteFunction = remoteFuncs.requestRevive

local bindableFuncs = script.Parent.Parent.Parent.Parent.funcs.general.player
local requestRevive: BindableFunction = bindableFuncs.requestRevive

local bindableEvents = script.Parent.Parent.Parent.Parent.events.general.player
local changeSpectator: BindableEvent = bindableEvents.spectateStep

local ReviveC = {
	conns = {},
	debugOn = false,
	reviveLocked = false,
	targetConn = nil,
	targetUserId = nil,
	isSpectating = false,
	waiting = false,
	lastStepAt = 0,
	lastStepAtR = 0,
	stepCooldown = 0.25,
}

function ReviveC:requestRevive()
	if self.reviveLocked then
		return false
	end
	self.reviveLocked = true
	--set death screen revive to loading
	local ok, result = pcall(function()
		return requestReviveFunc:InvokeServer()
	end)
	self.reviveLocked = false
	if not ok then
		return false
	end
	if result then
		self:stopSpectating()
	end
	return result == true
end

function ReviveC:returnToLobby()
	if self.reviveLocked then
		return false
	end
	local now = os.clock()
	if now - self.lastStepAtR < self.stepCooldown then
		return
	end
	self.lastStepAtR = now
	returnToLobbyEvent:FireServer()
	return true
end

function ReviveC:setCameraToUserId(userId: number)
	local targetPlayer = Players:GetPlayerByUserId(userId)
	if not targetPlayer then
		return
	end

	if self.targetConn then
		self.targetConn:Disconnect()
		self.targetConn = nil
	end

	local function applyCharacter(character)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			humanoid = character:WaitForChild("Humanoid", 5)
		end
		if humanoid then
			local camera = workspace.CurrentCamera
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = humanoid
		end
	end

	if targetPlayer.Character then
		applyCharacter(targetPlayer.Character)
	end
	self.targetConn = targetPlayer.CharacterAdded:Connect(function(character)
		applyCharacter(character)
	end)
end

function ReviveC:handleTarget(payload)
	if type(payload) ~= "table" then
		return
	end
	if not payload.targetUserId then
		return
	end
	local targetPlayer = Players:GetPlayerByUserId(payload.targetUserId)
	if not targetPlayer then
		return
	end
	if not self.isSpectating then
		UISDeath.requestOverview()
	end
	local spectatorName = targetPlayer.DisplayName
	UISDeath.setSpectator(spectatorName)
	self.targetUserId = payload.targetUserId
	self.isSpectating = true
	self:setCameraToUserId(targetPlayer)
end

function ReviveC:requestStep(direction: number)
	if not self.isSpectating then
		return
	end
	local now = os.clock()
	if now - self.lastStepAt < self.stepCooldown then
		return
	end
	self.lastStepAt = now
	spectateStepEvent:FireServer(direction)
end

function ReviveC:stopSpectating()
	self.isSpectating = false
	self.waiting = false
	self.targetUserId = nil

	if self.targetConn then
		self.targetConn:Disconnect()
		self.targetConn = nil
	end

	local localPlayer = Players.LocalPlayer
	if localPlayer and localPlayer.Character then
		local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local camera = workspace.CurrentCamera
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = humanoid
		end
	end
end

function ReviveC:load()
	local conn = spectateTargetEvent.OnClientEvent:Connect(function(payload)
		self:handleTarget(payload)
	end)
	table.insert(self.conns, conn)

	local conn2 = changeSpectator.Event:Connect(function(direction)
		self:requestStep(direction)
	end)
	table.insert(self.conns, conn2)

	requestRevive.OnInvoke(function()
		return self:requestRevive()
	end)

end

function ReviveC:unload()
	for _, conn in ipairs(self.conns) do
		conn:Disconnect()
	end
	self.conns = {}
	self:stopSpectating()
end

return ReviveC