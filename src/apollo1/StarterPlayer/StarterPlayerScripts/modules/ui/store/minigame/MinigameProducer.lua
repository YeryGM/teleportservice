local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Reflex = require(ReplicatedStorage.packages.Reflex)
local MinigameState = require(script.Parent.MinigameState)

local function cloneUi(state)
    local next = table.clone(state)
    next.ui = table.clone(state.ui)
    return next
end

local MinigameProducer = Reflex.createProducer(
    MinigameState.createInitialState(),
    {
        --STATE
        setLoading = function(state, loading)
            local next = cloneUi(state)
            next.ui.loading = loading
            return next
        end,

        setError = function(state, error)
            local next = cloneUi(state)
            next.ui.error = error
            return next
        end,

        reset = function()
            return MinigameState.createInitialState()
        end,
    }
)

return MinigameProducer