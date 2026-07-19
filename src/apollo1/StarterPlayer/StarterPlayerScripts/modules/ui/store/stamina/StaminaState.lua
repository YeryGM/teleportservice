local StaminaState = {}

function StaminaState.createInitialState()
    return {
        ui = {
            loading = false,
            error = nil,
            shownAtFull = false,
        },

        current = 100,
        max = 100,
        isInfinite = false,
    }
end

return StaminaState