local ServerScriptService = game:GetService("ServerScriptService")

local datastores = script.Parent.Parent.Parent.datastores
local CreditsDS = require(datastores.CreditsDS)

local types = require(ServerScriptService.modules.general.data.enums.EPurchases)

local rng = Random.new()

local function buildPurchaseId(player: Player, productId: number)
    local timestampMs = DateTime.now().UnixTimestampMillis
    local salt = rng:NextInteger(100000, 999999)
    return string.format("%d-%d-%d-%d", player.UserId, productId, timestampMs, salt)
end

local GameProduct = {
    debugOn = false,
    callbacks = {
        onPurchase = nil,
        onSavePurchase = nil,
        isPurchaseCompleted = nil,
    },
}

function GameProduct.purchaseItem(player:Player, productId:number, data, productData): (boolean, any?)
    data = data or {}
    if not player or type(productId) ~= "number" or type(data) ~= "table" then
        return false
    end
    if not productData then
        if GameProduct.debugOn then
            warn("Missing product data for product ID:", productId)
        end
        return false
    end
    local CreditsDSInstance = CreditsDS.playerMap[player.UserId]
    if not CreditsDSInstance then
        if GameProduct.debugOn then
            warn("No CreditsDS instance found for player:", player.Name)
        end
        return false
        
    end
    --DEDUCT CREDITS
    local price = productData.Price
    if type(price) ~= "number" or price < 0 then
        if GameProduct.debugOn then
            warn("Invalid price for product ID:", productId)
        end
        return false
    end
    local amount = data.amount or 1
    if type(amount) ~= "number" or amount < 1 then
        if GameProduct.debugOn then
            warn("Invalid amount for purchase:", amount)
        end
        return false
    end
    local total = price * amount
    local success, usedCredits, errorMessage = pcall(function()
        return CreditsDSInstance:useCredits(total, productData.Name)
    end)
    if not success then
        errorMessage = tostring(usedCredits)
        usedCredits = false
    end
    if not usedCredits then
        if GameProduct.debugOn then
            warn("Error occurred while using credits for player:", player.Name)
            warn("Error message:", tostring(errorMessage))
        end
        return false
    end
    if not GameProduct.callbacks.onPurchase or not GameProduct.callbacks.onSavePurchase then
        if GameProduct.debugOn then
            warn("Missing purchase callbacks for game product processing.")
        end
        return false
    end
    local purchaseId = buildPurchaseId(player, productId)
    local purchaseData = {
		ProductId = productId,
		ProductName = productData.Name,
		Type = types.Types.GameProduct,
		Category = productData.Category,
		Price = productData.Price,
		Currency = productData.Currency,
		Status = types.States.Pending,
		PurchaseId = purchaseId,
		ReceiptId = purchaseId,
		Metadata = {
			Description = productData.Description,
			Amount = amount,
		}
	}
    --GRANT ITEM
    local success1, granted, grantReason = pcall(function()
        return GameProduct.callbacks.onPurchase(player, productId, data)
    end)
    if not success1 then
        grantReason = tostring(granted)
        granted = false
    end
    if not granted then
        if GameProduct.debugOn then
            warn("Error occurred while processing purchase for player:", player.Name, "Reason:", tostring(grantReason))
        end
        purchaseData.Metadata.GrantFailure = grantReason or "grant_failed"
        local saveOk, saveSuccess, saveReason = pcall(function()
            return GameProduct.callbacks.onSavePurchase(player, purchaseData, false, grantReason)
        end)
        if (not saveOk or not saveSuccess) and GameProduct.debugOn then
            warn("Failed to record failed purchase for player:", player.Name, "Reason:", tostring(saveReason))
        end
        local refundOk, refundSuccess, refundReason = pcall(function()
            return CreditsDSInstance:addCredits(total, "Refund: " .. (productData.Name or "purchase"))
        end)
        if (not refundOk or not refundSuccess) and GameProduct.debugOn then
            warn("Failed to refund credits for player:", player.Name, "Reason:", tostring(refundReason))
        end
        return false
    end
    --SAVE PURCHASE
    local success2, saveResult, saveReason = pcall(function()
        return GameProduct.callbacks.onSavePurchase(player, purchaseData, true)
    end)
    if not success2 or not saveResult then
        if GameProduct.debugOn then
            warn("Error occurred while saving purchase for player:", player.Name, "Reason:", tostring(saveReason))
        end
        return false
    end
    return true, purchaseData
end


function GameProduct.setCallbacks(callbackTable)
	if callbackTable.onPurchase then
		GameProduct.callbacks.onPurchase = callbackTable.onPurchase
	end
	if callbackTable.onSavePurchase then
		GameProduct.callbacks.onSavePurchase = callbackTable.onSavePurchase
	end
	if callbackTable.isPurchaseCompleted then
		GameProduct.callbacks.isPurchaseCompleted = callbackTable.isPurchaseCompleted
	end
end

return GameProduct