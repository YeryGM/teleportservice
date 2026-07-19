local ShopSelectors = require(script.Parent.Parent.store.shop.ShopSelectors)
local ShopItemSelectors = require(script.Parent.Parent.store.shop.ShopItemSelectors)
local useStoreSelector = require(script.Parent.useStoreSelector)

local useShop = {}

function useShop.useVisible()
    return useStoreSelector(
        ShopSelectors.selectVisible
    )
end

function useShop.useCredits()
    return useStoreSelector(
        ShopSelectors.selectCredits
    )
end

function useShop.useItems()
    return useStoreSelector(
        ShopSelectors.selectItems
    )
end

function useShop.useTransitioned()
    return useStoreSelector(
        ShopSelectors.selectTransitioned
    )
end

function useShop.useCountdown()
    return useStoreSelector(
        ShopSelectors.selectCountdownData
    )
end

function useShop.useWaitingCounts()
    return useStoreSelector(
        ShopSelectors.selectWaitingCounts
    )
end

function useShop.useShopItem(itemId)
   local item = useStoreSelector(
        ShopItemSelectors.selectItem(itemId)
    )

    local available = useStoreSelector(
        ShopItemSelectors.selectAvailable(itemId)
    )

    local selectedAmount = useStoreSelector(
        ShopItemSelectors.selectSelectedAmount(itemId)
    )

    return {
        item = item,
        available = available,
        selectedAmount = selectedAmount,
    }
end

return useShop