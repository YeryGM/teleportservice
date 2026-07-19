local ServerScriptService = game:GetService("ServerScriptService")

--categories
local categoriesFolder = script.Parent.categories
local Currency = require(categoriesFolder.Currency)
local Consumables = require(categoriesFolder.Consumables)
local Revive = require(categoriesFolder.Revive)
--processors
local paymentProcessorsFolder = script.Parent.payments
local GameProduct = require(paymentProcessorsFolder.GameProduct)
local DevProduct = require(paymentProcessorsFolder.DevProduct)
--types
local dataStoresFolder = script.Parent.Parent.datastores
local PurchaseDS = require(dataStoresFolder.PurchaseDS)

local dataFolder = ServerScriptService.modules.general.data
local DataTypes = require(dataFolder.types.TDataStores)
local types = require(dataFolder.enums.EPurchases)
local ProductList = require(dataFolder.info.IFSProducts)
type PurchaseInput = DataTypes.PurchaseInput

local modules = {
	categoriesProcessors = { 
		[types.Categories.Currency] = Currency,
		[types.Categories.Consumable] = Consumables,
		[types.Categories.Revive] = Revive,
	},
	paymentProcessors = {
		[types.Types.GameProduct] = GameProduct,
		[types.Types.DevProduct] = DevProduct,
	},
}

local Caller = {
	debugOn = true,
	retryConfig = {
		grant = { attempts = 10, delay = 0.5 },
		save = { attempts = 3, delay = 1 },
	},
}

local function retryWithPcall(label: string, attempts: number, delaySeconds: number, fn)
	local lastError = nil
	for attempt = 1, attempts do
		local ok, result, reason = pcall(fn)
		if ok and result then
			return true, result, nil
		end
		if not ok then
			lastError = tostring(result)
		else
			lastError = reason or lastError
		end
		if attempt < attempts then
			task.wait(delaySeconds)
		end
	end
	return false, nil, lastError or (label .. "_failed")
end

local function getProductInfo(id:number)
	local productData = ProductList[id]
	if not productData then
		if Caller.debugOn then
			warn("Unknown product ID:", id)
		end
		return false, nil
	end
	local paymentProcessor = modules.paymentProcessors[productData.Type]
	local categoryProcessor = modules.categoriesProcessors[productData.Category]
	if not paymentProcessor or not categoryProcessor then
		if Caller.debugOn then
			warn("No processor found for product type:", productData.Type, "or category:", productData.Category)
		end
		return false, nil
	end
	return true, productData, paymentProcessor, categoryProcessor
end

function Caller.load()
	--Callbacks
	for _category, processor in pairs(modules.paymentProcessors) do
		if processor.setCallbacks then
			processor.setCallbacks({
				onPurchase = Caller.grantItem, 
				onSavePurchase = Caller.saveItemPurchase,
				isPurchaseCompleted = Caller.isPurchaseCompleted,
			})
		end
	end
end
--PROCESS PAYMENT
function Caller.processItemPurchase(player: Player, id: number, data): (boolean, any, string?)
	local idOk, productData, paymentProcessor, categoryProcessor = getProductInfo(id)
	if not idOk then
		return false, nil
	end
	data = data or {}
	data.amount = data.amount or 1
	-- Validate purchase requirements
	local ok, canPurchase, reason = pcall(function()
		return categoryProcessor.validatePurchase(player, id, data, productData)
	end)
	if not ok or not canPurchase then
		if Caller.debugOn then
			warn("Player cannot purchase this item:", player.Name, "Reason:", (reason or "Unknown reason"))
		end
		return false, nil, reason
	end
	-- Process payment
	local ok1, purchaseSuccess, purchaseData = pcall(function()
		return paymentProcessor.purchaseItem(player, id, data, productData)
	end) 
	if not ok1 or not purchaseSuccess then
		if Caller.debugOn then
			warn(string.format("Error processing purchase for %s: %s", productData.Name, tostring(purchaseData)))
		end
		return false, nil, purchaseData
	end
	-- Granting the item is handled by the payment processor's purchaseItem function, 
	-- which should call Caller.grantItem internally. We just need to check if it succeeded and return the appropriate result.
	-- Record the purchase in the datastore is handled by the payment processor as well,
	--so we assume if purchaseSuccess is true, it was recorded successfully. If not, we log it and return failure.
	return true, purchaseData
