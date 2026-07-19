local UiEnums = require(script.Parent.Parent.ui.UiEnums)

local MinigameSelectors = {}

function MinigameSelectors.selectVisible(state)
    return state.ui.mode == UiEnums.UiMode.Minigame
end

function MinigameSelectors.selectLoading(state)
    return state.Minigame.ui.loading
end

function MinigameSelectors.selectError(state)
    return state.Minigame.ui.error
end

return MinigameSelectors