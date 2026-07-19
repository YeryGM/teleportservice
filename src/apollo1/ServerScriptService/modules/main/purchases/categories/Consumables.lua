local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local general = ReplicatedStorage.modules.general
local Enums = require(general.data.Enums)
local ItemManager = require(ServerScriptService.modules.general.items.ItemManager)
local ConsumablesList = require(ServerScriptService.modules.general.data.Info).Consumables

local productToConsumableMap = {
    [123344] = 100,
    [123345] = 102,
    [123346] = 103,
    [123347] = 104,
}

local requirements = {
	[3456747226] = {
        hasRequirement = false,
	},
	[345678] = {
        hasRequirement = false,
    }
}

local Consumables = {
    debugOn = true,
}

local function getConsumableInfo(productId: number, player: Player, productData)
    if not player or not player:IsA("Player") or not productId then
        if Consumables.debugOn then
            warn("Invalid input for getConsumableInfo. Player or ProductId is missing.")
        end
        return false, "Invalid input"
    end
    local metadata = productData and productData.Metadata or {}
    local consumableId = metadata.consumableId or productToConsumableMap[productId]
    if not consumableId then
        if Consumables.debugOn then
            warn("No consumable mapping found for product ID:", productId)
        end
        return false, "Invalid product"
    end
    local consumableInfo = ConsumablesList[consumableId]
    if not consumableInfo then
        if Consumables.debugOn then
            warn("No consumable info found for consumable ID:", consumableId)
        end
        return false, "Consumable not found"
    end
    return true, consumableId, consumableInfo
end

function Consumables.validatePurchase(player: Player, productId: number, _data: {amount: number}?, productData)
    local isValid, consumableId, _ = getConsumableInfo(productId, player, productData)
    if not isValid then
        return false, tostring(consumableId)
    end
    local requirement = requirements[productId] or requirements[consumableId]
    if requirement and requirement.hasRequirement then
       if Consumables.debugOn then
            print("Checking requirements for consumable ID:", consumableId)
        end
        --return 
    end
    return true
end

function Consumables.grantItem(player: Player, productId: number, data: {amount: number}?, productData)
    local isValid, consumableId, _ = getConsumableInfo(productId, player, productData)
    if not isValid then
        return false, "invalid_consumable"
    end
    local amount = (data and data.amount or 1) * (productData and productData.Amount or 1)
    local success, backPackAdded = pcall(function()
        return ItemManager:addItem(player, amount, consumableId, Enums.items.types.Consumable)
    end)
    if not success or not backPackAdded then
        return false, "grant_failed"
    end
    return true
end

return Consumables