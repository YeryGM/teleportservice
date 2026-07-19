local ShopState = {}

function ShopState.createInitialState()
    return {
        ui = {
            transitioned = false,
            loading = false,
            error = nil,
        },

        inventory = {
            items = {},
            available = {},
        },

        purchase = {
            selectedItems = {},
            totalCost = 0,
            credits = 0,
        },

        countdown = {
            data = nil,
        },

        waiting = {
            counts = {},
        },
    }
end

return ShopState