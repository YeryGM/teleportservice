local RootStore = require(script.Parent.Parent.RootStore)

local CraftingActions = {}

function CraftingActions.getState()
    return RootStore.producer.crafting:getState()
end

function CraftingActions.setLoading(value)
    RootStore.producer.crafting.setLoading(value)
end

function CraftingActions.setLoaded(value)
    RootStore.producer.crafting.setLoaded(value)
end

function CraftingActions.setError(value)
    RootStore.producer.crafting.setError(value)
end

function CraftingActions.setSelectedItem(itemId)
    RootStore.producer.crafting.setSelectedItem(itemId)
end

function CraftingActions.setCraftables(payload)
    RootStore.producer.crafting.setCraftables(payload)
end

function CraftingActions.setCraftInfo(craftInfo)
    RootStore.producer.crafting.setCraftInfo(craftInfo)
end

function CraftingActions.setIngredientsOwned(ingredients)
    RootStore.producer.crafting.setIngredientsOwned(ingredients)
end

function CraftingActions.setBombAmounts(bombs)
    RootStore.producer.crafting.setBombAmounts(bombs)
end

return CraftingActions