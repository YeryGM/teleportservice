local ReplicatedStorage = game:GetService("ReplicatedStorage")

local playerRemoteEvents = ReplicatedStorage.events.general.player
local spectateTargetEvent: RemoteEvent = playerRemoteEvents.spectateTarget
local spectateStepEvent: RemoteEvent = playerRemoteEvents.spectateStep

local Spectating = {
	debugOn = false,
	waitSeconds = 30,
	stepCooldown = 0.25,
	alive = {},
	spectators = {},
	conns = {},
}

local function getAliveList(aliveMap, excludeUserId: number)
	local list = {}
	for userId, _ in pairs(aliveMap) do
		if userId ~= excludeUserId then
			table.insert(list, userId)
		end
	end
	table.sort(list)
	return list
end

function Spectating:areThereAlivePlayers()
	return next(self.alive) ~= nil
end

function Spectating:markAlive(player: Player)
	if not player then
		return
	end
	self.alive[player.UserId] = true
	self:assignWaitingSpectators()
end

function Spectating:markDead(player: Player)
	if not player then
		return
	end
	self.alive[player.UserId] = nil
	self:handleTargetRemoved(player.UserId)
end

function Spectating:removePlayer(player: Player)
	if not player then
		return
	end
	self.alive[player.UserId] = nil
	self:handleTargetRemoved(player.UserId)
	self:stopSpectating(player)
	self:clearWaiting(player)
end

function Spectating:startSpectating(player: Player)
	if not player then
		return
	end
	local userId = player.UserId
	local data = self.spectators[userId]
	if not data then
		data = {
			player = player,
			targetUserId = nil,
			waiting = false,
			waitToken = 0,
			lastStepAt = 0,
		}
		self.spectators[userId] = data
	end
	self:assignTarget(player)
end

function Spectating:stopSpectating(player: Player)
	if not player then
		return
	end
	local userId = player.UserId
	if not self.spectators[userId] then
		return
	end
	self.spectators[userId] = nil
end

function Spectating:assignTarget(player: Player, direction: number?)
	local userId = player.UserId
	local data = self.spectators[userId]
	if not data then
		return
	end

	local aliveList = getAliveList(self.alive, userId)
	if #aliveList == 0 then
		self:startWaitingReturn(player)
		return
	end

	local targetUserId = nil
	if not direction then
		targetUserId = aliveList[1]
	else
		local currentIndex = table.find(aliveList, data.targetUserId) or 1
		local nextIndex = currentIndex + direction
		if nextIndex < 1 then
			nextIndex = #aliveList
		elseif nextIndex > #aliveList then
			nextIndex = 1
		end
		targetUserId = aliveList[nextIndex]
	end

	data.targetUserId = targetUserId
	data.waiting = false
	spectateTargetEvent:FireClient(player,{targetUserId = targetUserId})
end

function Spectating:assignWaitingSpectators()
	for _, data in pairs(self.spectators) do
		if data.waiting then
			self:assignTarget(data.player)
		end
	end
end

function Spectating:handleTargetRemoved(removedUserId: number)
	for _, data in pairs(self.spectators) do
		if data.targetUserId == removedUserId then
			self:assignTarget(data.player)
		end
	end
end

function Spectating:startWaitingReturn()
	if self.awaitingReturn then
		return
	end
	self.awaitingReturn = true
	task.delay(self.waitSeconds, function()
		if not self.awaitingReturn then
			return
		end
		self:returnToLobby()
	end)
end

function Spectating:clearWaiting(player: Player)
	local data = self.spectators[player.UserId]
	if not data then
		return
	end
	data.waiting = false
	data.waitToken = data.waitToken + 1
end

function Spectating:stepTarget(player: Player, direction:number)
	local data = self.spectators[player.UserId]
	if not data then
		return
	end
	local now = os.clock()
	if data.lastStepAt and now - data.lastStepAt < self.stepCooldown then
		return
	end
	data.lastStepAt = now
	local step = 0
	if not ((direction == 1) or (direction == -1)) then
		return
	end
	self:assignTarget(player, step)
end

function Spectating:returnToLobby()
	
end

function Spectating:load()
	local conn = spectateStepEvent.OnServerEvent:Connect(function(player: Player, direction:number)
		self:stepTarget(player, direction)
	end)
	table.insert(self.conns, conn)
end

function Spectating:unload()
	for _, conn in ipairs(self.conns) do
		conn:Disconnect()
	end
	self.conns = {}
	self.alive = {}
	self.spectators = {}
end

return Spectating