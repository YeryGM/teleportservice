local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local IFSCutscenes = require(ServerScriptService.modules.general.data.info.IFSCutscene)

local storyRemoteEvents = ReplicatedStorage.events.general.storytelling
local start: RemoteEvent = storyRemoteEvents.cutsceneStart
local stop: RemoteEvent = storyRemoteEvents.cutsceneStop
local skip: RemoteEvent = storyRemoteEvents.cutsceneSkip

type CutsceneModule = {
	play: (players: {Player}, onEnd: () -> ()) -> any,
	stop: () -> (),
	duration: number,
	isGlobal: boolean,
	isSkippable: boolean,
}

type CutsceneRun = {
	cutsceneId: number,
	cutsceneModule: CutsceneModule,
	cutscene: any,
	runId: number,
	players: {Player},
	duration: number,
	isGlobal: boolean,
	isSkippable: boolean,
	ended: boolean,
	onEnd: () -> (),
	threads: {thread},
	skipVotes: {[number]: boolean},
}

local CutsceneM = {
	debugOn = false,
	playerQueues = {},
	playerActive = {},
	globalQueue = {},
	activeGlobal = nil,
	suppressQueue = false,
	runCounter = 0,
	conns = {},
}

function CutsceneM:nextRunId():number
	self.runCounter += 1
	return self.runCounter
end

local function toggleLock(player: Player, lock: boolean)
	if not player then
		return
	end
	local character = player.Character
	if not character then
		return
	end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end
	hrp.Anchored = lock
end

function CutsceneM:lockPlayer(player: Player)
	toggleLock(player, true)
end

function CutsceneM:unlockPlayer(player: Player)
	toggleLock(player, false)
end

function CutsceneM:load()
	local conn = Players.PlayerRemoving:Connect(function(player: Player)
		self.playerQueues[player.UserId] = nil
		local run = self.playerActive[player.UserId]
		if run then
			if run.isGlobal then
				for i, p in ipairs(run.players) do
					if p.UserId == player.UserId then
						table.remove(run.players, i)
						break
					end
				end
				self.playerActive[player.UserId] = nil
				self:unlockPlayer(player)
				if #run.players == 0 then
					self:endRun(run)
				end
			else
				self:endRun(run)
			end
		end
		self:unlockPlayer(player)
	end)
	table.insert(self.conns, conn)

	local conn2 = skip.OnServerEvent:Connect(function(player: Player)
		self:skipRequest(player)
	end)
	table.insert(self.conns, conn2)
end

function CutsceneM:unload()
	for _, conn in ipairs(self.conns) do
		if conn and conn.Connected then
			conn:Disconnect()
		end
	end
	self.conns = {}
	self:stopAll()
end

function CutsceneM:playMultiple(cutsceneId: number, players: {Player}?, onEnd:()->()?)
	if not cutsceneId then
		return
	end
	local cutsceneModule = IFSCutscenes[cutsceneId]
	if not cutsceneModule then
		if self.debugOn then
			warn("Cutscene id not found: " .. tostring(cutsceneId))
		end
		return
	end

	if cutsceneModule.isGlobal == true then
		players = Players:GetPlayers()
		local run = self:buildRun(cutsceneId, cutsceneModule, players, onEnd)
		if not run then
			return
		end
		table.insert(self.globalQueue, run)
	else
		if not players or #players == 0 then
			if self.debugOn then
				warn("No players specified for CutsceneM: " .. tostring(cutsceneId))
			end
			return
		end
		local validPlayers = {}
		for _, player in ipairs(players) do
			if player and player.Parent == Players then
				table.insert(validPlayers, player)
			end
		end
		local run = self:buildRun(cutsceneId, cutsceneModule, validPlayers, onEnd)
		if not run then
			return
		end
	end
	self:processQueues()
end

function CutsceneM:playSingle(cutsceneId: number, player: Player, onEnd: () -> ()?)
	if not cutsceneId or not player then
		return
	end
	local cutsceneModule = IFSCutscenes[cutsceneId]
	if not cutsceneModule then
		if self.debugOn then
			warn("Cutscene id not found: " .. tostring(cutsceneId))
		end
		return
	end
	local run = self:buildRun(cutsceneId, cutsceneModule, {player}, onEnd)
	if not run then
		return
	end
	self:processQueues()
end

function CutsceneM:buildRun(cutsceneId: number, cutsceneModule: CutsceneModule,players: {Player}, onEnd: () -> ()):CutsceneRun?
	local duration = cutsceneModule.duration
	if not duration or duration <= 0 then
		return nil
	end
	local isGlobal = cutsceneModule.isGlobal or false
	local isSkippable = cutsceneModule.isSkippable or false
	local run : CutsceneRun = {
		cutsceneId = cutsceneId,
		cutsceneModule = cutsceneModule,
		runId = self:nextRunId(),
		players = players,
		duration = duration,
		isGlobal = isGlobal,
		isSkippable = isSkippable,
		ended = false,
		onEnd = onEnd,
		threads = nil,
		skipVotes = {}	
	} 
	for _, player in ipairs(players) do
		if not self.playerQueues[player.UserId] then
			self.playerQueues[player.UserId] = {}
		end
		table.insert(self.playerQueues[player.UserId], run)
	end
	return run
