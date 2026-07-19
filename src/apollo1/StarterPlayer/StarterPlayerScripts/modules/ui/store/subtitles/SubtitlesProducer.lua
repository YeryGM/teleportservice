local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Reflex = require(ReplicatedStorage.packages.Reflex)
local SubtitlesState = require(script.Parent.SubtitlesState)

local function cloneUi(state)
    local next = table.clone(state)
    next.ui = table.clone(state.ui)
    return next
end

local SubtitlesProducer = Reflex.createProducer(
    SubtitlesState.createInitialState(),
    {
        --UI
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
            return SubtitlesState.createInitialState()
        end,
        --SUBTITLES
        setSubtitle = function(state, sectionId:number, speaker:string?, text:string)
            if not speaker then
                speaker = ""
            end
            local next = table.clone(state)
            next.sections = table.clone(state.sections)
            next.sections[sectionId] = {
                speaker = speaker,
                text = text
            }

            next.ui = table.clone(state.ui)
            next.ui.sectionsVisible = table.clone(state.ui.sectionsVisible)
            next.ui.sectionsVisible[sectionId] = true
            return next
        end,

        clearSubtitle = function(state, sectionId:number)
            local next = table.clone(state)
            next.ui = table.clone(state.ui)
            next.ui.sectionsVisible = table.clone(state.ui.sectionsVisible)
            next.ui.sectionsVisible[sectionId] = false
            return next
        end,
        isSectionRegistered = function(state, sectionId:number): boolean
            return state.sections[sectionId] ~= nil
        end,
    }
)

return SubtitlesProducer