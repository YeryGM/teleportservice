local SubtitleActions = require(script.Parent.Parent.store.subtitles.SubtitlesActions)

local delay = 0.25

local SubtitlesService = {}

function SubtitlesService.showSubtitle(speaker:string?, text:string, sectionId:number): ()
    SubtitleActions.clearSubtitle(sectionId)
    task.delay(delay, function()
        SubtitleActions.setSectionSubtitle(sectionId, speaker, text)
    end)
end

function SubtitlesService.clearSubtitle(sectionId:number)
   SubtitleActions.clearSubtitle(sectionId)
end

function SubtitlesService.isSectionRegistered(sectionId:number): boolean
    return SubtitleActions.isSectionRegistered(sectionId)
end


return SubtitlesService
