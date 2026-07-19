local SubtitlesState = {}

function SubtitlesState.createInitialState()
    return {
        ui = {
            loading = false,
            error = nil,
            sectionsVisible = {
                [1] = false,
                [2] = false,
            }
        },
        title = {
            text = "",
        },
        
        sections = {
            [1] = {
                speaker = "",
                text = "",
            },
            [2] = {
                speaker = "",
                text = "",
            }
        }
    }
end

return SubtitlesState