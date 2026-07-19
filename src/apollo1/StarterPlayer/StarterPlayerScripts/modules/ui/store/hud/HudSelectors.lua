local UiSelectors = require(script.Parent.Parent.ui.UiSelectors)

local HudSelectors = {}

function HudSelectors.selectVisible(state)
    return UiSelectors.selectHudVisible(state) == true
end

function HudSelectors.selectLoading(state)
    return state.Hud.ui.loading
end

function HudSelectors.selectError(state)
    return state.Hud.ui.error
end

function HudSelectors.selectCrafting(state)
    return state.Hud.ui.crafting
end

function HudSelectors.selectTitle(state)
    return state.Hud.title
end

function HudSelectors.selectHint(state)
    return state.Hud.hint
end

return HudSelectors