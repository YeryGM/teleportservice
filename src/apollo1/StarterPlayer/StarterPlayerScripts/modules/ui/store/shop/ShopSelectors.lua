local UiEnums = require(script.Parent.Parent.ui.UiEnums)

local ShopSelectors = {}

function ShopSelectors.selectVisible(state)
    return state.ui.mode == UiEnums.UiMode.Shop
end

function ShopSelectors.selectLoading(state)
    return state.shop.ui.loading
end

function ShopSelectors.selectTransitioned(state)
    return state.shop.ui.transitioned
end

function ShopSelectors.selectError(state)
    return state.shop.ui.error
end

function ShopSelectors.selectItems(state)
    return state.shop.inventory.items
end

function ShopSelectors.selectItem(state, itemId)
    return state.shop.inventory.items[itemId]
end

function ShopSelectors.selectAvailable(state)
    return state.shop.inventory.available
end

function ShopSelectors.selectCredits(state)
    return state.shop.purchase.credits
end

function ShopSelectors.selectSelectedItems(state)
    return state.shop.purchase.selectedItems
end

function ShopSelectors.selectAvailableItem(state, itemId)
    return state.shop.inventory.available[itemId]
end

function ShopSelectors.selectTotalCost(state)
    local total = 0
    local items = state.shop.inventory.items
    local selected = state.shop.purchase.selectedItems
    for itemId, amount in pairs(selected) do
        local item = items[itemId]
        if item then
            total += item.Price * amount
        end
    end
    return total
end

function ShopSelectors.selectCountdownData(state)
    return state.shop.countdown.data
end

function ShopSelectors.selectWaitingCounts(state)
    return state.shop.waiting.counts
end


return ShopSelectors