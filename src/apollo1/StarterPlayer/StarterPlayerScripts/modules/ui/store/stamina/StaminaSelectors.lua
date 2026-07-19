local UiSelectors = require(script.Parent.Parent.Parent.store.ui.UiSelectors)
local StaminaSelectors = {}

function StaminaSelectors.selectVisible(state)
    return UiSelectors.selectStaminaVisible(state)
end

function StaminaSelectors.selectLoading(state)
    return state.stamina.ui.loading
end

function StaminaSelectors.selectError(state)
    return state.stamina.ui.error
end

function StaminaSelectors.selectCurrent(state)
    return state.stamina.current
end

function StaminaSelectors.selectMax(state)
    return state.stamina.max
end

function StaminaSelectors.selectPercent(state)
    return math.clamp((state.stamina.current / state.stamina.max) or 1, 0, 1)
end

function StaminaSelectors.selectIsFull(state)
    return state.stamina.current == state.stamina.max
end

function StaminaSelectors.selectShownAtFull(state)
    return state.stamina.ui.shownAtFull
end

function StaminaSelectors.selectIsInfinite(state)
    return state.stamina.isInfinite
end


return StaminaSelectors