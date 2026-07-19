local ShopItemSelectors = {}

function ShopItemSelectors.selectItem(itemId)
    return function(state)
        return state.shop.inventory.items[itemId]
    end
end

function ShopItemSelectors.selectAvailable(itemId)
    return function(state)
        return state.shop.inventory.available[itemId]
    end
end

function ShopItemSelectors.selectSelectedAmount(itemId)
    return function(state)
        return state.shop.purchase.selectedItems[itemId] or 0
    end
end

return ShopItemSelectors