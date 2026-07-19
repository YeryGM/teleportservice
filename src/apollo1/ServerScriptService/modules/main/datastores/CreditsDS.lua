--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local DataTypes = require(ServerScriptService.modules.general.data.types.TDataStores)
local DatastoreModule = require(script.Parent.DataStore)

type CreditsData = DataTypes.CreditsData

local CreditsDS = {
    data = {
        DefaultData = {
            Balance = 0,
            LastUpdated = 0,
            TransactionHistory = {}
        },
    },
    maxTransactions = 10,
    playerMap = {},
    debugOn = false
}
CreditsDS.__index = CreditsDS
setmetatable(CreditsDS, { __index = DatastoreModule })

function CreditsDS.new(rootStore, player: Player)
    local self = setmetatable(rootStore:CreateNestedStore("cred", CreditsDS.data), CreditsDS)
    self.player = player
    self.debugOn = CreditsDS.debugOn
    CreditsDS.playerMap[player.UserId] = self
    return self
end

function CreditsDS:save(): boolean
    return self:SaveAllCached()
end

function CreditsDS:addCredits(amount: number, reason: string?): (boolean, string?)
    if type(amount) ~= "number" or amount <= 0 then
        return false, "Invalid amount"
    end
    local normalizedReason = if type(reason) == "string" then reason else "Unknown"
    return self:UpdateCachedData(self.player.UserId, function(data: CreditsData): (CreditsData?, string?)
		data.Balance = data.Balance + amount
		data.LastUpdated = os.time()
		table.insert(data.TransactionHistory, 1, {
			Amount = amount,
            Reason = normalizedReason,
			Timestamp = os.time()
		})
		if #data.TransactionHistory > self.maxTransactions then
			table.remove(data.TransactionHistory, #data.TransactionHistory)
		end
        return data, nil
	end)
end

function CreditsDS:useCredits(amount: number, reason: string?): (boolean, string?)
    if type(amount) ~= "number" or amount <= 0 then
        return false, "Invalid amount"
    end
    local normalizedReason = if type(reason) == "string" then reason else "Unknown"
    return self:UpdateCachedData(self.player.UserId, function(data: CreditsData): (CreditsData?, string?)
        if data.Balance < amount then
            return nil, "Insufficient credits"
        end
        data.Balance = data.Balance - amount
        data.LastUpdated = os.time()
        table.insert(data.TransactionHistory, 1, {
            Amount = -amount,
            Reason = normalizedReason,
            Timestamp = os.time()
        })
        if #data.TransactionHistory > self.maxTransactions then
            table.remove(data.TransactionHistory, #data.TransactionHistory)
        end
        return data, nil
    end)
end

function CreditsDS:getBalance(): number
    local cachedData = self:GetCachedData(self.player.UserId) :: CreditsData?
    local data = cachedData or (self:LoadData(self.player.UserId) :: CreditsData)
    return data.Balance or 0
end

function CreditsDS:unload()
	CreditsDS.playerMap[self.player.UserId] = nil
end

return CreditsDS