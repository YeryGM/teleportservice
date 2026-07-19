local UISSubtitles = require(script.Parent.Parent.Parent.ui.services.UISSubtitles)

local Subtitles = {
    currentToken = 0,
    activeSections = {
        [1] = nil,
        [2] = nil
    },
    section = {
        [1] = true,
        [2] = true
    },
}

function Subtitles:displaySubtitle(speaker:string?, text:string, section:number?, duration:number?)
    if not text then
        return
    end
    if duration and duration <= 0 then
        return
    end
    local sectionId  = 0
    if not (section and self.section[section]) then
        sectionId = self:resolveSection()
    else
        sectionId = section
    end
    self:hideSubtitle(sectionId)
    local token = self.currentToken + 1
    self.currentToken = token
    if duration and duration > 0 then
        task.delay(duration, function()
            if self.currentToken == token then
                self:hideSubtitle(sectionId)
            end
        end)
    end
    UISSubtitles.showSubtitle(speaker, text, sectionId)
    self.activeSections[sectionId] = token
end

function Subtitles:hideSubtitle(sectionId:number)
    UISSubtitles.clearSubtitle(sectionId)
    self.activeSections[sectionId] = nil
end

function Subtitles:resolveSection():number
    for sectionId, token in pairs(self.activeSections) do
        if token == nil then
            return sectionId
        end
    end
    return 1
end

return Subtitles