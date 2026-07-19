local UiEnums = require(script.Parent.Parent.ui.UiEnums)

local ObjectiveSelectors = {}

function ObjectiveSelectors.selectVisible(state)
    return state.ui.mode == UiEnums.UiMode.Gameplay and state.ui.components[UiEnums.uiComponents.objectives]
end

function ObjectiveSelectors.selectLoading(state)
    return state.objectives.ui.loading
end

function ObjectiveSelectors.selectError(state)
    return state.objectives.ui.error
end

function ObjectiveSelectors.selectObjectiveVisible(state, objectiveId)
    return state.objectives.objectives[objectiveId] and not state.objectives.objectives[objectiveId].completed
end

function ObjectiveSelectors.selectObjective(state, objectiveId)
    return state.objectives.objectives[objectiveId]
end

function ObjectiveSelectors.selectObjectives(state)
    return state.objectives.objectives
end

return ObjectiveSelectors