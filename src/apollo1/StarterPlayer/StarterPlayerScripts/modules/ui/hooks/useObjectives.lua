local ObjectivesSelectors = require(script.Parent.Parent.store.objectives.ObjectivesSelectors)
local useStoreSelector = require(script.Parent.useStoreSelector)

local useObjectives = {}

function useObjectives.useVisible()
    return useStoreSelector(ObjectivesSelectors.selectVisible)
end

function useObjectives.useLoading()
    return useStoreSelector(ObjectivesSelectors.selectLoading)
end

function useObjectives.useError()
    return useStoreSelector(ObjectivesSelectors.selectError)
end

function useObjectives.useObjective(objectiveId)
    return useStoreSelector(ObjectivesSelectors.selectObjective(objectiveId))
end

function useObjectives.useObjectiveVisible(objectiveId)
    return useStoreSelector(ObjectivesSelectors.selectObjectiveVisible(objectiveId))
end

function useObjectives.useObjectives()
    return useStoreSelector(ObjectivesSelectors.selectObjectives)
end

return useObjectives
