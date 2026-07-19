local RootStore = require(script.Parent.Parent.RootStore)

local ShopActions = {}

function ShopActions.getState()
    return RootStore.producer.shop:getState()
end

function ShopActions.setLoading(value:boolean)
    RootStore.producer.shop.setLoading(value)
end

function ShopActions.setError(value)
    RootStore.producer.shop.setError(value)
end

function ShopActions.setItems(items)
    RootStore.producer.shop.setItems(items)
end

function ShopActions.setAvailable(available)
    RootStore.producer.shop.setAvailable(available)
end

function ShopActions.setCredits(credits)
    RootStore.producer.shop.setCredits(credits)
end

function ShopActions.setCountdownData(countDownData)
    RootStore.producer.shop.setCountdownData(countDownData)
end

function ShopActions.setSelectedItems(selectedItems)
    RootStore.producer.shop.setSelectedItems(selectedItems)
end

function ShopActions.setPurchaseResult(purchaseResult)
    RootStore.producer.shop.setPurchaseResult(purchaseResult)
end

function ShopActions.setTransitioned(transitioned)
    RootStore.producer.shop.setTransitioned(transitioned)
end

function ShopActions.setWaitingCounts(counts)
    RootStore.producer.shop.setWaitingCounts(counts)
end

function ShopActions.selectItem(itemId)
    RootStore.producer.shop.selectItem(itemId)
end
function ShopActions.deselectItem(itemId)
    RootStore.producer.shop.deselectItem(itemId)
end

return ShopActions