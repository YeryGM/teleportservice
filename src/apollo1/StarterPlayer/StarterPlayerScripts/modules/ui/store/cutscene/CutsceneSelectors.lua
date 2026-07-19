local UiEnums = require(script.Parent.Parent.ui.UiEnums)

local CutsceneSelectors = {}

function CutsceneSelectors.selectVisible(state)
    return state.ui.mode == UiEnums.UiMode.Cutscene
end

function CutsceneSelectors.selectLoading(state)
    return state.Cutscene.ui.loading
end

function CutsceneSelectors.selectError(state)
    return state.Cutscene.ui.error
end

function CutsceneSelectors.selectBars(state)
    return state.Cutscene.bars
end

function CutsceneSelectors.selectSkipVotes(state)
    return state.Cutscene.skipVotes
end

function CutsceneSelectors.selectSkipVisible(state)
    return state.Cutscene.skipVotes.votes > 0
end

return CutsceneSelectors