local Players = game:GetService("Players")

local PlayerDataStores = require(script.Parent.PlayerDataStores)

local DataManager = {
	playerMap = {},
	conns = {},
	debugOn = true,
	loaded = false,
}

local function onPlayerAdded(player: Player)
	if DataManager.playerMap[player.UserId] then
		warn("Player data already exists for user:", player.UserId)
		return
	end
	DataManager.playerMap[player.UserId] = PlayerDataStores.new(player)
end

local function onPlayerRemoving(player: Player)
	local playerData = DataManager.playerMap[player.UserId]
	if playerData then
		playerData:unload()
		DataManager.playerMap[player.UserId] = nil
	end
end

local function onPlayerSaved(player: Player)
	local playerData = DataManager.playerMap[player.UserId]
	if playerData then
		playerData:save()
	end
end

function DataManager:load()
	if self.loaded then
		return
	end
	self.loaded = true
	self.conns.playerAdded = Players.PlayerAdded:Connect(onPlayerAdded)
	self.conns.playerRemoving = Players.PlayerRemoving:Connect(onPlayerRemoving)

	game:BindToClose(function()
		self:save()
	end)

	for _, player in pairs(Players:GetPlayers()) do
		self.playerMap[player.UserId] = PlayerDataStores.new(player)
	end
end

function DataManager:unload()
	for _, player in pairs(Players:GetPlayers()) do
		onPlayerRemoving(player)
	end
	for _, conn in pairs(self.conns) do
		if conn and conn.Connected then
			conn:Disconnect()
		end
	end
end

function DataManager:save()
	for _, player in pairs(Players:GetPlayers()) do
		onPlayerSaved(player)
	end
end

function DataManager:savePlayerData(player: Player)
	onPlayerSaved(player)
end

function DataManager:getPlayerData(player: Player)
	return self.playerMap[player.UserId]
end

return DataManager