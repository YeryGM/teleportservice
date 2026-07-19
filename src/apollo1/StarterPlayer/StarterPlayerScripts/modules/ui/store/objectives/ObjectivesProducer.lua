local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Reflex = require(ReplicatedStorage.packages.Reflex)
local ObjectivesState = require(script.Parent.ObjectivesState)

local function cloneUi(state)
    local next = table.clone(state)
    next.ui = table.clone(state.ui)
    return next
end

local ObjectivesProducer = Reflex.createProducer(
    ObjectivesState.createInitialState(),
    {
        --STATE
        setLoading = function(state, loading)
            local next = cloneUi(state)
            next.ui.loading = loading
            return next
        end,

        setError = function(state, error)
            local next = cloneUi(state)
            next.ui.error = error
            return next
        end,

        reset = function()
            return ObjectivesState.createInitialState()
        end,

       completeObjective = function(state, objectiveId)
            local next = table.clone(state)
            next.objectives = table.clone(state.objectives)
            if not next.objectives[objectiveId] then
                return next -- Can't set status of an objective that doesn't exist
            end
            next.objectives[objectiveId].completed = true
            return next
        end,

        setObjective = function(state, objectiveId, text, subObjectives:{ [number]: string })
            local next = table.clone(state)
            next.objectives = table.clone(state.objectives)
            if next.objectives[objectiveId] then
                return next -- Don't overwrite existing objective text or sub-objectives if the objective already exists
            end
            next.objectives[objectiveId] = {
                text = text,
                completed = false,
                subObjectives = subObjectives or {},
            }
            return next
        end,

        completeSubObjective = function(state, objectiveId, subObjectiveId)
            local next = table.clone(state)
            next.objectives = table.clone(state.objectives)
            if not next.objectives[objectiveId] then
                return next -- Can't set status of a sub-objective if the parent objective doesn't exist
            end
            next.objectives[objectiveId].subObjectives = table.clone(next.objectives[objectiveId].subObjectives)
            if not next.objectives[objectiveId].subObjectives[subObjectiveId] then
                return next -- Can't set status of a sub-objective that doesn't exist
            end
            next.objectives[objectiveId].subObjectives[subObjectiveId].completed = true
            return next
        end,

        setSubObjective = function(state, objectiveId, subObjectiveId, text)
            local next = table.clone(state)
            next.objectives = table.clone(state.objectives)
            if not next.objectives[objectiveId] then
                return next -- Can't set a sub-objective if the parent objective doesn't exist
            end
            next.objectives[objectiveId].subObjectives = table.clone(next.objectives[objectiveId].subObjectives)
            if next.objectives[objectiveId].subObjectives[subObjectiveId] then
                return next -- Don't overwrite existing sub-objective text if the sub-objective already exists
            end
            next.objectives[objectiveId].subObjectives[subObjectiveId] = {
                text = text,
                completed = false,
            }
            return next
        end,

        removeObjective = function(state, objectiveId)
            local next = table.clone(state)
            next.objectives = table.clone(state.objectives)
            next.objectives[objectiveId] = nil
            return next
        end,
    }
)

return ObjectivesProducer