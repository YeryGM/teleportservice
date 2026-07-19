local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Reflex = require(ReplicatedStorage.packages.Reflex)
local ShopState = require(script.Parent.DeathState)

local ShopProducer = Reflex.createProducer(
    ShopState.createInitialState(),
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

        setOverviewOpen = function(state, overviewOpen)
            local next = table.clone(state)
            next.ui = table.clone(next.ui)
            next.ui.overviewOpen = overviewOpen
            return next
        end,

        reset = function()
            return ShopState.createInitialState()
        end,
        -- OVERVIEW
        setOverviewData = function(state, overviewData)
            local next = table.clone(state)
            next.overview = overviewData
            return next
        end,

        -- SPECTATOR
        setSpectator = function(state, targetName)
            local next = table.clone(state)
            next.spectator = table.clone(next.spectator)
            next.spectator.name = targetName
            return next
        end,

        --COUNTDOWN
        setCountdownData = function(state, data)
            local next = table.clone(state)
            next.countdown = table.clone(next.countdown)
            next.countdown.data = data
            return next
        end,

        -- WAITING
        setWaitingCounts = function(state, counts)
            local next = table.clone(state)
            next.waiting = table.clone(next.waiting)
            next.waiting.counts = counts
            return next
        end
    }
)

return ShopProducer