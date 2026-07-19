local cutsceneSelectors = require(script.Parent.Parent.store.cutscene.CutsceneSelectors)
local useStoreSelector = require(script.Parent.useStoreSelector)

local useCutscene = {}

function useCutscene.selectVisible()
    return useStoreSelector(cutsceneSelectors.selectVisible)
end

function useCutscene.selectLoading()
    return useStoreSelector(cutsceneSelectors.selectLoading)
end

function useCutscene.selectError()
    return useStoreSelector(cutsceneSelectors.selectError)
end

function useCutscene.selectBars()
    return useStoreSelector(cutsceneSelectors.selectBars)
end

function useCutscene.selectSkipVotes()
    return useStoreSelector(cutsceneSelectors.selectSkipVotes)
end

function useCutscene.selectSkipVisible()
    return useStoreSelector(cutsceneSelectors.selectSkipVisible)
end

return useCutscene
