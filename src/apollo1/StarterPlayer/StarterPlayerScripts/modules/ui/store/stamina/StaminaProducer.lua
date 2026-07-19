local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Reflex = require(ReplicatedStorage.packages.Reflex)
local StaminaState = require(script.Parent.StaminaState)

local StaminaProducer = Reflex.createProducer(
    StaminaState.createInitialState(),
    {
        --STATE
        setLoading = function(state, loading)
            local next = table.clone(state)
            next.ui = table.clone(next.ui)
            next.ui.loading = loading
            return next
        end,

        setError = function(state, error)
            local next = table.clone(state)
            next.ui = table.clone(next.ui)
            next.ui.error = error
            return next
        end,

        setShownAtFull= function(state, shownAtFull)
            local next = table.clone(state)
            next.ui = table.clone(next.ui)
            next.ui.shownAtFull = shownAtFull
            return next
        end,

        reset = function()
            return StaminaState.createInitialState()
        end,
            
        setCurrent = function(state,current)
            local next= table.clone(state)
            next.stamina = table.clone(next.stamina)
            next.stamina.current = current
            return next
        end,

        setMax = function(state,max)
            local next = table.clone(state)
            next.stamina = table.clone(next.stamina)
            next.stamina.max = max
            return next
        end,

        setInfinite = function(state, isInfinite)
            local next = table.clone(state)
            next.stamina = table.clone(next.stamina)
            next.stamina.isInfinite = isInfinite
            return next
        end,

    }
)

return StaminaProducer