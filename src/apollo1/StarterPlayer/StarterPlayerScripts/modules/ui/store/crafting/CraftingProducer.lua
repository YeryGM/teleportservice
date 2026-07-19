local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Reflex = require(ReplicatedStorage.packages.Reflex)

local CraftingState = require(script.Parent.CraftingState)

local CraftingProducer = Reflex.createProducer(
    CraftingState.createInitialState(),
    {

        setLoading = function(state, loading)
            local next = table.clone(state)
            next.ui = table.clone(state.ui)
            next.ui.loading = loading

            return next
        end,

        setError = function(state, error)
            local next = table.clone(state)
            next.ui = table.clone(state.ui)
            next.ui.error = error
            return next
        end,

        setLoaded = function(state, loaded)
            local next = table.clone(state)
            next.ui = table.clone(state.ui)
            next.ui.loaded = loaded
            return next
        end,

        setSelectedItem = function(state, itemId)
            local next = table.clone(state)
            next.ui = table.clone(state.ui)
            next.ui.selectedItemId = itemId
            return next
        end,

        setCraftables = function(state, payload)
            local next = table.clone(state)
            next.recipes = table.clone(state.recipes)
            next.recipes.craftables = payload.craftables
            next.recipes.itemIds = payload.itemIds
            return next
        end,

        setCraftInfo = function(state, craftInfo)
            local next = table.clone(state)
            next.details = table.clone(state.details)
            next.details.craftInfo = craftInfo
            return next
        end,

        setIngredientsOwned = function(state, ingredients)
            local next = table.clone(state)
            next.inventory = table.clone(state.inventory)
            next.inventory.ingredientsOwned = ingredients
            return next
        end,

        setBombAmounts = function(state, bombs)
            local next = table.clone(state)
            next.inventory = table.clone(state.inventory)
            next.inventory.amounts = bombs
            return next
        end,
    }
)

return CraftingProducer