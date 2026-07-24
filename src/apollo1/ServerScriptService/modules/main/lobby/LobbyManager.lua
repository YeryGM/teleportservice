local debugOn = true

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.modules.general.data.Enums)
local Chapters = require(ReplicatedStorage.modules.general.data.Chapters)
local StateMachine = require(ReplicatedStorage.modules.general.utils.StateMachine)
local SessionManager = require(script.Parent.SessionManager)
local MemoryStoreManager = require(script.Parent.MemoryStoreManager)

local lobbyEvents = ReplicatedStorage:WaitForChild("events"):WaitForChild("general"):WaitForChild("lobby")
local OpenLobbyUI: RemoteEvent = lobbyEvents:WaitForChild("OpenLobbyUI")
local CloseLobbyUI: RemoteEvent = lobbyEvents:WaitForChild("CloseLobbyUI")
local SubmitLobbyConfig: RemoteEvent = lobbyEvents:WaitForChild("SubmitLobbyConfig")
local CancelLobby: RemoteEvent = lobbyEvents:WaitForChild("CancelLobby")

local TAG = "TeleportLobby"

local LobbyManager = {
	pads = {},
	connections = {},
}

function LobbyManager:load()
	if debugOn then
		print("[LobbyManager] Inicializando...")
	end

	local chapterCount = 0
	for _ in pairs(Chapters) do
		chapterCount += 1
	end
	if debugOn then
		print("[LobbyManager] Capitulos disponibles: " .. tostring(chapterCount))
	end

	local taggedParts = CollectionService:GetTagged(TAG)
	if debugOn then
		print("[LobbyManager] Pads encontrados: " .. tostring(#taggedParts))
	end

	for _, part in ipairs(taggedParts) do
		if part:IsA("BasePart") then
			self:_setupPad(part)
		end
	end

	local submitConn = SubmitLobbyConfig.OnServerEvent:Connect(function(player, data)
		self:_onSubmitConfig(player, data)
	end)
	local cancelConn = CancelLobby.OnServerEvent:Connect(function(player)
		self:_onCancelLobby(player)
	end)

	table.insert(self.connections, submitConn)
	table.insert(self.connections, cancelConn)

	if debugOn then
		print("[LobbyManager] Senales conectadas (SubmitLobbyConfig, CancelLobby)")
		print("[LobbyManager] Inicializacion completa")
	end
end

function LobbyManager:unload()
	if debugOn then
		print("[LobbyManager] Descargando...")
	end

	for _, pad in pairs(self.pads) do
		for _, conn in ipairs(pad.conns) do
			if conn and conn.Connected then
				conn:Disconnect()
			end
		end
		if pad.checkThread then
			task.cancel(pad.checkThread)
		end
		pad.sm:Cleanup()
	end
	self.pads = {}

	for _, conn in ipairs(self.connections) do
		if conn and conn.Connected then
			conn:Disconnect()
		end
	end
	self.connections = {}

	if debugOn then
		print("[LobbyManager] Descarga completa")
	end
end

function LobbyManager:_setupPad(part: BasePart)
	local pad = {
		part = part,
		sm = StateMachine.new(),
		players = {},
		host = nil,
		sizeTarget = 3,
		difficulty = Enums.diff.Normal,
		chapter = nil,
		conns = {},
		checkThread = nil,
	}

	self:_registerStates(pad)
	self.pads[part] = pad

	if debugOn then
		print("[LobbyManager] Lobby Pad inicializado para " .. part.Name)
	end

	pad.sm:SetState(Enums.lobby.state.Libre)
end

function LobbyManager:_buildChapterList()
	local list = {}
	for key, chapter in pairs(Chapters) do
		table.insert(list, { key = key, displayName = chapter.DisplayName })
	end
	return list
end

function LobbyManager:_registerStates(pad)
	local sm = pad.sm

	sm:SetStateChangedCallback(function(prevState, newState)
		if debugOn then
			print("[LobbyManager] " .. pad.part.Name .. ": " .. tostring(prevState) .. " -> " .. tostring(newState))
		end
	end)

	sm:AddState(Enums.lobby.state.Libre,
		function()
			local conn = pad.part.Touched:Connect(function(hit)
				self:_onTouched(pad, hit)
			end)
			table.insert(pad.conns, conn)
		end,
		function()
			self:_disconnectPadEvents(pad)
		end
	)

	sm:AddState(Enums.lobby.state.Configurando,
		function() end,
		function() end
	)

	sm:AddState(Enums.lobby.state.Esperando,
		function()
			local touchConn = pad.part.Touched:Connect(function(hit)
				self:_onTouchedWaiting(pad, hit)
			end)
			local endedConn = pad.part.TouchEnded:Connect(function(hit)
				self:_onTouchEndedWaiting(pad, hit)
			end)
			table.insert(pad.conns, touchConn)
			table.insert(pad.conns, endedConn)

			pad.checkThread = task.spawn(function()
				self:_checkTeleportLoop(pad)
			end)
		end,
		function()
			self:_disconnectPadEvents(pad)
			if pad.checkThread then
				task.cancel(pad.checkThread)
				pad.checkThread = nil
			end
		end
	)

	sm:AddState(Enums.lobby.state.Teleportando,
		function()
			task.spawn(function()
				self:_executeTeleport(pad)
			end)
		end,
		function() end
	)
end

function LobbyManager:_disconnectPadEvents(pad)
	for i = #pad.conns, 1, -1 do
		local conn = pad.conns[i]
		if conn and conn.Connected then
			conn:Disconnect()
		end
		table.remove(pad.conns, i)
	end
end

function LobbyManager:_onTouched(pad, hit)
	if pad.sm:GetState() ~= Enums.lobby.state.Libre then
		return
	end

	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then
		return
	end

	if debugOn then
		print("[LobbyManager] Jugador " .. player.Name .. " intentando crear partida")
	end

	pad.host = player
	pad.sm:SetState(Enums.lobby.state.Configurando)

	local chapterList = self:_buildChapterList()
	OpenLobbyUI:FireClient(player, { chapters = chapterList })
end

function LobbyManager:_onTouchedWaiting(pad, hit)
	if pad.sm:GetState() ~= Enums.lobby.state.Esperando then
		return
	end

	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then
		return
	end

	if pad.players[player] then
		return
	end

	pad.players[player] = true
	local count = 0
	for _ in pairs(pad.players) do
		count += 1
	end

	if debugOn then
		print("[LobbyManager] " .. player.Name .. " se unio a " .. pad.part.Name .. " (" .. count .. "/" .. pad.sizeTarget .. ")")
	end
end

function LobbyManager:_onTouchEndedWaiting(pad, hit)
	if pad.sm:GetState() ~= Enums.lobby.state.Esperando then
		return
	end

	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then
		return
	end

	if not pad.players[player] then
		return
	end

	pad.players[player] = nil
	local count = 0
	for _ in pairs(pad.players) do
		count += 1
	end

	if debugOn then
		print("[LobbyManager] " .. player.Name .. " salio de " .. pad.part.Name .. " (" .. count .. "/" .. pad.sizeTarget .. ")")
	end
end

function LobbyManager:_onSubmitConfig(player, data)
	if not data or type(data) ~= "table" then
		warn("[LobbyManager] SubmitLobbyConfig: payload invalido")
		return
	end

	local pad = self:_getPadByPlayer(player)
	if not pad then
		if debugOn then
			print("[LobbyManager] SubmitLobbyConfig: " .. player.Name .. " no esta en ningun pad")
		end
		return
	end

	if pad.host ~= player then
		if debugOn then
			print("[LobbyManager] SubmitLobbyConfig: " .. player.Name .. " no es el host")
		end
		return
	end

	if pad.sm:GetState() ~= Enums.lobby.state.Configurando then
		if debugOn then
			print("[LobbyManager] SubmitLobbyConfig: pad no esta en Configurando")
		end
		return
	end

	local chapterKey = data.chapter
	if type(chapterKey) ~= "string" or not Chapters[chapterKey] then
		warn("[LobbyManager] SubmitLobbyConfig: capitulo invalido (" .. tostring(chapterKey) .. ")")
		return
	end

	local difficulty = data.difficulty
	if type(difficulty) ~= "number" then
		warn("[LobbyManager] SubmitLobbyConfig: difficulty invalido")
		return
	end

	local partySize = data.partySize
	if type(partySize) ~= "number" or partySize < 1 or partySize > 5 then
		warn("[LobbyManager] SubmitLobbyConfig: partySize invalido (" .. tostring(partySize) .. ")")
		return
	end

	pad.chapter = chapterKey
	pad.difficulty = difficulty
	pad.sizeTarget = partySize
	pad.players[player] = true

	if debugOn then
		print("[LobbyManager] Configuracion recibida -> chapter=" .. chapterKey
			.. ", difficulty=" .. tostring(difficulty)
			.. ", partySize=" .. tostring(partySize))
		print("[LobbyManager] " .. pad.part.Name .. ": Configurando -> Esperando")
	end

	pad.sm:SetState(Enums.lobby.state.Esperando)
end

function LobbyManager:_onCancelLobby(player)
	local pad = self:_getPadByPlayer(player)
	if not pad then
		return
	end

	if pad.host ~= player then
		if debugOn then
			print("[LobbyManager] CancelLobby: " .. player.Name .. " no es el host")
		end
		return
	end

	local currentState = pad.sm:GetState()
	if currentState ~= Enums.lobby.state.Configurando and currentState ~= Enums.lobby.state.Esperando then
		return
	end

	if debugOn then
		print("[LobbyManager] " .. pad.part.Name .. ": CancelLobby -> reset a Libre")
	end

	self:_resetPad(pad)
	CloseLobbyUI:FireClient(player)
	pad.sm:SetState(Enums.lobby.state.Libre)
end

function LobbyManager:_checkTeleportLoop(pad)
	while pad.sm:GetState() == Enums.lobby.state.Esperando do
		local count = 0
		for _ in pairs(pad.players) do
			count += 1
		end

		if count >= pad.sizeTarget then
			if debugOn then
				print("[LobbyManager] " .. pad.part.Name .. ": Jugadores completos (" .. count .. "/" .. pad.sizeTarget .. ") -> Teleportando")
			end
			pad.sm:SetState(Enums.lobby.state.Teleportando)
			return
		end

		task.wait(0.5)
	end
end

function LobbyManager:_executeTeleport(pad)
	local playerList = {}
	for player in pairs(pad.players) do
		if player and player.Parent then
			table.insert(playerList, player)
		end
	end

	if #playerList == 0 then
		if debugOn then
			print("[LobbyManager] " .. pad.part.Name .. ": Sin jugadores, abortando teleport")
		end
		self:_resetPad(pad)
		pad.sm:SetState(Enums.lobby.state.Libre)
		return
	end

	local chapterConfig = Chapters[pad.chapter]
	if not chapterConfig then
		warn("[LobbyManager] " .. pad.part.Name .. ": Capitulo no encontrado (" .. tostring(pad.chapter) .. ")")
		self:_resetPad(pad)
		pad.sm:SetState(Enums.lobby.state.Libre)
		return
	end

	local placeId = chapterConfig.Places[1]
	if not placeId or placeId == 0 then
		warn("[LobbyManager] " .. pad.part.Name .. ": PlaceId no configurado para " .. pad.chapter)
		self:_resetPad(pad)
		pad.sm:SetState(Enums.lobby.state.Libre)
		return
	end

	if debugOn then
		print("[LobbyManager] Teletransportando grupo al Capitulo " .. pad.chapter)
		print("[LobbyManager] PlaceId: " .. tostring(placeId) .. " | Jugadores: " .. tostring(#playerList))
	end

	local sessionId = HttpService:GenerateGUID(false)
	if debugOn then
		print("[LobbyManager] SessionID: " .. sessionId)
	end

	local playerNames = {}
	for _, player in ipairs(playerList) do
		table.insert(playerNames, player.Name)
	end

	local teleportData = {
		session = sessionId,
		chapter = pad.chapter,
		difficulty = pad.difficulty,
		size = pad.sizeTarget,
	}

	local saved = MemoryStoreManager.SaveSession(sessionId, {
		chapter = pad.chapter,
		difficulty = pad.difficulty,
		size = pad.sizeTarget,
		players = playerNames,
	})

	if not saved then
		warn("[LobbyManager] " .. pad.part.Name .. ": Session save failed, aborting teleport")
		self:_resetPad(pad)
		pad.sm:SetState(Enums.lobby.state.Libre)
		return
	end

	local result = SessionManager.TeleportGroup(playerList, placeId, teleportData)

	if not result.success then
		warn("[LobbyManager] Teleport failed: " .. tostring(result.error))
		if debugOn then
			print("[LobbyManager] Reseteando " .. pad.part.Name .. " a Libre")
		end
		self:_resetPad(pad)
		pad.sm:SetState(Enums.lobby.state.Libre)
		return
	end

	if debugOn then
		print("[LobbyManager] Teleport ejecutado exitosamente")
	end

	task.wait(2)
	self:_resetPad(pad)
	pad.sm:SetState(Enums.lobby.state.Libre)
end

function LobbyManager:_resetPad(pad)
	for player in pairs(pad.players) do
		pad.players[player] = nil
	end
	pad.host = nil
	pad.chapter = nil
	pad.sizeTarget = 1
	pad.difficulty = Enums.diff.Normal
end

function LobbyManager:_getPadByPlayer(player)
	for _, pad in pairs(self.pads) do
		if pad.players[player] or pad.host == player then
			return pad
		end
	end
	return nil
end

return LobbyManager
