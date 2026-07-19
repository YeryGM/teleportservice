local UiEnums = require(script.Parent.Parent.ui.UiEnums)

local DeathSelectors = {}

function DeathSelectors.selectVisible(state)
    return (state.ui.mode == UiEnums.UiMode.Dead or state.ui.mode == UiEnums.UiMode.Spectator)
end

function DeathSelectors.selectIsSpectating(state)
    return state.ui.mode == UiEnums.UiMode.Spectator
end

function DeathSelectors.selectLoading(state)
    return state.death.ui.loading
end

function DeathSelectors.selectError(state)
    return state.death.ui.error
end

function DeathSelectors.selectCountdownData(state)
    return state.death.countdown.data
end

function DeathSelectors.selectWaitingCounts(state)
    return state.death.waiting.counts
end

function DeathSelectors.selectOverviewData(state)
    return state.death.overview
end

function DeathSelectors.selectSpectator(state)
    return state.death.spectator
end

function DeathSelectors.selectOverviewOpen(state)
    return state.death.ui.overviewOpen
end




return DeathSelectors