local CutsceneState = {}

function CutsceneState.createInitialState()
    return {
        ui = {
            loading = false,
            error = nil,
        },

        bars = {
            active = false,
            heightScale = 0.12,
        },
        skipVotes = {
            votes = 0,
            totalPlayers = 0,
        },
    }
end

return CutsceneState