end
--GRANT ITEM
function Caller.grantItem(player:Player, id:number, data:{amount: number}?)
	--for Dev products the amount is determined by the product info Metadata
	--for game products the amount is determined by the data passed in the purchaseItem call, 
	local productData = ProductList[id]
	if not productData then
		if Caller.debugOn then
			warn("Unknown product ID:", id)
		end
		return false, "unknown_product"
	end
	local categoryProcessor = modules.categoriesProcessors[productData.Category]
	if not categoryProcessor or not categoryProcessor.grantItem then
		if Caller.debugOn then
			warn("No grantItem handler for category:", productData.Category)
		end
		return false, "missing_category_handler"
	end
	local ok, _granted, reason = retryWithPcall("grant", Caller.retryConfig.grant.attempts, Caller.retryConfig.grant.delay, function()
		return categoryProcessor.grantItem(player, id, productData, data)
	end)
	if not ok then
		if Caller.debugOn then
			warn("Failed to grant item for product:", id, "Reason:", tostring(reason))
		end
		return false, reason
	end
	return true
end
--SAVE PURCHASE
function Caller.saveItemPurchase(player: Player, purchaseData: PurchaseInput, grantSuccess:boolean, reason: string?)
	if not player or not purchaseData then
		if Caller.debugOn then
			warn("Invalid parameters for saveItemPurchase. Player or purchaseData is nil.")
		end
		return false
	end
	local PurchaseDSInstance = PurchaseDS.playerMap[player.UserId]
	if not PurchaseDSInstance then
		if Caller.debugOn then
			warn("No PurchaseDS instance found for player:", player.Name)
		end
		return false
	end

	if grantSuccess then
		purchaseData.Status = types.States.Completed
		local ok, _saved, saveReason = retryWithPcall("save_purchase", Caller.retryConfig.save.attempts, Caller.retryConfig.save.delay, function()
			return PurchaseDSInstance:RecordPurchase(purchaseData)
		end)
		if ok then
			if Caller.debugOn then
				warn(string.format("Successfully saved purchase history for %s's purchase of %s ", 
					player.Name, tostring(purchaseData.ProductName)))
			end
			return true
		end
		if Caller.debugOn then
			warn("Failed to save purchase for", player.Name, "Reason:", tostring(saveReason))
		end
		return false, saveReason
	else
		purchaseData.Status = types.States.Failed
		local okFail, recorded, recordReason = pcall(function()
			return PurchaseDSInstance:RecordFailedPurchase(purchaseData, reason)
		end)
		if not okFail or not recorded then
			if Caller.debugOn then
				warn("Failed to record failed purchase for", player.Name, "Reason:", tostring(recordReason))
			end
		end
		if Caller.debugOn then
			warn(string.format("Failed to process purchase for %s: %s", player.Name, tostring(purchaseData.ProductId)))
		end
		return false, reason
	end
end
--PURCHASE EXISTS
function Caller.isPurchaseCompleted(player: Player, purchaseId: string)
	if not player or not purchaseId then
		if Caller.debugOn then
			warn("Player or purchaseId is nil.")
		end
		return false
	end
	local PurchaseDSInstance = PurchaseDS.playerMap[player.UserId]
	if not PurchaseDSInstance then
		if Caller.debugOn then
			warn("No PurchaseDS instance found for player:", player.Name)
		end
		return false
	end
	local existingPurchase = PurchaseDSInstance:GetPurchaseById(purchaseId)
	if existingPurchase and existingPurchase.Status == types.States.Completed then
		return true
	end
	return false
end
--GET ITEMS
function Caller.getItems(ids: {number})
	local items = {}
	for _, id in ipairs(ids) do
		local item = Caller.getItem(id)
		if item then
			items[id] = item
		elseif Caller.debugOn then
			warn("Unknown item ID in getItems:", id)
		end
	end
	return items
end

function Caller.getItem(itemId: number)
	local item = ProductList[itemId]
	if not item then
		return nil
	end
	return item
end

function Caller.getSafeItems(ids: {number})
	local items = {}
	for _, id in ipairs(ids) do
		local item = Caller.getSafeItem(id)
		if item then
			items[id] = item	
		else
			if Caller.debugOn then
				warn("Unknown item ID in getSafeItems:", id)
			end
		end
	end
	return items
end

function Caller.getSafeItem(itemId: number)
	local item = ProductList[itemId]
	if not item then
		return nil
	end
	return {
		Name = item.Name,
		Type = item.Type,
		Category = item.Category,
		Price = item.Price,
		ImageId = item.ImageId,
		Description = item.Description,
		AvailableAmount = item.MaxPurchasesPerPlayer
	}
end

function Caller.isValidItem(itemId: number)
	return ProductList[itemId] ~= nil
end

Caller.load()

return Caller