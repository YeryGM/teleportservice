local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reflex = require(ReplicatedStorage.packages.Reflex)
local ShopState = require(script.Parent.ShopState)

local function cloneUi(state)
    local next = table.clone(state)
    next.ui = table.clone(state.ui)
    return next
end

local function cloneInventory(state)
    local next = table.clone(state)
    next.inventory = table.clone(state.inventory)
    return next
end

local function clonePurchase(state)
    local next = table.clone(state)
    next.purchase = table.clone(state.purchase)
    return next
end

local function cloneCountdown(state)
    local next = table.clone(state)
    next.countdown = table.clone(state.countdown)
    return next
end

local function cloneWaiting(state)
    local next = table.clone(state)
    next.waiting = table.clone(state.waiting)
    return next
end

local ShopProducer = Reflex.createProducer(
    ShopState.createInitialState(),
    {
        --STATE
        setLoading = function(state, loading)
            local next = cloneUi(state)
            next.ui.loading = loading
            return next
        end,

        setTransitioned = function(state, transitioned)
            local next = cloneUi(state)
            next.ui.transitioned = transitioned
            return next
        end,

        setError = function(state, error)
            local next = cloneUi(state)
            next.ui.error = error
            return next
        end,

        reset = function()
            return ShopState.createInitialState()
        end,

        --INVENTORY

        setItems = function(state, items)
            local next = cloneInventory(state)
            next.inventory.items = items
            return next
        end,

        setAvailable = function(state, available)
            local next = cloneInventory(state)
            next.inventory.available = available
            return next
        end,

        --PURCHASE

        setCredits = function(state, credits)
            local next = clonePurchase(state)
            next.purchase.credits = credits
            return next
        end,

        --SELECT / DESELECT ITEMS

        selectItem = function(state, itemId)
            local next = table.clone(state)
            next.purchase = table.clone(state.purchase)
            next.inventory = table.clone(state.inventory)
            next.purchase.selectedItems = table.clone(state.purchase.selectedItems)
            next.inventory.available = table.clone(state.inventory.available)
            next.purchase.selectedItems[itemId] = (next.purchase.selectedItems[itemId] or 0) + 1
            next.inventory.available[itemId] = next.inventory.available[itemId] - 1
            return next
        end,
        
        deselectItem = function(state, itemId)
            local next = table.clone(state)
            next.purchase = table.clone(state.purchase)
            next.inventory = table.clone(state.inventory)
            next.purchase.selectedItems = table.clone(state.purchase.selectedItems)
            next.inventory.available = table.clone(state.inventory.available)
            next.purchase.selectedItems[itemId] = (next.purchase.selectedItems[itemId] or 0) - 1
            next.inventory.available[itemId] = next.inventory.available[itemId] + 1
            return next
        end,

        --COUNTDOWN

        setCountdownData = function(state, data)
            local next = cloneCountdown(state)
            next.countdown.data = data
            return next
        end,

        -- WAITING

        setWaitingCounts = function(state, counts)
            local next = cloneWaiting(state)
            next.waiting.counts = counts
            return next
        end
    }
)

return ShopProducer