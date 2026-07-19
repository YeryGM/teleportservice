--!strict
local DatastoreModule = require(script.Parent.DataStore)
local ServerScriptService = game:GetService("ServerScriptService")
local dataFolder = ServerScriptService.modules.general.data
local DataTypes = require(dataFolder.types.TDataStores)
local Enums = require(dataFolder.enums.EPurchases)

type PurchaseData = DataTypes.PurchaseData
type PurchaseEntry = DataTypes.PurchaseEntry
type PurchaseInput = DataTypes.PurchaseInput
type FailedPurchaseEntry = DataTypes.FailedPurchaseEntry
type FailedPurchaseInput = DataTypes.FailedPurchaseInput

local PurchaseDS = {
	defaultData = {
		UseScopes = false,
		EnableLogging = false,
		AutoSave = true,
		SaveInterval = 120,
		DefaultData = {
			Purchases = {},
			FailedPurchases = {},
			TotalPurchases = 0,
			TotalSpent = 0,
			LastPurchaseTime = 0,
			FirstPurchaseTime = 0,
			Statistics = {
				ByProductId = {},
				ByType = {},
				ByCategory = {}
			}
		}
	},
	maxHistoryEntries = 100,
	maxFailedEntries = 50,
	trackRefunds = true,
	trackFailures = true,
	playerMap = {},
	debugOn = false
}

PurchaseDS.__index = PurchaseDS
setmetatable(PurchaseDS, {__index = DatastoreModule})

function PurchaseDS.new(player: Player)
	local self = setmetatable(DatastoreModule.new("hist", PurchaseDS.defaultData, nil, nil), PurchaseDS)
	self.player = player
	self.debugOn = PurchaseDS.debugOn
	PurchaseDS.playerMap[player.UserId] = self
	return self
end

function PurchaseDS:save(): boolean
	return self:SaveAllCached()
end

local function isPositiveNumber(value: any): boolean
	return type(value) == "number" and value > 0
end

local function normalizeCategory(category: any): string
	return if type(category) == "string" and category ~= "" then category else "Uncategorized"
end

local function normalizeString(value: any, fallback: string): string
	return if type(value) == "string" and value ~= "" then value else fallback
end

local function countPurchases(purchases: { [DataTypes.Id]: PurchaseEntry }): number
	local count = 0
	for _ in pairs(purchases) do
		count += 1
	end
	return count
end

local function removeOldestPurchase(purchases: { [DataTypes.Id]: PurchaseEntry })
	local oldestKey: DataTypes.Id? = nil
	local oldestTime = math.huge
	for key, purchase in pairs(purchases) do
		if type(purchase.Timestamp) == "number" and purchase.Timestamp < oldestTime then
			oldestTime = purchase.Timestamp
			oldestKey = key
		end
	end
	if oldestKey ~= nil then
		purchases[oldestKey] = nil
	end
end

