local UiEnums = require(script.Parent.Parent.ui.UiEnums)

local SubtitleSelectors = {}

function SubtitleSelectors.selectVisible(state)
    return state.ui.components[UiEnums.uiComponents.subtitles]
end

function SubtitleSelectors.selectLoading(state)
    return state.subtitles.ui.loading
end

function SubtitleSelectors.selectError(state)
    return state.subtitles.ui.error
end

function SubtitleSelectors.selectSubtitles(state)
    return state.subtitles.sections
end

function SubtitleSelectors.selectSectionSubtitle(sections, sectionId:number)
    local section = sections[sectionId]
    if not section then
        return nil
    end
    return section
end

function SubtitleSelectors.selectSectionsVisible(state)
    return state.subtitles.ui.sectionsVisible
end

function SubtitleSelectors.selectSectionVisible(sectionsVisible, sectionId:number)
    if not sectionsVisible then
        return false
    end
    return sectionsVisible[sectionId] or false
end

return SubtitleSelectors