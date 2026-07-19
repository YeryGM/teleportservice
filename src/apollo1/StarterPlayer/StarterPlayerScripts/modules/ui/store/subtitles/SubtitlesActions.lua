local RootStore = require(script.Parent.Parent.RootStore)

local SubtitleActions = {}

function SubtitleActions.getState()
    return RootStore.producer.subtitles:getState()
end

function SubtitleActions.setLoading(value:boolean)
    RootStore.producer.subtitles.setLoading(value)
end

function SubtitleActions.setError(value:boolean)
    RootStore.producer.subtitles.setError(value)
end
function SubtitleActions.setSectionSubtitle(sectionId:number, speaker: string?, text:string)
    RootStore.producer.subtitles.setSubtitle(sectionId, speaker, text)
end

function SubtitleActions.clearSubtitle(sectionId:number)
    RootStore.producer.subtitles.clearSubtitle(sectionId)
end

function SubtitleActions.isSectionRegistered(sectionId:number): boolean
    return RootStore.producer.subtitles.isSectionRegistered(sectionId)
end

return SubtitleActions