function PurchaseDS:RecordPurchase(purchaseData: PurchaseInput): (boolean, string?)
	if type(purchaseData) ~= "table" then
		return false, "Invalid purchase data"
	end
	if not isPositiveNumber(purchaseData.ProductId) or type(purchaseData.Type) ~= "string" 
		or type(purchaseData.Price) ~= "number" or type(purchaseData.Currency) ~= "string" then
		return false, "Invalid purchase data"
	end
	local receiptId = purchaseData.ReceiptId or purchaseData.PurchaseId
	if receiptId == nil then
		return false, "Missing receipt id"
	end

	return self:UpdateData(self.player.UserId, function(data: PurchaseData)
		-- Create purchase entry
		local purchase: PurchaseEntry = {
			Id = receiptId,
			ProductId = purchaseData.ProductId,
			ProductName = normalizeString(purchaseData.ProductName, "Unknown"),
			Type = purchaseData.Type, -- "DevProduct", "GamePass", "Bundle"
			Category = normalizeCategory(purchaseData.Category), 
			Price = purchaseData.Price,
			Currency = normalizeString(purchaseData.Currency, Enums.Currencies.Credits),
			Status = normalizeString(purchaseData.Status, Enums.States.Completed),
			Timestamp = os.time(),
			PurchaseId = purchaseData.PurchaseId,
			ReceiptId = purchaseData.ReceiptId,
			Metadata = purchaseData.Metadata or {}
		}
		-- Initialize Purchases table if needed
		if not data.Purchases then
			data.Purchases = {}
		end
		data.Purchases[purchase.Id] = purchase 
		-- Limit history size
		if countPurchases(data.Purchases) > self.maxHistoryEntries then
			removeOldestPurchase(data.Purchases)
		end
		-- Update statistics
		data.TotalPurchases = (data.TotalPurchases or 0) + 1
		data.TotalSpent = (data.TotalSpent or 0) + purchase.Price
		data.LastPurchaseTime = purchase.Timestamp
		if not data.FirstPurchaseTime then
			data.FirstPurchaseTime = purchase.Timestamp
		end
		-- Update statistics by product
		if not data.Statistics then
			data.Statistics = { ByProductId = {}, ByType = {}, ByCategory = {} }
		end
		-- By Product ID
		if not data.Statistics.ByProductId[purchase.ProductId] then
			data.Statistics.ByProductId[purchase.ProductId] = {
				Count = 0,
				TotalSpent = 0,
				LastPurchase = nil
			}
		end
		
		local productStats = data.Statistics.ByProductId[purchase.ProductId]
		productStats.Count = productStats.Count + 1
		productStats.TotalSpent = productStats.TotalSpent + purchase.Price
		productStats.LastPurchase = purchase.Timestamp
		-- By Type
		if not data.Statistics.ByType[purchase.Type] then
			data.Statistics.ByType[purchase.Type] = {
				Count = 0,
				TotalSpent = 0
			}
		end
		local typeStats = data.Statistics.ByType[purchase.Type]
		typeStats.Count = typeStats.Count + 1
		typeStats.TotalSpent = typeStats.TotalSpent + purchase.Price
		-- By Category 
		if not data.Statistics.ByCategory[purchase.Category] then
			data.Statistics.ByCategory[purchase.Category] = {
				Count = 0,
				TotalSpent = 0
			}
		end
		local categoryStats = data.Statistics.ByCategory[purchase.Category]
		categoryStats.Count = categoryStats.Count + 1
		categoryStats.TotalSpent = categoryStats.TotalSpent + purchase.Price
		return data, nil
	end)
end

