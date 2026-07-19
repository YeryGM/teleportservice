local CraftingSelectors = require(script.Parent.Parent.store.crafting.CraftingSelectors)
local CraftingItemSelectors = require(script.Parent.Parent.store.crafting.CraftingItemSelectors)
local useStoreSelector = require(script.Parent.useStoreSelector)

local useCrafting = {}

function useCrafting.useVisible()
    return useStoreSelector(CraftingSelectors.selectVisible)
end

function useCrafting.useLoading()
    return useStoreSelector(CraftingSelectors.selectLoading)
end

function useCrafting.useLoaded()
    return useStoreSelector(CraftingSelectors.selectLoaded)
end

function useCrafting.useError()
    return useStoreSelector(CraftingSelectors.selectError)
end

function useCrafting.useCraftables()
    return useStoreSelector(CraftingSelectors.selectCraftables)
end

function useCrafting.useSelectedItemId()
    return useStoreSelector(CraftingSelectors.selectSelectedItemId)
end

function useCrafting.useCraftInfo()
    return useStoreSelector(CraftingSelectors.selectCraftInfo)
end

function useCrafting.useIngredientsOwned()
    return useStoreSelector(CraftingSelectors.selectIngredientsOwned)
end

function useCrafting.useBombAmounts()
    return useStoreSelector(CraftingSelectors.selectBombAmounts)
end

function useCrafting.useIngredientList()
    return useStoreSelector(CraftingSelectors.selectIngredientList)
end

function useCrafting.useBombList()
    return useStoreSelector(CraftingSelectors.selectBombList)
end

function useCrafting.useSelectedBomb()
    local selectedItemId = useCrafting.useSelectedItemId()
    return useStoreSelector(CraftingItemSelectors.selectBombData(selectedItemId))
end

function useCrafting.useCraftable(itemId: number)
    local item = useStoreSelector(CraftingItemSelectors.selectCraftable(itemId))
    local craftInfo = useStoreSelector(CraftingItemSelectors.selectCraftInfo(itemId))
    local ownedAmount = useStoreSelector(CraftingItemSelectors.selectOwnedIngredients(itemId))
    return {
        item = item,
        craftInfo = craftInfo,
        ownedAmount = ownedAmount,
    }
end

return useCrafting