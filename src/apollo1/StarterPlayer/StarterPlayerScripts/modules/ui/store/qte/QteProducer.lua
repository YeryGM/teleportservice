local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Reflex = require(ReplicatedStorage.packages.Reflex)
local QteState = require(script.Parent.QteState)

local function cloneUi(state)
    local next = table.clone(state)
    next.ui = table.clone(state.ui)
    return next
end

local QteProducer = Reflex.createProducer(
    QteState.createInitialState(),
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
            return QteState.createInitialState()
        end,
        --QTE
        setActiveQte = function(state, qteId)
            local next = table.clone(state)
            next.activeQte = qteId
            return next
        end,
        setQteData = function(state, qteData)
            local next = table.clone(state)
            next.qteData = qteData
            return next
        end,
    }
)

return QteProducer