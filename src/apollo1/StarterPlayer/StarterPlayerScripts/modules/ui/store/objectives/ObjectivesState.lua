local ObjectivesState = {}

function ObjectivesState.createInitialState()
    return {
        ui = {
            loading = false,
            error = nil,
        },

        objectives = {
            -- [objectiveId] = {
            --     text = "Objective text",
            --     completed = false,
            --     subObjectives = {
            --         [subObjectiveId] = {
            --             text = "Sub-objective text",
            --             completed = false,
            --         }
        }
    }
end

return ObjectivesState