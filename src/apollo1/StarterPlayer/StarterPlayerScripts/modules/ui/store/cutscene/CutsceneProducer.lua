local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Reflex = require(ReplicatedStorage.packages.Reflex)
local CutsceneState = require(script.Parent.CutsceneState)

local function cloneUi(state)
    local next = table.clone(state)
    next.ui = table.clone(state.ui)
    return next
end

local CutsceneProducer = Reflex.createProducer(
    CutsceneState.createInitialState(),
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
            return CutsceneState.createInitialState()
        end,

        --BARS
        setBarsActive = function(state, active)
            local next = table.clone(state)
            next.bars = table.clone(state.bars)
            next.bars.active = active
            return next
        end,

        setBarsHeightScale = function(state, heightScale)
            local next = table.clone(state)
            next.bars = table.clone(state.bars)
            next.bars.heightScale = heightScale
            return next
        end,
        --SKIP VOTES
        setSkipVotes = function(state, votes, totalPlayers)
            local next = table.clone(state)
            next.skipVotes = table.clone(state.skipVotes)
            next.skipVotes.votes = votes
            next.skipVotes.totalPlayers = totalPlayers
            return next
        end,
    }
)

return CutsceneProducer