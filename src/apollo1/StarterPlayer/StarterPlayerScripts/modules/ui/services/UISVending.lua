local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiControllerC = require(script.Parent.UiControllerC)
local Enums = require(ReplicatedStorage.modules.general.configs.Enums)

local remoteFuncs = ReplicatedStorage.funcs.general.purchases
local getItems = remoteFuncs.getItems
local purchaseItem = remoteFuncs.purchaseItem
local purchaseItems = remoteFuncs.purchaseItems

local config = {
    shopTypes = {
        Prerun = Enums.purchases.shopTypes.Prerun,
        Vending = Enums.purchases.shopTypes.Vending,
    },
    limits = {
        maxPurchaseAmount = 10,
    },
}

local ShopService = {
    state = {
        items = {},
        selectedItems = {},
        loading = false,
        loaded = false,
        error = nil,
    },
    listeners = {},
    nextListenerId = 0,
}

local function setState(nextState)
    ShopService.state = nextState
    for _, listener in pairs(ShopService.listeners) do
        listener(nextState)
    end
end

function ShopService.getState()
    return ShopService.state
end

function ShopService.subscribe(listener)
    ShopService.nextListenerId += 1
    local id = ShopService.nextListenerId
    ShopService.listeners[id] = listener
    return function()
        ShopService.listeners[id] = nil
    end
end

function ShopService.loadProducts(shopType: number, force: boolean, countDownData:any?)
    local state = ShopService.state
    if state.loading then
        return
    end
    if state.loaded and not force then
        return
    end

    local nextState = table.clone(state)
    nextState.loading = true
    nextState.error = nil
    setState(nextState)

    local items = getItems:InvokeServer(shopType) or {}

    nextState = table.clone(ShopService.state)
    nextState.loading = false
    nextState.loaded = true
    nextState.items = items
    if countDownData then
        nextState.countDownData = countDownData
        nextState.onCountdownFinished = function()
            ShopService.close(countDownData.cutsceneOnFinish or false)
        end
    end
    setState(nextState)
end


local function isValidPurchase(itemId: number, amount: number)
    local item = ShopService.state.items[itemId]
    if not item then
        return false
    end
    if type(amount) ~= "number" or amount < 1 or amount > config.limits.maxPurchaseAmount then
        return false
    end
    return true
end

function ShopService.purchase(shopType:number, itemId:number, amount:number)
    if not isValidPurchase(itemId, amount) then
        return false
    end
    local ok, purchased = pcall(function()
        return purchaseItem:InvokeServer(shopType, itemId, {amount = amount or 1})
    end)
    if not ok then
        return false
    end
    return purchased
end

function ShopService.purchaseMultiple(shopType:number, items)
    for itemId, amount in pairs(items) do
        if not isValidPurchase(itemId, amount) then
            return false
        end
    end
    local ok, purchased = pcall(function()
        return purchaseItems:InvokeServer(shopType, items)
    end)
    if not ok or not purchased then
        return false
    end
    return true
end

function ShopService.purchaseSelectedItems(shopType:number)
    local selectedItems = ShopService.state.selectedItems[shopType] or {}
    return ShopService.purchaseMultiple(shopType, selectedItems)
end

function ShopService.selectItem(shopType:number, itemId:number)
    local state = ShopService.state
    local nextState = table.clone(state)
    nextState.selectedItems[shopType] = nextState.selectedItems[shopType] or {}
    nextState.selectedItems[shopType][itemId] = (nextState.selectedItems[shopType][itemId] or 0) + 1
    setState(nextState)
end

function ShopService.deselectItem(shopType:number, itemId:number)
    local state = ShopService.state
    local nextState = table.clone(state)
    if not nextState.selectedItems[shopType] or not nextState.selectedItems[shopType][itemId] then
        return
    end
    nextState.selectedItems[shopType][itemId] = nextState.selectedItems[shopType][itemId] - 1
    if nextState.selectedItems[shopType][itemId] <= 0 then
        nextState.selectedItems[shopType][itemId] = nil
    end
    setState(nextState)
end

function ShopService.open(shopType: number, countDownData:any?)
    UiControllerC:setShop()
    ShopService.loadProducts(shopType, false, countDownData)
end

function ShopService.close(override: boolean?)
    if override then
        UiControllerC:setCutscene()
        return
    end
    UiControllerC:setNormal()
end

return ShopService
