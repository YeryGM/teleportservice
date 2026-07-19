local DeathState = {}

function DeathState.createInitialState()
    return {
        ui = {
            loading = false,
            error = nil,
            overviewOpen = false,
        },

        overview = {
            creditsFound = 0,
            creditsEarned = 0,
            multiplier = 1,
            creditsTotal = 0,
            phrase = "Over the stars",
            imageId = ""
        },
        spectator = {
            name = "Player",
        },

        countdown = {
            data = nil,
        },

        waiting = {
            counts = nil,
        }
    }
end

return DeathState