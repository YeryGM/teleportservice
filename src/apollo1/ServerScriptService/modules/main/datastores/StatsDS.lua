--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local DataTypes = require(ServerScriptService.modules.general.data.types.TDataStores)
local DatastoreModule = require(script.Parent.DataStore)
type StatsData = DataTypes.StatsData

local StatsDS = {
	data = {
		DefaultData = {}
	},
	playerMap = {},
    debugOn = false
}
StatsDS.__index = StatsDS
setmetatable(StatsDS, { __index = DatastoreModule })

function StatsDS.new(rootStore, player:Player)
	local self = setmetatable(rootStore:CreateNestedStore("stat", StatsDS.data ), StatsDS)
    self.player = player
	self.debugOn = StatsDS.debugOn
	StatsDS.playerMap[player.UserId] = self
    return self
end

function StatsDS:save(): boolean
	return self:SaveAllCached()
end

function StatsDS:getStat(id: DataTypes.StatId): number?
	local data = self:LoadData(self.player.UserId) :: StatsData
	return data[id] or nil
end

function StatsDS:getAllStats(): StatsData
	return self:LoadData(self.player.UserId) :: StatsData
end

function StatsDS:incrementStat(id: DataTypes.StatId, value: number): (boolean, string?)
	if type(value) ~= "number" then
		return false, "Invalid stat value"
	end
	return self:UpdateCachedData(self.player.UserId, function(data: StatsData)
		data[id] = (data[id] or 0) + value
		return data, nil
	end)
end

function StatsDS:addStat(id: DataTypes.StatId, amount: number): (boolean, string?)
	if type(amount) ~= "number" then
		return false, "Invalid stat value"
	end
	return self:UpdateCachedData(self.player.UserId, function(data: StatsData)
		data[id] = (data[id] or 0) + amount
		return data, nil
	end)
end

function StatsDS:deleteStat(id: DataTypes.StatId): (boolean, string?)
	return self:UpdateCachedData(self.player.UserId, function(data: StatsData)
		data[id] = nil
		return data, nil
	end)
end

function StatsDS:updateStat(id: DataTypes.StatId, value: number): (boolean, string?)
	if type(value) ~= "number" then
		return false, "Invalid stat value"
	end
	return self:UpdateCachedData(self.player.UserId, function(data: StatsData)
		data[id] = value
		return data, nil
	end)
end

function StatsDS:unload()
	StatsDS.playerMap[self.player.UserId] = nil
end

return StatsDS