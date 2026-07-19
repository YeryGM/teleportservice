local CraftingItemSelectors = {}

function CraftingItemSelectors.selectCraftable(itemId:number)
    return function(state)
        return state.crafting.recipes.craftables[itemId]
    end
end

function CraftingItemSelectors.selectCraftInfo(itemId:number)
    return function(state)
        return state.crafting.details.craftInfo[itemId]
    end
end

function CraftingItemSelectors.selectOwnedIngredients(itemId:number)
    return function(state)
        return state.crafting.inventory.ingredientsOwned[itemId] or 0
    end
end

function CraftingItemSelectors.selectOwnedBombAmount(itemId:number)
    return function(state)
        return state.crafting.inventory.amounts[itemId] or 0
    end
end

function CraftingItemSelectors.selectBombData(itemId:number)
    return function(state)
        return state.crafting.details.bombList[itemId]
    end
end

return CraftingItemSelectors