-- Record a failed purchase
function PurchaseDS:RecordFailedPurchase(purchaseData: FailedPurchaseInput, reason: string?): (boolean, string?)
	if not self.trackFailures then
		return true 
	end
	if type(purchaseData) ~= "table" or not isPositiveNumber(purchaseData.ProductId) or type(purchaseData.Type) ~= "string" then
		return false, "Invalid purchase data"
	end
	local normalizedReason = normalizeString(reason, "Unknown")
	return self:UpdateData(self.player.UserId, function(data: PurchaseData)
		local failedPurchase: FailedPurchaseEntry = {
			ProductId = purchaseData.ProductId,
			ProductName = purchaseData.ProductName,
			Type = purchaseData.Type,
			Category = normalizeCategory(purchaseData.Category),
			Reason = normalizedReason,
			Timestamp = os.time(),
			Metadata = purchaseData.Metadata or {}
		}
		if not data.FailedPurchases then
			data.FailedPurchases = {}
		end
		table.insert(data.FailedPurchases, 1, failedPurchase)
		-- Limit failed purchase history
		while #data.FailedPurchases > self.maxFailedEntries do
			table.remove(data.FailedPurchases, #data.FailedPurchases)
		end
		
		return data, nil
	end)
end

-- Record a refund
function PurchaseDS:RecordRefund(receiptId: DataTypes.Id, reason: string?): (boolean, string?)
	if not self.trackRefunds then
		return true
	end
	if receiptId == nil then
		return false, "Missing receipt id"
	end
	local normalizedReason = normalizeString(reason, "Unknown")
	return self:UpdateData(self.player.UserId, function(data: PurchaseData)
		-- Find the original purchase
		local originalPurchase: PurchaseEntry? = nil
		for _, purchase in pairs(data.Purchases or {}) do
			if purchase.ReceiptId == receiptId then
				originalPurchase = purchase
				purchase.Status = Enums.States.Refunded
				purchase.RefundTime = os.time()
				purchase.RefundReason = normalizedReason
				break
			end
		end
		if originalPurchase then
			-- Update statistics
			data.TotalSpent = (data.TotalSpent or 0) - originalPurchase.Price
			-- Update product stats
			if data.Statistics and data.Statistics.ByProductId[originalPurchase.ProductId] then
				local productStats = data.Statistics.ByProductId[originalPurchase.ProductId]
				productStats.TotalSpent = productStats.TotalSpent - originalPurchase.Price
			end
			-- Update type stats
			if data.Statistics and data.Statistics.ByType[originalPurchase.Type] then
				local typeStats = data.Statistics.ByType[originalPurchase.Type]
				typeStats.TotalSpent = typeStats.TotalSpent - originalPurchase.Price
			end
			-- Update category stats
			if data.Statistics and data.Statistics.ByCategory[originalPurchase.Category] then
				local categoryStats = data.Statistics.ByCategory[originalPurchase.Category]
				categoryStats.TotalSpent = categoryStats.TotalSpent - originalPurchase.Price
			end
		end
		return data, nil
	end)
end

function PurchaseDS:GetAllPurchases(): { [DataTypes.Id]: PurchaseEntry }
	local data = self:LoadData(self.player.UserId) :: PurchaseData
	return data.Purchases or {}
end

function PurchaseDS:GetPurchaseById(purchaseId: DataTypes.Id): PurchaseEntry?
	local data = self:LoadData(self.player.UserId) :: PurchaseData
	local purchase = (data.Purchases or {})[purchaseId]
	if purchase then
		return purchase
	end
	if self.debugOn then
		warn("PurchaseDS:GetPurchaseById - Purchase ID not found:", purchaseId)
	end
	return nil
end
function PurchaseDS:GetPurchasesByProduct(productId: number): { PurchaseEntry }
	local data = self:LoadData(self.player.UserId) :: PurchaseData
	local purchases = {}
	
	for _, purchase in pairs(data.Purchases or {}) do
		if purchase.ProductId == productId then
			table.insert(purchases, purchase)
		end
	end
	
	return purchases
end

-- Get purchases by type
function PurchaseDS:GetPurchasesByType(purchaseType: string): { PurchaseEntry }
	local data = self:LoadData(self.player.UserId) :: PurchaseData
	local purchases = {}
	for _, purchase in pairs(data.Purchases or {}) do
		if purchase.Type == purchaseType then
			table.insert(purchases, purchase)
		end
	end
	return purchases
end

function PurchaseDS:GetPurchasesByCategory(category: string): { PurchaseEntry }
	local data = self:LoadData(self.player.UserId) :: PurchaseData
	local purchases = {}
	
	for _, purchase in pairs(data.Purchases or {}) do
		if purchase.Category == category then
			table.insert(purchases, purchase)
		end
	end
	
	return purchases
end

function PurchaseDS:HasPurchased(productId: number): boolean
	local data = self:LoadData(self.player.UserId) :: PurchaseData
	
	for _, purchase in pairs(data.Purchases or {}) do
		if purchase.ProductId == productId and purchase.Status == Enums.States.Completed then
			return true
		end
	end
	
	return false
end

-- Clear old purchases (for data management)
function PurchaseDS:ClearOldPurchases(olderThan: number): (boolean, string?)
	return self:UpdateData(self.player.UserId, function(data: PurchaseData)
		local currentTime = os.time()
		local newPurchases: { [DataTypes.Id]: PurchaseEntry } = {}
		
		for key, purchase in pairs(data.Purchases or {}) do
			if (currentTime - purchase.Timestamp) < olderThan then
				newPurchases[key] = purchase
			end
		end
		
		data.Purchases = newPurchases
		return data, nil
	end)
end

function PurchaseDS:unload()
	DatastoreModule.unload(self)
	PurchaseDS.playerMap[self.player.UserId] = nil
end

return PurchaseDS