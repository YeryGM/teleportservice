local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.modules.general.data.Enums)
local UIActions = require(script.Parent.Parent.store.ui.UiActions)
local ShopActions = require(script.Parent.Parent.store.shop.ShopActions)
local ShopSelectors = require(script.Parent.Parent.store.shop.ShopSelectors)

local remoteFuncs = ReplicatedStorage.funcs.general.purchases
local getItems:RemoteFunction = remoteFuncs.getItems
local purchaseItems:RemoteFunction = remoteFuncs.purchaseItems
local remoteEvents =  ReplicatedStorage.events.general.player
local registerWaitingEvent: RemoteEvent = remoteEvents.registerWaiting

local config = {
    limits = {
        maxPurchaseAmount = 10,
    },
    shopType = Enums.purchases.shopTypes.Prerun,
}

local ShopService = {
    nextListenerId = 0,
}

function ShopService.loadProducts(countDownData)
    ShopActions.setLoading(true)

    local ok, credits, items = pcall(function()
        return getItems:InvokeServer(config.shopType)
    end)

    if not ok then
        ShopActions.setLoading(false)
        ShopActions.setError("Failed to load shop")
        return
    end

    local available = {}
    for itemId, itemData in pairs(items) do
        available[itemId] = itemData.MaxPurchasesPerPlayer
    end
    ShopActions.setItems(items)
    ShopActions.setAvailable(available)
    ShopActions.setCredits(credits)
    ShopActions.setCountdownData(countDownData)
    ShopActions.setLoading(false)
end

function ShopService.confirmPurchase()
    local state = ShopActions.getState()
    local items = table.clone(ShopSelectors.selectSelectedItems(state))
    if next(items) then
        ShopService.purchase(items)
    end
    ShopService.notifyTransition()
    return true
end

function ShopService.purchase(items)
    local function isValidPurchase(itemId: number, amount: number): boolean
        local state = ShopActions.getState()
        local itemss = ShopSelectors.selectItems(state)
        local item = itemss[itemId]
        if not item then
            return false
        end
        if type(amount) ~= "number" or amount < 1 or amount > config.limits.maxPurchaseAmount then
            return false
        end
        return true
    end
    for itemId, amount in pairs(items) do
        if not isValidPurchase(itemId, amount) then
            return false
        end
    end
    local ok, purchased:boolean = pcall(function()
        return purchaseItems:InvokeServer(config.shopType, items)
    end)
    if not ok or not purchased then
        return false
    end
    return true
end

function ShopService.selectItem(itemId)
    local state = ShopActions.getState()
    local item = ShopSelectors.selectItem(state, itemId)
    if not item then
        return
    end

    local available = ShopSelectors.selectAvailableItem(state, itemId)
    if available and available <= 0 then
        return
    end

    local totalCost = ShopSelectors.selectTotalCost(state)
    local credits = ShopSelectors.selectCredits(state)
    if totalCost + item.Price > credits then
        return
    end
    ShopActions.selectItem(itemId)
end

function ShopService.deselectItem(itemId)
    local state = ShopActions.getState()
    local item = ShopSelectors.selectItem(state, itemId)
    if not item then
        return
    end
    local selected = ShopSelectors.selectSelectedItems(state)[itemId]
    if not selected then
        return
    end
    ShopActions.deselectItem(itemId)
end

function ShopService.notifyTransition()
    registerWaitingEvent:FireServer()
    ShopActions.setTransitioned(true)
end

function ShopService.updateCounts(counts)
    ShopActions.setWaitingCounts(counts)
end

function ShopService.open(countDownData)
    UIActions.setShop()
    ShopService.loadProducts(countDownData)
end

function ShopService.close()
    UIActions.setCutscene() 
end

return ShopService
