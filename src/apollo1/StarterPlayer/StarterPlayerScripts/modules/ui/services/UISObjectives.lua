local ObjectivesActions = require(script.Parent.Parent.store.objectives.ObjectivesActions)

local UISObjectives = {}

function UISObjectives:addObjective(objectiveId: number, text: string, subObjectives)
    ObjectivesActions.addObjective(objectiveId, text, subObjectives)
end

function UISObjectives:completeObjective(objectiveId: number)
    ObjectivesActions.completeObjective(objectiveId)
end

function UISObjectives:addSubObjective(objectiveId: number, subObjectiveId: number, text: string)
    ObjectivesActions.addSubObjective(objectiveId, subObjectiveId, text)
end

function UISObjectives:completeSubObjective(objectiveId: number, subObjectiveId: number)
    ObjectivesActions.completeSubObjective(objectiveId, subObjectiveId)
end

function UISObjectives:removeObjective(objectiveId: number)
    ObjectivesActions.removeObjective(objectiveId)
end


return UISObjectives
