local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Reflex = require(ReplicatedStorage.packages.Reflex)
local HudState = require(script.Parent.HudState)

local function cloneUi(state)
    local next = table.clone(state)
    next.ui = table.clone(state.ui)
    return next
end

local HudProducer = Reflex.createProducer(
    HudState.createInitialState(),
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
            return HudState.createInitialState()
        end,
        --Hud
        setCrafting = function(state, on)
            local next = table.clone(state)
            next.ui.crafting = on
            return next
        end,
        setHudTitle = function(state, title)
            local next = table.clone(state)
            next.title = title
            return next
        end,
        setHudHint = function(state, hint)
            local next = table.clone(state)
            next.hint = hint
            return next
        end,
    }
)

return HudProducer