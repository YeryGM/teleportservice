local UiEnums = require(script.Parent.Parent.ui.UiEnums)

local CraftingSelectors = {}

function CraftingSelectors.selectVisible(state)
    return state.ui.mode == UiEnums.UiMode.Crafting
end

function CraftingSelectors.selectLoading(state)
    return state.crafting.ui.loading
end

function CraftingSelectors.selectLoaded(state)
    return state.crafting.ui.loaded
end

function CraftingSelectors.selectError(state)
    return state.crafting.ui.error
end

function CraftingSelectors.selectCraftables(state)
    return state.crafting.recipes.craftables
end

function CraftingSelectors.selectCraftablesById(state)
    return state.crafting.recipes.craftablesById
end

function CraftingSelectors.selectItemIds(state)
    return state.crafting.recipes.itemIds
end

function CraftingSelectors.selectSelectedItemId(state)
    return state.crafting.ui.selectedItemId
end

function CraftingSelectors.selectCraftInfo(state)
    return state.crafting.details.craftInfo
end

function CraftingSelectors.selectIngredientsOwned(state)
    return state.crafting.inventory.ingredientsOwned
end

function CraftingSelectors.selectBombAmounts(state)
    return state.crafting.inventory.amounts
end

function CraftingSelectors.selectIngredientList(state)
    return state.crafting.details.ingredientList
end

function CraftingSelectors.selectBombList(state)
    return state.crafting.details.bombList
end

function CraftingSelectors.selectSelectedBomb(state)

    local selectedItemId =
        state.crafting.ui.selectedItemId

    if not selectedItemId then
        return nil
    end

    return state.crafting.details.bombList[selectedItemId]
end

return CraftingSelectors