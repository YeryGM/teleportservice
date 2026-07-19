local RootStore = require(script.Parent.Parent.RootStore)

local ObjectivesActions = {}

function ObjectivesActions.getState()
    return RootStore.producer.objectives:getState()
end

function ObjectivesActions.setLoading(value:boolean)
    RootStore.producer.objectives.setLoading(value)
end

function ObjectivesActions.setError(value:boolean)
    RootStore.producer.objectives.setError(value)
end

function ObjectivesActions.addObjective(objectiveId:number, text:string, subObjectives:{ [number]: string})
    RootStore.producer.objectives.setObjective(objectiveId, text, subObjectives )
end

function ObjectivesActions.completeObjective(objectiveId:number)
    RootStore.producer.objectives.completeObjective(objectiveId)
end

function ObjectivesActions.completeSubObjective(objectiveId:number, subObjectiveId:number)
    RootStore.producer.objectives.completeSubObjective(objectiveId, subObjectiveId)
end

function ObjectivesActions.reset()
    RootStore.producer.objectives.reset()
end

function ObjectivesActions.addSubObjective(objectiveId:number, subObjectiveId:number, text:string)
    RootStore.producer.objectives.setSubObjective(objectiveId, subObjectiveId, text)
end

function ObjectivesActions.removeObjective(objectiveId:number)
    RootStore.producer.objectives.removeObjective(objectiveId)
end

return ObjectivesActions