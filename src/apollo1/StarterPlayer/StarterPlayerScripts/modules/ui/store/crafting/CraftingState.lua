
local CraftingState = {}

function CraftingState.createInitialState()
    return {
        ui = {
            loading = false,
            error = nil,
            selectedItemId = nil,
        },

        recipes = {
            craftables = {},
        },

        inventory = {
            ingredientsOwned = {},
        },

        details = {
            ingredientList = {},
            bombList = {},
            craftInfo = nil,
        }
    }
end

return CraftingState