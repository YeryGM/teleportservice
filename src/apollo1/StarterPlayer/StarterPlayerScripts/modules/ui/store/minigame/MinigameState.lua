local CutsceneState = {}

function CutsceneState.createInitialState()
    return {
        ui = {
            loading = false,
            error = nil,
        },

    }
end

return CutsceneState