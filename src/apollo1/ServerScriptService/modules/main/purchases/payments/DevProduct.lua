local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ProductList = require(ServerScriptService.modules.general.data.info.IFSProducts)
local types = require(ServerScriptService.modules.general.data.enums.EPurchases)

local DevProduct = {
	maxRetries = 5,
	productInfoCache = {},
	productInfoCacheOrder = {},
	productInfoCacheMax = 100,
	failedReceiptCache = {},
	failedReceiptOrder = {},
	failedReceiptCacheMax = 200,
	debugOn = true,
	callbacks = {
		onPurchase = nil,
		onSavePurchase = nil,
		isPurchaseCompleted = nil,
	},
}

local function cacheProductInfo(productId: number, productInfo)
	if not DevProduct.productInfoCache[productId] then
		table.insert(DevProduct.productInfoCacheOrder, productId)
	end
	DevProduct.productInfoCache[productId] = productInfo
	if #DevProduct.productInfoCacheOrder > DevProduct.productInfoCacheMax then
		local oldestId = table.remove(DevProduct.productInfoCacheOrder, 1)
		DevProduct.productInfoCache[oldestId] = nil
	end
end

local function rememberFailedReceipt(purchaseId: string): boolean
	if DevProduct.failedReceiptCache[purchaseId] then
		return false
	end
	DevProduct.failedReceiptCache[purchaseId] = true
	table.insert(DevProduct.failedReceiptOrder, purchaseId)
	if #DevProduct.failedReceiptOrder > DevProduct.failedReceiptCacheMax then
		local oldestId = table.remove(DevProduct.failedReceiptOrder, 1)
		DevProduct.failedReceiptCache[oldestId] = nil
	end
	return true
end

local function processReceipt(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	-- Check if this specific receipt was already processed 
	local existingPurchase = DevProduct.callbacks.isPurchaseCompleted 
							and DevProduct.callbacks.isPurchaseCompleted(player, receiptInfo.PurchaseId)
	if existingPurchase then
		if DevProduct.debugOn then
			warn("Receipt already processed for player:", player.Name, "PurchaseId:", receiptInfo.PurchaseId)
		end
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	-- Get product info
	local productInfo = DevProduct.getProductInfo(receiptInfo.ProductId)
	if not productInfo then
		if DevProduct.debugOn then
			warn(string.format("Failed to get product info for ProductId %d in receipt processing", receiptInfo.ProductId))
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	-- Record the purchase
	local productData = ProductList[receiptInfo.ProductId]
	local purchaseData = {
		ProductId = receiptInfo.ProductId,
		ProductName = productInfo.Name,
		Type = types.Types.DevProduct, 
		Category = productData and productData.Category or "Uncategorized",
		Price = receiptInfo.CurrencySpent,
		Currency = receiptInfo.CurrencyType.Name,
		Status = types.States.Pending,
		PurchaseId = receiptInfo.PurchaseId,
		ReceiptId = receiptInfo.PurchaseId,
		Metadata = {
			PlaceId = receiptInfo.PlaceIdWherePurchased,
			Description = productInfo.Description,
		}
	}
	-- GRANT the item
	local ok, grantSuccess, grantReason = pcall(function()
		if DevProduct.callbacks.onPurchase then
			return DevProduct.callbacks.onPurchase(player, receiptInfo.ProductId)
		end
		return true 
	end)
	if not ok then
		grantReason = tostring(grantSuccess)
		grantSuccess = false
	end
	
	if ok and grantSuccess then
		if DevProduct.callbacks.onSavePurchase then
			pcall(function()
				DevProduct.callbacks.onSavePurchase(player, purchaseData, true)
			end)
		end
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		if DevProduct.callbacks.onSavePurchase and rememberFailedReceipt(receiptInfo.PurchaseId) then
			pcall(function()
				DevProduct.callbacks.onSavePurchase(player, purchaseData, false, grantReason)
			end)
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

function DevProduct.setCallbacks(callbackTable)
	if callbackTable.onPurchase then
		DevProduct.callbacks.onPurchase = callbackTable.onPurchase
	end
	if callbackTable.onSavePurchase then
		DevProduct.callbacks.onSavePurchase = callbackTable.onSavePurchase
	end
	if callbackTable.isPurchaseCompleted then
		DevProduct.callbacks.isPurchaseCompleted = callbackTable.isPurchaseCompleted
	end
end

function DevProduct.purchaseItem(player: Player, productId: number, _): boolean
	return DevProduct.promptPurchase(player, productId)
end

function DevProduct.getProductInfo(productId: number)
	-- Check cache first
	if DevProduct.productInfoCache[productId] then
		return DevProduct.productInfoCache[productId]
	end
	-- Retrieve information about the specified developer product
	local tries = 0
	local success, productInfo = nil, nil
	repeat
		success, productInfo = pcall(function()
			return MarketplaceService:GetProductInfoAsync(productId, Enum.InfoType.Product)
		end)
		if not success then
			tries = tries + 1
			if tries < DevProduct.maxRetries then
				task.wait(0.5) -- Wait before retry
			end
		end
	until success or tries >= DevProduct.maxRetries
	if success and productInfo then
		-- Cache the result
		cacheProductInfo(productId, productInfo)
		return productInfo
	end
	if DevProduct.debugOn then
		warn(string.format("Failed to get product info after %d retries: %s", tries, tostring(productInfo)))
	end
	return nil
end

function DevProduct.promptPurchase(player: Player, productId: number)
	local productInfo = DevProduct.getProductInfo(productId)
	if not productInfo then
		if DevProduct.debugOn then
			warn(string.format("Cannot prompt purchase for invalid product ID %d", productId))
		end
		return false
	end
	MarketplaceService:PromptProductPurchase(player, productId, false)
	return true
end

function DevProduct.clearCache(productId: number?)
	if productId then
		DevProduct.productInfoCache[productId] = nil
		for index, cachedId in ipairs(DevProduct.productInfoCacheOrder) do
			if cachedId == productId then
				table.remove(DevProduct.productInfoCacheOrder, index)
				break
			end
		end
	else
		DevProduct.productInfoCache = {}
		DevProduct.productInfoCacheOrder = {}
	end
end

MarketplaceService.ProcessReceipt = processReceipt
return DevProduct