end

function CutsceneM:processQueues()
	if self.activeGlobal then
		return
	end
	if #self.globalQueue > 0 then
		if not (next(self.playerActive) ~= nil) then
			local run = table.remove(self.globalQueue, 1)
			self:startRun(run)
		end
		return
	end
	for player, queue in pairs(self.playerQueues) do
		if not self.playerActive[player.UserId] and #queue > 0 then
			local run = table.remove(queue, 1)
			self:startRun(run)
		end
		if #queue == 0 then
			self.playerQueues[player.UserId] = nil
		end
	end
end

function CutsceneM:startRun(run:CutsceneRun)
	if run.ended then
		return
	end
	local cutscene = run.cutsceneModule
	if not cutscene then
		run.ended = true
		return
	end

	if run.isGlobal then
		self.activeGlobal = run
	end
	local runId = run.runId
	local payload = {
		runId = runId,
		cutsceneId = run.cutsceneId,
		serverTime = os.clock(),
	}

	for _, player in ipairs(run.players) do
		self:lockPlayer(player, run.runId)
		self.playerActive[player.UserId] = run
		start:FireClient(player, payload)
	end

	local playThread = task.spawn(function()
		cutscene:play(run.players, run.onEnd)
	end)

	local stopThread = task.delay(run.duration, 
		function()
			if run.runId == runId and not run.ended then
				self:endRun(run)
			end
		end)
	run.threads = {playThread, stopThread}
end

function CutsceneM:endRun(run:CutsceneRun)
	if run.ended then
		return
	end
	run.ended = true
	local cutsceneModule = run.cutsceneModule
	if cutsceneModule.stop then
		pcall(function()
			return cutsceneModule.stop()
		end)
	end

	if run.threads then
		for _, thread in ipairs(run.threads) do
			if coroutine.status(thread) ~= "dead" then
				task.cancel(thread)
			end
		end
		run.threads = {}
	end
	
	for _, player in ipairs(run.players) do
		self:unlockPlayer(player, run.runId)
		self.playerActive[player.UserId] = nil
		stop:FireClient(player, {runId = run.runId, cutsceneId = run.cutsceneId})
	end
	if run.isGlobal and self.activeGlobal.runId == run.runId then
		self.activeGlobal = nil
	end
	
	if not self.suppressQueue then
		self:processQueues()
	end
end

function CutsceneM:skipRequest(player:Player)
	if not player or not player:IsA("Player")then
		return
	end
	local run = self.playerActive[player.UserId]
	if not run then return end
	if not run.isSkippable then
		if self.debugOn then
			warn("Cutscene is not skippable: " .. tostring(run.cutsceneId))
		end
		return
	end
	if run.isGlobal then
		self:globalSkip(run, player)
	else
		self:endRun(run)
	end
end

function CutsceneM:globalSkip(run:CutsceneRun, requester:Player)
	if run.ended then return end
	if run.runId ~= self.activeGlobal.runId then return end
	if next(run.skipVotes) == nil then
		for _, player in ipairs(run.players) do
			run.skipVotes[player.UserId] = false
		end
	end
	run.skipVotes[requester.UserId] = true
	local votes = 0
	for _, voted in pairs(run.skipVotes) do
		if voted then
			votes += 1
		end
	end
	skip:FireAllClients({runId = run.runId, cutsceneId = run.cutsceneId, votes = votes, totalPlayers = #run.players})
	if votes >= #run.players then
		self:endRun(run)
	end
end

-- to stop a non global cutscene for a player
function CutsceneM:stopPlayer(player: Player)
	if not player or not player:IsA("Player")then
		return
	end
	local run = self.playerActive[player.UserId]
	if run and not run.isGlobal then
		self:endRun(run)
	end
end

-- to stop a global cutscene for all players, only to be called after voting
function CutsceneM:stopGlobal()
	local run = self.activeGlobal
	if run then
		self:endRun(run)
	end
end

function CutsceneM:stopAll()
	self.suppressQueue = true
	if self.activeGlobal then
		self:endRun(self.activeGlobal)
	end
	for _, run in pairs(self.playerActive) do
		if run and not run.ended then
			self:endRun(run)
		end
	end
	local lockedPlayers = {}
	for player, _ in pairs(self.playerLocks) do
		table.insert(lockedPlayers, player)
	end
	for _, player in ipairs(lockedPlayers) do
		self:unlockPlayer(player)
	end
	self.playerQueues = {}
	self.playerActive = {}
	self.globalQueue = {}
	self.suppressQueue = false
end

return CutsceneM